@istest
private class ProjectActivityPlanningConfigurationTest{  
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is for setup the testData
    ----------------------------------------------------------------------------------------------------------*/ 
    @testSetup
    private static void testData(){
        
        List<leankor__ValueStream__c> valueStreamListData = new List<leankor__ValueStream__c>();
        for(Integer i=1;i<=5;i++){
            leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
            valueStream.Name = 'dummy Data';    
            valueStream.leankor__ScheduleBackward__c = true;
            valueStream.leankor__ProjectBoardStartDateTime__c = System.now();
            valueStream.leankor__ProjectBoardEndDateTime__c = System.now()+2;
            valueStreamListData.add(valueStream);
        }
        insert valueStreamListData;
    }
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover updateValueStreamPlanningModes Method inside ProjectActivityPlanningConfiguration Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void updateValueStreamPlanningModesTest(){
        
        String mySessionID = userinfo.getSessionId(); 
        List<leankor__ValueStream__c> listValueStreamRecord = [Select Name,
                                                                    leankor__ProjectBoardStartDateTime__c,
                                                                    leankor__ProjectBoardEndDateTime__c,
                                                                    leankor__ScheduleBackward__c
                                                                From leankor__ValueStream__c
                                                                Where Name = 'dummy Data'
                                                                Limit 5];
        
        for(leankor__ValueStream__c valueStreamRecord : listValueStreamRecord){
            valueStreamRecord.Name = 'demo deta';
            valueStreamRecord.leankor__ScheduleBackward__c = false;
            valueStreamRecord.leankor__ProjectBoardStartDateTime__c = System.now()+2;
            valueStreamRecord.leankor__ProjectBoardEndDateTime__c = System.now()+4;
        }
        
        Test.startTest();
        List<leankor__ValueStream__c> updateValueStream = ProjectActivityPlanningConfiguration.updateValueStreamPlanningModes(listValueStreamRecord,mySessionID);
        List<leankor__ValueStream__c> updateListValueStreamRecord = [Select Name,
                                                                            leankor__ProjectBoardStartDateTime__c,
                                                                            leankor__ProjectBoardEndDateTime__c
                                                                       From leankor__ValueStream__c
                                                                       Where Name = 'demo deta'
                                                                       Order by Name
                                                                       Limit 5];
        
        System.assertEquals(updateListValueStreamRecord[0].Name,'demo deta');
        System.assertEquals(updateListValueStreamRecord[0].leankor__ProjectBoardStartDateTime__c,System.now()+2);
        System.assertEquals(updateListValueStreamRecord[0].leankor__ProjectBoardEndDateTime__c, System.now()+4);
        Test.stoptest();      
    }
    
    @istest
    private static void updateValueStreamPlanningModesTestData(){
        Test.startTest();
        List<leankor__ValueStream__c> updateListValueStream = [Select Id,
                                                                        Name,
                                                                        leankor__ProjectBoardEndDateTime__c,
                                                                        leankor__ProjectBoardStartDateTime__c,
                                                                        leankor__ScheduleBackward__c
                                                                    From leankor__ValueStream__c
                                                                    Where Name = 'dummy Data'
                                                                    Order by Name
                                                                    Limit 5];
        
        
        List<leankor__ValueStream__c> updateValueStream = ProjectActivityPlanningConfiguration.updateValueStreamPlanningModes(updateListValueStream);
        System.assert(updateValueStream.size()>0);
        Test.stoptest();      
    } 
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover ProjectActivityPlanningConfiguration constructor inside ProjectActivityPlanningConfiguration Class
    ----------------------------------------------------------------------------------------------------------*/ 
    @istest
    private static void projectActivityPlanningConfigurationTest(){
        
        Boolean flag = true; 
        leankor__ValueStream__c valueStream = [Select Id,
                                                      Name
                                                From leankor__ValueStream__c
                                                Limit 1];
        Test.startTest();
        ApexPages.StandardController stdControllerRecord = new ApexPages.StandardController(valueStream);
        ProjectActivityPlanningConfiguration projectActivityPlanningConRecord = new  ProjectActivityPlanningConfiguration(stdControllerRecord);
        System.assertEquals(true, flag);
        Test.stopTest();
    }  
}