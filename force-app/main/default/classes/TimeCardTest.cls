@isTest
private class TimeCardTest{
	
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @testSetup
    static void testData(){
        leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c(leankor__startdatetime__c= system.now(),leankor__duedatetime__c = system.now()+2,leankor__EstimatedDuration__c =3 ,Name ='new card');
        insert kanbanCardRecord;
        Profile profileDetails = [Select Id from Profile Where Name='Standard User']; 
        User standardUser = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = profileDetails.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@leankortest.com');
        insert standardUser;
        List<leankor__TimeSheet__c> testTimeSheets = new List<leankor__TimeSheet__c>();
        for(Integer count=0;count<=4;count++){
            leankor__TimeSheet__c TimeSheet = new leankor__TimeSheet__c();
            TimeSheet.Name = 'testTimeSheet-1';
            TimeSheet.leankor__StartDateTime__c = System.now();
            TimeSheet.leankor__EndDateTime__c =System.now()+2;
            TimeSheet.leankor__Resource__c = UserInfo.getUserId();
            if(count==1){
                TimeSheet.leankor__ApprovalHistoryStatus__c = 'pending';
            }
            if(count==2){
                TimeSheet.leankor__Resource__c = standardUser.id;
            }
            testTimeSheets.add(TimeSheet);
        }
        insert testTimeSheets;
        List<leankor__TimeCard__c> testTimeCards = new List<leankor__TimeCard__c>();
        for(Integer count=0; count<=99; count++){
            leankor__TimeCard__c timeCard = new leankor__TimeCard__c();
            timeCard.leankor__AssignedTo__c = UserInfo.getUserId();
            timeCard.leankor__Assign_a_User__c = UserInfo.getUserId();
            timeCard.leankor__Duration__c = 'Hours';
            timeCard.leankor__Estimation__c = 1.0;
            timeCard.leankor__Hours__c = 1.0;
            timeCard.leankor__IsBillable__c = false;
            timeCard.leankor__TimeScheduleType__c = 'Regular';
            timeCard.leankor__Subject__c = 'None';
            timeCard.leankor__Date__c = Date.newInstance(2016, 12, 9);
            timeCard.leankor__KanbanCard__c = kanbanCardRecord.id;
            timeCard.leankor__Notes__c = 'Work is Done by Developer';
            timeCard.leankor__Task__c = 'Task assign to Developer';
            timeCard.leankor__TaskDueDate__c = datetime.newInstance(2020, 04, 30, 12, 30, 0);
            timeCard.leankor__ExpenseAccount__c ='Engineers';
            timeCard.leankor__ExpenseCategory__c = 'Hotel';
            timeCard.leankor__ExpenseSubCategory__c = 'Products';
            timeCard.leankor__ExternalHourlyRate__c = 50000.10;
            timeCard.leankor__InternalHourlyRate__c = 30000.10;
            timeCard.leankor__LogTime__c = System.now()+1;
            if(count>=0 && count<=49){
                //TimeSheet with blank approvalStatusHistory
                timeCard.leankor__TimeSheet__c = testTimeSheets[0].Id; 
            }
            if(count>=50 && count<=99){
                //TimeSheet with Peding approvalStatusHistory
                timeCard.leankor__TimeSheet__c = testTimeSheets[1].Id;
            }
            testTimeCards.add(timeCard);
        }
        insert testTimeCards;
    }
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover readTimeCardsUsers Method inside TimeCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void readTimeCardsUsersTest(){
        List<Id> testIds = new List<Id>();
        DateTime startDateTime = System.now();
        DateTime endDateTime = System.now()+2;
        for(Integer count=0; count<=50;count++){
            Id singleId = UserInfo.getUserId();
            testIds.add(singleId);
        }
        Test.startTest();
        TimeCard instanceOfTimeCardClass = new TimeCard();
        List<leankor__TimeCard__c> resultTimeCard =  leankor.TimeCard.readTimeCardsUsers(testIds, startDateTime, endDateTime);
        System.assert(resultTimeCard.size()>0);
        try{
            List<leankor__TimeCard__c> resultTimeCardNegative =  leankor.TimeCard.readTimeCardsUsers(new List<Id>{'00Dd0000001h60X'}, startDateTime, endDateTime);
        }
        catch (Exception e) {
            System.Assert(e.getMessage().contains('Invalid input'));
        }
        test.stopTest();
    }
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover readTimeCardsTimeSheets Method inside TimeCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void readTimeCardsTimeSheetsTest(){
        Test.startTest();
        List<Id> testIds = new List<Id>();
        for(leankor__TimeSheet__c singeRecords:[Select Id From leankor__TimeSheet__c]){
            testIds.add(singeRecords.Id);
        }
        List<leankor__TimeCard__c> resultTimeCard =  leankor.TimeCard.readTimeCardsTimeSheets(testIds);
        try{
            List<leankor__TimeCard__c> resultTimeCardNegative =  leankor.TimeCard.readTimeCardsTimeSheets(new List<Id>{'00Dd0000001h60X'});   
        }catch (Exception e) {
            System.Assert(e.getMessage().contains('Invalid input'));
        }
        System.assert(resultTimeCard.size()>0);
        test.stopTest();
    }

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover createTimeCards Method inside TimeCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private  static void createTimeCardsTest(){ 
        Test.startTest();
        List<leankor__TimeSheet__c> timeSheet = [Select Id from leankor__TimeSheet__c];
        
        List<leankor__TimeCard__c> listtestTimeCards1 = new List<leankor__TimeCard__c>();
        //TimeCard for blank ApprovalStatusHistory parent
        for(Integer count=0; count<=199; count++){
            leankor__TimeCard__c testTimeCard = new leankor__TimeCard__c();
            testTimeCard.leankor__AssignedTo__c = UserInfo.getUserId();
            testTimeCard.leankor__Assign_a_User__c = UserInfo.getUserId();
            testTimeCard.leankor__Duration__c = 'Hours';
            testTimeCard.leankor__Estimation__c = 1.0;
            testTimeCard.leankor__Hours__c = 1.0;
            testTimeCard.leankor__IsBillable__c = false;
            testTimeCard.leankor__LogTime__c = Date.today()+1;
            testTimeCard.leankor__TimeScheduleType__c = 'Regular';
            testTimeCard.leankor__TimeSheet__c = timeSheet[0].Id;
            testTimeCard.leankor__TimeScheduleType__c = 'Regular';
            listtestTimeCards1.add(testTimeCard);
        }

        // Test Negative scenarios                                 
        List<leankor__TimeCard__c> resultTimeCard1 = leankor.TimeCard.createTimeCards(listtestTimeCards1);
        System.assert(resultTimeCard1.size()>0);
        List<leankor__TimeCard__c> listtestTimeCards2= [Select Id, 
                                                            leankor__AssignedTo__c,
                                                            leankor__Duration__c,
                                                            leankor__Estimation__c
                                                       From leankor__TimeCard__c];
        try {
           List<leankor__TimeCard__c> resultTimeCard2 = leankor.TimeCard.createTimeCards(listtestTimeCards2);
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('INVALID_FIELD_FOR_INSERT_UPDATE'));
            
        }
        test.stopTest();
    }

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover  updateTimeCards Method inside TimeCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private  static void updateTimeCardsTest(){
        Test.startTest(); 
        List<leankor__TimeCard__c> listTimeCard1 = [Select Id, 
                                                       leankor__AssignedTo__c,
                                                       leankor__Duration__c,
                                                       leankor__Estimation__c,
                                                       leankor__Hours__c,
                                                       leankor__IsBillable__c,
                                                       leankor__LogTime__c,
                                                       leankor__TimeScheduleType__c,
                                                       leankor__TimeSheet__c,
                                                       leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c,
                                                       leankor__KanbanCard__c
                                                  From leankor__TimeCard__c
                                                  Where leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c = Null
                                                  And   leankor__TimeSheet__r.leankor__Resource__c =: UserInfo.getUserId()];
       
        for(leankor__TimeCard__c timeCard : listTimeCard1){
            timeCard.leankor__Hours__c = 3.0;
        }
        List<leankor__TimeCard__c> resultTimeCard1 =  leankor.TimeCard.updateTimeCards(listTimeCard1);
        System.assert(resultTimeCard1.size()>0); 

        // Check Validation Rule  for ApprovalHistoryStatus
        // To allow an update of TimeCard__c only if TimeSheet.ApprovalHistoryStatus is empty otherwise throw error
        List<leankor__TimeCard__c> listTimeCard2 = [Select Id, 
                                                        leankor__AssignedTo__c,
                                                        leankor__Duration__c,
                                                        leankor__Estimation__c,
                                                        leankor__Hours__c,
                                                        leankor__IsBillable__c,
                                                        leankor__LogTime__c,
                                                        leankor__TimeScheduleType__c,
                                                        leankor__TimeSheet__c,
                                                        leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c,
                                                        leankor__KanbanCard__c
                                                   From leankor__TimeCard__c
                                                  Where leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c != Null
                                                  And leankor__TimeSheet__r.leankor__Resource__c =: UserInfo.getUserId()];
                                                   
        try{
            List<leankor__TimeCard__c> resultTimeCard2 = leankor.TimeCard.updateTimeCards(listTimeCard2);
        }
        catch (Exception e) {
           
            //System.Assert(e.getMessage().contains('The TimeSheet Resource is not equaled to the TimeCard assigned user or Parent ApprovalHistoryStatus is not null'));
        }

        // Check Validation Rule  for TimeSheet Resource 
        // To allow an update of TimeCard__c only if AssignedTo is the same as TimeSheet.Resource otherwise throw error
        User standardUser = [Select id From user Where Alias = 'standt'];
        List<leankor__TimeCard__c> listTimeCard3 = [Select Id, 
                                                        leankor__AssignedTo__c,
                                                        leankor__Duration__c,
                                                        leankor__Estimation__c,
                                                        leankor__Hours__c,
                                                        leankor__IsBillable__c,
                                                        leankor__LogTime__c,
                                                        leankor__TimeScheduleType__c,
                                                        leankor__TimeSheet__c,
                                                        leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c,
                                                        leankor__KanbanCard__c
                                                   From leankor__TimeCard__c
                                                Where leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c = Null
                                                And leankor__TimeSheet__r.leankor__Resource__c =: standardUser.id];                                  
        try{
            List<leankor__TimeCard__c> resultTimeCard3 = leankor.TimeCard.updateTimeCards(listTimeCard3);
        }
        catch (Exception e) {
            System.Assert(e.getMessage().contains('The TimeSheet Resource is not equaled to the TimeCard assigned user or Parent ApprovalHistoryStatus is not null'));
        }
        test.stopTest();                                            
       
    }
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover  cloneTimeCards Method inside TimeCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private  static void cloneTimeCardsTest(){
        Test.startTest(); 
        List<leankor__TimeCard__c> listTimeCard = [Select Id, 
                                                       leankor__AssignedTo__c,
                                                       leankor__Duration__c,
                                                       leankor__Estimation__c,
                                                       leankor__Hours__c,
                                                       leankor__IsBillable__c,
                                                       leankor__LogTime__c,
                                                       leankor__TimeScheduleType__c,
                                                       leankor__TimeSheet__c,
                                                       leankor__Assign_a_User__c,
                                                       leankor__Subject__c,
                                                       leankor__Date__c,
                                                       leankor__KanbanCard__c,
                                                       leankor__Notes__c,
                                                       leankor__Order__c,
                                                       leankor__Task__c,
                                                       leankor__TaskDueDate__c,
                                                       leankor__ExpenseAccount__c,
                                                       leankor__ExpenseCategory__c,
                                                       leankor__ExpenseSubCategory__c,
                                                       leankor__ExternalHourlyRate__c,
                                                       leankor__InternalHourlyRate__c,
                                                       leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c
                                                  From leankor__TimeCard__c];
        //System.debug('listTimeCard[0]'+listTimeCard[0]);
        List<leankor__TimeCard__c> resultTimeCard = leankor.TimeCard.cloneTimeCards(listTimeCard);
        System.assert(resultTimeCard.size()>0);
        test.stopTest();   
    }
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover  deleteTimeCards Method inside TimeCard Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private  static void deleteTimeCardsTest(){
        Test.startTest(); 
        List<Id>testIds = new List<Id>();
        List<leankor__TimeCard__c> listTimeOfCard = [Select Id, 
                                                         leankor__AssignedTo__c,
                                                         leankor__Duration__c,
                                                         leankor__Estimation__c
                                                    From leankor__TimeCard__c];
                                                      
        for(leankor__TimeCard__c singleTimeCardRecord:listTimeOfCard){
            testIds.add(singleTimeCardRecord.id);
        }
        List<Id> listOfId = leankor.TimeCard.deleteTimeCards(testIds);
        System.assert(listOfId.size()>0);
        test.stopTest();   
    }

    //This Method is cover getTimeCardExpenseAccount Method inside TimeCard Class
    @isTest
    private  static void getTimeCardExpenseAccountTest(){
        Test.startTest(); 
        List<TimeCard.PicklistValueInfo> picklistValueInfos =  leankor.TimeCard.getTimeCardExpenseAccount();
        System.assert(picklistValueInfos.size()>0);                   
        Test.stopTest(); 
    }

    //This Method is cover getTimeCardExpenseCategory Method inside TimeCard Class
    @isTest
    private  static void getTimeCardExpenseCategoryTest(){
        Test.startTest();
        List<TimeCard.PicklistValueInfo> picklistValueInfos =  leankor.TimeCard.getTimeCardExpenseCategory();
        System.assert(picklistValueInfos.size()>0);
        Test.stopTest(); 
    }
    //This Method is cover getTimeCardExpenseSubCategory Method inside TimeCard Class
    @isTest
    private  static void getTimeCardExpenseSubCategoryTest(){
        Test.startTest(); 
        List<TimeCard.PicklistValueInfo> picklistValueInfos =  leankor.TimeCard.getTimeCardExpenseSubCategory();
        System.assert(picklistValueInfos.size()>0);  
        Test.stopTest(); 
    }
    //This Method is cover getTimeCardExpenseSubCategory Method inside TimeCard Class
    @isTest
    private  static void getTimeScheduleTypeTest(){
        Test.startTest(); 
        List<TimeCard.PicklistValueInfo> picklistValueInfos =  leankor.TimeCard.getTimeScheduleType();
        System.assert(picklistValueInfos.size()>0);                        
        Test.stopTest(); 
    }
    
    @isTest
    private static void updateTimeCardByOrderTest(){
        List<leankor__TimeCard__c> listTimeCard = [Select Id, 
                                                            leankor__AssignedTo__c,
                                                            leankor__Duration__c,
                                                            leankor__Estimation__c,
                                                        leankor__Subject__c
                                                    From leankor__TimeCard__c
                                                    Where leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c = Null];
        List<leankor__TimeCard__c> timeCardRecords = new List<leankor__TimeCard__c>();
        for(leankor__TimeCard__c singleRecord:listTimeCard){
            singleRecord.leankor__Subject__c ='demo records';
            timeCardRecords.add(singleRecord);
        }
        Test.startTest();
        TimeCard.updateTimeCardByOrder(listTimeCard);
        leankor__TimeCard__c listTimeCard2 = [Select Id, 
                                                    leankor__AssignedTo__c,
                                                    leankor__Duration__c,
                                                    leankor__Estimation__c,
                                                    leankor__Subject__c
                                            From leankor__TimeCard__c
                                            Where leankor__TimeSheet__r.leankor__ApprovalHistoryStatus__c = Null
                                            Limit 1];
        
        System.assert(listTimeCard2.leankor__Subject__c=='demo records');
        Test.stopTest();
    }
}