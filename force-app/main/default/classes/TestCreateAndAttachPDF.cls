/*

Copyright (c) 2012, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.




 * Salesforce version written for: Winter '12
 * This Apex plug-in for Visual Workflow creates a pdf document and attaches to the notes and attachmetns section of any record in salesforce.
 * Inputs: 
 *    Record ID (Required)
 *    Attachment Name (Required)
 *    Attachment content (Required)
 *
 * Outputs:
 *    Status = SUCCESS/ERROR if all is well or any Error
 *    ErrorMessage if status is ERROR with the apprporiate error message
 */


@isTest
private class TestCreateAndAttachPDF {

 static testMethod void createAttachPDFTest() {

        // Create dummy lead
        Lead testLead = new Lead(Company='Test Lead',FirstName='John',LastName='Doe');
        insert testLead;

        createAndAttachPDF aPdfPlugin = new createAndAttachPDF();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        inputParams.put('recordID',testLead.ID);
        inputParams.put('pdfAttachmentName','PDF Attachment');
        inputParams.put('pdfAttachmentContent','Dear All This is a test');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        result = aPdfPlugin.invoke(request);
        System.debug(result);
        
        System.assertEquals(result.OutputParameters.get('Status'),'SUCCESS');     

        Attachment anAttach = [select parentID, name from attachment where parentiD =:testLead.ID];
        System.AssertEquals(anAttach.name, 'PDF Attachment' );            
        
        
        }
        
        /*
        * basic -eve test with an invalid recordID
        */        
        static testMethod void negativePDFTest() {


        createAndAttachPDF aPdfPlugin = new createAndAttachPDF();
        Map<String,Object> inputParams = new Map<String,Object>();
        Map<String,Object> outputParams = new Map<String,Object>();

        //Pass in invalid ID
        inputParams.put('recordID','blah');
        inputParams.put('pdfAttachmentName','PDF Attachment');
        inputParams.put('pdfAttachmentContent','Dear All This is a test');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result;
        try{
            result = aPdfPlugin.invoke(request);
            System.assertEquals(result.OutputParameters.get('Status'),'ERROR');    
        }catch(Exception e){
            System.Assert(e.getMessage().contains('ERROR:Invalid id'));
        } 
        
}


 /*
  * This test is to test the describe() method
  */ 
        static testMethod void describeTest() {

                createAndAttachPDF aPdfPlugin = new createAndAttachPDF();
                Process.PluginDescribeResult result = aPdfPlugin.describe();
                
                System.AssertEquals(result.inputParameters.size(), 3);
                System.AssertEquals(result.OutputParameters.size(), 2);
        
        }
                

}