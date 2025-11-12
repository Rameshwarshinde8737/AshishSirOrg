@isTest
private class TimeCardTriggerHandlerTest {
    public TimeCardTriggerHandlerTest() {}

    private static User u = null;

    /* This method sets up the Account and Contact data to be used by the Community User
    *  Specficially created so that DML statements for creating Account and Contact don't interfere with the DML statements for creating User
    */
    @TestSetup
    static void makeData(){
        Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);
    }
	
    // Method for creating a user with 'Visual Lean Designer' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
	private static void createDesignerUser() {
        u = leankor.PermissionSetsTestDataFactory.getUser('A', 'User', 'Standard User', new List<String>{'Visual_Lean_Designer'});
	}

    // Method for creating a Community user with 'Visual Lean Customer Community User' permission set and run as them for tests
    // calls PermissionSetsTestDataFactory class
    private static void createCommunityUser() {
        List<String> permissionSets = new List<String>{'Visual_Lean_Customer_Community_User'};
        Contact testContact = [Select Id 
                                From Contact
                                Where Birthdate =:Date.newInstance(2016, 12, 9)
                                Limit 1];
        u = leankor.PermissionSetsTestDataFactory.getCommunityUser('Community', 'User', testContact.Id, 'Customer Community Plus Login User', permissionSets);
    }

    // Method for creating a test Timesheet
    private static leankor__TimeSheet__c createTimeSheet(String nameInput, Id userId) {
        leankor__TimeSheet__c sampleTimeSheet = new leankor__TimeSheet__c();
        sampleTimeSheet.Name = nameInput; 
        sampleTimeSheet.leankor__StartDateTime__c = Datetime.newInstance(2022 , 01 , 01, 12, 15, 10);
        sampleTimeSheet.leankor__EndDateTime__c = Datetime.newInstance(2022 , 01 , 01, 12, 15, 10);
        sampleTimeSheet.leankor__ApprovalHistoryStatus__c = 'Submitted'; 
        sampleTimeSheet.leankor__Resource__c = userId;
        insert sampleTimeSheet;
        return sampleTimeSheet;
    }

    // Method for creating a list of Time Cards
    private static List<leankor__TimeCard__c> createTimeCards(String timeSheetId, Id userId) {
        List<leankor__TimeCard__c> timeCardList = new List<leankor__TimeCard__c>();
        for(Integer i = 0; i < 1000; i++) {
            leankor__TimeCard__c  timeCard = new leankor__TimeCard__c();
                timeCard.leankor__TimeSheet__c = timeSheetId;
                timeCard.leankor__Assign_a_User__c = userId;	   	
                timeCardList.add(timeCard);
        } 
        insert timeCardList;
        return timeCardList;
    }

    /* Method tests when handler receives from trigger for a delete of Time Card record(s)
    * Test will pass if an error is thrown since Time Card will be related to a Timesheet.
    * Test will fail if an error is NOT thrown even if Time Card is related to a Timesheet
    */
    @isTest
    static void testDeleteTimeCardFromSubmittedTimeSheet() {

        createDesignerUser();

        System.runAs(u) {

            leankor__TimeSheet__c sampleTimeSheet = createTimeSheet('Sample', u.Id);

            Test.startTest();

            List<leankor__TimeCard__c> timeCardList = createTimeCards(sampleTimeSheet.Id, u.Id);

            TimeCardTriggerHandler handler = new TimeCardTriggerHandler(timeCardList);

            Boolean thrownException = false;
            Exception error;

            try {
                handler.onBeforeDelete();
            } catch (Exception e) {
                error = e;
                thrownException = true;
            } finally {
                System.debug('Exception thrown? ' + thrownException);
                System.debug(error);
                System.assert(error.getMessage().contains('Cannot update or delete time card from a timesheet that has already been processed'));
                System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
            }

            Test.stopTest();
            
        }

    }

    /* Method tests when handler receives from trigger for an update of Time Card record(s)
    * Test will pass if an error is thrown since Time Card will be related to a Timesheet.
    * Test will fail if an error is NOT thrown even if Time Card is related to a Timesheet
    */
    @isTest
    static void testUpdateTimeCardFromSubmittedTimeSheet() {
        
        createDesignerUser();

        System.runAs(u) {

            leankor__TimeSheet__c sampleTimeSheet = createTimeSheet('Sample', u.Id);

            Test.startTest();

            List<leankor__TimeCard__c> timeCardList = createTimeCards(sampleTimeSheet.Id, u.Id);

            TimeCardTriggerHandler handler = new TimeCardTriggerHandler(timeCardList);

            Boolean thrownException = false;
            Exception error;

            try {
                handler.onBeforeUpdate();
            } catch (Exception e) {
                error = e;
                thrownException = true;
            } finally {
                System.debug('Exception thrown? ' + thrownException);
                System.debug(error);
                System.assert(error.getMessage().contains('Cannot update or delete time card from a timesheet that has already been processed'));
                System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
            }

            Test.stopTest();
            
        }
    }

    /* Method tests when handler receives from trigger for an update of Time Card record(s)
    * This method also tests to run as a Community User
    * Test will pass if an error is thrown since Time Card will be related to a Timesheet.
    * Test will fail if an error is NOT thrown even if Time Card is related to a Timesheet
    */
    @isTest
    static void testUpdateTimeCardCommunityUser() {

        createCommunityUser();

        System.runAs(u) {

            leankor__TimeSheet__c sampleTimeSheet = createTimeSheet('Sample', u.Id);

            Test.startTest();

            List<leankor__TimeCard__c> timeCardList = createTimeCards(sampleTimeSheet.Id, u.Id);

            TimeCardTriggerHandler handler = new TimeCardTriggerHandler(timeCardList);

            Boolean thrownException = false;
            Exception error;

            try {
                handler.onBeforeUpdate();
            } catch (Exception e) {
                error = e;
                thrownException = true;
            } finally {
                System.debug('Exception thrown? ' + thrownException);
                System.debug(error);
                System.assert(error.getMessage().contains('Cannot update or delete time card from a timesheet that has already been processed'));
                System.AssertEquals(true, thrownException, 'A thrown exception was expected, but there was none.');
            }

            Test.stopTest();

        }
    }

    /* Method tests to make sure that a Community User with 'Visual Lean Community Customer User' permission set can access Timesheet object
    * Test will pass if the user with the permission set can create, read, edit, and delete the Timesheet object.
    * Test will fail if for some reason the user cannot create, red, edit, or delete the Timesheet object.
    */
    @isTest
    static void testCommunityUserAccessTimeSheet() {

        createCommunityUser();

        Test.startTest();

        System.runAs(u) {        

            List<ObjectPermissions> objPermissionList = [Select Id, 
                                                                SObjectType,
                                                                PermissionsCreate, 
                                                                PermissionsDelete,
                                                                PermissionsEdit,
                                                                PermissionsRead 
                                                        From ObjectPermissions 
                                                        Where ParentId In (Select PermissionSetId
                                                                            From PermissionSetAssignment 
                                                                            Where Assignee.Name = :u.Name
                                                                            And PermissionSet.Name = 'Visual_Lean_Customer_Community_User')
                                                        And SObjectType = 'leankor__TimeSheet__c'];

            for(ObjectPermissions op : objPermissionList) {
                System.assertEquals(true, op.PermissionsRead, 'Community user should be able to read Time Sheet object');
                System.assertEquals(true, op.PermissionsCreate, 'Community user should be able to create Time Sheet object');
                System.assertEquals(true, op.PermissionsEdit, 'Community user should be able to edit Time Sheet object');
                System.assertEquals(true, op.PermissionsDelete, 'Community user should be able to delete Time Sheet object');
            }

            Test.stopTest();

        }
    }

   /* Method tests to make sure that a Community User with 'Visual Lean Community Customer User' permission set can access Time card object
    * Test will pass if the user with the permission set can create, read, edit, and delete the Time card object.
    * Test will fail if for some reason the user cannot create, red, edit, or delete the Times card object.
    */
    @isTest
    static void testCommunityUserAccessTimeCard() {

        createCommunityUser();

        Test.startTest();

        System.runAs(u) {

            List<ObjectPermissions> objPermissionList = [Select Id, 
                                                                SObjectType,
                                                                PermissionsCreate, 
                                                                PermissionsDelete,
                                                                PermissionsEdit,
                                                                PermissionsRead 
                                                        From ObjectPermissions 
                                                        Where ParentId In (Select PermissionSetId
                                                                            From PermissionSetAssignment 
                                                                            Where Assignee.Name = :u.Name
                                                                            And PermissionSet.Name = 'Visual_Lean_Customer_Community_User')
                                                        And SObjectType = 'leankor__TimeCard__c'];

            for(ObjectPermissions op : objPermissionList) {
                System.assertEquals(true, op.PermissionsRead, 'Community user should be able to read Time Card object');
                System.assertEquals(true, op.PermissionsCreate, 'Community user should be able to create Time Card object');
                System.assertEquals(true, op.PermissionsEdit, 'Community user should be able to edit Time Card object');
                System.assertEquals(true, op.PermissionsDelete, 'Community user should be able to delete Time Card object');
            }

            Test.stopTest();

        }
    }

}