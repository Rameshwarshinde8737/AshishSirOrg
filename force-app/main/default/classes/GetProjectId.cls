public with sharing class GetProjectId {
    public GetProjectId() {
 
    }
    @AuraEnabled
    public static String getProjectRoomIdFromValueStream(String valueStreamId) {
        leankor__valuestream__c vs = [
            SELECT leankor__projectroom__c
            FROM leankor__valuestream__c
            WHERE Id = :valueStreamId
            LIMIT 1
        ];
        return vs.leankor__projectroom__c;
    }
}