/**
* Class : UpdateRecordTypeforCard
* Description :  Batch Apex class for update kanbancard for recordtypeid as default activitycard after updating version from 1.188
*/
global with sharing class UpdateRecordTypeKC implements Database.Batchable<sObject> {
  
    global RecordType recordtypeobject;
   

    // Non parameterized constructor 
    global UpdateRecordTypeKC () {
        this.recordtypeobject = new RecordType();
        this.recordtypeobject = [Select Id,
                                            Name,
                                            SobjectType 
                                        From RecordType 
                                        Where SobjectType = 'leankor__KanbanCard__c' 
                                            And Name = 'ActivityCard' 
                                        Limit 1];  
    }
     

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id, RecordtypeId, leankor__ValueStream__c From leankor__KanbanCard__c Where leankor__ValueStream__c != null';
        //String query = 'SELECT Id, RecordtypeId, leankor__ValueStream__c FROM leankor__KanbanCard__c WHERE leankor__IsRecordDeleted__c = false AND leankor__Valuestream__r.leankor__IsRecordDeleted__c = false';
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<leankor__KanbanCard__c> scope) {
        List<leankor__KanbanCard__c> kanbanList = new List<leankor__KanbanCard__c>();    
        
        //Check CRUD / FLC behavior
  		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
  		if (!kanbanCardBehaviour.isUpdateable()) {
            System.abortJob(BC.getJobId());
        }
		//Check CRUD / FLC behavior
        
        for(leankor__kanbancard__c Card:scope) {            
            Card.RecordtypeId = recordtypeobject.Id;
            kanbanList.add(Card);               
        }

        try {
            update kanbanList;         
        } catch(Exception ex) {
            // code for to send email to support@leankor.com with the ORG ID
            throw new UpdateRecordTypeKCException('ERROR:' + ex.getMessage());
        }
    }  


    global void finish(Database.BatchableContext BC) {
        String emailAddress = UserInfo.getUserEmail();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        string [] toaddress= New string[]{emailAddress};
        email.setSubject('Testing Apex Scheduler-Subject');
        email.setPlainTextBody('Testing Apex Scheduler-Body');
        email.setToAddresses(toaddress);
        Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});    
    }
    
    global class UpdateRecordTypeKCException extends Exception{}
}