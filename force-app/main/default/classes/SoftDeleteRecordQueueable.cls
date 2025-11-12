/**
 * Company : Leankor
 * FILE  : SoftDeleteRecordQueueable.cls
 * CLASS : SoftDeleteRecordQueueable
 * USAGE : Update ValueStream and KanbanCards Records.
 */
public with sharing class SoftDeleteRecordQueueable  implements Queueable{

    public List<String> projectRoomIds = new List<String>();
    
    public SoftDeleteRecordQueueable(List<String> projectRoomIds) {       
        this.projectRoomIds = projectRoomIds;
    }

    public void execute(QueueableContext context) {

        List<leankor__ValueStream__c> valueStreamList = [Select Id,
                                                                leankor__isRecordDeleted__c 
                                                           From leankor__ValueStream__c 
                                                           Where leankor__ProjectRoom__c In :projectRoomIds 
                                                                 And leankor__isRecordDeleted__c = false
                                                           Limit :getQueryRowsCount()];

            List<String> valueStreamIdList = new List<String>();
            
            for (leankor__ValueStream__c valueStream  : valueStreamList) {
                valueStream.leankor__isRecordDeleted__c = true;
                valueStreamIdList.add(valueStream.Id);
            }

            update valueStreamList; 
            
            if (getQueryRowsCount() > 0) {
                List<leankor__kanbanCard__c> kanbanCardList = [Select Id,
                                                                      leankor__isRecordDeleted__c
                                                                 From leankor__KanbanCard__c
                                                                 Where (leankor__ValueStream__c In :valueStreamIdList  
                                                                       Or leankor__ValueStream__r.leankor__isRecordDeleted__c = true)
                                                                       And leankor__isRecordDeleted__c = false 
                                                                       And leankor__Valuestream__r.leankor__projectroom__c = :projectRoomIds
                                                                 Limit :getQueryRowsCount()];

                for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {
                    kanbanCard.leankor__isRecordDeleted__c = true;
                } 

            update kanbanCardList;

            }
        
            List<leankor__ValueStream__c> remainingValueStreams  = [Select Id,
                                                                           leankor__isRecordDeleted__c
                                                                      From leankor__ValueStream__c 
                                                                      Where leankor__ProjectRoom__c In :projectRoomIds 
                                                                            And leankor__isRecordDeleted__c = false
                                                                      Limit 1];

            Integer remainingKanbanCards =  [Select count()
                                                From leankor__KanbanCard__c 
                                                Where (leankor__ValueStream__c In :valueStreamIdList 
                                                     Or leankor__ValueStream__c In :remainingValueStreams
                                                     Or leankor__ValueStream__r.leankor__isRecordDeleted__c = true)
                                                     And leankor__isRecordDeleted__c = false
                                                     And leankor__Valuestream__r.leankor__projectroom__c = :projectRoomIds
                                                Limit 1];
                                                    
													
            if (remainingValueStreams.size() > 0 || remainingKanbanCards > 0) {
                
			    if(!Test.isRunningTest()) {
				
                System.enqueueJob(new SoftDeleteRecordQueueable(this.projectRoomIds));
				
              }
            }
    }

    private static Integer getQueryRowsCount() {
		/*If we perform dml operation on 9999 records then dmlRow count will be 10000 and in case of exception 
         rollback performed then it will count one dml row means total 10001.then exception occurs for dml rows 10001.
         So that is why we have used limit counter 9998 */
		return 9998 - Limits.getQueryRows();
	}	
}