/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ResourceTest {

    private static leankor__Resource__c createTestResourceRecord(Id userId) {
        leankor__Resource__c testResource = new leankor__Resource__c();
        testResource.leankor__User__c = userId;
        testResource.leankor__ExpenseCategory__c = 'Labor';
        testResource.leankor__ExpenseSubCategory__c = 'Internal Employee';
        testResource.leankor__ExpenseAccount__c = 'Engineers';
        testResource.leankor__ExternalHourlyRate__c = 1;
        testResource.leankor__InternalHourlyRate__c = 1;            
        insert testResource;
        return testResource;
    }

    private static leankor__Portfolio__c createTestFolderRecord(String nameInput) {
        leankor__Portfolio__c testFolder = new leankor__Portfolio__c();
        testFolder.Name = nameInput;
        insert testFolder;
        return testFolder;
    }

    private static leankor__ProjectRoom__c createTestProjectRecord(String nameInput, String folderId) {
        leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c();
        testProject.Name = nameInput;
        testProject.leankor__Portfolio__c = folderId;
        insert testProject;
        return testProject;
    }

    private static leankor__ValueStream__c createTestValueStreamRecord(String nameInput, String projectRoomId) {
        leankor__ValueStream__c testValueStream = new leankor__ValueStream__c();
        testValueStream.Name = nameInput;
        testValueStream.leankor__SevenDayWorkWeek__c = true;
        testValueStream.leankor__ProjectRoom__c = projectRoomId;
        insert testValueStream;
        return testValueStream;
    }

    private static leankor__KanbanCard__c createTestKanbanCardRecord(String nameInput, String valueStreamId) {
        leankor__KanbanCard__c testKanbanCard = new leankor__KanbanCard__c();
        testKanbanCard.Name = nameInput;
        testKanbanCard.leankor__DurationUnits__c = 'Days';
        testKanbanCard.leankor__EstimatedDuration__c = 1;
        testKanbanCard.leankor__StartDateTime__c = DateTime.newInstance(2011, 11, 18, 3, 3, 3); 
        testKanbanCard.leankor__DueDateTime__c = DateTime.newInstance(2011, 11, 19, 3, 3, 3);
        testKanbanCard.leankor__ValueStream__c = valueStreamId;
        testKanbanCard.leankor__isRecordDeleted__c = false;
        insert testKanbanCard;
        return testKanbanCard;
    }
    
    private static leankor__ResourceAssignment__c createTestResourceAssignmentRecord(String kanbanCardId) {
        leankor__ResourceAssignment__c testResourceAssignment = new leankor__ResourceAssignment__c();
        testResourceAssignment.leankor__KanbanCard__c = kanbanCardId;
        testResourceAssignment.leankor__PercentAllocation__c = 1;
        testResourceAssignment.leankor__ExpenseCategory__c = 'Labor';
        testResourceAssignment.leankor__ExpenseSubCategory__c = 'Internal Employee';
        testResourceAssignment.leankor__ExpenseAccount__c = 'Engineers';
        testResourceAssignment.leankor__ExternalHourlyRate__c = 1;
        testResourceAssignment.leankor__InternalHourlyRate__c = 1;
        insert testResourceAssignment;
        return testResourceAssignment;
    }
    
    // Tests if no records are obtained
    @isTest static void readResourceTest() {
        createTestResourceRecord(UserInfo.getUserId());
        
        Boolean expected = false;
        Boolean actual = Resource.readResource(new Set<Id>{UserInfo.getUserId()}).isEmpty();
        System.assertEquals(expected, actual);      
    }

    @isTest static void setResourceAccountsMultiCurrencyUserTest() {
        String folderId = createTestFolderRecord('Folder').Id;
        String projectRoomId = createTestProjectRecord('Project', folderId).id;
        String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
        String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
        
        createTestResourceRecord(UserInfo.getUserId());
        
        Boolean expected = false;                   
        
        leankor__ResourceAssignment__c resourceAccount = Resource.setResourceAccounts(UserInfo.getUserId(), Resource.readResource(new Set<Id>{UserInfo.getUserId()}), createTestResourceAssignmentRecord(kanbanCardId), UserInfo.isMultiCurrencyOrganization());        
        
        Boolean actual = (resourceAccount == null);
        System.assertEquals(expected, actual);
    }
    
    @isTest static void setResourceAccountsMultiCurrencyNoUserTest() {
        String folderId = createTestFolderRecord('Folder').Id;
        String projectRoomId = createTestProjectRecord('Project', folderId).id;
        String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
        String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
        
        Id userId;
        createTestResourceRecord(userId);
        
        Boolean expected = false;                   
        
        leankor__ResourceAssignment__c resourceAccount = Resource.setResourceAccounts(UserInfo.getUserId(), Resource.readResource(new Set<Id>{UserInfo.getUserId()}), createTestResourceAssignmentRecord(kanbanCardId), UserInfo.isMultiCurrencyOrganization());        
        
        Boolean actual = (resourceAccount == null);
        System.assertEquals(expected, actual);
    }
    
    @isTest static void setResourceAccountsSingleCurrencyUserTest() {
        String folderId = createTestFolderRecord('Folder').Id;
        String projectRoomId = createTestProjectRecord('Project', folderId).id;
        String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
        String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
        
        createTestResourceRecord(UserInfo.getUserId());
        
        Boolean expected = false;                   
        
        leankor__ResourceAssignment__c resourceAccount = Resource.setResourceAccounts(UserInfo.getUserId(), Resource.readResource(new Set<Id>{UserInfo.getUserId()}), createTestResourceAssignmentRecord(kanbanCardId));        
    
        Boolean actual = (resourceAccount == null);
        System.assertEquals(expected, actual);
    }
    
    @isTest static void setResourceAccountsSingleCurrencyNoUserTest() {
        String folderId = createTestFolderRecord('Folder').Id;
        String projectRoomId = createTestProjectRecord('Project', folderId).id;
        String valueStreamId = createTestValueStreamRecord('Valuestream', projectRoomId).Id;
        String kanbanCardId = createTestKanbanCardRecord('Kanban card', valueStreamId).Id;
        
        Id userId;
        createTestResourceRecord(userId);
        
        Boolean expected = false;                   
        
        leankor__ResourceAssignment__c resourceAccount = Resource.setResourceAccounts(UserInfo.getUserId(), Resource.readResource(new Set<Id>{UserInfo.getUserId()}), createTestResourceAssignmentRecord(kanbanCardId));        
    
        Boolean actual = (resourceAccount == null);
        System.assertEquals(expected, actual);
    }
    
    @isTest static void instanceResource() {
        Resource instanceResource = new Resource('TEST_INSTANCE');
        
        Boolean expected = false;
        Boolean actual = (instanceResource == null);
        System.assertEquals(expected, actual);      
    }   
            
}