/**************************************************************************
 	* Company : Leankor
 	* Description: Hyperjump Multiple KanbanCard
 	* Usage	  : Use to Hyperjump bulk KanbanCard through sObject request.
 	* None       : 
 **************************************************************************/ 

global with sharing class MultipleHyperJumpAction implements System.Queueable {	
    
     // Maximum Record Limit for MultipleCreateKanbanCardAction API.
    private final static Integer MAXIMUM_RECORD_SIZE = 2000;
    // Limit Queueable Jobs.
	private final static Integer LIMIT_QUEUEABLE_JOBS = Limits.getLimitQueueableJobs();
    private KanbanController.MCHyperJumpLog hyperJumpRequest;
    private MultipleHyperJumpRequest request;

    global class MultipleHyperJumpRequest {
		@InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to hyper jump.' required=true)
		global List<leankor__KanbanCard__c> kanbanCardRequests = new List<leankor__KanbanCard__c> ();
		@InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message to affected board.')
		global Boolean sendBroadcastMessage;
		@InvocableVariable(label = 'Project Board Id' description = 'Project board id to place the hyper jumped records.' required=true)
		global String targetBoardId;
		@InvocableVariable(label = 'Zone Id' description = 'Zone id to place the hyper jumped records.')
		global String targetZoneId;
		@InvocableVariable(label = 'Category Id' description = 'Category id of the hyper jumped records.')
		global String targetCategoryId;
		@InvocableVariable(label = 'Project Board Id To Link' description = 'Project board id to link the hyper jumped records.')
		global String targetLinkBoardId;
        @InvocableVariable(label = 'Card Id To Link' description = 'Card id to link the hyper jumped records.')
		global String targetLinkCardId;
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
        global String projectEventCustomPayload;
        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		global Boolean generateWorkBreakdownStructure = false; 
	}

    // parameterized constructor
    public MultipleHyperJumpAction( KanbanController.MCHyperJumpLog hyperJumpRequest) {
        this.hyperJumpRequest = hyperJumpRequest;
    }

    public MultipleHyperJumpAction( KanbanController.MCHyperJumpLog hyperJumpRequest, MultipleHyperJumpRequest request) {
        this.hyperJumpRequest = hyperJumpRequest;
        this.request = request;
    }

    /*
    @InvocableMethod
    global static void hyperJumpKanbanCardProcess(List<MultipleHyperJumpRequest> kanbanCardRequests) {
        // List<KanbanController.MCHyperJumpLog> hyperJumpRequests = new List<KanbanController.MCHyperJumpLog>();
        Set<String> kanbanCardIDs = new Set<String>();
        Set<String> targetValueStreamIds =  new Set<String>();
        Boolean isSameValueStreamId = false;
        //Code For checking the source board and target board is not same.
        for(MultipleHyperJumpRequest request : kanbanCardRequests) {
            targetValueStreamIds.add(request.targetBoardId);
            for(leankor__KanbanCard__c kanbanCard : request.kanbanCardRequests) {
                kanbanCardIDs.add(kanbanCard.Id);
            }
        }
        for(leankor__KanbanCard__c kanbanId : [Select leankor__ValueStream__c 
                                                From leankor__KanbanCard__c 
                                                Where Id In :kanbanCardIDs 
                                                Limit 10000]) {
            if(targetValueStreamIds.contains(kanbanId.leankor__ValueStream__c)){
                isSameValueStreamId = true;
            }
        }
        if(isSameValueStreamId){
            throw new Util.LeanException('Error : can\'t hyperjump cards on same board');
        } 
        for(MultipleHyperJumpRequest request : kanbanCardRequests) {
            KanbanController.MCHyperJumpLog hyperJumpRequest = new KanbanController.MCHyperJumpLog();
            hyperJumpRequest.CardIDs = new List<String>(kanbanCardIDs);
            hyperJumpRequest.IsClone = false;
            hyperJumpRequest.TargetVSID = request.targetBoardId;
            hyperJumpRequest.DefaultCardtemplateID = request.targetCategoryId;
            hyperJumpRequest.LinkVSID = request.targetLinkBoardId;
            hyperJumpRequest.LinkCardID = request.targetLinkCardId;
            hyperJumpRequest.ColumnID = request.targetZoneId; 
            hyperJumpRequest.sendBroadcastMessage =request.sendBroadcastMessage == true ? true : false;
            hyperJumpRequest.projectEventCustomPayload = request.projectEventCustomPayload;
            hyperJumpRequest.projectId = request.projectId;
            if(kanbanCardIDs.size() <= MAXIMUM_RECORD_SIZE){
                system.enqueueJob(new MultipleHyperJumpAction(hyperJumpRequest));
            }
            else {
                throw new Util.LeanException('Error : Maximum Record Limit Exceeded');
            }
        }
    }   
    */
    
    @InvocableMethod
    global static void hyperJumpKanbanCardProcess(List<MultipleHyperJumpRequest> kanbanCardRequests) {
		// Variable used to check MAXIMUM_RECORD_SIZE
		Boolean isMaximumRecordSizeExceeded = false;

		/*	Iterating over the loop to check MAXIMUM_RECORD_SIZE for all requests, 
			if one of the requests exceeds the MAXIMUM_RECORD_SIZE then all requests will not be processed (meaning ALL or NOTHING).*/
		for (MultipleHyperJumpRequest request : kanbanCardRequests) {
			if (request.kanbanCardRequests.size() > MAXIMUM_RECORD_SIZE) {
				isMaximumRecordSizeExceeded = true;
				break;
			}
		}

        // If any request does not exceed MAXIMUM_RECORD_SIZE then processed to next.
		if (isMaximumRecordSizeExceeded) {
            throw new Util.LeanException('Error: One of the requests has exceeded the size limit of ' + MAXIMUM_RECORD_SIZE + '. No request will be processed.');
        } else {
            Integer totalRequests = kanbanCardRequests.size();
			Integer totalProcessedRequests = 0;

            for (MultipleHyperJumpRequest request : kanbanCardRequests) {

                // Queueable job limit not exceeded then doing queueable, if Queueable job limit exceeded then will ignore remaining requests.
                if (Limits.getQueueableJobs() < LIMIT_QUEUEABLE_JOBS) {
                    hyperJumpKanbanCards(request);
                    totalProcessedRequests++;
                } else {
					throw new Util.LeanException('Error: Too many queueable jobs are being added to the queue. Only ' + totalProcessedRequests + ' of ' + totalRequests + ' added to the queue.');
				}
            }
		}
    }   


    global void execute(QueueableContext queueableContext) {  
        //04/April/2023 : We have added new variable for Hybrid constraint while hyperJump the card with updating links. 
        KanbanController.isCalledFromMultipleAPI = true;  
        KanbanController.allMCCardsHyperJump(hyperJumpRequest);
        if (this.request.generateWorkBreakdownStructure == true) {
            if (String.isNotBlank(this.request.targetBoardId) && !Test.isRunningTest()) {
                CreateKanbanCardsQueueable.updateProjectWBS(new Set<String>{this.request.targetBoardId});
            }
        }

    }
    

    public static void hyperJumpKanbanCards(MultipleHyperJumpRequest request) {
        Boolean isSameValueStreamId = false;
        Set<String> kanbanCardIDs = new Set<String>();
        for (leankor__KanbanCard__c kanbanCard : [Select leankor__ValueStream__c 
                                                From leankor__KanbanCard__c 
                                                Where Id In :request.kanbanCardRequests 
                                                With Security_Enforced
                                                Limit 10000]) {
            kanbanCardIDs.add(kanbanCard.Id);                                   
            if (request.targetBoardId == kanbanCard.leankor__ValueStream__c) {
                isSameValueStreamId = true;
                break;
            }
        }
        if (isSameValueStreamId) {
            throw new Util.LeanException('Error : can\'t hyperjump cards on same board');
        } 

        KanbanController.MCHyperJumpLog hyperJumpRequest = new KanbanController.MCHyperJumpLog();
        hyperJumpRequest.CardIDs = new List<String>(kanbanCardIDs);
        hyperJumpRequest.IsClone = false;
        hyperJumpRequest.TargetVSID = request.targetBoardId;
		// 01 July 2022 : Changes to make a consistent MultipleHyperjump API with multiple Hyperjump cards from UI(there is inconsistency with category). 
        List<leankor__KanbanCardTemplate__c> valueStreamCategories = RealTimeController.getKanbanCardTemplates(request.targetBoardId);
        
        hyperJumpRequest.DefaultCardtemplateID = request.targetCategoryId != null ? request.targetCategoryId : valueStreamCategories[0].Id;
        hyperJumpRequest.LinkVSID = request.targetLinkBoardId;
        hyperJumpRequest.LinkCardID = request.targetLinkCardId;
        hyperJumpRequest.ColumnID = request.targetZoneId; 
        hyperJumpRequest.sendBroadcastMessage =request.sendBroadcastMessage == true ? true : false;
        hyperJumpRequest.projectEventCustomPayload = request.projectEventCustomPayload;
        hyperJumpRequest.projectId = request.projectId;

        system.enqueueJob(new MultipleHyperJumpAction(hyperJumpRequest, request));
    }
}