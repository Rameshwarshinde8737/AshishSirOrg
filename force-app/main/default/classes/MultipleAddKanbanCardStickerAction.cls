/**************************************************************************
 * Author     : Reynald Ocampo
 * Description: Add KanbanCard stickers
 **************************************************************************/ 
global with sharing class MultipleAddKanbanCardStickerAction implements System.Queueable {
    private final static Integer MAXIMUM_RECORD_SIZE = 10000;
    private final static Integer LIMIT_QUEUEABLE_JOBS = Limits.getLimitQueueableJobs();
    private MultipleAddKanbanCardStickerRequest addKanbanCardStickerRequest;

    // parameterized constructor
    public MultipleAddKanbanCardStickerAction(MultipleAddKanbanCardStickerRequest addKanbanCardStickerRequest) {
        this.addKanbanCardStickerRequest = addKanbanCardStickerRequest;
    }


    global class MultipleAddKanbanCardStickerRequest {   
        @InvocableVariable(label = 'Add KanbanCard sObjects' description = 'List of KanbanCard sObjects to add stickers.' required = true)
        global List<leankor__KanbanCard__c> kanbanCardRequest;

        @InvocableVariable(label = 'Add Sticker sObjects' description = 'List of Sticker sObjects to add.' required = true)
        global List<leankor__Sticker__c> stickerRequest;

        @InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
        global Boolean sendBroadcastMessage = false;

        @InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		global String projectId = '';

        @InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
		global String projectEventCustomPayload = '';
    }


    @InvocableMethod
    global static void addKanbanCardStickerProcess(List<MultipleAddKanbanCardStickerRequest> kanbanCardStickerStickerRequests) {
		// Variable used to check MAXIMUM_RECORD_SIZE
		Boolean isMaximumRecordSizeExceeded = false;

		/*	Iterating over the loop to check MAXIMUM_RECORD_SIZE for all requests, 
			if one of the requests exceeds the MAXIMUM_RECORD_SIZE then all requests will not be processed (meaning ALL or NOTHING).*/
		for (MultipleAddKanbanCardStickerRequest request : kanbanCardStickerStickerRequests) {
			if (request.kanbanCardRequest.size() * request.stickerRequest.size() > MAXIMUM_RECORD_SIZE) {
				isMaximumRecordSizeExceeded = true;
				break;
			}
		}

        // If any request does not exceed MAXIMUM_RECORD_SIZE then processed to next.
		if (isMaximumRecordSizeExceeded) {
            throw new Util.LeanException('Error: One of the requests has exceeded the size limit of ' + MAXIMUM_RECORD_SIZE + '. No request will be processed.');
        } else {
            Integer totalRequests = kanbanCardStickerStickerRequests.size();
			Integer totalProcessedRequests = 0;

            for (MultipleAddKanbanCardStickerRequest request : kanbanCardStickerStickerRequests) {
                // Queueable job limit not exceeded then doing queueable, if Queueable job limit exceeded then will ignore remaining requests.
                if (Limits.getQueueableJobs() < LIMIT_QUEUEABLE_JOBS) {
                    System.enqueueJob(new MultipleAddKanbanCardStickerAction(request));
                    totalProcessedRequests++;
                } else {
					throw new Util.LeanException('Error: Too many queueable jobs are being added to the queue. Only ' + totalProcessedRequests + ' of ' + totalRequests + ' added to the queue.');
				}
            }
		}
    }


    global void execute(QueueableContext queueableContext) {
        KanbanCardSticker.createKanbanCardStickers(addKanbanCardStickerRequest);
    }    
}