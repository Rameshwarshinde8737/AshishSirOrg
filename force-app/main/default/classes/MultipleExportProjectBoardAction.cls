/**
* Copyright 2019-2020 Lucidsoft Inc. All rights reserved.
* FILE:  MultipleExportProjectBoardAction.cls
* CLASS: MultipleExportProjectBoardAction
* USAGE: Provides invocable methods for exporting both Plan Gantt and Kanban Boards to JSON files that are "importable"
*/
global with sharing class MultipleExportProjectBoardAction {
    //-------------------GLOBAL CONSTANTS--------------------------------------
    
    // use KBC_TYPES.get(RecordTypeId).getDeveloperName() to get the string name of the Record Type
    private static final Map<Id,Schema.RecordTypeInfo> KBC_TYPES = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosById();
    private static final String KBC_MILESTONE = 'MileStoneCard';
    private static final String KBC_ACTIVITYGROUP = 'FolderCard';

    // board types
    private static final String BOARD_TYPE_PG = 'UberBoard'; // actually Plan Gantt on UI
    private static final String BOARD_TYPE_KB = 'Kanban Board';
    private static final String BOARD_TYPE_RU = 'Plan Board'; // actually Rollup Board on UI
    private static final String BOARD_TYPE_WB = 'Whiteboard';

    // to be used with type 'Datetime' variables like this myDateTime.format(DATETIME_FORMAT)
    private static final String DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss';
    private static final String TIME_FORMAT = 'HH:mm';

    // private static final String FOLDER_NAME = 'Leankor Export';
    private static final String FILE_NAME = 'LeankorGanttExport';
    private static final String FILE_EXT = 'txt';
    private static final String CONTENT_LOC_SFDC = 'S';// means save content inside Salesforce Files

    private static Map<String, String> TIMEUNITS_MAP {
        get {
            if (TIMEUNITS_MAP == null) {
                TIMEUNITS_MAP = new Map<String, String>{
                    'Minutes' => 'mi',
                    'Hours' => 'h',
                    'Days' => 'd',
                    'Weeks' => 'w',
                    'Months' => 'm',
                    'Years' => 'y'
                };
            }
            return TIMEUNITS_MAP;
        }
        set;
    }

    private static Map<String, Integer> LAGUNITS_MAP {
        get {
            if (LAGUNITS_MAP == null) {
                LAGUNITS_MAP = new Map<String, Integer>{
                    'Start To Start' => 0,
                    'Start To Finish' => 1,
                    'Finish To Start' => 2,
                    'Finish To Finish' => 3
                };
            }
            return LAGUNITS_MAP;
        }
        set;
    }

    //error codes
    private static final String ERR_BADVS = 'Unable to read the Board valuestream__c record in the database. Check server logs for more detail.';
    private static final String ERR_BOARD_NOTSUPPORTED = 'This type of Leankor Board is not currently supported for export.';
    private static final String ERR_BAD_JSON = 'An error during export caused no output to be generated. Check server logs for more detail.';
    private static final String ERR_FILESAVE = 'Could not save the JSON file to Salesforce File. Check server logs for more detail.';
    // -------------------- END publicS --------------------------

    //---------------------  main input/output classes ----------------------
    global class MultipleExportProjectBoardRequest {
        @InvocableVariable(label='Project ID' description='The project id of the board to be exported.')
        global String projectId;

        @InvocableVariable(label='Valuestream ID' description='The valuestream id of the board to be exported.')
        global String vsId;

        @InvocableVariable(label='Export File Name' description='The name of the file to be saved in Salesforce Files. Do not include extension.')
        global String fileName;

        @InvocableVariable(label='Return String' description='If set to true, the operation will return the JSON in a variable.')
        global Boolean isReturnJSONString = false;

        @InvocableVariable(label='Create File' description='If set to true, the operation will write the file to Salesforce Files.')
        global Boolean isWriteFile = true;
    }

    global class MultipleExportProjectBoardResult {
        @InvocableVariable(label='True if Successful' description='Returns true if a successful export was completed.')
        global Boolean status;

        @InvocableVariable(label='Error Message' description='The full error explanation.')
        global String errorMsg;

        @InvocableVariable(label='File URL' description='The Salesforce Files URL link to retrieve export results.')
        global String fileURL;

        @InvocableVariable(label='JSON Output' description='The JSON representation of the work items.')
        global String outputJSON;
    }
    //---------------------  end main input/output classes ----------------------

    
    //--------------------------- JSON export classes ---------------------------------

    // generates calendar entry ID's while building out Calendar arrays
    static private Integer calIdGenerator{
        get {
            if (calIdGenerator == null) {
                calIdGenerator = 1;
                return 1;  
            } else {
                return ++calIdGenerator;
            }
        } 
        set {
            calIdGenerator = value;
        }
    }

    private class Calendar {
        Integer Id;
        String Name;
        Integer parentId;
        Integer DaysPerWeek;
        Integer DaysPerMonth;
        Integer HoursPerDay;
        Integer WeekendFirstDay;
        Integer WeekendSecondDay;
        Boolean WeekendsAreWorkdays;
        List <String> DefaultAvailability; // formatted time string followed by dash and then another end time string
        Boolean leaf;
        List<Calendar> children; // should only be here when there are children otherwise NULL and not written

        // inner class  constructor
        public Calendar() {
            this.Id = calIdGenerator;
            this.Name = 'Leankor Base Calendar';
            this.DaysPerWeek = 5;
            this.DaysPerMonth = 20;
            this.HoursPerDay = 8;
            this.WeekendsAreWorkdays = false;
            this.WeekendFirstDay = 6;
            this.WeekendSecondDay = 0;
            this.DefaultAvailability = new List<String>();
            this.DefaultAvailability.add('08:00-12:00');
            this.DefaultAvailability.add('13:00-17:00');
            this.parentId = null;
            this.children = null;
            this.leaf = true;
            return;
        }

        // get my Calendar ID
        public Integer getCalendarId() {
            return this.Id;
        }

    }

   private class CalsMetadata{
        Integer projectCalendar;

        // inner class constructor
        public CalsMetadata(Integer inCalNumber) {
            projectCalendar = inCalNumber; 
            return;
        }

    }

    // note this is Calendars with plural ... which is a collection of Calendar (singular)
    private class Calendars {
        public CalsMetadata metaData; 
        public List<Calendar> children;

        // inner class  constructor
        public Calendars() {
            MultipleExportProjectBoardAction.Calendar newCal = new MultipleExportProjectBoardAction.Calendar();
            children = new List<Calendar>();
            children.add(newCal);
            metadata = new CalsMetadata(newCal.getCalendarId());

            return;
        }
    }
    

    // generates unique integers for use in building Calendars
    static private Integer taskIdGenerator {
        get {
            if (taskIdGenerator == null) {
                taskIdGenerator = 1;
                return 1;  
            } else {
                return ++taskIdGenerator;
            }
        } 
        set {
            taskIdGenerator = value;
        }
    }

    //
    // Includes extended metadata
    //
    private class Task {
        Integer Id;
        String Name;
        String StartDate;
        String EndDate;
        Decimal Duration;
        String DurationUnit;    //  supported names are: [m, h, d, w, mo, %, y, em, eh, ed, ew, emo, ey, e%]
                                // but the Gantt needs minutes to be marked as "mi" and not "m" ("m" means months in the Gantt)
        Decimal PercentDone; // 0 to 100 ; can be 24.5 as example
        Boolean Milestone;
        Boolean Rollup; // not sure what this does in Bryntum if anything
        Boolean ManuallyScheduled;
        String ConstraintDate; // if null don't export to JSON
        String ConstraintType; // must be empty string if not there and not null; not sure why
        String BaselineStartDate; // all three next ones must be empty string if not there
        String BaselineEndDate;
        String BaselineDuration; // empty mostly
        String TemplateName; // null if not there
        List<Task> children; // null if doesn't have children
        Boolean expanded; // true only if children
        Boolean leaf; // true if no children; otherwise if children, make false

        // extended metadata here
        String leankorKBCId;        // the leankor__kanbancard__c ID
        String LongId; // the longer WBS type number like 2.3.7 which end users will relate to more than internal Id

        // inner class constructor to create empty Task
        public Task() {
            Id = taskIdGenerator;
            Milestone = false;
            Rollup = false;
            ManuallyScheduled = false;
            ConstraintDate = null; // assume not there
            ConstraintType = '';
            BaselineEndDate = '';
            BaselineStartDate = '';
            BaselineDuration = '';
            TemplateName = '';
            children = null;
            expanded = false;  // need to set TRUE if AG otherwise importer will not iterate under it
            leaf = true;
            Duration = 1;
            DurationUnit = 'd';
            leankorKBCId = '';
            LongId = '';
            return;
        }

        // PG activity inner class constructor .....with init variables
        public Task(Integer inId, // when we create KBC objects they are wrappered with an Integer ID automatically
            String inName, 
            String inTemplateName, 
            Datetime inStartDateTime, 
            Datetime inDueDateTime, 
            Decimal inDuration, 
            String inDurationUnits, // Minutes, Hours, Days, Weeks, Months, Years
            Decimal inPercentComplete, 
            Boolean inIsMilestone, 
            Boolean inIsActivityGroup,
            String leankorId,
            String prettyId) {
            
            Id = inId;
            Name = inName;
            TemplateName = inTemplateName;
            StartDate = inStartDateTime.format(DATETIME_FORMAT);
            EndDate = inDueDateTime.format(DATETIME_FORMAT);
            Duration = inDuration != null ? Math.round(inDuration) : 0;
            DurationUnit = TIMEUNITS_MAP.get(inDurationUnits);
            PercentDone = inPercentComplete;
            Milestone = inIsMilestone;
            leaf = !inIsActivityGroup;
            children = null;

            // not sure how to set the rest of these
            Rollup = false;
            ManuallyScheduled = false;
            ConstraintDate = null; // assume not there
            ConstraintType = '';
            BaselineEndDate = '';
            BaselineStartDate = '';
            BaselineDuration = '';       
            expanded = false;

            // extended metadata
            leankorKBCId = leankorId;
            LongId = prettyId;

            return;
        }

        // KB Card inner class constructor .....with init variables
        public Task(Integer inId, // when we create KBC objects they are wrappered with an Integer ID automatically
            String inName, 
            String inTemplateName, 
            Datetime inStartDateTime, 
            Datetime inDueDateTime, 
            Decimal inDuration, 
            String inDurationUnits, // Minutes, Hours, Days, Weeks, Months, Years
            Decimal inPercentComplete, 
            Boolean inIsMilestone,   // even the KB now has milestones in CV mode
            String leankorId) {
            
            Id = inId;
            Name = inName;
            TemplateName = inTemplateName;
            StartDate = inStartDateTime.format(DATETIME_FORMAT);
            EndDate = inDueDateTime.format(DATETIME_FORMAT);
            Duration = inDuration != null ? Math.round(inDuration) : 0;
            DurationUnit = TIMEUNITS_MAP.get(inDurationUnits);
            PercentDone = inPercentComplete;
            Milestone = inIsMilestone;
            children = null;
            
            // extended metadata
            leankorKBCId = leankorId;

            return;
        }

        // public get children so others can add more children to it
        List<Task> getChildren() {
            return this.children;
        }

        // make this an AG
        public void makeActivityGroup() {
            this.expanded = true;  // the import utility does not look under the Task for children unless this is set
        }

    }


     //
    // Includes extended metadata
    //
    private class LeanAgileCard {
        Integer Id;
        String Name;
        String StartDate;
        String EndDate;
        Decimal Duration;
        String DurationUnit;    //  supported names are: [m, h, d, w, mo, %, y, em, eh, ed, ew, emo, ey, e%]
                                // but the Gantt needs minutes to be marked as "mi" and not "m" ("m" means months in the Gantt)
        Decimal PercentDone; // 0 to 100 ; can be 24.5 as example
        Boolean Milestone;
        String TemplateName; // null if not there
        List<LeanAgileCard> children; // null if doesn't have children
        Boolean leaf; // true if no children; otherwise if children, make false

        String ColumnName;
        String SwimlaneName;
        String SubColumnName;
        String Priority;
        Integer StoryPoints;
        String OnScheduleIndicator;
        String OnBudgetIndicator;
        String OnQualityIndicator;

        // extended metadata here
        String leankorKBCId;        // the leankor__kanbancard__c ID

        // inner class constructor to create empty Task
        public LeanAgileCard() {
            Id = taskIdGenerator;
            Milestone = false;
            TemplateName = '';
            children = null;
            leaf = true;
            Duration = 1;
            DurationUnit = 'd';
            ColumnName = '';
            SwimlaneName = '';
            SubColumnName = '';
            Priority = '';
            StoryPoints = 0;
            OnScheduleIndicator = '';
            OnBudgetIndicator = '';
            OnQualityIndicator = '';
            leankorKBCId = '';
            return;
        }

        // KB Card inner class constructor .....with init variables
        public LeanAgileCard(Integer inId, // when we create KBC objects they are wrappered with an Integer ID automatically
            String inName, 
            String inTemplateName, 
            Datetime inStartDateTime, 
            Datetime inDueDateTime, 
            Decimal inDuration, 
            String inDurationUnits, // Minutes, Hours, Days, Weeks, Months, Years
            Decimal inPercentComplete, 
            Boolean inIsMilestone,   // even the KB now has milestones in CV mode
            String inColumnName, // leankor__MasterContainer__r.Name
            String inSwimlaneName, // leankor__Swimlane__r.Name
            String inZoneName, //  leankor__Zone__r.Name
            String inPriority, // 'High', 'Medium', 'Low'
            Integer inPoints, // leankor__Point__c which is the Story Points
            String inOnTimeColor, // Red, Amber, Green
            String inOnBudgetColor, 
            String inOnQualityColor,
            String leankorId) {
            
            Id = inId;
            Name = inName;
            TemplateName = inTemplateName;
            StartDate = inStartDateTime.format(DATETIME_FORMAT);
            EndDate = inDueDateTime.format(DATETIME_FORMAT);
            Duration = inDuration != null ? Math.round(inDuration) : 0;
            DurationUnit = TIMEUNITS_MAP.get(inDurationUnits);
            PercentDone = inPercentComplete;
            Milestone = inIsMilestone;
            children = null;
            leaf = true;

            // KB Card metadata
            ColumnName = inColumnName;
            SwimlaneName = inSwimlaneName;
            SubColumnName = inZoneName;
            Priority = inPriority;
            StoryPoints = inPoints;
            OnScheduleIndicator = inOnTimeColor;
            OnBudgetIndicator = inOnBudgetColor;
            OnQualityIndicator = inOnQualityColor;
            
            // extended metadata
            leankorKBCId = leankorId;

            return;
        }

        // public get children so others can add more children to it
        List<LeanAgileCard> getChildren() {
            return this.children;
        }

        // make this an AG
        public void makeActivityGroup() {
            this.leaf = false;  // the import utility does not look under the Task for children unless this is set
        }

    }


    private class TaskMetadata {
        String projectStartDate;  // does it really matter?
        Boolean cascadeChanges;  // not entirely sure what to use

        //inner class constructor
        public TaskMetadata() {
            cascadeChanges = true;  
            return;
        }

        // set up the project start datetime given a Date
        public void setProjectStart(Date inPrjStart) {
            if (inPrjStart == null) return;
            projectStartDate = (Datetime.newInstance(inPrjStart, Time.newInstance(8,0,0,0))).format(DATETIME_FORMAT);
            return;
        }
    }

    // note Tasks and Task are two different classes...fun 
    private class Tasks {
        List<Task> children;
        String Name;  // apparently allways "Root Node"
        TaskMetadata metaData;

        //inner class constructor
        public Tasks() {
            children = new List<Task>();
            Name = 'Root Node';
            metaData = new TaskMetadata();
        }

        // return the task array
        public List<Task> getTaskList() {
            return this.children;
        }

        // set the project start datetime with a date
        public void setProjectStart(Date inProjectStart) {
            if (this.metaData == null || inProjectStart == null) return;
            this.metaData.setProjectStart(inProjectStart);
            return;
        }

    }

     // note LeanAgileCards and LeanAgileCard are two different classes...fun 
     private class LeanAgileCards {
        List<LeanAgileCard> children;
        String Name;  // something descriptive like maybe the Board Name
        TaskMetadata metaData;

        //inner class constructor
        public LeanAgileCards() {
            children = new List<LeanAgileCard>();
            Name = 'Kanban Board';
            metaData = new TaskMetadata();
        }

        // return the task array
        public List<LeanAgileCard> getLeanAgileCardList() {
            return this.children;
        }

        // set the project start datetime with a date
        public void setProjectStart(Date inProjectStart) {
            if (this.metaData == null || inProjectStart == null) return;
            this.metaData.setProjectStart(inProjectStart);
            return;
        }
    }

    // generates unique integers for use in building Dependencies
    static private Integer dependencyIdGenerator{
        get {
            if (dependencyIdGenerator == null) {
                dependencyIdGenerator = 1;
                return 1;  
            } else {
                return ++dependencyIdGenerator;
            }
        } 
        set {
            dependencyIdGenerator = value;
        }
    }

    private class Dependency {
        Integer Id;
        Integer To;
        Integer Fromx; // apparently "From" is not allowed in Apex so we will need to do string replace inside the JSON after-the-fact !!
        Integer Lag;
        String LagUnit;  // TimeUnit supported names are: [m, h, d, w, mo, %, y, em, eh, ed, ew, emo, ey, e%]
                        // but the Gantt needs minutes to be marked as "mi" and not "m" ("m" means months in the Gantt)
        Integer Type; // FF = 3, FS = 2, SF = 1, SS = 0

        //inner class constructor
        public Dependency(Integer inId, Integer inTheTo, Integer inFrom, Integer inLag, String inLagUnit, String inType) {
            Id = inId;
            To = inTheTo;
            Fromx = inFrom;
            Lag = inLag;
            LagUnit = TIMEUNITS_MAP.get(inLagUnit);
            Type = LAGUNITS_MAP.get(inType);

            return;
        }
    }


    // generates unique integers for use in building Resources
    static private Integer assignmentIdGenerator{
        get {
            if (assignmentIdGenerator == null) {
                assignmentIdGenerator = 1;
                return 1;  
            } else {
                return ++assignmentIdGenerator;
            }
        } 
        set {
            assignmentIdGenerator = value;
        }
    }


    //
    // Now contains extended metadata to hold resource assignments to tasks
    //
    private class Assignment {
        Integer assignmentId;                     // autogenerated 
        Integer resourceId;             // this is using the autoP-gen numbering scheme
        Integer taskId;                 // this is using the auto-gen numbering of task
        Integer units; // apparently not a String !

        // extended metadata
        String leankorUserId;           // the User ID one of this or the one below but NOT BOTH
        String leankorResourceTypeId;   // the leankor__resourcetype__c ID 
        String leankorKBCId;            // the leankor__kanbancard__c ID
        Decimal leankorAllocation;      // percent allocated where 1.0 is 100% and 0.50 is 50%
        Decimal leankorPercDone;        // percent completed where 1.0 is 100% etc.. 

        // inner class  constructor
        public Assignment(Integer resNum, Integer taskNum, String usr, String restype, String kbc, Decimal alloc, Decimal perc) {
            this.assignmentId = assignmentIdGenerator;
            this.leankorUserId = usr;
            this.leankorResourceTypeId = restype;
            this.leankorKBCId = kbc;
            this.leankorPercDone = perc;
            this.leankorAllocation = alloc;
            this.resourceId = resNum;
            this.taskId = taskNum;
            return;
        }
    }


    // generates unique integers for use in building Resources
    static private Integer resourceIdGenerator{
        get {
            if (resourceIdGenerator == null) {
                resourceIdGenerator = 1;
                return 1;  
            } else {
                return ++resourceIdGenerator;
            }
        } 
        set {
            resourceIdGenerator = value;
        }
    }

    // 
    // includes specific extended metadata as well
    //
    private class Resource {
        public Integer resourceId;             // generated incrementor 
        public String resourceName;            // unclear usage; likely put leankor__resource__c.Name in here

        // Extended metadata
        public String leankorResourceTypeId;       // force.com ID from leankor__resourceType__c
        public String leankorUserId;               // force.com ID from User object lookup on the leankor__resource__c record

        // constructor
        public Resource(String resType, String usr, String aName) {
            this.resourceId = resourceIdGenerator;
            this.leankorResourceTypeId = resType;
            this.leankorUserId = usr;
            this.resourceName = aName;
            return;
        }
    }

    private class Column {
        String xtype;  // much more complex than just this option, but nonetheless make it null if no column definition available

        public Column() {
            xtype = null;
            return;
        }
    }

    private class LeankorJSON {
        public Calendars calendars;
        public Tasks tasks;
        public List<Dependency> dependencies;
        public List<Assignment> assignments;
        public List<Resource> resources;
        public List<Column> columns;

        // inner class constructor ... seems like Bryntum wants proper empty arrays if none are to be placed in the file vs. putting NULL
        public LeankorJSON() {
            calendars = new MultipleExportProjectBoardAction.Calendars();
            tasks = new MultipleExportProjectBoardAction.Tasks();
            dependencies = new List<MultipleExportProjectBoardAction.Dependency>();
            assignments = new List<MultipleExportProjectBoardAction.Assignment>();
            resources = new List<MultipleExportProjectBoardAction.Resource>();
            columns = new List<MultipleExportProjectBoardAction.Column>();
            return;
        }

        // set project start datetime with a date
        Public void setProjectStartDate(Date inProjDate) {
            if (this.tasks == null) return;
            this.tasks.setProjectStart(inProjDate);
            return;
        }
    }

    private class LeankorLeanAgileJSON {
        public Calendars calendars;
        public LeanAgileCards cards;
        public List<Dependency> dependencies;
        public List<Assignment> assignments;
        public List<Resource> resources;

        // inner class constructor ... seems like Bryntum wants proper empty arrays if none are to be placed in the file vs. putting NULL
        public LeankorLeanAgileJSON() {
            calendars = new MultipleExportProjectBoardAction.Calendars();
            cards = new MultipleExportProjectBoardAction.LeanAgileCards();
            dependencies = new List<MultipleExportProjectBoardAction.Dependency>();
            assignments = new List<MultipleExportProjectBoardAction.Assignment>();
            resources = new List<MultipleExportProjectBoardAction.Resource>();
            return;
        }

        // set project start datetime with a date
        public void setProjectStartDate(Date inProjDate) {
            if (this.cards == null) return;
            this.cards.setProjectStart(inProjDate);
            return;
        }
    }
    //------------------------------ end JSON export classes ----------------------------


    //---------------------  data access helper methods **** ALL DATABASE ACCESS HERE ****** ----------------------------------------------------------

    // helper to strip out soft deleted records in a list of objects 
    // nobody actually uses this class though as it is virtual --> use one of the extensions below it please 
    private virtual class ListCleaner {
        private List<SObject> myList;

        // default constructor but not really for use 
        public ListCleaner() {
            this.myList = null;
        }

        // should really use this constructor
        public ListCleaner(List<SObject> inList) {
            this.myList = inList;
        }

        // uses implementation of isOK() to properly rid the list of objects of soft deleted
        public void cleanList() {
            List<SObject> killList = new List<SObject>();

            // punch out if someone calls me before initializing properly
            if (this.myList == null) return;

            // magic of virtual methods revealed here !
            for (SObject oneObj : this.myList) {
                if (isSoftDeleted(oneObj)) {
                    killList.add(oneObj);
                }
            }

            // clean up stuff
            for (SObject killIt : killList) {
                this.myList.remove(this.myList.indexOf(killIt));
            }

            return;
        }

        // override this method an return true if the record is found to be soft deleted
        public virtual Boolean isSoftDeleted(SObject inObj) {
            return false;
        }
    }

    // helper implementation for KBC (activities, milestones)
    private class KBCCleaner extends ListCleaner {
        // type-specific constructor
        public KBCCleaner (List<leankor__KanbanCard__c> inList) {
            super((List<SObject>)inList);
        }

        // can cast to KBC since we know that's the whole point of this override
        public override Boolean isSoftDeleted(SObject inObj) {
            leankor__KanbanCard__c myKBC;

            myKBC = (leankor__KanbanCard__c)inObj;

            if (myKBC.leankor__ValueStream__c == null || myKBC.leankor__ValueStream__r.leankor__ProjectRoom__c  == null) {
                return true;
            } else {
                return false;
            }
        }
    }

    // helper implementation for dependencies
    private class DependencyCleaner extends ListCleaner {
        // type-specific constructor
        public DependencyCleaner (List<leankor__Dependency__c> inList) {
            super((List<SObject>)inList);
        }

        // can cast to Dependency since we know that's the whole point of this override
        public override Boolean isSoftDeleted(SObject inObj) {
            leankor__Dependency__c myDep;

            myDep = (leankor__Dependency__c)inObj;

            // hunting for missing or soft-deleted parents... as well as cross-PG dependencies which are not yet supported
            if (myDep.leankor__Successor__c == null 
            || myDep.leankor__Successor__r.leankor__ValueStream__c == null 
            || myDep.leankor__Predecessor__c == null 
            || myDep.leankor__Predecessor__r.leankor__ValueStream__c == null 
            || myDep.leankor__Predecessor__r.leankor__ValueStream__c != myDep.leankor__Successor__r.leankor__ValueStream__c
            || myDep.leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c == null
            || myDep.leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c == null) {
                return true;
            } else {
                return false;
            }
        }
    }


    // helper implementation for valuestreams
    private class ValueStreamCleaner extends ListCleaner {
        // type-specific constructor
        public ValueStreamCleaner (List<leankor__ValueStream__c> inList) {
            super((List<SObject>)inList);
        }

        public override Boolean isSoftDeleted(SObject inObj) {
            leankor__ValueStream__c myValueStream;

            myValueStream = (leankor__ValueStream__c)inObj;

            // hunting for missing or soft-deleted parents...
            if (myValueStream.leankor__ProjectRoom__c == null) {
                return true;
            } else {
                return false;
            }
        }
    }


    // sets up a single VS record for export
    private with sharing class ValueStream {
        private leankor__ValueStream__c myVs = null;
        public Boolean isFound = false;

        // inner class constructor loads the VS record or sets isFound false if some issue
        public ValueStream(ID vsId) {
            if (myVs != null) {
                return;
            }

            try {
                myVs = [Select Id, 
                                Name, 
                                leankor__ProjectRoom__c, 
                                leankor__BoardType__c,
                                leankor__ProjectRoom__r.leankor__StartDate__c   
                            From leankor__ValueStream__c 
                            Where Id = :vsId
                                And leankor__isRecordDeleted__c = false
                            With Security_Enforced
                            Limit 1];

                isFound = myVs != null && myVs.leankor__ProjectRoom__c != null;
            } catch (Exception ex) {
                System.debug('Leankor Export: Could not get Valuestream record, ' + ex.getMessage());
                myVs = null;
                isFound = false;
            }

            return; 
        }

        // determines if the VS record is that of a PG
        public Boolean isPG() {
            return myVs.leankor__BoardType__c == BOARD_TYPE_PG;
        }

        // determines if the VS record is that of a PG
        public Boolean isKB() {
            return myVs.leankor__BoardType__c == BOARD_TYPE_KB || myVs.leankor__BoardType__c == BOARD_TYPE_RU;
        }

        // get the ID of this VS record
        public ID getID() {
            return myVs != null ? myVs.Id : null;
        }

        // get the start date
        public Date getProjectStartDate() {
            return myVs != null ? myVs.leankor__ProjectRoom__r.leankor__StartDate__c : null;
        }
    }


    // container for a signle KBC or Activity/Milestone on a PG 
    // in future may need to create a base class then layer on KB-specific and Gantt-specific attributes/methods
    private class KanbanCard {
        private leankor__KanbanCard__c myKC = null;
        private KanbanCard parentAGLink = null;
        private List<KanbanCard> children = null;
        public Integer Id {get;set;}
        public Boolean isKanbanBoard {get; set;}  // good to know sometimes if we are working on a Kanban Board vs PG

        // inner class constructor
        public KanbanCard(leankor__KanbanCard__c someKC) {
            myKC = someKC;
            this.Id = taskIdGenerator;  // turns out the ID's in export file need to be unique but simple whole numbers

            if (someKC.leankor__ValueStream__r.leankor__BoardType__c == BOARD_TYPE_KB || 
                someKC.leankor__ValueStream__r.leankor__BoardType__c == BOARD_TYPE_RU) {
                this.isKanbanBoard = true;
            } else {
                this.isKanbanBoard = false;
            }

            return;
        }

        // returns true if we think this is an activity with AG parent
        public Boolean hasParent() {
            return (myKC.leankor__ValueStreamCardLink__c != null);
        }

        // return true if has children
        public Boolean hasChildren() {
            return this.children != null;
        }

        // return the children
        public List<KanbanCard> getChildren() {
            return this.children;
        }

        // link this KBC / activity to its AG parent then...
        // add this object to the parent's children colleciton
        // NOTE: Only call this after the full PG or KB Board is loaded into the Map
        public void linkParentAG(Map<Id, KanbanCard> someMap) {

                parentAGLink = someMap.get(myKC.leankor__ValueStreamCardLink__c);
                if (parentAGLink == null) return; // for example if we are on a KB Board and the card is linked on a DIFFERENT board, we would not find it in the map

                // we got here, so did find the parent and we now link it
                if (parentAGLink.children == null) parentAGLink.children = new List<KanbanCard>();
                parentAGLink.children.add(this);

                return;
        }

        // access the leankor__kanbancard__c Id value
        public String getKBCId() {
            return this.myKC.Id;
        }

        // access Name
        public String getName() {
            return this.myKC.Name;
        }

        // access category
        public String getCategory() {
            return this.myKC.leankor__KanbanCardTemplate__r.Name;
        }

        // access start date
        public Datetime getStartDatetime() {
            return this.myKC.leankor__StartDateTime__c;
        }

        // access due date 
        public Datetime getDueDatetime() {
            return this.myKC.leankor__DueDateTime__c;
        }

        // access duration
        public Decimal getDuration() {
            return this.myKC.leankor__EstimatedDuration__c;
        }

        // access duration units
        public String getDurationUnits() {
            return this.myKC.leankor__DurationUnits__c;
        }

        // access percentage of activity complete
        public Decimal getPercentComplete() {
            return this.myKC.leankor__PercentComplete2__c;
        }

        // access nice ID like 2.3.5
        public String getPrettyId() {
            return this.myKC.leankor__CardID__c;
        }

        // determine if milestone
        public Boolean isMilestone() {
            try {
                return KBC_TYPES.get(this.myKC.RecordTypeId).getDeveloperName() == KBC_MILESTONE;
            } catch (Exception ex) {
                return false;
            }
        }

        // determine if activity group
        public Boolean isActivityGroup() {
            try {
                return KBC_TYPES.get(this.myKC.RecordTypeId).getDeveloperName() == KBC_ACTIVITYGROUP;
            } catch (Exception ex) {
                return false;
            }
        }

        // ------------------------------- Kanban Card on KB Boards Accessors ----------------------
        public String getKBColumn() {
            return this.myKC.leankor__MasterContainer__r.Name;
        }

        public String getKBSwimlane() {
            if (this.myKC.leankor__Swimlane__r != null && this.myKC.leankor__Swimlane__r.Name != null) {
                return this.myKC.leankor__Swimlane__r.Name;
            } else {
                return '';
            }
        }

        public String getKBZone() {
            if (this.myKC.leankor__Zone__r != null && this.myKC.leankor__Zone__r.Name != null) {
                return this.myKC.leankor__Zone__r.Name;
            } else {
                return '';
            }
        }

        public String getKBPriority() {
            if (this.myKC.leankor__Priority__c == 1) {
                return 'High';
            } else if (this.myKC.leankor__Priority__c == 2) {
                return 'Medium';
            } else {
                return 'Low';
            }
        }

        public Integer getKBPoints() {
            return (Integer)this.myKC.leankor__Point__c;
        }

        public String getKBOnTimeColor() {
            return this.myKC.leankor__OnTime__c;
        }

        public String getKBOnBudgetColor() {
            return this.myKC.leankor__OnBudget__c;
        }

        public String getKBOnQualityColor() {
            return this.myKC.leankor__OnQuality__c;
        }

    }

    // main class to execute SOQL to build out list of activities, activity groups, milestones etc... 
    // ALSO: saves all Resources and Resource Assignments here
    private with sharing class KanbanCardList {
        private List<KanbanCard> myKCList = null;
        private Map<Id, KanbanCard> myKCMap = new Map<Id, KanbanCard>();
        private Map<Integer, String> myIdToKBCIdMap = new Map<Integer, String>();
        private Map<String, Integer> myKBCIdToIdMap = new Map<String, Integer>();
        public Boolean isKanbanBoard {get; set;}  // is this a list of cards on a Kanban Board vs PG

        // augmented metadata
        private MultipleExportProjectBoardAction.AResourceList resList = new MultipleExportProjectBoardAction.AResourceList();
        private MultipleExportProjectBoardAction.AResourceAssignmentList resAssignList = new MultipleExportProjectBoardAction.AResourceAssignmentList();

        // for PG: build AG links after the myKCMap is fully populated (not before)
        // for KB Board: if the KB cards are linked to parents, we build the linkages here but cards might be linked to another board !
        private void createHierarchy() {
            List<KanbanCard> toRemove = new List<KanbanCard>();

            for (KanbanCard aKBC : myKCList) {
                if (aKBC.hasParent()) {
                    aKBC.linkParentAG(myKCMap);
                    if (!this.isKanbanBoard) toRemove.add(aKBC); // clean up the array later; but only if PG
                }
            }

            // once fully processed, this list should only contain top level AG or Activities/Milestones
            for (KanbanCard iKBC : toRemove) {
                myKCList.remove(myKCList.indexOf(iKBC));
            }
             
            return;
        }

        // returns set of KBC Id's for use in other SOQL
        // returns empty set if nothing there so can be used inline of SOQL WHERE clause still
        public Set<Id> getKBCIDSet() {
            if (myKCMap != null && myKCMap.isEmpty() == false) {
                return myKCMap.keySet();
            }
            
            return new Set<Id>();
        }

        //return the top level list of kbc
        public List<MultipleExportProjectBoardAction.KanbanCard> getKBCList() {
            return this.myKCList;
        }

        //return the Map of kbc
        public Map<Id, MultipleExportProjectBoardAction.KanbanCard> getKBCMap() {
            return this.myKCMap;
        }

        // inner class constructor: get from database and build linkages
        public KanbanCardList(ValueStream someVS) {
            List<leankor__KanbanCard__c> kbList = null;
            KBCCleaner kc = null;
            this.isKanbanBoard = someVS.isKB();

            // get KC's from the database which are not soft deleted
            try {
                kbList = [Select Id,
                                Name,
                                RecordTypeId,
                                leankor__CardID__c,
                                leankor__StartDateTime__c,
                                leankor__DueDateTime__c,
                                leankor__EstimatedDuration__c,
                                leankor__DurationUnits__c,
                                leankor__PercentComplete2__c,
                                leankor__DescriptionLong__c,
                                leankor__MasterContainer__r.Name, // next 8 only used on KB export; not PG export
                                leankor__Swimlane__r.Name,
                                leankor__Zone__r.Name,
                                leankor__Priority__c,
                                leankor__Point__c,
                                leankor__OnTime__c,
                                leankor__OnBudget__c,
                                leankor__OnQuality__c,
                                leankor__ValueStream__c,
                                leankor__KanbanCardTemplate__r.Name,
                                leankor__ValueStreamCardLink__c,
                                leankor__ValueStreamLink__c,
                                leankor__ValueStream__r.leankor__BoardType__c,
                                leankor__ValueStream__r.leankor__ProjectRoom__c,
                                (Select Id,
                                        leankor__ResourceType__c,       // leankor__resourcetype__c Id
                                        leankor__PercentAllocation__c,  // whole number 1 - 100
                                        leankor__PercentCompleted__c,   // whole number 1 - 100
                                        leankor__AssignedTo__c,         // User Id
                                        leankor__AssignedTo__r.Name,    // User name
                                        leankor__ResourceType__r.Name   // leankor__resourcetype__c.Name 
                                    From leankor__ResourceAssignments__r) 
                            From leankor__KanbanCard__c
                            Where leankor__ValueStream__c = :someVS.getID() 
                                And leankor__isRecordDeleted__c = false
                                And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                            With Security_Enforced    
                            Order By leankor__CardID__c
                            Limit 50000];

            } catch (Exception ex) {
                System.debug('Leankor Export: Could not get activities from database, ' + ex.getMessage());
                return;
            }
            
            if (kbList == null) {
                return;
            } else {
                // clean up soft deletes
                kc = new KBCCleaner(kbList);
                kc.cleanList();
            }

            // throw them in to a custom List object
            // and create maps to go from internally generated simple ID's to database ID's
            myKCList = new List<MultipleExportProjectBoardAction.KanbanCard>();

            for (leankor__KanbanCard__c aKBC : kbList) {
                KanbanCard myKC = new KanbanCard(aKBC);
                myKCList.add(myKC);
                myKCMap.put(aKBC.Id, myKC);
                myIdToKBCIdMap.put(myKC.Id, myKC.getKBCId());
                myKBCIdToIdMap.put(myKC.getKBCId(), myKC.Id);

                // process resources and resource assignments
                if (aKBC.leankor__ResourceAssignments__r != null && aKBC.leankor__ResourceAssignments__r.size() > 0) {
                    for(leankor__ResourceAssignment__c ra: aKBC.leankor__ResourceAssignments__r) {

                        MultipleExportProjectBoardAction.AResource aRes = new MultipleExportProjectBoardAction.AResource(
                                ra.leankor__AssignedTo__c, 
                                ra.leankor__ResourceType__c, 
                                String.isBlank(ra.leankor__AssignedTo__c) ? ra.leankor__ResourceType__r.Name : ra.leankor__AssignedTo__r.Name);

                        this.resList.addResource(aRes);
                        
                        MultipleExportProjectBoardAction.AResourceAssignment aResAssign = new MultipleExportProjectBoardAction.AResourceAssignment(
                                ra.leankor__ResourceType__c, 
                                aKBC.Id, 
                                ra.leankor__PercentAllocation__c, 
                                ra.leankor__PercentCompleted__c,
                                ra.leankor__AssignedTo__c);

                        this.resAssignList.addResourceAssignment(aResAssign);
                    }
                }
            }

            // create the parent hierarchy once the myKCList and myKCMap are fully populated
            createHierarchy();
           
            return;
        }
    }

    //
    // augmented metadata --------------------------------------
    //
    private class AResource {
        public String userId {
            get{return userId;}
            set{userId = value;}
        }

        public String resTypeId {
            get{return resTypeId;}
            set{resTypeId = value;}
        }

        public String Name {
            get{return Name;}
            set{Name = value;}
        }

        public AResource(String res, String resType, String aName) {
            this.userId = res;
            this.resTypeId = resType;
            this.Name = aName;
            return;
        }

    }


    private class AResourceList {
        private List<MultipleExportProjectBoardAction.AResource> resList = new List<MultipleExportProjectBoardAction.AResource>();
        private Map<String, MultipleExportProjectBoardAction.AResource> resMap = new Map<String, MultipleExportProjectBoardAction.AResource>();

        public AResourceList() {
            return;
        }

        public void addResource(AResource res) {
            String myId = String.isBlank(res.userId) ? res.resTypeId : res.userId;

            if ((resMap.size() == 0) || (resMap.get(myId) == null)) {
                resList.add(res);
                resMap.put(myId, res);
            }
            return;
        }

        public List<MultipleExportProjectBoardAction.AResource> getResourceList() {
            return this.resList;
        }

        public Map<String, MultipleExportProjectBoardAction.AResource> getResourceMap() {
            return this.resMap;
        }
    }


    private class AResourceAssignment {

        public String resourceTypeId {get; set;}
        public String leankorKBCId {get; set;}
        public String userId {get; set;}
        public Decimal percentAllocation {
            get {return percentAllocation;}
            set {percentAllocation = value/100;}
        }
        public Decimal percentComplete {
            get{return percentComplete;}
            set {percentComplete = value/100;} 
        }

        public AResourceAssignment(String resType, String kbcId, Decimal alloc, Decimal complete, String userdbId) {
            this.resourceTypeId = resType;
            this.leankorKBCId = kbcId;
            this.percentAllocation = alloc;
            this.percentComplete = complete;
            this.userId = userdbId;
            return;
        }

    }

    private class AResourceAssignmentList {
        private List<MultipleExportProjectBoardAction.AResourceAssignment> resAssignList = new List<MultipleExportProjectBoardAction.AResourceAssignment>();
        
        public AResourceAssignmentList() {
            return;
        }

        public void addResourceAssignment(AResourceAssignment resAssign) {
            this.resAssignList.add(resAssign);
            return;
        }

        public List<MultipleExportProjectBoardAction.AResourceAssignment> getResourceAssignmentList() {
            return this.resAssignList;
        }

    }

    //
    // augmented metadata --------------------------------------
    //

    private class ADependency {
        public Integer Id {get;set;}

        private leankor__Dependency__c myDep = null;
        private KanbanCard predecessor = null;
        private KanbanCard successor = null;

        // constructor for Dependency object
        public ADependency(leankor__Dependency__c someDep, Map<Id, MultipleExportProjectBoardAction.KanbanCard> inMap) {
            if (someDep == null || inMap == null || inMap.size() == 0) return;
            this.myDep = someDep;
            this.Id = dependencyIdGenerator;
            this.predecessor = inMap.get(someDep.leankor__predecessor__c);
            this.successor = inMap.get(someDep.leankor__successor__c);
            return;
        }

        // get KB predencessor and successor ID's 
        public Integer getPredecessorId() {
            if (this.predecessor == null) return 0;
            return this.predecessor.Id;
        }

        public Integer getSuccessorId() {
            if (this.successor == null) return 0;
            return this.successor.Id;
        }

        // get the lag
        public Integer getLag() {
            if (this.myDep == null) return 0;
            return Math.round(this.myDep.leankor__LagLead__c);
        }

        // get the Lag unit of measure string which is just a string in the database ; not picklist
        public String getLagUnit() {
            if (this.myDep == null) return '';
            return this.myDep.leankor__LagLeadUnit__c;
        }

        // get the type of lag which in the database can be one of 
        // "Start_To_Start", "Start_To_Finish", "Finish_To_Start", "Finish_To_Finish"
        // seems like there is a type for both successor and predecessor which doesn't make much sense 
        // ... far as I can tell only the successor type is used by Leankor
        public String getDependencyType() {
            if (this.myDep == null) return '';
            return this.myDep.leankor__SuccessorType__c;
        }
    }

    private with sharing class DependencyList {
        private List<MultipleExportProjectBoardAction.ADependency> myDepList = null; 

        // constructor for the Dep List
        Public DependencyList(ValueStream someVS, KanbanCardList kbcList) {
            List<leankor__Dependency__c> depList = null;
            DependencyCleaner dc = null;
            
            // get dep's from the database which are not soft deleted
            // TODO: look for soft deleted KBC after the list is built and remove them
            try {
                depList = [Select Id,
                                leankor__Predecessor__c,
                                leankor__PredecessorType__c,
                                leankor__Successor__c,
                                leankor__SuccessorType__c,
                                leankor__LagLead__c,
                                leankor__LagLeadUnit__c,
                                leankor__Successor__r.leankor__ValueStream__c,
                                leankor__Predecessor__r.leankor__ValueStream__c,
                                leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
                                leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c
                            From leankor__Dependency__c
                            Where leankor__ValueStream__c = :someVS.getId() 
                                And leankor__Predecessor__r.leankor__isRecordDeleted__c = false 
                                And leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                And leankor__Successor__r.leankor__isRecordDeleted__c = false 
                                And leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                            With Security_Enforced
                            Limit 50000];
            } catch (Exception ex) {
                System.debug('Leankor Export: Could not get dependencies from database, ' + ex.getMessage());
                return;
            }
            
            if (depList == null) {
                return;
            } else {
                // clean up soft deletes
                dc = new DependencyCleaner(depList);
                dc.cleanList();
            }

            // throw them in to a custom List object
            myDepList = new List<MultipleExportProjectBoardAction.ADependency>();
            for (leankor__Dependency__c aDep : depList) {
                ADependency myDep = new ADependency(aDep, kbcList.getKBCMap());
                myDepList.add(myDep);
            }

            return;
        }

        // do i have any dependencies ?
        public Boolean hasDependency() {
            if (myDepList != null && myDepList.size() > 0) return true;
            return false;
        }

        // return the list to whomever
        public List<MultipleExportProjectBoardAction.ADependency> getDepList() {
            return myDepList;
        }
    }
    //---------------------  end data access helper methods ---------------------------------------------------------------


    //------------------- BEGIN platform event helper -------------------------------------
    private class ExportPlatformEvent {
        private leankor__ProjectEvent__e myPe = null;

        // inner class constructors: just give me an event name and this will send it off with EventCategory of 'Export'
        public ExportPlatformEvent(String eventName, String prjId, String vsId) {
            if (myPe != null) {
                return;
            } else if (eventName == null || eventName.length() == 0) {
                return;
            }

            myPe = new leankor__ProjectEvent__e();
            
            myPe.leankor__EventCategory__c = 'Export';
            myPe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
            myPe.leankor__ProjectID__c = prjId;
            myPe.leankor__UserID__c = UserInfo.getUserId();
    
            sendEvent(eventName, vsId);

            return;
        }

        // sends a given export event 
        public void sendEvent(String eventName, String payload) {

            if (eventName == null || eventName.length() == 0 || myPe == null) {
                return;
            }

            if (payload == null) {
                payload = '';
            }

            myPe.leankor__EventName__c = eventName;
            myPe.leankor__CustomPayload__c =payload;
    
            // Call method to publish events
            Database.SaveResult pe_result = EventBus.publish(myPe);
    
            // quick error processing, no need to Rollback
            if (!pe_result.isSuccess()) {
                
                for(Database.Error err : pe_result.getErrors()) {
                    System.debug('Leankor Platform Event Error during Export: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            } 
            
            return;
            
        }

    }
    //------------------- END platform event helper  -------------------------------------


    //------------------- Export PG and KB -------------------------------------

    // recursive, ordered deep dive of PG hierarchy
    @TestVisible
    private static void buildTasks(List<MultipleExportProjectBoardAction.KanbanCard> inKBCList, List<Task> inTaskList) {
        if (inKBCList == null) return;

        // in test situation, need 100% code coverage; even constructors never used here
        if (Test.isRunningTest()) {
            MultipleExportProjectBoardAction.Task testTask = new MultipleExportProjectBoardAction.Task();
        }

        for(KanbanCard myKBC : inKBCList) {
            Task heapTask = new Task(myKBC.Id, 
                                    myKBC.getName(),
                                    myKBC.getCategory(),
                                    myKBC.getStartDatetime(),
                                    myKBC.getDueDatetime(),
                                    myKBC.getDuration(),
                                    myKBC.getDurationUnits(),
                                    myKBC.getPercentComplete(),
                                    myKBC.isMilestone(),
                                    myKBC.isActivityGroup(),
                                    myKBC.getKBCId(),
                                    myKBC.getPrettyId());

            inTaskList.add(heapTask);

            if (myKBC.hasChildren()) {
                heapTask.children = new List<Task>();
                heapTask.makeActivityGroup();
                buildTasks(myKBC.getChildren(), heapTask.getChildren());
            }
        }

        return;
    }

     // recursive, ordered deep dive of KB hierarchy
     @TestVisible
     private static void buildLeanAgileBoard(List<MultipleExportProjectBoardAction.KanbanCard> inKBCList, List<LeanAgileCard> inCardList) {
        if (inKBCList == null) return;

        // in test situation, need 100% code coverage; even constructors never used here
        if (Test.isRunningTest()) {
            MultipleExportProjectBoardAction.LeanAgileCard testCard = new MultipleExportProjectBoardAction.LeanAgileCard();
        }

        for(KanbanCard myKBC : inKBCList) {
            LeanAgileCard heapCard = new LeanAgileCard( myKBC.Id, 
                                                        myKBC.getName(),
                                                        myKBC.getCategory(),
                                                        myKBC.getStartDatetime(),
                                                        myKBC.getDueDatetime(),
                                                        myKBC.getDuration(),
                                                        myKBC.getDurationUnits(),
                                                        myKBC.getPercentComplete(),
                                                        myKBC.isMilestone(),
                                                        myKBC.getKBColumn(),
                                                        myKBC.getKBSwimlane(),
                                                        myKBC.getKBZone(),
                                                        myKBC.getKBPriority(),
                                                        myKBC.getKBPoints(),
                                                        myKBC.getKBOnTimeColor(),
                                                        myKBC.getKBOnBudgetColor(),
                                                        myKBC.getKBOnQualityColor(),
                                                        myKBC.getKBCId());

            inCardList.add(heapCard);

            if (myKBC.hasChildren()) {
                heapCard.children = new List<LeanAgileCard>();
                heapCard.makeActivityGroup();
                buildLeanAgileBoard(myKBC.getChildren(), heapCard.getChildren());
            }
        }

        return;
    }


    // build out dependencies in the JSON from the ones we found in database
    @TestVisible
    private static void buildDependencies(List<MultipleExportProjectBoardAction.ADependency> inDepList, List<MultipleExportProjectBoardAction.Dependency> jsonDepList) {
        if (inDepList == null || inDepList.size() == 0) return;
        MultipleExportProjectBoardAction.Dependency myNewDep = null;
        if (jsonDepList == null) new List<MultipleExportProjectBoardAction.Dependency>();

        for (MultipleExportProjectBoardAction.ADependency oneDep : inDepList) {
            //Integer inId, Integer inTo, Integer inFrom, Integer inLag, String inLagUnit, String inType
            myNewDep = new MultipleExportProjectBoardAction.Dependency(oneDep.Id, oneDep.getSuccessorId(), oneDep.getPredecessorId(), oneDep.getLag(), oneDep.getLagUnit(), oneDep.getDependencyType());
            jsonDepList.add(myNewDep);
        }
    }


    // build augmented metadata around resources
    @TestVisible
    private static void buildResources(List<MultipleExportProjectBoardAction.Resource> resList, List<MultipleExportProjectBoardAction.Assignment> assignList, MultipleExportProjectBoardAction.KanbanCardList kbcList) {
        // process the Resource list
        Map<String, Integer> leankorDBIdToLocalId = new Map<String, Integer>();
        for (MultipleExportProjectBoardAction.AResource aRes : kbcList.resList.getResourceList()) {
            MultipleExportProjectBoardAction.Resource res = new MultipleExportProjectBoardAction.Resource(aRes.resTypeId, aRes.userId, aRes.Name);
            resList.add(res);
            leankorDBIdToLocalId.put(String.isBlank(aRes.userId) ? aRes.resTypeId : aRes.userId, res.resourceId);
        }

        // process the Resource Assignment List
        for (MultipleExportProjectBoardAction.AResourceAssignment aResAssign : kbcList.resAssignList.getResourceAssignmentList()) {
            MultipleExportProjectBoardAction.Assignment assign = new MultipleExportProjectBoardAction.Assignment(leankorDBIdToLocalId.get(String.isBlank(aResAssign.userId) ? aResAssign.resourceTypeId : aResAssign.userId), 
                                                                            kbcList.myKBCIdToIdMap.get(aResAssign.leankorKBCId),    
                                                                            aResAssign.userId, 
                                                                            aResAssign.resourceTypeId, 
                                                                            aResAssign.leankorKBCId, 
                                                                            aResAssign.percentAllocation, 
                                                                            aResAssign.percentComplete);
            assignList.add(assign);
        }

        return;
    }


    //
    // exports a Plan Gantt specifically, crawling through everything including dependencies
    //
    @TestVisible
    private static String exportPGorKB(ValueStream expVS) {
        KanbanCardList kbcList = null;
        String exportJSON = '';
        String finalExportJSON = '';
        LeankorJSON exportObject;
        LeankorLeanAgileJSON exportKBObject;

        // build list via SOQL call
        kbcList = new KanbanCardList(expVS);
        exportObject = new LeankorJSON();
        exportKBObject = new LeankorLeanAgileJSON();

        // loop through kbcList building the tasks
        List<MultipleExportProjectBoardAction.KanbanCard> kbcListToExport = kbcList.getKBCList();
        if (kbcListToExport != null && kbcListToExport.size() >0) {
            if (expVS.isPG()) {
                buildTasks(kbcListToExport, exportObject.tasks.getTaskList());
            } else {
                buildLeanAgileBoard(kbcListToExport, exportKBObject.cards.getLeanAgileCardList());
            }
        }

        // build out dependencies if any
        DependencyList depList = new DependencyList(expVS, kbcList);
        if (depList != null && depList.hasDependency()) {
            if (expVS.isPG()) {
                buildDependencies(depList.getDepList(), exportObject.dependencies);
            } else {
                buildDependencies(depList.getDepList(), exportKBObject.dependencies);
            }
        }

        // build out resources and resource assignments as augmented metadata
        if (expVS.isPG()) {
            buildResources(exportObject.resources, exportObject.assignments, kbcList);
        } else {
            buildResources(exportKBObject.resources, exportKBObject.assignments, kbcList);
        }
       
        // set the project start date
        if (expVS.getProjectStartDate() != null) {
            if (expVS.isPG()) {
                exportObject.setProjectStartDate(expVS.getProjectStartDate());
            } else {
                exportKBObject.setProjectStartDate(expVS.getProjectStartDate());
            }
        } else {
            Datetime tempDT = System.now();
            if (expVS.isPG()) {
                exportObject.setProjectStartDate(date.newInstance(tempDT.year(), tempDT.month(), tempDT.day()));
            } else{
                exportKBObject.setProjectStartDate(date.newInstance(tempDT.year(), tempDT.month(), tempDT.day()));
            }
        }

        // create the JSON string
        try {
            exportJSON = expVS.isPG() ? JSON.serializePretty(exportObject, true) : JSON.serializePretty(exportKBObject, true);
        } catch (Exception ex) {
            return null;
        }

        // fix any field name issues due to reserved words in APEX
        if (exportJSON != null) {
            finalExportJSON = exportJSON.replace('"Fromx"', '"From"');
            exportJSON = null; // help the JVM garbage collector
            return finalExportJSON;
        }

        // if we are here, there's a big problem
        return null;
    }
    //------------------- End Export PG and KB   ----------------------------------


    //-------------------- FILE WRITER ---------------------------------------------
    @TestVisible
    private static String writeJSON(String inFileName, String inJSON) {
        ContentVersionBehaviour contentVersionBehaviour = new ContentVersionBehaviour();
        if (!contentVersionBehaviour.isCreateable() ) {
            throw new Util.LeanException('Error: No access to records');
        }
        ContentVersion cv;
        List<ContentVersion> cvDoc;
        String outFile;

        cv = new ContentVersion();
        cv.ContentLocation = CONTENT_LOC_SFDC;
        cv.VersionData = System.Blob.valueOf(inJSON);  // special chars must be escaped
        outFile = (inFileName != null && inFileName != '') ? inFileName : FILE_NAME;
        cv.Title = outFile;
        cv.PathOnClient = outFile + '.' + FILE_EXT;

        try {
            insert cv;
        } catch (DmlException ex) {
            System.debug('Leankor Export: Could not write file to Salesforce, ' + ex);
            return null;
        }

        // get DocumentId and then return the URL
        String baseUrl = 'https://' + DomainCreator.getOrgMyDomainHostname();
        String contentDocumentId = [Select ContentDocumentId 
                                        From ContentVersion 
                                        Where Id = :cv.Id 
                                        Limit 1].ContentDocumentId;

        // Construct the URL
        String fileUrl = baseUrl + '/lightning/r/ContentDocument/' + contentDocumentId + '/view';

        return fileUrl;
    }
    //--------------------- END FILE WRITER ---------------------------------------


    @TestVisible
    private static String getRecordId(String recordId, String objectName) {
        return recordId InstanceOf Id ? (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == objectName ? recordId : '') : '';
    }


    // 
    //--------------------  main invocation method starts here ------------------------------------------------------------
    //
    @InvocableMethod
    public static List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult> exportProjectBoardProcess(List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest> requests) {
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult> results = new List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult>();
        MultipleExportProjectBoardAction.MultipleExportProjectBoardResult exportResult;
        ValueStream exportVS;
        String jsonFile;
        String aFileURL;

        //--- get the Gantt's ValueStream Id for all requests having empty vsId
        //--- get the Project Id for all requests having empty projectId
        Map<String, String> undefinedValueStreamIdRequests = new Map<String, String>();
        Map<String, String> undefinedProjectIdRequests = new Map<String, String>();
        for (MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest request : requests) {
            request.projectId = getRecordId(request.projectId, 'leankor__ProjectRoom__c');
            request.vsId = getRecordId(request.vsId, 'leankor__ValueStream__c');

            if (String.isBlank(request.vsId) && String.isNotBlank(request.projectId)) {
                undefinedValueStreamIdRequests.put(request.projectId, '');
            }

            if (String.isBlank(request.projectId) && String.isNotBlank(request.vsId)) {
                undefinedProjectIdRequests.put(request.vsId, '');
            }
        }

        // get the Gantt's ValueStream Id for all requests having empty vsId        
        if (undefinedValueStreamIdRequests.size() > 0) {
            List<leankor__ValueStream__c> valueStreams = [Select Id,
                                                                    leankor__ProjectRoom__c
                                                                From leankor__ValueStream__c 
                                                                Where leankor__ProjectRoom__c In :undefinedValueStreamIdRequests.keySet()
                                                                    And leankor__BoardType__c = :BOARD_TYPE_PG
                                                                    And leankor__isRecordDeleted__c = false
                                                                With Security_Enforced
                                                                Limit 50000];

            for  (leankor__ValueStream__c valueStream : valueStreams) {
                undefinedValueStreamIdRequests.put(valueStream.leankor__ProjectRoom__c, valueStream.Id);
            }
        }

       // get the Project Id for all requests having empty projectId        
        if (undefinedProjectIdRequests.size() > 0) {
            List<leankor__ValueStream__c> valueStreams = [Select Id,
                                                                    leankor__ProjectRoom__c
                                                                From leankor__ValueStream__c 
                                                                Where Id In :undefinedProjectIdRequests.keySet()
                                                                    And leankor__isRecordDeleted__c = false
                                                                With Security_Enforced
                                                                Limit 50000];

            for  (leankor__ValueStream__c valueStream : valueStreams) {
                if (valueStream.leankor__ProjectRoom__c != null) {
                    undefinedProjectIdRequests.put(valueStream.Id, valueStream.leankor__ProjectRoom__c);
                }
            }
        }
        //--- get the Gantt's ValueStream Id for all requests having empty vsId
        //--- get the Project Id for all requests having empty projectId
        
        for (MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest request : requests) {
            exportResult = new MultipleExportProjectBoardAction.MultipleExportProjectBoardResult();

            if (String.isBlank(request.vsId) && String.isBlank(request.projectId)) {
                exportResult.status = false;
                exportResult.errorMsg = ERR_BADVS; 
                results.add(exportResult);
                continue;
            }

            // get the Gantt's ValueStream Id of the Project if request.vsId is empty
            if (String.isBlank(request.vsId)) {
                request.vsId = undefinedValueStreamIdRequests.get(request.projectId);
            }

            // get the Project Id of the ValueStream if request.projectId is empty
            if (String.isBlank(request.projectId)) {
                request.projectId = undefinedProjectIdRequests.get(request.vsId);
            }

            ExportPlatformEvent epe = new ExportPlatformEvent('BeginBoardExport', request.projectId, request.vsId);            
            exportVS = new ValueStream(request.vsId);
            // exportResult = new MultipleExportProjectBoardAction.MultipleExportProjectBoardResult();

            // confirm the VS exists and call appropriate helper method depending on the Board Type
            if (!exportVS.isFound) {
                exportResult.status = false;
                exportResult.errorMsg = ERR_BADVS; 
                results.add(exportResult);
                continue;
            }

            if (exportVS.isPG() || exportVS.isKB()) {
                jsonFile = exportPGorKB(exportVS);
            } else {
                exportResult.status = false;
                exportResult.errorMsg = ERR_BOARD_NOTSUPPORTED; 
                results.add(exportResult);
                continue;
            }

            // deal with JSON serialization issues or database etc..
            if (jsonFile == null || jsonFile == '') {
                exportResult.status = false;
                exportResult.errorMsg = ERR_BAD_JSON;
                results.add(exportResult);
                continue;
            }

            if (request.isReturnJSONString) {
                exportResult.outputJSON = jsonFile;
            }

            if (request.isWriteFile) {
                aFileURL = writeJSON(request.fileName, jsonFile);

                if (aFileURL == null) {
                    exportResult.status = false;
                    exportResult.errorMsg = ERR_FILESAVE;
                    results.add(exportResult);
                    continue;
                } else {
                    exportResult.fileURL = aFileURL;
                }
            }

            // success
            exportResult.status = true;
            exportResult.errorMsg = 'Success';
            results.add(exportResult);
        }

        return results;
    }
    //--------------------  end main invocation method   ----------------------------------------------------------
}