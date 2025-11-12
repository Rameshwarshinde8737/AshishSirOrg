@isTest
private class IsRecordDeletedOfValueStreamTest {

    @isTest
    static void testBatchExecution() {
        // Create non-system boards with and without ProjectRoom
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = 'TestFolder';
		insert testFolder;

        leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c();
        testProject.Name = 'TestProject';
        testProject.leankor__Portfolio__c = testFolder.Id;
		insert testProject;

        List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();

        // Create user boards
        leankor__ValueStream__c userBoard1 = new leankor__ValueStream__c();
        userBoard1.Name = 'UserBoard1';
        userBoard1.leankor__ProjectRoom__c = null;
        
        leankor__ValueStream__c userBoard2 = new leankor__ValueStream__c();
        userBoard2.Name = 'UserBoard2';
        userBoard2.leankor__ProjectRoom__c = testProject.Id; // Assuming testProject is initialize
        
        // Create system boards (should be excluded from logic if needed later)
        leankor__ValueStream__c systemBoard1 = new leankor__ValueStream__c(Name = '_System_PlanBoard');
        leankor__ValueStream__c systemBoard2 = new leankor__ValueStream__c(Name = '_System_Board');
        leankor__ValueStream__c systemBoard3 = new leankor__ValueStream__c(Name = '_System_DashBoard');
        
        // Add all to the list
        valueStreams.add(userBoard1);
        valueStreams.add(userBoard2);
        valueStreams.add(systemBoard1);
        valueStreams.add(systemBoard2);
        valueStreams.add(systemBoard3);
        
        // Insert the records
        insert valueStreams;
        

        Test.startTest();
        IsRecordDeletedOfValueStream batch = new IsRecordDeletedOfValueStream();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Fetch updated boards
        List<leankor__ValueStream__c> updatedBoards = [ Select Name,
                                                                leankor__isRecordDeleted__c 
                                                            From leankor__ValueStream__c 
                                                            Where Name IN ('UserBoard1', 'UserBoard2')];
        // Assertions
        for (leankor__ValueStream__c board : updatedBoards) {
            if (board.Name == 'UserBoard1') {
                System.assertEquals(true, board.leankor__isRecordDeleted__c, 'UserBoard1 should be marked as deleted');
            } else if (board.Name == 'UserBoard2') {
                System.assertEquals(false, board.leankor__isRecordDeleted__c, 'UserBoard2 should not be marked as deleted');
            }
        }

        // System boards must not be modified
        List<leankor__ValueStream__c> systemBoards = [Select Name, 
                                                                leankor__isRecordDeleted__c 
                                                            From leankor__ValueStream__c 
                                                            Where Name Like '_System_%'];
        for (leankor__ValueStream__c sysBoard : systemBoards) {
            System.assertEquals(false, sysBoard.leankor__isRecordDeleted__c, sysBoard.Name + ' should remain unmodified');
        }
    }
}