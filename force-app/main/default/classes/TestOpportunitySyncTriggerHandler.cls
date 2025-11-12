/**
 * Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
 * FILE: TestOpportunitySyncTriggerHandler.cls
 * CLASS: TestOpportunitySyncTriggerHandler        
 */

@isTest
private class TestOpportunitySyncTriggerHandler {
	static testmethod void TestOpportunitySyncTriggerHandler() {
		OpportunitySyncTriggerHandler opportunitySyncTriggerHandler = new OpportunitySyncTriggerHandler(true,100);
		boolean isTriggerContext = opportunitySyncTriggerHandler.IsTriggerContext;
		boolean isVisualforcePageContext = opportunitySyncTriggerHandler.IsVisualforcePageContext;
		boolean isWebServiceContext = opportunitySyncTriggerHandler.IsWebServiceContext;
		boolean isExecuteAnonymousContext = opportunitySyncTriggerHandler.IsExecuteAnonymousContext;

        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__DisableKanbanCardTrigger__c = false;
        customSetting.leankor__FirstInstall__c = true;
        customSetting.leankor__DisableCaseTrigger__c = false;
        customSetting.leankor__DisableOpportunityTrigger__c = false; 
        customSetting.leankor__AvoidTaskDueDateCheck__c = true;
        try {
        insert customSetting;
        }
        Catch(Exception Ex) {
        system.debug('Error:'+Ex.getMessage());
        }
		// Create a test account
        Account testAcct = new Account ();
        testAcct.Name = 'My Test Account';
        insert testAcct;

        //Test Opportunity
            
        //ProjectBoardCarousel.ProjectRoom prjRoom=ProjectBoardCarousel.createProjectRoom('Test Room');
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
        insert testFolder;

        leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
        prjRoom.Name = 'Test Room';
        prjRoom.leankor__Portfolio__c = testFolder.Id;
        insert prjRoom;

        leankor__KanbanCardTemplate__c templatecard = New leankor__KanbanCardTemplate__c();
        templatecard.Name = 'default';//,leankor__Valuestream__C = vss.id 
        insert templatecard;

        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'myVS';
        valueStream.leankor__BoardType__c='Kanban Board';
        valueStream.leankor__ProjectRoom__c=prjRoom.Id;
        valueStream.leankor__SevenDayWorkWeek__c = false;
        valueStream.leankor__OpportunityRoleId__c=UserInfo.getUserRoleId();
        valueStream.leankor__OpportunityRecordType__c = 'All';
        valueStream.leankor__OpportunityLeadSource__c = 'All';
        valueStream.leankor__OpportunityCardCategory__c =templatecard.Id;
        valueStream.leankor__OpportunityType__c = 'All';
        valueStream.leankor__OpportunitySynchronization__c =true;
        insert valueStream;
            
        leankor__Zone__c testzone = New leankor__Zone__c();
        testzone.Name = 'test-zone';
        testzone.leankor__Valuestream__c =valueStream.id;
        testzone.leankor__GUID__c = 'test-guid'+System.now().getTime();
        testzone.leankor__OpportunityStageName__c='Customer Won';
        insert testzone;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name ='New Opp';
        opportunity.AccountID = testAcct.Id;
        opportunity.StageName = 'Customer Won';
        opportunity.Amount = 3000;
        opportunity.CloseDate = System.today();
        opportunity.type='New Customer';
        insert opportunity; 
        
        leankor__KanbanCard__c kanbanCard = New leankor__KanbanCard__c();
        kanbanCard.Name = 'test'; 
        kanbanCard.leankor__Valuestream__c = valueStream.id;
        kanbanCard.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanbanCard.leankor__StartDate__c = system.today()+4;
        kanbanCard.leankor__DueDate__c = system.today()+5;
        kanbanCard.leankor__GUID__c = '30-'+System.now().getTime();
        kanbanCard.leankor__Zone__c = testzone.Id;
        kanbanCard.leankor__Opportunity__c = opportunity.Id;
        insert kanbanCard;

        Opportunity Opportunity2 = [Select Id,
                                            Amount,
                                            StageName 
                                        From  Opportunity
                                        Where id=:opportunity.Id];
        Opportunity2.Amount=5000;
        Opportunity2.StageName='Customer Won';
        Update Opportunity2;

        Opportunity2.StageName='default';
        Update Opportunity2;

        List<Opportunity> opps = [Select Id, 
                                        StageName 
                                    From Opportunity 
                                    Where Id =: opportunity.Id 
                                    Limit 49999];

        System.assert(opps.size() > 0);
        System.assert(opps[0].StageName == 'default');

        delete opportunity;

        List<Opportunity> opps2 = [Select Id,
                                            StageName 
                                        From Opportunity 
                                        Where Id =: opportunity.Id 
                                        Limit 49999];
        System.assert(opps2.size() == 0);
	}
	static testmethod void TestOpportunitySyncTriggerHandler2() {
		OpportunitySyncTriggerHandler ost = new OpportunitySyncTriggerHandler(true,100);
    
        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__DisableKanbanCardTrigger__c = false;
        customSetting.leankor__FirstInstall__c = true ;
        customSetting.leankor__DisableCaseTrigger__c= false;
        customSetting.leankor__DisableOpportunityTrigger__c= false;
        customSetting.leankor__AvoidTaskDueDateCheck__c = true;
        try {
            insert customSetting;
        }
        Catch(Exception Ex) {
            system.debug('Error:'+Ex.getMessage());
        }
	    // Create a test account
        Account testAcct = new Account ();
        testAcct.Name = 'My Test Account';
        insert testAcct;
		 
        //VS
        //ProjectBoardCarousel.ProjectRoom prjRoom=ProjectBoardCarousel.createProjectRoom('Test Room');
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
        insert testFolder;
  
        leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
        prjRoom.Name = 'Test Room';
        prjRoom.leankor__Portfolio__c = testFolder.Id;
        insert prjRoom;

   		leankor__KanbanCardTemplate__c templatecard = New leankor__KanbanCardTemplate__c();
        templatecard.Name = 'default';//,leankor__Valuestream__C = vss.id 
        insert templatecard;
        
   		leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'myVS';
        valueStream.leankor__BoardType__c='Kanban Board';
        valueStream.leankor__ProjectRoom__c=prjRoom.Id;
        valueStream.leankor__SevenDayWorkWeek__c = false;
        valueStream.leankor__OpportunityRoleId__c=UserInfo.getUserRoleId();
        valueStream.leankor__OpportunityRecordType__c = 'All';
        valueStream.leankor__OpportunityLeadSource__c = 'All';
        valueStream.leankor__OpportunityCardCategory__c =templatecard.Id;
        valueStream.leankor__OpportunityType__c = 'All';
        valueStream.leankor__OpportunitySynchronization__c =true;
        insert valueStream;
        
        leankor__Zone__c testzone = New leankor__Zone__c();
        testzone.Name = 'test-zone';
        testzone.leankor__Valuestream__c =valueStream.id;
        testzone.leankor__GUID__c = 'test-guid'+System.now().getTime();
        testzone.leankor__OpportunityStageName__c='Default';
        insert testzone;
        
        //Test Opportunity
        Opportunity opportunity = new Opportunity();
        opportunity.Name ='New Opp';
        opportunity.AccountID = testAcct.Id;
        opportunity.StageName = 'Customer Won'; 
        opportunity.Amount = 3000;
        opportunity.CloseDate = System.today();
        insert opportunity;
        
        leankor__KanbanCard__c kanbanCard = New leankor__KanbanCard__c();
        kanbanCard.Name = 'test';
        kanbanCard.leankor__Valuestream__c = valueStream.id;
        kanbanCard.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanbanCard.leankor__StartDate__c = System.today()+4;
        kanbanCard.leankor__DueDate__c = System.today()+5;
        kanbanCard.leankor__GUID__c = '30-'+System.now().getTime();
        kanbanCard.leankor__Zone__c = testzone.Id;
        kanbanCard.leankor__Opportunity__c = opportunity.Id;
        insert kanbanCard;
		
        Opportunity opportunity2 = [Select Id,
                                    Amount
                                From  Opportunity 
                                Where id=:opportunity.Id];
        opportunity2.Amount=5000;
        Update opportunity2;

        List<Opportunity> opps = [Select Id,
                                          Amount 
                                        From Opportunity 
                                        Where Id =: opportunity.Id 
                                        Limit 49999];
        System.assert(opps.size() > 0);
        System.assert(opps[0].Amount == 5000);
	}

    static testmethod void TestOpportunitySyncTriggerHandler3(){
        OpportunitySyncTriggerHandler ost = new OpportunitySyncTriggerHandler(true,100);
    leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
    customSetting.leankor__DisableKanbanCardTrigger__c = false;
    customSetting.leankor__FirstInstall__c = true ;
    customSetting.leankor__DisableCaseTrigger__c= false;
    customSetting.leankor__DisableOpportunityTrigger__c= false;
    customSetting.leankor__AvoidTaskDueDateCheck__c = true;
    try {
        insert customSetting;
    }
    Catch(Exception Ex) {
        system.debug('Error:'+Ex.getMessage());
    }
    // Create a test account
    Account testAcct = new Account ();
    testAcct.Name = 'My Test Account';
    insert testAcct;

    //ProjectBoardCarousel.ProjectRoom prjRoom=ProjectBoardCarousel.createProjectRoom('Test Room');
    leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
    testFolder.Name = 'Test Room';
    insert testFolder;
    
    leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
    prjRoom.Name = 'Test Room';
    prjRoom.leankor__Portfolio__c = testFolder.Id;
    insert prjRoom;

    leankor__KanbanCardTemplate__c templatecard = New leankor__KanbanCardTemplate__c();
    templatecard.Name = 'default';//,leankor__Valuestream__C = vss.id 
    insert templatecard;

    leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
    valueStream.Name = 'myVS';
    valueStream.leankor__BoardType__c='Kanban Board';
    valueStream.leankor__ProjectRoom__c=prjRoom.Id;
    valueStream.leankor__SevenDayWorkWeek__c = false;
    valueStream.leankor__OpportunityRoleId__c = UserInfo.getUserRoleId();
    valueStream.leankor__OpportunityRecordType__c = 'All';
    valueStream.leankor__OpportunityLeadSource__c = 'All';
    valueStream.leankor__OpportunityCardCategory__c = templatecard.Id;
    valueStream.leankor__OpportunityType__c = 'All';
    valueStream.leankor__OpportunitySynchronization__c = true;
    insert valueStream;
            
    leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c ();
    masterContainer.leankor__Valuestream__C = valueStream.id;
    masterContainer.leankor__Type__c='Backlog';
    masterContainer.leankor__IsCardAvailable__c=true;
    masterContainer.Name = 'zone';
    masterContainer.leankor__GUID__c = 'test-1234-'+system.now();
    insert masterContainer;
    
    leankor__Swimlane__c swimLane = new leankor__Swimlane__c ();
    swimLane.leankor__MasterContainer__c =masterContainer.id;
    swimLane.leankor__Valuestream__C = valueStream.id;
    swimLane.Name =  'zone';
    swimLane.leankor__GUID__c = 'test-1234-'+system.now();
    insert swimLane;
    
    leankor__Zone__c testzone = New leankor__Zone__c();
    testzone.Name = 'test-zone';
    testzone.leankor__Valuestream__c =valueStream.id;
    testzone.leankor__GUID__c = 'test-guid'+System.now().getTime();
    testzone.leankor__OpportunityStageName__c='None';
    testzone.leankor__Swimlane__c =swimLane.Id;
    testzone.leankor__CaseStatus__c = 'None';
    insert testzone;
    
    //Test Opportunity
    Opportunity oppt = new Opportunity();
    oppt.Name ='New Opp';
    oppt.AccountID = testAcct.ID;
    oppt.StageName = 'Customer Won';
    oppt.Amount = 3000;
    oppt.CloseDate = System.today();
    insert oppt; 
    
    leankor__KanbanCard__c kanbanCard = New leankor__KanbanCard__c();
    kanbanCard.Name = 'test';
    kanbanCard.leankor__Valuestream__c = valueStream.id;
    kanbanCard.leankor__KanbanCardTemplate__c = templatecard.Id;
    kanbanCard.leankor__StartDate__c=system.today()+4;
    kanbanCard.leankor__DueDate__c=system.today()+5;
    kanbanCard.leankor__GUID__c = '30-'+System.now().getTime();
    kanbanCard.leankor__Zone__c=testzone.Id;
    kanbanCard.leankor__Opportunity__c=oppt.Id;
    insert kanbanCard;

    Opportunity opportunity6 = [Select Id,
                                Amount 
                            From  Opportunity 
                            Where id=:oppt.Id];
    opportunity6.Amount=5000;
    Update opportunity6;
        
    leankor__MasterContainer__c masterContainerNew = [Select Id,
                                                leankor__Type__c 
                                            From leankor__MasterContainer__c 
                                            Where id=:masterContainer.Id];	
    masterContainerNew.leankor__Type__c='Template';
    update masterContainerNew;	
        
    Opportunity oppt5 = new Opportunity();
    oppt5.Name ='New Opp1';
    oppt5.AccountID = testAcct.Id;
    oppt5.StageName = 'Customer Won'; 
    oppt5.Amount = 3000;
    oppt5.CloseDate = System.today();
    insert oppt5; 
        
    Opportunity opp2 = [Select Id,
                                Amount 
                            From  Opportunity 
                            Where id=:oppt.Id];
    opp2.Amount=5000;
    Update opp2;
    List<Opportunity> opps = [Select Id, 
                                    Amount 
                                From Opportunity 
                                Where Id =: oppt.Id 
                                Limit 49999];

    System.assert(opps.size() > 0);
    System.assert(opps[0].Amount == 5000);

    }
    static testmethod void TestOpportunitySyncTriggerHandler4(){
        OpportunitySyncTriggerHandler ost = new OpportunitySyncTriggerHandler(true,100);
        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
        customSetting.leankor__DisableKanbanCardTrigger__c = false;
        customSetting.leankor__FirstInstall__c = true ;
        customSetting.leankor__DisableCaseTrigger__c= false;
        customSetting.leankor__DisableOpportunityTrigger__c= false;
        customSetting.leankor__AvoidTaskDueDateCheck__c = true;
        try {
            insert customSetting;
        }
        Catch(Exception Ex) {
            System.debug('Error:'+Ex.getMessage());
        }
        // Create a test account
        Account testAcct = new Account ();
        testAcct.Name = 'My Test Account';
        insert testAcct;

		//Test Opportunity
		Opportunity oppt = new Opportunity();
        oppt.Name ='New Opp'; 
        oppt.AccountID = testAcct.Id;
        oppt.StageName = 'Customer Won'; 
        oppt.Amount = 3000;
        oppt.CloseDate = System.today();
   		insert oppt; 
   		//VS
   		//ProjectBoardCarousel.ProjectRoom prjRoom=ProjectBoardCarousel.createProjectRoom('Test Room');
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'Test Room';
        insert testFolder;
    
        leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c();
        prjRoom.Name = 'Test Room';
        prjRoom.leankor__Portfolio__c = testFolder.Id;
        insert prjRoom;
        
   		leankor__KanbanCardTemplate__c templatecard = New leankor__KanbanCardTemplate__c();
        templatecard.Name = 'default';//,leankor__Valuestream__C = vss.id 
        insert templatecard;

   		leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'myVS';
        valueStream.leankor__BoardType__c='Whiteboard';
        valueStream.leankor__ProjectRoom__c=prjRoom.Id;
        valueStream.leankor__SevenDayWorkWeek__c = false;
        valueStream.leankor__OpportunityRoleId__c=UserInfo.getUserRoleId();
        valueStream.leankor__OpportunityRecordType__c = 'All';
        valueStream.leankor__OpportunityLeadSource__c = 'All';
        valueStream.leankor__OpportunityCardCategory__c =templatecard.Id;
        valueStream.leankor__OpportunityType__c = 'All';
        valueStream.leankor__OpportunitySynchronization__c =true;
        insert valueStream;
        
        leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c ();
        masterContainer.leankor__Valuestream__C = valueStream.id;
        masterContainer.leankor__Type__c='Template';
        masterContainer.leankor__IsCardAvailable__c=true;
        masterContainer.Name = 'zone';
        masterContainer.leankor__GUID__c = 'test-1234-'+system.now();
        insert masterContainer;
        
        leankor__Swimlane__c swimLane = new leankor__Swimlane__c ();
        swimLane.leankor__MasterContainer__c = masterContainer.id ;
        swimLane.leankor__Valuestream__C = valueStream.id;
        swimLane.Name =  'zone';
        swimLane.leankor__GUID__c = 'test-1234-'+system.now();
        insert swimLane;
        
        leankor__Zone__c testzone = New leankor__Zone__c();
        testzone.Name = 'test-zone';
        testzone.leankor__Valuestream__c =valueStream.id;
        testzone.leankor__GUID__c = 'test-guid'+System.now().getTime();
        testzone.leankor__OpportunityStageName__c='None';
        testzone.leankor__Swimlane__c =swimLane.Id;
        insert testzone;
        
        leankor__KanbanCard__c kanbanCard = New leankor__KanbanCard__c();
        kanbanCard.Name = 'test';
        kanbanCard.leankor__Valuestream__c = valueStream.id;
        kanbanCard.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanbanCard.leankor__StartDate__c=system.today()+4;
        kanbanCard.leankor__DueDate__c=system.today()+5;
        kanbanCard.leankor__GUID__c = '30-'+System.now().getTime();
        kanbanCard.leankor__Zone__c=testzone.Id;
        kanbanCard.leankor__Opportunity__c=oppt.Id;
        insert kanbanCard;

        Opportunity oppt5 = new Opportunity();
        oppt5.Name ='New Opp1';
        oppt5.AccountID = testAcct.Id;
        oppt5.StageName = 'Customer Won'; 
        oppt5.Amount = 3000;
        oppt5.CloseDate = System.today();
        insert oppt5; 
        
        Opportunity opp2 = [Select Id,
                                    Amount 
                                From  Opportunity 
                                Where id=:oppt.Id];
        opp2.Amount=5000;
        Update opp2;

  		delete testzone;
  		
        leankor__KanbanCard__c kanban2 = New leankor__KanbanCard__c();
        kanban2.Name = 'test';
        kanban2.leankor__Valuestream__c = valueStream.id;
        kanban2.leankor__KanbanCardTemplate__c = templatecard.Id;
        kanban2.leankor__GUID__c = '31-'+System.now().getTime();
        insert kanban2;	
          
        Opportunity oppt6 = new Opportunity();
        oppt6.Name ='New Opp1';
        oppt6.AccountID = testAcct.Id; 
        oppt6.StageName = 'Customer Won';
        oppt6.Amount = 3000;
        oppt6.CloseDate = System.today();
        insert oppt6;
        
  		Opportunity opp7 = [Select Id, 
                                    Amount 
                                From Opportunity 
                                Where id=:oppt5.Id];
        opp2.Amount=5000;
        Update opp7;

        List<Opportunity> opps = [Select Id, 
                                        Amount 
                                    From Opportunity 
                                    Where Id =: oppt5.Id 
                                    Limit 49999];
        System.assert(opps.size() > 0);
        System.assert(opps[0].Amount == 3000); 
	}
}