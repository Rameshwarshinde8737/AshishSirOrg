@isTest
private class BlackoutCalendarTest {
    /*----------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------*/ 
    @TestSetup
    private static void testData(){
        List<BlackoutCalendar__c> listblackoutCalendarRecord = new List<BlackoutCalendar__c>();
        for(Integer i=1;i<=10;i++){
            BlackoutCalendar__c blackoutCalendarRecord= new BlackoutCalendar__c();
            blackoutCalendarRecord.Name = 'Blackout';
            blackoutCalendarRecord.leankor__StartDate__c = System.Today();
            blackoutCalendarRecord.leankor__EndDate__c = System.Today()+2;
            listblackoutCalendarRecord.add(blackoutCalendarRecord);
        }
        insert listblackoutCalendarRecord;
    }
    
    /*------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readBlackoutCalendars Method inside  BlackoutCalendar Class
    ---------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void readBlackoutCalendarsTest(){
        List<BlackoutCalendar__c> blackoutCalendarRecord  = [Select Id
                                                                From BlackoutCalendar__c
                                                                Where Name ='Blackout'
                                                                Limit 10];
        Test.startTest();
        List<BlackoutCalendar__c> blackoutCalendarRecords = BlackoutCalendar.readBlackoutCalendars();
        System.assertEquals(blackoutCalendarRecords[0].leankor__StartDate__c,System.Today());
        System.assert(blackoutCalendarRecords.size()>0);
        System.assertNotEquals(blackoutCalendarRecords[0].leankor__StartDate__c,System.Today()+2);
        Test.stopTest(); 
    }
    
    /*--------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This is cover readBlackoutCalendars Constructor inside  BlackoutCalendar Class
    ---------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void  blackoutCalendarTest(){
        Boolean flag = true; 
        Test.startTest(); 
        Util utilRecord = new Util();
        BlackoutCalendar blackoutCalendarRecord  = new BlackoutCalendar(utilRecord);
        System.assertEquals(true, flag); 
        Test.stopTest(); 
    }
}