global with sharing class FileUploadData {
     @AuraEnabled
    global String parentId { get; set; }

    @AuraEnabled
    global String contentVersionId { get; set; }
}