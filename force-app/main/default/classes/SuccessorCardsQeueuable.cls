public without sharing class SuccessorCardsQeueuable implements Queueable {
    private Set<String> valueStreamIds;
    private List<leankor__KanbanCard__c> predecessors;
    private  String sessionID;
    private Boolean isFlow =false;
    private Set<Id> recordIds;
    public SuccessorCardsQeueuable(List<leankor__KanbanCard__c> predecessors, Set<String> valueStreamIds, String sessionID) {
        this.predecessors = predecessors;
        this.valueStreamIds = valueStreamIds;
        this.sessionID = sessionID;
    }
    public SuccessorCardsQeueuable(List<leankor__KanbanCard__c> predecessors, Set<String> valueStreamIds, String sessionID, Boolean isFlow) {
        this.predecessors = predecessors;
        this.valueStreamIds = valueStreamIds;
        this.sessionID = sessionID;
        this.isFlow = isFlow;
    }
     
    public void execute(QueueableContext context) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isUpdateable()) {
            System.abortJob(context.getJobId());
        }
        //Check CRUD / FLC behavior

    	List<leankor__KanbanCard__c> successors = new List<leankor__KanbanCard__c>();
    	Map<String,List<String>> broadcastContentMap =  new Map<String,List<String>>();
		List<String> jsonDataList = new List<String>();
        String kanbanVerb='OnHoldItemsFalse';
		//Get all affected successors
        recordIds = getSuccessors();

        // Tilak Raj Mahale: 24.08.2020 - Changes for removing NOT IN clause from the Query
        Set<Id> forRemoveNotInClauseFromQuery = new Set<Id>();
        forRemoveNotInClauseFromQuery.addAll(recordIds);

		// If method is called from API and successor have FolderCard then find its child items too
        if(isFlow){
            List<leankor__KanbanCard__c> folders = [SELECT 
                                                        Id, 
                                                        RecordType.Name, 
                                                        leankor__IsOnHold__c, 
                                                        leankor__ValueStreamCardLink__c 
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE leankor__BoardType__c = 'Uberboard' 
                                                        AND Id IN: recordIds  
                                                        AND RecordType.name = 'FolderCard' 
                                                    LIMIT 9999];
            
            if(folders.size()>0){
                List<leankor__KanbanCard__c> linkedActivities = new List<leankor__KanbanCard__c>();

                for (leankor__KanbanCard__c subItems : [SELECT 
                                                            Id, 
                                                            RecordType.Name, 
                                                            leankor__IsOnHold__c, 
                                                            leankor__ValueStreamCardLink__c  
                                                        FROM leankor__KanbanCard__c 
                                                        WHERE leankor__BoardType__c ='Uberboard' 
                                                            //AND IN not in : recordIds 
                                                            AND leankor__ValueStream__c IN : valueStreamIds 
                                                        LIMIT 29999]) {

                    if (subItems.leankor__ValueStreamCardLink__c != null && (!forRemoveNotInClauseFromQuery.contains(subItems.Id))) {
                        linkedActivities.add(subItems);
                    }
                }                                       
                for(leankor__KanbanCard__c folder: folders){
                    Map<String,List<leankor__KanbanCard__c>> mapOfKanbanCard=new Map<String,List<leankor__KanbanCard__c>>();
                    mapOfKanbanCard.put(folder.Id,linkedActivities);
                    childActivity(folder.Id,predecessors[0].leankor__IsOnHold__c,mapOfKanbanCard);
                }
            }
        }
        
        for(Id recordId : recordIds){
            //prepare kanbanCard instance for updation 
        	successors.add(new leankor__KanbanCard__c(Id=recordId, leankor__IsOnHold__c=predecessors[0].leankor__IsOnHold__c));
        	jsonDataList.add(recordId);
        }
        if(successors.size()>0){
        	update successors;
            
            // Prepare data for broadcast according to ValueStream
            for (AggregateResult kb : [SELECT leankor__ValueStream__c vs FROM leankor__KanbanCard__c WHERE Id IN: jsonDataList GROUP BY leankor__ValueStream__c]) {
          broadcastContentMap.put((String)kb.get('vs'), jsonDataList);      
        }
            
            // Date:09.10.2019 - Changes for onhold broadcast.
        if(predecessors[0].leankor__IsOnHold__c==true){
            kanbanVerb='OnHoldItemsTrue';
        }
        //Send broadcast of affected items (both GS & PT)
        leankor.GenericStreamingController.sendBroadcastForBulkRecords(kanbanVerb, broadcastContentMap, sessionID);
        }
    }
    
    //This method will return all affected successor recordIds
    public Set<Id> getSuccessors(){
    	Map<Id,leankor__KanbanCard__c> predcessorMap = new Map<Id,leankor__KanbanCard__c>(predecessors); 
        List<leankor__Dependency__c> dependencies = [Select 
                                                        leankor__Predecessor__c, 
                                                        leankor__Successor__c,
    	 												 leankor__Successor__r.leankor__ValueStreamCardLink__c	
                                                    From leankor__Dependency__c 
        											Where leankor__ValueStream__c In :valueStreamIds 
        												And leankor__Predecessor__r.leankor__IsRecordDeleted__c = false
        												And leankor__Successor__r.leankor__IsRecordDeleted__c = false 
                                                    With Security_Enforced
        											Limit 9999];
		Set<Id> predIds = predcessorMap.keySet();        											
		return  GanttTaskBoard.getAllDependentCardIds(dependencies,predIds , predcessorMap, new Set<Id>(predIds));
    }
    

	//If FolderCard is insuccessors then find child Items
    public void childActivity(String kbId, Boolean isonHold, Map<String,List<leankor__KanbanCard__c>> mapOfkanbanCards){                        
     List<leankor__KanbanCard__c> kanbanList=mapOfkanbanCards.get(kbId);
     for(leankor__KanbanCard__c kb : mapOfkanbanCards.get(kbId)){
        if(kbId.equals(kb.leankor__ValueStreamCardLink__c)){
            if(kb.RecordType.Name=='FolderCard'){
                recordIds.add(kb.id);                  
                Map<String,List<leankor__KanbanCard__c>> kbmap =new  Map<String,List<leankor__KanbanCard__c>>();
                kbmap.put(kb.Id,kanbanList);
                childActivity(kb.Id,isonHold,kbmap);
            }else {
                recordIds.add(kb.Id);   
            }
        }
     } 
    } 
}