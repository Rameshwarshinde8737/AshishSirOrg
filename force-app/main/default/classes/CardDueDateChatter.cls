/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: CardDueDateChatter.cls
 * CLASS: CardDueDateChatter    
 */
 
global with sharing class CardDueDateChatter implements Database.Batchable<sObject> {
    // This Method is for Getting Per Card Chatter Massage in Batchformate  
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date dt = System.today();
        String query = 'Select id,Name,leankor__KanbanCard__r.leankor__ValueStream__r.Name,leankor__KanbanCard__r.leankor__ProjectRoom__c,leankor__KanbanCard__r.id,leankor__KanbanCard__r.Name,leankor__KanbanCard__r.leankor__ValueStream__r.leankor__BoardType__c,leankor__KanbanCard__r.leankor__ValueStream__c,leankor__KanbanCard__r.leankor__PercentComplete2__c,leankor__KanbanCard__r.leankor__duedate__c,leankor__SubscriberID__c,leankor__cardpastduedate__c from leankor__Subscriber__c where leankor__KanbanCard__r.leankor__duedate__c =:dt and leankor__KanbanCard__r.leankor__ValueStream__c != null and leankor__SubscriberID__c != null and leankor__KanbanCard__r.leankor__ValueStream__r.leankor__projectroom__c != null';
        return Database.getQueryLocator(query);
    }
   
    // This(Execute Method) is for Getting Per Card Chatter Massage in Batchformate  
    global void execute(Database.BatchableContext BC, List<leankor__Subscriber__c> scope) {
        //Check CRUD / FLC behavior
        FeedItemBehaviour checkFeedItemBehaviour = new FeedItemBehaviour();
        UserBehaviour checkUserBehaviour = new userBehaviour();
        if (!checkFeedItemBehaviour.isAccessible() || 
            !checkFeedItemBehaviour.isCreateable() || 
            !checkUserBehaviour.isAccessible()) {
            //abort the job if no access
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior
        try {
            List<FeedItem> postList =new List<FeedItem>();
            Map<Id,User> userMap;
            // Create the network member map.
            Map<Id,Id> networkMemberMap = new Map<Id,Id>();

            // Checking if the NetworkMember available in the org or not.
            // If the communities are deactivated in the org then this object are unavailable.
            Boolean isNetworkAvailable = (Type.forName('Schema.NetworkMember') != null);
            if (isNetworkAvailable) {
                List<Id> userIds = new List<Id>();
                for(leankor__Subscriber__c card : scope){
                    userIds.add(card.leankor__SubscriberID__c);
                }
                
                userMap = new Map<Id,User> ([Select Id, 
                                                    UserType 
                                                From User 
                                                Where Id IN: userIds 
                                                Limit 9999]);
                List<Schema.DescribeSObjectResult> sObj = Schema.describeSObjects(new List<String>{(Type.forName('Schema.NetworkMember').getName())});
                if (sObj.size() != 0 && sObj[0].isAccessible() && sObj[0].isQueryable()) {	
                    readNetworkMember(userIds, networkMemberMap);
                }
            }
            String baseUrl= 'https://' + DomainCreator.getOrgMyDomainHostname();
            String boardBaseUrl = baseUrl;

            // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
            Set<Id> assigneeIds = getAssigneeIds();

            for (leankor__Subscriber__c card : scope) {
                PageReference pageRef;
                if (card.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__BoardType__c == 'Whiteboard') {
                    pageRef= new PageReference('/apex/VisualKanban');
                } else if (card.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board') {
                    pageRef= new PageReference('/apex/KanbanBoard');
                } else if (card.leankor__KanbanCard__r.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
                    pageRef= new PageReference('/apex/PortfolioView');
                } else {
                    pageRef= new PageReference('/');
                }
                baseUrl +=pageRef.getUrl(); 
                
                if (card.leankor__cardpastduedate__c == true && card.leankor__KanbanCard__r.leankor__PercentComplete2__c < 100) {
                    FeedItem post = new FeedItem();
                    if (assigneeIds.contains(card.leankor__SubscriberID__c)) {
                        post.ParentId = card.leankor__SubscriberID__c; 
                        // For standard user we don't have to provide network id in feedItem
                        if (isNetworkAvailable && userMap!=null && userMap.containsKey(card.leankor__SubscriberID__c) && userMap.get(card.leankor__SubscriberID__c).UserType != 'Standard') {                            
                            post.put('NetworkScope', networkMemberMap.get(card.leankor__SubscriberID__c));
                        } 
                        post.Title = card.leankor__KanbanCard__r.Name;    
                        
                        post.Body = System.Label.leankor.TheCard+''+card.leankor__KanbanCard__r.Name+''+System.Label.leankor.IsOverdue;
                        //23.08.2017 : provide projectName and Board Name for Email Alert
                        post.Body += '\n\n' + card.leankor__KanbanCard__r.leankor__ProjectRoom__c + ' / ' + card.leankor__KanbanCard__r.leankor__ValueStream__r.Name; 
                        
                        post.LinkUrl =baseUrl+'?id='+card.leankor__KanbanCard__r.leankor__ValueStream__c+'&cardid='+card.leankor__KanbanCard__r.id;
                        postList.add(post);
                    }
                }           
                baseUrl =  boardBaseUrl;
            }
        
	        if (!postList.isEmpty()) {
            	insert postList;
	        }
        } catch (DmlException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new CardDueDateChatterException('ERROR:' + ex.getMessage());
        }
    }
    public static void readNetworkMember(List<Id> userIds, Map<Id,Id> networkMemberMap){
    	for (sObject netMember: Database.query('SELECT Id, '+
    								'MemberId, NetworkId '+
    								'FROM NetworkMember '+
    								'WHERE MemberId IN: userIds '+
    								'and Network.Status = \'Live\' '+
    								'ORDER BY Network.LastModifiedDate DESC ')) {
            networkMemberMap.put((Id)netMember.get('MemberId'), (Id)netMember.get('NetworkId'));
        }
    }
    
    // This Finish Method For Batchformate  
    global void finish(Database.BatchableContext BC){}

    global class CardDueDateChatterException extends Exception{}
    
    private static Set<Id> getAssigneeIds() {
        Set<Id> assigneeIds = new Set<Id>();
        try{
            for (PermissionSetAssignment assignment : [Select Id, 
                                                            AssigneeId 
                                                        From PermissionSetAssignment
                                                        Where PermissionSet.NamespacePrefix = 'leankor']) {
                assigneeIds.add(assignment.AssigneeId);
            }
        } catch (Exception e) {
            System.debug('Error '+e.getMessage());
        }
        return assigneeIds;
    }
}