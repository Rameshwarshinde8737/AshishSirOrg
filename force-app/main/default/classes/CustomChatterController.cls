public with sharing class CustomChatterController {
     @AuraEnabled(cacheable=true)
    public static ConnectApi.FeedElementPage getFeedElements(String recordId) {
        return ConnectApi.ChatterFeeds.getFeedElementsFromFeed(
            Network.getNetworkId(), 
            ConnectApi.FeedType.Record, 
            recordId
        );
    }
    
    @AuraEnabled
    public static ConnectApi.FeedElement postFeedElement(String recordId, String text) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        textSegmentInput.text = text;
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>{textSegmentInput};
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;
        
        return ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
}