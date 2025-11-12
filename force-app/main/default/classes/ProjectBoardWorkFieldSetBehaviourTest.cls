@IsTest
public class ProjectBoardWorkFieldSetBehaviourTest {

    @IsTest
    static void testIsAccessible() {
     // Create a test instance of the class
        ProjectBoardWorkFieldSetBehaviour behaviour = new ProjectBoardWorkFieldSetBehaviour();
        Boolean isAccessible = behaviour.isAccessible();
         System.assertEquals(true, isAccessible, 'isAccessible should return true when object and fields are accessible');

    }

    @IsTest
    static void testIsUpdateable() {
       // Create a test instance of the class
        ProjectBoardWorkFieldSetBehaviour behaviour = new ProjectBoardWorkFieldSetBehaviour(); 
        Boolean isUpdateable = behaviour.isUpdateable();
        System.assertEquals(true, isUpdateable, 'isUpdateable should return true when object and fields are updateable');
    }

    @IsTest
    static void testIsCreateable() {
        // Setup: Create a test instance of the class
        ProjectBoardWorkFieldSetBehaviour behaviour = new ProjectBoardWorkFieldSetBehaviour();
        Boolean isCreateable = behaviour.isCreateable();
        System.assertEquals(true, isCreateable, 'isCreateable should return true when object and fields are createable');
    }

    @IsTest
    static void testIsDeletable() {
        // Setup: Create a test instance of the class
        ProjectBoardWorkFieldSetBehaviour behaviour = new ProjectBoardWorkFieldSetBehaviour();
        Boolean isDeletable = behaviour.isDeletable();
        System.assertEquals(true, isDeletable, 'isDeletable should return true when object is deletable');
    }
    
    @isTest 
	static void testCRUDAccess() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User u1 = new User(Alias = 'leankor1', Email='leankor1@leankor.com',
						EmailEncodingKey='UTF-8', LastName='Leankor1', LanguageLocaleKey='en_US',
						LocaleSidKey='en_US', ProfileId = p.Id,
						TimeZoneSidKey='America/Los_Angeles', UserName='leankor1@leankor.com');

		User u2 = new User(Alias = 'leankor2', Email='leankor2@leankor.com',
						EmailEncodingKey='UTF-8', LastName='Leankor2', LanguageLocaleKey='en_US',
						LocaleSidKey='en_US', ProfileId = p.Id,
						TimeZoneSidKey='America/Los_Angeles', UserName='leankor2@leankor.com');

		insert u1;
		insert u2;

		//PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Visual_Lean_User'];
		//insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id );

		//positive test. User u1 has 'Visual_Lean_User' permission set assigned. Should have access to object
		System.runAs(u2) {
			ProjectBoardWorkFieldSetBehaviour b = new ProjectBoardWorkFieldSetBehaviour();
			
			//Read Access
			System.assertEquals(b.isAccessible(), false);
           

			//Update Access
			System.assertEquals(b.isUpdateable(), false);

			//Create Access
			System.assertEquals(b.isCreateable(), false);

			//Delete Access
			System.assertEquals(b.isDeletable(), false);
        }
    }
    

}