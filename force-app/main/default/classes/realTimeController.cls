/* Copyright 2012 - 2015 Lucidsoft Inc.All rights reserved.
 * FILE : realTimeController.cls
 * CLASS : realTimeController
 * USAGE : manages the realtime view of a VisualStream object rendered as a flow.
 */
global with sharing class realTimeController {  
    public static final String NAMESPACE_PREFIX = 'leankor';
    public static final DateTime LASTMODIFIEDDATETIME_CONST = DateTime.newInstance(2000, 01, 01, 12, 0, 0);
    public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c', 'leankor__KanbanCardSticker__c'};
    public static final Set<String> MASTERCONTAINERTYPEFILTERS_CONST = new Set<String>{'Archive', 'Backlog', 'Regular'};
    public static final Set<String> BOARDTYPEFILTERS_CONST = new Set<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard'};
    public static final Set<String> BOARDTYPEFILTERS_NONCARDHIERARCHY_CONST = new Set<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard', 'Portfolio View', 'UberBoard'};
    public static final String USER_SESSION_ID_CONST = UserInfo.getSessionId();
    public static final String USER_ID_CONST = UserInfo.getUserId();
    public static final String USER_NAME_CONST = UserInfo.getName();
    public static List<Id> linkParentCardIds = new List<Id>();
    //Variable added for allow Scheduling constraint custom setting.
    public static final Boolean ALLOW_SCHEDULING_CONSTRAINTS = leankor__LeanConstants__c.getInstance().leankor__AllowSchedulingConstraints__c;
    public static Boolean updateTaskDatesWeekCalendar = false;
    private static DescribeSchema realTimeControllerDescribeSchema = new DescribeSchema();
    private static Map<String, Schema.FieldSet> kanbanCardFieldSets = realTimeControllerDescribeSchema.getFieldSets('leankor__Kanbancard__c');

    public static List<leankor__VisualLeanUIItemSetting__mdt> UIItemSettings = getVisualLeanUIItemSettings();
    public static List<leankor__VisualLeanUIHeaderSetting__mdt> UIHeaderSettings = getVisualLeanUIHeaderSettings();
    public realTimeController(Util controller){}
    public static Map<String, Schema.SObjectField> fieldMapKanbanCard = new DescribeSchema().getObjectFields('leankor__KanbanCard__c');
    
    global realTimeController(ApexPages.StandardSetController controller) {}
    global realTimeController() {}
    global leankor__ProjectRoom__c theProjectRoom {get; set;}
    global static Boolean checkdeafaultlinkflag = true;

    public static Boolean isCalledAPI = false;
    //29/06/2022 : isConstraintrecalculate should be true for parent card also.
    public static Boolean isConstraintRecalculateForChildCard = false;

    public String defaultKanbanCardTemplate { get; private set; }

    global realTimeController(ApexPages.StandardController stdController) {
        this.theController = stdController;
        this.theValueStream = (leankor__ValueStream__c)StdController.getRecord();
        if(String.isNotBlank(this.theValueStream.Id) && 
            Util.getSObjectName(this.theValueStream.Id) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
        }
        List<leankor__ProjectRoom__c> projectRooms = RealTimeControllerHelper.readProjectRecord(new List<String>{this.theValueStream.leankor__ProjectRoom__c});

    	if (projectRooms.size() > 0) {
    		this.theProjectRoom = projectRooms[0];
    	}
        if(String.isNotBlank(this.theValueStream.Id)) {
            this.defaultKanbanCardTemplate = JSON.serialize(GanttViewController.getKanbanCardTemplates(this.theValueStream.Id));
        }
        
    }
   
    //14.12.2017 - passing current valuestream record on load
    global realTimeController(leankor__ValueStream__c valueStream) {
        this.theValueStream = valueStream;
        List<leankor__ProjectRoom__c> projectRooms = RealTimeControllerHelper.readProjectRecord(new List<String>{this.theValueStream.leankor__ProjectRoom__c});

    	if (projectRooms.size() > 0) {
    		this.theProjectRoom = projectRooms[0];
    	}
    }
    
    //TODO: must refactor the methods using the following variables, too confusing to use these globally
    global static Set<String> valueStreamCardLinkIDList = new Set<String>();
    global static String oldParentVar = '';
    global static Boolean checkDefaultLinkFlag = true;
    global static Set<String> gskanbanCardIds = new Set<String>();
    public static Set<String> externalCardIDs = new Set<String>();
	//This variable is used for handling IsSuccessorRecalculate of parent in GS (When multiple operation are performed at speed)
    public static Set<String> parentActivityIds = new Set<String>();
    //TODO:
    
    //lean constants
    private static final Boolean LEANFALSE = false;
    private static final Boolean LEANTRUE = true;
    private static final String LEANUBERBOARD = 'UberBoard';
    //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
    private static final Boolean IS_GENERIC_STREAMING = false;   
    //20/March/2024 : Currently we are deprecating Broadcasting channel, So broadcast should ot fire in PE, so we are setting true value. 
	private static final Boolean IS_USING_PLATFORM_EVENT = true;
    public static Boolean flowWithGSForAPI = false;
    private static Set<String> recalculateIds = new Set<String>(); 
    private static Set<String> valueStreamIds = new Set<String>();

    // get any custom settings here
    global static Decimal getStreamingAPIVersion() {
        return leankor__LeanConstants__c.getInstance().leankor__StreamingAPIVersion__c;
    }


    // set by the constructor of the class
    private final ApexPages.StandardController theController {
        private get;
        private set;
    }


    global leankor__ValueStream__c theValueStream {
        get;
        set;
    }


    // list of attachments for this valuestream... namely the png/jpeg snapshot of it
    // constructor class for when you just need an empty container
    global class theAttachment {
        global String Id;
        global String FileName = '';
        global String Base64Body = '';
        global String ContentType = '';
        global String Description = '';
        
        global theAttachment() {
            return;
        }

        global theAttachment(Attachment Att) {
            if (Att != null) {
                Id = Att.Id;
                Base64Body = EncodingUtil.Base64Encode(Att.Body);
                FileName = Att.Name;
                ContentType = Att.ContentType;
                Description = Att.Description;
            } else {
                return;
            }
        }
    }
    

    public PageReference redirect() {
       return new PageReference('/apex/LeankorNav');

        }
    

    global PageReference saveWorkspace() {
        try {
            this.theController.save();
        } catch (DmlException e) {
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        ApexPages.currentPage().setRedirect(false);
        System.debug('Redirecting to LeankorNav page');
        return ApexPages.currentPage();
    }


    // Remote web service for returning background images to append to value stream in browser
    @RemoteAction
    global static List<theAttachment> getValueStreamBackgrounds(String parentId) { 
		if (String.isNotBlank(parentId) && Util.getSObjectName(parentId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<theAttachment> returnList = new List<theAttachment>();       
        for (Attachment[] attachments : [Select Id, 
                                                Name, 
                                                Body, 
                                                ContentType, 
                                                Description 
                                            From Attachment 
                                            Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                And ParentId = :parentId
                                            Order By LastModifiedDate 
                                            Limit 4]) {

            for (Integer iCount = 0; iCount < attachments.size(); iCount++) {
                if (attachments[iCount].Description != null && attachments[iCount].Description.contains('background')) {
                    returnList.add(new theAttachment(attachments[iCount]));
                }
            }
        }

        return returnList;
    }


    /***
     * Remote web service for returning the SmallPhotoUrl's for each User Id provided
     * INPUT: Array of strings, each representing an owner of a kanban card
     * TODO: Get ChatterActivity data for kanban card owners and return in separate array
     * [SELECT ParentID, PostCount, LikeReceivedCount, InfluenceRawRank, CommentReceivedCount, CommentCount From ChatterActivity where ParentId in :ownerList]
    */
    private static List<User> getUserRecordsCore(List<String> ownerList) {
        // Input validation
 		for (String ownerId : ownerList) {
            if (String.isNotBlank(ownerId) && Util.getSObjectName(ownerId) != 'User') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        return [Select Id, 
                        FirstName,
                        Email,
                        LastName,
                        Name,
                        Username, 
                        Alias,
                        UserRoleId,
                        SmallPhotoUrl
                    From User Where Id In :ownerList
                    Limit 50000];
    }

    @AuraEnabled
    public static List<User> getUserData(List<String> ownerList) {
        // Null or empty check for the ownerList
        if (ownerList == null || ownerList.isEmpty()) {
            System.debug('Error: ownerList is null or empty');
            return new List<User>();  // Return an empty list
        }
        
        // Ensure each ownerId in the list is valid
        for (String ownerId : ownerList) {
            if (String.isNotBlank(ownerId) && Util.getSObjectName(ownerId) != 'User') {
                System.debug('Error: Invalid input for ownerId: ' + ownerId);
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        // Call the existing @RemoteAction method
        return getUserRecords(ownerList);
    }


    // RemoteAction method for Visualforce pages
    @RemoteAction
    global static List<User> getUserRecords(List<String> ownerList) {
        return getUserRecordsCore(ownerList);
    }

    // AuraEnabled method for Aura components and LWC
    @AuraEnabled
    public static List<User> getUserRecordsLWC(List<String> ownerList) {
        return getUserRecordsCore(ownerList);
    }


    // used in the method below to replace certain templates that inherite Attachments from 'global Templates'
    class ToReplace {
        leankor__KanbanCardTemplate__c KCT;
        Integer ReplaceIndex;
    }


	//Added this wrapper class for RemoveKanbanCard
    public class KanbanCardsData {
    	public List<leankor__KanbanCard__c> kanbanCards;
    	public Set<String> recordIds;
    }

    @AuraEnabled
    public static List<leankor__KanbanCardTemplate__c> retrieveKanbanCardTemplates(Id valueStreamId) {
        try {
            // Call the existing RemoteAction method and return its result
            return getKanbanCardTemplates(valueStreamId);
        } catch (Util.LeanException e) {
            // Handle and propagate any exceptions that occur
            throw new AuraHandledException(e.getMessage());
        }
    }


    /***
     * Remote web service for returning all the Kanban Card Templates
     * If no templates exist for the value stream, then they will be created from global Templates
     * global Templates are those with no ValueStream ID and no DerivedFrom ID (both null), but have Attachment PNG/JPG/GIF
     * INPUT: Value Stream ID
     * OUTPUT: Array of leankor__KanbanCardTemplate__c with sub-array Attachments
    */
    // This method should be converted to a singleton, as currently it does not only get the templates but it also updates the templates
    @RemoteAction
    global static List<leankor__KanbanCardTemplate__c> getKanbanCardTemplates(Id valueStreamId) {
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
		KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour =  new KanbanCardTemplateBehaviour();
        ValueStreamBehavior valueStreamBehavior =  new ValueStreamBehavior();
        
        if (!kanbanCardTemplateBehaviour.isAccessible() 
        || !kanbanCardTemplateBehaviour.isUpdateable() 
        || !kanbanCardTemplateBehaviour.isCreateable()
        || !valueStreamBehavior.isAccessible()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        List<leankor__KanbanCardTemplate__c> returnKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();
 
        // First, get all templates which have valueStreamId
        // They may or may not have Attachments.
        // If no attachment, then use its DerivedFrom Kanban Card Template Attachment (assuming it is derived)
        List<leankor__ValueStream__c> valueStreams = [Select leankor__ProjectRoom__c
                                                        From leankor__ValueStream__c 
                                                        Where Id = :valueStreamId 
                                                        Limit 1];
        
        if (valueStreams.size() > 0) {                        
            returnKanbanCardTemplates = [Select Id, 
                                                leankor__ValueStream__c,
                                                Name, 
                                                leankor__AssetID__c, 
                                                leankor__CSSLayout__c, 
                                                leankor__Color__c, 
                                                leankor__Height__c, 
                                                //leankor__JSONData__c, 
                                                //leankor__JSONDefinition__c, 
                                                leankor__Title__c, 
                                                leankor__width__c, 
                                                leankor__DerivedFrom__c, 
                                                leankor__DerivedFrom__r.leankor__ProjectRoom__c, 
                                                leankor__FieldSetName__c,
                                                leankor__WeekCalendar__c
                                            From leankor__KanbanCardTemplate__c 
                                            Where leankor__ValueStream__c = :valueStreamId
                                            Order By Name];      

            Map<String, leankor__KanbanCardTemplate__c> kanbanCardTemplates = new Map<String, leankor__KanbanCardTemplate__c>();
            Set<String> valueStreamKanbanCardTemplates = new Set<String>();
            Set<Id> derivedKanbanCardTemplates = new Set<Id>();

            for (leankor__KanbanCardTemplate__c returnKanbanCardTemplate : returnKanbanCardTemplates) {
                if (String.isNotBlank(returnKanbanCardTemplate.Name)) {
                    valueStreamKanbanCardTemplates.add(returnKanbanCardTemplate.Name.toUpperCase().trim());
                }

                if (returnKanbanCardTemplate.leankor__DerivedFrom__c != null) {
                    derivedKanbanCardTemplates.add(returnKanbanCardTemplate.leankor__DerivedFrom__c);
                } else {
                    kanbanCardTemplates.put(returnKanbanCardTemplate.Name.toUpperCase().trim(), returnKanbanCardTemplate);
                }
            }

            List<leankor__KanbanCardTemplate__c> globalTemplates = new List<leankor__KanbanCardTemplate__c>();
            
            // NOTE: This is a non-selective query due to the "Not In" operator, however there is no way to filter out the the "derivedKanbanCardTemplates" without querying the entire table
            // Next, find any global Templates not yet an ancestor of any returnKanbanCardTemplates, and add a clone Force.com and the return array
            List<leankor__KanbanCardTemplate__c> allGlobalTemplates = [Select Id, 
                                                                                Name, 
                                                                                leankor__AssetID__c, 
                                                                                leankor__CSSLayout__c, 
                                                                                leankor__Color__c, 
                                                                                leankor__Height__c, 
                                                                                //leankor__JSONData__c, 
                                                                                //leankor__JSONDefinition__c, 
                                                                                leankor__Title__c, 
                                                                                leankor__width__c, 
                                                                                leankor__DerivedFrom__c, 
                                                                                leankor__FieldSetName__c,
                                                                                leankor__ValueStream__c,
                                                                                leankor__ProjectRoom__c,
                                                                                leankor__WeekCalendar__c
                                                                            From leankor__KanbanCardTemplate__c 
                                                                            Where Id Not In :derivedKanbanCardTemplates 
                                                                            Order By CreatedDate Desc
                                                                            Limit 20000];
                                                                        
            for (leankor__KanbanCardTemplate__c allGlobalTemplate : allGlobalTemplates) {
                if (allGlobalTemplate.leankor__ValueStream__c == null 
                && allGlobalTemplate.leankor__DerivedFrom__c == null 
                && allGlobalTemplate.leankor__ProjectRoom__c == null) {
                    globalTemplates.add(allGlobalTemplate);
                }
            }

            Set<leankor__KanbanCardTemplate__c> localKanbanCardTemplates = new Set<leankor__KanbanCardTemplate__c>();
            Set<leankor__KanbanCardTemplate__c> globalKanbanCardTemplates = new Set<leankor__KanbanCardTemplate__c>();

            for (leankor__KanbanCardTemplate__c tempglobal : globalTemplates) {
                if (kanbanCardTemplates.containskey(tempGlobal.Name.touppercase().trim())) {               
                    leankor__KanbanCardTemplate__c updateKanbanCardTemplate = kanbanCardTemplates.get(tempGlobal.Name.touppercase().trim()); 

                    if (!localKanbanCardTemplates.contains(updateKanbanCardTemplate)) {                   
                        updateKanbanCardTemplate.leankor__DerivedFrom__c = tempGlobal.Id;
                        updateKanbanCardTemplate.leankor__color__c = tempGlobal.leankor__color__c;
                        updateKanbanCardTemplate.leankor__FieldSetName__c = tempGlobal.leankor__FieldSetName__c;
                        localKanbanCardTemplates.add(updateKanbanCardTemplate);
                    }
                } else {
                    if (!valueStreamKanbanCardTemplates.contains(tempGlobal.Name.touppercase().trim())) {
                        globalKanbanCardTemplates.add(tempGlobal);
                        valueStreamKanbanCardTemplates.add(tempGlobal.Name.touppercase().trim());
                    }
                }
            }

            List<leankor__KanbanCardTemplate__c> globalProjectRoomKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();

            List<leankor__KanbanCardTemplate__c> projectRoomKanbanCardTemplates = [Select Id, 
                                                                                            Name, 
                                                                                            leankor__AssetID__c, 
                                                                                            leankor__CSSLayout__c, 
                                                                                            leankor__Color__c, 
                                                                                            leankor__Height__c, 
                                                                                            //leankor__JSONData__c, 
                                                                                            //leankor__JSONDefinition__c, 
                                                                                            leankor__Title__c, 
                                                                                            leankor__width__c, 
                                                                                            leankor__DerivedFrom__c, 
                                                                                            leankor__FieldSetName__c,
                                                                                            leankor__ValueStream__c,
                                                                                            leankor__WeekCalendar__c
                                                                                        From leankor__KanbanCardTemplate__c 
                                                                                        Where leankor__ProjectRoom__c = :valueStreams[0].leankor__ProjectRoom__c
                                                                                        Order By CreatedDate Desc
                                                                                        Limit 20000];

            for (leankor__KanbanCardTemplate__c projectRoomKanbanCardTemplate : projectRoomKanbanCardTemplates) {
                if (projectRoomKanbanCardTemplate.leankor__ValueStream__c == null 
                && projectRoomKanbanCardTemplate.leankor__DerivedFrom__c != null 
                && !derivedKanbanCardTemplates.contains(projectRoomKanbanCardTemplate.Id)) {
                    globalProjectRoomKanbanCardTemplates.add(projectRoomKanbanCardTemplate);
                }
            }
            
            for (leankor__KanbanCardTemplate__c globalProjectRoomKanbanCardTemplate : globalProjectRoomKanbanCardTemplates) {
                if (kanbanCardTemplates.containskey(globalProjectRoomKanbanCardTemplate.Name.touppercase().trim())) {
                    leankor__KanbanCardTemplate__c updateKanbanCardTemplate = kanbanCardTemplates.get(globalProjectRoomKanbanCardTemplate.Name.touppercase().trim());

                    if(!localKanbanCardTemplates.contains(updateKanbanCardTemplate)) {   
                        updateKanbanCardTemplate.leankor__DerivedFrom__c = globalProjectRoomKanbanCardTemplate.ID;
                        updateKanbanCardTemplate.leankor__Color__c = globalProjectRoomKanbanCardTemplate.leankor__color__c;
                        updateKanbanCardTemplate.leankor__FieldSetName__c = globalProjectRoomKanbanCardTemplate.leankor__FieldSetName__c;

                        localKanbanCardTemplates.add(updateKanbanCardTemplate);
                    }
                } else {
                    if (!valueStreamKanbanCardTemplates.contains(globalProjectRoomKanbanCardTemplate.Name.touppercase().trim())) {
                        globalKanbanCardTemplates.add(globalProjectRoomKanbanCardTemplate);
                    }
                }
            }

            Set<leankor__KanbanCardTemplate__c> cloneKanbanCardTemplates = new Set<leankor__KanbanCardTemplate__c> ();

            // clone the global templates for this particular value stream
            // next time this API is called, we won't hit this code
            for (leankor__KanbanCardTemplate__c globalKanbanCardTemplate : globalKanbanCardTemplates) {
                // first create a clone in Force.com
                leankor__KanbanCardTemplate__c cloneKanbanCardTemplate = new leankor__KanbanCardTemplate__c();

                cloneKanbanCardTemplate.Name = globalKanbanCardTemplate.Name;
                cloneKanbanCardTemplate.leankor__CSSLayout__c = globalKanbanCardTemplate.leankor__CSSLayout__c;
                cloneKanbanCardTemplate.leankor__Color__c = globalKanbanCardTemplate.leankor__Color__c;
                cloneKanbanCardTemplate.leankor__Height__c = globalKanbanCardTemplate.leankor__Height__c;
                //cloneKanbanCardTemplate.leankor__JSONData__c = globalKanbanCardTemplate.leankor__JSONData__c;
                //cloneKanbanCardTemplate.leankor__JSONDefinition__c = globalKanbanCardTemplate.leankor__JSONDefinition__c;
                cloneKanbanCardTemplate.leankor__Title__c = globalKanbanCardTemplate.leankor__Title__c;
                cloneKanbanCardTemplate.leankor__width__c = globalKanbanCardTemplate.leankor__width__c;
                cloneKanbanCardTemplate.leankor__ValueStream__c = valueStreamId;
                cloneKanbanCardTemplate.leankor__DerivedFrom__c = globalKanbanCardTemplate.Id;
                cloneKanbanCardTemplate.leankor__FieldSetName__c = globalKanbanCardTemplate.leankor__FieldSetName__c;
                cloneKanbancardTemplate.leankor__WeekCalendar__c = globalKanbanCardTemplate.leankor__WeekCalendar__c;
                cloneKanbanCardTemplates.add(cloneKanbanCardTemplate);
            }

            // do not need to clone attachment, because we use global Template to pick up icons                 
            List<leankor__KanbanCardTemplate__c> createKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>(cloneKanbanCardTemplates);
            List<leankor__KanbanCardTemplate__c> updateKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>(localKanbanCardTemplates);
            
            Savepoint sp = Database.setSavepoint();
            try {
                if (createKanbanCardTemplates.size() > 0) {                        
                    insert createKanbanCardTemplates;          
                }

                if (updateKanbanCardTemplates.size() > 0) {
                    update updateKanbanCardTemplates;
                }
            } catch (DmlException e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
                
            returnKanbanCardTemplates.addall(createKanbanCardTemplates);
            returnKanbanCardTemplates = [Select Id, 
                                                Name, 
                                                leankor__AssetId__c, 
                                                leankor__CSSLayout__c, 
                                                leankor__Color__c, 
                                                leankor__Height__c, 
                                                //leankor__JSONData__c, 
                                                //leankor__JSONDefinition__c, 
                                                leankor__Title__c, leankor__width__c, 
                                                leankor__DerivedFrom__c, 
                                                leankor__DerivedFrom__r.leankor__ProjectRoom__c, 
                                                leankor__FieldSetName__c,
                                                leankor__WeekCalendar__c 
                                            From leankor__KanbanCardTemplate__c 
                                            Where Id In :returnKanbanCardTemplates
                                            Order By CreatedDate Desc
                                            Limit 20000];

        }
        System.debug(returnKanbanCardTemplates[0].Name);

        return returnKanbanCardTemplates.isEmpty() ? returnKanbanCardTemplates : JSONKanbanTemplateInjection(returnKanbanCardTemplates);
    }


    /***
     * Remote web service for resetting the height/width of a Kanban Card Template
     * INPUT: Kanban Card Template ID, the width/height to modify
     * OUTPUT: String showing error if any otherwise "success"
    */
    @RemoteAction
    global static String setKanbanCardTemplate(Id templateId, Integer width, Integer height) {
        if (String.isNotBlank(templateId) && Util.getSObjectName(templateId) != 'leankor__KanbanCardTemplate__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
		KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour =  new KanbanCardTemplateBehaviour();
        if (!kanbanCardTemplateBehaviour.isAccessible() 
        || !kanbanCardTemplateBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');        
        }
        //Check CRUD / FLC behavior

        leankor__KanbanCardTemplate__c kanbanCardTemplate = new leankor__KanbanCardTemplate__c();
        String returnVal = 'success';
        kanbanCardTemplate.Id = templateId;
        kanbanCardTemplate.leankor__Height__c = height;
        kanbanCardTemplate.leankor__width__c = width;

        try {
            update kanbanCardTemplate;
        } catch (Exception e) {
            System.debug('ERROR: while trying to save new height-width to kanban card template' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return returnVal;
    }


    /***
     * Remote web service for resetting the height/width of a Kanban Card
     * INPUT: Kanban Card  ID, the width/height to modify
     * OUTPUT: String showing error if any otherwise "success"
     */
    @RemoteAction
    global static String setKanbanCard(Id cardId, Integer width, Integer height) {
        if (String.isNotBlank(cardId) && Util.getSObjectName(cardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour =  new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c();
        String returnVal = 'success';
        
        kanbanCard.Id = cardId;
        kanbanCard.leankor__Height__c = height;
        kanbanCard.leankor__width__c = width;

        try {
            update kanbanCard;
        } catch (Exception e) {
            System.debug('ERROR: while trying to save new height-width to kanban card' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return returnVal;
    }
    

    /*
     * Remote web service for returning all the Kanban Card Stickers that are system-wide and all specifically linked to the Value Stream
     * INPUT: Value Stream ID
     * OUTPUT: Array of leankor__Sticker__c with sub-array Attachments
    */
    @RemoteAction
    global static List<leankor__Sticker__c> getAllStickers(Id valueStreamId) {
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<leankor__Sticker__c> myStickers = new List<leankor__Sticker__c>();
        List<leankor__Sticker__c> stickerIds = new List<leankor__Sticker__c>();
        Map<Id, Attachment> mapAttachments = new Map<Id, Attachment>(); 
         
        try {
            List<leankor__Sticker__c> allStickerIds = [Select Id,
                                                                leankor__ValueStream__c
                                                            From leankor__Sticker__c
                                                            Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST
                                                            Limit 50000];
                                                    
            for (leankor__Sticker__c allStickerId : allStickerIds) {
                if (allStickerId.leankor__ValueStream__c == null || allStickerId.leankor__ValueStream__c == valueStreamId) {
                    stickerIds.add(allStickerId);
                }
            }

            if (stickerIds.size() > 0) {
                for (Attachment[] attachment : [Select Id, 
                                                        Body 
                                                    From Attachment 
                                                    Where ParentId In :stickerIds 
                                                    Limit 50000]) {

                    mapAttachments.putAll(attachment);
                }

                for (List<leankor__Sticker__c> sticker : [Select Id, 
                                                                Name, 
                                                                (Select Id, 
                                                                        ContentType,
                                                                        Description
                                                                    From Attachments 
                                                                    Where ParentId In :stickerIds) 
                                                            From leankor__Sticker__c Where Id In :stickerIds 
                                                            Order By Name
                                                            Limit 50000]) {

					sticker.sort();
                    for (Integer iCount = 0; iCount < sticker.size(); iCount++) {
                        //stickers must have attachment because without attachment sticker will not be used on UI.
                        if (sticker[iCount].Attachments.size() > 0) {

                            // loop through all stickers to get binary body, then base64 encode the body and slam into Description field (string)
                            for (Attachment attachment : sticker[iCount].Attachments) {
                                attachment.Description = EncodingUtil.Base64Encode(mapAttachments.get(attachment.Id).Body);
                            }

                            myStickers.add(sticker[iCount]);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('ERROR: while getting attachment to Sticker: ' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return myStickers;
    }


    /***
     * Remote web service for returning the Sticker information for each Kaban Card Id provided
     * INPUT: Array of strings, each representing a kanban card
     * OUTPUT: Custom object array of Stickers and their associated icons
    */
    @RemoteAction
    global static List<leankor__Sticker__c> getKanbanCardStickers(List<String> kanbanList) {
		for (String kanbanCardId : kanbanList) {
            if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        
        List<leankor__Sticker__c> myStickers = new List<leankor__Sticker__c>();

        try {    
            Set<Id> stickerIds = new Set<Id>();
            for (leankor__KanbanCardSticker__c[] stickers : [Select leankor__Sticker__c 
                                                                From leankor__KanbanCardSticker__c 
                                                                Where leankor__KanbanCard__c In :kanbanList 
                                                                Limit 50000]) {
                for (Integer iCount = 0; iCount < stickers.size(); iCount++) {
                    stickerIds.add(stickers[iCount].leankor__Sticker__c);
                }
            }
            
            for (List<leankor__Sticker__c> stickers : [Select Id, 
                                                                Name, 
                                                                (Select Id 
                                                                    From Attachments 
                                                                    Where ParentId In :stickerIds) 
                                                            From leankor__Sticker__c Where Id In :stickerIds 
                                                            Limit 50000]) {  
				stickers.sort();  
                for (Integer iCount = 0; iCount < stickers.size(); iCount++) { 
                    if(stickers[iCount].Attachments.size() > 0) {
                        for (Attachment att : stickers[iCount].Attachments) {                                       
                            att.Description = '';
                            att.Name = stickers[iCount].Id;
                        }
                        myStickers.add(stickers[iCount]);
                    }
                }
            }
        } catch (Exception e){
            System.debug('ERROR: while getting attachment to Sticker: ' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
       
        return myStickers;
    }


    /***
     * Remote web service for adding a Sticker to a Kaban Card
     * INPUT: Array of strings, each representing a kanban card
     * OUTPUT: Custom object array of Stickers and their associated icons
    */
    @RemoteAction
    global static Boolean addStickerToKanbanCard(List<String> stickerIds, String kanbanCardId) {
        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

		for (String stickerId : stickerIds) {
            if (String.isNotBlank(stickerId) && Util.getSObjectName(stickerId) != 'leankor__Sticker__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        //Check CRUD / FLC behavior
		KanbanCardStickerBehaviour kanbanCardStickerBehaviour =  new KanbanCardStickerBehaviour();
		if (!kanbanCardStickerBehaviour.isAccessible() 
        || !kanbanCardStickerBehaviour.isCreateable()
        || !kanbanCardStickerBehaviour.isUpdateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__KanbanCardSticker__c> kanbanStickers = [Select Id, 
                                                                    leankor__Sticker__c,
                                                                    leankor__KanbanCard__c
                                                                From leankor__KanbanCardSticker__c 
                                                                Where leankor__KanbanCard__c = :kanbanCardId
                                                                Limit 50000];

        //TODO: Must test method as it is converted to singleton, deletion has been removed
        /*
        List<leankor__KanbanCardSticker__c> newKanbanStickers = new List<leankor__KanbanCardSticker__c>();
        if (!leankor__KanbanCard__c.sObjectType.getDescribe().isDeletable() && !leankor__KanbanCardSticker__c.sObjectType.getDescribe().isCreateable()) {
            return false;
        } else {
            try {
                Database.Delete(kanbanStickers, true);
            } catch (DmlException e) {
                System.debug('ERROR:' + e.getMessage());
                return false;
            }
        }
        for (String stickerId : stickerIds) {
            leankor__KanbanCardSticker__c kanbanCardSticker = new leankor__KanbanCardSticker__c(leankor__KanbanCard__c = kanbanCardId, leankor__Sticker__c = stickerId);
            newKanbanStickers.add(kanbanCardSticker);
        }

        try {
            Database.Insert(newKanbanStickers, true);
        } catch (DmlException e) {
            System.debug('ERROR:' + e.getMessage());
            return false;
        }
        */

        //Map<Id, Id> kanbanCardStickers = new Map<Id, Id>();
        for (leankor__KanbanCardSticker__c kanbanSticker : kanbanStickers) {
            kanbanSticker.leankor__Sticker__c = null;
            kanbanSticker.leankor__KanbanCard__c = null;
        }

        try {
           update kanbanStickers;
        } catch (DmlException e) {
            System.debug('ERROR:' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        List<leankor__KanbanCardSticker__c> newKanbanStickers = new List<leankor__KanbanCardSticker__c>();
        for (String stickerId : stickerIds) {
            //if (!kanbanCardStickers.containsKey(stickerId) && newKanbanStickers.size() < 10000) {
            //if (!kanbanCardStickers.containsKey(stickerId)) {
                leankor__KanbanCardSticker__c kanbanCardSticker = new leankor__KanbanCardSticker__c(
                    leankor__KanbanCard__c = kanbanCardId, 
                    leankor__Sticker__c = stickerId);

                newKanbanStickers.add(kanbanCardSticker);
            //}
        }

        Boolean returnVal = false;

        if (newKanbanStickers.size() > 0) {
            try {
                insert newKanbanStickers;
                returnVal = true;
            } catch (DmlException e) {
                System.debug('Error:' + e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }
    

    /****
     * Remote web service for adding a Sticker to a Kaban Card
     * INPUT: Array of strings, each representing a kanban card
     *  OUTPUT: Custom object array of Stickers and their associated icons
    */
    @RemoteAction
    global static Boolean removeStickerFromKanbanCard(String[] stickerIds, String kanbanCardId) {   
        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

		for (String stickerId : stickerIds) {
            if (String.isNotBlank(stickerId) && Util.getSObjectName(stickerId) != 'leankor__Sticker__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        //Check CRUD / FLC behavior
		KanbanCardStickerBehaviour kanbanCardStickerBehaviour =  new KanbanCardStickerBehaviour();
        if (!kanbanCardStickerBehaviour.isAccessible() 
        || !kanbanCardStickerBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__KanbanCardSticker__c> kanbanCardStickers = [Select Id,
                                                                        leankor__Sticker__c,
                                                                        leankor__KanbanCard__c
                                                                    From leankor__KanbanCardSticker__c 
                                                                    Where leankor__KanbanCard__c = :kanbanCardId 
                                                                        And leankor__Sticker__c In :stickerIds 
                                                                    Limit 10000];

        Boolean returnVal = false;

        if (!kanbanCardStickers.isEmpty()) {
            for(leankor__KanbanCardSticker__c kanbanCardSticker : kanbanCardStickers){
                kanbanCardSticker.leankor__Sticker__c = null;
                kanbanCardSticker.leankor__KanbanCard__c = null;
            }
            try {
                update kanbanCardStickers;
                returnVal = true;
            } catch (DmlException e) {
                System.debug('Error:' + e.getMessage() + ' while removing sticker [' + stickerIds + '] from Kanban Card: ' + kanbanCardId);
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }


    // used to create return array below
    // remote async calls cannot pass binary Blobs in their return package (ie. Attachment objects)
    global class ImageAttachment {
        Id MarkerID;
        String ContentType;
        String Base64Body;
        String AttachmentID;
    }


    /***
     * Remote web service for returning the attached image for each Marker Id provided
     * INPUT: Array of strings, each representing a Marker
     * OUTPUT: Custom object array of Attachments and their associated icons or image file data Base64 enc
    */
    @RemoteAction
    global static List<ImageAttachment> getMarkerImages(List<String> markerIds) {
		for (String markerId : markerIds) {
            if (String.isNotBlank(markerId) && Util.getSObjectName(markerId) != 'leankor__Marker__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        List<ImageAttachment> imageAttachments = new List<ImageAttachment>();    

        try {
            for (Attachment[] attachment : [Select Id,
                                                    ParentId, 
                                                    ContentType 
                                                From Attachment 
                                                Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                    And ParentId In :markerIds 
                                                Limit 50000]) {

               for (Integer iCount = 0; iCount < attachment.size(); iCount++) { 
                    ImageAttachment imageAttachment = new ImageAttachment();
                    imageAttachment.AttachmentID = attachment[iCount].Id;
                    imageAttachment.MarkerID = attachment[iCount].ParentID;
                    imageAttachment.ContentType = attachment[iCount].ContentType;
                    imageAttachments.add(imageAttachment);
               }
            }
        } catch (Exception e) {
            System.debug('Error: while getting marker image' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return imageAttachments;
    }


    // the internal model representation of a Marker in Force.com and in the MVC web data store
    global class Marker {
        global String CmpID;
        global String GUID;
        global Integer Top;
        global Integer Bottom;
        global Integer Left;
		//06/06/2022 : Width was not updating on UI, issue related to Case sensitive
        global Integer Width;
        global Integer Height;
        global Integer X;
        global Integer Y;
        global Integer ZIndex;
        global String CSSLayout;
        global String JSONData;
        global String JSONDefinition;
        global String Base64Body;
        global String ContentType;
        global String Name; // the Name field of the Marker
        global String StickerID; // leankor__Sticker__c Force.com id
        global String VSLink; // leankor__ValueStream__c Force.com id for drill-down capability
        global boolean LockState;
        global String ValueStreamCardLink;
        global String ValueStreamID;
        global String ForceID;
        global String Id;
        global String ValueStreamLinkBoardType;
        global String UrlLink;
        global String Type;
        global String TextLabel;
        global String AttachmentID;
        global String LinkProjectRoomName;
        global String LinkProjectRoomId;
        global String LinkValueStreamName;
        global String LinkCardName;
    }
    

    /***
     * Remote web service for adding a Sticker to a Kaban Card
     * INPUT: List of Marker, each representing a kanban card
     * OUTPUT: Custom object array of Stickers and their associated icons
    */
    @RemoteAction
    global static Marker createMarker(String valueStreamId, List<Marker> remoteMarkers) {
        // '' is a valid input for valueStreamId inside createMarker method 
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
		MarkerBehaviour markerBehaviour =  new MarkerBehaviour();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        
        if (!markerBehaviour.isAccessible() 
        || !markerBehaviour.isCreateable() 
        || !attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Marker returnVal = new Marker();

        if (remoteMarkers.size() > 0) {
            List<leankor__Marker__c> markers = new List<leankor__Marker__c>();

            for (Marker remoteMarker : remoteMarkers) {
                leankor__Marker__c marker = new leankor__Marker__c(
                    leankor__GUID__c = remoteMarker.GUID,
                    leankor__GUID2__c = remoteMarker.GUID,
                    leankor__CmpID__c = remoteMarker.CmpId,
                    Name = String.isBlank(remoteMarker.Name) ? 'Label' : remoteMarker.Name.unescapeHtml4(),
                    leankor__Top__c = remoteMarker.Top,
                    leankor__Bottom__c = remoteMarker.Bottom,
                    leankor__Left__c = remoteMarker.Left,
                    leankor__width__c = remoteMarker.width,
                    leankor__Height__c = remoteMarker.Height,
                    leankor__X__c = remoteMarker.X,
                    leankor__Y__c = remoteMarker.Y,
                    leankor__ZIndex__c = remoteMarker.ZIndex == null ? 120 : remoteMarker.ZIndex,
                    leankor__CSSLayout__c = remoteMarker.CSSLayout,
                    leankor__JSONDefinition__c = remoteMarker.JSONDefinition,
                    leankor__JSONData__c = remoteMarker.JSONData,
                    leankor__ValueStream__c = valueStreamId == '' ? null : valueStreamId,
                    leankor__Sticker__c = remoteMarker.StickerID == '' ? null : remoteMarker.StickerID,
                    leankor__ValueStreamLink__c = remoteMarker.VSLink == '' ? null : remoteMarker.VSLink,
                    leankor__LockState__c = remoteMarker.LockState,
                    leankor__UrlLink__c = remoteMarker.UrlLink,
                    leankor__TextLabel__c = remoteMarker.TextLabel,
                    leankor__Type__c = remoteMarker.Type,
                    leankor__ValueStreamCardLink__c = remoteMarker.ValueStreamCardLink == '' ? null : remoteMarker.ValueStreamCardLink
                );

                markers.add(marker);
            }

            Savepoint sp = Database.setSavepoint();
            try {
                insert markers;

                Map<String, String> mapMarkers = new Map<String, String>();
                for (leankor__Marker__c baseMarker : markers) {
                    mapMarkers.put(baseMarker.leankor__GUID__c, baseMarker.Id);
                }

                List<Attachment> attachments = new List<Attachment>();
                Boolean markerFlag = false;

                for (Marker remoteMarker : remoteMarkers) {                    
                    if (remoteMarker.Base64Body != '' && remoteMarker.ContentType != '') {
                        String fileName = 'marker_' + remoteMarker.Name;
                        String suffix = '';

                        if (remoteMarker.ContentType == 'image/jpeg') {
                            suffix = '.jpg';
                        } else if (remoteMarker.ContentType == 'image/gif') {
                            suffix = '.gif';
                        } else {
                            suffix = '.png';
                        }

                        Attachment attachment = new Attachment(
                            Name = fileName + suffix,
                            ContentType = remoteMarker.ContentType,
                            ParentID = mapMarkers.get(remoteMarker.GUID),
                            Body = EncodingUtil.Base64Decode(remoteMarker.Base64Body));

                        attachments.add(attachment);
                    } else if (markers[0].leankor__Type__c != 'Label') {
                        markerFlag = true;
                    }
                }

                if (markerFlag) {
                    List<ContentVersion> contentVersions = [Select ContentDocumentId, 
                                                                    ContentLocation,
                                                                    Description,
                                                                    FileExtension,
                                                                    FileType,
                                                                    FirstPublishLocationId,
                                                                    PathOnClient,
                                                                    Title,
                                                                    VersionData
                                                                From ContentVersion
                                                                Where ContentDocumentId = :remoteMarkers[0].AttachmentID 
                                                                    And isLatest = true
                                                                Limit 1];

                    if (contentVersions.size() > 0) {
                        Attachment attachment = new Attachment(
                            Name = ('marker_' + contentVersions[0].Title + contentVersions[0].FileExtension),
                            ContentType = 'image/' + contentVersions[0].FileExtension,
                            ParentID = mapMarkers.get(remoteMarkers[0].GUID),
                            Body = contentVersions[0].VersionData
                        );
                        
                        attachments.add(attachment);
                    } else {
                        List<Attachment> newAttachments = [Select Name,
                                                                    ContentType,
                                                                    ParentID,
                                                                    Body
                                                                From Attachment Where Id = :remoteMarkers[0].AttachmentId 
                                                                    And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                                Limit 1];

                        if (newAttachments.size() > 0) {
                            Attachment newAttachment = new Attachment(
                                Name = newAttachments[0].Name,
                                ContentType = newAttachments[0].ContentType,
                                ParentID = mapMarkers.get(remoteMarkers[0].GUID),
                                Body = newAttachments[0].Body
                            );

                            attachments.add(newAttachment);
                        }
                    }
                }

                if (attachments.size() > 0) {
                    insert attachments;
                }

                Map<String, String> mapAttachments = new Map<String, String>();     
                for(Attachment attachment : attachments) {
                    mapAttachments.put(attachment.ParentId, attachment.Id);
                }

                remoteMarkers[0].AttachmentID = mapAttachments.containsKey(markers[0].Id) ? mapAttachments.get(markers[0].Id) : remoteMarkers[0].AttachmentID;
                remoteMarkers[0].Id = markers[0].Id;

                returnVal = remoteMarkers[0];

            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }            
        }

        return returnVal;
    }


    @RemoteAction
    global static Boolean removeMarker(String markerId, String valueStreamId) {
		if ((String.isNotBlank(markerId) && Util.getSObjectName(markerId) != 'leankor__Marker__c' )
        || (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior	
        AttachmentBehaviour attachmentBehaviour =  new AttachmentBehaviour();
        MarkerBehaviour markerBehaviour =  new MarkerBehaviour();
         
        if (!attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isDeletable() 
        || !markerBehaviour.isAccessible() 
        || !markerBehaviour.isUpdateable()) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
         //Check CRUD / FLC behavior	
                
        Boolean returnVal = false;                                            

        List<attachment> attachments = [Select Id 
                                            From Attachment 
                                            Where ParentId = :markerId 
                                                And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                            Limit 10000];

        List<leankor__Marker__c> markers = [Select Id, 
                                                    leankor__ValueStream__c, 
                                                    leankor__ValueStreamCardLink__c,  
                                                    leankor__ValueStreamLink__c, 
                                                    leankor__Sticker__c  
                                                From leankor__Marker__c 
                                                Where Id = :markerId 
                                                    And leankor__ValueStream__c = :valueStreamId 
                                                Limit 1];
                
        for (leankor__Marker__c marker : markers) {
            marker.leankor__ValueStream__c = null;
            marker.leankor__ValueStreamCardLink__c = null;  
            marker.leankor__ValueStreamLink__c  = null;
            marker.leankor__Sticker__c = null;
        }       
        Savepoint sp = Database.setSavepoint();
        try {
            if (attachments.size() > 0) {
                delete attachments;
            }

            if (!markers.isEmpty()) {
                update markers;
            }

            returnVal = true;
        } catch (DmlException e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return returnVal;
    }


    @deprecated
    @RemoteAction
    global static String NavStateChange(String verb, String clientSessionID, String jsonData) {
        return 'serverSessionId';
    }

           
    //DCO 1/30/2018 AuraEnabled method to handle kanban state changes
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static string kanbanStateChange(Id valueStreamId, String verb, String jsonData) {
        String clientSessionId = USER_SESSION_ID_CONST;
        return kanbanStateChange(valueStreamId, verb, clientSessionId, jsonData);
    }

    
    public class ExternalDependent{    
    	public Set<String> cardIds ;
    	public Set<String> externalCardIDs; 
    	public Set<String> externalValuestreamIDs; 
    	public Set<String> parentActivityIdsGS;  
    }
    

    /*
     * Remote web service for broadcasting state changes to a ValueStream open in a browser
    */
    @RemoteAction
    global static String kanbanStateChange(Id valueStreamId, String verb, String clientSessionId, String jsonData) {
        System.debug(valueStreamId);
        System.debug(verb);
        System.debug(clientSessionId);
        System.debug(jsonData);
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
                
        //String jsonNewData = jsonData.unescapeHtml4();
        
        String jsonRecords = jsonData.replace('&quot;', '\\"');
        String jsonNewData = jsonRecords.unescapeHtml4();
        
        if (verb == 'OpenValueStream' && !IS_GENERIC_STREAMING) {
            createValueStreamPushTopic(valueStreamId, jsonNewData, clientSessionId);
        } else {
            manageStateChange(valueStreamId, verb, jsonNewData, clientSessionId); // runs async in another thread
        }

        String kanbanCardIds = '';

        ExternalDependent externalDependent = new ExternalDependent();
        externalDependent.cardIds = gskanbanCardIds;

        if (IS_GENERIC_STREAMING) {
	        externalDependent.externalCardIDs = externalCardIDs;  

            //This variable is used for handling IsSuccessorRecalculate of parent in GS (When multiple operation are performed at speed)      
	        externalDependent.parentActivityIdsGS = parentActivityIds;
        }

        kanbanCardIds = JSON.serialize(externalDependent);

        gskanbanCardIds.clear();
        externalCardIDs.clear();

        return kanbanCardIds;
    }


    /*
     * Helper class used to deserialize JSON in manageStateChange() below
     */
    global class StateChangePackage {
        global String Id;
        global String CardID;
        global String Title;
        global String Name;
        global Decimal width;
        global Decimal Height;
        global Decimal Top;
        global Decimal Bottom;
        global Decimal Left;
        global Decimal X;
        global Decimal Y;
        global String ZoneOpportunityStage;
        global String CmpID;
        global String ZoneID;
        global String MCForceID;
        global String SWForceID;
        global String ZoneForceID;
        global String State;
        global String Color; // EjB7: added color
        global Decimal EstimatedDuration; //EjB12 added duration
        global String DurationUnits; // EjB12 added duration Units
        global DateTime DueDate; // EjB10: added due date
        global Decimal Priority; // EjB14: need to update priority now and again
        global Decimal HarveyBall;
        global String OwnerID;
        global String TemplateID;
        global String JSONData;
        global String JSONDefinition;
        global String ZoneMode;
        global String KanbanSequence;
        global String Description;
        global String AcceptanceCriteria;
        global String KanbanUrl;
        global String EntryFlowName;
        global String ExitFlowName;
        global String LeavedZoneID;
        global String ValueStreamLinkID;
        global String ValueStreamCardLink;
        global String ValueStreamOld;
        global String Account;
        global String Contact;
        global String CaseID;
        global Integer DefaultHeight;
        global Integer Defaultwidth;
        global String ZoneStatus;
        global String ForceID;
        global String ValueStream;
        global String ValueStreamID;
        global String SwitchedVSName;
        global String AccountName;
        global String ContactName;
        global String CaseSubject;
        global String CaseStatus;
        global String CasePriority;
        global String ZoneTitle;
        global String LeavedZoneTitle;
        global boolean CaseTrigger;
        global boolean isUndo;
        global String GUID;
        global String Extensions;
        global DateTime StartDate;
        global Decimal TaskLimit;
        global Decimal Order;
        global String ParentZone;
        global String Swimlane;
        global Decimal CardsPerRow;
        global String Help;
        global Decimal PercentDone;
        global String ValueStreamLinkBoardType;
        global boolean leaf;
        global boolean SWeek;
        global String Opportunity;
        global String OpportunityName;
        global String OpportunityStage;
        global String SmallPhotoUrl;
        global String ItemType;
        global String BoardType;
        global String TemplateName;
        global String OnBudget;
        global String OnQuality;
        global String OnTime;
        global String LinkedCardVerb;
        global String ValueStreamName;
        global Integer TaskComments;
        global Integer ChatterComments;
        global String ResourceId; // Use For Resource Borad Contains Owner ID
        global String UrlLink;
        global String Type;
        global String TextLabel;
        global String ProjectRoomName;
        global String ProjectRoomID;
        global String KanbanCardName;
        global String successorsArray;
        global String Unit;
        global Decimal Point;
        global Decimal EffortRemaining;
        global String dl;
        global Boolean deleteMiniature;
        global Boolean IsExternallyDependent;//if Activity have Externally dependent than this field value will be true.
        global string LinkCN;//using abbreviation for Valuestreamcardlink Name.
        global boolean flowWithGS; //Rs 12/12/2017 To check api is called from flow 
		//This variable is used for handling IsSuccessorRecalculate of parent in GS (When multiple operation are performed at speed)
        public Boolean IsSR;
        public Boolean isAtRisk; 
        public Boolean isOnHold;
        public String sessionId;
        public String recordTypeId;
        //15/05/2023 : Added this variable for provide the value on broadcast while hyperJump a single card from UI.
        public Boolean isConstraintRecalculate;
        
        //Pratiksha : 06/Oct/2023
        public Boolean Monday;
        public Boolean Tuesday;
        public Boolean Wednesday;   
        public Boolean Thursday;
        public Boolean Friday;
        public Boolean Saturday;
        public Boolean Sunday;
        public String weekCalendar;
    }


    //Model class contains only required fields for Kanban Card broadcast. It will manage character limit in RealtimeTracker__c.
    global class CardStreamingPackage {
        global String Id;
        global String CardID;
        global String Title;
        global String Name;
        global Decimal width;
        global Decimal Height;
        global Decimal Top;
        global Decimal Bottom;
        global Decimal Left;
        global Decimal X;
        global Decimal Y;
        global String ZoneOpportunityStage;
        global String CmpID;
        global String ZoneID;
        global boolean isDependent;
        global String State;
        global String Color; // EjB7: added color
        global Decimal EstimatedDuration; //EjB12 added duration
        global String DurationUnits; // EjB12 added duration Units
        global DateTime DueDate; // EjB10: added due date
        global Decimal Priority; // EjB14: need to update priority now and again
        global Decimal HarveyBall;
        global String OwnerID;
        global String TemplateID;
        global String ZoneMode;
        global String LeavedZoneID;
        global String ValueStreamLinkID;
        global String ValueStreamCardLink;
        global String ValueStreamOld;
        global String Account;
        global String Contact;
        global String CaseID;
        global Integer DefaultHeight;
        global Integer Defaultwidth;
        global String ZoneStatus;
        global String ForceID;
        global String ValueStream;
        global String ValueStreamID;
        global String ZoneTitle;
        global String LeavedZoneTitle;
        global boolean CaseTrigger;
        global boolean isUndo;
        global String GUID;
        global DateTime StartDate;
        global Decimal Order;
        global String Swimlane;
        global Decimal PercentDone;
        global String ValueStreamLinkBoardType;
        global boolean leaf;
        global String Opportunity;
        global String OpportunityStage;
        global String SmallPhotoUrl;
        global String BoardType;
        global String OnBudget;
        global String OnQuality;
        global String OnTime;
        global String LinkedCardVerb;
        global String ValueStreamName;
        global Integer TaskComments;
        global Integer ChatterComments;
        global boolean SWeek;
        global String dl;
        global String Extensions;
        global Integer Lag;
        global string LagUnit;
        global string LinkCN;//using abbreviation for Valuestreamcardlink Name.
        global string SwitchedVSName; 
        global String verb;
        global String sessionID;        
        global boolean flowWithGS; //Rs 12/12/2017 To check api is called from flow         
		//This variable is used for handling IsSuccessorRecalculate of parent in GS (When multiple operation are performed at speed)
        public Boolean IsSR;
		//This variable is used for Broadcasting and managing history Notification
        public String ItemType;
        public String ConstraintType;
        public String ConstraintDate;
        public List<String> cardIds;
        public String multipleAPIName;
        // Ashutosh : 20/09/2021 : Variables added for multipleHyperjumpAction and multipleClone API.
        public String TargetVSID;
        public String SourceVSID;
        public Boolean IsClone;
        public String ValueStreamOwnerName;
        // Pratiksha : 20/09/2021 : Variables added for Planinng Mode.
        public DateTime ProjectBoardStartDateTime;
        public DateTime ProjectBoardEndDateTime;
        public Boolean scheduleBackward;

        //Pratiksha : 08/11/2021 : Variable added for GS board cloning.
        public String MySessionId;
        public String OldValueStreamId;
        //Pratiksha : 07/03/2023 : Variable adeded for constraintRecalculate should be true only for Parent card from CV.
        public Boolean isCalledFromCV;

        //Pratiksha : 04/April/2023 We are adding this variable for Broadcast of borad cloning if constraint is violated.
        public String currentCardName;
        public String constraintDescription;
        public String constraintCardName;
        public String boardName;
        public String constraintCardId;
        public String violatedBoardType;
        public String violatedBoardId;
        public String projectID;
        public List<ProjectBoardWorkFieldSet.FieldSetData> fieldSets;
    }


    /***
     * Constant value for size of each JSON segment.
     * We have to split JSON package across text values, because Streaming API does not allow Large Text Areas
     * Force.com string holds 255 so we need 55 characters for escape sequences
     * for creation and handling of segments of a single JSON string
     */
    private static final Integer JSONSegmentSize = 200;
    global class JSONGroup {
        global String JSON1;
        global String JSON2;
        global String JSON3;
        global String JSON4;
        global String JSON5;
        global String JSON6;
        global String JSON7;
        global String JSON8;
    }


    /***
     * helper function for manageStateChange() to split one string into four
     * INPUT: a long string
     * OUTPUT: a set of four strings that, together, equal the long string
     */
    public static Boolean putJSONGroup(String inputString, JSONGroup outGroup) {
        // initialize
        outGroup.JSON1 = '';
        outGroup.JSON2 = '';
        outGroup.JSON3 = '';
        outGroup.JSON4 = '';
        outGroup.JSON5 = '';
        outGroup.JSON6 = '';
        outGroup.JSON7 = '';
        outGroup.JSON8 = '';

        // check blank or empty JSON object
        if (String.isBlank(inputString) || inputString == '{}') {
            outGroup.JSON1 = inputString;
            return true;
        }

        String nextString = '';
        Integer strSize = inputString.length();

        // cannot handle string... too large
        if (strSize > JSONSegmentSize * 8) {
            return false;
        }

        // loop only as many times necessary to process segments
        Decimal decRepeat = (Decimal)((Decimal)strSize / (Decimal)JSONSegmentSize);
        Integer numRepeat = (Integer)decRepeat.round(System.RoundingMode.CEILING);
        for (Integer i = 0; i < numRepeat; i++) {
            nextString = inputString.mid((Integer)(JSONSegmentSize * i), JSONSegmentSize);
            if (i == 0) {
                outGroup.JSON1 = nextString;
            } else if (i == 1) {
                outGroup.JSON2 = nextString;
            } else if (i == 2) {
                outGroup.JSON3 = nextString;
            } else if (i == 3) {
                outGroup.JSON4 = nextString;
            } else if (i == 4) {
                outGroup.JSON5 = nextString;
            } else if (i == 5) {
                outGroup.JSON6 = nextString;
            } else if (i == 6) {
                outGroup.JSON7 = nextString;
            } else if (i == 7) {
                outGroup.JSON8 = nextString;
            }
        }
        
        return true;
    }

    // Ashutosh : 03/12/2021 : New Inner class added to maintain the PushTopic charachter Limit.
    public Class ManageStateChangePackage{
        public String Id;
        public String Title;
        public String Name;
        public String ZoneID;
        public boolean isDependent;
        public Decimal EstimatedDuration;
        public String DurationUnits;
        public DateTime DueDate;
        public String OwnerID;
        public String TemplateID;
        public String LeavedZoneID;
        public String ValueStreamOld;
        public String ForceID;
        public String ValueStream;
        public String ValueStreamID;
        public String ZoneTitle;
        public String LeavedZoneTitle;
        public boolean isUndo;
        public String GUID;
        public DateTime StartDate;
        public String BoardType;
        public boolean leaf;
        public String LinkedCardVerb;
        public String ValueStreamName;
        public String dl;
        public String Extensions;
        public String verb;
        public String sessionID;      
        public boolean flowWithGS;
        public String ItemType;
        public Boolean IsSR;
        public List<String> cardIds;
        public String TargetVSID;
        public String SourceVSID;
        public String MySessionId;
        public String OldValueStreamId;
        public String multipleAPIName;
        public Boolean IsClone;
		//12:07:2022 Changes : Old board name was not receing in broadcast when hyperJumping the card.
        public String SwitchedVSName; 
        //25/08/2022 Changes : Broadcast was not receiving on PG when we link the card with Activity in case of PE channel.
        public String ValueStreamCardLink; 
       	public String ValueStreamLinkID;
    }
    
    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    Modified manageStateChange
    Inputs:         Id ValueStreamID, String verb, String someJSONData, String sessionID
    Returns:        -
    ------------------------------------------------------------*/
    global static void manageStateChange(Id valueStreamId, String verb, String someJSONData, String sessionId) {    
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();        
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior();
        ZoneBehavior zoneBehavior = new ZoneBehavior();
        MarkerBehaviour markerBehaviour = new MarkerBehaviour();
        ChartBehaviour chartBehaviour = new ChartBehaviour();
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior(); 
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();

        if (!realtimeTrackerBehavior.isAccessible() 
        || !realtimeTrackerBehavior.isCreateable()
        || !kanbanCardBehaviour.isAccessible()
        || !kanbanCardBehaviour.isUpdateable()
        || !kanbanCardBehaviour.isCreateable()
        || !subscriberBehavior.isAccessible() 
        || !subscriberBehavior.isUpdateable() 
        || !subscriberBehavior.isCreateable() 
        || !zoneBehavior.isAccessible()
        || !zoneBehavior.isCreateable()
        || !zoneBehavior.isUpdateable()
        || !markerBehaviour.isAccessible()
        || !markerBehaviour.isUpdateable()
        || !markerBehaviour.isCreateable()
        || !chartBehaviour.isAccessible()
        || !chartBehaviour.isUpdateable()
        || !chartBehaviour.isCreateable()
        || !entitySubscriptionBehaviour.isAccessible()
        || !entitySubscriptionBehaviour.isCreateable()
        || !resourceAssignmentBehavior.isAccessible()
        || !resourceAssignmentBehavior.isUpdateable()
        || !resourceAssignmentBehavior.isCreateable()
        || !scheduleModeBehavior.isAccessible()
        || !scheduleModeBehavior.isCreateable()
        || !scheduleModeBehavior.isUpdateable()
        || !feedItemBehaviour.isAccessible()
        || !feedItemBehaviour.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior	

        StateChangePackage stateChangePackageInstance = null;
        CardStreamingPackage cardStreamingPackageInstance = null;
        TaskData taskRecord;
        String currentUserID = '';
        String linkedCardVerb = '';
        String linkedValueStream = '';
        String oldParentKC = '';
        Boolean updateparent = false;
        Boolean oldParent = false;
        RealTimeControllerHelper.ManageStateChangeWrapper mscWrapperInstance = new RealTimeControllerHelper.ManageStateChangeWrapper();
        List<leankor__Zone__c> zones = new List<leankor__Zone__c>();
        List<leankor__Marker__c> markers = new List<leankor__Marker__c>();
        List<leankor__Chart__c> charts = new List<leankor__Chart__c>();
        List<String> jsonListData = new List<String>();

        //Substring for 0 to n number of jsondefinition and jsondata
        String someJSONDataModified = '';

        Set<String> broadcastVerbs = new Set<String> {
            'ManageDependency',
            'DeleteKanbanCard',
            'MoveKanbanCard',
            'CreateKanbanCard',
            'UpdateKanbanCard',
            'Hyper-leave',
            'Hyper-arrive',
            'NewChatterComments',
            'ManageSticker'
        };
        if (broadcastVerbs.contains(verb)) {
            // converting long json to smaller that will not break broadcast.
            cardStreamingPackageInstance = (CardStreamingPackage)JSON.deserialize(someJSONData, CardStreamingPackage.class);
            ///Pratiksha : 07/03/2023 : Changes for constraintRecalculate should be true only for Parent card from CV.
            isConstraintRecalculateForChildCard = cardStreamingPackageInstance.isCalledFromCV != null ?cardStreamingPackageInstance.isCalledFromCV : false;
            //03.02.2017 yj miniature broadcasting.

            //this is for activity history from calender View.
            if (verb == 'UpdateKanbanCard' && cardStreamingPackageInstance.BoardType != 'UberBoard' && cardStreamingPackageInstance.ValueStreamCardLink != null) {
                cardStreamingPackageInstance.LinkedCardVerb = 'CardHierarchyToOther';
            }
            if (cardStreamingPackageInstance.LinkedCardVerb == 'CardHierarchyToOther') {
                leankor__kanbancard__c vsTemplate = RealTimeControllerHelper.readLinkedCard(cardStreamingPackageInstance.Id);/*[Select leankor__ValueStreamCardLink__r.Name, leankor__ValueStreamCardLink__r.leankor__boardtype__c, leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c, leankor__ValueStream__r.leankor__IsTemplateBoard__c, leankor__ValueStreamLink__c, leankor__MasterContainer__r.leankor__Type__c from leankor__kanbancard__c where Id = : cardStreamingPackageInstance.Id limit 1];*/
                
                if (((vsTemplate.leankor__MasterContainer__r.leankor__Type__c != 'Template' && vsTemplate.leankor__ValueStream__r.leankor__IsTemplateBoard__c == false) || vsTemplate.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c == true)) {
                    cardStreamingPackageInstance.LinkCN = vsTemplate.leankor__ValueStreamCardLink__r.Name;
                    linkedCardVerb = cardStreamingPackageInstance.LinkedCardVerb;
                    linkedValueStream = (cardStreamingPackageInstance.ValueStreamLinkID != null && cardStreamingPackageInstance.ValueStreamLinkID != '' ? cardStreamingPackageInstance.ValueStreamLinkID : vsTemplate.leankor__ValueStreamLink__c);
                }
            } else {
                linkedCardVerb = cardStreamingPackageInstance.LinkedCardVerb;
                linkedValueStream = (cardStreamingPackageInstance.ValueStream != null ? cardStreamingPackageInstance.ValueStream : cardStreamingPackageInstance.ValueStreamID); // taking valueStreamId to broadcast in other board. this Id will not same as ValueStreamId (very first arugment in this method).
            } // taking verb to broadcast in other board.

            cardStreamingPackageInstance.verb = verb;
            if (verb == 'NewChatterComments') {
                someJSONData = someJSONData.removeEndIgnoreCase('}');
                someJSONData += ',"' + 'verb' + '":' + '"' + verb + '"' + '}';
                someJSONDataModified = someJSONData;
            } else {
                cardStreamingPackageInstance.SmallPhotoUrl = '';
                someJSONDataModified = JSON.serialize(cardStreamingPackageInstance);
            }
        } else if (verb == 'createTask' || verb == 'UpdateTask' || verb == 'DeleteTask') {
            taskRecord = (TaskData)JSON.deserialize(someJSONData, TaskData.class);
            linkedCardVerb = (taskRecord.LinkedCardVerb == null ? 'Other' : taskRecord.LinkedCardVerb);
            linkedValueStream = taskRecord.ValueStream;
            someJSONData = someJSONData.removeEndIgnoreCase('}');
            someJSONData += ',"' + 'verb' + '":' + '"' + verb + '"' + '}';
            someJSONDataModified = someJSONData;
        } else {
            someJSONData = someJSONData.removeEndIgnoreCase('}');
            someJSONData += ',"' + 'verb' + '":' + '"' + verb + '"' + '}';
            someJSONDataModified = someJSONData;
        }

        List<String> listOfJSON = new List<String>{someJSONDataModified};

        mscWrapperInstance.someJSONData = someJSONData;
        mscWrapperInstance.verb = verb;
        mscWrapperInstance.valueStreamID = valueStreamId;
        mscWrapperInstance.listOfJSON = listOfJSON;
        mscWrapperInstance.sessionID = sessionId;
        mscWrapperInstance.linkedCardVerb = linkedCardVerb;
        mscWrapperInstance.linkedVS = linkedValueStream;
        mscWrapperInstance.fieldMapKanbanCard = fieldMapKanbanCard;

        Savepoint sp = Database.setSavepoint();        
        try {     
            Switch on verb {
                when 'MoveKanbanCard','UpdateKanbanCard' {
                    mscWrapperInstance = RealTimeControllerHelper.moveOrUpdateKanbanCard(mscWrapperInstance);
                }
                when 'MoveZone','UpdateZone' {
                    zones = RealTimeControllerHelper.moveOrUpdateZone(someJSONData);
                }
                when 'MoveMarker' {
                    markers = RealTimeControllerHelper.moveMarker(someJSONData);
                }
                when 'MoveChart' {
                    charts = RealTimeControllerHelper.moveChart(someJSONData);
                }
                when 'UpdateHarveyBall' {
                    mscWrapperInstance = RealTimeControllerHelper.updateHarveyBall(mscWrapperInstance);
                }
                when 'MoveActivity' {
                    mscWrapperInstance = RealTimeControllerHelper.moveActivity(mscWrapperInstance);
                }
                when 'ManageDependency' {
                    mscWrapperInstance = RealTimeControllerHelper.manageDependencies(mscWrapperInstance);
                }
            }

            if (mscWrapperInstance != null) {
                // To create Subscriber
                if (mscWrapperInstance.subscribers != null) {
                    Schema.Sobjectfield subExternField = leankor__Subscriber__c.Fields.leankor__SubscriberKey__c;
                    Database.upsert(mscWrapperInstance.subscribers, subExternField, true);
                }

                // To create scheduleMode
                if (mscWrapperInstance.scheduleMode != null) {
                    Database.upsert(mscWrapperInstance.scheduleMode, true);
                }

                // To create ResourceAssignment
                if (mscWrapperInstance.resourceAssignment != null) {
                    Database.upsert(mscWrapperInstance.resourceAssignment, true);
                }

                // Task update if card's start date / due date change and task is not in between.
                if (mscWrapperInstance.listOfUpdateTask != null) {
                    leankor.OpenTaskRestriction.updateTask(mscWrapperInstance.listOfUpdateTask);
                }

                // To update KanbanCard
                if (mscWrapperInstance.kanbanCards != null) {
                    Schema.Sobjectfield externField = leankor__KanbanCard__c.Fields.leankor__GUID__c;
                    Database.upsert(mscWrapperInstance.kanbanCards, externField, true);
                }

                /*// To delete EntitySubscription
                if (mscWrapperInstance.entitySubscriptions != null) {
                    //ChatterAutoFollow.removeAutoFollow(mscWrapperInstance.entitySubscriptions); //First remove all subscription for the kanban card
                    Database.Delete(mscWrapperInstance.entitySubscriptions, true);
                }*/

                // To create EntitySubscription
                if (mscWrapperInstance.entitySubscriptionWrapperInstance != null) {
                    RealTimeControllerHelper.EntitySubscriptionWrapper esWrapperInstance = mscWrapperInstance.entitySubscriptionWrapperInstance;
                    if (esWrapperInstance.entitySubList.size() > 0) {
                        //ChatterAutoFollow.createAutoFollow(mscWrapperInstance.entitySubscriptionWrapperInstance.entitySubList);
                        Database.insert(esWrapperInstance.entitySubList, true);
                        if (esWrapperInstance.entitySubSobjectList.size() > 0) {
                            Database.insert(esWrapperInstance.entitySubSobjectList, true);
                        }
                    }
                }
            
                // To update zone
                if (zones.size() > 0) {
                    Schema.Sobjectfield externField = leankor__Zone__c.Fields.leankor__GUID__c;
                    Database.upsert(zones, externField, true); // GUID is the external unique key to match
                }

                // To update markers
                if (markers.size() > 0) {
                    Schema.Sobjectfield externField = leankor__Marker__c.Fields.leankor__GUID2__c;
                    Database.upsert(markers, externField, true); // GUID is the external unique key to match
                }

                // To update chart
                if (charts.size() > 0) {
                    Schema.Sobjectfield externField = leankor__Chart__c.Fields.leankor__GUID__c;
                    Database.upsert(charts, externField, true); // GUID is the external unique key to match
                } 
            
                // To insert FeedItem , it is for chatter.
                if (mscWrapperInstance.feeds != null) {
                    OpenFeedItemRestriction.createFeedItems(mscWrapperInstance.feeds);
                }

                //To remove  miniature reference
                if (mscWrapperInstance.miniature != null) {
                    Database.update(mscWrapperInstance.miniature, true);
                }

                RealTimeControllerHelper.realTimeTrackerHelper(mscWrapperInstance);

                Switch on verb {
                    when 'UpdateHarveyBall' {
                        if (mscWrapperInstance.stateChangePackageInstance.Boardtype != 'UberBoard') {
                            leankor.realtimeController.updateParentCards(mscWrapperInstance.kanbanCards);                            
                            leankor.ProjectBoardCarousel.updateActivityPercentageComplete(mscWrapperInstance.activityIds);
                        } else if (mscWrapperInstance.stateChangePackageInstance.State != 'Unable') {
                            // this method will update  Resource assigment percent completed field as same as activity HarveyBall.
                            leankor.ProjectBoardCarousel.updateActivityPercentageComplete(mscWrapperInstance.activityIds);
                        }
                    }
                    when 'MoveActivity' {
                        if (mscWrapperInstance.stateChangePackageInstance.Boardtype != 'UberBoard') {
                            leankor.realtimeController.updateParentCards(mscWrapperInstance.kanbanCards);
                        }
                    }
                    when 'MoveKanbanCard','UpdateKanbanCard' {
                        if (mscwrapperInstance.oldParent) {
                            leankor.realtimeController.updateParentCards((List<leankor__kanbancard__c>)JSON.deserialize(mscwrapperInstance.oldParentKC, List<leankor__kanbancard__c>.class));
                        }
                        if (mscWrapperInstance.updateparent) {
                            if (!mscWrapperInstance.kanbanCards.isEmpty()) {
                                leankor.realtimeController.updateParentCards(mscWrapperInstance.kanbanCards);
                            }
                        }

                        leankor.ProjectBoardCarousel.updateActivityPercentageComplete(mscWrapperInstance.activityIds);

                        if (mscWrapperInstance.resourceAssignmentList != null) {
                            update mscWrapperInstance.resourceAssignmentList;
                        }
                    }
                }
                
                //RS 12/12/2017 If condition that will work for generic streaming in flow for broadcasting.
                if(IS_GENERIC_STREAMING){
                    if (broadcastVerbs.contains(verb)) {
                        if (cardStreamingPackageInstance.flowWithGS == true) {
                            jsonListData.add(JSON.serialize(cardStreamingPackageInstance));
                            GenericStreamingController.broadcastNotificationAsync(verb, jsonListData);
                        }
                    } else if (verb == 'createTask' || verb == 'UpdateTask' || verb == 'DeleteTask') {
                        if (taskRecord.flowWithGS == true) {
                            jsonListData.add(JSON.serialize(taskRecord));
                            GenericStreamingController.broadcastNotificationAsync(verb, jsonListData);
                        }
                    } else if ((verb == 'PopUp' || verb == 'UpdateRuntimeBoard')) {
                        //RS 19/12/2017 for popUpAction API for GS
                        leankor.KanbanController.PopUp popUpInstance = (leankor.KanbanController.PopUp)JSON.deserialize(someJSONData, leankor.KanbanController.PopUp.class);
                        popUpInstance.verb = verb;
                        if (popUpInstance.flowWithGS == true) {
                            jsonListData.add(JSON.serialize(popUpInstance));
                            leankor.GenericStreamingController.broadcastNotificationAsync(verb, jsonListData);
                        }
                    }
                }
            }
       } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            if ((e.getMessage()).containsIgnoreCase('TRANSFER_REQUIRES_READ')) {
                throw new Util.LeanException('Insufficient privileges to change the ownership of this record. Please contact your Admin');
            } else {
                //Exception is commented for fixing the self link issue with single kanbancard.
              //  throw new Util.LeanException('Error: ' + e.getmessage()); 
            }
        }
    }


    /***
     * this type of 'future' usage runs asynchronously
     * and will be called once when the realtime kanban opens to create a trackable flow
     * @future
    */

    global static void createValueStreamPushTopic(Id valueStreamId, String someJSONData, String sessionId) {

		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
                      
        List<String> jsonList = new List<String>{someJSONData};
        leankor.GenericStreamingController.createRealtimeTracker(valueStreamId ,'OpenValueStream', jsonList, sessionId);        
    }
    
    
    // the internal model representation of a kanban card in Force.com and in the MVC web data store
    global class Kanban {
        global String Id;
        global String CardID;
        global String Title;
        global Decimal Top;
        global Decimal Bottom;
        global Decimal Left;
        global Decimal Width;
        global Decimal Height;
        global Decimal X;
        global Decimal Y;
        global String GUID;
        global String JSONData;
        global String JSONDefinition;
        global String State;
        global String ZoneID;
        global String MCForceID;
        global String SWForceID;
        global String ZoneForceID;
        global String Base64Drawing;
        global String Base64FileType;
        global String Name; // the Name field of the Kanban Card comes from Name of Kanban Card Template
        global String TemplateID; // kanban card template Force.com id
        global String TemplateName;
        global Decimal EstimatedDuration; // new field to track if project/product on schedule;
        global String Color; // EjB7: added
        global DateTime DueDate; // EjB10: added due date
        global String DurationUnits; //EjB11: added durationUnits picklist string
        global Integer Priority; //EjB14: added priority
        global String HarveyBall;
        global String DateColor;
        global String OwnerID;
        global String Description;
        global String KanbanUrl;
        global String ValueStreamCardLink;
        global String ValueStreamLinkID;
        global String ValueStreamOld;
        global String ValueStreamName;
        global String ValueStreamCardLinkName;
        global String ValueStreamLinkIDName;
        global String ValueStreamLinkBoardType;
        global String Account;
        global String Contact;
        global String CaseID;
        global String ForceID;
        global String CmpID;
        global String ValueStream;
        global String AccountName;
        global String ContactName;
        global String CaseSubject;
        global String CaseStatus;
        global String CasePriority;
        global boolean CaseTrigger;
        global boolean isUndo;
        global String ZoneTitle;
        global String LeavedZoneTitle;
        global DateTime StartDate;
        global Decimal PercentDone;
        global boolean leaf; //Variable used in LeankorGanttJS chart(Case Sensitive)
        global String LastModifiedDate;
        global String CreateDate;
        global String Extensions;
        global String LeavedZoneID;
        global Decimal xcount;
        global Decimal xindex;
        global Decimal Order;
        global String Opportunity;
        global String OpportunityName;
        global String OpportunityStage;
        global String SmallPhotoUrl;
        global String ItemType;
        global String BoardType;
        global String OnBudget;
        global String OnQuality;
        global String OnTime;
        global Integer TaskComments;
        global String OwnerName;
        global String UrlLink;
        global Decimal Point;
        global boolean SWeek;
        global Decimal EffortRemaining;
        global String successorsArray;
        global String AcceptanceCriteria;
        global String dl;
        // To support broadcasting for scheduling  mode Object  SD 02-01-17
        global string SchedulingMode;
        global boolean ManuallyScheduled;
        global decimal Effort;
        global string EffortUnit;
        global string SchedulingModeId; 
        // 10.12.2016 for clone project : stop previous kanban card update
        global String checkcloneProject;
        // 22.12.2016 yj for clone schedule and assignment
        global List<leankor__ScheduleMode__c > schedulemodeList;
        global List<leankor__ResourceAssignment__c > resourceAssignmentList;
        //added variable for miniature of planGantt broadcastiong
        global String ProjectName;
        global String sessionID;
        global String ValueStreamID;
        global Boolean IsExternallyDependent;//if Activity have Externally dependent than this field value will be true.        
        global String LinkedCardVerb;// added by shreyas for multi broadcasting
        global Date HarveyBallDoneDate; //cloning harvey ball done date
        global DateTime PromiseCompletionDate; //cloning harvey ball done date
        global Boolean IsSuccessorRecalculate; // recalculating successors of activity     
        global List<taskUsers> TaskUserNames; //Task list for task filter 
        global Boolean IsTemplate;  
        global Boolean IsProjectTemplate;  
        global boolean isTaskDueCheck;
        global boolean isMiniature;
        global Decimal Units;//Resource assignment allocation
        global String ProjectID;
        global String AssignToId;
        global Decimal percentCompleted;
        global Decimal percentAllocation;
        global string CSSLayout;        
        //CaseNumber may contain character so use string type
        public String caseNumber2;
        //We are not using this variable anymore
        global Decimal CaseNumber;
        global boolean flowWithGS; 
        global String ParentProjectRoomID;
		//Add FSL record details with Activity
        public Integer workOrderCount;
        public Integer serviceAppointmentCount;
        public DateTime fslSchedStartDateTime;
        public DateTime fslSchedDueDateTime;
        public  Boolean isDueDatePercentComplete;
        public String timeToProjectLaunch;
	    public Boolean isAtRisk;
		public Boolean isOnHold;
        public leankor__kanbancard__c kanbanCustomField;
        public Boolean ownerIsActive;
        public String masterContainerName;
        public String zoneName;
        public String swimlaneName;
  		// Date: 31/1/2020 - To assign the resource on Activity creation.
        public Boolean autoAssignResource;
        public String recordTypeId;
        public List<leankor.GanttTaskBoard.Miniature> miniature;
        global String ConstraintType;
        global DateTime ConstraintDate;
        //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
        global Boolean isConstraintRecalculate;
        //24/Feb/2023 : Both varibale added for showing parent Card Constraint data in KB.
        public String parentCardConstraintType;
        public DateTime parentCardConstraintDate;
        public String LinkProjectRoomID;

        //Pratiksha : 10/Oct/2023
        public Boolean Monday;
        public Boolean Tuesday;
        public Boolean Wednesday;   
        public Boolean Thursday;
        public Boolean Friday;
        public Boolean Saturday;
        public Boolean Sunday;
        public String weekCalendar;
        public Boolean isScheduleBackward;
        //shakil
         public Integer seriesNumber;

    }


    // the internal model representation of a zone in Force.com and in the MVC web data store
    global class Zone {
        global String Id;
        global String Title;
        global Decimal Top;
        global Decimal Bottom;
        global Decimal Left;
        global Decimal width;
        global Decimal Height;
        global Decimal X;
        global Decimal Y;
        global String ZoneOpportunityStage;
        global String EntryFlowName;
        global String ExitFlowName;
        global String VSLink; // drill down to another detail level of the value stream
        global String ZoneMode;
        global String KanbanSequence;
        global String ValuestreamLinkID;
        global String ValueStreamCardLink;
        global String ValueStreamLinkBoardType;
        global Decimal DefaultHeight;
        global Decimal Defaultwidth;
        global String ZoneStatus;
        global Decimal TaskLimit;
        global Decimal Order;
        global String ParentZone;
        global String Swimlane;
        global Decimal CardsPerRow;
        global String Help;
        global String GUID;
        global String ValueStream;
        global String CaseStatus;
        global String CmpID;
        global String CompletionRateUnits;
        global Decimal CompletionRate;
        global String CSSLayout;
        global String JSONDefinition;
        global Decimal KanbanCardCount;
        global Decimal KanbanCardThroughput;
        global Decimal LeadTime;
        global String ZoneTemplate;
        global String Name;
        global String OwnerID;
        global Boolean leaf;
        global List<leankor.KanbanToGanttController.MasterContainer > children;
        global boolean expanded;
        global String StartDate;
        global String DueDate;
        global String ForceID;
        global String ItemType;
        global String Color;
        global String UrlLink; //  To save URL Link For Per Zone
        global String Unit;
    }


    //Internal model class for Background
    global class Backgrounds {
        global Integer Height;
        global Integer width;
    }


    // the key elements of the value stream to save which cannot use standard controller (view state limits)
    global class ValueStream {
        global String VSDrawing;
        global Backgrounds Background;
    }


    // the browser will make a remote call passing to us these two arrays of objects to store in Force.com
    global class WorkspacePackage {
        global ValueStream ValueStream;
        global List<Zone> Zones;
        global List<Kanban> KanbanCards;
    }


    /***
     * Save the kanban and zone information to the force.com system.
     * This particular call should be a candidate for a @future adornmnet.
     * INPUT: WorkspacePackage class which contains two arrays (zones and kanban cars)
     * OUTPUT: String of "success" if all went well and "ERROR: <some message>" if not
     * (there is likely a more formal way to pass result codes back and error messages!)
    */
    @RemoteAction
    global static String saveWorkspace(String valueStreamId, WorkspacePackage workSpace, String base64Pic) {
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        ZoneBehavior zoneBehavior =  new ZoneBehavior();
        KanbanCardBehaviour kanbanCardBehaviour =  new KanbanCardBehaviour();
        ValueStreamBehavior  valueStreamBehavior = new ValueStreamBehavior();
        
        if (!zoneBehavior.isAccessible() 
        || !zoneBehavior.isCreateable() 
        || !zoneBehavior.isUpdateable() 
        || !kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable() 
        || !kanbanCardBehaviour.isCreateable()
        || !valueStreamBehavior.isAccessible()
        || !valueStreamBehavior.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');        
        }
        //Check CRUD / FLC behavior

        Map<String, Map<String, String>> imageDetail = new Map<String,Map<String, String>>();
        leankor__KanbanCard__c[] kanbans = new leankor__KanbanCard__c[]{};
        leankor__Zone__c[] zones = new leankor__Zone__c[]{};
        leankor__ValueStream__c valueStream = new leankor__ValueStream__c();
        String returnString = 'success';

        for (Zone remoteZone : workSpace.Zones) {
            // make sure valid values for VSLink
            if (remoteZone.VSLink == '' || remoteZone.VSLink == null) {
                remoteZone.VSLink = null;
            } else {
                remoteZone.VSLink = remoteZone.VSLink.left(15);
            }

            leankor__Zone__c newZone = new leankor__Zone__c(
                leankor__GUID__c = remoteZone.GUID,
                leankor__Title__c = remoteZone.Title,
                Name = remoteZone.Title,
                leankor__Top__c = remoteZone.Top,
                leankor__Bottom__c = remoteZone.Bottom,
                leankor__Left__c = remoteZone.Left,
                leankor__width__c = remoteZone.width,
                leankor__Height__c = remoteZone.Height,
                leankor__X__c = remoteZone.X,
                leankor__Y__c = remoteZone.Y,
                leankor__EntryFlowName__c = remoteZone.EntryFlowName,
                leankor__ExitFlowName__c = remoteZone.ExitFlowName,
                leankor__ValueStream__c = valueStreamId.left(15), // should never be blank, so can do left() call
                leankor__ValueStreamLink__c = remoteZone.VSLink,
                leankor__ZoneMode__c = remoteZone.ZoneMode,
                leankor__KanbanSequence__c = remoteZone.KanbanSequence,
                leankor__CardsPerRow__c = remoteZone.CardsPerRow,
                leankor__Help__c = remoteZone.Help,
                leankor__Limit__c = remoteZone.TaskLimit,
                leankor__Order__c = remoteZone.Order,
                leankor__ParentZone__c = (remoteZone.ParentZone != '' ? remoteZone.ParentZone : null),
                leankor__Swimlane__c = (remoteZone.Swimlane != '' ? remoteZone.Swimlane : null)
            );

            zones.add(newZone);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            Schema.Sobjectfield externFieldZone = leankor__Zone__c.Fields.leankor__GUID__c;
            Database.upsert(zones, externFieldZone, true); // GUID is the external unique key to match

            for (Kanban remoteKanban : workSpace.KanbanCards) {
                // make sure valid values for TemplateID
                if (remoteKanban.TemplateID == '' || remoteKanban.TemplateID == null) {
                    remoteKanban.TemplateID = null;
                } else {
                    remoteKanban.TemplateID = remoteKanban.TemplateID.left(15);
                }
                //06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
                leankor__KanbanCard__c newKanban = new leankor__KanbanCard__c(
                    leankor__GUID__c = remoteKanban.GUID,
                    leankor__Title__c = remoteKanban.Title,
                    Name = remoteKanban.Name,
                    leankor__Top__c = remoteKanban.Top,
                    leankor__Bottom__c = remoteKanban.Bottom,
                    leankor__Left__c = remoteKanban.Left,
                    leankor__width__c = remoteKanban.width,
                    leankor__Height__c = remoteKanban.Height,
                    leankor__X__c = remoteKanban.X,
                    leankor__Y__c = remoteKanban.Y,
                    //leankor__JSONData__c = remoteKanban.JSONData,
                    //leankor__JSONDefinition__c = remoteKanban.JSONDefinition,
                    leankor__State__c = remoteKanban.State,
                    leankor__ZoneGUID__c = remoteKanban.ZoneID,
                    leankor__MasterContainer__c = remoteKanban.MCForceID,
                    leankor__Swimlane__c = remoteKanban.SWForceID,
                    leankor__Zone__c = remoteKanban.ZoneForceID,
                    leankor__ValueStream__c = valueStreamId.left(15), // make sure ID is correct
                    leankor__KanbanCardTemplate__c = remoteKanban.TemplateID,
                    leankor__EstimatedDuration__c = remoteKanban.EstimatedDuration,
                    leankor__Color__c = remoteKanban.Color,
                    leankor__DueDate__c = Date.newInstance(remoteKanban.DueDate.year(), remoteKanban.DueDate.month(), remoteKanban.DueDate.day()),
                    leankor__DurationUnits__c = remoteKanban.DurationUnits, // EjB11: added this picklist value
                    leankor__Priority__c = remoteKanban.Priority, //EjB14: added priority
                    leankor__StartDate__c = Date.newInstance(remoteKanban.StartDate.year(), remoteKanban.StartDate.month(), remoteKanban.StartDate.day()),
                    leankor__StartDateTime__c = remoteKanban.StartDate,
                    leankor__DueDateTime__c = remoteKanban.DueDate,
                    leankor__OnBudget__c = remoteKanban.OnBudget,
                    leankor__OnQuality__c = remoteKanban.OnQuality,
                    leankor__OnTime__c = remoteKanban.OnTime
                );

                kanbans.add(newKanban);
            }

            Schema.Sobjectfield externFieldKanbanCard = leankor__KanbanCard__c.Fields.leankor__GUID__c;
            List<Database.Upsertresult> uResults = Database.upsert(kanbans, externFieldKanbanCard, true); // GUID is the external unique key to match

            // cycle through kanban results and insert drawings where necessary
            Integer counter = 0;

            for (Database.Upsertresult kanResult : uResults) {
                // save the drawing if it exists
                // TODO: might need to change savePreview() to FUTURE async to speed this up
                if (kanResult.isSuccess() && String.isNotBlank(workSpace.KanbanCards[counter].Base64Drawing)) {
                    Map<String, String> tempMap = new Map<String, String>();
                    tempMap.put('base64Pic',workSpace.KanbanCards[counter].Base64Drawing);
                    tempMap.put('fType',workSpace.KanbanCards[counter].Base64FileType);
                    imageDetail.put(kanResult.getId(), tempMap);
                }

                counter++;
            }
            savePreview(imageDetail,'drawing');
            imageDetail.clear();
            Map<String, String> tempMap = new Map<String, String>();
            tempMap.put('base64Pic',base64Pic);
            tempMap.put('fType','image/jpeg');
            imageDetail.put(valueStreamId, tempMap);
            // save the png/jpeg image preview of the value stream
            if (!savePreview(imageDetail,'preview')) {
                System.debug('ERROR: Problem saving the value stream preview image to Force.com');
                returnString += 'ERROR: Problem saving the value stream preview image to Force.com';
            }
            imageDetail.clear();
            tempMap.put('base64Pic',workSpace.ValueStream.VSDrawing);
            imageDetail.put(valueStreamId, tempMap);
            // save the png image drawing of the value stream
            if (String.isNotBlank(workSpace.ValueStream.VSDrawing)) {
                if (!savePreview(imageDetail,'drawing')) {
                    System.debug('ERROR: Problem saving the value stream drawing to Force.com');
                    returnString += 'ERROR: Problem saving the value stream drawing to Force.com';
                }
            }

            // save background X,Y coordinates (and in future any other value stream info)
            valueStream.Id = valueStreamId;
            valueStream.leankor__BackgroundHeight__c = workSpace.ValueStream.Background.Height;
            valueStream.leankor__Backgroundwidth__c = workSpace.ValueStream.Background.width;

            // Date: 06/06/2019 - Use to save the board. Upsert the value stream record in case of read only access to the board.
            List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();
            valueStreams.add(valueStream);
            leankor.RealTimeControllerHelper.updateOperation_Helper(valueStreams);
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }          

        // IMPORTANT: this call does not refresh the page automatically, but the JavaScript on client side MUST
        // this is to update the internal MVC model with new force.com ID's so future deletes can succeed
        return returnString;
    }


    /***
     * Helper method for the above saveWorkspace()
     * INPUT: png/jpeg snapshot in base64 encoding and the parent ID (valuestream or kanban card ID of the Attachment)
     * and the base file name/type to upsert ('preview' for a value stream preview image and 'drawing' for back of kanban/value stream drawing)
     * OUTPUT: hopefully a saved file and return code TRUE if successful insertion or update
    */
    global static Boolean savePreview(String PID, String Base64Pic, String FName, String FType) {
        /*
		//Check CRUD / FLC behavior
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        if (
            !attachmentBehaviour.isAccessible() ||
            !attachmentBehaviour.isCreateable() ||
            !attachmentBehaviour.isUpdateable() 
        ) {
            return false;
        }

        
        //Check CRUD / FLC behavior
        List<Attachment> Attach = new List<Attachment>();
        // only select those records with "preview" in the file name (value streams have ONE)
        String LikeSearch = '%' + FName + '%';
        // yj 08.08.17 
        // 1. Added Parent.Type to make the query to Attachment faster
        Attach = [Select Id, Name, Body, ContentType, ParentID from Attachment where ParentID = : PID AND Parent.Type IN :SETSTICKERSOBJECTS_CONST AND Name LIKE: LikeSearch LIMIT 1];
        if (Attach.size() == 0) {
            String Suffix = '';
            if (FType == 'image/jpeg') {
                Suffix = '.jpg';
            } else {
                Suffix = '.png';
            }
            Attachment NewAttach = new Attachment(
                    Name = FName + Suffix,
                    ContentType = FType,
                    ParentID = PID,
                    Body = EncodingUtil.Base64Decode(Base64Pic));
            try {
                if (Attachment.sObjectType.getDescribe().isCreateable()) {
                    insert NewAttach;
                }
            } catch (DmlException e) {
                System.debug(e.getMessage());
                return false;
            }
            // if we get here, successful insertion of new attachment pic
            return true;
        }

        Attach[0].Body = EncodingUtil.Base64Decode(Base64Pic);
        try {
            if (Attachment.sObjectType.getDescribe().isUpdateable()) {
            	// Date: 06/06/2019 - Need to put in without sharing class beacuse of cross value reference excetion on attachment.
                // update Attach;
                leankor.RealTimeControllerHelper.updateOperation_Helper(Attach);
            }
        } catch (DmlException e) {
            System.debug(e.getMessage());
            return false;
        }
        */
        return false;
    }
    /***
     * Overloaded Helper method for the above saveWorkspace() method
     * INPUT: First input is Map in which keys are ParentId of attachment object and value is another map(contains 'base64Pic' or 'fType' as a key and String value as a value) and
     *        second input is name of attachment and of type string
     * OUTPUT: hopefully a saved file and return code TRUE if successful insertion or update
    */
    global static Boolean savePreview(Map<String, Map<String, String>> imageDetail, String fName) {        
        //Check CRUD / FLC behavior
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        set<String> parentIds = imageDetail.keySet();
        if (!attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isCreateable() 
        || !attachmentBehaviour.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');        
        }
        //Check CRUD / FLC behavior

        // only select those records with "preview" in the file name (value streams have ONE)
        String likeSearch = '%' + fName + '%';

        List<Attachment> attachments = [Select Id, 
                                                Name, 
                                                Body, 
                                                ContentType, 
                                                ParentId 
                                            From Attachment 
                                            Where ParentId In :parentIds 
                                                And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                And Name Like :likeSearch];

        try {
            if (attachments.size() > 0) {
                for(Attachment attach : attachments ){
                    attach.Body = EncodingUtil.Base64Decode(imageDetail.get(attach.ParentId).get('base64Pic'));
                }
                leankor.RealTimeControllerHelper.updateOperation_Helper(attachments);
                return true;
            } else {
                for(String parentId : parentIds){
                    String suffix = imageDetail.get(ParentId).get('fType') == 'image/jpeg' ? '.jpg' : '.png';
                    Attachment attachment = new Attachment(
                        Name = fName + suffix,
                        ContentType = imageDetail.get(ParentId).get('fType'),
                        ParentId = parentId,
                        Body = EncodingUtil.Base64Decode(imageDetail.get(parentId).get('base64Pic')));
                    attachments.add(attachment);
                }
                insert attachments;
                return true;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
    }


    /***
     * remote method to create a new zone; shortcut vs. saveWorkspace() which saves the whole value stream
     * INPUT: value stream ID (parent ID of the Zone) and a Zone record
     * Zone Class: String id, entryflowname, exitflowname, Integer title, top, bottom, left, width, height, x, y
     * OUTPUT: hopefully a saved Zone and returns the force.com ID for the UI MVC to save
    */
    @RemoteAction
    global static String createZone(String valueStreamId, List<Zone> remoteZones) {    

        // '' is a valid input for valueStreamId inside createZone method 
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        ZoneBehavior zoneBehavior =  new ZoneBehavior();
        if (!zoneBehavior.isAccessible() 
        || !zoneBehavior.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__Zone__c> newZoneList = new List<leankor__Zone__c>();

        for (Zone remoteZone : remoteZones) {
            leankor__Zone__c newZone = new leankor__Zone__c(
                leankor__UrlLink__c = remoteZone.UrlLink,
                leankor__GUID__c = remoteZone.GUID,
                leankor__Title__c = remoteZone.Title,
                leankor__Unit__c = remoteZone.Unit,
                Name = remoteZone.Title,
                leankor__Top__c = remoteZone.Top,
                leankor__Bottom__c = remoteZone.Bottom,
                leankor__Left__c = remoteZone.Left,
                leankor__width__c = remoteZone.width,
                leankor__Height__c = remoteZone.Height,
                leankor__X__c = remoteZone.X,
                leankor__OpportunityStageName__c = remoteZone.ZoneOpportunityStage,
                leankor__Y__c = remoteZone.Y,
                leankor__EntryFlowName__c = remoteZone.EntryFlowName,
                leankor__ExitFlowName__c = remoteZone.ExitFlowName,
                leankor__ValueStream__c = valueStreamId == '' ? null : valueStreamId,
                leankor__zoneMode__c = remoteZone.ZoneMode,
                leankor__kanbanSequence__c = remoteZone.KanbanSequence,
                leankor__ValueStreamLink__c = remoteZone.ValueStreamLinkID == '' ? null : remoteZone.ValueStreamLinkID,
                leankor__ValueStreamCardLink__c = remoteZone.ValueStreamCardLink == '' ? null : remoteZone.ValueStreamCardLink,
                leankor__Defaultwidth__c = remoteZone.Defaultwidth,
                leankor__DefaultHeight__c = remoteZone.DefaultHeight,
                leankor__CaseStatus__c = remoteZone.ZoneStatus,
                leankor__CardsPerRow__c = remoteZone.CardsPerRow,
                leankor__Help__c = remoteZone.Help,
                leankor__Limit__c = remoteZone.TaskLimit,
                leankor__Order__c = remoteZone.Order,
                leankor__ParentZone__c = remoteZone.ParentZone != '' ? remoteZone.ParentZone : null,
                leankor__Swimlane__c = remoteZone.Swimlane != '' ? remoteZone.Swimlane : null
            );

            newZoneList.add(newZone);
        }

        try {
            insert newZoneList;
        } catch (DmlException e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return newZoneList[0].Id;       
    }
    

    //TODO: This method is too long and must refactor
    /*
     change Input Parameter List of String to List of Wrapper class.  
	 No longer using the above method, use CreateKanbanCard method with parameter passed as List<Kanban> instead of list of string
	 To prevent unnecessory Serialization/Deserialization of data
    */
    public static List<leankor__KanbanCard__c> createKanbanCard(String valueStreamId, List<realTimeController.Kanban> remoteKanbanCard, Boolean cloneBoard) {
		// NOTE: Secure Coding input validation is inside createKanbanCards(valueStreamId, kanbancards) method, which is the calling method

        //Check CRUD / FLC behavior		
        KanbanCardBehaviour kanbanCardBehaviour =  new KanbanCardBehaviour();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();		
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior(); 
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();

        if (!kanbanCardBehaviour.isAccessible()	
        || !kanbanCardBehaviour.isUpdateable() 
        || !kanbanCardBehaviour.isCreateable() 
        || !resourceAssignmentBehavior.isAccessible() 
        || !resourceAssignmentBehavior.isCreateable() 
        || !scheduleModeBehavior.isAccessible() 
        || !scheduleModeBehavior.isCreateable() 
        || !subscriberBehavior.isAccessible() 
        || !subscriberBehavior.isUpdateable() 
        || !subscriberBehavior.isCreateable()
        || !entitySubscriptionBehaviour.isAccessible()
        || !entitySubscriptionBehaviour.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');        
        }
        //Check CRUD / FLC behavior

        List<leankor__KanbanCard__c> newKanbanCards = new List<leankor__KanbanCard__c>(); 

        Boolean updateparent = false;
        String defaultRecordTypeId, mileStoneCardId, folderCardId;
        
		Set<Id> resourceIds = new Set<Id>();
        Set<Id> resourceTypeIds = new Set<Id>();
        
		Map<Id, leankor__ResourceType__c> mapOfResourceType = new Map<Id, leankor__ResourceType__c>();
        Map<Id, leankor__Resource__c> resourceTypes = new Map<Id, leankor__Resource__c>();

        List<ChatterFeed> chatterFeeds = new List<ChatterFeed>();
        List<ZoneKanbanAction> zones = new List<ZoneKanbanAction>();        
		List<leankor__ResourceAssignment__c> resourceAssignments = new List<leankor__ResourceAssignment__c>();
        List<leankor__ScheduleMode__c> scheduleModes = new List<leankor__ScheduleMode__c>();	 
        Set<Id> oldResourceAssignmentIds = new Set<Id>();		     

        //Changed to Soql For loop query
        for (RecordType recordType : [Select Id, 
                                            Name 
                                        From RecordType 
                                        Where SobjectType = 'leankor__Kanbancard__c']) {

            if (recordType.Name == 'ActivityCard') {
                defaultRecordTypeId = recordType.Id;
            } else if (recordType.Name == 'MileStoneCard') {
                mileStoneCardId = recordType.Id;
            } else if (recordType.Name == 'FolderCard') {
                folderCardId = recordType.Id;
            }
        }
        
        leankor__Valuestream__c valueStreamLog = new leankor__Valuestream__c();

        if (!String.isBlank(valueStreamId)) {
            valueStreamLog = leankor.RealTimeControllerHelper.createKanbanCard_Helper_Vs(valueStreamId);
        }

        Map<String, Schema.SObjectField> fieldMapKanbanCardForClone = new DescribeSchema().getObjectFieldsForClone('leankor__KanbanCard__c');                             
		
		// Ramanand : 29/06/2021 - Changes : chaning set to map from here instead of set we will use map and will use map containsKey() method.  
        //Set<Id> activeUserIds = new Set<Id>();
		Map<Id, User> activeUserIdsMap = new map<Id, User>(); 
        /*for (User resourceUser : [Select Id 
                                        From User 
                                        Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST
                                            And IsActive = true
                                        Limit 50000]) {

            activeUserIds.add(resourceUser.Id);
        }*/
		activeUserIdsMap = new Map<Id, User>([SELECT Id FROM User WHERE IsActive = true]);

        for (realTimeController.Kanban remoteKanban : remoteKanbanCard) {                    
            leankor__KanbanCard__c newKanban = new leankor__KanbanCard__c(
                RecordTypeId = defaultRecordTypeId,
                OwnerId = (remoteKanban.ownerIsActive == null ? true : remoteKanban.ownerIsActive) ? remoteKanban.OwnerId : USER_ID_CONST,
                leankor__CardID__c = remoteKanban.CardID,
                leankor__GUID__c = remoteKanban.GUID,
                leankor__Title__c = remoteKanban.Title,
                leankor__Point__c = remoteKanban.point,
                leankor__EffortRemaining__c = remoteKanban.EffortRemaining,
                Name = remoteKanban.Name,
                leankor__Top__c = remoteKanban.Top,
                leankor__Bottom__c = remoteKanban.Bottom,
                leankor__Left__c = remoteKanban.Left,
                leankor__width__c = remoteKanban.width,
                leankor__Height__c = remoteKanban.Height,
                leankor__X__c = remoteKanban.X,
                leankor__Y__c = remoteKanban.Y,
                leankor__UrlLink__c = remoteKanban.UrlLink,
                leankor__ValueStream__c = valueStreamId == '' ? remoteKanban.ValueStream : valueStreamId,
                leankor__KanbanCardTemplate__c = remoteKanban.TemplateID == '' ? null : remoteKanban.TemplateID,
                leankor__EstimatedDuration__c = remoteKanban.EstimatedDuration,
                leankor__Color__c = remoteKanban.Color, // EjB7: added color and JSONDefinition
                //leankor__JSONDefinition__c = remoteKanban.JSONDefinition,
                //leankor__JSONData__c = remoteKanban.JSONData,
                leankor__DurationUnits__c = remoteKanban.DurationUnits, // EjB11: added duration units picklist string
                leankor__Priority__c = remoteKanban.Priority, //EjB14: added priority
                leankor__PercentComplete2__c = Integer.valueof(Decimal.valueof(remoteKanban.HarveyBall)), //field for Harvay Ball in percentage
                leankor__Order__c = remoteKanban.Order,
                leankor__DateColor__c = remoteKanban.DateColor, //field for foreground color of Date value
                leankor__DescriptionLong__c = remoteKanban.Description,
                leankor__ValueStreamCardLink__c = (remoteKanban.ValueStreamCardLink == '' ? (string.Isblank(valueStreamId) ? null : valueStreamLog.leankor__ValueStreamCardLink__c) : remoteKanban.ValueStreamCardLink),
                leankor__ValueStreamLink__c = (remoteKanban.ValueStreamLinkID == '' ? (string.Isblank(valueStreamId) ? null : valueStreamLog.leankor__ValueStreamLink__c) : remoteKanban.ValueStreamLinkID),
                leankor__Account__c = remoteKanban.Account == '' ? null : remoteKanban.Account,
                leankor__Contact__c = remoteKanban.Contact == '' ? null : remoteKanban.Contact,
                leankor__Case__c = remoteKanban.CaseID == '' ? null : remoteKanban.CaseID,
                leankor__ZoneGUID__c = remoteKanban.ZoneID == '' ? null : remoteKanban.ZoneID,
                leankor__MasterContainer__c = remoteKanban.MCForceID == '' ? null : remoteKanban.MCForceID,
                leankor__Swimlane__c = remoteKanban.SWForceID == '' ? null : remoteKanban.SWForceID,
                leankor__Zone__c = remoteKanban.ZoneForceID == '' ? null : remoteKanban.ZoneForceID,
                leankor__Opportunity__c = remoteKanban.Opportunity == '' ? null : remoteKanban.Opportunity,
                leankor__OnBudget__c = remoteKanban.OnBudget,
                leankor__OnQuality__c = remoteKanban.OnQuality,
                leankor__AcceptanceCriteria__c = remoteKanban.AcceptanceCriteria,
                leankor__OnTime__c = remoteKanban.OnTime,
                leankor__HarveyBallDoneDate__c = remoteKanban.HarveyBallDoneDate,
                leankor__PromiseCompletionDate__c = remoteKanban.PromiseCompletionDate,
                leankor__IsSuccessorRecalculate__c = remoteKanban.IsSuccessorRecalculate == null ? false : remoteKanban.IsSuccessorRecalculate,
                leankor__IsAtRisk__c = remoteKanban.isAtRisk != null ? remoteKanban.isAtRisk : false,
                leankor__IsOnHold__c =  remoteKanban.isOnHold != null ? remoteKanban.isOnHold : false,
                leankor__IsConstraintRecalculate__c = remoteKanban.isConstraintRecalculate != null ? remoteKanban.isConstraintRecalculate : false,
                leankor__Monday__c = remoteKanban.Monday == false ? false : true,
                leankor__Tuesday__c = remoteKanban.Tuesday == false ? false : true,
                leankor__Wednesday__c = remoteKanban.Wednesday == false ? false : true,
                leankor__Thursday__c = remoteKanban.Thursday == false ? false : true,
                leankor__Friday__c = remoteKanban.Friday == false ? false : true,
                leankor__Saturday__c = remoteKanban.Saturday == false ? false : true,
                leankor__Sunday__c = remoteKanban.Sunday == false ? false : true,
                leankor__WeekCalendar__c = String.isNotBlank(remoteKanban.weekCalendar) ? remoteKanban.weekCalendar : null
            );
             if(newKanban.Name.length() > 80){
                newKanban.Name = remoteKanban.Name.subString(0,80);
             }       
            //checking recordtype
            newKanban.RecordTypeId = remoteKanban.ItemType == 'FolderCard'
                                    ? folderCardId
                                    : (newKanban.leankor__EstimatedDuration__c == 0 && remoteKanban.ItemType == 'MileStoneCard' 
                                        ? mileStoneCardId 
                                        : defaultRecordTypeId);
            
            if (newKanban.leankor__ValueStreamCardLink__c != null && remoteKanban.BoardType != 'UberBoard') {
                updateparent = true;             
            }

            if (remoteKanban.checkcloneProject == 'StopOriginalkanbanCardUpdate') {                   
                updateparent = false;
            }

            newKanban.leankor__DueDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(remoteKanban.DueDate), DateTime.class);//remoteKanban.DueDate; //DateTime.valueOf(remoteKanban.DueDate),
            newKanban.leankor__StartDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(remoteKanban.StartDate), DateTime.class);//remoteKanban.StartDate; //DateTime.valueOf(remoteKanban.StartDate),                               
			newKanban.leankor__DueDate__c = Date.newInstance(newKanban.leankor__DueDateTime__c.year(), newKanban.leankor__DueDateTime__c.month(), newKanban.leankor__DueDateTime__c.day());
			newKanban.leankor__StartDate__c = Date.newInstance(newKanban.leankor__StartDateTime__c.year(), newKanban.leankor__StartDateTime__c.month(), newKanban.leankor__StartDateTime__c.day());                                

            // Changes related to add the custom fields in instance. 
            
            if (remoteKanban.kanbanCustomField != null) {    
                Map<String, Object> fieldsToValue = remoteKanban.kanbanCustomField.getPopulatedFieldsAsMap();
                for (String key : fieldsToValue.keySet()) {									
				    newKanban.put(key, fieldsToValue.get(key));				
			    }

            } else {
            	if (kanbanCardFieldSets.size() != 0) {            		
                   leankor.UpdateInjector updateInjector = new leankor.UpdateInjector();
                   newKanban = updateInjector.updateKanbanCard(newKanban, remoteKanban.JSONData, fieldMapKanbanCardForClone);
            	}
            }     

            newKanbanCards.add(newKanban);

            if (remoteKanban.resourceAssignmentList != null && remoteKanban.resourceAssignmentList.size() > 0) {
	            for (leankor__ResourceAssignment__c resource: remoteKanban.resourceAssignmentList) {
	            	//RS 28/11/2019 Instead of querying user record added owner.IsActive field in query
	            	//resourceIds.add(resource.leankor__AssignedTo__r.IsActive ? resource.leankor__AssignedTo__c : USER_ID_CONST);	            	
	            	// Ramanand : 29/06/2021 - Changes : cahing list to mapfrom here instead of list we will use map and will use map containsKey() method. 
					resourceIds.add(
                            activeUserIdsMap.containsKey(resource.leankor__AssignedTo__c) 
                            ? resource.leankor__AssignedTo__c 
                            : USER_ID_CONST
                        );
                    
                    if (String.isNotBlank(resource.leankor__ResourceType__c)) {
	            		resourceTypeIds.add(resource.leankor__ResourceType__c);
	            	}	            	
            	}
        	}
        }        

        // gets the latest resource record of each user 
		if (resourceIds.size() > 0) {
			resourceTypes = Resource.readResource(resourceIds); 
		}

        if (resourceTypeIds.size() > 0) {
			mapOfResourceType = ResourceType.readResourceType(resourceTypeIds);		            
        }
        	
        fieldMapKanbanCardForClone.clear();	  
        
        
        Map<String, String> resourceAssignmentReference = new Map<String, String>();
        if(CloneProjectAction.isClonedProject == true){
            resourceAssignmentReference = FinancialDataTableController.getNewProjectFinancial(valueStreamId);
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            Schema.Sobjectfield externField = leankor__KanbanCard__c.Fields.leankor__GUID__c;                           
            // To perform the DML for the cloning when the standard user don't have access to valueStream.
            leankor.RealTimeControllerHelper.createKanbanCard_Helper(newKanbanCards, externField, true);
            
            //start cloning RA and schedule mode        
            Map<String, leankor__KanbanCard__c> mapKanbanCards = new Map<String, leankor__KanbanCard__c>();                    
            for (leankor__KanbanCard__c newKanbanCard: newKanbanCards) {
                    String kanbanCardGUID = (newKanbanCard.leankor__GUID__c).SubStringBefore('-');

                    if (String.isNotBlank(kanbanCardGUID)) {
                        mapKanbanCards.put(kanbanCardGUID, newKanbanCard);
                    }
            }                                                     

            for (Kanban remoteKanban : remoteKanbanCard) {
                if (remoteKanban.resourceAssignmentList != null && remoteKanban.resourceAssignmentList.size() > 0) {                     
                    Set<Id> checkDuplicate = new Set<Id>();

                    for (leankor__ResourceAssignment__c base: remoteKanban.resourceAssignmentList) {
                        checkDuplicate.add(base.leankor__AssignedTo__c);
                    }
                                                                                    
                    for (leankor__ResourceAssignment__c base : remoteKanban.resourceAssignmentList) {
                        leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();                             
                        resourceAssignment.leankor__AssignedTo__c = base.leankor__AssignedTo__c;

                        if (!checkDuplicate.contains(USER_ID_CONST) && remoteKanban.ownerId == base.leankor__AssignedTo__c) {
                            //RS 28/11/2019 Instead of querying user record added owner.IsActive field in query
                            // Ramanand : 29/06/2021 - Changes : cahing list to mapfrom here instead of list we will use map and will use map containsKey() method.
							resourceAssignment.leankor__AssignedTo__c = activeUserIdsMap.containsKey(base.leankor__AssignedTo__c) ? base.leankor__AssignedTo__c : USER_ID_CONST;
                        }
                                                    
                        resourceAssignment.leankor__KanbanCard__c = mapKanbanCards.get(remoteKanban.Id).Id;
                        resourceAssignment.leankor__PercentAllocation__c = base.leankor__PercentAllocation__c;
                        resourceAssignment.leankor__PercentCompleted__c = base.leankor__PercentCompleted__c;
                        resourceAssignment.leankor__CompletedDate__c = mapKanbanCards.get(remoteKanban.Id).leankor__DueDateTime__c;
                        resourceAssignment.leankor__ReferenceSourceId__c = base.Id;
                        if (String.isNotEmpty(base.leankor__ResourceType__c)) {
                            resourceAssignment.leankor__ResourceType__c = base.leankor__ResourceType__c;
                        }
                        
                        if (mapOfResourceType.containsKey(resourceAssignment.leankor__ResourceType__c)) {
                            resourceAssignment = ResourceType.IS_MULTI_CURRENCY_ORGANIZATION ? ResourceType.setResourceAccounts(resourceAssignment.leankor__ResourceType__c, mapOfResourceType, resourceAssignment, true) : ResourceType.setResourceAccounts(resourceAssignment.leankor__ResourceType__c, mapOfResourceType, resourceAssignment);
                        } else {
                            resourceAssignment = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(resourceAssignment.leankor__AssignedTo__c, resourceTypes, resourceAssignment, true) : Resource.setResourceAccounts(resourceAssignment.leankor__AssignedTo__c, resourceTypes, resourceAssignment);
                        }
                        resourceAssignment.leankor__ProjectFinancial__c = (base.leankor__ProjectFinancial__c != null) ? (CloneProjectAction.isExpense == true && String.isNotBlank(resourceAssignmentReference.get(base.leankor__ProjectFinancial__c)) ? resourceAssignmentReference.get(base.leankor__ProjectFinancial__c) : base.leankor__ProjectFinancial__c ): null;
                        oldResourceAssignmentIds.add(base.Id);                                   
                        resourceAssignments.add(resourceAssignment);
                    }                   
                }
                //Ashutosh Gour (18/03/2021): Two new fields(leankor__ConstraintDateTime__c,leankor__ScheduleConstraint__c) add for impelementing constraint feature for creating card/ Activity form cloning.
                if (remoteKanban.schedulemodeList != null && remoteKanban.schedulemodeList.size() > 0) {     
                    leankor__ScheduleMode__c scheduleMode = new leankor__ScheduleMode__c();
                    scheduleMode.leankor__ManuallyScheduled__c = remoteKanban.schedulemodeList[0].leankor__ManuallyScheduled__c;
                    scheduleMode.leankor__Mode__c = remoteKanban.schedulemodeList[0].leankor__Mode__c;
                    scheduleMode.leankor__EffortUnits__c = remoteKanban.schedulemodeList[0].leankor__EffortUnits__c;
                    scheduleMode.leankor__EffortActual__c = remoteKanban.schedulemodeList[0].leankor__EffortActual__c;
                    scheduleMode.leankor__KanbanCard__c = mapKanbanCards.get(remoteKanban.Id).Id;
                    //scheduleMode.leankor__ReadOnly__c = remoteKanban.schedulemodeList[0].leankor__ReadOnly__c;
                    //Changes : Check constraint setting enable or not.
                    if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                        scheduleMode.leankor__ConstraintDateTime__c = (remoteKanban.ConstraintDate != null) ? remoteKanban.ConstraintDate : null;
                        scheduleMode.leankor__ScheduleConstraint__c = (remoteKanban.ConstraintType != null ) ? remoteKanban.ConstraintType : null;
                    }
                    scheduleModes.add(scheduleMode);
                }                        
            }

            if (resourceAssignments.size() > 0) {
                insert resourceAssignments;
                if(CloneProjectAction.isExpense == true){
                    RealTimeControllerHelper.cloneExpenseResourceAssignments(oldResourceAssignmentIds, resourceAssignments, valueStreamId);
                }
            }

            if (scheduleModes.size() > 0) {
                insert scheduleModes;
            }

            remoteKanbanCard.clear();
            mapKanbanCards.clear();
            resourceAssignments.clear();
            scheduleModes.clear();

            //For ExternalDependency case
            //Put parent id in map If card's mastercontainer is not template and parentId is not null
            for (leankor__KanbanCard__c parentKanbanCard : [Select leankor__ValuestreamCardLink__c,
                                                        leankor__ValueStream__r.leankor__IsTemplateBoard__c,
                                                        leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c 
                                                    From leankor__KanbanCard__c 
                                                    Where Id In :newKanbanCards 
                                                        And leankor__MasterContainer__r.leankor__Type__c In :MASTERCONTAINERTYPEFILTERS_CONST 
                                                        And leankor__Valuestream__r.leankor__BoardType__c In :BOARDTYPEFILTERS_CONST 
                                                        Limit 50000]) {
                
                if ((parentKanbanCard.leankor__ValueStream__r.leankor__IsTemplateBoard__c && parentKanbanCard.leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c) || 
                (!parentKanbanCard.leankor__ValueStream__r.leankor__IsTemplateBoard__c && !parentKanbanCard.leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c)) {
                    Util.recalculateRecord.put(parentKanbanCard.leankor__ValueStreamCardLink__c, true);
                }
            }

            if (updateparent) {
                leankor.RealTimeController.updateParentCards(newKanbanCards);
            }             
                
			//Ramanand : 05/07/2021 - Changes : We will call this block of code from another process while cloning project to decreate CPU time Limit.
	        //Pratiksha : 22/09/2021 - Changes for Async Board Clone.
			if(CloneProjectAction.isClonedProject == true || CloneProjectBoardAsyncAction.isClonedBoard == true){
	            CloneProjectAction.newKanbanCardsStatic = newKanbanCards;
	            CloneProjectAction.valueStreamIdStatic = valueStreamId;
	        }else{
	            if (newKanbanCards.size() > 0) {
	                List <String> valueStreamList = new List<String>();

	                if (String.isBlank(valueStreamId)) {
	                    for (leankor__KanbanCard__c kanban : newKanbanCards) {
	                        valueStreamList.add(kanban.leankor__ValueStream__c);
	                    }
	                } else {
	                    valueStreamList.add(valueStreamId);
	                }

	                List<leankor__Preference__c> preferences = [Select Id, 
	                                                                Name, 
	                                                                leankor__ValueStream__r.leankor__BoardType__c,
	                                                                leankor__CardPastDueDate__c, 
	                                                                leankor__DerivedFrom__c, 
	                                                                leankor__FollowOnChatter__c, 
	                                                                leankor__GUID__c, 
	                                                                leankor__Moved__c, 
	                                                                leankor__PercentDone__c, 
	                                                                leankor__SubscribeToCard__c, 
	                                                                leankor__TaskPastDueDate__c, 
	                                                                leankor__isTaskCompleted__c, 
	                                                                leankor__ValueStream__c, 
	                                                                OwnerID 
	                                                            From leankor__Preference__c 
	                                                            Where leankor__ValueStream__c In :valueStreamList 
	                                                                And OwnerID In (Select Id 
	                                                                                    From User 
	                                                                                    Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST) 
	                                                            Limit 50000];

	                List<leankor__Subscriber__c> subscribers = new List<leankor__Subscriber__c>();
	                List<EntitySubscription> entitySubscriptions = new List<EntitySubscription>();
	                List<sObject> sObjectEntitySubscriptions = new List<EntitySubscription>();

	                if (preferences.size() > 0) {
	                    for (leankor__KanbanCard__c kanban: [Select Id,
	                                                            leankor__ValueStream__r.Name,
	                                                            RecordType.Name,
	                                                            leankor__ProjectRoom__c, 
	                                                            leankor__TemplateBoard__c,
	                                                            leankor__MasterContainer__r.leankor__Type__c,
	                                                            leankor__KanbanCardTemplate__c,
	                                                            leankor__ValueStream__c, 
	                                                            leankor__ValueStream__r.leankor__BoardType__c,
	                                                            leankor__ValueStream__r.leankor__ProjectRoom__c, 
	                                                            leankor__ZoneGUID__c, 
	                                                            Name, 
	                                                            OwnerId 
	                                                        From leankor__KanbanCard__c 
	                                                        Where Id In :newKanbanCards]) {

	                        // preparing data for bulk enter the zone method
	                        if (String.isNotBlank(kanban.leankor__ZoneGUID__c)) {
	                            ZoneKanbanAction zoneKanbanAction = new ZoneKanbanAction();
	                            zoneKanbanAction.KanbanID = kanban.Id;
	                            zoneKanbanAction.ZoneID = kanban.leankor__ZoneGUID__C;
	                            zoneKanbanAction.SwimlaneID = '';
	                            zoneKanbanAction.MasterContainerID = '';
	                            zoneKanbanAction.VSID = kanban.leankor__ValueStream__C;
	                            zoneKanbanAction.Action = 'Entered Zone';
	                            zoneKanbanAction.SessionID = USER_SESSION_ID_CONST;
	                            zones.add(zoneKanbanAction);
	                        }
                        
	                        // rbo 05.11.17 notify assigned owner of card creation regardless, but only if the owner is not the one who created the card
	                        //August 4 2017 : put template condition for prevent email notification to user for template borad
	                        if (kanban.OwnerID != USER_ID_CONST && !cloneBoard && kanban.leankor__TemplateBoard__c == LEANFALSE && kanban.leankor__MasterContainer__r.leankor__Type__c != 'Template') {

	                            ChatterFeed chatterFeed = new ChatterFeed();
	                            chatterFeed.KanbanID = kanban.Id;
	                            chatterFeed.KanbanTitle = kanban.Name;
	                            chatterFeed.ProjectBoardName = kanban.leankor__ProjectRoom__c +' / '+ kanban.leankor__ValueStream__r.Name ;
                            
	                            chatterFeed.kanbanURL ='https://' + DomainCreator.getOrgMyDomainHostname();
	                            //Need to checking board type here to make correct url for the Kanban Card.
	                            if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard') {
	                                if(kanban.RecordType.Name!='MileStoneCard') {
	                                    chatterFeed.kanbanURL += (new PageReference('/apex/leankor__GanttView').getUrl()) + '?fid=' + kanban.leankor__ValueStream__r.leankor__projectRoom__c + '&btype=projectgantt&' + 'Id=' + kanban.leankor__ValueStream__c +'&cardid=';
	                                } else {
	                                    chatterFeed.kanbanURL += (new PageReference('/apex/leankor__GanttView').getUrl()) + '?fid=' + kanban.leankor__ValueStream__r.leankor__projectRoom__c + '&btype=projectgantt&' + 'Id=' + kanban.leankor__ValueStream__c +'&cardid=&&ThisIsMilestone';
	                                }
	                            } else {
	                                if (kanban.RecordType.Name != 'MileStoneCard') {
	                                    if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board' || kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Plan Board') {
	                                        chatterFeed.kanbanURL += (new PageReference('/apex/leankor__KanbanBoard').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
	                                    } else if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
	                                        chatterFeed.kanbanURL += (new PageReference('/apex/leankor__PortfolioView').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
	                                    } else {
	                                        chatterFeed.kanbanURL += (new PageReference('/apex/leankor__VisualKanban').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
	                                    }
	                                } else {
	                                    chatterFeed.kanbanURL += (new PageReference('/apex/leankor__CalenderView').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=&&ThisIsMilestone';
	                                }
	                            }

	                            chatterFeed.AssignedUser = kanban.OwnerID;
	                            chatterFeeds.add(chatterFeed);
	                        } //End of if

	                        for (leankor__Preference__c preference : preferences) {                       
	                            if (valueStreamId != '' || preference.leankor__ValueStream__c == kanban.leankor__ValueStream__c) {

	                                //this is for subcriber of card
	                                if (preference.leankor__SubscribeToCard__c == 'all' || (preference.leankor__SubscribeToCard__c).contains(kanban.leankor__KanbanCardTemplate__c)) {
	                                    leankor__Subscriber__c subscriber = new leankor__Subscriber__c(
	                                        Name = kanban.Name,
	                                        leankor__KanbanCard__c = kanban.Id,
	                                        leankor__SubscriberID__c = preference.OwnerID,
	                                        leankor__Moved__c = preference.leankor__Moved__c,
	                                        leankor__PercentDone__c = preference.leankor__PercentDone__c,
	                                        leankor__CardPastDueDate__c = preference.leankor__CardPastDueDate__c,
	                                        leankor__TaskPastDueDate__c = preference.leankor__TaskPastDueDate__c,
	                                        leankor__isTaskCompleted__c = (preference.leankor__isTaskCompleted__c ? preference.leankor__isTaskCompleted__c : false),
	                                        leankor__Flag__c = 1,
	                                        leankor__Preference__c = preference.Id,
	                                        leankor__SubscriberKey__c = kanban.Id + '-' + preference.OwnerID
	                                    );

	                                    subscribers.add(subscriber);
	                                } //End of if

	                                //this is for My Preference of card                             
	                                if (preference.leankor__FollowOnChatter__c == 'all' || (preference.leankor__FollowOnChatter__c).contains(kanban.leankor__KanbanCardTemplate__c)) {
	                                    if (Network.getnetworkid() != null) {
	                                        sObject sObjectEntitySubscription = new EntitySubscription();
	                                        sObjectEntitySubscription.put('ParentID', kanban.Id);
	                                        sObjectEntitySubscription.put('NetworkID', Network.getnetworkid());
	                                        sObjectEntitySubscription.put('SubscriberID', preference.OwnerID);
	                                        sObjectEntitySubscriptions.add(sObjectEntitySubscription);
	                                    } else {
	                                        entitySubscriptions.add(new EntitySubscription(ParentID = kanban.Id, SubscriberId = preference.OwnerID));
	                                    }
                                                                                                    
	                                } //End of If
	                            }
	                        } //End of Preference Loop +"?fid={!leankor__ValueStream__c.leankor__ProjectRoomId__c}&btype=projectgantt&Id={!leankor__ValueStream__c.Id}"
	                    } //End of Kanban Card Loop
                    
	                    if (subscribers.size() > 0) {
	                        Schema.Sobjectfield externField1 = leankor__Subscriber__c.Fields.leankor__SubscriberKey__c;
	                        Database.upsert(subscribers, externField1, true);
	                    }

	                    if (entitySubscriptions.size() > 0) {
	                        ChatterAutoFollow.createAutoFollow(entitySubscriptions);
	                    }

	                    if (sObjectEntitySubscriptions.size() > 0) {
                            //21/04/2023 : Moving the code in Without sharing class for creating entitySubscription.
	                        //insert sObjectEntitySubscriptions;
                            ChatterAutoFollow.createAutoFollow(sObjectEntitySubscriptions);
	                    }

	                } else { //End of IF Prefences
	                    // notify assigned owner of card creation regardless, but only if the owner is not the one who created the card
	                    if (!cloneBoard) {
	                        //Id userId = USER_ID_CONST;
	                        String salesforceBaseURL = 'https://' + DomainCreator.getOrgMyDomainHostname();
                        
	                        for (leankor__KanbanCard__c kanban : [Select Id,
	                                                                leankor__TemplateBoard__c,
	                                                                leankor__MasterContainer__r.leankor__Type__c, 
	                                                                Name, 
	                                                                OwnerId,
	                                                                RecordType.Name,
	                                                                leankor__ValueStream__c,
	                                                                leankor__ValueStream__r.leankor__projectRoom__c,
	                                                                leankor__ValueStream__r.leankor__BoardType__c,
	                                                                leankor__ValueStream__r.Name,
	                                                                leankor__ProjectRoom__c
	                                                            From leankor__KanbanCard__c 
	                                                            Where Id In :newKanbanCards
	                                                                And leankor__MasterContainer__r.leankor__Type__c In :MASTERCONTAINERTYPEFILTERS_CONST]) {

	                            //August 4 2017 : put template condition for prevent email notification to user for template board
	                            if (kanban.OwnerID != USER_ID_CONST && kanban.leankor__TemplateBoard__c == LEANFALSE) {
	                                ChatterFeed chatterFeed = new ChatterFeed();
	                                chatterFeed.KanbanID = kanban.Id;
	                                chatterFeed.KanbanTitle = kanban.Name;                                     
	                                chatterFeed.KanbanURL = salesforceBaseURL;                           
	                                chatterFeed.ProjectBoardName = kanban.leankor__ProjectRoom__c + ' / ' + kanban.leankor__ValueStream__r.Name;
                                                    
	                                if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard') {
	                                    if (kanban.RecordType.Name!='MileStoneCard') {
	                                        chatterFeed.kanbanURL += (new PageReference('/apex/leankor__GanttView').getUrl()) + '?fid=' + kanban.leankor__ValueStream__r.leankor__projectRoom__c + '&btype=projectgantt&' + 'Id=' + kanban.leankor__ValueStream__c +'&cardid=';
	                                    } else {
	                                        chatterFeed.kanbanURL += (new PageReference('/apex/leankor__GanttView').getUrl()) + '?fid=' + kanban.leankor__ValueStream__r.leankor__projectRoom__c + '&btype=projectgantt&' + 'Id=' + kanban.leankor__ValueStream__c +'&cardid=&&ThisIsMilestone';
	                                    }
	                                } else {
	                                    if (kanban.RecordType.Name!='MileStoneCard') {
	                                        if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board' || kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Plan Board') {
	                                            chatterFeed.kanbanURL += (new PageReference('/apex/leankor__KanbanBoard').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
	                                        } else if (kanban.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
	                                            chatterFeed.kanbanURL += (new PageReference('/apex/leankor__PortfolioView').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
	                                        } else {
	                                            chatterFeed.kanbanURL += (new PageReference('/apex/leankor__VisualKanban').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=';
	                                        }
	                                    } else {
	                                        chatterFeed.kanbanURL += (new PageReference('/apex/leankor__CalenderView').getUrl()) + '?Id=' + kanban.leankor__ValueStream__c + '&cardid=&&ThisIsMilestone';
	                                    }
	                                }
                                
	                                chatterFeed.AssignedUser = kanban.OwnerID;
	                                chatterFeeds.add(chatterFeed);
	                            }           
	                        }
	                    }
	                }
	            }

			// Ramanand : 23/05/2021- Changes : Now we will call zoneKanbanActions method from queueable while creating recotrds from MultipleCreateKanbanCardAction API.
            if(isCalledAPI){
                leankor.CreateKanbanCardsQueueable.zoneKanbanActions = zones;
                leankor.MultipleCloneKanbanCardAction.zoneKanbanActions = zones;
            }else{
                enterTheZoneBulkify(zones);
            }

	            createChatterFeed(chatterFeeds, 'CreateKanbanCard'); // call for chatter feed
			}
        } catch(Exception e) {
			// Changes : Ramanand - 20/01/2022 : Fixed issue that community user facing while creating/cloning card INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY.
            Database.rollback(sp);
            System.debug(e.getMessage()); 
            throw new Util.LeanException('Error: ' + e.getmessage());
        }     

        return newKanbanCards;    
    }
    

    /***
     * remote method to create a new kanban card; shortcut vs. saveWorkspace() which saves the whole value stream
     * ASSUMPTION: this is called right away; before any drawing can be created, so no need to save drawing on back
     * INPUT: value stream ID (parent ID of the kanban card) and list of kanban card in form of json string.
     * Kanban Class: String id, Integer title, top, bottom, left, width, height, x, y etc.
     * OUTPUT: hopefully a saved card and returns the force.com Kanban card list for the UI MVC to save
     */
    //26.09.2017 : for Generic Streaming and Bulk call
    global class KanbanCardData{
        global List<leankor__KanbanCard__c> cardList;
        public String externalCardIds;
        global String kanbanIds;
        public Set<String> externallyDependentCardIds;
    }


    @RemoteAction
    global static KanbanCardData createKanbanCardGS(String valueStreamId, List<String> remoteKanbanCard) {
        // '' is a valid input for valueStreamId
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

       // Date : 22/10/19 using wrapper class instance instead of Serialization.
       List<leankor.realTimeController.Kanban> kanbancards = new List<leankor.realTimeController.Kanban>();
        for (String kanbancard : RemoteKanbanCard) {
       		leankor.realTimeController.Kanban card = (leankor.realtimeController.Kanban)JSON.deserialize(kanbancard, (leankor.realtimeController.Kanban.Class));
       		kanbancards.add(card);
       }

       KanbanCardData kanbanCardData = new KanbanCardData();    
       kanbanCardData.cardList = createKanbanCards(valueStreamId, kanbancards);
       kanbanCardData.kanbanIds = JSON.serialize(gskanbanCardIds);
       if (IS_GENERIC_STREAMING) {
        	kanbanCardData.externalCardIds =JSON.serialize(externalCardIDs);        
       }

       gskanbanCardIds.clear();
       externalCardIDs.clear();

       return kanbanCardData;
    }     
            
       
    @RemoteAction
    global static List<leankor__KanbanCard__c> createKanbanCard(String valueStreamId, List<String> remoteKanbanCard) {
        // '' is a valid input for valueStreamId
		if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<leankor.realTimeController.Kanban> remotekanbanCards = new List<leankor.realTimeController.Kanban>();
        
    	for (String cardJson : remoteKanbanCard) {
    		leankor.realTimeController.Kanban card = (leankor.realtimeController.Kanban)JSON.deserialize(cardJson, (leankor.realtimeController.Kanban.Class));
    		remotekanbanCards.add(card);
        }
   
        List<leankor__KanbanCard__c> kanbancards = new List<leankor__KanbanCard__c>();

        if (remotekanbanCards.size() > 0) {
            try {
                kanbancards = createKanbanCards(valueStreamId, remotekanbanCards);
            } catch (Exception e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return kanbancards;                      
    }
    
    
    /*
     	Date :22/10/19 
     	change Input Parameter List of String to List of Wrapper class.
    */     
    public static List<leankor__KanbanCard__c> createKanbanCards(String valueStreamId, List<realTimeController.Kanban> remoteKanbanCard) { 
        // input validation is done from the calling method

        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour =  new KanbanCardBehaviour();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable() 
        || !resourceAssignmentBehavior.isAccessible() 
        || !resourceAssignmentBehavior.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Boolean isUndo = false;
        Decimal units;

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();        
        List<Id> kanbancardLinkIds = new List<Id>();
        List<realTimeController.Kanban> remoteKanbanCards = new List<realTimeController.Kanban>();
        
        remoteKanbanCards.addAll(remoteKanbanCard);

        Savepoint sp = Database.setSavepoint();
        try {
            for (realTimeController.Kanban card : remoteKanbanCards) {            
                //checking boardtype condition except updating of AG's IsSuccessorRecalculate field 
                if(card.BoardType != 'UberBoard') {
                    if (String.isNotBlank(card.ValueStreamCardLink)) {
                        kanbancardLinkIds.add(card.ValueStreamCardLink);          
                    }
                    
                    //undo feature in kanban board
                    if(card.isUndo != null && card.isUndo == true) {                
                        isUndo = card.isUndo;    
                    }
                    
                    if(card.units != null) {
                        units = card.units;
                    }
                }
            }

            kanbanCards = createKanbanCard(valueStreamId, remoteKanbanCard, false);
            remoteKanbanCard.clear();

            Set<Id> resourceIds = new Set<Id>();
            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                kanbancardLinkIds.add(kanbanCard.Id);
                resourceIds.add(kanbanCard.OwnerId);           
            }

            // gets the latest resource record of each user 
            Map<Id, leankor__Resource__c> resourceTypes = Resource.readResource(resourceIds);  
                
            //when we click event on undo so again add RA and isrecordDeleted put again false
            if (isUndo) {        
                List<leankor__ResourceAssignment__c> resourceAssignments = new List<leankor__ResourceAssignment__c>();
                
                for (leankor__KanbanCard__c kanbanCard : kanbanCards) {                
                    kanbanCard.leankor__isRecordDeleted__c = false;               

                    leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();                
                    resourceAssignment.leankor__KanbanCard__c = kanbanCard.Id;
                    resourceAssignment.leankor__AssignedTo__c = kanbanCard.OwnerId;
                    resourceAssignment.leankor__PercentAllocation__c = 100;
                    resourceAssignment.leankor__PercentCompleted__c = kanbanCard.leankor__PercentComplete2__c;
                    resourceAssignment.leankor__CompletedDate__c = kanbanCard.leankor__DueDateTime__c;  
                    resourceAssignment = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(kanbanCard.OwnerId, resourceTypes, resourceAssignment, true) : Resource.setResourceAccounts(kanbanCard.OwnerId, resourceTypes, resourceAssignment);
                    resourceAssignments.add(resourceAssignment);
                }
                
                update kanbanCards;
                insert resourceAssignments;
            }
        
            //creating default RA and SM for 
            if (String.isNotBlank(valueStreamId)) {
                List<leankor__ValueStream__c> valueStreams = [Select Id,
                                                                    leankor__Boardtype__c,
                                                                    leankor__ProjectRoom__r.leankor__AutoAssignResource__c 
                                                                From leankor__ValueStream__c 
                                                                Where Id = :valueStreamId 
                                                                Limit 1];
                
                if (valueStreams.size() > 0 && valueStreams[0].leankor__ProjectRoom__r.leankor__AutoAssignResource__c == false && valueStreams[0].leankor__Boardtype__c == 'UberBoard') {                
                    leankor.GanttTaskBoard.CreateScheduleMode(kanbanCards);
                } else {
                    //if undo funtion is running so no need to create default resource we are creating above.
                    if (!isUndo) {
                        createDefaultResourceAssignment(kanbanCards, units);
                    }

                    leankor.GanttTaskBoard.CreateScheduleMode(kanbanCards);
                }                  
            }
			// Ramanand : 23/05/2021- Changes : Now we will call updateActivityPercentageComplete method from queueable while creating recotrds from MultipleCreateKanbanCardAction API.
            if(isCalledAPI){
                leankor.CreateKanbanCardsQueueable.kanbancardLinkIds = kanbancardLinkIds;
            }else{
                leankor.ProjectBoardCarousel.updateActivityPercentageComplete(kanbancardLinkIds);
            }
        } catch(Exception e) {
            //Changes : Ramanand - 20/01/2022 : Fixed issue that community user facing while creating/cloning card INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY. 
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }     

        return kanbanCards;                   
    }
    
    
    public static void createDefaultResourceAssignment(List<leankor__kanbancard__c> kanbanCards, Decimal units) {
        //Check CRUD / FLC behavior
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();

        if (!resourceAssignmentBehavior.isAccessible() 
        || !resourceAssignmentBehavior.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        List<leankor__ResourceAssignment__c> resourceAssignments = new List<leankor__ResourceAssignment__c>();
 		Set<Id> resourceIds = new Set<Id>();
        
        for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
			resourceIds.add(kanbanCard.OwnerId);
        }

        if (resourceIds.size() > 0) {
            // gets the latest resource record of each user 
            Map<Id, leankor__Resource__c> resourceTypes = Resource.readResource(resourceIds);  
            
            Id recordTypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
            for (leankor__kanbancard__c kanbanCard : kanbanCards) {    
                // creating RA for only activity card
                if(kanbanCard.RecordTypeId == recordTypeId) {
                    leankor__ResourceAssignment__c resourceAssignment = new leankor__ResourceAssignment__c();
                    resourceAssignment.leankor__KanbanCard__c = kanbanCard.Id;
                    resourceAssignment.leankor__AssignedTo__c = kanbanCard.OwnerId;
                    resourceAssignment.leankor__PercentAllocation__c = units != null ? units : 100;
                    resourceAssignment = Resource.IS_MULTI_CURRENCY_ORGANIZATION ? Resource.setResourceAccounts(kanbanCard.OwnerId, resourceTypes, resourceAssignment, true) : Resource.setResourceAccounts(kanbanCard.OwnerId, resourceTypes, resourceAssignment);
                    resourceAssignments.add(resourceAssignment);
                }
            }
            
            if (resourceAssignments.size() > 0) {
                insert resourceAssignments;
            }
        }
    }
    

    public static void removeLinkedCard(List<String> cardIds) {
		// NOTE: Secure Coding input validation is inside removeKanbanCard(List<String> cardIds) method, which is the calling method

        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior(); 
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior(); 

        if (!kanbanCardBehaviour.isAccessible()
        || !kanbanCardBehaviour.isCreateable()
        || !kanbanCardBehaviour.isUpdateable()
        || !valueStreamBehavior.isAccessible()
        || !valueStreamBehavior.isCreateable() 
        || !valueStreamBehavior.isUpdateable()
        || !timeCardBehavior.isAccessible()
        || !timeCardBehavior.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        // Date 03/05/19 get data from without sharing.
        List<leankor__KanbanCard__c> deletedCards = leankor.RealTimeControllerHelper.readremoveLinkedCard(cardIds);
        List<leankor__TimeCard__c> timeCards = new List<leankor__TimeCard__c>();
        List<leankor__KanbanCard__c> linkedCards = new List<leankor__KanbanCard__c>();        
        List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();                                                     
        List<leankor.realtimeController.bulkStreaming> bulkStreamingMessages = new List<leankor.realtimeController.bulkStreaming>();
        String valueSteamId;
        for (leankor__KanbanCard__c linkedCard : [Select Id,
                                                        leankor__ValueStream__c,
                                                        leankor__GUID__c,
                                                        leankor__ValueStreamCardLink__c, 
                                                        leankor__ValueStreamLink__c 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStreamCardLink__c In :deletedCards]) {

            linkedCard.leankor__ValueStreamCardLink__c = null;
            linkedCard.leankor__ValueStreamLink__c = null;
            
            leankor.realTimeController.CardStreamingPackage remoteKanban = new leankor.realTimeController.CardStreamingPackage();
            remoteKanban.Id = linkedCard.Id;            
            remoteKanban.GUID = linkedCard.leankor__GUID__c;
            remoteKanban.ForceID = linkedCard.Id;
            remoteKanban.Verb = 'UpdateMultipleKanbanCards';    
            //RS 1/04/2019 Added valuestream For single channel     
            remoteKanban.ValueStream = linkedCard.leankor__ValueStream__c; 
            //broadcasting for plangantt to other Board when deleting card 
            /*leankor.realtimeController.bulkStreaming bulkStreaming = new leankor.realtimeController.bulkStreaming();
            bulkStreaming.SomeJSONData = JSON.Serialize(remoteKanban);
            bulkStreaming.VSID =  linkedCard.leankor__ValueStream__c;                    
            bulkStreaming.SessionID = USER_SESSION_ID_CONST;
            bulkStreaming.Verb = 'UpdateMultipleKanbanCards';
            bulkStreamingMessages.add(bulkStreaming);*/
            valueSteamId = linkedCard.leankor__ValueStream__c;
            linkedCards.add(linkedCard);
            //RS 1/04/2019 To fix issue "Link still showing on child card, when parent card deleted"
            gskanbanCardIds.add(remoteKanban.Id);                  
        }

        //13/Feb/2024 : Preventing to call multiple Apex remote action method.
        leankor.realtimeController.bulkStreaming bulkStreaming = new leankor.realtimeController.bulkStreaming();
        RealTimeController.DirectLinkCardLog tempLog = new RealTimeController.DirectLinkCardLog();
        tempLog.cardIds = new List<String>(gskanbanCardIds);
        tempLog.ValueStreamID = valueSteamId;
        bulkStreaming.VSID =  valueSteamId;                    
        bulkStreaming.SessionID = UserInfo.getSessionId();
        bulkStreaming.Verb = 'UpdateMultipleKanbanCards';
        bulkStreaming.cardIds = new List<String>(gskanbanCardIds);
        bulkStreaming.SomeJSONData = JSON.Serialize(tempLog);
        bulkStreamingMessages.add(bulkStreaming);
        
        //getting default  link to null if card is deleted
        for (leankor__ValueStream__c valueStream : [Select Id,
                                                            leankor__ProjectRoomLink__c,
                                                            leankor__ValueStreamCardLink__c,
                                                            leankor__ValueStreamLink__c 
                                                        From leankor__ValueStream__c 
                                                        Where leankor__ValueStreamCardLink__c In :deletedCards]) { 
            valueStream.leankor__ProjectRoomLink__c = null;         
            valueStream.leankor__ValueStreamCardLink__c = null;
            valueStream.leankor__ValueStreamLink__c = null;
            valueStreams.add(valueStream);
        }  

        //24/06/2022 : Changes to remove linking from TimeCard while deleting KanbanCard.
        for (leankor__TimeCard__c timeCard: [Select Id,
                                                        leankor__KanbanCard__c
                                                From leankor__TimeCard__c 
                                                Where leankor__KanbanCard__c In : deletedCards 
                                                Limit 10000]) {
            timeCard.leankor__KanbanCard__c = null;
            timeCards.add(timeCard);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            upsert linkedCards;
            upsert valueStreams;
            update timeCards;

            //calling method for insert record into reatimetrackerlist for broadcasting   
            leankor.realtimeController.defaultLinkBroadcasting(bulkStreamingMessages, 'UpdateMultipleKanbanCards');
            //13/Feb/2024 : Preventing to call multiple Apex remote action method.
            //RealTimeController.sendBroadcast(bulkStreamingMessages, 'UpdateMultipleKanbanCards');
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }                  
    }
    

    /***
     * Removes the kanban from value stream by making the relationship field blank.
     * We do this rather than delete() because we may need the kanban and all its data for historical reporting
     * INPUT: The GUID for the kanban generated by the browser when it was first created
     * OUTPUT: String of "success" if all went well and "ERROR: <some message>" if not
     *  (there is likely a more formal way to pass result codes back and error messages!)
    */
    @RemoteAction
    global static String removeKanbanCard(List<String> cardIds) {
        if (cardIds.isEmpty()) {
            return 'Error: Unable to remove empty cards.';
        }
        //Check CRUD / FLC behavior		
        KanbanCardBehaviour kanbanCardBehaviour =  new KanbanCardBehaviour();
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior();
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();

        if (!kanbanCardBehaviour.isAccessible()	
        || !kanbanCardBehaviour.isUpdateable() 
        || !kanbanCardBehaviour.isCreateable() 
        || !subscriberBehavior.isAccessible() 
        || !subscriberBehavior.isUpdateable() 
        || !dependencyBehaviour.isAccessible() 
        || !dependencyBehaviour.isUpdateable() ){
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

        for (String cardId : cardIds) {                    
            if (String.isNotBlank(cardId)) {
                leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c(
                    leankor__GUID__c = cardId, 
                    leankor__ValueStream__c = null, 
                    leankor__isRecordDeleted__c = true
                );

                kanbanCards.add(kanbanCard);
            }
        }

        String returnString = 'success';

        if (kanbanCards.size() > 0) {
            List<leankor__KanbanCard__c> kanbanCardValueStreams = [Select leankor__Valuestream__c,
                                                                        leankor__Valuestream__r.leankor__BoardType__c
                                                                    From leankor__KanbanCard__c 
                                                                    Where Id In :cardIds
                                                                        Or leankor__GUID__c In :cardIds
                                                                    Limit 1];

            //Ashutosh : 13/10/2021 - Fixes for deleting dependencies.
            String valueStreamId = kanbanCardValueStreams.size() > 0 ? kanbanCardValueStreams[0].leankor__Valuestream__c : '';
            String boardType = kanbanCardValueStreams.size()> 0 ? kanbanCardValueStreams[0].leankor__Valuestream__r.leankor__BoardType__c : '';
            Schema.Sobjectfield ExternField = leankor__KanbanCard__c.Fields.leankor__GUID__c;               
            Database.upsert(kanbanCards, ExternField, true);
            /*List<EntitySubscription> entitySubscriptionList = [Select Id 
                                                                    From EntitySubscription 
                                                                    Where ParentId In :kanbanCards 
                                                                    Limit 1000];*/

            List<leankor__Subscriber__c> subscribers = [Select Id, 
                                                            leankor__Moved__c, 
                                                            leankor__PercentDone__c, 
                                                            leankor__CardPastDueDate__c, 
                                                            leankor__TaskPastDueDate__c, 
                                                            leankor__isTaskCompleted__c 
                                                        From leankor__Subscriber__c 
                                                        Where leankor__KanbanCard__c In :kanbanCards 
                                                        Limit 10000];

            for (leankor__Subscriber__c subscriber: subscribers) {
                subscriber.leankor__Moved__c = false;
                subscriber.leankor__PercentDone__c = false;
                subscriber.leankor__CardPastDueDate__c = false;
                subscriber.leankor__TaskPastDueDate__c = false;
                subscriber.leankor__isTaskCompleted__c = false;
            }

            Map<Id, leankor__KanbanCard__c> mapKanbanCards = new Map<Id, leankor__KanbanCard__c>([Select Id, 
                                                                                                    leankor__ValueStreamCardLink__c
                                                                                                From leankor__kanbancard__c 
                                                                                                Where Id In :kanbanCards
                                                                                                Limit 10000]);

            List<leankor__Dependency__c> dependencies = [Select Id, 
                                                                leankor__Predecessor__c, 
                                                                leankor__Successor__c,
                                                                leankor__ValueStream__c
                                                            From leankor__Dependency__c 
                                                            Where leankor__Successor__c In :mapKanbanCards.keySet() 
                                                                Or leankor__Predecessor__c In :mapKanbanCards.keySet() 
                                                            Limit 10000];

            Set<String> dependentCardIdSet = new Set<String>();
            if (dependencies.size() > 0) {
                for (leankor__Dependency__c dependency : dependencies) {
                    //Get dependent card's Id for checking their's EDA updation
                    if (!mapKanbanCards.keyset().contains(dependency.leankor__Predecessor__c)) {
                        dependentCardIdSet.add(dependency.leankor__Predecessor__c);
                    }
                    if (!mapKanbanCards.keyset().contains(dependency.leankor__Successor__c)) {
                        dependentCardIdSet.add(dependency.leankor__Successor__c);
                    }
                    //Changes added for soft deleting Dependency records.
                    dependency.leankor__Predecessor__c = null;
                    dependency.leankor__Successor__c = null;
                    dependency.leankor__ValueStream__c = null;

                }
            }

            Savepoint sp = Database.setSavepoint();
            try {
                removeLinkedCard(cardIds);
                leankor.GanttTaskBoard.DeleteScheduleMode(cardIds);
                leankor.GanttTaskBoard.DeleteResourceAssignment(cardIds);

                /*if (entitySubscriptionList.size() > 0) {
                    delete entitySubscriptionList; 
                }*/

                if (subscribers.size() > 0) {
                    update subscribers;
                }
                
                if (dependencies.size() > 0) {
                    update dependencies;
                        }
                        
                //If card has external dependency then also update dependent cards 
                if (dependentCardIdSet.size() > 0) {
                    leankor.RealTimeController.KanbanCardsData dependentCards  = RealTimeControllerHelper.updateExternallyDependentCards(dependentCardIdSet);
                    if (dependentCards.kanbanCards.size() > 0) {
                        update dependentCards.kanbanCards;
                        
                        if (IS_GENERIC_STREAMING) {
                            gskanbanCardIds.addAll(dependentCards.recordIds);
                        }

                        //If valueStreamId has value then send broadcast
                        if (String.isNotBlank(valueStreamId)) {
                            Map<String, List<String>> broadcastContentMap =  new Map<String,List<String>>();
                            List<String> jsonDataList = new List<string>(dependentCards.recordIds);

                            broadcastContentMap.put(valueStreamId, jsonDataList);
                            leankor.GenericStreamingController.tempCreateRTForMultipleBoards('UpdateMultipleKanbanCards', broadcastContentMap, USER_SESSION_ID_CONST);
                        }
                    }
                }
                //Update is successor recalculate of parent to true
                for (leankor__kanbancard__c kanbanCard : mapKanbanCards.values()) {
                    if (String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)) {
                        //Add Linked card ids to broadcast in GS
                        if (IS_GENERIC_STREAMING) {
                            gskanbanCardIds.add(kanbanCard.leankor__ValueStreamCardLink__c);
                        }
                        
                        Util.recalculateRecord.put(kanbanCard.leankor__ValueStreamCardLink__c, true);
                    }
                }
                //19/Feb/2024 : As per discussion with UI team this below method is not needed in PG. commenting this method can reduce remote call for Parent Card/Activity and it will not send broadcast for parents records if Deletion is perfomed from PG.
                if(boardType != 'UberBoard'){
                    leankor.RealTimeController.updateParentCards(mapKanbanCards.values());
                }

                returnString = JSON.serialize(gskanbanCardIds);
            } catch(Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        } else {
            returnString = 'ERROR: Unable to remove empty cards.';
        }

        return returnString;
    }


    /***
     * Helper method for the two "get drawing" remote actions below
     * INPUT: parent Id of an attachment assumed to be a PNG
     * OUTPUT: returns the base64 encoded form of the PNG image
    */
    private static String getDrawing(String parentId) {
        if (String.isBlank(parentId)) {
            return 'ERROR: Unable to find the image.';
        }

        // only select those records with "preview" in the file name (value streams have ONE)

        /*
        String likeSearch = '%' + 'drawing' + '%';
        List<Attachment> attachments = [Select Body 
                                        From Attachment 
                                        Where ParentId = :parentId 
                                            And Name Like :likeSearch 
                                        Limit 1];
        return attach.size() > 0 ? EncodingUtil.Base64Encode(attach[0].Body) : '';
        */

        String likeSearch = 'drawing';
        String body = '';

        for (Attachment attachment : [Select Body,
                                                Name
                                            From Attachment 
                                            Where ParentId = :parentId
                                            Order By LastModifiedDate Desc
                                            Limit 50000]) {
            if (attachment.Name.contains(likeSearch)) {
                body = EncodingUtil.Base64Encode(attachment.Body);
                break;
            }
        }

        return body;
    }


    /***
     * remote method to retrieve the saved drawing from the "back" of the kanban card
     *SS 11.09.2018*
     *This method is not used by UI anymore so we have used this for 1.243.2 patch only
	 *Since we were not able to manage sequence of Broadcast for PT. We have used this alternative to set activity dates according to miniatures dates
     *This code is only applied due to inability of adding new global method in Patch
     
     * INPUT: kanban card ID(parent Card Id ) 
     * OUTPUT: returns Minimum/Maximum dates of activity according to its miniatures
     * Modified : SS 08.10.2019 Logic of this method is modified again at the time of implementation of exclusion of records with null project/valuestream 
     */
	 @RemoteAction
     global static String getKanbanCardDrawing(String kanbanCardId) {
        if (String.isBlank(kanbanCardId)) {
            return 'Error: Unable to find the card.';
        }

        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

		String dateRange = '';

        try {
			//TO Do :Logic may be need to change for different duration unit
			//This total duration count is used for AutoTranslationOfACtivity according to its miniature
			Integer totalDurationCount = 0; 
	        RealTimeController.DependencyStreaming miniature = new RealTimeController.DependencyStreaming();
	        miniature.Id = kanbanCardId;
			miniature.totalDurationCount = totalDurationCount;

            for (AggregateResult ag : getMiniatureAggregateResult(kanbanCardId)) {
				if (ag.get('valueStream') != null && ag.get('projectRoom') != null){
					DateTime startDate = (DateTime)JSON.deserialize(JSON.serialize(ag.get('MinDate')), DateTime.class);
					DateTime dueDate = (DateTime)JSON.deserialize(JSON.serialize(ag.get('MaxDate')), DateTime.class);
					if (miniature.StartDate != null) {
						if (miniature.StartDate>startDate) {
							miniature.StartDate = startDate;
						}
					} else {
						miniature.StartDate = startDate;
					}
					if (miniature.DueDate != null) {
						if (miniature.DueDate < dueDate) {
							miniature.DueDate = dueDate;
						}
					} else {
						miniature.DueDate = dueDate;
					}
				}										  	
            }
            
			//If  there are no miniatures then we will pick the Start / Due date from the activity
			if (miniature.StartDate == null && miniature.DueDate == null) {
                List<leankor__KanbanCard__c> kanbanCards =  [Select leankor__StartDateTime__c,
                                                                    leankor__DueDateTime__c 
                                                                From leankor__KanbanCard__c 
                                                                Where Id = :kanbanCardId 
                                                                    And leankor__isRecordDeleted__c = false 
                                                                    And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                                Limit 1];
	        	if (kanbanCards.size() > 0) {
                    miniature.StartDate = kanbanCards[0].leankor__StartDateTime__c;                    
		            miniature.DueDate = kanbanCards[0].leankor__DueDateTime__c;
	        	}
            }
            
	        dateRange = Json.serialize(miniature);
        } catch(Exception e) {
            System.debug('Error: ' + e.getmessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

		return dateRange;
    }


    @TestVisible
    private static List<AggregateResult> getMiniatureAggregateResult(String kanbanCardId) {
        return [Select Min(leankor__StartDateTime__c) MinDate, 
                        Max(leankor__DueDateTime__c) MaxDate, 
                        leankor__valueStream__c valueStream, 
                        leankor__valueStream__r.leankor__Projectroom__c projectRoom  
                    From leankor__KanbanCard__c 
                    Where leankor__ValueStreamCardLink__c = :kanbanCardId 
                        And leankor__isRecordDeleted__c = false 
                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                        And leankor__MasterContainer__r.leankor__Type__c In :MASTERCONTAINERTYPEFILTERS_CONST
                        And ((leankor__ValueStream__r.leankor__IsTemplateBoard__c = false 
                            And leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = false)
                            Or (leankor__ValueStream__r.leankor__IsTemplateBoard__c = true 
                            And leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c = true))
                    Group By leankor__valueStream__r.leankor__Projectroom__c, leankor__valueStream__c
                    Limit 50000];
    }


    /***
     * remote method to retrieve the saved drawing from the "back" of the value stream
     * ASSUMPTION: such a drawing, if it exists, is an Attachment PNG with the string 'drawing' in the file name
     * INPUT: vs ID (parent ID of the value stream drawing attachment)
     * OUTPUT: returns "" or the base64 string of the PNG attachment drawing
    */
    @RemoteAction
    global static String getValueStreamDrawing(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return realtimeController.getDrawing(valueStreamId);
    }


    /***
     * Removes the zone from value stream by making the relationship field blank.
     * We do this rather than delete() because we may need the zone and all its data for historical reporting
     * INPUT: The GUID for the zone generated by the browser when it was first created
     * OUTPUT: String of "success" if all went well and "ERROR: <some message>" if not
     * (there is likely a more formal way to pass result codes back and error messages!)
    */
    @RemoteAction
    global static String removeZone(String zoneId) {
        if (String.isBlank(zoneId)) {
            return 'Error: Unable to find the zone to remove.';
        }

       //We are not adding input validation code here. because Here ZoneId is receiving GUID ID.

        //Check CRUD / FLC behavior		
        KanbanCardBehaviour kanbanCardBehaviour =  new KanbanCardBehaviour();
        ZoneBehavior zoneBehavior = new ZoneBehavior();

        if (!kanbanCardBehaviour.isAccessible()	
        || !kanbanCardBehaviour.isUpdateable() 
        || !kanbanCardBehaviour.isCreateable() 
        || !zoneBehavior.isAccessible() 
        || !zoneBehavior.isUpdateable() 
        || !zoneBehavior.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior


        String returnString = 'success';

        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                            Name, 
                                                            leankor__GUID__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ZoneGUID__c = :zoneId 
                                                        Limit 10000];

        if (kanbanCards.size() > 0) {
            for (leankor__KanbanCard__c kanbanCard: kanbanCards) {
                kanbanCard.leankor__ZoneGUID__c = '';
            }
    
            leankor__Zone__c zone = new leankor__Zone__c(
                leankor__GUID__c = zoneId, 
                leankor__ValueStream__c = null, 
                leankor__Swimlane__c = null
            );

            Savepoint sp = Database.setSavepoint();
            try {
                upsert kanbanCards leankor__GUID__c; // GUID is the external unique key to match
                upsert zone leankor__GUID__c; // GUID is the external unique key to match
            } catch (DmlException e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());            
            }
        } else {
            leankor__Zone__c zone = new leankor__Zone__c(
                leankor__GUID__c = zoneId, 
                leankor__ValueStream__c = null, 
                leankor__Swimlane__c = null
            );
            Savepoint sp = Database.setSavepoint();
            try {
                upsert zone leankor__GUID__c; // GUID is the external unique key to match
            } catch (DmlException e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());            
            }
        }

        return returnString;
    }


    /***
     * INPUT: kanban unique id, zone unique id, value stream unique id (force.com ID's) and sessionId of browswer that instigated the event
     * OUTPUT:  inserts a row into leankor__ZoneKanbanAction__c and lets the workflow engine do the rest
    */
    @RemoteAction
    global static String enterTheZone(ZoneKanbanAction zoneKanbanAction) {        
        if ((String.isNotBlank(zoneKanbanAction.KanbanID) && Util.getSObjectName(zoneKanbanAction.KanbanID) != 'leankor__KanbanCard__c')|| (String.isNotBlank(zoneKanbanAction.ZoneID) && Util.getSObjectName(zoneKanbanAction.ZoneID) != 'leankor__Zone__c')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        
        //Check CRUD / FLC behavior		
        ZoneKanbanActionBehavior zoneKanbanActionBehavior = new ZoneKanbanActionBehavior();
        ZoneBehavior zoneBehavior = new ZoneBehavior();

        if (!zoneKanbanActionBehavior.isAccessible() 
        || !zoneKanbanActionBehavior.isCreateable() 
        || !zoneBehavior.isAccessible() 
        || !zoneBehavior.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        // if action = 'HyperJumpToZone' called by FlowZone.invoke(), then this is a special case;
        // we need to broadcast a "new kanban card event" to all value stream maps which are open
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

        if (zoneKanbanAction.Action == 'HyperJumpToZone') {
            kanbanCards = [Select Id,
                                    Name,
                                    leankor__GUID__c,
                                    leankor__Title__c,
                                    leankor__Top__c,
                                    leankor__Bottom__c,
                                    leankor__Left__c,
                                    leankor__width__c,
                                    leankor__Height__c,
                                    leankor__X__c,
                                    leankor__Y__c,
                                    leankor__JSONData__c,
                                    leankor__State__c,
                                    leankor__ZoneGUID__c,
                                    leankor__MasterContainer__c,
                                    leankor__Swimlane__c,
                                    leankor__Zone__c,
                                    leankor__CmpID__c,
                                    leankor__Color__c,
                                    leankor__DueDateTime__c,
                                    leankor__Priority__c
                                From leankor__KanbanCard__c 
                                Where Id = :zoneKanbanAction.KanbanID 
                                Limit 1];

            if (kanbanCards.isEmpty()) {
                return 'ERROR: Could not find kanban card to broadcast HyperJump.';
            }
        }

        Double decimalHours = 0;
        Decimal diffMinutes = 0;
        Decimal totalTime = 0;
        Integer kanbanCount = 1;

        //Calculate Wait time if zoneKanbanAction.action == 'Left Zone'
        if (zoneKanbanAction.Action == 'Left Zone') {
            List<leankor__ZoneKanbanAction__c> enterZoneRecords = [Select CreatedDate, 
                                                                            Id, 
                                                                            leankor__ActionType2__c, 
                                                                            leankor__KanbanCard2__c, 
                                                                            leankor__ValueStream__c, 
                                                                            leankor__Zone2__c, 
                                                                            Name, 
                                                                            leankor__WaitTime2__c 
                                                                        From leankor__ZoneKanbanAction__c 
                                                                        Where leankor__KanbanCard2__c = :zoneKanbanAction.KanbanID 
                                                                            And leankor__Zone2__c = :zoneKanbanAction.ZoneID 
                                                                            And leankor__ActionType2__c = 'Entered Zone' 
                                                                        Order By CreatedDate Desc 
                                                                        Limit 1];
            if (enterZoneRecords.size() > 0) {
                leankor__ZoneKanbanAction__c enterZone = enterZoneRecords[0];
                DateTime leftZoneTime = System.Now();
                kanbanCount = -1;
                if (leftZoneTime.isSameDay(enterZone.CreatedDate)) {
                    // Checking Kanban Card enter and left the zone is same or not.
                    decimalHours = (((leftZoneTime.getTime()) / 1000 / 60) - ((enterZone.CreatedDate.getTime()) / 1000 / 60)) / 60;
                    diffMinutes = (((leftZoneTime.getTime()) / 1000 / 60) - ((enterZone.CreatedDate.getTime()) / 1000 / 60)) - (decimalHours * 60);
                    totalTime = decimalHours + (diffMinutes / 100);
                } else {
                    Integer diffInDays = enterZone.CreatedDate.date().daysBetween(leftZoneTime.date());
                    datetime sameDayEndDate = enterZone.CreatedDate.addDays(diffInDays);
                    decimalHours = (((leftZoneTime.getTime()) / 1000 / 60) - ((sameDayEndDate.getTime()) / 1000 / 60)) / 60;
                    diffMinutes = (((leftZoneTime.getTime()) / 1000 / 60) - ((sameDayEndDate.getTime()) / 1000 / 60)) - (decimalHours * 60);
                    decimalHours = (diffInDays * 8) + decimalHours;
                    totalTime = decimalHours + (diffMinutes / 100);
                }
            }
        }
        
        List<leankor__Zone__c> currentZones = [Select Id, 
                                                        leankor__Bottom__c, 
                                                        leankor__CaseStatus__c, 
                                                        leankor__CmpID__c, 
                                                        leankor__CompletionRateUnits__c, 
                                                        leankor__CompletionRate__c, 
                                                        leankor__CSSLayout__c, 
                                                        leankor__DefaultHeight__c, 
                                                        leankor__Defaultwidth__c, 
                                                        leankor__EntryFlowName__c, 
                                                        leankor__ExitFlowName__c, 
                                                        leankor__GUID__c, 
                                                        leankor__Height__c, 
                                                        leankor__JSONDefinition__c, 
                                                        leankor__KanbanCardCount2__c, 
                                                        leankor__KanbanCardThroughput__c, 
                                                        leankor__kanbanSequence__c, 
                                                        leankor__LeadTime__c, 
                                                        leankor__Left__c, 
                                                        leankor__Title__c, 
                                                        leankor__Top__c, 
                                                        leankor__ValueStreamCardLink__c, 
                                                        leankor__ValueStreamLink__c, 
                                                        leankor__ValueStream__c, 
                                                        leankor__width__c, 
                                                        leankor__X__c, 
                                                        leankor__Y__c, 
                                                        leankor__zoneMode__c, 
                                                        leankor__ZoneTemplate__c, 
                                                        Name, 
                                                        OwnerId 
                                                    From leankor__Zone__c 
                                                    Where Id = :zoneKanbanAction.ZoneID 
                                                    Limit 1];

        String returnVal = 'success';

        if (currentZones.size() > 0) {                               
            currentZones[0].leankor__KanbanCardCount2__c += kanbanCount;

            leankor__ZoneKanbanAction__c newZoneKanbanAction = new leankor__ZoneKanbanAction__c(
                leankor__KanbanCard2__c = zoneKanbanAction.KanbanID,
                leankor__SessionID__c = zoneKanbanAction.SessionID,
                leankor__Zone2__c = zoneKanbanAction.ZoneID,
                leankor__OtherZone__c = zoneKanbanAction.OtherZoneID == '' ? null : zoneKanbanAction.OtherZoneID,
                leankor__OtherSwimlane__c = zoneKanbanAction.OtherSwimlaneID == '' ? null : zoneKanbanAction.OtherSwimlaneID,
                leankor__OtherMasterContainer__c = zoneKanbanAction.OtherMasterContainerID == '' ? null : zoneKanbanAction.OtherMasterContainerID,
                leankor__ValueStream__c = zoneKanbanAction.VSID,
                leankor__ActionType2__c = zoneKanbanAction.Action,
                leankor__Swimlane__c = zoneKanbanAction.SwimlaneID == '' ? null : zoneKanbanAction.SwimlaneID,
                leankor__MasterContainer__c = zoneKanbanAction.MasterContainerID == '' ? null : zoneKanbanAction.MasterContainerID,
                leankor__WaitTime2__c = totalTime
            );

            Savepoint sp = Database.setSavepoint();
            try {
                insert newZoneKanbanAction;
                update currentZones;

                // if action = 'HyperJumpToZone' called by FlowZone.invoke(), then this is a special case;
                // we need to broadcast a "new kanban card event" to all value stream maps which are open
                if (zoneKanbanAction.Action == 'HyperJumpToZone' && kanbanCards.size() > 0) {
                    StateChangePackage stateChangePackage = new StateChangePackage();

                    stateChangePackage.GUID = kanbanCards[0].leankor__GUID__c;
                    stateChangePackage.Title = kanbanCards[0].Name;
                    stateChangePackage.width = kanbanCards[0].leankor__width__c;
                    stateChangePackage.Height = kanbanCards[0].leankor__Height__c;
                    stateChangePackage.Top = kanbanCards[0].leankor__Top__c;
                    stateChangePackage.Bottom = kanbanCards[0].leankor__Bottom__c;
                    stateChangePackage.Left = kanbanCards[0].leankor__Left__c;
                    stateChangePackage.X = kanbanCards[0].leankor__X__c;
                    stateChangePackage.Y = kanbanCards[0].leankor__Y__c;
                    stateChangePackage.CmpID = kanbanCards[0].leankor__CmpID__c;
                    stateChangePackage.ZoneID = kanbanCards[0].leankor__ZoneGUID__c;
                    stateChangePackage.MCForceID = kanbanCards[0].leankor__MasterContainer__c;
                    stateChangePackage.SWForceID = kanbanCards[0].leankor__Swimlane__c;
                    stateChangePackage.ZoneForceID = kanbanCards[0].leankor__Zone__c;
                    stateChangePackage.State = kanbanCards[0].leankor__State__c;
                    stateChangePackage.Color = kanbanCards[0].leankor__Color__c;
                    stateChangePackage.DueDate = kanbanCards[0].leankor__DueDateTime__c;
                    stateChangePackage.Priority = kanbanCards[0].leankor__Priority__c;

                    // fire the state change event to broadcast the hyper-jump to everyone
                    realtimeController.kanbanStateChange(zoneKanbanAction.VSID, 'CreateKanbanCard', zoneKanbanAction.SessionID, JSON.serialize(stateChangePackage));
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());            
            }
        } else {
            returnVal = 'Error: Could not find current zone.';
        }

        return returnVal;
    }



    /***
     * Given a value stream ID, returns the top 50 comments and such
     * INPUT: Value Stream ID
     * OUTPUT: array of leankor__ValueStream__Feed objects
    */
    @RemoteAction
    global static List<leankor__ValueStream__Feed> getValueStreamFeed(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select Id, 
                        Type, 
                        CreatedById, 
                        CreatedBy.FirstName, 
                        CreatedBy.LastName, 
                        ParentID, 
                        Parent.Name, 
                        Body, 
                        Title, 
                        LinkUrl, 
                        (Select Id, 
                                FieldName, 
                                OldValue, 
                                NewValue 
                            From FeedTrackedChanges 
                            Order By Id Desc), 
                        (Select Id, 
                                CommentBody, 
                                CreatedDate, 
                                CreatedBy.FirstName, 
                                CreatedBy.LastName 
                            From FeedComments 
                            Order By CreatedDate 
                            Limit 50), 
                        (Select CreatedBy.FirstName, 
                                CreatedBy.LastName 
                            From FeedLikes)
                    From leankor__ValueStream__Feed 
                    Where ParentID = :valueStreamId 
                    Order By CreatedDate Desc,
                        Id Desc 
                    Limit 50];
    }


    /***
     * Given a kanban card ID, returns the top 50 comments and such
     * INPUT: Kanban Card ID
     * OUTPUT: array of leankor__KanbanCard__Feed objects
    */
    @RemoteAction
    global static List<leankor__KanbanCard__Feed> getKanbanCardFeed(Id kanbanCardId) {
        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select Id, 
                        Type, 
                        CreatedById, 
                        CreatedBy.FirstName, 
                        CreatedBy.LastName,
                        ParentID, 
                        Parent.Name, 
                        Body, 
                        Title, 
                        LinkUrl,
                        (Select Id, 
                                FieldName, 
                                OldValue, 
                                NewValue
                            From FeedTrackedChanges 
                            Order By Id Desc),
                        (Select Id, 
                                CommentBody, 
                                CreatedDate,
                                CreatedBy.FirstName, 
                                CreatedBy.LastName
                            From FeedComments 
                            Order By CreatedDate 
                            Limit 50),
                        (Select CreatedBy.FirstName, 
                                CreatedBy.LastName
                            From FeedLikes)
                    From leankor__KanbanCard__Feed
                    Where ParentID = :kanbanCardId
                    Order By CreatedDate Desc, 
                        Id Desc
                    Limit 50];
    }


    //Inner class for Kanban Chatter Stats.
    global class KanbanChatterStats {
        Id KanbanID;
        Integer Comments;
        global Integer TaskChatterCount;
        Integer Changes;
        Boolean Success;
    }


    /***
     * Given a kanban card ID list, returns key stats
     * INPUT: List of Kanban Card ID
     * OUTPUT: object with stats
     * USAGE : It will use in Chatter count.
    */
    //@ReadOnly
    @RemoteAction
    global static List<KanbanChatterStats> getKanbanCardChatterStats(List<Id> kanbanArray) {
		for (Id kanbanId : kanbanArray) {
            if (String.isNotBlank(kanbanId) && Util.getSObjectName(kanbanId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        List<KanbanChatterStats> kanbanChatterStats = new List<KanbanChatterStats>();
        List<leankor__kanbanCard__c> kanbanCards = [Select Id, 
                                                            leankor__Case__c, 
                                                            leankor__Opportunity__c, 
                                                            leankor__Valuestream__r.leankor__ViewChatterOptions__c 
                                                        From leankor__kanbancard__c 
                                                        Where Id In :kanbanArray
                                                        Limit 50000];

        Map<Id, KanbanChatterStats> kanbanCardChatterStats = new Map<Id, KanbanChatterStats>();
        Map<Id, Set<Id>> kanbanCardCaseIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> kanbanCardOpportunityIds = new Map<Id, Set<Id>>();
        Set<Id> kanbanCardIds = new Set<Id>();

        for (leankor__kanbancard__c kanbanCard : kanbanCards) {
            if (kanbanCard.leankor__Valuestream__r.leankor__Viewchatteroptions__c == 'Cases Chatter' && kanbanCard.leankor__Case__c != null) {
                Set<Id> kanbanIds = kanbanCardCaseIds.get(kanbanCard.leankor__Case__c);
                kanbanIds.add(kanbanCard.Id);
                kanbanCardCaseIds.put(kanbanCard.leankor__Case__c, kanbanIds);
            } else if (kanbanCard.leankor__Valuestream__r.leankor__Viewchatteroptions__c == 'Opportunities Chatter' && kanbanCard.leankor__Opportunity__c != null) {
                Set<Id> kanbanIds = kanbanCardOpportunityIds.get(kanbanCard.leankor__Opportunity__c);
                kanbanIds.add(kanbanCard.Id);
                kanbanCardOpportunityIds.put(kanbanCard.leankor__Opportunity__c, kanbanIds);
            } else {
                kanbanCardIds.add(kanbanCard.Id);
            }
        }
		// 01/15/2021 Changes : TO fix Adding task on new cv causing exception issue 
        if (kanbanCardCaseIds.size() > 0) {
            AggregateResult[] agCaseFeeds = [Select Count(Id) FeedCount,
                                                    Type,
                                                    ParentId
                                                From CaseFeed
                                                Where ParentId In :kanbanCardCaseIds.keySet()
                                                Group By Type,
                                                    ParentId
                                                Limit 50000];
            if (agCaseFeeds.size() > 0) {
                for (AggregateResult agCaseFeed : agCaseFeeds) {
                    Id parentId = (Id)agCaseFeed.get('ParentId');
                    Set<Id> kanbanIds = kanbanCardCaseIds.get(parentId);
                    setKanbanCardChatter(kanbanCardChatterStats, (Integer)agCaseFeed.get('FeedCount'), (String)agCaseFeed.get('Type'), parentId, kanbanIds);
                }
            } else {
                setKanbanCardChatterForNoFeedItem(kanbanCardChatterStats, kanbanCardIds);
            }
        }

        if (kanbanCardOpportunityIds.size() > 0) {
            AggregateResult[] agOpportunityFeeds = [Select Count(Id) FeedCount,
                                                            Type,
                                                            ParentId
                                                        From OpportunityFeed
                                                        Where ParentId In :kanbanCardOpportunityIds.keySet()
                                                        Group By Type,
                                                            ParentId
                                                        Limit 50000];

            if (agOpportunityFeeds.size() > 0) {
                for (AggregateResult agOpportunityFeed : agOpportunityFeeds) {
                    Id parentId = (Id)agOpportunityFeed.get('ParentId');
                    Set<Id> kanbanIds = kanbanCardOpportunityIds.get(parentId);
                    setKanbanCardChatter(kanbanCardChatterStats, (Integer)agOpportunityFeed.get('FeedCount'), (String)agOpportunityFeed.get('Type'), parentId, kanbanIds);
                }
            } else {
               setKanbanCardChatterForNoFeedItem(kanbanCardChatterStats, kanbanCardIds);
            }
        }

        if (kanbanCardIds.size() > 0) {            
            AggregateResult[] agKanbanCardFeeds = [Select Count(Id) FeedCount,
                                                            Type,
                                                            ParentId
                                                        From leankor__KanbanCard__Feed
                                                        Where ParentId In :kanbanCardIds
                                                        Group By Type,
                                                            ParentId
                                                        Limit 50000];
            
            if (agKanbanCardFeeds.size() > 0) {
                for (AggregateResult agKanbanCardFeed : agKanbanCardFeeds) {
                    Id parentId = (Id)agKanbanCardFeed.get('ParentId');
                    setKanbanCardChatter(kanbanCardChatterStats, (Integer)agKanbanCardFeed.get('FeedCount'), (String)agKanbanCardFeed.get('Type'), parentId, kanbanCardIds);
                }
            } else {
                setKanbanCardChatterForNoFeedItem(kanbanCardChatterStats, kanbanCardIds);    
            }
        }

        for (Id key : kanbanCardChatterStats.keySet()) {
            kanbanChatterStats.add(kanbanCardChatterStats.get(key));
        }

        return kanbanChatterStats;
    }


    // helper method to getKanbanCardChatterStats
    // to set the KanbanChatterStats passing kanbanCardChatterStats as a reference
    private static void setKanbanCardChatter(Map<Id, KanbanChatterStats> kanbanCardChatterStats, Integer feedCount, String feedType, Id parentId, Set<Id> kanbanCardIds) {
        for (Id kanbanCardId : kanbanCardIds) {
            KanbanChatterStats kanbanChatterStat = new KanbanChatterStats();
                if (feedType != 'TrackedChange') {
                    kanbanChatterStat.Comments = feedCount;
                    kanbanChatterStat.Changes = 0;
                } else {
                    kanbanChatterStat.Changes = feedCount;
                    kanbanChatterStat.Comments = 0;
                }
                kanbanChatterStat.Success = true;
                kanbanChatterStat.KanbanID = kanbanCardId;                    
                kanbanCardChatterStats.put(parentId, kanbanChatterStat);

        }
    }


    /***
     *  Helper method of getKanbanCardChatterStats
     *  Input  : Kanaban cardId List
    */
    private static void setKanbanCardChatterForNoFeedItem(Map<Id, KanbanChatterStats> kanbanCardChatterStats, set<Id> kanbanCardIds){
        for (Id kanbanId : kanbanCardIds) {
            KanbanChatterStats kanbanChatterStat = new KanbanChatterStats();
            kanbanChatterStat.Changes = 0;
            kanbanChatterStat.Comments = 0;
            kanbanChatterStat.KanbanID = kanbanId;                    
            kanbanCardChatterStats.put(kanbanId, kanbanChatterStat);
        }
    }


    /***
     * Given a zone ID, returns the top 50 comments and such
     * INPUT: Zone ID
     * OUTPUT: array of leankor__Zone__Feed objects
    */
    @RemoteAction
    global static List<leankor__Zone__Feed> getZoneFeed(String zoneId) {
        if (String.isNotBlank(zoneId) && Util.getSObjectName(zoneId) != 'leankor__Zone__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select Id, 
                        Type, 
                        CreatedById, 
                        CreatedBy.FirstName, 
                        CreatedBy.LastName,
                        ParentID, 
                        Parent.Name, 
                        Body, 
                        Title, 
                        LinkUrl,
                        (Select Id, 
                                FieldName, 
                                OldValue, 
                                NewValue
                            From FeedTrackedChanges 
                            Order By Id Desc),
                        (Select Id, 
                                CommentBody, 
                                CreatedDate,
                                CreatedBy.FirstName, 
                                CreatedBy.LastName
                            From FeedComments 
                            Order By CreatedDate 
                            Limit 50),
                        (Select CreatedBy.FirstName, 
                                CreatedBy.LastName
                            From FeedLikes)
                    From leankor__Zone__Feed
                    Where ParentId = :zoneId
                    Order By CreatedDate Desc, 
                        Id Desc
                    Limit 50];
    }
    
    
    /***
     * INPUT  : Takes string verb 'imported' or 'other'
     * OUTPUT : Returns Inner class Object BackgroundLibrary
     * USAGE  : It will return background images from different sources.
    */
    @RemoteAction
    global static BackgroundLibrary getBackgroundImages(String Verb) {        
        BackgroundLibrary bgLib = new BackgroundLibrary();

        if (verb == 'imported') {            
            // rbo 08.19.17 get all Ids of stickers which will be used to filter attachment object
            List <leankor__Background__c> stickerIds = [Select Id 
                                                            From leankor__Background__c 
                                                            Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST
                                                            Limit 50000];
                    
            // rbo 08.19.17 use stickerIds to filter attachment object, this should improve the performance of the query                
            bgLib.Imported = [Select Id, 
                                        Name, 
                                        (Select Id, 
                                                ContentType 
                                            From Attachments 
                                            Where ParentId In :stickerIds) 
                                    From leankor__Background__c 
                                    Where Id In :stickerIds];
        } else {
            //images from cloud files.
            //Date: 11/06/2019 - To return the record of last 3 month.
            Datetime threeMonthOldDate = System.now().addDays(-90);

            bgLib.Other = [Select ArchivedById, 
                                    ArchivedDate, 
                                    ContentSize, 
                                    Description, 
                                    FileExtension, 
                                    FileType, 
                                    Id, 
                                    IsArchived, 
                                    IsDeleted, 
                                    LatestPublishedVersionId, 
                                    OwnerId, 
                                    ParentId, 
                                    PublishStatus, 
                                    SystemModstamp, 
                                    Title 
                                From ContentDocument 
                                Where FileExtension In ('jpg', 'gif', 'png', 'jpeg') 
                                    And LastModifiedDate >= :threeMonthOldDate 
                                Order By LastModifiedDate Desc 
                                Limit 50000];
        } //End of else

        return bgLib;
    }


    //Inner model class for background images.
    global class BackgroundLibrary {
        global List<ContentDocument> Other;
        global List<leankor__Background__c> Imported;
    }


    /***
     * INPUT  : Integer offsetSize, String filterValue, Integer limits
     * OUTPUT : Returns Inner class RecordDetails object
     * USAGE  : It will use for paging feature in LeankorJS app for users.
    */
    @RemoteAction
    global static RecordDetails getUserData(Integer offsetSize, String filterValue, Integer limits) {
        String filterVal = '%' + filterValue + '%'; // It can be '' or any string.
        
        // TODO: make the following queries selective
        // getting count to manage paging or maximum number of user available on the basis filterValue.
        Integer count = [Select Count()
                            From User 
                            Where Name Like :filterVal];

        List<User> users = [Select Id, 
                                    Name, 
                                    Email, 
                                    FirstName, 
                                    LastName, 
                                    SmallPhotoUrl, 
                                    Username, 
                                    UserType 
                                From User 
                                Where Name Like :filterVal 
                                    And IsActive = true 
                                    And UserType != 'CsnOnly' 
                                Order By LastName Asc 
                                Limit :limits 
                                Offset :offsetSize];

        RecordDetails records = new RecordDetails();

        records.Count = count;
        records.OffsetSize = offsetSize;
        records.Users = users;

        return records;
    }
    @AuraEnabled
    public static RecordDetail retrieveUserData(Integer offsetSize, String filterValue, Integer limits){
        RecordDetail recordDetail = new RecordDetail();

        RecordDetails result = getUserData( offsetSize,filterValue, limits);
        recordDetail.Count = result.Count;
        recordDetail.OffsetSize = result.OffsetSize;
        recordDetail.Users = result.Users;
        return recordDetail;
    }
    

    @RemoteAction
    global static RecordDetails getallactiveUserData(Integer offsetSize, String filterValue, Integer limits) {
        String filterVal = '%' + filterValue + '%'; // It can be '' or any string.
        
        // TODO: make the following queries selective
        // getting count to manage paging or maximum number of user available on the basis filterValue.
        Integer count = [Select Count()
                            From User 
                            Where Name Like :filterVal
                                And IsActive = true];

        List<User> users = [Select Id, 
                                    Name, 
                                    Email, 
                                    FirstName, 
                                    LastName, 
                                    SmallPhotoUrl, 
                                    Username, 
                                    UserType 
                                From User 
                                Where Name Like :filterVal 
                                    And IsActive = true 
                                Order By LastName Asc 
                                Limit :limits 
                                Offset :offsetSize];

        RecordDetails records = new RecordDetails();

        records.Count = count;
        records.OffsetSize = offsetSize;
        records.Users = users;

        return records;
    }
    
    
    //Inner model class used for Backgorund image.
    global class BackgroundData {
        global String Base64ImageFile; // base64 image
        global String ContentType; // image type like image/png
        global String Name; // name of image in background__C object
        global String Id;
    }


    /***
     * INPUT  : String valueStreamId,String Attachment ID,Integer Height,Integer width,String Verb
     * OUTPUT : returns success / failer
     * USAGE  : method will insert / update VS background image
    */
    @RemoteAction
    global static String valueStreamBackground(String valueStreamId, String attachmentId, Integer height, Integer width, String verb) {
       if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c'){
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        if(String.isNotBlank(attachmentId) && (Util.getSObjectName(attachmentId) != 'ContentDocument' && Util.getSObjectName(attachmentId) != 'attachment')){
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();

        if (!valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isUpdateable()
        || (String.isNotBlank(attachmentId)
        && (!attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isUpdateable() 
        || !attachmentBehaviour.isCreateable()))) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior	

        String returnString = 'success';

        List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                            leankor__BackgroundHeight__c, 
                                                            leankor__BackgroundWidth__c 
                                                        From leankor__ValueStream__c 
                                                        Where Id = :valueStreamId 
                                                        Limit 1];

        if (valueStreams.size() > 0) {
            //Blank attachment Id for update Height & width of ValueStream background.
            valueStreams[0].leankor__BackgroundHeight__c = height;
            valueStreams[0].leankor__BackgroundWidth__c = width;

            Savepoint sp = Database.setSavepoint();
            try {
                update valueStreams;

                if (String.isNotBlank(attachmentId)) {
                    //TODO: make the following query selective
                    //if not blank than can find record in Attachment object using Parent Id valueStreamId.
                    List<Attachment> attachments = [Select Name, 
                                                            Body, 
                                                            ContentType 
                                                        From Attachment 
                                                        Where ParentID = :valueStreamId 
                                                            And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                            And Description Like '%background%' 
                                                        Limit 1]; //Background attachment description always have Background text.

                    //Checking verb String is 'other' or not.
                    if (verb == 'other') {
                        //if other than attachmentId is ContentDocumentId.
                        //record will be in ContentVersion object.
                        List<ContentVersion> contentVersions = [Select ContentDocumentId, 
                                                                        ContentLocation, 
                                                                        Description, 
                                                                        FileExtension, 
                                                                        FileType, 
                                                                        FirstPublishLocationId, 
                                                                        PathOnClient, 
                                                                        Title, 
                                                                        VersionData 
                                                                    From ContentVersion 
                                                                    Where ContentDocumentId = :attachmentId 
                                                                        And isLatest = true 
                                                                    Limit 1];

                        if (contentVersions.size() > 0) {                                 
                            //Attachment list size is not zero than we have background attachment already for given ValueStream record.
                            //Need to update that attachment using values of contentVersion.
                            if (attachments.size() > 0) {
                                attachments[0].Name = (contentVersions[0].Title + contentVersions[0].FileExtension);
                                attachments[0].ContentType = 'image/' + contentVersions[0].FileExtension;
                                attachments[0].Body = contentVersions[0].VersionData;
                                attachments[0].Description = 'background';

                                update attachments;
                            } else {
                                //otherwise need to insert background attachment record very first time / after delete background.
                                Attachment newAttachment = new Attachment(
                                        Name = (contentVersions[0].Title + contentVersions[0].FileExtension),
                                        ContentType = 'image/' + contentVersions[0].FileExtension,
                                        ParentID = valueStreamId,
                                        Body = contentVersions[0].VersionData,
                                        Description = 'background');

                                insert newAttachment;
                            }
                        }
                    } else {
                        //if verb is not 'other' than we have Attachment Id not  ContentDocument Id.
                        List<Attachment> attachmentContents = [Select Id, 
                                                                        Name, 
                                                                        ParentID, 
                                                                        Body, 
                                                                        ContentType 
                                                                    From Attachment 
                                                                    Where Id = :attachmentId 
                                                                        And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                                    Limit 1];

                        if (attachmentContents.size() > 0 && attachmentContents[0].ContentType != '') {
                            String fileName = (attachmentContents[0].Name).substringBefore('.');
                            String suffix = '';
                            if (attachmentContents[0].ContentType == 'image/jpeg' || attachmentContents[0].ContentType == 'image/jpg') {
                                suffix = '.jpg';
                            } else if (attachmentContents[0].ContentType == 'image/gif') {
                                suffix = '.gif';
                            } else {
                                suffix = '.png';
                            }

                            if (attachments.size() > 0) {
                                attachments[0].Name = (fileName + suffix);
                                attachments[0].ContentType = attachmentContents[0].ContentType;
                                attachments[0].Body = attachmentContents[0].Body;
                                attachments[0].Description = 'background';

                                update attachments;
                            } else {
                                Attachment newAttachment = new Attachment(
                                        Name = fileName + suffix,
                                        ContentType = attachmentContents[0].ContentType,
                                        ParentID = valueStreamId,
                                        Body = attachmentContents[0].Body,
                                        Description = 'background');

                                insert newAttachment;
                            }
                        }
                    }
                }
            } catch(Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        } else {
            returnString = 'ERROR: Unable to find the record.';
        }

        return returnString;
    }


    /***
     * INPUT : String Background Id.
     * OUTPUT : success / ''.
     * USAGE : Removes background image record.
    */
    @RemoteAction
    global static String removeBGImg(String backgroundId) {
        if (String.isNotBlank(backgroundId) && Util.getSObjectName(backgroundId) != 'leankor__Background__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        BackgroundBehaviour backgroundBehaviour = new BackgroundBehaviour();

        if (!backgroundBehaviour.isAccessible() 
        || !backgroundBehaviour.isDeletable()) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String returnVal = 'Error: Unable to find the record';

        List<leankor__Background__c> backgrounds = [Select Id, 
                                                            Name 
                                                        From leankor__Background__c 
                                                        Where Id = :backgroundId 
                                                        Limit 1];

        if (backgrounds.size() > 0) {
            try {   
                delete backgrounds;
                returnVal = 'Success';
            } catch (DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());            
            }
        }

        return returnVal;
    }


    /***
     * INPUT : String valueStreamId, BackgroundData remoteBackground
     * OUTPUT : success / ''.
     * USAGE : Create Background record and its attachment for background image.
    */
    @RemoteAction
    global static String insertBackground(String valueStreamId, BackgroundData remoteBackground) {
        if (String.isBlank(remoteBackground.Name)) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        BackgroundBehaviour backgroundBehaviour = new BackgroundBehaviour();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();

        if (!backgroundBehaviour.isAccessible() 
        || !backgroundBehaviour.isCreateable() 
        || !attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String returnVal = '';

        leankor__Background__c newBackgroundLib = new leankor__Background__c(
            Name = (remoteBackground.Name).substringBefore('.')
        );
        
        Savepoint sp = Database.setSavepoint();
        try {
            insert newBackgroundLib;

            // if there is a file to be saved, make the attachment
            if (remoteBackground.Base64ImageFile != '' && remoteBackground.ContentType != '') {
                String fileName = '' + (remoteBackground.Name).substringBefore('.');
                String suffix = '';

                if (remoteBackground.ContentType == 'image/jpeg' || remoteBackground.ContentType == 'image/jpg') {
                    suffix = '.jpg';
                } else if (remoteBackground.ContentType == 'image/gif') {
                    suffix = '.gif';
                } else {
                    suffix = '.png';
                }

                Attachment attachment = new Attachment(
                    Name = fileName + suffix,
                    ContentType = remoteBackground.ContentType,
                    ParentID = newBackgroundLib.Id,
                    Body = EncodingUtil.Base64Decode(remoteBackground.Base64ImageFile)
                );

                insert attachment;
            }

            returnVal = newBackgroundLib.Id;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
    
        return returnVal;
    }


    // Inner model class AlertRecords that will prepare data for alerts using bell icon on LeankorJS app.
    global class AlertRecords {
        String Id;
        String UserName;
        DateTime CreateDate;
        DateTime SystemModStamp;
        String KanbanVerb;
        String ActionType;
        String KanbanTitle;
        String ZoneName;
        String ZoneState;
        String fieldListupdated;
        String kanbanBoardTitle;
        //constructor
        global AlertRecords(String Id, String UserName, DateTime CreateDate, DateTime SystemModStamp, String KanbanVerb, String ActionType, String KanbanTitle, String ZoneName, String ZoneState) {
            this.Id = Id;
            this.UserName = UserName;
            this.CreateDate = CreateDate;
            this.SystemModStamp = SystemModStamp;
            this.KanbanVerb = KanbanVerb;
            this.ActionType = ActionType;
            this.KanbanTitle = KanbanTitle;
            this.ZoneName = ZoneName;
            this.ZoneState = ZoneState;
        } //End of contructor
        // one more parameterized constructor added for RealTime Tracker History
        global AlertRecords(String Id, String UserName, DateTime CreateDate, DateTime SystemModStamp, String KanbanVerb, String ActionType, String KanbanTitle, String ZoneName, String ZoneState, String fieldListupdated) {
            this.Id = Id;
            this.UserName = UserName;
            this.CreateDate = CreateDate;
            this.SystemModStamp = SystemModStamp;
            this.KanbanVerb = KanbanVerb;
            this.ActionType = ActionType;
            this.KanbanTitle = KanbanTitle;
            this.ZoneName = ZoneName;
            this.ZoneState = ZoneState;
            this.fieldListupdated = fieldListupdated;
        }

        // one more parameterized constructor added for RealTime Tracker History
        global AlertRecords(String Id, String UserName, DateTime CreateDate, DateTime SystemModStamp, String KanbanVerb, String ActionType, String KanbanTitle, String ZoneName, String ZoneState, String fieldListupdated, String kanbanBoardTitle) {
            this.Id = Id;
            this.UserName = UserName;
            this.CreateDate = CreateDate;
            this.SystemModStamp = SystemModStamp;
            this.KanbanVerb = KanbanVerb;
            this.ActionType = ActionType;
            this.KanbanTitle = KanbanTitle;
            this.ZoneName = ZoneName;
            this.ZoneState = ZoneState;
            this.fieldListupdated = fieldListupdated;
            this.kanbanBoardTitle = kanbanBoardTitle;
        } //End of contructor

    } //End of class
    //Comparable class that will ordered alerts.


    global class AlertWrapper implements Comparable {
        global AlertRecords ars;
        global AlertWrapper(AlertRecords Alrt) {
            ars = Alrt;
        }
        global Integer compareTo(Object CompareTo) {
            AlertWrapper CompareToArs = (AlertWrapper)CompareTo;
            Integer ReturnValue = 0;
            if (ars.SystemModstamp > CompareToArs.ars.SystemModstamp) {
                ReturnValue = 1;
            } else if (ars.SystemModstamp < CompareToArs.ars.SystemModstamp) {
                ReturnValue = -1;
            }
            return ReturnValue;
        }
    }


	/***
     * INPUT : String valueStreamId.
     * OUTPUT : returns AlertWrapper list
     * USAGE : method will return prepared alert message using realtimetracker sobject record last 50.
	   Modified : 16/01/2020 (refactoring and removed unnnecessory queries)
    */
    @RemoteAction
	global static List<AlertWrapper> getAlerts(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        AlertWrapper[] alertList = new List<AlertWrapper>();

        List<String> alertVerbs = new List<String>{
            'OpenValueStream',
            'CreateKanbanCard',
            'DeleteKanbanCard',
            'UpdateKanbanCard',
            'SetBaseline',
            'MoveKanbanCard',
            'CreateZone',
            'MoveZone',
            'DeleteZone',
            'CreateMarker',
            'MoveMarker',
            'DeleteMarker',
            'CreateChart',
            'MoveChart',
            'DeleteChart',
            'Hyper-arrive',
            'Hyper-leave'
        };

        String kanbanTitleValue = '';
        String zoneNameValue = '';
        String zoneStateValue = '';
        String realTimeRecord = '';
        String actionType = '';
    	String kanbanBoardTitleValue = '';
	    for (leankor__Realtimetracker__c tracker: [Select Id,
                                                            CreatedById,
                                                            CreatedBy.Name,
                                                            leankor__JSONDataSmall2__c,
                                                            leankor__JSONDataSmall3__c,
                                                            leankor__JSONDataSmall4__c,
                                                            leankor__JSONDataSmall5__c,
                                                            leankor__JSONDataSmall6__c,
                                                            leankor__JSONDataSmall7__c,
                                                            leankor__JSONDataSmall8__c,
                                                            leankor__JSONDataSmall__c,
                                                            CreatedDate,
                                                            leankor__ValueStream__c,
                                                            leankor__ValueStream__r.Name,
                                                            leankor__KanbanVerb__c,
                                                            SystemModstamp
                                                        From leankor__Realtimetracker__c
                                                        Where leankor__ValueStream__c = :valueStreamId
                                                            And leankor__KanbanVerb__c In :alertVerbs
                                                        Order By SystemModstamp Desc 
                                                        Limit 50]) {

			realTimeRecord = (tracker.leankor__JSONDataSmall__c == null ? '' : tracker.leankor__JSONDataSmall__c) + '' + (tracker.leankor__JSONDataSmall2__c == null ? '' : tracker.leankor__JSONDataSmall2__c) + '' + (tracker.leankor__JSONDataSmall3__c == null ? '' : tracker.leankor__JSONDataSmall3__c) + '' + (tracker.leankor__JSONDataSmall4__c == null ? '' : tracker.leankor__JSONDataSmall4__c) + '' + (tracker.leankor__JSONDataSmall5__c == null ? '' : tracker.leankor__JSONDataSmall5__c) + '' + (tracker.leankor__JSONDataSmall6__c == null ? '' : tracker.leankor__JSONDataSmall6__c) + '' + (tracker.leankor__JSONDataSmall7__c == null ? '' : tracker.leankor__JSONDataSmall7__c) + '' + (tracker.leankor__JSONDataSmall8__c == null ? '' : tracker.leankor__JSONDataSmall8__c);
            
            StateChangePackage stateChangePackage = new StateChangePackage();
			zoneNameValue = '';
			kanbanTitleValue = '';
			actionType = '';
			kanbanBoardTitleValue = '';
            String fieldList = '';
            
			if (tracker.leankor__KanbanVerb__c != 'OpenValueStream') {

				if (String.isEmpty(realTimeRecord)) {
					continue;
    			}

				try {
					stateChangePackage = (StateChangePackage)JSON.deserialize(realTimeRecord, StateChangePackage.class);
				} catch (Exception ex) {
					continue;
				}

				kanbanTitleValue = stateChangePackage.Name;
				// Verb 'CreateMarker', 'MoveMarker', 'DeleteMarker' used for Marker sobject.
				// Common verb for both marker and label.
				Switch on tracker.leankor__KanbanVerb__c {
					when 'CreateMarker', 'MoveMarker', 'DeleteMarker'{
						kanbanTitleValue = '" ' + kanbanTitleValue + ' " ' + ((stateChangePackage.Type == null || stateChangePackage.Type == 'Marker') ? 'Marker.' : 'Text.');
					}
					when 'Hyper-arrive' {
						zoneNameValue = stateChangePackage.ValueStreamName;
					}
					when 'Hyper-leave'{
						zoneNameValue = stateChangePackage.SwitchedVSName;
					}
					when 'UpdateKanbanCard', 'CreateKanbanCard', 'MoveKanbanCard', 'DeleteKanbanCard'{
						kanbanTitleValue = String.isNotBlank(stateChangePackage.LinkCN) ? '' + stateChangePackage.Name + '"' + ' linked to activity ' + '"' + stateChangePackage.LinkCN + '' : stateChangePackage.Name;
                        
                        if (String.isNotBlank(stateChangePackage.dl)) {
							fieldList = stateChangePackage.dl;
                        }
                        
						actionType = stateChangePackage.ItemType;
						zoneStateValue = stateChangePackage.State;
						zoneNameValue = stateChangePackage.ZoneTitle;
					}
                    when 'MoveZone'{
                        kanbanTitleValue = stateChangePackage.Title;
                    }
                }
                kanbanBoardTitleValue = tracker.leankor__ValueStream__r.Name;
				// add one more parameter in alertRecords constructor stateChangePackage.dl
				alertList.add(new AlertWrapper(new AlertRecords(tracker.Id, tracker.CreatedBy.Name, tracker.CreatedDate, tracker.SystemModStamp, tracker.leankor__KanbanVerb__c, actionType, kanbanTitleValue, zoneNameValue, zoneStateValue, fieldList, kanbanBoardTitleValue)));
			} else {
				// default message when opens board verb 'OpenValueStream'
				//kanbanTitleValue = tracker.leankor__ValueStream__r.Name;
				kanbanBoardTitleValue = tracker.leankor__ValueStream__r.Name;
				// add one more parameter in alertRecords constructor stateChangePackage.dl
				alertList.add(new AlertWrapper(new AlertRecords(tracker.Id, tracker.CreatedBy.Name, tracker.CreatedDate, tracker.SystemModStamp, tracker.leankor__KanbanVerb__c, actionType, kanbanTitleValue, zoneNameValue, zoneStateValue, fieldList, kanbanBoardTitleValue)));
			}
        }
        
	    return alertList;
    }


    /***
     * INPUT  : String valueStreamId.
     * OUTPUT : Attachment Id for preview image.
     * USAGE  : Used to show PDf preview in LeankorJS app if already preview availabel.
     */
    @RemoteAction
    global static String getPreview(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        String returnVal = '';

        String likeSearch = 'preview';

        for (Attachment attachment : [Select Id, 
                                            Name 
                                        From Attachment 
                                        Where ParentId = :valueStreamId 
                                            And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                            Order By LastModifiedDate Desc
                                            Limit 50000]) {

            if (attachment.Name.contains(likeSearch)) {
                returnVal = attachment.Id;
                break;
            }
        }

        return returnVal;
    }


    /***
     * INPUT : String valueStreamId.
     * OUTPUT : returns 'Success' / '' string values.
     * USAGE : this will remove background image.
     */
    @RemoteAction
    global static String removeValueStreamBackground(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior	
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();

        if (!attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isDeletable()) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String likeSearch = 'background';

        List<Attachment> attachments = new List<Attachment>();

        for (Attachment attachment : [Select Id, 
                                                Description 
                                            From Attachment 
                                            Where ParentId = :valueStreamId 
                                                And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                            Order By LastModifiedDate Desc
                                            Limit 10000]) {
            //Pratiksha : 19/08/2021 - Changes for fixing the background image issue.                                    
            if (String.isNotBlank(attachment.Description) && attachment.Description.contains(likeSearch)) {
                attachments.add(attachment);
            }
        }

        if (attachments.size() > 0) {
            delete attachments;
        }

        return 'Success';
    }


    /***
     * INPUT : Kanban Class JSON as string and BoardType like 'Whiteboard'.
     * OUTPUT : returns kanban class object.
     * USAGE : method will inhance broadcast limit.
     * here added some fields values that is was removed at the time of insertion realtimetracker object for kanban card.
     * This will make broadcast to each type of board from different sources. Eg: Whiteboard to Calender View, Card Hierarchy and vise versa.
    */
    @RemoteAction
    global static Kanban getKanbanCardRecord(String kanbanJSON, String boardVerb) {
        Kanban remoteKanban = new Kanban();
        remoteKanban = (Kanban)JSON.deserialize(kanbanJSON, Kanban.class);

        if (String.isNotBlank(remoteKanban.Id) && Util.getSObjectName(remoteKanban.Id) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
     
        //Date:03/05/19 Get kanbancard record from without sharing class.
        leankor__KanbanCard__c kanbanCard = leankor.RealTimeControllerHelper.readKanbanCardRecord(remoteKanban, boardVerb);

        if (kanbanCard != null) {
            //Exclude records with null Vs / Project
            //Reverted changes as in delete item again record is retrieved from apex again
            if ((boardVerb!= 'DeleteKanbanCard' 
            && String.isBlank(kanbanCard.Id)) 
            && (String.isBlank(kanbanCard.leankor__ValueStream__c) 
            || String.isBlank(kanbanCard.leankor__ProjectRoom__c))) {
                //After implementing null condition of ValueStream/ProjectRoom it is possible that we will have no record due to exclusion
                //that's why commenting exception throw as this method is used for handling broadcast
                return remoteKanban;
                //throw new Util.LeanException('Card no longer exist. Please try again.');
                //return remoteKanban;
            }
        } else {
            return remoteKanban;
        }

        // get number of swimlane and zone record based on master container.
        Integer swimlaneCount = [Select Count() 
                                    From leankor__Swimlane__c 
                                    Where leankor__MasterContainer__c = :kanbanCard.leankor__MasterContainer__c];

        Integer zoneCount = [Select Count() 
                                From leankor__Zone__c 
                                Where leankor__Swimlane__c = :kanbanCard.leankor__Swimlane__c];

        // query task records and put results in a list         
        List<Task> taskRecords = [Select Id
                                        From Task
                                        Where WhatId = :kanbanCard.Id 
                                            And IsDeleted = false 
                                        Limit 50000 
                                        All Rows];

        //If Fsl is enabled then get FSL data count for cards(activity)			
	    Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>{kanbanCard.Id},'KC');
        
        Map<String, List<leankor.GanttTaskBoard.Miniature>> mapMiniatures = new Map<String, List<leankor.GanttTaskBoard.Miniature>>();

        if (boardVerb == 'AddMiniature') {
            List<String> kanbanCardIds = new List<String>();
            kanbanCardIds.add(kanbanCard.Id);
            mapMiniatures = getMiniatureData(kanbanCardIds);
        }

        List<User> users = [Select Id,
                                    SmallPhotoUrl 
                                From User 
                                Where Id = :kanbanCard.OwnerId 
                                Limit 1];

        remoteKanban.Id = kanbanCard.Id;
        remoteKanban.Name = kanbanCard.Name;
        remoteKanban.Title = kanbanCard.leankor__KanbanCardTemplate__r.Name;
        remoteKanban.Color = kanbanCard.leankor__KanbanCardTemplate__r.leankor__color__c;
        remoteKanban.UrlLink = kanbanCard.leankor__UrlLink__c;
        remoteKanban.GUID = kanbanCard.leankor__GUID__c;
        remoteKanban.Point = KanbanCard.leankor__Point__c;
        remoteKanban.EffortRemaining = integer.valueof(KanbanCard.leankor__EffortRemaining__c);
        remoteKanban.MCForceID = kanbanCard.leankor__MasterContainer__c;
        remoteKanban.SWForceID = kanbanCard.leankor__Swimlane__c;
        remoteKanban.ZoneForceID = kanbanCard.leankor__Zone__c;
        remoteKanban.TemplateID = kanbanCard.leankor__KanbanCardTemplate__c;
        remoteKanban.TemplateName = kanbanCard.leankor__KanbanCardTemplate__r.Name;
        //06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
        //remoteKanban.JSONData = kanbanCard.leankor__JSONData__c == '' || kanbanCard.leankor__JSONData__c == null ? '{}' : kanbanCard.leankor__JSONData__c;
        //remoteKanban.JSONDefinition = kanbanCard.leankor__JSONDefinition__c == '' || kanbanCard.leankor__JSONDefinition__c == null ? '{}' : kanbanCard.leankor__JSONDefinition__c;
        remoteKanban.AccountName = kanbanCard.leankor__Account__c == null ? '' : kanbanCard.leankor__Account__r.Name;
        remoteKanban.ContactName = kanbanCard.leankor__Contact__c == null ? '' : kanbanCard.leankor__Contact__r.Name;
        remoteKanban.OpportunityName = kanbanCard.leankor__Opportunity__c == null  ? '' : kanbanCard.leankor__Opportunity__r.Name;
        remoteKanban.PercentDone = kanbanCard.leankor__PercentComplete2__c;
        remoteKanban.CaseSubject = kanbanCard.leankor__Case__c == null ? '' : (kanbanCard.leankor__Case__r.Subject == null ? 'Case : ' + kanbanCard.leankor__Case__r.CaseNumber : kanbanCard.leankor__Case__r.Subject);
        remoteKanban.CaseStatus = kanbanCard.leankor__Case__c == null ? '' : kanbanCard.leankor__Case__r.Status;
        remoteKanban.CasePriority = kanbanCard.leankor__Case__c == null ? '' : kanbanCard.leankor__Case__r.Priority;
        remoteKanban.SmallPhotoUrl = users.size() > 0 ? users[0].SmallPhotoUrl : null;
        remoteKanban.KanbanUrl = '';
        remoteKanban.ValueStreamLinkID = kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__c;
        remoteKanban.ValueStreamCardLink = kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__c;
        remoteKanban.ValueStreamLinkBoardType = kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__r.leankor__Boardtype__c;
        remoteKanban.ValueStreamLinkIDName = kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__r.Name;
        remoteKanban.ValueStreamCardLinkName = kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__r.Name;
        remoteKanban.Description = String.isBlank(kanbanCard.leankor__DescriptionLong__c) ? '' : kanbanCard.leankor__DescriptionLong__c;
        remoteKanban.ValueStream = kanbanCard.leankor__ValueStream__c;
        remoteKanban.CardID = kanbanCard.leankor__CardID__c == null ? '' : kanbanCard.leankor__CardID__c;
        remoteKanban.OwnerName = kanbanCard.Owner.Name;
        remoteKanban.StartDate = kanbanCard.leankor__StartDateTime__c;
        remoteKanban.DueDate = kanbanCard.leankor__DueDateTime__c;
        remoteKanban.OwnerID = kanbanCard.OwnerId;
        remoteKanban.HarveyBall = String.valueof(kanbanCard.leankor__PercentComplete2__c);
        remoteKanban.Priority = kanbanCard.leankor__Priority__c == null || kanbanCard.leankor__Priority__c == 0 ? 4 : Integer.valueof(kanbanCard.leankor__Priority__c);        
        remoteKanban.Height = kanbanCard.leankor__Height__c;
        remoteKanban.UrlLink = String.isEmpty(kanbanCard.leankor__UrlLink__c) ? '' : kanbanCard.leankor__UrlLink__c;
        remoteKanban.width = kanbanCard.leankor__width__c;
        remoteKanban.Top = kanbanCard.leankor__Top__c;
        remoteKanban.Left = kanbanCard.leankor__Left__c;
        remoteKanban.X = kanbanCard.leankor__X__c;
        remoteKanban.Y = kanbanCard.leankor__Y__c;   
        remoteKanban.ZoneID = kanbanCard.leankor__ZoneGUID__c == null ? '' : kanbanCard.leankor__ZoneGUID__c;
        remoteKanban.Point  = kanbanCard.leankor__Point__c;
        remoteKanban.Color  = kanbanCard.leankor__KanbanCardTemplate__r.leankor__color__c; 
        remoteKanban.Order = kanbanCard.leankor__Order__c;           
        remoteKanban.OnBudget = kanbanCard.leankor__OnBudget__c;
        remoteKanban.OnQuality = kanbanCard.leankor__OnQuality__c;
        remoteKanban.OnTime = kanbanCard.leankor__OnTime__c;
        remoteKanban.AcceptanceCriteria = String.isEmpty(kanbanCard.leankor__AcceptanceCriteria__c) ? '' : kanbanCard.leankor__AcceptanceCriteria__c ;
        remoteKanban.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c;
        remoteKanban.DurationUnits = kanbanCard.leankor__DurationUnits__c;        
       	remoteKanban.isAtRisk = kanbanCard.leankor__IsAtRisk__c;
       	remoteKanban.isOnHold = kanbanCard.leankor__IsOnHold__c;
        remoteKanban.ValueStreamName = kanbanCard.leankor__Valuestream__r.Name;
        remoteKanban.ProjectName = kanbanCard.leankor__ProjectRoom__c;
        remoteKanban.BoardType = kanbanCard.leankor__valuestream__r.leankor__boardtype__c;
        remoteKanban.IsSuccessorRecalculate = kanbanCard.leankor__IsSuccessorRecalculate__c;        
        remoteKanban.IsTemplate = (kanbanCard.leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c != kanbanCard.leankor__Valuestream__r.leankor__IsTemplateBoard__c) || kanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template';
        remoteKanban.IsProjectTemplate = kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c;
        remoteKanban.isScheduleBackward = kanbanCard.leankor__valueStream__r.leankor__ScheduleBackward__c;
        //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
        	remoteKanban.isConstraintRecalculate = kanbanCard.leankor__IsConstraintRecalculate__c;
        }
        
        // Added fields for schedulemode broadcasting SD 02-03-17
        if (kanbanCard.leankor__ScheduleModes__r != null) {   
            for(leankor__ScheduleMode__c schedulemodes : kanbanCard.leankor__ScheduleModes__r) {
                remoteKanban.SchedulingMode = schedulemodes.leankor__Mode__c == null ? 'Normal' : schedulemodes.leankor__Mode__c;
                remoteKanban.ManuallyScheduled = schedulemodes.leankor__ManuallyScheduled__c == null ? false : schedulemodes.leankor__ManuallyScheduled__c;
                remoteKanban.Effort = schedulemodes.leankor__EffortActual__c == null ? 0 : schedulemodes.leankor__EffortActual__c;
                remoteKanban.EffortUnit = schedulemodes.leankor__EffortUnits__c == null ? 'Days' : schedulemodes.leankor__EffortUnits__c;
                remoteKanban.SchedulingModeId = schedulemodes == null ? '' : schedulemodes.Id;
                //Changes : Check Constraint setting enable or not.
                if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                    remoteKanban.ConstraintType = (schedulemodes.leankor__ScheduleConstraint__r.leankor__Type__c != null && String.isNotBlank(schedulemodes.leankor__ScheduleConstraint__r.leankor__Type__c)) ? schedulemodes.leankor__ScheduleConstraint__r.leankor__Type__c : '';
                    remoteKanban.ConstraintDate = (schedulemodes.leankor__ConstraintDateTime__c != null) ? schedulemodes.leankor__ConstraintDateTime__c : null;
                }
            }
        }       
        
        //-- rbo 03.28.18 NOTE to developers: the following code can cause an issue if there are many resources associated to an Activity                       
        if (kanbanCard.leankor__ResourceAssignments__r != null && kanbanCard.leankor__ResourceAssignments__r.size() > 0) {
            remoteKanban.AssignToId = kanbanCard.leankor__ResourceAssignments__r[0].leankor__AssignedTo__c;   
            remoteKanban.percentCompleted = kanbanCard.leankor__ResourceAssignments__r[0].leankor__PercentCompleted__c;
            remoteKanban.percentAllocation = kanbanCard.leankor__ResourceAssignments__r[0].leankor__PercentAllocation__c;                
        }

        // 24.01.2017 - yj if card boardtype is uberboard then card recordtype name is assigning in itemtype
        // else card boardtype is not uberboard then item type is kanbanCard.
        if (kanbanCard.leankor__valuestream__r.leankor__boardtype__c == 'UberBoard') {            
            remoteKanban.timeToProjectLaunch = String.isNotBlank(String.valueOf(kanbanCard.leankor__TimeToProjectLaunch__c)) ? String.valueOf(kanbanCard.leankor__TimeToProjectLaunch__c.intValue()) : '';                            
            remoteKanban.ItemType = kanbanCard.Recordtype.name;
            remotekanban.leaf = remoteKanban.ItemType == 'MilestoneCard' || remoteKanban.ItemType == 'ActivityCard';
            
            List<leankor__KanbanCard__c> miniatureKanbanCards = [Select Id 
                                                                    From leankor__KanbanCard__c
                                                                    Where leankor__ValueStreamCardLink__c = :kanbanCard.Id 
                                                                        And ((leankor__MasterContainer__r.leankor__Type__c In :MASTERCONTAINERTYPEFILTERS_CONST 
                                                                            And leankor__TemplateBoard__c = false) 
                                                                            Or leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c = true) 
                                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
                                                                        And leankor__IsRecordDeleted__c = false 
                                                                    Limit 1];
            
            remoteKanban.isMiniature = miniatureKanbanCards.size() > 0;                                                    
        } else {
            remoteKanban.ItemType = kanbanCard.RecordType.Name == 'MileStoneCard' ? 'MileStoneCard' : 'KC' ;
        }
        
        remoteKanban.SWeek = kanbanCard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c;
        remoteKanban.ForceID = kanbanCard.Id;
        remoteKanban.isTaskDueCheck = kanbanCard.leankor__ValueStream__r.leankor__TaskDateCheck__c;
        remoteKanban.IsExternallyDependent = kanbanCard.leankor__IsExternallyDependent__c;
        
        remoteKanban.Account = String.isEmpty(kanbanCard.leankor__Account__c) ? '' : kanbanCard.leankor__Account__c;
        remoteKanban.Bottom = 0;
        remoteKanban.CaseID = String.isEmpty(kanbanCard.leankor__Case__c) ? '' : kanbanCard.leankor__Case__c;
        remoteKanban.Contact = String.isEmpty(kanbanCard.leankor__Contact__c) ? '' : kanbanCard.leankor__Contact__c;
        remoteKanban.Opportunity = String.isEmpty(kanbanCard.leankor__Opportunity__c) ? '' : kanbanCard.leankor__Opportunity__c;
        remoteKanban.OpportunityStage = String.isEmpty(kanbanCard.leankor__Opportunity__c) ? '' : kanbanCard.leankor__Opportunity__r.StageName;
        remoteKanban.State = kanbanCard.leankor__State__c;
        remoteKanban.ZoneTitle = String.isEmpty(kanbanCard.leankor__Zone__c) ? '': kanbanCard.leankor__Zone__r.leankor__Title__c;
        remoteKanban.ProjectID = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
        remoteKanban.ValueStreamID = kanbanCard.leankor__ValueStream__c;
        remoteKanban.ParentProjectRoomID = kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c;
        remoteKanban.LinkProjectRoomID = kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? '' : kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c;
        remoteKanban.TaskComments = taskRecords.size();

        //If FSL is enabled then add FSL info with KC instance
    	remoteKanban.workOrderCount  = fslDataInfo.containsKey(kanbanCard.Id) ?  fslDataInfo.get(kanbanCard.Id).workOrderCount : 0;
		remoteKanban.serviceAppointmentCount =  fslDataInfo.containsKey(kanbanCard.Id) ? fslDataInfo.get(kanbanCard.Id).serviceAppointmentCount != null ? fslDataInfo.get(kanbanCard.Id).serviceAppointmentCount  : null : 0;
		remoteKanban.fslSchedStartDateTime =  fslDataInfo.containsKey(kanbanCard.Id) ? fslDataInfo.get(kanbanCard.Id).fslSchedStartDateTime != null ? fslDataInfo.get(kanbanCard.Id).fslSchedStartDateTime : null : null;
		remoteKanban.fslSchedDueDateTime =   fslDataInfo.containsKey(kanbanCard.Id) ? fslDataInfo.get(kanbanCard.Id).fslSchedDueDateTime != null ? fslDataInfo.get(kanbanCard.Id).fslSchedDueDateTime: null : null;
		
		//These fields are handled on PDG, in case of UpdateCardRecords() method, they pass sobject Field
		remoteKanban.HarveyBallDoneDate = kanbanCard.leankor__HarveyBallDoneDate__c;
		remoteKanban.PromiseCompletionDate = kanbanCard.leankor__PromiseCompletionDate__c; 			

        //Date : 01/05/19  use for miniature percent.
       	leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
		Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();

        //Date: 14/11/2019 - changes related to blackout
        Set<Id> valueStreamIds = new Set<Id>();
        valueStreamIds.add(kanbanCard.leankor__ValueStream__c);

        // Get the blacout records
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> mapBlackouts =  leankor.RealTimeControllerHelper.getBlackOutRecords(valueStreamIds);
        leankor.Util.WorkWeek workWeek = new leankor.Util.WorkWeek(firstDayOfWeek, kanbanCard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c ? 7 : 5, mapBlackouts.get(kanbanCard.leankor__ValueStream__c));          
                
        remoteKanban.isDueDatePercentComplete = GanttTaskBoard.hasSeventyPercentDueDate(kanbanCard, workWeek);
        remoteKanban.masterContainerName=kanbanCard.leankor__MasterContainer__r.Name;
        remoteKanban.zoneName = zoneCount > 1 ? kanbanCard.leankor__Zone__r.Name : null;
        remoteKanban.swimlaneName = swimlaneCount > 1 ? kanbanCard.leankor__Swimlane__r.Name : null;

        if (boardVerb == 'AddMiniature' && remoteKanban.BoardType == 'UberBoard') {
            remoteKanban.miniature = mapMiniatures.get(kanbanCard.Id);
        }

        //Pratiksha 01/Dec/2023 : Changes added for showing weekCalendar data on MyWork if user change the date form MyWork.
        if(kanbanCard.leankor__valueStream__r.leankor__SevenDayWorkWeek__c){
            //Pratiksha : 19/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
            if(kanbanCard.leankor__Monday__c == false && kanbanCard.leankor__Tuesday__c == false && kanbanCard.leankor__Wednesday__c == false &&  kanbanCard.leankor__Thursday__c == false &&  kanbanCard.leankor__Friday__c == false &&  kanbanCard.leankor__Saturday__c == false &&  kanbanCard.leankor__Sunday__c == false){
                remoteKanban.Monday = true;
                remoteKanban.Tuesday = true;
                remoteKanban.Wednesday = true;
                remoteKanban.Thursday = true;
                remoteKanban.Friday = true;
                remoteKanban.Saturday = true;
                remoteKanban.Sunday = true;
            }else{
                remoteKanban.Monday = kanbanCard.leankor__Monday__c;
                remoteKanban.Tuesday = kanbanCard.leankor__Tuesday__c;
                remoteKanban.Wednesday = kanbanCard.leankor__Wednesday__c;
                remoteKanban.Thursday = kanbanCard.leankor__Thursday__c;
                remoteKanban.Friday = kanbanCard.leankor__Friday__c;
                remoteKanban.Saturday = kanbanCard.leankor__Saturday__c;
                remoteKanban.Sunday = kanbanCard.leankor__Sunday__c;
                remoteKanban.weekCalendar = String.isEmpty(kanbanCard.leankor__WeekCalendar__c) ? '' : kanbanCard.leankor__WeekCalendar__c;
            }
        }
        
        return remoteKanban;
    }
    
    @AuraEnabled
    public static KanbanAura getKanbanCardRecordAura(String kanbanJSON, String boardVerb) {
        try {
            // Reuse existing server logic
            Kanban kanban = getKanbanCardRecord(kanbanJSON, boardVerb);

            // Map Kanban -> KanbanAura via JSON round-trip (no manual field mapping needed)
            return (KanbanAura) JSON.deserialize(
                JSON.serialize(kanban),
                KanbanAura.class
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //new methods for broadcast reciever 
    @RemoteAction
    global static List<Kanban> getKanbanCardData(List<String> kanbanCardIds, String boardVerb) {
        for (String kanbanCardId : kanbanCardIds) {
            if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        List<Kanban> remoteKanbanCard = new List<Kanban>();
        List<String> ownerIds = new List<String>();
        Map<String, List<leankor.GanttTaskBoard.Miniature>> mapMiniatures = new Map<String, List<leankor.GanttTaskBoard.Miniature>>();
        
        //Date : 1/05/19  use for miniature percent.
       	leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
		Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();
        
        if (boardVerb == 'AddMiniature') {
            mapMiniatures = getMiniatureData(kanbanCardIds);
        } 

        if (boardVerb == 'MultipleDragDrop') {
            // Get kanbancards Data from withOut sharing.                     
      		kanbanCardList = leankor.RealTimeControllerHelper.readKanbanCardData(kanbanCardIds, boardVerb);  
            for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {   
                Kanban remoteKanban = new Kanban();
                remoteKanban.Id = kanbanCard.ID;
                remoteKanban.GUID = kanbanCard.leankor__GUID__c;
                remoteKanban.Order = kanbanCard.leankor__Order__c; 
                remoteKanbanCard.add(remoteKanban);     
            }        
        } else {
        	// Get kanbancards Data from withOut sharing.
            List<leankor__KanbanCard__c> tempKanbanCardList = leankor.RealTimeControllerHelper.readKanbanCardData(kanbanCardIds, boardVerb);
            //Date :18/02/2020 To add records in List in Order of recordType.
			List<leankor__KanbanCard__c> folderCardList = new List<leankor__KanbanCard__c>();
            List<leankor__KanbanCard__c> activityCardList = new List<leankor__KanbanCard__c>();
            List<leankor__KanbanCard__c> milestoneCardList = new List<leankor__KanbanCard__c>(); 
           
            for (leankor__KanbanCard__c kanbanCard : tempKanbanCardList) {
                //Exclude records with null Vs / Project 
                if (String.isNotBlank(kanbanCard.leankor__ValueStream__c) && String.isNotBlank(kanbanCard.leankor__ProjectRoom__c)) {
                    if (kanbanCard.RecordType.Name == 'FolderCard') {
                        folderCardList.add(kanbanCard);
                    } else if(kanbanCard.RecordType.Name == 'MileStoneCard') {
                        milestoneCardList.add(kanbanCard);
                    } else {
                        activityCardList.add(kanbanCard);
                    }

                    ownerIds.add(kanbanCard.OwnerId);
                }
            }

            kanbanCardList.addAll(folderCardList);
            kanbanCardList.addAll(milestoneCardList);
            kanbanCardList.addAll(activityCardList);

            List<Task> taskRecords = [Select Id
                                        From Task
                                        Where WhatID In :kanbanCardIds 
                                            And IsDeleted = false 
                                        Limit 50000
                                        All Rows];
            
            List<User> users = [Select Id,
                                        SmallPhotoUrl
                                    From User
                                    Where Id In :ownerIds 
                                    Limit 50000];
                    
            Map<Id, String> UserRecords = new Map<Id, String>();

            for (User user : users) {
                UserRecords.put(user.Id, user.SmallPhotoUrl);
            }
        
            //If Fsl is enabled then get FSL data count for cards(activity)			
	        Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>(kanbanCardIds), 'KC') ;
	    
            // Date: 14/11/2019 - changes related to blackout
            Map<Id, Boolean> mapValueStreams = new Map<Id, Boolean>();

            for (leankor__KanbanCard__c kanban: kanbanCardList) {
                mapValueStreams.put(kanban.leankor__ValueStream__c, kanban.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c);
            }

            // Get the blackout records
            Map<Id, List<leankor__ProjectScheduleBlackout__c>> mapBlackouts =  leankor.RealTimeControllerHelper.getBlackOutRecords(mapValueStreams.keySet());

            Map<Id, leankor.Util.WorkWeek> mapWorkWeeks = new Map<Id, leankor.Util.WorkWeek>();
            for (Id key : mapValueStreams.keySet()) {
                leankor.Util.WorkWeek workWeek = new leankor.Util.WorkWeek(firstDayOfWeek, mapValueStreams.get(key) ? 7 : 5, mapBlackouts.get(key));
                mapWorkWeeks.put(key, workWeek);
            }

            for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {
                    Kanban remoteKanban = new Kanban();
                    
                    remoteKanban.Id = kanbanCard.Id;
                    remoteKanban.Name = kanbanCard.Name;
                    remoteKanban.Title = kanbanCard.leankor__KanbanCardTemplate__r.Name;
                    remoteKanban.Color = kanbanCard.leankor__KanbanCardTemplate__r.leankor__color__c;
                    remoteKanban.UrlLink = kanbanCard.leankor__UrlLink__c;
                    remoteKanban.GUID = kanbanCard.leankor__GUID__c;
                    remoteKanban.Point = KanbanCard.leankor__Point__c;
                    remoteKanban.EffortRemaining = integer.valueof(KanbanCard.leankor__EffortRemaining__c);
                    remoteKanban.MCForceID = kanbanCard.leankor__MasterContainer__c;
                    remoteKanban.SWForceID = kanbanCard.leankor__Swimlane__c;
                    remoteKanban.ZoneForceID = kanbanCard.leankor__Zone__c;
                    remoteKanban.TemplateID = kanbanCard.leankor__KanbanCardTemplate__c;
                    remoteKanban.TemplateName = kanbanCard.leankor__KanbanCardTemplate__r.Name;
                    //06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
                    //remoteKanban.JSONData = ((kanbanCard.leankor__JSONData__c == '' || kanbanCard.leankor__JSONData__c == null) ? '{}' : kanbanCard.leankor__JSONData__c);
                    //remoteKanban.JSONDefinition = ((kanbanCard.leankor__JSONDefinition__c == '' || kanbanCard.leankor__JSONDefinition__c == null) ? '{}' : kanbanCard.leankor__JSONDefinition__c);
                    remoteKanban.AccountName = kanbanCard.leankor__Account__c == null ? '' : kanbanCard.leankor__Account__r.Name;
                    remoteKanban.ContactName = kanbanCard.leankor__Contact__c == null ? '' : kanbanCard.leankor__Contact__r.Name;
                    remoteKanban.OpportunityName = kanbanCard.leankor__Opportunity__c == null  ? '' : kanbanCard.leankor__Opportunity__r.Name;
                    remoteKanban.PercentDone = kanbanCard.leankor__PercentComplete2__c;
                    remoteKanban.CaseSubject = ((kanbanCard.leankor__Case__c == null) ? '' : (kanbanCard.leankor__Case__r.Subject == null) ? 'Case : ' + kanbanCard.leankor__Case__r.CaseNumber : (kanbanCard.leankor__Case__r.Subject));
                    remoteKanban.CaseStatus = ((kanbanCard.leankor__Case__c == null) ? '' : (kanbanCard.leankor__Case__r.Status));
                    remoteKanban.CasePriority = ((kanbanCard.leankor__Case__c == null) ? '' : (kanbanCard.leankor__Case__r.Priority));
                    remoteKanban.SmallPhotoUrl = UserRecords.get(kanbanCard.OwnerId);
                    remoteKanban.KanbanUrl = '';
                    remoteKanban.ValueStreamLinkID = (kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__c);
                    remoteKanban.ValueStreamCardLink = (kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__c);
                    remoteKanban.ValueStreamLinkBoardType = (kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__r.leankor__Boardtype__c);
                    remoteKanban.ValueStreamLinkIDName = (kanbanCard.leankor__ValueStreamLink__c == Null ? '' : kanbanCard.leankor__ValueStreamLink__r.Name);
                    remoteKanban.ValueStreamCardLinkName = (kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__r.Name);
                    remoteKanban.Description = kanbanCard.leankor__DescriptionLong__c;
                    remoteKanban.ValueStream = kanbanCard.leankor__ValueStream__c;
                    remoteKanban.CardID = (kanbanCard.leankor__CardID__c == null ? '' : kanbanCard.leankor__CardID__c);
                    remoteKanban.OwnerName = kanbanCard.Owner.Name;
                    remoteKanban.StartDate = kanbanCard.leankor__StartDateTime__c;
                    remoteKanban.DueDate = kanbanCard.leankor__DueDateTime__c;
                    remoteKanban.OwnerID = kanbanCard.OwnerId;
                    remoteKanban.HarveyBall = String.valueof(kanbanCard.leankor__PercentComplete2__c);
                    remoteKanban.Priority = kanbanCard.leankor__Priority__c == null || kanbanCard.leankor__Priority__c == 0 ? 4 : Integer.valueof(kanbanCard.leankor__Priority__c);        
                    remoteKanban.Height = kanbanCard.leankor__Height__c;
                    remoteKanban.UrlLink = String.isEmpty(kanbanCard.leankor__UrlLink__c) ? '' : kanbanCard.leankor__UrlLink__c;
                    remoteKanban.width = kanbanCard.leankor__width__c;
                    remoteKanban.Top = kanbanCard.leankor__Top__c;
                    remoteKanban.Left = kanbanCard.leankor__Left__c;
                    remoteKanban.X = kanbanCard.leankor__X__c;
                    remoteKanban.Y = kanbanCard.leankor__Y__c;   
                    remoteKanban.ZoneID = kanbanCard.leankor__ZoneGUID__c == null ? '' : kanbanCard.leankor__ZoneGUID__c;
                    remoteKanban.Point  = kanbanCard.leankor__Point__c;
                    remoteKanban.Color  = kanbanCard.leankor__KanbanCardTemplate__r.leankor__color__c; 
                    remoteKanban.Order = kanbanCard.leankor__Order__c;           
                    remoteKanban.OnBudget = kanbanCard.leankor__OnBudget__c;
                    remoteKanban.OnQuality = kanbanCard.leankor__OnQuality__c;
                    remoteKanban.OnTime = kanbanCard.leankor__OnTime__c;
                    remoteKanban.isAtRisk = kanbanCard.leankor__IsAtRisk__c;
                    remoteKanban.isOnHold = kanbanCard.leankor__IsOnHold__c;
                    remoteKanban.AcceptanceCriteria = String.isEmpty(kanbanCard.leankor__AcceptanceCriteria__c) ? '' : kanbanCard.leankor__AcceptanceCriteria__c ;
                    remoteKanban.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c;
                    remoteKanban.DurationUnits = kanbanCard.leankor__DurationUnits__c;
                    // yj 02.01.2017 added fields for broadcasting
                    remoteKanban.ValueStreamName = kanbanCard.leankor__Valuestream__r.Name;
                    remoteKanban.ProjectName = kanbanCard.leankor__ProjectRoom__c;
                    remoteKanban.BoardType = kanbanCard.leankor__valuestream__r.leankor__boardtype__c;       
                    remoteKanban.IsSuccessorRecalculate = kanbanCard.leankor__IsSuccessorRecalculate__c;      
                    remoteKanban.IsExternallyDependent= kanbanCard.leankor__IsExternallyDependent__c;                
                    remoteKanban.IsTemplate = (kanbanCard.leankor__ValueStreamLink__r.leankor__IsTemplateBoard__c != kanbanCard.leankor__Valuestream__r.leankor__IsTemplateBoard__c) || kanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template';
                    remoteKanban.IsProjectTemplate = kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c;
                    //29/06/2022 : Changes for adding the isConstraintRecalculate field for Constraint hybrid mode.
                    if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                    	remoteKanban.isConstraintRecalculate = kanbanCard.leankor__IsConstraintRecalculate__c;
                    }    
                    
                    // Added fields for schedulemode broadcasting SD 02-03-17       
                    if (kanbanCard.leankor__ScheduleModes__r != null) {   
                        for(leankor__ScheduleMode__c schedulemode : kanbanCard.leankor__ScheduleModes__r) {
                            remoteKanban.SchedulingMode = (schedulemode.leankor__Mode__c == null ? 'Normal' : schedulemode.leankor__Mode__c);
                            remoteKanban.ManuallyScheduled = (schedulemode.leankor__ManuallyScheduled__c == null ? false : schedulemode.leankor__ManuallyScheduled__c);
                            remoteKanban.Effort = (schedulemode.leankor__EffortActual__c == null ? 0 : schedulemode.leankor__EffortActual__c);
                            remoteKanban.EffortUnit = (schedulemode.leankor__EffortUnits__c == null ? 'Days' : schedulemode.leankor__EffortUnits__c);
                            remoteKanban.SchedulingModeId = (schedulemode == null ? '' : schedulemode.Id);
                            //Changes : Check Constraint setting enable or not.
                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                remoteKanban.ConstraintType = (schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c != null && String.isNotBlank(schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c)) ? schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c : '';
                                remoteKanban.ConstraintDate = (schedulemode.leankor__ConstraintDateTime__c != null) ? schedulemode.leankor__ConstraintDateTime__c : null;
                            }
                        }
                    }       
                    
                    //-- rbo 03.28.18 NOTE to developers: the following code can cause an issue if there are many resources associated to an Activity               
                    if (kanbanCard.leankor__ResourceAssignments__r != null && kanbanCard.leankor__ResourceAssignments__r.size() > 0) {
                        remoteKanban.AssignToId = kanbanCard.leankor__ResourceAssignments__r[0].leankor__AssignedTo__c;
                        remoteKanban.percentCompleted = kanbanCard.leankor__ResourceAssignments__r[0].leankor__PercentCompleted__c;   
                        remoteKanban.percentAllocation = kanbanCard.leankor__ResourceAssignments__r[0].leankor__PercentAllocation__c; 
                    }
                    
                    // 24.01.2017 - yj if card boardtype is uberboard then card recordtype name is assigning in itemtype
                    // else card boardtype is not uberboard then item type is kanbanCard.
                    if (kanbanCard.leankor__valuestream__r.leankor__boardtype__c == 'UberBoard') {
                        remoteKanban.timeToProjectLaunch = String.isNotBlank(String.valueOf(kanbanCard.leankor__TimeToProjectLaunch__c)) 
                            ? String.valueOf(kanbanCard.leankor__TimeToProjectLaunch__c.intValue()) 
                            : '';
                        remoteKanban.ItemType = kanbanCard.Recordtype.Name;
                        remotekanban.leaf = remoteKanban.ItemType == 'MilestoneCard' || remoteKanban.ItemType == 'ActivityCard';
                    } else {
                        remoteKanban.ItemType = kanbanCard.Recordtype.name == 'MileStoneCard' ? 'MileStoneCard' : 'KC';
                    }
                    
                    remoteKanban.SWeek = kanbanCard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c;
                    remoteKanban.ForceID = kanbanCard.Id;               
                    remoteKanban.IsExternallyDependent = kanbanCard.leankor__IsExternallyDependent__c;
                    remoteKanban.isTaskDueCheck = kanbanCard.leankor__ValueStream__r.leankor__TaskDateCheck__c;
                    remoteKanban.Account = String.isEmpty(kanbanCard.leankor__Account__c) ? '' : kanbanCard.leankor__Account__c;          
                    remoteKanban.CaseID = String.isEmpty(kanbanCard.leankor__Case__c) ? '' : kanbanCard.leankor__Case__c;
                    remoteKanban.Contact = String.isEmpty(kanbanCard.leankor__Contact__c) ? '' : kanbanCard.leankor__Contact__c;
                    remoteKanban.Opportunity = String.isEmpty(kanbanCard.leankor__Opportunity__c) ? '' : kanbanCard.leankor__Opportunity__c;
                    remoteKanban.OpportunityStage = String.isEmpty(kanbanCard.leankor__Opportunity__c) ? '' : kanbanCard.leankor__Opportunity__r.StageName;
                    remoteKanban.State = kanbanCard.leankor__State__c;
                    remoteKanban.ZoneTitle = String.isEmpty(kanbanCard.leankor__Zone__c) ? '': kanbanCard.leankor__Zone__r.leankor__Title__c;
                    remoteKanban.ProjectID = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
                    remoteKanban.ValueStreamID = kanbanCard.leankor__ValueStream__c;
                    remoteKanban.ParentProjectRoomID = kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c;
                    remoteKanban.LinkProjectRoomID = kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? '' : kanbanCard.leankor__ValueStreamLink__r.leankor__ProjectRoom__c;
                    remoteKanban.TaskComments = kanbanCard.Tasks.size();
            
                    //Add FSL Data info to activity instance
                    remoteKanban.workOrderCount = fslDataInfo.containsKey(kanbanCard.Id) ? fslDataInfo.get(kanbanCard.Id).workOrderCount : 0;
                    remoteKanban.serviceAppointmentCount = fslDataInfo.containsKey(kanbanCard.Id) ? fslDataInfo.get(kanbanCard.Id).serviceAppointmentCount != null ? fslDataInfo.get(kanbanCard.Id).serviceAppointmentCount : null : 0;
                    remoteKanban.fslSchedStartDateTime = fslDataInfo.containsKey(kanbanCard.Id) ? (fslDataInfo.get(kanbanCard.Id).fslSchedStartDateTime != null ? fslDataInfo.get(kanbanCard.Id).fslSchedStartDateTime : null ) : null;
                    remoteKanban.fslSchedDueDateTime = fslDataInfo.containsKey(kanbanCard.Id) ? (fslDataInfo.get(kanbanCard.Id).fslSchedDueDateTime != null ? fslDataInfo.get(kanbanCard.Id).fslSchedDueDateTime : null ) : null;
            
                    //These fields are handled on PDG, in case of UpdateCardRecords() method, they pass sobject Field
                    remoteKanban.HarveyBallDoneDate = kanbanCard.leankor__HarveyBallDoneDate__c;
                    remoteKanban.PromiseCompletionDate = kanbanCard.leankor__PromiseCompletionDate__c;
                    
                    //Date : 01/05/19  use for miniature percent.
                    remoteKanban.isDueDatePercentComplete = GanttTaskBoard.hasSeventyPercentDueDate(kanbanCard, mapWorkWeeks.get(kanbanCard.leankor__ValueStream__c));
                
                    if (boardVerb == 'AddMiniature' && remoteKanban.BoardType == 'UberBoard') {
                        remoteKanban.miniature = mapMiniatures.get(kanbanCard.Id);
                    }
                     //Pratiksha 01/Dec/2023 : Changes added for showing weekCalendar data on MyWork if user change the date form MyWork.
                    if(kanbanCard.leankor__valueStream__r.leankor__SevenDayWorkWeek__c){
                        remoteKanban.Monday = kanbanCard.leankor__Monday__c;
                        remoteKanban.Tuesday = kanbanCard.leankor__Tuesday__c;
                        remoteKanban.Wednesday = kanbanCard.leankor__Wednesday__c;
                        remoteKanban.Thursday = kanbanCard.leankor__Thursday__c;
                        remoteKanban.Friday = kanbanCard.leankor__Friday__c;
                        remoteKanban.Saturday = kanbanCard.leankor__Saturday__c;
                        remoteKanban.Sunday = kanbanCard.leankor__Sunday__c;
                        remoteKanban.weekCalendar = String.isEmpty(kanbanCard.leankor__WeekCalendar__c) ? '' : kanbanCard.leankor__WeekCalendar__c;
                    }
                    remoteKanbanCard.add(remoteKanban); 
            }
        }

        return remoteKanbanCard;
    }
   
    
    // Inner model class TaskData that will prepare data for task on LeankorJS app.
    global class TaskData {
        global String Id;
        global String Priority;
        global String OwnerId;
        global String OwnerName;
        global String Subject;
        global String Status;
        global String ActivityDate;
        global String WhatId;
        global String Description;
        global String LinkedCardVerb;
        global String ValueStream;
        global DateTime StartDate;
        global DateTime DueDate;
        global String CreatedDate;
        global String ItemType;
        global String ValueStreamID;
        global String ValueStreamName;
        global String ProjectRoomName;
        global String ProjectRoomID;
        global String SmallPhotoUrl;
        global String KanbanCardName;
        global Boolean expanded;
        global Boolean leaf;
        global String verb;
        global boolean flowWithGS;
        global Integer TaskChatterCount;
    }


    /***
     * Given a Task Records, returns key stats
     * INPUT: List of TaskData(array objects of TaskData )
     * OUTPUT: List of TaskData(array objects of TaskData )
     */
    global class Valuestreamrecords {
        global string ValueStreamName;
        global string ProjectRoomName;
        global string ProjectRoomID;
    }


    @RemoteAction
    global static List<TaskData> insertTask(List<TaskData> taskData) {
        //Check CRUD / FLC behavior		
        TaskBehaviour taskBehaviour = new TaskBehaviour();

        if (!taskBehaviour.isAccessible() 
        || !taskBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<TaskData> subTasks = new List<TaskData>();        
        List<String> cardId = new List<String>();
        List<String> valueStreamIds = new List<String>();
        Map<String, leankor__KanbanCard__c> mapCardValueStreams;
        Map<String, Valuestreamrecords> mapValueStreams = new Map<String, Valuestreamrecords>();
        List<Task> taskList = new List<Task>();

        Boolean isVisibleFieldAvailable = new DescribeSchema().isFieldExistInSobject('Task' , 'IsVisibleInSelfService');

        for (TaskData task : taskData) {
            if ((String.isNotBlank(task.WhatId) && Util.getSObjectName(task.WhatId) != 'leankor__KanbanCard__c')
            || (String.isNotBlank(task.ValueStreamID) && Util.getSObjectName(task.ValueStreamID) != 'leankor__ValueStream__c')) {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

            cardId.add(task.WhatId);
            valueStreamIds.add(task.ValueStreamID);

            Task newTask = new Task();
            newTask.Priority = task.Priority;
            newTask.OwnerID = task.OwnerID;
            newTask.Subject = task.Subject.unescapeHtml3();
            newTask.Status = task.Status;
            newTask.ActivityDate = Date.valueOf(task.ActivityDate);
            newTask.WhatId = task.WhatId;
            newTask.Description = task.Description.unescapeHtml3();

            if (isVisibleFieldAvailable) {
                newTask.put('IsVisibleInSelfService', true);
            }
                            
            taskList.add(newTask);
        }
    
        mapCardValueStreams = new Map<String, leankor__KanbanCard__c>([Select Id, 
                                                                                Name, 
                                                                                leankor__ValueStream__r.Name,
                                                                                leankor__ProjectRoom__c,
                                                                                leankor__TemplateBoard__c,
                                                                                leankor__MasterContainer__r.leankor__Type__c,
                                                                                leankor__ValueStream__r.leankor__BoardType__c,
                                                                                leankor__ValueStream__c 
                                                                            From leankor__kanbanCard__c 
                                                                            Where Id In :cardId]);      
                    
        List<leankor__ValueStream__c> valueStreams = [Select Id,
                                                                Name, 
                                                                leankor__ProjectRoom__c, 
                                                                leankor__ProjectRoom__r.Name 
                                                            From leankor__ValueStream__c 
                                                            Where Id In :valueStreamIds];
                    
        for (leankor__ValueStream__c valueStream : valueStreams) {
            Valuestreamrecords valueStreamRecord = new Valuestreamrecords();
            
            valueStreamRecord.ValueStreamName = valueStream.Name;
            valueStreamRecord.ProjectRoomName = valueStream.leankor__ProjectRoom__r.name;
            valueStreamRecord.ProjectRoomID = valueStream.leankor__ProjectRoom__c;
            mapValueStreams.put(valueStream.ID, valueStreamRecord);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            insert taskList;
            
            // moved code below to minimize loops
            /*
            List<FeedItem> feeds = new List<FeedItem>();
            for (Task task : taskList) {
                FeedItem post = new FeedItem();
                post.ParentID = task.Id;
                post.Type = 'CreateRecordEvent';
                feeds.add(post);
            }
            */

            Map<String, String> ownerMap = new Map<String, String>();        
            for (Task taskOwner : leankor.OpenTaskRestriction.readTask(taskList)) {
                ownerMap.put(taskOwner.OwnerID, taskOwner.Owner.Name);
            }

            //whenever we add task in kanban then card message will post in chatter of card.-------
            String baseUrl = 'https://' + DomainCreator.getOrgMyDomainHostname();
            String networkId = Network.getNetworkId();
            if (networkId != null) {
                baseUrl = leankor.OpenFeedItemRestriction.getNetworkUrl(networkId, baseUrl);
            }
            
            // Create the user map
            Map<Id, User> mapUsers = new Map<Id, User>([Select Id, 
                                                                UserType 
                                                            From User 
                                                            Where Id In :ownerMap.keySet() 
                                                            Limit 50000]);
            
            // Create the network member map.
            Map<Id, Id> mapNetworkMembers = new Map<Id, Id>();

            // Checking if the NetworkMember available in the org or not.
            // If the communities are deactivated in the org then this object are unavailable.
            Boolean isNetworkAvailable =  Type.forName('Schema.NetworkMember') != null;
            if (isNetworkAvailable) {
                List<Id> userIds = new List<Id>(mapUsers.keyset());
                leankor.OpenFeedItemRestriction.readNetworkMember(userIds, mapNetworkMembers);
            }

            List<FeedItem> feeds = new List<FeedItem>();
            // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
            Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();

            for (Task task : taskList) {   //task owner and logged in user should not be the same
                // moved code from above
                FeedItem feed = new FeedItem();
                feed.ParentID = task.Id;
                feed.Type = 'CreateRecordEvent';
                feeds.add(feed);
                //

                //August 4 2017 : put template condition for prevent email notification to user for template borad
                if (task.OwnerID != USER_ID_CONST && mapCardValueStreams.get(task.WhatId).leankor__TemplateBoard__c == LEANFALSE && mapCardValueStreams.get(task.WhatId).leankor__MasterContainer__r.leankor__Type__c != 'Template') {
                    FeedItem post = new FeedItem();
                    if(assigneeIds.contains(task.OwnerID)) {
                        post.ParentID = task.OwnerID;                              
                        post.Title = task.Subject;

                        // For standard user we don't need to provide NetworkScope in the FeedItem object.
                        if (isNetworkAvailable && mapUsers.containsKey(task.OwnerId) && mapUsers.get(task.OwnerID).UserType != 'Standard') {                            
                            post.put('NetworkScope', mapNetworkMembers.get(task.OwnerId));  
                        }                                                   

                        //For chatter post visibility for all users from community  
                        if (String.isNotBlank(networkId)) {
                            post.put('Visibility', 'AllUsers');
                        }               

                        if (mapCardValueStreams.get(task.WhatId).leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board' || mapCardValueStreams.get(task.WhatId).leankor__ValueStream__r.leankor__BoardType__c == 'Plan Board') {
                            post.LinkUrl = baseUrl + '/apex/leankor__KanbanBoard?id=' +  mapCardValueStreams.get(task.WhatId).leankor__Valuestream__c + '&cardid=' + task.WhatID;
                        } else if (mapCardValueStreams.get(task.WhatId).leankor__ValueStream__r.leankor__BoardType__c == 'Whiteboard') {
                            post.LinkUrl = baseUrl + '/apex/VisualKanban?id=' +  mapCardValueStreams.get(task.WhatId).leankor__Valuestream__c + '&cardid=' + task.WhatID;
                        } else if (mapCardValueStreams.get(task.WhatId).leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
                            post.LinkUrl = baseUrl + '/apex/PortfolioView?id=' +  mapCardValueStreams.get(task.WhatId).leankor__Valuestream__c + '&cardid=' + task.WhatID;
                        }
                        
                    
                  
	                    List<String> customlabelsParam = new List<String>();
	                    customlabelsParam.add(''+USER_NAME_CONST);
	                    customlabelsParam.add(''+(task.Subject != null ? task.Subject : '') );
	                    customlabelsParam.add(''+(getMonth(task.ActivityDate.month())));
	                    customlabelsParam.add(''+(task.ActivityDate.day()));
	                    customlabelsParam.add(''+(task.ActivityDate.year()));
	                    String LabelsWithParameter = String.format(System.Label.leankor.HasMadeYouOwnerOfTask,customlabelsParam);
	                    post.Body = LabelsWithParameter;
	                    //23.08.2017 : provide project name and valuestream name and card name on emil notification
	                    post.Body +=  '\n\n'+mapCardValueStreams.get(task.WhatId).leankor__ProjectRoom__c+' / '+mapCardValueStreams.get(task.WhatId).leankor__ValueStream__r.Name+' / '+mapCardValueStreams.get(task.WhatId).Name;
                        feeds.add(Post);
                    }
                }

                // code moved from below
                TaskData subTask = new TaskData();
                subTask.Id = task.Id;
                subTask.Priority = task.Priority;
                subTask.OwnerID = task.OwnerID;
                subTask.OwnerName = ownerMap.get(task.OwnerID);
                subTask.Subject = task.Subject;
                subTask.Status = task.Status;
                subTask.ActivityDate = String.valueOf(task.ActivityDate);
                subTask.WhatId = task.WhatId;
                subTask.Description = task.Description;
                subTask.ValueStreamID = (mapCardValueStreams.containsKey(task.WhatId) ? mapCardValueStreams.get(task.WhatId).leankor__Valuestream__c : '');

                Valuestreamrecords valueStreamRecords = (mapValueStreams.containsKey(subTask.ValueStreamID) ? mapValueStreams.get(subTask.ValueStreamID) : new Valuestreamrecords());

                subTask.ValueStreamName = (valueStreamRecords.ValueStreamName == null ? '' : valueStreamRecords.ValueStreamName);
                subTask.ProjectRoomName = (valueStreamRecords.ProjectRoomName == null ? '' : valueStreamRecords.ProjectRoomName);
                subTask.ProjectRoomID = (valueStreamRecords.ProjectRoomID == null ? '' : valueStreamRecords.ProjectRoomID);
                subTask.KanbanCardName = (mapCardValueStreams.containsKey(task.WhatId) ? mapCardValueStreams.get(task.WhatId).Name : '');
                subTasks.add(subTask);
                //

            }

            leankor.OpenFeedItemRestriction.createFeedItems(feeds);            
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return subTasks;
    }


    /***
        this will return string name of month
    */
    private static String getMonth(Integer month){
        String monthString;

        if (month == 1) {
            monthString = 'January';        
        } else if (month == 2) {
            monthString = 'February';
        } else if (month == 3) {
            monthString = 'March';
        } else if (month == 4) {
            monthString = 'April';
        } else if (month == 5) {
            monthString = 'May';
        } else if (month == 6) {
            monthString = 'June';
        } else if (month == 7) {
            monthString = 'July';
        } else if (month == 8) {
            monthString = 'August';
        } else if (month == 9) {
            monthString = 'September';
        } else if (month == 10) {
            monthString = 'October';
        } else if (month == 11) {
            monthString = 'November';
        } else if (month == 12) {
            monthString = 'December';
        }

        return monthString;     
    }


    @RemoteAction
    global static List<TaskData> getTasks(String kanbanCardId) {
        List<TaskData> taskData = new List<TaskData>();

        if (String.isBlank(kanbanCardId)) {
            return taskData;
        }

        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        
        // Tilak Raj Mahale:23.04.2020 - Code has been shifted to without sharing class.
        List<Task> taskRecords = leankor.OpenTaskRestriction.readTask(new List<String>{kanbanCardId});     
       
        if (taskRecords.isEmpty()) {
            return taskData;
        }

        Set<String> userId = new Set<String>();
        Map<Id, String> userRecords = new Map<Id, String>();    
        
        try {
            for (Task taskRecord : taskRecords) {
                userId.add(taskRecord.OwnerId);
            }
    
            //Date : 09/05/19 get card data from without sharing.                     
            leankor__KanbanCard__c kanbanRecord = leankor.RealTimeControllerHelper.readTask(kanbanCardId);
                                
            if (kanbanRecord != null && String.isNotBlank(kanbanRecord.Id)) {        
                List<User> users = [Select Id,
                                            SmallPhotoUrl 
                                        From User 
                                        Where Id In :userId 
                                        Limit 50000];
        
                for (User user : users) {
                    userRecords.put(user.Id, user.SmallPhotoUrl);
                }

                Map<Id, Integer> mapFeeds = leankor.KanbanController.getTaskChatterCounts(taskRecords);
    
                for (Task taskRecord: taskRecords) {
                    Integer taskChatterCount = mapFeeds.get(taskRecord.Id);
                    TaskData task = new TaskData();

                    task.Id = taskRecord.Id;
                    task.OwnerName = taskRecord.Owner.name;
                    task.SmallPhotoUrl = userRecords.get(taskRecord.OwnerID);
                    task.Priority = taskRecord.Priority;
                    task.OwnerID = taskRecord.OwnerID;
                    task.Subject = taskRecord.Subject;
                    task.Status = taskRecord.Status;
                    task.ActivityDate = String.ValueOf(taskRecord.ActivityDate);
                    task.WhatId = taskRecord.WhatID;
                    task.Description = taskRecord.Description;
                    task.ValueStreamID = kanbanRecord.leankor__Valuestream__c;
                    task.ValueStreamName = kanbanRecord.leankor__Valuestream__r.Name;
                    task.ProjectRoomName = kanbanRecord.leankor__Valuestream__r.leankor__ProjectRoom__r.Name;
                    task.ProjectRoomID = kanbanRecord.leankor__Valuestream__r.leankor__ProjectRoom__c;
                    task.KanbanCardName = kanbanRecord.Name;
                    task.CreatedDate = JSON.Serialize(taskRecord.CreatedDate);
                    task.TaskChatterCount = taskChatterCount == null ? 0 : taskChatterCount;

                    taskData.add(task);
                }
            }
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            taskData = new List<TaskData>();
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
                        
        return taskData;
    }


    //DCO 1/30/2018 AuraEnabledMethod to update task
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static String updateTaskLightning(String stringTskData) {
        String returnString;

        try {
            TaskData taskData = (TaskData)JSON.deserialize(stringTskData, TaskData.class);
            returnString = JSON.serialize(updateTask(taskData));
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            returnString = 'Error: ' + e.getMessage();
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return returnString;
    }
    
    
    /***
     * Given Update Task records on kanban card
     * INPUT: object of Task Data
     * OUTPUT:  of object(TaskData) contains all Fields.
     */
    @RemoteAction
    global static TaskData updateTask(TaskData taskData) {
        if ((String.isNotBlank(taskData.WhatId) && Util.getSObjectName(taskData.WhatId) != 'leankor__KanbanCard__c')|| (String.isNotBlank(taskData.OwnerId) && Util.getSObjectName(taskData.OwnerId) != 'User')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior(); 

        if (!subscriberBehavior.isAccessible() 
        || !subscriberBehavior.isUpdateable() 
        || !subscriberBehavior.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<Task> taskList = leankor.OpenTaskRestriction.readTask(taskData.Id);
        // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
        Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();
        Task taskInstance = new Task();

        if (taskList.size() > 0) {
        	taskInstance = taskList[0];
        } else {
	        throw new Util.LeanException('You do not have the necessary level of access. Please contact the owner of the record or your administrator if access is necessary');	
        }
        
        List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                            Name, 
                                                            leankor__ValueStream__r.Name,
                                                            leankor__ProjectRoom__c,
                                                            leankor__TemplateBoard__c,
                                                            leankor__MasterContainer__r.leankor__Type__c,
                                                            leankor__ValueStream__c, 
                                                            leankor__ValueStream__r.leankor__BoardType__c, 
                                                            leankor__UrlLink__c 
                                                        From leankor__KanbanCard__c 
                                                        Where Id = :taskData.WhatId 
                                                        Limit 1];

        if (kanbanCards.isEmpty()) {
	        throw new Util.LeanException('You do not have the necessary level of access. Please contact the owner of the record or your administrator if access is necessary');	
        }

        String oldOwnerId = taskInstance.OwnerID;
        String newOwnerName =  [Select Name 
                                    From User 
                                    Where Id = :taskData.OwnerId].Name;

        taskInstance.OwnerID = taskData.OwnerId;
        taskInstance.Priority = taskData.Priority;
        taskInstance.Subject = taskData.Subject;
        taskInstance.Status = taskData.Status;
        taskInstance.ActivityDate = Date.valueOf(taskData.ActivityDate);
        taskInstance.WhatId = taskData.WhatID;
        taskInstance.Description = taskData.Description;

        //Note: Salesforce does not allow the creation of a FeedItem record that has the type of 'TrackedChange'
        /*
        FeedItem feedItem = new FeedItem();
        feedItem.ParentID = taskInstance.Id;
        feedItem.Type = 'TrackedChange';
        */

        // Date : 13/05/19 to get valueStream from without sharing.
        leankor__Valuestream__c valueStreamRecord = RealTimeControllerHelper.readTaskValueStream(kanbanCards[0].leankor__ValueStream__c);

        List<leankor__Subscriber__c> taskSubscribers = [Select Id, 
                                                                Name, 
                                                                leankor__KanbanCard__c, 
                                                                leankor__SubscriberID__c, 
                                                                leankor__Moved__c, 
                                                                leankor__PercentDone__c, 
                                                                leankor__CardPastDueDate__c, 
                                                                leankor__TaskPastDueDate__c, 
                                                                leankor__isTaskCompleted__c, 
                                                                OwnerId 
                                                            From leankor__Subscriber__c 
                                                            Where leankor__KanbanCard__c = :kanbanCards[0].Id 
                                                            Limit 50000];

        leankor__Subscriber__c subscriber;
        
        //---------------checking isTaskCompleted for chatter.------------------
        //Checking subscribers record for card.
        if (taskSubscribers.size() > 0 && taskInstance.OwnerID != taskData.OwnerId) {
            List<leankor__Preference__c> taskPreferences = [Select Id, 
                                                                    leankor__CardPastDueDate__c, 
                                                                    leankor__DerivedFrom__c, 
                                                                    leankor__FollowOnChatter__c, 
                                                                    leankor__GUID__c, 
                                                                    leankor__Moved__c, 
                                                                    leankor__PercentDone__c, 
                                                                    leankor__SubscribeToCard__c, 
                                                                    leankor__TaskPastDueDate__c, 
                                                                    leankor__isTaskCompleted__c, 
                                                                    leankor__ValueStream__c, 
                                                                    Name, 
                                                                    OwnerId 
                                                                From leankor__Preference__c 
                                                                Where leankor__ValueStream__c = :kanbanCards[0].leankor__ValueStream__c 
                                                                    And OwnerId = :kanbanCards[0].OwnerID 
                                                                Limit 1];
            
            //Checking preference created or not.
            if (taskPreferences.size() > 0) {
                //if created than updated subscriber for card.
                subscriber = new leankor__Subscriber__c(
                    Name = kanbanCards[0].Id,
                    leankor__KanbanCard__c = kanbanCards[0].Id,
                    leankor__SubscriberID__c = taskSubscribers[0].OwnerID,
                    leankor__SubscriberKey__c = kanbanCards[0].Id + '-' + taskSubscribers[0].OwnerID,
                    leankor__isTaskCompleted__c = (taskPreferences[0].leankor__isTaskCompleted__c ? taskPreferences[0].leankor__isTaskCompleted__c : false),
                    leankor__TaskPastDueDate__c = taskPreferences[0].leankor__TaskPastDueDate__c
                );

            } else {
                //if not have preference setting than subscribed using default values because of new card owner.
                subscriber = new leankor__Subscriber__c(
                    Name = kanbanCards[0].Id,
                    leankor__KanbanCard__c = kanbanCards[0].Id,
                    leankor__SubscriberID__c = taskSubscribers[0].OwnerID,
                    leankor__SubscriberKey__c = kanbanCards[0].Id + '-' + taskSubscribers[0].OwnerID,
                    leankor__isTaskCompleted__c = true,
                    leankor__TaskPastDueDate__c = true
                );
            }
        }

        // if isTaskCompleted values gets change and set values is 'Completed' then subscriber will send chatter message.
        String baseUrl = 'https://' + DomainCreator.getOrgMyDomainHostname();

        String networkId = Network.getNetworkId();
        if (networkId != null) {
        	baseUrl = leankor.OpenFeedItemRestriction.getNetworkUrl(networkId, baseUrl);
        }

        List<FeedItem> taskFeeds = new List<FeedItem>();
        TaskData sTask = new TaskData();

        sTask.Id = taskInstance.Id;
        sTask.Priority = taskInstance.Priority;
        sTask.OwnerID = taskInstance.OwnerID;
        sTask.OwnerName = newOwnerName;
        sTask.Subject = taskInstance.Subject;
        sTask.Status = taskInstance.Status;
        sTask.ActivityDate = String.valueOf(taskInstance.ActivityDate);
        sTask.WhatID = taskInstance.WhatID;
        sTask.Description = taskInstance.Description;
        sTask.ValueStreamID = kanbanCards[0].leankor__ValueStream__c == null ? '' : kanbanCards[0].leankor__ValueStream__c;
        sTask.ValueStreamName = kanbanCards[0].leankor__ValueStream__c == null ? '' : valueStreamRecord.Name;
        sTask.ProjectRoomName = kanbanCards[0].leankor__ValueStream__c == null ? '' : valueStreamRecord.leankor__projectroom__r.Name;
        sTask.ProjectRoomID = kanbanCards[0].leankor__ValueStream__c == null ? '' : valueStreamRecord.leankor__ProjectRoom__c;
        sTask.KanbanCardName = taskData.whatID == null ? '' : kanbanCards[0].Name;
        
        if (sTask.Status == 'Completed') {            
            //checking flag if any subcriber isTaskCompleted__c = true then task completed chatter will post
            Boolean checkIsTaskCompleted = false;
            Integer taskSubscribersSize = taskSubscribers.size();

            for (leankor__Subscriber__c taskSubscriber : taskSubscribers) {
                if (((taskSubscriber.leankor__SubscriberId__c != USER_ID_CONST) 
                || (taskSubscriber.leankor__SubscriberId__c == USER_ID_CONST && taskSubscribersSize == 1))
                && taskSubscriber.leankor__isTaskCompleted__c) {
                    checkIsTaskCompleted = true;
                    break;
                }
            }
            
            if (checkIsTaskCompleted) {
                //shifted to outside of loop to prevent multiple chatter for single update
                FeedItem post = new FeedItem();
                post.ParentID = sTask.WhatID;                                                           
                post.Title = sTask.Subject;                                         
                
                if (kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board' || kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Plan Board') {
                    post.LinkUrl = baseUrl + '/apex/leankor__KanbanBoard?id=' + kanbanCards[0].leankor__ValueStream__C + '&cardid=' + sTask.WhatID;
                } else if (kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Whiteboard') {
                    post.LinkUrl = baseUrl + '/apex/leankor__VisualKanban?id=' + kanbanCards[0].leankor__ValueStream__C + '&cardid=' + sTask.WhatID;
                } else if (kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
                    post.LinkUrl = baseUrl + '/apex/leankor__PortfolioView?id=' + kanbanCards[0].leankor__ValueStream__C + '&cardid=' + sTask.WhatID;
                }
                
              
                post.Body = System.Label.leankor.TheTask+' '+ sTask.Subject + ''+System.Label.leankor.IsNowCompleted;
                //For chatter post visibility for all users from community  
                
                if(String.isNotBlank(networkId)){
                    post.put('Visibility','AllUsers');
                }

                //23.08.2017 : provide project name and valuestream name and card name on email notification
                post.Body +=  '\n\n'+kanbanCards[0].leankor__ProjectRoom__c+' / '+kanbanCards[0].leankor__ValueStream__r.Name+' / '+kanbanCards[0].Name;
                
                taskFeeds.add(post);
            }
        }

        // Tilak Raj Mahale:27.04.2020 - In case of external user we have to provide NetworkScope in feedItem object.
        // Create the user map
        Map<Id, User> mapUsers = new Map<Id, User>([Select Id, 
                                                            UserType 
                                                        From User 
                                                        Where Id = :taskInstance.OwnerId 
                                                        Limit 50000]);
        
        // Create the network member map.
        Map<Id, Id> mapNetworkMembers = new Map<Id, Id>();

		// Checking if the NetworkMember available in the org or not.
        // If the communities are deactivated in the org then this object are unavailable.
		Boolean isNetworkAvailable = Type.forName('Schema.NetworkMember') != null;
        if (isNetworkAvailable) {
        	List<Id> userIds = new List<Id>(mapUsers.keySet());
        	leankor.OpenFeedItemRestriction.readNetworkMember(userIds, mapNetworkMembers);
        }

        //we update owner of task so notification will be post changed owner chatter home tab
        //August 4 2017 : put template condition for prevent email notification to user for template borad
        if (oldOwnerId != taskData.OwnerId && kanbanCards[0].leankor__TemplateBoard__c == LEANFALSE && kanbanCards[0].leankor__MasterContainer__r.leankor__Type__c != 'Template' ) {
            FeedItem post = new FeedItem();
            if(assigneeIds.contains(taskData.OwnerId)) {
                post.ParentID = taskData.OwnerId;                                        
                post.Title = taskData.Subject;

                if (isNetworkAvailable && mapUsers.containsKey(taskData.OwnerId) && mapUsers.get(taskData.OwnerId).UserType != 'Standard') {                            
                    post.put('NetworkScope', mapNetworkMembers.get(taskData.OwnerId));
                }

                //For chatter post visibility for all users from community  
                if (String.isNotBlank(networkId)) {
                    post.put('Visibility','AllUsers');
                }
                                                                    
                if (kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board' || kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Plan Board') {
                    post.LinkUrl = baseUrl + '/apex/leankor__KanbanBoard?id=' + kanbanCards[0].leankor__ValueStream__c + '&cardid=' + taskData.WhatID;
                } else if (kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Whiteboard') {
                    post.LinkUrl = baseUrl + '/apex/leankor__VisualKanban?id=' + kanbanCards[0].leankor__ValueStream__c + '&cardid=' + taskData.WhatID;
                } else if (kanbanCards[0].leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
                    post.LinkUrl = baseUrl + '/apex/leankor__PortfolioView?id=' + kanbanCards[0].leankor__ValueStream__c + '&cardid=' + taskData.WhatID;
                }
                
            
          
                List<String> customlabelsParam = new List<String>();
                    customlabelsParam.add(''+USER_NAME_CONST);
                    customlabelsParam.add(''+( sTask.Subject != null ? sTask.Subject : '' ) );
                    customlabelsParam.add(''+(getMonth(taskInstance.ActivityDate.month())));
                    customlabelsParam.add(''+(taskInstance.ActivityDate.day()));
                    customlabelsParam.add(''+(taskInstance.ActivityDate.year()));
                    String LabelsWithParameter = String.format(System.Label.leankor.HasMadeYouOwnerOfTask,customlabelsParam);
                    post.Body = LabelsWithParameter;
                //23.08.2017 : provide project name and valuestream name and card name on emil notification
                post.Body += '\n\n'+ kanbanCards[0].leankor__ProjectRoom__c+' / '+kanbanCards[0].leankor__ValueStream__r.Name+' / '+kanbanCards[0].Name;
            
                taskFeeds.add(Post);  
            }                              
        }

        Savepoint sp = Database.setSavepoint();
        try {        
            if (taskInstance != null) {
                List<Task> tasks = new List<Task>();
                tasks.add(taskInstance);
                leankor.OpenTaskRestriction.updateTask(tasks);
            }

            //Note: Salesforce does not allow the creation of a FeedItem record that has the type of 'TrackedChange'
            /*
            if (feedItem != null) {
                insert feedItem;
            }
            */

            if (subscriber != null) {
                upsert subscriber;
            }

            if (taskFeeds.size() > 0) {
                leankor.OpenFeedItemRestriction.createFeedItems(taskFeeds);
            }
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException(e.getmessage());
        }

        return sTask;
    }


    global class ReportRecords {
        global String Id;
        global String DeveloperName;
        global String Description;
        global String Format;
        global String Name;
        global String OwnerID;
        global boolean RestButton;
    }


    /***
     * Given Array of Reports records
     * INPUT: Void
     * OUTPUT:  Array of object(Report) contains all Fields with report formate , chats.
    */
    @RemoteAction
    global static List<ReportRecords> getReports() {
        List<ReportRecords> reportRecords = new List<ReportRecords>();
        
        List<Folder> folders = [Select Id 
                                    From Folder 
                                    Where DeveloperName = 'LeanReports' 
                                    Limit 1];

        if (folders.isEmpty()) {
            System.debug('No access to Folder');
            return reportRecords;
        }

        List<Profile> profiles = [Select PermissionsEditReadonlyFields 
                                        From Profile 
                                        Where Id = :UserInfo.getProfileId()
                                        Limit 1];

        if (profiles.isEmpty()) {
            System.debug('No access to Profile');
            return reportRecords;
        }

        List<Report> reportLogs = [Select Id, 
                                            DeveloperName, 
                                            Description, 
                                            Format, 
                                            Name, 
                                            OwnerID 
                                        From Report 
                                        Where OwnerID = :folders[0].Id 
                                        Limit 50000];

        for (Report reportLog : reportLogs) {
            ReportRecords reportRecord = new ReportRecords();
            
            reportRecord.Id = reportLog.Id;
            reportRecord.DeveloperName = reportLog.DeveloperName;
            reportRecord.Description = reportLog.Description;
            reportRecord.Format = reportLog.Format;
            reportRecord.Name = reportLog.Name;
            reportRecord.OwnerID = reportLog.OwnerID;
            reportRecord.RestButton = false;
            
            if (profiles[0].PermissionsEditReadonlyFields) {
                Reports.ReportDescribeResult reportDescribeResult = Reports.ReportManager.describeReport(reportLog.ID);
                Reports.ReportTypeMetadata reportTypeMetadata = reportDescribeResult.getReportTypeMetadata();
                List<Reports.ReportTypeColumnCategory> reportTypeColumnCategories = reportTypeMetadata.getCategories();
                
                for (Reports.ReportTypeColumnCategory reportTypeColumnCategory : reportTypeColumnCategories) {
                    if (reportTypeColumnCategory.getLabel() == 'ValueStreamStatistics') {
                        reportRecord.RestButton = true;
                        break;
                    }
                }
            }

            reportRecords.add(reportRecord);
        }

        return reportRecords;
    }


    // Inner class for Chart.
    global class Chart {
        global String Id;
        global String ForceID;
        global String Name;
        global String DeveloperName;
        global String ReportId;
        global String Filter;
        global String Format;
        global String GUID;
        global Integer Height;
        global Integer Left;
        global Boolean LockState;
        global Integer Top;
        global String ValueStreamID;
		//06/06/2022 : Width was not updating on UI, issue related to Case sensitive
        global Integer Width;
        global Integer X;
        global Integer Y;
        global String CmpID;
        global String Size;
        global String ChartURL;
        global String JSONData;
        global Boolean OnlyShowChart;
    }


    /***
     * This method is use to create chart Records (Bulky method)
     * INPUT: Array of Sobject (Chart) with field data.
     * OUTPUT: return ID if inserted without error return null if inertion failes.
    */
    @RemoteAction
    global static String insertChart(List<Chart> remoteCharts) {
        //Check CRUD / FLC behavior		
        ChartBehaviour chartBehaviour = new ChartBehaviour();

        if (!chartBehaviour.isAccessible() 
        || !chartBehaviour.isUpdateable() 
        || !chartBehaviour.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String returnVal = '';
        List<leankor__Chart__c> newCharts = new List<leankor__Chart__c>();

        for (Chart chart : remoteCharts) {
            if (String.isNotBlank(chart.ValueStreamID) && Util.getSObjectName(chart.ValueStreamID) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

            leankor__Chart__c newChart = new leankor__Chart__c();

            newChart.Name = chart.Name;
            newChart.leankor__DeveloperName__c = chart.DeveloperName;
            newChart.leankor__Filter__c = chart.Filter;
            newChart.leankor__Format__c = chart.Format;
            newChart.leankor__GUID__c = chart.GUID;
            newChart.leankor__Height__c = chart.Height;
            newChart.leankor__Left__c = chart.Left;
            newChart.leankor__LockState__c = chart.LockState;
            newChart.leankor__ReportId__c = chart.ReportID;
            newChart.leankor__Top__c = chart.Top;
            newChart.leankor__ValueStream__c = (chart.ValueStreamID == '' ? null : chart.ValueStreamID);
            newChart.leankor__width__c = chart.width;
            newChart.leankor__X__c = chart.X;
            newChart.leankor__Y__c = chart.Y;
            newChart.leankor__CmpID__c = chart.CmpID;
            newChart.leankor__Size__c = chart.Size;
            newChart.leankor__ChartURL__c = chart.ChartURL;
            newChart.leankor__JSONData__c = chart.JSONData;
            newChart.leankor__OnlyShowChart__c = chart.OnlyShowChart;

            newCharts.add(newChart);
        }

        if (remoteCharts.size() > 0) {
            try {
                Schema.Sobjectfield externField = leankor__Chart__c.Fields.leankor__GUID__c;
                Database.upsert(newCharts, externField, true);
                returnVal = newCharts[0].Id;
            } catch (DmlException e) {
               System.debug(e.getMessage());
               returnVal = '';
               throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }


    /***
     * This method is use to get chart Records
     * INPUT: Valuestream ID.
     * OUTPUT: return Array of Charts Object filterd by Valuestream IDs.
    */
    @RemoteAction
    global static List<leankor__Chart__c> getAllCharts(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select Id, 
                        Name, 
                        leankor__CmpID__c, 
                        leankor__OnlyShowChart__c, 
                        leankor__JSONData__c, 
                        leankor__Size__c, 
                        leankor__DeveloperName__c, 
                        leankor__Filter__c, 
                        leankor__Format__c, 
                        leankor__GUID__c, 
                        leankor__Height__c, 
                        leankor__Left__c, 
                        leankor__LockState__c, 
                        leankor__ReportID__c, 
                        leankor__Top__c, 
                        leankor__ValueStream__c, 
                        leankor__width__c, 
                        leankor__X__c, 
                        leankor__Y__c 
                    From leankor__Chart__c 
                    Where leankor__ValueStream__c = :valueStreamId 
                    Limit 50000];
    }


    /***
     * Remote web service for Remove Chart
     * INPUT: String Chart Id
     * OUTPUT: Boolean value
    */
    @RemoteAction
    global static Boolean removeChart(String chartId) {
        if (String.isNotBlank(chartId) && Util.getSObjectName(chartId) != 'leankor__Chart__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        ChartBehaviour chartBehaviour = new ChartBehaviour();

        if (!chartBehaviour.isAccessible() 
        || !chartBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Boolean returnVal = false;

        List<leankor__Chart__c> charts = [Select Id, 
                                                    leankor__ValueStream__c 
                                                From leankor__Chart__c 
                                                Where Id = :chartId 
                                                Limit 1];

        if (!charts.isEmpty()) {
            for(leankor__Chart__c chart : charts){
                chart.leankor__ValueStream__c = null;
            }
            try {
                update charts;
                returnVal = true;
            } catch (Exception e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }


    /***
     * Remote web service for Remove Task(Builky)
     * INPUT: Array Of Task IDs, with What Id(KanbanCard ID)
     * OUTPUT: Boolean value
    */
    @RemoteAction
    global static String DeletebulkTask(List<String> kanbanCardIds) {
        for (String kanbanCardId : kanbanCardIds) {
            if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        /*if (!Task.sObjectType.getDescribe().isDeletable()) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }*/

        String returnVal = '';

        List<Task> tasks = [Select Id 
                                From Task 
                                Where WhatId In :kanbanCardIds 
                                    And IsDeleted = false 
                                Limit 10000 
                                All Rows];

        if (tasks.size() > 0) {
            try {
                leankor.OpenTaskRestriction.deleteTask(tasks);
                returnVal = 'Success';
            } catch (DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }


    /***
     * Remote web service for Remove Task(Builky)
     * INPUT: Array Of Task IDs, with What Id(KanbanCard ID)
     * OUTPUT: Boolean value
     */
    @RemoteAction
    global static String removeTask(String[] taskIds, String kanbanCardId) {
        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        String returnVal = '';

        try {
            leankor.OpenTaskRestriction.deleteTask(leankor.OpenTaskRestriction.readTask(taskIds, kanbanCardId));
            returnVal = 'Success';
        } catch (DmlException e) {               
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return returnVal;
    }


    //Inner class for Kanban Template.
    global class KanbanTemplate {
        global String Id;
        global String Name;
        global String Title;
        global String Color;
        global String CSSLayout;
        global Integer Height;
        global Integer width;
        global String DerivedFrom;
        global String JSONData;
        global String JSONDefinition;
        global String ValueStream;
        global String StartDate;
        global String DueDate;
        global Boolean EntireRoom;
        global Boolean EntireORG;
        global Boolean EntireBoard;
        global String RoomID;
        global List<leankor.KanbanToGanttController.MasterContainer> children;
        global Boolean expanded;
        global String FieldSetName;
        global String weekCalendar;
    }

    @AuraEnabled
    public static List<leankor__KanbanCardTemplate__c> createKanbanCardTemplateRecord(List<KanbanCardTemplateRequest> kanbanTemplateData) {
        System.debug(kanbanTemplateData);
        // List to hold inner class instances
        List<KanbanTemplate> kanbanTemplates = new List<KanbanTemplate>();
        
        // Populate inner class instances from top-level class
        for (KanbanCardTemplateRequest  template : kanbanTemplateData) {
            KanbanTemplate kanbanTemplate = new KanbanTemplate();
            kanbanTemplate.name = template.name;
            kanbanTemplate.Title = template.title;
            kanbanTemplate.Color = template.color;
            kanbanTemplate.CSSLayout = template.cssLayout;
            kanbanTemplate.Height = template.height;
            kanbanTemplate.width = template.width;
            kanbanTemplate.ValueStream = template.valueStream;
            kanbanTemplate.RoomID = template.roomID;
            kanbanTemplate.EntireRoom = template.entireRoom;
            kanbanTemplate.EntireORG = template.entireORG;
            kanbanTemplate.FieldSetName = template.fieldSetName;
            kanbanTemplate.weekCalendar = template.weekCalendar;

            kanbanTemplates.add(kanbanTemplate);
        }

        // Call the existing method with the inner class list
        system.debug(kanbanTemplates);
        return createKanbanCardTemplate(kanbanTemplates);
    }


    /***
     * Remote web service for Remove Task(Builky)
     * INPUT: Array Of Task IDs, with What Id(KanbanCard ID)
     * OUTPUT: Boolean value
    */
    @RemoteAction
    global static List<leankor__KanbanCardTemplate__c> createKanbanCardTemplate(List<KanbanTemplate> kanbanTemplates) {
        for (KanbanTemplate kanbanTemplate : kanbanTemplates) {
            if ((String.isNotBlank(kanbanTemplate.ValueStream) && Util.getSObjectName(kanbanTemplate.ValueStream) != 'leankor__ValueStream__c')
            || (String.isNotBlank(kanbanTemplate.RoomID) && Util.getSObjectName(kanbanTemplate.RoomID) != 'leankor__ProjectRoom__c')) {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        //Check CRUD / FLC behavior		
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();

        if (!kanbanCardTemplateBehaviour.isAccessible() 
        || !kanbanCardTemplateBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__KanbanCardTemplate__c> newTemplates = new List<leankor__KanbanCardTemplate__c>();
        leankor__KanbanCardTemplate__c roomGlobalTemplate = new leankor__KanbanCardTemplate__c();
        leankor__KanbanCardTemplate__c parentGlobalTemplate = new leankor__KanbanCardTemplate__c();

        kanbanTemplates[0].EntireRoom = (kanbanTemplates[0].EntireRoom == null ? false : kanbanTemplates[0].EntireRoom);
        kanbanTemplates[0].EntireORG = (kanbanTemplates[0].EntireORG == null ? false : kanbanTemplates[0].EntireORG);

        Savepoint sp = Database.setSavepoint();
       // try {        
            if (kanbanTemplates[0].EntireRoom || kanbanTemplates[0].EntireORG) {
                    parentGlobalTemplate.Name = kanbanTemplates[0].Name;
                    parentGlobalTemplate.leankor__Title__c = kanbanTemplates[0].Title;
                    parentGlobalTemplate.leankor__Color__c = kanbanTemplates[0].Color;
                    parentGlobalTemplate.leankor__CSSLayout__c = kanbanTemplates[0].CSSLayout;
                    parentGlobalTemplate.leankor__Height__c = kanbanTemplates[0].Height;
                    parentGlobalTemplate.leankor__width__c = kanbanTemplates[0].width;
                    //parentGlobalTemplate.leankor__JSONData__c = kanbanTemplates[0].JSONData;
                    //parentGlobalTemplate.leankor__JSONDefinition__c = kanbanTemplates[0].JSONDefinition;
                    parentGlobalTemplate.leankor__ProjectRoom__c = (kanbanTemplates[0].EntireORG == true ? null : kanbanTemplates[0].RoomID);
                    parentGlobalTemplate.leankor__FieldSetName__c = kanbanTemplates[0].FieldSetName;
                 	parentGlobalTemplate.leankor__WeekCalendar__c = kanbanTemplates[0].weekCalendar;

                    insert parentGlobalTemplate;

                    if (!kanbanTemplates[0].EntireORG) {
                        roomGlobalTemplate.Name = kanbanTemplates[0].Name;
                        roomGlobalTemplate.leankor__Title__c = kanbanTemplates[0].Title;
                        roomGlobalTemplate.leankor__Color__c = kanbanTemplates[0].Color;
                        roomGlobalTemplate.leankor__CSSLayout__c = kanbanTemplates[0].CSSLayout;
                        roomGlobalTemplate.leankor__Height__c = kanbanTemplates[0].Height;
                        roomGlobalTemplate.leankor__width__c = kanbanTemplates[0].width;
                        //roomGlobalTemplate.leankor__JSONData__c = kanbanTemplates[0].JSONData;
                        //roomGlobalTemplate.leankor__JSONDefinition__c = kanbanTemplates[0].JSONDefinition;
                        roomGlobalTemplate.leankor__ProjectRoom__c = kanbanTemplates[0].RoomID;
                        roomGlobalTemplate.leankor__DerivedFrom__c = parentGlobalTemplate.ID;
                        roomGlobalTemplate.leankor__FieldSetName__c = kanbanTemplates[0].FieldSetName;
						roomGlobalTemplate.leankor__WeekCalendar__c = kanbanTemplates[0].weekCalendar;
                        insert roomGlobalTemplate;
                    }
            }

            for (KanbanTemplate kanbanTemplate : kanbanTemplates) {
                leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c(
                    Name = kanbanTemplate.Name,
                    leankor__Title__c = kanbanTemplate.Title,
                    leankor__Color__c = kanbanTemplate.Color,
                    leankor__CSSLayout__c = kanbanTemplate.CSSLayout,
                    leankor__Height__c = kanbanTemplate.Height,
                    leankor__width__c = kanbanTemplate.width,
                    //leankor__JSONData__c = kanbanTemplate.JSONData,
                    //leankor__JSONDefinition__c = kanbanTemplate.JSONDefinition,
                    leankor__ValueStream__c = kanbanTemplate.ValueStream == '' ? null : kanbanTemplate.ValueStream,
                    leankor__DerivedFrom__c = roomGlobalTemplate.Id == null ? parentGlobalTemplate.Id : roomGlobalTemplate.Id,
                    leankor__FieldSetName__c = kanbanTemplate.FieldSetName,
                    leankor__WeekCalendar__c = kanbanTemplate.weekCalendar
                );   

                newTemplates.add(template);
            }
            System.debug(newTemplates);

            if (newTemplates.size() > 0) {
                insert newTemplates;
            }


            
            // when we got Request to Created Global Level Catagory So at That time we are checking  is any same name Project or  Board Type catagory was available in Database
            if(kanbanTemplates[0].EntireORG){
                List<leankor__KanbanCardTemplate__c>listOfCatagory = [Select Id,
                                                                                Name,
                                                                                leankor__ValueStream__c,
                                                                                leankor__DerivedFrom__c,
                                                                                leankor__ProjectRoom__c 
                                                                                From leankor__KanbanCardTemplate__c 
                                                                                Where Name =:kanbanTemplates[0].Name
                                                                                And leankor__DerivedFrom__c!=: parentGlobalTemplate.Id
                                                                                //Id!=:parentGlobalTemplate.Id
                                                                                And IsDeleted = false];

                List<leankor__KanbanCardTemplate__c>updatedCatagoryRecords = new List<leankor__KanbanCardTemplate__c>();
                List<leankor__KanbanCardTemplate__c>removeCatagoryRecords = new List<leankor__KanbanCardTemplate__c>();
                
                for(leankor__KanbanCardTemplate__c catagoryRecords:listOfCatagory){
                    //If same Name Project level catagory is available so we associated with Global Catagory
                    if(catagoryRecords.leankor__DerivedFrom__c!=Null && catagoryRecords.leankor__ProjectRoom__c==Null && catagoryRecords.leankor__ValueStream__c!=Null ){
                        catagoryRecords.leankor__DerivedFrom__c = parentGlobalTemplate.id;
                        updatedCatagoryRecords.add(catagoryRecords);
                    }
                    //If Same name Board Level Catagory is available so we associated with Global Catagory
                    if(catagoryRecords.leankor__DerivedFrom__c == Null && catagoryRecords.leankor__ProjectRoom__c==Null && catagoryRecords.leankor__ValueStream__c!=Null){
                        catagoryRecords.leankor__DerivedFrom__c = parentGlobalTemplate.id;
                        updatedCatagoryRecords.add(catagoryRecords);
                    }

                    //We are Deleting the other Project Level Catagory Records.(When we Created Prject Level Catagory at that time total 3 was created in same name we are deleting 2 Records Below)
                    if(catagoryRecords.leankor__DerivedFrom__c == Null && catagoryRecords.leankor__ProjectRoom__c!=Null && catagoryRecords.leankor__ValueStream__c==Null){
                        removeCatagoryRecords.add(catagoryRecords);
                    }
                    if(catagoryRecords.leankor__DerivedFrom__c!= Null && catagoryRecords.leankor__ProjectRoom__c!=Null && catagoryRecords.leankor__ValueStream__c==Null){
                        removeCatagoryRecords.add(catagoryRecords);
                    }

                }
                if(updatedCatagoryRecords.size()>0){
                    update updatedCatagoryRecords;
                }
                if(removeCatagoryRecords.size()>0){
                    delete removeCatagoryRecords;
                }   
            }
            
            
            // when we got Request to Created Project Level  Catagory So at That time we are checking  is any same name  Board Type catagory was available in Database in Same Project
            if(kanbanTemplates[0].EntireRoom){
                List<leankor__KanbanCardTemplate__c>listOfCatagory = [Select Id,
                                                                                Name,
                                                                                leankor__ValueStream__c,
                                                                                leankor__DerivedFrom__c,
                                                                                leankor__ProjectRoom__c 
                                                                                From leankor__KanbanCardTemplate__c 
                                                                                Where Name =:kanbanTemplates[0].Name
                                                                                And Leankor__ValueStream__r.Leankor__ProjectRoom__c =: kanbanTemplates[0].RoomID
                                                                                And leankor__DerivedFrom__c = Null
                                                                                And leankor__ValueStream__c != Null
                                                                                And IsDeleted = false];

                List<leankor__KanbanCardTemplate__c>updatedListCatagoryRecords = new List<leankor__KanbanCardTemplate__c>();      
                for(leankor__KanbanCardTemplate__c catagoryRecords:listOfCatagory){
                    catagoryRecords.leankor__DerivedFrom__c= roomGlobalTemplate.id;
                    updatedListCatagoryRecords.add(catagoryRecords);
                }
                if(updatedListCatagoryRecords.size()>0){
                    update updatedListCatagoryRecords;
                }    
            }
        /*} catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }*/
System.debug(newTemplates);
        return newTemplates;
    }

    
    @RemoteAction
    global static List<KanbanChatterStats> getTaskChatterStats(List<Id> kanbanArray) {
        // for (Id kanbanId : kanbanArray) {
        //     if (Util.getSObjectName(kanbanId) != 'leankor__ValueStream__c') { 
        //         System.debug('Error: Invalid input');
        //         throw new Util.LeanException('Error: Invalid input');
        //     }
        // }

        List<KanbanChatterStats> kanbanChatterStats = new List<KanbanChatterStats>();  
        Map<Id, KanbanChatterStats> kanbanCardChatterStats = new Map<Id, KanbanChatterStats>();
        Map<Id, Set<Id>> kanbanCardTaskIds = new Map<Id, Set<Id>>();
        Set<Id> kanbanCardIds = new Set<Id>();

        kanbanCardIds.addAll(kanbanArray);

        AggregateResult[] agTaskFeeds = [Select Count(Id) FeedCount,
                                                Type,
                                                Parent.WhatId
                                            From TaskFeed
                                            Where Parent.WhatId In :kanbanArray
                                            Group By Type,
                                                Parent.WhatId
                                            Limit 50000];

        for (AggregateResult agTaskFeed : agTaskFeeds) {
            Id parentWhatId = (Id)agTaskFeed.get('Parent.WhatId');
            setKanbanCardChatter(kanbanCardChatterStats, (Integer)agTaskFeed.get('FeedCount'), (String)agTaskFeed.get('Type'), parentWhatId, kanbanCardIds);
        }

        for (Id key : kanbanCardChatterStats.keySet()) {
            kanbanChatterStats.add(kanbanCardChatterStats.get(key));
        }

        return kanbanChatterStats;
    }


    /***
     * Given List of Permission sets of user
     * INPUT: User ID
     * OUTPUT: array Of Object PermissionSetAssignment
    */
    @RemoteAction
    global static List<PermissionSetAssignment> getUserPermissionSet(String userId) {
        if (String.isNotBlank(userId) && Util.getSObjectName(userId) != 'User') { 
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select AssigneeID, 
                        Id, 
                        PermissionSetID, 
                        PermissionSet.Name 
                    From PermissionSetAssignment 
                    Where AssigneeID = :userId 
                    Limit 50000];
    }


    /***
     * This method is use to update KanbanCard Template
     * INPUT: Object of KambanTemplate with new update records(records will update on GUID Field)
     * OUTPUT: Return object of leankor__KanbanCardTemplate__c with update record.
    */
    global static leankor__KanbanCardTemplate__c updatelocalKanbanCardTemplate(KanbanTemplate kanbanTemplate) {
        if (String.isNotBlank(kanbanTemplate.Id) && Util.getSObjectName(kanbanTemplate.Id) != 'leankor__KanbanCardTemplate__c'
        || (String.isNotBlank(kanbanTemplate.ValueStream) && Util.getSObjectName(kanbanTemplate.ValueStream) != 'leankor__ValueStream__c')) { 
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();

        if (!kanbanCardTemplateBehaviour.isAccessible() 
        || !kanbanCardTemplateBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__KanbanCardTemplate__c returnVal = new leankor__KanbanCardTemplate__c();

        List<leankor__KanbanCardTemplate__c> kanbanCardTemplates = [Select Id, 
                                                                            Name, 
                                                                            leankor__AssetID__c, 
                                                                            leankor__CSSLayout__c, 
                                                                            leankor__Color__c, 
                                                                            leankor__Height__c, 
                                                                            //leankor__JSONData__c, 
                                                                            //leankor__JSONDefinition__c, 
                                                                            leankor__Title__c, 
                                                                            leankor__Width__c,
                                                                            leankor__ValueStream__c,
                                                                            leankor__DerivedFrom__c, 
                                                                            leankor__DerivedFrom__r.leankor__ProjectRoom__c,
                                                                            leankor__FieldSetName__c,
                                                                    		leankor__WeekCalendar__c
                                                                        From leankor__KanbanCardTemplate__c 
                                                                        Where Id = :kanbanTemplate.Id 
                                                                            And leankor__ValueStream__c = :kanbanTemplate.ValueStream 
                                                                        Limit 1];

        if (kanbanCardTemplates.size() > 0) {
            kanbanCardTemplates[0].Name = kanbanTemplate.Name;
            kanbanCardTemplates[0].leankor__Title__c = kanbanTemplate.Title;
            kanbanCardTemplates[0].leankor__Color__c = kanbanTemplate.Color;
            kanbanCardTemplates[0].leankor__CSSLayout__c = kanbanTemplate.CSSLayout;
            kanbanCardTemplates[0].leankor__Height__c = kanbanTemplate.Height;
            kanbanCardTemplates[0].leankor__Width__c = kanbanTemplate.Width;
            //kanbanCardTemplates[0].leankor__JSONData__c = kanbanTemplate.JSONData;
            //kanbanCardTemplates[0].leankor__JSONDefinition__c = kanbanTemplate.JSONDefinition;
            kanbanCardTemplates[0].leankor__ValueStream__c = (kanbanTemplate.ValueStream == '' ? null : kanbanTemplate.ValueStream);
            kanbanCardTemplates[0].leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
            kanbanCardTemplates[0].leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
            try {
                update kanbanCardTemplates;                
                returnVal = kanbanCardTemplates[0];
            } catch (DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }

    @AuraEnabled
    public static leankor__KanbanCardTemplate__c updateKanbanTemplateRecord(KanbanCardTemplateRequest templateRequest) {
        System.debug(templateRequest);
        // Validate the incoming request
        if (templateRequest != null) {
            // Create an instance of KanbanTemplate from the KanbanCardTemplateRequest
            KanbanTemplate kanbanTemplate = new KanbanTemplate();
            kanbanTemplate.Id = templateRequest.Id;
            kanbanTemplate.Name = templateRequest.Name;
            kanbanTemplate.Title = templateRequest.Title;
            kanbanTemplate.Color = templateRequest.Color;
            kanbanTemplate.CSSLayout = templateRequest.CSSLayout;
            kanbanTemplate.Height = templateRequest.Height;
            kanbanTemplate.Width = templateRequest.Width; // Fixed spelling to match PascalCase
            kanbanTemplate.DerivedFrom = templateRequest.DerivedFrom;
            kanbanTemplate.JSONData = templateRequest.JSONData;
            kanbanTemplate.JSONDefinition = templateRequest.JSONDefinition;
            kanbanTemplate.ValueStream = templateRequest.ValueStream;
            kanbanTemplate.StartDate = templateRequest.StartDate;
            kanbanTemplate.DueDate = templateRequest.DueDate;
            kanbanTemplate.EntireRoom = templateRequest.EntireRoom;
            kanbanTemplate.EntireORG = templateRequest.EntireORG;
            kanbanTemplate.EntireBoard = templateRequest.EntireBoard;
            kanbanTemplate.RoomID = templateRequest.RoomID;
            kanbanTemplate.Children = templateRequest.Children;
            kanbanTemplate.Expanded = templateRequest.Expanded;
            kanbanTemplate.FieldSetName = templateRequest.FieldSetName;
            kanbanTemplate.WeekCalendar = templateRequest.WeekCalendar;
            // ... map other fields as needed ...
            
            // Call the existing method to update the Kanban card template
            return updateKanbanCardTemplate(kanbanTemplate);
        } else {
            // Handle the case where the templateRequest is null
            throw new AuraHandledException('Invalid template request');
        }
    }


    @RemoteAction
    global static leankor__KanbanCardTemplate__c updateKanbanCardTemplate(KanbanTemplate kanbanTemplate) {        
        if ((String.isNotBlank(kanbanTemplate.Id) && Util.getSObjectName(kanbanTemplate.Id) != 'leankor__KanbanCardTemplate__c')
        || (String.isNotBlank(kanbanTemplate.ValueStream) && Util.getSObjectName(kanbanTemplate.ValueStream) != 'leankor__ValueStream__c')
        || (String.isNotBlank(kanbanTemplate.RoomID) && Util.getSObjectName(kanbanTemplate.RoomID) != 'leankor__ProjectRoom__c') 
        || (String.isNotBlank(kanbanTemplate.DerivedFrom) && Util.getSObjectName(kanbanTemplate.DerivedFrom) != 'leankor__KanbanCardTemplate__c')) { 
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
  		KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
          
        if (!kanbanCardTemplateBehaviour.isAccessible() 
        || !kanbanCardTemplateBehaviour.isUpdateable() 
        || !kanbanCardTemplateBehaviour.isCreateable() 
        || !kanbanCardTemplateBehaviour.isDeletable()) {
            System.debug('Error: No access to create, update or delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__KanbanCardTemplate__c result = new leankor__KanbanCardTemplate__c();
        
        List<leankor__Valuestream__c> valueStreams = [Select Id, 
                                                                leankor__Boardtype__c 
                                                            From leankor__Valuestream__c 
                                                            Where Id = :kanbanTemplate.ValueStream
                                                            Limit 1];
        
        Savepoint sp = Database.setSavepoint();
        try {
            Id parentGlobalTemplateId;
            Id roomGlobalTemplateId;
            Id roomKanbanCardTemplateParentsId;
            if (valueStreams.size() > 0 && valueStreams[0].leankor__Boardtype__c != 'Portfolio View') {   
                if (kanbanTemplate.DerivedFrom == null && (kanbanTemplate.EntireRoom || kanbanTemplate.EntireORG)) {
                    leankor__KanbanCardTemplate__c parentGlobalTemplate = new leankor__KanbanCardTemplate__c(
                        Name = kanbanTemplate.Name,
                        leankor__Title__c = kanbanTemplate.Title,
                        leankor__Color__c = kanbanTemplate.Color,
                        leankor__CSSLayout__c = kanbanTemplate.CSSLayout,
                        leankor__Height__c = kanbanTemplate.Height,
                        leankor__width__c = kanbanTemplate.Width,
                        //leankor__JSONData__c = kanbanTemplate.JSONData,
                        //leankor__JSONDefinition__c = kanbanTemplate.JSONDefinition,
                        leankor__ProjectRoom__c = kanbanTemplate.EntireORG ? null : kanbanTemplate.RoomID,
                        leankor__FieldSetName__c = kanbanTemplate.FieldSetName,
                        leankor__WeekCalendar__c =  String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null
                    );
                    
                    insert parentGlobalTemplate;
                    parentGlobalTemplateId = parentGlobalTemplate.id;

                    leankor__KanbanCardTemplate__c roomGlobalTemplate = new leankor__KanbanCardTemplate__c();

                    if (kanbanTemplate.EntireRoom) {
                        roomGlobalTemplate.Name = kanbanTemplate.Name;
                        roomGlobalTemplate.leankor__Title__c = kanbanTemplate.Title;
                        roomGlobalTemplate.leankor__Color__c = kanbanTemplate.Color;
                        roomGlobalTemplate.leankor__CSSLayout__c = kanbanTemplate.CSSLayout;
                        roomGlobalTemplate.leankor__Height__c = kanbanTemplate.Height;
                        roomGlobalTemplate.leankor__width__c = kanbanTemplate.width;
                        //roomGlobalTemplate.leankor__JSONData__c = kanbanTemplate.JSONData;
                        //roomGlobalTemplate.leankor__JSONDefinition__c = kanbanTemplate.JSONDefinition;
                        roomGlobalTemplate.leankor__ProjectRoom__c = kanbanTemplate.RoomID;
                        roomGlobalTemplate.leankor__DerivedFrom__c = parentGlobalTemplate.ID;
                        roomGlobalTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                        roomGlobalTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;

                        insert roomGlobalTemplate;
                        roomGlobalTemplateId = roomGlobalTemplate.id;
                    }

                    leankor__KanbanCardTemplate__c kanbanCardTemplate = new leankor__KanbanCardTemplate__c(
                        Id = kanbanTemplate.Id,
                        Name = kanbanTemplate.Name,
                        leankor__Title__c = kanbanTemplate.Title,
                        leankor__Color__c = kanbanTemplate.Color,
                        leankor__CSSLayout__c = kanbanTemplate.CSSLayout,
                        leankor__Height__c = kanbanTemplate.Height,
                        leankor__width__c = kanbanTemplate.width,
                        //leankor__JSONData__c = kanbanTemplate.JSONData,
                        //leankor__JSONDefinition__c = kanbanTemplate.JSONDefinition,
                        leankor__ValueStream__c = kanbanTemplate.ValueStream == '' ? null : kanbanTemplate.ValueStream,
                        leankor__DerivedFrom__c = roomGlobalTemplate.Id == null ? parentGlobalTemplate.Id : roomGlobalTemplate.Id,
                        leankor__FieldSetName__c = kanbanTemplate.FieldSetName,
                        leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null
                    );

                    update kanbanCardTemplate;
 
                    result = readKanbanCardTemplate(kanbanTemplate.Id);
                    
                } else {

                    Boolean isCurrentKanbanCardTemplateUpdate = false;

                    List<leankor__KanbanCardTemplate__c> parentKanbanCardTemplates = [Select Id, 
                                                                                                leankor__Title__c, 
                                                                                                leankor__ProjectRoom__c, 
                                                                                                leankor__DerivedFrom__c 
                                                                                            From leankor__KanbanCardTemplate__c 
                                                                                            Where Id = :kanbanTemplate.DerivedFrom
                                                                                            Limit 1];
					//28/09/2021 : Changes for fixing the category issue.
                   //  if (parentKanbanCardTemplates.size() > 0) {
                        if (kanbanTemplate.EntireRoom && parentKanbanCardTemplates[0].leankor__ProjectRoom__c != kanbanTemplate.RoomID) {
                            leankor__KanbanCardTemplate__c kanbanCardTemplate = new leankor__KanbanCardTemplate__c(
                                Name = kanbanTemplate.Name,
                                leankor__Title__c = kanbanTemplate.Title,
                                leankor__Color__c = kanbanTemplate.Color,
                                leankor__CSSLayout__c = kanbanTemplate.CSSLayout,
                                leankor__Height__c = kanbanTemplate.Height,
                                leankor__width__c = kanbanTemplate.width,
                                //leankor__JSONData__c = kanbanTemplate.JSONData,
                                //leankor__JSONDefinition__c = kanbanTemplate.JSONDefinition,
                                leankor__ValueStream__c = null,
                                leankor__projectRoom__C = kanbanTemplate.RoomID,
                                leankor__DerivedFrom__c = kanbanTemplate.DerivedFrom,
                                leankor__FieldSetName__c = kanbanTemplate.FieldSetName,
                                leankor__WeekCalendar__c =String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null
                            );
                            
                            insert kanbanCardTemplate;

                            List<leankor__KanbanCardTemplate__c> allKanbanCardTemplates = [Select Id, 
                                                                                                    leankor__Title__c, 
                                                                                                    Name, 
                                                                                                    leankor__DerivedFrom__c, 
                                                                                                    leankor__Color__c, 
                                                                                                    leankor__WeekCalendar__c,
                                                                                                    leankor__Valuestream__r.leankor__projectroom__c 
                                                                                                From leankor__KanbanCardTemplate__c 
                                                                                                Where (leankor__DerivedFrom__c = :kanbanTemplate.DerivedFrom 
                                                                                                    And leankor__Valuestream__r.leankor__Projectroom__c = :kanbanTemplate.RoomID)
                                                                                                    Or Id = :kanbanTemplate.DerivedFrom 
                                                                                                Limit 10000];
                            
                            for (leankor__KanbanCardTemplate__c allKanbanCardTemplate : allKanbanCardTemplates) {
                                
                                if (allKanbanCardTemplate.Id == kanbanTemplate.DerivedFrom) {
                                    allKanbanCardTemplate.leankor__ProjectRoom__c = kanbanTemplate.RoomID;
                                    allKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                    allKanbanCardTemplate.Name = kanbanTemplate.Name;
                                    allKanbanCardTemplate.leankor__Color__c = kanbanTemplate.Color;
                                    allKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                    allKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                } else if (allKanbanCardTemplate.leankor__Valuestream__r.leankor__ProjectRoom__c == kanbanTemplate.RoomID) {
                                    allKanbanCardTemplate.leankor__DerivedFrom__c = kanbanCardTemplate.ID;
                                    allKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                    allKanbanCardTemplate.Name = kanbanTemplate.Name;
                                    allKanbanCardTemplate.leankor__Color__c = kanbanTemplate.Color;
                                    allKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                    allKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                } else if (allKanbanCardTemplate.leankor__Valuestream__r.leankor__ProjectRoom__c != kanbanTemplate.RoomID) {
                                    allKanbanCardTemplate.leankor__DerivedFrom__c = null;
                                }

                                if (allKanbanCardTemplate.Id == kanbanTemplate.Id) {
                                    allKanbanCardTemplate.Name = kanbanTemplate.Name;
                                    allKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                    allKanbanCardTemplate.leankor__Color__c = kanbanTemplate.Color;
                                    allKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                    allKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                }
                            }

                            if (allKanbanCardTemplates.size() > 0) {
                                update allKanbanCardTemplates;
                            }

                            result = readKanbanCardTemplate(kanbanTemplate.Id);

                        } else if (kanbanTemplate.EntireORG) {
                            if (parentKanbanCardTemplates[0].leankor__DerivedFrom__c != null && parentKanbanCardTemplates[0].leankor__ProjectRoom__c == kanbanTemplate.RoomID) {
                                List<leankor__KanbanCardTemplate__c> roomKanbanCardTemplateParents = [Select Id, 
                                                                                                                leankor__FieldSetName__c, 
                                                                                                                leankor__Title__c, 
                                                                                                                leankor__ProjectRoom__c 
                                                                                                            From leankor__KanbanCardTemplate__c 
                                                                                                            Where Id = :parentKanbanCardTemplates[0].leankor__DerivedFrom__c
                                                                                                            Limit 1];

                                if (roomKanbanCardTemplateParents.size() > 0) {
                                    List<leankor__KanbanCardTemplate__c> updateKanbanCardTemplates = [Select Id,
                                                                                                                leankor__FieldSetName__c, 
                                                                                                                leankor__Title__c, 
                                                                                                                Name, 
                                                                                                                leankor__Color__c, 
                                                                                                                leankor__DerivedFrom__c,
                                                                                                                leankor__WeekCalendar__c
                                                                                                            From leankor__KanbanCardTemplate__c 
                                                                                                            Where leankor__DerivedFrom__r.leankor__DerivedFrom__c = :roomKanbanCardTemplateParents[0].Id];
                                    roomKanbanCardTemplateParentsId = roomKanbanCardTemplateParents[0].id;
                                    for (leankor__KanbanCardTemplate__c updateKanbanCardTemplate : updateKanbanCardTemplates) {
                                        updateKanbanCardTemplate.leankor__DerivedFrom__c = roomKanbanCardTemplateParents[0].Id;
                                        updateKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                        updateKanbanCardTemplate.Name = kanbanTemplate.Name;
                                        updateKanbanCardTemplate.leankor__Color__c = kanbanTemplate.Color;
                                        updateKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                        updateKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                    }

                                    roomKanbanCardTemplateParents[0].leankor__ProjectRoom__c = null;
                                    roomKanbanCardTemplateParents[0].name = kanbanTemplate.Name;
                                    roomKanbanCardTemplateParents[0].leankor__Title__c = kanbanTemplate.Name;
                                    roomKanbanCardTemplateParents[0].leankor__Color__c = kanbanTemplate.Color;
                                    roomKanbanCardTemplateParents[0].leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                    roomKanbanCardTemplateParents[0].leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;

                                    updateKanbanCardTemplates.add(roomKanbanCardTemplateParents[0]);
                                                                    
                                    for (leankor__KanbanCardTemplate__c updateKanbanCardTemplate : updateKanbanCardTemplates) {
                                        if (updateKanbanCardTemplate.ID == kanbanTemplate.ID) {
                                            updateKanbanCardTemplate.Name = kanbanTemplate.Name;
                                            updateKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                            updateKanbanCardTemplate.leankor__Color__c = kanbanTemplate.color;
                                            updateKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                            updateKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                            isCurrentKanbanCardTemplateUpdate = true;
                                        }
                                    }
                                    //28/09/2021 : Changes for fixing the Category issue  
                                    if (updateKanbanCardTemplates.size() > 0) {
                                        update updateKanbanCardTemplates;
                                    }
                                    //Pratiksha - 18/08/2021 :Changes for Avoid the exception.
                                    delete parentKanbanCardTemplates;
								    //Database.delete(parentKanbanCardTemplates,false);


                                    List<leankor__KanbanCardTemplate__c> roomKanbanCardTemplates = [Select Id,
                                                                                                            leankor__ProjectRoom__c    
                                                                                                        From leankor__KanbanCardTemplate__c 
                                                                                                        Where leankor__DerivedFrom__c = :roomKanbanCardTemplateParents[0].Id];
                                    
                                    List<leankor__KanbanCardTemplate__c> deleteRoomKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();
                                    for (leankor__KanbanCardTemplate__c roomKanbanCardTemplate : roomKanbanCardTemplates) {
                                        if (roomKanbanCardTemplate.leankor__ProjectRoom__c != null) {
                                            deleteRoomKanbanCardTemplates.add(roomKanbanCardTemplate);
                                        }
                                    }

                                    if (deleteRoomKanbanCardTemplates.size() > 0) {
                                        delete deleteRoomKanbanCardTemplates;
                                    }
                                }
								
                                result = isCurrentKanbanCardTemplateUpdate ? readKanbanCardTemplate(kanbanTemplate.Id) : updatelocalKanbanCardTemplate(kanbanTemplate);

                            } else {   
                                List<leankor__KanbanCardTemplate__c> roomKanbanCardTemplateParents = [Select Id, 
                                                                                                                leankor__ValueStream__c
                                                                                                            From leankor__KanbanCardTemplate__c 
                                                                                                            Where leankor__DerivedFrom__c = :parentKanbanCardTemplates[0].Id]; 

                                List<leankor__KanbanCardTemplate__c> deleteRoomKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();
                                for (leankor__KanbanCardTemplate__c roomKanbanCardTemplateParent : roomKanbanCardTemplateParents) {
                                    if (roomKanbanCardTemplateParent.leankor__ValueStream__c == null) {
                                        deleteRoomKanbanCardTemplates.add(roomKanbanCardTemplateParent);
                                    }
                                }
                                                                            
                                List<Id> derivedRoomIds = new List<Id>();                                
                                for (leankor__KanbanCardTemplate__c deleteroomKanbanCardTemplate : deleteRoomKanbanCardTemplates) {
                                    derivedRoomIds.add(deleteroomKanbanCardTemplate.Id);
                                }
                                
                                List<leankor__KanbanCardTemplate__c> updateKanbanCardTemplates = [Select Id, 
                                                                                                            leankor__FieldSetName__c,
                                                                                                            leankor__Title__c, 
                                                                                                            Name, 
                                                                                                            leankor__Color__c, 
                                                                                                            leankor__DerivedFrom__c,
                                                                                                            leankor__WeekCalendar__c
                                                                                                        From leankor__KanbanCardTemplate__c 
                                                                                                        Where leankor__DerivedFrom__c In :derivedRoomIds];
                                
                                if (updateKanbanCardTemplates.size() == 0) {
                                    updateKanbanCardTemplates = [Select Id,
                                                                        leankor__FieldSetName__c, 
                                                                        leankor__Title__c, 
                                                                        Name, 
                                                                        leankor__Color__c, 
                                                                        leankor__WeekCalendar__c,
                                                                        leankor__DerivedFrom__c 
                                                                    From leankor__KanbanCardTemplate__c 
                                                                    Where leankor__DerivedFrom__c = :parentKanbanCardTemplates[0].Id];
                                }
                                
                                for (leankor__KanbanCardTemplate__c updateKanbanCardTemplate : updateKanbanCardTemplates) {
                                    updateKanbanCardTemplate.leankor__DerivedFrom__c = parentKanbanCardTemplates[0].Id;
                                    updateKanbanCardTemplate.Name = kanbanTemplate.Name;
                                    updateKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                    updateKanbanCardTemplate.leankor__Color__c = kanbanTemplate.color;
                                    updateKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                    updateKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                }
                                
                                parentKanbanCardTemplates[0].leankor__ProjectRoom__c = null;
                                parentKanbanCardTemplates[0].Name = kanbanTemplate.Name;
                                parentKanbanCardTemplates[0].leankor__Title__c = kanbanTemplate.Name;
                                parentKanbanCardTemplates[0].leankor__Color__c = kanbanTemplate.Color;
                                parentKanbanCardTemplates[0].leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                parentKanbanCardTemplates[0].leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                
                                update parentKanbanCardTemplates;

                                for (leankor__KanbanCardTemplate__c updateKanbanCardTemplate : updateKanbanCardTemplates) {
                                    if (updateKanbanCardTemplate.ID == kanbanTemplate.ID) {
                                        updateKanbanCardTemplate.Name = kanbanTemplate.Name;
                                        updateKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                        updateKanbanCardTemplate.leankor__Color__c = kanbanTemplate.Color;
                                        updateKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                        updateKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                                        isCurrentKanbanCardTemplateUpdate = true;
                                    }
                                }

                                if (updateKanbanCardTemplates.size() > 0) {
                                    update updateKanbanCardTemplates;
                                }
                                
                                if (deleteRoomKanbanCardTemplates.size() > 0) {
                                    delete deleteRoomKanbanCardTemplates;
                                }
                                
                                result = isCurrentKanbanCardTemplateUpdate ? readKanbanCardTemplate(kanbanTemplate.Id) : updatelocalKanbanCardTemplate(kanbanTemplate);
                            }
                        } else if (kanbanTemplate.EntireBoard) {
                            List<leankor__KanbanCardTemplate__c> kanbanCardTemplates = [Select Id, 
                                                                                                leankor__DerivedFrom__c, 
                                                                                                leankor__DerivedFrom__r.leankor__DerivedFrom__c 
                                                                                            From leankor__KanbanCardTemplate__c 
                                                                                            Where Id = :kanbanTemplate.Id];

                            if (kanbanCardTemplates.size() > 0 && kanbanCardTemplates[0].leankor__DerivedFrom__c != null) {
                                List<leankor__KanbanCardTemplate__c> deleteGlobalKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();
                                List<leankor__KanbanCardTemplate__c> globalKanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();

                                if (kanbanCardTemplates[0].leankor__DerivedFrom__r.leankor__DerivedFrom__c != null) {
                                    globalKanbanCardTemplates = [Select Id, 
                                                                        leankor__DerivedFrom__c,
                                                                        leankor__ValueStream__c 
                                                                    From leankor__KanbanCardTemplate__c 
                                                                    Where leankor__DerivedFrom__c = :kanbanCardTemplates[0].leankor__DerivedFrom__r.leankor__DerivedFrom__c 
                                                                        Or Id = :kanbanCardTemplates[0].leankor__DerivedFrom__c
                                                                    Limit 10000];
                                } else {
                                    globalKanbanCardTemplates = [Select Id, 
                                                                        leankor__DerivedFrom__c,
                                                                        leankor__ValueStream__c 
                                                                    From leankor__KanbanCardTemplate__c 
                                                                    Where Id = :kanbanCardTemplates[0].leankor__DerivedFrom__c 
                                                                    Limit 10000];
                                }

                                for (leankor__KanbanCardTemplate__c globalKanbanCardTemplate : globalKanbanCardTemplates) {
                                    if (globalKanbanCardTemplate.leankor__ValueStream__c == null) {
                                        deleteGlobalKanbanCardTemplates.add(globalKanbanCardTemplate);
                                    }
                                }                            

                                if (kanbanCardTemplates[0].leankor__DerivedFrom__r.leankor__DerivedFrom__c != null) {
                                    List<leankor__KanbanCardTemplate__c> otherParentKanbanCardTemplates = [Select Id, 
                                                                                                                    leankor__DerivedFrom__c 
                                                                                                                From leankor__KanbanCardTemplate__c 
                                                                                                                Where Id = :kanbanCardTemplates[0].leankor__DerivedFrom__r.leankor__DerivedFrom__c 
                                                                                                                Limit 10000];
                                    deleteGlobalKanbanCardTemplates.addall(otherParentKanbanCardTemplates);
                                }

                                if (deleteGlobalKanbanCardTemplates.size() > 0) {
                                    delete deleteGlobalKanbanCardTemplates;
                                }
                            }

                            result = updatelocalKanbanCardTemplate(kanbanTemplate);

                        } else if (kanbanTemplate.EntireRoom && parentKanbanCardTemplates[0].leankor__ProjectRoom__c == kanbanTemplate.RoomID) {
                            List<leankor__KanbanCardTemplate__c> derivedKanbanCardTemplates = [Select Id,
                                                                                                        leankor__FieldSetName__c, 
                                                                                                        leankor__Title__c, 
                                                                                                        Name, 
                                                                                                        leankor__Color__c, 
                                                                                                        leankor__DerivedFrom__c,
                                                                                                        leankor__WeekCalendar__c
                                                                                                    From leankor__KanbanCardTemplate__c 
                                                                                                    Where leankor__DerivedFrom__c = :kanbanTemplate.DerivedFrom 
                                                                                                        Or Id = :parentKanbanCardTemplates[0].leankor__DerivedFrom__c];
                            
                            for (leankor__KanbanCardTemplate__c derivedKanbanCardTemplate : derivedKanbanCardTemplates) {
                                derivedKanbanCardTemplate.Name = kanbanTemplate.Name;
                                derivedKanbanCardTemplate.leankor__Title__c = kanbanTemplate.Name;
                                derivedKanbanCardTemplate.leankor__Color__c = kanbanTemplate.Color;
                                derivedKanbanCardTemplate.leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                                derivedKanbanCardTemplate.leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;
                            }

                            parentKanbanCardTemplates[0].Name = kanbanTemplate.Name;
                            parentKanbanCardTemplates[0].leankor__Title__c = kanbanTemplate.Name;
                            parentKanbanCardTemplates[0].leankor__Color__c = kanbanTemplate.Color;
                            parentKanbanCardTemplates[0].leankor__FieldSetName__c = kanbanTemplate.FieldSetName;
                            parentKanbanCardTemplates[0].leankor__WeekCalendar__c = String.isNotBlank(kanbanTemplate.weekCalendar) ? kanbanTemplate.weekCalendar : null;

                            update parentKanbanCardTemplates;

                            if (derivedKanbanCardTemplates.size() > 0) {
                                update derivedKanbanCardTemplates;
                            }
                            
                            result = readKanbanCardTemplate(kanbanTemplate.Id);

                        } else {
                            result = updatelocalKanbanCardTemplate(kanbanTemplate);
                        }
                  //  }
                }
            } else {
                result = updatelocalKanbanCardTemplate(kanbanTemplate);
            }

            // when we got Request to Created Global Level Catagory So at That time we are checking  is any same name Project or Board Type catagory was available in Database
            // IF same name Board and Project Level Catagory was available so we associated with Global Catagory
            if(kanbanTemplate.EntireORG && (parentGlobalTemplateId!=null || roomKanbanCardTemplateParentsId !=null)){
                List<leankor__KanbanCardTemplate__c>listOfCatagory = [Select Id,
                                                                                Name,
                                                                                leankor__ValueStream__c,
                                                                                leankor__DerivedFrom__c,
                                                                                leankor__ProjectRoom__c 
                                                                            From leankor__KanbanCardTemplate__c 
                                                                            Where Name =:kanbanTemplate.Name
                                                                            And leankor__DerivedFrom__c!=: parentGlobalTemplateId!=null ? parentGlobalTemplateId : roomKanbanCardTemplateParentsId
                                                                            And Id!=: parentGlobalTemplateId!=null ? parentGlobalTemplateId : roomKanbanCardTemplateParentsId
                                                                            And IsDeleted = false];
                List<leankor__KanbanCardTemplate__c>updatedCatagoryRecords = new List<leankor__KanbanCardTemplate__c>();
                List<leankor__KanbanCardTemplate__c>removeCatagoryRecords = new List<leankor__KanbanCardTemplate__c>();
                if(listOfCatagory.size()>0){
                    for(leankor__KanbanCardTemplate__c catagoryRecords:listOfCatagory){
                        //If same Name Project level catagory is available so we associated with Global Catagory
                        if(catagoryRecords.leankor__DerivedFrom__c!=Null && catagoryRecords.leankor__ProjectRoom__c==Null && catagoryRecords.leankor__ValueStream__c!=Null ){
                            catagoryRecords.leankor__DerivedFrom__c = parentGlobalTemplateId!= null ? parentGlobalTemplateId : roomKanbanCardTemplateParentsId;
                            updatedCatagoryRecords.add(catagoryRecords);
                        }

                        //If Same name Board Level Catagory is available so we associated with Global Catagory
                        if(catagoryRecords.leankor__DerivedFrom__c == Null && catagoryRecords.leankor__ProjectRoom__c==Null && catagoryRecords.leankor__ValueStream__c!=Null){                         
                            catagoryRecords.leankor__DerivedFrom__c = parentGlobalTemplateId!= null ? parentGlobalTemplateId : roomKanbanCardTemplateParentsId;
                            updatedCatagoryRecords.add(catagoryRecords);
                        }

                        //We are Deleting the other Project Level Catagory Records.(When we Created Prject Level Catagory at that time total 3 was created in same name we are deleting 2 Records Below)
                        if(catagoryRecords.leankor__DerivedFrom__c == Null && catagoryRecords.leankor__ProjectRoom__c!=Null && catagoryRecords.leankor__ValueStream__c==Null){
                            removeCatagoryRecords.add(catagoryRecords);
                        }
                        if(catagoryRecords.leankor__DerivedFrom__c!= Null && catagoryRecords.leankor__ProjectRoom__c!=Null && catagoryRecords.leankor__ValueStream__c==Null){
                            removeCatagoryRecords.add(catagoryRecords);
                        }

                    }
                    if(updatedCatagoryRecords.size()>0){
                        update updatedCatagoryRecords;
                    }
                    if(removeCatagoryRecords.size()>0){
                        delete removeCatagoryRecords;
                    }
                }   
            }

            // if we are Converting  Board type Catagory to Project type Catagory, at that time if same name other Board type Catagory was Paresnt in Project so it will associate to Project Type Catagory
             if(kanbanTemplate.EntireRoom && roomGlobalTemplateId!=null){
                List<leankor__KanbanCardTemplate__c>listOfCatagory = [Select Id,
                                                                                Name,
                                                                                leankor__ValueStream__c,
                                                                                leankor__DerivedFrom__c,
                                                                                leankor__ProjectRoom__c 
                                                                            From leankor__KanbanCardTemplate__c 
                                                                            Where Name =:kanbanTemplate.Name
                                                                            And Leankor__ValueStream__r.Leankor__ProjectRoom__c =: kanbanTemplate.RoomID
                                                                            And leankor__DerivedFrom__c = Null
                                                                            And leankor__ValueStream__c != Null
                                                                            And IsDeleted = false];

               List<leankor__KanbanCardTemplate__c>updatedListCatagoryRecords = new List<leankor__KanbanCardTemplate__c>();
               if(listOfCatagory.size()>0){
                    for(leankor__KanbanCardTemplate__c catagoryRecords:listOfCatagory){
                        catagoryRecords.leankor__DerivedFrom__c= roomGlobalTemplateId;
                            updatedListCatagoryRecords.add(catagoryRecords);
                    }
                    update updatedListCatagoryRecords;
                }
            }
            
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return result;
    }


    // helper method to get KanbanCardTemplate given the record id
    @TestVisible
    private static leankor__KanbanCardTemplate__c readKanbanCardTemplate(Id templateId) {
        return [Select Id, 
                        Name, 
                        leankor__AssetID__c, 
                        leankor__CSSLayout__c, 
                        leankor__Color__c, 
                        leankor__Height__c, 
                        //leankor__JSONData__c, 
                        //leankor__JSONDefinition__c, 
                        leankor__Title__c, 
                        leankor__Width__c, 
                        leankor__DerivedFrom__c, 
                        leankor__DerivedFrom__r.leankor__ProjectRoom__c,
                		leankor__WeekCalendar__c
                    From leankor__KanbanCardTemplate__c 
                    Where Id = :templateId];
    }


    @AuraEnabled
    public static String removeKanbanTemplateRecord(KanbanCardTemplateRequest templateRequest) {
        // Validate the incoming request
        if (templateRequest != null) {
            // Create an instance of KanbanTemplate from the KanbanCardTemplateRequest
            KanbanTemplate kanbanTemplate = new KanbanTemplate();
            kanbanTemplate.Id = templateRequest.Id;
            kanbanTemplate.ValueStream = templateRequest.ValueStream;

            // Call the existing method to remove the Kanban card template
            return removeKanbanCardTemplate(kanbanTemplate);
        } else {
            // Handle the case where the templateRequest is null
            throw new AuraHandledException('Invalid template request');
        }
    }


    /***
     * This Method is use to delete The KanbanCard template
     * INPUT: Object of KambanTemplate with new update records(records will update on GUID Field)
     * OUTPUT: Return 'Success' on delete and return Error if deleting fails.
    */
    @RemoteAction
    global static String removeKanbanCardTemplate(KanbanTemplate kanbanTemplate) {        
        if ((String.isNotBlank(kanbanTemplate.Id) && Util.getSObjectName(kanbanTemplate.Id) != 'leankor__KanbanCardTemplate__c')
        || (String.isNotBlank(kanbanTemplate.ValueStream) && Util.getSObjectName(kanbanTemplate.ValueStream) != 'leankor__ValueStream__c')) { 
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
  		PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
          
        if (!preferenceBehaviour.isAccessible() 
        || !preferenceBehaviour.isUpdateable() 
        || !kanbanCardTemplateBehaviour.isAccessible() 
        || !kanbanCardTemplateBehaviour.isDeletable()) {
            System.debug('Error: No access to update or delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
                
        String returnVal = '';

        List<leankor__KanbanCardTemplate__c> kanbanCardTemplates = [Select Id
                                                                        From leankor__KanbanCardTemplate__c 
                                                                        Where Id = :kanbanTemplate.Id
                                                                            And leankor__ValueStream__c = :kanbanTemplate.ValueStream 
                                                                        Limit 1];

        if (kanbanCardTemplates.size() > 0) {
            List<leankor__Preference__c> preferences = [Select Id, 
                                                                leankor__CardPastDueDate__c, 
                                                                leankor__DerivedFrom__c, 
                                                                leankor__FollowOnChatter__c, 
                                                                leankor__GUID__c, 
                                                                leankor__Moved__c, 
                                                                leankor__PercentDone__c, 
                                                                leankor__SubscribeToCard__c, 
                                                                leankor__TaskPastDueDate__c, 
                                                                leankor__ValueStream__c, 
                                                                Name, 
                                                                OwnerID 
                                                            From leankor__Preference__c 
                                                            Where leankor__ValueStream__c = :kanbanTemplate.ValueStream 
                                                            Limit 10000];

            for (leankor__Preference__c preference : preferences) {
                if ((preference.leankor__SubscribeToCard__c != 'all' || preference.leankor__SubscribeToCard__c != 'none') && preference.leankor__SubscribeToCard__c.contains(kanbanTemplate.Id)) {
                    String tempString = '{"Categories" :' + preference.leankor__SubscribeToCard__c + '}';
                    Preference tempPreference = (Preference)JSON.deserialize(tempString, Preference.class);
                    Integer i = 0, j = -1;
                    
                    for (i = 0; i < tempPreference.Categories.size(); i++) {   
                        if (tempPreference.Categories[i] == kanbanTemplate.Id) {
                            j = i;
                        }
                    }
                
                    if (j == 0 && tempPreference.Categories.size() == 1) {
                        tempPreference.Categories.remove(j);
                        preference.leankor__SubscribeToCard__c = 'none';
                
                    } else if (j >= 0 && tempPreference.Categories.size() > 1) {
                        tempPreference.Categories.remove(j);
                        tempString = '[';
                        
                        for (Integer k = 0; k < tempPreference.Categories.size(); k++) {
                            tempString += (((tempPreference.Categories.size() - 1) == k) ? '"' + tempPreference.Categories[k] + '"]' : '"' + tempPreference.Categories[k] + '"');
                        }

                        preference.leankor__SubscribeToCard__c = tempString;
                    }
                }
                
                if ((preference.leankor__FollowOnChatter__c != 'all' || preference.leankor__FollowOnChatter__c != 'none') && preference.leankor__FollowOnChatter__c.contains(kanbanTemplate.Id)) {
                    String tempString = '{"Categories" :' + preference.leankor__FollowOnChatter__c + '}';
                    Preference tempPreference = (Preference)JSON.deserialize(tempString, Preference.class);
                    Integer i = 0, j = -1;

                    for (i = 0; i < tempPreference.Categories.size(); i++) {
                        if (tempPreference.Categories[i] == kanbanTemplate.Id) {
                            j = i;
                        }
                    }

                    if (j == 0 && tempPreference.Categories.size() == 1) {
                        tempPreference.Categories.remove(j);
                        preference.leankor__FollowOnChatter__c = 'none';
                    } else if (j >= 0 && tempPreference.Categories.size() > 1) {
                        tempPreference.Categories.remove(j);
                        tempString = '[';

                        for (Integer k = 0; k < tempPreference.Categories.size(); k++) {
                            tempString += (((tempPreference.Categories.size() - 1) == k) ? '"' + tempPreference.Categories[k] + '"]' : '"' + tempPreference.Categories[k] + '"');
                        }

                        preference.leankor__FollowOnChatter__c = tempString;
                    }
                }
            }

            Savepoint sp = Database.setSavepoint();
            try {
                delete kanbanCardTemplates;

                if (preferences.size() > 0) {
                    update preferences;
                }

                returnVal = 'Success';
    
            } 
            catch(DmlException e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }            
        }

        return returnVal;
    }


    // This Is Inner Class For Subscriber
    global class Subscriber {
        global String Id;
        global String Name;
        global String KanbanID;
        global String SubscriberID;
        global Boolean KanbanMove;
        global Boolean PercentDone;
        global Boolean isTaskCompleted;
        global Boolean CardPastDueDate;
        global Boolean TaskPastDueDate;
        global Integer Flag;
        global String Preference;
    }
    @AuraEnabled(cacheable=false)
    public static List<leankor__Subscriber__c> retrieveSubscribers(String kanbanCardId) {
        try {
            // Call the existing getSubscribers method
            return getSubscribers(kanbanCardId);
        } catch (Util.LeanException e) {
            // Handle and propagate the exception
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***
     * This Method is use to Get subsriber records on kanban card
     * INPUT: KanbanCard ID
     * OUTPUT: Return Array of subscriber
     */
    @RemoteAction
    global static List<leankor__Subscriber__c> getSubscribers(String kanbanCardId) {
        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select Id, 
                        Name, 
                        OwnerID, 
                        leankor__SubscriberID__c, 
                        leankor__kanbanCard__c, 
                        leankor__Moved__c, 
                        leankor__PercentDone__c, 
                        leankor__CardPastDueDate__c, 
                        leankor__TaskPastDueDate__c, 
                        leankor__Flag__c, 
                        leankor__Preference__c, 
                        leankor__isTaskCompleted__c 
                    From leankor__Subscriber__c 
                    Where leankor__KanbanCard__c = :kanbanCardId 
                    Limit 10000];
    }


    /***
     * This Method is use to delete subsriber records on kanban card
     * INPUT: KanbanCard ID , subscriber record on kanbancrad which to be deleted.
     * OUTPUT: Return 'Success' on delete and return Error if deleting fails.
    */
    
    @RemoteAction
    global static String removeSubscriber(String kanbanCardId, String subscriber) {
        if ((String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c')|| (String.isNotBlank(subscriber) && Util.getSObjectName(subscriber) != 'User')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        return leankor.RealTimeControllerHelper.removeSubscriberHelper(kanbanCardId, subscriber);
    }

    @AuraEnabled
    global static String removeSubscriberAura(String kanbanCardId, String subscriber) {
        if ((String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c')|| (String.isNotBlank(subscriber) && Util.getSObjectName(subscriber) != 'User')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        return leankor.RealTimeControllerHelper.removeSubscriberHelper(kanbanCardId, subscriber);
    }

    @AuraEnabled
    public static leankor__Subscriber__c manageSubscriberWrapper(SubscriberWrapper subscriberWrapper) {
        System.debug('SubscriberWrapper received: ' + subscriberWrapper);
    
        // Check if subscriberWrapper is null
        if (subscriberWrapper == null) {
            throw new Util.LeanException('Error: SubscriberWrapper is null');
        }
    
        Subscriber subscriber = new Subscriber();
        subscriber.KanbanID = subscriberWrapper.KanbanID != null ? subscriberWrapper.KanbanID : '';
        subscriber.SubscriberID = subscriberWrapper.SubscriberID != null ? subscriberWrapper.SubscriberID : '';
        subscriber.KanbanMove = subscriberWrapper.KanbanMove != null ? subscriberWrapper.KanbanMove : false;
        subscriber.PercentDone = subscriberWrapper.PercentDone != null ? subscriberWrapper.PercentDone : false;
        subscriber.isTaskCompleted = subscriberWrapper.isTaskCompleted != null ? subscriberWrapper.isTaskCompleted : false;
        subscriber.CardPastDueDate = subscriberWrapper.CardPastDueDate != null ? subscriberWrapper.CardPastDueDate : false;
        subscriber.TaskPastDueDate = subscriberWrapper.TaskPastDueDate != null ? subscriberWrapper.TaskPastDueDate : false;
        subscriber.Flag = subscriberWrapper.Flag != null ? subscriberWrapper.Flag : 0;
        subscriber.Preference = subscriberWrapper.Preference != null ? subscriberWrapper.Preference : '';
    
        System.debug('Mapped Subscriber object: ' + JSON.serialize(subscriber));
    
        // Call the existing method
        leankor__Subscriber__c result = manageSubscriber(subscriber);
    
        if (result == null) {
            throw new Util.LeanException('Error: manageSubscriber returned null');
        }
    
        return result;
    }
    

    /***
     * This Method is use to update subsriber records on kanban card
     * INPUT:  subscriber update record on kanbancrad which to be deleted.
     * OUTPUT: Return updated record of subsriber.
    */
    @RemoteAction
    global static leankor__Subscriber__c manageSubscriber(Subscriber subscriber) {        
        if ((String.isNotBlank(subscriber.KanbanID) && Util.getSObjectName(subscriber.KanbanID) != 'leankor__KanbanCard__c')
        || (String.isNotBlank(subscriber.Preference) && Util.getSObjectName(subscriber.Preference) != 'leankor__Preference__c')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior();

        if (!subscriberBehavior.isAccessible() 
        || !subscriberBehavior.isCreateable() 
        || !subscriberBehavior.isUpdateable()) {
            System.debug('Error: No access to update or delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__Subscriber__c updateSubscriber = new leankor__Subscriber__c(
            Name = subscriber.KanbanID,
            leankor__KanbanCard__c = subscriber.KanbanID,
            leankor__SubscriberID__c = subscriber.SubscriberID,
            leankor__Moved__c = subscriber.KanbanMove,
            leankor__PercentDone__c = subscriber.PercentDone,
            leankor__isTaskCompleted__c = subscriber.isTaskCompleted ? subscriber.isTaskCompleted : false,
            leankor__CardPastDueDate__c = subscriber.CardPastDueDate,
            leankor__TaskPastDueDate__c = subscriber.TaskPastDueDate,
            leankor__Flag__c = subscriber.Flag,
            leankor__Preference__c = subscriber.Preference == '' ? null : subscriber.Preference,
            leankor__SubscriberKey__c = subscriber.KanbanID + '-' + subscriber.SubscriberID
        );
        
        try {
            Schema.Sobjectfield externField = leankor__Subscriber__c.Fields.leankor__SubscriberKey__c;
            Database.upsert(updateSubscriber, externField, true);
        } catch (DmlException e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return updateSubscriber;
    }


    // This Is Inner Class For ChatterFeed
    global class ChatterFeed {
        global String KanbanID;
        global String KanbanTitle;
        global String KanbanURL;
        global String AssignedUser;
        global String ProjectBoardName; 
    }

    
    /***
     * This Method is use to create Chatter Feed on kanban cards
     * INPUT:  array of chatters , verb for opration of CRUD.
     * OUTPUT: Return updated record of subsriber.
    */
    global static void createChatterFeed(List<ChatterFeed> chatterFeeds, String kanbanVerb) {
        for (ChatterFeed chatterFeed : chatterFeeds) {
            if ((String.isNotBlank(chatterFeed.AssignedUser) && Util.getSObjectName(chatterFeed.AssignedUser) != 'User')
            || (String.isNotBlank(chatterFeed.KanbanID) && Util.getSObjectName(chatterFeed.KanbanID) != 'leankor__KanbanCard__c')) {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        //Check CRUD / FLC behavior	
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();

        if (!entitySubscriptionBehaviour.isAccessible() 
        || !entitySubscriptionBehaviour.isCreateable() 
        || !feedItemBehaviour.isAccessible() 
        || !feedItemBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior        

        List<EntitySubscription> entitySubscriptions = new List<EntitySubscription>();
        List<EntitySubscription> entitySubscriptions2 = new List<EntitySubscription>();
        List<sobject> entitySubscriptionObjects = new List<EntitySubscription>();
        List<FeedItem> posts = new List<FeedItem>();

        if (kanbanVerb == 'CreateKanbanCard') {
            Map<Id, User> mapUsers;            
            Map<Id, Id> mapNetworkMembers = new Map<Id, Id>();
    
            // Checking if the NetworkMember available in the org or not.
            // If the communities are deactivated in the org then this object are unavailable.
            Boolean isNetworkAvailable =  Type.forName('Schema.NetworkMember') != null;
            String networkId = Network.getNetworkId();

            if (isNetworkAvailable) {
                List<Id> userIds = new List<Id>();

                for (ChatterFeed chatterFeed : chatterFeeds) {
                    userIds.add(chatterFeed.AssignedUser);
                }
                
                mapUsers = new Map<Id, User> ([Select Id, 
                                                        UserType 
                                                    From User 
                                                    Where Id In :userIds 
                                                    Limit 50000]);

                leankor.OpenFeedItemRestriction.readNetworkMember(userIds, mapNetworkMembers);
            }
            // Ramanand - 15/05/2023 : Changes to prevent FeedItem record creation if the parent record does not have permissions.
            Set<Id> assigneeIds = RealTimeControllerHelper.getAssigneeIds();
            for (ChatterFeed chatterFeed : chatterFeeds) {
                FeedItem post = new FeedItem();
                if(assigneeIds.contains(chatterFeed.AssignedUser)) {
                    post.ParentId = chatterFeed.AssignedUser;

                    // For standard user we don't have to provide network id in feedItem
                    if (isNetworkAvailable && mapUsers != null && mapUsers.containsKey(chatterFeed.AssignedUser) && mapUsers.get(chatterFeed.AssignedUser).UserType != 'Standard') {                            
                        post.put('NetworkScope', mapNetworkMembers.get(chatterFeed.AssignedUser));
                    }

                    //For chatter post visibility for all users from community  
                    if (String.isNotBlank(networkId)) {
                        post.put('Visibility', 'AllUsers');
                    }

                    post.Title = chatterFeed.KanbanTitle;
                    
                    if (chatterFeed.KanbanURL.contains('GanttView')) {
                        if (chatterFeed.KanbanURL.contains('&&ThisIsMilestone')) {
                            post.Body = USER_NAME_CONST + ' has assigned you as owner of Milestone "' + chatterFeed.KanbanTitle + '". Click this link to go to the project board. '+'\n\n'+ chatterFeed.ProjectBoardName;
                            chatterFeed.KanbanURL = chatterFeed.KanbanURL.replace('&&ThisIsMilestone','');
                        } else {
                        
                            List<String> customlabelsParam = new List<String>();
                                customlabelsParam.add(''+USER_NAME_CONST);
                                customlabelsParam.add(''+chatterFeed.KanbanTitle);
                                customlabelsParam.add(''+chatterFeed.ProjectBoardName);
                                String LabelsWithParameter = String.format(System.Label.leankor.HasMadeYouOwnerOfActivity,customlabelsParam);
                                post.Body = LabelsWithParameter;
                        }
                    } else {
                        if (chatterFeed.KanbanURL.contains('&&ThisIsMilestone')) {
                            post.Body = USER_NAME_CONST + ' has assigned you as owner of Milestone "' + chatterFeed.KanbanTitle + '". Click this link to go to the project board. '+'\n\n'+ chatterFeed.ProjectBoardName;
                            chatterFeed.KanbanURL = chatterFeed.KanbanURL.replace('&&ThisIsMilestone','');
                        } else {
                        
                            List<String> customlabelsParam = new List<String>();
                                customlabelsParam.add(''+USER_NAME_CONST);
                                customlabelsParam.add(''+chatterFeed.KanbanTitle);
                                customlabelsParam.add(''+chatterFeed.ProjectBoardName);
                                String LabelsWithParameter = String.format(System.Label.leankor.HasMadeYouOwnerOfCard,customlabelsParam);
                                post.Body = LabelsWithParameter;
                        }
                    }

                    post.LinkUrl = chatterFeed.KanbanURL + chatterFeed.KanbanID;
                    posts.add(post);
                }
            }

            try {
                OpenFeedItemRestriction.createFeedItems(posts);
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }

        } else if (kanbanVerb == 'MoveKanbanCard') {
            Set<String> uniqueKanbans = new Set<String>();
            Set<String> uniqueUsers = new Set<String>();
            
            for (ChatterFeed chatterFeed : chatterFeeds) {
                uniqueKanbans.add(chatterFeed.KanbanID);
                uniqueUsers.add(chatterFeed.AssignedUser);
            }

            List<String> kanbanCardIds = new List<String>(uniqueKanbans);
            List<String> assignedUsers = new List<String>(uniqueUsers);

            entitySubscriptions = [Select Id, 
                                            ParentId, 
                                            SubscriberId 
                                        From EntitySubscription 
                                        Where ParentID In :kanbanCardIds 
                                            And SubscriberId In :assignedUsers 
                                        Limit 1000];

            for (ChatterFeed chatterFeed : chatterFeeds) {
                boolean flag = true;
                for (EntitySubscription entitySubscription : entitySubscriptions) {
                    if (entitySubscription.ParentId == chatterFeed.AssignedUser && entitySubscription.ParentId == chatterFeed.KanbanID) {
                        flag = false;
                        break;
                    }
                }
                if (flag) {
                    if (Network.getnetworkid() != null) {
                        sObject entitySubscriptionObject = New EntitySubscription();
                        entitySubscriptionObject.put('ParentId', chatterFeed.KanbanID);
                        entitySubscriptionObject.put('NetworkId', Network.getnetworkid());
                        entitySubscriptionObject.put('SubscriberId', chatterFeed.AssignedUser);
                        entitySubscriptionObjects.add(entitySubscriptionObject);
                    } else {
                        EntitySubscription entitySubscription2 = new EntitySubscription(ParentId = chatterFeed.KanbanID, SubscriberId = chatterFeed.AssignedUser);
                        entitySubscriptions2.add(entitySubscription2);
                    }
                }
            }

            Savepoint sp = Database.setSavepoint();            
            try {
                if (entitySubscriptionObjects.size() > 0) {
                    //21/04/2023 : Moving the code in Without sharing class for creating entitySubscription.
                    //insert entitySubscriptionObjects;
                    ChatterAutoFollow.createAutoFollow(entitySubscriptionObjects);
                }

                if (entitySubscriptions2.size() > 0) {
                    ChatterAutoFollow.createAutoFollow(entitySubscriptions2);
                }

                if (posts.size() > 0) {
                    insert posts;
                }
            } catch(Exception e) {
				//Changes : Ramanand - 20/01/2022 : Fixed issue that community user facing while creating/cloning card INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY. 
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }
    }


    /***
     * This Method is use to get Valuestream records
     * INPUT:  ProjectRoom ID / ValueStream ID
     * OUTPUT: Return Valuestream records.
    */
    @RemoteAction
    global static List<leankor__ValueStream__c> getValueStreams(String projectRoomId) {
        if (String.isNotBlank(projectRoomId) && (Util.getSObjectName(projectRoomId) != 'leankor__ValueStream__c'
        && Util.getSObjectName(projectRoomId) != 'leankor__ProjectRoom__c')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();
    
        if (String.isNotBlank(projectRoomId)) {
            Id objectId = projectRoomId;
            
            //checking api name if objectId is for valuestream it will filter by valuestream id otherwise will filter by projectroom id.
            // Tilak Raj Mahale - 04/03/2020 - Changes for filtering soft deleted record and removing null condition from where clause.
			if (objectId.getSObjectType().getDescribe().getName() == 'leankor__ValueStream__c') {
                valueStreams = [Select Id, 
                                        Name, 
                                        leankor__BoardType__c, 
                                        leankor__ProjectRoom__c, 
                                        leankor__ProjectRoom__r.Name, 
                                        UserRecordAccess.HasEditAccess,
                                        leankor__ScheduleBackward__c 
                                    From leankor__ValueStream__c 
                                    Where Id = :objectId 
                                        And leankor__BoardType__c In :BOARDTYPEFILTERS_NONCARDHIERARCHY_CONST
                                        And leankor__isRecordDeleted__c = false 
                                    Limit 50000];
            } else {
                valueStreams = [Select Id, 
                                        Name, 
                                        leankor__BoardType__c, 
                                        leankor__ProjectRoom__c, 
                                        leankor__ProjectRoom__r.Name, 
                                        UserRecordAccess.HasEditAccess,
                                        leankor__ScheduleBackward__c 
                                    From leankor__ValueStream__c 
                                    Where leankor__ProjectRoom__c = :projectRoomId
                                        And leankor__BoardType__c In :BOARDTYPEFILTERS_NONCARDHIERARCHY_CONST 
                                        And leankor__isRecordDeleted__c = false  
                                    Limit 50000];
            }
        } else {
            for (leankor__ValueStream__c valueStream : [Select Id, 
                                                            Name, 
                                                            leankor__BoardType__c, 
                                                            leankor__ProjectRoom__c, 
                                                            leankor__ProjectRoom__r.Name, 
                                                            leankor__ScheduleBackward__c,
                                                            UserRecordAccess.HasEditAccess 
                                                        From leankor__ValueStream__c 
                                                        Where leankor__BoardType__c In :BOARDTYPEFILTERS_NONCARDHIERARCHY_CONST  
                                                            And leankor__isRecordDeleted__c = false 
                                                        Limit 50000]) {

                if (valueStream.leankor__ProjectRoom__c != null) {
                    valueStreams.add(valueStream);
                }
            }
        }
        
        // Date: 07/05/2019 - Now we only returning those valuestream those have edit access.
        List<leankor__ValueStream__c> returnValueStreams = new List<leankor__ValueStream__c>();
        for(leankor__ValueStream__c valueStream : valueStreams){
        	if (valueStream.UserRecordAccess.HasEditAccess) {
        		returnValueStreams.add(valueStream);
            }
        }
        
        return returnValueStreams;
    }


    /***
     * This Method is use to get VFpage records.
     * INPUT:  Name of VFPage.
     * OUTPUT: Return Name SpacePrefix of Page(Lean).
    */
    @RemoteAction
    global static String getPageNamespace(String pageName) {
        if (String.isBlank(pageName)) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<ApexPage> pages = [Select NamespacePrefix
                                    From ApexPage 
                                    Where Name = :pageName 
                                    Limit 1];

        return pages.isEmpty() ? '' : pages[0].NamespacePrefix;
    }


    /***
     * This Method is use to get kanbancards records.
     * INPUT:  Valuestream ID.
     * OUTPUT: Return KAnbanCard record in Object.
    */
    @RemoteAction
    global static List<leankor__KanbanCard__c> getKanbanCards(String valueStream) {
        if (String.isNotBlank(valueStream) && Util.getSObjectName(valueStream) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
    	return RealTimeControllerHelper.getKanbanCardsHelper(valueStream);
    }


    /***
     * This Method is use to get Account records.
     * INPUT:  Limit of size of records, filter value 'like keyword', limits .
     * OUTPUT: Return Account record in Object.
    */
    @RemoteAction
    global static RecordDetails getAccounts(Integer offsetSize, String filterValue, Integer limits) {

       Integer count;
        List<Account> accounts;

        if(filterValue.length() > 1){
            List<List<Account>> searchCount = [Find :filterValue In Name Fields Returning Account (Id, Name Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST Limit :limits)];
            count =  searchCount[0].size();
            List<List<Account>> searchList = [Find :filterValue In Name Fields Returning Account (Id, Name Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST Limit :limits Offset :offsetSize)];
            accounts = searchList[0];
        }else{
            count = [Select Count() 

                            From Account 
                                Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST
                            Limit :limits];

            accounts = [Select Id, 
                                Name 
                            From Account 
                            Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST
                            Limit :limits 
                            Offset: offsetSize];                          

        }
        accounts.sort();
        RecordDetails records = new RecordDetails();

        records.Count = count;
        records.OffsetSize = offsetSize;
        records.Accounts = accounts;

        return records;
    }


    /***
     * This Method is use to get Contact records.
     * INPUT:  Limit of size of records, filter value 'like keyword', limits .
     * OUTPUT: Return contact record in Object.
    */
    @RemoteAction
    global static RecordDetails getContacts(Integer offsetSize, String filterValue, Integer limits, Boolean filter, String inputAccountId) {
        if (inputAccountId != 'All' && String.isNotBlank(inputAccountId) &&  Util.getSObjectName(inputAccountId) != 'Account') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<Contact> contacts = new List<Contact>();
        List<Account> accounts = new List<Account>();
        Integer count = 0;

        //TODO: modify for query selectivity, to remove the null and like from where clause
        if (inputAccountId == 'All') {
            if (filter) {
                accounts = [Select Id, 
                                    Name 
                                From Account 
                                Where OwnerId = :USER_ID_CONST
                                Limit :limits 
                                Offset: offsetSize];

                accounts.sort();
                
                if(filterValue.length() > 1){
                    List<List<Contact>> contactCount = [Find :filterValue In Name Fields Returning Contact (Id, Name Where AccountId In :accounts)];
                    count = contactCount[0].size();
                    List<List<Contact>> contactList = [Find :filterValue In Name Fields Returning Contact (Id, Name, FirstName, LastName, Account.Name, AccountId Where AccountId In :accounts Limit :limits Offset :offsetSize)];
                    contacts = contactList[0];
                }else{
                    count = [Select Count() 
                                    From Contact 
                                    Where AccountId In :accounts];

                    contacts = [Select Id, 
                                        Name, 
                                        FirstName, 
                                        LastName, 
                                        Account.Name, 
                                        AccountId 
                                    From Contact 
                                    Where AccountId In :accounts 
                                        Limit :limits 
                                    Offset :offsetSize];
                }
            } else {
                if(filterValue.length() > 1){
                    List<List<Contact>> contactCount = [Find :filterValue In Name Fields Returning Contact (Id, Name Where AccountId != null)];
                    count = contactCount[0].size();
                    List<List<Contact>> contactList = [Find :filterValue In Name Fields Returning Contact (Id, Name, FirstName, LastName, Account.Name, AccountId Where AccountId != null Limit :limits Offset :offsetSize)];
                    contacts = contactList[0];
                }else{
                    count = [Select Count() 
                                From Contact 
                                    Where AccountId != null];

                    contacts = [Select Id, 
                                        Name, 
                                        FirstName, 
                                        LastName, 
                                        Account.Name, 
                                        AccountId 
                                    From Contact 
                                    Where AccountId != null 
                                        Limit :limits 
                                    Offset :offsetSize];
                }
            }
        } else {
            if(filterValue.length() > 1){
                List<List<Contact>> contactCount = [Find :filterValue In Name Fields Returning Contact (Id, Name Where AccountId =: inputAccountId)];
                count = contactCount[0].size();
                List<List<Contact>> contactList = [Find :filterValue In Name Fields Returning Contact (Id, Name, FirstName, LastName, Account.Name, AccountId Where AccountId =: inputAccountId Limit :limits Offset :offsetSize)];
                contacts = contactList[0];
            }else{
                count = [Select Count()
                            From Contact 
                                Where AccountId = :inputAccountId];

                contacts = [Select Id, 
                                    Name, 
                                    FirstName, 
                                    LastName, 
                                    Account.Name, 
                                    AccountId 
                                From Contact 
                                Where AccountId = :inputAccountId 
                                    Limit :limits 
                                Offset: offsetSize];
        	}
        }
        contacts.sort();
        RecordDetails records = new RecordDetails();
        records.Count = count;
        records.OffsetSize = offsetSize;
        records.Contacts = contacts;

        return records;
    }


    /***
     * This Method is use to get Case records.
     * INPUT:  Limit of size of records, filter value 'like keyword', limits .
     * OUTPUT: Return case record in Object.
    */
    @RemoteAction
    global static RecordDetails getCases(Integer offsetSize, String filterValue, Integer limits, Boolean filter, String inputAccountId) {
        if (inputAccountId != 'All' && String.isNotBlank(inputAccountId) && Util.getSObjectName(inputAccountId) != 'Account') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
  
        Set<String> statusList = new Set<String>{'New', 'Working', 'Escalated'};

        Integer count;
        List<Case> cases = new List<Case>();
        RecordDetails records = new RecordDetails();
        Boolean caseNumber;
        Boolean CaseSubject;
        Boolean contactName;
        Boolean accountName;

        //TODO: modify for query selectivity, to remove the null and like from where clause
        try {
            if (inputAccountId == 'All') {
                if (filter) {
                    List<Account> accounts = [Select Id, 
                                                    Name 
                                                From Account 
                                                Where OwnerId = :USER_ID_CONST
                                                Limit :limits 
                                                Offset: offsetSize];

                    List<Case> casesRecord = [Select AccountId, 
                                    Account.Name, 
                                    CaseNumber, 
                                    ContactId, 
                                    Contact.Name, 
                                    Description, 
                                    Id, 
                                    OwnerID, 
                                    Priority, 
                                    Status, 
                                    Subject, 
                                    Type 
                                From Case 
                                Where AccountId In :accounts 
                                    And Status In :statusList
                                Limit :limits 
                                Offset :offsetSize];

                    if(casesRecord.size()> 0 && filterValue.length()>1){
                        for(Case caseRecord : casesRecord){
                            caseNumber = (caseRecord.CaseNumber == null) ? false : caseRecord.CaseNumber.startsWithIgnoreCase(filterValue);
                            caseSubject = (caseRecord.Subject == null) ? false : caseRecord.Subject.startsWithIgnoreCase(filterValue);
                            contactName = (caseRecord.Contact.Name == null) ?  false : caseRecord.Contact.Name.startsWithIgnoreCase(filterValue);
                            accountName = (caseRecord.Account.Name == null) ?  false : caseRecord.Account.Name.startsWithIgnoreCase(filterValue);
                            if(caseNumber || caseSubject || contactName || accountName){
                                cases.add(caseRecord);
                            }
                        }
                } else {
                        cases = casesRecord;
                    }
                    count = cases.size();
                } else {
                   List<Case> casesRecord = [Select AccountId, 
                                    Account.Name, 
                                    CaseNumber, 
                                    ContactId, 
                                    Contact.Name, 
                                    Description, 
                                    Id, 
                                    OwnerId, 
                                    Priority, 
                                    Status, 
                                    Subject, 
                                    Type 
                                From Case 
                                Where AccountId != null 
                                    And Status In :statusList 
                                Limit :limits 
                                Offset :offsetSize];

                    if(casesRecord.size()> 0 && filterValue.length()>1){
                        for(Case caseRecord : casesRecord){
                            caseNumber = (caseRecord.CaseNumber == null) ? false : caseRecord.CaseNumber.startsWithIgnoreCase(filterValue);
                            caseSubject = (caseRecord.Subject == null) ? false : caseRecord.Subject.startsWithIgnoreCase(filterValue);
                            contactName = (caseRecord.Contact.Name == null) ?  false : caseRecord.Contact.Name.startsWithIgnoreCase(filterValue);
                            accountName = (caseRecord.Account.Name == null) ?  false : caseRecord.Account.Name.startsWithIgnoreCase(filterValue);
                            if(caseNumber || caseSubject || contactName || accountName){
                                cases.add(caseRecord);
                            }
                        }
            } else {
                    cases = casesRecord;
                    }
                    count = cases.size();    
                }
            } else {
                    List<Case> casesRecord = [Select AccountId, 
                                Account.Name, 
                                CaseNumber, 
                                ContactId, 
                                Contact.Name, 
                                Description, 
                                Id, 
                                OwnerID, 
                                Priority, 
                                Status, 
                                Subject, 
                                Type 
                            From Case 
                            Where Status In :statusList 
                                And AccountId = :inputAccountId 
                            Limit :limits 
                            Offset :offsetSize];
                 if(casesRecord.size()> 0 && filterValue.length()>1){
                    for(Case caseRecord : casesRecord){
                        caseNumber = (caseRecord.CaseNumber == null) ? false : caseRecord.CaseNumber.startsWithIgnoreCase(filterValue);
                        caseSubject = (caseRecord.Subject == null) ? false : caseRecord.Subject.startsWithIgnoreCase(filterValue);
                        contactName = (caseRecord.Contact.Name == null) ?  false : caseRecord.Contact.Name.startsWithIgnoreCase(filterValue);
                        accountName = (caseRecord.Account.Name == null) ?  false : caseRecord.Account.Name.startsWithIgnoreCase(filterValue);
                        if(caseNumber || caseSubject || contactName || accountName){
                            cases.add(caseRecord);
                        }   
                    }
                }else{
                    cases = casesRecord;
                }
                count = cases.size();                                     
            }   
            
            records.Count = count;
            records.OffsetSize = offsetSize;
            records.Cases = cases;

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return records;
    }


    // This Is Inner Class For Record Details
    global class RecordDetails {
        Integer Count;
        Integer OffsetSize;
        List<Contact> Contacts;
        List<Account> Accounts;
        List<User> Users;
        List<Case> Cases;
        List<Opportunity> Opportunities;
    }


    /***
     * This Method is use to Create user records .
     * INPUT:   .
     * OUTPUT: Return  Database save result.
    */
    @RemoteAction
    global static List<Database.SaveResult> createUsers(String[] users, String myWorkSpace) {
        //Check CRUD / FLC behavior
        UserBehaviour userBehaviour = new UserBehaviour();
        PermissionSetAssignmentBehaviour permissionSetAssignmentBehaviour = new PermissionSetAssignmentBehaviour();

        if (!userBehaviour.isAccessible() 
        || !userBehaviour.isCreateable() 
        || !permissionSetAssignmentBehaviour.isAccessible() 
        || !permissionSetAssignmentBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Database.SaveResult[] userResults = null;
        leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();

        List<Profile> profiles = [Select Id, 
                                            Name 
                                        From Profile 
                                        Where Name = :leanConstant.leankor__InviteProfile__c 
                                        Limit 1];

        if (profiles.size() > 0) {
            String invitePermissionSet = 'Visual_Lean_User';
            
            if (String.isNotBlank(leanConstant.leankor__InvitePermissionSet__c)) {
                invitePermissionSet = leanConstant.leankor__InvitePermissionSet__c;
            }

            List<PermissionSet> permissionSets = [Select Id 
                                                        From PermissionSet 
                                                        Where Name = :invitePermissionSet 
                                                        Limit 1];
            
            if (permissionSets.size() > 0) {
                String inviteRole = leanConstant.leankor__InviteRole__c;

                if (inviteRole == 'None' || inviteRole == 'none' || inviteRole == '' || inviteRole == null) {
                    inviteRole = null;
                } else {
                    List<UserRole> userRoles = [Select Id 
                                                    From UserRole 
                                                    Where Name = :leanConstant.leankor__InviteRole__c 
                                                    Limit 1];

                    inviteRole = userRoles.isEmpty() ? null : userRoles[0].Id;
                }

                List<User> newUsers = new List<User>();

                for (String user : users) {
                    String userName = user.substringBefore('@');
                    String firstName = '';
                    String lastName = '';
                    
                    if (userName.length() > 8) {
                        firstName = userName.subString(0, 7);
                        lastName = userName.subString(0, 7);
                    } else {
                        firstName = userName;
                        lastName = userName;
                    }
                    
                    User newUser = new User();
                    
                    newUser.UserName = user;
                    newUser.Email = user;
                    newUser.CommunityNickname = firstName;
                    newUser.FirstName = firstName;
                    newUser.LastName = lastName;
                    newUser.Alias = firstName;
                    newUser.LanguageLocaleKey = 'en_US';
                    newUser.LocaleSidKey = UserInfo.getLocale();
                    newUser.EmailEncodingKey = 'UTF-8';
                    newUser.TimeZoneSidKey = 'America/Los_Angeles';
                    newUser.ProfileID = profiles[0].Id;
                    newUser.UserRoleId = inviteRole;
                    newUser.isActive = true;

                    newUsers.add(newUser);
                }

                if (users.size() > 0) {

                    Set<String> userResultIds = new Set<String>();

                    String error = '';
                    List<EmailTemplate> emailTemplates = [Select Id
                                                                From EmailTemplate 
                                                                Where Name = 'LeanWelcomeEmail' 
                                                                Limit 1];

                    List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment> ();
                    
                    Savepoint sp = Database.setSavepoint();            
                    try {
                        userResults = Database.insert(newUsers, false);

                        for (Database.SaveResult userResult : userResults) {
                            if (userResult.isSuccess()) {
                                String userResultId = userResult.getId();

                                if (emailTemplates.size() > 0) {
                                    Messaging.SingleEmailMessage Mail = new Messaging.SingleEmailMessage();
                                    
                                    Mail.setTargetObjectID(userResultId);
                                    Mail.setTemplateID(emailTemplates[0].Id);                                    
                                    Mail.setSaveAsActivity(false);
                                    
                                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{Mail});
                                }

                                // System.resetPassword(userResultId, true);
                                
                                PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
                                permissionSetAssignment.AssigneeID = userResultId;
                                permissionSetAssignment.PermissionSetID = permissionSets[0].Id;
                                permissionSetAssignments.add(permissionSetAssignment);

                                userResultIds.add(userResultId);

                            } else {
                                for (Database.Error e : userResult.getErrors()) {
                                    error += e.getMessage();
                                    system.debug('Not able to create user ' + e.getMessage());
                                }

                                System.debug(error);
                            }
                        }

                        if (permissionSetAssignments.size() > 0) {
                            Database.insert(permissionSetAssignments, false);
                                        
                            List<PackageLicense> packageLicenses = [Select Id 
                                                                        From PackageLicense 
                                                                        Where NamespacePrefix = :NAMESPACE_PREFIX 
                                                                        Limit 1];

                            if (packageLicenses.size() > 0) {
                                List<UserPackageLicense> resultsUserPackageLicenses = [Select Id 
                                                                                            From UserPackageLicense 
                                                                                            Where PackageLicenseId = :packageLicenses[0].Id 
                                                                                                And UserId In :userResultIds]; 

                                List<UserPackageLicense> userPackageLicenses = new List<UserPackageLicense>();

                                for (UserPackageLicense resultsUserPackageLicense : resultsUserPackageLicenses) {
                                    UserPackageLicense newUserPackageLicense = new UserPackageLicense();

                                    newUserPackageLicense.UserId = resultsUserPackageLicense.UserId;
                                    newUserPackageLicense.PackageLicenseId = packageLicenses[0].Id;

                                    userPackageLicenses.add(newUserPackageLicense);
                                }

                                if (userPackageLicenses.size() > 0) {
                                    insert userPackageLicenses;
                                }
                            }
                        }
                    } catch(Exception e) {
                        Database.rollback(sp);
                        System.debug(e.getMessage());
                        throw new Util.LeanException('Error: ' + e.getmessage());
                    }
                }
            }
        }

        return userResults;
    }


    //Inner class for Preference.
    global class Preference {
        global String Id;
        global String Name;
        global String GUID;
        global String CurrentUser;
        global String FollowOnChatter;
        global String SubscribeToCard;
        global String ValueStream;
        global Boolean OwnerEditCard;
        global Boolean OwnerMoveCard;
        global String ValueStreamOwner;
        global List<String> Categories;
        global Boolean CardPastDueDate;
        global Boolean TaskPastDueDate;
        global Boolean isTaskCompleted;
        global Boolean Moved;
        global Boolean PercentDone;
        global Integer Flag;
        global String DerivedFrom;
        global Decimal GanttDividerSize;
    }


    /***
     * This Method is setUserPreferenceAndSecurity records
     * INPUT:  Object records  of Preference class
     * OUTPUT: Return  update preference records
    */
    @RemoteAction
    global static leankor__Preference__c setUserPreferenceAndSecurity(Preference userPref) {
        if ((String.isNotBlank(userPref.ValueStream) && Util.getSObjectName(userPref.ValueStream) != 'leankor__ValueStream__c')
        || (String.isNotBlank(userPref.DerivedFrom) && Util.getSObjectName(userPref.DerivedFrom) != 'leankor__Preference__c')
        || (String.isNotBlank(userPref.CurrentUser) && Util.getSObjectName(userPref.CurrentUser) != 'User')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
  		PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        
        if (!preferenceBehaviour.isAccessible() 
        || !preferenceBehaviour.isUpdateable() 
        || !preferenceBehaviour.isCreateable() 
        || !valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__Preference__c userPreference;

        if (userPref == null) {
            System.debug('Error: Preference is empty and cannot proceed');
            return userPreference;
        }

        List<leankor__Preference__c> preferences = [Select Id,
                                                            leankor__ValueStream__c
                                                        From leankor__Preference__c 
                                                        Where OwnerId = :USER_ID_CONST
                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                        Order By CreatedDate Desc
                                                        Limit 50000];

        Id preferenceId;                                       
        
        for (leankor__Preference__c preference : preferences) {
            if (preference.leankor__ValueStream__c == null) {
                preferenceId = preference.Id;
                break;
            }
        }

        userPreference = new leankor__Preference__c(
            Name = userPref.Name,
            leankor__GUID__c = userPref.GUID,
            leankor__FollowOnChatter__c = userPref.FollowOnChatter,
            leankor__SubscribeToCard__c = userPref.SubscribeToCard,
            leankor__CardPastDueDate__c = userPref.CardPastDueDate,
            leankor__Moved__c = userPref.Moved,
            leankor__PercentDone__c = userPref.PercentDone,
            leankor__TaskPastDueDate__c = userPref.TaskPastDueDate,
            leankor__isTaskCompleted__c = userPref.isTaskCompleted ? userPref.isTaskCompleted : false,
            leankor__ValueStream__c = String.isBlank(userPref.ValueStream) ? null : userPref.ValueStream,
            leankor__DerivedFrom__c = preferenceId
        );
                
        Savepoint sp = Database.setSavepoint();            
        try {        
            Schema.Sobjectfield externField = leankor__Preference__c.Fields.leankor__GUID__c;
            Database.UpsertResult uResult = Database.upsert(userPreference, externField, true);
            
            if (uResult.isSuccess()) {
                String prefId = uResult.getId();

                followOnChatters(prefId, userPref);
                valueStreamPreference(prefId, userPref);

                if (String.isNotBlank(userPref.ValueStreamOwner)) {                
                    /*
                    // 22-06-2020 Changes for allow Sys Admin to Change Board Owner.
                    List<User> userRecords = [Select Profile.Name 
                                                    From User 
                                                    Where Id = :userPref.CurrentUser 
                                                    Limit 1];
                    
                    Boolean isSysAdminUser = userRecords.size() > 0 ? (userRecords[0].Profile.Name == 'System Administrator') : false;
					*/
                    
                    List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                                            OwnerId 
                                                                        From leankor__ValueStream__c 
                                                                        Where Id = :userPref.ValueStream 
                                                                        Limit 1];
                    //--- to fix "Insecure Security Control Implementation"
                    //if (valueStreams.size() > 0 && (valueStreams[0].OwnerId == userPref.CurrentUser || isSysAdminUser)) {
                    if (valueStreams.size() > 0 
                        && (valueStreams[0].OwnerId == USER_ID_CONST 
                        || Util.readUserProfileName(UserInfo.getProfileId()) == 'System Administrator')) {    
                        valueStreams[0].OwnerId = userPref.ValueStreamOwner;
                        update valueStreams;
                    }
                }
            }
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return userPreference;
    }

    global static void followOnChatters(String derivedFromId, Preference userPref) {                
        /*
        //Check CRUD / FLC behavior
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();
        if (
            !EntitySubscriptionBehaviour.isAccessible() ||
            !EntitySubscriptionBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior                
        */

        if (String.isBlank(userPref.FollowOnChatter)) {
            return;
        }

        List<EntitySubscription> entitySubscriptions = new List<EntitySubscription>();
        List<sObject> entitySubscriptionObjects = new List<EntitySubscription>();

        if (userPref.FollowOnChatter == 'all' || userPref.FollowOnChatter == 'none') {
            List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

            if (String.isBlank(userPref.ValueStream)) {
                //TODO: the following is reading all records of KBC and must be investigated                   
                List<leankor__KanbanCard__c> kanbanCardRecords = [Select Id, 
                                                                            leankor__Case__c, 
                                                                            leankor__Opportunity__c, 
                                                                            leankor__Valuestream__r.leankor__Viewchatteroptions__c,
                                                                            leankor__ValueStream__c
                                                                        From leankor__KanbanCard__c 
                                                                        Where LastModifiedDate >= :LASTMODIFIEDDATETIME_CONST
                                                                            And leankor__isRecordDeleted__c = false
                                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                                        Order By CreatedDate Desc
                                                                        Limit 10000];

                List<leankor__Preference__c> preferences = [Select leankor__ValueStream__c                 
                                                                From leankor__Preference__c 
                                                                Where leankor__DerivedFrom__c = :derivedFromId 
                                                                Limit 10000];


                if (preferences.size() == 0) { 
                    for (leankor__KanbanCard__c kanbanCardRecord : kanbanCardRecords) {
                        if (String.isNotBlank(kanbanCardRecord.leankor__ValueStream__c)) {
                            kanbanCards.add(kanbanCardRecord);
                        }
                    }
                } else {
                    Set<String> valueStreams = new Set<String>();

                    for (leankor__Preference__c preference : preferences) {
                        if (String.isNotBlank(preference.leankor__ValueStream__c)) {
                            valueStreams.add(preference.leankor__ValueStream__c);
                        }
                    }

                    for (leankor__KanbanCard__c kanbanCardRecord : kanbanCardRecords) {
                        if (!valueStreams.contains(kanbanCardRecord.leankor__ValueStream__c)) {
                            kanbanCards.add(kanbanCardRecord);
                        }
                    }                
                }

            } else {
                kanbanCards = [Select Id,
                                        leankor__Case__c, 
                                        leankor__Opportunity__c, 
                                        leankor__Valuestream__r.leankor__Viewchatteroptions__c 
                                    From leankor__KanbanCard__c 
                                    Where leankor__ValueStream__c = :userPref.ValueStream 
                                        And leankor__isRecordDeleted__c = false
                                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                    Limit 10000];
            }

            if (userPref.FollowOnChatter == 'all') {
                //02/Feb/2023 : issue fixes for preveting the creation of dublicate record of EntitySubscription.
                List<EntitySubscription> ESList = new List<EntitySubscription>();
                Set<String> cardIds = new Set<String>();
                Set<String> userIds = new Set<String>();
                for (leankor__KanbanCard__c kanban: kanbanCards) {
                    cardIds.add(kanban.Id);
                    userIds.add(userPref.CurrentUser);
                }
                ESList = OpenFeedItemRestriction.readEntitySubscription(cardIds, userIds);
                for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                    Boolean flag = true;
                    if(Network.getnetworkid() != null) {
                       for (EntitySubscription ES: ESList) {
                        
                            if (ES.SubscriberID == userPref.CurrentUser && Es.ParentID == kanbanCard.Id && Es.get('NetworkID') == Network.getnetworkid()){
                                flag = false;
                                break;
                            }
                        } 
                    }
                    

                    if (Network.getnetworkid() != null) {
                        if(flag){
                            sObject entitySubscriptionObject = new EntitySubscription();
                            entitySubscriptionObject.put('ParentID', kanbanCard.Id);
                            entitySubscriptionObject.put('NetworkID', Network.getnetworkid());
                            entitySubscriptionObject.put('SubscriberID', userPref.CurrentUser);
    
                            entitySubscriptionObjects.add(entitySubscriptionObject);
                        }

                    } else {
                        entitySubscriptions.add(setKanbanCardSubscription(kanbanCard, userPref.CurrentUser));
                    }
                }

                Savepoint sp = Database.setSavepoint();
                try {
                    if (entitySubscriptions.size() > 0) {
                        ChatterAutoFollow.createAutoFollow(entitySubscriptions);
                    }

                    if (entitySubscriptionObjects.size() > 0) {
                        insert entitySubscriptionObjects;
                    }
                } catch (DmlException e) {
                    Database.rollback(sp);
                    System.debug(e.getMessage());
                    throw new Util.LeanException('Error: ' + e.getmessage());
                }
            } else {
                if (kanbanCards.size() > 0) {
                    if (kanbanCards.size() > 200) {
                        Set<String> kanbanCardSubscriptionIds = getKanbanCardSubscriptionIds(kanbanCards);

                        entitySubscriptions = [Select Id, 
                                                        ParentId, 
                                                        SubscriberId 
                                                    From EntitySubscription 
                                                    Where ParentId In :kanbanCardSubscriptionIds 
                                                        And SubscriberId = :userPref.CurrentUser 
                                                    Limit 1000];
                       
                    } else {
                        entitySubscriptions = [Select Id, 
                                                        ParentId, 
                                                        SubscriberId 
                                                    From EntitySubscription 
                                                    Where ParentId In :kanbanCards 
                                                        And SubscriberId = :userPref.CurrentUser 
                                                    Limit 1000];
                    }

                    Savepoint sp = Database.setSavepoint();
                    try {                    
                        ChatterAutoFollow.removeAutoFollow(entitySubscriptions);
                    } catch (DmlException e) {
                        Database.rollback(sp);
                        System.debug(e.getMessage());
                        throw new Util.LeanException('Error: ' + e.getmessage());
                    }
                }
            }
        } else {
            String tempString = '{"Categories" :' + userPref.FollowOnChatter + '}';
            Preference preference = (Preference)JSON.deserialize(tempString, Preference.class);

            Set<Id> kanbanCardTemplateIds = new Set<Id>();
            for (String category : preference.Categories) {
                if (Id.valueOf(category).getSObjectType().getDescribe().getName() == 'leankor__KanbanCardTemplate__c') {
                    kanbanCardTemplateIds.add(category);
                }
            }

            if (kanbanCardTemplateIds.isEmpty()) {
                return;
            }

            List<leankor__KanbanCard__c> kanbanCards = [Select Id,  
                                                                leankor__Case__c, 
                                                                leankor__Opportunity__c, 
                                                                leankor__Valuestream__r.leankor__Viewchatteroptions__c 
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__c = :userPref.ValueStream
                                                                And leankor__isRecordDeleted__c = false
                                                                And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                                And leankor__KanbanCardTemplate__c 
                                                                    In (Select Id 
                                                                            From leankor__KanbanCardTemplate__c 
                                                                            Where Id In :kanbanCardTemplateIds
                                                                    )
                                                            Limit 10000];
            
            //02/Feb/2023 : issue fixes for preveting the creation of dublicate record of EntitySubscription.
            List<EntitySubscription> ESList = new List<EntitySubscription>();
            Set<String> cardIds = new Set<String>();
            Set<String> userIds = new Set<String>();
            for (leankor__KanbanCard__c kanban: kanbanCards) {
                cardIds.add(kanban.Id);
                userIds.add(userPref.CurrentUser);
            }
            ESList = OpenFeedItemRestriction.readEntitySubscription(cardIds, userIds);
            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                Boolean flag = true;
                if(Network.getnetworkid() != null) {
                for (EntitySubscription ES: ESList) {
                    if (ES.SubscriberID == userPref.CurrentUser && Es.ParentID == kanbanCard.Id && Es.get('NetworkId') == Network.getnetworkid()){
                        flag = false;
                        break;
                    }
                }
                }
                if (Network.getnetworkid() != null) {
                    if(flag){   
                        sObject entitySubscriptionObject = new EntitySubscription();
                        entitySubscriptionObject.put('ParentID', kanbanCard.Id);
                        entitySubscriptionObject.put('NetworkID', Network.getnetworkid());
                        entitySubscriptionObject.put('SubscriberID', userPref.CurrentUser);
                        
                        entitySubscriptionObjects.add(entitySubscriptionObject);
                    }
                } else {                    
                    entitySubscriptions.add(setKanbanCardSubscription(kanbanCard, userPref.CurrentUser));
                }
            }

            Savepoint sp = Database.setSavepoint();
            try {                
                if (entitySubscriptions.size() > 0) {
                    ChatterAutoFollow.createAutoFollow(entitySubscriptions);
                }

                if (entitySubscriptionObjects.size() > 0) {
                    insert entitySubscriptionObjects;
                    
                }

                if (kanbanCards.size() > 0) {
                    Set<String> kanbanCardSubscriptionIds = new Set<String>();
    
                    if (kanbanCards.size() > 200) {
                        kanbanCardSubscriptionIds = getKanbanCardSubscriptionIds(kanbanCards);
                    } else {
                        for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                            kanbanCardSubscriptionIds.add(kanbanCard.Id);
                        }
                    }
    
                    List<EntitySubscription> entitySubscriptionRecords = new List<EntitySubscription>();
    
                    List<EntitySubscription> subEntitySubscriptionRecords = [Select Id, 
                                                                                    ParentId, 
                                                                                    SubscriberId 
                                                                                From EntitySubscription 
                                                                                Where SubscriberId = :userPref.CurrentUser
                                                                                Limit 1000];
    
                    for (EntitySubscription subEntitySubscriptionRecord : subEntitySubscriptionRecords) {
                        if (!kanbanCardSubscriptionIds.contains(subEntitySubscriptionRecord.ParentId)) {
                            entitySubscriptionRecords.add(subEntitySubscriptionRecord);
                        }
                    }
    
                    ChatterAutoFollow.removeAutoFollow(entitySubscriptionRecords);
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }
    }


    // helper method to read EntitySubscription
    @TestVisible
    private static Set<String> getKanbanCardSubscriptionIds(List<leankor__KanbanCard__c> kanbanCards) {
        Set<String> kanbanCardSubscriptionIds = new Set<String>();
        Integer maximuKanbanCardChatters = 200;

        Integer tempSize = kanbanCards.size() / maximuKanbanCardChatters;
        for (Integer j = 0; j < tempSize; j++) {
            Integer tempI = j * maximuKanbanCardChatters;
            Integer tempLimit = (((j + 1) * maximuKanbanCardChatters) > kanbanCards.size() ? kanbanCards.size() : ((j + 1) * maximuKanbanCardChatters));

            for (Integer i = tempI; i < tempLimit; i++) {
                if (kanbanCards[i].leankor__Valuestream__r.leankor__Viewchatteroptions__c == 'Opportunities Chatter') {
                    kanbanCardSubscriptionIds.add(kanbanCards[i].leankor__Opportunity__c);
                } else if (kanbanCards[i].leankor__Valuestream__r.leankor__Viewchatteroptions__c == 'Cases Chatter') {
                    kanbanCardSubscriptionIds.add(kanbanCards[i].leankor__Case__c);
                } else {
                    kanbanCardSubscriptionIds.add(kanbanCards[i].Id);
                }
            }
        }

        return kanbanCardSubscriptionIds;
    }


    // helper method to set EntitySubscription
    @TestVisible
    private static EntitySubscription setKanbanCardSubscription(leankor__KanbanCard__c kanbanCard, String subscriberId) {
        Id parentId;

        if (kanbanCard.leankor__Valuestream__r.leankor__Viewchatteroptions__c == 'Opportunities Chatter') {
            parentId = kanbanCard.leankor__Opportunity__c;
        } else if (kanbanCard.leankor__Valuestream__r.leankor__Viewchatteroptions__c == 'Cases Chatter') {
            parentId = kanbanCard.leankor__Case__c;
        } else {
            parentId = kanbanCard.Id;
        }

        return new EntitySubscription(ParentId = parentId, SubscriberId = subscriberId);
    }

    @AuraEnabled
    public static leankor__Preference__c getUserPreference(PreferenceRequest userPrefRequest) {
    // Initialize a Preference object using the data from the top-level class
    Preference userPref = new Preference();
    
    // Set fields from the top-level class to the inner class
    userPref.ValueStream = userPrefRequest.ValueStream;
    userPref.Name = userPrefRequest.Name;
    userPref.GUID = userPrefRequest.GUID;
    userPref.FollowOnChatter = userPrefRequest.FollowOnChatter;
    userPref.SubscribeToCard = userPrefRequest.SubscribeToCard;
    userPref.CardPastDueDate = userPrefRequest.CardPastDueDate;
    userPref.Moved = userPrefRequest.Moved;
    userPref.PercentDone = userPrefRequest.PercentDone;
    userPref.TaskPastDueDate = userPrefRequest.TaskPastDueDate;
    userPref.CurrentUser = userPrefRequest.CurrentUser; // Assuming this is part of Preference
    userPref.DerivedFrom = userPrefRequest.DerivedFrom; // Assuming this is part of Preference
    userPref.GanttDividerSize = userPrefRequest.GanttDividerSize; // Assuming this is part of Preference

    // Call the existing method
    leankor__Preference__c resultPreference = getPreference(userPref);

    // Return the updated PreferenceRequest object
    return resultPreference;
}



    /***
     * This Method is setUserPreferenceAndSecurity records .
     * INPUT:  Object records  of Preference class  .
     * OUTPUT: Return  update preference records  .
    */
    @RemoteAction
    global static leankor__Preference__c getPreference(Preference userPref) {
        if ((String.isNotBlank(userPref.ValueStream) && Util.getSObjectName(userPref.ValueStream) != 'leankor__ValueStream__c')
        || (String.isNotBlank(userPref.DerivedFrom) && Util.getSObjectName(userPref.DerivedFrom) != 'leankor__Preference__c')
        || (String.isNotBlank(userPref.CurrentUser) && Util.getSObjectName(userPref.CurrentUser) != 'User')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior		
        PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();

        if (!preferenceBehaviour.isAccessible() 
        || !preferenceBehaviour.isCreateable() 
        || !preferenceBehaviour.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        if(String.isNotBlank(userPref.ValueStream)){
            leankor__ValueStream__c valueStreamRecord = [Select Id,
                                                                    leankor__BoardType__c
                                                                From leankor__ValueStream__c
                                                                Where Id =: userPref.ValueStream 
                                                                Limit 1];
        if(valueStreamRecord.leankor__BoardType__c == 'WhiteBoard' || valueStreamRecord.leankor__BoardType__c == 'DashBoard'){
                RealTimeControllerHelper.updateProjectBoardDates(new Set<String>{userPref.ValueStream});
        }
                                                            }
       
        //22/12/2021 : Changes added for GanttDivide Bar GanttDividerSize. 
        leankor__Preference__c userPreference = new leankor__Preference__c();

        List<leankor__Preference__c> preferences = [Select Id, 
                                                            Name, 
                                                            leankor__CardPastDueDate__c, 
                                                            leankor__DerivedFrom__c, 
                                                            leankor__FollowOnChatter__c, 
                                                            leankor__GUID__c, 
                                                            leankor__Moved__c, 
                                                            leankor__PercentDone__c, 
                                                            leankor__SubscribeToCard__c, 
                                                            leankor__TaskPastDueDate__c, 
                                                            leankor__ValueStream__c, 
                                                            OwnerId, 
                                                            leankor__isTaskCompleted__c,
                                                            leankor__GanttDividerSize__c 
                                                        From leankor__Preference__c 
                                                        Where leankor__ValueStream__c = :userPref.ValueStream 
                                                            And OwnerId = :USER_ID_CONST
                                                        Limit 1];

        if (preferences.isEmpty()) {
            if (String.isNotBlank(userPref.ValueStream)) {
                List<leankor__Preference__c> globalPreferences = [Select Id, 
                                                                            leankor__CardPastDueDate__c, 
                                                                            leankor__DerivedFrom__c, 
                                                                            leankor__FollowOnChatter__c, 
                                                                            leankor__GUID__c, 
                                                                            leankor__Moved__c, 
                                                                            leankor__PercentDone__c, 
                                                                            leankor__SubscribeToCard__c, 
                                                                            leankor__TaskPastDueDate__c, 
                                                                            leankor__ValueStream__c, 
                                                                            Name, 
                                                                            OwnerId, 
                                                                            leankor__isTaskCompleted__c,
                                                                            leankor__GanttDividerSize__c
                                                                        From leankor__Preference__c 
                                                                        Where leankor__ValueStream__c = '' 
                                                                            And OwnerId = :USER_ID_CONST
                                                                        Limit 1];

                if (globalPreferences.isEmpty()) {
                    userPref.DerivedFrom = '';
                } else {
                    userPref.DerivedFrom = globalPreferences[0].Id;
                    userPref.FollowOnChatter = globalPreferences[0].leankor__FollowOnChatter__c;
                    userPref.SubscribeToCard = globalPreferences[0].leankor__SubscribeToCard__c;
                    userPref.CardPastDueDate = globalPreferences[0].leankor__CardPastDueDate__c;
                    userPref.Moved = globalPreferences[0].leankor__Moved__c;
                    userPref.PercentDone = globalPreferences[0].leankor__PercentDone__c;
                    userPref.TaskPastDueDate = globalPreferences[0].leankor__TaskPastDueDate__c;
                    userPref.isTaskCompleted = globalPreferences[0].leankor__isTaskCompleted__c != null ? globalPreferences[0].leankor__isTaskCompleted__c : false;
                    userPref.GanttDividerSize =  globalPreferences[0].leankor__GanttDividerSize__c;
                }
            }

            userPreference = new leankor__Preference__c(
                Name = userPref.Name,
                leankor__GUID__c = userPref.GUID,
                leankor__FollowOnChatter__c = userPref.FollowOnChatter,
                leankor__SubscribeToCard__c = userPref.SubscribeToCard,
                leankor__CardPastDueDate__c = userPref.CardPastDueDate,
                leankor__Moved__c = userPref.Moved,
                leankor__PercentDone__c = userPref.PercentDone,
                leankor__TaskPastDueDate__c = userPref.TaskPastDueDate,
                leankor__isTaskCompleted__c = userPref.isTaskCompleted != null ? userPref.isTaskCompleted : false,
                leankor__ValueStream__c = userPref.ValueStream == '' ? null : userPref.ValueStream,
                leankor__DerivedFrom__c = userPref.DerivedFrom == '' ? null : userPref.DerivedFrom,
                leankor__GanttDividerSize__c = userPref.GanttDividerSize
            );
                       
            //substring to Name for prevent more than 80 char
            if (String.isNotBlank(userPreference.Name) && userPreference.Name.length() > 80) {
                userPreference.Name = UserPreference.Name.substring(0, 79);              
            } 
           
            Savepoint sp = Database.setSavepoint();
            try {
                Schema.Sobjectfield externField = leankor__Preference__c.Fields.leankor__GUID__c;
                Database.Upsertresult uResult = Database.upsert(userPreference, externField, true);
                
                if (uResult.isSuccess() && String.isNotBlank(userPref.ValueStream)) {                    
                    String prefId = uResult.getId();
    
                    followOnChatters(prefId, userPref);
                    valueStreamPreference(prefId, userPref);
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }              
        } else {
            userPreference = preferences[0];

            if (String.isNotBlank(userPreference.leankor__ValueStream__c)) {
                userPref.Name = userPreference.Name;
                userPref.GUID = userPreference.leankor__GUID__c;
                userPref.FollowOnChatter = userPreference.leankor__FollowOnChatter__c;
                userPref.SubscribeToCard = userPreference.leankor__SubscribeToCard__c;
                userPref.CardPastDueDate = userPreference.leankor__CardPastDueDate__c;
                userPref.Moved = userPreference.leankor__Moved__c;
                userPref.PercentDone = userPreference.leankor__PercentDone__c;
                userPref.TaskPastDueDate = userPreference.leankor__TaskPastDueDate__c;
                userPref.isTaskCompleted = userPreference.leankor__isTaskCompleted__c != null ? userPreference.leankor__isTaskCompleted__c : false;
                userPref.ValueStream = userPreference.leankor__ValueStream__c;
                userPref.DerivedFrom = userPreference.leankor__DerivedFrom__c;
                userPref.GanttDividerSize = userPreference.leankor__GanttDividerSize__c;

                Savepoint sp = Database.setSavepoint();
                try {
                    valueStreamPreference(userPreference.Id, userPref);
                } catch (Exception e) {
                    Database.rollback(sp);
                    System.debug(e.getMessage());
                    throw new Util.LeanException('Error: ' + e.getmessage());
                }
            }
        }

        return userPreference;
    }

    global static void ValueStreamPreference(String prefId, Preference userPref) {
        /*
        //Check CRUD / FLC behavior		
  		SubscriberBehavior subscriberBehavior = new SubscriberBehavior();

        if (!subscriberBehavior.isAccessible() 
        || !subscriberBehavior.isCreateable() 
        || !subscriberBehavior.isUpdateable() 
        || !subscriberBehavior.isDeletable()
		) {
            System.debug('Error: No access to create, update or delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        */

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        List<leankor__KanbanCard__c> otherKanbanCards = new List<leankor__KanbanCard__c>();
        List<leankor__Subscriber__c> deleteSubscribers = new List<leankor__Subscriber__c>();
        Set<String> individualSubscribers = new Set<String>();

        List<leankor__Subscriber__c> subscribers = [Select Id, 
                                                            Name, 
                                                            OwnerId, 
                                                            leankor__SubscriberKey__c, 
                                                            leankor__SubscriberId__c, 
                                                            leankor__KanbanCard__c, 
                                                            leankor__Moved__c, 
                                                            leankor__PercentDone__c, 
                                                            leankor__CardPastDueDate__c, 
                                                            leankor__TaskPastDueDate__c, 
                                                            leankor__Flag__c, 
                                                            leankor__Preference__c, 
                                                            leankor__isTaskCompleted__c 
                                                        From leankor__Subscriber__c 
                                                        Where leankor__kanbanCard__r.leankor__ValueStream__c = :userPref.ValueStream 
                                                            And leankor__Flag__c = 0 
                                                            And leankor__SubscriberId__c = :userPref.CurrentUser 
                                                        Limit 10000];
        
        for (leankor__Subscriber__c subscriber : subscribers) {
            individualSubscribers.add(subscriber.leankor__KanbanCard__c);
        }

        if (userPref.SubscribeToCard == 'all') {
            kanbanCards = [Select Id 
                                From leankor__KanbanCard__c 
                                Where Id Not In :individualSubscribers 
                                    And leankor__ValueStream__c = :userPref.ValueStream 
                                    And leankor__isRecordDeleted__c = false 
                                    And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                Limit 10000];

        } else if (userPref.SubscribeToCard == 'none') {
            List<leankor__KanbanCard__c> otherKanbanCardRecords = [Select Id 
                                                                        From leankor__KanbanCard__c 
                                                                        Where leankor__ValueStream__c = :userPref.ValueStream
                                                                            And leankor__isRecordDeleted__c = false 
                                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                                        Limit 10000];

            for (leankor__KanbanCard__c otherKanbanCardRecord : otherKanbanCardRecords) {
                if (!individualSubscribers.contains(otherKanbanCardRecord.Id)) {
                    otherKanbanCards.add(otherKanbanCardRecord);
                }
            }    

            if (otherKanbanCards.size() > 0) {
                deleteSubscribers = [Select Id
                                        From leankor__Subscriber__c 
                                        Where leankor__KanbanCard__c In :otherKanbanCards 
                                            And leankor__SubscriberId__c = :USER_ID_CONST 
                                        Limit 10000];
            }

        } else {
            String tempString = '{"Categories" :' + userPref.SubscribeToCard + '}';
            Preference pref = (Preference)JSON.deserialize(tempString, Preference.class);

            List<leankor__KanbanCard__c> kanbanCardRecords = [Select Id 
                                                                    From leankor__KanbanCard__c 
                                                                    Where leankor__ValueStream__c = :userPref.ValueStream 
                                                                        And leankor__KanbanCardTemplate__c In :pref.Categories 
                                                                        And leankor__isRecordDeleted__c = false 
                                                                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                                    Limit 10000];

            for (leankor__KanbanCard__c kanbanCardRecord : kanbanCardRecords) {
                if (!individualSubscribers.contains(kanbanCardRecord.Id)) {
                    kanbanCards.add(kanbanCardRecord);
                }
            }

            List<leankor__KanbanCard__c> otherKanbanCardRecords = [Select Id,
                                                                            leankor__KanbanCardTemplate__c
                                                                        From leankor__KanbanCard__c 
                                                                        Where leankor__ValueStream__c = :userPref.ValueStream 
                                                                            And leankor__isRecordDeleted__c = false 
                                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                                        Limit 10000];
            
            for (leankor__KanbanCard__c otherKanbanCardRecord : otherKanbanCardRecords) {
                if (!individualSubscribers.contains(otherKanbanCardRecord.Id) 
                && !pref.Categories.contains(otherKanbanCardRecord.leankor__KanbanCardTemplate__c)) {
                    otherKanbanCards.add(otherKanbanCardRecord);
                }
            }    

            if (otherKanbanCards.size() > 0) {
                deleteSubscribers = [Select leankor__KanbanCard__c, 
                                            leankor__Preference__c,  
                                            leankor__SubscriberId__c 
                                        From leankor__Subscriber__c 
                                        Where leankor__KanbanCard__c In :otherKanbanCards 
                                            And leankor__SubscriberId__c = :USER_ID_CONST
                                        Limit 10000];
            }
        }

        for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
            leankor__Subscriber__c subscriber = new leankor__Subscriber__c(
                Name = kanbanCard.Id,
                leankor__KanbanCard__c = kanbanCard.Id,
                leankor__SubscriberId__c = USER_ID_CONST,
                leankor__Moved__c = userPref.Moved,
                leankor__PercentDone__c = userPref.PercentDone,
                leankor__CardPastDueDate__c = userPref.CardPastDueDate,
                leankor__TaskPastDueDate__c = userPref.TaskPastDueDate,
                leankor__isTaskCompleted__c = userPref.isTaskCompleted == true ? userPref.isTaskCompleted : false,
                leankor__SubscriberKey__c = kanbanCard.Id + '-' + USER_ID_CONST,
                leankor__Preference__c = null,
                leankor__Flag__c = 1
            );

            subscribers.add(subscriber);
        }
         for (leankor__Subscriber__c deleteSubscriber : deleteSubscribers) {
            deleteSubscriber.leankor__KanbanCard__c = null;
            deleteSubscriber.leankor__Preference__c = null;
            deleteSubscriber.leankor__SubscriberId__c = null;
         }

        Savepoint sp = Database.setSavepoint();
        try {        
            if (!deleteSubscribers.isEmpty()) {
                update deleteSubscribers;
            }

            if (subscribers.size() > 0) {
                Schema.Sobjectfield externField = leankor__Subscriber__c.Fields.leankor__SubscriberKey__c;
                Database.upsert(subscribers, externField, true);           
            }
        } catch (Exception e) {
			// Changes : Ramanand - 20/01/2022 : Fixed community issue that is community user unable to delete subscriber record. 
            //Database.rollback(sp);
            System.debug(e.getMessage());
            //throw new Util.LeanException('Error: ' + e.getmessage());
        }        
    }


    @RemoteAction
    global static List<leankor__Security__c> manageSecurity(List<leankor__Security__c> securities) {
        return new List<leankor__Security__c>();                     
    }
    

    //Inner class for Security.
    global class Security {
        global String Id;
        global String Name;
        global String GUID;
        global Boolean OwnerEditCard;
        global Boolean OwnerMoveCard;
        global String ValueStream;
        global List<leankor__Security__c> SecurityArray;
    }


    /***
     * This Method is use to update security setting records .
     * INPUT:  Object records  of security object  .
     * OUTPUT: Return boolean value   .
    */
    @RemoteAction
    global static Boolean setSecurity(Security securities) {
//        if (String.isNotBlank(securities.ValueStream) && Util.getSObjectName(securities.ValueStream) != 'leankor__ValueStream__c') {
        if (securities.SecurityArray.isEmpty()
        || String.isBlank(securities.ValueStream)
        || Util.getSObjectName(securities.ValueStream) != 'leankor__ValueStream__c') {        
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        SecurityBehavior SecurityBehavior = new SecurityBehavior();

        if (!SecurityBehavior.isAccessible() 
        || !SecurityBehavior.isCreateable() 
        || !SecurityBehavior.isUpdateable()) {
            System.debug('Error: No access to create or delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Set<Id> valuesStreamIds = new Set<Id>();
        for(leankor__Security__c security : securities.SecurityArray) {
            valuesStreamIds.add(security.leankor__ValueStream__c);
        }
        
        Map<Id, leankor__ValueStream__c> valueStreamMap = (Map<Id, leankor__ValueStream__c>) new Map<Id, leankor__ValueStream__c>([Select Id, 
                                                                                                                                            OwnerId 
                                                                                                                                        From leankor__ValueStream__c 
                                                                                                                                        Where Id In : valuesStreamIds
                                                                                                                                        And leankor__IsRecordDeleted__c = false]);

        //--- to fix "Insecure Security Control Implementation"
        if (Util.readUserProfileName(UserInfo.getProfileId()) != 'System Administrator') {
            for (leankor__Security__c security : securities.SecurityArray) {
                if (valueStreamMap.get(security.leankor__ValueStream__c).OwnerId != USER_ID_CONST) {
                    System.debug('Error: No access to create or delete records');
                    throw new Util.LeanException('Error: No access to records');
                }
            }
        }
        //---

        Boolean returnVal = false;

        List<leankor__Security__c> existingSecurityList = [Select Id,
                                                                leankor__ValueStream__c,
                                                                leankor__UserRoleId__c  
                                                                From leankor__Security__c 
                                                                Where leankor__ValueStream__c = :securities.ValueStream];
        
        
        for (leankor__Security__c existingSecurity : existingSecurityList) {
            existingSecurity.leankor__ValueStream__c = null;
            existingSecurity.leankor__UserRoleId__c = null;
        }                                                    
        Savepoint sp = Database.setSavepoint();
        try {
            if (!existingSecurityList.isEmpty()) {
                update existingSecurityList;
            }

            if (securities.SecurityArray.size() > 0) {
                insert securities.SecurityArray;
            }

            returnVal = true;

        } catch (DmlException e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }        
                    
        return returnVal;
    }


    /***
     * This Method is use to get security setting records with userRole.
     * INPUT:  Valuestream Id.
     * OUTPUT: Return list of security records.
     */
    @RemoteAction
    global static List<leankor__Security__c> getSecurity(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<leankor__Security__c> result = new List<leankor__Security__c>(); 
        
        List<UserRole> userRoles = [Select Id, 
                                            Name, 
                                            ParentRoleId, 
                                            RollUpDescription 
                                        From UserRole 
                                        Where PortalType = 'None'];
        
        Map<Id, leankor__Security__c> securityMap = new Map<Id, leankor__Security__c>();
        
        //maping with UserRoleId and security object to find record. 
        for (leankor__Security__c security : [Select Id,
                                                        Name,
                                                        leankor__UserRoleId__c,
                                                        leankor__GUID__c, 
                                                        leankor__OwnerMoveCard__c,
                                                        leankor__OwnerEditCard__c, 
                                                        leankor__ValueStream__c 
                                                    From leankor__Security__c 
                                                    Where leankor__ValueStream__c = :valueStreamId]) {    

            securityMap.put(security.leankor__UserRoleId__c, security);          
        }
        
        for (UserRole userRole : userRoles) {            
            // avoiding multiple get to improve performance
            leankor__Security__c securityValue = securityMap.get(userRole.Id);
            //

            leankor__Security__c security = new leankor__Security__c();

            security.leankor__UserRoleID__c = userRole.Id;
            security.Name = userRole.Name; 

            // avoiding multiple get to improve performance
            //security.leankor__OwnerEditCard__c = securityMap.get(userRole.Id) != null ? securityMap.get(userRole.Id).leankor__OwnerEditCard__c : false;
            //security.leankor__OwnerMoveCard__c = securityMap.get(userRole.Id) != null ? securityMap.get(userRole.Id).leankor__OwnerMoveCard__c : false;
            security.leankor__OwnerEditCard__c = securityValue == null ? false : securityValue.leankor__OwnerEditCard__c;
            security.leankor__OwnerMoveCard__c = securityValue == null ? false : securityValue.leankor__OwnerMoveCard__c;
            //

            security.leankor__ValueStream__c = valueStreamId;      

            result.add(security);               
        }   
        
        return result; 
    }


    //-----------------------------------------------------Ending security related methods----------------------------------------    
    /***
     * This Method is use to get User records .
     * INPUT:  Valuestream Id  .
     * OUTPUT: Return list of User records  .
    */
    @RemoteAction
    global static List<User> getAllUsers(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior();
        IssueLogBehaviour issueLogBehaviour = new IssueLogBehaviour();
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        if (
            !valueStreamBehavior.isAccessible() ||
            !kanbanCardBehaviour.isAccessible() ||
            !subscriberBehavior.isAccessible()  ||
            !issueLogBehaviour.isAccessible()   ||
            !timeCardBehavior.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<USer> users = new List<User>();

        List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                                OwnerId, 
                                                                leankor__DefaultOwnerId__c 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :valueStreamId 
                                                                And leankor__isRecordDeleted__c = false 
                                                            Limit 1];

        if (valueStreams.size() > 0) {
            Set<String> allRelatedUserId = new Set<String>();

            allRelatedUserId.add(valueStreams[0].OwnerId);
            allRelatedUserId.add(valueStreams[0].leankor__DefaultOwnerId__c);

            List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                                OwnerId 
                                                            From leankor__KanbanCard__c 
                                                            Where leankor__ValueStream__c = :valueStreamId 
                                                                And leankor__isRecordDeleted__c = false 
                                                                And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                            Limit 10000];

            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                allRelatedUserId.add(kanbanCard.OwnerId);
            }

            for (Task task : [Select Id, 
                                        OwnerId 
                                    From Task 
                                    Where WhatId In :kanbanCards 
                                        And IsDeleted = false 
                                    Limit 50000 
                                    All Rows]) {

                allRelatedUserId.add(task.OwnerId);
            }
            
            List<leankor__Subscriber__c> subscribers = [Select Id, 
                                                                leankor__SubscriberId__c
                                                            From leankor__Subscriber__c 
                                                            Where leankor__KanbanCard__c In :kanbanCards 
                                                            Limit 10000];

            for (leankor__Subscriber__c subscriber : subscribers) {
                if (subscriber.leankor__SubscriberId__c != null) {
                    allRelatedUserId.add(subscriber.leankor__SubscriberId__c);
                }
            }

            List<leankor__IssueLog__c> issueLogs = [Select Id, 
                                                            leankor__AssignedTo__c, 
                                                            OwnerId 
                                                        From leankor__IssueLog__c 
                                                        Where leankor__KanbanCard__c In :kanbanCards 
                                                        Limit 10000];

            for (leankor__IssueLog__c issueLog : issueLogs) {
                if (issueLog.leankor__AssignedTo__c != null) {
                    allRelatedUserId.add(issueLog.leankor__AssignedTo__c);
                }

                allRelatedUserId.add(issueLog.OwnerId);
            }

            List<leankor__TimeCard__c> timeCards = [Select Id, 
                                                            leankor__AssignedTo__c, 
                                                            leankor__Assign_a_User__c, 
                                                            OwnerId 
                                                        From leankor__TimeCard__c 
                                                        Where leankor__KanbanCard__c In :kanbanCards 
                                                        Limit 10000];
            
            for (leankor__TimeCard__c timeCard : timeCards) {
                if (timeCard.leankor__AssignedTo__c != null) {
                    allRelatedUserId.add(timeCard.leankor__AssignedTo__c);
                }

                if (timeCard.leankor__Assign_a_User__c != null) {
                    allRelatedUserId.add(timeCard.leankor__Assign_a_User__c);
                }

                allRelatedUserId.add(timeCard.OwnerId);
            }

            //adding current login user in list - 21.03.2018
            allRelatedUserId.add(USER_ID_CONST);

            users = [Select Id, 
                            Name, 
                            Email, 
                            FirstName, 
                            LastName, 
                            SmallPhotoUrl, 
                            Username, 
                            UserType 
                        From User 
                        Where Id In :allRelatedUserId 
                        Limit 50000];
        }

        return users;
    }


    /***
     * This Method is use to get Project Rooms records .
     * INPUT:  Void  .
     * OUTPUT: Return all records of Project Room records  .
     */
     /*
        changes on 07/06/19  for security method return List of project if project has edit access.
     */
    @RemoteAction
    global static List<leankor__ProjectRoom__c> getProjectRooms() {
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        if (!projectRoomBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        List<leankor__ProjectRoom__c> projectRoomList = new  List<leankor__ProjectRoom__c >();

        List<leankor__ProjectRoom__c> projectRooms = [Select Id, 
                                                                Name, 
                                                                OwnerId,
                                                                leankor__Portfolio__r.Name,
                                                                UserRecordAccess.HasEditAccess
                                                            From leankor__ProjectRoom__c 
                                                            Order By Name 
                                                            Limit 50000];

        for (leankor__ProjectRoom__c projectRoom : projectRooms) {
            if (projectRoom.leankor__Portfolio__c != null 
            && projectRoom.UserRecordAccess.HasEditAccess) {
                
                projectRoomList.add(projectRoom);
            }
        }

        return projectRoomList;
    }


    // Inner class for Project Board Clone.
    global class ProjectBoardClone {
        global String PrjName;
        global String ProjectRoomId;
        global String ParentVS;
        global String LinkCloneRoomID;
        global String LinkCloneVSID;
        global String LinkCloneKanbanCardID;
        global Boolean Isrecalculate;
        public Boolean isShowWeekCalendar;
        
    }


    /***
     * This Method is use to Create Project Board records .
     * INPUT:  Object records  of Project Board clone Class  .
     * OUTPUT: Return new ValueStram Records   .
     */
    @RemoteAction
    global static leankor__ValueStream__c createProjectBoard(ProjectBoardClone projectBoardClone) {
        if ((String.isNotBlank(projectBoardClone.ParentVS) && Util.getSObjectName(projectBoardClone.ParentVS) != 'leankor__ValueStream__c')
        || (String.isNotBlank(projectBoardClone.ProjectRoomId) && Util.getSObjectName(projectBoardClone.ProjectRoomId) != 'leankor__ProjectRoom__c')
        || (String.isNotBlank(projectBoardClone.LinkCloneVSID) && Util.getSObjectName(projectBoardClone.LinkCloneVSID) != 'leankor__ValueStream__c')
        || (String.isNotBlank(projectBoardClone.LinkCloneRoomID) && Util.getSObjectName(projectBoardClone.ProjectRoomId) != 'leankor__ProjectRoom__c')
        || (String.isNotBlank(projectBoardClone.LinkCloneKanbanCardID) && Util.getSObjectName(projectBoardClone.LinkCloneKanbanCardID) != 'leankor__KanbanCard__c')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        SecurityBehavior securityBehavior = new SecurityBehavior();
        ProjectScheduleBlackoutBehaviour ProjectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();

        if (!valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isCreateable() 
        || !kanbanCardTemplateBehaviour.isAccessible() 
        || !kanbanCardTemplateBehaviour.isCreateable() 
        || !securityBehavior.isCreateable() 
        || !securityBehavior.isUpdateable() 
        || !ProjectScheduleBlackoutBehaviour.isAccessible() 
        || !ProjectScheduleBlackoutBehaviour.isCreateable() 
        || !attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__ValueStream__c returnVal = new leankor__ValueStream__c();

        /* already validated above
        if (String.isBlank(projectBoardClone.ParentVS)
        || String.isBlank(projectBoardClone.ProjectRoomId)) {
            System.debug('Error: Cannot proceed with an empty ValueStream or ProjectRoom Id');
            return returnVal;
        }
        */

        List<leankor__ProjectRoom__c> projectRooms = [Select Id, 
                                                                leankor__IsTemplateProject__c 
                                                            From leankor__ProjectRoom__c 
                                                            Where Id = :projectBoardClone.ProjectRoomId
                                                            Limit 1];

        if (projectRooms.isEmpty()) {
            System.debug('Error: Unable to find ProjectRoom record');
            return returnVal;
        }

        List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                                leankor__UrlLink__c ,
                                                                leankor__ManuallyScheduled__c,leankor__Mode__c,
                                                                leankor__EffortUnits__c,leankor__BoardType__c, 
                                                                leankor__IsTemplateBoard__c, 
                                                                leankor__ValueStreamCardLink__c, 
                                                                leankor__ValueStreamLink__c, 
                                                                leankor__BackgroundHeight__c, 
                                                                leankor__Backgroundwidth__c, 
                                                                leankor__JSONSnapshot__c, 
                                                                leankor__KanbanCardCount__c, 
                                                                leankor__KanbanCardThroughput__c, 
                                                                leankor__ProjectRoomLink__c, 
                                                                leankor__ProjectRoom__c, 
                                                                leankor__ValueStreamTemplate__c, 
                                                                Name, 
                                                                OwnerId, 
                                                                leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ScheduleBackward__c ,
                                                                leankor__ProjectBoardEndDateTime__c, // 11/04/2023 : retrieve end date time from valuestream
                                                                leankor__ProjectBoardStartDateTime__c // 11/04/2023 : retrieve start date time from valuestream
                                                            From leankor__ValueStream__c 
                                                            Where Id = :projectBoardClone.ParentVS                 
                                                            Limit 1];

        if (valueStreams.isEmpty()) {
            System.debug('Error: Unable to find ValueStream record');            
            return returnVal;
        }

        leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();

        leankor__ValueStream__c projectBoard = new leankor__ValueStream__c(
            Name = projectBoardClone.PrjName,
            leankor__PointPicklist__c = leanConstant.leankor__PointSequence__c,
            leankor__IsAgile__c = true,
            leankor__Effortindicator__c = 'Days',
            leankor__TaskDateCheck__c = !leanConstant.leankor__AvoidTaskDueDateCheck__c,
            leankor__ProjectRoom__c = projectBoardClone.ProjectRoomId,
            leankor__BackgroundHeight__c = valueStreams[0].leankor__BackgroundHeight__c,
            leankor__Backgroundwidth__c = valueStreams[0].leankor__Backgroundwidth__c,
            leankor__JSONSnapshot__c = valueStreams[0].leankor__JSONSnapshot__c,
            leankor__KanbanCardCount__c = valueStreams[0].leankor__KanbanCardCount__c,
            leankor__KanbanCardThroughput__c = valueStreams[0].leankor__KanbanCardThroughput__c,
            leankor__ProjectRoomLink__c = projectBoardClone.LinkCloneRoomID == '' ? valueStreams[0].leankor__ProjectRoomLink__c : projectBoardClone.LinkCloneRoomID,
            leankor__ValueStreamLink__c = projectBoardClone.LinkCloneVSID == '' ? valueStreams[0].leankor__ValueStreamLink__c : projectBoardClone.LinkCloneVSID,
            leankor__ValueStreamCardLink__c = projectBoardClone.LinkCloneVSID == '' ? valueStreams[0].leankor__ValueStreamCardLink__c : (projectBoardClone.LinkCloneKanbanCardID == '' ? null : projectBoardClone.LinkCloneKanbanCardID), //Card is not mandatory value for clone board.
            leankor__BoardType__c = valueStreams[0].leankor__BoardType__c,
            leankor__Isrecalculate__c = projectBoardClone.Isrecalculate,
            leankor__EffortUnits__c = valueStreams[0].leankor__EffortUnits__c,
            leankor__ManuallyScheduled__c = valueStreams[0].leankor__ManuallyScheduled__c,
            leankor__Mode__c = valueStreams[0].leankor__Mode__c,
            leankor__UrlLink__c = valueStreams[0].leankor__UrlLink__c,
            leankor__ProjectBoardLaunchDateTime__c = valueStreams[0].leankor__ProjectBoardLaunchDateTime__c,
            leankor__ProjectBoardStartDateTime__c = valueStreams[0].leankor__ProjectBoardStartDateTime__c, // 11/04/2023 : creating board with start date time from valuestream
            leankor__ProjectBoardEndDateTime__c = valueStreams[0].leankor__ProjectBoardEndDateTime__c,  // 11/04/2023 : creating board with end date time from valuestream
            leankor__ScheduleBackward__c = valueStreams[0].leankor__ScheduleBackward__c
        );

        String moduleBoardType = '';

        switch on valueStreams[0].leankor__BoardType__c {
            when 'Kanban Board' {
                moduleBoardType = '_System_Board';
            }
            when 'Whiteboard' {
                moduleBoardType = '_System_Whiteboard';
            }
            when 'DashBoard' {
                moduleBoardType = '_System_DashBoard';
            }
            when 'UberBoard' {
                moduleBoardType = '_System_UberBoard';
            }
            when 'Plan Board' {
                moduleBoardType = '_System_PlanBoard';
            }
        }

        // 24.01.2017 - yj - if project template is ON then every valuestream template is true.
        if (projectRooms[0].leankor__IsTemplateProject__c) {
            projectBoard.leankor__IsTemplateBoard__c = true;
        } else { // else - if project template is Off then first we check module select setup if select setup is check then template is off and if select setup is uncheck template is ON.
            Boolean flag = false;

            List<leankor__ProjectLaunchBehavior__c> projectLaunchBehaviors = [Select Id, 
                                                                                    leankor__DefaultBoard__c, 
                                                                                    leankor__Module__r.leankor__BoardType__c, 
                                                                                    leankor__Project__c, 
                                                                                    Name 
                                                                                From leankor__ProjectLaunchBehavior__c 
                                                                                Where leankor__Project__c = :projectBoardClone.ProjectRoomId 
                                                                                Limit 10000];
            
            //TODO: the following must be investigated
            for (leankor__ProjectLaunchBehavior__c projectLaunchBehavior : projectLaunchBehaviors) {               
                if (projectLaunchBehavior.leankor__Module__r.leankor__BoardType__c == moduleBoardType) {
                    flag = true;
                    break;
                }
            }

            if (flag) {
                projectBoard.leankor__IsTemplateBoard__c = false;
            } else {
                projectBoard.leankor__IsTemplateBoard__c = true;
            }
        }

        List<leankor__Security__c> securities = [Select Id, 
                                                        Name, 
                                                        leankor__ValueStream__c, 
                                                        leankor__GUID__c, 
                                                        leankor__OwnerEditCard__c, 
                                                        leankor__OwnerMoveCard__c, 
                                                        leankor__UserRoleId__c 
                                                    From leankor__Security__c 
                                                    Where leankor__ValueStream__c = :projectBoardClone.ParentVS];

        List<leankor__ProjectScheduleBlackout__c> projectBlackOutList = [Select Id,
                                                                                Name,
                                                                                leankor__EndDate__c,
                                                                                leankor__ProjectBoard__c,
                                                                                leankor__StartDate__c
                                                                            From leankor__ProjectScheduleBlackout__c
                                                                            Where leankor__ProjectBoard__c = :projectBoardClone.ParentVS
                                                                            Limit 10000];

        Savepoint sp = Database.setSavepoint();
        try {
            insert projectBoard;

            List<Attachment> copyAttachments = new List<Attachment>();

            for (Attachment[] attachment : [Select Body, 
                                                    ContentType, 
                                                    Description, 
                                                    Id, 
                                                    Name, 
                                                    ParentId 
                                                From Attachment 
                                                Where ParentId = :projectBoardClone.ParentVS 
                                                    And Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                                Limit 10000]) {

                for (Integer iCount = 0; iCount < attachment.size(); iCount++) {
                    Attachment newAttachment = new Attachment(
                            Name = attachment[iCount].Name,
                            ContentType = attachment[iCount].ContentType,
                            ParentId = projectBoard.Id,
                            Body = attachment[iCount].Body,
                            Description = attachment[iCount].Description);

                    copyAttachments.add(newAttachment);
                }
            }

            if (copyAttachments.size() > 0) {
                insert copyAttachments;
            }
            
            List<leankor__Security__c> userSecurities = new List<leankor__Security__c> ();

            for (leankor__Security__c security : securities) {
                leankor__Security__c userSecurity = new leankor__Security__c(
                    Name = security.Name,
                    leankor__UserRoleID__c = security.leankor__UserRoleID__c,
                    leankor__GUID__c = projectBoard.Id + '-' + security.leankor__UserRoleID__c,
                    leankor__OwnerMoveCard__c = security.leankor__OwnerMoveCard__c,
                    leankor__OwnerEditCard__c = security.leankor__OwnerEditCard__c,
                    leankor__ValueStream__c = projectBoard.Id
                );

                userSecurities.add(userSecurity);
            }

            if (userSecurities.size() > 0) {
                Schema.Sobjectfield externField = leankor__Security__c.Fields.leankor__GUID__c;
                Database.upsert(userSecurities, externField, true);
            }

            // Date: 06/11/2019 - To clone the black out records.
            List<leankor__ProjectScheduleBlackout__c> cloneProjectBlackOuts = new List<leankor__ProjectScheduleBlackout__c>();

            for (leankor__ProjectScheduleBlackout__c blackOut : projectBlackOutList) {
                leankor__ProjectScheduleBlackout__c blackOutInstance = new leankor__ProjectScheduleBlackout__c();

                blackOutInstance.Name = blackOut.Name;
                blackOutInstance.leankor__EndDate__c = blackOut.leankor__EndDate__c;
                blackOutInstance.leankor__StartDate__c = blackOut.leankor__StartDate__c;
                blackOutInstance.leankor__ProjectBoard__c = projectBoard.Id;

                cloneProjectBlackOuts.add(blackOutInstance);
            }  

            if (cloneProjectBlackOuts.size() > 0) {
                insert cloneProjectBlackOuts;
            }

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }       

        return projectBoard;
    }
    
    
    //Inner class for InviteU sers.
    global class InviteUsers {
        List<User> Users;
        String InvitePermissionSet;
        String InviteProfile;
        String InviteRole;
        PackageLicense PkgLicense;
    }


    /***
     * This Method is use  .
     * INPUT:    .
     * OUTPUT: Return  Records   .
    */
    @RemoteAction
    global static InviteUsers InviteUserValidation(List<String> users) {
        Set<String> setUsers = new Set<String>();
        for (String user : users) {
            if (String.isNotBlank(user)) {
                setUsers.add(user);
            }
        }
        if (setUsers.isEmpty()) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        InviteUSers inviteUser = new InviteUsers();

        List<PackageLicense> packageLicenses = [Select Id, 
                                                        AllowedLicenses, 
                                                        CreatedDate, 
                                                        ExpirationDate, 
                                                        NamespacePrefix, 
                                                        isProvisioned, 
                                                        Status, 
                                                        UsedLicenses 
                                                    From PackageLicense 

                                                    Where NamespacePrefix = :NAMESPACE_PREFIX 

                                                     

                                                    Limit 1];
        if (packageLicenses.size() > 0) {
            leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();


            


           /* List<User> userRecords = [Select Id, 
                                            FirstName, 
                                            Email, 
                                            LastName, 
                                            Name, 
                                            Username, 
                                            Alias, 
                                            UserRoleId, 
                                            SmallPhotoUrl 
                                        From User 
                                        Where UserName In :users 
                                            Or Email In :users 
                                        Limit 50000];*/
            String usersList = String.join(users, ' OR '); 
            List<List<User>> userList = [Find :usersList In Name Fields Returning User (Id, FirstName, Email, LastName, Name, Username, Alias, UserRoleId, SmallPhotoUrl Where UserName In :users Limit :2000)];

            inviteUser.InvitePermissionSet = leanConstant.leankor__InvitePermissionSet__c;
            inviteUser.InviteRole = leanConstant.leankor__InviteRole__c;
            inviteUser.InviteProfile = leanConstant.leankor__InviteProfile__c;
           // inviteUser.Users = userRecords;
            inviteUser.Users = userList[0];
            inviteUser.PkgLicense = packageLicenses[0];
        }

        return inviteUser;
    }


    /***
     * This Method is use to get picklist value of casestatus records .
     * INPUT:  void .
     * OUTPUT: Return list of picklist Records of casestatus   .
    */
    @RemoteAction
    global static List<Schema.PicklistEntry> getCaseStatus() {
        List<Schema.PicklistEntry> pickListValues;
        
        try {
            Schema.DescribeFieldResult statusField = Case.Status.getDescribe();
            pickListValues = statusField.getPicklistValues();
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return pickListValues;
    }


    /***
     * This Method is use to get picklist value of casetype records .
     * INPUT:  void .
     * OUTPUT: Return list of picklist Records of casetype   .
    */
    @RemoteAction
    global static List<Schema.PicklistEntry> getCaseType() {
        List<Schema.PicklistEntry> pickListValues;
        
        try {
            Schema.DescribeFieldResult typeField = Case.Type.getDescribe();
            pickListValues = typeField.getPicklistValues();
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());           
        }

        return pickListValues;
    }


    // Inner class for Project Board.
    global class ProjectBoard {
        global String Id;
        global String Name;
        global String OwnerID;
        global String OwnerName;
        global String OpportunityType;
        global String OpportunityCardCategory;
        global Boolean OpportunitySynchronization;
        global String OpportunityRecordType;
        global String OpportunityLeadSource;
        global String OpportunityRoleId;
        global String OpportunityRoleName;
        global String CaseType;
        global String CaseCardCategory;
        global Boolean CaseSynchronization;
        global String CaseRecordType;
        global String BoardType;
        global String ValueStreamCardLink;
        global String ValueStreamLinkID;
        global Integer BackgroundHeight;
        global Integer Backgroundwidth;
        global String JSONSnapshot;
        global Integer KanbanCardCount;
        global Integer KanbanCardThroughput;
        global String ProjectRoom;
        global String ValueStreamTemplate;
        global String StartDate;
        global String DueDate;
        global List<leankor.KanbanToGanttController.MasterContainer> children;
        global boolean expanded;
        global string PointPicklist;
        global Integer DaysPerSprint;
        global boolean TaskDueDateCheck;
        global boolean IsAgile;
        global string SprintStartDate;
        global string Effortindicator;
        global String AttachmentID;
        global Boolean TaskIndicator;
        global Boolean PortfolioMode;
        global Boolean SevenDayWorkWeek;
        global string DefaultCategory;
        global string DefaultOwner;
        global boolean IsTemplateBoard;
        global boolean DisableCalendarView;
        global string ViewChatterOptions;
        global Integer cardsRequireFilterConfirmation;
        global boolean DisableTaskAsMiniature;
        global boolean isShowCategoryColor;
	    public boolean hasEditAccess;
	    public boolean hasReadAccess;
	    public boolean hasDeleteAccess;
	    public String projectBoardLaunchDate;
        //Pratiksha -07/03/2022 : changes for add the ItemType in CH.
        public String ItemType;
        global Boolean ScheduleBackwards;
        //Pratiksha : 25/Nov/2023 : Variable added for showing the variable on CH while onloading methods.
        public Boolean isShowWeekCalendar;
    }


    /***
     * This Method is use to update Project Board records
     * INPUT: Object records  of Project Board Class
     * OUTPUT: Return Updated valuestream Records of casetype 
    */
    @RemoteAction
    global static leankor__ValueStream__c updateAgileBoard(ProjectBoard board) {
        if (String.isNotBlank(board.Id) && Util.getSObjectName(board.Id) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();

        if (!valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__ValueStream__c returnVal = new leankor__ValueStream__c();

    	//Update new field ProjectboardLaunchDateTime also when ValueStream updates
        List<leankor__ValueStream__c> valueStreams = [Select Id,  
                                                                leankor__DisableTaskAsMiniature__c,
                                                                leankor__boardtype__c, 
                                                                leankor__ProjectRoom__c, 
                                                                leankor__ProjectRoom__r.leankor__IsTemplateProject__c, 
                                                                leankor__DefaultCategory__c, 
                                                                leankor__SevenDayWorkWeek__c, 
                                                                leankor__PortfolioMode__c, 
                                                                leankor__ViewChatterOptions__c, 
                                                                leankor__DefaultOwnerID__c, 
                                                                leankor__Effortindicator__c, 
                                                                leankor__TaskIndicator__c, 
                                                                leankor__TaskDateCheck__c, 
                                                                leankor__IsAgile__c, 
                                                                leankor__SprintStartDate__c, 
                                                                leankor__DaysPerSprint__c, 
                                                                leankor__PointPicklist__c,
                                                                leankor__ProjectBoardLaunchDateTime__c 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :board.Id 
                                                            Limit 1];
                            
        if (valueStreams.size() > 0) {
            valueStreams[0].leankor__DisableCalendarView__c = board.DisableCalendarView == null ? false : board.DisableCalendarView;
            valueStreams[0].leankor__DefaultCategory__c = board.DefaultCategory == '' ? null : board.DefaultCategory;
            valueStreams[0].leankor__DefaultOwnerID__c = board.DefaultOwner == '' ? null : board.DefaultOwner;
            valueStreams[0].leankor__PointPicklist__c = board.PointPicklist;
            valueStreams[0].leankor__DaysPerSprint__c = board.DaysPerSprint;
            valueStreams[0].leankor__SprintStartDate__c = (DateTime)JSON.deserialize(JSON.serialize(board.SprintStartDate), DateTime.class);       
            valueStreams[0].leankor__IsAgile__c = board.IsAgile;
            valueStreams[0].leankor__Effortindicator__c = board.Effortindicator;
            valueStreams[0].leankor__PortfolioMode__c = board.PortfolioMode;
            valueStreams[0].leankor__TaskDateCheck__c = board.TaskDueDateCheck;
            valueStreams[0].leankor__TaskIndicator__c = board.TaskIndicator == null ? false : board.TaskIndicator;
            valueStreams[0].leankor__ViewChatterOptions__c = String.isBlank(board.ViewChatterOptions) ? 'Kanban Cards Chatter' : board.ViewChatterOptions;
            // 24.01.2017 - yj If a project is a template, the system must not allow the ?emplate Board?to be turned off from Board Preferences 
            valueStreams[0].leankor__IsTemplateBoard__c = valueStreams[0].leankor__ProjectRoom__r.leankor__IsTemplateProject__c ? true : (board.IsTemplateBoard == null ? false : board.IsTemplateBoard);
            valueStreams[0].leankor__CardsRequireFilterConfirmation__c = board.cardsRequireFilterConfirmation;
            valueStreams[0].leankor__DisableTaskAsMiniature__c = board.DisableTaskAsMiniature;
            valueStreams[0].leankor__ProjectBoardLaunchDateTime__c = board.projectBoardLaunchDate != null ? (DateTime)JSON.deserialize(board.projectBoardLaunchDate, DateTime.class) : valueStreams[0].leankor__ProjectBoardLaunchDateTime__c;
            
            // Tilak Raj Mahale: 17.06.2020 - Changes to update the parent records when board converted to template/non-template.
            List<leankor__KanbanCard__c> kanbanCards = [Select Id,
                                                                leankor__ValueStream__c,
                                                                leankor__ValueStreamCardLink__c
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__c = :valueStreams[0].Id
                                                            Limit 50000];

            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                Util.recalculateRecord.put(kanbanCard.leankor__ValueStreamCardLink__c, true);
            }

            Savepoint sp = Database.setSavepoint();
            try {
                update valueStreams;

                // Calling the updateParentCards to update the parent records
                leankor.RealTimeController.flowWithGSForAPI = true;
                leankor.RealTimeController.updateParentCards(kanbanCards);

                returnVal = valueStreams[0];
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());                
            }
        }

        return returnVal;
    }


    @RemoteAction
    global static leankor__ValueStream__c updateProjectBoard(ProjectBoard board) {
        if (String.isNotBlank(board.Id) && Util.getSObjectName(board.Id) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();

        if (!valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__ValueStream__c returnVal = new leankor__ValueStream__c();

        List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                                leankor__SprintStartDate__c, 
                                                                leankor__DaysPerSprint__c, 
                                                                leankor__PointPicklist__c, 
                                                                leankor__BoardType__c, 
                                                                leankor__ValueStreamCardLink__c, 
                                                                leankor__ValueStreamLink__c, 
                                                                leankor__BackgroundHeight__c, 
                                                                leankor__Backgroundwidth__c, 
                                                                leankor__JSONSnapshot__c, 
                                                                leankor__KanbanCardCount__c, 
                                                                leankor__KanbanCardThroughput__c, 
                                                                leankor__ProjectRoom__c, 
                                                                leankor__ValueStreamTemplate__c, 
                                                                Name, 
                                                                OwnerId, 
                                                                leankor__CaseType__c, 
                                                                leankor__CaseSynchronization__c 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :board.Id 
                                                            Limit 1];

        if (valueStreams.size() > 0) {
            valueStreams[0].leankor__CaseSynchronization__c = board.casesynchronization;
            valueStreams[0].leankor__CaseType__c = String.isBlank(board.CaseType) ? 'None' : board.CaseType;
            valueStreams[0].leankor__CaseCardCategory__c = board.CaseCardCategory;
            valueStreams[0].leankor__CaseRecordType__c = board.CaseRecordType;
            valueStreams[0].leankor__BoardType__c = board.BoardType != valueStreams[0].leankor__BoardType__c && String.isNotBlank(board.BoardType) ? board.BoardType : valueStreams[0].leankor__BoardType__c;
            
            try {
                update valueStreams;
                returnVal = valueStreams[0];
            } catch (DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }


    /***
     * This Method is use to Clone Preference record on Valuestream .
     * INPUT:  Object records  of Preference Class .
     * OUTPUT: Return Updated Preference Records.
    */
    @RemoteAction
    global static leankor__Preference__c clonePreference(Preference userPref) {
        if ((String.isNotBlank(userPref.ValueStream) && Util.getSObjectName(userPref.ValueStream) != 'leankor__ValueStream__c')
        || (String.isNotBlank(userPref.DerivedFrom) && Util.getSObjectName(userPref.DerivedFrom) != 'leankor__Preference__c')
        || (String.isNotBlank(userPref.CurrentUser) && Util.getSObjectName(userPref.CurrentUser) != 'User')) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
        if (!preferenceBehaviour.isAccessible() 
        || !preferenceBehaviour.isCreateable() 
        || !preferenceBehaviour.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__Preference__c userPreference = new leankor__Preference__c(
            Name = userPref.Name,
            leankor__GUID__c = userPref.GUID,
            leankor__FollowOnChatter__c = userPref.FollowOnChatter,
            leankor__SubscribeToCard__c = userPref.SubscribeToCard,
            leankor__CardPastDueDate__c = userPref.CardPastDueDate,
            leankor__Moved__c = userPref.Moved,
            leankor__PercentDone__c = userPref.PercentDone,
            leankor__TaskPastDueDate__c = userPref.TaskPastDueDate,
            leankor__isTaskCompleted__c = userPref.isTaskCompleted ? userPref.isTaskCompleted : false,
            leankor__ValueStream__c = userPref.ValueStream == '' ? null : userPref.ValueStream,
            leankor__DerivedFrom__c = userPref.DerivedFrom == '' ? null : userPref.DerivedFrom
        );

        Savepoint sp = Database.setSavepoint();
        try {        
            Schema.Sobjectfield externField = leankor__Preference__c.Fields.leankor__GUID__c;
            Database.Upsertresult uResult = Database.upsert(userPreference, externField, true);

            if (uResult.isSuccess()) {
                String prefId = uResult.getId();

                if (String.isNotBlank(userPref.ValueStream)) {
                    followOnChatters(prefId, userPref);
                    valueStreamPreference(prefId, userPref);
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());            
        }

        return userPreference;
    }


    /***
     * This Method is use to Clone Task record  .
     * INPUT:  Object records  of Task Class .
     * OUTPUT: Void.
    */
    @RemoteAction
    global static void cloneTask(List<TaskData> dataTasks) {
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();

        if (!taskBehaviour.isAccessible() 
        || !taskBehaviour.isCreateable() 
        || !feedItemBehaviour.isAccessible() 
        || !feedItemBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Set<String> taskIds = new Set<String>();

        for (TaskData dataTask : dataTasks) {
            taskIds.add(dataTask.Id);
        }

        List<Task> tasks = [Select Id, 
                                    Priority, 
                                    OwnerId, 
                                    Subject, 
                                    Status, 
                                    ActivityDate, 
                                    WhatId, 
                                    Description 
                                From Task 
                                Where WhatId In :taskIds 
                                    And IsDeleted = false 
                                Limit 10000 
                                All Rows];
        
        List<Task> cloneTasks = new List<Task>();

        for (Task task : tasks) {
            for (TaskData dataTask : dataTasks) {
                if (task.WhatId == dataTask.Id) {
                    Task clone = new Task();
                    
                    clone.Priority = task.Priority;
                    clone.OwnerID = task.OwnerID;
                    clone.Subject = task.Subject;
                    clone.Status = task.Status;
                    clone.ActivityDate = Date.valueOf(task.ActivityDate);
                    clone.WhatId = dataTask.WhatID;
                    clone.Description = task.Description;

                    cloneTasks.add(clone);
                }
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            insert cloneTasks;

            List<FeedItem> feeds = new List<FeedItem> ();
            for (Task cloneTask : cloneTasks) {
                FeedItem post = new FeedItem();
                post.ParentId = cloneTask.Id;
                post.Type = 'CreateRecordEvent';
                feeds.add(post);
            }

            insert feeds;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
    }
    
    
    // This Is Inner Class For cloneKanbancard
    global class cloneKanban {
        global String ParentCardID;
        global String ChildCardID;
    }
    

    /***
     * This Method is use to Clone Sticker on kanbancard   .
     * INPUT:  array of clonekanban class .
     * OUTPUT: return true or false.
    */
    @RemoteAction
    global static Boolean cloneStickerToKanbanCard(List<cloneKanban> cloneKanbans) {
        //Check CRUD / FLC behavior
        KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour();

        if (!kanbanCardStickerBehaviour.isAccessible() 
        || !kanbanCardStickerBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Set<String> kanbanCardIds = new Set<String>();

        for (cloneKanban cloneKanban : cloneKanbans) {
            if ((String.isNotBlank(cloneKanban.ParentCardID) && Util.getSObjectName(cloneKanban.ParentCardID) != 'leankor__KanbanCard__c')
            || (String.isNotBlank(cloneKanban.ChildCardID) && Util.getSObjectName(cloneKanban.ChildCardID) != 'leankor__KanbanCard__c')) {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

            kanbanCardIds.add(cloneKanban.ParentCardID);
        }

        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>();

        List<leankor__KanbanCardSticker__c> kanbanCardToStickers = [Select leankor__Sticker__c, 
                                                                            leankor__KanbanCard__c 
                                                                        From leankor__KanbanCardSticker__c 
                                                                        Where leankor__KanbanCard__c In :kanbanCardIds 
                                                                        Limit 10000];

        for (leankor__KanbanCardSticker__c kanbanCardToSticker : kanbanCardToStickers) {
            for (cloneKanban cloneKanban : cloneKanbans) {
                if (cloneKanban.ParentCardID == kanbanCardToSticker.leankor__KanbanCard__c) {
                    leankor__KanbanCardSticker__c kanbanCardSticker = new leankor__KanbanCardSticker__c(
                        leankor__KanbanCard__c = cloneKanban.ChildCardID,
                        leankor__Sticker__c = kanbanCardToSticker.leankor__Sticker__c
                    );

                    kanbanCardStickers.add(kanbanCardSticker);
                }
            }
        }

        Boolean returnVal = false;

        if (kanbanCardStickers.size() > 0) {
            try {
                insert kanbanCardStickers;
                returnVal = true;
            } catch (DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }


    /**
     *  Remote web service for update case status on move on kanbancard.
     *  INPUT  : Case ID, String of update Case Status.
     *  OUTPUT : Array of record type descirption of respected object .
    */
    @RemoteAction
    global static String updateCaseStatus(String caseId, String caseStatus) {
        if (String.isNotBlank(caseId) && Util.getSObjectName(caseId) != 'Case') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        CaseBehaviour caseBehaviour = new CaseBehaviour();
        if (!caseBehaviour.isAccessible() 
        ||  !caseBehaviour.isCreateable()
        ||  !caseBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<Case> remoteCases = [Select Id, 
                                            Subject, 
                                            Status 
                                        From Case 
                                        Where Id = :caseId 
                                        Limit 1];

        String returnVal = 'Success';

        if (remoteCases.size() > 0) {
            remoteCases[0].Status = (String.isBlank(caseStatus) ? 'None' : caseStatus);
            
            try {
                update remoteCases;
            } catch (Exception e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }


    /**
     *  Remote web service for get record type .
     *  INPUT  : Sobject Name.
     *  OUTPUT : Array of record type description of respected object .
    */
    //Pratiksha - 13/09/2021 : Fixes for internationalization of active record type.
    @RemoteAction
    global static List<RecordType> getActiveRecordType(String sObjName) {        
        if (String.isBlank(sObjName)) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select Description, 
                        DeveloperName, 
                        Id,         
                        IsActive, 
                        toLabel(Name), 
                        NamespacePrefix, 
                        SobjectType 
                    From RecordType 
                    Where SobjectType = :sObjName 
                        And IsActive = true 
                    Limit 10000];
    }

    
    /**
     *  Remote web service for Update Cmp records on kanban card Sobject.
     *  INPUT  : KanbanCardID,CmpID.
     *  OUTPUT : New CmpID().
    */
    @RemoteAction
    global static String updateCmpID(String kanbanCardId, String cmpId) {   
        if (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String returnVal = '';

        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                            Name, 
                                                            leankor__CmpId__c 
                                                        From leankor__KanbanCard__c 
                                                        Where Id = :kanbanCardId 
                                                        Limit 1];

        if (kanbanCards.size() > 0) {
            kanbanCards[0].leankor__CmpId__c = cmpId;

            try {
                update kanbanCards;
                returnVal = cmpId;
            } catch (DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }
    

    public class GSData {
        String channelName;
        String someJSONData;

        public GSData(String channelName, String someJSONData) {
            this.channelName = channelName;
            this.someJSONData = someJSONData;
        }
    }


    // Inner class for BulkStreaming and contain all records with card JSONData to Broadcast.
    global class bulkStreaming {       
        global String VSID;
        global String verb;
        global String sessionID;
        global String someJSONData;
        global List<String> cardIds;
        global List<leankor__KanbanCard__c> kanbansObjectList;
        global String kanbanVerb;
    }


    public class KanbanRecalculateParent {
        public String Id;
        public String valueStreamCardLinkId;
        public String masterContainerId;
        public Datetime startDate;
        public Datetime dueDate; 
    }
    

    /**
     *  Remote web service for managing bulk DML opration on kanbancad with broadcast.
     *  INPUT  : JSON of bulkStreaming Inner calss, KanbanVerb(Update,create,delete).
     *  OUTPUT : Void.
     */
    //26.09.2017 : for Generic Streaming and Bulk call
    @RemoteAction
    global static String manageBulkStreamingGS(List<bulkStreaming> realTimeStreaming, String kanbanVerb) {           
        manageBulkStreaming(realTimeStreaming, kanbanVerb);
        String kanbanCardIds = JSON.serialize(gskanbanCardIds);
        gskanbanCardIds.clear();

        return kanbanCardIds;
    }

    
    @RemoteAction
    global static void manageBulkStreaming(List<bulkStreaming> realTimeStreaming, String kanbanVerb) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable() 
        || !kanbanCardBehaviour.isCreateable() 
        || !realtimeTrackerBehavior.isCreateable()
        || !dependencyBehaviour.isAccessible()
        || !dependencyBehaviour.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Boolean updateParent = false;        
        List<ChatterFeed> chatterFeeds = new List <ChatterFeed>();
        List<leankor__RealtimeTracker__c> realtimeTrackers = new List <leankor__RealtimeTracker__c>();
        List<leankor__KanbanCard__c> kanbanCards = new List <leankor__KanbanCard__c>();
        List<Id> activityIds = new List<Id>();
        Set<String> kanbanCardStateChangeIds = new Set<String>();

        //Instance to hold List of broadcast events
		List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
		
		//mapKanbanRecalculateParents for mapping card with MasterContainer, Dates and parentId
        Map<String, KanbanRecalculateParent> mapKanbanRecalculateParents = new Map<String, KanbanRecalculateParent>();
        List<String> jsonListDataForBulkify = new List<String>();
        Boolean flagForBulkGS = false;
        String sessionId;
        for (bulkStreaming realTime : realTimeStreaming) {
            if (String.isNotBlank(realTime.VSID) 
            && Util.getSObjectName(realTime.VSID) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

            StateChangePackage stateChangePackage = null;
            JSONGroup myJSONGroup = new JSONGroup();
            String linkedCardVerb = '';             
            String linkedValueStream = '';
            String someJSONData = '';
            sessionId = realTime.SessionID;
                    
            if (realTime.Verb == 'AddMiniature' 
            || realTime.Verb == 'MoveKanbanCard' 
            || realTime.Verb == 'CreateKanbanCard' 
            || realTime.Verb == 'UpdateKanbanCard' 
            || realTime.Verb == 'UpdateMultipleKanbanCards' 
            || realTime.Verb == 'MoveActivity' 
            || realTime.Verb == 'IndentActivity' 
            || realTime.Verb == 'OutdentActivity' 
            || realTime.Verb == 'IndentOutdentActivityPDV') {
                
                CardStreamingPackage cardStreamingPackage = (CardStreamingPackage)JSON.deserialize(realTime.someJSONData, CardStreamingPackage.class);
                linkedCardVerb = cardStreamingPackage.linkedCardVerb; // taking verb to broadcast in other board.                 
                linkedValueStream = String.isNotBlank(cardStreamingPackage.ValueStreamLinkID) ? cardStreamingPackage.ValueStreamLinkID : cardStreamingPackage.ValueStream; // taking VSID to broadcast in other board. this Id will not same as ValueStreamId (very first arugment in this method).
                cardStreamingPackage.verb = realTime.Verb;
                someJSONData = JSON.serialize(cardStreamingPackage);
            
                //26.09.2017 : for Generic Streaming and Bulk call
                if (String.isNotBlank(cardStreamingPackage.Id) 
                && (realTime.Verb == 'AddMiniature' 
                || realTime.Verb == 'UpdateMultipleKanbanCards' 
                || realTime.Verb == 'MoveActivity' 
                || realTime.Verb == 'MoveKanbanCard' 
                || realTime.Verb == 'IndentActivity' 
                || realTime.Verb == 'OutdentActivity' 
                || realTime.Verb == 'IndentOutdentActivityPDV' 
                || realTime.Verb == 'UpdateKanbanCard')) { 

                    gskanbanCardIds.add(cardStreamingPackage.Id);
                }

                //RS 19/12/2018 If condition that will work for generic streaming case related broadcasting.                
                if ((cardStreamingPackage.flowWithGS == true || flowWithGSForAPI) && IS_GENERIC_STREAMING) {                                         
                    jsonListDataForBulkify.add(JSON.serialize(cardStreamingPackage));
                    flagForBulkGS = true;
                }
                                
            } else {
                //RS 19/4/2018 If condition that will work for generic streaming case related broadcasting when case is deleted.
                CardStreamingPackage cardStreamingPackage;

                //-- preventing for Task
                if (realTime.Verb != 'UpdateTask' && realTime.Verb != 'CreateTask' && realTime.Verb != 'DeleteTask') {                     
                    cardStreamingPackage = (CardStreamingPackage)JSON.deserialize(realTime.SomeJSONData, CardStreamingPackage.class);
                    
                    if ((cardStreamingPackage.flowWithGS == true || flowWithGSForAPI) && IS_GENERIC_STREAMING) {
                        cardStreamingPackage.verb = kanbanVerb;                                                           
                        jsonListDataForBulkify.add(JSON.serialize(cardStreamingPackage));
                        flagForBulkGS = true;
                    } 
                    
                    if (String.isNotBlank(cardStreamingPackage.Id) 
                    && (realTime.Verb == 'ExternalDependent' 
                    || realTime.Verb == 'ManageDependency' 
                    || realTime.Verb == 'UpdateKanbanCards')) {
                        gskanbanCardIds.add(cardStreamingPackage.Id);
                    }
                }
                
                if (cardStreamingPackage != null && realTime.Verb == 'ExternalDependent') {
                	cardStreamingPackage.verb = 'UpdateMultipleKanbanCards';
                	someJSONData = JSON.serialize(cardStreamingPackage);
                } else {
               		someJSONData = realTime.SomeJSONData;
                }
            }
            
            //for move activity we are handling broadcast from glueforce (glueforcePlanGantt)
            if(kanbanVerb != 'MoveActivity' 
            && kanbanVerb != 'IndentActivity' 
            && kanbanVerb != 'OutdentActivity' 
            && kanbanVerb != 'IndentOutdentActivityPDV' 
            && kanbanVerb != 'UpdateKanbanCards'
            && kanbanVerb != 'UpdateMultipleKanbanCards'
            && kanbanVerb != 'ExternalDependent') {

                if (IS_USING_PLATFORM_EVENT) {
				    //prepare content for Broadcast  and add to List of Events
				    broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(realTime.Verb, someJSONData, realTime.SessionID));
                }
                
                if (!putJSONGroup(someJSONData, myJSONGroup)) {
                    //TODO: string too large and then??? must investigate as it should not proceed if an error is encountered
					// string was too large
					System.debug('Error: JSON String is too large for broadcasting [' + realTime.Verb + '] for ValueStream: ' + realTime.vsId);
                    //throw new Util.LeanException('Error: String is too large for broadcasting');
				} else {
					leankor__RealtimeTracker__c aRealtimeTracker = new leankor__RealtimeTracker__c();
					
					aRealtimeTracker.leankor__SessionID__c = realTime.SessionID;
					aRealtimeTracker.leankor__ValueStream__c = realTime.VSID;
                    aRealtimeTracker.leankor__KanbanVerb__c = realTime.Verb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : realTime.Verb ;
					aRealtimeTracker.leankor__JSONDataSmall__c = myJSONGroup.JSON1;
					aRealtimeTracker.leankor__JSONDataSmall2__c = myJSONGroup.JSON2;
					aRealtimeTracker.leankor__JSONDataSmall3__c = myJSONGroup.JSON3;
					aRealtimeTracker.leankor__JSONDataSmall4__c = myJSONGroup.JSON4;
					aRealtimeTracker.leankor__JSONDataSmall5__c = myJSONGroup.JSON5;
					aRealtimeTracker.leankor__JSONDataSmall6__c = myJSONGroup.JSON6;
					aRealtimeTracker.leankor__JSONDataSmall7__c = myJSONGroup.JSON7;
                    aRealtimeTracker.leankor__JSONDataSmall8__c = myJSONGroup.JSON8;
                    
					realtimeTrackers.add(aRealtimeTracker);

                    if (String.isNotBlank(linkedCardVerb)
                    && linkedCardVerb == 'CardHierarchyToOther' 
                    && String.isNotBlank(linkedValueStream)
                    && linkedValueStream != realTime.VSID) {
                        if (IS_USING_PLATFORM_EVENT) {
                            //prepare content for Broadcast  and add to List of Events
                            broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(realTime.Verb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : realTime.Verb, someJSONData, realTime.SessionID));
                        }

                        leankor__RealtimeTracker__c aRealtimeTracker2 = new leankor__RealtimeTracker__c();
                        
                        aRealtimeTracker2.leankor__ValueStream__c = linkedValueStream;
                        aRealtimeTracker2.leankor__SessionID__c = realTime.SessionID;
                        aRealtimeTracker2.leankor__KanbanVerb__c = realTime.Verb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : realTime.Verb ;
                        aRealtimeTracker2.leankor__JSONDataSmall__c = myJSONGroup.JSON1;
                        aRealtimeTracker2.leankor__JSONDataSmall2__c = myJSONGroup.JSON2;
                        aRealtimeTracker2.leankor__JSONDataSmall3__c = myJSONGroup.JSON3;
                        aRealtimeTracker2.leankor__JSONDataSmall4__c = myJSONGroup.JSON4;
                        aRealtimeTracker2.leankor__JSONDataSmall5__c = myJSONGroup.JSON5;
                        aRealtimeTracker2.leankor__JSONDataSmall6__c = myJSONGroup.JSON6;
                        aRealtimeTracker2.leankor__JSONDataSmall7__c = myJSONGroup.JSON7;
                        aRealtimeTracker2.leankor__JSONDataSmall8__c = myJSONGroup.JSON8;
                                                
                        realtimeTrackers.add(aRealtimeTracker2);														
                    }
			    }			
			}
			
            if (realTime.Verb == 'AddMiniature' 
            || realTime.Verb == 'MoveKanbanCard' 
            || realTime.Verb == 'UpdateKanbanCard' 
            || realTime.Verb == 'UpdateMultipleKanbanCards' 
            || realTime.Verb == 'MoveActivity' 
            || realTime.Verb == 'IndentActivity' 
            || realTime.Verb == 'OutdentActivity' 
            || realTime.Verb == 'IndentOutdentActivityPDV' 
            || realTime.Verb == 'UpdateKanbanCards') {
				try {		
					stateChangePackage = (StateChangePackage)JSON.deserialize(realTime.someJSONdata, StateChangePackage.class);
				} catch (Exception e) {
                    System.debug('ERROR: while parsing JSON: ' + e.getMessage() + 'For JSON data: ' + realTime.SomeJSONData);
                    throw new Util.LeanException('Error: ' + e.getmessage());
                }
                
				leankor__KanbanCard__c updateKanban = new leankor__KanbanCard__c(
                    Id = stateChangePackage.Id,
                    leankor__GUID__c = stateChangePackage.GUID,
                    leankor__CardID__c = stateChangePackage.CardID,
                    leankor__Title__c = stateChangePackage.Title,
                    leankor__Point__c = stateChangePackage.Point,
                    Name = stateChangePackage.Name, // don't want to do this anymore; name not same as title!
                    leankor__Top__c = stateChangePackage.Top,
                    leankor__Bottom__c = stateChangePackage.Bottom,
                    leankor__Left__c = stateChangePackage.Left,
                    leankor__width__c = stateChangePackage.width,
                    leankor__Height__c = stateChangePackage.Height,
                    leankor__X__c = stateChangePackage.X,
                    leankor__Y__c = stateChangePackage.Y,
                    leankor__State__c = stateChangePackage.State,
                    leankor__ZoneGUID__c = stateChangePackage.ZoneID,
                    leankor__MasterContainer__c = stateChangePackage.MCForceID == '' ? null : stateChangePackage.MCForceID,
                    leankor__Swimlane__c = stateChangePackage.SWForceID == '' ? null : stateChangePackage.SWForceID,
                    leankor__Zone__c = stateChangePackage.ZoneForceID == '' ? null : stateChangePackage.ZoneForceID,
                    leankor__DurationUnits__c = stateChangePackage.DurationUnits,
                    leankor__EstimatedDuration__c = stateChangePackage.EstimatedDuration,
                    leankor__EffortRemaining__c = stateChangePackage.EffortRemaining,
                    leankor__Priority__c = stateChangePackage.Priority,
                    leankor__PercentComplete2__c = stateChangePackage.HarveyBall,
                    OwnerID = stateChangePackage.OwnerID,
                    leankor__color__c = stateChangePackage.Color,
                    leankor__KanbanCardTemplate__c = stateChangePackage.TemplateID == '' ? null : stateChangePackage.TemplateID,
                    leankor__DescriptionLong__c = stateChangePackage.Description,
                    leankor__AcceptanceCriteria__c = stateChangePackage.AcceptanceCriteria,
                    leankor__JSONData__c = stateChangePackage.JSONData,
                    leankor__JSONDefinition__c = stateChangePackage.JSONDefinition,
                    leankor__ValueStreamCardLink__c = stateChangePackage.ValueStreamCardLink == '' ? null : stateChangePackage.ValueStreamCardLink,
                    leankor__ValueStreamLink__c = stateChangePackage.ValueStreamLinkID == '' ? null : stateChangePackage.ValueStreamLinkID,
                    leankor__Account__c = stateChangePackage.account == '' ? null : stateChangePackage.account,
                    leankor__Contact__c = stateChangePackage.contact == '' ? null : stateChangePackage.contact,
                    leankor__Case__c = stateChangePackage.caseid == '' ? null : stateChangePackage.caseid,
                    leankor__ValueStream__c = stateChangePackage.ValueStream == null ? stateChangePackage.ValueStreamID : stateChangePackage.ValueStream,
                    leankor__Opportunity__C = stateChangePackage.Opportunity == '' ? null : stateChangePackage.Opportunity,
                    leankor__StartDateTime__c = stateChangePackage.StartDate,
                    leankor__DueDateTime__c = stateChangePackage.DueDate,
                    leankor__OnBudget__c = stateChangePackage.OnBudget,
                    leankor__OnQuality__c = stateChangePackage.OnQuality,
                    leankor__OnTime__c = stateChangePackage.OnTime,
                    leankor__StartDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(stateChangePackage.StartDate), DateTime.class)),
                    leankor__DueDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(stateChangePackage.DueDate), DateTime.class)),
                    leankor__UrlLink__c = stateChangePackage.UrlLink
                );
				
                if (stateChangePackage.isAtRisk != null) {
                    updateKanban.leankor__IsAtRisk__c = stateChangePackage.isAtRisk;
                }
                                        
                if (stateChangePackage.isOnHold != null) {	 	
                    updateKanban.leankor__IsOnHold__c = stateChangePackage.isOnHold;
                }
                
                if (realTime.Verb == 'UpdateKanbanCards') {
                    updateKanban.RecordTypeId = stateChangePackage.recordTypeId;
                }

                Kanban cardData = (Kanban)JSON.deserialize(realTime.someJSONdata, Kanban.class);
				
				if (cardData.HarveyBallDoneDate != null) {
	        		updateKanban.leankor__HarveyBallDoneDate__c = stateChangePackage.HarveyBall == 100 ? System.today(): cardData.HarveyBallDoneDate;
                }
                
	            if (cardData.PromiseCompletionDate != null) {      	
	        		updateKanban.leankor__PromiseCompletionDate__c = stateChangePackage.HarveyBall == 100 ? System.now(): cardData.PromiseCompletionDate;
	          	}

                KanbanRecalculateParent recalParent = new KanbanRecalculateParent();
				recalParent.Id = updateKanban.Id;
				recalParent.dueDate = updateKanban.leankor__DueDateTime__c;
				recalParent.startDate = updateKanban.leankor__StartDateTime__c;
				recalParent.valueStreamCardLinkId = updateKanban.leankor__ValueStreamCardLink__c;
				recalParent.masterContainerId = updateKanban.leankor__MasterContainer__c;
				mapKanbanRecalculateParents.put(recalParent.Id, recalParent);

				kanbanCardStateChangeIds.add(stateChangePackage.ID);					
				if (stateChangePackage.Order != null){
					updateKanban.leankor__Order__c = stateChangePackage.Order;
                }
                                 
                //checking null pointer exception
				/*1.250 --> Moving Milestone moves dates*/
                //For PG item do not send or update AG from KcUpdatePVCard                
                if (updateKanban.leankor__ValueStreamCardLink__c != null && stateChangePackage.BoardType!='UberBoard') {
					updateParent = true;
                    //adding valuestreamcardlink in list for updating parent RA 
                    activityIds.add(updateKanban.leankor__ValueStreamCardLink__c);                      
                }
                
				//yj:22.08.2017 updating RA according to card harvey ball status. 
				activityIds.add(updateKanban.Id);
				kanbanCards.add(UpdateKanban);
			}
        }
	   
        Savepoint sp = Database.setSavepoint();
        try {
            if (realtimeTrackers.size() > 0) {
                insert realtimeTrackers;
            }
          
            if (kanbanCards.size() > 0) {
                List<Task> oldTasks = new List<Task>();
                
                List<leankor__Kanbancard__c> listKanbanCards = [Select Id,  
                                                                        Name, 
                                                                        leankor__MasterContainer__c, 
                                                                        leankor__Valuestream__r.leankor__IsTemplateBoard__c, 
                                                                        leankor__MasterContainer__r.leankor__Type__c, 
                                                                        leankor__Valuestream__r.leankor__SevenDayWorkWeek__c, 
                                                                        leankor__StartDateTime__c, 
                                                                        leankor__DueDateTime__c,
                                                                        leankor__DueDate__c, 
                                                                        leankor__StartDate__c, 
                                                                        leankor__ValueStreamCardLink__c, 
                                                                        leankor__Valuestream__r.leankor__TaskDatecheck__c 
                                                                    From leankor__KanbanCard__c 
                                                                    Where Id In :kanbanCardStateChangeIds 
                                                                    Limit 10000];

                Map<String, List<Task>> mapTasks = new Map<String,List<Task>>();
                
                List<Task> taskRecords = [Select Id, 
                                                    WhatId,
                                                    ActivityDate 
                                                From Task 
                                                Where WhatId In :listKanbanCards 
                                                    And What.Type = 'leankor__KanbanCard__c' 
                                                    And IsDeleted = false 
                                                Limit 50000 
                                                All Rows];

                //find all Task records under each KanbanCard Record       	
                for (Task task : taskRecords) {
                    List<Task> taskList = mapTasks.containsKey(task.WhatId) ? mapTasks.get(task.WhatId) : new List<Task>();
                    taskList.add(task);  
                    mapTasks.put(task.WhatId, taskList);
                }
                
                //yj - 04.05.2018 getting first day of week from custom setting	
                leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
                Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();	
                Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
                
                for (leankor__Kanbancard__c listKanbanCard : listKanbanCards) {
                    KanbanRecalculateParent tempRecalParent = mapKanbanRecalculateParents.containsKey(listKanbanCard.Id) ? mapKanbanRecalculateParents.get(listKanbanCard.Id) : new KanbanRecalculateParent();
                    
                    if (tempRecalParent != null) {
                        Date newDuedate = tempRecalParent.dueDate.dateGMT();
                        Date newStartdate = tempRecalParent.startDate.dateGMT();
                    
                        //If master container is Template then do not update successor recalculate
                        //If master container is changed from Template to regular then Update is Successor recalculate
                        /*
                        Boolean isRecalForTemplateContainer = false;
                        if (listKanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template') {
                            if (listKanbanCard.leankor__MasterContainer__c != tempRecalParent.masterContainerId) {
                                isRecalForTemplateContainer = true;
                            }
                        }
                        */

                        Boolean isRecalForTemplateContainer = listKanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template' && listKanbanCard.leankor__MasterContainer__c != tempRecalParent.masterContainerId;

                        //When master container is not template then successorRecalculation only when date changed or card link is changed or master container changed to regular
                        //if ((listKanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template' && (listKanbanCard.leankor__DueDate__c != newDuedate) || (listKanbanCard.leankor__StartDate__c != newStartdate) || (listKanbanCard.leankor__ValueStreamCardLink__c !=  tempRecalParent.valueStreamCardLinkId)) || isRecalForTemplateContainer) {
                        if ((listKanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template' 
                        && (listKanbanCard.leankor__DueDate__c != newDuedate 
                        || listKanbanCard.leankor__StartDate__c != newStartdate 
                        || listKanbanCard.leankor__ValueStreamCardLink__c != tempRecalParent.valueStreamCardLinkId)) 
                        || isRecalForTemplateContainer) {

                            if(String.isNotBlank(listKanbanCard.leankor__ValueStreamCardLink__c)){
                                Util.recalculateRecord.put(listKanbanCard.leankor__ValueStreamCardLink__c, true);
                            }

                            if(String.isNotBlank(tempRecalParent.valueStreamCardLinkId)){
                                Util.recalculateRecord.put(tempRecalParent.valueStreamCardLinkId, true);
                            }
                        }
                    }
                    
                    if (mapTasks.get(listKanbanCard.ID) != null && mapTasks.get(listKanbanCard.ID).size() > 0) {                	
                        DateTime Duedate = (DateTime)(mapKanbanRecalculateParents.get(listKanbanCard.Id).dueDate).dateGMT();
                        dateTime Startdate = (DateTime)(mapKanbanRecalculateParents.get(listKanbanCard.Id).startDate).dateGMT();
                        
                        for (Task loopTask : mapTasks.get(listKanbanCard.ID)) {					
                            if (date.newinstance((startdate).year(), (startdate).month(), (startdate).day()) != date.newinstance((listKanbanCard.leankor__StartDateTime__c).year(), (listKanbanCard.leankor__StartDateTime__c).month(), (listKanbanCard.leankor__StartDateTime__c).day()) 
                            && date.newinstance((Duedate).year(), (Duedate).month(), (Duedate).day()) != date.newinstance((listKanbanCard.leankor__DueDateTime__c).year(), (listKanbanCard.leankor__DueDateTime__c).month(), (listKanbanCard.leankor__DueDateTime__c).day())) {
                                integer diff = (listKanbanCard.leankor__StartDateTime__c.Date()).daysBetween(StartDate.Date());
                                loopTask.ActivityDate = loopTask.ActivityDate + diff;
                            }
                            
                            if (loopTask.ActivityDate > Duedate && listKanbanCard.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                                loopTask.ActivityDate = date.newinstance((Duedate).year(), (Duedate).month(), (Duedate).day());
                            } else if (loopTask.ActivityDate < StartDate && listKanbanCard.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                                loopTask.ActivityDate = date.newinstance((StartDate).year(), (StartDate).month(), (StartDate).day());
                            }
                            
                            datetime taskDuedate = Datetime.newInstance(loopTask.ActivityDate.year(), loopTask.ActivityDate.month(), loopTask.ActivityDate.day(), 1, 1, 1);
                            
                            if (!listKanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) {							
                                loopTask.ActivityDate = Util.readNextWorkingDate(workWeek, taskDuedate, loopTask.ActivityDate);
                                
                            }
                            
                            oldTasks.add(loopTask);
                        }
                    }
                }
    
                Schema.Sobjectfield externField = leankor__KanbanCard__c.Fields.leankor__GUID__c;
                // Task update if card's start date / due date change and task is not inbetween.			
                Database.upsert(kanbanCards, externField, true); // GUID is the external unique key to match                    

                if (oldTasks.size() > 0) {
                    leankor.OpenTaskRestriction.updateTask(oldTasks);
                }

                if (updateParent){                   	                    	       				         				                       
                    leankor.realtimeController.KCupdatePVcard(JSON.serialize(kanbanCards));                                       
                }
                
                //updating parent RA percent completed 
                leankor.ProjectBoardCarousel.updateActivityPercentageComplete(activityIds);

                List<leankor__KanbanCard__c> newKanbanCardLists = [Select Id, 
                                                                            leankor__ProjectRoom__c,
                                                                            leankor__ValueStream__r.Name,
                                                                            leankor__TemplateBoard__c,
                                                                            leankor__MasterContainer__r.leankor__Type__c,
                                                                            leankor__ValueStream__r.leankor__projectRoom__c, 
                                                                            leankor__ValueStream__c, 
                                                                            leankor__ValueStream__r.leankor__BoardType__c, 
                                                                            Name, 
                                                                            OwnerId, 
                                                                            RecordType.Name 
                                                                        From leankor__KanbanCard__c 
                                                                        Where Id In :kanbanCardStateChangeIds];

                for (leankor__KanbanCard__c newKanbanCardList : newKanbanCardLists) {
                    //August 4 2017 : put template condition for prevent email notification to user for template borad
                    if(newKanbanCardList.leankor__TemplateBoard__c == LEANFALSE && newKanbanCardList.leankor__MasterContainer__r.leankor__Type__c != 'Template') {
                        ChatterFeed chatterFeed = new ChatterFeed();
                        chatterFeed.KanbanId = newKanbanCardList.Id;
                        chatterFeed.KanbanTitle = newKanbanCardList.Name;
                        //23.08.2017 : provide project name and valuestream name and card name on emil notification
                        chatterFeed.ProjectBoardName = newKanbanCardList.leankor__ProjectRoom__c + ' / ' + newKanbanCardList.leankor__ValueStream__r.Name;
                        
                        // added base salesforce URL to create card URl.
                        chatterFeed.kanbanURL = 'https://' + DomainCreator.getOrgMyDomainHostname();
                                        
                        if(newKanbanCardList.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard') {
                            if(newKanbanCardList.RecordType.Name!='MileStoneCard') {
                                chatterFeed.kanbanURL += (new PageReference('/apex/leankor__GanttView').getUrl()) + '?fid=' + newKanbanCardList.leankor__ValueStream__r.leankor__projectRoom__c + '&btype=projectgantt&' + 'Id=' + newKanbanCardList.leankor__ValueStream__c +'&cardid=';
                            } else {
                                chatterFeed.kanbanURL += (new PageReference('/apex/leankor__GanttView').getUrl()) + '?fid=' + newKanbanCardList.leankor__ValueStream__r.leankor__projectRoom__c + '&btype=projectgantt&' + 'Id=' + newKanbanCardList.leankor__ValueStream__c +'&cardid=&&ThisIsMilestone';
                            }
                            
                        } else {
                            if (newKanbanCardList.RecordType.Name != 'MileStoneCard') {
                                if (newKanbanCardList.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board' || newKanbanCardList.leankor__ValueStream__r.leankor__BoardType__c == 'Plan Board') {
                                    chatterFeed.kanbanURL += (new PageReference('/apex/leankor__KanbanBoard').getUrl()) + '?Id=' + newKanbanCardList.leankor__ValueStream__c + '&cardid=';
                                } else if (newKanbanCardList.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
                                    chatterFeed.kanbanURL += (new PageReference('/apex/leankor__PortfolioView').getUrl()) + '?Id=' + newKanbanCardList.leankor__ValueStream__c + '&cardid=';
                                } else {
                                    chatterFeed.kanbanURL += (new PageReference('/apex/leankor__VisualKanban').getUrl()) + '?Id=' + newKanbanCardList.leankor__ValueStream__c + '&cardid=';
                                }

                            } else {
                                chatterFeed.kanbanURL += (new PageReference('/apex/leankor__CalenderView').getUrl()) + '?Id=' + newKanbanCardList.leankor__ValueStream__c + '&cardid=&&ThisIsMilestone';
                            }
                        }
                        chatterFeed.AssignedUser = newKanbanCardList.OwnerID;
                        chatterFeeds.add(chatterFeed);
                    }
                }

                createChatterFeed(chatterFeeds, kanbanVerb);
            }

            if (IS_USING_PLATFORM_EVENT) {
                if(kanbanVerb == 'UpdateMultipleKanbanCards' || kanbanVerb == 'ExternalDependent'){
                    BroadcastEventPayload broadcastEventPayload = new BroadcastEventPayload();
                    broadcastEventPayload.cardIds = kanbanCardStateChangeIds;
                    broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(kanbanVerb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : kanbanVerb, JSON.serialize(broadcastEventPayload), sessionId));

                }
                
                if (broadcastEvents.size() > 0) {
                    //Publish BroadcastEvents
                    LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);
                }
            } else {
                if (flagForBulkGS) {    
                    if ((kanbanVerb == 'UpdateMultipleKanbanCards' || kanbanVerb == 'AddMiniature') && flowWithGSForAPI) {
                        Map<String, List<String>> broadcastContentMap =  new Map<String, List<String>>();
                        broadcastContentMap.put('', new List<String>(leankor.RealTimeController.gskanbanCardIds));   	 	
                        GenericStreamingController.sendBroadcastForBulkRecords(kanbanVerb, broadcastContentMap, USER_SESSION_ID_CONST);
                    } else {
                        GenericStreamingController.broadcastNotificationAsync(kanbanVerb, jsonListDataForBulkify);  
                    }               
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
    }


	/**
	 *  Remote web service for get Zone Records by remote calling.
	 *  INPUT  : valueStreamId,string Case Status.
	 *  OUTPUT : Array of Zone Object in respect to valueStreamId.
	*/
	@RemoteAction
	global static List<leankor__Zone__c> checkZoneStatus(String valueStreamId, String caseStatus) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        return [Select Id, 
                        leankor__OpportunityStageName__c, 
                        leankor__Bottom__c, 
                        leankor__CaseStatus__c, 
                        leankor__CmpId__c, 
                        leankor__CompletionRateUnits__c, 
                        leankor__CompletionRate__c, 
                        leankor__CSSLayout__c, 
                        leankor__DefaultHeight__c, 
                        leankor__Defaultwidth__c, 
                        leankor__EntryFlowName__c, 
                        leankor__ExitFlowName__c, 
                        leankor__GUID__c, 
                        leankor__Height__c, 
                        leankor__JSONDefinition__c, 
                        leankor__KanbanCardCount2__c, 
                        leankor__KanbanCardThroughput__c, 
                        leankor__kanbanSequence__c, 
                        leankor__LeadTime__c, 
                        leankor__Left__c, 
                        leankor__Title__c, 
                        leankor__Top__c, 
                        leankor__ValueStreamCardLink__c, 
                        leankor__ValueStreamLink__c, 
                        leankor__ValueStream__c, 
                        leankor__width__c, 
                        leankor__X__c, 
                        leankor__Y__c, 
                        leankor__zoneMode__c, 
                        leankor__ZoneTemplate__c, 
                        Name, 
                        OwnerId 
                    From leankor__Zone__c 
                    Where leankor__ValueStream__c = :valueStreamId 
                        And leankor__CaseStatus__c = :caseStatus 
                    Order By SystemModStamp Desc 
                    Limit 50000];
    }
    

	/**
	 *  Remote web service for get Report Records in MataData by remote calling.
	 *  INPUT  : ReportID.
	 *  OUTPUT : Report Records in HTML Page(incucing chats and table).
	*/
	@RemoteAction
	global static ReportFilters getReportMetadata(String reportId) {
        if (String.isBlank(reportId)) {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

		List<leankor__ValueStream__c> valueStreams = getValueStreams('');
		Reports.ReportDescribeResult reportDescribeResult = Reports.ReportManager.describeReport(reportId);
		List<ColumnFilter> columnFilters = new List<ColumnFilter> ();
		Reports.ReportMetadata reportMetaData = reportDescribeResult.getReportMetadata();
        String filterColumnName = '';
        
		if (reportMetaData.getReportFilters().size() > 0) {
			for (Integer i = 0; i < reportMetaData.getReportFilters().size(); i++) {
				String columnName = reportMetaData.getReportFilters()[i].getColumn();
				if (columnName == 'FK_NAME' || columnName.endsWith('ValueStream__c') || columnName.endsWith('ValueStream__c.Name')) {
                    filterColumnName = columnName;
                    break;
				}
			}
        }
        
		// All available Filter Operators
		Map<String, List<FilterSelectOption>> filterSelectOptions = new Map<String, List<FilterSelectOption>>();
		Map<String, List<Reports.FilterOperator>> filterOperators = Reports.ReportManager.getDataTypeFilterOperatorMap();

        for (String filterOperator : filterOperators.keySet()) {
			List<FilterSelectOption> filterSelectOptionOperators = new List<FilterSelectOption> ();
			// Append _DATA to match ColumnDataType from ReportTypeColumn
			filterSelectOptions.put(filterOperator.toUpperCase() + '_DATA', filterSelectOptionOperators);
			for (Reports.FilterOperator reportsFilterOperator : filterOperators.get(filterOperator)) {
				filterSelectOptionOperators.add(new FilterSelectOption(reportsFilterOperator.getName(), reportsFilterOperator.getLabel()));
			}
        }
        
		for (Reports.ReportTypeColumnCategory reportTypeColumnCategory : reportDescribeResult.getReportTypeMetadata().getCategories()) {
			for (Reports.ReportTypeColumn reportTypeColumn : reportTypeColumnCategory.getColumns().values()) {
				if (reportTypeColumn.getFilterable()) {
                    String dataType = '';
                    String reportTypeColumnName = reportTypeColumn.getName();
                    String reportTypeColumnDataTypeName = reportTypeColumn.getDataType().name();

					List<FilterSelectOption> dataTypeOperators = filterSelectOptions.get((reportTypeColumnDataTypeName == 'HTML_DATA' ? 'STRING_DATA' : reportTypeColumnDataTypeName));

                    dataType = reportTypeColumnName == 'FK_NAME' || reportTypeColumnName.endsWith('ValueStream__c') || reportTypeColumnName.endsWith('ValueStream__c.Name')
                        ? 'LIST_DATA' : reportTypeColumnDataTypeName;

                    ColumnFilter columnFilter = new ColumnFilter(
                        reportTypeColumn.getLabel(),
                        reportTypeColumnName,
                        dataType,
                        dataTypeOperators);

                    columnFilters.add(columnFilter);
                }
			}
        }
        
		ReportFilters reportFilters = new ReportFilters();
		reportFilters.Filters = columnFilters;
		reportFilters.FilterColumnName = filterColumnName;
        reportFilters.ValueStreams = valueStreams;
        
		return reportFilters;
    }
    

	global class ReportFilters {
		global List<ColumnFilter> Filters;
		global String FilterColumnName;
		global List<leankor__ValueStream__c> ValueStreams;
    }
    

	global class FilterSelectOption {
		global String Label {
			get;
			set;
		}
		global String Value {
			get;
			set;
		}
		global FilterSelectOption(String VAL, String LAB) {
			Value = VAL;
			Label = LAB;
		}
    }
    

	global class ColumnFilter {
		global ColumnFilter(String LAB, String Col, String DT, List<FilterSelectOption> DTOpts) {
			Label = LAB;
			Column = Col;
			DataType = DT;
			DataTypeOperators = DTOpts;
        }
        
        global ColumnFilter(){}
        
        global List<FilterSelectOption> DataTypeOperators {
			get;
			set;
        }
        
		// Values needed for apex:analytics component
		global String Column {
			get;
			set;
        }
        
		global String Operator {
			get;
			set;
        }
        
		global String Value {
			get;
			set;
		}
        
        // Values need for display and operator select list
		global String Label {
			get;
			set;
		}
        
        global String DataType {
			get;
			set;
		}
    }
    

	/**
	 *  Remote web service for create Kanban Card using gantt in this inner call to createKanbanCard() here trying to reuse old CreateKanbanCard() for gantt.
	 *  INPUT  : Value Stream ID, serialized Kanban Card record.
	 *  OUTPUT : returns array of Kanban Cards.
	*/
	@RemoteAction
    global static KanbanCardData createGanttCardGS(String valueStreamId, String remoteKanbanCard) {       
        // NOTE: Secure Coding input validation is inside createKanbanCards(valueStreamId, kanbancards) method

        KanbanCardData kanbanCardData = new KanbanCardData(); 

        try {
            kanbanCardData.cardList = createGanttCard(valueStreamId, remoteKanbanCard);
            kanbanCardData.kanbanIds = JSON.serialize(gskanbanCardIds);
            gskanbanCardIds.clear();
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return kanbanCardData;
    }  
    

	@RemoteAction
	global static List<leankor__KanbanCard__c> createGanttCard(String valueStreamId, String remoteKanbanCard) {		
		// NOTE: Secure Coding input validation is inside createKanbanCards(valueStreamId, kanbancards) method

        List<leankor__KanbanCard__c> newCards ;
        try {
            List<realTimeController.Kanban> kanbanCards = new List<realTimeController.Kanban>();	
            leankor.realTimeController.Kanban card = (leankor.realtimeController.Kanban)JSON.deserialize(remoteKanbanCard, (leankor.realtimeController.Kanban.Class));

            kanbanCards.add(card);

            newCards = realtimeController.createKanbanCards(valueStreamId, kanbanCards);

        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return newCards;
    }


    /**
	 * Inner class for Dependencies.
	*/
    global class Dependency {
        @AuraEnabled
		global string Id;
        @AuraEnabled
		global string FromId;
		global string FromVSID;
        @AuraEnabled
		global string To;
		global string ToVSID;
        @AuraEnabled
		global Integer Type;
        @AuraEnabled
		global Integer Lag;
        @AuraEnabled
		global string LagUnit;
	    global Decimal LagLeadDuration;
		public Boolean IsDependencyRecalculate;
		public Boolean IsExternalDependency;
    }
    

	global class DependencyStreaming {
		global String Id;
		global String GUID;
		global DateTime StartDate;
		global DateTime DueDate;
		global Decimal EstimatedDuration;
		global String DurationUnits;
		global String ItemType;
		global String OwnerID;
		global String AssignToId;
		//This field is used for calculation of AutoTranslationOfActivity
		public Integer totalDurationCount;
		public String ValueStreamID;
		public Boolean isDueDatePercentComplete;
		public String timeToProjectLaunch;
        global String ConstraintType;
        global DateTime ConstraintDate;
    }
    @AuraEnabled(cacheable=true)
    public static List<Dependency> retrieveDependencies(String valueStreamId, String boardType, List<String> remoteCardIds) {
        try {
            // Call the existing getDependency method
            return getDependency(valueStreamId, boardType, remoteCardIds);
        } catch (Util.LeanException e) {
            // Handle any exceptions and propagate them to the client
            throw new AuraHandledException(e.getMessage());
        }
    }

	/**
	 *  Remote web service for managing dependencies.
	 *  INPUT  : Value Stream ID.
	 *  OUTPUT : returns array of dependencies as required JS end.
	*/
    @AuraEnabled
	@RemoteAction
	global static List<Dependency> getDependency(String valueStreamId, String boardType, List<String> remoteCardIds) {
        Set<String> setValueStreamIds = new Set<String>();
        setValueStreamIds.add(valueStreamId);
        setValueStreamIds.addAll(remoteCardIds);
        for (String setValueStreamId : setValueStreamIds) {
            if (String.isNotBlank(setValueStreamId) && Util.getSObjectName(setValueStreamId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

		List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();
        
        //RS 23/1/2018 For performance removed leankor__KanbanCard__C,leankor__PredecessorType__c from query not using anywhere.
        // Tilak - 04/03/2020 - Changes for filtering soft deleted record and removing null condition from where clause.
		if (boardType == 'Card Hierarchy') {
            dependencies = [Select Id,
                                    leankor__LagLead__c,
                                    leankor__LagLeadUnit__c,
                                    leankor__GUID__c, 
                                    leankor__Predecessor__c, 
                                    leankor__Predecessor__r.leankor__ValueStream__c, 
                                    leankor__Successor__c, 
                                    leankor__Successor__r.leankor__ValueStream__c, 
                                    leankor__SuccessorType__c
                                From leankor__Dependency__c 
                                Where leankor__ValueStream__c = :valueStreamId 
                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
                                    And leankor__Predecessor__r.leankor__isRecordDeleted__c = false
                                    And leankor__Successor__r.leankor__isRecordDeleted__c = false
                                    And leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                    And leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                Limit 50000];

        //calling from dependency view and project dependency gantt
        } else if (boardType == 'ProjectDependencyGantt' || boardType == 'other') {
            dependencies = [Select Id, 
                                    leankor__LagLead__c,
                                    leankor__LagLeadUnit__c,
                                    leankor__GUID__c, 
                                    leankor__Predecessor__c, 
                                    leankor__Predecessor__r.leankor__ValueStream__c, 
                                    leankor__Successor__c, 
                                    leankor__Successor__r.leankor__ValueStream__c, 
                                    leankor__SuccessorType__c, 
                                    leankor__IsDependencyRecalculate__c 
                                From leankor__Dependency__c 
                                Where leankor__ValueStream__c In :remoteCardIds  
                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                    And leankor__Predecessor__r.leankor__isRecordDeleted__c = false
                                    And leankor__Successor__r.leankor__isRecordDeleted__c = false
                                    And leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                    And leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                Limit 50000];
        
		} else {
            List<leankor__KanbanCard__C> kanbanCards = [Select Id, 
                                                                Name 
                                                            From leankor__KanbanCard__c 
                                                            Where leankor__ValueStream__c = :valueStreamId 
                                                            Limit 10000];
            dependencies = [Select Id, 
                                leankor__LagLead__c,
                                leankor__LagLeadUnit__c,
                                leankor__GUID__c, 
                                leankor__Predecessor__c, 
                                leankor__Predecessor__r.leankor__ValueStream__c, 
                                leankor__Successor__c, 
                                leankor__Successor__r.leankor__ValueStream__c, 
                                leankor__SuccessorType__c, 
                                leankor__IsDependencyRecalculate__c 
                            From leankor__Dependency__c 
                            Where (leankor__Predecessor__c In :kanbanCards Or leankor__Successor__c In :kanbanCards) 
                                And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                And leankor__Predecessor__r.leankor__isRecordDeleted__c = false
                                And leankor__Successor__r.leankor__isRecordDeleted__c = false
                                And leankor__Predecessor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                And leankor__Successor__r.leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                            Limit 50000];
		}

        if (boardType == 'Kanban Board') {
            // Remove the self and duplicate dependency between the cards
            Set<String> removeDuplicateSet = new Set<String>();
            for (Integer i = 0; i < dependencies.size();) {
                if (dependencies[i].leankor__Successor__c == dependencies[i].leankor__Predecessor__c 
                || removeDuplicateSet.contains((String)(dependencies[i].leankor__Successor__c) + (String)(dependencies[i].leankor__Predecessor__c))) {
                    dependencies.remove(i);
                    continue;
                }

                removeDuplicateSet.add((String)(dependencies[i].leankor__Successor__c) + (String)(dependencies[i].leankor__Predecessor__c));
                removeDuplicateSet.add((String)(dependencies[i].leankor__Predecessor__c) + (String)(dependencies[i].leankor__Successor__c));
                i++;
            }
        }

        List<Dependency> dependencyLists = new List<Dependency>();

        for (leankor__Dependency__c dependency : dependencies) {
            if (dependency.leankor__GUID__c != null) {
                Dependency newDependency = new Dependency();

                newDependency.Id = dependency.leankor__GUID__c;
                newDependency.FromId = dependency.leankor__Predecessor__c;
                newDependency.FromVSID = dependency.leankor__Predecessor__r.leankor__ValueStream__C;
                newDependency.To = dependency.leankor__Successor__c;
                newDependency.ToVSID = dependency.leankor__Successor__r.leankor__ValueStream__C;
                newDependency.Lag = Integer.valueof(dependency.leankor__LagLead__c);
                newDependency.LagUnit = dependency.leankor__LagLeadUnit__c;
                newDependency.Type = dependency.leankor__SuccessorType__c == 'Start To Start' 
                    ? 0 : (dependency.leankor__SuccessorType__c == 'Start To Finish' 
                    ? 1 : (dependency.leankor__SuccessorType__c == 'Finish To Start' 
                    ? 2 : 3));
                
                //12.sep.2017 - added one more field for auto lead lag calculation
              //newDependency.LagLeadDuration = dependency.leankor__LagLeadDuration__c;
                newDependency.IsExternalDependency  = dependency.leankor__Predecessor__r.leankor__ValueStream__c != dependency.leankor__Successor__r.leankor__ValueStream__c;
                newDependency.IsDependencyRecalculate = dependency.leankor__IsDependencyRecalculate__c != null ? dependency.leankor__IsDependencyRecalculate__c : false; 
                dependencyLists.add(newDependency);
            }
        }

        return dependencyLists;
    }
    

	/**
	 *  Remote web service for managing dependencies.
	 *  INPUT  : Value Stream ID, array of dependencies.
	 *  OUTPUT : returns success or failure.
	 */
	@RemoteAction
	global static String ManageDependency(String valueStreamId, List<String> dependencies) {
        //Check CRUD / FLC behavior
  		DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!dependencyBehaviour.isCreateable() 
        || !dependencyBehaviour.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<String> cardIds = new List<String>();
        List<Dependency> dependencyLists = new List<Dependency>();

        for (String dependence : dependencies) {
            Dependency dependency = (Dependency)JSON.deserialize(dependence, Dependency.class);
            if ((String.isNotBlank(dependency.FromID) && Util.getSObjectName(dependency.FromID) != 'leankor__KanbanCard__c')|| (String.isNotBlank(dependency.To) &&Util.getSObjectName(dependency.To) != 'leankor__KanbanCard__c')) {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

            cardIds.add(dependency.FromID);
            cardIds.add(dependency.To);
            dependencyLists.add(dependency);
        }

        List<leankor__Dependency__c> dependencyDuplicateRecords = [Select leankor__GUID__c,
                                                                            leankor__Predecessor__c, 
                                                                            leankor__Successor__c
                                                                        From leankor__Dependency__c
                                                                        Where leankor__Predecessor__c In :cardIds
                                                                            And leankor__Successor__c In :cardIds
                                                                        Limit 50000];

        List<leankor__Dependency__c> dependencyRecords = new List<leankor__Dependency__c>();

        for (Dependency dependencyList : dependencyLists) {
            String currentGUID = '';
            Boolean isDependencyExist = false;

            // Checking GUID should not be blank
            if (String.isNotBlank(dependencyList.Id)) {

                // Checking if dependency exist between the card or not?
                for (leankor__Dependency__c dependencyDuplicateRecord : dependencyDuplicateRecords) {
                    if ((dependencyDuplicateRecord.leankor__Predecessor__c == dependencyList.FromID && dependencyDuplicateRecord.leankor__Successor__c == dependencyList.To)
                    || (dependencyDuplicateRecord.leankor__Successor__c == dependencyList.FromID && dependencyDuplicateRecord.leankor__Predecessor__c == dependencyList.To) ) {
                        isDependencyExist = true;
                        currentGUID = dependencyDuplicateRecord.leankor__GUID__c;
                        break;
                    }
                }

                // If we found existing dependency b/w cards then we continue; because we can't create another dependency b/w cards.
                leankor__Dependency__c dependency = new leankor__Dependency__c (
                    leankor__GUID__c = isDependencyExist ? currentGUID : dependencyList.Id,
                    leankor__ValueStream__c = valueStreamId == null && valueStreamId == '' ? valueStreamId : dependencyList.FromVSID,
                    leankor__Predecessor__c = dependencyList.FromID,
                    leankor__Successor__c = dependencyList.To,
                    leankor__LagLead__c = dependencyList.Lag,
                    leankor__LagLeadUnit__c = dependencyList.LagUnit,
                  //leankor__LagLeadDuration__c = dependencyList.LagLeadDuration,
                    leankor__SuccessorType__c = dependencyList.Type == 0 ? 'Start To Start' : (dependencyList.Type == 1 ? 'Start To Finish' : (dependencyList.Type == 2 ? 'Finish To Start' : 'Finish To Finish')),

                    //15.11.2018 added for relaxing rule new field - > IsDependencyRecalculate
                    // It will be set to true when dependency is External and requires recalculation
                    leankor__IsDependencyRecalculate__c = dependencyList.IsDependencyRecalculate != null ? dependencyList.IsDependencyRecalculate : false
                );
                
                dependencyRecords.add(dependency);
            }
        }

        if (dependencyRecords.size() > 0) {
            try {
                Schema.Sobjectfield externField = leankor__Dependency__c.Fields.leankor__GUID__c;
                Database.upsert(dependencyRecords, externField, true); 
            } catch (DmlException e) {
                System.debug('Error: trying to create dependency : ' + e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return 'Success';      
    }
    

	/**
	 *  Remote web service for removing dependencies.
	 *  INPUT  : Array of GUID
	 *  OUTPUT : returns success or failure.
	*/
	@RemoteAction
	global static String RemoveDependency(List<String> dependencyLists) {
        //Check CRUD / FLC behavior
  		DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!dependencyBehaviour.isAccessible() 
        || !dependencyBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__Dependency__c> dependencies = [Select Id, 
                                                            leankor__ValueStream__c,
                                                            leankor__Predecessor__c,
                                                            leankor__Successor__c
                                                        From leankor__Dependency__c 
                                                        Where leankor__GUID__c In :dependencyLists];

        if (dependencies.size() > 0) {
            //Changes added for soft deleting Dependency records.
            for (leankor__Dependency__c dependency : dependencies) {
                dependency.leankor__ValueStream__c = null;
                dependency.leankor__Predecessor__c = null;
                dependency.leankor__Successor__c = null;
            }

            try {
                update dependencies;
            } catch (DmlException e) {
                System.debug('Error: while removing dependency: ' + e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return 'Success';
    }
    

	/**
	 *  Remote web service for returning Opportunities according the paramertes.
	 *  INPUT  : offsetSize , filterValue , limits.
	 *  OUTPUT : Object of RecordDetails with subarray of Opportunities.
	*/
	@RemoteAction
	global static RecordDetails getOpportunities(Integer offsetSize, String filterValue, Integer limits, Boolean filter, String inputAccountId) {

        if (inputAccountId != 'All' && String.isNotBlank(inputAccountId) && Util.getSObjectName(inputAccountId) != 'Account') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

		

		Integer count;
        List<Opportunity> opportunityRecords = new List<Opportunity> ();
		List<Opportunity> opportunities = new List<Opportunity> ();
		List<Account> accounts = new List<Account> ();
        RecordDetails recordDetails = new RecordDetails();
        
		try {
			if (inputAccountId == 'All') {
				if(!filter) {
                    //TODO: remove filter on null values
                    if(filterValue.length() > 1){
                        List<List<Opportunity>> opportunityCount = [Find :filterValue In Name Fields Returning Opportunity (Id, Name Where (AccountId != null And IsClosed = false))];
                        count = opportunityCount[0].size();
                        List<List<Opportunity>> opportunityList = [Find :filterValue In Name Fields Returning Opportunity (Id, AccountId, Account.Name, Amount, IsClosed, Name, StageName Where IsClosed = false  Limit :limits Offset :offsetSize)];
                        opportunityRecords = opportunityList[0];
                    } else {
                    count = [Select Count() 
                                From Opportunity 
                                where AccountId != null 
                                        And IsClosed = false];

                        opportunityRecords = [Select Id, 
                                                    AccountId, 
                                                    Account.Name, 
                                                    Amount, 
                                                    IsClosed, 
                                                    Name, 
                                                    StageName 
                                                From Opportunity 
                                                Where IsClosed = false 
                                                Limit :limits 
                                                Offset :offsetSize];                                                
                    }
                    for (Opportunity opportunityRecord : opportunityRecords) {
                        if (opportunityRecord.AccountId != null) {
                            opportunities.add(opportunityRecord);
                        }
                    }
				} else {
                    accounts = [Select Id, 
                                        Name 
                                    From Account 
                                    Where OwnerId = :USER_ID_CONST
                                    Limit :limits 
                                    Offset: offsetSize];
                    if(filterValue.length() > 1){
                        List<List<Opportunity>> opportunityCount = [Find :filterValue In Name Fields Returning Opportunity (Id, Name Where (AccountId In : accounts And IsClosed = false))];
                        count = opportunityCount[0].size();
                        List<List<Opportunity>> opportunityList = [Find :filterValue In Name Fields Returning Opportunity (Id, AccountId, Account.Name, Amount, IsClosed, Name, StageName Where (IsClosed = false And AccountId In :accounts) Limit :limits Offset :offsetSize)];
                        opportunities = opportunityList[0];
                    } else {
                    count = [Select Count()
                                From Opportunity 
                                Where AccountId In :accounts 
                                        And IsClosed = false];

                    opportunities = [Select Id, 
                                            AccountId, 
                                            Account.Name, 
                                            Amount, 
                                            IsClosed, 
                                            Name, 
                                            StageName 
                                        From Opportunity 
                                        Where AccountId In :accounts 
                                            And IsClosed = false 
                                        Limit :limits 
                                        Offset :offsetSize];
				    }
				}
			} else {
                if(filterValue.length() > 1){
                    List<List<Opportunity>> opportunityCount = [Find :filterValue In Name Fields Returning Opportunity (Id, Name Where (AccountId = : inputAccountId And IsClosed = false))];
                    count = opportunityCount[0].size();
                    List<List<Opportunity>> opportunityList = [Find :filterValue In Name Fields Returning Opportunity (Id, AccountId, Account.Name, Amount, IsClosed, Name, StageName Where (IsClosed = false And AccountId = :inputAccountId) Limit :limits Offset :offsetSize)];
                    opportunities = opportunityList[0];
                } else {
                count = [Select Count() 
                            From Opportunity 
                            Where IsClosed = false 
                                    And AccountId = :inputAccountId ];

                opportunities = [Select Id, 
                                        AccountId, 
                                        Account.Name, 
                                        Amount, 
                                        IsClosed, 
                                        Name, 
                                        StageName 
                                    From Opportunity 
                                    Where IsClosed = false 
                                        And AccountId = :inputAccountId 
                                    Limit :limits 
                                    Offset :offsetSize];
                }
            }
            
			recordDetails.Count = count;
			recordDetails.OffsetSize = offsetSize;
            recordDetails.Opportunities = opportunities;
            
		} catch (Exception e) {
            System.debug('Error: while getting Opportunities: ' + e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());            
        }
        
		return recordDetails;
    }
    

	/**
	 *  Remote web service for bulk dependency streaming .
	 *  INPUT  : ValueStream ID, array of Dependency as string, Verb.
	 *  OUTPUT : returns success or failure.
	*/
	@RemoteAction
	global static String DependencyStreaming(String valueStreamId, List<String> realTimeStreaming, String kanbanVerb, String clientSessionId) {

        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        try {						
            leankor.GenericStreamingController.createRealtimeTracker(valueStreamId, kanbanVerb, realTimeStreaming , clientSessionId);	
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

		return 'Success';
    }
    

	/**
	 *  Remote web service for get all dependent card by filter of valuestream  .
	 *  INPUT  : valueStreamId.
	 *  OUTPUT : returns Array of cards ID.
	*/
	@RemoteAction
	global static List<String> getDependentCards(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
        
        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                            leankor__TimeToProjectLaunch__c, 
                                                            leankor__ValueStream__c,
                                                            leankor__ValueStream__r.leankor__SevenDayWorkWeek__c, 
                                                            (Select leankor__AssignedTo__c 
                                                                From leankor__ResourceAssignments__r 
                                                                Where leankor__AssignedTo__c = :USER_ID_CONST),
                                                            (Select 
                                                                    Id,
                                                                    leankor__Mode__c,
                                                                    leankor__ManuallyScheduled__c,
                                                                    leankor__EffortActual__c,
                                                                    leankor__EffortUnits__c,
                                                                    leankor__ConstraintDateTime__c,
                                                                    leankor__ScheduleConstraint__r.leankor__Type__c  											 
                                                                From leankor__ScheduleModes__r
                                                            ),
                                                            OwnerId,
                                                            leankor__BoardType__c, 
                                                            RecordType.Name, 
                                                            leankor__DueDateTime__c, 
                                                            leankor__DurationUnits__c, 
                                                            leankor__EstimatedDuration__c, 
                                                            leankor__GUID__c, 
                                                            leankor__StartDateTime__c 
                                                        From leankor__KanbanCard__c 
                                                        Where Id In :RealTimeControllerHelper.getDependentItems(valueStreamId) 
                                                        Limit 50000];

        Map<Id, Boolean> mapValueStreams = new Map <Id, Boolean>();

        for(leankor__KanbanCard__c kanbanCard : kanbanCards){
            mapValueStreams.put(kanbanCard.leankor__ValueStream__c, kanbanCard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c);
        }

        // Get the blackout records
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> mapBlackouts =  leankor.RealTimeControllerHelper.getBlackOutRecords(mapValueStreams.keySet());

		leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
        Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0 || leanConstant.leankor__FirstDayOfTheWeek__c > 6 
            ? 1 
            : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();
		
        Map<Id, leankor.Util.WorkWeek> mapWorkWeeks = new Map<Id, leankor.Util.WorkWeek>();

        for(Id key : mapValueStreams.keySet()){
            leankor.Util.WorkWeek workWeek = new leankor.Util.WorkWeek(firstDayOfWeek, mapValueStreams.get(key) ? 7 : 5, mapBlackouts.get(key));
            mapWorkWeeks.put(key, workWeek);
        }

        List<String> tempDependencies = new List<String>();

		for (leankor__KanbanCard__c kanban : kanbanCards) {
            leankor.RealTimeController.DependencyStreaming dependencyStreaming = new leankor.RealTimeController.DependencyStreaming();
            
			dependencyStreaming.Id = kanban.Id;
			dependencyStreaming.GUID = kanban.leankor__GUID__C;
			dependencyStreaming.StartDate = kanban.leankor__StartDateTime__c;
			dependencyStreaming.DueDate = kanban.leankor__DueDateTime__c;
			dependencyStreaming.EstimatedDuration = kanban.leankor__EstimatedDuration__c;
			dependencyStreaming.DurationUnits = kanban.leankor__DurationUnits__c;
			dependencyStreaming.ItemType = kanban.Recordtype.name == 'MileStoneCard' ? 'MileStoneCard' : 'KC';	
			dependencyStreaming.OwnerID = kanban.OwnerId;
			dependencyStreaming.timeToProjectLaunch = String.valueOf(kanban.leankor__TimeToProjectLaunch__c);

			//Date 02/05/19 check DueDate Percent Complete. 
			if(kanban.leankor__BoardType__c!='UberBoard'){
                dependencyStreaming.isDueDatePercentComplete = GanttTaskBoard.hasSeventyPercentDueDate(kanban, mapWorkWeeks.get(kanban.leankor__ValueStream__c));
			}
			
			if(kanban.leankor__ResourceAssignments__r != null && kanban.leankor__ResourceAssignments__r.size() > 0)
			{
				dependencyStreaming.AssignToId = kanban.leankor__ResourceAssignments__r[0].leankor__AssignedTo__c;
			}
            //Changes : Check Constraint setting enable or not.
            if(kanban.leankor__ScheduleModes__r.Size() > 0 && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS ){
                dependencyStreaming.ConstraintType = kanban.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c;
                dependencyStreaming.ConstraintDate = kanban.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c;
            }
			dependencyStreaming.ValueStreamID = kanban.leankor__ValueStream__c;
			tempDependencies.add(JSON.Serialize(dependencyStreaming));
        }
        
		return tempDependencies;
    }
    

	/**
	 * Inner class for Zone Kanban Action.
	*/
	global class ZoneKanbanAction {
		global String Action;
		global String KanbanID;
		global String ZoneID;
		global String SwimlaneID;
		global String MasterContainerID;
		global String VSID;
		global String OtherZoneID;
		global String OtherSwimlaneID;
		global String OtherMasterContainerID;
		global String SessionID;
    }
    

	/**
	 *  Remote web service for bulk zone change streaming .
	 *  INPUT  : array of ZoneKanbanAction class.
	 *  OUTPUT : returns success or failure.
	*/
	@RemoteAction
	global static String enterTheZoneBulkify(List<ZoneKanbanAction> zoneKanbanActions) {
        //Check CRUD / FLC behavior
  		ZoneBehavior zoneBehavior = new ZoneBehavior();
        ZoneKanbanActionBehavior zoneKanbanActionBehavior = new ZoneKanbanActionBehavior();
          
  		if (!zoneBehavior.isAccessible() 
        || !zoneBehavior.isUpdateable()
        || !zoneKanbanActionBehavior.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

		Decimal decimalHours = 0;
		Integer kanbanCount = 1;
		List<String> zoneIds = new List<String>();
		Map<String, leankor.CardHierarchyController.TempMasterContainer> mapZoneIds = new Map<String, leankor.CardHierarchyController.TempMasterContainer>();
        List<leankor__ZoneKanbanAction__c> newZoneKanbanActions = new List<leankor__ZoneKanbanAction__c> ();
        
		for (ZoneKanbanAction zoneKanbanAction : zoneKanbanActions) {
			zoneIds.add(zoneKanbanAction.ZoneID);
        }
        
        List<leankor__Zone__c> zones = [Select Id, 
                                                leankor__GUID__c, 
                                                leankor__KanbanCardCount2__c, 
                                                Name, 
                                                OwnerId, 
                                                leankor__Swimlane__c 
                                            From leankor__Zone__c 
                                            Where leankor__GUID__c In :zoneIds 
                                            Limit 10000];
        
        for (leankor__Zone__c zone : zones) {
			mapZoneIds.put(zone.leankor__GUID__C, (new leankor.CardHierarchyController.TempMasterContainer(zone.Id, zone.Name, zone.leankor__Swimlane__c, 0)));
			zone.leankor__KanbanCardCount2__c += kanbanCount;
		}

        Map<String, leankor.CardHierarchyController.TempMasterContainer> swims = new Map<String, leankor.CardHierarchyController.TempMasterContainer>();
        for (leankor__Swimlane__c swimLane: [Select Id, 
                                                        leankor__ValueStream__c, 
                                                        Name, 
                                                        leankor__MasterContainer__c, 
                                                        (Select Id, 
                                                                Name, 
                                                                leankor__Swimlane__c 
                                                            From leankor__Swimlane__c.leankor__Zones__r 
                                                            Where Id In :zoneIds)
                                                    From leankor__Swimlane__c 
                                                    Limit 10000]) {

			swims.put(swimLane.Id, (new leankor.CardHierarchyController.TempMasterContainer(swimLane.Id, swimLane.Name, swimLane.leankor__MasterContainer__c, 0)));
        }
        
        for (ZoneKanbanAction zoneKanbanAction : zoneKanbanActions) {
            leankor.CardHierarchyController.TempMasterContainer tempZone = mapZoneIds.get(zoneKanbanAction.ZoneID);
            leankor.CardHierarchyController.TempMasterContainer tempSwim = new leankor.CardHierarchyController.TempMasterContainer();

            if (swims.ContainsKey(tempZone.ParentID)) {
                tempSwim = swims.get(tempZone.ParentID);
            }

            // commented out for this is not needed
            //zoneIds.add(zoneKanbanAction.ZoneID);

            leankor__ZoneKanbanAction__c newZoneKanbanAction = new leankor__ZoneKanbanAction__c(
                leankor__KanbanCard2__c = zoneKanbanAction.KanbanID,
                leankor__Zone2__c = tempZone.Id,
                leankor__Swimlane__c = swims.containsKey(tempZone.ParentID) ? tempSwim.Id : null,
                leankor__MasterContainer__c = swims.containsKey(tempZone.ParentID) ? tempSwim.ParentID : null,
                leankor__ValueStream__c = zoneKanbanAction.VSID,
                leankor__ActionType2__c = zoneKanbanAction.Action,
                leankor__OtherZone__c = zoneKanbanAction.OtherZoneID == '' ? null : zoneKanbanAction.OtherZoneID,
                leankor__OtherSwimlane__c = zoneKanbanAction.OtherSwimlaneID == '' ? null : zoneKanbanAction.OtherSwimlaneID,
                leankor__OtherMasterContainer__c = zoneKanbanAction.OtherMasterContainerID == '' ? null : zoneKanbanAction.OtherMasterContainerID,
                leankor__SessionID__c = zoneKanbanAction.SessionID,
                leankor__WaitTime2__c = decimalHours
            );

            newZoneKanbanActions.add(newZoneKanbanAction);
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            if (newZoneKanbanActions.size() > 0) {
                insert newZoneKanbanActions;
            }

            if (zones.size() > 0) {
                update zones;
            }
        } catch (DmlException e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());            
        }

        return 'Success';
    }


    /**
     * Inner class for ChatterFeedStats.
     */
    global class ChatterFeedStats {
        public String ID;
        public String Name;
        public Decimal TaskCount;
        public Decimal ChatterCount;
        public Integer CountUnDoneTask;
        public List<leankor__Sticker__C> KanbanStickers;
        public List<taskUsers> TaskUserNames;
        global ChatterFeedStats() {}

        global ChatterFeedStats(String ID, String Name, Decimal TaskCount, List<leankor__Sticker__C> KanbanStickers, Decimal ChatterCount, Integer CountUnDoneTask ) {
            this.ID = ID;
            this.Name = Name;
            this.TaskCount = TaskCount;
            this.KanbanStickers = KanbanStickers;
            this.ChatterCount = ChatterCount;
            this.CountUnDoneTask = CountUnDoneTask;
            this.TaskUserNames = TaskUserNames;
        }

        global ChatterFeedStats(String ID, String Name, Decimal TaskCount, List<leankor__Sticker__C> KanbanStickers, Decimal ChatterCount, Integer CountUnDoneTask, List<taskUsers> TaskUserNames) {
			this.ID = ID;
			this.Name = Name;
			this.TaskCount = TaskCount;
			this.KanbanStickers = KanbanStickers;
			this.ChatterCount = ChatterCount;
			this.CountUnDoneTask = CountUnDoneTask;
            this.TaskUserNames = TaskUserNames;
		}
    }
    

    global class taskUsers {
	    String ID;
	    String TaskUserName;
	    String TaskUserId;
	    
	    global taskUsers() {}
	    	    
	    global taskUsers(String ID,String TaskUserId, String TaskUserName) {
	     	this.ID = ID;
	     	this.TaskUserName = TaskUserName;
	     	this.TaskUserId = TaskUserId;
        }
        
	    global taskUsers(String ID, String TaskUserName){
     		this.ID = ID;
     		this.TaskUserName = TaskUserName;     		
     	}
    }
    

    /**
     *  Remote web service for Get All Chatter of kanban card with respect to valuestream ID.
     *  INPUT  : Value Stream ID.
     *  OUTPUT : returns array of ChatterFeedstat class(card ID, chatter count, task count).
    */
    @RemoteAction
    global static List<ChatterFeedStats> getAllChatterStats(String valueStreamId) { 
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<ChatterFeedStats> chatterFeedStats = new List<ChatterFeedStats>(); 

		List<leankor__KanbanCard__c> kanbanCards = [Select Id,  
                                                            Name, 
                                                            leankor__Case__c, 
                                                            leankor__Opportunity__c, 
                                                            leankor__ValueStream__r.leankor__ViewChatterOptions__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c = :valueStreamId
                                                            And leankor__isRecordDeleted__c = false 
                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                        Limit 50000];
       
        if (kanbanCards.size() > 0) {
            Map<String, List<Task>> mapTasks = new Map<String, List<Task>>();

            //query task records and put results in a list        	
            List<Task> taskRecords = [Select Id, 
                                                Status,
                                                Owner.Name,
                                                WhatId 
                                            From Task 
                                            Where WhatId In :kanbanCards 
                                                And What.Type = 'leankor__KanbanCard__c' 
                                                And IsDeleted = false 
                                            Limit 50000 
                                            All Rows];
            
            //find all Task records under each KanbanCard Record       	
            for(Task taskRecord : taskRecords) {
                List<Task> tasks = mapTasks.containsKey(taskRecord.WhatId) ? mapTasks.get(taskRecord.WhatId) : new List<Task>();
                tasks.add(taskRecord);  
                mapTasks.put(taskRecord.WhatId, tasks);
            }
            
            List<leankor__KanbanCard__Feed> kanbanCardFeeds = new List<leankor__KanbanCard__Feed>();

            List<leankor__KanbanCard__Feed> kanbanCardFeedRecords = [Select Id, 
                                                                            ParentId,
                                                                            Type 
                                                                        From leankor__KanbanCard__Feed 
                                                                        Where ParentId In :kanbanCards 
                                                                        Limit 50000];
            

            for (leankor__KanbanCard__Feed kanbanCardFeedRecord : kanbanCardFeedRecords) {
                if (kanbanCardFeedRecord.Type != 'TrackedChange') {
                    kanbanCardFeeds.add(kanbanCardFeedRecord);
                }
            }
        
            Set<String> caseIds = new Set<String>();
            Set<String> opportunityIds = new Set<String>();
            
            for (leankor__KanbanCard__C kanbanCard : kanbanCards) {
                if (kanbanCard.leankor__Case__c != null) {
                    caseIds.add(kanbanCard.leankor__case__c);
                }

                if (kanbanCard.leankor__Opportunity__c != null) {
                    opportunityIds.add(kanbanCard.leankor__Opportunity__c);
                }
            }

            List<CaseFeed> caseFeeds = new List<CaseFeed>();

            if (caseIds.size() > 0) {
                List<CaseFeed> caseFeedRecords = [Select Id, 
                                                            ParentId,
                                                            Type
                                                        From CaseFeed 
                                                        Where ParentId In :caseIds 
                                                        Limit 50000];

                for (CaseFeed caseFeedRecord : caseFeedRecords) {
                    if (caseFeedRecord.Type != 'TrackedChange') {
                        caseFeeds.add(caseFeedRecord);
                    }
                }                
            }

            List<OpportunityFeed> opportunityFeeds = new List<OpportunityFeed>();

            if (opportunityIds.size() > 0) {
                List<OpportunityFeed> opportunityFeedRecords = [Select Id, 
                                                                        ParentId,
                                                                        Type
                                                                    From OpportunityFeed 
                                                                    Where ParentId In :opportunityIds 
                                                                    Limit 50000];

                for (OpportunityFeed opportunityFeedRecord : opportunityFeedRecords) {
                    if (opportunityFeedRecord.Type != 'TrackedChange') {
                        opportunityFeeds.add(opportunityFeedRecord);
                    }
                }
            }

            Map<String, Integer> mapFeeds = new Map<String, Integer>();
            Map<String, Integer> mapCaseFeeds = new Map<String, Integer>();
            Map<String, Integer> mapOpportunityFeeds = new Map<String, Integer>();

            //TODO: Why only check for the first item??? Must investigate!
            if (kanbanCards[0].leankor__ValueStream__r.leankor__ViewChatterOptions__c == 'Cases Chatter') {
                for (CaseFeed caseFeed : caseFeeds) {
                    if (mapCaseFeeds.containsKey(caseFeed.ParentId) == true) {
                        Integer i = (mapCaseFeeds.get(caseFeed.ParentId) == null ? 1 : mapCaseFeeds.get(caseFeed.ParentId));
                        i += 1;
                        mapCaseFeeds.put(caseFeed.ParentId, i);
                    } else {
                        mapCaseFeeds.put(caseFeed.ParentId, 1);
                    }
                }
            } else if (kanbanCards[0].leankor__ValueStream__r.leankor__ViewChatterOptions__c == 'Opportunities Chatter') {
                for (OpportunityFeed opportunityFeed : opportunityFeeds) {
                    if (mapOpportunityFeeds.containsKey(opportunityFeed.ParentId) == true) {
                        Integer i = (mapOpportunityFeeds.get(opportunityFeed.ParentId) == null ? 1 : mapOpportunityFeeds.get(opportunityFeed.ParentId));
                        i += 1;
                        mapOpportunityFeeds.put(opportunityFeed.ParentId, i);
                    } else {
                        mapOpportunityFeeds.put(opportunityFeed.ParentId, 1);
                    }
                }
            }
            //TODO:

            for (leankor__KanbanCard__Feed kanbanCardFeed : kanbanCardFeeds) {
                if (mapFeeds.containsKey(kanbanCardFeed.ParentId) == true) {
                    Integer i = mapFeeds.get(kanbanCardFeed.ParentId);
                    i += 1;
                    mapFeeds.put(kanbanCardFeed.ParentId, i);
                } else {
                    mapFeeds.put(kanbanCardFeed.ParentId, 1);
                }
            }

            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                Decimal count = 0;
                
                if (kanbanCard.leankor__ValueStream__r.leankor__ViewChatterOptions__c == 'Cases Chatter') {
                    if (kanbanCard.leankor__Case__c != null) {
                        count = mapCaseFeeds.get(kanbanCard.leankor__case__c);
                    }
                } else if (kanbanCard.leankor__ValueStream__r.leankor__ViewChatterOptions__c == 'Opportunities Chatter') {
                    if (kanbanCard.leankor__Opportunity__c != null) {
                        count = mapOpportunityFeeds.get(kanbanCard.leankor__Opportunity__c);
                    }                    
                } else {
                    count = mapFeeds.get(kanbanCard.id);
                }

                List<taskUsers> taskUserNames = new List<taskUsers>();            
                Integer taskCount = 0;
                Integer countUnDoneTask = 0;

                if (mapTasks.get(kanbanCard.Id) != null && mapTasks.get(kanbanCard.Id).size() > 0) {
                    for (Task task : mapTasks.get(kanbanCard.Id)) {
                        if (task.Status != 'Completed') {
                            countUnDoneTask++;
                        }

                        taskUsers taskOwner = new taskUsers(task.Id, task.OwnerId, task.Owner.Name);
                        taskUserNames.add(taskOwner);
                    }

                    taskCount = mapTasks.get(kanbanCard.Id).size();
                }
                
                ChatterFeedStats chatterFeedStat = new ChatterFeedStats(kanbanCard.Id, kanbanCard.Name, taskCount, new List<leankor__Sticker__c>(), count, countUnDoneTask, taskUserNames);
                
                chatterFeedStats.add(chatterFeedStat);
            }
        }

        return chatterFeedStats;
    }


    /**
     * Inner class for Glueforce Data.
     */
    global class GlueforceData {
        List<ChatterFeedStats> ChatterFeeds;
        List<User> Users;
        global GlueforceData(List<ChatterFeedStats> ChatterFeeds, List<User> Users) {
            this.ChatterFeeds = ChatterFeeds;
            this.Users = Users;
        }
    }


    /**
     *  Remote web service for Get All Chatter of kanban card with respect to valuestream ID.
     *  INPUT  : Value Stream ID.
     *  OUTPUT : returns array of ChatterFeedstat class(card ID, chatter count, task count).
     */
	//method is modified for reuse sticker records for CalenderView and OtherBoards
    @RemoteAction
    global static GlueforceData getGlueforceData(String valueStreamId) {
        // input validation is inside getAllChatterStats

        GlueforceData glueforceData;

        try {
            glueforceData = RealTimeControllerHelper.readCardsWithStickers(valueStreamId, getAllChatterStats(valueStreamId), getAllusers(valueStreamId));
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return glueforceData;
    }


    /**
     *  Remote web service for managing dependencies of card to update dependencies .
     *  INPUT  : Array of remote Cards .
     *  OUTPUT : returns array of dependencies as required JS end.
    */
    @RemoteAction
    global static String UpdateDependencyCards(List<String> remoteCards) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
          
        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isCreateable() 
        || !kanbanCardBehaviour.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
                
        Set<leankor__KanbanCard__c> kanbanCards = new Set<leankor__KanbanCard__c>();
        List<String> idLists = new List<String>();
        Map<String, DateTime> remoteKanbanCards = new Map <String, DateTime>();
        Map<String, DateTime> remoteKanbanStartCards = new Map<String, DateTime>();
        Map<String, DateTime> cardStartDates = new Map<String, DateTime>();
        Map<String, DateTime> cardDueDates = new Map<String, DateTime>();
        Map<String, String> valueStreamCards = new Map<String, String>();
        List<leankor.realtimeController.bulkStreaming> bulkStreamingMessages = new List<leankor.realtimeController.bulkStreaming>(); 
        List<String> cardIdLists = new List<String>();
        Map<Id, leankor__KanbanCard__C> mapOldKanbanCards;

        for(String someJSONData : remoteCards){
			leankor.realTimeController.Kanban remoteKanban = (leankor.realTimeController.Kanban)JSON.deserialize(someJSONData, leankor.realTimeController.Kanban.class);
            
            if (String.isNotBlank(remoteKanban.Id) && Util.getSObjectName(remoteKanban.Id) != 'leankor__KanbanCard__c'){
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
            cardIdLists.add(remoteKanban.id);
        }

        if(cardIdLists.size()>0){
            mapOldKanbanCards = new Map<Id, leankor__KanbanCard__C>([Select Id,
                                                                            Name,
                                                                            leankor__DueDate__c, 
                                                                            leankor__DueDateTime__c, 
                                                                            leankor__StartDateTime__c, 
                                                                            leankor__GUID__c, 
                                                                            leankor__StartDate__c                                                              
                                                                    From leankor__KanbanCard__c 
                                                                    Where Id In :cardIdLists
                                                                    Limit 9999]);
        }
        
        for (String someJSONData : remoteCards) { 
			leankor.realTimeController.Kanban remoteKanban = (leankor.realTimeController.Kanban)JSON.deserialize(someJSONData, leankor.realTimeController.Kanban.class);
            
            //broadcasting for kanban board to plangantt when linked by default link
            leankor.realTimeController.CardStreamingPackage kanbanData = new leankor.realTimeController.CardStreamingPackage();                
            kanbanData.Id = remoteKanban.Id;          
            kanbanData.verb = 'UpdateMultipleKanbanCards';          
                                                                                                                                                      
			leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c(
                leankor__GUID__c = remoteKanban.GUID,
                Id = remoteKanban.Id,
                leankor__CardId__c = remoteKanban.CardId,
                leankor__ValueStreamCardLink__c = remoteKanban.ValueStreamCardLink,

                //30/05/2023 IF we are Getting the Null Value of the followings Fields(leankor__StartDateTime__c,leankor__DueDateTime__c,leankor__StartDate__c,leankor__DueDate__c) From UI so we will set old values From Database 
                leankor__StartDateTime__c = remoteKanban.StartDate == null ? mapOldKanbanCards.get(remoteKanban.Id).leankor__StartDateTime__c : remoteKanban.StartDate,
                leankor__DueDateTime__c = remoteKanban.DueDate == null ? mapOldKanbanCards.get(remoteKanban.Id).leankor__DueDateTime__c : remoteKanban.DueDate,
                leankor__StartDate__c = remoteKanban.StartDate == null ? mapOldKanbanCards.get(remoteKanban.Id).leankor__StartDate__c : Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(remoteKanban.StartDate), DateTime.class)),
                leankor__DueDate__c = remoteKanban.DueDate == null ? mapOldKanbanCards.get(remoteKanban.Id).leankor__DueDate__c : Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(remoteKanban.DueDate), DateTime.class))
            );
            

			kanbanCards.add(kanbanCard);
            idLists.add(remoteKanban.GUID);
            
            cardStartDates.put(remoteKanban.Id, kanbanCard.leankor__StartDateTime__c);
            cardDueDates.put(remoteKanban.Id, kanbanCard.leankor__DueDateTime__c);
            remoteKanbanCards.put(remoteKanban.GUID, kanbanCard.leankor__DueDateTime__c);
            remoteKanbanStartCards.put(remoteKanban.GUID, kanbanCard.leankor__StartDateTime__c);
            valueStreamCards.put(remoteKanban.Id, remoteKanban.ValueStreamCardLink);

        }

        Map<Id, leankor__KanbanCard__c> mapKanbanCards = new Map<Id, leankor__KanbanCard__c>(new List<leankor__KanbanCard__c>(kanbanCards));
        List<Task> oldTasks = new List<task>();
        
        List<leankor__KanbanCard__c> oldKanbanCards = [Select Id, 
                                                                leankor__MasterContainer__c, 
                                                                leankor__MasterContainer__r.leankor__Type__c, 
                                                                leankor__Valuestream__r.leankor__SevenDayWorkWeek__c, 
                                                                leankor__DueDate__c, 
                                                                leankor__DueDateTime__c, 
                                                                leankor__StartDateTime__c, 
                                                                leankor__GUID__c, 
                                                                leankor__StartDate__c, 
                                                                leankor__Valuestream__r.leankor__Taskdatecheck__c, 
                                                                leankor__ValueStreamCardLink__c, 
                                                                leankor__ValueStream__r.leankor__IsRecordDeleted__c, 
                                                                leankor__ProjectRoom__c,
                                                                leankor__Monday__c,
                                                                leankor__Tuesday__c,
                                                                leankor__Wednesday__c,
                                                                leankor__Thursday__c,
                                                                leankor__Friday__c,
                                                                leankor__Saturday__c,
                                                                leankor__Sunday__c 
                                                            From leankor__KanbanCard__c 
                                                            Where leankor__GUID__c In :idLists 
                                                            Limit 10000];

        Map<String, List<Task>> mapTasks = new Map<String, List<Task>>();

        List<Task> taskRecords = [Select Id, 
                                            ActivityDate, 
                                            Description, 
                                            WhatId 
                                        From Task 
                                        Where WhatId In :oldKanbanCards 
                                            And What.Type = 'leankor__KanbanCard__c' 
                                            And IsDeleted = false 
                                        Limit 50000 
                                        All Rows];

        for (Task taskRecord : taskRecords) {
			List<Task> tasks = mapTasks.containsKey(taskRecord.WhatId) ? mapTasks.get(taskRecord.WhatId) : new List<Task>();
            tasks.add(taskRecord);
      		mapTasks.put(taskRecord.WhatId, tasks);
 		}
        
        Map<String, Integer> diffs = new Map<String, Integer>();
        Map<String, Boolean> taskDueDateCheckers = new Map<String, Boolean>();
        
        //04.05.2018 - getting first day of week from custom setting	
		leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
    	Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();	     	
        Integer numOfDays = oldKanbanCards[0].leankor__Valuestream__r.leankor__SevenDayWorkWeek__c ? 7 : 5;
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, numOfDays);
        Set<String> weekDays = new Set<String>();
        for (leankor__KanbanCard__c oldKanbanCard : oldKanbanCards) {
        	if(mapKanbanCards.containsKey(oldKanbanCard.Id) && (String.isBlank(oldKanbanCard.leankor__Valuestream__c) 
        	|| oldKanbanCard.leankor__ValueStream__r.leankor__IsRecordDeleted__c 
        	|| String.isBlank(oldKanbanCard.leankor__ProjectRoom__c))) {
        		leankor__KanbanCard__c kcInstance  = mapKanbanCards.get(oldKanbanCard.Id);
        		kcInstance.leankor__ValueStreamLink__c = null;
        		kcInstance.leankor__ValueStreamCardLink__c = null;
        		mapKanbanCards.put(kcInstance.Id, kcInstance);
        	}

            if (oldKanbanCard.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
            && ((oldKanbanCard.leankor__DueDate__c != (DateTime)cardDueDates.get(oldKanbanCard.Id).dateGMT()) 
            || (oldKanbanCard.leankor__StartDate__c != (DateTime)cardStartDates.get(oldKanbanCard.Id).dateGMT()) 
            || (oldKanbanCard.leankor__ValueStreamCardLink__c != valueStreamCards.get(oldKanbanCard.Id)))) {
				if (String.isNotBlank(oldKanbanCard.leankor__ValueStreamCardLink__c)) {
					Util.recalculateRecord.put(oldKanbanCard.leankor__ValueStreamCardLink__c, true);
                }
                
				if (String.isNotBlank(valueStreamCards.get(oldKanbanCard.Id))) {
					Util.recalculateRecord.put(valueStreamCards.get(oldKanbanCard.Id), true);
				}
            }
            
            if (mapTasks.get(oldKanbanCard.Id) != null && mapTasks.get(oldKanbanCard.Id).size() > 0) {
                if(oldKanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c){
                    weekDays.add(oldKanbanCard.leankor__Monday__c == false ? 'Mon' : 'false');
                    weekDays.add(oldKanbanCard.leankor__Tuesday__c == false ? 'Tue' : 'false');
                    weekDays.add(oldKanbanCard.leankor__Wednesday__c == false ? 'Wed' : 'false');
                    weekDays.add(oldKanbanCard.leankor__Thursday__c == false ? 'Thu' : 'false');
                    weekDays.add(oldKanbanCard.leankor__Friday__c == false ? 'Fri' : 'false');
                    weekDays.add(oldKanbanCard.leankor__Saturday__c == false ? 'Sat' : 'false');
                    weekDays.add(oldKanbanCard.leankor__Sunday__c == false ? 'Sun' : 'false');
                }
                Util.weekDays = weekDays;
                
				DateTime newstartdate = remoteKanbanStartCards.get(oldKanbanCard.leankor__GUID__C);
				DateTime oldstartdate = oldKanbanCard.leankor__StartDateTime__C;
                Integer diffInDays = (oldstartdate.date()).daysBetween(newstartdate.date());
                
				diffs.put(oldKanbanCard.Id, diffInDays == null ? 0 : diffInDays);
				taskDueDateCheckers.put(oldKanbanCard.Id, oldKanbanCard.leankor__Valuestream__r.leankor__Taskdatecheck__c);
	           
                for (Task loopTask : mapTasks.get(oldKanbanCard.Id)) {
                    DateTime scpStartDate = cardStartDates.get(loopTask.WhatId);
                    DateTime scpDuedate = cardDueDates.get(loopTask.WhatId);
                    integer diff = 0;

                    if (diffs.ContainsKey(loopTask.WhatId) == true) {
                        diff = diffs.get(loopTask.WhatId);
                        loopTask.ActivityDate = loopTask.ActivityDate + diff;
                        if(oldKanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c){
                            DateTime taskDateTime = workWeek.getNextWorkingDay(DateTime.newInstance(loopTask.ActivityDate.year(), loopTask.ActivityDate.month(), loopTask.ActivityDate.day(), 1, 1, 1));
                            loopTask.ActivityDate = taskDateTime.date();
                    }
                    }
                                                
                    if (loopTask.ActivityDate > scpDuedate && taskDueDateCheckers.get(loopTask.WhatId)) {
                        loopTask.ActivityDate = date.newinstance((scpDuedate).year(), (scpDuedate).month(), (scpDuedate).day());
                    } else if (loopTask.ActivityDate <= scpStartDate && taskDueDateCheckers.get(loopTask.WhatId)) {
                        loopTask.ActivityDate = date.newinstance((scpStartDate).year(), (scpStartDate).month(), (scpStartDate).day());
                    }
                                                    
                    Datetime taskDuedate = Datetime.newInstanceGmt(loopTask.ActivityDate.year(), loopTask.ActivityDate.month(), loopTask.ActivityDate.day(), 1, 1, 1);
                    
                    if (!oldKanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) {							
                        loopTask.ActivityDate = Util.readNextWorkingDate(workWeek, taskDuedate, loopTask.ActivityDate);
                    }

                    oldTasks.add(loopTask);
                }
			}
        }	
        
        String kanbanCardIds = '';

        Savepoint sp = Database.setSavepoint();
        try {        
            if (oldTasks.size() > 0) {
                leankor.OpenTaskRestriction.updateTask(oldTasks);
            }

            if (kanbanCards.size() > 0) {
                Schema.Sobjectfield externField = leankor__KanbanCard__c.Fields.leankor__GUID__c;
                Database.upsert(mapKanbanCards.values(), externField, true);
            
                //calling method for insert record into reatimetrackerlist for broadcasting                        
                leankor.realtimeController.updateParentCards(new List<leankor__kanbanCard__c>(kanbanCards));

                if (IS_GENERIC_STREAMING) {
                    ExternalDependent externalDependent = new ExternalDependent();

                    externalDependent.cardIds = gskanbanCardIds;
                    externalDependent.externalCardIDs = externalCardIDs;        
                    
                    kanbanCardIds = JSON.serialize(externalDependent);
                } else {
                    kanbanCardIds = JSON.serialize(gskanbanCardIds);
                }
                
                //TODO: Where are these being initialized and why clear the values? and if an exception occurs, do we need clear the values?
                gskanbanCardIds.clear();
                externalCardIDs.clear();
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

		return kanbanCardIds;
    }
    

	/**
	 *  Remote web service for linked Valuestream Card to other Valuestream  .
	 *  INPUT  : valueStream Id.
	 *  OUTPUT : returns array of ValuestreamIDs.
	*/
	@deprecated
	@RemoteAction
	global static Set<String> getLinkedVSToCard(String valueStreamId) {
		Set<String> valueStreamIds = new Set<String>();

        return valueStreamIds;
    }


    /**
     *  Remote web service for bulk dependency streaming .
     *  INPUT  : JSON Data of Class Kanban.
     *  OUTPUT : returns Array of Class MasterContainer.
    */
    @RemoteAction
    global static List<leankor.KanbanToGanttController.MasterContainer> getKanbanCardTask(String remoteKanbanCard) {
        Kanban kanban = (Kanban)JSON.Deserialize(remoteKanbanCard, Kanban.Class);

        if (String.isNotBlank(kanban.Id) && Util.getSObjectName(kanban.Id) != 'leankor__KanbanCard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        Set<String> userId = new Set<String>();
        List<leankor.KanbanToGanttController.MasterContainer> listKanbanCards = new List<leankor.KanbanToGanttController.MasterContainer>();
        List<leankor.KanbanToGanttController.MasterContainer> listKanbanTasks = new List<leankor.KanbanToGanttController.MasterContainer>();

        List<Task> tasks = [Select Id, 
                                    Priority, 
                                    OwnerId, 
                                    Subject, 
                                    Status, 
                                    ActivityDate, 
                                    WhatId, 
                                    Description, 
                                    Owner.Name, 
                                    LastModifiedDate 
                                From Task 
                                Where WhatId = :kanban.Id 
                                    And IsDeleted = false 
                                Order By SystemModStamp 
                                Limit 10000 
                                All Rows];
        
        for (Task task : tasks) {
            userId.add(task.OwnerId);
        }

        List<User> users = [Select Id, 
                                    SmallPhotoUrl 
                                From User 
                                Where Id In :userId 
                                Limit 50000];

        Map<Id, String> userRecords = new Map<Id, String>();

		for (User user : users) {
			userRecords.put(user.Id, user.SmallPhotoUrl);
        }
        
        leankor.KanbanToGanttController.MasterContainer listTask = new leankor.KanbanToGanttController.MasterContainer();
        
		listTask.Name = 'Tasks for ' + kanban.Name;
		listTask.Id = kanban.Id + '-T';
		listTask.ValueStreamID = kanban.ValueStream;
		listTask.leaf = false;
		listTask.Title = 'Tasks for ' + kanban.Name;
		listTask.Order = kanban.Order + 0.3;
		listTask.expanded = true;
		listTask.ItemType = 'Ghost';
        listTask.Color = '#CCCCCC';
        
		for (Task task : tasks) {                        
            Date tempActivityDate = (task.ActivityDate == null ? Date.valueOf(task.LastModifiedDate) : task.ActivityDate);
            Date tempDate = (task.ActivityDate == null ? Date.valueOf(task.LastModifiedDate) : task.ActivityDate);

            leankor.KanbanToGanttController.MasterContainer kanbanTask = new leankor.KanbanToGanttController.MasterContainer();

			kanbanTask.Id = task.Id;
			kanbanTask.ValueStreamID = kanban.ValueStream;            
			kanbanTask.StartDate = String.valueofGMT(Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 01, 01, 01));
			kanbanTask.DueDate = String.valueofGMT(Datetime.newInstanceGmt(tempActivityDate.year(), tempActivityDate.month(), tempActivityDate.day(), 01, 01, 01));
			kanbanTask.EstimatedDuration = 1;
			kanbanTask.DurationUnits = 'd';
			kanbanTask.OwnerID = task.OwnerID;
			kanbanTask.OwnerName = task.Owner.Name;
			kanbanTask.SmallPhotoUrl = userRecords.get(task.OwnerId);
			kanbanTask.Priority = (task.Priority == 'Normal' ? 0 : (task.Priority == 'Low' ? 1 : 2));
			kanbanTask.Subject = task.Subject;
			kanbanTask.Name = task.Subject;
			kanbanTask.Status = task.Status;
			kanbanTask.Description = task.Description;
			kanbanTask.WhatId = task.WhatId;
			kanbanTask.ItemType = 'Task';
			kanbanTask.expanded = false;
			kanbanTask.leaf = true;
            kanbanTask.Order = listTask.Order;
            
			listKanbanTasks.add(kanbanTask);
        }
        
		listTask.StartDate = String.valueofGMT(kanban.StartDate);
		listTask.DueDate = String.valueofGMT(kanban.DueDate);
        listTask.children = listKanbanTasks;
        
        listKanbanCards.add(listTask);
        
		return listKanbanCards;
    }
    

	// Inner class for Direct Link Card.
	global class DirectLinkCardLog {
		global String ValueStreamId;
		global String LinkRoomId;
		global String LinkRoomName;
		global String LinkValueStreamId;
		global String LinkValueStreamName;
		global String LinkValueStreamBoardType;
		global String LinkKanbanCardId;
		global String LinkKanbanCardName;
		global String OldLinkKanbanCardId;
		global String OldLinkValueStreamId;
		global String MySessionId;
		public String verb;
        global String OldValueStreamId;
        public List<String> cardIds;
        public String multipleAPIName;
        // Ashutosh : 28/09/21 : variables added for MultipleHyperJump and multipleClone Api.
        public String TargetVSID;
        public String SourceVSID;
        public Boolean IsClone;
        public String ValueStreamOwnerName;
        // Pratiksha : 20/09/2021 : Variables added for Planinng Mode.
        public DateTime ProjectBoardStartDateTime;
        public DateTime ProjectBoardEndDateTime;
        public Boolean scheduleBackward;
        public String sessionID;

        //Pratiksha : 04/April/2023 We are adding this variable for Broadcast of borad cloning if constraint is violated.
        public String currentCardName;
        public String constraintDescription;
        public String constraintCardName;
        public String boardName;
        public String constraintCardId;
        public String violatedBoardType;
        public String violatedBoardId;
        public String projectID;
    }
    

	// Takes list of DirectLinkCardLog class and updates all cards links accordingly.
	//USAGE : Updates default link to each and every card of the board and creates broadcast message too.
	@RemoteAction
	global static String UpdateDefaultLink(List<DirectLinkCardLog> directLinkLogs) {
        //Check CRUD / FLC behavior
  		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
          
        if (!valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isUpdateable() 
        || !kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior
        
        List<leankor.RealTimeController.bulkStreaming> bulkStreams = new List<leankor.RealTimeController.bulkStreaming>();
		Map<String, leankor.RealTimeController.DirectLinkCardLog> directLinkCardLogs = new Map<String, leankor.RealTimeController.DirectLinkCardLog>();
        
        for (leankor.RealTimeController.DirectLinkCardLog directLinkCardLog : directLinkLogs) {
            if (String.isNotBlank(directLinkCardLog.ValueStreamId) && Util.getSObjectName(directLinkCardLog.ValueStreamId) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

			directLinkCardLog.verb = 'UpdateDefaultLink';
			directLinkCardLogs.put(directLinkCardLog.ValueStreamId, directLinkCardLog);
        }
        
        Set<String> valueStreamIds = directLinkCardLogs.keySet();
        
        List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                                leankor__ValueStreamLink__c, 
                                                                leankor__ValueStreamCardLink__c, 
                                                                leankor__ProjectRoomLink__c 
                                                            From leankor__ValueStream__c 
                                                            Where Id In :valueStreamIds 
                                                            Limit 10000];
        
        for (leankor__ValueStream__c valueStream : valueStreams) {
            if (directLinkCardLogs.ContainsKey(valueStream.Id)) {
                leankor.RealTimeController.DirectLinkCardLog tempLog = directLinkCardLogs.get(valueStream.Id);

                valueStream.leankor__ProjectRoomLink__c = tempLog.LinkRoomId == '' ? null : tempLog.LinkRoomId;
                valueStream.leankor__ValueStreamLink__c = tempLog.LinkValueStreamId == '' ? null : tempLog.LinkValueStreamId;
                valueStream.leankor__ValueStreamCardLink__c = tempLog.LinkKanbanCardId == '' ? null : tempLog.LinkKanbanCardId;
                
                leankor.RealTimeController.bulkStreaming tempStreaming = new leankor.RealTimeController.bulkStreaming();

                tempStreaming.VSID = tempLog.ValueStreamId;
                tempStreaming.Verb = 'UpdateDefaultLink';
                tempStreaming.SessionID = tempLog.MySessionId;
                tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
                
                bulkStreams.add(tempStreaming);
            }
        }

        String kanbanCardIds = '';

        Savepoint sp = Database.setSavepoint();
        try {
			//Changes for fixing the default link issue.
           	//update valueStreams;
            DataBase.upsert(valueStreams, false);
            
            // commented out for this is not used
            //List<leankor.realtimeController.bulkStreaming> bulkStreamingMessages = new List<leankor.realtimeController.bulkStreaming>();
           
            // ---------begin, the following lines should be moved before the Savepoint to improve efficiency and readability
            List<leankor__KanbanCard__c> kanbanCardRecords = [Select Id,  
                                                                        leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c,
                                                                        leankor__TemplateBoard__c,
                                                                        leankor__MasterContainer__r.leankor__Type__c,
                                                                        leankor__Boardtype__c,
                                                                        leankor__GUID__c,
                                                                        leankor__ValueStream__r.Name,
                                                                        leankor__ValueStreamCardLink__r.Name,
                                                                        leankor__ValueStreamLink__r.leankor__Boardtype__c,
                                                                        Name,
                                                                        leankor__Description__c,
                                                                        leankor__ValueStreamCardLink__c, 
                                                                        leankor__ValueStreamLink__c, 
                                                                        leankor__ValueStream__c, 
                                                                        leankor__PercentComplete2__c,
                                                                        RecordType.Name,
                                                                        leankor__StartDateTime__c,
                                                                        leankor__DueDateTime__c
                                                                    From leankor__KanbanCard__c 
                                                                    Where leankor__ValueStream__c In :valueStreamIds 
                                                                        And leankor__isRecordDeleted__c = false 
                                                                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false];
            
            List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

            //Changes : fixing the issue of Default Link was not updating.
            for (leankor__KanbanCard__c kanbanCard : kanbanCardRecords) {
                if (kanbanCard.RecordType.Name != 'MileStoneCard') {
                    kanbanCards.add(kanbanCard);
                }
            }

            List<String> cardLinkIds = new List<String>();
            //05/April/2023 : We have added code for Hybrid constraint while Default links from Boards.        
            List<KanbanCard> cardsToCheck = new List<KanbanCard>();
            KanbanController.KanbanCardConstraintViolation violationResult = new KanbanController.KanbanCardConstraintViolation();
            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                if (kanbanCard.leankor__ValueStreamCardLink__c != null) {
                    valueStreamCardLinkIDList.add(kanbanCard.leankor__ValueStreamCardLink__c);
                }

                //broadcasting for kanban board to plangantt when linked by default link
                leankor.realTimeController.CardStreamingPackage remoteKanban = new leankor.realTimeController.CardStreamingPackage();

                remoteKanban.Id = kanbanCard.Id;
                remoteKanban.GUID = kanbanCard.leankor__GUID__c;
                remoteKanban.ForceID = kanbanCard.Id;

                if (directLinkCardLogs.containsKey(kanbanCard.leankor__ValueStream__c)) {
                    leankor.RealTimeController.DirectLinkCardLog tempLog = directLinkCardLogs.get(kanbanCard.leankor__ValueStream__C);
                    //Changes for fixing the default link issue. 
                    if(kanbanCard.Id == tempLog.LinkKanbanCardId ){
                        continue;
                    }                
                    //August 10 2017 : added condition for template board and template MC to prevent miniature broadcast on linked Board
                    if((kanbanCard.leankor__TemplateBoard__c == LEANFALSE && kanbanCard.leankor__MasterContainer__r.leankor__Type__c != 'Template') 
                    || kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c == LEANTRUE) {
                        if (String.isNotBlank(remoteKanban.Id)) {					
                            gskanbanCardIds.add(remoteKanban.Id);							
                        }						  
                    }
                                
                    if ((kanbanCard.leankor__ValueStreamLink__c == (tempLog.OldLinkValueStreamId == '' ? null : tempLog.OldLinkValueStreamId) 
                    && kanbanCard.leankor__ValueStreamCardLink__c == (tempLog.OldLinkKanbanCardId == '' ? null : tempLog.OldLinkKanbanCardId)) 
                    || (kanbanCard.leankor__ValueStreamLink__c == Null && kanbanCard.leankor__ValueStreamCardLink__c == null)) {
                        kanbanCard.leankor__ValueStreamLink__c = (tempLog.LinKValueStreamId == '' ? null : tempLog.LinKValueStreamId);
                        kanbanCard.leankor__ValueStreamCardLink__c = (tempLog.LinkKanbanCardId == '' ? Null : tempLog.LinkKanbanCardId);
                        
                        if (String.isNotEmpty(kanbanCard.leankor__ValueStreamCardLink__c)) {                   	
                            cardLinkIds.add(kanbanCard.leankor__ValueStreamCardLink__c);
                            Util.recalculateRecord.put(kanbanCard.leankor__ValueStreamCardLink__c, true);
                        }
                        if(ALLOW_SCHEDULING_CONSTRAINTS && String.isNotBlank(kanbanCard.leankor__ValueStreamLink__c) && String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)){
                            KanbanCard checkCard = new KanbanCard();
                            checkCard.Id = kanbanCard.Id;
                            checkCard.name = kanbanCard.Name;
                            checkCard.valueStream = kanbanCard.leankor__ValueStream__c;
                            checkCard.startDateTime = kanbanCard.leankor__StartDateTime__c;
                            checkCard.dueDateTime =  kanbanCard.leankor__DueDateTime__c;
                            checkCard.isUpdateValueStreamCardLink = true;
                            checkCard.valueStreamLink = kanbanCard.leankor__ValueStreamLink__c;
                            checkCard.valueStreamCardLink = kanbanCard.leankor__ValueStreamCardLink__c;
                            cardsToCheck.add(checkCard);
                        }
                    }
                   
                }                  		                        	            
            }
            //30/march/2023 : checking constraint.
            if(!cardsToCheck.isEmpty()){
                violationResult = KanbanController.getConstraintViolation(cardsToCheck, false);
            }
            if(!violationResult.isEmpty()) {
                System.debug('Constraint is Violated');
                Database.rollback(sp);
                return Json.serialize(violationResult);
            }else{
                // ---------end, the above lines should be moved before the Savepoint to improve efficiency and readability
                if (kanbanCards.size() > 0) {
                    update kanbanCards;
                    leankor.realtimeController.updateParentCards(kanbanCards);
                }

                if (cardLinkIds.size() > 0) {
                    leankor.ProjectBoardCarousel.updateActivityPercentageComplete(cardLinkIds);     
                }

                if (bulkStreams.size() > 0) {
                    bulkStreams[0].cardIds = new List<String>();
                    
                    leankor.RealTimeController.sendBroadCast(bulkStreams, 'UpdateDefaultLink');
                            
                    bulkStreams[0].cardIds.addAll(gskanbanCardIds);
                    
                    kanbanCardIds = JSON.serialize(bulkStreams);
                }
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return kanbanCardIds;       
    }
	
	
	// Takes ValueStream /Project Board  Id and return default links values for the same.
	// USAGE : this record will initialize default link popup in LeankorJS.
    @RemoteAction
	global static leankor.RealTimeController.DirectLinkCardLog getDefaultLink(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) 
        && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        leankor.RealTimeController.DirectLinkCardLog tempLinkValues = new leankor.RealTimeController.DirectLinkCardLog();

        List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                                leankor__ValueStreamLink__c, 
                                                                leankor__ValueStreamLink__r.Name, 
                                                                leankor__ValueStreamLink__r.leankor__BoardType__c, 
                                                                leankor__ValueStreamCardLink__c, 
                                                                leankor__ValueStreamCardLink__r.Name, 
                                                                leankor__ProjectRoomLink__c, 
                                                                leankor__ProjectRoomLink__r.Name 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :valueStreamId 
                                                            Limit 1];
        
        if (valueStreams.size() > 0) {
            tempLinkValues.ValueStreamId = valueStreams[0].Id;
            tempLinkValues.LinkRoomId = valueStreams[0].leankor__ProjectRoomLink__c == null ? '' : valueStreams[0].leankor__ProjectRoomLink__c;
            tempLinkValues.LinkRoomName = valueStreams[0].leankor__ProjectRoomLink__c == null ? '' : valueStreams[0].leankor__ProjectRoomLink__r.Name;
            tempLinkValues.LinkValueStreamId = valueStreams[0].leankor__ValueStreamLink__c == null ? '' : valueStreams[0].leankor__ValueStreamLink__c;
            tempLinkValues.LinkValueStreamName = valueStreams[0].leankor__ValueStreamLink__c == null ? '' : valueStreams[0].leankor__ValueStreamLink__r.Name;
            tempLinkValues.LinkValueStreamBoardType = valueStreams[0].leankor__ValueStreamLink__c == null ? '' : valueStreams[0].leankor__ValueStreamLink__r.leankor__BoardType__c;
            tempLinkValues.LinkKanbanCardId = valueStreams[0].leankor__ValueStreamCardLink__c == null ? '' : valueStreams[0].leankor__ValueStreamCardLink__c;
            tempLinkValues.LinkKanbanCardName = valueStreams[0].leankor__ValueStreamCardLink__c == null ? '' : valueStreams[0].leankor__ValueStreamCardLink__r.Name;
            tempLinkValues.OldLinkKanbanCardId = valueStreams[0].leankor__ValueStreamCardLink__c == null ? '' : valueStreams[0].leankor__ValueStreamCardLink__c;
            tempLinkValues.OldLinkValueStreamId = valueStreams[0].leankor__ValueStreamLink__C == null ? '' : valueStreams[0].leankor__ValueStreamLink__c;
            tempLinkValues.MySessionId = '';
        }

		return tempLinkValues;
    }
    

	//Inner class that contains all picklist values of Opportunity Object and Role Hierarchy too.
	global class OpportunitySync {
		global List<Schema.PicklistEntry> LeadSource;
		global List<RecordType> RecordTypes;
		global List<Schema.PicklistEntry> Type;
		global List<Schema.PicklistEntry> StageName;
		global Set<leankor.ProjectBoardCarousel.RoleLog> RoleHierarchy;
    }
    

	//Returns OpportunitySync class contains required list of records for the Opportunity sync popup.
	//USAGE : Initialize the edit popup with Opportunity class picklist values.
	@RemoteAction
	global static leankor.RealTimeController.OpportunitySync getOpportunitySync() {
		String sObjectName = 'Opportunity';
		leankor.RealTimeController.OpportunitySync opportunitySync = new leankor.RealTimeController.OpportunitySync();
        
        opportunitySync.LeadSource = leankor.ProjectBoardCarousel.getPicklist(sObjectName, 'LeadSource');
		opportunitySync.Type = leankor.ProjectBoardCarousel.getPicklist(sObjectName, 'Type');
		opportunitySync.StageName = leankor.ProjectBoardCarousel.getPicklist(sObjectName, 'StageName');
		opportunitySync.RecordTypes = leankor.RealTimeController.getActiveRecordType(sObjectName);
        opportunitySync.RoleHierarchy = leankor.ProjectBoardCarousel.getRoleHierarchy();
        
		return opportunitySync;
    }
    

    //getting stageName of Opportunity objects
    @RemoteAction
    global static leankor.RealTimeController.OpportunitySync getStageName() {
        String sObjectName = 'Opportunity';
        leankor.RealTimeController.OpportunitySync opportunitySync = new leankor.RealTimeController.OpportunitySync();  

        opportunitySync.StageName = leankor.ProjectBoardCarousel.getPicklist(sObjectName, 'StageName');       
        
        return opportunitySync;
    }
    

	// Takes Projeboard class and update ValueStream__C sobject and returns ValueStream__C record.
	//USAGE : if user enables Opprtunity sync features than this board will add in Opportunity trigger list for ValueStream__C.
	@RemoteAction
	global static leankor__ValueStream__c updateOpportunityProjectBoard(ProjectBoard projectBoard) {
        if (String.isNotBlank(projectBoard.Id) 
        && Util.getSObjectName(projectBoard.Id) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
          
        if (!valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__ValueStream__c returnVal = new leankor__ValueStream__c();

        List<leankor__ValueStream__c> valueStreams = [Select Id, 
                                                                leankor__OpportunityLeadSource__c, 
                                                                leankor__BoardType__c, 
                                                                leankor__ValueStreamCardLink__c, 
                                                                leankor__ValueStreamLink__c, 
                                                                leankor__BackgroundHeight__c, 
                                                                leankor__BackgroundWidth__c, 
                                                                leankor__JSONSnapshot__c, 
                                                                leankor__KanbanCardCount__c, 
                                                                leankor__KanbanCardThroughput__c, 
                                                                leankor__ProjectRoom__c, 
                                                                leankor__ValueStreamTemplate__c, 
                                                                Name, 
                                                                OwnerId, 
                                                                leankor__OpportunityType__c, 
                                                                leankor__OpportunitySynchronization__c, 
                                                                leankor__OpportunityCardCategory__c, 
                                                                leankor__OpportunityRecordType__c 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :projectBoard.Id 
                                                            Limit 1];

        if (valueStreams.size() > 0) {
            valueStreams[0].leankor__OpportunitySynchronization__c = projectBoard.OpportunitySynchronization;
            valueStreams[0].leankor__OpportunityType__c = projectBoard.OpportunityType;
            valueStreams[0].leankor__OpportunityCardCategory__c = projectBoard.OpportunityCardCategory == '' ? null : projectBoard.OpportunityCardCategory;
            valueStreams[0].leankor__OpportunityRecordType__c = projectBoard.OpportunityRecordType;
            valueStreams[0].leankor__OpportunityLeadSource__c = projectBoard.OpportunityLeadSource;
            valueStreams[0].leankor__OpportunityRoleId__c = projectBoard.OpportunityRoleId;
            valueStreams[0].leankor__OpportunityRoleName__c = projectBoard.OpportunityRoleName;
            valueStreams[0].leankor__BoardType__c = projectBoard.BoardType != valueStreams[0].leankor__BoardType__c && projectBoard.BoardType != '' ? projectBoard.BoardType : valueStreams[0].leankor__BoardType__c;

            try {
                update valueStreams;
                returnVal = valueStreams[0];
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());                    
            }
        }
        
		return returnVal;
    }
    

	//Takes Opportunity Id and Stage name and updates opportunity stage name and returns success.
	// This will be used to create trigger event for Opprtunity Sync feature.
	@RemoteAction
	global static String updateOpportunityStageName(String opportunityId, String opportunityStageName) {
        if (String.isNotBlank(opportunityId) 
        && Util.getSObjectName(opportunityId) != 'Opportunity') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        OpportunityBehaviour opportunityBehaviour = new OpportunityBehaviour();

        if (!opportunityBehaviour.isAccessible() 
        || !opportunityBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<Opportunity> opportunities = [Select Id, 
                                                    Name, 
                                                    StageName 
                                                From Opportunity 
                                                Where Id = :opportunityId 
                                                Limit 1];

        if (opportunities.size() > 0) {
            opportunities[0].StageName = opportunityStageName;
            
            try {
                update opportunities;
            } catch (DmlException e) {
                System.debug('Error: ' + e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

		return 'Success';
    }
    

	//Takes List of TaskData class and returns same updated record in force.com.
	@RemoteAction
	global static List<TaskData> updateTaskList(List<TaskData> dataTasks) {
        Set<String> taskIds = new Set<String>();

		for (TaskData dataTask : dataTasks) {
            if (String.isNotBlank(dataTask.ID) 
            && Util.getSObjectName(dataTask.ID) != 'Task') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

			taskIds.add(dataTask.ID);
        }

        List<TaskData> returnVal = new List<TaskData>();

        List<Task> tasks = [Select Id, 
                                    Priority, 
                                    Subject, 
                                    Status, 
                                    ActivityDate, 
                                    WhatId, 
                                    Description, 
                                    OwnerId 
                                From Task 
                                Where Id In :taskIds 
                                    And IsDeleted = false 
                                Limit 10000 
                                All Rows];

        if (tasks.size() > 0) {
            String networkId = Network.getNetworkId();
            List<FeedItem> feedItems = new List<FeedItem>();

            for (Task task : tasks) {
                for (TaskData dataTask : dataTasks) {
                    if (task.Id == dataTask.ID) {
                        task.OwnerId = dataTask.OwnerId;
                        task.Priority = dataTask.Priority;
                        task.Subject = dataTask.Subject;
                        task.Status = dataTask.Status;
                        task.ActivityDate = Date.valueOf(dataTask.ActivityDate);
                        task.WhatId = dataTask.WhatID;
                        task.Description = dataTask.Description;
                    }
                }

                FeedItem feedItem = new FeedItem();

                feedItem.ParentId = task.Id;
                
                //Note: Salesforce does not allow the creation of a FeedItem record that has the type of 'TrackedChange'
                //feedItem.Type = 'TrackedChange'; // term used for update in force.com

                feedItem.Body = 'The task ' + task.Subject + ' is ' + task.Status + '.'; // chatter message for taskSubscribers.

                //For chatter post visibility for all users from community 
                if (String.isNotBlank(networkId)) {
                    feedItem.put('Visibility', 'AllUsers');
                }

                feedItems.add(feedItem);
            }

            Savepoint sp = Database.setSavepoint();
            try {               
                leankor.OpenTaskRestriction.updateTask(tasks);

                if (feedItems.size() > 0) {
                    insert feedItems;
                }
            } catch (DmlException e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }

            for (Task task : tasks) {
                TaskData taskData = new TaskData();
                
                taskData.Id = task.Id;
                taskData.Priority = task.Priority;
                taskData.OwnerID = task.OwnerID;
                taskData.Subject = task.Subject;
                taskData.Status = task.Status;
                taskData.ActivityDate = String.valueOf(task.ActivityDate);
                taskData.WhatID = task.WhatID;
                taskData.Description = task.Description;
                
                returnVal.add(taskData);
            }
        }

		return returnVal;
    }
    

	// Takes marker class object and returns update marker class object.
	// this is only use to enhance broadcast message length for markers.
	@RemoteAction
	global static Marker getMarkerRecord(Marker remoteMarker) {
        if (String.isNotBlank(remoteMarker.Id) 
        && Util.getSObjectName(remoteMarker.Id) != 'leankor__Marker__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        List<leankor__Marker__c> markers = [Select Id, 
                                                    leankor__TextLabel__c 
                                                From leankor__Marker__c 
                                                Where Id = :remoteMarker.Id 
                                                Limit 1];

        if (markers.size() > 0) {
    		remoteMarker.TextLabel = markers[0].leankor__TextLabel__c; //added text label once again to marker class object.
            remoteMarker.Base64Body = ''; // If text label than Base64Body will be blank.
        }

		return remoteMarker;
    }
    

	global class EditBoardModifiedRecord {
		global String PermissionCheck;
		global String VSID;
		global String UserID;
		global DateTime ModifiedDate;
		global Boolean Identical;
		global String UserName;
		global String OprationVerb;
		//-------------- MC Input/output ---------------
		global List<String> DeleteMC; // Input For DeleteMC
		global List<leankor.KanbanController.MasterContainer> CreateMC; // Input for CreateMC
		global List<leankor.KanbanController.MasterContainer> UpdateMC; // Input for UpdateMC
		//-------------- SW Input/output ---------------
		global List<String> DeleteSW; // Input For DeleteSW
		global List<leankor.KanbanController.Swimlane> UpdateSW; // Input For UpdateSW
		global List<leankor.KanbanController.Swimlane> InputCSW; // Input For CreateSW
		//-------------- Zone Input/output ---------------
		global List<Zone> InputZone; // Input For CreaetZone
		global String UpdateZone; // Input for UpdateZone
		global List<String> DeleteZone; // Input for Delete multy Zones
    }
    

	// Remote web service for resetting the Last modified Date and user of edit mode
	// INPUT: VSID, UserID,ModifiedDate
	// OUTPUT: if matched then return True and if not then return False with UsreName(how has modidied recently) ;
	@RemoteAction
	global static EditBoardModifiedRecord editBoardModifiedMethod(EditBoardModifiedRecord editBoardModifiedRecord) {
		// input validation for editBoardModifiedRecord should be inside those called methods, and not directly here

		projectBoardModifiedRecords projectBoardModifiedRecords = getPermissionToEdit(editBoardModifiedRecord.PermissionCheck);

        
       editBoardModifiedRecord.VSID = projectBoardModifiedRecords.VSID;
		editBoardModifiedRecord.UserID = projectBoardModifiedRecords.UserID;
		editBoardModifiedRecord.ModifiedDate = projectBoardModifiedRecords.ModifiedDate;
		editBoardModifiedRecord.Identical = projectBoardModifiedRecords.Identical;
        editBoardModifiedRecord.UserName = projectBoardModifiedRecords.UserName;
        
		if (projectBoardModifiedRecords.Identical) {
            Savepoint sp = Database.setSavepoint();
            try {
                Switch on editBoardModifiedRecord.OprationVerb {
                    when 'CreateMC' {
                        List<leankor__MasterContainer__c> masterContainer = leankor.KanbanController.createMasterContainer(editBoardModifiedRecord.CreateMC);
                    
                        if (masterContainer.size() > 0) {
                            for (leankor.KanbanController.Swimlane createObjectSwimlane : editBoardModifiedRecord.InputCSW) {
                                createObjectSwimlane.MasterContainer = masterContainer[0].Id;
                            }
                            
                            for (leankor.KanbanController.MasterContainer outputObjectMasterContainer : editBoardModifiedRecord.CreateMC) {
                                outputObjectMasterContainer.Id = masterContainer[0].Id;
                            }

                            List<leankor__Swimlane__c> swimlane = leankor.KanbanController.createSwimlane(editBoardModifiedRecord.InputCSW);
                            
                            if (swimlane.size() > 0) {
                                for (Zone createObjectZone : editBoardModifiedRecord.InputZone) {
                                    createObjectZone.Swimlane = swimlane[0].Id;
                                }
                                
                                for (leankor.KanbanController.Swimlane outputObjectSwimlane : editBoardModifiedRecord.InputCSW) {
                                    outputObjectSwimlane.Id = swimlane[0].id;
                                    outputObjectSwimlane.ForceID = swimlane[0].Id;
                                }

                                String zoneId = createZone(editBoardModifiedRecord.VSID, editBoardModifiedRecord.InputZone);
                                
                                if (String.isNotBlank(zoneId)) {
                                    for (Zone createObjectZone : editBoardModifiedRecord.InputZone) {
                                        createObjectZone.Id = zoneId;
                                        createObjectZone.ForceID = zoneId;
                                    }
                                }
                            }
                        }
                    }
                    when 'UpdateMCOnDeleteMC' {
                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }
                        
                        if (editBoardModifiedRecord.DeleteZone.size() > 0) {
                            DeleteBuilkyZone(editBoardModifiedRecord.DeleteZone);
                        }

                        if (editBoardModifiedRecord.DeleteSW.size() > 0) {
                            leankor.KanbanController.deleteSwimlane(editBoardModifiedRecord.DeleteSW);
                        }

                        if (editBoardModifiedRecord.DeleteMC.size() > 0) {
                            leankor.KanbanController.deleteMasterContainer(editBoardModifiedRecord.DeleteMC);
                        }              
                    }
                    when 'UpdateMC' {
                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }                  
                    }
                    when 'AddSwimlane' {
                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }
                        
                        List<leankor__Swimlane__c> swimlane = leankor.KanbanController.createSwimlane(editBoardModifiedRecord.InputCSW);
                        
                        if (swimlane.size() > 0) {
                            for (Zone createObjectZone : editBoardModifiedRecord.InputZone) {
                                createObjectZone.Swimlane = swimlane[0].Id;
                            }
                            
                            for (leankor.KanbanController.Swimlane outputObjectSwimlane : editBoardModifiedRecord.InputCSW) {
                                outputObjectSwimlane.Id = swimlane[0].Id;
                                outputObjectSwimlane.ForceID = swimlane[0].Id;
                            }
                            
                            String zoneId = createZone(editBoardModifiedRecord.VSID, editBoardModifiedRecord.InputZone);
                            
                            if (String.isNotBlank(zoneId)) {
                                for (Zone createObjectZone : editBoardModifiedRecord.InputZone) {
                                    createObjectZone.Id = zoneId;
                                    createObjectZone.ForceID = zoneId;
                                }
                            }
                        }                  
                    }
                    when 'UpdateSW' {
                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }
                        
                        if (editBoardModifiedRecord.UpdateSW.size() > 0) {
                            leankor.KanbanController.updateSwimlane(editBoardModifiedRecord.UpdateSW);
                        }

                        if (editBoardModifiedRecord.UpdateZone != null && editBoardModifiedRecord.UpdateZone != '{}') {
                            manageStateChange(editBoardModifiedRecord.VSID, 'UpdateZone', editBoardModifiedRecord.UpdateZone, '');
                        }                        
                    }
                    when 'DeleteSwimlane' {
                        if (editBoardModifiedRecord.DeleteZone.size() > 0) {
                            DeleteBuilkyZone(editBoardModifiedRecord.DeleteZone);
                        }
                        
                        if (editBoardModifiedRecord.DeleteSW.size() > 0) {
                            leankor.KanbanController.deleteSwimlane(editBoardModifiedRecord.DeleteSW);
                        }

                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }                        
                    }
                    when 'CreateZones' {
                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }
                        
                        String zoneId = createZone(editBoardModifiedRecord.VSID, editBoardModifiedRecord.InputZone);

                        if (String.isNotBlank(zoneId)) {
                            for (Zone createObjectZone : editBoardModifiedRecord.InputZone) {
                                createObjectZone.Id = zoneId;
                                createObjectZone.ForceID = zoneId;
                            }
                        }
                    }
                    when 'UpdateZones' {
                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }

                        if (editBoardModifiedRecord.UpdateZone != null && editBoardModifiedRecord.UpdateZone != '{}') {
                            kanbanStateChange(editBoardModifiedRecord.VSID, 'MoveZone', '', editBoardModifiedRecord.UpdateZone);
                        }                      
                    }
                    when 'DeleteSingleZone' {
                        if (editBoardModifiedRecord.DeleteZone.size() > 0) {
                            DeleteBuilkyZone(editBoardModifiedRecord.DeleteZone);
                        }

                        if (editBoardModifiedRecord.UpdateMC.size() > 0) {
                            leankor.KanbanController.updateMasterContainer(editBoardModifiedRecord.UpdateMC);
                        }
                        
                        if (editBoardModifiedRecord.UpdateZone != null && editBoardModifiedRecord.UpdateZone != '' && editBoardModifiedRecord.UpdateZone != '{}') {
                            manageStateChange(editBoardModifiedRecord.VSID, 'MoveZone', editBoardModifiedRecord.UpdateZone, USER_SESSION_ID_CONST);
                    	}
                	}
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
		}

        return editBoardModifiedRecord;
    }
    

	global class projectBoardModifiedRecords {
		global String VSID;
		global String UserID;
		global DateTime ModifiedDate;
		global Boolean Identical;
		global String UserName;
    }
    

	/***
	 * Remote web service for resetting the Last modified Date and user of edit mode
	 * INPUT: VSID, UserID,ModifiedDate
	 * OUTPUT: if matched then return True and if not then return False with UsreName(how has modidied recently) ;
	*/
	@RemoteAction
	global static projectBoardModifiedRecords getPermissionToEdit(String projectBoardJSON) {
        //Check CRUD / FLC behavior
        ValuestreamBehavior valuestreamBehavior = new ValuestreamBehavior();

        if (!valuestreamBehavior.isAccessible() 
        || !valuestreamBehavior.isUpdateable()) {
            System.debug('Error: No access to update records');            
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        projectBoardModifiedRecords projectBoardModifiedRecords = (projectBoardModifiedRecords)JSON.deserialize(projectBoardJSON, projectBoardModifiedRecords.class);

        if (String.isNotBlank(projectBoardModifiedRecords.VSID) 
        && Util.getSObjectName(projectBoardModifiedRecords.VSID) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        projectBoardModifiedRecords.Identical = false;

        List<leankor__Valuestream__c> valueStreams = [Select Id, 
                                                                Name, 
                                                                leankor__LastModifiedDateTime__c, 
                                                                leankor__LastModifiedUserID__c, 
                                                                CreatedById, 
                                                                LastModifiedById 
                                                            From leankor__ValueStream__c 
                                                            Where Id = :projectBoardModifiedRecords.VSID];

        if (valueStreams.size() > 0) {            
            if ((valueStreams[0].leankor__LastModifiedUserID__c == projectBoardModifiedRecords.UserID || valueStreams[0].leankor__LastModifiedUserID__c == null) 
            && (valueStreams[0].leankor__LastModifiedDateTime__c == projectBoardModifiedRecords.ModifiedDate || valueStreams[0].leankor__LastModifiedDateTime__c == null)) {
                valueStreams[0].leankor__LastModifiedDateTime__c = System.now();
                valueStreams[0].leankor__LastModifiedUserId__c = USER_ID_CONST;

                try {
                    Update valueStreams;
                    // 09/09/2021 Chnages : Edit board functionality is behaving wrong when user is changing the numbers in card per row option.
                    List<leankor__valuestream__c> updatedValueStreams = [Select 
                                                                                leankor__LastModifiedDateTime__c 
                                                                            From leankor__valuestream__c 
                                                                            Where Id =: valueStreams[0].Id];
                    projectBoardModifiedRecords.ModifiedDate = updatedValueStreams[0].leankor__LastModifiedDateTime__c;
                    //projectBoardModifiedRecords.ModifiedDate = valueStreams[0].leankor__LastModifiedDateTime__c;
                    projectBoardModifiedRecords.UserID = valueStreams[0].leankor__LastModifiedUserID__c;
                    projectBoardModifiedRecords.Identical = true;    
                } catch (DmlException e) {
                    System.debug(e.getMessage());
                    throw new Util.LeanException('Error: ' + e.getmessage());                    
                }
            } else {
                projectBoardModifiedRecords.UserID = valueStreams[0].leankor__LastModifiedUserID__c;
                projectBoardModifiedRecords.ModifiedDate = valueStreams[0].leankor__LastModifiedDateTime__c;

                String userRecordId = String.isBlank(valueStreams[0].leankor__LastModifiedUserID__c)
                    ? (valueStreams[0].LastModifiedById == null ? valueStreams[0].CreatedById : valueStreams[0].LastModifiedById) 
                    : valueStreams[0].leankor__LastModifiedUserID__c;

                List<User> userRecords = [Select Name 
                                                From User 
                                                Where Id = :userRecordId 
                                                Limit 1];

                if (userRecords.size() > 0) {
                    projectBoardModifiedRecords.UserName = userRecords[0].Name;
                }
            }
        }

        return projectBoardModifiedRecords;
    }
    

	/***
	 *  Removes the zone from value stream by making the relationship field blank.
	 * We do this rather than delete() because we may need the zone and all its data for historical reporting
	 * INPUT: The GUID for the zone generated by the browser when it was first created
	 * OUTPUT: String of "success" if all went well and "ERROR: <some message>" if not
	 * (there is likely a more formal way to pass result codes back and error messages!)
	 */
	@RemoteAction
	global static String DeleteBuilkyZone(List<String> zoneIds) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ZoneBehavior zoneBehavior = new ZoneBehavior();

        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isCreateable() 
        || !kanbanCardBehaviour.isUpdateable() 
        || !zoneBehavior.isAccessible() 
        || !zoneBehavior.isUpdateable()) {
            System.debug('Error: No access to create, update or delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                            leankor__GUID__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ZoneGUID__c In :zoneIds 
                                                        Limit 10000];

        for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
            kanbanCard.leankor__ZoneGUID__c = '';
        }

        List<leankor__Zone__c> zones = [Select Id,
                                                leankor__ParentZone__c,     
                                                leankor__ZoneTemplate__c, 
                                                leankor__ValueStreamLink__c, 
                                                leankor__ValueStream__c, 
                                                leankor__Swimlane__c,  
                                                leankor__ValueStreamCardLink__c
                                            From leankor__Zone__c 
                                            Where leankor__GUID__c In :zoneIds 
                                            Limit 10000];

        for (leankor__Zone__c zone : zones) {
            zone.leankor__ParentZone__c = null;
            zone.leankor__ZoneTemplate__c = null;
            zone.leankor__ValueStreamLink__c  = null;
            zone.leankor__ValueStream__c  = null;
            zone.leankor__Swimlane__c  = null;
            zone.leankor__ValueStreamCardLink__c  = null;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            if (kanbanCards.size() > 0) {
                upsert kanbanCards leankor__GUID__c;
            }

            if (!zones.isEmpty()) {
                update zones;
            }
        } catch (DmlException e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());            
        }

        return 'success';
    }
    

    @AuraEnabled 
    @RemoteAction
	global static String getBaseURL() {

        return String.isNotBlank(Network.getNetworkId()) 
        ? ('https://' + DomainCreator.getExperienceCloudSitesHostname() + '/') 
        : ('https://' + DomainCreator.getVisualforceHostname('leankor') + '/');
    }
    

	@RemoteAction
	global static Boolean resetReportData(String valueStreamId, String reportId) {
        if (String.isNotBlank(valueStreamId) 
        && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
 
        //Check CRUD / FLC behavior
        ValueStreamStatisticBehavior valueStreamStatisticBehavior = new ValueStreamStatisticBehavior();
        
        if (!valueStreamStatisticBehavior.isAccessible() 
        || !valueStreamStatisticBehavior.isDeletable()) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Boolean containValueStreamReport = false;
		Reports.ReportDescribeResult reportDescribeResult = Reports.ReportManager.describeReport(reportId);
		Reports.ReportTypeMetadata reportTypeMetadata = reportDescribeResult.getReportTypeMetadata();
        List<Reports.ReportTypeColumnCategory> reportTypeColumnCategories = reportTypeMetadata.getCategories();
        
		for (Reports.ReportTypeColumnCategory reportTypeColumnCategory : reportTypeColumnCategories) {
			if (reportTypeColumnCategory.getLabel() == 'ValueStreamStatistics') {
                containValueStreamReport = true;
                break;
			}
        }
        
		if (containValueStreamReport) {
            List<leankor__ValueStreamStatistic__c> valueStreamStatistics = [Select Id, 
                                                                                    leankor__ValueStream__c 
                                                                                From leankor__ValueStreamStatistic__c 
                                                                                Where leankor__ValueStream__c = :valueStreamId];

            if (valueStreamStatistics.size() > 0) {
                try {
                    delete valueStreamStatistics;
                } catch (DmlException e) {
                    System.debug(e.getMessage());
                    throw new Util.LeanException('Error: ' + e.getmessage());
                }
            }
        }
        
		return true;
	}
    
    
    //26.09.2017 : for Generic Streaming and Bulk call
	@RemoteAction
    @AuraEnabled
	global static String UpdateBulkCardsGS(List<String> cardIds, String updateJSON) {
        // input validation is inside updateBulkCards
        
        UpdateBulkCards(cardIds, updateJSON); 
        
        String kanbanCardIds;
        
		if (IS_GENERIC_STREAMING) {
	        ExternalDependent externalDependent = new ExternalDependent();
	        externalDependent.cardIds = gskanbanCardIds;
	        externalDependent.externalCardIDs = externalCardIDs;        
	        kanbanCardIds = JSON.serialize(externalDependent);
        } else {
        	kanbanCardIds = JSON.serialize(gskanbanCardIds);
        }

        gskanbanCardIds.clear();
        externalCardIDs.clear();

		return kanbanCardIds;
	}
	

    /**
     * Tilak Raj Mahale:28.05.2020 - New method to update the bulk KC records.
     * Note: If UI stop sending ZoneForceID when we are not moving the cards. 
     *       We can otimized the code and then we don't need to process all the fields when we moving the cards.
    */
    @RemoteAction
    global static Boolean UpdateBulkCards(List<String> cardIds, String updateJSON) {
        //Check CRUD / FLC behavior
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior(); 
          
        if (!resourceAssignmentBehavior.isAccessible() 
        || !resourceAssignmentBehavior.isCreateable() 
        || !resourceAssignmentBehavior.isUpdateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__Zone__c> newZones = new List<leankor__Zone__c>();
        Decimal maxOrderSize = 0.0;
        updateTaskDatesWeekCalendar = true;
        // Get the request
        leankor.RealTimeController.Kanban request = (leankor.RealTimeController.Kanban)JSON.deserialize(updateJSON, leankor.RealTimeController.Kanban.class);

        if (String.isNotBlank(request.ValueStreamCardLink)
        && Util.getSObjectName(request.ValueStreamCardLink) != 'leankor__Kanbancard__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        if (String.isNotBlank(request.ZoneForceID)) {
            if (Util.getSObjectName(request.ZoneForceID) != 'leankor__Zone__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

            // Get the maximum KanbanCard order of the new Zone
            AggregateResult[] maximumOrder = [Select Max(leankor__Order__c) MaxOrder 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__Zone__c = :request.ZoneForceID
                                                        And leankor__isRecordDeleted__c = false
                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false];
            
            if (maximumOrder.size() > 0) {
                maxOrderSize = maximumOrder[0].get('MaxOrder') == null ? 0.0 : (Decimal)maximumOrder[0].get('MaxOrder');
            }

            // Get the new zone
            newZones = [Select Id, 
                                (Select Id 
                                        From leankor__kanban_cards__r), 
                                leankor__GUID__c, 
                                leankor__Swimlane__c, 
                                leankor__Swimlane__r.leankor__MasterContainer__c 
                            From leankor__Zone__c 
                            Where Id = :request.ZoneForceID 
                            Limit 1];                                
        }

        String kanbanVerb;
        Set<String> cardLinksIds = new Set<String>();
        List<String> kanbanCardIds = new List<String>();
        List<leankor__Kanbancard__c> kanbanCards = new List<leankor__Kanbancard__c>();

        // For create ZoneKanbanAction records on move
        Map<Id, leankor__Zone__c> mapZones = new Map<Id, leankor__Zone__c>(); 
        Map<Id, leankor__Kanbancard__c> mapKanbanCards = new Map<Id, leankor__Kanbancard__c>(); 

        //Changes for prevent the self linking while select the multiple cards.
        if(cardIds.contains(request.ValueStreamCardLink)) {
            cardIds.remove(cardIds.indexOf(request.ValueStreamCardLink));
        }

        // Process the request
        for (leankor__Kanbancard__c kanbanCard : leankor.RealTimeControllerHelper.readUpdateBulkCard(cardIds)) {
            // Added boardtype condition for planGantt we will not send notify mail when we do multiselect in PlanGantt
            if (String.isNotBlank(request.OwnerID) && kanbanCard.OwnerID != request.OwnerID && kanbanCard.leankor__ValueStream__r.leankor__BoardType__c != 'Uberboard') {
                kanbanVerb = 'CreateKanbanCard';    
            }

            if (String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)) {
                cardLinksIds.add(kanbanCard.leankor__ValueStreamCardLink__c);
            }

            kanbanCard.leankor__CardID__c = String.isBlank(request.CardID) ? (kanbanCard.leankor__CardID__c == null ? '' : kanbanCard.leankor__CardID__c) : request.CardID;
            kanbanCard.leankor__Point__c = request.Point == null ? kanbanCard.leankor__Point__c : request.Point;
            kanbanCard.leankor__Title__c = String.isBlank(request.Title) ? kanbanCard.leankor__Title__c : request.Title;
            kanbanCard.Name = String.isBlank(request.Name) ? kanbanCard.Name : request.Name;
            kanbanCard.leankor__Top__c = request.Top == null ? kanbanCard.leankor__Top__c : request.Top;
            kanbanCard.leankor__Bottom__c = request.Bottom == null ? kanbanCard.leankor__Bottom__c : request.Bottom;
            kanbanCard.leankor__Left__c = request.Left == null ? kanbanCard.leankor__Left__c : request.Left;
            kanbanCard.leankor__width__c = request.width == null ? kanbanCard.leankor__width__c : request.width;
            kanbanCard.leankor__Height__c = request.Height == null ? kanbanCard.leankor__Height__c : request.width;
            kanbanCard.leankor__X__c = request.X == null ? kanbanCard.leankor__X__c : request.X;
            kanbanCard.leankor__Y__c = request.Y == null ? kanbanCard.leankor__Y__c : request.Y;
			//06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
            //kanbanCard.leankor__JSONDefinition__c = String.isBlank(request.JSONDefinition) || String.isBlank(request.TemplateID) ? kanbanCard.leankor__JSONDefinition__c : request.JSONDefinition;
            //kanbanCard.leankor__JSONData__c = String.isBlank(request.TemplateID) || String.isBlank(request.JSONDefinition) ? kanbanCard.leankor__JSONData__c : request.JSONData;
            kanbanCard.leankor__KanbanCardTemplate__c = String.isBlank(request.TemplateID) ? kanbanCard.leankor__KanbanCardTemplate__c : request.TemplateID; 
            kanbanCard.leankor__color__c = String.isBlank(request.Color) ? kanbanCard.leankor__color__c : request.Color; 
            kanbanCard.leankor__AcceptanceCriteria__c = String.isBlank(request.AcceptanceCriteria) ? kanbanCard.leankor__AcceptanceCriteria__c : request.AcceptanceCriteria;
            kanbanCard.leankor__DescriptionLong__c = String.isBlank(request.Description) ? kanbanCard.leankor__DescriptionLong__c : request.Description;
            kanbanCard.leankor__DueDateTime__c = request.DueDate == null ? kanbanCard.leankor__DueDateTime__c : request.DueDate;
            kanbanCard.leankor__EstimatedDuration__c = request.EstimatedDuration == null ? kanbanCard.leankor__EstimatedDuration__c : request.EstimatedDuration;
            kanbanCard.leankor__EffortRemaining__c = Integer.valueof(request.EffortRemaining == null ? kanbanCard.leankor__EffortRemaining__c : request.EffortRemaining);
            kanbanCard.leankor__DurationUnits__c = String.isBlank(request.DurationUnits) ? kanbanCard.leankor__DurationUnits__c : request.DurationUnits;
            kanbanCard.leankor__Priority__c = request.Priority == 4 || request.Priority == null ? Integer.valueOf(kanbanCard.leankor__Priority__c) : request.Priority;
            kanbanCard.OwnerID = String.isBlank(request.OwnerID) ? kanbanCard.OwnerID : request.OwnerID;
            kanbanCard.leankor__ValueStreamCardLink__c = String.isBlank(request.ValueStreamCardLink) ? kanbanCard.leankor__ValueStreamCardLink__c : request.ValueStreamCardLink;
            kanbanCard.leankor__ValueStreamLink__c = String.isBlank(request.ValueStreamLinkID) ? kanbanCard.leankor__ValueStreamLink__c : request.ValueStreamLinkID;
            
            if (String.isNotBlank(request.HarveyBall)) {
                kanbanCard.leankor__HarveyBallDoneDate__c = kanbanCard.leankor__PercentComplete2__c != Decimal.valueof(request.HarveyBall) && Decimal.valueof(request.HarveyBall) == 100 ? System.today() : kanbanCard.leankor__HarveyBallDoneDate__c; 
                kanbanCard.leankor__PromiseCompletionDate__c = kanbanCard.leankor__PercentComplete2__c != Decimal.valueof(request.HarveyBall) && Decimal.valueof(request.HarveyBall) == 100 ? System.now() : kanbanCard.leankor__PromiseCompletionDate__c;                                
                kanbanCard.leankor__PercentComplete2__c = Integer.valueOf(request.HarveyBall);
            }                           
            
            kanbanCard.leankor__Account__c = String.isBlank(request.Account) ? kanbanCard.leankor__Account__c : request.Account;
            kanbanCard.leankor__Opportunity__c = String.isBlank(request.Opportunity) ? kanbanCard.leankor__Opportunity__c : request.Opportunity;
            kanbanCard.leankor__Contact__c = String.isBlank(request.Contact) ? kanbanCard.leankor__Contact__c : request.Contact;
            kanbanCard.leankor__Case__c = String.isBlank(request.CaseId) ? kanbanCard.leankor__Case__c : request.CaseId;
            kanbanCard.leankor__OnBudget__c = String.isBlank(request.OnBudget) ? (kanbanCard.leankor__OnBudget__c == null ? 'Green' : kanbanCard.leankor__OnBudget__c) : request.OnBudget;
            kanbanCard.leankor__OnQuality__c = String.isBlank(request.OnQuality) ? (kanbanCard.leankor__OnQuality__c == null ? 'Green' : kanbanCard.leankor__OnQuality__c) : request.OnQuality;
            kanbanCard.leankor__OnTime__c = String.isBlank(request.OnTime) ? (kanbanCard.leankor__OnTime__c == null ? 'Green' : kanbanCard.leankor__OnTime__c) : request.OnTime;
            kanbanCard.leankor__StartDateTime__c = request.StartDate == null ? (kanbanCard.leankor__StartDateTime__c == null ? System.now() : kanbanCard.leankor__StartDateTime__c) : request.StartDate;
            
            // This if block only execute when we calling this method to move the cards
            if (String.isNotBlank(request.ZoneForceID) && newZones.size() > 0) {
                // If Card has been moved in the same zone, then no need to update the cards
                if (request.ZoneForceID == kanbanCard.leankor__Zone__c) {
                    continue;
                }

                leankor__KanbanCard__c kanban = new leankor__KanbanCard__c (
                    Id = kanbanCard.Id,
                    leankor__ZoneGUID__c = kanbanCard.leankor__ZoneGUID__c,
                    leankor__Zone__c = kanbanCard.leankor__Zone__c,
                    leankor__MasterContainer__c = kanbanCard.leankor__MasterContainer__c,
                    leankor__Swimlane__c = kanbanCard.leankor__Swimlane__c,
                    leankor__ValueStream__c = kanbanCard.leankor__ValueStream__c
                );

                mapKanbanCards.put(kanbanCard.Id, kanban); 

                kanbanCard.leankor__ZoneGUID__c = newZones[0].leankor__GUID__c;
                kanbanCard.leankor__Zone__c = newZones[0].Id;
                kanbanCard.leankor__MasterContainer__c = newZones[0].leankor__Swimlane__r.leankor__MasterContainer__c;
                kanbanCard.leankor__Swimlane__c = newZones[0].leankor__Swimlane__c;
                kanbanCard.leankor__Order__c = ++maxOrderSize; // Increase maxorder by one for each card in new zone.
                kanbanCard.leankor__State__c = kanbanCard.leankor__ZoneGUID__c == null ? 'nozone' : 'inzone';

                // For creating zoneKanbanAction reords
                kanbanCardIds.add(kanbanCard.Id);
                mapZones.put(kanbanCard.Id, newZones[0]);
            }

            kanbanCard.leankor__UrlLink__c = String.isBlank(request.UrlLink) ? kanbanCard.leankor__UrlLink__c : request.UrlLink;
            kanbanCard.leankor__StartDate__c = kanbanCard.leankor__StartDateTime__c.date();
            kanbanCard.leankor__DueDate__c = kanbanCard.leankor__DueDateTime__c.date();

            Set<String> weekDays = new Set<String>();
            if(kanbanCard.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c == true){
                weekDays.add(kanbanCard.leankor__Monday__c == false ? 'Mon' : 'false');
                weekDays.add(kanbanCard.leankor__Tuesday__c == false ? 'Tue' : 'false');
                weekDays.add(kanbanCard.leankor__Wednesday__c == false ? 'Wed' : 'false');
                weekDays.add(kanbanCard.leankor__Thursday__c == false ? 'Thu' : 'false');
                weekDays.add(kanbanCard.leankor__Friday__c == false ? 'Fri' : 'false');
                weekDays.add(kanbanCard.leankor__Saturday__c == false ? 'Sat' : 'false');
                weekDays.add(kanbanCard.leankor__Sunday__c == false ? 'Sun' : 'false');
            }
            Util.weekDays = weekDays;

            if (String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)) {
                cardLinksIds.add(kanbanCard.leankor__ValueStreamCardLink__c);
            }
                    
            kanbanCards.add(kanbanCard);
        }

        if (kanbanCards.size() > 0) {
            BulkStreaming stream = new BulkStreaming();

            stream.sessionID = request.sessionID;
            stream.kanbansObjectList = kanbanCards;
            stream.SomeJSONData = String.isNotBlank(request.Extensions) ? '"Extensions":"'+request.Extensions+'"' :''; 
            stream.verb = 'UpdateMultipleKanbanCards';

            Savepoint sp = Database.setSavepoint();
            try {
                // If we change owner of card in multiselect
                if (String.isNotBlank(kanbanVerb)) {  
                    stream.kanbanVerb = kanbanVerb; 

                    //This method executes CRUD and broadcasting, and therefore must be called only after all CRUD operations are successful, moved below
                    //leankor.RealTimeController.manageBulkStreaming(stream, true);

                    // Update RA when we update kanban card owner
                    List<leankor__ResourceAssignment__c> resourceAssignments = leankor.GanttTaskBoard.updateMultipleRA(cardIds , request.OwnerID);
                    if (resourceAssignments.size() > 0) {
                        upsert resourceAssignments;
                    }
                } else {

                    //This method executes CRUD and broadcasting, and therefore must be called only after all CRUD operations are successful, moved below
                    //leankor.RealTimeController.manageBulkStreaming(stream, true);
                }
                        
                // This method will update  Resource assigment percent completed field as same as activity HarveyBall.              
                if ((String.isNotBlank(request.ValueStreamCardLink) && request.BoardType == null) || String.isNotBlank(request.HarveyBall)) {           
                    cardIds.addAll(cardLinksIds);        
                }             

                Boolean flag = leankor.ProjectBoardCarousel.updateActivityPercentageComplete(cardIds);
                        
                if (request.Units != null) {       
                    leankor.RealTimeController.updateRAallocation(cardIds , updateJSON);
                }

                // Create the ZoneKanbanAction record 
                if (kanbanCardIds.size() > 0) {
                    List<leankor__ZoneKanbanAction__c> zoneKanbanActions = [Select CreatedDate, 
                                                                                    Id,
                                                                                    leankor__ActionType2__c,
                                                                                    leankor__KanbanCard2__c,
                                                                                    leankor__ValueStream__c,
                                                                                    leankor__Zone2__c, 
                                                                                    Name, 
                                                                                    leankor__WaitTime2__c 
                                                                                From leankor__ZoneKanbanAction__c 
                                                                                Where leankor__KanbanCard2__c In :kanbanCardIds 
                                                                                    And leankor__ActionType2__c = 'Entered Zone' 
                                                                                Order By CreatedDate Desc 
                                                                                Limit 50000];
                    
                    // Create the new leankor__ZoneKanbanAction__c for moved card
                    leankor.MoveKanbanCardAction.createZkaRecords(kanbanCardIds, mapKanbanCards, mapZones, zoneKanbanActions);
                }

                //This method executes CRUD and broadcasting, and therefore must be called only after all CRUD operations are successful, moved from above
                leankor.RealTimeController.manageBulkStreaming(stream, true);

            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException(e.getmessage());           
            }
        }

        return true;
    }


    public static void updateRAallocation(List<String> cardIds, String kanbanJson) {
        // input validation is done from the calling method

        //Check CRUD / FLC behavior
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior(); 

        if (!resourceAssignmentBehavior.isAccessible() 
        || !resourceAssignmentBehavior.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__ResourceAssignment__c> resourceAssignments = new list<leankor__ResourceAssignment__c>();
        leankor.realTimeController.Kanban kanban = (leankor.realtimeController.Kanban)JSON.deserialize(kanbanJson, (leankor.realtimeController.Kanban.Class));
         
        for(leankor__ResourceAssignment__c resourceAssignment : [Select leankor__PercentAllocation__c 
                                                                    From leankor__ResourceAssignment__c 
                                                                    Where leankor__KanbanCard__c In :cardIds 
                                                                    Limit 10000]) {

            resourceAssignment.leankor__PercentAllocation__c = kanban.Units;
            resourceAssignments.add(resourceAssignment);
        }

        if (resourceAssignments.size() > 0) {
            update resourceAssignments;
        }
    }
    

    //updating IsSuccessorRecalculate Field if we change Dates
    public static Boolean updateIsSuccessorRecalculate(Set<String> cardLinksIds) {
        // input validation is done from the calling method

        Boolean isSuccess = false;
       
        if (cardLinksIds.size() == 0) {
            return isSuccess;       
        }

        //Check CRUD / FLC behavior	
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');            
        }
        //Check CRUD / FLC behavior
       
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        
        for (String cardLinksId : cardLinksIds) {
            leankor__KanbanCard__c kanbanCard = new leankor__KanbanCard__c(
                Id = cardLinksId,
                leankor__IsSuccessorRecalculate__c = true
            );

            kanbanCards.add(kanbanCard);
        }
        
        if (kanbanCards.size() > 0) {
            try {
                update kanbanCards;
                isSuccess = true;
            } catch(DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());      
            } 
        }

        return isSuccess;
    }
    
    
	global class Sticker {
		global String Name;
		global String Id;
		global String Base64Body;
		global String ContentType;
		global String AttachmentID;
    }
    

	// This method is for uploading stickers for board .
	@RemoteAction
	global static Sticker createSticker(String valueStreamId, List<Sticker> remoteJSON) {
        if (String.isNotBlank(valueStreamId)
        && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior	
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour(); 
        StickerBehavior stickerBehavior = new StickerBehavior();

        if (!attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isCreateable() 
        || !stickerBehavior.isAccessible() 
        || !stickerBehavior.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__Sticker__c> stickers = new List<leankor__Sticker__c>();

        for (Sticker remoteSticker : remoteJSON) {
            leankor__Sticker__c sticker = new leankor__Sticker__c(
                Name = String.isBlank(remoteSticker.Name) ? 'Label' : remoteSticker.Name,
                leankor__ValueStream__c = (valueStreamId == '' ? null : valueStreamId)
            );

            stickers.add(sticker);
        }

        if (stickers.size() > 0) {

            Savepoint sp = Database.setSavepoint();
            try {

                insert stickers;
                
                List<Attachment> attachments = new List<Attachment>();

                Map<Id, Id> contentAttachmentIds = new Map<Id, Id>();

                for (leankor__Sticker__c sticker : stickers) {
                    for (Sticker remoteSticker : remoteJSON) {
                        if (remoteSticker.Base64Body != '' && remoteSticker.ContentType != '') {
                            String fileName = 'Sticker_' + remoteSticker.Name;
                            String suffix = '';

                            if (remoteSticker.ContentType == 'image/jpeg' || remoteSticker.ContentType == 'image/jpg') {
                                suffix = '.jpg';
                            } else if (remoteSticker.ContentType == 'image/gif') {
                                suffix = '.gif';
                            } else if (remoteSticker.ContentType == 'image/bmp') {
                                suffix = '.bmp';
                            } else {
                                suffix = '.png';
                            }

                            Attachment attachment = new Attachment(
                                    Name = fileName + suffix,
                                    ContentType = remoteSticker.ContentType,
                                    ParentId = sticker.Id,
                                    Body = EncodingUtil.Base64Decode(remoteSticker.Base64Body));

                            attachments.add(attachment);
                        } else {
                            /*
                            Integer contentVersionCount = [Select Count()
                                                                From ContentVersion 
                                                                Where ContentDocumentId =  :remoteSticker.AttachmentID 
                                                                    And isLatest = true];

                            if (contentVersionCount == 0) {
                                Attachment att = [SELECT Name, ContentType, ParentID, Body From Attachment where ID =  :remoteSticker.AttachmentID AND Parent.Type IN :SETSTICKERSOBJECTS_CONST Limit 1];
                                
                                Attachment attachment = new Attachment(
                                        Name = att.Name,
                                        ContentType = att.ContentType,
                                        ParentID = sticker.Id,
                                        Body = att.Body);

                                attachments.add(attachment);
                            }
                            */

                            contentAttachmentIds.put(remoteSticker.AttachmentID, sticker.Id);
                        }
                    }
                }
                
                if (contentAttachmentIds.size() > 0) {
                    List<AggregateResult> agContentVersions = [Select Count(Id) ContentVersionCount,
                                                                        ContentDocumentId
                                                                    From ContentVersion 
                                                                    Where ContentDocumentId In :contentAttachmentIds.keySet()
                                                                        And isLatest = true
                                                                    Group By ContentDocumentId];

                    for (AggregateResult agContentVersion : agContentVersions) {
                        Integer contentVersionCount = (Integer)agContentVersion.get('ContentVersionCount');

                        if (contentVersionCount > 0) {
                            Id contentDocumentId = (Id)agContentVersion.get('ContentDocumentId');
                            contentAttachmentIds.remove(contentDocumentId);
                        }                
                    }
                    
                    List<Attachment> addAttachments = [Select Id, 
                                                                Name, 
                                                                ContentType, 
                                                                ParentId, 
                                                                Body 
                                                            From Attachment 
                                                            Where Id In :contentAttachmentIds.keySet() 
                                                                And Parent.Type In :SETSTICKERSOBJECTS_CONST];

                    for (Attachment addAttachment : addAttachments) {
                        Id stickerId = contentAttachmentIds.get(addAttachment.Id);

                        if (stickerId != null) {
                            Attachment attachment = new Attachment(
                                Name = addAttachment.Name,
                                ContentType = addAttachment.ContentType,
                                ParentId = stickerId,
                                Body = addAttachment.Body);

                            attachments.add(addAttachment);
                        }
                    }
                }

                if (attachments.size() > 0) {
                    insert attachments;
                
                    Map<String, String> mapAttachments = new Map<String, String>();

                    for (Attachment attachment : attachments) {
                        mapAttachments.put(attachment.ParentId, attachment.Id);
                    }

                    remoteJSON[0].AttachmentID = mapAttachments.containsKey(stickers[0].Id) ? mapAttachments.get(stickers[0].Id) : remoteJSON[0].AttachmentID;
                    remoteJSON[0].Id = stickers[0].Id;
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());            
            }
        }

        return remoteJSON.size() > 0 ? remoteJSON[0] : new Sticker();
    }
    

	@Remoteaction
	global static String manageBulkDelete(Id valueStreamId, String verb, List<String> someJSONData, String sessionId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        for (String someJSONDatum : someJSONData) {
            if (String.isNotBlank(someJSONDatum) && Util.getSObjectName(someJSONDatum) != 'leankor__KanbanCard__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        String returnVal = '';

        // this code is only for delete verb "Deletebulkcards"
        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                            leankor__ValueStreamCardLink__c, 
                                                            leankor__GUID__c 
                                                        From leankor__KanbanCard__c 
                                                        Where Id In :someJSONData
                                                            And leankor__isRecordDeleted__c = false 
                                                            And leankor__ValueStream__r.leankor__isRecordDeleted__c = false];

        List<String> allCardIds = new List<String>();
        
		for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
			//Add parent ids to gs Variable, we have removed call for getLinkedIds method from glueforce unnecessory
			if(String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)){
				gskanbanCardIds.add(kanbanCard.leankor__ValueStreamCardLink__c);
            }
            
			allCardIds.add(kanbanCard.leankor__GUID__c);
        }

        if (allCardIds.size() > 0) {
            try {
                removeKanbanCard(allCardIds);
                List<String> jsonList = new List<String>{JSON.serialize(someJSONData)};
                
                //TODO: Investigate the call to this method, should it be called before or after the call to updateParentCards
                leankor.GenericStreamingController.createRealtimeTracker(valueStreamId, verb, jsonList, sessionId);
                //19/Feb/2024 : we have commenting this method this is already calling inside removeKanbanCard method which is i calling in upper code.
                //leankor.RealTimeController.updateParentCards(kanbanCards);
                returnVal = JSON.serialize(gskanbanCardIds);
                gskanbanCardIds.clear();
                
            } catch (Exception e) {			
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }

        return returnVal;
    }
    @AuraEnabled
    public static Boolean checkIntroDetails(String board) {
        // Query to check if any Intro records exist for the current user and the specified board
        Integer introLogs = [SELECT Count()
                                FROM leankor__Intro__c 
                                WHERE OwnerId = :UserInfo.getUserId()
                                    AND leankor__IntroLocation__c = :board];

        // Return true if no logs exist, false otherwise
        return (introLogs == 0);
    }


	@RemoteAction
	global static Boolean getIntroDetails(String board) {
        Integer introLogs = [Select Count()
                                From leankor__Intro__c 
                                Where OwnerId =  :USER_ID_CONST
                                    And leankor__IntroLocation__c = :board];

        return (introLogs == 0);
    }
    
    @AuraEnabled
    public static Boolean createIntroDetails(String board) {
        // Call the existing @RemoteAction method
        Boolean result = setIntroDetails(board);
        return result;
    }

	@RemoteAction
	global static Boolean setIntroDetails(String board) {
        //Check CRUD / FLC behavior
        IntroBehaviour introBehaviour = new IntroBehaviour();

        if (!introBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__Intro__c intro = new leankor__Intro__c();

        intro.leankor__IntroLocation__c = board;

        try {
            insert intro;
        } catch (DmlException e) {
            System.debug(e.getMessage());
            throw new Util.LeanException('Error: ' + e.getmessage());
        }

        return true;
    }
    

	@Future
	global static Void KCupdateParentcard(String kanbanCardString) {
         //Check CRUD / FLC behavior
         DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();

         if (!dependencyBehaviour.isAccessible()
         || !dependencyBehaviour.isUpdateable()) {
             System.debug('Error: No access to update records');
             throw new Util.LeanException('Error: No access to records');
         }
         //Check CRUD / FLC behavior
		KCupdatePVcard(kanbanCardString);
    }
    

    //TODO: must refactor, method is too long


  

    global static void KCupdatePVcard(String kanbanCardString) {

        //Check CRUD / FLC behavior
       /* DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();

        if (!dependencyBehaviour.isAccessible()
        || !dependencyBehaviour.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior*/

        List<leankor__kanbancard__c> kanbanCards = (List<leankor__kanbancard__c>)JSON.deserialize(kanbanCardString, List<leankor__kanbancard__c>.class);
        
        Set<String> parentCards = new Set<String>(); 
        if (valueStreamCardLinkIDList.size() > 0 && checkDefaultLinkFlag) {
            parentCards.addall(valueStreamCardLinkIDList);
        }
        
        Boolean nonEmptyChild = true;
        Map<String, leankor__KanbanCard__c> mapKanbanCards = new Map<String, leankor__Kanbancard__c>();
        Map<String, DateTime> mapDueDates = new Map<String, DateTime>();
        Map<String, DateTime> mapStartDates = new Map<String, DateTime>();
        Map<String, Integer> mapHarveyBalls = new Map<String, Integer>();
        Map<String, Integer> mapChildCounts = new Map<String, Integer>();
        Map<String, Decimal> mapBudgetedTimeTotals = new Map<String, Decimal>();
        Map<String, Decimal> mapBudgetTimeRemainingTotals = new Map<String, Decimal>();
        List<leankor__KanbanCard__c> updateParentCards = new List<leankor__KanbanCard__c>();
        List<leankor.realtimeController.bulkStreaming> bulkStreamingMessages = new List<leankor.realtimeController.bulkStreaming>();
        
        for (leankor__kanbancard__c kanbanCard : kanbanCards) {
            if (kanbanCard.leankor__ValueStreamCardLink__c != null) {
                parentCards.add(kanbanCard.leankor__ValueStreamCardLink__c);
            }
        }
           
        for (leankor__kanbancard__c kanbanCard : RealTimeControllerHelper.readKcUpdatePvCards(parentCards)) {
            if (parentCards.contains(kanbanCard.ID) 
            && (kanbanCard.leankor__Valuestream__r.leankor__PortfolioMode__c || kanbanCard.leankor__Valuestream__r.leankor__BoardType__c == 'UberBoard')) {          
                updateParentCards.add(kanbanCard);
            }

            //Do not calculate Date of  parent if child is Deleted
            if (parentCards.contains(kanbanCard.leankor__ValueStreamCardLink__c) 
            && !kanbanCard.leankor__IsRecordDeleted__c) {
                if (mapDueDates.containskey(kanbanCard.leankor__ValueStreamCardLink__c)) {
                    DateTime maxDueDate = mapDueDates.get(kanbanCard.leankor__ValueStreamCardLink__c);
                    DateTime minStartDate = mapStartDates.get(kanbanCard.leankor__ValueStreamCardLink__c);
                    Integer totalHarvey = mapHarveyBalls.get(kanbanCard.leankor__ValueStreamCardLink__c);
                    Integer childCount = mapChildCounts.get(kanbanCard.leankor__ValueStreamCardLink__c) + 1;
                    Decimal totalTime = mapBudgetedTimeTotals.get(kanbanCard.leankor__ValueStreamCardLink__c);
                    Decimal totalRemainingTime = mapBudgetTimeRemainingTotals.get(kanbanCard.leankor__ValueStreamCardLink__c);
                    
                    if (kanbanCard.leankor__DueDateTime__c > maxDueDate) {
                        mapDueDates.put(kanbanCard.leankor__ValueStreamCardLink__c, kanbanCard.leankor__DueDateTime__c);
                    }

                    if (kanbanCard.leankor__StartDateTime__c < minStartDate) {
                        mapStartDates.put(kanbanCard.leankor__ValueStreamCardLink__c, kanbanCard.leankor__StartDateTime__c);
                    }
                    
                    mapHarveyBalls.put(kanbanCard.leankor__ValueStreamCardLink__c, Integer.valueof(totalHarvey + kanbanCard.leankor__PercentComplete2__c));                    
                    mapChildCounts.put(kanbanCard.leankor__ValueStreamCardLink__c, childCount);
                    mapBudgetedTimeTotals.put(kanbanCard.leankor__ValueStreamCardLink__c, totalTime + kanbanCard.leankor__Budgeted_Time__c);
                    mapBudgetTimeRemainingTotals.put(kanbanCard.leankor__ValueStreamCardLink__c, totalRemainingTime + kanbanCard.leankor__BudgetTimeRemaining__c);
                } else {
                    mapDueDates.put(kanbanCard.leankor__ValueStreamCardLink__c, kanbanCard.leankor__DueDateTime__c);
                    mapStartDates.put(kanbanCard.leankor__ValueStreamCardLink__c, kanbanCard.leankor__StartDateTime__c);
                    mapHarveyBalls.put(kanbanCard.leankor__ValueStreamCardLink__c, Integer.valueof(kanbanCard.leankor__PercentComplete2__c));
                    mapChildCounts.put(kanbanCard.leankor__ValueStreamCardLink__c, 1);
                    mapBudgetedTimeTotals.put(kanbanCard.leankor__ValueStreamCardLink__c, kanbanCard.leankor__Budgeted_Time__c);
                    mapBudgetTimeRemainingTotals.put(kanbanCard.leankor__ValueStreamCardLink__c, kanbanCard.leankor__BudgetTimeRemaining__c);
                }
            }
        }
        
        Set<String> linkCardIds = new Set<String>();

        //This variable is used for adding card ids of ext. dependent card
        Set<String> externalCardIds = new Set<String>();

        //04.05.2018 - getting first day of week from custom setting	
        leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();
    	Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();	
        
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);


		List<Task> oldTasks = new List<Task>();        
        Map<String, List<Task>> mapTasks = new Map<String,List<Task>>();

        List<Task> taskRecords = [Select Id, 
                                            ActivityDate, 
                                            Description, 
                                            WhatId 
                                        From Task 
                                        Where WhatId In :updateParentCards 
                                            And What.Type = 'leankor__KanbanCard__c'
                                            And IsDeleted = false 
                                        Limit 50000 
                                        All Rows];
        
        //find all Task records under each KanbanCard Record       	
        for (Task task : taskRecords) {
			List<Task> taskList = mapTasks.containsKey(task.WhatId) ? mapTasks.get(task.WhatId) : new List<Task>();
        	taskList.add(task);  
          	mapTasks.put(task.WhatId, taskList);
	  	}        

        for (leankor__Kanbancard__c kanbanCard : updateParentCards) {
            if (!mapHarveyBalls.containsKey(kanbanCard.Id)) {
                nonEmptyChild = false;
                continue;
            }

            Integer totalHarvey = mapHarveyBalls.get(kanbanCard.Id);            
            Integer childCount = mapChildCounts.get(kanbanCard.Id);   
            Decimal allBudgetedTime = mapBudgetedTimeTotals.containsKey(kanbanCard.Id) ? mapBudgetedTimeTotals.get(kanbanCard.ID) : 0;
            Decimal allBudgetTimeRemaining = mapBudgetTimeRemainingTotals.containsKey(kanbanCard.Id) ? mapBudgetTimeRemainingTotals.get(kanbanCard.Id) : 0;
            Decimal harveyBall = allBudgetedTime - allBudgetTimeRemaining;                   
            leankor.realTimeController.Kanban remoteKanban = new leankor.realTimeController.Kanban();

            mapKanbanCards.put(kanbanCard.Id, kanbanCard);

            remoteKanban.Id = kanbanCard.ID;
            remoteKanban.CardID = kanbanCard.leankor__CardId__c == null ? '' : kanbanCard.leankor__CardId__c;
            remoteKanban.Point = kanbanCard.leankor__Point__c;
            remoteKanban.ForceID = kanbanCard.ID;
            remoteKanban.GUID = kanbanCard.leankor__GUID__c;
            remoteKanban.Title = kanbanCard.leankor__KanbanCardTemplate__r.Name;
            remoteKanban.Name = kanbanCard.Name;
            remoteKanban.Top = kanbanCard.leankor__Top__c;
            remoteKanban.Bottom = kanbanCard.leankor__Bottom__c;
            remoteKanban.Left = kanbanCard.leankor__Left__c;
            remoteKanban.width = kanbanCard.leankor__width__c;
            remoteKanban.Height = kanbanCard.leankor__Height__c;
            remoteKanban.X = kanbanCard.leankor__X__c;
            remoteKanban.Y = kanbanCard.leankor__Y__c;
            remoteKanban.JSONDefinition = kanbanCard.leankor__JSONDefinition__c;
            remoteKanban.JSONData = kanbanCard.leankor__JSONData__c;
            remoteKanban.TemplateID = kanbanCard.leankor__KanbanCardTemplate__c;
            remoteKanban.Color = kanbanCard.leankor__color__c;
            remoteKanban.AcceptanceCriteria = kanbanCard.leankor__AcceptanceCriteria__c;
            remoteKanban.Description = kanbanCard.leankor__DescriptionLong__c;
            remoteKanban.EffortRemaining = Integer.valueOf(kanbanCard.leankor__EffortRemaining__c);
            remoteKanban.DurationUnits = 'Days';
            remoteKanban.Priority = Integer.valueOf(kanbanCard.leankor__Priority__c);
            remoteKanban.OwnerID = kanbanCard.OwnerID;
            remoteKanban.ValueStreamCardLink = kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__c;
            remoteKanban.ValueStreamLinkID = kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__c;
            remoteKanban.ValueStream = kanbanCard.leankor__ValueStream__c;
            remoteKanban.Account = kanbanCard.leankor__Account__c == null ? '' : kanbanCard.leankor__Account__c;
            remoteKanban.Opportunity = kanbanCard.leankor__Opportunity__c == null ? '' : kanbanCard.leankor__Opportunity__c;
            remoteKanban.Contact = kanbanCard.leankor__Contact__c == null ? '' : kanbanCard.leankor__Contact__c;
            remoteKanban.CaseID = kanbanCard.leankor__Case__c == null ? '' : kanbanCard.leankor__Case__c;
            remoteKanban.Order = kanbanCard.leankor__Order__c == null ? 0 : kanbanCard.leankor__Order__c;
            remoteKanban.OnBudget = kanbanCard.leankor__OnBudget__c == null ? 'Green' : kanbanCard.leankor__OnBudget__c;
            remoteKanban.OnQuality = kanbanCard.leankor__OnQuality__c == null ? 'Green' : kanbanCard.leankor__OnQuality__c;
            remoteKanban.OnTime = kanbanCard.leankor__OnTime__c == null ? 'Green' : kanbanCard.leankor__OnTime__c;
            remoteKanban.ZoneID = kanbanCard.leankor__ZoneGUID__c == null ? '' : kanbanCard.leankor__ZoneGUID__c;
            remoteKanban.MCForceID = kanbanCard.leankor__MasterContainer__c;
            remoteKanban.SWForceID = kanbanCard.leankor__Swimlane__c;
            remoteKanban.ZoneForceID = kanbanCard.leankor__Zone__c;
            remoteKanban.BoardType = kanbanCard.leankor__Valuestream__r.leankor__Boardtype__c;
            remoteKanban.ValueStreamLinkBoardType = kanbanCard.leankor__ValueStreamLink__r.leankor__Boardtype__c;
            remoteKanban.UrlLink = kanbanCard.leankor__UrlLink__c;
            remoteKanban.State = kanbanCard.leankor__ZoneGUID__c == null ? 'nozone' : 'inzone';
            
            if (harveyBall == 0) {
                remoteKanban.HarveyBall = String.valueOf(0);
			} else {
                remoteKanban.HarveyBall = String.valueOf(Integer.valueOf((harveyBall == 0 ? 1 : harveyBall) * 100 / (allBudgetedTime == 0 ? 1 : allBudgetedTime)));
			}
			
			// YJ 15.11.2017 updating HarveyBallDoneDate and PromiseCompletionDate
			remoteKanban.HarveyBallDoneDate = (kanbanCard.leankor__PercentComplete2__c != Decimal.valueOf(remoteKanban.HarveyBall) && Decimal.valueOf(remoteKanban.HarveyBall) == 100) ? System.today() : kanbanCard.leankor__HarveyBallDoneDate__c; 
			remoteKanban.PromiseCompletionDate = (kanbanCard.leankor__PercentComplete2__c != Decimal.valueOf(remoteKanban.HarveyBall) && Decimal.valueOf(remoteKanban.HarveyBall) == 100) ? System.now() : kanbanCard.leankor__PromiseCompletionDate__c;           
            
            if (kanbanCard.leankor__Valuestream__r.leankor__Boardtype__c == 'UberBoard') {
                remoteKanban.DueDate = kanbanCard.leankor__DueDateTime__c;
                remoteKanban.StartDate = kanbanCard.leankor__StartDateTime__c;
                remoteKanban.EstimatedDuration = kanbanCard.leankor__EstimatedDuration__c;
            } else {
                Integer dueYear = mapDueDates.get(kanbanCard.Id).year();
                Integer dueMonth = mapDueDates.get(kanbanCard.Id).month();
                Integer dueDay = mapDueDates.get(kanbanCard.Id).day();
                Integer dueHour = System.now().hour();
                Integer dueMinute = System.now().minute();
                Integer dueSecond = System.now().second();

                remoteKanban.DueDate = DateTime.newInstance(dueYear, dueMonth, dueDay, dueHour, dueMinute, dueSecond);
                                    
                Integer year = mapStartDates.get(kanbanCard.Id).year();
                Integer month = mapStartDates.get(kanbanCard.Id).month();
                Integer day = mapStartDates.get(kanbanCard.Id).day();
                Integer hour = system.now().hour();
                Integer minute = system.now().minute();
                Integer second = system.now().second();

                //RS 30/07/2018 Linking Card to Gantt's Milestone
                remoteKanban.StartDate = kanbanCard.RecordType.Name != 'MileStoneCard' ? Datetime.newInstance(year, month, day, hour, minute, second) : DateTime.newInstance(dueYear, dueMonth, dueDay, dueHour, dueMinute, dueSecond) ;
                            
                //RS 30/07/2018 Linking Card to Gantt's Milestone
                Integer diffDay = kanbanCard.RecordType.Name != 'MileStoneCard' ? (remoteKanban.StartDate.Date().daysBetween(remoteKanban.DueDate.Date()) + 1) : 0;
                remoteKanban.EstimatedDuration = diffDay;

                if (!kanbanCard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c) {
                    Integer count = 0;
                    DateTime startDate = remoteKanban.StartDate;

                    while (startDate <= remoteKanban.DueDate) {
                        if (!workWeek.isWorkingDay(startDate.format('EEEE'))) {
                            count++;
                        }
                        
                        startDate = startDate + 1;
                    }
                    
                    remoteKanban.EstimatedDuration = (remoteKanban.EstimatedDuration - count) == 0 ? count : remoteKanban.EstimatedDuration - count;				
                }
            }

            remoteKanban.isOnHold = kanbanCard.leankor__IsOnHold__c;
            remoteKanban.isAtRisk = kanbanCard.leankor__IsAtRisk__c;
            
			leankor.realtimeController.bulkStreaming bulkStreaming = new leankor.realtimeController.bulkStreaming();
			bulkStreaming.SomeJSONData = JSON.Serialize(remoteKanban);
			bulkStreaming.VSID = kanbanCard.leankor__ValueStream__c;
            bulkStreaming.Verb = flowWithGSForAPI ? 'AddMiniature' : 'UpdateMultipleKanbanCards';
            bulkStreaming.SessionID = USER_SESSION_ID_CONST;
                                                                
            //RS 08/08/2018 isSuccessor Recalculation for milestone and activity                                                    
            if (kanbanCard.Recordtype.Name != 'FolderCard') {
            	linkCardIds.add(kanbanCard.Id);
            }
                                                               
            bulkStreamingMessages.add(bulkStreaming);
            
			/*
			it will be again true if parent card have to update 
			when we have two card in plan gantt first card has no child 
			but second has child than we have to put again true in nonEmptyChild.
            */
            nonEmptyChild = true;
            
            //----- The following code is moved from below
            //TODO: Need to analyze the following code as it might not need to use mapKanbanCards
            if (mapKanbanCards.containsKey(kanbanCard.Id)) {	
                if (mapTasks.get(kanbanCard.Id) != null && mapTasks.get(kanbanCard.Id).size() > 0) {    
                    for (Task loopTask : mapTasks.get(kanbanCard.Id)) {
                        Task updateTask = new Task();

                        updateTask.Id = loopTask.Id;

                        //TODO: This might not be needed
                        leankor__KanbanCard__c oldKanbanCard = mapKanbanCards.get(kanbanCard.Id);
                        
                        //TODO: This might not be needed as it is validating against itself
                        if (Date.newinstance((kanbanCard.leankor__StartDateTime__c).year(), 
                        (kanbanCard.leankor__StartDateTime__c).month(), 
                        (kanbanCard.leankor__StartDateTime__c).day()) != Date.newinstance((oldKanbanCard.leankor__StartDateTime__c).year(), 
                        (oldKanbanCard.leankor__StartDateTime__c).month(), 
                        (oldKanbanCard.leankor__StartDateTime__c).day()) && Date.newinstance((kanbanCard.leankor__DueDateTime__c).year(), 
                        (kanbanCard.leankor__DueDateTime__c).month(), 
                        (kanbanCard.leankor__DueDateTime__c).day()) != Date.newinstance((oldKanbanCard.leankor__DueDateTime__c).year(), 
                        (oldKanbanCard.leankor__DueDateTime__c).month(), 
                        (oldKanbanCard.leankor__DueDateTime__c).day())) {

                            Integer diff = (oldKanbanCard.leankor__StartDateTime__c.date()).daysBetween(kanbanCard.leankor__StartDateTime__c.date());
                            updateTask.ActivityDate = loopTask.ActivityDate + diff;
                        }
                        //TODO:

                        if (updateTask.ActivityDate > kanbanCard.leankor__DueDateTime__c && kanbanCard.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                            updateTask.ActivityDate = Date.newinstance((kanbanCard.leankor__DueDateTime__c).year(), (kanbanCard.leankor__DueDateTime__c).month(), (kanbanCard.leankor__DueDateTime__c).day());
                        }

                        if (updateTask.ActivityDate < kanbanCard.leankor__StartDateTime__c && kanbanCard.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                            updateTask.ActivityDate = Date.newinstance((kanbanCard.leankor__StartDateTime__c).year(), (kanbanCard.leankor__StartDateTime__c).month(), (kanbanCard.leankor__StartDateTime__c).day());
                        }

                        oldTasks.add(updateTask);
                    }
                }
            }
            //-----
        }
        
		if (updateParentCards.size() > 0 || nonEmptyChild) {
            Set<String> recalculateIds = new Set<String>(); 
			checkDefaultLinkFlag = false;
            
            for (String linkCardId : linkCardIds) {
            	if (Util.recalculateRecord.containsKey(linkCardId)) {
            		recalculateIds.add(linkCardId);
            	}
            }
            
            Savepoint sp = Database.setSavepoint();
            try {            
                if (oldTasks.size() > 0) {
                    leankor.OpenTaskRestriction.updateTask(oldTasks);
                }

                //Update isSuccessorRecalculate only when date values are changed or card to card is changed calculated with Util.recalculateRecord 
                if (recalculateIds.size() > 0) {
                    //If Update of IsSuccessor is successful then add IsSR in JSON for broadcast in PT
                    Boolean isUpdateSuccess = leankor.RealtimeController.updateIsSuccessorRecalculate(recalculateIds);
                    
                    if (isUpdateSuccess) {
                        String tempSomeJSONData = bulkStreamingMessages[0].SomeJSONData.removeEndIgnoreCase('}');
                        tempSomeJSONData +=  ',"'+'IsSR'+'":'+'true'+'}';
                        bulkStreamingMessages[0].SomeJSONData = tempSomeJSONData;
                    }
                    
                    //Update Dependency records  
                    RealTimeControllerHelper.DependencyMap dependencyMap = GanttTaskBoard.readSuccessorDependencyForRecalculate(recalculateIds);
                    if (dependencyMap.externalDependencies.size() > 0) {
                        Database.update(new List<leankor__Dependency__c>(dependencyMap.externalDependencies));
                    }
                    
                    externalCardIds = dependencyMap.externallyDependentVSIds;
                    List<BulkStreaming> streamDependentCards =	leankor.RealTimeControllerHelper.getDependentCardsDataForStreaming(dependencyMap.externalDependencies);
                    
                    if (streamDependentCards.size() > 0) {
                        leankor.realtimeController.manageBulkStreaming(streamDependentCards, 'ManageDependency');
                    }
                    
                    if (IS_GENERIC_STREAMING) {
                        if (isUpdateSuccess) {
                            parentActivityIds = recalculateIds;
                        }
                        
                        if (externalCardIds.size() > 0) {
                            externalCardIDs.addAll(externalCardIds);
                        }
                    }
                }
                
                leankor.realtimeController.manageBulkStreaming(bulkStreamingMessages, flowWithGSForAPI ? 'AddMiniature' : 'UpdateMultipleKanbanCards');
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());
            }
        }
	  	}
  		
	               
    global static Integer getHarveyBall(integer harveyBall) {
		return harveyBall;
	}


    global class issuelog {
		global List<Schema.PicklistEntry> Weight;
		global List<Schema.PicklistEntry> Probability;
	}


    @RemoteAction
	global static leankor.realTimeController.issuelog getIssuelogpicklist() {
		leankor.realTimeController.issuelog result = new leankor.realTimeController.issuelog();

		DescribeSchema describeSchema = new DescribeSchema();
		Map <String,Schema.SObjectField> globalDescribefield = describeSchema.getObjectFields('leankor__IssueLog__c');
		result.Weight = globalDescribefield.get('leankor__Weight__c').getDescribe().getPicklistValues();
		result.Probability = globalDescribefield.get('leankor__Probability__c').getDescribe().getPicklistValues();

        return result;
    }
    

	@RemoteAction
	global static List<Account> getAccountFilter(Boolean filter) {
        List<Account> accounts = new List<Account>();
        
        if (filter == true) {
            accounts = [Select Id, 
                                Name 
                            From Account 
                            Where OwnerId = :USER_ID_CONST 
                            Limit 50000];
        } else {
            accounts = [Select Id, 
                                Name 
                            From Account 
                            Limit 50000];
        }

        return accounts;
    }
    

	@RemoteAction
	global static leankor__ValueStream__c updateBoardsetting(ProjectBoard board) {

        if (String.isNotBlank(board.ID) && Util.getSObjectName(board.ID) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();

        if (!valueStreamBehavior.isAccessible() 
        || !valueStreamBehavior.isUpdateable()) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior        

        leankor__Valuestream__c returnVal = new leankor__Valuestream__c();

        List<leankor__Valuestream__c> valueStreams = [Select Id, 
                                                                leankor__SevenDayWorkWeek__c,
                                                                leankor__IsShowCategoryColor__c
                                                            From leankor__ValueStream__c 
                                                            Where Id = :board.ID];
        
        if (valueStreams.size() > 0) {
            valueStreams[0].leankor__SevenDayWorkWeek__c = board.SevenDayWorkWeek;
            valueStreams[0].leankor__IsShowCategoryColor__c = board.isShowCategoryColor == null ? false : board.isShowCategoryColor;
            try {
                update valueStreams;
                returnVal = valueStreams[0];
            } catch (DmlException e) {
                System.debug(e.getMessage());
                throw new Util.LeanException('Error: ' + e.getmessage());                
            }
        }

        return returnVal;
    }
    

	global class AccountFilter{
		global Integer OffsetSize;
		global String FilterValue;
		global Integer Limits;
		global Boolean MyRecord;		
    }
    

	@RemoteAction
	global static RecordDetails getAccountsRecord(AccountFilter accountFilter) {
		Integer count = 0;
        List<Account> accounts = new List<Account>();
        
        //List<account> Listofaccounts = new List<Account>();
        
        if (accountFilter.MyRecord == true) {
            //Listofaccounts = [SELECT Id, Name FROM Account WHERE OwnerId = :USER_ID_CONST Limit 49999];
            if(accountFilter.filterValue.length() > 1){
                List<List<Account>> searchCount = [Find :accountFilter.FilterValue In Name Fields Returning Account (Id, Name Where OwnerId = :USER_ID_CONST)];
                count =  searchCount[0].size();
                List<List<Account>> searchList = [Find :accountFilter.FilterValue In Name Fields Returning Account (Id, Name Where OwnerId = :USER_ID_CONST Limit :accountFilter.Limits Offset :accountFilter.OffsetSize)];
                accounts = searchList[0];
            }else{
            count = [Select Count() 
                        From Account 
                        Where OwnerId = :USER_ID_CONST];

            accounts = [Select Id, 
                                Name 
                            From Account 
                                Where OwnerId = :USER_ID_CONST 
                            Limit :accountFilter.Limits 
                            Offset :accountFilter.OffsetSize];
            }                
        } else {
            //Listofaccounts = [SELECT Id, Name FROM Account Limit 49999];
            if(accountFilter.filterValue.length() > 1){
                List<List<Account>> searchCount = [Find :accountFilter.FilterValue In Name Fields Returning Account (Id, Name)];
                count =  searchCount[0].size();
                List<List<Account>> searchList = [Find :accountFilter.FilterValue In Name Fields Returning Account (Id, Name Limit :accountFilter.Limits Offset :accountFilter.OffsetSize)];
                accounts = searchList[0];
            }else{
            count = [Select Count() 
                                From Account
                                Limit 50000];

                accounts = [Select Id, 
                                Name 
                            From Account 
                            Limit :accountFilter.Limits 
                            Offset :accountFilter.OffsetSize];
        }
        }
        accounts.sort();
        RecordDetails recordDetails = new RecordDetails();

        recordDetails.Count = count;
        recordDetails.OffsetSize = accountFilter.OffsetSize;
        recordDetails.Accounts = accounts;
		
		return recordDetails;
    }
    

	//convert private to public we need this method in other classes also.

    public static void defaultLinkBroadcasting(List<bulkStreaming> realTimeStreaming, String kanbanVerb) {

        // input validation is done from the calling method

     	//Instance to hold List of broadcast events
		List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
     	List<leankor__RealtimeTracker__c> realtimeTrackers = new List<leankor__RealtimeTracker__c>();
     	JSONGroup myJSONGroup = new JSONGroup();
     	
     	for (bulkStreaming bulkStreaming : realTimeStreaming) {
            if (IS_USING_PLATFORM_EVENT) {
     		    broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(bulkStreaming.Verb, bulkStreaming.SomeJSONData, bulkStreaming.SessionID));
            }

            if (!putJSONGroup(bulkStreaming.SomeJSONData, myJSONGroup)) {						
				System.debug('ERROR: JSON String too large for broadcasting [' + bulkStreaming.Verb + '] for ValueStream: ' + bulkStreaming.vsId);
			} else { 
		     	leankor__RealtimeTracker__c realtimeTracker = new leankor__RealtimeTracker__c();
		     	realtimeTracker.leankor__ValueStream__c =  bulkStreaming.VSID;
				realtimeTracker.leankor__SessionID__c = bulkStreaming.SessionID;
				realtimeTracker.leankor__KanbanVerb__c = bulkStreaming.Verb;
				realtimeTracker.leankor__JSONDataSmall__c = myJSONGroup.JSON1;
				realtimeTracker.leankor__JSONDataSmall2__c = myJSONGroup.JSON2;
				realtimeTracker.leankor__JSONDataSmall3__c = myJSONGroup.JSON3;
				realtimeTracker.leankor__JSONDataSmall4__c = myJSONGroup.JSON4;
				realtimeTracker.leankor__JSONDataSmall5__c = myJSONGroup.JSON5;
				realtimeTracker.leankor__JSONDataSmall6__c = myJSONGroup.JSON6;
				realtimeTracker.leankor__JSONDataSmall7__c = myJSONGroup.JSON7;
				realtimeTracker.leankor__JSONDataSmall8__c = myJSONGroup.JSON8;
				
				realtimeTrackers.add(realtimeTracker);    
	     	 }
        }
        
        try {
            if (realtimeTrackers.size() > 0) {
                //Date : 22/05/19  record insert in without sharing class
                OpenTaskRestriction.insertRealTimeTrackers(realtimeTrackers);
            }

            if (IS_USING_PLATFORM_EVENT && broadcastEvents.size() > 0) {
                LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            //throw new Util.LeanException('Error: ' + e.getmessage());
        }
    }
          

    /*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accessor method for item metadata.
	Inputs: 		None
	Returns: 		List<leankor__VisualLeanUIItemSetting__mdt>
	------------------------------------------------------------*/
    public static List<leankor__VisualLeanUIItemSetting__mdt> getVisualLeanUIItemSettings() {        
        return [Select Label, 
                        leankor__UIJSONString__c 
                    From leankor__VisualLeanUIItemSetting__mdt
                    Limit 50000];
    }

    
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Accessor method for header metadata
	Inputs: 		None
	Returns: 		List<leankor__VisualLeanUIHeaderSetting__mdt>
	------------------------------------------------------------*/
    public static List<leankor__VisualLeanUIHeaderSetting__mdt> getVisualLeanUIHeaderSettings() {        
        return [Select Label, 
                        leankor__UIJSONString__c 
                    From leankor__VisualLeanUIHeaderSetting__mdt
                    Limit 50000];
    }

    
	/*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Obtains all cards on a board.
	Inputs: 		None
	Returns: 		List<leankor__KanbanCard__c>
	------------------------------------------------------------*/
    public List<leankor__KanbanCard__c> getBoardKanbanCards() {    	
		DescribeSchema describeSchema = new DescribeSchema();
		List<leankor__KanbanCard__c> boardKanbanCards = new List<leankor__KanbanCard__c>();
        Set<String> allOtherFields = new Set<String>();
        
		//DCO 10.8.17 added kanbanCardJSONUpdator instantiation
		KanbanCardJSONUpdator kanbanCardJSONUpdator = new KanbanCardJSONUpdator();
		try {
			Set<String> allFields = fieldMapKanbanCard.keyset();
			
			//Use allOtherFields because the allFields set is read-only
			allOtherFields.addAll(allFields);
			
			//----------adding Name of refrenceObject----------------
			//Add name of reference object for dynamic query 
			Set<String> referenceFieldNames = describeSchema.getReferenceFieldName(fieldMapKanbanCard);
			allOtherFields.addAll(referenceFieldNames); 
			
			//Add all fields not obtained through the schema describe such as the dot
			//quantified fields.
						
			allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__Color__c');
			allOtherFields.add('leankor__Opportunity__r.StageName');
			allOtherFields.add('leankor__ValueStreamLink__r.leankor__BoardType__c');
			allOtherFields.add('leankor__Case__r.Subject');
			allOtherFields.add('leankor__Case__r.Status');
			allOtherFields.add('leankor__Case__r.Priority');
            allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__FieldSetName__c');
            allOtherFields.add('leankor__ValueStreamLink__r.leankor__ProjectRoom__c');
                     
            //DCO 10.8.17 update JSONDefinition and JSONData
			//Changes done while Lazy load custom field data on load
            boardKanbanCards = describeSchema.dynamicFieldQuery('leankor__KanbanCard__c', allOtherFields, 
                			'WHERE leankor__ValueStream__c = ' + '\'' + this.theValueStream.Id + '\'' + ' AND leankor__KanbanCard__c.leankor__isRecordDeleted__c = false and leankor__ValueStream__r.leankor__isRecordDeleted__c = false AND RecordType.Name != \'MileStoneCard\'');
            
		} catch (Exception e) {
			System.debug(e);
            boardKanbanCards = new List<leankor__KanbanCard__c>();
            throw new Util.LeanException('Error: ' + e.getmessage());            
        }
        
    	return boardKanbanCards;
    }
    

    /*------------------------------------------------------------
	Author: 		Dlanyer Ocampo
	Company: 		Leankor
	Description: 	Updates some field's values in kanban templates.
	Inputs: 		List<leankor__KanbanCardTemplate__c> kanbanCardTemplates
	Returns: 		List<leankor__KanbanCard__c>
	------------------------------------------------------------*/
    @TestVisible 
    private static List<leankor__KanbanCardTemplate__c> JSONKanbanTemplateInjection(List<leankor__KanbanCardTemplate__c> kanbanCardTemplates) {        
    	try {
	    	if (!kanbanCardTemplates.isEmpty()) {
		    	leankor.KanbanSerializer kanbanSerializer = new leankor.KanbanSerializer();
		    	
		    	Set<String> setKanbanFieldSet = new Set<String>();
		    	for (leankor__KanbanCardTemplate__c kanbanCardTemplate : kanbanCardTemplates) {
					setKanbanFieldSet.add(kanbanCardTemplate.leankor__FieldSetName__c);
		    	}
		    	
		    	Map<String, String> mapKanbanJSONDefinition = new Map<String, String>();
		    	//DCO 10.8.17 added mapKanbanJSONData instantiation
		    	Map<String, String> mapKanbanJSONData = new Map<String, String>();

               /*for (String kanbanFieldSet : setKanbanFieldSet) {
		    		mapKanbanJSONDefinition.put(kanbanFieldSet, kanbanSerializer.serializeHeader('leankor__KanbanCard__c', kanbanFieldSet, UIHeaderSettings, UIItemSettings, fieldMapKanbanCard));   		
		    	}
		    	
		    	for (leankor__KanbanCardTemplate__c kanbanCardTemplate : kanbanCardTemplates) {
		    		kanbanCardTemplate.JSONDefinition__c = mapKanbanJSONDefinition.get(kanbanCardTemplate.leankor__FieldSetName__c);
		    	}*/
	    	}
    	} catch (Exception e) {
    		System.debug(e);
            throw new Util.LeanException('Error: ' + e.getmessage());            
        }
        
    	return kanbanCardTemplates;		
	}
          

    /* 10OCT17 NW : Field Set JSON Wrapper class*/  
    global class FieldSetJSONWrapper {
    	public String fieldSetName;
    	public String fieldSetAPIName;
        public String fieldSetJSON;

        @deprecated
        global fieldSetJSONWrapper(String fieldSetName, String fieldSetAPIName, String fieldSetJSON) {
	        this.fieldSetName = fieldSetName;
	        this.fieldSetAPIName = fieldSetAPIName;
	        this.fieldSetJSON = fieldSetJSON;
	    }
        
	    global FieldSetJSONWrapper(String fieldSetName, String fieldSetAPIName) {
	        this.fieldSetName = fieldSetName;
	        this.fieldSetAPIName = fieldSetAPIName;
	    }
    } 

    @AuraEnabled
    public static List<FieldSetJsonResponse> getKanbanFieldSetForAura() {
        List<FieldSetJSONWrapper> fieldSetJSONWrappers = getKanbanFieldSetANDJSON();
        List<FieldSetJsonResponse> fieldSetJsonResponses = new List<FieldSetJsonResponse>();

        for (FieldSetJSONWrapper wrapper : fieldSetJSONWrappers) {
            fieldSetJsonResponses.add(new FieldSetJsonResponse(wrapper.fieldSetName, wrapper.fieldSetAPIName));
        }

        return fieldSetJsonResponses;
    }



    /*  10OCT17 NW : Added Method, it will return List of fieldSetJSONWrapper */         
	@RemoteAction
	global static List<FieldSetJSONWrapper> getKanbanFieldSetANDJSON() {
		Map<String, Schema.FieldSet> kanbanFieldSetMap = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();
		List<FieldSetJSONWrapper> fieldSetJSONWrapper = new List<FieldSetJSONWrapper>();		

        for (String kanbanFieldSet : kanbanFieldSetMap.keySet()) {
            fieldSetJSONWrapper.add(new FieldSetJSONWrapper(kanbanFieldSetMap.get(kanbanFieldSet).getLabel(), kanbanFieldSet));   		
        }

        return fieldSetJSONWrapper;
	}     
    
    
	//yj 24.10.17 method to unlink cards to broadcast on kanban Board
	@RemoteAction
    global static List<leankor.realtimeController.bulkStreaming> getLinkedIds(List<String> cardIds) {        
         List<leankor__KanbanCard__c> kanbanCards = [Select Id 
                                                            From leankor__KanbanCard__c 
                                                            Where leankor__GUID__c In :cardIds 
                                                                Or Id In :cardIds];        
         
         List<leankor.realtimeController.bulkStreaming> bulkStreamingMessages = new List<leankor.realtimeController.bulkStreaming>();
         Map<String, List<String>> mapLinkedCards = new Map<String, List<String>>();        
         
         for (leankor__KanbanCard__c kanbanCard : [Select Id,
                                                            leankor__ValueStream__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStreamCardLink__c In :kanbanCards 
                                                            And leankor__IsRecordDeleted__c = false 
                                                        Limit 10000]) {     	
                
            if (mapLinkedCards.containsKey(kanbanCard.leankor__ValueStream__c)) {
                List<String> linkedCard = mapLinkedCards.get(kanbanCard.leankor__ValueStream__c);

                linkedCard.add(kanbanCard.Id);
                mapLinkedCards.put(kanbanCard.leankor__ValueStream__c, linkedCard);
            } else {
                List<String> linkedCard = new List<String>();

                linkedCard.add(kanbanCard.Id);
                mapLinkedCards.put(kanbanCard.leankor__ValueStream__c, linkedCard);
            }
        }

        for (String valueStreamId : mapLinkedCards.keySet()) {
                leankor.realtimeController.bulkStreaming bulkStreaming = new leankor.realtimeController.bulkStreaming();

	            bulkStreaming.VSID = valueStreamId;
	            bulkStreaming.cardIds = mapLinkedCards.get(valueStreamId); 
	            bulkStreamingMessages.add(bulkStreaming);
        }

        return bulkStreamingMessages;                           
     }     
    
     
     /*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description:    Read KanbanCard's Sticker with card info
	Inputs: 		String valueStreamId
	Returns: 		GlueforceData
	Date: 			24.8.18
	------------------------------------------------------------*/
    @RemoteAction	
    global static realTimeController.GlueforceData getCardsWithStickerInfo(String valueStreamId) {
        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

	    return RealTimeControllerHelper.readCardsWithStickers(valueStreamId, null, null);

	}  
     
     
	@RemoteAction
	global static string getOrgBaseURL() {
		//For community need to use community url
		//the inability to open quick action popup for community users handled in apex.        
        return String.isNotBlank(Network.getNetworkId()) 
            ? ('https://' + DomainCreator.getExperienceCloudSitesHostname() + '/') 
            : ('https://' + DomainCreator.getOrgMyDomainHostname()+ '/apex/');
            
	}   
    
    
	/*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description:    Read Dependent Kanbans on the board
					(This method is specifically created for managing
					ManageDependency broadcast on LeankorNAV)
	Inputs: 		String valueStreamId
	Returns: 		List<Kanban>
	------------------------------------------------------------*/
	@RemoteAction

    global static List<Kanban> readNavDependentCards(String valueStreamId) {

        if (String.isNotBlank(valueStreamId) && Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }

    	List<realTimeController.Kanban> kanbans = new List<realTimeController.Kanban>();

        for (leankor__KanbanCard__c kanbanCard : RealTimeControllerHelper.readDependentNavKanbanCard(valueStreamId)) {
			realTimeController.Kanban kanbanCardInstance = new realTimeController.Kanban();
			kanbanCardInstance.Id = kanbanCard.Id;
			kanbanCardInstance.Name = kanbanCard.Name;
			kanbanCardInstance.isTaskDueCheck = kanbanCard.leankor__ValueStream__r.leankor__TaskDateCheck__c;
			kanbanCardInstance.SWeek = kanbanCard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c;
			kanbanCardInstance.DueDate = kanbanCard.leankor__DueDateTime__c;
			kanbanCardInstance.StartDate = kanbanCard.leankor__StartDateTime__c;
			kanbanCardInstance.ProjectID = kanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
			kanbanCardInstance.OwnerID = kanbanCard.OwnerId;
			kanbanCardInstance.OwnerName = kanbanCard.Owner.Name;
			kanbanCardInstance.BoardType = kanbanCard.leankor__BoardType__c;
			kanbanCardInstance.ProjectName = kanbanCard.leankor__ProjectRoom__c;
			kanbanCardInstance.ValueStream = kanbanCard.leankor__ValueStream__c;
            kanbanCardInstance.ValueStreamName = kanbanCard.leankor__Valuestream__r.Name;
            
            if (kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c == LEANFALSE 
            && (kanbanCard.leankor__Valuestream__r.leankor__IsTemplateBoard__c == LEANTRUE || kanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template')) {           
                kanbanCardInstance.IsTemplate = true;     
            } else {
                kanbanCardInstance.IsTemplate = false;
            } 
            
            if (kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__r.leankor__IsTemplateProject__c == LEANTRUE) {
                kanbanCardInstance.IsProjectTemplate = true;
            } else {
                kanbanCardInstance.IsProjectTemplate = false;
            } 
            
            if (kanbanCard.leankor__BoardType__c == 'UberBoard') {
            	kanbanCardInstance.ItemType = kanbanCard.Recordtype.name;
                kanbanCardInstance.leaf = kanbanCardInstance.ItemType == 'MilestoneCard' || kanbanCardInstance.ItemType == 'ActivityCard' ? true : false;
            } else {
                //CV Milestone on navigation  
                kanbanCardInstance.ItemType = kanbanCard.Recordtype.name == 'MileStoneCard' ? 'MileStoneCard':'KC';
            } 
            
            if(kanbanCard.leankor__ResourceAssignments__r != null && kanbanCard.leankor__ResourceAssignments__r.size() > 0) {
                kanbanCardInstance.AssignToId = kanbanCard.leankor__ResourceAssignments__r[0].leankor__AssignedTo__c;
            }

			kanbans.add(kanbanCardInstance);	
        }

    	return kanbans;
    }
    

    /**
     * Tilak Raj Mahale: 21.05.2020 - This method used to update Kanban card records using remote Action call using sObject list.
     */
    @RemoteAction
    global static String manageBulkKCStreaming(BulkStreaming realTimeStreaming) {    
        if (realTimeStreaming.kanbansObjectList != null && realTimeStreaming.kanbansObjectList.size() > 0) {
            // We could not directly perform the DML and SOQL query on the JavaScript sObject, because of that we need to create new sObject list.
            realTimeStreaming.kanbansObjectList = new List<leankor__KanbanCard__c>(realTimeStreaming.kanbansObjectList);
            //after executing multipleUpdateAPI this method is calling on CV for recalculation, so task dates should adjust according to workingdays.
            updateTaskDatesWeekCalendar = realTimeStreaming.verb == 'UpdateKanbanCard' ? true : false;
            // Call manageBulkStreaming to update the Records
            leankor.RealTimeController.manageBulkStreaming(realTimeStreaming, true);
        }      

        String kanbanCardIds = JSON.serialize(gskanbanCardIds);
        gskanbanCardIds.clear();
        
        return kanbanCardIds;
    }


    //TODO: Must separate CRUD operations and broadcasting
    /**
     * Tilak Raj Mahale: 21.04.2020 - This method used to update the kanban card records and sending broadcast for the same. 
    */
    public static void manageBulkStreaming(BulkStreaming streaming, Boolean updateParentFlag) {
        // input validation is done from the calling method

        //Check CRUD / FLC behavior
  		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
  		RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();
        
        if (!kanbanCardBehaviour.isAccessible() 
        || !kanbanCardBehaviour.isUpdateable() 
        || !kanbanCardBehaviour.isCreateable() 
        || !realtimeTrackerBehavior.isCreateable()) {
            System.debug('Error: No access to create or update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        Set<Id> valueStreamIds = new Set<Id>();
        List<Id> activityIds = new List<Id>();
        List<String> jsonList = new List<String>();
        Set<String> broadcastIds = new Set<String>(); // Use to send broadcast in GS for API's
        List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
        Map<Id, leankor__RealtimeTracker__c> mapRealTimeTrackers = new Map<Id, leankor__RealtimeTracker__c>();

        if (streaming.kanbansObjectList != null && streaming.kanbansObjectList.size() > 0) {
            kanbanCards = streaming.kanbansObjectList;
        }
        
        if (kanbanCards.size() > 0) {
            if(linkParentCardIds.size()>0){
                for(leankor__KanbanCard__c singleCardRecord:kanbanCards){
                   for(Id singleId : linkParentCardIds){
                        if(singleCardRecord.Id == singleId){
                            singleCardRecord.leankor__IsConstraintRecalculate__c = true;
                        }
                   }
                }
            }


            // Get the old values on the card before updating the KC records
            Map<Id, leankor__KanbanCard__c> mapOldKanbanCards = leankor.RealTimeControllerHelper.readKanbanCardMap(kanbanCards);

            Savepoint sp = Database.setSavepoint();        
            try {
                Set<String> kanbanCardIds = new Set<String>();
                String valueStreamLinkId;
                // Update the KC records
                Schema.Sobjectfield externField = leankor__KanbanCard__c.Fields.leankor__GUID__c;
                Database.upsert(kanbanCards, externField, true);

                // Get the updated values on the card that will used for chatter, task update and broadcasting
                Map<Id, leankor__KanbanCard__c> mapUpdatedKanbanCards = leankor.RealTimeControllerHelper.readKanbanCardMap(kanbanCards);
                String jsonPayload = '';
                Boolean isScheduleRecalculateOnMove = false;
                leankor__KanbanCard__c oldKanbanCard = new leankor__KanbanCard__c();
                String tempVerb = streaming.verb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : streaming.verb;
                for (leankor__KanbanCard__c kanbanCard : mapUpdatedKanbanCards.values()) {
                    // Get the old value of the KC
                    oldKanbanCard = mapOldKanbanCards.get(kanbanCard.Id);
                    kanbanCardIds.add(kanbanCard.Id);
                    // For UberBoard items we does not update the parent record                
                    if (String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c) && kanbanCard.leankor__BoardType__c != 'UberBoard') {
                        activityIds.add(kanbanCard.leankor__ValueStreamCardLink__c);                     
                    }
                    // For this verb we are sending broadcast from glueforceUtil and in case of multiple sobject API's(UpdateKanbanCards) we are reloading the Board.
                    if (streaming.verb != 'MoveActivity' && streaming.verb != 'IndentActivity' && streaming.verb != 'OutdentActivity' && streaming.verb != 'IndentOutdentActivityPDV' && streaming.verb !='UpdateKanbanCards' && tempVerb != 'UpdateMultipleKanbanCards' && tempVerb != 'UpdateKanbanCard' ) {
                        // Create json payload for broadcasting form old and new value on the card
                        jsonPayload = manageBulkStreamingHelper(kanbanCard, oldKanbanCard, mapRealTimeTrackers, streaming);

                        // Used to send broadcast for APIs in GS.
                        if (flowWithGSForAPI && IS_GENERIC_STREAMING) {                   
                            jsonList.add(jsonPayload);
                        }
                        
                        if (IS_USING_PLATFORM_EVENT) {
                            broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(tempVerb, jsonPayload, streaming.sessionId));
                        }
                    }

                    /*
                    isScheduleRecalculateOnMove = false;
                    if (kanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template' || oldKanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template') {
                        if (kanbanCard.leankor__MasterContainer__r.leankor__Type__c != oldKanbanCard.leankor__MasterContainer__r.leankor__Type__c) {
                            isScheduleRecalculateOnMove = true;
                        } 
                    }
                    */

                    isScheduleRecalculateOnMove = (kanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template' || oldKanbanCard.leankor__MasterContainer__r.leankor__Type__c == 'Template') 
                        && (kanbanCard.leankor__MasterContainer__r.leankor__Type__c != oldKanbanCard.leankor__MasterContainer__r.leankor__Type__c);

                    // When master container is not template and then dates or cardlink or MC type changed then successorRecalculation for parent cards.
                    if ((kanbanCard.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
                    && ((kanbanCard.leankor__DueDate__c != oldKanbanCard.leankor__DueDate__c) 
                    || (kanbanCard.leankor__StartDate__c != oldKanbanCard.leankor__StartDate__c) 
                    || (kanbanCard.leankor__ValueStreamCardLink__c != oldKanbanCard.leankor__ValueStreamCardLink__c))) 
                    || isScheduleRecalculateOnMove) {
                        if (String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)) {
                            Util.recalculateRecord.put(kanbanCard.leankor__ValueStreamCardLink__c, true);
                        }

                        if (String.isNotBlank(oldKanbanCard.leankor__ValueStreamCardLink__c)) {
                            Util.recalculateRecord.put(oldKanbanCard.leankor__ValueStreamCardLink__c, true);
                        }
                    }
                    
                    if(!(String.isNotBlank(valueStreamLinkId))) {
                        valueStreamLinkId = String.isNotBlank(kanbanCard.leankor__ValueStreamLink__c) ? kanbanCard.leankor__ValueStreamLink__c : null;
                    }
                    
                    activityIds.add(kanbanCard.Id);
                    broadcastIds.add(kanbanCard.Id);
                    gskanbanCardIds.add(kanbanCard.Id);
                }

                // Insert the RTT records for PT and history.
                if (mapRealTimeTrackers.size() > 0) {
                    insert mapRealTimeTrackers.values();
                    mapRealTimeTrackers.clear();
                }

                // Update the parent of the KC
                if (updateParentFlag) {                                                                                                                       
                    leankor.realtimeController.updateParentCards(mapUpdatedKanbanCards.values());                          
                }

                // Update the task on the card
                leankor.OpenTaskRestriction.updateTask(mapUpdatedKanbanCards.values(), mapOldKanbanCards);
                mapOldKanbanCards.clear();

                // Updating parent RA percent completed 
                leankor.ProjectBoardCarousel.updateActivityPercentageComplete(activityIds);
                activityIds.clear();
                
                // Send Chatter feed for cards. 
                leankor.OpenFeedItemRestriction.createChatterFeed(mapUpdatedKanbanCards.values(), (String.isNotBlank(streaming.kanbanVerb) ? streaming.kanbanVerb : streaming.verb));
                mapUpdatedKanbanCards.clear();

                if (IS_USING_PLATFORM_EVENT) {
                    if(tempVerb == 'UpdateMultipleKanbanCards' || tempVerb == 'UpdateKanbanCard'){
                        BroadcastEventPayload broadcastEventPayload = new BroadcastEventPayload();
                        broadcastEventPayload.cardIds = kanbanCardIds;
                        broadcastEventPayload.ValueStreamLinkID = valueStreamLinkId;
                        broadcastEventPayload.verb = streaming.verb;
                        broadcastEventPayload.sessionID = streaming.sessionID;
                        broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(tempVerb == 'UpdateKanbanCard' ? 'UpdateMultipleKanbanCards' : tempVerb, JSON.serialize(broadcastEventPayload), streaming.sessionId));
                    }
                    if (broadcastEvents.size() > 0) {
                        LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);
                        broadcastEvents.clear();
                    }
                } else { 
                    // Send the broadcast in GS.
                    if (jsonList.size() > 0) {  
                        if (streaming.verb == 'UpdateMultipleKanbanCards' || streaming.verb == 'AddMiniature') {
                            // This condition used to send broadcast for API's in GS before this we are used to send broadcast for parent record from API.
                            Map<String, List<String>> broadcastContentMap = new Map<String, List<String>>();
                            broadcastContentMap.put('', new List<String>(broadcastIds));   	 	
                            GenericStreamingController.sendBroadcastForBulkRecords(streaming.verb, broadcastContentMap, streaming.sessionId);
                        } else {
                            leankor.GenericStreamingController.broadcastNotificationAsync(streaming.verb, jsonList);
                        }               
                    }
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw new Util.LeanException('Insufficient privileges to change the ownership of this record. Please contact your Admin');
            }
        }
    }

    
    /**
     * Tilak Raj Mahale: 22.04.2020 - Helper method of manageBulkStreaming used to create payload for broadcasting.
     */
    @TestVisible
    private static String manageBulkStreamingHelper(leankor__KanbanCard__c kanbanCard, leankor__KanbanCard__c oldKanbanCard, Map<Id, leankor__RealtimeTracker__c> mapRealTimeTrackers, BulkStreaming streaming) {
        JSONGroup myJSONGroup = new JSONGroup();

        // ---------------------- Generate the payload for broadcasting ---------------------------------
        String payload = '{"Id":"'+ kanbanCard.Id +'","GUID":"'+ kanbanCard.leankor__GUID__c +'","ValueStreamID":"'+ kanbanCard.leankor__ValueStream__c +'","sessionID":"'+ streaming.sessionID +'",';
        
        if (String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)) {
            payload += '"ValueStreamCardLink":"'+ kanbanCard.leankor__ValueStreamCardLink__c+'",';
        }

        if (String.isNotBlank(kanbanCard.leankor__ValueStreamLink__c)) {
            payload += '"ValueStreamLinkID":"'+ kanbanCard.leankor__ValueStreamLink__c+'",';
        }

        if (String.isNotBlank(streaming.someJSONData)) {
            payload += streaming.someJSONData + ',';
        }

        if (kanbanCard.leankor__IsSuccessorRecalculate__c) {
            payload += '"IsSR":true,';
        }

        payload += '"verb":"'+ streaming.verb +'"}';
        // -----------------------------------------------------------------------------------------------

        // Create Realtime trackers record
        if (!putJSONGroup(payload, myJSONGroup)) {
            System.debug('ERROR: JSON String too large for broadcasting [' + streaming.verb + '] for ValueStream: ' + kanbanCard.leankor__ValueStream__c);
        } else {
            mapRealTimeTrackers.put(kanbanCard.Id, createRealtimeTrackerInstance(streaming.sessionID, kanbanCard.leankor__ValueStream__c, streaming.verb, myJSONGroup));

            // if the linking on the card has been changed or linked then insert RTT records
            if (oldKanbanCard.leankor__ValueStreamCardLink__c != kanbanCard.leankor__ValueStreamCardLink__c && String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)) {
                mapRealTimeTrackers.put(kanbanCard.Id, createRealtimeTrackerInstance(streaming.sessionID, kanbanCard.leankor__ValueStreamLink__c, streaming.verb, myJSONGroup));
            }
        }

        return payload;
    }


    /**
     * Tilak Raj Mahale: 05.05.2020 - This method used to update the parent records.
     * Note: This static varible use to store the KC and VS ids. We have to make IsSuccessorRecalculate = true for this KC's
    */
    public static void updateParentCards(List<leankor__kanbanCard__c> kanbanCards) {           
        // input validation is done from the calling method
                     
        Set<String> parentCardIds = new Set<String>();
        List<leankor__kanbancard__c> parentCards = new List<leankor__kanbancard__c>();
        for (leankor__kanbancard__c kanbanCard : kanbanCards) {
            if (String.isNotBlank(kanbanCard.leankor__ValueStreamCardLink__c)) {
                parentCardIds.add(kanbanCard.leankor__ValueStreamCardLink__c);
            }        
        }
        // Get all the linked parent records so that we can update those records at one go at manageBulkStreaming.
        parentCards = leankor.RealTimeController.getAllParentRecords(new Map<Id,leankor__kanbanCard__c>(), parentCardIds, false).values();

        if (parentCards.size() > 0) {
            if (recalculateIds.size() > 0) {
               // For external dependencies we need to make IsDependencyRecalculate__c = true.
                leankor.Dependency.updateExternalDependencies(recalculateIds, valueStreamIds);
                valueStreamIds.clear(); // Not in used anymore

                if (IS_GENERIC_STREAMING) {
                    //If UpdateSuccess then add parentIds to this global variable to be used in GS for broadcasting of isSuccessorRecalculate
                    parentActivityIds = new Set<String>(recalculateIds);
                    recalculateIds.clear(); // No in used anymore
                }
            }

            /* Calling manageBulkStreaming to update the parent cards and sending updateParentFlag = false in parameter as 
               we don't need to call this method again as we process all the linked parent records using getAllParentRecords method. */
            BulkStreaming stream = new BulkStreaming();

            stream.verb = flowWithGSForAPI ? 'AddMiniature' : 'UpdateMultipleKanbanCards';
            stream.sessionID = USER_SESSION_ID_CONST;
            stream.kanbansObjectList = parentCards;
            
            leankor.RealTimeController.manageBulkStreaming(stream, false);
        }
    }  


    /**
     * Tilak Raj Mahale: 14.05.2020 - This method used to get all linked parent KC records.
     * Note: Getting n-level parent record not posssible as we can't process more than 49999 record at a time in salesforce.
     *      If all the parent records in org are under 49999 then we can do that. Right now we can do around 50 level or some more depends upon the query limitation.
    */
    @TestVisible
    private static Map<Id, leankor__KanbanCard__c> getAllParentRecords(Map<Id, leankor__KanbanCard__c> mapChildKanbanCards, Set<String> parentIds, Boolean childFlag) {
        Set<String> parentCardIds = new Set<String>();
        Map<Id, leankor__KanbanCard__c> mapParentKanbanCards = new Map<Id, leankor__kanbanCard__c>();
        Map<Id, leankor__KanbanCard__c> mapKanbanCards = new Map<Id, leankor__kanbanCard__c>();
        Map<Id, leankor.Util.WorkWeek> mapWorkWeeks = new Map<Id, leankor.Util.WorkWeek>();

        Decimal totalBudgetTime;
        Decimal totalBudgetTimeRemaining;
        Boolean firstChild;

        for (leankor__KanbanCard__c parent : leankor.RealTimeControllerHelper.getParentRecords(parentIds, mapWorkWeeks)) {   
            totalBudgetTime = 0;
            totalBudgetTimeRemaining = 0;
            firstChild = true;

            if (parent.leankor__Kanban_Cards__r == null || parent.leankor__Kanban_Cards__r.size() == 0) {
                // This means child record deleted or board converted to template. But for removing miniature from the activity we need to send broadcast.
                mapParentKanbanCards.put(parent.Id, parent); 
                continue;
            }

            for (leankor__kanbancard__c child : parent.leankor__Kanban_Cards__r) {
                // Get the updated child record if we updated that within this process
                if (mapChildKanbanCards.containsKey(child.Id) && childFlag) {
                    child = mapChildKanbanCards.get(child.Id); 
                    // Calculating the formula field leankor__Budgeted_Time__c and leankor__BudgetTimeRemaining__c as per the formula
                    totalBudgetTime = 8 * parent.leankor__EstimatedDuration__c;
                    totalBudgetTimeRemaining = totalBudgetTime * (1 - (child.leankor__PercentComplete2__c/100));
                } else {
                    totalBudgetTime += child.leankor__Budgeted_Time__c;
                    totalBudgetTimeRemaining += child.leankor__BudgetTimeRemaining__c;
                }

                // We are not updating dates of parent in case of UberBoard
                if (parent.leankor__Valuestream__r.leankor__Boardtype__c != 'UberBoard') {
                    if (firstChild) {
                        firstChild = false;
                        parent.leankor__StartDateTime__c = child.leankor__StartDateTime__c;
                        parent.leankor__DueDateTime__c = child.leankor__DueDateTime__c;
                        continue;
                    }

                    if (child.leankor__StartDateTime__c < parent.leankor__StartDateTime__c) {
                        parent.leankor__StartDateTime__c = child.leankor__StartDateTime__c;
                    }

                    if (child.leankor__DueDateTime__c > parent.leankor__DueDateTime__c) {
                        parent.leankor__DueDateTime__c = child.leankor__DueDateTime__c;
                    }
                }
            }
            
            parent.leankor__Kanban_Cards__r.clear();// Child records data not needed anymore.

            // Get the old leankor__PercentComplete2__c value
            Decimal oldPercenteComplete = parent.leankor__PercentComplete2__c;
            Decimal harveyBall = totalBudgetTime - totalBudgetTimeRemaining;  

            if (harveyBall == 0) {
                parent.leankor__PercentComplete2__c = Integer.valueof(0);
            } else {
                parent.leankor__PercentComplete2__c = Integer.valueof((harveyBall == 0 ? 1 : harveyBall) * 100 / (totalBudgetTime == 0 ? 1 : totalBudgetTime));
            }

            parent.leankor__HarveyBallDoneDate__c = parent.leankor__PercentComplete2__c != oldPercenteComplete && parent.leankor__PercentComplete2__c == 100 ? System.today() : parent.leankor__HarveyBallDoneDate__c; 
            parent.leankor__PromiseCompletionDate__c = parent.leankor__PercentComplete2__c != oldPercenteComplete && parent.leankor__PercentComplete2__c == 100 ? System.now() : parent.leankor__PromiseCompletionDate__c;           
            parent.leankor__DurationUnits__c = 'Days'; //Duration unit is only Days for parent cards

            // If the dates are changed then we need to do leankor__IsSuccessorRecalculate__c = true for parent of parent card
            if (String.isNotBlank(parent.leankor__ValueStreamCardLink__c) 
            && parent.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
            && (parent.leankor__StartDateTime__c.date() != parent.leankor__StartDate__c || parent.leankor__DueDateTime__c.date() != parent.leankor__DueDate__c)) {
                leankor.Util.recalculateRecord.put(parent.leankor__ValueStreamCardLink__c, true);
            }

            if (parent.leankor__Valuestream__r.leankor__Boardtype__c != 'UberBoard') {
                parent.leankor__EstimatedDuration__c = mapWorkWeeks.get(parent.leankor__Valuestream__c).getBusinessDays(parent.leankor__StartDateTime__c.date(), parent.leankor__DueDateTime__c.date()) + 1;
                parent.leankor__DueDate__c = parent.leankor__DueDateTime__c.date();
                parent.leankor__StartDate__c = parent.leankor__StartDateTime__c.date();
            }
            
            if (parent.Recordtype.Name != 'FolderCard' && leankor.Util.recalculateRecord.containsKey(parent.Id)) {
                parent.leankor__IsSuccessorRecalculate__c = true;
                recalculateIds.add(parent.Id);
                valueStreamIds.add(parent.leankor__ValueStream__c);
            } 

            // Update the parent if board is not UberBoard, in case of UberBoard this is managed at the UI end
            if (String.isNotBlank(parent.leankor__ValueStreamCardLink__c) && parent.leankor__BoardType__c != 'UberBoard') {
                mapKanbanCards.put(parent.Id, parent);
                parentCardIds.add(parent.leankor__ValueStreamCardLink__c);
            }
            //29/06/2022 : IsConstraintrecalculate should be true for parent card also.
            if(isConstraintRecalculateForChildCard == true && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS == true && (parent.leankor__BoardType__c == 'UberBoard' || parent.leankor__BoardType__c =='Plan Board')){
                parent.leankor__IsConstraintRecalculate__c = true;
                isConstraintRecalculateForChildCard = false;
            }

            // Add updated parent record into the list
            mapParentKanbanCards.put(parent.Id, parent);   
        }

        // Call the same method recusivelly until we need to update parent of parent record
        if (mapKanbanCards.size() > 0) { 
            mapParentKanbanCards.putAll(leankor.RealTimeController.getAllParentRecords(mapKanbanCards, parentCardIds, true));
        } 

        return mapParentKanbanCards;
    }


    /** Tilak Raj Mahale: 13.05.2020
     *  This method used to send broadcast. We can use this method in place of manageBulkStreaming once we stop using managebulkstreaming to update record completly.
     */ 
    @RemoteAction
    global static void sendBroadcast(List<BulkStreaming> bulkStreaming, String kanbanVerb) {
        //Check CRUD / FLC behavior
        RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();
          
        if (!realtimeTrackerBehavior.isAccessible() 
        || !realtimeTrackerBehavior.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
        List<leankor__RealtimeTracker__c> realtimeTrackers = new List<leankor__RealtimeTracker__c>();
        List<String> jsonList = new List<String>();
        String linkedCardVerb, linkedValueStream, someJSONData;
        
        for (BulkStreaming streaming : bulkStreaming) {
            CardStreamingPackage cardStreamingPackage = (CardStreamingPackage) JSON.deserialize(streaming.SomeJSONData, CardStreamingPackage.class);

            if ((String.isNotBlank(cardStreamingPackage.ValueStreamLinkID) 
            && Util.getSObjectName(cardStreamingPackage.ValueStreamLinkID) != 'leankor__ValueStream__c') 
            || (String.isNotBlank(cardStreamingPackage.ValueStream) 
            && Util.getSObjectName(cardStreamingPackage.ValueStream) != 'leankor__ValueStream__c')) {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
            }

            JSONGroup myJSONGroup = new JSONGroup();
            linkedCardVerb = '';
            linkedValueStream = '';
            someJSONData = '';
           
            if (streaming.Verb == 'AddMiniature' 
            || streaming.Verb == 'MoveKanbanCard' 
            || streaming.Verb == 'CreateKanbanCard' 
            || streaming.Verb == 'UpdateKanbanCard' 
            || streaming.Verb == 'UpdateMultipleKanbanCards' 
            || streaming.Verb == 'MoveActivity' 
            || streaming.Verb == 'IndentActivity' 
            || streaming.Verb == 'OutdentActivity' 
            || streaming.Verb == 'IndentOutdentActivityPDV'
            || streaming.Verb == 'ManageProjectBoardWorkFieldSet') {
                linkedCardVerb = cardStreamingPackage.linkedCardVerb; // taking verb to broadcast in other board.                 
                linkedValueStream = String.isNotBlank(cardStreamingPackage.ValueStreamLinkID) ? cardStreamingPackage.ValueStreamLinkID : cardStreamingPackage.ValueStream; // taking valueStreamId to broadcast in other board. this Id will not same as ValueStreamId (very first arugment in this method).
                cardStreamingPackage.verb = streaming.Verb;
                someJSONData = JSON.serialize(cardStreamingPackage);
            
                if (String.isNotBlank(cardStreamingPackage.Id) 
                && (streaming.Verb == 'UpdateMultipleKanbanCards' 
                || streaming.Verb == 'MoveActivity' 
                || streaming.Verb == 'MoveKanbanCard' 
                || streaming.Verb == 'IndentActivity' 
                || streaming.Verb == 'OutdentActivity' 
                || streaming.Verb == 'IndentOutdentActivityPDV' 
                || streaming.Verb == 'UpdateKanbanCard')) {                   
                    gskanbanCardIds.add(cardStreamingPackage.Id);
                }
                                
                if (flowWithGSForAPI || IS_GENERIC_STREAMING) {     
                    //01/Aug/2023 - Changes : Passing sessionId for UI with UpdateMultipleKanbanCards in case of GS broadcasting channel to fix "In PG when user create a dependency 
                                            // from activity to AG then the expansion of the time grid got freeze and duration of the time grid is set to 1 month" issue. 
                    if(streaming.Verb == 'UpdateMultipleKanbanCards'){
                        CardStreamingPackage tempCardStreamingPackage = (CardStreamingPackage) JSON.deserialize(someJSONData, CardStreamingPackage.class); 
                        tempCardStreamingPackage.sessionID = streaming.SessionID;
                        jsonList.add(Json.serialize(tempCardStreamingPackage));
                    }else{
                        jsonList.add(someJSONData);
                    }
                }  
            } else {     
                if (streaming.Verb != 'UpdateTask' && streaming.Verb != 'CreateTask' && streaming.Verb != 'DeleteTask') {                      
                    if (flowWithGSForAPI && IS_GENERIC_STREAMING) {
                        cardStreamingPackage.verb = kanbanVerb;                                                           
                        jsonList.add(JSON.serialize(cardStreamingPackage));
                    } 

                    if (String.isNotBlank(cardStreamingPackage.Id) 
                    && (streaming.Verb == 'ExternalDependent' 
                    || streaming.Verb == 'ManageDependency' 
                    || streaming.Verb == 'UpdateKanbanCards')) {
                        gskanbanCardIds.add(cardStreamingPackage.Id);
                    }
                }
                
                if (cardStreamingPackage != null && streaming.Verb == 'ExternalDependent') {
                    cardStreamingPackage.verb = 'UpdateMultipleKanbanCards';
                    someJSONData = JSON.serialize(cardStreamingPackage);
                } else {
                    someJSONData = streaming.SomeJSONData;
                } 
            }
            
            if (kanbanVerb != 'MoveActivity' 
            && kanbanVerb != 'IndentActivity' 
            && kanbanVerb != 'OutdentActivity' 
            && kanbanVerb != 'IndentOutdentActivityPDV' 
            && kanbanVerb != 'UpdateKanbanCards') {
                //prepare content for Broadcast  and add to List of Events 
                if (IS_USING_PLATFORM_EVENT) {
                    broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(streaming.Verb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : streaming.Verb, someJSONData, streaming.SessionID));
                }

                //set up the JSON
                if (!putJSONGroup(someJSONData, myJSONGroup)) {
                    // string was too large
                    System.debug('ERROR: JSON String too large for broadcasting [' + streaming.Verb + '] for ValueStream: ' + streaming.vsId);
                } else {
                    realTimeTrackers.add(createRealtimeTrackerInstance(streaming.SessionID, streaming.VSID, streaming.Verb, myJSONGroup));
                                                        
                    if (linkedCardVerb != null && linkedCardVerb != '' && linkedCardVerb == 'CardHierarchyToOther' && linkedValueStream != streaming.VSID && linkedValueStream != null && linkedValueStream != '') {
                        if (IS_USING_PLATFORM_EVENT) {
                            //prepare content for Broadcast  and add to List of Events
                            broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(streaming.Verb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : streaming.Verb, someJSONData, streaming.SessionID));
                        }

                        realTimeTrackers.add(createRealtimeTrackerInstance(streaming.SessionID, linkedValueStream, streaming.Verb, myJSONGroup));
                    }
                }
            }           
        }

        //Savepoint sp = Database.setSavepoint();
        try {        
            // Insert RTT records for PT
            if (realtimeTrackers.size() > 0) {
                insert realtimeTrackers;
                realtimeTrackers.clear();
            }
            
            if (IS_USING_PLATFORM_EVENT) {
                if (broadcastEvents.size() > 0) {
                    // Publish BroadcastEvents
                    LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);
                    broadcastEvents.clear();
                }
            } else {
                // Send broadcast for GS
                if (jsonList.size() > 0) {
                    GenericStreamingController.broadcastNotificationAsync(kanbanVerb, jsonList);
                }
            }

        } catch (Exception e) {
            //Database.rollback(sp);
            System.debug(e.getMessage());
            //throw new Util.LeanException('Error: ' + e.getmessage());
        }
    } 
    

    /**
     * Tilak Raj Mahale:26.05.2020 - This method used to create the leankor__RealtimeTracker__c instance
    */
    public static leankor__RealtimeTracker__c createRealtimeTrackerInstance(String sessionId, String valueStreamId, String verb, JSONGroup jsonGroup) {
        return new leankor__RealtimeTracker__c(
            leankor__ValueStream__c = valueStreamId,
            leankor__SessionID__c = sessionId,
            leankor__KanbanVerb__c = verb == 'ExternalDependent' ? 'UpdateMultipleKanbanCards' : verb,
            leankor__JSONDataSmall__c = jsonGroup.JSON1,
            leankor__JSONDataSmall2__c = jsonGroup.JSON2,
            leankor__JSONDataSmall3__c = jsonGroup.JSON3,
            leankor__JSONDataSmall4__c = jsonGroup.JSON4,
            leankor__JSONDataSmall5__c = jsonGroup.JSON5,
            leankor__JSONDataSmall6__c = jsonGroup.JSON6,
            leankor__JSONDataSmall7__c = jsonGroup.JSON7,
            leankor__JSONDataSmall8__c = jsonGroup.JSON8
        );
    }


    /**
     * Tilak Raj Mahale:04.06.2020 - This method return the map activity=> miniature of activity map that used at getKanbanCardData and getKanbanCardRecord method.
    */
    public static Map<String, List<leankor.GanttTaskBoard.Miniature>> getMiniatureData(List<String> cardIds) {
        // input validation is done from the calling method

        Map<Id, leankor.Util.WorkWeek> mapWorkWeeks = new Map<Id, leankor.Util.WorkWeek>();
        Map<String, List<leankor.GanttTaskBoard.Miniature>> mapReturnMiniatures = new Map<String, List<leankor.GanttTaskBoard.Miniature>>();
        
        // Get the Activity=>Miniature and workweek map
        Map<Id, List<leankor__KanbanCard__c>> mapMiniatures = getActivityMiniatureMap(new Set<String>(cardIds), mapWorkWeeks);

        for (Id parentId : mapMiniatures.keySet()) {
            for (leankor__Kanbancard__c kanbanCard : mapMiniatures.get(parentId)) {
                leankor.GanttTaskBoard.Miniature miniature = new leankor.GanttTaskBoard.Miniature();

                miniature.Id = kanbanCard.Id;
                miniature.Name = kanbanCard.Name ;
                miniature.State = kanbanCard.leankor__PercentComplete2__c == 0 ? 'NotStarted' : (kanbanCard.leankor__PercentComplete2__c < 100 ? 'InProgress' : 'Done');
                miniature.CardId = kanbanCard.leankor__ValueStreamCardLink__c;
                miniature.DueDate = JSON.Serialize(kanbanCard.leankor__DueDateTime__c);
                miniature.StartDate = JSON.Serialize(kanbanCard.leankor__StartDateTime__c);
                miniature.ProjectName = kanbanCard.leankor__Projectroom__c;
                miniature.BoardName = kanbanCard.leankor__ValueStream__r.Name;
                miniature.BoardType = kanbanCard.leankor__ValueStream__r.leankor__BoardType__c;
                miniature.ValueStreamID = kanbanCard.leankor__ValueStream__c;
                miniature.IsSuccessorRecalculate = kanbanCard.leankor__IsSuccessorRecalculate__c;
                miniature.OwnerId = kanbanCard.OwnerId;
                miniature.PercentDone = kanbanCard.leankor__PercentComplete2__c;
                miniature.Title = kanbanCard.leankor__KanbanCardTemplate__r.leankor__Title__c;
                
                // Use for Miniature Due Date percent.                
                miniature.isDueDatePercentComplete = leankor.GanttTaskBoard.hasSeventyPercentDueDate(kanbanCard, mapWorkWeeks.get(kanbanCard.leankor__ValueStream__c));    

                List<leankor.GanttTaskBoard.Miniature> miniatures = mapReturnMiniatures.containsKey(parentId) ?  mapReturnMiniatures.get(parentId) : new List<leankor.GanttTaskBoard.Miniature>();

                miniatures.add(miniature);

                mapReturnMiniatures.put(parentId, miniatures);
            }
        }

        return mapReturnMiniatures;
    }


    /**
     * Tilak Raj Mahale:04.06.2020 - This method return the map activity=> miniature of activity and valuestream=> blackout map through reference.
    */
    public static Map<Id, List<leankor__KanbanCard__c>> getActivityMiniatureMap(Set<String> activityIds, Map<Id, leankor.Util.WorkWeek> mapWorkWeeks) {
        // input validation is done from the calling method

        Map<Id, Boolean> valueStreamMap = new Map<Id, Boolean>();
        Map<Id, List<leankor__KanbanCard__c>> mapMiniatures = new Map<Id, List<leankor__KanbanCard__c>>();
        
        for (leankor__KanbanCard__c kanbanCard : leankor.RealTimeControllerHelper.getMiniatureCards(activityIds)) {
            List<leankor__KanbanCard__c> kanbanCards = mapMiniatures.containsKey(kanbanCard.leankor__ValueStreamCardLink__c) ? mapMiniatures.get(kanbanCard.leankor__ValueStreamCardLink__c) : new List<leankor__KanbanCard__c>();
            kanbanCards.add(kanbanCard);
            mapMiniatures.put(kanbanCard.leankor__ValueStreamCardLink__c, kanbanCards);

            // This is used to create workweek map 
            valueStreamMap.put(kanbanCard.leankor__ValueStream__c, kanbanCard.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c);
        }

        // Get the blacout records
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> mapBlackouts =  leankor.RealTimeControllerHelper.getBlackOutRecords(valueStreamMap.keySet());

        // Create the workweek instance for each ValueStream and put into the map
        for (Id key : valueStreamMap.keySet()) {
            leankor.Util.WorkWeek workWeek = new leankor.Util.WorkWeek(valueStreamMap.get(key) ? 7 : 5, mapBlackouts.get(key));
            mapWorkWeeks.put(key, workWeek);
        }

        return mapMiniatures;
    }
    
     /***
     * This Method is updatePreference records it is used for Gantt divide bar.
     * INPUT:  List of leankor__Preference__c object  .
     * OUTPUT: Return  update leankor__Preference__c List  .
    */
    @RemoteAction
    global static List<leankor__Preference__c> updatePreference(List<leankor__Preference__c> preferenceList) {
        
        try {
            update preferenceList;
        } catch (DMLException e) {
            System.debug('Error:: '+e.getMessage());
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        
        return preferenceList;
    }

    public class BroadcastEventPayload {
        public Set<String> cardIds;
        public String ValueStreamLinkID;
        public String verb;
        public String sessionID;
    }
}