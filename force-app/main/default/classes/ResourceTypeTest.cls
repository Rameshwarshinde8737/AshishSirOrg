/*
 Date :26/09/19
 To Cover ResourceType Class Methods.
*/
@isTest	
public with sharing class ResourceTypeTest {
   
    private static testMethod void readResourceTypeTest(){
    	
    	List< leankor__ResourceType__c>  resourceTypeList =new List< leankor__ResourceType__c>();
    	for(Integer i=0;i<5;i++){
    		leankor__ResourceType__c  resourceType =new  leankor__ResourceType__c();
    			resourceType.Name='IT'+i;
    			resourceType.leankor__InternalHourlyRate__c=50;
    			resourceType.leankor__ExternalHourlyRate__c=60;   		    			
    			resourceTypeList.add(resourceType);
    		
    	}    	
    	 insert resourceTypeList;
    	 //leankor.ResourceType.IS_MULTI_CURRENCY_ORGANIZATION=true;
    	 Set<Id> resourceTypeId =new Set<Id>();
    	 List<leankor__ResourceAssignment__c> resourceAssignmentList =new List<leankor__ResourceAssignment__c>();
    	 for(leankor__ResourceType__c resource:resourceTypeList){
    	 	leankor__ResourceAssignment__c resourceAssignment =new  leankor__ResourceAssignment__c();
    	  	resourceAssignment.leankor__ResourceType__c=resource.Id;
    	  	resourceAssignment.leankor__PercentCompleted__c=50;
    	  	resourceAssignment.leankor__PercentAllocation__c=60;
    	  	resourceAssignmentList.add(resourceAssignment);
    	 	resourceTypeId.add(resource.Id);
    	 
    	 }
    	insert  resourceAssignmentList;   
    	List<Id> resourceTypeIds=new List<Id>();
    	resourceTypeIds.addAll(resourceTypeId);	  
    	Test.startTest();
	    	 //To cover readResourceType method.
	    	 Map<Id, leankor__ResourceType__c> mapofResorceType=leankor.ResourceType.readResourceType(resourceTypeId);
	    	 //To cover setResourceAccounts method
	    	 System.assert(leankor.ResourceType.setResourceAccounts(resourceTypeIds[0],mapofResorceType,resourceAssignmentList[0])!=null);
	    	 System.assert(leankor.ResourceType.setResourceAccounts(null,mapofResorceType,resourceAssignmentList[0])!=null);
	    	 //To cover setResourceAccounts method if isMultiCurrency is True.
	    	 System.assert(leankor.ResourceType.setResourceAccounts(resourceTypeIds[0],mapofResorceType,resourceAssignmentList[0],true)!=null);
	    	 System.assert(leankor.ResourceType.setResourceAccounts(null,mapofResorceType,resourceAssignmentList[0],true)!=null);
    	Test.stopTest();
    	
    }
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @testSetup
    private static void testData(){
        
       List<leankor__Resource__c> listResourceRecord = new List<leankor__Resource__c>();
        for(Integer i=1;i<=5;i++){
            leankor__Resource__c resourceRecord = new leankor__Resource__c();
            resourceRecord.leankor__ExpenseAccount__c = 'Engineers';
            resourceRecord.leankor__ExpenseCategory__c = 'Labor';
            resourceRecord.leankor__ExpenseSubCategory__c = 'External Contractor';
            resourceRecord.leankor__ExternalHourlyRate__c = 0;
            resourceRecord.leankor__InternalHourlyRate__c = 0;
            resourceRecord.leankor__User__c=UserInfo.getUserId();
            listResourceRecord.add(resourceRecord);
        }
        insert  listResourceRecord;
        
        List< leankor__ResourceType__c>  listResourceTypeRecord = new List< leankor__ResourceType__c>();
        for(Integer i=0;i<5;i++){
            leankor__ResourceType__c  resourceTypeRecord = new leankor__ResourceType__c();
            resourceTypeRecord.Name = 'Demo Resource';
            resourceTypeRecord.leankor__ExpenseAccount__c = 'Engineers';
            resourceTypeRecord.leankor__ExpenseCategory__c = 'Labor';
            resourceTypeRecord.leankor__ExpenseSubCategory__c = 'External Contractor';
            resourceTypeRecord.leankor__InternalHourlyRate__c = 0;
            resourceTypeRecord.leankor__ExternalHourlyRate__c = 0;
            listResourceTypeRecord.add(resourceTypeRecord);
        }    
        insert listResourceTypeRecord;
        
        
        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name ='Demo Project';
        insert projectRecord;
        
        leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
        valueStreamRecord.Name = 'ps create';
        valueStreamRecord.leankor__ProjectRoom__c = projectRecord.id;
        valueStreamRecord.leankor__BoardType__c = 'Kanban Board';
        valueStreamRecord.leankor__SevenDayWorkWeek__c = true;
        valueStreamRecord.leankor__IsTemplateBoard__c = false;
        insert valueStreamRecord;

        
        leankor__MasterContainer__c  masterContainerRecord = new leankor__MasterContainer__c ();
        masterContainerRecord.Name = 'master c';
        masterContainerRecord.leankor__Type__c = 'Archive';
        masterContainerRecord.leankor__GUID__c = TestDataFactory.createGuid();
        insert masterContainerRecord;
        
        List<RecordType> recordTypeList = [Select Id,
                                                  Name,
                                                  SobjectType 
                                             From RecordType 
                                             Where Name='ActivityCard'];  
        
        
        List<leankor__KanbanCard__c> listKanbanCard = new List<leankor__KanbanCard__c>();
        for(Integer i=1;i<=5;i++){
            leankor__KanbanCard__c kanbanCardRecord = new leankor__KanbanCard__c();
            kanbanCardRecord.Name='kb'+i;
            kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
            kanbanCardRecord.leankor__ValueStream__c= valueStreamRecord.id;
            kanbanCardRecord.leankor__MasterContainer__c = masterContainerRecord.id;
            kanbanCardRecord.leankor__ValueStreamCardLink__c = null; 
            kanbanCardRecord.leankor__DueDateTime__c = system.now().addDays(1);
            kanbanCardRecord.leankor__DurationUnits__c = 'Days';
            kanbanCardRecord.leankor__EstimatedDuration__c = 1;
            kanbanCardRecord.leankor__isRecordDeleted__c = false;
            kanbanCardRecord.leankor__StartDate__c = System.Today();
            kanbanCardRecord.leankor__DueDate__c = System.Today().addDays(1);
            kanbanCardRecord.RecordTypeId=recordTypeList[0].id;
            listKanbanCard.add(kanbanCardRecord);
        }
        insert listKanbanCard;
        
        List<leankor__ScheduleMode__c> listSchedualMode = new List<leankor__ScheduleMode__c>();
        for(Integer i=1;i<=5;i++){
            leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c();
            scheduleMode.leankor__KanbanCard__c = listKanbanCard[0].id;
            scheduleMode.leankor__ManuallyScheduled__c = false;
            scheduleMode.leankor__Mode__c ='Normal';
            scheduleMode.leankor__EffortActual__c = 2;
            scheduleMode.leankor__EffortUnits__c = 'Days';
            listSchedualMode.add(scheduleMode);     
        }
        insert listSchedualMode;
        
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        for(Integer i=0;i<5;i++){
            leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
            resourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
            resourceAssignment.leankor__ResourceType__c = listResourceTypeRecord[0].id;
            resourceAssignment.leankor__KanbanCard__c = listKanbanCard[0].id;
            resourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
            resourceAssignment.leankor__ExpenseCategory__c = 'Labor';
            resourceAssignment.leankor__ExpenseSubCategory__c = 'External Contractor';
            resourceAssignment.leankor__PercentCompleted__c = 0;
            resourceAssignment.leankor__PercentAllocation__c = 100;
            resourceAssignmentList.add(resourceAssignment);  
        }
        insert resourceAssignmentList; 
    }
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readFilteredResourceTypes Method inside  ResourceType Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void readFilteredResourceTypesTest(){
        
        List<leankor__ResourceType__c> resourceTypeRecordList = [Select Id, 
                                                                        Name
                                                                    From leankor__ResourceType__c 
                                                                    Where leankor__ExpenseCategory__c = 'Labor'
                                                                    Limit 5];
        
        Set<Id> resourceTypeId = new Set<Id>();
        for(leankor__ResourceType__c resourceTypeRecordId:resourceTypeRecordList){
            resourceTypeId.add(resourceTypeRecordId.id);
        }

        Integer offsetSize = 1;
        String filterValue = 'Demo Resource';
        Integer limits = 5;

        Test.startTest();
        leankor.ResourceType.ResourceTypesLog records = new  leankor.ResourceType.ResourceTypesLog();
        Map<Id, leankor__ResourceType__c> mapofResorceType = leankor.ResourceType.readResourceType(resourceTypeId);
        records=leankor.ResourceType.ResourceTypesLog.readFilteredResourceTypes(offsetSize,filterValue,limits);
        System.assert(records.offsetSize == 1);
        System.assert(records.count == 5);
        String filterValueChange ='Resource Demo';
        records=leankor.ResourceType.ResourceTypesLog.readFilteredResourceTypes(offsetSize,'filterValueChange',limits);
        System.assertNotEquals(records.offsetSize == 1, records.offsetSize == null);
        Test.stopTest();
    } 
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readAllResourceTypes Method inside  ResourceType Class 
    ----------------------------------------------------------------------------------------------------------*/ 
    @istest    
    private static void readAllResourceTypesTest(){
        
        List<leankor__ResourceType__c> resourceTypeRecordList = [Select Id, 
                                                                        Name 
                                                                    From leankor__ResourceType__c 
                                                                    Where leankor__ExpenseCategory__c = 'Labor'
                                                                    Limit 5];
        
        
        leankor__ProjectRoom__c projectRoomRecord = [Select Id,
                                                            Name 
                                                       From leankor__ProjectRoom__c 
                                                       Where Name = 'Demo Project'
                                                       Limit 1]; 
       
        
        Set<Id> resourceTypeId = new Set<Id>();
        for(leankor__ResourceType__c resourceTypeRecordId:resourceTypeRecordList){
            resourceTypeId.add(resourceTypeRecordId.id);
        }
        
        ResourceType.ResourceTypesInputLog resourceTypesinputLogRecord  = new ResourceType.ResourceTypesInputLog();
        resourceTypesinputLogRecord.ProjectIds.add(projectRoomRecord.Id);
        resourceTypesinputLogRecord.UserIDs.add(UserInfo.getUserId()); 
        resourceTypesinputLogRecord.isprojectfilter = true;
        resourceTypesinputLogRecord.StartDate = String.valueOf(System.today());
        resourceTypesinputLogRecord.DueDate = String.valueOf(System.today()+1); 
        resourceTypesinputLogRecord.resourceTypeIds.add(resourceTypeRecordList[0].id);
        
        Test.startTest();
        leankor.ResourceType.ResourceTypesLog resourceTypesLog = new leankor.ResourceType.ResourceTypesLog();
        resourceTypesLog=leankor.ResourceType.ResourceTypesLog.readAllResourceTypes(resourceTypesinputLogRecord);
        System.assert(resourceTypesLog.resourceTypes.size()>0); 				
        Test.stopTest(); 
        
    }
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readAllResourceTypes Method inside  ResourceType Class
    ----------------------------------------------------------------------------------------------------------*/
    @istest    
    private static void readAllResourceTypesSecondTest(){
        
        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name = 'Demo Project';
        insert projectRecord;
        
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c();
        projectBoardOne.Name = 'PG';
        projectBoardOne.leankor__BoardType__c = 'UberBoard';   
        projectBoardOne.leankor__ProjectRoom__c = projectRecord.Id; 
        projectBoardOne.leankor__IsTemplateBoard__c = false;
        insert projectBoardOne;
        
        leankor__KanbanCard__c kanbanCardRecord  = new leankor__KanbanCard__c();
        kanbanCardRecord.Name = 'activity';
        kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.Id;
        kanbanCardRecord.leankor__StartDateTime__c =  System.now();
        insert kanbanCardRecord;
        
        
        leankor__ValueStream__c clonedProjectBoardOne = new leankor__ValueStream__c();         
        clonedProjectBoardOne.Name = 'RollUp';
        clonedProjectBoardOne.leankor__BoardType__c = 'Plan Board';   
        clonedProjectBoardOne.leankor__ProjectRoom__c = projectRecord.Id;                                                                           
        clonedProjectBoardOne.leankor__IsTemplateBoard__c = false;                                                                                                                            
        insert clonedProjectBoardOne;
        
        leankor__KanbanCard__c kanbanCardParent = new leankor__KanbanCard__c();
        kanbanCardParent.Name = 'parentKanban';
        kanbanCardParent.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanCardParent.leankor__ValueStream__c = clonedProjectBoardOne.Id; 
        insert kanbanCardParent;
        
        
        leankor__KanbanCard__c kanbanCardChild = new leankor__KanbanCard__c();  
        kanbanCardChild.Name = 'childKanban';
        kanbanCardChild.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanCardChild.leankor__ValueStream__c =  clonedProjectBoardOne.Id;  
        kanbanCardChild.leankor__ValueStreamCardLink__c = kanbanCardParent.Id;
        kanbanCardChild.leankor__ValueStreamLink__c = clonedProjectBoardOne.Id; 
        insert kanbanCardChild; 
        
        
        List<leankor__KanbanCard__c> listKanbanCardRecord = new List<leankor__KanbanCard__c>();
        
        for(Integer count=1;count<=2;count++){
            leankor__KanbanCard__c cloneKanbanChild = new leankor__KanbanCard__c();
            cloneKanbanChild.Name = 'ChildKanban'+count;  
            cloneKanbanChild.leankor__GUID__c = TestDataFactory.createGuid();
            cloneKanbanChild.leankor__ValueStream__c = clonedProjectBoardOne.Id ;
            cloneKanbanChild.leankor__ValueStreamCardLink__c =  kanbanCardRecord.Id; 
            cloneKanbanChild.leankor__ValueStreamLink__c = projectBoardOne.Id;   
            cloneKanbanChild.leankor__StartDateTime__c = System.now().addDays(count);
            cloneKanbanChild.leankor__IsRecordDeleted__c = false;
            listKanbanCardRecord.add(cloneKanbanChild);
        }
        insert listKanbanCardRecord; 
        
        leankor__MasterContainer__c masterContainerRecords = new leankor__MasterContainer__c();
        masterContainerRecords.leankor__ValueStream__c = projectBoardOne.id;
        masterContainerRecords.leankor__Type__c = 'Archive';  
        masterContainerRecords.OwnerId=UserInfo.getUserId();
        insert masterContainerRecords;
        
        
        Set<String> setKanbanIds = new Set<String>();
        for( leankor__KanbanCard__c dd : listKanbanCardRecord){
            setKanbanIds.add(string.valueOf(dd.id));
        }
        
        List< leankor__ResourceType__c>  listResourceTypeRecord = new List< leankor__ResourceType__c>();
        for(Integer i=0;i<5;i++){
            leankor__ResourceType__c  resourceTypeRecord = new leankor__ResourceType__c();
            resourceTypeRecord.Name = 'demo'+i;
            resourceTypeRecord.leankor__ExpenseAccount__c = 'Engineers';
            resourceTypeRecord.leankor__ExpenseCategory__c = 'Labor';
            resourceTypeRecord.leankor__ExpenseSubCategory__c = 'External Contractor';
            resourceTypeRecord.leankor__InternalHourlyRate__c = 0;
            resourceTypeRecord.leankor__ExternalHourlyRate__c = 0;
            listResourceTypeRecord.add(resourceTypeRecord);
        }    	
        insert listResourceTypeRecord;
        
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        for(Integer i=0;i<2;i++){
            leankor__ResourceAssignment__c resourceAssignment = new  leankor__ResourceAssignment__c();
            resourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
            resourceAssignment.leankor__ResourceType__c = listResourceTypeRecord[0].Id;
            resourceAssignment.leankor__KanbanCard__c = listKanbanCardRecord[1].Id;
            resourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
            resourceAssignment.leankor__ExpenseCategory__c = 'Labor';
            resourceAssignment.leankor__ExpenseSubCategory__c = 'External Contractor';
            resourceAssignment.leankor__PercentCompleted__c = 0;
            resourceAssignment.leankor__PercentAllocation__c = 100;
            resourceAssignmentList.add(resourceAssignment);  
        }
        insert resourceAssignmentList;   
        
        Set<Id> resourceTypeId = new Set<Id>();
        for(leankor__ResourceType__c resourceTypeRecordId:listResourceTypeRecord){
            resourceTypeId.add(resourceTypeRecordId.id);
        }
        
        ResourceType.ResourceTypesInputLog resourceTypesinputLogRecord  = new ResourceType.ResourceTypesInputLog();
        resourceTypesinputLogRecord.ProjectIds.add(projectRecord.Id);
        resourceTypesinputLogRecord.UserIDs.add(UserInfo.getUserId()); 
        resourceTypesinputLogRecord.isprojectfilter = true;
        resourceTypesinputLogRecord.StartDate = String.valueOf(System.today());
        resourceTypesinputLogRecord.DueDate = String.valueOf(System.today()+1); 
        resourceTypesinputLogRecord.resourceTypeIds.add(listResourceTypeRecord[0].Id);
        
        Test.startTest();
        leankor.ResourceType.ResourceTypesLog resourceTypesLog = new leankor.ResourceType.ResourceTypesLog();
        resourceTypesLog = leankor.ResourceType.ResourceTypesLog.readAllResourceTypes(resourceTypesinputLogRecord);
        System.assert(resourceTypesLog.resourceTypes.size()>0); 				
        Test.stopTest();     
    } 
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method ResourceTypeFirstTest is cover ResourceType constructor inside  ResourceType Class 
    ----------------------------------------------------------------------------------------------------------*/      
    @istest
    private static void resourceTypeFirstTest(){
        Boolean flag = true; 
        Test.startTest();
        leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
        ApexPages.StandardController sdcontrollerRecord = new ApexPages.StandardController(valueStreamRecord);
        Leankor.ResourceType resourceTypeRecordsdcontrollerRecord = new Leankor.ResourceType(sdcontrollerRecord);
        System.assertEquals(true, flag);
        Test.stopTest(); 
    }
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method ResourceTypeSecondTest is cover ResourceType constructor inside  ResourceType Class 
    ----------------------------------------------------------------------------------------------------------*/  
    @istest
    private static void resourceTypeSecondTest(){
        Boolean flag = true; 
        Test.startTest();
        List<leankor__ValueStream__c> valueStreamRecords = [Select Id,
                                                                   Name 
                                                               From leankor__ValueStream__c
                                                               Where leankor__IsTemplateBoard__c = false
                                                               Limit 5];   
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(valueStreamRecords);
        Leankor.ResourceType resourceTypeRecordstdSetController = new Leankor.ResourceType(stdSetController);
        System.assertEquals(true, flag);
        Test.stopTest();     
    }
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method ResourceTypeThirdTest is cover ResourceType [Default Constructor] inside  ResourceType Class 
    ----------------------------------------------------------------------------------------------------------*/  
    @istest
    private static void resourceTypeThirdTest(){
        ResourceType instanceResource = new ResourceType('TEST_INSTANCE');
        Boolean expected = false;
        Boolean actual = (instanceResource == null);
        System.assertEquals(expected, actual);      
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readAllResourceTypes Method inside  ResourceType Class
    ----------------------------------------------------------------------------------------------------------*/    
    
    @istest     
    private static void  readAllResourceTypesThirdTest(){
        
        Profile profileRecord  = [Select Id 
                                     From Profile 
                                     Where Name = 'Standard User'];
        
        User userRecord = new User(Alias = 'leankor1', Email='leankor1@leankor.com',
                           EmailEncodingKey='UTF-8', LastName='Leankor1', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = profileRecord.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='leankor1@leankor.com');
        
        insert userRecord;
        
        leankor__ProjectRoom__c projectRoomRecord = [Select Id,
                                                            Name 
                                                       From leankor__ProjectRoom__c 
                                                       Where Name = 'Demo Project'
                                                       Limit 1];
        
                       
       List<leankor__KanbanCard__c> listKanbanCard = [Select Id,
                                                             Name
                                                        From leankor__KanbanCard__c
                                                        Where leankor__ValueStreamCardLink__c = null
                                                        Limit 5];

     
        List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        for(Integer i=0;i<5;i++){
            leankor__ResourceAssignment__c resourceAssignment = new  leankor__ResourceAssignment__c();
            resourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
            resourceAssignment.leankor__ResourceType__c = null; 
            resourceAssignment.leankor__KanbanCard__c = listKanbanCard[0].id;
            resourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
            resourceAssignment.leankor__ExpenseCategory__c = 'Labor';
            resourceAssignment.leankor__ExpenseSubCategory__c = 'External Contractor';
            resourceAssignment.leankor__PercentCompleted__c = 0;
            resourceAssignment.leankor__PercentAllocation__c = 100;
            resourceAssignmentList.add(resourceAssignment);  
        }
        insert resourceAssignmentList;         
        
    
        ResourceType.ResourceTypesInputLog resourceTypesinputLogRecord  = new ResourceType.ResourceTypesInputLog();
        resourceTypesinputLogRecord.ProjectIds.add(projectRoomRecord.Id);
        resourceTypesinputLogRecord.UserIDs.add(UserInfo.getUserId()); 
        resourceTypesinputLogRecord.isprojectfilter = true;
        resourceTypesinputLogRecord.StartDate = string.valueOf(System.today());
        resourceTypesinputLogRecord.DueDate = string.valueOf(System.today()+1); 
        resourceTypesinputLogRecord.resourceTypeIds.add(null); 
        
        
        Test.startTest();
        leankor.ResourceType.ResourceTypesLog resourceTypesLog = new leankor.ResourceType.ResourceTypesLog();
        resourceTypesLog=leankor.ResourceType.ResourceTypesLog.readAllResourceTypes(resourceTypesinputLogRecord);
        System.assert(resourceTypesLog.resourceTypes.size()>0); 				
        Test.stopTest();
    } 
    
   /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readAllResourceTypes Method inside  ResourceType Class
    ----------------------------------------------------------------------------------------------------------*/       
    @istest     
    private static void  readAllResourceTypesFourthTest(){
        
        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name = 'Demo Project Name';
        insert projectRecord;

        
        leankor__ValueStream__c projectBoardOne = new leankor__ValueStream__c();
        projectBoardOne.Name = 'PG';
        projectBoardOne.leankor__BoardType__c = 'UberBoard';   
        projectBoardOne.leankor__ProjectRoom__c = projectRecord.Id; 
        projectBoardOne.leankor__IsTemplateBoard__c = false;
        insert projectBoardOne;
        
        leankor__KanbanCard__c kanbanCardRecord  = new leankor__KanbanCard__c();
        kanbanCardRecord.Name = 'activity';
        kanbanCardRecord.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.Id;
        kanbanCardRecord.leankor__StartDateTime__c = System.now();
        insert kanbanCardRecord;
        
        
        leankor__ValueStream__c clonedProjectBoardtwo = new leankor__ValueStream__c();         
        clonedProjectBoardtwo.Name = 'RollUp';
        clonedProjectBoardtwo.leankor__BoardType__c = 'UberBoard';   
        clonedProjectBoardtwo.leankor__ProjectRoom__c = projectRecord.Id;                                                                           
        clonedProjectBoardtwo.leankor__IsTemplateBoard__c = false;                                                                                                                            
        insert clonedProjectBoardtwo;


        List<RecordType> recordTypeList = [Select Id,
                                                  Name,
                                                  SobjectType 
                                             From RecordType 
                                             Where Name='ActivityCard'];  
        
        
       
        leankor__KanbanCard__c kanbanCardRecordOne = new leankor__KanbanCard__c();
        kanbanCardRecordOne.Name = 'kb';
        kanbanCardRecordOne.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanCardRecordOne.leankor__ValueStream__c = clonedProjectBoardtwo.Id;
        kanbanCardRecordOne.leankor__ValueStreamCardLink__c = kanbanCardRecord.Id;
        kanbanCardRecordOne.leankor__ValueStreamLink__c = projectBoardOne.Id; 
        kanbanCardRecordOne.leankor__DueDateTime__c = system.now().addDays(1);
        kanbanCardRecordOne.leankor__DurationUnits__c = 'Days';
        kanbanCardRecordOne.leankor__EstimatedDuration__c = 1;
        kanbanCardRecordOne.leankor__isRecordDeleted__c = false;
        kanbanCardRecordOne.leankor__StartDate__c = System.Today();
        kanbanCardRecordOne.leankor__DueDate__c = System.Today().addDays(1);
        kanbanCardRecordOne.RecordTypeId=recordTypeList[0].id;
        insert kanbanCardRecordOne;

        leankor__KanbanCard__c kanbanCardRecords = new leankor__KanbanCard__c();
        kanbanCardRecords.Name = 'parentKanban';
        kanbanCardRecords.leankor__GUID__c = TestDataFactory.createGuid();
        kanbanCardRecords.leankor__ValueStreamCardLink__c = kanbanCardRecordOne.Id;
        kanbanCardRecords.leankor__ValueStreamLink__c = projectBoardOne.Id;
        kanbanCardRecord.leankor__ValueStream__c = projectBoardOne.Id;
        insert kanbanCardRecords;


        List<leankor__ResourceType__c> resourceTypeRecordList = [Select Id, 
                                                                        Name
                                                                    From leankor__ResourceType__c 
                                                                    Where leankor__ExpenseCategory__c = 'Labor'
                                                                    Limit 5];
                                                        
        
       List<leankor__ResourceAssignment__c> resourceAssignmentList = new List<leankor__ResourceAssignment__c>();
        for(Integer i=0;i<5;i++){
            leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
            resourceAssignment.leankor__AssignedTo__c = UserInfo.getUserId();
            resourceAssignment.leankor__ResourceType__c = resourceTypeRecordList[0].Id;
            resourceAssignment.leankor__KanbanCard__c = kanbanCardRecordOne.id;
            resourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
            resourceAssignment.leankor__ExpenseCategory__c = 'Labor';
            resourceAssignment.leankor__ExpenseSubCategory__c = 'External Contractor';
            resourceAssignment.leankor__PercentCompleted__c = 0;
            resourceAssignment.leankor__PercentAllocation__c = 100;
            resourceAssignmentList.add(resourceAssignment);  
        }
        insert resourceAssignmentList;
        
        
        Set<Id> resourceTypeId = new Set<Id>();
        for(leankor__ResourceType__c resourceTypeRecordId:resourceTypeRecordList){
            resourceTypeId.add(resourceTypeRecordId.Id);
        }
        
        ResourceType.ResourceTypesInputLog resourceTypesinputLogRecord  = new ResourceType.ResourceTypesInputLog();
        resourceTypesinputLogRecord.ProjectIds.add(projectRecord.Id);
        resourceTypesinputLogRecord.UserIDs.add(UserInfo.getUserId()); 
        resourceTypesinputLogRecord.isprojectfilter = true;
        resourceTypesinputLogRecord.StartDate = string.valueOf(system.today());
        resourceTypesinputLogRecord.DueDate =  string.valueOf(system.today()+1); 
        resourceTypesinputLogRecord.resourceTypeIds.add(resourceTypeRecordList[0].Id);
        
        Test.startTest();
        leankor.ResourceType.ResourceTypesLog resourceTypesLog = new leankor.ResourceType.ResourceTypesLog();
        resourceTypesLog = leankor.ResourceType.ResourceTypesLog.readAllResourceTypes(resourceTypesinputLogRecord);
        System.assert(resourceTypesLog.resourceTypes.size()>0); 				
        Test.stopTest(); 
    }

    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readAllResourceTypes Method inside  ResourceType Class
    ----------------------------------------------------------------------------------------------------------*/       
    @istest    
    private static void readAllResourceTypesFifthTest(){
        
         leankor__ResourceType__c  resourceTypeRecord = new leankor__ResourceType__c();
         resourceTypeRecord.Name = 'Dummy Resource';
         resourceTypeRecord.leankor__ExpenseAccount__c = null; 
         resourceTypeRecord.leankor__ExpenseCategory__c = null; 
         resourceTypeRecord.leankor__ExpenseSubCategory__c = null; 
         resourceTypeRecord.leankor__InternalHourlyRate__c = 0;
         resourceTypeRecord.leankor__ExternalHourlyRate__c = 0;
         insert resourceTypeRecord;
        
        
        leankor__ProjectRoom__c projectRoomRecord = [Select Id,
                                                            Name 
                                                       From leankor__ProjectRoom__c 
                                                       Where Name = 'Demo Project'
                                                       Limit 1];
                                                    
    
        ResourceType.ResourceTypesInputLog resourceTypesinputLogRecord  = new ResourceType.ResourceTypesInputLog();
        resourceTypesinputLogRecord.ProjectIds.add(projectRoomRecord.Id);
        resourceTypesinputLogRecord.UserIDs.add(UserInfo.getUserId()); 
        resourceTypesinputLogRecord.isprojectfilter = true;
        resourceTypesinputLogRecord.StartDate = string.valueOf(system.today());
        resourceTypesinputLogRecord.DueDate = string.valueOf(system.today()+1); 
        resourceTypesinputLogRecord.resourceTypeIds.add(resourceTypeRecord.id);
        
        Test.startTest();
        leankor.ResourceType.ResourceTypesLog resourceTypesLog = new leankor.ResourceType.ResourceTypesLog();
        resourceTypesLog=leankor.ResourceType.ResourceTypesLog.readAllResourceTypes(resourceTypesinputLogRecord);
        System.assert(resourceTypesLog.resourceTypes.size()>0); 				
        Test.stopTest(); 
    }
}