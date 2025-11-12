@isTest
private class LabelProviderTest {

    /**
     * Setup method to insert only allowed records (custom settings)
     */
    @testSetup
    static void setupTestData() {
        // Insert mock LeanConstants to enable custom label logic
        insert new leankor__LeanConstants__c(
            Name = 'Default',
            leankor__UseCustomLabels__c = true
        );
    }

    /**
     * Basic test for Aura method wrapper with custom consumer
     */
    @isTest
    static void testGetLabelsForConsumersLightning() {
        Test.startTest();
        Map<String, String> result = LabelProvider.getLabelsForConsumersLightning('TestComponent');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    /**
     * Covers getLabelsForConsumers and other branches
     */
    @isTest
    static void testGetLabelsForConsumers() {
        Set<String> categories = new Set<String>{'LeankorBase', 'LeankorCalendar', 'UnknownCategory'};

        Test.startTest();
        Map<String, String> result = LabelProvider.getLabelsForConsumers(categories);
        Test.stopTest();

        System.assert(result != null, 'Should return a result map');
    }

    /**
     * Simulate hardcoded label extraction and internal mapping logic
     */
    @isTest
    static void testGetHardcodedLabels() {
        Map<String, String> mockReturnMap = new Map<String, String>{
            'finishnolaterthan' => 'Finish No Later',
            'finishnoearlierthan' => 'Finish No Earlier',
            'mustfinishon' => 'Must Finish On',
            'muststarton' => 'Must Start On',
            'startnoearlierthan' => 'Start No Earlier',
            'startnolaterthan' => 'Start No Later',
            'aslateaspossible' => 'As Late As Possible',
            'assoonaspossible' => 'As Soon As Possible'
        };

        Test.startTest();
        LabelProvider.getHardCodedLabels(mockReturnMap);
        Test.stopTest();

        System.assert(mockReturnMap.containsKey('ConstraintDescription'), 'Should include serialized JSON');
    }

    /**
     * Covers SOQL sanitizer utility
     */
    @isTest
    static void testSanitizeForSOQL() {
        // Properly escaped Apex string to simulate dirty input
        String dirty = '\'_\\%test';
        String cleaned = LabelProvider.sanitizeForSOQL(dirty);

        System.assertNotEquals(dirty, cleaned, 'String should be sanitized');
        System.assertEquals('\\\'\\_\\\\\\%test', cleaned); // expected result after sanitizeForSOQL
    }


    @isTest
    static void testSanitizeForSOQL_BlankAndNullInputs() {
        // Case: null input
        String resultNull = LabelProvider.sanitizeForSOQL(null);
        System.assertEquals('', resultNull, 'Null input should return empty string');
    
        // Case: empty string input
        String resultEmpty = LabelProvider.sanitizeForSOQL('');
        System.assertEquals('', resultEmpty, 'Empty string should return empty string');
    
        // Case: whitespace input
        String resultWhitespace = LabelProvider.sanitizeForSOQL('   ');
        System.assertEquals('', resultWhitespace, 'Whitespace-only string should return empty string');
    }    


    @isTest
    static void testReadLabelProviders_EmptyInput() {
        // Simulate null case
        List<leankor__VisualLeanLabelProvider__mdt> result1 = LabelProvider.readLabelProviders(null);
        System.assertEquals(0, result1.size(), 'Expected empty list for null input');
    
        // Simulate empty Set
        Set<String> emptySet = new Set<String>();
        List<leankor__VisualLeanLabelProvider__mdt> result2 = LabelProvider.readLabelProviders(emptySet);
        System.assertEquals(0, result2.size(), 'Expected empty list for empty input');
    }


    @isTest
    static void testReadLabelProviders_OnlyBlankStrings() {
        // Input includes only blank, null, or empty strings
        Set<String> categories = new Set<String>{' ', '', null};
    
        List<leankor__VisualLeanLabelProvider__mdt> result = LabelProvider.readLabelProviders(categories);    
        System.assertEquals(0, result.size(), 'Expected early return for blank-only categories');
    }

 
    /**
     * Covers getLabelsForConsumersLightning with user context
     */
    @isTest
    static void testGetLabelsWithCustomUserContext() {
        User testUser = PermissionSetsTestDataFactory.getUser('Leankor_FName', 'Leankor_LName', 'Standard User', new List<String>{'Visual_Lean_User'});

        System.runAs(testUser) {
            Test.startTest();
            Map<String, String> result = LabelProvider.getLabelsForConsumersLightning('CustomComponent');
            Test.stopTest();

            System.assert(result != null, 'Expected result from runAs user');
        }
    }
}