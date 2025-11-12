@isTest
Private class KanbanCardFavoriteBehaviourTest {
    
    //To create data for all the methods in this test class 
     
    @testsetup
    static void setupTestData(){
        
        Profile profileRecord = [Select Id 
                                   From Profile 
                                   Where Name = 'Standard User'];
        
        User userRecord = new User(Alias = 'leankor1', Email ='leankor1@leankor.com',
                                   EmailEncodingKey = 'UTF-8', LastName = 'Leankor1', LanguageLocaleKey = 'en_US',
                                   LocaleSidKey = 'en_US', ProfileId = profileRecord.Id,
                                   TimeZoneSidKey = 'America/Los_Angeles', UserName = 'example@leankor.com');
        insert userRecord;
        
    }
    
    @isTest 
    private static void accessCRUDTest() {
      
        Profile profileRecord = [Select Id 
                                   From Profile 
                                   Where Name = 'Standard User'];
        
        User userRecord = [Select Name 
                             From User 
                             Where UserName = 'example@leankor.com' 
                             Limit 1];
      
        
        PermissionSet permissionSet  = [Select Id 
                                           From PermissionSet 
                                           Where Name = 'Visual_Lean_User'];
        
        insert new PermissionSetAssignment(AssigneeId = userRecord.id, PermissionSetId = permissionSet.Id);
         System.runAs(userRecord) {
            KanbanCardFavoriteBehaviour kanbanCardFavoriteBehaviour = new KanbanCardFavoriteBehaviour();
            Test.startTest();
            System.assertEquals(kanbanCardFavoriteBehaviour.isAccessible(), true);
            System.assertEquals(kanbanCardFavoriteBehaviour.isCreateable(), true);
            System.assertEquals(kanbanCardFavoriteBehaviour.isUpdateable(), true);
            System.assertEquals(kanbanCardFavoriteBehaviour.isDeletable(), true);
            Test.stopTest();           
        }		
    }
    
    /*-----------------------------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover isAccessible Method inside  KanbanCardFavoriteBehaviour Class
    --------------------------------------------------------------------------------------------------------------------------------------------*/
    @istest
    private static void isCRUDTest(){ 
        
        User userRecord = [Select Name,
                                  ProfileId 
                               From User 
                               Where UserName = 'example@leankor.com' 
                               Limit 1];        
        
        System.runAs(userRecord) {
            Test.startTest();
            KanbanCardFavoriteBehaviour kanbanCardFavoriteBehaviour = new KanbanCardFavoriteBehaviour();
            System.assertEquals(kanbanCardFavoriteBehaviour.isAccessible(), false);
            System.assertEquals(kanbanCardFavoriteBehaviour.isCreateable(), false);
            System.assertEquals(kanbanCardFavoriteBehaviour.isUpdateable(), false);
            System.assertEquals(kanbanCardFavoriteBehaviour.isDeletable(), false);
            Test.stopTest();
        }
    }
}