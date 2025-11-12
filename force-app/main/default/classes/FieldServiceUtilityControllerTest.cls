/**
 * Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 * Author: Rahul Solanki   
 * FILE: FieldServiceUtilityControllerTest.cls
 * CLASS: FieldServiceUtilityControllerTest
*/
@isTest
private class FieldServiceUtilityControllerTest{
     static testMethod void testWorkOrders() 
    {   
        //Boolean checkFSL = leankor.KanbanController.checkFSLManageApp();
        //RS 05/12/2018  Due to 'Availability of FSL features in Leankor application' feature have to add this condition
        Boolean checkFSL = leankor.KanbanController.checkFSLManageApp() ? new DescribeSchema().isFieldExistInSobject('WorkOrder','KanbanCard__c') : false;
        if(checkFSL){
            Test.startTest(); 
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            
            User u = new User(Alias = 'Test', 
                        Email =  'Test' + '@leankor.com',
                        EmailEncodingKey = 'UTF-8', 
                        LastName = 'Leankor1', 
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US', 
                        ProfileId = p.Id,
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        UserName =  'Test' + '@leankor.com.test');
            
            insert u;  
             
            //To create Folder
            leankor__Portfolio__c portfolio= new leankor__Portfolio__c(Name = 'folderName');   
            insert portfolio;       
            
            //To create Project
            leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = 'projectName' ,leankor__IsTemplateProject__c=false, leankor__Portfolio__c = portfolio.Id);        
            insert project;
            
            //To create Board
            list<string> boards = new list<string>{'Kanban Board','Portfolio View','Card Hierarchy','UberBoard','Plan Board','DashBoard'};
            
            list<leankor__ValueStream__c> vStreamList = new list<leankor__ValueStream__c>();
            for(string board: boards){
            leankor__ValueStream__c vStream = new leankor__ValueStream__c();
            vStream.Name = 'Plan Board (' + project.Name + ')';
            vStream.leankor__Effortindicator__c = 'Days';
            vStream.leankor__BoardType__c = board;
            vStream.leankor__ProjectRoom__c = project.Id;
            vStreamList.add(vStream); 
            }
            insert vStreamList;
            
            //To create Kanban Card Template
            leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
            template.Name = 'Default';
            template.leankor__Title__c = 'Default';
            template.leankor__Height__c = 120;
            template.leankor__Color__c = '#bdbffc';
            template.leankor__Width__c = 170;
            template.leankor__ValueStream__c = vStreamList[0].Id;
            
            insert template;
            
            //To create kanban card
            list<leankor__KanbanCard__c> kbList = new list<leankor__KanbanCard__c>();
            Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            Integer count = 1; 
            for(leankor__ValueStream__c vs : vStreamList ){
                        
            leankor__KanbanCard__c kb = new leankor__KanbanCard__c();        
            kb.Name = 'Activity ';
            kb.RecordTypeId = recType;
            kb.leankor__ValueStream__c = vs.Id;
            kb.leankor__GUID__c = String.valueOf(count) + String.valueOf(system.now().getTime()) + String.valueOf(count);                          
            kb.leankor__KanbanCardTemplate__c = template.Id;
            kb.leankor__StartDate__c = System.today();
            kb.leankor__DueDate__c = System.today().addDays(1);        
            kb.OwnerId=u.id;        
            kbList.add(kb);
            count++;
            }
                            
            insert kbList;        
            
            //To create Workorder
            list<string> kbIds = new list<string>();        
            list<sObject> woList = new list<sObject>();
            for(leankor__KanbanCard__c kcard: kbList){
            kbIds.add(kcard.Id);        
            Schema.SObjectType workOrderSobject=Schema.getGlobalDescribe().get('WorkOrder'); 
            sObject sObj = workOrderSobject.newSObject();
            sObj.put('KanbanCard__c', kcard.Id );          
            woList.add(sObj);
            }      
            insert woList;        
            
            //To call methods 
            List<KanbanController.WorkOrderType> work = FieldServiceUtilityController.getWorkOrderRecords(kbIds);       
            system.assert(work.size()!=0); 
            
            FieldServiceUtilityController.RecordDetails records= FieldServiceUtilityController.getAllWorkOrders(0,'',10);
            system.assert(records.FieldServiceLightning.size()!=0);       
    
            string WorkOrderRecord = '{\"cardId\" : \"'+kbList[0].Id +'\" , \"workOrderId\" : \"'+woList[2].Id +'\"}';
            list<string> WorkOrderRecordData = new list<string>();
            WorkOrderRecordData.add(WorkOrderRecord);
            system.assertEquals(FieldServiceUtilityController.updateWorkOrder(WorkOrderRecordData),true);                     
            
            Test.stopTest();
        }
    }
}