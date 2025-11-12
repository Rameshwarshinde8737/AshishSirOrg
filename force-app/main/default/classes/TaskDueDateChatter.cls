/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TaskDueDateChatter.cls
 * CLASS: TaskDueDateChatter     
 */
global with sharing class TaskDueDateChatter implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date activityDate = System.today();

        String query = 'SELECT Id, Priority, OwnerId, Subject, Status, ActivityDate, WhatId, Description FROM Task WHERE ActivityDate =: activityDate AND What.Type = \'leankor__KanbanCard__c\' AND IsDeleted = false ALL ROWS';
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<Task> scope){

        //Check CRUD / FLC behavior
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (!feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable()) {
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior

        try{
            if(scope.size() >0){
                // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
                Set<Id> assigneeIds = getAssigneeIds();
                List<FeedItem> postList =new List<FeedItem>();
                Set<String> kanbanIds=new Set<String>();
		        
		        // Create the user map
		        Map<Id,User> userMap;
		        
		        // Create the network member map.
		        Map<Id,Id> networkMemberMap = new Map<Id,Id>();
				List<Id> userIds = new List<Id>();
		        for(Task t : scope){
                    kanbanIds.add(t.WhatId);
                    userIds.add(t.OwnerId);
                }
                // Checking if the NetworkMember available in the org or not.
		        // If the communities are deactivated in the org then this object are unavailable.
		        Boolean isNetworkAvailable =  (Type.forName('Schema.NetworkMember')!=null);
		        if (isNetworkAvailable) {
		        	userMap = new Map<Id,User> ([Select Id, 
                                                        UserType 
                                                    From User 
                                                    Where Id IN: userIds 
                                                    Limit 9999]);
                    //leankor.OpenFeedItemRestriction.readNetworkMember(userIds, networkMemberMap);
                    List<Schema.DescribeSObjectResult> sObj = Schema.describeSObjects(new List<String>{(Type.forName('Schema.NetworkMember').getName())});
                    if (sObj.size()!=0 && sObj[0].isAccessible() && sObj[0].isQueryable())
			        {	
		            	readNetworkMember(userIds, networkMemberMap);
			        }
			    }
                
                List<leankor__KanbanCard__c> kanbanLst = [Select Id,
                                                                Name,
                                                                leankor__ValueStream__r.Name,
                                                                leankor__ProjectRoom__c,
                                                                leankor__ValueStream__c,
                                                                leankor__ValueStream__r.leankor__BoardType__c, 
                                                                leankor__ValueStream__r.leankor__IsTemplateBoard__c, 
                                                                leankor__ValueStream__r.leankor__ProjectRoom__c
                                                            From leankor__KanbanCard__c 
                                                            Where Id In: kanbanIds 
                                                                And IsDeleted = false
                                                                And leankor__ISRecordDeleted__c = false
                                                            Limit 49999];
                
                
                String baseUrl = 'https://' + DomainCreator.getOrgMyDomainHostname();
		 		String boardBaseUrl = baseUrl;
                 
                for(Task tsk : scope){     
                    if(tsk.Status != 'Completed'){
                        FeedItem post = new FeedItem();
                        if(assigneeIds.contains(tsk.OwnerId)) {
	                        post.ParentId = tsk.OwnerId;  
	                        // For standard user we don't have to provide network id in feedItem
			                 if (isNetworkAvailable && userMap!=null && userMap.containsKey(tsk.OwnerId) && userMap.get(tsk.OwnerId).UserType != 'Standard') {                            
			                    post.put('NetworkScope', networkMemberMap.get(tsk.OwnerId));
			                 }
                         
	                        post.Body = System.Label.leankor.TheTask+''+tsk.Subject+''+System.Label.leankor.IsOverdue; 
	                        if(kanbanLst.size()>0){  
	                            for(leankor__KanbanCard__c kanban:kanbanLst){
	                                if (tsk.WhatId == kanban.id && kanban.leankor__ValueStream__c != null && kanban.leankor__ValueStream__r.leankor__IsTemplateBoard__c == false && kanban.leankor__ValueStream__r.leankor__projectroom__c != null) {
	                                    PageReference pageRef;
	                                    if(kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Whiteboard'){
	                                        pageRef= new PageReference('/apex/VisualKanban');
	                                    }else if(kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board'){
	                                        pageRef= new PageReference('/apex/KanbanBoard');
	                                    }else if(kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View'){
	                                        pageRef= new PageReference('/apex/PortfolioView');
	                                    }
	                                    if(pageRef!=null)baseUrl +=pageRef.getUrl(); // condition added to prevent null pointer exception
	                                    post.Title =kanban.Name;
	                                    //23.08.2017 : provide projectName and Board Name and card Name for Email Alert
	                                    post.Body += '\n\n' + kanban.leankor__ProjectRoom__c + ' / ' + kanban.leankor__ValueStream__r.Name + ' / '+ kanban.Name;
                                    
	                                    post.LinkUrl =baseUrl+'?Id='+kanban.leankor__ValueStream__c+'&cardid='+kanban.Id;
	                                }
	                            }
	                        }

	                        postList.add(post);
	                    }
                    }
                    baseUrl = boardBaseUrl;
                }

                if (!postList.isEmpty()) {
                    //OpenFeedItemRestriction.createFeedItems(postList);
                    insert postList;
		        }
            }
        }catch (DmlException e){
            throw new TaskDueDateChatterException('ERROR:' + e.getMessage());
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
 
    global void finish(Database.BatchableContext BC) { 
        // Called when all batches execution completed
    }

    global class TaskDueDateChatterException extends Exception{}
    
    private static Set<Id> getAssigneeIds() {
        Set<Id> assigneeIds = new Set<Id>();
        try {
            for (PermissionSetAssignment assignment : [Select Id, 
                                                                AssigneeId
                                                            From PermissionSetAssignment
                                                            Where PermissionSet.NamespacePrefix = 'leankor']) {
                assigneeIds.add(assignment.AssigneeId);
            }
        } catch (Exception e) {
            System.debug('Error :'+e.getMessage());
        }
        return assigneeIds;
    }
}