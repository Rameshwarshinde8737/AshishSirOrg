public without sharing class MiniatureCardsQueueable implements Queueable {
    private  GanttTaskBoard.ActivityWrapper wrapper;
    
	public MiniatureCardsQueueable(GanttTaskBoard.ActivityWrapper wrapper) {
        this.wrapper = wrapper;
    }
	
    public void execute(QueueableContext context) {
		//Check CRUD / FLC behavior 
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!kanbanCardBehaviour.isUpdateable()) {
			System.abortJob(context.getJobId());
		}
		//Check CRUD / FLC behavior 

    	List<leankor__KanbanCard__c> miniatureCards = new List<leankor__KanbanCard__c>();
    	Map<String,List<String>> broadcastContentMap =  new Map<String,List<String>>();
		List<String> jsonDataList = new List<String>();
    	Set<String> vsIds = new Set<String>();
		String kanbanVerb ='OnHoldItemsFalse';
    	Map<Id,leankor__KanbanCard__c> parentItems = new Map<Id,leankor__KanbanCard__c>(wrapper.activity);
		/*
		*Modified By :Ashutosh Gour
		*Modification : Modification for making SOQL selective and remove negative selection.
		*/
		for (leankor__KanbanCard__c miniature : [Select Id, 
													leankor__ValueStream__c 
												From leankor__KanbanCard__c 
												Where leankor__ValueStreamCardLink__c In : parentItems.keySet() 
													And leankor__BoardType__c In('Kanban Board','Kanban Board','Portfolio View','Card Hierarchy','Plan Board','DashBoard')
												With Security_Enforced
												Limit 9999]) {
	        miniature.leankor__IsOnHold__c = wrapper.activity[0].leankor__IsOnHold__c;
	        miniatureCards.add(miniature);
	        vsIds.add(miniature.leankor__ValueStream__c);
	        jsonDataList = broadcastContentMap.containsKey(miniature.leankor__ValueStream__c) ? broadcastContentMap.get(miniature.leankor__ValueStream__c) : new List<String>();
	        jsonDataList.add(miniature.Id);
            broadcastContentMap.put(miniature.leankor__ValueStream__c, jsonDataList);
        }
        if (miniatureCards.size()>0 ) {
        	Update miniatureCards;
	        List<leankor__Dependency__c> dependencies = [Select Id	
	        											From leankor__Dependency__c 
	        											Where leankor__Predecessor__c In : miniatureCards 
	        												  And leankor__Predecessor__r.leankor__IsRecordDeleted__c = false
	        												  And leankor__Successor__r.leankor__IsRecordDeleted__c = false 
														With Security_Enforced
													  	Limit 1];
	    	if (!Test.isRunningTest() && dependencies.size()>0) {
        		System.enqueueJob(new SuccessorCardsQeueuable(miniatureCards,vsIds, wrapper.sessionID));
        	}
			 //Date :09/10/19 changes for onhold broadcast.
			if (wrapper.activity[0].leankor__IsOnHold__c == true) {
            	kanbanVerb='OnHoldItemsTrue';
        	}
        	leankor.GenericStreamingController.sendBroadcastForBulkRecords(kanbanVerb, broadcastContentMap, wrapper.sessionID);
        }
    }
}