@isTest
public class LeanConstantsBehaviourTest {

    @isTest
    static void testIsAccessible(){
        LeanConstantsBehaviour behaviour = new LeanConstantsBehaviour();
         Boolean isAccessible = behaviour.isAccessible();
         System.assertEquals(true, isAccessible, 'isAccessible should return true when object and fields are accessible');
    }
    @isTest
    static void testIsUpdateable(){
        LeanConstantsBehaviour behaviour = new LeanConstantsBehaviour();
         Boolean isUpdateable = behaviour.isUpdateable();
         System.assertEquals(true, isUpdateable, 'isUpdateable should return true when object and fields are accessible');
    }
    @isTest
    static void testIsCreateable(){
        LeanConstantsBehaviour behaviour = new LeanConstantsBehaviour();
         Boolean isCreateable = behaviour.isCreateable();
         System.assertEquals(true, isCreateable, 'isCreateable should return true when object and fields are accessible');
    }
    @isTest
    static void testIsDeletable(){
        LeanConstantsBehaviour behaviour = new LeanConstantsBehaviour();
         Boolean isDeletable = behaviour.isDeletable();
         System.assertEquals(true, isDeletable, 'isDeletable should return true when object and fields are accessible');
    }
}