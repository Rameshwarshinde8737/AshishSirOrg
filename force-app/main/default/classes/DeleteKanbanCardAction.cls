/**************************************************************************
	* Company     : Leankor
 	* Description : This API used remove KanbanCards records from the Board.
 	* Usage	      : This API used remove KanbanCards records from the Board.
 	* None        : 
 **************************************************************************/ 

global with sharing class DeleteKanbanCardAction {
    @InvocableMethod
    global static List<kanbanCardResult> deleteKanbanCardProcess(List<KanbanCardRequest> requests) {
        return deleteKanbanCards(requests);
    }

    global class KanbanCardRequest {
        @InvocableVariable(label = 'Kanban Card List' description = 'List of Kanban Card as Input' required = true)
       	global List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();  	  
		@InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		global Boolean generateWorkBreakdownStructure = false;              
    }
    
    global class KanbanCardResult{    
        @InvocableVariable(label = 'List of deleted Kanban Cards' description = 'List of deleted Kanban Cards')
        global List<Id> kanbanCardIds;      
    }

    private static List<KanbanCardResult> deleteKanbanCards(List<KanbanCardRequest> requests) {
		Boolean generateWorkBreakdownStructure = false;
    	//Collect kanban cards
    	List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
    	for (KanbanCardRequest request : requests) {
    		kanbanCards.addAll(request.kanbanCards);
			generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;
    	}

    	//Collect kanban card ids
    	/*Set<Id> setKanbanCardIds = new Set<Id>();
    	for(leankor__KanbanCard__c kanbanCard : kanbanCards) {
    		setKanbanCardIds.add(kanbanCard.Id);
    	}*/

    	//Convert to set
    	//List<Id> kanbanCardIds = new List<Id>(setKanbanCardIds);


    	//Collect kanban card GUIDs
    	Set<String> setKanbanCardGuids = new Set<String>();
    	for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
    		setKanbanCardGuids.add(kanbanCard.leankor__GUID__c);
    	}

    	//Convert to set
    	List<String> kanbanCardGuids = new List<String>(setKanbanCardGuids);

    	//Soft delete records
    	String jsonIds = '';
    	try {
			Set<String> valueStreamIds = new Set<String>();
			if (generateWorkBreakdownStructure) {

				for (leankor__KanbanCard__c kanbanCard : [Select leankor__Valuestream__c
                                                                    From leankor__KanbanCard__c 
                                                                    Where (Id In :kanbanCardGuids
                                                                        Or leankor__GUID__c In :kanbanCardGuids)
																		And leankor__IsRecordDeleted__c = false
																		And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                                    Limit 10000]) {
		
					valueStreamIds.add(kanbanCard.leankor__ValueStream__c);
				}
			} 

    		jsonIds = realTimeController.removeKanbanCard(kanbanCardGuids);

			if (!valueStreamIds.isEmpty()) {
				CreateKanbanCardsQueueable.updateProjectWBS(valueStreamIds);
			}
			
    	} catch (Exception e) {
    		throw e;
    	}
    	//Set return object
    	List<Id> kanbanCardIds = (List<Id>)System.JSON.deserialize(jsonIds, List<Id>.class);
    	KanbanCardResult result = new KanbanCardResult();
    	result.kanbanCardIds = kanbanCardIds;
    	List<KanbanCardResult> results = new List<KanbanCardResult>();
    	results.add(result);

    	return results;
    } 
}