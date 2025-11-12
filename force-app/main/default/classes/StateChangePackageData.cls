public with sharing class StateChangePackageData {
    @AuraEnabled 
    public String id { get; set; }
    @AuraEnabled 
    public String cardId { get; set; }
    @AuraEnabled 
    public String title { get; set; }
    @AuraEnabled 
    public String name { get; set; }
    @AuraEnabled 
    public Decimal width { get; set; }
    @AuraEnabled 
    public Decimal height { get; set; }
    @AuraEnabled 
    public Decimal top { get; set; }
    @AuraEnabled 
    public Decimal bottom { get; set; }
    @AuraEnabled 
    public Decimal left { get; set; }
    @AuraEnabled 
    public Decimal x { get; set; }
    @AuraEnabled public Decimal y { get; set; }
    @AuraEnabled 
    public String zoneOpportunityStage { get; set; }
    @AuraEnabled 
    public String cmpId { get; set; }
    @AuraEnabled 
    public String zoneId { get; set; }
    @AuraEnabled 
    public String mcForceId { get; set; }
    @AuraEnabled 
    public String swForceId { get; set; }
    @AuraEnabled 
    public String zoneForceId { get; set; }
    @AuraEnabled 
    public String state { get; set; }
    @AuraEnabled 
    public String color { get; set; } // EjB7: added color
    @AuraEnabled 
    public Decimal estimatedDuration { get; set; } // EjB12 added duration
    @AuraEnabled 
    public String durationUnits { get; set; } // EjB12 added duration Units
    @AuraEnabled 
    public Datetime dueDate { get; set; } // EjB10: added due date
    @AuraEnabled 
    public Decimal priority { get; set; } // EjB14: need to update priority now and again
    @AuraEnabled 
    public Decimal harveyBall { get; set; }
    @AuraEnabled 
    public String ownerId { get; set; }
    @AuraEnabled 
    public String templateId { get; set; }
    @AuraEnabled 
    public String jsonData { get; set; }
    @AuraEnabled 
    public String jsonDefinition { get; set; }
    @AuraEnabled 
    public String zoneMode { get; set; }
    @AuraEnabled 
    public String kanbanSequence { get; set; }
    @AuraEnabled 
    public String description { get; set; }
    @AuraEnabled 
    public String acceptanceCriteria { get; set; }
    @AuraEnabled 
    public String kanbanUrl { get; set; }
    @AuraEnabled 
    public String entryFlowName { get; set; }
    @AuraEnabled 
    public String exitFlowName { get; set; }
    @AuraEnabled 
    public String leavedZoneId { get; set; }
    @AuraEnabled 
    public String valueStreamLinkId { get; set; }
    @AuraEnabled 
    public String valueStreamCardLink { get; set; }
    @AuraEnabled 
    public String valueStreamOld { get; set; }
    @AuraEnabled 
    public String account { get; set; }
    @AuraEnabled 
    public String contact { get; set; }
    @AuraEnabled 
    public String caseId { get; set; }
    @AuraEnabled 
    public Integer defaultHeight { get; set; }
    @AuraEnabled 
    public Integer defaultWidth { get; set; }
    @AuraEnabled 
    public String zoneStatus { get; set; }
    @AuraEnabled 
    public String forceId { get; set; }
    @AuraEnabled 
    public String valueStream { get; set; }
    @AuraEnabled 
    public String valueStreamId { get; set; }
    @AuraEnabled 
    public String switchedVsName { get; set; }
    @AuraEnabled 
    public String accountName { get; set; }
    @AuraEnabled 
    public String contactName { get; set; }
    @AuraEnabled 
    public String caseSubject { get; set; }
    @AuraEnabled 
    public String caseStatus { get; set; }
    @AuraEnabled 
    public String casePriority { get; set; }
    @AuraEnabled 
    public String zoneTitle { get; set; }
    @AuraEnabled 
    public String leavedZoneTitle { get; set; }
    @AuraEnabled 
    public Boolean caseTrigger { get; set; }
    @AuraEnabled 
    public Boolean isUndo { get; set; }
    @AuraEnabled 
    public String guid { get; set; }
    @AuraEnabled 
    public String extensions { get; set; }
    @AuraEnabled 
    public Datetime startDate { get; set; }
    @AuraEnabled 
    public Decimal taskLimit { get; set; }
    @AuraEnabled 
    public Decimal orderValue { get; set; }
    @AuraEnabled 
    public String parentZone { get; set; }
    @AuraEnabled 
    public String swimlane { get; set; }
    @AuraEnabled 
    public Decimal cardsPerRow { get; set; }
    @AuraEnabled 
    public String help { get; set; }
    @AuraEnabled 
    public Decimal percentDone { get; set; }
    @AuraEnabled 
    public String valueStreamLinkBoardType { get; set; }
    @AuraEnabled 
    public Boolean leaf { get; set; }
    @AuraEnabled 
    public Boolean sWeek { get; set; }
    @AuraEnabled 
    public String opportunity { get; set; }
    @AuraEnabled 
    public String opportunityName { get; set; }
    @AuraEnabled 
    public String opportunityStage { get; set; }
    @AuraEnabled 
    public String smallPhotoUrl { get; set; }
    @AuraEnabled 
    public String itemType { get; set; }
    @AuraEnabled 
    public String boardType { get; set; }
    @AuraEnabled 
    public String templateName { get; set; }
    @AuraEnabled 
    public String onBudget { get; set; }
    @AuraEnabled 
    public String onQuality { get; set; }
    @AuraEnabled 
    public String onTime { get; set; }
    @AuraEnabled 
    public String linkedCardVerb { get; set; }
    @AuraEnabled 
    public String valueStreamName { get; set; }
    @AuraEnabled 
    public Integer taskComments { get; set; }
    @AuraEnabled 
    public Integer chatterComments { get; set; }
    @AuraEnabled public String resourceId { get; set; } // For Resource Board Contains Owner ID
    @AuraEnabled public String urlLink { get; set; }
    @AuraEnabled public String type { get; set; }
    @AuraEnabled public String textLabel { get; set; }
    @AuraEnabled public String projectRoomName { get; set; }
    @AuraEnabled public String projectRoomId { get; set; }
    @AuraEnabled public String kanbanCardName { get; set; }
    @AuraEnabled public String successorsArray { get; set; }
    @AuraEnabled public String unit { get; set; }
    @AuraEnabled public Decimal point { get; set; }
    @AuraEnabled public Decimal effortRemaining { get; set; }
    @AuraEnabled public String dl { get; set; }
    @AuraEnabled public Boolean deleteMiniature { get; set; }
    @AuraEnabled public Boolean isExternallyDependent { get; set; } // If Activity has external dependencies
    @AuraEnabled public String linkCn { get; set; } // Abbreviation for ValueStreamCardLink Name
    @AuraEnabled public Boolean flowWithGs { get; set; } // Rs 12/12/2017 API called from Flow
    @AuraEnabled public Boolean isSr { get; set; } // Successor Recalculate flag
    @AuraEnabled public Boolean isAtRisk { get; set; }
    @AuraEnabled public Boolean isOnHold { get; set; }
    @AuraEnabled public String sessionId { get; set; }
    @AuraEnabled public String recordTypeId { get; set; }
    @AuraEnabled public Boolean isConstraintRecalculate { get; set; } // 15/05/2023 HyperJump recalculation
    // Weekday flags
    @AuraEnabled 
    public Boolean monday { get; set; }
    @AuraEnabled 
    public Boolean tuesday { get; set; }
    @AuraEnabled 
    public Boolean wednesday { get; set; }
    @AuraEnabled 
    public Boolean thursday { get; set; }
    @AuraEnabled 
    public Boolean friday { get; set; }
    @AuraEnabled 
    public Boolean saturday { get; set; }
    @AuraEnabled 
    public Boolean sunday { get; set; }
    @AuraEnabled 
    public String weekCalendar { get; set; }
}