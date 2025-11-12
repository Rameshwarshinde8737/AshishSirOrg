global with sharing class IsRecordDeletedOfValueStream implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	//RS 23/4/2018 This batch should not update system board's leankor__isRecordDeleted__c field,otherwise System boards will be purged by PurgeSoftDeletedRecords batch.
    	//list<string> boards = new list<string>{'_System_PlanBoard','_System_Board','_System_DashBoard'};
        //String query = 'SELECT Id , leankor__ProjectRoom__c FROM leankor__ValueStream__c where Name Not In : boards'; 
        /*Modified by :Ashutosh
            01/09/2020 : 200k query modification. We are removing where clause from this query because its not selective and 'NOT IN' used for prevent only 3 records. 
                        We will manage this on execute method by using if condition. */
        String query = 'SELECT Id, Name, leankor__ProjectRoom__c FROM leankor__ValueStream__c'; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<leankor__ValueStream__c> boardList){
        //Check CRUD / FLC behavior   
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
		if (!valueStreamBehavior.isUpdateable()) {
            System.abortJob(BC.getJobId());
        }
		//Check CRUD / FLC behavior       
        
        Set<string> boards = new Set<string>{'_System_PlanBoard','_System_Board','_System_DashBoard'};

        for(leankor__ValueStream__c vs:boardList){
            if(boards.contains(vs.Name)){
                continue;
            }
			if(vs.leankor__ProjectRoom__c == null){
				vs.leankor__isRecordDeleted__c = true;
			}else{
				vs.leankor__isRecordDeleted__c = false;
			}			
        }
        try{        
            update boardList;
        }catch(Exception ex){
            //25/04/2023 : We are Throwing Exception
            throw new IsRecordDeletedOfValueStreamException('ERROR:' + ex.getMessage());
        }
    }  
    global void finish(Database.BatchableContext BC){}

    global class IsRecordDeletedOfValueStreamException extends Exception{}
}