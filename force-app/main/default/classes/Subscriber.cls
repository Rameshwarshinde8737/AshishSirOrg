public with sharing class Subscriber {
    public List<leankor__Subscriber__c> getSubscribers(List<Id> workItemIds){
        return [Select Id, 
                        Name, 
                        leankor__KanbanCard__c, 
                        leankor__SubscriberId__c,
                        leankor__SubscriberKey__c,
                        leankor__SubscriberId__r.UserType,
                        leankor__Moved__c, 
                        leankor__PercentDone__c, 
                        leankor__CardPastDueDate__c,    
                        leankor__TaskPastDueDate__c, 
                        leankor__isTaskCompleted__c 
                    From leankor__Subscriber__c 
                    Where leankor__KanbanCard__c In :workItemIds
                    With Security_Enforced
                    Limit 10000]; 
    }

    public static List<leankor__Subscriber__c> upsertSubscribers(final List<leankor__Subscriber__c> subscribers) {
		//Check CRUD / FLC behavior   
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior();
		if (!subscriberBehavior.isCreateable() ||
            !subscriberBehavior.isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior 
		
		try{
			Schema.Sobjectfield subExternField = leankor__Subscriber__c.Fields.leankor__SubscriberKey__c;
            Database.upsert(subscribers, subExternField, true);
		}catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return subscribers;
	}
}