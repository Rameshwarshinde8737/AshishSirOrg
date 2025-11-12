/**
 * Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 * FILE: TestOpportunityTriggerHandler.cls
 * CLASS: TestOpportunityTriggerHandler
 */

 @ isTest
private class TestOpportunityTriggerHandler{
    static testmethod void testOpportunityTriggerHandler() {
        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__DisableKanbanCardTrigger__c = false;
        customSetting.leankor__FirstInstall__c = true;
        customSetting.leankor__DisableCaseTrigger__c= false;
        customSetting.leankor__DisableOpportunityTrigger__c= false;
        customSetting.leankor__AvoidTaskDueDateCheck__c = true;
        try {
            insert customSetting;
        } Catch(Exception Ex) {
            system.debug('Error:'+Ex.getMessage());
        }

        // Create a test account
        Account testAcct = new Account();
        testAcct.Name = 'My Test Account';
        insert testAcct;

        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
		insert testFolder;

		leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
        prjRoom.Name = 'Test Room';
        prjRoom.leankor__Portfolio__c = testFolder.Id;
		insert prjRoom;

        leankor__KanbanCardTemplate__c templatecard = New leankor__KanbanCardTemplate__c();
        templatecard.Name = 'default'; //,leankor__Valuestream__C = vss.id
        insert templatecard;

        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'myVS';
        valueStream.leankor__BoardType__c = 'Kanban Board';
        valueStream.leankor__ProjectRoom__c = prjRoom.Id;
        valueStream.leankor__SevenDayWorkWeek__c = false;
        valueStream.leankor__OpportunityRoleId__c = UserInfo.getUserRoleId();
        valueStream.leankor__OpportunityRecordType__c = 'All';
        valueStream.leankor__OpportunityLeadSource__c = 'All';
        valueStream.leankor__OpportunityCardCategory__c = templatecard.Id;
        valueStream.leankor__OpportunityType__c = 'All';
        valueStream.leankor__OpportunitySynchronization__c = true;
        insert valueStream;

        leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c();
        masterContainer.leankor__Valuestream__C = valueStream.id;
        masterContainer.leankor__Type__c = 'Backlog';
        masterContainer.leankor__IsCardAvailable__c = true; 
        masterContainer.Name = 'zone'; 
        masterContainer.leankor__GUID__c = 'test-1234-' + system.now();
        insert masterContainer;

        leankor__Swimlane__c swimLane = new leankor__Swimlane__c();
        swimLane.leankor__MasterContainer__c = masterContainer.id;
        swimLane.leankor__Valuestream__C = valueStream.id;
        swimLane.Name = 'zone';
        swimLane.leankor__GUID__c = 'test-1234-' + system.now();
        insert swimLane;
        string oppRtype = '';
        try{
            oppRtype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New RecordType').getRecordTypeId();
        } catch(Exception ex) {
            oppRtype = '';
        }
        leankor__AutomationTemplate__c autoTemplate = New leankor__AutomationTemplate__c();
        autoTemplate.leankor__GUID__c = 'test-' + system.now() + '-123';
        autoTemplate.leankor__Account__c = testAcct.Id;
        autoTemplate.leankor__ProjectRoom__c = prjRoom.Id;
        autoTemplate.OwnerId = UserInfo.getUserId();
        autoTemplate.leankor__StageName__c = 'Customer Won';
        autoTemplate.leankor__EndDate__c = System.today() + 2;
        autoTemplate.leankor__StartDate__c = System.today();
        autoTemplate.leankor__ValueStream__c = valueStream.Id;
        autoTemplate.leankor__RecordTypeId__c = oppRtype;
        insert autoTemplate;

        leankor__TaskTemplate__c taskTemplate = new leankor__TaskTemplate__c();
        taskTemplate.Name = 'Task Temp';
        taskTemplate.leankor__Priority__c = 'Normal';
        taskTemplate.OwnerId = UserInfo.getUserId();
        taskTemplate.leankor__Status__c = 'Completed';
        taskTemplate.leankor__ActivityDate__c = system.today();
        taskTemplate.leankor__Description__c = 'Description';
        taskTemplate.leankor__AutomationTemplate__c = autoTemplate.Id;
        taskTemplate.leankor__GUID__c = 'test-' + system.now().getTime();
        insert taskTemplate;

        leankor__Zone__c testzone = New leankor__Zone__c();
        testzone.Name = 'test-zone';
        testzone.leankor__Valuestream__c = valueStream.id;
        testzone.leankor__GUID__c = 'test-guid' + System.now().getTime();
        testzone.leankor__OpportunityStageName__c = 'None';
        testzone.leankor__Swimlane__c = swimLane.Id;
        testzone.leankor__CaseStatus__c = 'None';
        insert testzone;

        Opportunity oppt = new Opportunity();
        if(oppRtype != '') { 
            oppt.Name = 'New Opp'; 
            oppt.AccountID = testAcct.ID; 
            oppt.StageName = 'Customer Won'; 
            oppt.Amount = 3000; oppt.CloseDate = System.today() + 2;
            //oppt.RecordTypeId = oppRtype;
            insert oppt;
        } else {
            oppt.Name = 'New Opp'; oppt.AccountID = testAcct.ID; oppt.StageName = 'Customer Won'; oppt.Amount = 3000; oppt.CloseDate = System.today() + 2;
            insert oppt;
        }
        Opportunity oppt1 = new Opportunity();
        //oppt1.Name = 'New Opp'; oppt1.AccountID = testAcct.ID; oppt1.StageName = 'Customer Won'; oppt1.Amount = 3000; oppt1.CloseDate = System.today() + 2;oppt1.RecordTypeId = oppRtype;
        //insert oppt1;       
        leankor__KanbanCard__c kanban = New leankor__KanbanCard__c();
        kanban.Name = 'test';
        kanban.leankor__Valuestream__c = valueStream.id;
        kanban.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanban.leankor__GUID__c = '30-' + System.now().getTime();
        kanban.leankor__Zone__c = testzone.Id;
        kanban.leankor__Opportunity__c = oppt.Id;//
        insert kanban;

        List<Opportunity> opps = [Select Id, 
                                        Amount 
                                    From Opportunity 
                                    Where Id =: oppt.Id 
                                    Limit 49999];

        System.assert(opps.size() > 0);
        System.assert(opps[0].Amount == 3000); 

    }
}