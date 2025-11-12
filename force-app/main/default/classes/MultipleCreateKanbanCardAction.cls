/**************************************************************************
	* Company     : Leankor
 	* Description : Use to Create multiple create kanban card using sObject.
 	* Usage	      : Use to Move bulk KanbanCard through sObject request.
 	* None        : 
 **************************************************************************/ 
global with sharing class MultipleCreateKanbanCardAction {

	// Maximum Record Limit for MultipleCreateKanbanCardAction API.
	private final static Integer MAXIMUM_RECORD_SIZE = 2000;
	// Limit Queueable Jobs.
	private final static Integer LIMIT_QUEUEABLE_JOBS = Limits.getLimitQueueableJobs();
	

	global class KanbanCardRequest {
		@InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to create.')
		global List <leankor__KanbanCard__c> kanbanCardRequests;  
		@InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
		global Boolean sendBroadcastMessage; 
		@InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
		@InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
		global String projectEventCustomPayload;
		@InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		global Boolean generateWorkBreakdownStructure = false;
		public String title;
		public String categoryName;  
		public Id ownerID;
		public String projectBoardName;	 
		public String sessionId;
		public String verb;
	}   

	global class KanbanCardResult {          
		@InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of created KanbanCard records.')
		global List<leankor__KanbanCard__c> kanbanCardResults; 
	}

	@InvocableMethod
    global static List<KanbanCardResult> CreateKanbanCardProcess(List<KanbanCardRequest> kanbanCardRequest) {
		List<KanbanCardResult> results = new List<KanbanCardResult>(); 
		// Variable used to check MAXIMUM_RECORD_SIZE
		Boolean isMaximumRecordSizeExceeded = false;

		/*	Iterating over the loop to check MAXIMUM_RECORD_SIZE for all requests, 
			if one of the requests exceeds the MAXIMUM_RECORD_SIZE then all requests will not be processed (meaning ALL or NOTHING).*/
		for (KanbanCardRequest request : kanbanCardRequest) {
			if (request.kanbanCardRequests.size() > MAXIMUM_RECORD_SIZE) {
				isMaximumRecordSizeExceeded = true;
				break;
			}
		}

		// If any request exceeds MAXIMUM_RECORD_SIZE then throw an error
		if (isMaximumRecordSizeExceeded) {
			throw new Util.LeanException('Error: One of the requests has exceeded the size limit of ' + MAXIMUM_RECORD_SIZE + '. No request will be processed.');
		} else {
			Integer totalRequests = kanbanCardRequest.size();
			Integer totalProcessedRequests = 0;

			for (KanbanCardRequest request : kanbanCardRequest) {

				// Queueable job limit not exceeded then doing queueable, if Queueable job limit exceeded then will ignore remaining requests. 
				if (Limits.getQueueableJobs() < LIMIT_QUEUEABLE_JOBS) {	
					CreateKanbanCard.createKanbanCard(request); // this always returns an empty list as it is an asynch process
					totalProcessedRequests++;
				} else {
					throw new Util.LeanException('Error: Too many queueable jobs are being added to the queue. Only ' + totalProcessedRequests + ' of ' + totalRequests + ' added to the queue.');
				}
			}
		}
		
		return results;
	}	
}