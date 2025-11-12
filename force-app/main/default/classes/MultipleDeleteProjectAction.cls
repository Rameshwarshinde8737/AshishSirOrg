/**************************************************************************
* Company     : Leankor
* Description : Delete multiple projects
 **************************************************************************/ 
global with sharing class MultipleDeleteProjectAction implements System.Queueable {

	private final static Integer MAXIMUM_RECORD_SIZE = 2000; // Maximum Record Limit for MultipleDeleteProjectAction API
	private final static Integer LIMIT_QUEUEABLE_JOBS = Limits.getLimitQueueableJobs(); // Limit Queueable Jobs.
    private Id projectRoomId;
    private String projectEventId;
    private String projectEventCustomPayload;
    private Boolean sendBroadcastMessage;

    public MultipleDeleteProjectAction(Id projectRoomId, String projectEventId, String projectEventCustomPayload, Boolean sendBroadcastMessage) {
        this.projectRoomId = projectRoomId;
        this.projectEventId = projectEventId;
        this.projectEventCustomPayload = projectEventCustomPayload;
        this.sendBroadcastMessage = sendBroadcastMessage;
    }

	global class ProjectRequest {
		@InvocableVariable(label = 'List of Project sObjects' description = 'List of Project records to delete.')
		global List <leankor__ProjectRoom__c> projectRequests;
		@InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
		global Boolean sendBroadcastMessage = false;        
		@InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
		@InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
		global String projectEventCustomPayload;
	}


	@InvocableMethod
    global static void deleteProjectProcess(List<ProjectRequest> projectRequests) {
		// iterate to check MAXIMUM_RECORD_SIZE for all requests
	    // if one of the requests exceeds the MAXIMUM_RECORD_SIZE then all requests will not be processed (meaning ALL or NOTHING)
		for (ProjectRequest request : projectRequests) {
			if (request.projectRequests.size() > MAXIMUM_RECORD_SIZE) {
                throw new Util.LeanException('Error: One of the requests has exceeded the size limit of ' + MAXIMUM_RECORD_SIZE + '. No request will be processed.');
			}
		}

        Integer totalRequests = projectRequests.size();
        Integer totalProcessedRequests = 0;

        for (ProjectRequest request : projectRequests) {
            for (leankor__ProjectRoom__c projectRoom : request.projectRequests) {
                // Queueable job limit not exceeded then doing queueable, if Queueable job limit exceeded then will ignore remaining requests. 
                if (Limits.getQueueableJobs() < LIMIT_QUEUEABLE_JOBS) {	
                    System.enqueueJob(new MultipleDeleteProjectAction(projectRoom.Id, request.projectId, request.projectEventCustomPayload, request.sendBroadcastMessage));
                    totalProcessedRequests++;
                } else {
                    throw new Util.LeanException('Error: Too many queueable jobs are being added to the queue. Only ' + totalProcessedRequests + ' of ' + totalRequests + ' added to the queue.');
                }
            }
        }
	}	
   
    global void execute(QueueableContext queueableContext) {
        try {
            if (ProjectBoardCarousel.deleteProjectRoom(projectRoomId) == 'Success') {
               
                // broadcast message
                if (sendBroadcastMessage) {
                    
                    ProjectBoardCarousel.PortfolioHierarchy portfolioHierarchy = new ProjectBoardCarousel.PortfolioHierarchy();
                    portfolioHierarchy.verb = 'DeleteProject';
                    portfolioHierarchy.Id = projectRoomId;                  
                    RealtimeKanbanController.manageNavChange('LeankorNAV', JSON.serialize(portfolioHierarchy), UserInfo.getSessionId());
                    //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
                    Boolean isGS = false;  
                    if (isGS) {
                        List<String> jsonDataList = new List<String>();
                        String json = '{"verb":"DeleteProject","Id":"'+projectRoomId+'","sessionID":"'+UserInfo.getSessionID()+'"}';
                        jsonDataList.add(json);
                        GenericStreamingController.broadcastNotificationAsync('LeankorNAV', jsonDataList);
                    }
                                
                }

                /*//------------------- BEGIN platform event broadcast
                if(String.isNotBlank(projectEventId) && Util.getSObjectName(projectEventId) == 'leankor__ProjectRoom__c'){
                    leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();

                    projectEvent.leankor__EventCategory__c = 'Deleting';
                    projectEvent.leankor__EventName__c = 'EndDelete';
                    projectEvent.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                    projectEvent.leankor__ProjectID__c = projectEventId;
                    projectEvent.leankor__UserID__c = UserInfo.getUserId();
                    projectEvent.leankor__CustomPayload__c = projectEventCustomPayload;
                    // Call method to publish events
                    Database.SaveResult saveResult = EventBus.publish(projectEvent);
                    if (!saveResult.isSuccess()){
                        // quick error processing, no need to Rollback
                        for (Database.Error error : saveResult.getErrors()) {
                            System.debug('Leankor Platform Event Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
                        }
                        // continue on because a failed platform event is no big deal; do NOT rollback
                    }   
                }
                //------------------- END platform event broadcast  */
            }
        } 
        catch(Exception e) {
            throw new Util.LeanException('Error: ' + e.getMessage());          
        }
        //Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in Another try/Catch block.
        try{
            //------------------- BEGIN platform event broadcast
            if(String.isNotBlank(projectEventId) && Util.getSObjectName(projectEventId) == 'leankor__ProjectRoom__c'){
                leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();

                projectEvent.leankor__EventCategory__c = 'Deleting';
                projectEvent.leankor__EventName__c = 'EndDelete';
                projectEvent.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                projectEvent.leankor__ProjectID__c = projectEventId;
                projectEvent.leankor__UserID__c = UserInfo.getUserId();
                projectEvent.leankor__CustomPayload__c = projectEventCustomPayload;
                // Call method to publish events
                Database.SaveResult saveResult = EventBus.publish(projectEvent);
                if (!saveResult.isSuccess()){
                    // quick error processing, no need to Rollback
                    for (Database.Error error : saveResult.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
                    }
                    // continue on because a failed platform event is no big deal; do NOT rollback
                }   
            }
            //------------------- END platform event broadcast 
        }catch(Exception ex){
            System.debug('ERROR :: '+ex.getMessage());
        }
    }
}