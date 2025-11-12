@istest
private class MultipleDeleteProjectActionTest {

    /*------------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------*/
   @testSetup 
   private static void makeData(){
    
    leankor__Portfolio__c testFolder = new leankor__Portfolio__c(Name = 'TestFolder');
    insert testFolder;
    
    List<leankor__ProjectRoom__c> testProjectList = new List<leankor__ProjectRoom__c>();
    for(integer i=1;i<=10;i++){
        leankor__ProjectRoom__c testProject = new leankor__ProjectRoom__c();
        testProject.Name = 'TestProject'+i;
        testProject.leankor__Portfolio__c = testFolder.Id;
        testProjectList.add(testProject);
    }
    insert testProjectList;

 }
    /*------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover deleteProjectProcess Method inside  MultipleDeleteProjectAction Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void deleteProjectProcessTest(){ 
        List<leankor__ProjectRoom__c> projectRoomRecord = [Select id 
                                                            From leankor__ProjectRoom__c
                                                            Limit 10];
                                                            
        List<MultipleDeleteProjectAction.ProjectRequest> projectRequestList = new List< MultipleDeleteProjectAction.ProjectRequest>();
        MultipleDeleteProjectAction.ProjectRequest projectRequest = new MultipleDeleteProjectAction.ProjectRequest();
        projectRequest.sendBroadcastMessage=true;
        projectRequest.projectId=projectRoomRecord[0].id;
        projectRequest.projectEventCustomPayload= 'Test';
        projectRequest.projectRequests= projectRoomRecord;
        projectRequestList.add(projectRequest);
     
        Test.startTest();
            MultipleDeleteProjectAction.deleteProjectProcess(projectRequestList);
		Test.stopTest();
        List<leankor__ProjectRoom__c> projectRoomRecord2 = [Select id 
                                                            From leankor__ProjectRoom__c];
        
        System.assert(projectRoomRecord2.size() == 0); 
    }
}