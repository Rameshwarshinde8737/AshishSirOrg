public class CloneProjectRequestData {
    
    @AuraEnabled public String sourceFolderId { get; set; }
        @AuraEnabled public String sourceFolderName { get; set; }
        @AuraEnabled public String sourceProjectId { get; set; }
        @AuraEnabled public String sourceProjectName { get; set; }
        @AuraEnabled public String targetFolderId { get; set; }
        @AuraEnabled public String targetFolderName { get; set; }
        @AuraEnabled public String targetProjectName { get; set; }
        @AuraEnabled public Datetime targetProjectStartDateTime { get; set; }
        @AuraEnabled public Datetime targetProjectDueDateTime { get; set; }
        @AuraEnabled public Boolean planGantt { get; set; }
        @AuraEnabled public Boolean rollUp { get; set; }
        @AuraEnabled public Boolean projectBoard { get; set; }
        @AuraEnabled public Boolean whiteBoard { get; set; }
        @AuraEnabled public Boolean dashBoard { get; set; }
        @AuraEnabled public Boolean expenses { get; set; }
        @AuraEnabled public Boolean returnPortfolioHierarchy { get; set; }
        @AuraEnabled public String relinkClonedProjectId { get; set; }
        @AuraEnabled public List<String> projectBoardTypes { get; set; }
        @AuraEnabled public Integer totalCardsOfSourceProjectBoards { get; set; }
        @AuraEnabled public Boolean cloneFiles { get; set; }
        @AuraEnabled public Boolean cloneCustomFields { get; set; }
        @AuraEnabled public Datetime targetLaunchDateTime { get; set; }
        @AuraEnabled public String projectEventCustomPayload { get; set; }
        @AuraEnabled public Boolean cardStickerVerb { get; set; }

        // If your UI sends these as strings, keep them. Otherwise you can drop them.
        @AuraEnabled public String targetStartDate { get; set; }
        @AuraEnabled public String targetLaunchDate { get; set; }
        @AuraEnabled public String targetDueDate { get; set; }
        @AuraEnabled public String sessionID { get; set; }

}