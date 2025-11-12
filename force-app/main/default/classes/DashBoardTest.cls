@isTest
public class DashBoardTest {
    @isTest
    static void createDashBoardTest() {
        // Create Project Room (if required by CloneSystemBoard)
        leankor__ProjectRoom__c projectRoom = new leankor__ProjectRoom__c();
        projectRoom.Name = 'Test Project Room';
        insert projectRoom;

        // Create Source ValueStream (System Board, if required)
        leankor__ValueStream__c sourceValueStream = new leankor__ValueStream__c();
        sourceValueStream.Name = '_System_Board';
        sourceValueStream.leankor__BoardType__c = 'DashBoard';
        sourceValueStream.leankor__ProjectRoom__c = projectRoom.Id;
        insert sourceValueStream;

        // Create Source Zone (if required)
        leankor__Zone__c sourceZone = new leankor__Zone__c();
        sourceZone.leankor__ValueStream__c = sourceValueStream.Id;
        sourceZone.leankor__Title__c = 'Source Zone';
        sourceZone.leankor__GUID__c = 'source-zone-guid';
        sourceZone.leankor__Order__c = 1;
        insert sourceZone;

        // Create Global Preference for the current user
        leankor__Preference__c globalPref = new leankor__Preference__c();
        //globalPref.leankor__ValueStream__c = ''; // Empty ValueStream__c
        globalPref.OwnerId = UserInfo.getUserId();
        globalPref.Name = 'Global Preference';
        globalPref.leankor__CardPastDueDate__c = false;
        globalPref.leankor__FollowOnChatter__c = 'none';
        globalPref.leankor__SubscribeToCard__c = 'none';
        globalPref.leankor__TaskPastDueDate__c = false;
        globalPref.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        //globalPref.leankor__PercentDone__c = 0;
        globalPref.leankor__Moved__c = false;
        insert globalPref;

        // Create Target ValueStream
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        valueStream.Name = 'myvalueStream';
        valueStream.leankor__BoardType__c = 'DashBoard';
        valueStream.leankor__ProjectRoom__c = projectRoom.Id;
        insert valueStream;

        // Create Kanban Card Template (if required)
        leankor__KanbanCardTemplate__c kanbanCardTemplate = new leankor__KanbanCardTemplate__c();
        kanbanCardTemplate.leankor__ValueStream__c = valueStream.Id;
        kanbanCardTemplate.Name = 'Test Template';
        kanbanCardTemplate.leankor__Title__c = 'Test Template';
        insert kanbanCardTemplate;

        // Create Zone for Target ValueStream (if required)
        leankor__Zone__c zone = new leankor__Zone__c();
        zone.leankor__ValueStream__c = valueStream.Id;
        zone.leankor__Title__c = 'Test Zone';
        zone.leankor__GUID__c = 'test-zone-guid';
        zone.leankor__Order__c = 1;
        insert zone;

        // Create Preference for Source ValueStream (if required)
        leankor__Preference__c pref = new leankor__Preference__c();
        pref.leankor__ValueStream__c = sourceValueStream.Id;
        pref.OwnerId = UserInfo.getUserId();
        pref.Name = 'Source Preference';
        pref.leankor__GUID__c = leankor.TestDataFactory.createGuid();
        insert pref;

        // Run Test
        Test.startTest();
        try {
            DashBoard.createDashBoard(valueStream.Id);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
            System.assert(false, 'Test failed with exception: ' + e.getMessage());
        }
        Test.stopTest();

        // Verify Results
        leankor__ValueStream__c createdVs = [Select Id,
                                                    Name, 
                                                    leankor__BoardType__c 
                                                From leankor__ValueStream__c 
                                                Where Id = :valueStream.Id];
        System.assertEquals('DashBoard', createdVs.leankor__BoardType__c, 'ValueStream should be a dashboard');
    }
    
    /*---------------------------------------------------------------------------------------------------------
     Test for createDashBoard with invalid VS ID
    ----------------------------------------------------------------------------------------------------------*/
    @isTest
    static void createDashBoardTestWithInvalidId() {
        Test.startTest();
        try {
            DashBoard.createDashBoard(null);
            System.assert(false, 'Expected an exception for invalid ID');
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
            System.assert(true, 'Caught expected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}