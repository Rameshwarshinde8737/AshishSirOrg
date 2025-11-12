@isTest
private class WeekCalendarBehaviourTest {
    @isTest 
    static void testCRUDAccess() {
        Profile p = [Select Id 
                        From Profile 
                        Where Name='Standard User'];
                        
        User u1 = new User();
        u1.Alias = 'leankor1';
        u1.Email='leankor1@leankor.com';
        u1.EmailEncodingKey='UTF-8'; 
        u1.LastName='Leankor1'; 
        u1.LanguageLocaleKey='en_US';
        u1.LocaleSidKey='en_US'; 
        u1.ProfileId = p.Id;
        u1.TimeZoneSidKey='America/Los_Angeles'; 
        u1.UserName='leankor1@leankor.com';

        User u2 = new User();
        u2.Alias = 'leankor2';
        u2.Email='leankor2@leankor.com';
        u2.EmailEncodingKey='UTF-8'; 
        u2.LastName='Leankor2'; 
        u2.LanguageLocaleKey='en_US';
        u2.LocaleSidKey='en_US'; 
        u2.ProfileId = p.Id;
        u2.TimeZoneSidKey='America/Los_Angeles'; 
        u2.UserName='leankor2@leankor.com';

        insert u1;
        insert u2;

        PermissionSet ps = [Select Id 
                                From PermissionSet 
                                Where Name = 'Visual_Lean_User'];

        insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id );

        //positive test. User u1 has 'Visual_Lean_User' permission set assigned. Should have access to object
        System.runAs(u1) {
            WeekCalendarBehaviour weekCalendarBehaviour= new WeekCalendarBehaviour();
            
            //Read Access
            System.assertEquals(weekCalendarBehaviour.isAccessible(), true);

            //Update Access
            System.assertEquals(weekCalendarBehaviour.isUpdateable(), true);

            //Create Access
            System.assertEquals(weekCalendarBehaviour.isCreateable(), true);

            //Delete Access
            System.assertEquals(weekCalendarBehaviour.isDeletable(), true);
        } 
         System.runAs(u2) {
            WeekCalendarBehaviour weekCalendarBehaviour= new WeekCalendarBehaviour();
            
            //Read Access
            System.assertEquals(weekCalendarBehaviour.isAccessible(), false);

            //Update Access
            System.assertEquals(weekCalendarBehaviour.isUpdateable(), false);

            //Create Access
            System.assertEquals(weekCalendarBehaviour.isCreateable(), false);

            //Delete Access
            System.assertEquals(weekCalendarBehaviour.isDeletable(), false);
        } 

    }
}