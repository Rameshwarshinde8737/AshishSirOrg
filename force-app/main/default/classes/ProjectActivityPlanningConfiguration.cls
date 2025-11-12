/* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: KanbanController.cls
 * CLASS: KanbanController
 */

global with sharing class ProjectActivityPlanningConfiguration {
    
    global ProjectActivityPlanningConfiguration(ApexPages.StandardController stdController) {
        
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Update Schedule Planning Configuration Record.
     Input       : List SchedulePlanningConfiguration Object.
     Output      : List SchedulePlanningConfiguration Object.
     --------------------------------------------------------------------------------*/ 
     // Ramanand : 16/11/2021- Changes : Created a new remote action method(Overloaded) so deprecating this method.
    //@RemoteAction
    @deprecated
    global static List<leankor__ValueStream__c> updateValueStreamPlanningModes(List<leankor__ValueStream__c> planningModes){
        
        return planningModes;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Update Schedule Planning Configuration Record.
     Input       : List SchedulePlanningConfiguration Object.
     Output      : List SchedulePlanningConfiguration Object.
     --------------------------------------------------------------------------------*/ 
     @RemoteAction
     global static List<leankor__ValueStream__c> updateValueStreamPlanningModes(List<leankor__ValueStream__c> planningModes, String sessionId){
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        for(leankor__ValueStream__c valueStream : planningModes){
            if (String.isNotBlank(valueStream.Id) && Util.getSObjectName(valueStream.Id) != 'leankor__ValueStream__c') {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
         
        List<leankor.RealTimeController.bulkStreaming> bulkStreams = new List<leankor.RealTimeController.bulkStreaming>();
        leankor.RealTimeController.flowWithGSForAPI = true;
        try {
            update planningModes;
             
        } catch (DMLException e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
         
        for(leankor__ValueStream__c singleInstanceOfValueStream : planningModes){
            leankor.realTimeController.bulkStreaming bulkStreaming = new leankor.realTimeController.bulkStreaming();
            leankor.RealTimeController.DirectLinkCardLog dataLog = new leankor.RealTimeController.DirectLinkCardLog();
            dataLog.ValueStreamId = singleInstanceOfValueStream.id;
            dataLog.ProjectBoardStartDateTime =  singleInstanceOfValueStream.leankor__ProjectBoardStartDateTime__c;
            dataLog.ProjectBoardEndDateTime = singleInstanceOfValueStream.leankor__ProjectBoardEndDateTime__c;
            dataLog.scheduleBackward = singleInstanceOfValueStream.leankor__ScheduleBackward__c;
            dataLog.sessionID = sessionId;
            bulkStreaming.VSID = singleInstanceOfValueStream.id;
            bulkStreaming.verb = 'UpdateProjectBoardPlanning';
            bulkStreaming.sessionID = UserInfo.getSessionID();
            bulkStreaming.SomeJSONData = JSON.Serialize(dataLog);
            // bulkStreaming.someJSONData = '{"schedulebackword" : "'+singleInstanceOfValueStream.leankor__ScheduleBackward__c	+'","ValueStreamID" :"'+ singleInstanceOfValueStream.Id+'" , "ProjectBoardStartDateTime" :"'+singleInstanceOfValueStream.leankor__ProjectBoardStartDateTime__c+'","ProjectBoardEndDateTime" :"'+singleInstanceOfValueStream.leankor__ProjectBoardEndDateTime__c+'"}';
            //bulkStreaming.someJSONData = '{"ScheduleBackwards" : "'+singleInstanceOfValueStream.leankor__ScheduleBackward__c	+'","Id" :"'+ singleInstanceOfValueStream.Id+'" , "StartDate" :"'+singleInstanceOfValueStream.leankor__ProjectBoardStartDateTime__c+'","DueDate" :"'+singleInstanceOfValueStream.leankor__ProjectBoardEndDateTime__c+'"}';
            bulkStreams.add(bulkStreaming);
        }
        leankor.RealTimeController.sendBroadCast(bulkStreams, 'UpdateProjectBoardPlanning');
        return planningModes;
    }
}