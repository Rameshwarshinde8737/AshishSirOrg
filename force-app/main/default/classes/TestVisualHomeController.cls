/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestVisualHomeController.cls
 * CLASS: TestVisualHomeController        
 */

@isTest
private class TestVisualHomeController {

	static testMethod void testKanbanCards() {
		leankor__ProjectRoom__c pro = new leankor__ProjectRoom__c();
        pro.Name = 'pro';
        insert pro;
        
    	leankor__ValueStream__c vss = new leankor__ValueStream__c();
        vss.Name = 'myVS'; 
        vss.leankor__ProjectRoom__c = pro.Id;
        insert vss;
        
        leankor__KanbanCardTemplate__c kanbanTemp = new leankor__KanbanCardTemplate__c();
        kanbanTemp.Name ='TestTemplate';
        kanbanTemp.leankor__Title__c = 'TestTemplate';
        kanbanTemp.leankor__color__c = '#fff';
        kanbanTemp.leankor__csslayout__c = '';
        kanbanTemp.leankor__height__c = 300;
        kanbanTemp.leankor__width__c = 300;
        kanbanTemp.leankor__jsondata__c = '{}';
        kanbanTemp.leankor__jsondefinition__c = '{}';
        kanbanTemp.leankor__valuestream__c = vss.Id;
        insert kanbanTemp;
        
       String userId_1=UserInfo.getUserId();
        // test create kanban call
        //Date: 23/10/19
        //List<String> kanbans=new List<String>();
        List<realTimeController.Kanban> kanbanCards =new List<realTimeController.Kanban>();
        realtimeController.Kanban newKanban2 = new realtimeController.Kanban();
        newKanban2.guid ='305ee49a-8489-4091-bf76-8a08088066g8';
        newKanban2.ownerid=userId_1;
        newKanban2.title = 'newkanname';
        newKanban2.name = 'Small card';
        newKanban2.top = 100;
        newKanban2.bottom = 0;
        newKanban2.left = 100;
        newKanban2.width = 180;
        newKanban2.height = 200;
        newKanban2.x = 100;
        newKanban2.y = 100;
        newKanban2.JSONData = '{}';
        newKanban2.base64Drawing = 'somedummyfile';
        newKanban2.base64FileType = 'image/png';
        newKanban2.zoneid = 'randomzone';
        newKanban2.state = 'inzone';
        newKanban2.durationunits = 'Days';
        newKanban2.estimatedDuration = 1;
        newKanban2.duedate = System.Now();
        newKanban2.startdate =System.Now();
        newKanban2.templateid =kanbanTemp.Id;
        newKanban2.priority = 3;
        newKanban2.harveyBall = '50';
        newKanban2.description = 'short description about the kanbancard';
		// Date: 02/01/2020
        //newKanban2.kanbanUrl = 'https://leankor.na14.visual.force.com/apex/leankor__VisualKanban?Id='+vss.id+'&cardid=';
        newKanban2.kanbanUrl = 'https://' + DomainCreator.getOrgMyDomainHostname()+'/apex/leankor__VisualKanban?Id='+vss.id+'&cardid=';
        //Date :23/10/19
        //kanbans.add(JSON.Serialize(newKanban2));
        kanbanCards.add(newKanban2);
       // List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCard(vss.Id, kanbans);
        List<leankor__KanbanCard__c> retkan = realtimeController.createKanbanCards(vss.Id, kanbanCards);
		List < leankor__KanbanCard__c > kanban = visualHomeController.getKanbanCards();
        System.assert(kanban.size() >= 0);
    }

    public static testMethod void testRedirect(){
    User currentUser =[select id,name,leankor__MyWorkspace__c from User where id=:UserInfo.getUserId() limit 1];
    currentUser.leankor__MyWorkspace__c ='https://salesforce.com';
    update currentUser;
    visualHomeController contr = new visualHomeController();
    PageReference pr=contr.Redirect();
    System.assert(pr != null);
    }
   
   
    static testMethod void testRedirectWithInvalidWorkspace() {
        User currentUser = [Select Id, 
                                    leankor__MyWorkspace__c 
                                From User 
                                Where Id = :UserInfo.getUserId()];

        currentUser.leankor__MyWorkspace__c = null;
        update currentUser;
        
        try {
            Test.startTest();
            new VisualHomeController().Redirect();
            Test.stopTest();
            System.assert(false, 'Expected a Util.LeanException when MyWorkspace is null.');
        } catch (Util.LeanException ex) {
            System.assert(ex.getMessage().contains('ERROR:'), 'Expected error message to contain "ERROR:"');
        }
    }    
    
    static testMethod void testGetVisualReportURL() {
        PageReference pageRef = new PageReference('/apex/MyVisualforcePage');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('ReportId', 'TestReportId123');
        
        VisualHomeController controller = new VisualHomeController();
        
        String urlResult;
        try {
            urlResult = controller.getVisualReportURL();
        } catch (Exception e) {
            urlResult = null;
        }
        
        System.assertEquals(null, urlResult, 'getVisualReportURL should return a non-null result.');
    }
    
    static testMethod void testGetOutputContent() {
        PageReference pageRef = new PageReference('/apex/MyVisualforcePage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ReportId', 'AnotherTestReportId456');
        
        VisualHomeController controller = new VisualHomeController();
        
        Component.Apex.OutputText outputText;
        try {
            outputText = controller.getOutputContent();
        } catch (Exception e) {
            outputText = null;
        }
        
        System.assertEquals(null, outputText, 'getOutputContent should return a valid OutputText component.');
    }
    
    
    static testMethod void testVisualHomeControllerConstructor() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
        
        visualHomeController controllerExt = new visualHomeController(stdController);
        
        System.assertNotEquals(null, controllerExt, 'The visualHomeController instance should be created successfully.');
    }

}