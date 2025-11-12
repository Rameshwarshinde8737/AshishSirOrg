global with sharing class UpdateRAPercentageComplete implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext info) { 
        String kb = 'Select Id, leankor__PercentComplete2__c, (Select Id, leankor__PercentCompleted__c, leankor__PercentAllocation__c, leankor__KanbanCard__c From leankor__ResourceAssignments__r) From leankor__KanbanCard__c Where (leankor__ValueStream__r.leankor__IsRecordDeleted__c = false Or leankor__IsRecordDeleted__c = false ) And Recordtype.Name =\'ActivityCard\' ';    
        return Database.getQueryLocator(kb);
    }     


    global void execute(Database.BatchableContext info, List<leankor__KanbanCard__c> scope) {
        //Check CRUD / FLC behavior
		ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
		if (!resourceAssignmentBehavior.isUpdateable()) {
			System.abortJob(info.getJobId());
		}
        //Check CRUD / FLC behavior
        
        /** First we find currupt data mean we are recalculate harvey ball status according RA percentCompleted field
            if calculated Percentage is not equal to activity/card's Harvey Ball status then we will update RA percentage
            otherwise will escape that activity's RA.                           
        */
        List<leankor__ResourceAssignment__c> updateList = new List<leankor__ResourceAssignment__c>();     

        for (leankor__KanbanCard__c kb:scope) {    
            Decimal totalAllocated = 0;
            Decimal totaKBCompleted = 0;
            Decimal raContributionToKB = 0;
            
            for (leankor__ResourceAssignment__c ra : kb.leankor__ResourceAssignments__r) {
                totalAllocated = totalAllocated + ra.leankor__PercentAllocation__c;
            }

            for (leankor__ResourceAssignment__c ra : kb.leankor__ResourceAssignments__r) {   
                raContributionToKB = raContributionToKB + ((ra.leankor__PercentCompleted__c == null ? 0 :  ra.leankor__PercentCompleted__c)* (ra.leankor__PercentAllocation__c  / (totalAllocated == 0 ? 1 : totalAllocated)));
                raContributionToKB = raContributionToKB.setScale(2);                            
            }   

            if (kb.leankor__PercentComplete2__c != raContributionToKB.round().intValue()) {
                for (leankor__ResourceAssignment__c ral :kb.leankor__ResourceAssignments__r) {
                    ral.leankor__PercentCompleted__c = kb.leankor__PercentComplete2__c ;
                    updateList.add(ral); 
                }         
            }       
        }     

        if (updateList.size() > 0) {
            update updateList ;
        }   
    }     
    
    
    global void finish(Database.BatchableContext info){

    }
}