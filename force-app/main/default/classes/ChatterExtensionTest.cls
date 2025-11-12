/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ChatterExtensionTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        Contact cont = new Contact(LastName='cont1');
        insert cont;
        ApexPages.currentPage().getParameters().put('isLightning', cont.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(cont);
        ChatterExtension chatExt = new ChatterExtension(sc);
        
        leankor__LeanConstants__c leanConst = new leankor__LeanConstants__c();
        leanConst.name = 'Test Lean Constance';
        leanconst.leankor__ChatterUI__c = 'Auto';
        insert leanConst;
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(cont);
        ChatterExtension chatExt2 = new ChatterExtension(sc1);
        String chatterUI = leankor__LeanConstants__c.getInstance().leankor__ChatterUI__c;
        System.assertEquals(chatterUI, 'Auto');
        Test.stopTest();
    }
}