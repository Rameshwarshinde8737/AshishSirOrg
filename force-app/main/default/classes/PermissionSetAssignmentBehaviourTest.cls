@isTest
private class PermissionSetAssignmentBehaviourTest {
	
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

		PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Visual_Lean_User'];
		insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id );

		String [] fields = new String [] {'PermissionSetId', 'AssigneeId' };

		//positive test. User u1 has 'Visual_Lean_User' permission set assigned. Should have access to object
		System.runAs(u1) {
			PermissionSetAssignmentBehaviour b = new PermissionSetAssignmentBehaviour();
			
			//Read Access
			System.assertEquals(true, b.isAccessible());
			System.assertEquals(true, b.isAccessible(fields));

			//Update Access
            System.assertEquals(true, b.isUpdateable());
            System.assertEquals(true, b.isUpdateable(fields));

			//Create Access
            System.assertEquals(true, b.isCreateable());
            System.assertEquals(true, b.isCreateable(fields));

			//Delete Access
            System.assertEquals(true, b.isDeletable());
		}		

	}
	
}