/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: FlowZone.cls
 * CLASS: FlowZone  
 * USAGE: This class implements a plugin to allow kanban cards to be assigned to a zone 
 */
global with sharing class FlowZone implements Process.Plugin { 
    // The main method to be implemented. The Flow calls this at runtime.
    global Process.PluginResult invoke(Process.PluginRequest request) { 
        
        //Check CRUD / FLC behavior   
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!KanbanCardBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior 
       
        // Get the subject of the Chatter post from the flow
        String vsId = (String) request.inputParameters.get('TargetValueStreamID');
        String zoneId = (String) request.inputParameters.get('TargetZoneID');
        String kanbanId = (String) request.inputParameters.get('KanbanCardID');
        String sessionId = (String) request.inputParameters.get('SessionID');
        Boolean mySuccess = true;

        // We actually never need TargetValueStreamID and we know it's valid upon entry
        
        // Get the Zone
        leankor__Zone__c targetZone = null;
        try {
            targetZone = [Select Id,
                                    leankor__GUID__c,
                                    leankor__Top__c, 
                                    leankor__Left__c, 
                                    leankor__X__c, 
                                    leankor__Y__c 
                                    From leankor__Zone__c 
                                    Where Id = :zoneId 
                                    With Security_Enforced
                                    Limit 1];
        } catch (System.Queryexception se) {
            mySuccess = false;
            // return to Flow
            Map<String,Object> result = new Map<String,Object>{'HyperJumpSuccessFlag' => mySuccess};
            // return new Process.PluginResult(result); 
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + se.getMessage()); 	
        } 
        
        if (targetZone == null || targetZone.Id == null) {
            mySuccess = false;
            // return to Flow
            Map<String,Object> result = new Map<String,Object>{'HyperJumpSuccessFlag' => mySuccess};
            return new Process.PluginResult(result);
        }
        
        // Get the Kanban 
        leankor__KanbanCard__c targetKanbanCard = null;
        try {
            targetKanbanCard = [Select  Id,
                                        leankor__ValueStream__c, 
                                        leankor__ZoneGUID__c,
                                        leankor__Left__c, 
                                        leankor__Top__c, 
                                        leankor__X__c, 
                                        leankor__Y__c 
                                    From leankor__KanbanCard__c 
                                    Where Id = :kanbanId
                                    With Security_Enforced];
        } catch (System.Queryexception se) {
            mySuccess = false;
            // return to Flow
            Map<String,Object> result = new Map<String,Object>{'HyperJumpSuccessFlag' => mySuccess};
            //return new Process.PluginResult(result); 
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + se.getMessage()); 	
        } 
        
        if (targetKanbanCard == null || targetKanbanCard.Id == null) {
            mySuccess = false;
            // return to Flow
            Map<String,Object> result = new Map<String,Object>{'HyperJumpSuccessFlag' => mySuccess};
            return new Process.PluginResult(result);
        }
        
        // Set the KanbanCard up to hyper jump
        targetKanbanCard.leankor__ValueStream__c = vsId;
        targetKanbanCard.leankor__Left__c = targetZone.leankor__Left__c + 10;  // need some space to clear thickness
        targetKanbanCard.leankor__X__c = targetKanbanCard.leankor__Left__c;  // X and Left are identical
        targetKanbanCard.leankor__Top__c = targetZone.leankor__Top__c + 40; // should clear the top tab bar of zone
        targetKanbanCard.leankor__Y__c = targetZone.leankor__Y__c + 40;
        targetKanbanCard.leankor__ZoneGUID__c = targetZone.leankor__GUID__c; // modify the zone relationship to match new home
        
        // update it
        try {
            update targetKanbanCard; 
            
            // Zone entry trigger
            leankor.RealTimeController.ZoneKanbanAction ZoneLog = New leankor.RealTimeController.ZoneKanbanAction();
        ZoneLog.Action ='HyperJumpToZone';
        ZoneLog.KanbanID = kanbanId; 
        ZoneLog.ZoneID = zoneId; 
        ZoneLog.SwimlaneID = '';
        ZoneLog.MasterContainerID = '';
        ZoneLog.VSID = vsId ; 
        ZoneLog.SessionID = sessionId;
        if (realtimeController.enterTheZone(ZoneLog) != 'success') {
            //if (realtimeKanbanController.enterTheZone('HyperJumpToZone', kanbanId, zoneId, vsId, sessionId) != 'success') {
                mySuccess = false;
                System.debug('Problem calling enterTheZone() with kanban,zone,value stream: ' + kanbanId + ',' + zoneId + ',' + vsId);
        }
            
        } catch (DmlException e) {
            mySuccess = false;
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage()); 	
        }  
        
        // return to Flow
        Map<String,Object> result = new Map<String,Object>();
        result.put('HyperJumpSuccessFlag', mySuccess); 
        return new Process.PluginResult(result); 
    } 

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        
        result.Name = 'Send Kanban to Zone';
        result.Description = 'This plugin allows any kanban card to be moved to any zone in any value stream.';
        result.Tag = 'Send to Zone';
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
               new Process.PluginDescribeResult.InputParameter('TargetValueStreamID', 
               Process.PluginDescribeResult.ParameterType.STRING, true) ,
               new Process.PluginDescribeResult.InputParameter('TargetZoneID', 
               Process.PluginDescribeResult.ParameterType.STRING, true),
               new Process.PluginDescribeResult.InputParameter('KanbanCardID', 
               Process.PluginDescribeResult.ParameterType.STRING, true),
               new Process.PluginDescribeResult.InputParameter('SessionID', 
               Process.PluginDescribeResult.ParameterType.STRING, true)
            }; 
            
        result.outputParameters = new 
           List<Process.PluginDescribeResult.OutputParameter>{ 
                new Process.PluginDescribeResult.OutputParameter('HyperJumpSuccessFlag', 
                    Process.PluginDescribeResult.ParameterType.BOOLEAN)
           }; 
           
        return result; 
    }
 
}