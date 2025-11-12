/**
 Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 FILE: TestCardHierarchyController.cls
 CLASS: TestCardHierarchyController
*/
@isTest
private class TestCardHierarchyController {

    static testMethod void testGetResources(){
        //Creating a user with no access SD
        Profile p = [Select Id 
                        From Profile 
                        Where Name = 'Chatter Free User'];

        User nonStandardUser = new User();
        nonStandardUser.Alias = 'standt';
        nonStandardUser.Email = 'standarduser@testorg.com'; 
        nonStandardUser.EmailEncodingKey = 'UTF-8'; 
        nonStandardUser.LastName = 'Testing';
        nonStandardUser.LanguageLocaleKey = 'en_US'; 
        nonStandardUser.LocaleSidKey = 'en_US'; 
        nonStandardUser.ProfileId = p.Id; 
        nonStandardUser.TimeZoneSidKey = 'America/Los_Angeles'; 
        nonStandardUser.UserName = 'standarduser@leankortest.co.in';
        insert nonStandardUser;

        leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c();
        pr1.Name = 'myroom';
        insert pr1;

        leankor__ValueStream__c vs = new leankor__ValueStream__c();
        vs.leankor__ProjectRoom__c = pr1.ID;
        vs.Name = 'myVS';
        vs.leankor__DisableTaskAsMiniature__c=true;
        vs.leankor__BoardType__c='Portfolio View';
        vs.leankor__Istemplateboard__c=false;
        insert vs;

        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c();
        kct.Name = 'template name';
        kct.leankor__Width__c = 100;
        kct.leankor__Title__c = 'template title';
        kct.leankor__JSONDefinition__c = '{}';
        kct.leankor__JSONData__c = '{}';
        kct.leankor__Height__c = 200;
        kct.leankor__CSSLayout__c = 'some css';
        kct.leankor__color__c = '#CCC';
        kct.leankor__valueStream__c =vs.id;
        insert kct;

        // set up a standard controller page
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vs);
        leankor.CardHierarchyController rkc = new leankor.CardHierarchyController(sc);
        //Initializing TempMasterContainer
        leankor.CardHierarchyController.TempMasterContainer Tmc = new leankor.CardHierarchyController.TempMasterContainer();

        Task Tsk14 = new Task();
        Tsk14.Priority = 'High';
        Tsk14.OwnerID = UserInfo.getUserId();
        Tsk14.Subject = 'Task for Card Hierarchy';
        Tsk14.Status = 'Not Started';
        Tsk14.ActivityDate = System.today();
        Tsk14.WhatId = kct.Id;
        Tsk14.Description = 'Testing Task with Card hierarchy';
        insert Tsk14;
     
        leankor__ValueStream__c vs1= new leankor__ValueStream__c();
        vs1.leankor__ProjectRoom__c = pr1.id;
        vs1.Name = 'myVS1';
        vs1.leankor__Istemplateboard__c=false;
        insert vs1;

        leankor__mastercontainer__c Newmc = new leankor__mastercontainer__c();
        Newmc.name = 'MC1';
        Newmc.leankor__ValueStream__c = vs1.id;
        insert Newmc;

        leankor__swimlane__c sw = new leankor__swimlane__c();
        sw.name= 'Sw'; 
        sw.leankor__mastercontainer__c = Newmc.id;
        sw.leankor__ValueStream__c = vs1.id;
        insert sw;

        leankor__swimlane__c sw12 = new leankor__swimlane__c();
        sw12.name = 'Sw12'; 
        sw12.leankor__mastercontainer__c = Newmc.id;
        sw12.leankor__ValueStream__c = vs1.id;
        insert sw12;

        leankor__Zone__c zone = new leankor__Zone__c();
        zone.Name = 'Zone';
        zone.leankor__ValueStream__c = vs1.Id;
        zone.leankor__Swimlane__c = sw.Id;
        zone.leankor__GUID__c = System.now().getTime()+'-'+123;
        insert zone;

        leankor__Zone__c zone1=new leankor__Zone__c();
        zone1.Name = 'Zone1';
        zone1.leankor__ValueStream__c = vs1.Id;
        zone1.leankor__Swimlane__c = sw.Id;
        zone1.leankor__GUID__c = System.now().getTime()+'-'+1234;
        insert zone1;

        string szoneID = System.now().getTime()+'-'+12345;

        leankor__Zone__c zonenew=new leankor__Zone__c();
        zonenew.Name = 'Zone12';
        zonenew.leankor__ValueStream__c = vs1.Id;
        zonenew.leankor__swimlane__c = sw.id;
        zonenew.leankor__GUID__c = szoneID;
        insert zonenew;

        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Name = 'kanban test';
        kc.leankor__Y__c = 20;
        kc.leankor__X__c = 50;
        kc.leankor__Width__c = 100;
        kc.leankor__ValueStream__c = vs.Id;
        kc.leankor__Top__c = 150;
        kc.leankor__Title__c = 'kanban title test';
        kc.leankor__Left__c = 250;
        kc.leankor__JSONDefinition__c = '{}';
        kc.leankor__JSONData__c = '{}';
        kc.leankor__Height__c = 110;
        kc.leankor__GUID__c = 'my-GUID-kanban-test-151';
        kc.leankor__CmpID__c = 'my CMPID kanban test';
        kc.leankor__CSSLayout__c = 'some css';
        kc.leankor__Bottom__c = 450;
        kc.leankor__Priority__c = 1;
        kc.leankor__KanbanCardTemplate__c=kct.Id;
        kc.leankor__DurationUnits__c='Minutes';
        kc.leankor__EstimatedDuration__c=200;
        kc.leankor__Order__C = 2;
        kc.leankor__ZoneGUID__c = zone.leankor__GUID__c;
        kc.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc;
        
        Task Tsk = new Task();
        Tsk.Priority    =   'High';
        Tsk.OwnerID     =    UserInfo.getUserId();
        Tsk.Subject     =   'Task for Card Hierarchy';
        Tsk.Status      =   'Not Started';
        Tsk.ActivityDate =   System.today();
        Tsk.WhatId      =   kc.Id;
        Tsk.Description =   'Testing Task with Card hierarchy';
        insert Tsk;

        leankor__KanbanCard__c kc1 = new leankor__KanbanCard__c();
        kc1.Name = 'kanban test1';
        kc1.leankor__GUID__c = 'my-GUID-kanban-test152';
        kc1.leankor__CmpID__c = 'my CMPID kanban test1';
        kc1.leankor__ValueStream__c = vs.Id;
        kc1.leankor__KanbanCardTemplate__c=kct.Id;
        kc1.leankor__DurationUnits__c='Minutes';
        kc1.leankor__EstimatedDuration__c=2;
        kc1.leankor__ZoneGUID__c =zonenew.leankor__GUID__c;
        kc1.leankor__ValueStreamCardLink__c=kc.Id;
        kc1.leankor__ValueStreamLink__c =vs.Id;
        kc1.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc1;
       
        Task Tsk1 = new Task();
        Tsk1.Priority    =   'High';
        Tsk1.OwnerID =   UserInfo.getUserId();
        Tsk1.Subject     =   'Task for Card Hierarchy';
        Tsk1.Status      =   'Not Started';
        Tsk1.ActivityDate=   System.today();
        Tsk1.WhatId      =   kc1.Id;
        Tsk1.Description =   'Testing Task with Card hierarchy';
        insert Tsk1;
        
        leankor__dependency__c dep =new leankor__dependency__c(
        leankor__GUID__c=kc.leankor__GUID__c,
        leankor__Predecessor__c=kc.id,
        leankor__Successor__c=kc1.id,
        leankor__ValueStream__c=vs.Id,
        leankor__KanbanCard__c = kc.id
        );
        insert dep;

        leankor__dependency__c dep2 =new leankor__dependency__c();
        dep2.leankor__GUID__c=kc.leankor__GUID__c+'-1';
        dep2.leankor__Predecessor__c=kc.id;
        dep2.leankor__Successor__c=kc1.id;
        dep2.leankor__ValueStream__c=vs.Id;
        dep2.leankor__KanbanCard__c = kc1.id;
        insert dep2;

        leankor__KanbanCard__c kc2 = new leankor__KanbanCard__c();
        kc2.Name = 'kanban test2';
        kc2.leankor__GUID__c = 'my GUID kanban test2';
        kc2.leankor__CmpID__c = 'my CMPID kanban test2';
        kc2.leankor__ValueStream__c = vs.Id;
        kc2.leankor__KanbanCardTemplate__c=kct.Id;
        kc2.leankor__EstimatedDuration__c=2;
        kc2.leankor__ZoneGUID__c =zonenew.leankor__GUID__c;
        kc2.leankor__ValueStreamCardLink__c=kc1.Id;
        kc2.leankor__ValueStreamLink__c =vs.Id;
        kc2.leankor__DurationUnits__c='Minutes';
        kc2.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc2;

        leankor__KanbanCardTemplate__c kct1 = new leankor__KanbanCardTemplate__c();
        kct1.Name = 'template name';
        kct1.leankor__Width__c = 100;
        kct1.leankor__Title__c = 'template title';
        kct1.leankor__JSONDefinition__c = '{}';
        kct1.leankor__JSONData__c = '{}';
        kct1.leankor__Height__c = 200;
        kct1.leankor__CSSLayout__c = 'some css';
        kct1.leankor__valueStream__c =vs.id;
        kct1.leankor__color__c = '#CCC';
        insert kct1;

        Task Tsk11 = new Task();
        Tsk11.Priority    =   'High';
        Tsk11.OwnerID =   UserInfo.getUserId();
        Tsk11.Subject     =   'Task for Card Hierarchy';
        Tsk11.Status      =   'Not Started';
        Tsk11.ActivityDate=   System.today();
        Tsk11.WhatId      =   kc1.Id;
        Tsk11.Description =   'Testing Task with Card hierarchy';
        insert Tsk11;
        
        leankor__KanbanCard__c kc3 = new leankor__KanbanCard__c();
        kc3.Name = 'kanban test3';
        kc3.leankor__GUID__c = 'my GUID kanban test3';
        kc3.leankor__CmpID__c = 'my CMPID kanban test3';
        kc3.leankor__KanbanCardTemplate__c=kct1.Id;
        kc3.leankor__DurationUnits__c='Minutes';
        kc3.leankor__EstimatedDuration__c=2;
        kc3.leankor__ValueStream__c = vs.Id;
        kc3.leankor__StartDate__c =System.today();                      
        kc3.leankor__ZoneGUID__c =zone1.leankor__GUID__c;
        kc3.leankor__ValueStreamCardLink__c=kc.Id;
        kc3.leankor__ValueStreamLink__c =vs.Id;
        kc3.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc3;
        
        Task Tsk12 = new Task();
        Tsk12.Priority    =   'High';
        Tsk12.OwnerID =   UserInfo.getUserId();
        Tsk12.Subject     =   'Task for Card Hierarchy';
        Tsk12.Status      =   'Not Started';
        Tsk12.ActivityDate=   System.today();
        Tsk12.WhatId      =   kc3.Id;
        Tsk12.Description =   'Testing Task with Card hierarchy';
        insert Tsk12;
         
        leankor__KanbanCard__c kc4 = new leankor__KanbanCard__c();
        kc4.Name = 'kanban test4';
        kc4.leankor__GUID__c = 'my GUID kanban test4';
        kc4.leankor__CmpID__c = 'my CMPID kanban test4';
        kc4.leankor__ValueStream__c = vs1.Id;
        kc4.leankor__KanbanCardTemplate__c=kct1.Id;
        kc4.leankor__ValueStreamCardLink__c=kc.Id;
        kc4.leankor__ValueStreamLink__c =vs.Id;
        kc4.leankor__DurationUnits__c='Minutes';
        kc4.leankor__ZoneGUID__c = zonenew.leankor__GUID__c;
        kc4.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc4;

        Task Tsk13 = new Task();
        Tsk13.Priority    =   'High';
        Tsk13.OwnerID =   UserInfo.getUserId();
        Tsk13.Subject     =   'Task for Card Hierarchy';
        Tsk13.Status      =   'Not Started';
        Tsk13.ActivityDate=   System.today();
        Tsk13.WhatId      =   kc4.Id;
        Tsk13.Description =   'Testing Task with Card hierarchy';
        insert Tsk13;

        String RVerb= 'Card Hierarchy';
        list<string> VSIDs = new List<string>();
        VSIDs.add(vs.Id);
        VSIDs.add(vs1.Id);

        leankor__ScheduleMode__c ScheduleMode = new leankor__ScheduleMode__c();
        ScheduleMode.leankor__Mode__c='normal';
        ScheduleMode.leankor__KanbanCard__c=kc1.id;
        insert ScheduleMode;
        
        User user1 = leankor.TestDataFactory.createStandardUser('Lean');
        User user2 = leankor.TestDataFactory.createStandardUser('Leankor');   

        Boolean isVsReadwrite =leankor.TestDataFactory.shareRecord(user1,VSIDs,'leankor__ValueStream__Share','Edit');
        Boolean isVsReadOnly=leankor.TestDataFactory.shareRecord(user2,VSIDs,'leankor__ValueStream__Share','Read');
        
        list<string> project = new List<string>();
        project.add(pr1.id);
        
        Boolean isProjectReadwrite =leankor.TestDataFactory.shareRecord(user1,project,'leankor__ProjectRoom__Share','Edit');
        
        leankor.CardHierarchyController.CardHierarchyResourceScheduler CHRS;
        leankor.CardHierarchyController.CardHierarchyResourceScheduler CHRS1;
     
        if (isVsReadwrite) {
            System.runAs(user1){
                CHRS =leankor.CardHierarchyController.getResources(vs.Id,kc.Id,'Card Hierarchy');
                System.assertEquals(CHRS.hasEditAccess,false);

                CHRS1 =leankor.CardHierarchyController.getResources(vs.Id,kc1.Id,RVerb);
                System.assertEquals(CHRS1.hasEditAccess,false);
            
            } 
        }
        if (isVsReadOnly) {
            System.runAs(user2) {
                    CHRS =leankor.CardHierarchyController.getResources(vs.Id,kc.Id,'Card Hierarchy');
                    System.assertEquals(CHRS.hasEditAccess,false);
                    CHRS1 =leankor.CardHierarchyController.getResources(vs.Id,kc1.Id,RVerb);
                    System.assertEquals(CHRS1.hasEditAccess,false);
            
            }								
        }
        if (!isVsReadOnly && !isVsReadwrite) {   		   
            CHRS =leankor.CardHierarchyController.getResources(vs.Id,kc.Id,'Card Hierarchy');
            System.assertEquals(CHRS.hasEditAccess,true);
            CHRS1 =leankor.CardHierarchyController.getResources(vs.Id,kc1.Id,RVerb);
            System.assertEquals(CHRS1.hasEditAccess,true);	   
        }					

        Test.StartTest();
        list<string> UserIds =  new list<string>();
        for (leankor.KanbanToGanttController.CardResource UserLog : CHRS.CardResources) {
            UserIds.add(UserLog.id);
        }   
        //modified Test Class
        leankor.KanbanToGanttController.MasterContainer filterData = new leankor.KanbanToGanttController.MasterContainer();
        filterData.ValueStreamID = vs.Id;
        filterData.StartDate = (system.now()-10).format('yyyy-MM-dd');
        filterData.DueDate = (system.now()+10).format('yyyy-MM-dd');
        //Date: 22/11/18  add  lastCardId and lastTaskId variable value. 
        filterData.lastCardId=kc3.id; 
        filterData.lastTaskId='';
        
        leankor.KanbanToGanttController.ResourceScheduler CHRSResult  =leankor.CardHierarchyController.getKanbanCardsByResourceOnCH(UserIds,VSIDs,kc.Id,JSON.Serialize(filterData),'');
        UserIds.clear();

        for (leankor.KanbanToGanttController.CardResource UserLog : CHRS1.CardResources) {
            UserIds.add(UserLog.id);
        }

        leankor.KanbanToGanttController.MasterContainer filterData1 = new leankor.KanbanToGanttController.MasterContainer();
        filterData1.ValueStreamID = vs.Id;
        filterData1.StartDate = (system.now()-10).format('yyyy-MM-dd');
        filterData1.DueDate = (system.now()+10).format('yyyy-MM-dd');
        filterData1.lastCardId=kc3.id; 
        filterData.lastTaskId='';

    	leankor__KanbanCard__c  kc5=new leankor__KanbanCard__c();
     	kc5.Name = 'kanban test5';
        kc5.leankor__GUID__c = leankor.TestDataFactory.createguid();                  
        kc5.leankor__KanbanCardTemplate__c=kct1.Id;                        
        kc5.leankor__ValueStream__c = vs.Id;
        kc5.leankor__StartDate__c =System.today();                            
        kc5.leankor__ValueStreamCardLink__c=kc.Id;     
        kc5.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
      	insert kc5;
    	List<leankor__dependency__c> depndencyList =new List<leankor__dependency__c>();
    	for(String vs2:VSIDs){
    		leankor__dependency__c dep3 =new leankor__dependency__c();
        	dep3.leankor__GUID__c=leankor.TestDataFactory.createGuid();
        	dep3.leankor__Predecessor__c=kc5.id;
        	dep3.leankor__Successor__c=kc1.id;
        	dep3.leankor__ValueStream__c=vs2;
        	dep3.leankor__KanbanCard__c = kc1.id;
        	depndencyList.add(dep3);              
    	}
     	insert depndencyList;     	
    
        leankor.KanbanToGanttController.ResourceScheduler CHRSResult1  =leankor.CardHierarchyController.getKanbanCardsByResourceOnCH(UserIds,VSIDs,kc5.Id,JSON.Serialize(filterData1),'other');
        leankor.KanbanToGanttController.MasterContainer rr=leankor.CardHierarchyController.getVSHierarchyRecord(szoneID);
        //Checking behavior with user with no access and admin user input SD
        UserIds.clear();
        UserIds.add(UserInfo.getUserId());
        system.runAs(nonStandardUser) 
        {
            try {
                leankor.KanbanToGanttController.ResourceScheduler CHRSResult1NonStndAdmin  =leankor.CardHierarchyController.getKanbanCardsByResourceOnCH(UserIds,VSIDs,kc5.Id,JSON.Serialize(filterData1),'other');
                leankor.KanbanToGanttController.ResourceScheduler CHRSResult1NonStndAdmin1  =leankor.CardHierarchyController.getKanbanCardsByResourceOnCH(UserIds,VSIDs,kc5.Id,JSON.Serialize(filterData1),'other');
            // Date : 13/05/19
                //leankor.CardHierarchyController.CardHierarchyResourceScheduler CHRS23 =leankor.CardHierarchyController.getResources(vs.Id,kc1.Id,RVerb);
            // Date 22/11/18
                leankor.KanbanToGanttController.MasterContainer filterData2 = new leankor.KanbanToGanttController.MasterContainer();
                filterData2.ValueStreamID = vs.Id;
                filterData2.StartDate = (system.now()-10).format('yyyy-MM-dd');
                filterData2.DueDate = (system.now()+10).format('yyyy-MM-dd');    
                filterData2.lastCardId='';
                filterData2.lastTaskId=Tsk13.id;
                leankor.KanbanToGanttController.ResourceScheduler CHRSResult1NonStndAdmin24  =leankor.CardHierarchyController.getKanbanCardsByResourceOnCH(UserIds,VSIDs,kc5.Id,JSON.Serialize(filterData2),'other');
                
            } catch (Exception e) {
                System.assertEquals('System.QueryException',e.getTypeName());  
            }
        }
        UserIds.clear();
        UserIds.add(nonStandardUser.Id);
        leankor.KanbanToGanttController.ResourceScheduler CHRSResult1NonStd  =leankor.CardHierarchyController.getKanbanCardsByResourceOnCH(UserIds,VSIDs,kc5.Id,JSON.Serialize(filterData1),'other');
        //Checking behavior with user with no access and non admin user input SD
        system.runAs(nonStandardUser) 
        {
            try {
                leankor.KanbanToGanttController.ResourceScheduler CHRSResult1NonStndNonAdmin  =leankor.CardHierarchyController.getKanbanCardsByResourceOnCH(UserIds,VSIDs,kc5.Id,JSON.Serialize(filterData1),'other');
            } catch (Exception e) {
                System.assertEquals('System.QueryException',e.getTypeName());  
            }
        }

        System.assert(CHRS !=null);
        System.assert(CHRS1 !=null);
        System.assert(CHRSResult !=null);
        System.assert(CHRSResult1 !=null);

        leankor__mastercontainer__c Newmc1 = new leankor__mastercontainer__c();
        Newmc1.name = 'MC1';
        Newmc1.leankor__ValueStream__c = vs1.id; 
        Newmc1.leankor__GUID__c = system.now()+'12';
        insert Newmc1;

        leankor__swimlane__c sw3 = new leankor__swimlane__c();
        sw3.name= 'Sw'; 
        sw3.leankor__mastercontainer__c= Newmc1.id;
        sw3.leankor__ValueStream__c = vs1.id;
        insert sw3;

        string szoneID3 = System.now().getTime()+'-'+12345;
        leankor__Zone__c zone12=new leankor__Zone__c();
        zone12.Name='Zone112';
        zone12.leankor__ValueStream__c=vs1.Id;
        zone12.leankor__swimlane__c = sw3.id;
        zone12.leankor__GUID__c= szoneID3;
        insert zone12;

        leankor.KanbanToGanttController.MasterContainer rr1=leankor.CardHierarchyController.getVSHierarchyRecord(szoneID3);
        string szoneID4 = System.now().getTime()+'-'+12225;

        leankor__Zone__c zone123=new leankor__Zone__c();
        zone123.Name='Zone122';
        zone123.leankor__ValueStream__c=vs1.Id;
        zone123.leankor__swimlane__c = sw3.id;
        zone123.leankor__GUID__c= szoneID4;
        insert zone123;
    
        leankor.KanbanToGanttController.MasterContainer rr2=leankor.CardHierarchyController.getVSHierarchyRecord(szoneID4);
        // Asserting getVSHierarchyRecord 
        Test.StopTest(); 
        system.assert(rr2!=null);
    }

    public static testMethod void testcardNewHierarchy() {
        leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c();
        pr1.Name = 'myroom';
        insert pr1;

        leankor__ValueStream__c vs = new leankor__ValueStream__c();
        vs.leankor__ProjectRoom__c = pr1.id;
        vs.Name = 'myVS';
        vs.leankor__DisableTaskAsMiniature__c = true;
        vs.leankor__BoardType__c = 'Portfolio View';
        vs.leankor__Istemplateboard__c = false;
        insert vs;

        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c();
        kct.Name = 'template name';
        kct.leankor__Width__c = 100;
        kct.leankor__Title__c = 'template title';
        kct.leankor__JSONDefinition__c = '{}';
        kct.leankor__JSONData__c = '{}';
        kct.leankor__Height__c = 200;
        kct.leankor__CSSLayout__c = 'some css';
        kct.leankor__color__c = '#CCC';
        kct.leankor__valueStream__c =vs.id;
        insert kct;

        Task Tsk14 = new Task();
        Tsk14.Priority = 'High';
        Tsk14.OwnerID = UserInfo.getUserId();
        Tsk14.Subject = 'Task for Card Hierarchy';
        Tsk14.Status = 'Not Started';
        Tsk14.ActivityDate = System.today();
        Tsk14.WhatId = kct.Id;
        Tsk14.Description = 'Testing Task with Card hierarchy';
        insert Tsk14;

        leankor__Zone__c zone = new leankor__Zone__c();
        zone.Name='Zone1';
        zone.leankor__ValueStream__c=vs.Id;
        zone.leankor__GUID__c= System.now().getTime()+'-'+123;
        insert zone;

        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Name = 'kanban test';
        kc.leankor__Y__c = 20;
        kc.leankor__X__c = 50;
        kc.leankor__Width__c = 100;
        kc.leankor__ValueStream__c = vs.Id;
        kc.leankor__Top__c = 150;
        kc.leankor__Title__c = 'kanban title test';
        kc.leankor__Left__c = 250;
        kc.leankor__JSONDefinition__c = '{}';
        kc.leankor__JSONData__c = '{}';
        kc.leankor__Height__c = 110;
        kc.leankor__GUID__c = 'my-GUID-kanban-test-151';
        kc.leankor__CmpID__c = 'my CMPID kanban test';
        kc.leankor__CSSLayout__c = 'some css';
        kc.leankor__Bottom__c = 450;
        kc.leankor__Priority__c = 1;
        kc.leankor__KanbanCardTemplate__c = kct.Id;
        kc.leankor__DurationUnits__c = 'Hours';
        kc.leankor__EstimatedDuration__c = 2;
        kc.leankor__Order__c = 2;
        insert kc;

        leankor__ValueStream__c vs1 = new leankor__ValueStream__c();
        vs1.leankor__ProjectRoom__c = pr1.id;
        vs1.Name = 'myVS';
        vs1.leankor__BoardType__c = 'whiteBoard';
        vs1.leankor__Istemplateboard__c = false;
        insert vs1;

        leankor__KanbanCardTemplate__c kct1 = new leankor__KanbanCardTemplate__c();
        kct1.Name = 'template name';
        kct1.leankor__Width__c = 100;
        kct1.leankor__Title__c = 'template title';
        kct1.leankor__JSONDefinition__c = '{}';
        kct1.leankor__JSONData__c = '{}';
        kct1.leankor__Height__c = 200;
        kct1.leankor__CSSLayout__c = 'some css';
        kct1.leankor__valueStream__c =vs1.id;
        kct1.leankor__color__c = '#CCC';
        insert kct1;

        string szoneID2 = System.now().getTime()+'-'+12345;
        leankor__Zone__c zone1 = new leankor__Zone__c();
        zone1.Name='Zone12';
        zone1.leankor__ValueStream__c=vs1.Id;
        zone1.leankor__GUID__c=szoneID2;
        insert zone1;

        leankor__KanbanCard__c kc3 = new leankor__KanbanCard__c();
        kc3.Name = 'kanban test3';
        kc3.leankor__GUID__c = 'my GUID kanban test3';
        kc3.leankor__CmpID__c = 'my CMPID kanban test3';
        kc3.leankor__ValueStream__c = vs1.Id;
        kc3.leankor__KanbanCardTemplate__c = kct1.Id;
        kc3.leankor__DurationUnits__c = 'Years';
        kc3.leankor__EstimatedDuration__c = 2;
        kc3.leankor__ZoneGUID__c = zone1.leankor__GUID__c;
        kc3.leankor__ValueStreamCardLink__c = kc.Id;
        kc3.leankor__ValueStreamLink__c = vs.Id;
        insert kc3;

        Task Tsk12 = new Task();
        Tsk12.Priority    =   'High';
        Tsk12.OwnerID =   UserInfo.getUserId();
        Tsk12.Subject     =   'Task for Card Hierarchy';
        Tsk12.Status      =   'Not Started';
        Tsk12.ActivityDate=   System.today();
        Tsk12.WhatId      =   kc3.Id;
        Tsk12.Description =   'Testing Task with Card hierarchy';
        insert Tsk12;
         
        leankor__KanbanCard__c kc4 = new leankor__KanbanCard__c();
        kc4.Name = 'kanban test4';
        kc4.leankor__GUID__c = 'my GUID kanban test4';
        kc4.leankor__CmpID__c = 'my CMPID kanban test4';
        kc4.leankor__ValueStream__c = vs1.Id;
        kc4.leankor__KanbanCardTemplate__c=kct1.Id;
        kc4.leankor__ValueStreamCardLink__c=kc.Id;
        kc4.leankor__ValueStreamLink__c =vs.Id;
        kc4.leankor__DurationUnits__c='Months';
        insert kc4;

        Task Tsk13 = new Task();
        Tsk13.Priority    =   'High';
        Tsk13.OwnerID =   UserInfo.getUserId();
        Tsk13.Subject     =   'Task for Card Hierarchy';
        Tsk13.Status      =   'Not Started';
        Tsk13.ActivityDate=   System.today();
        Tsk13.WhatId      =   kc4.Id;
        Tsk13.Description =   'Testing Task with Card hierarchy';
        insert Tsk13;

        String RVerb= 'Card Hierarchy';
        // Date 22/11/18   
     	List<leankor__KanbanCard__c> kanbancardList=new List<leankor__KanbanCard__c>();
     		for (Integer i=0;i<2;i++) {
     			leankor__KanbanCard__c kb =new leankor__KanbanCard__c();
     			kb.name='kanban123';
     			kb.leankor__GUID__c=leankor.TestDataFactory.createGuid();
     			kb.leankor__ValueStream__c=vs.id;
     			kb.leankor__ValueStreamCardLink__c=kc.id;
     			kb.leankor__ValueStreamLink__c=vs.id;
     			kb.leankor__DurationUnits__c='Days';
     			kanbancardList.add(kb);
     		}
       	insert kanbancardList;
       	
     	List<leankor__ScheduleMode__c> schedulemodeList =new List<leankor__ScheduleMode__c>();    		
     		for (leankor__KanbanCard__c kb:kanbancardList) {
     			for (Integer i=0;i<2;i++) {    				
     				leankor__ScheduleMode__c schedulemode=new leankor__ScheduleMode__c();
     				schedulemode.leankor__KanbanCard__c=kb.id;
     				schedulemode.leankor__EffortActual__c=4;
     				schedulemode.leankor__EffortUnits__c='Days';
     				schedulemodeList.add(schedulemode);
     			}
     		}
     	insert schedulemodeList;
                
        leankor.CardHierarchyController.CardHierarchyResourceScheduler CHRS =leankor.CardHierarchyController.getResources(vs.Id,kc.Id,RVerb);
        system.assert(CHRS!= null);
        leankor.KanbanToGanttController.MasterContainer rr=leankor.CardHierarchyController.getVSHierarchyRecord(szoneID2);
        // Asserting getVSHierarchyRecord 
        system.assert(rr!=null);
    }
    @isTest
    public static void getVSHierarchyRecordTest2(){
        leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c();
        pr1.Name = 'myroom';
        insert pr1;

  	    leankor__ValueStream__c vs= new leankor__ValueStream__c(leankor__ProjectRoom__c = pr1.ID,Name = 'myVS',leankor__DisableTaskAsMiniature__c=true,leankor__BoardType__c='Portfolio View',leankor__Istemplateboard__c=false );
        insert vs;

        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c();
        kct.Name = 'template name';
        kct.leankor__Width__c = 100;
        kct.leankor__Title__c = 'template title';
        kct.leankor__JSONDefinition__c = '{}';
        kct.leankor__JSONData__c = '{}';
        kct.leankor__Height__c = 200;
        kct.leankor__CSSLayout__c = 'some css' ;
        kct.leankor__color__c = '#CCC';
        kct.leankor__valueStream__c =vs.id;
        insert kct;
        
        leankor__mastercontainer__c Newmc = new leankor__mastercontainer__c();
        Newmc.name = 'MC1';
        Newmc.leankor__ValueStream__c = vs.id;
        insert Newmc;

        leankor__swimlane__c sw = new leankor__swimlane__c();
        sw.name = 'Sw';
        sw.leankor__mastercontainer__c = Newmc.id;
        sw.leankor__ValueStream__c = vs.id;
        insert sw;

        leankor__swimlane__c sw2 = new leankor__swimlane__c();
        sw2.name= 'Sw2';
        sw2.leankor__mastercontainer__c = Newmc.id;
        sw2.leankor__ValueStream__c = vs.id;
        insert sw2;

        string szoneID = System.now().getTime()+'-'+12345;
        leankor__Zone__c zonenew = new leankor__Zone__c();
        zonenew.Name = 'Zone12';
        zonenew.leankor__ValueStream__c = vs.Id;
        zonenew.leankor__swimlane__c = sw.id;
        zonenew.leankor__GUID__c = szoneID;
        insert zonenew;

        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Name = 'kanban test';
        kc.leankor__Y__c = 20;
        kc.leankor__X__c = 50;
        kc.leankor__Width__c = 100;
        kc.leankor__ValueStream__c = vs.Id;
        kc.leankor__Top__c = 150;
        kc.leankor__Title__c = 'kanban title test';
        kc.leankor__Left__c = 250;
        kc.leankor__JSONDefinition__c = '{}';
        kc.leankor__JSONData__c = '{}';
        kc.leankor__Height__c = 110;
        kc.leankor__GUID__c = 'my-GUID-kanban-test-151';
        kc.leankor__CmpID__c = 'my CMPID kanban test';
        kc.leankor__CSSLayout__c = 'some css';
        kc.leankor__Bottom__c = 450;
        kc.leankor__Priority__c = 1;
        kc.leankor__KanbanCardTemplate__c=kct.Id;
        kc.leankor__DurationUnits__c='Minutes';
        kc.leankor__EstimatedDuration__c=200;
        kc.leankor__Order__C = 2;
        kc.leankor__ZoneGUID__c = zonenew.leankor__GUID__c;
        kc.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc;
        
        leankor.KanbanToGanttController.MasterContainer rr=leankor.CardHierarchyController.getVSHierarchyRecord(szoneID);
        // Asserting getVSHierarchyRecord 
        system.assert(rr!=null);
    }
    
    
    private static testMethod void getAssociatedCardsOfResources1(){
        User user1 = leankor.TestDataFactory.createStandardUser('Lean');
        User user2 = leankor.TestDataFactory.createStandardUser('Leankor');  
        
        leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c();
        pr1.Name = 'myroom';
        insert pr1;

        leankor__ValueStream__c vs= new leankor__ValueStream__c();
        vs.leankor__ProjectRoom__c = pr1.ID;
        vs.Name = 'myVS';
        vs.leankor__DisableTaskAsMiniature__c=true;
        vs.leankor__BoardType__c='Portfolio View';
        vs.leankor__Istemplateboard__c=false;
        insert vs;

        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c();
        kct.Name = 'template name';
        kct.leankor__Width__c = 100;
        kct.leankor__Title__c = 'template title';
        kct.leankor__JSONDefinition__c = '{}';
        kct.leankor__JSONData__c = '{}';
        kct.leankor__Height__c = 200;
        kct.leankor__CSSLayout__c = 'some css';
        kct.leankor__color__c = '#CCC';
        kct.leankor__valueStream__c =vs.id;
        insert kct;

        // set up a standard controller page
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vs);
        leankor.CardHierarchyController rkc = new leankor.CardHierarchyController(sc);
        //Initializing TempMasterContainer
        leankor.CardHierarchyController.TempMasterContainer Tmc = new leankor.CardHierarchyController.TempMasterContainer();

        Task Tsk14 = new Task();
        Tsk14.Priority = 'High';
        Tsk14.OwnerID = UserInfo.getUserId();
        Tsk14.Subject = 'Task for Card Hierarchy';
        Tsk14.Status = 'Not Started';
        Tsk14.ActivityDate = System.today();
        Tsk14.WhatId = kct.Id;
        Tsk14.Description = 'Testing Task with Card hierarchy';
        insert Tsk14;
     
        leankor__ValueStream__c vs1= new leankor__ValueStream__c();
        vs1.leankor__ProjectRoom__c = pr1.id;
        vs1.Name = 'myVS1';
        vs1.leankor__Istemplateboard__c=false;
        insert vs1;
        
        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Name = 'kanban test';
        kc.leankor__Y__c = 20;
        kc.leankor__X__c = 50;
        kc.leankor__Width__c = 100;
        kc.leankor__ValueStream__c = vs.Id;
        kc.leankor__Top__c = 150;
        kc.leankor__Title__c = 'kanban title test';
        kc.leankor__Left__c = 250;
        kc.leankor__JSONDefinition__c = '{}';
        kc.leankor__JSONData__c = '{}';
        kc.leankor__Height__c = 110;
        kc.leankor__GUID__c = 'my-GUID-kanban-test-151';
        kc.leankor__CmpID__c = 'my CMPID kanban test';
        kc.leankor__CSSLayout__c = 'some css';
        kc.leankor__Bottom__c = 450;
        kc.leankor__Priority__c = 1;
        kc.leankor__KanbanCardTemplate__c=kct.Id;
        kc.leankor__DurationUnits__c='Minutes';
        kc.leankor__EstimatedDuration__c=200;
        kc.leankor__Order__C = 2;
        kc.leankor__ZoneGUID__c = 'Zone dummy';
        kc.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc;
        
        Task Tsk = new Task();
        Tsk.Priority    =   'High';
        Tsk.OwnerID     =    UserInfo.getUserId();
        Tsk.Subject     =   'Task for Card Hierarchy';
        Tsk.Status      =   'Not Started';
        Tsk.ActivityDate =   System.today();
        Tsk.WhatId      =   kc.Id;
        Tsk.Description =   'Testing Task with Card hierarchy';
        insert Tsk;

        leankor__KanbanCard__c kc1 = new leankor__KanbanCard__c();
        kc1.Name = 'kanban test1';
        kc1.leankor__GUID__c = 'my-GUID-kanban-test152';
        kc1.leankor__CmpID__c = 'my CMPID kanban test1';
        kc1.leankor__ValueStream__c = vs.Id;
        kc1.leankor__KanbanCardTemplate__c=kct.Id;
        kc1.leankor__DurationUnits__c='Minutes';
        kc1.leankor__EstimatedDuration__c=2;
        kc1.leankor__ZoneGUID__c = 'zone dummy';
        kc1.leankor__ValueStreamCardLink__c=kc.Id;
        kc1.leankor__ValueStreamLink__c =vs.Id;
        kc1.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc1;
       
        Task Tsk1 = new Task();
        Tsk1.Priority    =   'High';
        Tsk1.OwnerID =   UserInfo.getUserId();
        Tsk1.Subject     =   'Task for Card Hierarchy';
        Tsk1.Status      =   'Not Started';
        Tsk1.ActivityDate=   System.today();
        Tsk1.WhatId      =   kc1.Id;
        Tsk1.Description =   'Testing Task with Card hierarchy';
        insert Tsk1;
        
        leankor__dependency__c dep =new leankor__dependency__c();
        dep.leankor__GUID__c=kc.leankor__GUID__c;
        dep.leankor__Predecessor__c=kc.id;
        dep.leankor__Successor__c=kc1.id;
        dep.leankor__ValueStream__c=vs.Id;
        dep.leankor__KanbanCard__c = kc.id;
        insert dep;

        leankor__dependency__c dep2 =new leankor__dependency__c();
        dep2.leankor__GUID__c=kc.leankor__GUID__c+'-1';
        dep2.leankor__Predecessor__c=kc.id;
        dep2.leankor__Successor__c=kc1.id;
        dep2.leankor__ValueStream__c=vs.Id;
        dep2.leankor__KanbanCard__c = kc1.id;
        insert dep2;

        leankor__KanbanCard__c kc2 = new leankor__KanbanCard__c();
        kc2.Name = 'kanban test2';
        kc2.leankor__GUID__c = 'my GUID kanban test2';
        kc2.leankor__CmpID__c = 'my CMPID kanban test2';
        kc2.leankor__ValueStream__c = vs.Id;
        kc2.leankor__KanbanCardTemplate__c=kct.Id;
        kc2.leankor__EstimatedDuration__c=2;
        kc2.leankor__ZoneGUID__c = 'zone dummy';
        kc2.leankor__ValueStreamCardLink__c=kc1.Id;
        kc2.leankor__ValueStreamLink__c =vs.Id;
        kc2.leankor__DurationUnits__c='Minutes';
        kc2.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc2;

        leankor__KanbanCardTemplate__c kct1 = new leankor__KanbanCardTemplate__c();
        kct1.Name = 'template name';
        kct1.leankor__Width__c = 100;
        kct1.leankor__Title__c = 'template title';
        kct1.leankor__JSONDefinition__c = '{}';
        kct1.leankor__JSONData__c = '{}';
        kct1.leankor__Height__c = 200;
        kct1.leankor__CSSLayout__c = 'some css';
        kct1.leankor__valueStream__c =vs.id;
        kct1.leankor__color__c = '#CCC';
        insert kct1;

        Task Tsk11 = new Task();
        Tsk11.Priority    =   'High';
        Tsk11.OwnerID =   UserInfo.getUserId();
        Tsk11.Subject     =   'Task for Card Hierarchy';
        Tsk11.Status      =   'Not Started';
        Tsk11.ActivityDate=   System.today();
        Tsk11.WhatId      =   kc1.Id;
        Tsk11.Description =   'Testing Task with Card hierarchy';
        insert Tsk11;
        
        leankor__KanbanCard__c kc3 = new leankor__KanbanCard__c();
        kc3.Name = 'kanban test3';
        kc3.leankor__GUID__c = 'my GUID kanban test3';
        kc3.leankor__CmpID__c = 'my CMPID kanban test3';
        //leankor__ValueStream__c = '',//vs1.Id,
        kc3.leankor__KanbanCardTemplate__c=kct1.Id;
        kc3.leankor__DurationUnits__c='Minutes';
        kc3.leankor__EstimatedDuration__c=2;
        kc3.leankor__ValueStream__c = vs.Id;
        kc3.leankor__StartDate__c =System.today();                      
        kc3.leankor__ZoneGUID__c = 'zone dummy';
        kc3.leankor__ValueStreamCardLink__c=kc.Id;
        kc3.leankor__ValueStreamLink__c =vs.Id;
        kc3.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc3;

        Task Tsk12 = new Task();
        Tsk12.Priority    =   'High';
        Tsk12.OwnerID =   UserInfo.getUserId();
        Tsk12.Subject     =   'Task for Card Hierarchy';
        Tsk12.Status      =   'Not Started';
        Tsk12.ActivityDate=   System.today();
        Tsk12.WhatId      =   kc3.Id;
        Tsk12.Description =   'Testing Task with Card hierarchy';
        insert Tsk12;
         
        leankor__KanbanCard__c kc4 = new leankor__KanbanCard__c();
        kc4.Name = 'kanban test4';
        kc4.leankor__GUID__c = 'my GUID kanban test4';
        kc4.leankor__CmpID__c = 'my CMPID kanban test4';
        kc4.OwnerId = user1.Id;
        kc4.leankor__StartDate__c = System.now().date();
        kc4.leankor__DueDate__c = System.now().addDays(3).date();
        kc4.leankor__ValueStream__c = vs1.Id;
        kc4.leankor__KanbanCardTemplate__c=kct1.Id;
        kc4.leankor__ValueStreamCardLink__c=kc.Id;
        kc4.leankor__ValueStreamLink__c =vs.Id;
        kc4.leankor__DurationUnits__c='Minutes';
        kc4.leankor__ZoneGUID__c = 'zone dummy';
        kc4.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc4;

        Task Tsk13 = new Task();
        Tsk13.Priority    =   'High';
        Tsk13.OwnerID =   UserInfo.getUserId();
        Tsk13.Subject     =   'Task for Card Hierarchy';
        Tsk13.Status      =   'Not Started';
        Tsk13.ActivityDate=   System.today();
        Tsk13.WhatId      =   kc4.Id;
        Tsk13.Description =   'Testing Task with Card hierarchy';
        insert Tsk13;

        list<string> VSIDs = new List<string>();
        VSIDs.add(vs.Id);
        VSIDs.add(vs1.Id);
    
        
        leankor.KanbanToGanttController.MasterContainer filterData1 = new leankor.KanbanToGanttController.MasterContainer();
        filterData1.ValueStreamID = vs.Id;
        filterData1.StartDate = (system.now()-10).format('yyyy-MM-dd');
        filterData1.DueDate = (system.now()+10).format('yyyy-MM-dd');
        filterData1.lastCardId=''; 
        filterData1.lastTaskId='';
        CardHierarchyController.filterData = filterData1;
        CardHierarchyController.IscurrentUserPartner = true;
        CardHierarchyController.UserStandard = new List<String>{user1.Id, user2.Id};
        List<leankor.KanbanToGanttController.MasterContainer> result = CardHierarchyController.getAssociatedCardsOfResources(new List<String>{user1.Id, user2.Id}, VSIDs, kc.Id,'other');
        System.assert(result!=null);
        
    }
    
    private static testMethod void getAssociatedCardsOfResources2(){
        User user1 = leankor.TestDataFactory.createStandardUser('Lean');
        User user2 = leankor.TestDataFactory.createStandardUser('Leankor');  
        
        leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c();
        pr1.Name = 'myroom';
        insert pr1;

        leankor__ValueStream__c vs= new leankor__ValueStream__c();
        vs.leankor__ProjectRoom__c = pr1.ID;
        vs.Name = 'myVS';
        vs.leankor__DisableTaskAsMiniature__c=true;
        vs.leankor__BoardType__c='Portfolio View';
        vs.leankor__Istemplateboard__c=false;
        insert vs;

        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c();
        kct.Name = 'template name';
        kct.leankor__Width__c = 100;
        kct.leankor__Title__c = 'template title';
        kct.leankor__JSONDefinition__c = '{}';
        kct.leankor__JSONData__c = '{}';
        kct.leankor__Height__c = 200;
        kct.leankor__CSSLayout__c = 'some css';
        kct.leankor__color__c = '#CCC';
        kct.leankor__valueStream__c =vs.id;
        insert kct;

        // set up a standard controller page
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(vs);
        leankor.CardHierarchyController rkc = new leankor.CardHierarchyController(sc);
        //Initializing TempMasterContainer
        leankor.CardHierarchyController.TempMasterContainer Tmc = new leankor.CardHierarchyController.TempMasterContainer();

        Task Tsk14 = new Task();
        Tsk14.Priority = 'High';
        Tsk14.OwnerID = UserInfo.getUserId();
        Tsk14.Subject = 'Task for Card Hierarchy';
        Tsk14.Status = 'Not Started';
        Tsk14.ActivityDate = System.today();
        Tsk14.WhatId = kct.Id;
        Tsk14.Description = 'Testing Task with Card hierarchy';
        insert Tsk14;
     
        leankor__ValueStream__c vs1= new leankor__ValueStream__c();
        vs1.leankor__ProjectRoom__c = pr1.id;
        vs1.Name = 'myVS1';
        vs1.leankor__Istemplateboard__c=false;
        insert vs1;
        
        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Name = 'kanban test';
        kc.leankor__Y__c = 20;
        kc.leankor__X__c = 50;
        kc.leankor__Width__c = 100;
        kc.leankor__ValueStream__c = vs.Id;
        kc.leankor__Top__c = 150;
        kc.leankor__Title__c = 'kanban title test';
        kc.leankor__Left__c = 250;
        kc.leankor__JSONDefinition__c = '{}';
        kc.leankor__JSONData__c = '{}';
        kc.leankor__Height__c = 110;
        kc.leankor__GUID__c = 'my-GUID-kanban-test-151';
        kc.leankor__CmpID__c = 'my CMPID kanban test';
        kc.leankor__CSSLayout__c = 'some css';
        kc.leankor__Bottom__c = 450;
        kc.leankor__Priority__c = 1;
        kc.leankor__KanbanCardTemplate__c=kct.Id;
        kc.leankor__DurationUnits__c='Minutes';
        kc.leankor__EstimatedDuration__c=200;
        kc.leankor__Order__C = 2;
        kc.leankor__ZoneGUID__c = 'Zone dummy';
        kc.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc;
        
        Task Tsk = new Task();
        Tsk.Priority    =   'High';
        Tsk.OwnerID     =    UserInfo.getUserId();
        Tsk.Subject     =   'Task for Card Hierarchy';
        Tsk.Status      =   'Not Started';
        Tsk.ActivityDate =   System.today();
        Tsk.WhatId      =   kc.Id;
        Tsk.Description =   'Testing Task with Card hierarchy';
        insert Tsk;

        leankor__KanbanCard__c kc1 = new leankor__KanbanCard__c();
        kc1.Name = 'kanban test1';
        kc1.leankor__GUID__c = 'my-GUID-kanban-test152';
        kc1.leankor__CmpID__c = 'my CMPID kanban test1';
        kc1.leankor__ValueStream__c = vs.Id;
        kc1.leankor__KanbanCardTemplate__c=kct.Id;
        kc1.leankor__DurationUnits__c='Minutes';
        kc1.leankor__EstimatedDuration__c=2;
        kc1.leankor__ZoneGUID__c = 'zone dummy';
        kc1.leankor__ValueStreamCardLink__c=kc.Id;
        kc1.leankor__ValueStreamLink__c =vs.Id;
        kc1.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc1;
       
        Task Tsk1 = new Task();
        Tsk1.Priority    =   'High';
        Tsk1.OwnerID =   UserInfo.getUserId();
        Tsk1.Subject     =   'Task for Card Hierarchy';
        Tsk1.Status      =   'Not Started';
        Tsk1.ActivityDate=   System.today();
        Tsk1.WhatId      =   kc1.Id;
        Tsk1.Description =   'Testing Task with Card hierarchy';
        insert Tsk1;
        
        leankor__dependency__c dep =new leankor__dependency__c();
        dep.leankor__GUID__c=kc.leankor__GUID__c;
        dep.leankor__Predecessor__c=kc.id;
        dep.leankor__Successor__c=kc1.id;
        dep.leankor__ValueStream__c=vs.Id;
        dep.leankor__KanbanCard__c = kc.id;
        insert dep;

        leankor__dependency__c dep2 =new leankor__dependency__c();
        dep2.leankor__GUID__c=kc.leankor__GUID__c+'-1';
        dep2.leankor__Predecessor__c=kc.id;
        dep2.leankor__Successor__c=kc1.id;
        dep2.leankor__ValueStream__c=vs.Id;
        dep2.leankor__KanbanCard__c = kc1.id;
        insert dep2;

        leankor__KanbanCard__c kc2 = new leankor__KanbanCard__c();
        kc2.Name = 'kanban test2';
        kc2.leankor__GUID__c = 'my GUID kanban test2';
        kc2.leankor__CmpID__c = 'my CMPID kanban test2';
        kc2.leankor__ValueStream__c = vs.Id;
        kc2.leankor__KanbanCardTemplate__c=kct.Id;
        kc2.leankor__EstimatedDuration__c=2;
        kc2.leankor__ZoneGUID__c = 'zone dummy';
        kc2.leankor__ValueStreamCardLink__c=kc1.Id;
        kc2.leankor__ValueStreamLink__c =vs.Id;
        kc2.leankor__DurationUnits__c='Minutes';
        kc2.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc2;

        leankor__KanbanCardTemplate__c kct1 = new leankor__KanbanCardTemplate__c();
        kct1.Name = 'template name';
        kct1.leankor__Width__c = 100;
        kct1.leankor__Title__c = 'template title';
        kct1.leankor__JSONDefinition__c = '{}';
        kct1.leankor__JSONData__c = '{}';
        kct1.leankor__Height__c = 200;
        kct1.leankor__CSSLayout__c = 'some css';
        kct1.leankor__valueStream__c =vs.id;
        kct1.leankor__color__c = '#CCC';
        insert kct1;

        Task Tsk11 = new Task();
        Tsk11.Priority    =   'High';
        Tsk11.OwnerID =   UserInfo.getUserId();
        Tsk11.Subject     =   'Task for Card Hierarchy';
        Tsk11.Status      =   'Not Started';
        Tsk11.ActivityDate=   System.today();
        Tsk11.WhatId      =   kc1.Id;
        Tsk11.Description =   'Testing Task with Card hierarchy';
        insert Tsk11;
        
        leankor__KanbanCard__c kc3 = new leankor__KanbanCard__c();
        kc3.Name = 'kanban test3';
        kc3.leankor__GUID__c = 'my GUID kanban test3';
        kc3.leankor__CmpID__c = 'my CMPID kanban test3';
        //leankor__ValueStream__c = '',//vs1.Id,
        kc3.leankor__KanbanCardTemplate__c=kct1.Id;
        kc3.leankor__DurationUnits__c='Minutes';
        kc3.leankor__EstimatedDuration__c=2;
        kc3.leankor__ValueStream__c = vs.Id;
        kc3.leankor__StartDate__c =System.today();                      
        kc3.leankor__ZoneGUID__c = 'zone dummy';
        kc3.leankor__ValueStreamCardLink__c=kc.Id;
        kc3.leankor__ValueStreamLink__c =vs.Id;
        kc3.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc3;

        Task Tsk12 = new Task();
        Tsk12.Priority    =   'High';
        Tsk12.OwnerID =   UserInfo.getUserId();
        Tsk12.Subject     =   'Task for Card Hierarchy';
        Tsk12.Status      =   'Not Started';
        Tsk12.ActivityDate=   System.today();
        Tsk12.WhatId      =   kc3.Id;
        Tsk12.Description =   'Testing Task with Card hierarchy';
        insert Tsk12;
         
        leankor__KanbanCard__c kc4 = new leankor__KanbanCard__c();
        kc4.Name = 'kanban test4';
        kc4.leankor__GUID__c = 'my GUID kanban test4';
        kc4.leankor__CmpID__c = 'my CMPID kanban test4';
        kc4.OwnerId = user1.Id;
        kc4.leankor__StartDate__c = System.now().date();
        kc4.leankor__DueDate__c = System.now().addDays(3).date();
        kc4.leankor__ValueStream__c = vs1.Id;
        kc4.leankor__KanbanCardTemplate__c=kct1.Id;
        kc4.leankor__ValueStreamCardLink__c=kc.Id;
        kc4.leankor__ValueStreamLink__c =vs.Id;
        kc4.leankor__DurationUnits__c='Minutes';
        kc4.leankor__ZoneGUID__c = 'zone dummy';
        kc4.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc4;

        Task Tsk13 = new Task();
        Tsk13.Priority    =   'High';
        Tsk13.OwnerID =   UserInfo.getUserId();
        Tsk13.Subject     =   'Task for Card Hierarchy';
        Tsk13.Status      =   'Not Started';
        Tsk13.ActivityDate=   System.today();
        Tsk13.WhatId      =   kc4.Id;
        Tsk13.Description =   'Testing Task with Card hierarchy';
        insert Tsk13;

        list<string> VSIDs = new List<string>();
        VSIDs.add(vs.Id);
        VSIDs.add(vs1.Id);
    
        
        leankor.KanbanToGanttController.MasterContainer filterData1 = new leankor.KanbanToGanttController.MasterContainer();
        filterData1.ValueStreamID = vs.Id;
        filterData1.StartDate = (system.now()-10).format('yyyy-MM-dd');
        filterData1.DueDate = (system.now()+10).format('yyyy-MM-dd');
        filterData1.lastCardId = kc4.Id; 
        filterData1.lastTaskId = '';

        CardHierarchyController.filterData = filterData1;
        CardHierarchyController.IscurrentUserPartner = true;
        CardHierarchyController.UserStandard = new List<String>{user1.Id, user2.Id};
        List<leankor.KanbanToGanttController.MasterContainer> result = CardHierarchyController.getAssociatedCardsOfResources(new List<String>{user1.Id, user2.Id}, VSIDs, kc.Id,'other');
        System.assert(result!=null);
        
    }
    
   private static testMethod void getAssociatedTaskOfResources1(){
        
        User user1 = leankor.TestDataFactory.createStandardUser('Lean'); 

        leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c();
        pr1.Name = 'myroom';
        insert pr1;
        
  	    leankor__ValueStream__c vs= new leankor__ValueStream__c();
        vs.leankor__ProjectRoom__c = pr1.ID;
        vs.Name = 'myVS';
        vs.leankor__DisableTaskAsMiniature__c=true;
        vs.leankor__boardtype__c='Portfolio View';
        vs.leankor__Istemplateboard__c=false;
        insert vs;

        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c();
        kct.Name = 'template name';
        kct.leankor__Width__c = 100;
        kct.leankor__Title__c = 'template title';
        kct.leankor__JSONDefinition__c = '{}';
        kct.leankor__JSONData__c = '{}';
        kct.leankor__Height__c = 200;
        kct.leankor__CSSLayout__c = 'some css';
        kct.leankor__color__c = '#CCC';
        kct.leankor__valueStream__c =vs.id;
        insert kct;

        Task Tsk14 = new Task();
        Tsk14.Priority = 'High';
        Tsk14.OwnerID = UserInfo.getUserId();
        Tsk14.Subject = 'Task for Card Hierarchy';
        Tsk14.Status = 'Not Started';
        Tsk14.ActivityDate = System.today();
        Tsk14.WhatId = kct.Id;
        Tsk14.Description =   'Testing Task with Card hierarchy';
        insert Tsk14;
     
        leankor__ValueStream__c vs1= new leankor__ValueStream__c();
        vs1.leankor__ProjectRoom__c = pr1.id;
        vs1.Name = 'myVS1';
        vs1.leankor__Istemplateboard__c = false; 
        vs1.leankor__boardtype__c = 'Portfoo View';
        insert vs1;

        leankor__mastercontainer__c Newmc = new leankor__mastercontainer__c();
        Newmc.name = 'MC1';
        Newmc.leankor__ValueStream__c = vs1.id; 
        Newmc.leankor__Type__c = 'Tempate';
        insert Newmc;

        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Name = 'kanban test';
        kc.leankor__Y__c = 20;
        kc.leankor__X__c = 50;
        kc.leankor__Width__c = 100;
        kc.leankor__ValueStream__c = vs.Id;
        kc.leankor__Top__c = 150;
        kc.leankor__Title__c = 'kanban title test';
        kc.leankor__Left__c = 250;
        kc.leankor__JSONDefinition__c = '{}';
        kc.leankor__JSONData__c = '{}';
        kc.leankor__Height__c = 110;
        kc.leankor__GUID__c = 'my-GUID-kanban-test-151';
        kc.leankor__CmpID__c = 'my CMPID kanban test';
        kc.leankor__CSSLayout__c = 'some css';
        kc.leankor__Bottom__c = 450;
        kc.leankor__Priority__c = 1;
        kc.leankor__KanbanCardTemplate__c=kct.Id;
        kc.leankor__DurationUnits__c='Minutes';
        kc.leankor__EstimatedDuration__c=200;
        kc.leankor__Order__C = 2;
        kc.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc;
        
        Task Tsk = new Task();
        Tsk.Priority    =   'High';
        Tsk.OwnerID     =    UserInfo.getUserId();
        Tsk.Subject     =   'Task for Card Hierarchy';
        Tsk.Status      =   'Not Started';
        Tsk.ActivityDate =   System.today();
        Tsk.WhatId      =   kc.Id;
        Tsk.Description =   'Testing Task with Card hierarchy';
        insert Tsk;
        
        leankor__KanbanCard__c kc1 = new leankor__KanbanCard__c();
        kc1.Name = 'kanban test1';
        kc1.leankor__GUID__c = 'my-GUID-kanban-test152';
        kc1.leankor__CmpID__c = 'my CMPID kanban test1';
        kc1.leankor__ValueStream__c = vs.Id;
        kc1.leankor__KanbanCardTemplate__c=kct.Id;
        kc1.leankor__DurationUnits__c='Minutes';
        kc1.leankor__EstimatedDuration__c=2;
        kc1.leankor__ValueStreamCardLink__c=kc.Id;
        kc1.leankor__ValueStreamLink__c =vs.Id;
        kc1.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc1;
       
        Task Tsk1 = new Task();
        Tsk1.Priority    =   'High';
        Tsk1.OwnerID =   UserInfo.getUserId();
        Tsk1.Subject     =   'Task for Card Hierarchy';
        Tsk1.Status      =   'Not Started';
        Tsk1.ActivityDate=   System.today();
        Tsk1.WhatId      =   kc1.Id;
        Tsk1.Description =   'Testing Task with Card hierarchy';
        insert Tsk1;
        
        
         
        leankor__KanbanCard__c kc4 = new leankor__KanbanCard__c();
        kc4.Name = 'kanban test4';
        kc4.leankor__GUID__c = 'my GUID kanban test4';
        kc4.leankor__CmpID__c = 'my CMPID kanban test4';
        kc4.OwnerId = user1.Id;
        kc4.leankor__StartDate__c = System.now().date();
        kc4.leankor__DueDate__c = System.now().addDays(2).date();
        kc4.leankor__ValueStream__c = vs1.Id;
        kc4.leankor__KanbanCardTemplate__c=kct.Id;
        kc4.leankor__ValueStreamCardLink__c=kc.Id;
        kc4.leankor__ValueStreamLink__c =vs.Id;
        kc4.leankor__DurationUnits__c='Minutes';
        kc4.leankor__mastercontainer__c = Newmc.Id;
        kc4.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc4;

        Task Tsk13 = new Task();
        Tsk13.Priority    =   'High';
        Tsk13.OwnerID =   user1.Id;
        Tsk13.Subject     =   'Task for Card Hierarchy';
        Tsk13.Status      =   'Not Started';
        Tsk13.ActivityDate=   System.today();
        Tsk13.WhatId      =   kc4.Id;
        Tsk13.Description =   'Testing Task with Card hierarchy';
        insert Tsk13;

        list<string> VSIDs = new List<string>();
        VSIDs.add(vs.Id);
        VSIDs.add(vs1.Id);
    
        
        list<string> project = new List<string>();
        project.add(pr1.id);

        leankor.KanbanToGanttController.MasterContainer filterData1 = new leankor.KanbanToGanttController.MasterContainer();
        filterData1.ValueStreamID = vs.Id;
        filterData1.StartDate = (system.now()-10).format('yyyy-MM-dd');
        filterData1.DueDate = (system.now()+10).format('yyyy-MM-dd');
        //filterData1.lastCardId=kc.Id; 
        filterData1.lastTaskId=Tsk13.Id;
        
        CardHierarchyController.filterData = filterData1;
        CardHierarchyController.IscurrentUserPartner = true;
        CardHierarchyController.beginDate = System.now().addDays(-2676).date();
        CardHierarchyController.endDate = System.now().addDays(67).date();
        CardHierarchyController.UserStandard = new List<String>{user1.Id};
        List<leankor.KanbanToGanttController.MasterContainer> result = CardHierarchyController.getAssociatedTaskOfResources(new List<String>{user1.Id}, new List<leankor__KanbanCard__c>(), VSIDs);
        System.debug(result);
        System.assert(result!=null);
        
    }

    private static testMethod void getAssociatedTaskOfResources2() {
        
        User user1 = leankor.TestDataFactory.createStandardUser('Lean'); 

        leankor__ProjectRoom__c pr1 = new leankor__ProjectRoom__c();
        pr1.Name = 'myroom';
        insert pr1;
        
  	    leankor__ValueStream__c vs= new leankor__ValueStream__c();
        vs.leankor__ProjectRoom__c = pr1.ID;
        vs.Name = 'myVS';
        vs.leankor__DisableTaskAsMiniature__c=true;
        vs.leankor__boardtype__c='Portfolio View';
        vs.leankor__Istemplateboard__c=false;
        insert vs;

        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c();
        kct.Name = 'template name';
        kct.leankor__Width__c = 100;
        kct.leankor__Title__c = 'template title';
        kct.leankor__JSONDefinition__c = '{}';
        kct.leankor__JSONData__c = '{}';
        kct.leankor__Height__c = 200;
        kct.leankor__CSSLayout__c = 'some css';
        kct.leankor__color__c = '#CCC';
        kct.leankor__valueStream__c =vs.id;
        insert kct;

        Task Tsk14 = new Task();
        Tsk14.Priority = 'High';
        Tsk14.OwnerID = UserInfo.getUserId();
        Tsk14.Subject = 'Task for Card Hierarchy';
        Tsk14.Status = 'Not Started';
        Tsk14.ActivityDate = System.today();
        Tsk14.WhatId = kct.Id;
        Tsk14.Description =   'Testing Task with Card hierarchy';
        insert Tsk14;
     
        leankor__ValueStream__c vs1= new leankor__ValueStream__c();
        vs1.leankor__ProjectRoom__c = pr1.id;
        vs1.Name = 'myVS1';
        vs1.leankor__Istemplateboard__c = false; 
        vs1.leankor__boardtype__c = 'Portfoo View';
        insert vs1;

        leankor__mastercontainer__c Newmc = new leankor__mastercontainer__c();
        Newmc.name = 'MC1';
        Newmc.leankor__ValueStream__c = vs1.id; 
        Newmc.leankor__Type__c = 'Tempate';
        insert Newmc;

        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Name = 'kanban test';
        kc.leankor__Y__c = 20;
        kc.leankor__X__c = 50;
        kc.leankor__Width__c = 100;
        kc.leankor__ValueStream__c = vs.Id;
        kc.leankor__Top__c = 150;
        kc.leankor__Title__c = 'kanban title test';
        kc.leankor__Left__c = 250;
        kc.leankor__JSONDefinition__c = '{}';
        kc.leankor__JSONData__c = '{}';
        kc.leankor__Height__c = 110;
        kc.leankor__GUID__c = 'my-GUID-kanban-test-151';
        kc.leankor__CmpID__c = 'my CMPID kanban test';
        kc.leankor__CSSLayout__c = 'some css';
        kc.leankor__Bottom__c = 450;
        kc.leankor__Priority__c = 1;
        kc.leankor__KanbanCardTemplate__c=kct.Id;
        kc.leankor__DurationUnits__c='Minutes';
        kc.leankor__EstimatedDuration__c=200;
        kc.leankor__Order__C = 2;
        kc.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc;
        
        Task Tsk = new Task();
        Tsk.Priority    =   'High';
        Tsk.OwnerID     =    UserInfo.getUserId();
        Tsk.Subject     =   'Task for Card Hierarchy';
        Tsk.Status      =   'Not Started';
        Tsk.ActivityDate =   System.today();
        Tsk.WhatId      =   kc.Id;
        Tsk.Description =   'Testing Task with Card hierarchy';
        insert Tsk;
        
        leankor__KanbanCard__c kc1 = new leankor__KanbanCard__c();
        kc1.Name = 'kanban test1';
        kc1.leankor__GUID__c = 'my-GUID-kanban-test152';
        kc1.leankor__CmpID__c = 'my CMPID kanban test1';
        kc1.leankor__ValueStream__c = vs.Id;
        kc1.leankor__KanbanCardTemplate__c=kct.Id;
        kc1.leankor__DurationUnits__c='Minutes';
        kc1.leankor__EstimatedDuration__c=2;
        kc1.leankor__ValueStreamCardLink__c=kc.Id;
        kc1.leankor__ValueStreamLink__c =vs.Id;
        kc1.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc1;
       
        Task Tsk1 = new Task();
        Tsk1.Priority    =   'High';
        Tsk1.OwnerID =   UserInfo.getUserId();
        Tsk1.Subject     =   'Task for Card Hierarchy';
        Tsk1.Status      =   'Not Started';
        Tsk1.ActivityDate=   System.today();
        Tsk1.WhatId      =   kc1.Id;
        Tsk1.Description =   'Testing Task with Card hierarchy';
        insert Tsk1;
        
        
         
        leankor__KanbanCard__c kc4 = new leankor__KanbanCard__c();
        kc4.Name = 'kanban test4';
        kc4.leankor__GUID__c = 'my GUID kanban test4';
        kc4.leankor__CmpID__c = 'my CMPID kanban test4';
        kc4.OwnerId = user1.Id;
        kc4.leankor__StartDate__c = System.now().date();
        kc4.leankor__DueDate__c = System.now().addDays(2).date();
        kc4.leankor__ValueStream__c = vs1.Id;
        kc4.leankor__KanbanCardTemplate__c=kct.Id;
        kc4.leankor__ValueStreamCardLink__c=kc.Id;
        kc4.leankor__ValueStreamLink__c =vs.Id;
        kc4.leankor__DurationUnits__c='Minutes';
        kc4.leankor__mastercontainer__c = Newmc.Id;
        kc4.RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        insert kc4;

        Task Tsk13 = new Task();
        Tsk13.Priority    =   'High';
        Tsk13.OwnerID =   user1.Id;
        Tsk13.Subject     =   'Task for Card Hierarchy';
        Tsk13.Status      =   'Not Started';
        Tsk13.ActivityDate=   System.today();
        Tsk13.WhatId      =   kc4.Id;
        Tsk13.Description =   'Testing Task with Card hierarchy';
        insert Tsk13;

        list<string> VSIDs = new List<string>();
        VSIDs.add(vs.Id);
        VSIDs.add(vs1.Id);
    
        
        list<string> project = new List<string>();
        project.add(pr1.id);
        
        leankor.KanbanToGanttController.MasterContainer filterData1 = new leankor.KanbanToGanttController.MasterContainer();
        filterData1.ValueStreamID = vs.Id;
        filterData1.StartDate = (system.now()-10).format('yyyy-MM-dd');
        filterData1.DueDate = (system.now()+10).format('yyyy-MM-dd');
        //filterData1.lastCardId=kc.Id; 
        filterData1.lastTaskId = '';
        
        CardHierarchyController.filterData = filterData1;
        CardHierarchyController.IscurrentUserPartner = true;
        CardHierarchyController.beginDate = System.now().addDays(-2676).date();
        CardHierarchyController.endDate = System.now().addDays(67).date();
        CardHierarchyController.UserStandard = new List<String>{user1.Id};
        List<leankor.KanbanToGanttController.MasterContainer> result = CardHierarchyController.getAssociatedTaskOfResources(new List<String>{user1.Id}, new List<leankor__KanbanCard__c>(), VSIDs);
        System.debug(result);
        System.assert(result!=null);
        
    }
  
}