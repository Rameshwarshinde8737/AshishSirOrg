public with sharing class FileUploadController {
    @AuraEnabled
    public static Id saveFile(String fileName, String base64Data, String contentType) {
        System.debug('Hello');
        ContentVersion contentVersion = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = EncodingUtil.base64Decode(base64Data),
            IsMajorVersion = true
        );
        
        insert contentVersion;
        return contentVersion.Id;
    }
}