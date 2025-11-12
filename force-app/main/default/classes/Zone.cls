public virtual with sharing class Zone {
    public String id {get; set;}
    public String title {get; set;}
    public Decimal top {get; set;} {top = 0;}
    public Decimal bottom {get; set;} {bottom = 0;}
    public Decimal left {get; set;} {left = 0;}
    public Decimal width {get; set;} {width = 209;}
    public Decimal height {get; set;} {height = 492;}
    public Decimal x {get; set;} {x = 0;}
    public Decimal y {get; set;} {y = 0;}
    public String zoneOpportunityStage {get; set;}
    public String entryFlowName {get; set;} {entryFlowName = '';}
    public String exitFlowName {get; set;} {exitFlowName = '';}
    public String valueStreamLink {get; set;}
    public String zoneMode {get; set;} {zoneMode ='Vertical Stretch';}
    public String kanbanSequence {get; set;} {kanbanSequence = '[]';}
    public String valueStreamLinkId {get; set;} {valueStreamLinkId = '';}
    public String valueStreamCardLink {get; set;} {valueStreamCardLink = '';}
    public String valueStreamLinkBoardType {get; set;}
    public Decimal defaultHeight {get; set;}
    public Decimal defaultWidth {get; set;} {defaultWidth = 209;}
    public String zoneStatus {get; set;} {zoneStatus = 'None';}
    public Decimal taskLimit {get; set;} {taskLimit = 0;}
    public Decimal order {get; set;} {order = 0;}
    public String parentZone {get; set;} {parentZone= '';}
    public String swimlane {get; set;}
    public Decimal cardsPerRow {get; set;} {cardsPerRow=1;}
    public String help {get; set;} {help ='';}
    public String guid {get; set;}
    public String valueStreamId {get; set;}
    public String caseStatus {get; set;}
    public String cmpId {get; set;}
    public String completionRateUnits {get; set;}
    public Decimal completionRate {get; set;}
    public String cssLayout {get; set;}
    public String jsonDefinition {get; set;}
    public Decimal kanbanCardCount {get; set;}
    public Decimal kanbanCardThroughput {get; set;}
    public Decimal leadTime {get; set;}
    public String zoneTemplate {get; set;}
    public String name {get; set;}
    public String ownerID {get; set;}
    public Boolean leaf {get; set;}
    public List <leankor.KanbanToGanttController.MasterContainer> children {get; set;}
    public Boolean expanded {get; set;}
    public String startDate {get; set;}
    public String dueDate {get; set;}
    public String forceID {get; set;}
    public String itemType {get; set;}
    public String color {get; set;}
    public String urlLink {get; set;}
    public String unit {get; set;}

    
    public enum ZoneType {
        STANDARDINPROGRESS,
        INPROGRESS,
        STANDARD
    }


    /********************************************************************
    CONSTANTS
    *********************************************************************/
    public static final Zone STANDARDINPROGRESS {get;set;}
    //Static initializer
    static {
        STANDARDINPROGRESS = new Zone();
        STANDARDINPROGRESS.title = 'In Progress';
        STANDARDINPROGRESS.height = 492;
        STANDARDINPROGRESS.defaultHeight = 492;
    }


    public static final Zone INPROGRESS {get;set;}
    //Static initializer
    static {
        INPROGRESS = new Zone();
        INPROGRESS.title = 'In Progress';
        INPROGRESS.height = 174;
        INPROGRESS.defaultHeight = 174;
    }


    public static final Zone STANDARD {get;set;}
    //Static initializer
    static {
        STANDARD = new Zone();
        STANDARD.title = 'Default Column';
        STANDARD.height = 492;
        STANDARD.defaultHeight = 492;
    }


    /********************************************************************
    FACTORY
    *********************************************************************/
    private Zone getZone(leankor__Swimlane__c swimlane, ZoneType zoneType, Integer index) {
        Zone zone;
        switch on zoneType {
            when STANDARDINPROGRESS {
                zone = new StandardInProgressZone(swimlane, index);
            }
            when INPROGRESS {
                zone = new InProgressZone(swimlane, index);
            }
            when STANDARD {
                zone = new StandardZone(swimlane, index);
            }
            when else {
                zone = new Zone();
            }
        }
        return zone;
    }


    /********************************************************************
    SUBCLASS TYPES
    *********************************************************************/
    private class StandardInProgressZone extends Zone{
        public StandardInProgressZone(leankor__Swimlane__c swimlane, Integer index) {
            super(swimlane, STANDARDINPROGRESS, index);
        }
    }


    private class InProgressZone extends Zone{
        public InProgressZone(leankor__Swimlane__c swimlane, Integer index) {
            super(swimlane, INPROGRESS, index);
        }
    }


    private class standardZone extends Zone{
        public standardZone(leankor__Swimlane__c swimlane, Integer index) {
            super(swimlane, STANDARD, index);
        }
    }


    /********************************************************************
    CONSTRUCTORS
    *********************************************************************/
    //Default
    public Zone() {

    }


    public Zone(leankor__Swimlane__c swimlane, ZoneType zoneType, Integer index) {
        getZone(swimlane, zoneType, index);
    }


    public Zone(leankor__Swimlane__c swimlane, Zone newZone, Integer index) {
        this.id = newZone.id;
        this.title = newZone.title;
        this.top = newZone.top;
        this.bottom = newZone.bottom;
        this.left = newZone.left;
        this.width = newZone.width;
        this.height = newZone.height;
        this.x = newZone.x;
        this.y = newZone.y;
        this.zoneOpportunityStage = newZone.zoneOpportunityStage;
        this.entryFlowName = newZone.entryFlowName;
        this.exitFlowName = newZone.exitFlowName;
        this.valueStreamLink = newZone.valueStreamLink;
        this.zoneMode = newZone.zoneMode;
        this.kanbanSequence = newZone.kanbanSequence;
        this.valueStreamLinkId = newZone.valueStreamLinkId;
        this.valueStreamCardLink = newZone.valueStreamCardLink;
        this.valueStreamLinkBoardType = newZone.valueStreamLinkBoardType;
        this.defaultHeight = newZone.defaultHeight;
        this.defaultWidth = newZone.defaultWidth;
        this.zoneStatus = newZone.zoneStatus;
        this.taskLimit = newZone.taskLimit;
        this.order = newZone.order;
        this.parentZone = newZone.parentZone;
        this.swimlane = swimlane.id;
        this.cardsPerRow = newZone.cardsPerRow;
        this.help = newZone.help;
        this.guid = swimlane.leankor__valueStream__c+'-'+System.now().getTime()+'-z100'+index;
        this.valueStreamId = swimlane.leankor__valueStream__c;
        this.caseStatus = newZone.caseStatus;
        this.cmpId = newZone.cmpId;
        this.completionRateUnits = newZone.completionRateUnits;
        this.completionRate = newZone.completionRate;
        this.cssLayout = newZone.cssLayout;
        this.jsonDefinition = newZone.jsonDefinition;
        this.kanbanCardCount = newZone.kanbanCardCount;
        this.kanbanCardThroughput = newZone.kanbanCardThroughput;
        this.leadTime = newZone.leadTime;
        this.zoneTemplate = newZone.zoneTemplate;
        this.name = newZone.name;
        this.ownerID = newZone.ownerID;
        this.leaf = newZone.leaf;
        this.children = newZone.children;
        this.expanded = newZone.expanded;
        this.startDate = newZone.startDate;
        this.dueDate = newZone.dueDate;
        this.forceID = newZone.forceID;
        this.itemType = newZone.itemType;
        this.color = newZone.color;
        this.urlLink = newZone.urlLink;
        this.unit = newZone.unit;
    }


    public Zone(String valueStreamId, String swimlaneId, leankor__Zone__c newZone) {
        this.valueStreamId = valueStreamId;
        this.guid = newZone.Id+'-'+swimlaneId+'-z';
        this.title = newZone.leankor__Title__c;
        this.top = newZone.leankor__Top__c;
        this.bottom = newZone.leankor__Bottom__c;
        this.left = newZone.leankor__Left__c;
        this.width = newZone.leankor__Width__c;
        this.height = newZone.leankor__Height__c;
        this.unit = newZone.leankor__Unit__c;
        this.x = newZone.leankor__X__c;
        this.y = newZone.leankor__Y__c;
        this.entryFlowName = newZone.leankor__EntryFlowName__c;
        this.exitFlowName = newZone.leankor__ExitFlowName__c;
        this.zoneMode = newZone.leankor__zoneMode__c;
        this.kanbanSequence = newZone.leankor__kanbanSequence__c;
        this.valueStreamLinkID = newZone.leankor__ValueStreamLink__c;
        this.valueStreamCardLink = newZone.leankor__ValueStreamCardLink__c;
        this.defaultWidth  = newZone.leankor__DefaultWidth__c;
        this.defaultHeight = newZone.leankor__DefaultHeight__c;
        this.zoneStatus = newZone.leankor__CaseStatus__c ;
        this.zoneOpportunityStage = newZone.leankor__OpportunityStageName__c ;
        this.cardsPerRow = newZone.leankor__CardsPerRow__c;
        this.help = newZone.leankor__Help__c;
        this.taskLimit = newZone.leankor__Limit__c;
        this.order = newZone.leankor__Order__c;
        this.parentZone = '';
        this.swimlane = swimlaneId;
    }


    public static List<leankor__Zone__c> createZones(final List<Zone> zones) {
        List<leankor__Zone__c> createZones = new List<leankor__Zone__c>();
        String zoneId = '';

        //Check CRUD / FLC behavior
  		ZoneBehavior zoneBehavior = new ZoneBehavior();
  		if (!zoneBehavior.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior

        for (Zone zone: zones) {
            leankor__Zone__c createZone = new leankor__Zone__c();
            createZone.leankor__UrlLink__c = zone.urlLink;
            createZone.leankor__GUID__c = zone.guid;
            createZone.leankor__Title__c = zone.title;
            createZone.leankor__Unit__c = zone.unit;
            createZone.Name = zone.title;
            createZone.leankor__Top__c = zone.top;
            createZone.leankor__Bottom__c = zone.bottom;
            createZone.leankor__Left__c = zone.left;
            createZone.leankor__Width__c = zone.width;
            createZone.leankor__Height__c = zone.height;
            createZone.leankor__X__c = zone.x;
            createZone.leankor__OpportunityStageName__c = zone.zoneOpportunityStage;
            createZone.leankor__Y__c = zone.y;
            createZone.leankor__EntryFlowName__c = zone.entryFlowName;
            createZone.leankor__ExitFlowName__c = zone.exitFlowName;
            createZone.leankor__ValueStream__c = (zone.valueStreamId == '' ? null : zone.valueStreamId);
            createZone.leankor__zoneMode__c = zone.zoneMode;
            createZone.leankor__kanbanSequence__c = zone.kanbanSequence;
            createZone.leankor__ValueStreamLink__c = (zone.valueStreamLinkID == '' ? null : zone.valueStreamLinkID);
            createZone.leankor__ValueStreamCardLink__c = (zone.valueStreamCardLink == '' ? null : zone.valueStreamCardLink);
            createZone.leankor__DefaultWidth__c = zone.defaultWidth;
            createZone.leankor__DefaultHeight__c = zone.defaultHeight;
            createZone.leankor__CaseStatus__c = zone.zoneStatus;
            createZone.leankor__CardsPerRow__c = zone.cardsPerRow;
            createZone.leankor__Help__c = zone.help;
            createZone.leankor__Limit__c = zone.taskLimit;
            createZone.leankor__Order__c = zone.order;
            createZone.leankor__ParentZone__c = (zone.parentZone != '' ? zone.parentZone : null);
            createZone.leankor__Swimlane__c = (zone.swimlane != '' ? zone.swimlane : null);

            createZones.add(createZone);
        }

        try {
            Database.insert(createZones, false);
        } catch (DmlException e) {
            createZones = new List<leankor__Zone__c>();
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        
        return createZones;
    }
}