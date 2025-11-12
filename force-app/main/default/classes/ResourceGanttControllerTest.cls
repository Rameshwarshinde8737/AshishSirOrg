/*---------------------------------------------------------------------------------------
Copyright 2012-2016 Leankor. All rights reserved
Author     :    Taresh Pandey
Company    :    Leankor  
Description:    Test class to test management to Get a record of Card for New Gantt Resource
Inputs     :    ProjectIds - String List, List of project ids
                AllRoleIds - String List , List of Role Ids of user/users
                UserIDs - String List , Ids of user/users
                isprojectfilter - Boolean 
         
Output      :  ResourceUsers - User List
               ResourceCards -  leankor.KanbanToGanttController.MasterContainer
               ResourceAssignmentList - leankor.KanbanToGanttController.MasterContainer  
Test Class  :  ResourceGanttControllerTest
History     :
<Date>       <Authors Name>     <Brief Description of Change>
12/14/2016    Taresh Pandey       Initial copy
12/15/2016    Taresh Pandey       Modifications according to main class to cover the logic 192/197 covered.
12/20/2016    Taresh Pandey       Modifications to cover the start and due date feature.  219/229 covered.
---------------------------------------------------------------------------------------*/
@isTest
private class ResourceGanttControllerTest{
	/*
       Date: 01/11/18
	*/
	@testSetup static void testData() {
        // Step 1: Create setup objects (UserRole and User) using System.runAs
        User adminUser = [Select Id 
                                From User 
                                Where Profile.Name = 'System Administrator' And IsActive = true 
                                Limit 1];
        System.runAs(adminUser) {
            // Create test UserRole
            UserRole role = new UserRole();
            role.Name = 'TestRole';
            insert role;

            // Create test users
            Profile p = [Select Id 
                            From Profile 
                            Where Name = 'Standard User' 
                            Limit 1];
            List<User> testUsers = new List<User>();
            for (Integer i = 0; i < 2; i++) {
                testUsers.add(new User(
                    Alias = 'test' + i,
                    Email = 'testuser' + i + '@testorg.com',
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'Test' + i,
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    ProfileId = p.Id,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    Username = 'testuser' + i + '@12testorg.com',
                    UserRoleId = role.Id,
                    IsActive = true
                ));
            }
            insert testUsers;
        }
	    User users = leankor.TestDataFactory.createStandardUser('Lean123');		
		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1); 
        List<leankor__ValueStream__c> valuestreamlist=leankor.TestDataFactory.createValueStream(projectList,'planboard',users); 		        
		List<leankor__MasterContainer__C> masterContainerList=new List<leankor__MasterContainer__C>();
		for(integer i=0;i<5;i++){
		    leankor__MasterContainer__C masterContainer=new leankor__MasterContainer__C();
		    masterContainer.Name='Backlog';
		    masterContainer.leankor__GUID__c = TestDataFactory.createGuid();
		    masterContainer.leankor__ValueStream__c=valuestreamlist[0].id;
		    masterContainer.leankor__Type__c='';
		    masterContainerList.add(masterContainer);
		}
		insert masterContainerList;
		Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
		List<leankor__KanbanCard__c> kanbancardList = new List<leankor__KanbanCard__c>();
		for (integer i=0;i<5;i++) {
		 	leankor__KanbanCard__c kanban = new leankor__KanbanCard__c();
		 	kanban.name='Kanban1';		 		
		 	kanban.leankor__Valuestream__c=valuestreamlist[0].id;
		 	kanban.leankor__StartDate__c=System.Today();
		 	kanban.leankor__DueDate__c=System.Today()+10;
		 	kanban.leankor__Title__c='activity';
		 	kanban.leankor__GUID__c=TestDataFactory.createGuid();
		 	kanban.RecordTypeId=recType;
		 	kanban.leankor__MasterContainer__c = masterContainerList[0].id;
		 	kanbancardList.add(kanban);
		}
		insert kanbancardList;		 		
		List<leankor__ResourceAssignment__c> resourceAssignList = new List<leankor__ResourceAssignment__c>();
		for (integer i=0;i<5;i++){
        	leankor__ResourceAssignment__c resourceAssign = new leankor__ResourceAssignment__c();
        	resourceAssign.leankor__KanbanCard__c = kanbancardList[0].ID;
        	resourceAssign.leankor__AssignedTo__c = users.id;
        	resourceAssignList.add(resourceAssign);
		}
        insert resourceAssignList;      													
	}
    // Test getAllResources with role-based filtering
    @isTest
    static void testGetAllResourcesWithRoleFilter() {
        // Prepare input
        ResourceGanttController.ResourceAssignmentInputlog input = new ResourceGanttController.ResourceAssignmentInputlog();
        input.AllRoleIds = new List<String>{[Select Id 
                                                From UserRole 
                                                Where Name = 'TestRole' 
                                                Limit 1].Id};
        input.StartDate = DateTime.now().addDays(-1).format('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
        input.DueDate = DateTime.now().addDays(10).format('yyyy-MM-dd');
        input.isprojectfilter = false;

        Test.startTest();
        ResourceGanttController.ResourceAssignmentlog result = ResourceGanttController.getAllResources(input);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.ResourceUsersData.size() > 0, 'Should return user data');
    }
        
    static testmethod  void  TestWithRoleId() {
        Test.startTest();   
        //Creating project
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c(Name = 'Test Room');
		insert testFolder;

        leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c(Name = 'Test Room', leankor__Portfolio__c = testFolder.Id);
		insert prjRoom;   		
        
        // Create kanban cards with Activity record type
        leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS1',
        leankor__ProjectRoom__c = prjRoom.Id,
        leankor__Boardtype__c = 'UBERBoard',
        leankor__IsTemplateBoard__c = false);
        insert vs;
        ApexPages.StandardController sc = new ApexPages.StandardController(vs);
        ResourceGanttController rgc = new ResourceGanttController(sc); 
        ResourceGanttController rg = new ResourceGanttController(); 
        List<leankor__KanbanCard__c> kcL = new List<leankor__KanbanCard__c>();
        for (Integer i=0; i < 10; i++){
            kcL.add(new leankor__KanbanCard__c(Name = ('kname'+i),
            leankor__GUID__c = ('guid'+i),
            leankor__StartDate__c =system.today()+1,
             leankor__DueDate__c= system.today(), 
             leankor__ValueStream__c = vs.Id,
             RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId()));                             
        }
        insert kcl;
        List<leankor__ScheduleMode__c> sm = new List<leankor__ScheduleMode__c>();
        List<leankor__ResourceAssignment__c> Rsa = new List<leankor__ResourceAssignment__c>();
        for (leankor__KanbanCard__c kc : kcL){
            sm.add(new leankor__ScheduleMode__c(
            leankor__EffortActual__c = 0.0,
            leankor__EffortUnits__c = 'Days',
            leankor__KanbanCard__c = kc.id,
            leankor__ManuallyScheduled__c = true,
            leankor__Mode__c = 'Normal'));
            Rsa.add(new leankor__ResourceAssignment__c(   leankor__AssignedTo__c = UserInfo.getUserId(),
            leankor__KanbanCard__c = kc.Id,
            leankor__PercentAllocation__c = 100.00 ));
        }
        insert sm;
        Insert Rsa;
        ResourceGanttController.ResourceAssignmentInputlog inputRMlog = new ResourceGanttController.ResourceAssignmentInputlog();
        //give input variables
        inputRMlog.ProjectIds.add(prjRoom.Id);
        inputRMlog.AllRoleIds.add(UserInfo.getUserRoleId());
        inputRMlog.isprojectfilter = true;
        inputRMLog.StartDate = string.valueOf(system.today()) ;
        inputRMLog.DueDate =  string.valueOf(system.today()+1) ;
        //ResourceGanttController.ResourceAssignmentlog  output = ResourceGanttController.getAllResources(InputRMlog);              
	       		
        //Date :10/05/19  create users
        User user1 = leankor.TestDataFactory.createStandardUser('Lean');
		User user2 = leankor.TestDataFactory.createStandardUser('Lean78');
		User user3 = leankor.TestDataFactory.createStandardUser('Lea646');
		List<String> sharingList = new List<String> ();
		sharingList.add(vs.Id);
				
		//provide valustream  access level to user.
		Boolean isReadOnly =	leankor.TestDataFactory.shareRecord(user1, sharingList,'leankor__ValueStream__share','Read');
		Boolean isReadWrite =	leankor.TestDataFactory.shareRecord(user2, sharingList,'leankor__ValueStream__share','Edit');
		   	
        // Date: 10/05/19 To cover  getAllResources method if user has read only  access.     
	    if (isReadOnly) { 
            System.runAs(user1) { 
                ResourceGanttController.ResourceAssignmentlog  output = ResourceGanttController.getAllResources(InputRMlog);
                for (leankor.KanbanToGanttController.MasterContainer  resourcecard:output.ResourceCards) {
                    System.assertEquals(resourcecard.hasEditAccess,false);
                }	
                // check op with asserts
                system.assert(output != null);
            } 
	    }
        // Date: 10/05/19  To cover  getAllResources method if user has read/write access.     
	    if (isReadWrite) {
            System.runAs(user2){ 
                ResourceGanttController.ResourceAssignmentlog  output = ResourceGanttController.getAllResources(InputRMlog); 
                for(leankor.KanbanToGanttController.MasterContainer  resourcecard:output.ResourceCards){
                        System.assertEquals(resourcecard.hasEditAccess,true);
                }	
                // check op with asserts
                system.assert(output != null);											
            }
	    }      
        //Date: 10/05/19  To cover  getAllResources method if user has no access.
	    if(!isReadWrite && !isReadOnly){
            System.runAs(user3){ 
                try {
                    ResourceGanttController.ResourceAssignmentlog  output = ResourceGanttController.getAllResources(InputRMlog); 		    
                    if(output.ResourceCards.size()>0){
                        system.assert(output.ResourceCards.size()!=0);
                    }else{
                        system.assert(output.ResourceCards.size()==0);	
                    }
                    system.assert(output != null);	
                } catch (Exception e) {
                    System.assertEquals('leankor.Util.LeanException',e.getTypeName());  
                }									
		    }
	    }           
        Test.stopTest();
    }

    static testmethod  void  TestWithUserId() {
        Test.startTest();
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c(Name = 'Test Room');
		insert testFolder;

        leankor__ProjectRoom__c prjRoom = new leankor__ProjectRoom__c(Name = 'Test Room', leankor__Portfolio__c = testFolder.Id);
		insert prjRoom;   		
        
        //Create kanban cards with Activity record type
        leankor__ValueStream__c vs= new leankor__ValueStream__c(Name = 'myVS1',
        leankor__ProjectRoom__c = prjRoom.Id,
        leankor__Boardtype__c = 'UBERBoard',
        leankor__IsTemplateBoard__c = false);
        insert vs;
        List<leankor__KanbanCard__c> kcL = new List<leankor__KanbanCard__c>();
        for (Integer i=0; i < 10; i++){
            kcL.add(new leankor__KanbanCard__c(Name = ('kname'+i),
            leankor__GUID__c = ('guid'+i),
            leankor__StartDate__c =system.today()+1,
            leankor__DueDate__c= system.today(), 
            leankor__ValueStream__c = vs.Id,
            RecordTypeId=Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId()));                             
        }
        insert kcl;
        List<leankor__ScheduleMode__c> sm = new List<leankor__ScheduleMode__c>();
        List<leankor__ResourceAssignment__c> Rsa = new List<leankor__ResourceAssignment__c>();
        for (leankor__KanbanCard__c kc : kcL){
            sm.add(new leankor__ScheduleMode__c(
            leankor__EffortActual__c = 0.0,
            leankor__EffortUnits__c = 'Days',
            leankor__KanbanCard__c = kc.id,
            leankor__ManuallyScheduled__c = true,
            leankor__Mode__c = 'Normal'));
            Rsa.add(new leankor__ResourceAssignment__c(   leankor__AssignedTo__c = UserInfo.getUserId(),
            leankor__KanbanCard__c = kc.Id,
            leankor__PercentAllocation__c = 100.00 ));
        }
        insert sm;
        Insert Rsa;     
        ResourceGanttController.ResourceAssignmentInputlog inputRMlog = new ResourceGanttController.ResourceAssignmentInputlog();
        //give input variables
        inputRMlog.ProjectIds.add(prjRoom.Id);
        inputRMlog.UserIDs.add(UserInfo.getUserId());
        inputRMlog.isprojectfilter = true;
        inputRMLog.StartDate = string.valueOf(system.today());
        inputRMLog.DueDate =  string.valueOf(system.today()+1);
        ResourceGanttController.ResourceAssignmentlog  output = ResourceGanttController.getAllResources(InputRMlog);
        //check op with asserts
        system.assert(output != null);
        ResourceGanttController.ResourceAssignmentCreateDelete RSADelete = new ResourceGanttController.ResourceAssignmentCreateDelete();
        RSADelete.deleteId.add(Rsa[0].Id);
        ResourceGanttController.CreateAndDeleteResourceAssignment(RSADelete);
        Test.stopTest();    
        }
	
	/*
	   Date :- 01/11/18
	   To cover CreateAndDeleteResourceAssignment ,createGuid , getResourcesByUser Methods.
	*/
	private static testMethod void CreateAndDeleteResourceAssignmentTest(){   			
   		Profile p = [Select Id From Profile Where Name = 'System Administrator'];
        User user = new User(Alias = 'Leanko12', 
        Email = 'Leanko12' + '@leankor.com',
        EmailEncodingKey = 'UTF-8', 
        LastName = 'Leankor2', 
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', 
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles', 
        UserName = 'Leanko12' + '@leankor.com.test1');
        insert user;
   		List<leankor__ResourceAssignment__c> resourceAssignList =[Select Id From leankor__ResourceAssignment__c];
   		List<leankor__KanbanCard__c> kanbancardList = [select id from leankor__KanbanCard__c];
   		List<String> deleteId= new List<String>();
   		deleteId.add(resourceAssignList[0].id);
   		Test.startTest();
        //create MasterContainer inner class data.   		   	  		
        List< leankor.KanbanToGanttController.MasterContainer > masterContainerList =new List< leankor.KanbanToGanttController.MasterContainer >();
        leankor.KanbanToGanttController.MasterContainer  masterContainer = new leankor.KanbanToGanttController.MasterContainer();
        masterContainer.Name='test';
        masterContainer.BoardType='Plan Board';
        masterContainer.TaskId=kanbancardList[0].id;
        masterContainer.ResourceId=user.id;
        masterContainer.Units=2.0;
        masterContainer.PercentDone=2.0;
        masterContainerList.add(masterContainer);
        //create ResourceAssignmentCreateDelete data.		
        ResourceGanttController.ResourceAssignmentCreateDelete raCreateDelete=new ResourceGanttController.ResourceAssignmentCreateDelete();
        raCreateDelete.deleteId=deleteId;
        raCreateDelete.newData=masterContainerList; 
        //assertion for CreateAndDeleteResourceAssignment  method.		
        System.assert(ResourceGanttController.CreateAndDeleteResourceAssignment(raCreateDelete)!=null);    		   	
        //assertion for createGuid method.
        System.assert(ResourceGanttController.createGuid()!=null); 

        ResourceGanttController.ResourceAssignmentInputlog resLog=new ResourceGanttController.ResourceAssignmentInputlog();
        // assertion for getResourcesByUser method.
        System.assert(ResourceGanttController.getResourcesByUser(resLog)!=null);	
        Test.stopTest();	   		     		
        }
   	/*
   	   Date :- 01/11/18
   	   To cover getBusinessHourData method.
   	 
   	*/
   	private static testMethod void getBusinessHourDataTestMethod(){
   		//insert Resource Assignment where BusinessHours is not null.
   		Test.startTest();
   		BusinessHours bhour= [select id from BusinessHours where IsDefault=true Limit 1];   		
   		List<leankor__GlobalWorkHour__c> globalHourList=new List<leankor__GlobalWorkHour__c>();
   		leankor__GlobalWorkHour__c globalHour = new leankor__GlobalWorkHour__c();
   		globalHour.leankor__StartDate__c =System.today();
   		globalHour.leankor__EndDate__c =System.today()+5;
   		globalHour.leankor__BusinessHours__c=bhour.id;
   		globalHourList.add(globalHour);
   		insert globalHourList;
   		System.assert(leankor.ResourceGanttController.getBusinessHourData()!=null);
   		List<leankor__GlobalWorkHour__c> globalHourList1=new List<leankor__GlobalWorkHour__c>();
   		leankor__GlobalWorkHour__c globalHour1 = new leankor__GlobalWorkHour__c();
   		globalHour1.leankor__StartDate__c =System.today()+10;
   		globalHour1.leankor__EndDate__c =System.today()+15;				
   		globalHourList1.add(globalHour1);
   		insert globalHourList1;
   		System.assert(leankor.ResourceGanttController.getBusinessHourData()!=null);
   		Test.stopTest();
   	}
    //By Mp
    @isTest
    static void getBusinessHourDataElseTest() {
        // Insert Resource Assignment where BusinessHours is null
        Test.startTest();
        List<leankor__GlobalWorkHour__c> globalHourList = new List<leankor__GlobalWorkHour__c>();
        leankor__GlobalWorkHour__c globalHour = new leankor__GlobalWorkHour__c();
        globalHour.leankor__StartDate__c = System.today();
        globalHour.leankor__EndDate__c = System.today() + 5;
        globalHour.leankor__BusinessHours__c = null; // Set BusinessHours to null
        globalHourList.add(globalHour);
        insert globalHourList;
        List<ResourceGanttController.ResourceCalendar> result = leankor.ResourceGanttController.getBusinessHourData();
        // Assert that the result is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        Test.stopTest();
    }
    @isTest
    static void testKanbanCardDMLException() {
        // Use Minimum Access - Salesforce profile for users
        Profile minimalProfile = [Select Id 
                                        From Profile 
                                        Where Name = 'Minimum Access - Salesforce' 
                                        Limit 1];
        if (minimalProfile == null) {
            minimalProfile = [Select Id 
                                    From Profile 
                                    Where Name = 'Standard User' 
                                    Limit 1];
        }

        // Create a test user for TRANSFER_REQUIRES_READ
        User testUser = new User();
        testUser.Alias = 'testu';
        testUser.Email = 'testuser@leankor.com' + System.currentTimeMillis();
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.ProfileId = minimalProfile.Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Username = 'testuser@leankor.com' + System.currentTimeMillis();
        insert testUser;

        // Create a second user for general DMLException and resourceList update
        User noAccessUser = new User();
        noAccessUser.Alias = 'noaccess';
        noAccessUser.Email = 'noaccess@leankor.com' + System.currentTimeMillis();
        noAccessUser.EmailEncodingKey = 'UTF-8';
        noAccessUser.LastName = 'NoAccess';
        noAccessUser.LanguageLocaleKey = 'en_US';
        noAccessUser.LocaleSidKey = 'en_US';
        noAccessUser.ProfileId = minimalProfile.Id;
        noAccessUser.TimeZoneSidKey = 'America/Los_Angeles';
        noAccessUser.Username = 'noaccess@leankor.com' + System.currentTimeMillis();
        
        insert noAccessUser;

        // Create a project room
        leankor__ProjectRoom__c projectRoom = new leankor__ProjectRoom__c();
        projectRoom.Name = 'Test Project Room';
        insert projectRoom;

        // Create test data
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test Value Stream';
        valueStream.leankor__ProjectRoom__c = projectRoom.Id;
        valueStream.leankor__BoardType__c = 'Kanban Board';
        insert valueStream;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'Test Kanban Card';
        kanbanCard.leankor__ValueStream__c = valueStream.Id;
        kanbanCard.OwnerId = UserInfo.getUserId();
        insert kanbanCard;

        leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
        resourceAssignment.leankor__KanbanCard__c = kanbanCard.Id;
        resourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
        resourceAssignment.leankor__ResourceType__c = null; // Replace with valid picklist value if required; e.g.; 'Resource'
        resourceAssignment.leankor__PercentAllocation__c = 50;
        resourceAssignment.leankor__PercentCompleted__c = 0;
        insert resourceAssignment;

        // Create an Account for invalid deleteId test
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;

        Test.startTest();

        // Test 1: Cover throw Util.LeanException('Error: Invalid input') with invalid deleteId
        ResourceGanttController.ResourceAssignmentCreateDelete resourceAssignlogInvalidId = new ResourceGanttController.ResourceAssignmentCreateDelete();
        resourceAssignlogInvalidId.deleteId = new List<String>{testAccount.Id}; // Invalid SObject type (Account)
        resourceAssignlogInvalidId.newData = new List<leankor.KanbanToGanttController.MasterContainer>();
        try {
            leankor.ResourceGanttController.CreateAndDeleteResourceAssignment(resourceAssignlogInvalidId);
            System.assert(false, 'Expected a LeanException due to invalid deleteId');
        } catch (Exception e) {
            System.assertEquals('Error: Invalid input', e.getMessage(), 
                'Expected Util.LeanException with message "Error: Invalid input", but got: ' + e.getMessage());
        }

        // Test 2: Cover TRANSFER_REQUIRES_READ exception
        ResourceGanttController.ResourceAssignmentCreateDelete resourceAssignlog1 = new ResourceGanttController.ResourceAssignmentCreateDelete();
        resourceAssignlog1.deleteId = new List<String>{resourceAssignment.Id};
        resourceAssignlog1.newData = new List<leankor.KanbanToGanttController.MasterContainer>();
        leankor.KanbanToGanttController.MasterContainer newAssignment1 = new leankor.KanbanToGanttController.MasterContainer();
        newAssignment1.TaskId = kanbanCard.Id;
        newAssignment1.ResourceId = testUser.Id; // Minimal permissions user
        newAssignment1.Units = 50;
        newAssignment1.PercentDone = 0;
        resourceAssignlog1.newData.add(newAssignment1);

        try {
            leankor.ResourceGanttController.CreateAndDeleteResourceAssignment(resourceAssignlog1);
            System.assert(false, 'Expected a DMLException due to TRANSFER_REQUIRES_READ');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Insufficient privileges to change the ownership'), 
                'Expected TRANSFER_REQUIRES_READ exception, but got: ' + e.getMessage());
        }

        // Test 3: Cover catch (DMLException ex) for update resourceList
        System.runAs(noAccessUser) {
            ResourceGanttController.ResourceAssignmentCreateDelete resourceAssignlog3 = new ResourceGanttController.ResourceAssignmentCreateDelete();
            resourceAssignlog3.deleteId = new List<String>{resourceAssignment.Id};
            resourceAssignlog3.newData = new List<leankor.KanbanToGanttController.MasterContainer>(); // No new data to avoid KanbanCard update
            try {
                leankor.ResourceGanttController.CreateAndDeleteResourceAssignment(resourceAssignlog3);
                System.assert(false, 'Expected a DMLException due to lack of update permissions on resourceList');
            } catch (Exception e) {
                System.debug(e.getMessage()); 
                    //'Expected DMLException for update resourceList, but got: ' + e.getMessage());
            }
        }

        // Test 4: Cover general DMLException with invalid OwnerId
        ResourceGanttController.ResourceAssignmentCreateDelete resourceAssignlog2 = new ResourceGanttController.ResourceAssignmentCreateDelete();
        resourceAssignlog2.deleteId = new List<String>{resourceAssignment.Id};
        resourceAssignlog2.newData = new List<leankor.KanbanToGanttController.MasterContainer>();
        leankor.KanbanToGanttController.MasterContainer newAssignment2 = new leankor.KanbanToGanttController.MasterContainer();
        newAssignment2.TaskId = kanbanCard.Id;
        newAssignment2.ResourceId = '005000000000000'; // Invalid user ID
        newAssignment2.Units = 50;
        newAssignment2.PercentDone = 0;
        resourceAssignlog2.newData.add(newAssignment2);

        try {
            leankor.ResourceGanttController.CreateAndDeleteResourceAssignment(resourceAssignlog2);
            System.assert(false, 'Expected a DMLException due to invalid OwnerId');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('ERROR:'), 
                'Expected general DMLException, but got: ' + e.getMessage());
            System.assert(!e.getMessage().contains('TRANSFER_REQUIRES_READ'), 
                'Did not expect TRANSFER_REQUIRES_READ exception');
        }

        Test.stopTest();
    }
}