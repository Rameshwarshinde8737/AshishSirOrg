global class WeekCalendar {
        global WeekCalendar(Util controller){}
    
   global class InnerClass{
        public String Id;
        public String Name;
        public Boolean Monday;
        public Boolean Tuesday;
        public Boolean Wednesday;   
        public Boolean Thursday;
        public Boolean Friday;
        public Boolean Saturday;
        public Boolean Sunday;
    }
    
    @RemoteAction
    global static  list<InnerClass> readWeekCalendars(){
        
       list<InnerClass> listOfRecords = new list<InnerClass>();
        
        list<leankor__WeekCalendar__c> weekCalendarList = [Select Id, 
                                                                     Name,
                                                                     leankor__Monday__c,
                                                                     leankor__Saturday__c,
                                                                     leankor__Friday__c , 
                                                                     leankor__Sunday__c,
                                                                     leankor__Thursday__c,
                                                                     leankor__Tuesday__c,
                                                                     leankor__Wednesday__c 
                                                            From leankor__WeekCalendar__c
                                                            With Security_Enforced
                                                            Limit 50000];
     
      for(leankor__WeekCalendar__c weekCalendar : weekCalendarList){
      InnerClass weekCalendarRecord =  new InnerClass();
      weekCalendarRecord.Id        =   weekCalendar.id;    
      weekCalendarRecord.Name      =   weekCalendar.Name;
      weekCalendarRecord.Monday    =   weekCalendar.leankor__Monday__c;
      weekCalendarRecord.Tuesday   =   weekCalendar.leankor__Tuesday__c;  
      weekCalendarRecord.Wednesday =   weekCalendar.leankor__Wednesday__c;   
      weekCalendarRecord.Thursday  =   weekCalendar.leankor__Thursday__c;
      weekCalendarRecord.Friday    =   weekCalendar.leankor__Friday__c;  
      weekCalendarRecord.Saturday  =   weekCalendar.leankor__Saturday__c;   
      weekCalendarRecord.Sunday    =   weekCalendar.leankor__Sunday__c;  
      listOfRecords.add(weekCalendarRecord);
       
      }
       
      return listOfRecords;
        
    }
    
  
    @RemoteAction
    global static  list<InnerClass> readWeekCalendarsById(list<String> ids){
        
       list<InnerClass> listOfRecords = new list<InnerClass>();
        
        list<leankor__WeekCalendar__c> weekCalendarList = [Select Id, 
                                                                     Name,
                                                                     leankor__Monday__c,
                                                                     leankor__Saturday__c,
                                                                     leankor__Friday__c , 
                                                                     leankor__Sunday__c,
                                                                     leankor__Thursday__c,
                                                                     leankor__Tuesday__c,
                                                                     leankor__Wednesday__c 
                                                            From leankor__WeekCalendar__c
                                                            where Id = :ids
                                                            With Security_Enforced
                                                            Limit 50000];
     
      for(leankor__WeekCalendar__c weekCalendar : weekCalendarList){
      InnerClass weekCalendarRecord =  new InnerClass();
      weekCalendarRecord.Id        =   weekCalendar.id;    
      weekCalendarRecord.Name      =   weekCalendar.Name;
      weekCalendarRecord.Monday    =   weekCalendar.leankor__Monday__c;
      weekCalendarRecord.Tuesday   =   weekCalendar.leankor__Tuesday__c;  
      weekCalendarRecord.Wednesday =   weekCalendar.leankor__Wednesday__c;   
      weekCalendarRecord.Thursday  =   weekCalendar.leankor__Thursday__c;
      weekCalendarRecord.Friday    =   weekCalendar.leankor__Friday__c;  
      weekCalendarRecord.Saturday  =   weekCalendar.leankor__Saturday__c;   
      weekCalendarRecord.Sunday    =   weekCalendar.leankor__Sunday__c;  
      listOfRecords.add(weekCalendarRecord);
       
      }
      return listOfRecords;
        
    }
}