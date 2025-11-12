global with sharing class TimeCard {
    public TimeCard() {

    }

    public TimeCard(ApexPages.StandardController stdController) {

    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read the all TimeCard that AssignedTo in resourceIds and LogTime in between startDate and endDate.
     Input       : List of resource Id, StartDate if ThimeSheet, EndDate if ThimeSheet
     Output      : List of TimeCard.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeCard__c> readTimeCardsUsers(final List<Id> resourceIds, final DateTime startDateTime, final DateTime endDateTime){
        for (Id resourceId : resourceIds) {
            if (String.isNotBlank(resourceId) && (Util.getSObjectName(resourceId) != 'User')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Changes for Date field to DateTime field.
        DateTime startDateLastTime = startDateTime.dateGMT();
        DateTime endDateLastTime = (endDateTime.dateGmt()).addDays(1);
        endDateLastTime = endDateLastTime.addSeconds(-1);
       
        List<leankor__TimeCard__c> timeCards;
       // Date removedTimePortionStartDate = Date.newInstance(startDateTime.year(),startDateTime.month(),startDateTime.day());
       // Date removedTimePortionEndDate = Date.newInstance(endDateTime.year(),endDateTime.month(),endDateTime.day());
            timeCards = [Select Id,
                                leankor__Subject__c,
                                leankor__Description__c,
                                leankor__Assign_a_User__c,
                                leankor__Assign_a_User__r.Name,
                                leankor__Duration__c,
                                leankor__Estimation__c,
                                leankor__Hours__c,
                                leankor__KanbanCard__c,
                                leankor__KanbanCard__r.Name,
                                leankor__LogTime__c,
                                leankor__Notes__c,
                                leankor__Task__c,
                                OwnerId,
                                leankor__TaskDueDate__c,
                                leankor__AssignedTo__c,
                                leankor__IsBillable__c,
                                leankor__ExpenseAccount__c,
                                leankor__ExpenseCategory__c,
                                leankor__ExpenseSubCategory__c,
                                leankor__ExternalHourlyRate__c,
                                leankor__InternalHourlyRate__c,
                                leankor__TimeScheduleType__c,
                                leankor__TImeSheet__c,
                                leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c 
                            From leankor__TimeCard__c 
                            Where leankor__Assign_a_User__c In: resourceIds 
                                And leankor__LogTime__c >=: startDateLastTime
                                And leankor__LogTime__c <=: endDateLastTime
                            With Security_Enforced
                            Order By leankor__LogTime__c ASC
                            Limit 50000];
        return timeCards;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read the all TimeCard that parent TimeSheet Id in timeSheetIds.
     Input       : List of TimeSheet Id
     Output      : List of TimeCard.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeCard__c> readTimeCardsTimeSheets(final List<Id> timeSheetIds){
        for(Id timeSheetId : timeSheetIds){
            if (String.isNotBlank(timeSheetId) && (Util.getSObjectName(timeSheetId) != 'leankor__TimeSheet__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<leankor__TimeCard__c> timeCards;

        timeCards = [Select Id,
                            leankor__Subject__c,
                            leankor__Description__c,
                            leankor__Assign_a_User__c,
                            leankor__Assign_a_User__r.Name,
                            leankor__Duration__c,
                            leankor__Estimation__c,
                            leankor__Hours__c,
                            leankor__KanbanCard__c,
                            leankor__KanbanCard__r.Name,
                            leankor__LogTime__c,
                            leankor__Notes__c,
                            leankor__Task__c,
                            OwnerId,
                            leankor__TaskDueDate__c,
                            leankor__AssignedTo__c,
                            leankor__IsBillable__c,
                            leankor__ExpenseAccount__c,
                            leankor__ExpenseCategory__c,
                            leankor__ExpenseSubCategory__c,
                            leankor__ExternalHourlyRate__c,
                            leankor__InternalHourlyRate__c,
                            leankor__TimeScheduleType__c,
                            leankor__TImeSheet__c,
                            leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c
                        From leankor__TimeCard__c 
                        Where leankor__TimeSheet__c In: timeSheetIds
                        With Security_Enforced
                        Order By leankor__LogTime__c ASC
                        Limit 50000];
        
        return timeCards;
    } 

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Create The TimeCards that receives in method.
     Input       : List of TimeCard.
     Output      : List of TimeCard.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeCard__c> createTimeCards(final List<leankor__TimeCard__c> timeCards){
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        if (!timeCardBehavior.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__TimeCard__c> timeCardList = new List<leankor__TimeCard__c>();
        try {
            if(timeCards.size() > 0){
                insert timeCards;
            }   
        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return timeCards;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Update The TimeCards that receives in method.
     Input       : List of TimeCard.
     Output      : List of TimeCard.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeCard__c> updateTimeCards(final List<leankor__TimeCard__c> timeCards){
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        if (!timeCardBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }

        for (leankor__TimeCard__c timeCard : timeCards) {
            if (String.isNotBlank(timeCard.Id) && (Util.getSObjectName(timeCard.Id) != 'leankor__TimeCard__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<leankor__TimeCard__c> timeCardList = new List<leankor__TimeCard__c>();
        //24/06/2022 : Changes to remove previous Task detail from TimeCard when linking with new workItem. 
        for (leankor__TimeCard__c timeCard : timeCards) {
            if (timeCard.leankor__KanbanCard__c != null) { 
               timeCard.leankor__Task__c = null;
               timeCard.leankor__Subject__c = null;
               timeCard.leankor__AssignedTo__c = null;
           }
        }
        try {
            if (timeCards.size() > 0) {
                update timeCards;
            }    
        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return timeCards;
    }   
    
    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Clone The TimeCards that receives in method.
     Input       : List of TimeCard.
     Output      : List of TimeCard.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeCard__c> cloneTimeCards(final List<leankor__TimeCard__c> timeCards) {
        for (leankor__TimeCard__c timeCard : timeCards) {
            if (String.isNotBlank(timeCard.leankor__Assign_a_User__c) && (Util.getSObjectName(timeCard.leankor__Assign_a_User__c) != 'User')) {
                throw new Util.LeanException('Error: Invalid input');
            }
            if (String.isNotBlank(timeCard.leankor__KanbanCard__c) && (Util.getSObjectName(timeCard.leankor__KanbanCard__c) != 'leankor__KanbanCard__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
            if (String.isNotBlank(timeCard.leankor__AssignedTo__c) && (Util.getSObjectName(timeCard.leankor__AssignedTo__c) != 'User')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior(); 
        if (!timeCardBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__TimeCard__c> timeCardList = new List<leankor__TimeCard__c>();
		
        for (leankor__TimeCard__c oldTimeCard : timeCards) {
			leankor__TimeCard__c newTimeCard = new leankor__TimeCard__c();
			newTimeCard.leankor__Subject__c = oldTimeCard.leankor__Subject__c;
			newTimeCard.leankor__Assign_a_User__c = oldTimeCard.leankor__Assign_a_User__c;
			newTimeCard.leankor__Duration__c = oldTimeCard.leankor__Duration__c;
			newTimeCard.leankor__Estimation__c = oldTimeCard.leankor__Estimation__c;
			newTimeCard.leankor__Hours__c = oldTimeCard.leankor__Hours__c;
			newTimeCard.leankor__KanbanCard__c = oldTimeCard.leankor__KanbanCard__c;
			newTimeCard.leankor__LogTime__c = oldTimeCard.leankor__LogTime__c;
			newTimeCard.leankor__Notes__c = oldTimeCard.leankor__Notes__c;
			newTimeCard.leankor__Task__c = oldTimeCard.leankor__Task__c;
			newTimeCard.leankor__TaskDueDate__c = oldTimeCard.leankor__TaskDueDate__c;
			newTimeCard.leankor__AssignedTo__c = oldTimeCard.leankor__AssignedTo__c;
			newTimeCard.leankor__IsBillable__c = oldTimeCard.leankor__IsBillable__c;
			newTimeCard.leankor__ExpenseAccount__c = oldTimeCard.leankor__ExpenseAccount__c;
			newTimeCard.leankor__ExpenseCategory__c = oldTimeCard.leankor__ExpenseCategory__c;
			newTimeCard.leankor__ExpenseSubCategory__c = oldTimeCard.leankor__ExpenseSubCategory__c;
			newTimeCard.leankor__ExternalHourlyRate__c = oldTimeCard.leankor__ExternalHourlyRate__c;
			newTimeCard.leankor__InternalHourlyRate__c = oldTimeCard.leankor__InternalHourlyRate__c;
			newTimeCard.leankor__TimeScheduleType__c = oldTimeCard.leankor__TimeScheduleType__c;
			newTimeCard.leankor__TimeSheet__c = oldTimeCard.leankor__TImeSheet__c;
			timeCardList.add(newTimeCard);
		}
        try {
            if(timeCards.size() > 0){
                insert timeCardList;
            }

        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return timeCardList;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Delete The TimeCards that receives in method if parent TimeSheet ApprovalHistoryStatus is empty.
     Input       : List of TimeCard Id.
     Output      : List of TimeCard Id.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<Id> deleteTimeCards(final List<Id> timeCardIds){
        for (Id timeCardId : timeCardIds) {
            if (String.isNotBlank(timeCardId) && (Util.getSObjectName(timeCardId) != 'leankor__TimeCard__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        if (!timeCardBehavior.isDeletable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__TimeCard__c> timeCardList;

        try {
            // To allow deletion if parent�s TimeSheet.ApprovalHistoryStatus is empty
            timeCardList = [Select Id, 
                                    leankor__Assign_a_User__c, 
                                    leankor__AssignedTo__c, 
                                    leankor__KanbanCard__c, 
                                    leankor__TimeSheet__c 
                                From leankor__TimeCard__c 
                                Where Id In: timeCardIds 
                                    And leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c = null
                                With Security_Enforced];
            
            for (leankor__TimeCard__c timeCard : timeCardList) {
                timeCard.leankor__Assign_a_User__c = null;
                timeCard.leankor__AssignedTo__c = null;
                timeCard.leankor__KanbanCard__c = null;
                timeCard.leankor__TimeSheet__c = null;
            }
            
            if (timeCardList.size() > 0) {
                update timeCardList;
                return timeCardIds;
            }
            
        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return new List<Id>();
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : this method read all picklist value for ExpenseAccount field.
     Input       : None
     Output      : List of PicklistValueInfo.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<PicklistValueInfo> getTimeCardExpenseAccount() {
      
       Map<String, TimeCard.PicklistValueInfo> picklistValuesMap = DescribeSchema.getPicklistFieldValueInMap('leankor__TimeCard__c', 'leankor__ExpenseAccount__c', false);
       List<TimeCard.PicklistValueInfo> pickListValues = new List<TimeCard.PicklistValueInfo>();
       List<PicklistValueInfo> pick = new List<PicklistValueInfo>();
        for (String pickList : picklistValuesMap.keySet()) {
            pickListValues.add(picklistValuesMap.get(pickList));
        }

        return pickListValues;
    }
    
    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : this method read all picklist value for ExpenseCategory field.
     Input       : None
     Output      : List of PicklistValueInfo.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<PicklistValueInfo> getTimeCardExpenseCategory() {

       Map<String, TimeCard.PicklistValueInfo> picklistValuesMap = DescribeSchema.getPicklistFieldValueInMap('leankor__TimeCard__c', 'leankor__ExpenseCategory__c', false);
       List<TimeCard.PicklistValueInfo> pickListValues = new List<TimeCard.PicklistValueInfo>();
        for (String pickList : picklistValuesMap.keySet()) {
            pickListValues.add(picklistValuesMap.get(pickList));
        }

        return pickListValues;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : this method read all picklist value for ExpenseSubCategory field.
     Input       : None
     Output      : List of PicklistValueInfo.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<PicklistValueInfo> getTimeCardExpenseSubCategory() {

       Map<String, TimeCard.PicklistValueInfo> picklistValuesMap = DescribeSchema.getPicklistFieldValueInMap('leankor__TimeCard__c', 'leankor__ExpenseSubCategory__c', false);
       List<TimeCard.PicklistValueInfo> pickListValues = new List<TimeCard.PicklistValueInfo>();
        for (String pickList : picklistValuesMap.keySet()) {
            pickListValues.add(picklistValuesMap.get(pickList));
        }

        return pickListValues;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : this method read all picklist value for ScheduleType field.
     Input       : None
     Output      : List of PicklistValueInfo.
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<PicklistValueInfo> getTimeScheduleType() {

        Map<String, TimeCard.PicklistValueInfo> picklistValuesMap = DescribeSchema.getPicklistFieldValueInMap('leankor__TimeCard__c', 'leankor__TimeScheduleType__c', false);
       List<TimeCard.PicklistValueInfo> pickListValues = new List<TimeCard.PicklistValueInfo>();
        for (String pickList : picklistValuesMap.keySet()) {
            pickListValues.add(picklistValuesMap.get(pickList));
        }

        return pickListValues;
    }

    global class PicklistValueInfo {
		public Boolean IsDefaultValue;
        public String Label;
        public String Value ;
	}

    @RemoteAction
    global static void updateTimeCardByOrder(List<leankor__TimeCard__c> timeCards){
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        if (!timeCardBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        for(leankor__TimeCard__c timeCard : timeCards){
            if (String.isNotBlank(timeCard.Id) && (Util.getSObjectName(timeCard.Id) != 'leankor__TimeCard__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
       
        try {
            update timeCards;
        } catch(Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }                                            
    }

}