/**
*Class : createUberBoard
*Description :  Batch Apex class for creating Plan Gantt in ProjectRoom after updating version from 1.188
*/

global with sharing class CreateUberBoard implements Database.Batchable<sObject>
{
     global Database.QueryLocator start(Database.BatchableContext BC)
     {
            String query = 'SELECT Id, Name, (SELECT Id, leankor__BoardType__c FROM leankor__ValueStreams__r WHERE leankor__boardType__c = \'UberBoard\' LIMIT 1) FROM leankor__ProjectRoom__c ';
            return Database.getQueryLocator(query);
     }
   
    global void execute(Database.BatchableContext BC, List<leankor__ProjectRoom__c> scope)
    {  
        //Check CRUD / FLC behavior   
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardTemplateBehaviour cardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        
        if (!valueStreamBehavior.isCreateable()
        ||  !cardTemplateBehaviour.isCreateable()){
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior
        
        List<leankor__ValueStream__c> boards = new List<leankor__ValueStream__c>();
        for(leankor__ProjectRoom__c RoomLog : scope)
        {
            if (RoomLog.leankor__ValueStreams__r.isEmpty())
            {
                boards.add(new leankor__ValueStream__c(leankor__BoardType__c = 'UberBoard', leankor__ProjectRoom__c = RoomLog.Id, Name = 'Plan Board(' + RoomLog .Name + ')'));
            }
        }
        if (!boards.isEmpty())
        {
            insert boards;
            //---- insert KBCardTemplate 
            List<leankor__KanbanCardTemplate__c> listKCT = new List<leankor__KanbanCardTemplate__c>();
            for (leankor__ValueStream__c board : boards)
            {    
                for(integer i=0 ; i <=5 ;i++)
                {
		            leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
		            leankor__JSONDefinition__c = '',
		            leankor__JSONData__c = '',
		            leankor__Width__c = 170,
		            leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
		            leankor__CSSLayout__c = '',
		            leankor__Color__c = '#bdbffc',
		            leankor__ValueStream__c = board.Id               
		            );
		            kct.Name = (i==0 ?'Default' :(i==1 ? 'HR' :(i==2?'Sales' :(i==3?'Marketing' :(i==4 ? 'Finance': 'Operations')))));
		            kct.leankor__Title__c =kct.Name;
		            listKCT.add(kct);
                }                      
            }
            if (!listKCT.isEmpty())
            {
                insert listKCT;
            }            
        }
    }
    global void finish(Database.BatchableContext BC)
    {
            String emailAddress = UserInfo.getUserEmail();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            string [] toaddress= New string[]{emailAddress};
            email.setSubject('Testing Apex Scheduler-Subject');
            email.setPlainTextBody('Testing Apex Scheduler-Body');
            email.setToAddresses(toaddress);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
    }
}