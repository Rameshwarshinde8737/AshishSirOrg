/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestFlowZone.cls
 * CLASS: TestFlowZone      
 */
 
@isTest
private class TestFlowZone {

    // test for this flow class
    static testmethod void flowZoneTest() {
        
        // set up value stream A and insert
        leankor__ValueStream__c vs = new leankor__ValueStream__c();
        insert vs;
        ID vsAID = vs.Id;
        vs.Id = null;
        
        // set up value stream B and insert
        insert vs;
        ID vsBID = vs.Id;
        
        // set up zone and relate to B
        leankor__Zone__c lz = new leankor__Zone__c(leankor__ValueStream__c = vsBID);
        insert lz;
        
        // set up kanban card and relate to A
        leankor__KanbanCard__c kc = new leankor__KanbanCard__c(leankor__ValueStream__c = vsAID);
        insert kc;
        
        // call flow with kanban, zone and value stream ID's
        FlowZone plugin = new FlowZone();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams;

        InputParams.put('TargetValueStreamID', vsBID);
        InputParams.put('TargetZoneID', lz.Id);
        InputParams.put('KanbanCardID', kc.Id);
        InputParams.put('SessionID', 'dummysessionID');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        // have to create a zone and kanban record first otherwise this fails!
        Process.PluginResult result = plugin.invoke(request);
        System.AssertEquals(result.OutputParameters.get('HyperJumpSuccessFlag'), true);
    } 
    
    static testmethod void flowZoneNegativeTest() {
        
        // call flow with WRONG kanban, zone and value stream ID's
        FlowZone plugin = new FlowZone();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams;

        InputParams.put('TargetValueStreamID', 'a00d0000008k1ZZ');
        InputParams.put('TargetZoneID', 'a00d0000008k1ZZ');
        InputParams.put('KanbanCardID', 'a00d0000008k1ZZ');
        InputParams.put('SessionID', 'dummysessionID');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        Process.PluginResult result;
        // have to create a zone and kanban record first otherwise this fails!
        try{
            result = plugin.invoke(request);
            System.AssertEquals(result.OutputParameters.get('HyperJumpSuccessFlag'), false);
        }catch(Exception e){
            System.Assert(e.getMessage().contains('ERROR'));
        }
        
        //
        // NOW TRY TO PASS ZONE SELECT, BUT FAIL KANBAN
        //
        // set up value stream A and insert
        leankor__ValueStream__c vs = new leankor__ValueStream__c();
        insert vs;
        // set up zone and relate to B
        leankor__Zone__c lz = new leankor__Zone__c(leankor__ValueStream__c = vs.Id);
        insert lz;
        
        inputParams = new Map<String,Object>();
        InputParams.put('TargetValueStreamID', 'a00d0000008k1ZZ');
        InputParams.put('TargetZoneID', lz.Id);
        InputParams.put('KanbanCardID', 'a00d0000008k1ZZ');
        InputParams.put('SessionID', 'dummysessionID');

        request = new Process.PluginRequest(inputParams);           
        
        // have to create a zone and kanban record first otherwise this fails!
        try{
            result = plugin.invoke(request);
            System.AssertEquals(result.OutputParameters.get('HyperJumpSuccessFlag'), false);
        }catch(Exception e){
            System.Assert(e.getMessage().contains('ERROR'));
        }
        
        
    } 
    
     static testMethod void flowZoneDescribeTest() {

            FlowZone plugin = new FlowZone();
            Process.PluginDescribeResult result = plugin.describe();
                
            System.AssertEquals(result.inputParameters.size(), 4);
            System.AssertEquals(result.OutputParameters.size(), 1);
        
     }
     
}