/* FILE  : LeankorPlatformEvents.cls
 * CLASS : LeankorPlatformEvents
 * USAGE : Manage the Instance creation of BroadcastEvent 
		   and Publish broadcastEvents notification
 */
global with sharing class LeankorPlatformEvents{
	/***
     * INPUT: String verb, List<String> jsonList, String sessionId
     * OUTPUT: -
	 * Description : This method creates BroadcastEvent instance and call for publish those events
     */

    private static final Integer PAYLOAD_LENGTH_LIMIT = 131072;

    public String sessionId { get; set; }
    public String userId { get; set; }
    public String projectId { get; set; }
    public String eventCategory { get; set; }
    public String eventName { get; set; }
    public String jsonPayload { get; set; }
    public String customPayload { get; set; }
    public Boolean isAPIGenerated { get; set; }

    // Constructor
    // Initializing collections in the constructor is a common practice to ensure they are always ready for use, 
    //   especially in object-oriented programming
    // Initializing variables in the constructor ensures they have default values, 
    //   and to prevent NullPointerExceptions
    global LeankorPlatformEvents() {
        sessionId = userInfo.getSessionId();
        userId = UserInfo.getUserId();
        isAPIGenerated = true;
        projectId = '';
        eventCategory = '';
        eventName = '';
        customPayload = '';
        jsonPayload = '';
    }


    public void createPlatformEvents(leankor__ProjectEvent__e projectEvent) {
        projectEvent.leankor__UserID__c = userId;
        projectEvent.leankor__IsAPIGenerated__c = isAPIGenerated;
        projectEvent.leankor__ProjectID__c = projectId;
        projectEvent.leankor__EventCategory__c = eventCategory;
        projectEvent.leankor__EventName__c = eventName;
        projectEvent.leankor__CustomPayload__c = customPayload;
        projectEvent.leankor__JSONPayload__c = jsonPayload;

        EventBus.publish(projectEvent);
    }
    

	/***
     * INPUT: String verb, String jsonData, String sessionId
     * OUTPUT: leankor__BroadcastEvent__e (object)
	 * Description : This method creates BroadcastEvent instance
     */
    public static leankor__BroadcastEvent__e prepareBroadcastEvent(String verb, String jsonData, String sessionId) {
        if (String.isBlank(jsonData)) {
            return null;
        }
    
        leankor__BroadcastEvent__e broadcastEvent = new leankor__BroadcastEvent__e();
        broadcastEvent.leankor__EventName__c = verb;
        broadcastEvent.leankor__SessionID__c = sessionId;

        List<String> payloads = preparePayloadData(jsonData);
        Integer payloadSize = payloads.size();
            
        // Assign substrings to the appropriate fields on the Broadcast__e object
        if (payloadSize > 0) {
            broadcastEvent.leankor__JSONPayload__c = payloads[0]; 
        }

        if (payloadSize > 1) { 
            broadcastEvent.leankor__JSONPayload1__c = payloads[1]; 
    }
    
        if (payloadSize > 2) { 
            broadcastEvent.leankor__JSONPayload2__c = payloads[2]; 
    }

        return broadcastEvent;
    }
        

    private static List<String> preparePayloadData(String payloadString) {
        // List to hold the substrings
        List<String> subStrings = new List<String>();
        if (String.isNotBlank(payloadString)) {
            // Calculate the number of chunks needed
            Integer numOfChunks = (payloadString.length() + PAYLOAD_LENGTH_LIMIT - 1) / PAYLOAD_LENGTH_LIMIT;
            
            for (Integer i = 0; i < numOfChunks; i++) {
                Integer startIdx = i * PAYLOAD_LENGTH_LIMIT;
                Integer endIdx = Math.min(startIdx + PAYLOAD_LENGTH_LIMIT, payloadString.length());
                String subString = payloadString.substring(startIdx, endIdx);
                subStrings.add(subString);
            }
        }
        
        return subStrings;
    }


	/***
     * INPUT: List of Platform Event SOBject
	 * Description : This method publishes BroadcastEvents
     */
    public static void publishBroadcastEvent(List<SObject> broadcastEvents) {
        EventBus.publish(broadcastEvents);
    }   
}