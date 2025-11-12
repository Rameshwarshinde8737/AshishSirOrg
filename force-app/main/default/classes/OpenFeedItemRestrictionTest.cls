@isTest
private class OpenFeedItemRestrictionTest {
    @testSetup static void testData() {  
        //create and insert ContentVersion
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList, 1);
        List<leankor__ValueStream__c> valuestreamList = new List<leankor__ValueStream__c>();
        List<String> boardList = new List<String>{'UberBoard','Kanban Board','Portfolio View','Whiteboard','Card Hierarchy','Plan Board','DashBoard'};
        for(String board : boardList){
            leankor__ValueStream__c valueStreamTest = new leankor__ValueStream__c(Name = 'myValueStream',
                                                                                  leankor__BoardType__C = board,
                                                                                  leankor__ProjectRoom__C = projectList[0].Id);
            valuestreamList.add(valueStreamTest);
        }
        insert valuestreamList;
        leankor__ValueStream__c valueStreamForCV = new leankor__ValueStream__c(Name = 'myValueStream',
                                                                              leankor__ProjectRoom__C = projectList[0].Id);
        insert valueStreamForCV;
        List<leankor__KanbanCard__c> kanbanList = new List<leankor__KanbanCard__c>();
        for(leankor__ValueStream__c valuestream : valuestreamList){
            leankor__KanbanCard__c card = new leankor__KanbanCard__c(Name = 'KanbanCard', 
                                                                     leankor__ValueStream__c = valuestream.Id, 
                                                                     leankor__GUID__C = leankor.TestDataFactory.createguid());
            kanbanList.add(card);
        }
        insert kanbanList;
        leankor__KanbanCard__c mileStonecard = new leankor__KanbanCard__c(Name = 'Milestone', 
                                                                          leankor__ValueStream__c = valueStreamForCV.Id, 
                                                                          leankor__GUID__C = leankor.TestDataFactory.createguid(),
                                                                          RecordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId());
        insert mileStonecard;
        list<ContentVersion> contentVersionList = new list<ContentVersion>();   
        ContentVersion contentVersion_1 = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_1);
        ContentVersion contentVersion_2 = new ContentVersion(
          Title = 'Penguins1',
          PathOnClient = 'Penguins1.jpg',
          VersionData = Blob.valueOf('Test Content1'),
          IsMajorVersion = true
        );
        contentVersionList.add(contentVersion_2);
        insert contentVersionList;         

        //create and insert FeedItem            
        FeedItem post = new FeedItem();
        post.parentid = kanbanList[0].Id;
        post.Body = 'Body';
        post.relatedRecordId = contentVersionList[0].id;
        insert post;  
        
        //create and associate a content attachment to the post
        FeedAttachment FA = new FeedAttachment();
        FA.FeedEntityId = post.Id;                                    
        FA.RecordId = contentVersionList[0].Id; 
        FA.Type = 'CONTENT';
        //insert FA;           
        
        FeedComment FC = new FeedComment();
        FC.FeedItemId = post.Id ;
        FC.CommentBody  = 'Abc';
        FC.RelatedRecordId = contentVersionList[1].Id; 
        insert FC ; 

        Account sampleAcc = leankor.PermissionSetsTestDataFactory.createAccount('A Test Account');
        Contact commContact = leankor.PermissionSetsTestDataFactory.createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);
    }

    @IsTest
    static void openFeedItemRestrictionTest() {
        List<FeedItem> feedList = new List<FeedItem>();

        for (Integer i=1; i<=50; i++) {
            FeedItem feed = new FeedItem();
            feed.ParentID = UserInfo.getUserId();
            feed.Title = 'Test Feed Title '+i;
            feed.Body = 'Test body of Feed Item';
            feed.IsRichText = true;

            feedList.add(feed);
        }

        Test.startTest();

        // Test the creation of FeedItems
        List<FeedItem> createdFeeds = leankor.OpenFeedItemRestriction.createFeedItems(feedList);
        System.assertEquals(50, createdFeeds.size());

        // Test the updation of feedItems
        /*for (FeedItem feed: createdFeeds) {
            feed.Body = 'Test body of updated Feed Item';
        }
        List<FeedItem> updatedFeeds = leankor.OpenFeedItemRestriction.updateFeedItems(createdFeeds);
        System.assertEquals('Test body of updated Feed Item', updatedFeeds[0].Body);

        // Test the deletion of FeedItems
        leankor.OpenFeedItemRestriction.deleteFeedItems(updatedFeeds);
        List<FeedItem> deletedFeeds = [SELECT Id, Title FROM FeedItem WHERE Id IN: updatedFeeds];
        System.assertEquals(0, deletedFeeds.size());*/

        Test.stopTest();
    }

    @isTest
    private static void deleteFilesTest(){
        List<leankor__ValueStream__c> valueStreams = [Select Id From leankor__ValueStream__c Where Name =: 'myValueStream'];
        List<leankor__KanbanCard__c> cards = [Select Id From leankor__KanbanCard__c Where Name =: 'KanbanCard'];
        List<ContentVersion> contentVersions = [Select Id From ContentVersion Where Title =: 'Penguins'];
        leankor.KanbanController.FileInputWrapper FIW = new leankor.KanbanController.FileInputWrapper();
        FIW.filePublishLocation = 'ValueStream';
        List<Id> listIds = new List<Id>();  
        listIds.add(valueStreams[0].Id);               
        FIW.publishLocationIds = listIds;                        
        
        leankor.KanbanController.DeleteFileWrapper deleteData = new leankor.KanbanController.DeleteFileWrapper();
        deleteData.relatedRecordId = contentVersions[0].Id;
        deleteData.parentId = cards[0].Id;
        System.assert(leankor.OpenFeedItemRestriction.deleteFiles(deleteData) == 'Success');
    }

    @isTest
    private static void getNetworkUrltest(){
        String networkId = Network.getNetworkId();
        String baseUrl = OpenFeedItemRestriction.getNetworkUrl(networkId , 'https://' + DomainCreator.getOrgMyDomainHostname());
        System.assertEquals('https://' + DomainCreator.getOrgMyDomainHostname(),baseUrl);
    }

    @isTest
    private static void createChatterFeedtest(){
        List<leankor__KanbanCard__c> cards = [Select Id, 
                                                     OwnerId 
                                                From leankor__KanbanCard__c 
                                                Where Name = 'KanbanCard'];
        String kanbanVerb = 'MoveKanbanCard';
        OpenFeedItemRestriction.createChatterFeed(cards, kanbanVerb);
        System.assert(cards.size() > 0);
    }

    @isTest
    private static void createKanbanCardURLtest(){
        OpenFeedItemRestriction feeditem = new OpenFeedItemRestriction();
        List<leankor__ValueStream__c> valueStreams = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Name = 'myValueStream' ];
        List<leankor__KanbanCard__c> cards = [Select Id, 
                                                     OwnerId, 
                                                     leankor__ValueStream__r.leankor__BoardType__c,
                                                     RecordType.Name,
                                                     leankor__ValueStream__r.leankor__ProjectRoom__c 
                                                From leankor__KanbanCard__c 
                                                Where Name = 'KanbanCard'];
        leankor__KanbanCard__c mileStonecard = [Select Id, 
                                                       leankor__ValueStream__r.leankor__BoardType__c,
                                                       RecordType.Name,
                                                       leankor__ValueStream__r.leankor__ProjectRoom__c
                                                    From leankor__KanbanCard__c 
                                                    Where Name = 'Milestone'];
        for(leankor__KanbanCard__c card:cards){
            String kanbanurl = OpenFeedItemRestriction.createKanbanCardURL(card,'https://' + DomainCreator.getOrgMyDomainHostname());
            if(card.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard'){
                System.assertEquals(kanbanurl , 'https://' + DomainCreator.getOrgMyDomainHostname()+ '/apex/leankor__GanttView?fid='+card.leankor__ValueStream__r.leankor__projectRoom__c+'&btype=projectgantt&Id='+ card.leankor__ValueStream__c+'&cardid=');
            }
            if(card.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board'){
                System.assertEquals(kanbanurl ,'https://' + DomainCreator.getOrgMyDomainHostname()+ '/apex/leankor__KanbanBoard?Id='+card.leankor__ValueStream__c+'&cardid=');
            }
            if(card.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View'){
                System.assertEquals(kanbanurl , 'https://' + DomainCreator.getOrgMyDomainHostname()+ '/apex/leankor__PortfolioView?Id='+card.leankor__ValueStream__c+'&cardid=');
            }
        }
        System.assertEquals(OpenFeedItemRestriction.createKanbanCardURL(mileStonecard, 'https://' + DomainCreator.getOrgMyDomainHostname()) , 'https://' + DomainCreator.getOrgMyDomainHostname()+ '/apex/leankor__CalenderView?Id='+mileStonecard.leankor__ValueStream__c+'&cardid=');
    }
}