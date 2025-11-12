@isTest
private with sharing class ProjectScheduleBlackoutTriggerTest {

    private @TestSetup
    static void makeData(){
        
        // Value Stream records are created
        leankor__ValueStream__c vs_1 = new leankor__ValueStream__c(Name = 'PS_Blackout_Test_VS_01');
        INSERT vs_1;
        leankor__ValueStream__c vs_2 = new leankor__ValueStream__c(Name = 'PS_Blackout_Test_VS_02');
        INSERT vs_2;

        // Kanban card are created on Values Stream(vs_1) 
        leankor__KanbanCard__c kc =new leankor__KanbanCard__c();
        kc.Name='Test Card__01';
        kc.leankor__StartDate__c = System.today()-5;
        kc.leankor__DueDate__c = System.today()+3;
        kc.leankor__GUID__c=TestDataFactory.createGuid();          
        kc.leankor__ValueStream__c= vs_1.id;
        INSERT kc;

        leankor__KanbanCard__c kc_1 =new leankor__KanbanCard__c();
        kc_1.Name='Test Card__02';
        kc_1.leankor__StartDate__c = System.today()-10;
        kc_1.leankor__DueDate__c = System.today()+10;
        kc_1.leankor__GUID__c=TestDataFactory.createGuid();          
        kc_1.leankor__ValueStream__c= vs_1.id;
        INSERT kc_1;

        leankor__KanbanCard__c kc_2 =new leankor__KanbanCard__c();
        kc_2.Name='Test Card__03';
        kc_2.leankor__StartDate__c = System.today()+3;
        kc_2.leankor__DueDate__c = System.today()+10;
        kc_2.leankor__GUID__c=TestDataFactory.createGuid();          
        kc_2.leankor__ValueStream__c= vs_1.id;
        INSERT kc_2;

        leankor__KanbanCard__c kc_3 =new leankor__KanbanCard__c();
        kc_3.Name='Test Card__04';
        kc_3.leankor__StartDate__c = System.today()-20;
        kc_3.leankor__DueDate__c = System.today()+60;
        kc_3.leankor__GUID__c=TestDataFactory.createGuid();          
        kc_3.leankor__ValueStream__c= vs_1.id;
        INSERT kc_3;

        // Project Schedule Blackout records are created for Value Stream(vs)
        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
        blackOut.leankor__EndDate__c = System.today()+5;
        blackOut.leankor__StartDate__c = System.today();
        blackOut.leankor__ProjectBoard__c = vs_1.Id; 
        INSERT blackOut;

        leankor__ProjectScheduleBlackout__c blackOut_1 = new leankor__ProjectScheduleBlackout__c();
        blackOut_1.leankor__EndDate__c = System.today()+20;
        blackOut_1.leankor__StartDate__c = System.today()+10;
        blackOut_1.leankor__ProjectBoard__c = vs_1.Id; 
        INSERT blackOut_1;

        leankor__ProjectScheduleBlackout__c blackOut_3 = new leankor__ProjectScheduleBlackout__c();
        blackOut_3.leankor__EndDate__c = System.today()-5;
        blackOut_3.leankor__StartDate__c = System.today()-15;
        blackOut_3.leankor__ProjectBoard__c = vs_1.Id; 
        INSERT blackOut_3;
    }

    private @IsTest
    static void testBlackoutInsert(){

        leankor__ValueStream__c vs_1;
        leankor__ValueStream__c vs_2;

        List<leankor__ValueStream__c> vsList = [SELECT Id,
                                                Name,
                                                leankor__IsScheduleRecalculate__c
                                            FROM leankor__ValueStream__c
                                            WHERE Name LIKE 'PS_Blackout_Test_VS_0%'];
        
        for(leankor__ValueStream__c vs : vsList){
            
            if(vs.name == 'PS_Blackout_Test_VS_01'){
                vs_1 = vs;
            }else if(vs.name == 'PS_Blackout_Test_VS_02'){
                vs_2 = vs;
            }
        }                                                                                 

        // Project Schedule Blackout records are created for Value Stream(vs_2)
         leankor__ProjectScheduleBlackout__c blackOut_1 = new leankor__ProjectScheduleBlackout__c();
        blackOut_1.leankor__EndDate__c = System.today()+50;
        blackOut_1.leankor__StartDate__c = System.today()+25;
        blackOut_1.leankor__ProjectBoard__c = vs_2.Id;
        INSERT blackOut_1;

        leankor__ProjectScheduleBlackout__c blackOut_2 = new leankor__ProjectScheduleBlackout__c();
        blackOut_2.leankor__EndDate__c = System.today()+5;
        blackOut_2.leankor__StartDate__c = System.today();
        blackOut_2.leankor__ProjectBoard__c = vs_2.Id;
        INSERT blackOut_2;

        /** Checking for overlapping. 
            We are going to get Exception because of Project Schedule Blackout overlaping for this Board(vs_2)
        */
        leankor__ProjectScheduleBlackout__c blackOut_3 = new leankor__ProjectScheduleBlackout__c();
        blackOut_3.leankor__EndDate__c = System.today()+5;
        blackOut_3.leankor__StartDate__c = System.today();
        blackOut_3.leankor__ProjectBoard__c = vs_2.Id; // PSB Overlapping on this Value Stream

        leankor__ProjectScheduleBlackout__c blackOut_4 = new leankor__ProjectScheduleBlackout__c();
        blackOut_4.leankor__EndDate__c = System.today()+10;
        blackOut_4.leankor__StartDate__c = System.today()-10;
        blackOut_4.leankor__ProjectBoard__c = vs_2.Id; // PSB Overlapping on this Value Stream

        leankor__ProjectScheduleBlackout__c blackOut_5 = new leankor__ProjectScheduleBlackout__c();
        blackOut_5.leankor__EndDate__c = System.today()+1;
        blackOut_5.leankor__StartDate__c = System.today()-10;
        blackOut_5.leankor__ProjectBoard__c = vs_2.Id; // PSB Overlapping on this Value Stream
        
        try{
            INSERT blackOut_3;
        }catch(System.DmlException e){
            system.assert(e.getMessage().contains('Unable to create record due to overlapping record with id '+blackOut_2.Id));
        }

        try{
            INSERT blackOut_4;
        }catch(System.DmlException e){
            system.assert(e.getMessage().contains('Unable to create record due to overlapping record with id '+blackOut_2.Id));
        }

        try{
            INSERT blackOut_5;
        }catch(System.DmlException e){
            system.assert(e.getMessage().contains('Unable to create record due to overlapping record with id '+blackOut_2.Id));
        }

        /** After Insert. Here we checking the leankor__IsScheduleRecalculate__c for value stream. 
            whom cards are affacted by the new Project Schedule Blackout records. */
        for(leankor__ValueStream__c vs : [SELECT Id,
                                            leankor__IsScheduleRecalculate__c
                                        FROM leankor__ValueStream__c
                                        WHERE Id =: vs_1.Id OR Id =: vs_2.Id]){
            
            if(vs.Id == vs_1.Id){
                // True..!!! Because we had create some cards those affected by inserted PSB on only this value stream
                System.assertEquals(true, vs.leankor__IsScheduleRecalculate__c);
            }else if(vs.Id == vs_2.Id){
                System.assertEquals(true, vs.leankor__IsScheduleRecalculate__c); 
            }
        }
    }

    private @IsTest
    static void testBlackoutUpdate(){
        
        // Value Stream records are created
        leankor__ValueStream__c vs = [SELECT Id,
                                            leankor__IsScheduleRecalculate__c
                                        FROM leankor__ValueStream__c
                                        WHERE Name LIKE 'PS_Blackout_Test_VS_01'];

        Test.startTest(); 

        // Project Schedule Blackout records are created for Value Stream(vs)
        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
        blackOut.leankor__EndDate__c = System.today()+30;
        blackOut.leankor__StartDate__c = System.today()+21;
        blackOut.leankor__ProjectBoard__c = vs.Id; 
        INSERT blackOut;

        leankor__ProjectScheduleBlackout__c blackOut_1 = new leankor__ProjectScheduleBlackout__c();
        blackOut_1.leankor__EndDate__c = System.today()+100;
        blackOut_1.leankor__StartDate__c = System.today()+60;
        blackOut_1.leankor__ProjectBoard__c = vs.Id; 
        INSERT blackOut_1;

        /** Here we made leankor__IsScheduleRecalculate__c value to false to check the value after update
            because insert operation might be made that true */
        vs.leankor__IsScheduleRecalculate__c = false;
        UPDATE vs;

        blackOut.leankor__EndDate__c = System.today()+40;
        blackOut.leankor__StartDate__c = System.today()+21;
        UPDATE blackOut;

        try{
            /** This record are going to through exception because of Project Schedule Blackout (blackOut_1) 
                record are overlapping with Project Schedule Blackout (blackOut) */
            blackOut.leankor__EndDate__c = System.today()+80;
            blackOut.leankor__StartDate__c = System.today()+26;
            UPDATE blackOut;
        }catch(DmlException e){
            system.assert(e.getMessage().contains('Unable to create record due to overlapping record with id '+blackOut_1.Id));
        }

        /** Checking leankor__IsScheduleRecalculate__c for board after Update PSB */
        vs = [SELECT Id,
                        leankor__IsScheduleRecalculate__c
                    FROM leankor__ValueStream__c
                    WHERE Id =: vs.Id 
                    LIMIT 1];
        
        System.assertEquals(true, vs.leankor__IsScheduleRecalculate__c);      
        
        Test.stopTest();    
    }

    private @IsTest
    static void testBlackoutDelete(){
        
        leankor__ValueStream__c vs = [SELECT Id,
                                            leankor__IsScheduleRecalculate__c
                                        FROM leankor__ValueStream__c
                                        WHERE Name LIKE 'PS_Blackout_Test_VS_01'];

        Test.startTest();

        /** Here we made leankor__IsScheduleRecalculate__c value to false to check the value after delete
            because insert operation might be made that true */
        vs.leankor__IsScheduleRecalculate__c = false;
        UPDATE vs;

        // Delete the Project Schedule Blackout records
        List <leankor__ProjectScheduleBlackout__c> blackOutList = [SELECT Id 
                                    FROM leankor__ProjectScheduleBlackout__c 
                                    WHERE leankor__ProjectBoard__c =: vs.Id];
        DELETE blackOutList;

        Integer count = [SELECT count()
                                FROM leankor__ProjectScheduleBlackout__c
                                WHERE leankor__ProjectBoard__c =: vs.Id];                         
        // Checking count after deleting the records.
        System.assertEquals(0, count);  

        /** Checking leankor__IsScheduleRecalculate__c for board after Delete PSB */
        vs = [SELECT Id,
                        leankor__IsScheduleRecalculate__c
                    FROM leankor__ValueStream__c
                    WHERE Id =: vs.Id 
                    LIMIT 1];
        
        System.assertEquals(true, vs.leankor__IsScheduleRecalculate__c);      
        
        Test.stopTest();  
    }
	/*
    private @IsTest
    static void testBlackoutUndelete(){
        
        leankor__ValueStream__c vs = [SELECT Id,
                                            leankor__IsScheduleRecalculate__c
                                        FROM leankor__ValueStream__c
                                        WHERE Name LIKE 'PS_Blackout_Test_VS_01'];

        Test.startTest();

        Integer count = [SELECT count()
                                FROM leankor__ProjectScheduleBlackout__c
                                WHERE leankor__ProjectBoard__c =: vs.Id];  

        // Delete the Project Schedule Blackout records
        List <leankor__ProjectScheduleBlackout__c> blackOutList = [SELECT Id 
                                    FROM leankor__ProjectScheduleBlackout__c 
                                    WHERE leankor__ProjectBoard__c =: vs.Id];
        DELETE blackOutList;

        /** Here we made leankor__IsScheduleRecalculate__c value to false to check the value after delete
            because CRUD operation might be made that true  
        vs.leankor__IsScheduleRecalculate__c = false;
        UPDATE vs;

        // UnDelete the Project Schedule Blackout records
        UNDELETE blackOutList;

        // Checking count after Undeleting the records.
        System.assertEquals(count, [SELECT count() FROM leankor__ProjectScheduleBlackout__c WHERE leankor__ProjectBoard__c =: vs.Id]);  

        /** Checking leankor__IsScheduleRecalculate__c for board after UnDelete PSB 
        vs = [SELECT Id,
                        leankor__IsScheduleRecalculate__c
                    FROM leankor__ValueStream__c
                    WHERE Id =: vs.Id 
                    LIMIT 1];
        
        System.assertEquals(true, vs.leankor__IsScheduleRecalculate__c);      
        
        Test.stopTest();  
    }*/
}