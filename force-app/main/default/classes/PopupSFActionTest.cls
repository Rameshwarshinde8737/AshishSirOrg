@isTest
private class PopupSFActionTest {

    /*-----------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover PopupProcess Method inside PopupSFAction Class 
    -------------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void UpdateKanbanCardProcessTest(){ 
    Test.startTest();
        leankor__projectroom__c project = new leankor__projectroom__c( Name ='test');
        insert project;

        leankor__Valuestream__c valueStream = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = project.id);
        insert valueStream;

        leankor__mastercontainer__c NewMC = new leankor__mastercontainer__c();
        NewMC.name= 'MC1';
        NewMC.leankor__Valuestream__c= valueStream.id;
        insert NewMC ;

        leankor__swimlane__c  NewSw = new  leankor__swimlane__c();
        NewSw.name = 'sw';
        NewSw.leankor__mastercontainer__c= NewMC.id;
        NewSw.leankor__Valuestream__c = valueStream.id;
        insert NewSw;         

        leankor__kanbancard__c kanbancard = new leankor__kanbancard__c();
        kanbancard.Name = 'Kanban1';
        kanbancard.leankor__ValueStream__c = valueStream.id;
        kanbancard.leankor__GUID__c = system.now() +'A183289';
        kanbancard.leankor__StartDateTime__c = system.now();                     
        insert kanbancard;

        leankor__Zone__c zone= new leankor__Zone__c();
        zone.name= 'zone1';
        zone.leankor__Width__c= 180.0;  
        zone.leankor__X__c = 767.0;
        zone.leankor__GUID__c = system.now() +'zone1';
        zone.leankor__Y__c= 49.0;
        zone.leankor__swimlane__c= NewSw.id;
        insert zone;

        leankor__ZoneKanbanAction__c zoneKanbanCard = new leankor__ZoneKanbanAction__c();
        zoneKanbanCard.leankor__ActionType2__c = 'left zone';
        zoneKanbanCard.leankor__KanbanCard2__c= kanbancard.id;
        zoneKanbanCard.leankor__ValueStream__c =valueStream.id;
        zoneKanbanCard.leankor__SessionID__c =  userinfo.getSessionId();
        zoneKanbanCard.leankor__Zone2__c = Zone.Id;
        insert zoneKanbanCard;

        list<leankor.PopupSFAction.PopUpRequest> testrequest = new  list<leankor.PopupSFAction.PopUpRequest> ();
        leankor.PopupSFAction.PopUpRequest  request = new leankor.PopupSFAction.PopUpRequest();
        request.CardID =  kanbancard.id;
        request.YES = 'proceed';
        request.Buttonflag= false;
        request.customMessage= 'get card new';
        //request.sessionID = 'ahujfhjdgnildfijdfig';
        request.sessionID = userinfo.getSessionId(); 
        testrequest.add(request);
        System.assert(leankor.PopupSFAction.PopupProcess(testrequest).size()>0);
    Test.stopTest();
    }

    
}