@isTest
private class ProjectBoardWorkFieldSetTest { 
     @IsTest
     static void testReadProjectBoardWorkFieldSetRecords() {
        Test.startTest();
        List<leankor__ProjectBoardWorkFieldSet__c> result = ProjectBoardWorkFieldSet.readProjectBoardWorkFieldSetRecords('testValueStram');
        Test.stopTest();
        System.assertEquals(0, result.size(), 'There should be one record for testValueStram');

    }
    
    @isTest
    static void testCreateProjectBoardWorkFieldSets() {
        // Create test data
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c(Name = 'Test Value Stream');
        insert valueStream;

        List<String> valueStreamIds = new List<String> ();
        valueStreamIds.add(valueStream.Id);
            
        // Create some ProjectBoardWorkFieldSet records for testing
        List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSets = new List<leankor__ProjectBoardWorkFieldSet__c>();
        leankor__ProjectBoardWorkFieldSet__c pbWorkFieldSet1 = new leankor__ProjectBoardWorkFieldSet__c();

        
        pbWorkFieldSet1.leankor__ProjectBoard__c = valueStream.Id;
        pbWorkFieldSet1.leankor__FieldSetName__c = 'leankor__leankorfieldset0';
        projectBoardWorkFieldSets.add(pbWorkFieldSet1);
        
        leankor__ProjectBoardWorkFieldSet__c pbWorkFieldSet2 = new leankor__ProjectBoardWorkFieldSet__c();
        pbWorkFieldSet2.leankor__ProjectBoard__c = valueStream.Id;
        pbWorkFieldSet2.leankor__FieldSetName__c = 'leankor__leankorfieldset1';
        projectBoardWorkFieldSets.add(pbWorkFieldSet2);

       
        List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSetList = new List<leankor__ProjectBoardWorkFieldSet__c>();
        leankor__ProjectBoardWorkFieldSet__c pbWorkFieldSet = new leankor__ProjectBoardWorkFieldSet__c();
        pbWorkFieldSet.leankor__ProjectBoard__c = valueStream.Id;
        pbWorkFieldSet.leankor__FieldSetName__c = 'leankor__leankorfieldset';
        projectBoardWorkFieldSetList.add(pbWorkFieldSet);
            
        List<leankor__Filter__c> filterList = new  List<leankor__Filter__c>();
        leankor__Filter__c testFilter = new leankor__Filter__c();
        testFilter.leankor__ValueStream__c = valueStream.Id;
        testFilter.leankor__User__c = UserInfo.getUserId();
        testFilter.leankor__FeatureData__c = '["FSC:leankor__leankorfieldset"]';
        insert testFilter;
           
        Test.startTest();
        // Invoke the method to test
        List<leankor__ProjectBoardWorkFieldSet__c> result1 = ProjectBoardWorkFieldSet.createProjectBoardWorkFieldSets(projectBoardWorkFieldSets, valueStreamIds);
        List<leankor__ProjectBoardWorkFieldSet__c> result2 = ProjectBoardWorkFieldSet.createProjectBoardWorkFieldSets(projectBoardWorkFieldSetList, valueStreamIds);
        Test.stopTest();

        // Assertions to validate the expected outcome
       System.assertNotEquals(0, result1.size(), 'Result list should not be empty');
  
    }
    
    @isTest
    static void testGetCustomFieldSet() {
        Test.startTest();
        // Invoke the method
        List<GetObjectFieldsetAction.FieldSetData> result = ProjectBoardWorkFieldSet.getCustomFieldSet();
        Test.stopTest();

        // Verify the result 
        System.assert(result.size() > 0,'size will');
    }
    
    @IsTest
    static void testGetCustomFieldSetDetails() {
        Test.startTest();
        ProjectBoardWorkFieldSet.FieldSetDetails result = ProjectBoardWorkFieldSet.getCustomFieldSetDetails('Test Value Stream');
        Test.stopTest();

        System.assertNotEquals(0, result.customFieldSet.size(), 'There should be some custom field sets');
    
   }

}