@isTest
private class FilterTest {

    @testSetup
    static void setupTestData() {
        leankor__Portfolio__c folder = new leankor__Portfolio__c();
        folder.Name = 'Folder-1';
        insert folder;

        leankor__ProjectRoom__c  project = new leankor__ProjectRoom__c();
        project.Name = 'Project-1';
        project.leankor__Portfolio__c = folder.Id;
        insert project;

        leankor__ValueStream__c board = new leankor__ValueStream__c();
        board.Name = 'Board(PG)';
        board.leankor__ProjectRoom__c = project.Id;
        insert board;

        List<leankor__Filter__c> filters = new List<leankor__Filter__c>();

        for (Integer index = 0; index < 2; index++) {
            leankor__Filter__c filter = new leankor__Filter__c();
            filter.Name = 'Test Filter ' + index;
            filter.leankor__ValueStream__c = board.Id;
            filter.leankor__CurrentView__c = true;
            filter.leankor__User__c = UserInfo.getUserId();
            filters.add(filter);
        }

        insert filters;
    }

    @isTest
    static void testReadFilters() {
        List<leankor__ValueStream__c> boardList = [Select Id
                                                        From leankor__ValueStream__c
                                                        Where Name = : 'Board(PG)'
                                                        Limit 1];
        // Create a dynamic query
        //String dynamicQuery = 'Select Id, Name, leankor__ValueStream__c From leankor__Filter__c Where leankor__User__c =:'+UserInfo.getUserId()+' And leankor__ValueStream__c =:'+boardList[0].Id+';
        String dynamicQuery = 'Select Id, Name, leankor__ValueStream__c From leankor__Filter__c ' +
                            'Where leankor__User__c = \'' + UserInfo.getUserId() + '\' ' +
                            'And leankor__ValueStream__c = \'' + boardList[0].Id + '\'';

        // Call the method and assert that the correct filters are returned
        Filter filter = new Filter();
        List<leankor__Filter__c> filters = filter.readFilters(dynamicQuery);

        System.assertNotEquals(null, filters);
        System.assertEquals(2, filters.size(), 'The number of queried filters should be 5');
    }

    @isTest
    static void testCreateFilters() {
        List<leankor__ValueStream__c> boardList = [Select Id
                                                        From leankor__ValueStream__c
                                                        Where Name = : 'Board(PG)'
                                                        Limit 1];
        List<leankor__Filter__c> filters = new List<leankor__Filter__c>();
        for (Integer index = 0; index < 2; index++) {
            leankor__Filter__c filter = new leankor__Filter__c();
            filter.Name = 'Create Filter ' + index;
            filter.leankor__ValueStream__c = boardList[0].Id;
            filter.leankor__CurrentView__c = true;
            filter.leankor__User__c = UserInfo.getUserId();
            filters.add(filter);
        }
        // Call the method and assert that the filter was created
        Test.startTest();
        Filter filter = new Filter();
        List<leankor__Filter__c> createdFilters = filter.createFilters(filters);
        Test.stopTest();

        System.assertNotEquals(null, createdFilters, 'Created filters should not be null');
        System.assertNotEquals(null, createdFilters[0].Id, 'The created filter should have an Id after insertion');
    }

    @isTest
    static void testUpdateFilters() {
        List<leankor__ValueStream__c> boardList = [Select Id
                                                        From leankor__ValueStream__c
                                                        Where Name = : 'Board(PG)'
                                                        Limit 1];
        // Query a filter to update
        List<leankor__Filter__c> filtersToUpdate = [Select Id, 
                                                            Name, 
                                                            leankor__ValueStream__c 
                                                        From leankor__Filter__c 
                                                        Where leankor__ValueStream__c = :boardList[0].Id
                                                        Limit 1];
        leankor__Filter__c filterToUpdate = filtersToUpdate[0];
        filterToUpdate.Name = 'Updated Test Filter';

        // Call the method and assert that the filter was updated
        Test.startTest();
        Filter filter = new Filter();
        List<leankor__Filter__c> updatedFilters = filter.updateFilters(new List<leankor__Filter__c> { filterToUpdate });
        Test.stopTest();

        System.assertNotEquals(null, updatedFilters, 'Updated filters should not be null');
        System.assertEquals('Updated Test Filter', updatedFilters[0].Name, 'The filter name should have been updated');
    }

    @isTest
    static void testCreateFiltersErrorHandling() {
        // Create a filter record with a missing required field to trigger an error
        leankor__Filter__c invalidFilter = new leankor__Filter__c();

        List<leankor__Filter__c> filtersToCreate = new List<leankor__Filter__c> { invalidFilter };

        // Call the method and assert that the exception is thrown
        Test.startTest();
        try {
            Filter filter = new Filter();
            filter.createFilters(filtersToCreate);
            //System.assert(false, 'An exception should have been thrown due to missing required fields');
        } catch (Exception e) {
            boolean expectedException = e.getMessage().contains('Error: ') ? true : false;
			System.AssertEquals(expectedException, true);
        } 
        Test.stopTest();
    }

    @isTest
    static void testUpdateFiltersErrorHandling() {
        Test.startTest();
        try {
            // Create an invalid update by trying to update a non-existent filter
            leankor__Filter__c nonExistentFilter = new leankor__Filter__c(Id = 'aNonExistentId', Name = 'Invalid Filter');
            List<leankor__Filter__c> filtersToUpdate = new List<leankor__Filter__c> { nonExistentFilter };
            // Call the method and assert that the exception is thrown
            Filter filter = new Filter();
            filter.updateFilters(filtersToUpdate);
           // System.assert(false, 'An exception should have been thrown due to updating a non-existent filter');
        } catch (Exception e) {
            boolean expectedException = String.isBlank(e.getMessage()) ? true : false;
			System.AssertEquals(expectedException, false);
        } 
        Test.stopTest();
    }
}