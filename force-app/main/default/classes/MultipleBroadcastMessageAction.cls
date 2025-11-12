/**************************************************************************
 * Author     : Suraj Sen
 * Description: Send Broadcast for Bulk Records
 **************************************************************************/ 
Global with sharing class MultipleBroadcastMessageAction{
    @InvocableMethod
    Global static void sendBroadcastNotificationProcess(List<MultipleBroadcastMessageRequest> requests) {
        sendBulkBroadcastNotification(requests);
    }

    Global class MultipleBroadcastMessageRequest{   
        @InvocableVariable(label = 'Verb' description = 'Type of event which needs to broadcasted.' required = true)
        Global String verb;
        @InvocableVariable(label = 'Record Ids' description = 'List of record ids for which broadcast need to send.' required = true)
        Global List<String> recordIds;
    }

    public static void sendBulkBroadcastNotification(List<MultipleBroadcastMessageRequest> requests) {
    	Map<String, List<String>> broadcastMap = new Map<String, List<String>>();
    	String verb='';
    	for (MultipleBroadcastMessageRequest request : requests) {
    		broadcastMap.put('',request.recordIds);
    		verb = request.verb;
        } 
        GenericStreamingController.sendBroadcastForBulkRecords(verb, broadcastMap,UserInfo.getSessionId());
    }
}