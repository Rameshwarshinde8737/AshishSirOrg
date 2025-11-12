/**
 * This class used to perform CRUD opeation on FeedItem in without sharing environment.
 */
public without sharing class OpenFeedItemRestriction {
    
    public OpenFeedItemRestriction() {

    }


    public static List<FeedItem> createFeedItems(List<FeedItem> feedItems) {
        //Check CRUD / FLC behavior
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (!feedItemBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        try {
            //Database.insert(feedItems);
            //08/Sep/2023 :We are adding false in DB method because we were facing issue while creating a card and while creating card assign card to customer user.
            Database.insert(feedItems, false);
        } catch (Exception ex) {
            throw new GanttTaskBoard.LeanException('Insufficient privileges to change the ownership of this record. Please contact your Admin'); 
        }

        return feedItems;
    }


    public static List<FeedItem> updateFeedItems(List<FeedItem> feedItems) {
        //Check CRUD / FLC behavior
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (!feedItemBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        try {
            //Database.update(feedItems);
            //08/Sep/2023 :We are adding false in DB method because we were facing issue while updating a card and while updating card assign card to customer user.
            Database.update(feedItems, false);
        } catch (DmlException ex) {
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage()); 
        }
        
        return feedItems;
    }

    // Changes : Ramanand - 06/11/2020 : DML operation Delete not allowed on FeedItem so commenting this method.
    /*
    public static Boolean deleteFeedItems(List<FeedItem> feedItems) {
        //Check CRUD / FLC behavior
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (
            !feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isDeletable()
        ) {
            return false;
        }
        //Check CRUD / FLC behavior

        try {
            Database.delete(feedItems);
        } catch (Exception ex) {
            System.debug('Error: While deleting feed items at deleteFeedItems '+ex.getmessage());
            throw new GanttTaskBoard.LeanException('Error : '+ex.getmessage()); 
        }

        return true;
    } */


    public static void readNetworkMember(List<Id> userIds, Map<Id,Id> networkMemberMap) {
    	for (sObject netMember: Database.query('SELECT Id, '+
    								'MemberId, NetworkId '+
    								'FROM NetworkMember '+
    								'WHERE MemberId IN: userIds '+
    								'and Network.Status = \'Live\' '+
    								'ORDER BY Network.LastModifiedDate DESC ')) {
            networkMemberMap.put((Id)netMember.get('MemberId'), (Id)netMember.get('NetworkId'));
        }
    }


    public static String getNetworkUrl(String networkId, String baseUrl) {
    	for (sObject tempNetwork : Database.query('Select Id, UrlPathPrefix from Network where id = : networkId')) {
			if (tempNetwork.get('UrlPathPrefix') != null) {            
                baseUrl =baseUrl+'/'+tempNetwork.get('UrlPathPrefix');
            }
        }
        
		return baseUrl;
    }

    public static List<EntitySubscription> readEntitySubscription(Set<String> cardIds, Set<String> userIds) {
        String networkId = String.isBlank(Network.getNetworkId()) ? '' : 'NetworkId, ';
        List<EntitySubscription> entitySubscriptionList = Database.query('Select Id, ParentID, ' 
                                                      + networkId 
                                                      + 'SubscriberId From EntitySubscription Where ParentId In :cardIds And SubscriberId In :userIds Limit 1000');
        return entitySubscriptionList;
    }

    public static void createChatterFeed(List<leankor__KanbanCard__c> kanbanList, String kanbanVerb) {
        //Check CRUD / FLC behavior
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();
        if (!entitySubscriptionBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String currentUser = UserInfo.getName();
        List<FeedItem> feedItems = new List<FeedItem>();
        List<EntitySubscription> ESList = new List<EntitySubscription>();
        List<EntitySubscription> ESList2 = new List<EntitySubscription>();
        List<sObject> ESsobjectList = new List<EntitySubscription>();
        List<leankor__Subscriber__c> subscribers = new List<leankor__Subscriber__c>();
        
        if (kanbanVerb == 'CreateKanbanCard' && FeedItem.sObjectType.getDescribe().isCreateable()) {
            // Create the user map
            Map<Id, User> userMap;
            // Create the network member map.
            Map<Id, Id> networkMemberMap = new Map<Id, Id>();
    
            // Checking if the NetworkMember available in the org or not.
            // If the communities are deactivated in the org then this object are unavailable.
            Boolean isNetworkAvailable =  (Type.forName('Schema.NetworkMember') != null);
            String networkId = Network.getNetworkId();
            if (isNetworkAvailable) {
                List<Id> userIds = new List<Id>();
                for (leankor__KanbanCard__c kanban: kanbanList) {
                    userIds.add(kanban.OwnerID);
                }
                
                userMap = new Map<Id,User> ([SELECT Id, UserType FROM User WHERE Id IN: userIds LIMIT 9999]);	
                leankor.OpenFeedItemRestriction.readNetworkMember(userIds, networkMemberMap);
            }

            String orgBaseURL = 'https://' + DomainCreator.getOrgMyDomainHostname()
            ;
            for (leankor__KanbanCard__c kanban: kanbanList) {
                if (kanban.leankor__TemplateBoard__c == true && kanban.leankor__MasterContainer__r.leankor__Type__c == 'Template') {
                    // No need to send chatter in this case.
                    continue;
                }

                FeedItem Post = new FeedItem();
                Post.ParentID = kanban.OwnerID;
                Post.Title = kanban.Name;
                // For standard user we don't have to provide network id in feedItem
                if (isNetworkAvailable && userMap!=null && userMap.containsKey(kanban.OwnerID) && userMap.get(kanban.OwnerID).UserType != 'Standard') {                            
                    post.put('NetworkScope', networkMemberMap.get(kanban.OwnerID));
                }
                //For chatter post visibility for all users from community  
                if (String.isNotBlank(networkId)) {
                    post.put('Visibility', 'AllUsers');
                }
                if (kanban.RecordType.Name == 'MileStoneCard') {
                    Post.Body = currentUser + ' has assigned you as owner of Milestone "' + Post.Title + '". Click this link to go to the project board. '+'\n\n'+ kanban.leankor__ProjectRoom__c +' / '+ kanban.leankor__ValueStream__r.Name;
                } else {
                    Post.Body = currentUser + ' has assigned you as owner of '+kanban.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard' ? 'Activity': 'Card'+' "' + Post.Title + '". Click this link to go to the project board. '+'\n\n'+ kanban.leankor__ProjectRoom__c +' / '+ kanban.leankor__ValueStream__r.Name;
                }
                Post.LinkUrl = createKanbanCardURL(kanban, orgBaseURL) + kanban.Id;
                
                feedItems.add(Post);
            }
        } else if (kanbanVerb == 'MoveKanbanCard') {
            Set<String> cardIds = new Set<String>();
            Set<String> userIds = new Set<String>();
            
            for (leankor__KanbanCard__c kanban: kanbanList) {
                cardIds.add(kanban.Id);
                userIds.add(kanban.OwnerID);
            }
            
            ESList = readEntitySubscription(cardIds, userIds);
            for (leankor__KanbanCard__c kanban: kanbanList) {
                Boolean flag = true;
                for (EntitySubscription ES: ESList) {
                    if (ES.ParentID == kanban.OwnerID && Es.ParentID == kanban.Id) {
                        flag = false;
                        break;
                    }
                }
                if (flag) {
                    if (Network.getnetworkid() != null) {
                        sObject ESsobject = new EntitySubscription();
                        ESsobject.put('ParentID', kanban.Id);
                        ESsobject.put('NetworkID', Network.getnetworkid());
                        ESsobject.put('SubscriberID', kanban.OwnerID);
                        ESsobjectList.add(ESsobject);
                    } else {
                        if (EntitySubscription.sObjectType.getDescribe().isCreateable()) {
                            EntitySubscription entity = new EntitySubscription(ParentID = kanban.Id, SubscriberID = kanban.OwnerID);
                            ESList2.add(entity);
                        }
                    }
                }
            }
        }

       try {
            if (ESsobjectList.size() > 0) {
                insert ESsobjectList;
            }
            if (ESList2.size() > 0) {
                ChatterAutoFollow.createAutoFollow(ESList2);
            }
            if (feedItems.size() > 0) {
                leankor.OpenFeedItemRestriction.createFeedItems(feedItems);
            }
        } catch (DmlException exc) {
            throw new Util.LeanException('ERROR:' + exc.getMessage());
        }
    }


    public static String createKanbanCardURL(leankor__KanbanCard__c kanban, String orgBaseURL) {
        String kanbanURL = orgBaseURL;

        // Need to checking board type here to make correct url for the kanban Card.
        if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard') {
            kanbanURL += (new PageReference('/apex/leankor__GanttView').getUrl()) + '?fid=' + kanban.leankor__ValueStream__r.leankor__projectRoom__c + '&btype=projectgantt&' + 'Id=' + kanban.leankor__ValueStream__c +'&cardid=';
        } else {
            if(kanban.RecordType.Name != 'MileStoneCard') {
                if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board' || kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Plan Board') {
                    kanbanURL += (new PageReference('/apex/leankor__KanbanBoard').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
                } else if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
                    kanbanURL += (new PageReference('/apex/leankor__PortfolioView').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
                } else {
                    kanbanURL += (new PageReference('/apex/leankor__VisualKanban').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
                }
            } else {
                kanbanURL += (new PageReference('/apex/leankor__CalenderView').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
            }
        }

        return kanbanURL;
    }
    
    //06/04/2021 : Method for delete associated file.
    public static String deleteFiles(leankor.KanbanController.deleteFileWrapper deleteFileData){
        String returnValue = 'Success';
        List<FeedItem> feedItem = new List<FeedItem>();
        List<FeedItem> feedItemList = [Select Id, 
                                            ParentId, 
                                            Type, 
                                            Title, 
                                            Body, 
                                            RelatedRecordId
                                        From FeedItem 
                                        Where ParentId =: deleteFileData.parentId];

        try{
            for(FeedItem feed : feedItemList){
                if(deleteFileData.relatedRecordId.equals(feed.RelatedRecordId)){
                    feedItem.add(feed);
                }
            } 
            if(!feedItem.isEmpty()){
                delete feedItem;
            }
        }catch(Exception ex){
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        } 
        return returnValue;
    }
}