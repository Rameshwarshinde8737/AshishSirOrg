/**
*Class : SetExternallyDependentOnCard
*Description :  Batch Apex class for update kanbancard with new field value leankor__IsExternallyDependent__c as true if card is externally Dependent
*/

global with sharing class SetExternallyDependentOnCard implements Database.Batchable<sObject> {
    
    private static Set<String> globaltempIds = new Set<String>(); 
    
    //make batch apex for updating leankor__IsExternallyDependent__c field as set true if card is External Dependent
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, leankor__Predecessor__r.Recordtype.name, leankor__Successor__r.Recordtype.name, leankor__Predecessor__c, leankor__Predecessor__r.leankor__ValueStream__c, leankor__Successor__r.leankor__ValueStream__c, leankor__Successor__c FROM leankor__Dependency__c WHERE leankor__Predecessor__r.leankor__ValueStream__r.leankor__BoardType__c  = \'UberBoard\' OR leankor__Successor__r.leankor__ValueStream__r.leankor__BoardType__c = \'UberBoard\'';
		
		return Database.getQueryLocator(query);
	}
	
    
    global void execute(Database.BatchableContext BC, List<leankor__Dependency__c> scope) {
        //Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!kanbanCardBehaviour.isUpdateable()) {
			System.abortJob(BC.getJobId());
		}
		//Check CRUD / FLC behavior

        Set<String> kanbanListIds = new Set<String>();  
		Set<String> folderkanbanListIds = new Set<String>();
        List<leankor__KanbanCard__c> finalkanbanList = new List<leankor__KanbanCard__c>();
        
        //looping for find kanban card Id which is External dependent means Two cards in diffrent project and dependent Each other
        for (leankor__Dependency__c d: scope) {            
            if (d.leankor__Predecessor__r.leankor__ValueStream__c != d.leankor__Successor__r.leankor__ValueStream__c) {
				//card recordtype is folder card than store to in another list to find out childs.
				if (d.leankor__Predecessor__r.Recordtype.name == 'foldercard') {
					folderkanbanListIds.add(d.leankor__Predecessor__c);					 
				}                           
				
				if (d.leankor__Successor__r.Recordtype.name == 'foldercard') {					
					folderkanbanListIds.add(d.leankor__Successor__c);				 
        		}
				
				kanbanListIds.add(d.leankor__Successor__c);
				kanbanListIds.add(d.leankor__Predecessor__c);		 
       		}
		}
		
		//if External dependent is folder card than we have to find child of that folder and update value as True of leankor__isExternalDependent__c.
        if (folderkanbanListIds.size() > 0) {
			kanbanListIds.addAll(getChildKanbanCard(folderkanbanListIds));
        }
         
		for (String kc : kanbanListIds) {
			leankor__KanbanCard__c card = new leankor__KanbanCard__c();
			card.Id = kc;
			card.leankor__isExternallyDependent__c = true;
			finalkanbanList.add(card);		
		}
		
        try {
           	if (finalkanbanList.size() > 0) { 
				update finalkanbanList;
			}
           	globaltempIds.clear();         
        } catch(Exception ex) {         
            throw new SetExternallyDependentOnCardException('ERROR:' + ex.getMessage());
        }
    }
 

    global void finish(Database.BatchableContext BC){
            
    }
	
	
    // Getting all childs of folders
    private static Set<String> getChildKanbanCard(Set<String> folderkanbanList) {
		Set<String> tempIds = new Set<String>();		

		for (leankor__KanbanCard__c pf : [Select Id, 
												Recordtype.Name, 
												leankor__valuestreamcardlink__c 
											From leankor__KanbanCard__c 
											Where leankor__valuestreamcardlink__c In :folderkanbanList
											With Security_Enforced]) {				
			if (pf.Recordtype.name == 'foldercard') { 
				tempIds.add(pf.Id); 
			}

			globaltempIds.add(pf.Id);
		}

		// folders having folders than again find out their childs		
		if (tempIds.size() > 0) {
			getChildKanbanCard(tempIds);
		} 

		return globaltempIds;
	}

	global class SetExternallyDependentOnCardException extends Exception{}
}