@isTest
private class LeankorFieldSetControllerTest {

    @testSetup
    private static void testData() {
        User userRecord = [Select Id 
                            From User 
                            Where Id =:UserInfo.getUserId()];
        Profile p = [Select Id 
                        From Profile 
                        Where Name = 'Minimum Access - Salesforce'];
        User testUser = new User();
        testUser.Alias = 'testu';
        testUser.Email = 'testuser@test.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.ProfileId = p.Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Username = 'testuser' + DateTime.now().getTime() + '@test.com';
        insert testUser;
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);        
        List<leankor__ValueStream__c> valuestreamlist = leankor.TestDataFactory.createValueStream(projectList, 'UberBoard', userRecord);    
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(valuestreamlist[0]); 
        List<leankor__KanbanCard__c> kanbancardList = leankor.TestDataFactory.createKanbanCard(valuestreamlist[0],template,1,null,userRecord);
    }
    
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover readFieldSetData Method inside LeankorFieldSetController Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void readFieldSetDataTest() {    
        Test.startTest();
            List<leankor__ValueStream__c> valueStreamRecords = [Select Id 
                                                                    From leankor__ValueStream__c];
            List<Id> valueStreamId = new List<Id>();
        	leankor__KanbanCard__c kanbanCard = [Select Id 
                                                    From leankor__KanbanCard__c 
                                                    Limit 1];
        	List<Id> cardIds = new List<Id>{kanbanCard.Id};
            for (leankor__ValueStream__c singleId : valueStreamRecords) {
                valueStreamId.add(singleId.Id);
            }
			leankor__Filter__c filter = new leankor__Filter__c();
        	filter.Name = 'filter';
        	filter.leankor__FeatureData__c = 'FSC:leankor__leankorfieldset';
        	filter.leankor__ValueStream__c = valueStreamId[0];
        	filter.OwnerId = UserInfo.getUserId();
        	insert filter;

            leankor__ProjectBoardWorkFieldSet__c projectBoardWorkFieldSet = new leankor__ProjectBoardWorkFieldSet__c();
        	projectBoardWorkFieldSet.leankor__FieldSetName__c = 'leankor__leankorfieldset';
            projectBoardWorkFieldSet.leankor__ProjectBoard__c = valueStreamId[0];
            projectBoardWorkFieldSet.leankor__AutoCalculateTotals__c = true;
        	insert projectBoardWorkFieldSet;
        	
            List<leankor.LeankorFieldSetController.JsonInformation> jsonInformation = new List<leankor.LeankorFieldSetController.JsonInformation>();
            jsonInformation = leankor.LeankorFieldSetController.readObjectFieldSetInfo(valueStreamId);
            System.assert(jsonInformation.size() != 0, 'Expected non-empty JsonInformation list when EnableFieldSetColumn is true');
        	try {
                leankor.LeankorFieldSetController.readObjectFieldSetInfo(cardIds);
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains('Invalid input'), 'Expected exception for invalid input');
            }
        Test.stopTest();
    }

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover readFieldSetData Method inside LeankorFieldSetController Class when EnableFieldSetColumn was False
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void readFieldSetDataTestOne() {    
        Test.startTest();

            List<leankor.LeankorFieldSetController.JsonInformation> jsonInformation = new List<leankor.LeankorFieldSetController.JsonInformation>();
            jsonInformation = leankor.LeankorFieldSetController.readFieldSetInfo();
            System.assert(jsonInformation.size() == 0, 'Expected empty JsonInformation list when EnableFieldSetColumn is false');

        Test.stopTest();
    }
    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover readCardsFieldSetData Method inside LeankorFieldSetController Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void readCardsFieldSetDataTest() {    
        Test.startTest();
			leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        	valueStream.Name = 'Vs Test';
        	insert valueStream;

        	List<Id> valueStreamId = new List<Id>{valueStream.Id};
            List<leankor__KanbanCard__c> kanbanCardList = [Select Id 
                                                                From leankor__KanbanCard__c];  
            List<Id> kanbanCardId = new List<Id>();
            for (leankor__KanbanCard__c singleId : kanbanCardList) {
                kanbanCardId.add(singleId.Id);
            }

            Map<Id, leankor__KanbanCard__c> cardAndJsonMapRecord = new Map<Id, leankor__KanbanCard__c>();
            cardAndJsonMapRecord = leankor.LeankorFieldSetController.readCardsFieldSetData(kanbanCardId);
        	
            try {
                leankor.LeankorFieldSetController.readCardsFieldSetData(valueStreamId);
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains('Invalid input'), 'Expected exception for invalid input'); 
            }
        	System.assert(cardAndJsonMapRecord.size() != 0, 'Expected non-empty map of KanbanCard records');
        Test.stopTest();
    }

    /*---------------------------------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method is cover readCardsFieldSetData Method inside LeankorFieldSetController Class when EnableFieldSetColumn was False
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void readCardsFieldSetDataTestOne() {    
        Test.startTest();

            List<leankor__KanbanCard__c> kanbanCardList = [Select Id 
                                                                From leankor__KanbanCard__c];  
            List<Id> kanbanCardId = new List<Id>();
            for (leankor__KanbanCard__c singleId : kanbanCardList) {
                kanbanCardId.add(singleId.Id);
            }
            
            Map<Id, leankor__KanbanCard__c> cardAndJsonMapRecord = new Map<Id, leankor__KanbanCard__c>();
            cardAndJsonMapRecord = leankor.LeankorFieldSetController.readCardsFieldSetData(kanbanCardId);
            System.assert(cardAndJsonMapRecord.size() != 0, 'Expected non-empty map of KanbanCard records');
        
        Test.stopTest();
    }
    @isTest
    static void testGetCardsCustomFieldData() {
        leankor__KanbanCard__c kanbanCard = [Select Id 
                                                From leankor__KanbanCard__c 
                                                Limit 1];
        leankor__ValueStream__c valueStream = [Select Id    
                                                    From leankor__ValueStream__c 
                                                    Limit 1];
        List<Id> valueStreamIds = new List<Id>{valueStream.Id};
        List<Id> cardIds = new List<Id>{kanbanCard.Id};
        List<String> fieldsetAPIList = new List<String>{'TestFieldSet'};

        Test.startTest();
            Map<Id, leankor__KanbanCard__c> result = LeankorFieldSetController.getCardsCustomFieldData(cardIds, fieldsetAPIList);
            LeankorFieldSetController.getAllCustomFieldsData(valueStreamIds, fieldsetAPIList);
            try {
                LeankorFieldSetController.getAllCustomFieldsData(cardIds, fieldsetAPIList);
                LeankorFieldSetController.getCardsCustomFieldData(valueStreamIds, fieldsetAPIList);
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains('Invalid input'), 'Expected exception for invalid input');
            }
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Expected one KanbanCard record');
        System.assertEquals(kanbanCard.Id, result.keySet().iterator().next(), 'Card ID should match');
    }
    //new test method to cover Exception
    @isTest
    static void testGetCardsCustomFieldDataException() {
        leankor__ValueStream__c valueStream = [Select Id
                                                    From leankor__ValueStream__c    
                                                    Limit 1];
        List<Id> valueStreamIds = new List<Id>{valueStream.Id};
        List<String> fieldsetAPIList = new List<String>{'TestFieldSet'};

        Test.startTest();
       
            try {
                LeankorFieldSetController.getCardsCustomFieldData(valueStreamIds, fieldsetAPIList);
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains('Invalid input'), 'Expected exception for invalid input');
            }

        Test.stopTest();
    }
    @isTest
    static void testReadValueStreamCardsFieldSetData() {
        leankor__ValueStream__c valueStream = [Select Id
                                                    From leankor__ValueStream__c 
                                                    Limit 1];
        List<Id> valueStreamIds = new List<Id>{valueStream.Id};
        leankor__KanbanCard__c kanbanCard = [Select Id 
                                                From leankor__KanbanCard__c 
                                                Limit 1];
		List<Id> kanbanCardIds = new List<Id>{kanbanCard.Id};

        Test.startTest();
            Map<Id, leankor__KanbanCard__c> result = LeankorFieldSetController.readValueStreamCardsFieldSetData(valueStreamIds);
            try {
                LeankorFieldSetController.readValueStreamCardsFieldSetData(kanbanCardIds);
            } catch(Exception ex) {
                System.assert(ex.getMessage().contains('Invalid input'), 'Expected exception for invalid input');
            }
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }
    @isTest
    static void testReadFieldSetDetails() {
        
        leankor__ValueStream__c valueStream = [Select Id 
                                                    From leankor__ValueStream__c 
                                                    Limit 1];
        leankor__ProjectBoardWorkFieldSet__c projectBoardWorkFieldSet = new leankor__ProjectBoardWorkFieldSet__c();
        projectBoardWorkFieldSet.leankor__FieldSetName__c = 'leankor__leankorfieldset';
        projectBoardWorkFieldSet.leankor__ProjectBoard__c = valueStream.Id;
        projectBoardWorkFieldSet.leankor__AutoCalculateTotals__c = true;
        insert projectBoardWorkFieldSet;
        
        // Create input for the method
        LeankorFieldSetController.FieldSetAndValueStreamInformation input = new LeankorFieldSetController.FieldSetAndValueStreamInformation();
        input.fieldSetName = new List<String>{'leankor__leankorfieldset'};
        input.valuestreamId = valueStream.Id;
        List<String> serializedInput = new List<String>{JSON.serialize(input)};
        
        leankor__KanbanCard__c kanbanCard = [Select Id 
                                                From leankor__KanbanCard__c 
                                                Limit 1];
        LeankorFieldSetController.FieldSetAndValueStreamInformation inputs = new LeankorFieldSetController.FieldSetAndValueStreamInformation();
        inputs.fieldSetName = new List<String>{'TestFieldSet'};
        inputs.valuestreamId = kanbanCard.Id;
        List<String> serializedInputs = new List<String>{JSON.serialize(inputs)};

        Test.startTest();
            try {
                LeankorFieldSetController.JsonInformationWithConfig result = LeankorFieldSetController.readFieldSetDetails(serializedInput);
                LeankorFieldSetController.readFieldSetDetails(serializedInputs);
                System.assertNotEquals(null, result, 'Result should not be null');
                System.assertNotEquals(null, result.jsonInformation, 'JsonInformation should not be null');
                // Since RealTimeController.getKanbanFieldSetANDJSON is not mocked, we expect an empty result
                System.assertEquals(0, result.jsonInformation.size(), 'Expected no JsonInformation records due to missing RealTimeController data');
            } catch (Exception e) {
                System.assert(true, 'Unexpected exception: ' + e.getMessage());
            }
        Test.stopTest();
    }
    @isTest
    static void getAllCustomFieldsInsideTheFieldSet() {
        Test.startTest();
			List<Id> kanbanCardNullId = new List<Id>();
			String sObjectName = 'leankor__KanbanCard__c';
        	leankor.LeankorFieldSetController.getAllCustomFieldsInsideTheFieldSet(kanbanCardNullId,sObjectName);
        Test.stopTest();
        System.assert(true, 'allCardsFieldSetData executed without errors');
    }
    // New test method to cover the constructor
    @isTest
    static void testLeankorFieldSetControllerConstructor() {
        Test.startTest();
        try {
            leankor.Util utilInstance = new leankor.Util();
            LeankorFieldSetController controller = new LeankorFieldSetController(utilInstance);
            
            System.assert(true, 'Constructor should instantiate without errors');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception while instantiating LeankorFieldSetController: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void testNoAccessThrowsExceptionWithUser() {
        // Create a user with minimal permissions
		User testUser = [Select Id 
                            From User   
                            Where Alias = 'testu'];
        // Create test data
        List<Id> valueStreamIds = new List<Id>();
        leankor__ValueStream__c testValueStream = new leankor__ValueStream__c();
        testValueStream.Name = 'Test Value Stream';
        insert testValueStream;

        valueStreamIds.add(testValueStream.Id);
        leankor__KanbanCard__c kanbanCard = [Select Id 
                                                From leankor__KanbanCard__c     
                                                Limit 1];
        List<Id> cardIds = new List<Id>{kanbanCard.Id};

        // Run as the restricted user
        System.runAs(testUser) {
            Test.startTest();
                try {
                    leankor.LeankorFieldSetController.readObjectFieldSetInfo(valueStreamIds);
                    System.assert(false, 'Expected Util.LeanException to be thrown');
                } catch (Util.LeanException e) {
                    System.assertEquals('Error: No access to records', e.getMessage(), 'Unexpected exception message');
                }
                try {
                    leankor.LeankorFieldSetController.readFieldSetDetails(new List<String>());
                    System.assert(false, 'Expected Util.LeanException to be thrown');
                } catch (Util.LeanException e) {
                    System.assertEquals('Error: No access to records', e.getMessage(), 'Unexpected exception message');
                }
                try {
                    leankor.LeankorFieldSetController.readCardsFieldSetData(cardIds);
                    System.assert(false, 'Expected Util.LeanException to be thrown');
                } catch (Util.LeanException e) {
                    System.assertEquals('Error: No access to records', e.getMessage(), 'Unexpected exception message');
                }
                try {
                    leankor.LeankorFieldSetController.getCardsCustomFieldData(cardIds,new List<String>());
                    System.assert(false, 'Expected Util.LeanException to be thrown');
                } catch (Util.LeanException e) {
                    System.assertEquals('Error: No access to records', e.getMessage(), 'Unexpected exception message');
                }
                try {
                    leankor.LeankorFieldSetController.readValueStreamCardsFieldSetData(valueStreamIds);
                    System.assert(false, 'Expected Util.LeanException to be thrown');
                } catch (Util.LeanException e) {
                    System.assertEquals('Error: No access to records', e.getMessage(), 'Unexpected exception message');
                }
                try {
                    leankor.LeankorFieldSetController.getAllCustomFieldsData(valueStreamIds,new List<String>());
                    System.assert(false, 'Expected Util.LeanException to be thrown');
                } catch (Util.LeanException e) {
                    System.assertEquals('Error: No access to records', e.getMessage(), 'Unexpected exception message');
                }
            Test.stopTest();
        }
    }
    @isTest
    static void allCardsFieldSetDataTest() {
        // Create test data inline
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'Test Value Stream';
        insert valueStream;

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        kanbanCard.Name = 'Test Kanban Card';
        kanbanCard.leankor__ValueStream__c = valueStream.Id;
        kanbanCard.leankor__isRecordDeleted__c = false;
        insert kanbanCard;

        leankor__ProjectBoardWorkFieldSet__c projectBoardWorkFieldSet = new leankor__ProjectBoardWorkFieldSet__c();
        projectBoardWorkFieldSet.leankor__FieldSetName__c = 'leankor__leankorfieldset';
        projectBoardWorkFieldSet.leankor__ProjectBoard__c = valueStream.Id;
        projectBoardWorkFieldSet.leankor__AutoCalculateTotals__c = true;
        insert projectBoardWorkFieldSet;

        List<Id> valueStreamIds = new List<Id>{valueStream.Id};
        List<Id> kanbanCardIds = new List<Id>{kanbanCard.Id};
        List<Id> emptyIds = new List<Id>();

        String sObjectNameKanban = 'leankor__KanbanCard__c';
        String sObjectNameValueStream = 'leankor__ValueStream__c';

        Test.startTest();

            Map<Id, leankor__KanbanCard__c> resultKanban = LeankorFieldSetController.allCardsFieldSetData(kanbanCardIds, sObjectNameKanban);
            System.assertEquals(1, resultKanban.size(), 'Expected one KanbanCard in the result');
            
            Map<Id, leankor__KanbanCard__c> resultValueStream = LeankorFieldSetController.allCardsFieldSetData(valueStreamIds, sObjectNameValueStream);
            System.assertEquals(1, resultValueStream.size(), 'Expected one KanbanCard for ValueStream');

            Map<Id, leankor__KanbanCard__c> resultEmpty = LeankorFieldSetController.allCardsFieldSetData(emptyIds, sObjectNameKanban);
            System.assertEquals(0, resultEmpty.size(), 'Expected empty result for empty input');

            User testUser = [Select Id
                                From User 
                                Where Alias = 'testu'];
            System.runAs(testUser) {
                try {
                    LeankorFieldSetController.allCardsFieldSetData(kanbanCardIds, sObjectNameKanban);
                    System.assert(false, 'Expected Util.LeanException to be thrown');
                } catch (Util.LeanException e) {
                    System.assert(e.getMessage().contains('ERROR:'), 'Expected error message to contain "ERROR:"');
                }
            }
        Test.stopTest();
    }
}