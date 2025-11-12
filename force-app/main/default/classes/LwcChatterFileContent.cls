public with sharing class LwcChatterFileContent {
    @AuraEnabled public Id Id;
    @AuraEnabled public DateTime LastModifiedDate{get;set;}
    @AuraEnabled public String LinkUrl{get;set;}
    @AuraEnabled public String ParentId{get;set;}
    @AuraEnabled public String RelatedRecordId{get;set;}
    @AuraEnabled public String Status{get;set;}
    @AuraEnabled public DateTime SystemModstamp{get;set;}
    @AuraEnabled public String Title{get;set;}
    @AuraEnabled public String Type{get;set;}
    @AuraEnabled public String ExternalDocumentInfo1{get;set;}
    @AuraEnabled public String ContentLocation{get;set;}
    @AuraEnabled public String ExternalDataSourceId{get;set;}
    @AuraEnabled public String ContentDocumentId{get;set;}
    @AuraEnabled public String externalDocumentInfo2{get;set;}
    @AuraEnabled public String name{get;set;}
    @AuraEnabled public String documentId{get;set;}
    @AuraEnabled public String sourceType{get;set;}
    @AuraEnabled public Integer comments{get;set;}  	
    @AuraEnabled public String latestPublishedVersionId{get;set;}

    // Default constructor 
    public LwcChatterFileContent() {}

    // Overloaded constructor 
    public LwcChatterFileContent(
        Id Id,
        DateTime LastModifiedDate,
        String LinkUrl,
        String ParentId,
        String RelatedRecordId, 
        String Status,
        DateTime SystemModstamp,
        String Title,
        String Type,
        String ExternalDocumentInfo1,
        String ContentLocation,
        String ExternalDataSourceId,
        String ContentDocumentId
    ) {
        this.Id = Id;
        this.LastModifiedDate = LastModifiedDate;
        this.LinkUrl = LinkUrl;
        this.ParentId = ParentId;
        this.RelatedRecordId = RelatedRecordId;
        this.Status = Status;
        this.SystemModstamp = SystemModstamp;
        this.Title = Title;
        this.Type = Type;
        this.ExternalDocumentInfo1 = ExternalDocumentInfo1;
        this.ContentLocation = ContentLocation;
        this.ExternalDataSourceId = ExternalDataSourceId;
        this.ContentDocumentId = ContentDocumentId;
    }
}