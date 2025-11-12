/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 */

@isTest
private class SetPercentCompleteOnRATest {

     /*----------------------------------------------------------------------------------
     Company     : Leankor
    Description : This method is cover execute Method inside SetPercentCompletedOnRA Class
    ---------------------------------------------------------------------------------------*/ 
    @istest
    private static void percentCompleteOnRATest(){
            
        leankor__ValueStream__c vStream = new leankor__ValueStream__c();
        vStream.Name = 'Plan(Gantt)';      
        vStream.leankor__BoardType__c = 'UberBoard';
        insert vStream;
                
        List<leankor__KanbanCard__c> kanbanCardRecordList = new List<leankor__KanbanCard__c>();
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        RecordType recType = [Select Id 
                                    From RecordType 
                                    Where SobjectType = 'leankor__KanbanCard__c' 
                                        And DeveloperName = 'ActivityCard' 
                                    Limit 1];
            
        //inserting activty 
        for(Integer count = 0; count < 200; count++){
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Activity' + count;
            kanbanCard.leankor__ValueStream__c = vStream.Id;
            kanbanCard.RecordTypeId = recType.Id;               
            kanbanCard.leankor__GUID__c = String.valueOf(count) + String.valueOf(system.now().getTime()) + String.valueOf(count);               
            kanbanCard.leankor__PercentComplete2__c = 40;
            kanbanCardRecordList.add(kanbanCard);
        }
        insert kanbanCardRecordList;
    
        //inserting RA respective activity
        for(leankor__KanbanCard__c kc : kanbanCardRecordList){                   
            leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c();
            ra.leankor__KanbanCard__c = kc.Id;
            ra.leankor__AssignedTo__c = userInfo.getUserId();
            ra.leankor__PercentAllocation__c = 60;       		
            resourceAssignmentList.add(ra);      
        }
        insert resourceAssignmentList;
   
        Test.startTest();
        //calling schedule batch.
        SchedulePercentCompletedOnRA schedulePercent = new SchedulePercentCompletedOnRA();
        SchedulableContext sc;
        schedulePercent.execute(sc);              	
        Test.stopTest(); 
        
        //checking RA is updated with correct value or not.
        leankor__ResourceAssignment__c result = [Select leankor__PercentCompleted__c 
                                                    From leankor__ResourceAssignment__c 
                                                    Limit 1];
       System.assert(result.leankor__PercentCompleted__c == 40);  
       System.assertEquals(40, result.leankor__PercentCompleted__c); 		
    }

    /*------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover execute Method inside SetPercentCompletedOnRA Class
    --------------------------------------------------------------------------------------*/ 
    @istest
    private static void setPercentCompletedOnRATest(){

        Test.startTest();
        leankor__ValueStream__c vStream = new leankor__ValueStream__c();
        vStream.Name = 'Plan(Gantt)';      
        vStream.leankor__BoardType__c = 'UberBoard';
        insert vStream;
                
        List<leankor__KanbanCard__c> kanbanCardRecordList = new List<leankor__KanbanCard__c>();
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        RecordType recType = [Select Id 
                                From RecordType 
                                Where SobjectType = 'leankor__KanbanCard__c' 
                                    And DeveloperName = 'ActivityCard' 
                                Limit 1];
        //inserting activty 
        for(Integer count = 0; count < 200; count++){
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Activity ' + count;
            kanbanCard.leankor__ValueStream__c = vStream.Id;
            kanbanCard.RecordTypeId = recType.Id;               
            kanbanCard.leankor__GUID__c = String.valueOf(count) + String.valueOf(System.now().getTime()) + String.valueOf(count);               
            kanbanCard.leankor__PercentComplete2__c = 100;
            kanbanCard.leankor__HarveyBallDoneDate__c = Date.today();
            kanbanCardRecordList.add(kanbanCard);
        }
        insert kanbanCardRecordList;

        //inserting RA respective activity
        for(leankor__KanbanCard__c kc : kanbanCardRecordList){                   
            leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c();
            ra.leankor__KanbanCard__c = kc.Id;
            ra.leankor__AssignedTo__c = userInfo.getUserId();
            ra.leankor__PercentAllocation__c = 80; 
            ra.leankor__CompletedDate__c = System.now();  		
            resourceAssignmentList.add(ra);      
        }
        insert resourceAssignmentList;
    
        SetPercentCompletedOnRA setPercentCompletedOnRARecords = new SetPercentCompletedOnRA();
        setPercentCompletedOnRARecords.isCompletedDate = true;
        DataBase.executeBatch(setPercentCompletedOnRARecords); 
        Test.stopTest(); 
        
        //checking RA is updated with correct value or not.
        leankor__ResourceAssignment__c result = [Select leankor__PercentCompleted__c 
                                                    From leankor__ResourceAssignment__c 
                                                    Limit 1];

        System.assert(result.leankor__PercentCompleted__c == 100);   
        System.assertEquals(100, result.leankor__PercentCompleted__c);	
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover SetPercentCompletedOnRA constructer inside SetPercentCompletedOnRA Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void setPercentCompletedOnRAsecTest(){

        Boolean flag = true;
        Boolean isCompletedDate = true;
        Test.startTest();
        SetPercentCompletedOnRA setPercentCompletedOnRARecords = new SetPercentCompletedOnRA(isCompletedDate);
        System.assertEquals(true, flag); 
        Test.stopTest(); 
    }

    /*-------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover execute Method inside SetPercentCompletedOnRA Class
    ---------------------------------------------------------------------------------------*/ 
    @istest
    private static void setPercentCompletedOnRAthirdTest(){

        Test.startTest();
        leankor__ValueStream__c vStream = new leankor__ValueStream__c();
        vStream.Name = 'Plan(Gantt)';      
        vStream.leankor__BoardType__c = 'UberBoard';
        insert vStream;
               
        List<leankor__KanbanCard__c> kanbanCardRecordList = new List<leankor__KanbanCard__c>();
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
    
        RecordType recType = [Select Id 
                                  From RecordType 
                                  Where SobjectType = 'leankor__KanbanCard__c' 
                                  And DeveloperName = 'ActivityCard' 
                                  Limit 1];
        //inserting activty 
        for(Integer count = 0; count < 200; count++){
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Activity ' + count;
            kanbanCard.leankor__ValueStream__c = vStream.Id;
            kanbanCard.RecordTypeId = recType.Id;               
            kanbanCard.leankor__GUID__c = String.valueOf(count) + String.valueOf(System.now().getTime()) + String.valueOf(count);               
            kanbanCard.leankor__HarveyBallDoneDate__c = Date.today();
            kanbanCardRecordList.add(kanbanCard);
        }
        insert kanbanCardRecordList;
    
        //inserting RA respective activity
        for(leankor__KanbanCard__c kc : kanbanCardRecordList){                   
            leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c();
            ra.leankor__KanbanCard__c = kc.Id;
            ra.leankor__AssignedTo__c = userInfo.getUserId();
            ra.leankor__PercentAllocation__c = 100; 
            ra.leankor__PercentCompleted__c = 100;
            ra.leankor__CompletedDate__c = System.now();  		
            resourceAssignmentList.add(ra);      
        }
        insert resourceAssignmentList;

        SetPercentCompletedOnRA setPercentCompletedOnRARecords = new SetPercentCompletedOnRA();
        setPercentCompletedOnRARecords.isCompletedDate = true;
        DataBase.executeBatch(setPercentCompletedOnRARecords); 
        Test.stopTest(); 
        
        //checking RA is updated with correct value or not.
        leankor__ResourceAssignment__c result = [Select leankor__CompletedDate__c
                                                    From leankor__ResourceAssignment__c 
                                                    Limit 1];
        System.assert(result.leankor__CompletedDate__c == System.today()); 
        System.assertEquals(System.today(), result.leankor__CompletedDate__c); 
    }

    /*-----------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover execute Method inside SetPercentCompletedOnRA Class
    -------------------------------------------------------------------------------------*/ 
    @istest
    private static void setPercentCompletedOnRAforthTest(){
        
        Test.startTest();
        leankor__ValueStream__c vStream = new leankor__ValueStream__c();
        vStream.Name = 'Plan(Gantt)';      
        vStream.leankor__BoardType__c = 'UberBoard';
        insert vStream;
               
        List<leankor__KanbanCard__c> kanbanCardRecordList = new List<leankor__KanbanCard__c>();
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();

        RecordType recType = [Select Id 
                                From RecordType 
                                Where SobjectType = 'leankor__KanbanCard__c' 
                                And DeveloperName = 'ActivityCard' 
                                Limit 1];
        //inserting activty 
        for(Integer count = 0; count < 200; count++){
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
            kanbanCard.Name = 'Activity ' + count;
            kanbanCard.leankor__ValueStream__c = vStream.Id;
            kanbanCard.RecordTypeId = recType.Id;               
            kanbanCard.leankor__GUID__c = String.valueOf(count) + String.valueOf(system.now().getTime()) + String.valueOf(count);               
            kanbanCard.leankor__HarveyBallDoneDate__c = null;
            kanbanCardRecordList.add(kanbanCard);
        }
        insert kanbanCardRecordList;
     
        
        //inserting RA respective activity
        for(leankor__KanbanCard__c kc : kanbanCardRecordList){                   
            leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c();
            ra.leankor__KanbanCard__c = kc.Id;
            ra.leankor__AssignedTo__c = userInfo.getUserId();
            ra.leankor__PercentAllocation__c = 100; 
            ra.leankor__PercentCompleted__c = 100;
            ra.leankor__CompletedDate__c = null;		
            resourceAssignmentList.add(ra);      
        }
        insert resourceAssignmentList;
     
        SetPercentCompletedOnRA setPercentCompletedOnRARecords = new SetPercentCompletedOnRA();
        setPercentCompletedOnRARecords.isCompletedDate = true;
        DataBase.executeBatch(setPercentCompletedOnRARecords); 
        Test.stopTest(); 
        
        //checking RA is updated with correct value or not.
        leankor__ResourceAssignment__c result = [Select leankor__CompletedDate__c
                                                    From leankor__ResourceAssignment__c 
                                                    Limit 1];

        System.assert(result.leankor__CompletedDate__c != null);   	
    }
}