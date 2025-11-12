public class CreateFilterRequest {
    @AuraEnabled
    public String categoryName;
    @AuraEnabled
    public String filterName;
    @AuraEnabled
    public String ownerName;
    @AuraEnabled
    public String portfolioLinkCards;
    @AuraEnabled
    public String valueStream;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String ownerId;
    @AuraEnabled
    public String user;
    @AuraEnabled
    public Boolean isFilterON;
    @AuraEnabled
    public Boolean isDefaultFilter;
    @AuraEnabled
    public String boardURL;
    @AuraEnabled
    public String priorityName;
    @AuraEnabled
    public String stickerName;
    @AuraEnabled
    public Boolean isFilterONUpdate;
    @AuraEnabled
    public String featureData;
    @AuraEnabled
    public String miniatureName;
    @AuraEnabled
    public String percentCompleteRange;
    @AuraEnabled
    public String visibleColumnWidth;
    @AuraEnabled
    public Decimal ganttDividerSize;

    // Constructor
    public CreateFilterRequest() {
        // Initialize fields with default values
        this.categoryName = '';
        this.filterName = '';
        this.ownerName = '';
        this.portfolioLinkCards = '';
        this.valueStream = '';
        this.id = '';
        this.ownerId = '';
        this.user = '';
        this.isFilterON = false;
        this.isDefaultFilter = false;
        this.boardURL = '';
        this.priorityName = '';
        this.stickerName = '';
        this.isFilterONUpdate = false;
        this.featureData = '';
        this.miniatureName = '';
        this.percentCompleteRange = '';
        this.visibleColumnWidth = '';
        this.ganttDividerSize = 0.0;
    }
}