@isTest
private class DetectDeviceTest {

    /*---------------------------------------------------------------------------
    Company     : Leankor
    Description : This is cover getPhoneGapJS  method inside  DetectDevice Class
    ------------------------------------------------------------------------------*/ 
    @isTest
    private static void  getPhoneGapJSTest(){
        Test.startTest(); 
        DetectDevice detectDeviceRecord = new DetectDevice();
        String getPhoneGapJSRecord = detectDeviceRecord.getPhoneGapJS();
        System.assertEquals('{!$Resource.Cordova}', getPhoneGapJSRecord);
        Test.stopTest(); 
    }
}