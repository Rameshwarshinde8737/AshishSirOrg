/**************************************************************************
 	* Company : Leankor
 	* Description: Clone Multiple KanbanCard
 	* Usage	  : Use to Clone bulk KanbanCard through sObject request.
 	* None       : 
 **************************************************************************/ 
 
global with sharing class MultipleCloneKanbanCardAction implements System.Queueable {	    

    // Maximum Record Limit for MultipleCreateKanbanCardAction API.
    private final static Integer MAXIMUM_RECORD_SIZE = 2000;
    // Limit Queueable Jobs.
	private final static Integer LIMIT_QUEUEABLE_JOBS = Limits.getLimitQueueableJobs();

    private KanbanController.MCHyperJumpLog cloneCardRequest;
    private List<KanbanController.MCHyperJumpLog> cloneCardRequests;
    // This variable will manage calling of queueables in execute method, if true then will call for create required records and if false then will create remaining records for Kanaban cards. 
    private Boolean isFirstCallToClone = false;
	public static List<RealTimeController.ZoneKanbanAction> zoneKanbanActions = new List<RealTimeController.ZoneKanbanAction>();
	public List<RealTimeController.ZoneKanbanAction> zoneKanbanActionsForSecondCall = new List<RealTimeController.ZoneKanbanAction>();
    private MultipleCloneKanbanCardRequest request;

    global class MultipleCloneKanbanCardRequest {
        @InvocableVariable(label = 'List of KanbanCard sObjects' description = 'List of KanbanCard records to clone.' required=true)
        global List<leankor__KanbanCard__c> kanbanCardRequests = new List<leankor__KanbanCard__c> ();
        @InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
        global Boolean sendBroadcastMessage;
        @InvocableVariable(label = 'Project Board Id' description = 'Project board id to place the cloned records.' required=true)
        global String targetBoardId;
        @InvocableVariable(label = 'Zone Id' description = 'Zone id to place the cloned records.')
        global String targetZoneId;
        @InvocableVariable(label = 'Category Id' description = 'Category id of the cloned records.')
        global String targetCategoryId;
        @InvocableVariable(label = 'Project Board Id To Link' description = 'Project board id to link the cloned records.')
        global String targetLinkBoardId;
        @InvocableVariable(label = 'Card Id To Link' description = 'Card id to link the cloned records.')
        global String targetLinkCardId;
        @InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
        global String projectEventCustomPayload;
        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId;
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		global Boolean generateWorkBreakdownStructure = false;
    }        

    
    public MultipleCloneKanbanCardAction(List<KanbanController.MCHyperJumpLog> cloneCardRequests) {
        this.cloneCardRequests = cloneCardRequests;
    }


    public MultipleCloneKanbanCardAction(KanbanController.MCHyperJumpLog cloneCardRequest, Boolean isFirstCallToClone, MultipleCloneKanbanCardRequest request) {
        this.request = request;
        this.isFirstCallToClone = isFirstCallToClone;
        this.cloneCardRequest = cloneCardRequest;
    }


    // Parameterized Constructor to initialize remaining records to second queueable  call. 
	public MultipleCloneKanbanCardAction(List<RealTimeController.ZoneKanbanAction> zoneKanbanActions) {
        this.request = request;
	}

    // Parameterized Constructor to initialize remaining records to second queueable  call. 
	public MultipleCloneKanbanCardAction(List<RealTimeController.ZoneKanbanAction> zoneKanbanActions, MultipleCloneKanbanCardRequest request) {
        this.request = request;
		this.zoneKanbanActionsForSecondCall = zoneKanbanActions;
	}

/*
    @InvocableMethod
    global static void cloneKanbanCardProcess(List<MultipleCloneKanbanCardRequest> kanbanCardRequests) {
        Set<String> kanbanCardIDs = new Set<String>();
        for(MultipleCloneKanbanCardRequest request : kanbanCardRequests) {
            KanbanController.MCHyperJumpLog cloneCardRequest = new KanbanController.MCHyperJumpLog();
            for(leankor__KanbanCard__c kanbanCard : request.kanbanCardRequests) {
                kanbanCardIDs.add(kanbanCard.Id);
            }
            cloneCardRequest.CardIDs = new List<String>(kanbanCardIDs);
            cloneCardRequest.IsClone = true;
            cloneCardRequest.TargetVSID = request.targetBoardId;
            cloneCardRequest.DefaultCardtemplateID = request.targetCategoryId;
            cloneCardRequest.LinkVSID = request.targetLinkBoardId;
            cloneCardRequest.LinkCardID = request.targetLinkCardId;
            cloneCardRequest.ColumnID = request.targetZoneId; 
            cloneCardRequest.sendBroadcastMessage = request.sendBroadcastMessage == true ? true : false;
            cloneCardRequest.projectEventCustomPayload = request.projectEventCustomPayload; 
            cloneCardRequest.projectId = request.projectId; 
            
            if(kanbanCardIDs.size() <= MAXIMUM_RECORD_SIZE){
                system.enqueueJob(new MultipleCloneKanbanCardAction(cloneCardRequest, true));
            }
            else{
                throw new Util.LeanException('Error : Maximum Record Limit Exceeded');
            }
        }
    }
*/ 
    
    @InvocableMethod
    global static void cloneKanbanCardProcess(List<MultipleCloneKanbanCardRequest> kanbanCardRequests) {
		// Variable used to check MAXIMUM_RECORD_SIZE
		Boolean isMaximumRecordSizeExceeded = false;

		/*	Iterating over the loop to check MAXIMUM_RECORD_SIZE for all requests, 
			if one of the requests exceeds the MAXIMUM_RECORD_SIZE then all requests will not be processed (meaning ALL or NOTHING).*/
		for (MultipleCloneKanbanCardRequest request : kanbanCardRequests) {
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

            for (MultipleCloneKanbanCardRequest request : kanbanCardRequests) {

                // Queueable job limit not exceeded then doing queueable, if Queueable job limit exceeded then will ignore remaining requests. 
                if (Limits.getQueueableJobs() < LIMIT_QUEUEABLE_JOBS) {
                    cloneKanbanCards(request);
                    totalProcessedRequests++;
                } else {
					throw new Util.LeanException('Error: Too many queueable jobs are being added to the queue. Only ' + totalProcessedRequests + ' of ' + totalRequests + ' added to the queue.');
                }
            }
		}  
    }

    global void execute(QueueableContext queueableContext) {  
        //04/April/2023 : We have added new variable for Hybrid constraint while Cline the card with updating links. 
        KanbanController.isCalledFromMultipleAPI = true;
        if (isFirstCallToClone) {
            if (KanbanController.allMCCardsHyperJump(cloneCardRequest) != null && !Test.isRunningTest()) {
                System.enqueueJob(new MultipleCloneKanbanCardAction(zoneKanbanActions, this.request));
            }
        } else {
            if (this.request.generateWorkBreakdownStructure == true) {
                if (String.isNotBlank(this.request.targetBoardId)) {
                    CreateKanbanCardsQueueable.updateProjectWBS(new Set<String>{this.request.targetBoardId});
                }
            }
            createRemainingRecords(this.zoneKanbanActionsForSecondCall);       
        }
    }


    // Method for Creating remaining records after cloning cards.
    @TestVisible
    private static void createRemainingRecords(List<RealTimeController.ZoneKanbanAction> zoneKanbanActions) {
		// Perform long-running code
		RealTimeController.enterTheZoneBulkify(zoneKanbanActions);
	}

    public static void cloneKanbanCards(MultipleCloneKanbanCardRequest request) {
        KanbanController.MCHyperJumpLog cloneCardRequest = new KanbanController.MCHyperJumpLog();
        Set<String> kanbanCardIDs = new Set<String>();

        for (leankor__KanbanCard__c kanbanCard : request.kanbanCardRequests) {
            kanbanCardIDs.add(kanbanCard.Id);
        }
        cloneCardRequest.CardIDs = new List<String>(kanbanCardIDs);
        //Clear out full sObject list to reduce serialized memory size because We are not using any another places of this kanbanCardRequests
        request.kanbanCardRequests = new List<leankor__KanbanCard__c>();
        cloneCardRequest.IsClone = true;
        cloneCardRequest.TargetVSID = request.targetBoardId;
        // 01 July 2022 : Changes to make a consistent MultipleClone API with multiple Clone cards from UI(there is inconsistency with category). 
        List<leankor__KanbanCardTemplate__c> valueStreamCategories = RealTimeController.getKanbanCardTemplates(request.targetBoardId);
        cloneCardRequest.DefaultCardtemplateID = request.targetCategoryId != null ? request.targetCategoryId : valueStreamCategories[0].Id;
        //cloneCardRequest.DefaultCardtemplateID = request.targetCategoryId;
        cloneCardRequest.LinkVSID = request.targetLinkBoardId;
        cloneCardRequest.LinkCardID = request.targetLinkCardId;
        cloneCardRequest.ColumnID = request.targetZoneId; 
        cloneCardRequest.sendBroadcastMessage = request.sendBroadcastMessage == true ? true : false;
        cloneCardRequest.projectEventCustomPayload = request.projectEventCustomPayload; 
        cloneCardRequest.projectId = request.projectId; 
        System.enqueueJob(new MultipleCloneKanbanCardAction(cloneCardRequest, true, request));
    }
}