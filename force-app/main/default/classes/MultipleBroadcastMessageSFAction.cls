global with sharing class MultipleBroadcastMessageSFAction {
    global class MultipleBroadcastMessageRequest{   
        @InvocableVariable(label = 'Verb' description = 'Type of event which needs to broadcasted.' required = true)
        global String verb;
        @InvocableVariable(label = 'Record Ids' description = 'List of record ids for which broadcast need to send.' required = true)
        global List<String> recordIds;
    }

    @InvocableMethod
    global static List<MultipleBroadcastMessageRequest> sendBroadcastNotificationProcess(List<MultipleBroadcastMessageRequest> requests) {
        List<leankor.MultipleBroadcastMessageAction.MultipleBroadcastMessageRequest> multipleBroadcastMessageRequests = new List<leankor.MultipleBroadcastMessageAction.MultipleBroadcastMessageRequest>();
        for(MultipleBroadcastMessageRequest request : requests){
            leankor.MultipleBroadcastMessageAction.MultipleBroadcastMessageRequest multipleBroadcastMessageRequest = new leankor.MultipleBroadcastMessageAction.MultipleBroadcastMessageRequest();
            multipleBroadcastMessageRequest.verb = request.verb;
            multipleBroadcastMessageRequest.recordIds = request.recordIds;
            multipleBroadcastMessageRequests.add(multipleBroadcastMessageRequest);
        }
        leankor.MultipleBroadcastMessageAction.sendBroadcastNotificationProcess(multipleBroadcastMessageRequests);
        return requests;
    }
}