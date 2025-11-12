/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestSubmitForApproval.cls
 * CLASS: TestSubmitForApproval       
 */
 
@isTest
private class TestSubmitForApproval {

  /* 
 * Basic test. The test does not have an assert for the status as there the Process.submit depends on 
 * approval processes defined in the org. If that is the case, the status will be set to ERROR. Howecer
 * if the lead record enters an approval process, then the status will be SUCCESS. 

 */   
        static testMethod void basicTest() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;
        ProcessInstance[] anApprovalList;
        
        submitForApproval anApprovalPlugin = new submitForApproval();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = anApprovalPlugin.invoke(request);     
        anApprovalList = [select id, status from processInstance where targetObjectID = :testLead.Id];   
        if (anApprovalList.size() > 0)
            System.AssertEquals(result.OutputParameters.get('Status'), SubmitForApproval.SUCCESS_CODE);
        else
            System.AssertEquals(result.OutputParameters.get('Status'), SubmitForApproval.ERROR_CODE);
        }

 /* 
 * -ve test. This tests the fact that bad ids or non-existant IDs will always result in an ERROR status
 */ 
        static testMethod void negativeTest() {
        
        submitForApproval anApprovalPlugin = new submitForApproval();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',SubmitForApproval.BAD_ID);
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = anApprovalPlugin.invoke(request);
        System.AssertEquals(result.OutputParameters.get('Status'), SubmitForApproval.ERROR_CODE);
        }        
        
        static testMethod void describeTest() {

                submitForApproval anApprovalPlugin = new submitForApproval();
                Process.PluginDescribeResult result = anApprovalPlugin.describe();
                
                System.AssertEquals(result.inputParameters.size(), 1);
                System.AssertEquals(result.OutputParameters.size(), 2);
        
        }
        
}