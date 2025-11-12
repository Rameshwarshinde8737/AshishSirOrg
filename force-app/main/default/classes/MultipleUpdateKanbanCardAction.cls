/**************************************************************************
 	* Date : 18/02/2020
	* Author     : Vijay Jayswal
 	* Description: Update Multiple KanbanCard
 	* Usage	  : Use to Update bulk KanbanCard through sObject request.
 	* None       : We are not supporting Boolean field updating through this API.
 **************************************************************************/ 
global with sharing class MultipleUpdateKanbanCardAction {	

	//Maximum Record Limit for MultipleUpdateKanbanCardAction API.
	private final static Integer MAXIMUM_RECORD_SIZE = 2000;
	// Limit Queueable Jobs.
	private final static Integer LIMIT_QUEUEABLE_JOBS = Limits.getLimitQueueableJobs();

	global class KanbanCardRequest { 
		@InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to update.')
		global List<leankor__Kanbancard__c> kanbancardList = new List<leankor__Kanbancard__c> ();     
		@InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board')
		global Boolean sendBroadcastMessage = false;
		@InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
		@InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
		global String projectEventCustomPayload;
	}
	
	@InvocableMethod	
	global static void updateKanbanCardProcess(List<KanbanCardRequest> kanbanCardRequest) { 
		// Variable used to check MAXIMUM_RECORD_SIZE
		Boolean isMaximumRecordSizeExceeded = false;

		/*	Iterating over the loop to check MAXIMUM_RECORD_SIZE for all requests, 
			if one of the requests exceeds the MAXIMUM_RECORD_SIZE then all requests will not be processed (meaning ALL or NOTHING).*/
		for(KanbanCardRequest request : kanbanCardRequest){
			if(request.kanbancardList.size() > MAXIMUM_RECORD_SIZE){
				isMaximumRecordSizeExceeded = true;
				break;
			}
		}

		// If any request does not exceed MAXIMUM_RECORD_SIZE then processed to next.
		if(isMaximumRecordSizeExceeded){
			throw new Util.LeanException('Error: One of the requests has exceeded the size limit of ' + MAXIMUM_RECORD_SIZE + '. No request will be processed.');
		} else {
			Integer totalRequests = kanbanCardRequest.size();
			Integer totalProcessedRequests = 0;
			
			for(KanbanCardRequest request : kanbanCardRequest){

				// Queueable job limit not exceeded then doing queueable, if Queueable job limit exceeded then will ignore remaining requests. 
				if(Limits.getQueueableJobs() < LIMIT_QUEUEABLE_JOBS){
					// Calling the method
					UpdateKanbanCard.updateKanbanCards(request);
					totalProcessedRequests++;
				} else{
					throw new Util.LeanException('Error: Too many queueable jobs are being added to the queue. Only ' + totalProcessedRequests + ' of ' + totalRequests + ' added to the queue.');
				}
			}
		}
	}
}