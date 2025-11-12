/**
 * FILE: ProjectScheduleBlackoutTriggerHandler.cls
 * CLASS: ProjectScheduleBlackoutTriggerHandler
*/

public with sharing class ProjectScheduleBlackoutTriggerHandler {
    
    public ProjectScheduleBlackoutTriggerHandler() {}
    // Ashutosh : 08/12/2021 : Variable Added for checking code is executing from trigger or not
    public static Boolean  isCalledFromTrigger = false;
    
    public void onBeforeInsert(Object[] newObjects){

    }
    public void onBeforeUpdate(Object[] updatedObjects, Map<ID,Object> oldObjectMap, Map<ID,Object> newObjectMap){

    }
    public void onAfterInsert(Object[] newObjects){
        updateIsScheduleRecalculate(newObjects);                                                                           
    }
    
    public void onAfterUpdate(Object[] updateObjects){
        updateIsScheduleRecalculate(updateObjects);
    }


    public void onAfterDelete(Object[] deletedObjects){
        updateIsScheduleRecalculate(deletedObjects);
    }

    public void onAfterUnDelete(Object[] unDeletedObjects){
        updateIsScheduleRecalculate(unDeletedObjects);
    }

    /**
     * Helping method to update the Is Schedule Recalculate for Value stream when the CRUD operations on 
     * Project Schedule Blackout affecting the existing cards on a board.   
     */
    private void updateIsScheduleRecalculate(Object[] newObjects){
		String kanbanVerb ='ScheduleRecalculate'; 
		Map<String,List<String>> broadcastContentMap =  new Map<String,List<String>>();
		List<String> jsonDataList = new List<String>();
		
        Set<ID> vsIdSet = new Set<ID>(); // To store the affected Value Stream Ids.
        leankor__ProjectScheduleBlackout__c [] newProjectBlackOutList = (leankor__ProjectScheduleBlackout__c []) newObjects; 
        for (leankor__ProjectScheduleBlackout__c newBlackOut : newProjectBlackOutList) {
            vsIdSet.add(newBlackOut.leankor__ProjectBoard__c);
        } 
        // Retrieving the affected Value Stream records to update.
        List<leankor__ValueStream__c> updateValueStreams = [Select Id,
                                                                    leankor__IsScheduleRecalculate__c
                                                                From leankor__ValueStream__c
                                                                Where Id In: vsIdSet
                                                                With Security_Enforced
                                                                Limit 9999];
        
        List<String> vsList =new List<String>();                                                        
        for (leankor__ValueStream__c vs : updateValueStreams) {
            vs.leankor__IsScheduleRecalculate__c = true;
            vsList.add(vs.id);    
        }          
        updateValueStreams = ValueStream.updateValueStream(updateValueStreams);     
        //Date :05/11/19 sending Broadcast is Board ScheduleRecalculate is true.
         if (vsList.size()>0 && !(System.isFuture() || System.isQueueable())) {
         	broadcastContentMap.put('',vsList);  
        	leankor.GenericStreamingController.sendBroadcastForBulkRecords(kanbanVerb, broadcastContentMap, UserInfo.getSessionId());       
        } 
    }
}