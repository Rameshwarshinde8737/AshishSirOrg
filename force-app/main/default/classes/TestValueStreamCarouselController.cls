/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestValueStreamCarouselController.cls
 * CLASS: TestValueStreamCarouselController 
 */
 
@isTest
private class TestValueStreamCarouselController {
    
     public static testMethod void testCarousel() {
        
        List<leankor__ProjectRoom__c> lprL = new List<leankor__ProjectRoom__c>();
        leankor__ProjectRoom__c lpr = new leankor__ProjectRoom__c(Name = 'aroom');
        lprL.add(lpr);
        insert lprL;
        
        // did it insert?
        leankor__ProjectRoom__c lpr2 = [SELECT Id, Name FROM leankor__ProjectRoom__c WHERE Id = :lpr.Id LIMIT 1];
        String lprName = lpr2.Name;
        System.Assert(lprName.contains('aroom'));
        
        leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myvaluestream', leankor__ProjectRoom__c = lprL[0].Id);
        insert vs;
        
        // did it insert?
        leankor__ValueStream__c vs2 = [SELECT Id, Name, leankor__ProjectRoom__c FROM leankor__ValueStream__c WHERE Id = :vs.Id LIMIT 1];
        String vsName = vs2.Name;
        System.Assert(vsName.contains('myvaluestream'));
        System.Assert(vs2.leankor__ProjectRoom__c == vs.leankor__ProjectRoom__c);
        
        // set up one attachment as preview
        Attachment att = new Attachment();
        Blob myBlob = Blob.valueOf('blobdata');
        Attachment myatt = new Attachment(Body = myBlob, ContentType='text/plain', parentId = lprL[0].Id, Name = 'zhepreview.txt');
        insert myatt;
        
        // setup standard controller
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(lprL);    
        
        // call the main controller
        ValueStreamCarouselController vscc = new ValueStreamCarouselController(ssc);
        
        // call remote action
        Map<ID, List<ValueStreamCarouselController.wrapperAttachment>> mymap =  ValueStreamCarouselController.ValueStreamCarousel(lprL[0].Id);
        Test.startTest();
        try{
            Map<ID, List<ValueStreamCarouselController.wrapperAttachment>> mapToTestNegative =  ValueStreamCarouselController.ValueStreamCarousel('00Dd0000001h60X');
        }
        catch (Exception e) {
            System.Assert(e.getMessage().contains('Invalid input'));
        }
        Test.stopTest();
        
        // misc tests on wrapper attachments
        ValueStreamCarouselController.wrapperAttachment wa = new ValueStreamCarouselController.wrapperAttachment();
        ValueStreamCarouselController.wrapperAttachment wa1 = new ValueStreamCarouselController.wrapperAttachment(vs.Id,myatt,lprL[0].Name);
        ValueStreamCarouselController.wrapperAttachment wa2 = new ValueStreamCarouselController.wrapperAttachment(LprL[0].Id);
        ValueStreamCarouselController.wrapperAttachment wa3 = new ValueStreamCarouselController.wrapperAttachment(myatt,LprL[0].Id);
        ValueStreamCarouselController.wrapperAttachment wa4 = new ValueStreamCarouselController.wrapperAttachment(vs.Id,LprL[0].Id);
        ValueStreamCarouselController.wrapperAttachment wa5 = new ValueStreamCarouselController.wrapperAttachment(vs.Id,null,lprL[0].Name);         ValueStreamCarouselController.wrapperAttachment wa7 = new ValueStreamCarouselController.wrapperAttachment(null,LprL[0].Name,'Kanban Board');
        Map<ID, List<ValueStreamCarouselController.wrapperAttachment>> mapPR =  vscc.getmapPRAttachments();
       
        //If attachment list is not null or zero
        Attachment myatt1 = new Attachment(Body = myBlob, ContentType='text/plain', parentId = vs.Id, Name = 'preview.txt');
        insert myatt1;
        Map<ID, List<ValueStreamCarouselController.wrapperAttachment>> mymap1 =  ValueStreamCarouselController.ValueStreamCarousel(lprL[0].Id);
        //List<ValueStreamCarouselController.wrapperAttachment> mymap2 =  ValueStreamCarouselController.ValueStreamSenchaCarousel(lprL[0].Id);
        List<leankor__ProjectRoom__c> lprL1 = new List<leankor__ProjectRoom__c>();
        leankor__ProjectRoom__c lpr1 = new leankor__ProjectRoom__c(Name = 'aroom');
        lprL.add(lpr1);
         leankor__ProjectRoom__c lpr11 = new leankor__ProjectRoom__c(Name = 'aroom');
        lprL.add(lpr11);
        insert lprL1;
         // setup standard controller
        ApexPages.StandardSetController ssc1 = new ApexPages.StandardSetController(lprL1);  
        
        // call the main controller
        ValueStreamCarouselController vscc1 = new ValueStreamCarouselController(ssc1);
         String test='PrName';
         String test_vs='PrName';
         String test_vs1='PrName1';
         leankor__ProjectRoom__c prj=ValueStreamCarouselController.createProjectRoom(test);
         System.assert(prj.Name == test); 
         leankor__ValueStream__c vs_insert=ValueStreamCarouselController.createProjectBoard(test_vs,prj.id,'Kanban Board','','');
         System.assert(vs_insert.Name == test_vs); 
         leankor__KanbanCard__c kc = new leankor__KanbanCard__c(
             Name = 'kanban test ',
             leankor__Y__c = 20,
             leankor__X__c = 50,
             leankor__Width__c = 100,
             leankor__ValueStream__c = vs_insert.Id,
             leankor__Top__c = 150,
             leankor__Title__c = 'kanban title test',
             leankor__State__c = 'zoneaccepted',
             leankor__Left__c = 250,
             leankor__JSONDefinition__c = '{}',
             leankor__JSONData__c = '{}',
             leankor__Height__c = 110,
             leankor__GUID__c = 'my-GUID-kanban-test',
             leankor__CmpID__c = 'my-CMPID-kanban-test',
             leankor__CSSLayout__c = 'some css',
             leankor__Bottom__c = 450,
             leankor__Priority__c = 1
        );
        
        insert kc;
        leankor__ValueStream__c vs_insert2 = ValueStreamCarouselController.createProjectBoard(test_vs1, prj.id, 'Lean Board', vs_insert.id, kc.id);
        System.assert(vs_insert2.Name == test_vs1); 
        test='Test-Project-01';
        leankor__ProjectRoom__c prj1 = ValueStreamCarouselController.createProjectRoom(test);
        System.assert(prj1.Name == test); 
        
        try{
           String test2 = 'Asserts that the first two arguments are different. If they are the same, a fatal error is returned that causes code execution to halt';
           leankor__ProjectRoom__c prj2 = ValueStreamCarouselController.createProjectRoom(test2);
        }
        catch(Exception e){
           System.Assert(e.getMessage().contains('ERROR:Insert failed'));
        }
        test_vs= 'Test-Board-01';
        leankor__ValueStream__c vs_insert1 = ValueStreamCarouselController.createProjectBoard(test_vs, prj.id, 'Lean Board','','');
        System.assert(vs_insert1.Name == test_vs);
    
        try{
            String test_vs3 = 'Asserts that the first two arguments are different. If they are the same, a fatal error is returned that causes code execution to halt';
            leankor__ValueStream__c vs_insert3 = ValueStreamCarouselController.createProjectBoard(test_vs3, prj.id, 'Lean Board','','');
            System.assert(vs_insert3.Name == test_vs3);
        }catch(Exception e){
            System.Assert(e.getMessage().contains('ERROR:Insert failed'));
        }
        /*
        try{
            List<leankor__ProjectRoom__c> prlist = ValueStreamCarouselController.rebuildProjectRoom();
        }catch(Exception e){
            System.Assert(e.getMessage().contains('ERROR'));
        }
        */
        ValueStreamCarouselController.Preference pref = new ValueStreamCarouselController.Preference();
        pref.name = '';
        pref.guid = '123456';
        pref.currentUser = UserInfo.getUserId();
        pref.followonchatter = 'all';
        pref.subscribetocard = 'all';
        pref.valuestream = vs_insert2.Id;
        pref.moved = false;
        pref.cardpastduedate = true;
        pref.percentdone = true;
        pref.taskpastduedate = true;
        pref.valuestreamowner = UserInfo.getUserId();
         
         leankor__Preference__c preference1 = new leankor__Preference__c();
        preference1.Name = 'users';
        preference1.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        preference1.OwnerID = UserInfo.getUserId() ;
        //preference1.leankor__ValueStream__c = vs_insert1.Id;
        preference1.leankor__CardPastDueDate__c = false;
        insert preference1;
         
        
        leankor__Preference__c  preferences=ValueStreamCarouselController.getPreference(pref);
        System.assert( preferences!= null);
        pref.percentdone=true;
        pref.taskpastduedate=true;
        leankor__Preference__c  preferences1=ValueStreamCarouselController.setUserPreferenceAndSecurity(pref);
        System.assert( preferences1!= null); 
     }
    
    public static testMethod void testValueStream() {

        ValueStreamCarouselController vsCC=new ValueStreamCarouselController();
        leankor__ProjectRoom__C pr=new leankor__ProjectRoom__c(Name ='TestRoom');
        insert pr;
        leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myVS',leankor__BoardType__c='Whiteboard',leankor__ProjectRoom__c=pr.Id);
        List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
        vsList.add(vs);
        insert vsList;
        System.assert(vsCC.getValueStreams().size()>0); 
        leankor__KanbanCard__c kc = new leankor__KanbanCard__c(
             Name = 'kanban test ',
             leankor__Y__c = 20,
             leankor__X__c = 50,
             leankor__Width__c = 100,
             leankor__ValueStream__c = vsList[0].Id,
             leankor__Top__c = 150,
             leankor__Title__c = 'kanban title test',
             leankor__State__c = 'zoneaccepted',
             leankor__Left__c = 250,
             leankor__JSONDefinition__c = '{}',
             leankor__JSONData__c = '{}',
             leankor__Height__c = 110,
             leankor__GUID__c = 'my-GUID-kanban-test',
             leankor__CmpID__c = 'my-CMPID-kanban-test',
             leankor__CSSLayout__c = 'some css',
             leankor__Bottom__c = 450,
             leankor__Priority__c = 1,
             leankor__Order__c = 0
        );
        
        insert kc;
        //System.assert( ValueStreamCarouselController.getKanbanCards(vsList[0].Id).size()>0); 
        System.assert( vsCC.getBoardTypes().size()>0); 
        
    }
    
    public static testMethod void testGetVSLinkedCard() {
        leankor.realTimeController.ProjectBoard result = leankor.ValueStreamCarouselController.getVSLinkedCard(null);
        System.assert(result != null);
    }
    
    public static testMethod void valueStreamSenchaCarouselTest(){
        List<ValueStreamCarouselController.WrapperAttachment> result = ValueStreamCarouselController.ValueStreamSenchaCarousel(null);
        System.assert(result!=null);
    }

    public static testMethod void getKanbanCardsTest(){
		leankor__ValueStream__c vs1 = new leankor__ValueStream__c();
        vs1.Name = 'vs1';
        insert vs1;
        
        List<leankor__KanbanCard__c> result = ValueStreamCarouselController.getKanbanCards(vs1.Id);
        System.assert(result!=null);
    }
    
    public static testMethod void rebuildProjectRoomTest(){
        List<leankor__ProjectRoom__c> result = ValueStreamCarouselController.rebuildProjectRoom();
        System.assert(result!=null);
    }
}