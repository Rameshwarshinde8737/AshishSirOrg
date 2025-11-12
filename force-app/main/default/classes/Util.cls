/**
* FILE:  Util.cls
* CLASS: Util
* Description: Contains method related to dateTime calcuation
* USAGE: For date time calculation
*/

global with sharing class Util {
    // Hardcoded the version number due to issue getting the patch number
    // This needs to change every package build
    private final static String LEANKOR_VERSION = '1.309';

 	// This variable is used for isSuccessorRecalculation of Parent Cards
 	public static Map<String, Boolean> recalculateRecord = new Map<String,Boolean>();
    public static Set<String> weekDays = new Set<String>();


    /*--------------------------------------------------------------------------------------------
    Author      : Reynald Ocampo
    Company     : Leankor
    Description : Wrapper class for work week
    Test Class  : TODO
    History     : Created on April 18, 2018
    ----------------------------------------------------------------------------------------------*/    
    public with sharing class WorkWeek {    

        private final Integer ENDWEEKDAYNUMBER = 6;        
        private final Integer MAXTOTALWEEKDAYS = 7;                
        // 1st Jan 1900 is a Monday
		private final Date DATEMONDAY = Date.newInstance(1900, 1, 1);
		public final Integer firstDayOfWeek;
        public final Boolean isSevenDayWorkWeek;

        private final Map<Integer, String> MAPWEEKDAYS = new Map<Integer, String> {
            0 => 'Sunday', 
            1 => 'Monday', 
            2 => 'Tuesday', 
            3 => 'Wednesday', 
            4 => 'Thursday', 
            5 => 'Friday', 
            6 => 'Saturday'
        };

        private final Map<String, Integer> MAPWORKINGWEEKDAYS;       
        // key - the day name
        // value - the position of the day within the week 
        // sample map of a 5-day work week with a start day of Saturday as indicated by the value 1, map is not sorted
        /*
        Monday, 3
        Saturday, 1
        Sunday, 2
        Tuesday, 4
        Wednesday, 5
        */

        private final Map<String, Integer> MAPNONWORKINGWEEKDAYS;

        private final List <leankor__ProjectScheduleBlackout__c>  scheduledBlackout;
        private final Set<Date> blackOutSet;

        // Constructor                  
        // startWeekDay - starting day of the week in number format 
        // numberWeekDays - number of days in a week
        public WorkWeek(final Integer startWeekDay, final Integer numberWeekDays) {
            MAPWORKINGWEEKDAYS = createWorkingWeekDays(startWeekDay, numberWeekDays);
            MAPNONWORKINGWEEKDAYS = createNonWorkingWeekDays(MAPWEEKDAYS.values(), MAPWORKINGWEEKDAYS);
            
            // Date: 02/08/2019
            leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
            firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();  

            // Date: 05/11/2019 - changes for blackout
            blackOutSet = new Set<Date>();
            isSevenDayWorkWeek = numberWeekDays == 7 ? true: false;
        }


        // Constructor Overload
        // startWeekDay - starting day of the week in number format 
        // numberWeekDays - number of days in a week
        // scheduledBlackout - list of blackout records that need to consider in date calculation
        public WorkWeek(final Integer startWeekDay, final Integer numberWeekDays, final List<leankor__ProjectScheduleBlackout__c>  scheduledBlackout) {

            MAPWORKINGWEEKDAYS = createWorkingWeekDays(startWeekDay, numberWeekDays);
            MAPNONWORKINGWEEKDAYS = createNonWorkingWeekDays(MAPWEEKDAYS.values(), MAPWORKINGWEEKDAYS);
            
            // Date: 02/08/2019
            leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
            firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();  

            // Date: 05/11/2019 - changes for blackout
            blackOutSet = new Set<Date>();
            isSevenDayWorkWeek = numberWeekDays == 7 ? true: false;

            if (scheduledBlackout != null) {
                for (leankor__ProjectScheduleBlackout__c blackOut : scheduledBlackout) {
                    Date startDate = blackOut.leankor__StartDate__c;
                    while (startDate <= blackOut.leankor__EndDate__c) {
                        blackOutSet.add(startDate);
                        startDate = startDate +1;
                    }
                }
            }
        }


        // Tilak Raj Mahale: 01.06.2020 - New constructor so that we don't have to get first day of week from custom setting every time we create the workweek instance.
        public WorkWeek(final Integer numberWeekDays, final List<leankor__ProjectScheduleBlackout__c>  scheduledBlackout) {

            leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
            firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();  

            MAPWORKINGWEEKDAYS = createWorkingWeekDays(firstDayOfWeek, numberWeekDays);
            MAPNONWORKINGWEEKDAYS = createNonWorkingWeekDays(MAPWEEKDAYS.values(), MAPWORKINGWEEKDAYS);
    
            blackOutSet = new Set<Date>();
            isSevenDayWorkWeek = (numberWeekDays == 7 ? true: false);

            if (scheduledBlackout != null) {
                for (leankor__ProjectScheduleBlackout__c blackOut : scheduledBlackout) {
                    Date startDate = blackOut.leankor__StartDate__c;
                    while (startDate <= blackOut.leankor__EndDate__c) {
                        blackOutSet.add(startDate);
                        startDate = startDate +1;
                    }
                }
            }
        }

        // Returns a map of the week days
        public Map<Integer, String> readWeekDays() {
            return MAPWEEKDAYS; 
        }

        // Returns a map of the working week days
        public Map<String, Integer> readWorkingDays() {
            return MAPWORKINGWEEKDAYS; 
        }

        // Returns a map of the non-working week days
        public Map<String, Integer> readNonWorkingDays() {
            return MAPNONWORKINGWEEKDAYS; 
        }
                               
        // Returns true if the day is a working day
        // weekDay - the name of the day in long format
        public Boolean isWorkingDay(final String weekDay) {        
            return MAPWORKINGWEEKDAYS.containsKey(weekDay);
        }       
                       
        // Returns true if the day number is a working day
        // weekDay - the number of the day in integer format, 0 = Monday, 6 = Sunday
        public Boolean isWorkingDay(final Integer weekDay) {
            if (weekDay < 0 || weekDay > ENDWEEKDAYNUMBER) {
                return false;
            }
            return isWorkingDay(MAPWEEKDAYS.get(weekDay < 6 ? weekDay + 1 : 0));
        }

        // Returns true if the date is a working day
        // weekDay - date in date format
        public Boolean isWorkingDay(final Date weekDay) {
            return isWorkingDay(getDayIndex(weekDay));
        }
        
        // Returns the day of the week index with Monday being 0
        // Uses 1st Jan 1900 as a Monday reference
        public Integer getDayIndex(Date theDate) {
            return Math.mod(DATEMONDAY.daysBetween(theDate), 7);
        }
        
        // Returns a map of working days in a week
        // startWeekDay - starting day of the week in number format 
        //                0 - Sunday, 1 - Monday, 2 - Tuesday, 3 - Wednesday, 4 - Thursday, 5 - Friday, 6 - Saturday, 
        //                all other values are interpreted as 1
        // numberWeekDays - number of days in a week
        //                1 to 7
        //                all other values are interpreted as 7
        private Map<String, Integer> createWorkingWeekDays(final Integer startWeekDay, final Integer numberWeekDays) {

            Integer startDay = (startWeekDay == null || startWeekDay < 0 || startWeekDay > ENDWEEKDAYNUMBER) ? 1 : startWeekDay;    
            Integer weekDays = (numberWeekDays == null || numberWeekDays < 1 || numberWeekDays > MAXTOTALWEEKDAYS) ? MAXTOTALWEEKDAYS : numberWeekDays;   
            
            Map<String, Integer> workingWeekDays = new Map<String, Integer>();
                            
            for (Integer countLoop = 1; countLoop <= weekDays; countLoop++) {                             
                workingWeekDays.put(MAPWEEKDAYS.get(startDay), countLoop);                
                startDay = (startDay + 1 > ENDWEEKDAYNUMBER) ? 0 : startDay + 1;
            }

            return workingWeekDays;
        }       

        //Returns a map of non-working days in a Week given a list of week days and a map of working weekdays
        // nonWorkingDay map will contains 2 non working days
        // for eg. 1-saturday, 2-sunday 
        private Map<String, Integer> createNonWorkingWeekDays(final List<String> weekDays, final Map<String, Integer> mapWorkingWeekDays) {

        	Map<String, Integer> nonWorkingDays = new Map<String, Integer>();
        	Integer countDay = 1;
        	for (String day : weekDays) {
        		if (!mapWorkingWeekDays.containsKey(day)) {
        			nonWorkingDays.put(day, countDay++);
        		} 
        	}
            return nonWorkingDays;
        }                          


        // Author: Tilak Raj Mahale - Below method's only applicable for Five and Seven day work week ------------------------- 
        
        /**
         * Date: 06/11/2019
         * Returns true if the day is a working else false (Blackout days are considered***).
         */
        public Boolean check_IsWorkingDay(final Date weekDay) {
            if (this.isSevenDayWorkWeek) {
                return this.blackOutSet.contains(weekDay) ? false : true;
            }
    
            Switch on Math.abs(Math.MOD(weekDay.daysBetween(this.DATEMONDAY + (this.firstDayOfWeek !=0 ? (this.firstDayOfWeek -1) :6)) , 7)) {
                
                when 5 { // For Saturday
                    return false;
                }
                when 6 { // For Sunday
                    return false;       
                }
                when else {
                    return this.blackOutSet.contains(weekDay) ? false : true; 
                }
            }
        }
        

        /**
         * Date: 06/11/2019 - Putting this method inside the workWeek class to improve the execution time.
         * Return the number of working day between two given dates.  
         */
        public Integer getBusinessDays(Date startDate, Date dueDate) {	
            Boolean flag = true;

            if (startDate > dueDate) {
                flag= false;
                Date swapDate = startDate;
                startDate = dueDate;
                dueDate = swapDate;
            }

            if (this.isSevenDayWorkWeek) { 
                if (flag) {
                    return startDate.daysBetween(dueDate) - this.getBlackOutCount(startDate, dueDate);
                } else {
                    return -(startDate.daysBetween(dueDate) - this.getBlackOutCount(startDate, dueDate));
                }   
            }

            
            // Variable for extra days between two Dates other then the whole week. 
            Integer days = 0;
            
            // Variable that gives the remaining days when modulus calculate between two dates.
            final Integer DAYINDEX = Math.abs(Math.MOD(startDate.daysBetween(dueDate), 7));

            // Get the start dates day
            Switch on Math.abs(Math.MOD(startDate.daysBetween(this.DATEMONDAY + (this.firstDayOfWeek !=0 ? (this.firstDayOfWeek -1) :6)) ,7)){

                when 0 { // For monday
                    switch on DAYINDEX { 
                        when 1{days= 2;}when 2{days= 3;}when 3{days= 4;}when 4{days= 5;}when 5{days= 5;}when 6{days= 5;}when else{days = 1;}
                    }                
                }
                when 1 { // For Tuesday
                    switch on DAYINDEX {					
                        when 1{days= 2;}when 2{days= 3;}when 3{days= 4;}when 4{days= 4;}when 5{days= 4;}when 6{days= 5;}when else{days = 1;}
                    }                
                }
                when 2 { // For Wednesday
                    switch on DAYINDEX {
                        when 1{days= 2;}when 2{days= 3;}when 3{days= 3;}when 4{days= 3;}when 5{days= 4;}when 6{days= 5;}when else{days = 1;}
                    }                
                }
                when 3 { // For Thrusday
                    switch on DAYINDEX {
                        when 1{days= 2;}when 2{days= 2;}when 3{days= 2;}when 4{days= 3;}when 5{days= 4;}when 6{days= 5;}when else{days = 1;}
                    }                
                }
                when 4 { // For Friday
                    switch on DAYINDEX {
                        when 1{days= 1;}when 2{days= 1;}when 3{days= 2;}when 4{days= 3;}when 5{days= 4;}when 6{days= 5;}when else{days = 1;}
                    }                
                }
                when 5 { // For Saturday
                    switch on DAYINDEX {
                        when 1{days= 0;}when 2{days= 1;}when 3{days= 2;}when 4{days= 3;}when 5{days= 4;}when 6{days= 5;}when else{days = 0;}
                    }                
                }
                when 6 { // For Sunday
                    switch on DAYINDEX {
                        when 1{days= 1;}when 2{days= 2;}when 3{days= 3;}when 4{days= 4;}when 5{days= 5;}when 6{days= 5;}when else{days = 0;}
                    }                
                }
            }

            // Here we calculate days between two dates and then divide by 7 then multiply the quotient by 5 and add the remaining days.
            if (flag) {
                return (days + Integer.valueOf((Math.Floor((startDate.daysBetween(dueDate)/7))*5)-1) 
                                    - this.getBlackOutCount(startDate, dueDate));
            } else {
                return -(days + Integer.valueOf((Math.Floor((startDate.daysBetween(dueDate)/7))*5)-1) 
                                    - this.getBlackOutCount(startDate, dueDate));
            } 
        }


        /**
         * Date: 06/11/2019 - Putting this method inside the workWeek class to improve the execution time.
         * Return the start/Due date when Due/Start date and Estimate duration are given.  
         */
        public DateTime nextBusinessDate(Datetime currentBusinessDate, Integer dateDifference) {
            Datetime initialDate = currentBusinessDate;
            Boolean flag = dateDifference < 0 ? false : true;


            if (this.isSevenDayWorkWeek == true) {

                // Ramanand : 25/june/2024 - addding dates if week calendar not applied because week calendar code required initial date. 
                if (weekDays.size() <= 1) {
                	currentBusinessDate = currentBusinessDate.addDays(dateDifference);
                }
                
                    Integer blackOutCount = this.getBlackOutCount(initialDate.date(), currentBusinessDate.date());
                    
                if (flag) {
                    
                    while (blackOutCount > 0) { 
                        currentBusinessDate = currentBusinessDate.addDays(1);
                        if (this.check_IsWorkingDay(currentBusinessDate.date())) {
                            blackOutCount--;
                        }
                    }

                    //return currentBusinessDate;
                    Integer countDay = 1;
                    /*
                    while(countDay <= dateDifference) {
                        currentBusinessDate = currentBusinessDate.addDays(1);
                        if(this.check_IsWorkingDay(currentBusinessDate.date()) && (!weekDays.contains((currentBusinessDate).format('E')))){
                            i++;
                        }
                    } */
                    
                    if (weekDays.size() > 1) {
                        while (countDay <= dateDifference) {
                            currentBusinessDate = currentBusinessDate.addDays(1);
                            if (!weekDays.contains((currentBusinessDate).format('E'))) {
                                countDay++;
                            }
                        }
                    }

                    return currentBusinessDate;     
                } else {
                    
                    while (blackOutCount > 0) {
                        currentBusinessDate = currentBusinessDate.addDays(-1);
                        if (this.check_IsWorkingDay(currentBusinessDate.date())) {
                            blackOutCount--;
                        }
                    }
                    //return currentBusinessDate;
                    Integer countDay = 1;
                    //if(weekDays.size() > 1) {
                       /* while(i<=(-dateDifference)){
                        currentBusinessDate = currentBusinessDate.addDays(-1);
                        if(this.check_IsWorkingDay(currentBusinessDate.date()) && (!weekDays.contains((currentBusinessDate).format('E')))){
                            i++;
                        }
                        } */
                    //}
                    
                    if (weekDays.size() > 1) {
                        while (countDay <= (-dateDifference)) {
                            currentBusinessDate = currentBusinessDate.addDays(-1);
                            if (!weekDays.contains((currentBusinessDate).format('E'))) {
                                countDay++;
                            }
                        }
                    }

                    return currentBusinessDate;
                }
            }

            Integer days = 0;
            /** Finding the day of the Start/Due date */
            Integer dayOfWeek = Math.abs(Math.MOD(currentBusinessDate.date().daysBetween(this.DATEMONDAY + (this.firstDayOfWeek !=0 ? (this.firstDayOfWeek -1) :6)) ,7));

            if (flag) {
 
                Switch on dayOfWeek {
                    
                    when 0 { // For Monday	
                        //System.debug('Monday');		
                        /** In case of monday we don't have to do anything. 
                        It's managed by 'Divide and Modulus' formula in the last.*/	               
                    }
                    when 1 { // For Tuesday
                        //System.debug('Tuesday');
                        /** If start date is Tuesday and no. of working days are more than 3 days then we are going in the next week. 
                        So here we subtracting the 4 days from total working days and by adding 6 days in start date we shift start date to Monday. 
                        Later by using Divide and modulas formula we get the last date of card. Same thing has been done for all days. 
                        In case of Saturday and Sunday we dont have to decrease the working days because they are non-working days.  */
                        if (dateDifference > 3) { 
                            days = 6; 
                            dateDifference = dateDifference - 4;
                            currentBusinessDate = currentBusinessDate.addDays(days);
                        }               
                    }
                    when 2 { // For Wednesday
                        //System.debug('Wednesday');
                        if (dateDifference > 2) {
                            days = 5;
                            dateDifference = dateDifference-3;
                            currentBusinessDate = currentBusinessDate.addDays(days);
                        }                
                    }
                    when 3 { // For Thrusday
                        //System.debug('Thrusday');
                        if (dateDifference > 1) {
                            days = 4;
                            dateDifference = dateDifference-2;
                            currentBusinessDate = currentBusinessDate.addDays(days);
                        }              
                    }
                    when 4 { // For Friday
                        //System.debug('Friday');
                        if (dateDifference >= 1) {
                            days = 3;
                            dateDifference = dateDifference-1;
                            currentBusinessDate = currentBusinessDate.addDays(days);
                        }              
                    }
                    when 5 { // For Saturday
                        //System.debug('Saturday');
                        days = 2;
                        dateDifference = dateDifference;
                        currentBusinessDate = currentBusinessDate.addDays(days);      
                    }
                    when 6 { // For Sunday
                        //System.debug('Sunday'); 
                        days=1;
                        dateDifference = dateDifference;
                        currentBusinessDate = currentBusinessDate.addDays(days);          
                    }
                }

                currentBusinessDate = currentBusinessDate.addDays(Math.abs(Math.MOD(dateDifference, 5))+ (Math.abs(dateDifference/5)*7));
                Integer blackOutCount = this.getBlackOutCount(initialDate.date(), currentBusinessDate.date());

                while (blackOutCount > 0) {
                    currentBusinessDate = currentBusinessDate.addDays(1);
                    if (this.check_IsWorkingDay(currentBusinessDate.date())) {
                        blackOutCount--;
                    }
                }

                return currentBusinessDate;
            } else {
                dateDifference = Math.abs(dateDifference); // making positive for calculation
                /** By subtracting specific number of days we making every due date as Friday** so that the 'Divide and Modulus' formula 
                calculate the exact Start date because that formula only work for Friday in case of backward date calculation. */
                Switch on dayOfWeek {
                    when 0 { // For Monday
                        /** If Due date is Monday and no. of working days are more than 1 days then we are going in the previous week. 
                        So here we substract the 1 days from total working days and by subtracting 3 days in due date. We shifted due date to friday. 
                        Later by using 'Divide and Modulas' formula we get the start date of card. Same thing has been done for all days. 
                        In case of Saturday and Sunday we dont have to decrease the working days because they are non working days.  */
                        if (dateDifference >= 1) {
                            days = 3;
                            dateDifference = dateDifference-1;
                            currentBusinessDate = currentBusinessDate.addDays(-days);
                        }  			               
                    }
                    when 1 { // For Tuesday
                        if (dateDifference > 1) {
                            days=4;
                            dateDifference = dateDifference-2;
                            currentBusinessDate = currentBusinessDate.addDays(-days);
                        }                
                    }
                    when 2 { // For Wednesday
                        if (dateDifference > 2) {
                            days=5;
                            dateDifference = dateDifference-3;
                            currentBusinessDate = currentBusinessDate.addDays(-days);
                        }                
                    }
                    when 3 { // For Thrusday
                        if (dateDifference > 3) {
                            days=6;
                            dateDifference = dateDifference-4;
                            currentBusinessDate = currentBusinessDate.addDays(-days);
                        }              
                    }
                    when 4 { // For Friday 
                        /* Works as Monday in backward direction calculation.*/
                        /* In case of Friday we don't have to do anything. It's managed by 'Divide and Modulas' formula in the last.*/	            
                    }
                    
                    when 5 { // For Saturday
                        days=1;
                        dateDifference = dateDifference;
                        currentBusinessDate = currentBusinessDate.addDays(-days);           
                    }
                    when 6 { // For Sunday
                        days=2;
                        dateDifference = dateDifference;
                        currentBusinessDate = currentBusinessDate.addDays(-days);        
                    }
                }

                currentBusinessDate = currentBusinessDate.addDays(-(Math.abs(Math.MOD(dateDifference, 5))+ (Math.abs(dateDifference/5)*7)));
                Integer blackOutCount = this.getBlackOutCount(initialDate.date(), currentBusinessDate.date());
                    
                while (blackOutCount > 0) {
                    currentBusinessDate = currentBusinessDate.addDays(-1);
                    if (this.check_IsWorkingDay(currentBusinessDate.date())) {
                        blackOutCount--;
                    }
                }

                return currentBusinessDate;
            } 
        }


        /**
        * Date: 06/11/2019
        * Return the number of blackouts between two dates
        */
        private Integer getBlackOutCount(Date startDate, Date dueDate) {
            Integer blackOutCount = 0; 

            if (startDate > dueDate) {
                Date swapDate = startDate;
                startDate = dueDate;
                dueDate = swapDate;
            }

            if (this.isSevenDayWorkWeek) {
                for (Date blackOutDate : this.blackOutSet) {
                    // If blackout date falls between start and due date then increase the count
                    if (blackOutDate >= startDate && blackOutDate <= dueDate) { 
                        blackOutCount ++;
                    }
                }

                return blackOutCount;
            }

            for (Date blackOutDate : this.blackOutSet) {
                // If blackout date falls between start and due date and a working day then increase the count
                if (this.isWorkingDay(blackOutDate) && blackOutDate >= startDate && blackOutDate <= dueDate) {      
                    blackOutCount ++;
                }
            }

            return blackOutCount;
        }


        /**
         * Date: 08/11/2019
         * Return the next working if Start/Due date occured on blackout or Saturday/Sunday 
         */
        public Datetime getNextWorkingDay(Datetime weekDay) {
            while (!this.check_IsWorkingDay(weekDay.date()) || (weekDays.contains(((DateTime)weekDay).format('E')))) {
                weekDay = weekDay.addDays(1);
            }
            return weekDay;
        } 


        /**
         * Date: 08/11/2019
         * Return the previous working if Start/Due date occured on blackout or Saturday/Sunday 
         */
        public Datetime getPreviousWorkingDay(Datetime weekDay) {
            while (!this.check_IsWorkingDay(weekDay.date()) || (weekDays.contains(((DateTime)weekDay).format('E')))) {
                weekDay = weekDay.addDays(-1);
            }
            return weekDay;
        } 


        /**
        * Date: 17/12/2019
        * Return the Due datetime of the card depends upon the input.
        */
        public Datetime getKanbanCardDueDate(Integer ED, String durationUnit, Datetime startDateTime) {
            Switch on durationUnit {
                when 'Hours'{
                    if (math.mod(ED,8) > 0) {
                        ED = Integer.valueof(ED/8) + 1;
                    } else {
                        ED = Integer.valueof(ED/8);
                    }
                }
                when 'Years'{
                    startDateTime = startDateTime.addYears(ED);
                    startDateTime = startDateTime -1 ;
                }
                when 'Months'{
                    startDateTime = startDateTime.addMonths(ED);
                    startDateTime = startDateTime -1 ;
                }
                when 'Minutes'{
                    integer temphours;
                    if (math.mod(ED,60) >0 ) {
                        temphours = Integer.valueof(ED/60) + 1;
                    } else {
                        temphours= Integer.valueof(ED/60);
                    }
                    if (math.mod(temphours,8) >0) {
                        ED = Integer.valueof(temphours/8) + 1;
                    } else {
                        ED = Integer.valueof(temphours/8);
                    }
                }
                when 'Weeks'{
                    ED = Integer.valueof(ED * (this.isSevenDayWorkWeek ? 7: 5));
                }
            }

            if (durationUnit != 'Months' && durationUnit != 'Years' ) {
                ED = (ED == 0? 1: ED); // This condition for milestone
                startDateTime = this.nextBusinessDate(startDateTime, (ED-1));
            } else {
                // In case of month and year get the next working day if occured on holidays
                startDateTime = this.getNextWorkingDay(startDateTime);
            }

            return startDateTime;
        }


        /**
        * Date: 17/12/2019
        * Return the start datetime of the card depends upon the input.
        */
        public Datetime getKanbanCardStartDate(Integer ED, String durationUnit, Datetime dueDateTime) {
            Switch on durationUnit {
                when 'Hours'{
                    if (math.mod(ED,8) > 0) {
                        ED = Integer.valueof(ED/8) + 1;
                    } else {
                        ED = Integer.valueof(ED/8);
                    }
                }
                when 'Years'{
                    dueDateTime = dueDateTime.addYears(-ED);
                    dueDateTime = dueDateTime -1 ;
                }
                when 'Months'{
                    dueDateTime = dueDateTime.addMonths(-ED);
                    dueDateTime = dueDateTime -1 ;
                }
                when 'Minutes'{
                    integer temphours;
                    if (math.mod(ED,60) >0 ) {
                        temphours = Integer.valueof(ED/60) + 1;
                    } else {
                        temphours= Integer.valueof(ED/60);
                    }
                    if (math.mod(temphours,8) >0) {
                        ED = Integer.valueof(temphours/8) + 1;
                    } else {
                        ED = Integer.valueof(temphours/8);
                    }
                }
                when 'Weeks'{
                    ED = Integer.valueof(ED * (this.isSevenDayWorkWeek ? 7: 5));
                }
            }

            if (durationUnit != 'Months' && durationUnit != 'Years' ) {
                ED = (ED == 0? 1: ED); // This condition for milestone
                dueDateTime = this.nextBusinessDate(dueDateTime, -(ED-1));
            } else {
                // In case of month and year get the next working day if occured on holidays
                dueDateTime = this.getPreviousWorkingDay(dueDateTime);
            }

            return dueDateTime;
        }
        // Author: Tilak Raj Mahale ------------------------------------------------------------------------

    }// End of the WorkWeek Class
     

    
    /*--------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read next working day escaping non working days
     Input       : WorkWeek wrapper class object, DateTime
     Output      : IF currentDateTime is a working datetime then currentDateTime ELSE next working datetime
     ------------------------------------------------------------------------------------------------------*/ 
    public static Datetime readNextWorkingDateTime(WorkWeek workWeek, Datetime currentDateTime) {
        Datetime nextWorkingDateTime = currentDateTime;
        try {
            while (!workWeek.isWorkingDay(nextWorkingDateTime.format('EEEE')) || workWeek.blackOutSet.contains(nextWorkingDateTime.date())) {
                nextWorkingDateTime = nextWorkingDateTime + 1;
            }
        }
        catch (Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }       
        return nextWorkingDateTime;
    }
    

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read previous working day escaping non working days
     Input       : WorkWeek wrapper class object, DateTime
     Output      : IF currentDateTime is a working datetime then currentDateTime ELSE previous working datetime
     ----------------------------------------------------------------------------------------------------------*/ 
    public static Datetime readPreviousWorkingDateTime(WorkWeek workWeek, Datetime currentDateTime) {
        Datetime previousWorkingDateTime = currentDateTime;
        try {
            while (!workWeek.isWorkingDay(previousWorkingDateTime.format('EEEE')) || workWeek.blackOutSet.contains(previousWorkingDateTime.date())) {
                previousWorkingDateTime = previousWorkingDateTime - 1;
            }
        }
        catch (Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }       
        return previousWorkingDateTime;
    }


    /*-----------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read next working day escaping non working days
     Input       : WorkWeek wrapper class object, DateTime, Date
     Output      : IF currentDate is a working date then currentDate ELSE next working datet
     ------------------------------------------------------------------------------------------------------*/
    public static Date readNextWorkingDate(WorkWeek workWeek, Datetime currentDateTime, Date currentDate) {
        Date nextWorkingDate = currentDate; 
        try {       
            while (!workWeek.isWorkingDay(currentDateTime.format('EEEE')) || workWeek.blackOutSet.contains(currentDateTime.date())) {
                nextWorkingDate = nextWorkingDate + 1;
                currentDateTime = currentDateTime + 1;
            }
        }
        catch (Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }       
        return nextWorkingDate;
    } 
    

    /*---------------------------------------------------------------------------
     Company     : Leankor
     Description : Read next working day escaping non working days
     Input       : WorkWeek wrapper class object, Date
     Output      : Next working date
     ----------------------------------------------------------------------------*/
    public static Date readNextWorkingDate(WorkWeek workWeek, Date currentDate) {
        Date nextWorkingDate = currentDate + 1; 
        try {       
            while (!workWeek.isWorkingDay(nextWorkingDate) ||  workWeek.blackOutSet.contains(nextWorkingDate)) {
            	          	            	
                nextWorkingDate = nextWorkingDate + 1;
            }
        }
        catch (Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }       
        return nextWorkingDate;
    } 
        

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read previous working day escaping non working days
     Input       : WorkWeek wrapper class object, DateTime, Date
     Output      : IF currentDate is a working date then currentDate ELSE previous working date
     ----------------------------------------------------------------------------------------------------------*/
    public static Date readPreviousWorkingDate(WorkWeek workWeek, Datetime currentDateTime, Date currentDate) {
        Date previousWorkingDate = currentDate;
        try {
            while (!workWeek.isWorkingDay(currentDateTime.format('EEEE')) || workWeek.blackOutSet.contains(currentDateTime.date())) {
                previousWorkingDate = previousWorkingDate - 1;
                currentDateTime = currentDateTime - 1;
            }
        }
        catch (Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }       
        return previousWorkingDate;
    }   
     

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read previous working day escaping non working days
     Input       : WorkWeek wrapper class object, Date
     Output      : Previous working date
     --------------------------------------------------------------------------------*/
    public static Date readPreviousWorkingDate(WorkWeek workWeek, Date currentDate) {
        Date previousWorkingDate = currentDate - 1;
        try {
            while (!workWeek.isWorkingDay(previousWorkingDate) || workWeek.blackOutSet.contains(previousWorkingDate)) {
                previousWorkingDate = previousWorkingDate - 1;
            }
        }
        catch (Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }       
        return previousWorkingDate;
    }

 	// gets the CurrencyIsoCode of a given record
	public static String getCurrencyIsoCode(Object record) {		
		String currencyIsoCode = '';
		
		try {
			Map<String, Object> stringObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record));
			currencyIsoCode = (String)stringObject.get('CurrencyIsoCode');
		} catch (Exception e) {
			throw e; 
		}
		
		return currencyIsoCode;
	}	
    
    
    /**------------------------------------------------------------
        Company: 		Leankor
        Description: 	Calculate start date of the week as per first day of week value from custom setting.
        Inputs: 		Date
        Returns: 		Date
        History:        Created on September 28, 2019
	---------------------------------------------------------------*/
	public static Date getStartOfTheWeek(Date currentDate) {

        // We always use the custom setting first day of week. So it's doesn't matter what we put in WorkWeek instance.
        Util.WorkWeek workWeek = new Util.WorkWeek(1, 5);

        // Get the day of given date
        Integer dayOfWeek = Math.abs(Math.MOD(currentDate.daysBetween(workWeek.DATEMONDAY + (workWeek.firstDayOfWeek != 0 ? (workWeek.firstDayOfWeek -1) :6)) , 7));

        // Depends upon the day minus those many days to get the start of the week
        currentDate = dayOfWeek != 0 ? currentDate.addDays(-dayOfWeek): currentDate;

        return currentDate;
	}


    // To Handle the exception 
    global class LeanException extends Exception{}

    /** /

        Can be removed??

    //SS 10.05.2018
	//Commented these methods because these are not using any where.
	/*
    // helper functions to use javascript inside apex!  
    // http://boards.developerforce.com/t5/Visualforce-Development/Accessing-Javascript-variable-from-Visualforce-page/td-p/142046
    
    public static String getJSStart() {
        return '<script>document.write(';
    }
       
    public static String getJSEnd() {
        return ')</script>';
    }

    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields 
    // USAGE:
    //      String soql = Util.getCreatableFieldsSOQL('lead','id=\'00Q3000000aKwVN\'');
    //      lead l = (Lead)Database.query(soql);
    //      lead l2 = l.clone(false, true);
    //      insert l2;
    //
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;     
    }*/


    public class UtilConfig {
        public  String pageNameSpace;
        public ProjectBoardCarousel.ObjectAccess baseSecurity;
    }


    public static String getUtilConfig() {
        UtilConfig util = new Utilconfig();
        util.baseSecurity = ProjectBoardCarousel.checkBaseSecurity();
        util.pageNameSpace =realTimecontroller.getPageNamespace('Visualkanban');
        return JSON.serialize(util); 
    }
	
	/*------------------------------------------------------------
	Author: 		Dharma Penugonda
	Company: 		Leankor
	Description: 	Sanitize where clause to prevent Injection vulnerability
	Inputs: 		String whereClause
	Returns: 		String
	------------------------------------------------------------*/    
    public static String parseWhereClause(String whereClause) {
        if (String.isBlank(whereClause)) {
            return '';
        }

        String[] arrayOfStrings = whereClause.replace('\\','').split('\'');
        String replacedString = arrayofStrings[0];

        if (arrayOfStrings.size() > 1) {
            for (integer key=1;key<arrayOfStrings.size();key++) {
                replacedString += '\'' + string.escapeSingleQuotes(arrayOfStrings[key]) + '\'';
                if (arrayOfStrings.size() > key+1) {
                    key++;
                    replacedString += arrayOfStrings[key];
                }
            }
        }

        return replacedString;
    }


    public static String getSObjectName(String recordId) {
        return (recordId InstanceOf Id) ? Id.valueOf(recordId).getSObjectType().getDescribe().getName() : '';
    }


    /*----------------------------------------------------------------------------------------------
     Description : Calculate Sprint end date by using sprint start date and day per
     Input       : valueStream- the board detail StartSprint date and DayPerSprint value.
     Output      : retrun Sprint end date.
     -----------------------------------------------------------------------------------------------*/ 
    public static Datetime getSprintEndDate(leankor__ValueStream__c valueStream) {
        leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
        Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();	

        List<leankor__ProjectScheduleBlackout__c> blackOutList = [Select leankor__EndDate__c,       
                                                                            leankor__StartDate__c
                                                                        From leankor__ProjectScheduleBlackout__c
                                                                        Where leankor__ProjectBoard__c =: valueStream.Id
                                                                        With Security_Enforced
                                                                        Limit 10000];
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, valueStream.leankor__SevenDayWorkWeek__c ? 7 : 5, blackOutList);
        return workWeek.nextBusinessDate(valueStream.leankor__SprintStartDate__c, (Integer)valueStream.DaysPerSprint__c -1);
    }
	 // This code does not work for getting the patch number
    // System.requestVersion().patch() always returns null
    /*
    public static String readPackageVersion() {
        String packageVersion = '';
        try {
            if (System.requestVersion().patch() != null) {
                packageVersion = System.requestVersion().major() + '.' + System.requestVersion().minor() + '.' + System.requestVersion().patch();
            } else {
                packageVersion = System.requestVersion().major() + '.' + System.requestVersion().minor();
            }   
        } catch (Exception ex) {
            System.debug('Exception : ' + ex.getMessage());
        }
        return packageVersion;
    }
    
	// Returns the package version given the package's namespace prefix
    // namespacePrefix - the namespace prefix of the package
   public static String readPackageVersion(String namespacePrefix) {
        String packageVersion = '';
        try {
            ToolingAPI tool = new ToolingAPI();
            HttpResponse packageVersionResponse = tool.query('Select+Id,SubscriberPackage.NamespacePrefix,SubscriberPackage.Name,SubscriberPackageVersion.MajorVersion,SubscriberPackageVersion.MinorVersion,SubscriberPackageVersion.PatchVersion+From+InstalledSubscriberPackage');
            System.debug(packageVersionResponse.getBody());
            if (packageVersionResponse.getStatusCode() == 200) {
                InstalledPackage installedPackage = (InstalledPackage)JSON.deserialize(packageVersionResponse.getBody(), InstalledPackage.class);
                System.debug('installedPackage '+installedPackage);
                System.debug('installedPackage.records '+installedPackage.records);
                for (RecordPackage record : installedPackage.records) {
                    System.debug('NameSpace '+record.subscriberPackage.namespacePrefix);
                    if (record.subscriberPackage.namespacePrefix == namespacePrefix) {
                        packageVersion = record.subscriberPackageVersion.majorVersion + '.' + 
                            record.subscriberPackageVersion.minorVersion + '.' +
                            record.subscriberPackageVersion.patchVersion;
                        break;
                    }
                }
            }
        }
        catch (Exception ex){
            System.debug('Exception occured : ' + ex.getMessage());
        }           
        return packageVersion;
    }


    private class InstalledPackage {
        List<RecordPackage> records;
    }


    private class RecordPackage {
        String id;
        SubscriberPackage subscriberPackage;
        SubscriberPackageVersion subscriberPackageVersion;
    }

    private class SubscriberPackage {
        String name;
        String namespacePrefix;
    }

    private class SubscriberPackageVersion {
        Integer majorVersion;
        Integer minorVersion;
        Integer patchVersion;
    }*/

	// Returns the hardcoded version number of Leankor
    public static String readPackageVersion() {
        return LEANKOR_VERSION;
    }

    /*----------------------------------------------------------------------------------------------
     Description : Summation of uncompleted points and total points per board
     Input       : valueStreamId - the board id, masterContainerTypes - set of mastercontainer types
     Output      : uncompletedPoints and totalPoints fields as AggregateResult
     -----------------------------------------------------------------------------------------------*/    
     public static AggregateResult readWorkItemPoints(Id valueStreamId, Set<String> masterContainerTypes) {
        return [Select Sum(UncompletedPoints__c) uncompletedPoints,
                        Sum(leankor__Point__c) totalPoints
                    From leankor__KanbanCard__c
                    Where leankor__ValueStream__c = :valueStreamId
                        And leankor__MasterContainer__r.leankor__Type__c In :masterContainerTypes
                        And leankor__IsRecordDeleted__c = false
                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                    With Security_Enforced];
    }


    /*----------------------------------------------------------------------------------------------
     Description : Secure Coding SQL Injection - Securing Variable Object Names
     Input       : sObjectName, the API name of the sObject
     Output      : true if object is valid and accessible else false
     -----------------------------------------------------------------------------------------------*/ 	
    // Secure Coding SQL Injection - Securing Variable Object Names
	public static Boolean isObjectAccessible(String objectName) {
		Boolean isObjectAccessible = false;
		if (String.isNotBlank(objectName)) {
			SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
			isObjectAccessible = objectType != null && objectType.getDescribe().isAccessible();
		}    
		return isObjectAccessible;   
	}

    /*----------------------------------------------------------------------------------------------
     Description : Read the profile name
     Input       : profile id
     Output      : profile name
     -----------------------------------------------------------------------------------------------*/ 
     public static String readUserProfileName(Id profileId) {
        return [Select Name 
                    From Profile 
                    Where Id = :profileId].Name;
    }

    public static String getDomainUrl() {
        String leankorBaseURL = '';
        if (String.isNotBlank(Network.getNetworkId())) {
            leankorBaseURL = 'https://' + DomainCreator.getExperienceCloudSitesHostname();
        } else {
            leankorBaseURL = 'https://' + DomainCreator.getOrgMyDomainHostname();
        }
        return leankorBaseURL;
    }

    public static Map<Id, String> getRecordTypeMap() {
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        for (Schema.RecordTypeInfo recordType : Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfos()) {
            recordTypeMap.put(recordType.getRecordTypeId(), recordType.getDeveloperName());
        }
        return recordTypeMap;
    }

    /*----------------------------------------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    This method is used by the community to append a suffix to the URL 
	    Returns:        This method is Return URLPathPrefix  of the community
	---------------------------------------------------------------------------------------------*/
    public static String getUrlPathPrefix() {
        //For community need to add community suffix name in the Url
        String suffix;
        String networkId = Network.getNetworkId();
        if (String.isNotBlank(networkId)) {
            for (sObject tempNetwork : Database.query('Select Id, UrlPathPrefix From Network Where Id =: networkId')) {
                if (tempNetwork.get('UrlPathPrefix') != null) {
                    suffix = '/' + (String)tempNetwork.get('UrlPathPrefix');
                } else {
                    //If community does not have any suffix then make blank
                    suffix = '';
                }
            }
        }
        return suffix;
    }

}