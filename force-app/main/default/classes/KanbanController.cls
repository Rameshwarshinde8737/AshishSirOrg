/* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: KanbanController.cls
 * CLASS: KanbanController
 */
Global with sharing class KanbanController{ 
    // rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
    public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c'};
    // rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
    public static final String BLANKTEXT = '';
    public String valueStreamId{get;set;}
    public static Boolean isCalledFromSingleCloneAPI = false;
    //04/April/2023 : We have added new variable for Hybrid constraint while hyperJump the card with updating links. 
    public static Boolean isCalledFromMultipleAPI = false;

    
    Global KanbanController(ApexPages.StandardController controller) {
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('Id')) && 
            Util.getSObjectName(ApexPages.currentPage().getParameters().get('Id')) != 'leankor__ValueStream__c') {
                System.debug('Error: Invalid input');
                throw new Util.LeanException('Error: Invalid input');
        }
       	this.valueStreamId = ApexPages.currentPage().getParameters().get('Id')!= null ? Encodingutil.urlencode(ApexPages.currentPage().getParameters().get('Id'),'UTF-8'): Null;
        this.TheValueStream = (leankor__ValueStream__c)controller.getRecord(); 
    }

    global KanbanController(Util controller){}


    Global leankor__ValueStream__c TheValueStream {
        get;set;
    }
    //
    // This is Inner Class For MasterContainer
    //
    Global KanbanController() {}

    Global static  List<leankor__ProjectRoom__c> theProjectRooms {get;set;}

    Global KanbanController(ApexPages.StandardSetController controller) {
    }

    Global Class MasterContainer{
        Global String Id;
        Global String Unit;
        Global String ForceID;
        Global String Name;
        Global String Color;
        Global String CmpID;
        Global String GUID;
        Global Decimal Height;
        Global Boolean isCardAvailable;
        Global Decimal Left;
        Global Decimal Limits;
        Global Decimal Order;
        Global String Title;
        Global Decimal Top;
        Global String Type;
        Global String ValueStreamID;
        Global Decimal Width;
    }    
    
    //Rs 19/12/2017 Innerclass for api using gs in flow 
    public class PopUp{    
    	public String CardID;
    	public string YES;
        public string NO;
        public Boolean ForceUndo;
        public Boolean Buttonflag;       
        public String customMessage;
        public boolean flowWithGS;
        public String ValueStream;
        public String sessionID;
        public string verb ;
        public string ValueStreamOwnerName;
        public string ValueStreamID ;   
    }
    
    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method Is Used for Getting MasterContainer Records of Board 
	Inputs:         Valuestream Id
	Returns:        List of MasterContainer object records 
	------------------------------------------------------------*/  
    @RemoteAction
    Global static List<leankor__MasterContainer__c> getMasterContainer(String VS){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        if(!masterContainerBehaviour.isAccessible()){
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__MasterContainer__c> mContainers = [SELECT Id,
                                                                leankor__Unit__c,
                                                                leankor__CmpID__c,
                                                                leankor__Color__c,
                                                                leankor__GUID__c,
                                                                leankor__Height__c,
                                                                leankor__IsCardAvailable__c,
                                                                leankor__Left__c,
                                                                leankor__Limit__c,
                                                                leankor__Order__c,
                                                                leankor__Title__c,
                                                                leankor__Top__c,
                                                                leankor__Type__c,
                                                                leankor__ValueStream__c,
                                                                leankor__Width__c,
                                                                Name,
                                                                OwnerId 
                                                            FROM leankor__MasterContainer__c 
                                                            WHERE leankor__ValueStream__C =: VS LIMIT 49999]; 
        return mContainers;
    }
    
    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method Is Use for Delete MasterContainer Records
	Inputs:         List of String of MasterContainer ids
	Returns:        String - "Success" or empty String in case of any Exception 
	------------------------------------------------------------*/
    @RemoteAction
    Global static String deleteMasterContainer(List<String> Ids){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour(); 
        if (
            !masterContainerBehaviour.isAccessible() ||
            !masterContainerBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        String returnString = 'success';
        List<leankor__MasterContainer__c> masterContainers = [Select Id,
                                                                    leankor__ValueStream__c
                                                                    From leankor__MasterContainer__c 
                                                                Where Id In :ids 
                                                                Limit 10000]; 
        for (leankor__MasterContainer__c masterContainer : masterContainers) {
            masterContainer.leankor__ValueStream__c = null;
        }
        try{
            if (!masterContainers.isEmpty()) {
                update masterContainers;
            }
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return '';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return returnString;
    }
    
    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method is used for updating MasterContainer Records or will insert if externField will not match
	Inputs:         List of MasterContainer innerClass
	Returns:        List of MasterContainer object records 
	------------------------------------------------------------*/
    @RemoteAction
    Global static List<leankor__MasterContainer__c> updateMasterContainer(List<MasterContainer> MContainers){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour(); 
        if (
            !masterContainerBehaviour.isAccessible() ||
            !masterContainerBehaviour.isUpdateable() ||
            !masterContainerBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__MasterContainer__c> masterContainers = new List<leankor__MasterContainer__c>();
        for(MasterContainer MC : MContainers){
            leankor__MasterContainer__c m = new leankor__MasterContainer__c();
                m.Name = MC.Name;
                m.leankor__Color__c = MC.Color;
                m.leankor__Unit__c = MC.Unit;
                m.leankor__CmpID__c = MC.CmpID;
                m.leankor__GUID__c = MC.GUID;
                m.leankor__Height__c = MC.Height;
                m.leankor__IsCardAvailable__c = MC.isCardAvailable;
                m.leankor__Left__c = MC.Left;
                m.leankor__Limit__c = MC.Limits;
                m.leankor__Order__c = MC.Order;
                m.leankor__Title__c = MC.Title;
                m.leankor__Top__c = MC.Top;
                m.leankor__Type__C = MC.Type;
                m.leankor__ValueStream__c = ((MC.ValueStreamID == '')?null : MC.ValueStreamID);
                m.leankor__Width__c = MC.Width;
            masterContainers.add(m);
        }
        List<Database.Upsertresult> uResults;
        try{
            Schema.Sobjectfield externField = leankor__MasterContainer__c.Fields.leankor__GUID__c;
            uResults = Database.upsert(masterContainers, externField, true); // GUID is the external unique key to match
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return (new List<leankor__MasterContainer__c>());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return masterContainers;
    }
    
    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method Is Use for creating MasterContainer Records
	Inputs:         List of MasterContainer innerClass
	Returns:        List of MasterContainer object records 
	------------------------------------------------------------*/
    @RemoteAction
    Global static List<leankor__MasterContainer__c> createMasterContainer(List<MasterContainer> MContainers){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour(); 
        if (
            !masterContainerBehaviour.isAccessible() ||
            !masterContainerBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        leankor.MasterContainer newMasterContainer;
        List<leankor.MasterContainer> newMasterContainers = new List<leankor.MasterContainer>();
        for(KanbanController.MasterContainer MContainer : MContainers) {
            newMasterContainer = new leankor.MasterContainer();
            newMasterContainer.forceId = MContainer.ForceID;
            newMasterContainer.unit = MContainer.Unit;
            newMasterContainer.name = MContainer.Name;
            newMasterContainer.color = MContainer.Color;
            newMasterContainer.cmpId = MContainer.CmpID;
            newMasterContainer.guid = MContainer.GUID;
            newMasterContainer.height = MContainer.Height;
            newMasterContainer.isCardAvailable = MContainer.isCardAvailable;
            newMasterContainer.left = MContainer.Left;
            newMasterContainer.limits = MContainer.Limits;
            newMasterContainer.order = MContainer.Order;
            newMasterContainer.title = MContainer.Title;
            newMasterContainer.top = MContainer.Top;
            newMasterContainer.type = MContainer.Type;
            newMasterContainer.valueStreamId = MContainer.ValueStreamID;
            newMasterContainer.width = MContainer.Width;
            newMasterContainers.add(newMasterContainer);
        }
        return leankor.MasterContainer.createMasterContainers(newMasterContainers);
    }
    //
    // This Inner Method For Swimlane
    //
    Global Class Swimlane{
        Global String Id;
        Global String ForceID;
        Global String Name;
        Global Decimal CardPerRow;  
        Global String CmpID;
        Global String Color;
        Global String GUID;
        Global Decimal Height;
        Global String Help;
        Global Boolean isCardAvailable;
        Global Decimal Left;
        Global Decimal Limits;
        Global String MasterContainer;
        Global Decimal Order;
        Global String Title;
        Global Decimal Top;
        Global String ValueStreamID;
        Global Decimal Width;
        Global String Unit; 
    }

    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method is use for updating Swimlane Records
	Inputs:         List of Swimlane innerClass
	Returns:        List of Swimlane object records 
	------------------------------------------------------------*/
    @RemoteAction
    Global static List<leankor__Swimlane__c> updateSwimlane(List<Swimlane> MSwimlanes){
        //Check CRUD / FLC behavior 
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        if (
            !swimlaneBehavior.isAccessible() ||
            !swimlaneBehavior.isUpdateable() ||
            !swimlaneBehavior.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__Swimlane__c> swimlanes = new List<leankor__Swimlane__c>();
        for(Swimlane s : MSwimlanes){
            leankor__Swimlane__c swim = new leankor__Swimlane__c();
            swim.Name = s.Name;
            swim.leankor__CardPerRow__c = s.CardPerRow;
            swim.leankor__Unit__c = s.Unit;
            swim.leankor__CmpID__c = s.CmpID;
            swim.leankor__Color__c = s.Color;
            swim.leankor__GUID__c = s.GUID;
            swim.leankor__Height__c = s.Height;
            swim.leankor__Help__c = s.Help;
            swim.leankor__IsCardAvailable__c = s.isCardAvailable;
            swim.leankor__Left__c = s.Left;
            swim.leankor__Limit__c = s.Limits;
            swim.leankor__MasterContainer__c = (s.MasterContainer == ''? null : s.MasterContainer);
            swim.leankor__Order__c = s.Order;
            swim.leankor__Title__c = s.Title;
            swim.leankor__Top__c = s.Top;
            swim.leankor__ValueStream__c =(s.ValueStreamID == ''? null : s.ValueStreamID);
            swim.leankor__Width__c = s.Width;
            swimlanes.add(swim);
        }
        List<Database.Upsertresult> uResults;
        try{
            Schema.Sobjectfield externField = leankor__Swimlane__c.Fields.leankor__GUID__c;
            uResults = Database.upsert(swimlanes, externField, true); // GUID is the external unique key to match
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return (new List<leankor__Swimlane__c>());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return swimlanes;
    }
    
    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method is use for creating Swimlane Records
	Inputs:         List of Swimlane innerClass
	Returns:        List of Swimlane object records 
	------------------------------------------------------------*/
   @RemoteAction
    Global static List<leankor__Swimlane__c> createSwimlane(List<Swimlane> MSwimlanes){
        //Check CRUD / FLC behavior 
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        if (
            !swimlaneBehavior.isAccessible() ||
            !swimlaneBehavior.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        leankor.Swimlane newSwimlane;
        List<leankor.Swimlane> newSwimlanes = new List<leankor.Swimlane>();
        for(KanbanController.Swimlane MSwimlane : MSwimlanes) {
            newSwimlane = new leankor.Swimlane();
            newSwimlane.id = MSwimlane.Id;
            newSwimlane.forceId = MSwimlane.ForceID;
            newSwimlane.name = MSwimlane.Name;
            newSwimlane.cardPerRow = MSwimlane.CardPerRow;
            newSwimlane.cmpId = MSwimlane.CmpID;
            newSwimlane.color = MSwimlane.Color;
            newSwimlane.guid = MSwimlane.GUID;
            newSwimlane.height = MSwimlane.Height;
            newSwimlane.help = MSwimlane.Help;
            newSwimlane.isCardAvailable = MSwimlane.isCardAvailable;
            newSwimlane.left = MSwimlane.Left;
            newSwimlane.limits = MSwimlane.Limits;
            newSwimlane.masterContainer = MSwimlane.MasterContainer;
            newSwimlane.order = MSwimlane.Order;
            newSwimlane.title = MSwimlane.Title;
            newSwimlane.top = MSwimlane.Top;
            newSwimlane.valueStreamId = MSwimlane.ValueStreamID;
            newSwimlane.width = MSwimlane.Width;
            newSwimlane.unit = MSwimlane.Unit;
            newSwimlanes.add(newSwimlane);
        }
        return leankor.Swimlane.createSwimlanes(newSwimlanes);
    }
        
    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method Is Used for Deleting Swimlane Records
	Inputs:         List of String of Swimlane ids
	Returns:        String - "Success" or empty String in case of any Exception
	------------------------------------------------------------*/
    @RemoteAction
    Global static String deleteSwimlane(List<String> Ids){
        //Check CRUD / FLC behavior 
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        if (
            !swimlaneBehavior.isAccessible() ||
            !swimlaneBehavior.isDeletable()
        ) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        String ReturnString = 'success';
        List<leankor__Swimlane__c> swimlanes = [SELECT Id,
                                                    leankor__CardPerRow__c,
                                                    leankor__CmpID__c,
                                                    leankor__Color__c,
                                                    leankor__GUID__c,
                                                    leankor__Height__c,
                                                    leankor__Help__c,
                                                    leankor__IsCardAvailable__c,
                                                    leankor__Left__c,
                                                    leankor__Limit__c,
                                                    leankor__MasterContainer__c,
                                                    leankor__Order__c,
                                                    leankor__Title__c,
                                                    leankor__Top__c,
                                                    leankor__ValueStream__c,
                                                    leankor__Width__c,
                                                    Name,
                                                    OwnerId 
                                                FROM leankor__Swimlane__c 
                                                WHERE Id IN: Ids 
                                                LIMIT 10000];
        for(leankor__Swimlane__c s: swimlanes){
            s.leankor__ValueStream__c = null;
            s.leankor__MasterContainer__c = null;
        }
        List<Database.SaveResult> uResults;
        try{
        	uResults = Database.update(swimlanes, true);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return '';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return ReturnString;
    }
    
     /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method Is Use for Getting Swimlane Records
	Inputs:         Valustream id as a String
	Returns:        List of Swimlane object records.
	------------------------------------------------------------*/
    @RemoteAction
    Global static List<leankor__Swimlane__c> getSwimlane(String VS){
        //Check CRUD / FLC behavior 
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        if (!swimlaneBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__Swimlane__c> swimlanes = [SELECT Id,
                                                    leankor__Unit__c,
                                                    leankor__CardPerRow__c,
                                                    leankor__CmpID__c,
                                                    leankor__Color__c,
                                                    leankor__GUID__c,
                                                    leankor__Height__c,
                                                    leankor__Help__c,
                                                    leankor__IsCardAvailable__c,
                                                    leankor__Left__c,
                                                    leankor__Limit__c,
                                                    leankor__MasterContainer__c,
                                                    leankor__Order__c,
                                                    leankor__Title__c,
                                                    leankor__Top__c,
                                                    leankor__ValueStream__c,
                                                    leankor__Width__c,
                                                    Name,
                                                    OwnerId 
                                                FROM leankor__Swimlane__c 
                                                WHERE leankor__ValueStream__c =: VS 
                                                LIMIT 49999];
        return swimlanes;
    }
    
    /*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method to get URL Data
	Inputs:         ----
	Returns:        UrlData in form of String
	------------------------------------------------------------*/
    Global static String getURLData(){
        String salesforceUrlRewrite = 'https://' + DomainCreator.getOrgMyDomainHostname()
        ;   
        return salesforceUrlRewrite ;
    }

    //
    // This inner Method Is Use for CloneBoard
    //
    Global class CloneBoard{
        Global String VSID;
        Global String RealVSID;
        Global Boolean KanbanVerb;
        Global Boolean KanbanTemplateVerb;
        Global Boolean StickerVerb;
        Global Boolean TaskVerb;
        Global String FinalDate;
        Global String FinalStartDate;
        Global String BoardType;
        Global Boolean ZoneVerb;
        Global Boolean MarkerVerb;
        Global Boolean ChartVerb;
        Global String LinkCloneRoomID;
        Global String LinkCloneVSID;
        Global String LinkCloneKanbanCardID;
        Global String checkcloneproject; // 10.12.2016 for clone project : stop previous kanban card update
        Global Boolean isprojectclone;
        public Boolean isBoardclone;
        public Boolean cloneFiles;
        public Boolean cloneCustomFields;
		public String targetLaunchDate;
		public String projectBoardLaunchDate;

        public DateTime oldStartDateTime; // 11/04/2023 : added inner class field for we want to store the DateTIme
        public DateTime oldEndDateTime; // 11/04/2023 : added inner class field for we want to store the DateTIme
    }
    //
    // This Method Is Use for Create Kanban Board Records
    //
    Global static void createKanbanBoard(String VSID){
        leankor.KanbanBoard.createKanbanBoard(VSID);
    }

    Global static void createDashBoard(String VSID){
        leankor.DashBoard.createDashBoard(VSID);
    }
    //
    // This Method Is Use for Create Kanban Board Records
    //
    Global static void createPlanBoard(String VSID){
        PlanBoard.createPlanBoard(VSID);
    }
    
    public static Map<Id,User> getAllUser(){   
        //Check CRUD / FLC behavior 
        UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

    	map<Id,User> allUserMap = new map<Id,User>([SELECT Id,IsActive,Name FROM User WHERE IsActive = false LIMIT 49999]);
    	return allUserMap;
    }
    //
    // This Method Is Use for Clone Board Records
    //
    @RemoteAction
    Global static String CloneSystemBoard(CloneBoard cBoard) {
        //Check CRUD / FLC behavior 
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        ZoneBehavior zoneBehavior = new ZoneBehavior();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
        ProjectScheduleBlackoutBehaviour ProjectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        StickerBehavior stickerBehavior = new StickerBehavior();
        MarkerBehaviour markerBehaviour = new MarkerBehaviour();
        ChartBehaviour chartBehaviour = new ChartBehaviour();

        if (
            !projectRoomBehaviour.isAccessible() ||
            !valueStreamBehavior.isAccessible() ||
            !valueStreamBehavior.isCreateable() ||
            !valueStreamBehavior.isUpdateable() ||
            !masterContainerBehaviour.isAccessible() ||
            !swimlaneBehavior.isAccessible() ||
            !zoneBehavior.isAccessible() ||
            !kanbanCardTemplateBehaviour.isAccessible() ||
            !kanbanCardTemplateBehaviour.isCreateable() ||
            !kanbanCardTemplateBehaviour.isUpdateable() ||
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isCreateable() ||
            !feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable() ||
            !preferenceBehaviour.isAccessible() ||
            !preferenceBehaviour.isCreateable() ||
            !ProjectScheduleBlackoutBehaviour.isAccessible() ||
            !dependencyBehaviour.isAccessible() ||
            !scheduleModeBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isAccessible() ||
            !stickerBehavior.isAccessible() ||
            !markerBehaviour.isAccessible() ||
            !chartBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__Zone__C> TempZoneList = new List<leankor__Zone__C>();
        List<leankor__ValueStream__c> VS = new List<leankor__ValueStream__c>();
        
        Map<string,Date> mapcardduedate = new Map<string,Date>();       
        Map<string,Date> mapcardstartedate = new Map<string,Date>();        
        Map<String,String> ZoneGUIDs = new  Map<String,String>();// Collection of zone guid old and new for clone Cards.
        Map<String,String> ZoneForceIDs = new  Map<String,String>();// Collection of zone ID old and new for clone Cards.
        Map<String,String> MCForceIDs = new  Map<String,String>();// Collection of MC IDs old and new for clone Cards.
        Map<String,String> SWForceIDs = new  Map<String,String>();// Collection of SW IDs old and new for clone Cards.
        Map<String,String> NewZoneForceIDs = new  Map<String,String>();// Collection of zone ID old and new for clone Cards.
        Map<String,String> NewMCForceIDs = new  Map<String,String>();// Collection of MC IDs old and new for clone Cards.
        Map<String,String> NewSWForceIDs = new  Map<String,String>();// Collection of SW IDs old and new for clone Cards.
        Map<String,String> templateIDs = new  Map<String,String>();
        Map<String,String> mapWithOldKc = new Map<String,String>(); // Map old kc with new kc record
        //variables are used for WorkWeek  and FirstDayOfWeek
        Util.WorkWeek workWeek;
        Integer firstDayOfWeek;
        Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = GanttTaskBoard.getScheduleConstraints();              
        //Tilak Raj Mahale:02.06.2020 - add to send broadcast for parent card in GS
        leankor.RealTimeController.flowWithGSForAPI = true;

        //Pratiksha : 29/May/2023 : New varibale added to update the ProjectNode dates while cloning th eproject and constraint is enable.
        DateTime newProjectBoardStartDate;
        DateTime newProjectBoardEndDate;
        DateTime oldProjectBoardStartDate;
        DateTime oldProjectBoardEndDate;
        DateTime oldMinimumStart;
        DateTime oldMaximumStart;
                      
        if(cBoard.RealVSID == '') {           	
        	/* Date: 13/05/2019 - Standard user is not getting record of standard board. abnd because of that new standard board are creating. So
        	   prevent that queries are shifted to without sharing class.*/
        	VS = leankor.RealTimeControllerHelper.getVSForCloneSystemBoard_Helper(cBoard.BoardType);
            
            if(VS.Size() > 0 ){
                TempZoneList = [SELECT Id,leankor__OpportunityStageName__c,leankor__UrlLink__c,leankor__Bottom__c,leankor__CardsPerRow__c,leankor__CaseStatus__c,leankor__CmpID__c,leankor__CompletionRateUnits__c,leankor__CompletionRate__c,leankor__CSSLayout__c,leankor__DefaultHeight__c,leankor__DefaultWidth__c,leankor__EntryFlowName__c,leankor__ExitFlowName__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__JSONDefinition__c,leankor__KanbanCardCount2__c,leankor__KanbanCardThroughput__c,leankor__kanbanSequence__c,leankor__LeadTime__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__ParentZone__c,leankor__Swimlane__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__zoneMode__c,leankor__ZoneTemplate__c,Name,OwnerId,leankor__Unit__c FROM leankor__Zone__c WHERE leankor__ValueStream__c =:VS[0].Id Limit 9999 ];
            }            
        }else{
        	/*SS 20.08.2018*/
        	//Added filter for excluding soft deleting cards and VS
            //cloning existing Board                            
            if(cBoard.BoardType == 'Kanban Board' || cBoard.BoardType== 'Plan Board'){
                VS=[SELECT Id,Name,leankor__ProjectRoom__C, (SELECT Id,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Unit__c,leankor__Height__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__Type__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId FROM leankor__ValueStream__c.leankor__Master_Containers__r),(SELECT Id,leankor__CardPerRow__c,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__MasterContainer__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId,leankor__Unit__c FROM leankor__ValueStream__c.leankor__Swimlanes__r) From leankor__ValueStream__c Where Id = :cBoard.RealVSID 
                           AND leankor__IsRecordDeleted__c = FALSE
                    LIMIT 1];
                TempZoneList = [SELECT Id,leankor__OpportunityStageName__c,leankor__Bottom__c,leankor__CardsPerRow__c,leankor__CaseStatus__c,leankor__CmpID__c,leankor__CompletionRateUnits__c,leankor__CompletionRate__c,leankor__CSSLayout__c,leankor__DefaultHeight__c,leankor__DefaultWidth__c,leankor__EntryFlowName__c,leankor__ExitFlowName__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__JSONDefinition__c,leankor__KanbanCardCount2__c,leankor__KanbanCardThroughput__c,leankor__kanbanSequence__c,leankor__LeadTime__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__ParentZone__c,leankor__Swimlane__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__zoneMode__c,leankor__ZoneTemplate__c,Name,OwnerId,leankor__Unit__c FROM leankor__Zone__c WHERE leankor__ValueStream__C =:cBoard.RealVSID
                				 	   AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                			   LIMIT 9999 ];
            }else  if(cBoard.BoardType == 'Whiteboard'){
                 VS=[SELECT Id,Name,leankor__ProjectRoom__C, (SELECT Id,leankor__Bottom__c,leankor__UrlLink__c, leankor__CardsPerRow__c,leankor__CaseStatus__c,leankor__CmpID__c,leankor__CompletionRateUnits__c,leankor__CompletionRate__c,leankor__CSSLayout__c,leankor__DefaultHeight__c,leankor__DefaultWidth__c,leankor__EntryFlowName__c,leankor__ExitFlowName__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__JSONDefinition__c,leankor__KanbanCardCount2__c,leankor__KanbanCardThroughput__c,leankor__kanbanSequence__c,leankor__LeadTime__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__ParentZone__c,leankor__Swimlane__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__zoneMode__c,leankor__ZoneTemplate__c,Name,OwnerId,leankor__Unit__c,leankor__OpportunityStageName__c FROM leankor__ValueStream__c.leankor__Zones__r) From leankor__ValueStream__c Where Id = :cBoard.RealVSID 
                 			AND leankor__IsRecordDeleted__c = FALSE
                 	LIMIT 1];
            }else  if(cBoard.BoardType == 'Dashboard'){
                VS=[SELECT Id,Name,leankor__ProjectRoom__C, (SELECT Id,leankor__Bottom__c,leankor__UrlLink__c, leankor__CardsPerRow__c,leankor__CaseStatus__c,leankor__CmpID__c,leankor__CompletionRateUnits__c,leankor__CompletionRate__c,leankor__CSSLayout__c,leankor__DefaultHeight__c,leankor__DefaultWidth__c,leankor__EntryFlowName__c,leankor__ExitFlowName__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__JSONDefinition__c,leankor__KanbanCardCount2__c,leankor__KanbanCardThroughput__c,leankor__kanbanSequence__c,leankor__LeadTime__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__ParentZone__c,leankor__Swimlane__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__zoneMode__c,leankor__ZoneTemplate__c,Name,OwnerId,leankor__Unit__c,leankor__OpportunityStageName__c FROM leankor__ValueStream__c.leankor__Zones__r) From leankor__ValueStream__c Where Id = :cBoard.RealVSID 
                   			AND leankor__IsRecordDeleted__c = FALSE
                   LIMIT 1];
            }else{
                VS=[SELECT Id, Name, leankor__ProjectRoom__C, (SELECT Id,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Unit__c,leankor__Height__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__Type__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId FROM leankor__ValueStream__c.leankor__Master_Containers__r),(SELECT Id,leankor__CardPerRow__c,leankor__CmpID__c,leankor__Color__c,leankor__GUID__c,leankor__Height__c,leankor__Help__c,leankor__IsCardAvailable__c,leankor__Left__c,leankor__Limit__c,leankor__MasterContainer__c,leankor__Order__c,leankor__Title__c,leankor__Top__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId,leankor__Unit__c FROM leankor__ValueStream__c.leankor__Swimlanes__r) From leankor__ValueStream__c Where Id = :cBoard.RealVSID 
                		   AND leankor__IsRecordDeleted__c = FALSE
                	LIMIT 1];
            }
        }   
        if(VS.size() > 0){
            Savepoint newSavepoint = Database.setSavepoint();
            try {
            	Boolean newVStaskchecker,issevendays = false;
                if(cBoard.BoardType == 'Kanban Board' || cBoard.BoardType== 'Plan Board'){
                	//Moved here while HeapSize issue
                	List<leankor.MasterContainer> newMasterContainers = new List<leankor.MasterContainer>();
                	List<leankor.Swimlane> newSwimlanes = new List<leankor.Swimlane>();
                	List<leankor.Zone> newZones = new List<leankor.Zone>();                	               	
                    for(leankor__MasterContainer__c serverMasterContainer : vs[0].leankor__Master_Containers__r){                  
                        leankor.MasterContainer localMasterContainer = new leankor.MasterContainer(cBoard.VSID, serverMasterContainer);
                        newMasterContainers.add(localMasterContainer);
                        MCForceIDs.put(localMasterContainer.guid, serverMasterContainer.id);
                    }

                    for(leankor__MasterContainer__c serverMasterContainer : leankor.MasterContainer.createMasterContainers(newMasterContainers)){
                        NewMCForceIDs.put(MCForceIDs.get(serverMasterContainer.leankor__GUID__c),serverMasterContainer.id);
                        for(leankor__Swimlane__c serverSwimlane : VS[0].leankor__Swimlanes__r){
                            if(serverMasterContainer.leankor__GUID__C.contains(serverSwimlane.leankor__MasterContainer__c)){
                                leankor.Swimlane localSwimlane = new leankor.Swimlane(cBoard.VSID, serverMasterContainer.id, serverSwimlane);
                                newSwimlanes.add(localSwimlane);
                                SWForceIDs.put(localSwimlane.guid, serverSwimlane.id);
                            }
                        }
                    }
                    
                    MCForceIDs.clear();
                    newMasterContainers.clear();
                   
                    for(leankor__Swimlane__c serverSwimlane : leankor.Swimlane.createSwimlanes(newSwimlanes)){
                        NewSWForceIDs.put(SWforceIDs.get(serverSwimlane.leankor__GUID__c),serverSwimlane.id);
                        for(leankor__Zone__c serverZone: TempZoneList){
                            if((serverSwimlane.leankor__GUID__C).contains(serverZone.leankor__Swimlane__c)){
                                leankor.Zone localZone = new leankor.Zone(cBoard.VSID, serverSwimlane.id, serverZone);
                                newZones.add(localZone);
                                ZoneForceIDs.put(localZone.guid, serverZone.id);
                                ZoneGUIDs.put(serverZone.leankor__GUID__C, localZone.guid); // preparing collection of zone guid old and new for clone Cards.
                            }
                        }
                    }
                    newSwimlanes.clear();
                    //serverSwimlanes.clear();
                    TempZoneList.clear(); 
                    leankor.Zone.createZones(newZones);
                    newZones.clear();
                    // End of KanbanBoard clone for MC, Swimlane, Zone.
                }else if(cBoard.BoardType == 'Whiteboard' || cBoard.BoardType== 'DashBoard'){
                    if(VS[0].leankor__Zones__r.Size() > 0 && cBoard.ZoneVerb == true){
                    	//Changes for HeapSize reducing
						List<leankor.realTimeController.Zone> RemoteZones = new List<leankor.realTimeController.Zone>();
                        for(leankor__Zone__c z : VS[0].leankor__Zones__r){
                            leankor.realTimeController.Zone RemoteZone=new leankor.realTimeController.Zone();
                                RemoteZone.GUID = z.Id+'-'+cBoard.VSID+'-z';
                                RemoteZone.Title = z.leankor__Title__c;
                                RemoteZone.Top = z.leankor__Top__c;
                                RemoteZone.UrlLink =z.leankor__UrlLink__c;
                                RemoteZone.Bottom = z.leankor__Bottom__c;
                                RemoteZone.Left = z.leankor__Left__c;
                                RemoteZone.Width = z.leankor__Width__c;
                                RemoteZone.Height = z.leankor__Height__c;
                                RemoteZone.X = z.leankor__X__c;
                                RemoteZone.Y = z.leankor__Y__c;
                                RemoteZone.EntryFlowName = z.leankor__EntryFlowName__c;
                                RemoteZone.ExitFlowName = z.leankor__ExitFlowName__c;
                                RemoteZone.ZoneMode = z.leankor__zoneMode__c;
                                RemoteZone.KanbanSequence = z.leankor__kanbanSequence__c;
                                RemoteZone.ValueStreamLinkID = z.leankor__ValueStreamLink__c;
                                RemoteZone.ValueStreamCardLink = z.leankor__ValueStreamCardLink__c;
                                RemoteZone.DefaultWidth  = z.leankor__DefaultWidth__c;
                                RemoteZone.DefaultHeight = z.leankor__DefaultHeight__c;
                                RemoteZone.ZoneStatus = z.leankor__CaseStatus__c ;
                                RemoteZone.ZoneOpportunityStage = z.leankor__OpportunityStageName__c ;
                                RemoteZone.CardsPerRow = z.leankor__CardsPerRow__c;
                                RemoteZone.Help = z.leankor__Help__c;
                                RemoteZone.TaskLimit = z.leankor__Limit__c;
                                RemoteZone.Order = (z.leankor__Order__c == null ? 0 : z.leankor__Order__c);
                                RemoteZone.ParentZone='';
                                RemoteZone.Swimlane='';
                            RemoteZones.add(RemoteZone);
                            ZoneForceIDs.put(RemoteZone.GUID,Z.Id);
                            ZoneGUIDs.put(z.leankor__GUID__C, RemoteZone.GUID); // preparing collection of zone guid old and new for clone Cards.                   
                        }              
                        //ReturnsZones=realTimeController.createZone(cBoard.VSID,RemoteZones);
						realTimeController.createZone(cBoard.VSID,RemoteZones);
						RemoteZones.clear();
                    }
                }

                //List<leankor__Zone__c> NewZone = [Select ID,leankor__GUID__C From leankor__Zone__c Where leankor__ValueStream__c = :cBoard.VSID limit 9999];
                for(leankor__Zone__c z2 :[Select Id, 
                                                leankor__GUID__c 
                                            From leankor__Zone__c 
                                            Where leankor__ValueStream__c = :cBoard.VSID 
                                            Limit 10000]){
                    NewZoneForceIDs.put(ZoneForceIDs.get(z2.leankor__GUID__c),Z2.Id);
                }
                
                ZoneForceIDs.clear();

                
                List<leankor__ProjectBoardWorkFieldSet__c> newprojectBoardWorkFieldSet = new List<leankor__ProjectBoardWorkFieldSet__c>();
                List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSet = [Select Id,
                                                                                                Name,
                                                                                                leankor__FieldSetName__c,
                                                                                                leankor__ProjectBoard__c
                                                                                            From leankor__ProjectBoardWorkFieldSet__c
                                                                                            Where leankor__ProjectBoard__c =: cBoard.RealVSID];
                
                for(leankor__ProjectBoardWorkFieldSet__c singleRecord : projectBoardWorkFieldSet){
                    leankor__ProjectBoardWorkFieldSet__c newRecord = new leankor__ProjectBoardWorkFieldSet__c();
                    newRecord.leankor__FieldSetName__c = singleRecord.leankor__FieldSetName__c;
                    newRecord.leankor__ProjectBoard__c = cBoard.VSID;
                    newprojectBoardWorkFieldSet.add(newRecord);
                }
                if(newprojectBoardWorkFieldSet.size()>0){
                    insert newprojectBoardWorkFieldSet;
                }
                
                // Get new board values
                leankor__ValueStream__c newVS = [Select Id,
                                                    leankor__projectroom__c,
                                                    leankor__SevenDayWorkWeek__c,//Date: 08/11/2019 - Added for workweek object when creating thenew project.
                                                (Select Id 
                                                        From leankor__Kanban_Card_Templates__r),
                                                leankor__TaskIndicator__c,
                                                leankor__DefaultCategory__c,
                                                leankor__ViewChatterOptions__c,
                                                leankor__DisableCalendarView__c,
                                                leankor__IsTemplateBoard__c,
                                                leankor__DefaultOwnerID__c,
                                                leankor__TaskDateCheck__c,
                                                leankor__Effortindicator__c,
                                                leankor__IsAgile__c,
                                                leankor__DaysPerSprint__c,
                                                leankor__PointPicklist__c,
                                                leankor__SprintStartDate__c,
                                                leankor__OpportunitySynchronization__c, 
                                                leankor__OpportunityType__c, 
                                                leankor__OpportunityCardCategory__c,
                                                leankor__OpportunityRecordType__c,
                                                leankor__OpportunityLeadSource__c,
                                                leankor__OpportunityRoleId__c,
                                                leankor__OpportunityRoleName__c,
                                                leankor__CaseCardCategory__c,
                                                leankor__CaseRecordType__c,
                                                leankor__CaseSynchronization__c,
                                                leankor__CaseType__c,
                                                Name,
                                                leankor__ProjectRoomLink__c,
                                                leankor__ValueStreamCardLink__c,
                                                leankor__ValueStreamLink__c,
                                                leankor__projectroom__r.Name 
                                            From leankor__ValueStream__c 
                                            Where Id =: cBoard.VSID 
                                            Limit 1];   
                
				leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
                //get First day number  of week
                firstDayOfWeek= leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c < 0  || leanConstant.leankor__FirstDayOfTheWeek__c > 6?1:leanConstant.leankor__FirstDayOfTheWeek__c.intValue();
                

                if(cBoard.KanbanTemplateVerb == true){

                    Boolean updateVSdefaultKCT = false;             
                    List<leankor__KanbanCardTemplate__C> cloneTemplates = new List<leankor__KanbanCardTemplate__C>();
                    List<leankor__KanbanCardTemplate__C> kanbanTempates = new List<leankor__KanbanCardTemplate__C>();
                    if(cBoard.RealVSID == ''){
                    	//DCO 10.4.17 added leankor__FieldSetName__c to query
                        kanbanTempates = RealTimeControllerHelper.readkanbanCardTemplate();  /*[ SELECT Id,leankor__Color__c,leankor__CSSLayout__c,leankor__DerivedFrom__c,leankor__Height__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__Title__c,leankor__ValueStream__c,leankor__Width__c,Name,OwnerId,leankor__FieldSetName__c FROM leankor__KanbanCardTemplate__c Where leankor__ValueStream__r.name ='_System_Board' Limit 9999];*/
                    	//DCO 10.4
                    }else{
                    	//RS 28/11/2019 Added Owner.IsActive to query
                        kanbanTempates =[ SELECT Id, leankor__Color__c, leankor__CSSLayout__c, leankor__DerivedFrom__c, leankor__Height__c, leankor__JSONData__c, leankor__JSONDefinition__c, leankor__Title__c, leankor__ValueStream__c, leankor__Width__c, Name, OwnerId, leankor__FieldSetName__c, Owner.IsActive,leankor__WeekCalendar__c FROM leankor__KanbanCardTemplate__c WHERE leankor__ValueStream__c =: cBoard.RealVSID LIMIT 9999];
                    }
                    String newOwnerId;
                    for(leankor__KanbanCardTemplate__C serverKanbanCardTemplate : kanbanTempates){
                        templateIDs.put(serverKanbanCardTemplate.Id, serverKanbanCardTemplate.leankor__Title__c);
                        //RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries
                        //newOwnerId = allUserMap.containsKey(serverKanbanCardTemplate.OwnerId) ? UserInfo.getUserId() : serverKanbanCardTemplate.OwnerId;
                        newOwnerId = serverKanbanCardTemplate.Owner.IsActive ? serverKanbanCardTemplate.OwnerId : UserInfo.getUserId() ; 
                        leankor.KanbanCardTemplate localKanbanCardTemplate = new leankor.KanbanCardTemplate(cBoard.VSID, newOwnerId, serverKanbanCardTemplate);
                        localKanbanCardTemplate.setKanbanCardTemplate(localKanbanCardTemplate);               
                        cloneTemplates.add(localKanbanCardTemplate.kanbanCardTemplate);
                    }
                	//15th feb changes for Reducing heapSize
                    kanbanTempates.clear();
                    if(cloneTemplates.size() ==0){
                        leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
                            leankor__JSONDefinition__c = '',
                            leankor__JSONData__c = '',
                            leankor__Width__c = 170,
                            leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
                            leankor__CSSLayout__c = '',
                            leankor__Color__c = '#bdbffc',
                            leankor__ValueStream__c = cBoard.VSID,
                            Name = 'Default',
                            leankor__Title__c = 'Default'
                        );
                        updateVSdefaultKCT = true;
                        cloneTemplates.add(kct);
                    }
                    //DataBase.Insert(cloneTemplates, true);
                    leankor.RealTimeControllerHelper.insertKanbanCardTemplateRecords(cloneTemplates);
					
                    
                    for(leankor__KanbanCardTemplate__C kct : cloneTemplates){
                        String tId= kct.leankor__Title__c;
                        kct.leankor__Title__c = templateIDs.get(tId);
                        templateIDs.put(tId,kct.Id); // Getting Old template id from new collection.
                    }
                    //DataBase.Update(cloneTemplates, false);
                    leankor.RealTimeControllerHelper.updateKanbanCardTemplateRecords(cloneTemplates);

					//Changes for Reducing heapSize
					String cloneTemplateId= cloneTemplates[0].id;
                    cloneTemplates.clear();
                    if(updateVSdefaultKCT){
                        leankor__ValueStream__c projectBoardupdate = new leankor__ValueStream__c(leankor__DefaultCategory__c = cloneTemplateId, ID = cBoard.VSID);
                        DataBase.update(projectBoardupdate);
                    }
                    
                    if(cBoard.RealVSID != ''){
                        /**Here, Need to write code for update template values in new created Project Board using clone*/
                        leankor__ValueStream__c oldVS = [Select Id,
                                                                leankor__DisableTaskAsMiniature__c,
                        										leankor__IsShowCategoryColor__c,
                        										leankor__SevenDayWorkWeek__c,
                        										leankor__TaskIndicator__c,
                        										leankor__PortfolioMode__c,
                        										leankor__ViewChatterOptions__c,
                        										leankor__DefaultCategory__c,
                        										leankor__DisableCalendarView__c,
                        										leankor__IsTemplateBoard__c,
                        										leankor__DefaultOwnerID__c,
                        										leankor__TaskDateCheck__c,
                        										leankor__Effortindicator__c,
                        										leankor__IsAgile__c,
                        										leankor__DaysPerSprint__c,
                        										leankor__PointPicklist__c,
                        										leankor__SprintStartDate__c,
                        										leankor__OpportunitySynchronization__c, 
                        										leankor__OpportunityType__c, 
                        										leankor__OpportunityCardCategory__c,
                        										leankor__OpportunityRecordType__c,
                        										leankor__OpportunityLeadSource__c,
                        										leankor__OpportunityRoleId__c,
                        										leankor__OpportunityRoleName__c, 
                        										leankor__CaseCardCategory__c,
                        										leankor__CaseRecordType__c,
                        										leankor__CaseSynchronization__c,
                        										leankor__CaseType__c,Name,
                        										leankor__ProjectRoomLink__c,
                        										leankor__ValueStreamCardLink__c,
                        										leankor__ValueStreamLink__c,
                        										leankor__ProjectBoardLaunchDateTime__c,
                                                                leankor__ProjectBoardStartDateTime__c,
                                                                leankor__ProjectBoardEndDateTime__c
                        								From leankor__ValueStream__c 
                        								Where Id =: cBoard.RealVSID 
                                                        Limit 1];
                        
                        //Pratiksha : 29/May/2023 : Storing oldBoard projectNode dates to calculate the target board ProjectNode.
                        oldProjectBoardStartDate = oldVS.leankor__ProjectBoardStartDateTime__c;
                        oldProjectBoardEndDate = oldVS.leankor__ProjectBoardEndDateTime__c;                          
                        newVS.leankor__CaseCardCategory__c = templateIDs.get(oldVS.leankor__CaseCardCategory__c);
                        newVS.leankor__CaseRecordType__c = oldVS.leankor__CaseRecordType__c;
                        newVS.leankor__CaseSynchronization__c = oldVS.leankor__CaseSynchronization__c;
                        newVS.leankor__CaseType__c = oldVS.leankor__CaseType__c;
                        newVS.leankor__SprintStartDate__c = (oldVS.leankor__SprintStartDate__c == null ? null : oldVS.leankor__SprintStartDate__c) ;
                        newVS.leankor__PointPicklist__c = (oldVS.leankor__PointPicklist__c == '' ? ((leanConstant.leankor__PointSequence__c == null || leanConstant.leankor__PointSequence__c == '') ?'[]' :leanConstant.leankor__PointSequence__c) :oldVS.leankor__PointPicklist__c) ;
                        newVS.leankor__DaysPerSprint__c = (oldVS.leankor__DaysPerSprint__c == null ? null : oldVS.leankor__DaysPerSprint__c);
                        newVS.leankor__IsAgile__c = (oldVS.leankor__IsAgile__c == null ?false :oldVS.leankor__IsAgile__c);
                        newVS.leankor__Effortindicator__c = ((oldVS.leankor__Effortindicator__c == '' || oldVS.leankor__Effortindicator__c == Null) ? 'Days' :oldVS.leankor__Effortindicator__c);
                        //15/Feb/2023 : Changes added for Task Date check variable, If we are cloning Board/Project then old value will be assign in Custom field.
                        if(CloneProjectAction.isClonedProject == true || CloneProjectBoardAsyncAction.isClonedBoard == true){
                            newVS.leankor__TaskDateCheck__c = oldVS.leankor__TaskDateCheck__c; 
                        }
                        newVStaskchecker = newVS.leankor__TaskDateCheck__c;
                        newVS.leankor__OpportunitySynchronization__c = oldVS.leankor__OpportunitySynchronization__c;
                        newVS.leankor__OpportunityType__c = oldVS.leankor__OpportunityType__c;
                        newVS.leankor__OpportunityCardCategory__c = templateIDs.get(oldVS.leankor__OpportunityCardCategory__c);
                        newVS.leankor__OpportunityRecordType__c = oldVS.leankor__OpportunityRecordType__c;
                        newVS.leankor__OpportunityLeadSource__c = oldVS.leankor__OpportunityLeadSource__c;
                        newVS.leankor__OpportunityRoleId__c  = oldVS.leankor__OpportunityRoleId__c;
                        newVS.leankor__OpportunityRoleName__c = oldVS.leankor__OpportunityRoleName__c;
						//Instead of using complete collection of Clonned Template use single variable 
						//Changes for reducing HeapSize
                        //newVS.leankor__DefaultCategory__c = cloneTemplates[0].id ;//(templateIDs.get(oldVS.leankor__DefaultCategory__c)==null ?cloneTemplates[0].id :templateIDs.get(oldVS.leankor__DefaultCategory__c));
						newVS.leankor__DefaultCategory__c = cloneTemplateId;
                        newVS.leankor__DisableCalendarView__c = oldVS.leankor__DisableCalendarView__c;
                        //newVS.leankor__IsTemplateBoard__c = false ;//oldVS.leankor__IsTemplateBoard__c;//no need for update because we check for template feature in createprojectboard method in Realtimecontroller class
                        newVS.leankor__DefaultOwnerID__c = oldVS.leankor__DefaultOwnerID__c;
                        newVS.leankor__PortfolioMode__c = oldVS.leankor__PortfolioMode__c;
                        newVS.leankor__DisableTaskAsMiniature__c = oldVS.leankor__DisableTaskAsMiniature__c;
                        newVS.leankor__TaskIndicator__c = oldVS.leankor__TaskIndicator__c;
                        newVS.leankor__SevenDayWorkWeek__c = oldVS.leankor__SevenDayWorkWeek__c;
                        newVS.leankor__ViewChatterOptions__c= oldVS.leankor__ViewChatterOptions__c;
                        newVS.leankor__IsShowCategoryColor__c= oldVS.leankor__IsShowCategoryColor__c;
                        newVS.leankor__ProjectBoardLaunchDateTime__c = String.isNotBlank(cBoard.projectBoardLaunchDate) ? (DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate, DateTime.class) : oldVS.leankor__ProjectBoardLaunchDateTime__c;
                        issevendays =oldVS.leankor__SevenDayWorkWeek__c;

                        DataBase.Update(newVS, false);
						
						
                        //List<leankor__Preference__c> oldVSPre = [SELECT Id,OwnerId,leankor__CardPastDueDate__c, leankor__DerivedFrom__c,leankor__FollowOnChatter__c,leankor__GUID__c,leankor__Moved__c,leankor__PercentDone__c,leankor__SubscribeToCard__c,leankor__TaskPastDueDate__c,leankor__ValueStream__c,Name, leankor__isTaskCompleted__c FROM leankor__Preference__c WHERE leankor__ValueStream__c =: cBoard.RealVSID limit 9999];
                        leankor__Preference__c globalPref = [Select Id,
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
																	OwnerId 
																From leankor__Preference__c 
																Where leankor__ValueStream__c = '' 
																	And OwnerId =: UserInfo.getUserId() 
																Limit 1];  
                        List<leankor__Preference__c> clonePreferenceList = new List<leankor__Preference__c>();
                           
                        List<Id> prefUsers = new List<Id>();
                        for(leankor__Preference__c p : [Select Id,
                                                                OwnerId,
                                                                leankor__ValueStream__c,
                                                                Name 
                                                            From leankor__Preference__c 
                                                            Where leankor__ValueStream__c = :cBoard.RealVSID 
                                                            Order By OwnerId Desc 
                                                            Limit 10000]) {

                            if(!prefUsers.contains(p.OwnerId)) {
                                prefUsers.add(p.OwnerId);
                            }
                            else continue;
                        }
                        List<Id> activeUsers = new List<Id>();
                        for(User u : [Select Id, 
                                                Name, 
                                                IsActive 
                                            From User 
                                            Where Id In :prefUsers 
                                                And IsActive = true 
                                            Limit 10000]) {

                            if(activeUsers.contains(u.Id)) {
                                continue;
                            }
                            else activeUsers.add(u.Id);
                        }
                        List<Id> uniqueIdCheck = new List<Id>();

						//RS 28/11/2019 Added Owner.IsActive to query
                        for(leankor__Preference__c prefLog :[Select Id,
																	OwnerId,
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
																	leankor__isTaskCompleted__c,
																	Owner.IsActive 
																From leankor__Preference__c 
																Where leankor__ValueStream__c =: cBoard.RealVSID 
                                                                    And OwnerId In :activeUsers 
																Limit 10000]){
                            
                            // Tilak: 02.09.2020 - Create the 18 digit GUID 
                            Blob generatedBlob = Crypto.GenerateAESKey(128);
                            String hex = EncodingUtil.ConvertTohex(generatedBlob);
                            String guid = hex.substring(0, 8) + '-' + hex.substring(8, 12) + '-' + hex.substring(12, 16);
                            
                            leankor__Preference__c clonePref = New leankor__Preference__c();
                            clonePref.leankor__ValueStream__c = cBoard.VSID;                           
                           	//RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries
                            //clonePref.OwnerId = allUserMap.containsKey(prefLog.OwnerId) ? UserInfo.getUserId() : prefLog.OwnerId;
							clonePref.OwnerId = prefLog.Owner.IsActive ? prefLog.OwnerId : UserInfo.getUserId() ;
                            clonePref.leankor__CardPastDueDate__c =prefLog.leankor__CardPastDueDate__c;
                            clonePref.leankor__DerivedFrom__c = globalPref.ID;
                            clonePref.leankor__SubscribeToCard__c = prefLog.leankor__SubscribeToCard__c;
                            clonePref.leankor__FollowOnChatter__c = prefLog.leankor__FollowOnChatter__c;
                            if(prefLog.leankor__FollowOnChatter__c != 'all' && prefLog.leankor__FollowOnChatter__c != 'none'){
                                List<String> Arrchatter =(List<String>) JSON.deserialize(prefLog.leankor__FollowOnChatter__c,List<String>.class) ;
                                List<String> UpdateChatterIDs = New List<String>();
                                for(string StrChatter:Arrchatter){
                                    UpdateChatterIDs.add(templateIDs.get(StrChatter));
                                }
                                clonePref.leankor__FollowOnChatter__c =(Arrchatter.size() > 0 ?JSON.serialize(UpdateChatterIDs) :prefLog.leankor__FollowOnChatter__c);
                            }
                            if(prefLog.leankor__SubscribeToCard__c != 'all' && prefLog.leankor__SubscribeToCard__c != 'none'){
                                List<String> ArrCard =(List<String>) JSON.deserialize(prefLog.leankor__SubscribeToCard__c,List<String>.class) ;                             
                                List<String> UpdateCardIDs = New List<String>();
                                for(string StrCard:ArrCard){
                                    UpdateCardIDs.add(templateIDs.get(StrCard));
                                }
                                clonePref.leankor__SubscribeToCard__c = (ArrCard.size() > 0 ? JSON.serialize(UpdateCardIDs) : prefLog.leankor__SubscribeToCard__c);
                            }                    

                            // Tilak: 02.09.2020 - Same GUID will be created when boards are cloned on the same time. That causing an error while saving the records.
                            //clonePref.leankor__GUID__c = System.now() +'a-b'+prefLog.ID;
                            clonePref.leankor__GUID__c = guid +'a-b'+prefLog.ID;
                            clonePref.leankor__Moved__c = prefLog.leankor__Moved__c;
                            clonePref.leankor__PercentDone__c = prefLog.leankor__PercentDone__c;
                            clonePref.leankor__TaskPastDueDate__c = prefLog.leankor__TaskPastDueDate__c;
                            clonePref.Name = prefLog.Name;
                            clonePref.leankor__isTaskCompleted__c = prefLog.leankor__isTaskCompleted__c;
                            
                            if(!uniqueIdCheck.contains(prefLog.OwnerId)) { 
                            clonePreferenceList.add(clonePref);
                                uniqueIdCheck.add(prefLog.OwnerId);
                        }
                            else continue;
                            
                        }
                        Insert clonePreferenceList;
                        System.debug('Original/First Batch Board Preference Record Size => '+clonePreferenceList.size());
                        clonePreferenceList.clear();
                    }else if(cBoard.BoardType == 'Kanban board'){
                    	leankor__ValueStream__c oldVS = RealTimeControllerHelper.readsystemBoard();/*[SELECT Id,leankor__DefaultCategory__c,leankor__OpportunityCardCategory__c, leankor__CaseCardCategory__c FROM leankor__ValueStream__c WHERE Name = '_system_Board' Limit 1]*/
                        newVS.leankor__OpportunityCardCategory__c = templateIDs.get(oldVS.leankor__OpportunityCardCategory__c);
                        newVS.leankor__CaseCardCategory__c = templateIDs.get(oldVS.leankor__CaseCardCategory__c);
                        newVS.leankor__DefaultCategory__c = templateIDs.get(oldVS.leankor__DefaultCategory__c);
                        DataBase.Update(newVS, false);           
                    } 
                } // End Condition when code need to create template.
                    
                    
                // Date: 06/11/2019 - Changes related to black out, Getting the existing Project Schedule Blackout records
                List<leankor__ProjectScheduleBlackout__c> blackOutList = [Select 
                                                                            leankor__EndDate__c,                                                                           
                                                                            leankor__StartDate__c
                                                                        From leankor__ProjectScheduleBlackout__c
                                                                        Where leankor__ProjectBoard__c =: newVS.Id
                                                                        Limit 9999 ];
                    
                //Create instance of WorkWeek which provides Working week days information 
                workWeek = new Util.WorkWeek(firstDayOfWeek, newVS.leankor__SevenDayWorkWeek__c? 7 : 5, blackOutList);
                
                if(cBoard.KanbanVerb == true){
                    Boolean isFromStartDate = false;
                    Decimal otherDifference;
                    Integer dateDifference;
                    DateTime StartDate,FinalDate,tempDueDateTime,tempstartDateTime;
                    
                    //Map<String,boolean> IsSevenday = new Map<string,boolean>(); ->> Non in use

                    List<leankor__KanbanCard__c> RemoteKanbanCards = new List<leankor__KanbanCard__c>();                                    
                    List <Id> kanbanCardIdListForTask = new List <Id> ();
                                                
                    // Date :17/10/19 - changes related to clone custom field. Using dynamic qyery.         
                    //RS 28/11/2019 Added Owner.IsActive to query         
                    String sObjectFields = 'Id,leankor__IsSuccessorRecalculate__c,leankor__EffortRemaining__c,leankor__MasterContainer__c,'+                                                                     
                                        'leankor__CardID__c,leankor__Point__c,leankor__Swimlane__c,leankor__Zone__c,leankor__UrlLink__c,'+
                                        'leankor__Account__c,leankor__ActualDuration__c,leankor__Actual_Time_Taken__c,leankor__Bottom__c,leankor__Budgeted_Time__c,leankor__Case__c,'+
                                        'leankor__CmpID__c,leankor__Color__c,leankor__CompletionVariance__c,leankor__Contact__c,leankor__CSSLayout__c,leankor__DateColor__c,leankor__DescriptionLong__c,'+
                                        'leankor__AcceptanceCriteria__c,leankor__Description__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__EstimatedDuration__c,'+
                                        'leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__IsCompletedOnTime__c,leankor__JSONData__c,'+
                                        'leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__Left__c,leankor__Opportunity__c,leankor__Order__c,leankor__PercentComplete2__c,'+
                                        'leankor__Priority__c,leankor__PromiseCompletionDate__c,leankor__StartDate__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,'+
                                        'leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__ZoneGUID__c,Name,OwnerId, leankor__StartDateTime__C,'+
	                                    'leankor__DueDateTime__c,leankor__OnBudget__c,leankor__OnQuality__c,leankor__OnTime__c,leankor__IsAtRisk__c,leankor__IsOnHold__c,Owner.IsActive,leankor__Monday__c,'+
                                        'leankor__Tuesday__c,leankor__Wednesday__c,leankor__Thursday__c,leankor__Friday__c,leankor__Saturday__c,leankor__Sunday__c,leankor__WeekCalendar__c,';
                                          
                    String relatedsObjects =' (Select Id,leankor__ManuallyScheduled__c,leankor__Mode__c,leankor__ScheduleConstraint__r.leankor__Type__c,leankor__ConstraintDateTime__c,'+
                        					'leankor__EffortUnits__c,leankor__EffortActual__c,leankor__KanbanCard__c,leankor__KanbanCard__r.leankor__valuestream__c, leankor__ReadOnly__c From leankor__ScheduleModes__r Limit 1),'+
                                            '(Select Id,leankor__AssignedTo__c,leankor__KanbanCard__c,leankor__KanbanCard__r.leankor__valuestream__c,leankor__PercentAllocation__c,leankor__CompletedDate__c,Name,leankor__PercentCompleted__c,leankor__ExpenseAccount__c,leankor__ExpenseSubCategory__c,leankor__ExpenseCategory__c,leankor__ExternalHourlyRate__c,leankor__InternalHourlyRate__c,leankor__ResourceType__c,leankor__ProjectFinancial__c,leankor__AssignedTo__r.IsActive From leankor__ResourceAssignments__r),'+
                                            'leankor__ValueStream__r.leankor__ProjectRoom__c, leankor__ValueStream__r.leankor__ScheduleBackward__c, leankor__valuestream__r.leankor__boardtype__c,leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c, leankor__ValueStreamLink__r.leankor__ProjectRoom__c,'+
                                            'leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,RecordType.Name ';
                 
                    // 17/10/19 get customFields.          
                    Map<String, Schema.SObjectField> fieldMapKanbanCardForClone = new DescribeSchema().getObjectFieldsForClone('leankor__KanbanCard__c');                						
                    String customFields = '';  
 				    Integer size=0;  
	      		    for(String t : fieldMapKanbanCardForClone.keySet()){
                        customFields =  customFields + t +',';					
	      		    }                   	  			

                    /** For branch org.*/
                    //String soql ='select '+ customFields+relatedsObjects+' FROM leankor__KanbanCard__c where leankor__ValueStream__c =\'' + cBoard.RealVSID + '\' And leankor__IsRecordDeleted__c = FALSE And leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE Limit 10000';  			  				
                    
                    /** for Beta use below line.*/
                    String soql ='select '+ customFields + sObjectFields + relatedsObjects + ' FROM leankor__KanbanCard__c where leankor__ValueStream__c =\'' + cBoard.RealVSID + '\' And leankor__IsRecordDeleted__c = FALSE And leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE Limit 10000';  			  				
				    RemoteKanbanCards = Database.query(soql);									                                                                                                                                                                                                                                                 
                    
                    // rbo 11.23.16               
                    if(RemoteKanbanCards.Size() > 0){
                        cBoard.isprojectclone = (cBoard.isprojectclone==null ? false : cBoard.isprojectclone);// to remove this line need to ask UI to add this field when kanbanboard is going to clone
						//Use aggregateQuery instead of iterating over all records for Min/Max dates
                        //List<leankor__KanbanCard__c> tempRemoteKanbanCards =new List<leankor__KanbanCard__c>();
                          
                        //if(cBoard.BoardType != 'UberBoard' && string.isnotblank(string.valueof(cBoard.isprojectclone)))
                        if(cBoard.BoardType != 'UberBoard' && cBoard.isprojectclone){
                            //getting source project Board(Plan Gantt)
                            leankor__ValueStream__c SourceBoardId = [SELECT Id FROM leankor__ValueStream__c WHERE leankor__ProjectRoom__c =: vs[0].leankor__ProjectRoom__c and leankor__Boardtype__c = 'UberBoard' limit 1];
                            // Date: 18/06/2019 - For project board launch date
							//There is no need to maintain difference in case of clone project
                        	if(!String.isBlank(cBoard.projectBoardLaunchDate)){   
    	                        Isfromstartdate = true;                       
                                Datetime valueStreamStartDate;
                        		// Project launch date become the start date of project 
                        		cBoard.FinalStartDate = cBoard.projectBoardLaunchDate;
                        		
    	                        AggregateResult[] minStartDate = [Select Min(leankor__StartDateTime__c) minimumDate, Max(leankor__StartDateTime__c) maximumDate From leankor__KanbanCard__c Where leankor__ValueStream__c = : cBoard.RealVSID 
	                             										And leankor__IsRecordDeleted__c = False And leankor__ValueStream__r.leankor__IsRecordDeleted__c = False]; 

	                            leankor__ValueStream__c valueStream = [SELECT leankor__ProjectBoardLaunchDateTime__c FROM leankor__ValueStream__c WHERE Id =: cBoard.RealVSID ];
	                            	                           
	                            if(minStartDate[0].get('minimumDate') != null){
                                    //Pratiksha : 29/May/2023 : Storing oldBoard min and Max dates to calculate the target board ProjectNode.
                                    oldMinimumStart	= (Datetime)minStartDate[0].get('minimumDate');	
                                    oldMaximumStart	= (Datetime)minStartDate[0].get('maximumDate');	
							    	DateTime minimumStartDate = (Datetime)minStartDate[0].get('minimumDate');
							    	DateTime projectLaunchDate = valueStream.leankor__ProjectBoardLaunchDateTime__c ;             
                                    valueStreamStartDate = (Datetime)minStartDate[0].get('minimumDate');
						        	if(projectLaunchDate != null){
                                        if (issevendays) {
						        		Integer numberOfDaysToAdd = (projectLaunchDate.dateGMT()).daysBetween(minimumStartDate.dateGMT());							        							        		
						        		cBoard.FinalStartDate = Json.serialize((((DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate,DateTime.class)).addDays(numberOfDaysToAdd)));
                                        }
                                        else{
                                            Integer numberOfDaysToAdd = workWeek.getBusinessDays(projectLaunchDate.dateGMT(), minimumStartDate.dateGMT());
                                            cBoard.FinalStartDate = Json.serialize(numberOfDaysToAdd != 0 ? workWeek.nextBusinessDate((DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate,DateTime.class), numberOfDaysToAdd): minimumStartDate);
                                        
                                            // Abhishek:24/05/2022 :  when Launch date and Minimum Start date of Card is same 
                                            if(projectLaunchDate.dateGMT() == minimumStartDate.dateGMT()){
                                                cBoard.FinalStartDate = Json.serialize(workWeek.nextBusinessDate((DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate,DateTime.class), numberOfDaysToAdd));
                                            }
                                        }
						        	}else{
						        		// If project board launch date is not define that it work like board clonning with start date.
                                        /*
                                        *Modified By :Ashutosh Gour
                                        *Modification : Modification for making SOQL selective and remove negative selection.
                                        */
						        		/*minStartDate = [SELECT MIN(leankor__StartDateTime__c) minimumDate FROM leankor__KanbanCard__c WHERE leankor__ValueStream__c = : SourceBoardId.Id AND leankor__ValueStream__c != null
	                             										AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];*/
                                        if(issevendays){
                                            if(SourceBoardId.Id != null){
                                                minStartDate = [SELECT 
                                                                MIN(leankor__StartDateTime__c) minimumDate 
                                                            FROM leankor__KanbanCard__c 
                                                            WHERE leankor__ValueStream__c = : SourceBoardId.Id
                                                                AND leankor__IsRecordDeleted__c = FALSE 
                                                                AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
                                            }
                                            else{
                                                minStartDate.clear();
                                            }
                                        }
						        	}
	                            } 
	                            StartDate = (DateTime)JSON.deserialize(cBoard.FinalStartDate,DateTime.class); 
                                StartDate = workWeek.getNextWorkingDay(StartDate); 
								//Use new logic to calculate day difference, no more recurring loop execution
						        //dateDifference = daysBetweenExcludingWeekends((Datetime)minStartDate[0].get('minimumDate'), StartDate,issevendays,workWeek);  	                     
                                //dateDifference = leankor.Util.getBusinessDays((Datetime)minStartDate[0].get('minimumDate'),StartDate, issevendays, workWeek);
                                /*SS 12 March 2020*/
                                //To prevent TimeZone related issues, always use GMT method instead of user's local ,
                                //dateDifference = workWeek.getBusinessDays(((Datetime)minStartDate[0].get('minimumDate')).date(), StartDate.date()); 
                                //dateDifference = workWeek.getBusinessDays(((Datetime)minStartDate[0].get('minimumDate')).dateGMT(), StartDate.dateGMT());
                                //Ashutosh : 13/07/2021 - Fixes for issue Occuring on cloning project(Null PlanGantt) with Launch date.
                                dateDifference = minStartDate[0].get('minimumDate') != null ? workWeek.getBusinessDays(((Datetime)minStartDate[0].get('minimumDate')).dateGMT(), StartDate.dateGMT()) : workWeek.getBusinessDays(valueStreamStartDate.dateGMT(), StartDate.dateGMT());                                	                     
    	                    }
    	                    else if(!String.isBlank(cBoard.FinalStartDate)){
                                    Isfromstartdate = true;                       
                                    //clone project Start date                      
                                    StartDate = (DateTime)JSON.deserialize(cBoard.FinalStartDate, DateTime.class);
                                    StartDate = workWeek.getNextWorkingDay(StartDate); 
                                    /*SS 20.08.2018*/
                                    //Added filter for excluding soft deleted cards and vs
                                        //getting smallest datetime of card in source planGantt board
                                    /*
                                    *Modified By :Ashutosh Gour
                                    *Modification : Modification for making SOQL selective and remove negative selection.
                                    */
                                    /*AggregateResult[] groupedResultsMin = [SELECT MIN(leankor__StartDateTime__c) minimumDate FROM leankor__KanbanCard__c WHERE leankor__ValueStream__c = : SourceBoardId.Id AND leankor__ValueStream__c != null
                                                                            AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];*/
                                    AggregateResult[] groupedResultsMin = new List<AggregateResult>();
                                    if (SourceBoardId.Id != null) {
                                        groupedResultsMin = [SELECT 
                                                                    Min(leankor__StartDateTime__c) minimumDate,
                                                                    Max(leankor__StartDateTime__c) maximumDate 
                                                                FROM leankor__KanbanCard__c 
                                                                WHERE leankor__ValueStream__c = : SourceBoardId.Id
                                                                    AND leankor__IsRecordDeleted__c = FALSE 
                                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
                                    }
    	                             
                                    // getting diffrences between project start date and planGantt minimum date
    	                            if(groupedResultsMin[0].get('minimumDate') == null){
	                             	/*SS 20.08.2018*/
	                        	 	//Added filter for excluding soft deleted cards and vs
	                             	/*
                                    *Modified By :Ashutosh Gour
                                    *Modification : Modification for making SOQL selective and remove negative selection.
                                    */
                                    /*groupedResultsMin = [SELECT MIN(leankor__StartDateTime__c) minimumDate FROM leankor__KanbanCard__c WHERE leankor__ValueStream__c = : cBoard.RealVSID AND leankor__ValueStream__c != null
	                             						AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];*/
                                        if(cBoard.RealVSID != null){
                                            groupedResultsMin = [SELECT 
                                                                        Min(leankor__StartDateTime__c) minimumDate,
                                                                        Max(leankor__StartDateTime__c) maximumDate
                                                                    FROM leankor__KanbanCard__c 
                                                                    WHERE leankor__ValueStream__c = : cBoard.RealVSID 
                                                                        AND leankor__IsRecordDeleted__c = FALSE 
                                                                        AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
                                        }
                                        else{
                                            groupedResultsMin.clear();
                                        }
                                    }

                            	//Use new logic to calculate day difference, no more recurring loop execution
                                //dateDifference = daysBetweenExcludingWeekends((Datetime)groupedResultsMin[0].get('minimumDate'),StartDate,issevendays,workWeek);
                                //dateDifference = leankor.Util.getBusinessDays((Datetime)groupedResultsMin[0].get('minimumDate'), StartDate, issevendays, workWeek);
                             
                                /*SS 12 March 2020*/
                                //To prevent TimeZone related issues, always use GMT method instead of user's local , 
                                //dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMin[0].get('minimumDate')).date(), StartDate.date());
                                dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMin[0].get('minimumDate')).dateGMT(), StartDate.dateGMT());
                                //Pratiksha : 29/May/2023 : Storing oldBoard min and Max dates to calculate the target board ProjectNode.
                                oldMinimumStart	= (Datetime)groupedResultsMin[0].get('minimumDate');	
                                oldMaximumStart	= (Datetime)groupedResultsMin[0].get('maximumDate');	
    	                    }else{
    	                        //clone project Due date  
    	                        FinalDate = (DateTime)JSON.deserialize(cBoard.FinalDate, DateTime.class);
                                FinalDate = workWeek.getPreviousWorkingDay(FinalDate);
                                /*SS 20.08.2018*/
                                //Added filter for excluding soft deleted cards and vs
                                    // getting largest datetime of card in source planGantt board
                                /*
                                *Modified By :Ashutosh Gour
                                *Modification : Modification for making SOQL selective and remove negative selection.
                                */
                                /*AggregateResult[] groupedResultsMax = [SELECT Max(leankor__DueDateTime__c) maximumDate FROM leankor__KanbanCard__c WHERE leankor__ValueStream__c = : SourceBoardId.Id AND leankor__ValueStream__c != null
                                                                    AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];*/
                                AggregateResult[] groupedResultsMax = new List<AggregateResult>();
                                if(SourceBoardId.Id != null){
                                    groupedResultsMax = [SELECT
                                                                Max(leankor__DueDateTime__c) maximumDate, 
                                                                Min(leankor__StartDateTime__c) minimumDate
                                                            FROM leankor__KanbanCard__c 
                                                            WHERE leankor__ValueStream__c = : SourceBoardId.Id 
                                                                AND leankor__IsRecordDeleted__c = FALSE 
                                                                AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
                                }

    	                        if(groupedResultsMax[0].get('maximumDate') == null){
	                        	/*SS 20.08.2018*/
	                        	//Added filter for excluding soft deleted cards and vs
	                        		/*
                                    *Modified By :Ashutosh Gour
                                    *Modification : Modification for making SOQL selective and remove negative selection.
                                    */
                                    /*groupedResultsMax = [SELECT Max(leankor__DueDateTime__c) maximumDate FROM leankor__KanbanCard__c 
	                        										WHERE leankor__ValueStream__c = : cBoard.RealVSID AND leankor__ValueStream__c != null
													AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];*/
                                    if(cBoard.RealVSID != null){
                                        groupedResultsMax = [SELECT 
                                                                    Max(leankor__DueDateTime__c) maximumDate,
                                                                    Min(leankor__StartDateTime__c) minimumDate
                                                                FROM leankor__KanbanCard__c 
                                                                WHERE leankor__ValueStream__c = : cBoard.RealVSID 
													            AND leankor__IsRecordDeleted__c = FALSE 
                                                                AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
    	                            }
                                    else{
                                        groupedResultsMax.clear();
                                    }
    	                        }
								//Use new logic to calculate day difference, no more recurring loop execution	
    	                        // getting diffrences between project duedate date and planGantt max date
                                //dateDifference = daysBetweenExcludingWeekends((Datetime)groupedResultsMax[0].get('maximumDate'),FinalDate,issevendays, workWeek);
                                //dateDifference = leankor.Util.getBusinessDays((Datetime)groupedResultsMax[0].get('maximumDate'), FinalDate, issevendays, workWeek);
                              
                                /*SS 12 March 2020*/
                                //To prevent TimeZone related issues, always use GMT method instead of user's local , 
                                //dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMax[0].get('maximumDate')).date(), FinalDate.date());
                                dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMax[0].get('maximumDate')).dateGMT(), FinalDate.dateGMT());
                                oldMinimumStart	= (Datetime)groupedResultsMax[0].get('minimumDate');	
                                oldMaximumStart	= (Datetime)groupedResultsMax[0].get('maximumDate');
    	                    }                                          
                        }
                        else{
                        	// Date: 18/06/2019 - For project board launch date.
                        	if(String.isNotBlank(cBoard.projectBoardLaunchDate)){   
                        		// Project launch date become the start date of project 
                        		cBoard.FinalStartDate = cBoard.projectBoardLaunchDate;
    	                        AggregateResult[] minStartDate = [SELECT MIN(leankor__StartDateTime__c) minimumDate, Max(leankor__StartDateTime__c) maximumDate FROM leankor__KanbanCard__c WHERE leankor__ValueStream__c = : cBoard.RealVSID 
	                             										AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];  
	                             										
	                            leankor__ValueStream__c valueStream = [SELECT leankor__ProjectBoardLaunchDateTime__c FROM leankor__ValueStream__c WHERE Id=: cBoard.RealVSID ];
	                            	                           
	                            if(minStartDate[0].get('minimumDate') != null){     
                                    //Pratiksha : 29/May/2023 : Storing oldBoard min and Max dates to calculate the target board ProjectNode. 
                                    oldMinimumStart	= (Datetime)minStartDate[0].get('minimumDate');	
                                    oldMaximumStart	= (Datetime)minStartDate[0].get('maximumDate');									
							    	DateTime minimumStartDate = (Datetime)minStartDate[0].get('minimumDate');
							    	DateTime projectLaunchDate = valueStream.leankor__ProjectBoardLaunchDateTime__c ;               
						        	if(projectLaunchDate != null){
                                        Integer numberOfDaysToAdd = workWeek.getBusinessDays(projectLaunchDate.dateGMT(), minimumStartDate.dateGMT());
                                        Datetime tempFinalStartDate;
                                        if (issevendays) {
						        		    tempFinalStartDate = numberOfDaysToAdd != 0 ?(((DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate,DateTime.class)).addDays(numberOfDaysToAdd)) : minimumStartDate.dateGMT();
                                        }
                                        else{
                                            // Ashutosh : 07/10/2021 : Set MinimumStartDate in tempFinalStartDate if numberOfDaysToAdd is 0.
                                            tempFinalStartDate = numberOfDaysToAdd != 0 ? workWeek.nextBusinessDate((DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate,DateTime.class), numberOfDaysToAdd) : minimumStartDate.dateGMT();
                                            if(numberOfDaysToAdd < 0 && projectLaunchDate > (DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate,DateTime.class)){
                                                tempFinalStartDate = workWeek.getPreviousWorkingDay(tempFinalStartDate);
                                            }
                                        }
                                        
                                        //Abhishek:24/05/2022 :  when Launch date and Minimum Start date of Card is same 
                                            if(projectLaunchDate.dateGMT() == minimumStartDate.dateGMT()){
                                                tempFinalStartDate = workWeek.nextBusinessDate((DateTime)JSON.deserialize(cBoard.projectBoardLaunchDate,DateTime.class), numberOfDaysToAdd);
                                            }
                                        cBoard.FinalStartDate = Json.serialize(tempFinalStartDate);
						            }		
						        }	  	                     
    	                    }
                        	
                            if(String.isNotBlank(cBoard.FinalStartDate)){
                            	
                                Isfromstartdate = true;
                                //clone project Start date                        
                                StartDate = (DateTime)JSON.deserialize(cBoard.FinalStartDate, DateTime.class);
                                StartDate = workWeek.getNextWorkingDay(StartDate); // If occurred on holiday
                                /*SS 20.08.2018*/
	                            //Added filter for excluding soft deleted cards and vs
    	                        //getting smallest datetime of card in source board
	                    	    /*tempRemoteKanbanCards =[SELECT Id,leankor__StartDateTime__c FROM leankor__KanbanCard__c Where leankor__ValueStream__c =:cBoard.RealVSID  
							                    	AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE
							                    	ORDER BY leankor__StartDateTime__c ASC NULLS FIRST LIMIT 9999];
    	                        smallestStartDateTime = tempRemoteKanbanCards[0].leankor__StartDateTime__C; */
    	                        //23/01/19
		    	                AggregateResult[] groupedResultsMin  =[SELECT Min(leankor__StartDateTime__c) minimumDate, Max(leankor__StartDateTime__c) maximumDate  FROM leankor__KanbanCard__c Where leankor__ValueStream__c =:cBoard.RealVSID  
							                    	AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
		    	                //smallestStartDateTime = (Datetime)groupedResultsMin[0].get('minimumDate'); 
                                //Added new parameter WorkWeek for WorkingWeekday calculation 
    	                        // calculating working days between two date                      
								//Use new logic to calculate day difference, no more recurring loop execution
		                        //dateDifference = daysBetweenExcludingWeekends((Datetime)groupedResultsMin[0].get('minimumDate'),StartDate,issevendays,workWeek);
                                //dateDifference = leankor.Util.getBusinessDays((Datetime)groupedResultsMin[0].get('minimumDate'), StartDate, issevendays, workWeek); 	
                                //dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMin[0].get('minimumDate')).date(), StartDate.date());                     
                                /*SS 12 March 2020*/
                                //To prevent TimeZone related issues, always use GMT method instead of user's local ,
                                //dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMin[0].get('minimumDate')).date(), StartDate.date());
                                dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMin[0].get('minimumDate')).dateGMT(), StartDate.dateGMT());
                                //Pratiksha : 29/May/2023 : Storing oldBoard min and Max dates to calculate the target board ProjectNode.
                                oldMinimumStart	= (Datetime)groupedResultsMin[0].get('minimumDate');	
                                oldMaximumStart	= (Datetime)groupedResultsMin[0].get('maximumDate');									                            
                            }else{
    	                             //clone project Due date   
    	                        FinalDate = (DateTime)JSON.deserialize(cBoard.FinalDate, DateTime.class); // DateTime.ValueOf(cBoard.FinalDate);
                                FinalDate = workWeek.getPreviousWorkingDay(FinalDate);
                                /*SS 20.08.2018*/
                                //Added filter for excluding soft deleted cards and vs
    	                        // getting largest datetime of card in source board
	                        	/*tempRemoteKanbanCards =[SELECT Id,leankor__DueDateTime__c FROM leankor__KanbanCard__c Where leankor__ValueStream__c =:cBoard.RealVSID  
	                        							AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE
	                        							ORDER BY leankor__DueDateTime__c DESC NULLS FIRST LIMIT 9999];
    	                        	largestDueDateTime = tempRemoteKanbanCards[0].leankor__DueDateTime__C; */    	                        	
	    	                       AggregateResult[] groupedResultsMax =[SELECT Max(leankor__DueDateTime__c) maximumDate, Min(leankor__StartDateTime__c) minimumDate FROM leankor__KanbanCard__c Where leankor__ValueStream__c =:cBoard.RealVSID  
	                        							AND leankor__IsRecordDeleted__c = FALSE AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE];
		                        
                              	// calculating working days between two date                        
								//Use new logic to calculate day difference, no more recurring loop execution
								//dateDifference = daysBetweenExcludingWeekends((Datetime)groupedResultsMax[0].get('maximumDate'),FinalDate,issevendays,workWeek);
                                //dateDifference = leankor.Util.getBusinessDays((Datetime)groupedResultsMax[0].get('maximumDate'), FinalDate, issevendays, workWeek); 
                                /*SS 12 March 2020*/
                                //To prevent TimeZone related issues, always use GMT method instead of user's local ,
                                //dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMax[0].get('maximumDate')).date(), FinalDate.date());
                                dateDifference = workWeek.getBusinessDays(((Datetime)groupedResultsMax[0].get('maximumDate')).dateGMT(), FinalDate.dateGMT());
                                //Pratiksha : 29/May/2023 : Storing oldBoard min and Max dates to calculate the target board ProjectNode.
                                oldMinimumStart	= (Datetime)groupedResultsMax[0].get('minimumDate');	
                                oldMaximumStart	= (Datetime)groupedResultsMax[0].get('maximumDate');
                            }
                        }
                        
                        //List<String> NewKanbanCards=new List<String>();
						List<realTimeController.Kanban> NewKanbanCards=new List<realTimeController.Kanban>();		
                        Map<String,Decimal> mapKanbanCardDifference = new Map<String,Decimal>();                                     
                        
                        //Changes for Reducing HeapSize - Shifted this query below
                        /*List<leankor__Dependency__c> DependList = [select Id,leankor__LagLeadDuration__c,leankor__LagLead__c,leankor__LagLeadUnit__c,leankor__GUID__c,leankor__ValueStream__c,leankor__KanbanCard__C,leankor__Predecessor__c,leankor__Predecessor__r.leankor__ValueStream__C,leankor__PredecessorType__c,leankor__Successor__c,leankor__Successor__r.leankor__ValueStream__C,leankor__SuccessorType__c from leankor__Dependency__c where (leankor__Predecessor__c IN :RemoteKanbanCards OR leankor__Successor__c IN :RemoteKanbanCards) AND leankor__Predecessor__r.leankor__ValueStream__C =:cBoard.RealVSID AND leankor__Successor__r.leankor__ValueStream__C =:cBoard.RealVSID limit 9999];*/ 
                        
                        //Pratiksha : 03/April/2023
                        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
                        KanbanController.KanbanCardConstraintViolation violationResult = new KanbanController.KanbanCardConstraintViolation();
                        //19/04/2023 : Changes added for getting fieldSet Map.
                        Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();
                        //Pratiksha: new variable added to store the calculated dates of card for calcation of projectNode.
                        List<DateTime> dateList = new List<DateTime>();
                        List<String> cardIdList = new List<String>{cBoard.RealVSID};
                        KanbanController.FieldSetRecord singleFieldSetRecord = KanbanController.getAllFieldsetAndFieldDataForCloning(cardIdList, 'leankor__ValueStream__c');
                        //21/Dec/2023 :updating isSuccessorRecalculate field for parent card.
                        Set<String> cardLinksIds =  new set<String>();
                        if(cBoard.LinkCloneKanbanCardID != null && cBoard.LinkCloneKanbanCardID != '')
                        {
                            cardLinksIds.add(cBoard.LinkCloneKanbanCardID);
                        }
                        for(leankor__KanbanCard__c RemoteKanban : RemoteKanbanCards){

                        	//SS 28.03.2018
                        	//modified to query Task records in a separate list and refactored code to fix Techical Debt  
                            //kanbanTaskList.addall(RemoteKanban.Tasks);
							
							//Feb 15 changes for Reducing heapSize
                            /*if(mapKBTasks.get(RemoteKanban.Id) != null && mapKBTasks.get(RemoteKanban.Id).size()>0){
                            	kanbanTaskList.addall(mapKBTasks.get(RemoteKanban.Id));
                            }*/
                            
                            //Pratiksha : 21/09/2021 Changes for Clone KanbanCard's Sticker on Project cloning...
                            if( CloneProjectAction.isClonedProject == true && cBoard.StickerVerb == true ){
                                cloneProjectAction.kanbanCardIdsForStickerStatic.add(RemoteKanban.Id);
                            }
                            /*else{
                                kanbanCardIdListForTask.add(RemoteKanban.Id); 
                            }*/

                            kanbanCardIdListForTask.add(RemoteKanban.Id);
							Integer startDateConstraintDifference = 0;
                            Integer dueDateconstraintDifference = 0;
                            String tempID = templateIDs.get(RemoteKanban.leankor__KanbanCardTemplate__c);
                            String tempConstraintType;
                            Datetime tempConstraintDate;
                            //Changes : Check constraint setting enable or not.
                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                                for(leankor__ScheduleMode__c schedulemode : RemoteKanban.leankor__ScheduleModes__r){
                                    tempConstraintType = schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c;
                                    tempConstraintDate = schedulemode.leankor__ConstraintDateTime__c;
                                }
                            }
							//Need to manage Time Portion in Dates of clonned card.
                            //tempstartDateTime = RemoteKanban.leankor__StartDateTime__c;
                            //tempDueDateTime = remoteKanban.leankor__DueDateTime__c; 
								
							//If StartDate is not null then use time value from StartDate else pick from FinalDate
                            if(StartDate!=null){
                            	//tempstartDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__StartDateTime__c.dateGmt(),StartDate.timeGmt());
                                // 11/04/2023 : Time will be Cloned while cloning the card
                                tempstartDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__StartDateTime__c.dateGmt(),RemoteKanban.leankor__StartDateTime__c.timeGmt());
                                //tempDueDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__DueDateTime__c.dateGmt(),StartDate.timeGmt());
                                // 11/04/2023 : Time will be Cloned while cloning the card
                                tempDueDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__DueDateTime__c.dateGmt(),RemoteKanban.leankor__StartDateTime__c.timeGmt()); 

                            } else {
                                //tempstartDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__StartDateTime__c.dateGmt(),FinalDate.timeGmt());
                                // 11/04/2023 : Time will be Cloned while cloning the card
                                tempstartDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__StartDateTime__c.dateGmt(),RemoteKanban.leankor__StartDateTime__c.timeGmt());
                               // tempDueDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__DueDateTime__c.dateGmt(),FinalDate.timeGmt()); 
                               // 11/04/2023 : Time will be Cloned while cloning the card
                               tempDueDateTime = DateTime.newInstanceGmt(RemoteKanban.leankor__DueDateTime__c.dateGmt(),RemoteKanban.leankor__StartDateTime__c.timeGmt()); 

                            }
                                                                       
                            //issevendays is true mean user cloning board with sevendayworkweek
                            if(!issevendays)
                            {   
                            	//remove for loop from here and using " for loop "  inside method nextBusinessDate                                                
                                if(dateDifference > 0) // difference is positive than we have plus differences into date
                                {                                
                                    //tempstartDateTime = nextBusinessDate(tempstartDateTime,dateDifference,true, workWeek);
                                    //tempDueDateTime = nextBusinessDate(tempDueDateTime,dateDifference,true, workWeek);     
                                    if(Isfromstartdate){
                                        tempstartDateTime = workWeek.nextBusinessDate(tempstartDateTime, dateDifference);
                                    }else{
                                        tempDueDateTime = workWeek.nextBusinessDate(tempDueDateTime, dateDifference);
                                    }  
                                    
                                }else{ // difference is negative than we have minus differences into date                                
                                    //tempstartDateTime = nextBusinessDate(tempstartDateTime,dateDifference,false, workWeek);
                                    //tempDueDateTime = nextBusinessDate(tempDueDateTime,dateDifference,false, workWeek);     
                                    if(Isfromstartdate){
                                        tempstartDateTime = workWeek.nextBusinessDate(tempstartDateTime, dateDifference);
                                    }else{
                                        tempDueDateTime = workWeek.nextBusinessDate(tempDueDateTime, dateDifference); 
                                    }                                                                                                   
                                }  

                            }else{

								//Use updated DateTime values
                               //tempstartDateTime = RemoteKanban.leankor__StartDateTime__C + dateDifference;
                               //tempDueDateTime = remoteKanban.leankor__DueDateTime__C + dateDifference;
                                if(Isfromstartdate){
                                    tempstartDateTime = workWeek.nextBusinessDate(tempstartDateTime, dateDifference);
                                }else{
                                    tempDueDateTime = workWeek.nextBusinessDate(tempDueDateTime, dateDifference); 
                                }                       
                            }  
                            startDateConstraintDifference = tempConstraintDate != null ? (Date.newInstance(RemoteKanban.leankor__StartDateTime__c.year(),RemoteKanban.leankor__StartDateTime__c.month(),RemoteKanban.leankor__StartDateTime__c.day())).daysBetween(Date.newInstance(tempConstraintDate.year(),tempConstraintDate.month(),tempConstraintDate.day())) : 0;
                            dueDateconstraintDifference = tempConstraintDate != null ? (Date.newInstance(RemoteKanban.leankor__DueDateTime__c.year(),RemoteKanban.leankor__DueDateTime__c.month(),RemoteKanban.leankor__DueDateTime__c.day())).daysBetween(Date.newInstance(tempConstraintDate.year(),tempConstraintDate.month(),tempConstraintDate.day())) : 0;

                            mapKanbanCardDifference.put(RemoteKanban.Id,dateDifference);
                            
                            
                                // yj : 06 Nov. 2017 Checking user is active or not.no Need to code here
                                // NewKanban.OwnerId = allUserMap.get(RemoteKanban.OwnerId).IsActive ? RemoteKanban.OwnerId : UserInfo.getUserId();
                                //NewKanban.OwnerId = allUserMap.containsKey(RemoteKanban.OwnerId) ? UserInfo.getUserId() : RemoteKanban.OwnerId;
                                // yj : 06 Nov. 2017
                                //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar While Cloning the KanbanCard from UI and API also.
                            leankor.RealTimeController.Kanban NewKanban = new leankor.RealTimeController.Kanban();
                            NewKanban.Id = RemoteKanban.Id;
                            NewKanban.IsSuccessorRecalculate =  RemoteKanban.leankor__IsSuccessorRecalculate__c;
                                Set<String> weekDays = new Set<String>();
                                if(issevendays){
                                    //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar
                                    if(RemoteKanban.leankor__Monday__c == false && RemoteKanban.leankor__Tuesday__c == false && RemoteKanban.leankor__Wednesday__c == false &&  RemoteKanban.leankor__Thursday__c == false &&  RemoteKanban.leankor__Friday__c == false &&  RemoteKanban.leankor__Saturday__c == false &&  RemoteKanban.leankor__Sunday__c == false){
                                        NewKanban.Monday = true;
                                        NewKanban.Tuesday = true;
                                        NewKanban.Wednesday = true;
                                        NewKanban.Thursday = true;
                                        NewKanban.Friday = true;
                                        NewKanban.Saturday = true;
                                        NewKanban.Sunday = true;
                                    }else{
                                        NewKanban.Monday = RemoteKanban.leankor__Monday__c;
                                        NewKanban.Tuesday = RemoteKanban.leankor__Tuesday__c;
                                        NewKanban.Wednesday = RemoteKanban.leankor__Wednesday__c;
                                        NewKanban.Thursday = RemoteKanban.leankor__Thursday__c;
                                        NewKanban.Friday = RemoteKanban.leankor__Friday__c;
                                        NewKanban.Saturday = RemoteKanban.leankor__Saturday__c;
                                        NewKanban.Sunday = RemoteKanban.leankor__Sunday__c;
                                        NewKanban.WeekCalendar = RemoteKanban.leankor__WeekCalendar__c;
                                        NewKanban.IsSuccessorRecalculate = (dateDifference !=0 ) ? true : RemoteKanban.leankor__IsSuccessorRecalculate__c;

                                        weekDays.add(NewKanban.Monday == false ? 'Mon' : 'false');
                                        weekDays.add(NewKanban.Tuesday == false ? 'Tue' : 'false');
                                        weekDays.add(NewKanban.Wednesday == false ? 'Wed' : 'false');
                                        weekDays.add(NewKanban.Thursday == false ? 'Thu' : 'false');
                                        weekDays.add(NewKanban.Friday == false ? 'Fri' : 'false');
                                        weekDays.add(NewKanban.Saturday == false ? 'Sat' : 'false');
                                        weekDays.add(NewKanban.Sunday == false ? 'Sun' : 'false');
                                    }
                                }    
                                Util.weekDays = weekDays;
                                NewKanban.OwnerId = RemoteKanban.OwnerId;
                                NewKanban.UrlLink =RemoteKanban.leankor__UrlLink__c;
                                NewKanban.GUID = RemoteKanban.Id+'-'+tempID+'-k';
                                NewKanban.Title= RemoteKanban.leankor__Title__c;
                                NewKanban.Name = RemoteKanban.Name;
                                NewKanban.Top = RemoteKanban.leankor__Top__c;
                                NewKanban.Bottom = RemoteKanban.leankor__Bottom__c;
                                NewKanban.Left = RemoteKanban.leankor__Left__c;
                                NewKanban.Width = RemoteKanban.leankor__Width__c;
                                NewKanban.Height = RemoteKanban.leankor__Height__c;
                                NewKanban.X = RemoteKanban.leankor__X__c;
                                NewKanban.Y = RemoteKanban.leankor__Y__c;
                                NewKanban.ValueStream = cBoard.VSID;
                                NewKanban.TemplateID = tempID;
                                NewKanban.point = RemoteKanban.leankor__Point__c;
                                NewKanban.EffortRemaining = integer.valueof(RemoteKanban.leankor__EffortRemaining__c);
                                NewKanban.EstimatedDuration = RemoteKanban.leankor__EstimatedDuration__c;
                                NewKanban.Color = RemoteKanban.leankor__Color__c;  // EjB7: added color and JSONDefinition
                                // Date: 20/05/2019
                                // To clone the custome field set when cloneCustomFields is checked.
                               if(cBoard.cloneCustomFields == null || cBoard.cloneCustomFields){
	                                NewKanban.JSONDefinition = RemoteKanban.leankor__JSONDefinition__c;
	                                NewKanban.JSONData = RemoteKanban.leankor__JSONData__c;
                                }else{
                                	NewKanban.JSONDefinition = '{}';
                                	NewKanban.JSONData = '{}';
                                }
                                //NewKanban.DueDate = tempDueDateTime;
                                if(Util.weekDays.size() > 1) {
                               	NewKanban.DueDate = workWeek.getNextWorkingDay(tempDueDateTime);
                                    NewKanban.StartDate = workWeek.getNextWorkingDay(tempStartDateTime);
                                } else {
                                    NewKanban.DueDate = tempDueDateTime;
                                    NewKanban.StartDate = tempStartDateTime;
                                }
                               	
                                dateList.add((String.isNotBlank(cBoard.projectBoardLaunchDate)|| String.isNotBlank(cBoard.FinalStartDate)) ? tempStartDateTime : tempDueDateTime);
                                //NewKanban.StartDate = tempStartDateTime;
                               
                                //NewKanban.StartDate = workWeek.getPreviousWorkingDay(tempStartDateTime);
                                NewKanban.CardID = RemoteKanban.leankor__CardID__c; 
                                NewKanban.AcceptanceCriteria = RemoteKanban.leankor__AcceptanceCriteria__c; 
                                NewKanban.DurationUnits = RemoteKanban.leankor__DurationUnits__c;  // EjB11: added duration units picklist string
                                NewKanban.Priority = Integer.ValueOF(RemoteKanban.leankor__Priority__c); //EjB14: added priority
                                NewKanban.HarveyBall = String.ValueOF(RemoteKanban.leankor__PercentComplete2__c);//field for Harvay Ball in percentage 
                                NewKanban.Order = (RemoteKanban.leankor__Order__C == null ? 0 : Integer.ValueOF(RemoteKanban.leankor__Order__c));
                                NewKanban.DateColor = RemoteKanban.leankor__DateColor__c; //field for foreground color of Date value  
                                NewKanban.Description = RemoteKanban.leankor__DescriptionLong__c;
                                //RS 02/11/2018 After cloning board milestone of cv should not be linked to default linked activity  
                            	NewKanban.ValueStreamCardLink =  (cBoard.LinkCloneVSID == '' ? RemoteKanban.leankor__ValueStreamCardLink__c : (cBoard.LinkCloneKanbanCardID == '' ? null : (RemoteKanban.RecordType.Name != 'MileStoneCard' && RemoteKanban.leankor__valuestream__r.leankor__boardtype__c != 'UberBoard') ? cBoard.LinkCloneKanbanCardID : null));  //RemoteKanban.leankor__ValueStreamCardLink__c; 
                                //NewKanban.ValueStreamCardLink =  (cBoard.LinkCloneVSID == '' ? RemoteKanban.leankor__ValueStreamCardLink__c : (cBoard.LinkCloneKanbanCardID == '' ? null : cBoard.LinkCloneKanbanCardID));  //RemoteKanban.leankor__ValueStreamCardLink__c; 
                                NewKanban.ValueStreamLinkID = (cBoard.LinkCloneVSID == '' ? RemoteKanban.leankor__ValueStreamLink__c : cBoard.LinkCloneVSID);//RemoteKanban.leankor__ValueStreamLink__c ; 
                                NewKanban.Account = RemoteKanban.leankor__Account__c;
                                NewKanban.Contact = RemoteKanban.leankor__Contact__c;
                                NewKanban.CaseID = RemoteKanban.leankor__Case__c;
                                NewKanban.ZoneID = (ZoneGUIDs.containsKey(RemoteKanban.leankor__ZoneGUID__C) == true ? ZoneGUIDs.get(RemoteKanban.leankor__ZoneGUID__c) : '');
                                NewKanban.MCForceID =(NewMCForceIDs.containsKey(RemoteKanban.leankor__MasterContainer__c) == true ? NewMCForceIDs.get(RemoteKanban.leankor__MasterContainer__c):'');
                                NewKanban.SWForceID =(NewSWForceIDs.containsKey(RemoteKanban.leankor__Swimlane__c) == true ? NewSWForceIDs.get(RemoteKanban.leankor__Swimlane__c):'');
                                NewKanban.ZoneForceID =(NewZoneForceIDs.containsKey(RemoteKanban.leankor__Zone__c) == true ? NewZoneForceIDs.get(RemoteKanban.leankor__Zone__c):'');
                                NewKanban.Opportunity = RemoteKanban.leankor__Opportunity__C;
                                NewKanban.BoardType = RemoteKanban.leankor__valuestream__r.leankor__boardtype__c;
                                NewKanban.OnBudget = RemoteKanban.leankor__OnBudget__c;
                                NewKanban.OnQuality = RemoteKanban.leankor__OnQuality__c;
                                NewKanban.OnTime = RemoteKanban.leankor__OnTime__c; 
                                NewKanban.isAtRisk = RemoteKanban.leankor__IsAtRisk__c;
                                NewKanban.isOnHold = RemoteKanban.leankor__IsOnHold__c;
                                
                                if(RemoteKanban.RecordType.Name == 'ActivityCard')
                                {
                                    NewKanban.ItemType = RemoteKanban.RecordType.Name;
                                }else if(RemoteKanban.RecordType.Name == 'MileStoneCard')
                                {
                                    NewKanban.ItemType = RemoteKanban.RecordType.Name;
                                }else if(RemoteKanban.RecordType.Name == 'FolderCard')
                                {
                                    NewKanban.ItemType = RemoteKanban.RecordType.Name;
                                }
                                //NewKanban.ItemType = RemoteKanban.RecordtypeId;
		               
								// Calculation according to duration unit
                                Integer ED = integer.valueof(NewKanban.EstimatedDuration);
                                if(NewKanban.DurationUnits == 'Hours'){
                                    if(math.mod(ED,8) > 0){
                                        ED= Integer.valueof(ED/8) + 1;
                                    }else{
                                        ED= Integer.valueof(ED/8);
                                    }
                                }else if(NewKanban.DurationUnits == 'Years'){
                                    ED= Integer.valueof(ED*365);
                                }else if(NewKanban.DurationUnits == 'Months'){
                                    ED= Integer.valueof(ED*20);
                                }else if(NewKanban.DurationUnits == 'Minutes'){
                                    integer temphours;
                                    if(math.mod(ED,60) >0 ){
                                        temphours= Integer.valueof(ED/60) + 1;
                                    }else{
                                        temphours= Integer.valueof(ED/60);
                                    }
                                    if(math.mod(temphours,8) >0){
                                        ED= Integer.valueof(temphours/8) + 1;
                                    }else{
                                        ED= Integer.valueof(temphours/8);
                                    }
                                }else if(NewKanban.DurationUnits == 'Weeks'){
                                    ED= Integer.valueof(ED*5);
                                }

                                if(!Isfromstartdate){
                                    
                                    Datetime tempcalstartdate = NewKanban.DueDate;
                                    if(NewKanban.DurationUnits == 'Years'){
                                        tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(NewKanban.EstimatedDuration));
                                        tempcalstartdate = tempcalstartdate +1 ;
                                    }else if(NewKanban.DurationUnits == 'Months'){
                                        tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(NewKanban.EstimatedDuration));
                                        tempcalstartdate = tempcalstartdate +1 ;
                                    }else{                                                         
                                        // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                                        ED = (ED == 0 ? 1: ED);                                                    
                                        tempcalstartdate = workWeek.nextBusinessDate(tempcalstartdate, -(ED-1));      
                                        /*for(integer i = 1 ;i< ED;i++ ){
                                            tempcalstartdate = tempcalstartdate-1;
                                            //Calculate week days according to first day of week                                        
    									tempcalstartdate = Util.readPreviousWorkingDateTime(workWeek, tempcalstartdate);
                                        }*/
                                    }
                                    NewKanban.StartDate = workWeek.getPreviousWorkingDay(tempcalstartdate);
                                }else if(Isfromstartdate){
                                    Datetime tempcalDuedate = NewKanban.StartDate;
                                    if(NewKanban.DurationUnits == 'Years'){
                                        tempcalDuedate = tempcalDuedate.addYears(integer.valueof(NewKanban.EstimatedDuration));
                                        tempcalDuedate = tempcalDuedate -1 ;
                                    }else if(NewKanban.DurationUnits == 'Months'){
                                        tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(NewKanban.EstimatedDuration));
                                        tempcalDuedate = tempcalDuedate -1 ;
                                    }else{
                                        // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                                        ED = (ED == 0 || ED == Null ? 1: ED); 
                                        tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, ED-1);
                                        /*for(integer i = 1 ;i<ED;i++ ){
                                            tempcalDuedate = tempcalDuedate+1;
                                            //Calculate week days according to first day of week                                        
    									    tempcalDuedate = Util.readNextWorkingDateTime(workWeek, tempcalDuedate);
                                            }*/
                                    }
                                    NewKanban.DueDate = workWeek.getNextWorkingDay(tempcalDuedate);                    
                                }      
                            // 10.12.2016 for clone project : stop previous kanban card update
                            NewKanban.checkcloneProject = cBoard.checkcloneproject == '' ? '' :cBoard.checkcloneproject ;
                            
                            //Start****SS 05.07.2018*****//
                            //mapcardduedate.put(RemoteKanban.Id,NewKanban.DueDate);
                            //mapcardstartedate.put(RemoteKanban.Id,NewKanban.StartDate);
                            /**Note - Using TempFinalDate, tempcalstartdate variables for getting TskActivityDate also replacing values in 
                            DueDate,StartDate for card. So New date variables are created using year,Month, Day**/
                            Date tempCardDueDate = Date.newInstance(NewKanban.DueDate.year(), NewKanban.DueDate.month(), NewKanban.DueDate.day());
                            Date tempCardStartdate = Date.newInstance(NewKanban.StartDate.year(), NewKanban.StartDate.month(), NewKanban.StartDate.day());
                            
                            mapcardduedate.put(RemoteKanban.Id,tempCardDueDate);
                            mapcardstartedate.put(RemoteKanban.Id,tempCardStartdate);
                            //End****SS 05.07.2018*****//             
                                     
                            // 22.12.2016 yj for clone schedule and assignment
                            NewKanban.schedulemodeList = RemoteKanban.leankor__ScheduleModes__r;
    	                    NewKanban.resourceAssignmentList = RemoteKanban.leankor__ResourceAssignments__r;
                            // 22.12.2016 yj for clone schedule and assignment
                            
                            // YJ 15.11.2017 cloning harveyballdonedate and PromiseCompletionDate
                            NewKanban.HarveyBallDoneDate = RemoteKanban.leankor__HarveyBallDoneDate__c;
                            NewKanban.PromiseCompletionDate = RemoteKanban.leankor__PromiseCompletionDate__c;
                                
                            // ------------- Date :17/10/19 changes related to clone custom field -----------
                            if(cBoard.cloneCustomFields == true){
                                if((cBoard.BoardType == 'UberBoard' || cBoard.BoardType == 'Kanban Board')){
                                    Map<String, Object> fieldsToValue = RemoteKanban.getPopulatedFieldsAsMap();
                                    NewKanban.kanbanCustomField = new leankor__KanbanCard__c();	// Initialization of inner class variable.
                                    //for(String singleFieldName : FieldsName){
                                    for(String singleFieldName : singleFieldSetRecord.allFields){
                                        if(fieldMapKanbanCardForClone.containsKey(singleFieldName.toLowerCase())){
                                            //if(RemoteKanban.getPopulatedFieldsAsMap().containsKey(singleFieldName)){
                                                if(fieldsToValue.containsKey(singleFieldName)){
                                                NewKanban.kanbanCustomField.put(singleFieldName, RemoteKanban.get(singleFieldName)); 
                                            } 					   	
                                        }
                                    }                                
                                }
                                else{
                                    NewKanban.kanbanCustomField = new leankor__KanbanCard__c();	// Initialization of inner class variable.							                                 
                                    if(String.isNotBlank(RemoteKanban.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)){// Checking  fieldset on the category.
                                        // Get fields which is added in fieldset.	
                                        //19/04/2023 : If any fieldSet is already deleted then we were facing ("Attempt to de-reference a null object") so we are preventing by adding the condition.
                                        if(fieldSetMap.get(String.valueOf(RemoteKanban.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)) != null){
                                            //for(Schema.FieldSetMember fields : fieldSetMap.get(String.valueOf(RemoteKanban.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)).getFields()){
                                            for(String  fields : singleFieldSetRecord.fieldSetAndFields.get(String.valueOf(RemoteKanban.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c))){
                                                // Assign the Custom Field values of a cards to clone.
                                                if(fieldMapKanbanCardForClone.containsKey(fields.toLowerCase())){						   								   										   			    
                                                    NewKanban.kanbanCustomField.put(fields, RemoteKanban.get(fields));     					   	
                                                } 						   		           							
                                            } 
                                        }   
                                    }
                                }                            
                            }
                            //----------------------------------------------------------------------------------
                            //Date : 22/10/19 using wrapper class instance instead of Serialization.
                            //NewKanbanCards.add(JSON.Serialize(NewKanban));
                            //RS 28/11/2019 Added Owner.IsActive in object 
                            NewKanban.ownerIsActive = RemoteKanban.Owner.IsActive;
                            // NewKanban.ConstraintDate =  (RemoteKanban.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null)?RemoteKanban.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                            // NewKanban.ConstraintType =  (RemoteKanban.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r != null)?scheduleConstraints.get(RemoteKanban.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c).Id:null;
                            /**setting Constraint values null */
                            NewKanban.ConstraintDate = null;
                            NewKanban.ConstraintType = null;
                            /**calculating the constraintDates with startDate/dueDate if constraint type is not null or blank*/
                            //Changes : Check constraint setting enable or not.
                            if (String.isNotBlank(tempConstraintType) && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
								//Pratiksha : 02/02/2022 - Constraint date should be null in case of ASAP & ALAP.
                                NewKanban.ConstraintType = scheduleConstraints.get(tempConstraintType).Id;
                                NewKanban.ConstraintDate = (new List<String>{'aslateaspossible','assoonaspossible'}.contains(tempConstraintType)) ? null : (new List<String>{'startnoearlierthan','startnolaterthan','muststarton'}.contains(tempConstraintType)) ? NewKanban.StartDate + startDateConstraintDifference : NewKanban.DueDate + dueDateconstraintDifference;
                            }
                            //Pratiksha : 03/April/2023 : checking constraint While cloning board the with updating links.
                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS && String.isNotBlank(cBoard.LinkCloneVSID) && String.isNotBlank(cBoard.LinkCloneKanbanCardID) && RemoteKanban.RecordType.Name != 'MileStoneCard' && RemoteKanban.leankor__valuestream__r.leankor__boardtype__c != 'UberBoard'){
                                KanbanCard checkCard = new KanbanCard();
                                checkCard.Id = NewKanban.Id;
                                checkCard.name = NewKanban.Name;
                                checkCard.valueStream = cBoard.VSID;//CardsLog.leankor__ValueStream__c;
                                checkCard.startDateTime = NewKanban.StartDate;
                                checkCard.dueDateTime = NewKanban.DueDate;
                                checkCard.isUpdateValueStreamCardLink = true;
                                checkCard.valueStreamLink = NewKanban.ValueStreamLinkID;
                                checkCard.valueStreamCardLink = NewKanban.ValueStreamCardLink;
                                cardsToCheck.add(checkCard);
                            }
                           NewKanbanCards.add(NewKanban);
                           Util.weekDays.clear();
                        }
                        //Pratiksha : 29/May/2023 : Changes to calculate the target board ProjectNode.
                        dateList.sort();
                        Integer difference;
                        if(realtimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                            if(RemoteKanbanCards[0].leankor__ValueStream__r.leankor__ScheduleBackward__c == true){
                                difference = workWeek.getBusinessDays(oldMaximumStart.dateGMT(), oldProjectBoardEndDate.dateGMT());
                                newProjectBoardEndDate = workWeek.nextBusinessDate(dateList[dateList.size()-1], difference);
                            }else{
                                difference = workWeek.getBusinessDays(oldMinimumStart.dateGMT(), oldProjectBoardStartDate.dateGMT());
                                newProjectBoardStartDate = workWeek.nextBusinessDate(dateList[0], difference );
                            }
                        }
                        
                        // Cleared to reduce the heap size
                        ZoneGUIDs.clear();
                        NewMCForceIDs.clear();
                        NewSWForceIDs.clear();
						NewZoneForceIDs.clear();
                        templateIDs.clear();
                        fieldMapKanbanCardForClone.clear();
                        
                        //Pratiksha : 03/April/2023 :checking constraint While cloning board the with updating links.
                        if(!cardsToCheck.isEmpty()){
                            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                                violationResult = KanbanController.getConstraintViolation(cardsToCheck, false);
                            }
                            if(!violationResult.isEmpty()){
                                System.debug('Constraint is Violated.....');
                                leankor.RealTimeController.DirectLinkCardLog constraintViolation = new leankor.RealTimeController.DirectLinkCardLog();
                                constraintViolation.constraintCardName = violationResult.kanbanCardConstraint.kanbanCardRecord.current.name;
                                constraintViolation.boardName = violationResult.kanbanCardConstraint.kanbanCardRecord.current.boardName;
                                constraintViolation.currentCardName = violationResult.kanbanCardRecord.current.name;
                                constraintViolation.constraintDescription = violationResult.kanbanCardConstraint.scheduleModeRecord.constraintDescription;
                                constraintViolation.constraintCardId = violationResult.kanbanCardConstraint.kanbanCardRecord.current.Id;
                                constraintViolation.violatedBoardType = violationResult.kanbanCardConstraint.kanbanCardRecord.current.boardType;
                                constraintViolation.violatedBoardId = violationResult.kanbanCardConstraint.kanbanCardRecord.current.valueStream;
                                constraintViolation.projectID = violationResult.kanbanCardConstraint.kanbanCardRecord.current.projectID;
                                throw new Util.LeanException(Json.serialize(constraintViolation));
                            }
                        }
                        
						//Query before createkanbanCard() because we are clearing old record values inside the method from list
						List<leankor__Dependency__c> DependList = [SELECT Id, leankor__LagLead__c, leankor__LagLeadUnit__c, leankor__GUID__c, leankor__ValueStream__c, leankor__KanbanCard__C, leankor__Predecessor__c, leankor__Predecessor__r.leankor__ValueStream__C, leankor__PredecessorType__c, leankor__Successor__c, leankor__Successor__r.leankor__ValueStream__C, leankor__SuccessorType__c FROM leankor__Dependency__c WHERE (leankor__Predecessor__c IN :RemoteKanbanCards OR leankor__Successor__c IN :RemoteKanbanCards) AND leankor__Predecessor__r.leankor__ValueStream__C =:cBoard.RealVSID AND leankor__Successor__r.leankor__ValueStream__C =:cBoard.RealVSID LIMIT 9999];
                        System.debug('Original/First Batch Board Kanban Cards Size => '+NewKanbanCards.size());
                        //RS 28/11/2019 Removed allUserMap variable
                        //remoteKanbanCards = leankor.realTimeController.createKanbanCard(cBoard.VSID, NewKanbanCards, true,allUserMap);
                        remoteKanbanCards = leankor.realTimeController.createKanbanCard(cBoard.VSID, NewKanbanCards, true);
                        NewKanbanCards.clear(); // To reduce the heap size.
                        //21/Dec/2023 :updating isSuccessorRecalculate field for parent card.
                        leankor.RealTimeController.updateIsSuccessorRecalculate(cardLinksIds);
                        
						
                        //Map<String,String> mapKanbanCard = new Map<String,String>();
                        
                        for(leankor__KanbanCard__c kanban : RemoteKanbanCards){ 
                            String oldKanbanID = (kanban.leankor__GUID__C).SubStringBefore('-');
                            CloneProjectAction.mapWithOldKanbanCardStatic.put(oldKanbanID, kanban.Id);
                            mapWithOldKc.put(oldKanbanID, kanban.Id);
                        }
                     
                        //Start of clone Dependency.                                                                             
                        cloneDependency(cBoard,RemoteKanbanCards ,DependList,mapWithOldKc);
                                        
                        //15 Feb Changes for Reducing HeapSize
                        DependList.clear();
                        
                        List<Task> kanbanTaskList = new List<Task>();
                        if(cBoard.TaskVerb == true){
                        	//RS 28/11/2019 Added Owner.IsActive to query
                        	kanbanTaskList= [SELECT 
                        							ActivityDate,
                        							Description,
                        							Id,
                        							OwnerId,
                        							Priority,
                        							Status,
                        							Subject,
                        							WhatId,
                        							Owner.IsActive 
                        						FROM Task 
                        						where What.Type = 'leankor__KanbanCard__c'
                        						AND WhatId IN: kanbanCardIdListForTask AND IsDeleted = false 
                        						Order By CreatedDate ASC NUllS LAST 
                        						limit 9999 All Rows];
                        }
                        kanbanCardIdListForTask.clear();
                        
                        //Start of Clone Task
                        if(cBoard.TaskVerb == true){              
                            if(kanbanTaskList.Size() > 0 ){
                                List<Task> TaskList = new List<Task>();
                                for(Task t : kanbanTaskList){
                                    if(mapWithOldKc.containsKey(t.WhatID) == true){
                                        Task Tsk = new Task();
                                            Tsk.Priority    =   t.Priority;
                                            //RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries
                                            //Tsk.OwnerID = allUserMap.containsKey(t.OwnerID) ? UserInfo.getUserId() : t.OwnerID;
                                            Tsk.OwnerID = t.Owner.IsActive ? t.OwnerId : UserInfo.getUserId() ;
                                            Tsk.Subject     =   (t.Subject == null ? '' :t.Subject);
                                            Tsk.Status      =   t.Status;
    										Tsk.ActivityDate=  (t.ActivityDate == null ?(mapCardDueDate.get(t.WhatId)) :(t.ActivityDate+(Integer.ValueOf(mapKanbanCardDifference.get(t.WhatId)))));                                            
    										datetime TskDuedate = Datetime.newInstance(Tsk.ActivityDate.year(),Tsk.ActivityDate.month(), Tsk.ActivityDate.day(), 1, 1, 1);
                                            
                                            if(!isSevenDays){
                                                if(isFromStartDate){
                                                    //Get Working days escaping non working days for Task
                                                    Tsk.ActivityDate = Util.readNextWorkingDate(workWeek,TskDuedate,Tsk.ActivityDate);
    	                                        }else{
    											    Tsk.ActivityDate = Util.readPreviousWorkingDate(workWeek,TskDuedate,Tsk.ActivityDate);
    											}
    		                                }
                                            
                                            if(Tsk.ActivityDate > mapcardduedate.get(t.WhatId) && newVStaskchecker){
                                                Tsk.ActivityDate = mapcardduedate.get(t.WhatId);
                                            }else if (Tsk.ActivityDate < mapcardstartedate.get(t.WhatId) && newVStaskchecker){
                                                Tsk.ActivityDate = mapcardstartedate.get(t.WhatId);
                                            }
                                            //End**** SS 05.07.2018*****//
                                            Tsk.WhatID      =   mapWithOldKc.get(t.WhatID);
                                            Tsk.Description =   (t.Description == null ? '' : t.Description);
                                        TaskList.add(Tsk);
                                    }
                                }
                                //18Feb Changes for Reducing HeapSize
								kanbanTaskList.clear();
                                
                                Database.insert(TaskList,true);
                                    List<FeedItem> Feeds=new List<FeedItem>();
                                    for(Task Tsk:TaskList){
                                        FeedItem Post=new FeedItem();
                                        Post.ParentID=Tsk.Id;
                                        Post.Type='CreateRecordEvent';
                                        Feeds.add(Post);
                                    }
                                    insert Feeds;
                                }
                            }
                            //End of Task clone
                        }
                    }
                // Ashutosh : 27/10/2021 : Updating target ValueStream with ProjectBoardStartDateTime and ProjectBoardEndDateTime
                AggregateResult[] kanbanCardDates = [Select MAX(leankor__DueDateTime__c) maximumDueDate,
                                                                MIN(leankor__StartDateTime__c) minimumStartDate 
                                                            From leankor__kanbanCard__c 
                                                            Where leankor__Valuestream__c =: cBoard.VSID ];
                leankor__ValueStream__c valueStreamWithNewDates = new leankor__ValueStream__c();
                valueStreamWithNewDates.Id = cBoard.VSID;
                // Update minimum Activity and maximum activity dates as ProjectBoardStartdate and ProjectBoardEndDate.
                // 11/04/2023 : Time will be Cloned while cloning the Board
                if(kanbanCardDates[0].get('minimumStartDate') != null && kanbanCardDates[0].get('maximumDueDate') != null){
                    valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = newProjectBoardStartDate != null ? newProjectBoardStartDate  : DateTime.newInstanceGmt(workWeek.getNextWorkingDay((Datetime)kanbanCardDates[0].get('minimumStartDate')).dateGMT(),cBoard.oldStartDateTime.timeGMT());
                    valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = newProjectBoardEndDate != null ? newProjectBoardEndDate : DateTime.newInstanceGmt(workWeek.getNextWorkingDay((Datetime)kanbanCardDates[0].get('maximumDueDate')).dateGMT(),cBoard.oldEndDateTime.timeGMT());
                }
                // Update launch date Or startdate as ProjectBoardStartdate and ProjectBoardEndDate on Cloning with startDate or launchDate, If board doesn't contains any activity.
                // 11/04/2023 : Time will be Cloned while cloning the card
                else if(!String.isBlank(cBoard.FinalStartDate)){
                    DateTime ProjectBoardFinalStartDate = (DateTime)JSON.deserialize(cBoard.FinalStartDate,DateTime.class);
                    valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = DateTime.newInstanceGmt(ProjectBoardFinalStartDate.dateGMT(),cBoard.oldStartDateTime.timeGMT()); 
                    valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = DateTime.newInstanceGmt(ProjectBoardFinalStartDate.dateGMT(),cBoard.oldEndDateTime.timeGMT());
                }
                // Update TargetDate(DueDate) as ProjectBoardStartdate and ProjectBoardEndDate on Cloning with DueDate, If board doesn't contains activity.
                // 11/04/2023 : Time will be Cloned while cloning the card
                else if(!String.isBlank(cBoard.FinalDate)){
                    DateTime ProjectBoardFinalDate = (DateTime)JSON.deserialize(cBoard.FinalDate,DateTime.class);
                    //valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = (DateTime)JSON.deserialize(cBoard.FinalDate,DateTime.class); 
                    //valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = (DateTime)JSON.deserialize(cBoard.FinalDate,DateTime.class);
                    valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = DateTime.newInstanceGmt(ProjectBoardFinalDate.dateGMT(),cBoard.oldStartDateTime.timeGMT()); 
                    valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = DateTime.newInstanceGmt(ProjectBoardFinalDate.dateGMT(),cBoard.oldEndDateTime.timeGMT());
                }
                // Update currentDate if system doesn't find any of the above dates and If board doesn't contains activity.
                else{
                	//28/06/2022 : Update startdate and endDate according to saturday/sunday and blackouts
                    valueStreamWithNewDates.leankor__ProjectBoardStartDateTime__c = Util.readNextWorkingDateTime(workWeek,System.now()); 
                    valueStreamWithNewDates.leankor__ProjectBoardEndDateTime__c = Util.readNextWorkingDateTime(workWeek,System.now());
                }
                update valueStreamWithNewDates;
                valueStreamWithNewDates.clear();


                /**Start of Clone Sticker*/
                if(cBoard.StickerVerb == true && cBoard.BoardType != 'UberBoard')
                {
                    cloneStickers(cBoard);
                }
                /**Start of Clone Markers*/
                if(cBoard.MarkerVerb == true && cBoard.BoardType != 'UberBoard')
                {
                    cloneMarkers(cBoard);
                    
                }//End of If  
                /**Start of Clone Charts*/   
                if(cBoard.ChartVerb == true && cBoard.BoardType != 'UberBoard')
                {
                   cloneCharts(cBoard,VS);
                }//End of If
                if(cBoard.cloneFiles!=null && cBoard.cloneFiles){
                	cloneFiles(cBoard.realVSID, mapWithOldKc);
                }
            }catch (Exception e) {
                Database.rollback(newSavepoint);
                System.debug('Error : '+e.getMessage());
                throw new leankor.GanttTaskBoard.LeanException('Exception Error: ' + e.getMessage());
            }
        }else{
            if(cBoard.BoardType== 'Kanban Board'){
                leankor.KanbanController.createKanbanBoard(cBoard.VSID);
            }else if(cBoard.BoardType=='Plan Board'){
                leankor.KanbanController.createPlanBoard(cBoard.VSID);
            }else if(cBoard.BoardType=='DashBoard'){
                leankor.KanbanController.createDashBoard(cBoard.VSID);
            }
        }
        return 'Success';
    }
    
    public static void cloneFiles(String vsId, Map<String,String> mapKcCard){
        //Check CRUD / FLC behavior 
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (
            !feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable() 
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

    	List<FeedItem> fiList = new List<FeedItem>();
    	for(FeedItem feedInstance : RealTimeControllerHelper.readFeedItems(vsId)){	
			//Do not clone feed item which has deleted files
            if(String.isNotBlank(feedInstance.RelatedRecordId)){
	    		FeedItem fi  = new FeedItem();
	    		fi.Body = '';
				fi.ParentId = mapKcCard.get(feedInstance.parentId);
				fi.RelatedRecordId = feedInstance.RelatedRecordId;
				fiList.add(fi);
	    	}
    	}
        System.debug('Original/First Batch Kanban Cards Files Size => '+fiList.size());
    	Database.insert(fiList,true);
    }


    /*cloning dependency*/
    public static void cloneDependency(CloneBoard cBoard,List<leankor__KanbanCard__c> RemoteKanbanCards , List<leankor__Dependency__c> DependList,Map<String,String> mapKanbanCard){
        //Check CRUD / FLC behavior  
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (
            !dependencyBehaviour.isAccessible() ||
            !dependencyBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        // start cloning dependency
        List<leankor__Dependency__c> DependencyList = new List<leankor__Dependency__c>();                                                                                                     
        
        if(DependList.size()>0){
            for(leankor__Dependency__c dp : DependList){
                if((mapKanbanCard.ContainsKey(dp.leankor__Successor__c)) || (mapKanbanCard.ContainsKey(dp.leankor__Predecessor__c))){
                    leankor__Dependency__c d = new leankor__Dependency__c(
                    leankor__GUID__c = dp.Id+'-'+System.Now().getTime()+'-d', // Need to make dynamic GUID.
                    leankor__ValueStream__c = (cBoard.VSID == dp.leankor__ValueStream__c ? dp.leankor__ValueStream__c : cBoard.VSID),
                    leankor__Predecessor__c =  (mapKanbanCard.ContainsKey(dp.leankor__Predecessor__c) ? mapKanbanCard.get(dp.leankor__Predecessor__c) : dp.leankor__Predecessor__c),
                    leankor__Successor__c = (mapKanbanCard.ContainsKey(dp.leankor__Successor__c) ? mapKanbanCard.get(dp.leankor__Successor__c) : dp.leankor__Successor__c),
                    leankor__SuccessorType__c = dp.leankor__SuccessorType__c,
                    leankor__LagLead__c = dp.leankor__LagLead__c,
                    leankor__LagLeadUnit__c = dp.leankor__LagLeadUnit__c
                 // leankor__LagLeadDuration__c = dp.leankor__LagLeadDuration__c
                    );
                    DependencyList.add(d);
                }//End of If
            }//End of for loop
            try{
                Database.insert(DependencyList,false);
            }catch(Exception ex){
                System.debug('Error : '+ex.getMessage());
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }//End of If

    }


    /*cloning Stickers*/
    public static void cloneStickers(CloneBoard cBoard){    
        //Check CRUD / FLC behavior 
        StickerBehavior stickerBehavior = new StickerBehavior();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        if (
            !stickerBehavior.isAccessible() ||
            !stickerBehavior.isCreateable() ||
            !stickerBehavior.isUpdateable() ||
            !attachmentBehaviour.isAccessible() ||
            !attachmentBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__Sticker__c> newStickers = new List<leankor__Sticker__c>();
        List<leankor__Sticker__c> stickers= [SELECT Id, leankor__ValueStream__c, Name, OwnerId FROM leankor__Sticker__c Where leankor__ValueStream__c =: cBoard.RealVSID Limit 9999]; 
        if(stickers.Size() > 0){
            Map<String,String> stickerIDs = new  Map<String,String>();
            for(leankor__Sticker__c s :stickers){
                leankor__Sticker__c stk = new leankor__Sticker__c(leankor__ValueStream__C = cBoard.VSID, Name = s.Id, OwnerId = s.OwnerId );
                newStickers.add(stk);
                stickerIDs.put(s.Id,s.Name);
            }
            try{
                DataBase.Insert(newStickers,false); 
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            } 
            for(leankor__Sticker__c s : newStickers){
                String st = s.Name; 
                s.Name = stickerIDs.get(st);
                stickerIDs.put(st,s.Id);
            }
            try{
                DataBase.Update(newStickers,false); 
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            List<Attachment> newAttchments = new List<Attachment>();
            
            // rbo 08.07.17 
            // 1. Added Parent.Type to make the query to Attachment faster 
            // 2. Changed the LIMIT number to 49999
            // 3. Converted to SOQL for LOOPS
            /*
            List<Attachment> attchStickers =[SELECT Body,BodyLength,ContentType,Description,Id,Name,OwnerId,ParentId FROM Attachment Where ParentId in :stickers limit 999];
            for(Attachment att : attchStickers){
                Attachment NewAttach = new Attachment(
                    Name = att.Name,
                    ContentType = att.ContentType,
                    ParentID = stickerIDs.get(att.ParentId),
                    Body = att.Body
                );
                newAttchments.add(NewAttach);
            }
            */ 
                                
            for (Attachment[] att : [SELECT Body, BodyLength, ContentType, Description, Id, Name, OwnerId, ParentId FROM Attachment WHERE Parent.Type IN :SETSTICKERSOBJECTS_CONST AND ParentId IN :stickers LIMIT 9999]) {
                for (Integer iCount = 0; iCount < att.size(); iCount++) {                           
                    Attachment NewAttach = new Attachment(
                        Name = att[iCount].Name,
                        ContentType = att[iCount].ContentType,
                        ParentID = stickerIDs.get(att[iCount].ParentId),
                        Body = att[iCount].Body
                    );
                    newAttchments.add(NewAttach);        
                }
            }                   
            // rbo 08.07.17
            
            try{
                DataBase.Insert(newAttchments,true); 
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }
    }


    /*cloning Markers*/
    public static void cloneMarkers(CloneBoard cBoard){
        //Check CRUD / FLC behavior 
        MarkerBehaviour markerBehaviour = new MarkerBehaviour();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        if (
            !markerBehaviour.isAccessible() ||
            !markerBehaviour.isCreateable() ||
            !attachmentBehaviour.isAccessible() ||
            !attachmentBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        List<leankor__Marker__c> RemoteMarkers = [SELECT Id,
                                                        leankor__Type__c,
                                                        leankor__UrlLink__c,
                                                        leankor__ZIndex__c,
                                                        leankor__TextLabel__c,
                                                        leankor__Bottom__c,
                                                        leankor__CmpID__c,
                                                        leankor__CSSLayout__c,
                                                        leankor__GUID2__c,
                                                        leankor__GUID__c,
                                                        leankor__Height__c,
                                                        leankor__JSONData__c,
                                                        leankor__JSONDefinition__c,
                                                        leankor__Left__c,
                                                        leankor__LockState__c,
                                                        leankor__Sticker__c,
                                                        leankor__Top__c,
                                                        leankor__ValueStreamCardLink__c,
                                                        leankor__ValueStreamLink__c,
                                                        leankor__ValueStream__c,
                                                        leankor__Width__c,
                                                        leankor__X__c,
                                                        leankor__Y__c,
                                                        Name,OwnerId 
                                                    FROM leankor__Marker__c 
                                                    WHERE leankor__ValueStream__C =: cBoard.RealVSID 
                                                    LIMIT 9999];
                    
        if(RemoteMarkers.isEmpty() && cBoard.BoardType == 'DashBoard'){
            //Date : 05/06/19 
            //RemoteMarkers = [SELECT Id,leankor__Type__c,leankor__UrlLink__c,leankor__ZIndex__c,leankor__TextLabel__c,leankor__Bottom__c,leankor__CmpID__c,leankor__CSSLayout__c,leankor__GUID2__c,leankor__GUID__c,leankor__Height__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__Left__c,leankor__LockState__c,leankor__Sticker__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,Name,OwnerId FROM leankor__Marker__c Where leankor__ValueStream__r.Name ='_System_DashBoard' and leankor__ValueStream__r.leankor__ProjectRoom__C =null and leankor__ValueStream__r.leankor__BoardType__c = 'DashBoard' Limit 9999];
            RemoteMarkers= RealTimeControllerHelper.readMarkers();
        }

        // rbo 08.07.17 
        // the following block of code is already taken care of below
        /*               
        List<Attachment> Attachments = [SELECT Body,ContentType,Description,Id,Name,OwnerId,ParentId FROM Attachment Where ParentId IN :RemoteMarkers Limit 999];
        Map<String,SObject> AttachmentMap = new Map<String,SObject>();
        for(Attachment att : Attachments){
            AttachmentMap.put(att.ParentId, att);
        }
        */
        // rbo 08.07.17
        
        Map<String,String> OldMarkerIDMap = new Map<String,String>();
        Map<String,String> NewMarkerIDMAP = new Map<String,String>();
        List<leankor__Marker__c> NewMarkers = new List<leankor__Marker__c>();
        
        for(leankor__Marker__c RemoteMarker: RemoteMarkers){
            String tempGUID = RemoteMarker.Id+'-'+System.Now().getTime()+'-m';
            
            leankor__Marker__c NewMarker = new leankor__Marker__c(
                leankor__GUID__c = tempGUID,
                leankor__Type__c= RemoteMarker.leankor__Type__c,
                leankor__UrlLink__c= RemoteMarker.leankor__UrlLink__c,
                leankor__ZIndex__c = RemoteMarker.leankor__ZIndex__c,
                leankor__TextLabel__c = RemoteMarker.leankor__TextLabel__c,
                leankor__GUID2__c = tempGUID,
                leankor__CmpID__c = RemoteMarker.leankor__CmpID__c,
                Name = RemoteMarker.Name,
                leankor__Top__c = RemoteMarker.leankor__Top__c,
                leankor__Bottom__c = RemoteMarker.leankor__Bottom__c,
                leankor__Left__c = RemoteMarker.leankor__Left__c,
                leankor__Width__c = RemoteMarker.leankor__Width__c,
                leankor__Height__c = RemoteMarker.leankor__Height__c,
                leankor__X__c = RemoteMarker.leankor__X__c,
                leankor__Y__c = RemoteMarker.leankor__Y__c,
                leankor__CSSLayout__c = RemoteMarker.leankor__CSSLayout__c,
                leankor__JSONDefinition__c = RemoteMarker.leankor__JSONDefinition__c,
                leankor__JSONData__c = RemoteMarker.leankor__JSONData__c,
                leankor__ValueStream__c = cBoard.VSID,
                leankor__Sticker__c = (RemoteMarker.leankor__Sticker__C ==''? null : RemoteMarker.leankor__Sticker__c),
                leankor__ValueStreamLink__c = (RemoteMarker.leankor__ValueStreamLink__c == null ? null :RemoteMarker.leankor__ValueStreamLink__c),
                leankor__LockState__c = RemoteMarker.leankor__LockState__c,
                leankor__ValueStreamCardLink__c = (RemoteMarker.leankor__ValueStreamCardLink__c == null ? null : RemoteMarker.leankor__ValueStreamCardLink__c )  
            ); 
            OldMarkerIDMap.put(RemoteMarker.Id, tempGUID);
            NewMarkers.add(NewMarker);
        }        
        try {
            DataBase.Insert(NewMarkers,true);
        } catch (DmlException e){
            System.debug(e.getMessage());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
        }         
        for(leankor__Marker__c newMarker : NewMarkers){
            NewMarkerIDMAP.put(newMarker.leankor__GUID2__C, newMarker.Id);
        }       
                

        // rbo 08.07.17 
        // 1. Added Parent.Type to make the query to Attachment faster 
        // 2. Changed the LIMIT number to 49999
        // 3. Converted to SOQL for LOOPS
        /*               
        List<Attachment> NewAttachList = new List<Attachment>();
        for(Attachment att : Attachments){
            String tempGUID = (OldMarkerIDMap.ContainsKey(att.ParentID) ? OldMarkerIDMap.get(att.ParentID) : '');
            String tempParentId = '';
            tempParentId = (NewMarkerIDMAP.ContainsKey(tempGUID) ? NewMarkerIDMAP.get(tempGUID) : '');
            if(tempParentId != null && tempParentId != ''){
                Attachment NewAttach = new Attachment(
                    Name = att.Name,
                    ContentType = att.ContentType,
                    ParentID = tempParentId,
                    Body = att.Body
                );
                NewAttachList.add(NewAttach);
            }
        }  
        */
        
        List<Attachment> NewAttachList = new List<Attachment>();
        Map<String,SObject> AttachmentMap = new Map<String,SObject>();
        for (Attachment[] att : [SELECT Body, ContentType, Description, Id, Name, OwnerId, ParentId FROM Attachment WHERE Parent.Type IN :SETSTICKERSOBJECTS_CONST AND ParentId IN :RemoteMarkers LIMIT 9999]) {
            for (Integer iCount = 0; iCount < att.size(); iCount++) {
                AttachmentMap.put(att[iCount].ParentId, att[iCount]);

                String tempGUID = (OldMarkerIDMap.ContainsKey(att[iCount].ParentID) ? OldMarkerIDMap.get(att[iCount].ParentID) : '');
                String tempParentId = '';
                tempParentId = (NewMarkerIDMAP.ContainsKey(tempGUID) ? NewMarkerIDMAP.get(tempGUID) : '');
                if(tempParentId != null && tempParentId != ''){                                            
                    Attachment NewAttach = new Attachment(
                        Name = att[iCount].Name,
                        ContentType = att[iCount].ContentType,
                        ParentID = tempParentId,
                        Body = att[iCount].Body
                    );
                    NewAttachList.add(NewAttach);
                }   
                                    
            }
        }
        // rbo 08.07.17
        
        
        if(NewAttachList.size() >0){
            try {
                Database.insert(NewAttachList,true);
            } catch (DmlException e) {
                System.debug(e.getMessage());  
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + e.getMessage()); 
            }
        }

    }


    /*cloning charts*/
    public static void cloneCharts(CloneBoard cBoard , List<leankor__ValueStream__c> VS){
        //Check CRUD / FLC behavior 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ChartBehaviour chartBehaviour = new ChartBehaviour(); 
        if (
            !valueStreamBehavior.isAccessible() ||
            !chartBehaviour.isAccessible() ||
            !chartBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        leankor__ValueStream__c newVS = [SELECT Id,
                                                Name,
                                                leankor__projectroom__c,
                                                leankor__projectroom__r.Name 
                                            FROM leankor__ValueStream__c 
                                            WHERE Id =: cBoard.VSID 
                                            LIMIT 1];
        String VSname,VSRoomName,roomID,rollupID;
        
        VSname = newVS.Name;
        VSRoomName = newVS.leankor__projectroom__r.Name;
        roomID = newVS.leankor__projectroom__c;

        if(newVS.leankor__projectroom__c != null){
            List<leankor__ValueStream__c> rollupVS = [SELECT Id 
                                                        FROM leankor__Valuestream__c 
                                                        WHERE leankor__Projectroom__c =: newVS.leankor__projectroom__c 
                                                            AND leankor__BoardType__c = 'Plan Board' 
                                                        LIMIT 1 ];
            if(rollupVS.size() >0){
                rollupID = rollupVS[0].ID;
            }
        }
        
        List<leankor__Chart__c> RemoteCharts = [SELECT Id,leankor__OnlyShowChart__C,leankor__ChartURL__c,leankor__CmpID__c,leankor__DeveloperName__c,leankor__Filter__c,leankor__Format__c,leankor__GUID__c,leankor__Height__c,leankor__JSONData__c,leankor__Left__c,leankor__LockState__c,leankor__ReportId__c,leankor__Size__c,leankor__Top__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,Name,OwnerId FROM leankor__Chart__c WHERE leankor__ValueStream__C =: cBoard.RealVSID LIMIT 9999];
        if(RemoteCharts.size() == 0){
            RemoteCharts = [SELECT Id,leankor__OnlyShowChart__C,leankor__ChartURL__c,leankor__CmpID__c,leankor__DeveloperName__c,leankor__Filter__c,leankor__Format__c,leankor__GUID__c,leankor__Height__c,leankor__JSONData__c,leankor__Left__c,leankor__LockState__c,leankor__ReportId__c,leankor__Size__c,leankor__Top__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,Name,OwnerId FROM leankor__Chart__c WHERE leankor__ValueStream__C IN :VS LIMIT 9999];
        }

        List<leankor__Chart__c> NewCharts = new List<leankor__Chart__c>();
        for(leankor__Chart__c Chart: RemoteCharts){
            if(Chart.leankor__ValueStream__c != null){
                leankor__Chart__C Newchart = new leankor__Chart__c();
                    Newchart.Name = Chart.Name;
                    Newchart.leankor__DeveloperName__c = Chart.leankor__DeveloperName__c;
                    Newchart.leankor__Filter__c = Chart.leankor__Filter__c;
                    Newchart.leankor__Format__c = Chart.leankor__Format__c;
                    Newchart.leankor__GUID__c = Chart.Id+'-'+System.Now().getTime()+'-c';
                    Newchart.leankor__Height__c = Chart.leankor__Height__c;
                    Newchart.leankor__Left__c = Chart.leankor__Left__c;
                    Newchart.leankor__LockState__c = Chart.leankor__LockState__c;
                    Newchart.leankor__ReportId__c = Chart.leankor__ReportId__c;
                    Newchart.leankor__Top__c = Chart.leankor__Top__c;
                    Newchart.leankor__ValueStream__c = cBoard.VSID;
                    Newchart.leankor__Width__c = Chart.leankor__Width__c;
                    Newchart.leankor__X__c = Chart.leankor__X__c;
                    Newchart.leankor__Y__c = Chart.leankor__Y__c;
                    Newchart.leankor__CmpID__c =Chart.leankor__CmpID__c;
                    Newchart.leankor__Size__c = Chart.leankor__Size__c;    
                    Newchart.leankor__ChartURL__c = Chart.leankor__ChartURL__c;
                    if(Chart.leankor__JSONData__c !='' && Chart.leankor__JSONData__c != null && Chart.leankor__JSONData__c !='[{}]'){
                        List<chartJSON> JSONlog = (List<chartJSON>)JSON.deserialize(Chart.leankor__JSONData__c, List<chartJSON>.class);
                        if(cBoard.BoardType=='DashBoard'){
                            for(chartJSON log:JSONlog){
                                if(log.columnLabel.contains('ID')){
                                    if(log.columnLabel.contains('Value Stream ID')){
                                        log.value = rollupID;
                                    log.valueData = rollupID;
                                    }else if(log.columnLabel.contains('Project Room ID')){
                                        log.value = roomID;
                                        log.valueData = roomID;
                                    }
                                }else if(log.columnLabel == 'Value Stream: Value Stream Name' || log.columnLabel == 'Value Stream Name' || (log.columnLabel.contains('Value Stream Name') && !log.columnLabel.contains('Project Room'))){ 
                                    log.value = 'Roll-Up('+VSRoomName+')';
                                    log.valueData = 'Roll-Up('+VSRoomName+')';
                                }else if (log.columnLabel == 'Project Room' || log.columnLabel == 'Project Room Name' || log.columnLabel.contains('Project Room')){
                                    log.value = VSRoomName;
                                    log.valueData = VSRoomName;                         
                                }
                            }
                        }else{
                            for(chartJSON log:JSONlog){
                                if(log.columnLabel == 'Value Stream: Value Stream Name' || log.columnLabel == 'Value Stream Name' || log.columnLabel.contains('Value Stream Name')){
                                    log.value = VSname;
                                    log.valueData = VSname;
                                }else if (log.columnLabel == 'Project Room' || log.columnLabel == 'Project Room Name' || log.columnLabel.contains('Project Room')){
                                    log.value = VSRoomName;
                                    log.valueData = VSRoomName;                         
                                }
                            }
                        }
                        Newchart.leankor__JSONData__c = JSON.serialize(JSONlog);//Chart.leankor__JSONData__c;
                    }else{
                        Newchart.leankor__JSONData__c = Chart.leankor__JSONData__c;   
                    }  
                    Newchart.leankor__OnlyShowChart__c = Chart.leankor__OnlyShowChart__C;  
                NewCharts.add(Newchart);
            }
        }   
        try {
            Database.insert(NewCharts,false); 
        } catch (DmlException e){
            System.debug(e.getMessage());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());    
        }
    }


    global Class chartJSON{
        global string column;
        global string columnLabel;
        global string operator;
        global string operatorLabel;
        global string dataType;
        global string value;
        global string valueData;
    }
    //
    // This Inner Method Is Use for Log Time for Card Records
    //
    Global Class CardLogTime{
        Global String Id;
        Global String LogTime;
        Global String Description;
        Global String Duration;
        Global Decimal Estimation;
        Global String Subject;
        Global String TaskID;
        Global Decimal Hours;
        Global String KanbanCardID;
        Global String TaskDueDate;
        Global String AssignedTo;
        Global String AssignedAUser;
        Global String AssignedAUserName;
        Global String SmallPhotoUrl;
        Global CardLogTime(){}
        Global CardLogTime(String Id,String LogTime,String Description,String Duration, Decimal Estimation, String Subject,String TaskID, Decimal Hours, String KanbanCardID, String TaskDueDate, String AssignedTo,String SmallPhotoUrl,String AssignedAUser,String AssignedAUserName){
            this.Id = Id;
            this.LogTime = LogTime;
            this.Description = Description;
            this.Duration = Duration;
            this.Estimation = Estimation;
            this.Subject = Subject;
            this.TaskID = TaskID;
            this.Hours = Hours;
            this.KanbanCardID = KanbanCardID;
            this.TaskDueDate = TaskDueDate;
            this.AssignedTo = AssignedTo;
            this.SmallPhotoUrl = SmallPhotoUrl;
            this.AssignedAUser = AssignedAUser;
            this.AssignedAUserName = AssignedAUserName;
        }
    }
    //
    // This Method Is Use for Get Card Log Time Records
    //

    @AuraEnabled
    public static List<CardLogTimeData> retrieveCardLogs(String cardID) {
        // Call the existing method to get the CardLogTime list
        List<CardLogTime> cardLogs = getCardLogs(cardID);
        
        // List to hold the CardLogTimeData instances
        List<CardLogTimeData> wrappedCardLogs = new List<CardLogTimeData>();
        
        // Map each CardLogTime to CardLogTimeData
        for (CardLogTime log : cardLogs) {
            wrappedCardLogs.add(new CardLogTimeData(
                log.Id,
                log.LogTime,
                log.Description,
                log.Duration,
                log.Estimation,
                log.Subject,
                log.TaskID,
                log.Hours,
                log.KanbanCardID,
                log.TaskDueDate,
                log.AssignedTo,
                log.AssignedAUser,
                log.AssignedAUserName
            ));
        }
        
        return wrappedCardLogs; // Return the list of CardLogTimeData
    }   

    @RemoteAction
    Global static List<CardLogTime> getCardLogs(String CardID){
        //Check CRUD / FLC behavior 
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        UserBehaviour userBehaviour = new UserBehaviour(); 
        if (
            !timeCardBehavior.isAccessible() ||
            !userBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<CardLogTime> Cards = new List<CardLogTime>();
        set<String> UserIDs = New set<String>();      
        List<leankor__TimeCard__c> TimeCards = [SELECT Id,
                                                    leankor__Subject__c,
                                                    leankor__Date__c,
                                                    leankor__Description__c,
                                                    leankor__Assign_a_User__c,
                                                    leankor__Assign_a_User__r.Name,
                                                    leankor__Duration__c,
                                                    leankor__Estimation__c,
                                                    leankor__Hours__c,
                                                    leankor__KanbanCard__c,
                                                    leankor__LogTime__c,
                                                    leankor__Notes__c,
                                                    leankor__Task__c,
                                                    OwnerId,
                                                    leankor__TaskDueDate__c,
                                                    leankor__AssignedTo__c 
                                                FROM leankor__TimeCard__c 
                                                WHERE leankor__KanbanCard__c =: CardID 
                                                LIMIT 9999];
        for(leankor__TimeCard__c t : TimeCards){
            UserIDs.add(t.leankor__Assign_a_User__c);
        }
        List<User> users = [SELECT Id, FirstName,Email, LastName, Name, Username, Alias, UserRoleId, SmallPhotoUrl FROM User WHERE ID IN :UserIDs LIMIT 9999];
        Map<Id, String> UserRecords = new Map<Id, String>();

        for(User u : users){
            UserRecords.put(u.Id,u.SmallPhotoUrl);
        } 

        for(leankor__TimeCard__c t : TimeCards){
            String dt='{"LogTime": '+JSON.serialize(t.leankor__LogTime__c)+',"TaskDueDate" :';
            if(t.leankor__TaskDueDate__c != null){
                dt += JSON.serialize(t.leankor__TaskDueDate__c)+'}'; 
            }else{
                dt += '""}';
            }
            CardLogTime c = (CardLogTime)JSON.deserialize(dt,CardLogTime.Class);
            CardLogTime clt = new CardLogTime(
                t.Id,
                c.LogTime,
                (t.leankor__Description__c == null ? '':t.leankor__Description__c),
                t.leankor__Duration__c, 
                t.leankor__Estimation__c, 
                (t.leankor__Subject__c == null ? '' : t.leankor__Subject__c),
                (t.leankor__Task__c == null ? '' : t.leankor__Task__c),
                t.leankor__Hours__c,
                t.leankor__KanbanCard__c , 
                c.TaskDueDate, 
                (t.leankor__AssignedTo__c == null ? '' : t.leankor__AssignedTo__c), 
                UserRecords.get(t.leankor__Assign_a_User__c),
                t.leankor__Assign_a_User__c,
                t.leankor__Assign_a_User__r.Name
            );
            Cards.add(clt);
        }
        return Cards;
    }
    //
    // This Method Is Use for Create Card Log Time Records
    //
    @RemoteAction
    Global static leankor__TimeCard__c createCardLog(CardLogTime LogCard){
        //Check CRUD / FLC behavior 
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        UserBehaviour userBehaviour = new UserBehaviour(); 
        if (
            !timeCardBehavior.isAccessible() ||
            !timeCardBehavior.isCreateable() ||
            !userBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior  

        DateTime cardDateTime = ((LogCard.LogTime != null && LogCard.LogTime != '') ?((DateTime)JSON.deserialize(LogCard.LogTime, DateTime.class)) : null);
        List<leankor__TimeSheet__c> timeSheet = [Select id,
                                                        leankor__Resource__c,
                                                        leankor__StartDateTime__c,
                                                        leankor__EndDateTime__c 
                                                    From leankor__TimeSheet__c 
                                                    Where (leankor__Resource__c= :LogCard.AssignedAUser)
                                                    And ((leankor__StartDateTime__c <=: cardDateTime) AND (leankor__EndDateTime__c >= :cardDateTime )) 
                                                    And (leankor__ApprovalHistoryStatus__c = null)
                                                    ORDER BY CreatedDate DESC
                                                    LIMIT 1]; 
       
        User  u =[SELECT Id, isactive FROM User WHERE Id =: LogCard.AssignedAUser];
        leankor__TimeCard__c t = new leankor__TimeCard__c(
            leankor__LogTime__c  = ((LogCard.LogTime != null && LogCard.LogTime != '') ?((DateTime)JSON.deserialize(LogCard.LogTime, DateTime.class)) : null),
            leankor__Description__c  = LogCard.Description,
            leankor__Duration__c  = LogCard.Duration,
            leankor__Estimation__c = LogCard.Estimation,
            leankor__Subject__c = LogCard.Subject,
            leankor__Task__c = LogCard.TaskID,
            leankor__Hours__c = LogCard.Hours,
            leankor__KanbanCard__c = LogCard.KanbanCardID,
            leankor__TaskDueDate__c = ((LogCard.TaskDueDate != null && LogCard.TaskDueDate != '') ?((DateTime)JSON.deserialize(LogCard.TaskDueDate, DateTime.class)) : null),
            leankor__AssignedTo__C =  (LogCard.AssignedTo == '' ? null : LogCard.AssignedTo),
            leankor__Assign_a_User__c =  (LogCard.AssignedAUser == '' ? null : LogCard.AssignedAUser)
        );
        
        //Pratiksha : 24.04.2021 Chages for TimeSheet.
        if(timeSheet.size()>0){
            t.leankor__TimeSheet__c =  timeSheet[0].id;
        }

        try{
            if(u.isactive == true){
                DataBase.insert(t, true);
            }else{
                return (new leankor__TimeCard__c());
            }
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return (new leankor__TimeCard__c());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return t;
    }
    @AuraEnabled
    public static leankor__TimeCard__c createCardLogAura(CardLogTimeData request) {
        // Map TimeCardRequest to CardLogTime object
        CardLogTime logCard = new CardLogTime();
        
        logCard.logTime = request.logTime;
        logCard.description = request.description;
        logCard.duration = request.duration;
        logCard.estimation = request.estimation;
        logCard.subject = request.subject;
        logCard.taskID = request.taskId;
        logCard.hours = request.hours;
        logCard.kanbanCardID = request.kanbanCardID;
        logCard.taskDueDate = request.taskDueDate;
        logCard.assignedTo = request.assignedTo;
        logCard.assignedAUser = request.assignedAUser;

        // Call the existing createCardLog method
        return createCardLog(logCard);
    }

    //
    // This Method Is Use for Update Card Log Time Records
    //
    @RemoteAction
    Global static String updateCardLogs(CardLogTime LogCard){
        //Check CRUD / FLC behavior 
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        UserBehaviour userBehaviour = new UserBehaviour(); 
        if (
            !timeCardBehavior.isAccessible() ||
            !timeCardBehavior.isUpdateable() ||
            !userBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        User  u =[SELECT Id, isactive FROM User WHERE ID =: LogCard.AssignedAUser];  
        leankor__TimeCard__c TimeCards = [SELECT Id,
                                                leankor__Date__c,
                                                leankor__Description__c,
                                                leankor__Duration__c,
                                                leankor__Assign_a_User__c,
                                                leankor__Estimation__c,
                                                leankor__Hours__c,
                                                leankor__KanbanCard__c,
                                                leankor__LogTime__c,
                                                leankor__Notes__c,
                                                leankor__Task__c,
                                                Name,
                                                OwnerId,
                                                leankor__TaskDueDate__c,
                                                leankor__AssignedTo__c 
                                            FROM leankor__TimeCard__c 
                                            WHERE Id =:LogCard.Id 
                                            LIMIT 1];
        TimeCards.leankor__LogTime__c  = ((LogCard.LogTime != null  && LogCard.LogTime != '') ?((DateTime)JSON.deserialize(LogCard.LogTime, DateTime.class)) : TimeCards.leankor__LogTime__c);
        TimeCards.leankor__Description__c  = LogCard.Description;
        TimeCards.leankor__Duration__c  = LogCard.Duration;
        TimeCards.leankor__Estimation__c = LogCard.Estimation;
        TimeCards.leankor__Subject__c = LogCard.Subject;
        TimeCards.leankor__Task__c = LogCard.TaskID;
        TimeCards.leankor__Hours__c = LogCard.Hours;
        TimeCards.leankor__KanbanCard__c = LogCard.KanbanCardID;
        TimeCards.leankor__TaskDueDate__c = ((LogCard.TaskDueDate != null  && LogCard.TaskDueDate != '')?((DateTime)JSON.deserialize(LogCard.TaskDueDate, DateTime.class)) : TimeCards.leankor__TaskDueDate__c);
        TimeCards.leankor__AssignedTo__C = (LogCard.AssignedTo == '' ? null : LogCard.AssignedTo);
        TimeCards.leankor__Assign_a_User__c = (LogCard.AssignedAUser == '' ? null : LogCard.AssignedAUser);
        try{
            if(u.isactive == true){
                DataBase.Update(TimeCards, true);
            }else{
                return 'Failed';
            }
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return 'Success';
    }

    @AuraEnabled
    public static String updateCardLogsAura(CardLogTimeData logCardData) {
        // Convert CardLogTimeData to CardLogTime to match the existing method's parameter
        CardLogTime logCard = new CardLogTime();
        logCard.Id = logCardData.Id;
        logCard.LogTime = logCardData.LogTime;
        logCard.Description = logCardData.Description;
        logCard.Duration = logCardData.Duration;
        logCard.Estimation = logCardData.Estimation;
        logCard.Subject = logCardData.Subject;
        logCard.TaskID = logCardData.TaskID;
        logCard.Hours = logCardData.Hours;
        logCard.KanbanCardID = logCardData.KanbanCardID;
        logCard.TaskDueDate = logCardData.TaskDueDate;
        logCard.AssignedTo = logCardData.AssignedTo;
        logCard.AssignedAUser = logCardData.AssignedAUser;

        try {
            return updateCardLogs(logCard);
        } catch (Util.LeanException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //
    // This Method Is Use for Delete Card Log Time Records
    //
    @RemoteAction
    Global static String removeCardLogs(String LogID){
        //Check CRUD / FLC behavior 
        TimeCardBehavior timeCardBehavior = new TimeCardBehavior();
        if (
            !timeCardBehavior.isAccessible() ||
            !timeCardBehavior.isUpdateable()
        ) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__TimeCard__c> timeCards = [Select leankor__Assign_a_User__c, 
                                                        leankor__AssignedTo__c, 
                                                    leankor__KanbanCard__c,
                                                        leankor__TimeSheet__c
                                                    From leankor__TimeCard__c 
                                                    Where Id =:logId
                                                    Limit 1];
        
        for (leankor__TimeCard__c timeCard : timeCards) {
            timeCard.leankor__Assign_a_User__c = null;
            timeCard.leankor__AssignedTo__c = null;
            timeCard.leankor__KanbanCard__c = null;
            timeCard.leankor__TimeSheet__c = null;
        }

        try{
            DataBase.update(timeCards, true);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return 'Success';
    }
    @AuraEnabled
    public static String removeCardLogsAura(String logId) {
        try {
            return removeCardLogs(logId);
        } catch (Util.LeanException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** Class will use to take and return records to LeankorJS end in required format. */
    Global Class IssueLogs{
        Global String Id;
        Global String Subject;
        Global String Detail;
        Global String KanbanCardID;
        Global String LogTime;
        Global String Probability;
        Global String StatusType;
        Global String TaskID;
        Global String Weight;
        Global Boolean Resolved;
        Global String ResolvedTime;
        Global Decimal Score;
        Global String TaskDueDate;
        Global String AssignedTo;
        Global String SmallPhotoUrl;
		//******SS 10.06.2018 ******//
        //Added RiskMitigation
		
		Global String riskMitigation;

        /** IssueLogs Constructor */
        Global IssueLogs(){}
    }

   @AuraEnabled
    public static List<IssueLogResponse> retrieveIssueLogs(String kanbanID) {
        List<IssueLogResponse> responseList = new List<IssueLogResponse>();
            // Call the existing method to retrieve issue logs
            List<IssueLogs> issueLogs = getIssueLogs(kanbanID);
            
            // Create IssueLogResponse objects for each log
            for(IssueLogs logs : issueLogs) {
                IssueLogResponse response = new IssueLogResponse();
                response.id = logs.Id; // Make sure the property matches the class definition
                response.subject = logs.Subject;
                response.detail = logs.Detail;
                response.kanbanCardID = logs.KanbanCardID;
                response.logTime = logs.LogTime;
                response.probability = logs.Probability;
                response.statusType = logs.StatusType;
                response.taskID = logs.TaskID;
                response.weight = logs.Weight;
                response.resolved = logs.Resolved;
                response.resolvedTime = logs.ResolvedTime;
                response.score = logs.Score;
                response.taskDueDate = logs.TaskDueDate;
                response.assignedTo = logs.AssignedTo;
                response.smallPhotoUrl = logs.SmallPhotoUrl;
                // ******SS 10.06.2018 ******//
                // Added RiskMitigation field
                response.riskMitigation = logs.RiskMitigation;

                // Add to response list
                responseList.add(response);
            }
        

        return responseList;
    }


    


    /** Method will return all related Issuelog__c record to specific KanbanCard */
    @RemoteAction
    Global static List<IssueLogs> getIssueLogs(String KanbanID){
        //Check CRUD / FLC behavior 
        IssueLogBehaviour issueLogBehaviour = new IssueLogBehaviour();
        UserBehaviour userBehaviour = new UserBehaviour();
        if (
            !issueLogBehaviour.isAccessible() ||
            !userBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<IssueLogs> iLogs = new List<IssueLogs>();
        set<String> UserIDs = New set<String>(); 
		//******SS 10.06.2018 ******//
        //Added field RiskMitigation__c 
        List<leankor__IssueLog__c> Logs = [SELECT Id,
                                                leankor__Detail__c,
                                                leankor__KanbanCard__c,
                                                leankor__LogTime__c,
                                                leankor__Probability__c,
                                                leankor__StatusType__c,
                                                leankor__Task__c,
                                                leankor__Weight__c,
                                                Name,
                                                OwnerId,
                                                leankor__Resolved__C,
                                                leankor__ResolvedTime__C,
                                                leankor__Score__c,
                                                leankor__TaskDueDate__c,
                                                leankor__AssignedTo__c,
                                                leankor__RiskMitigation__c 
                                            FROM leankor__IssueLog__c 
                                            WHERE leankor__KanbanCard__C =:KanbanID 
                                            LIMIT 9999];
        For(leankor__IssueLog__c l : Logs){
            UserIDs.add(l.OwnerId);
        }
        List<User> users=[SELECT Id, FirstName,Email, LastName, Name, Username, Alias, UserRoleId, SmallPhotoUrl FROM User WHERE ID In :UserIDs LIMIT 9999];
        Map<Id, String> UserRecords = new Map<Id, String>();

        for(User u : users){
            UserRecords.put(u.Id,u.SmallPhotoUrl);
        }  

        for(leankor__IssueLog__c l : Logs){
            String dt='{"LogTime": '+JSON.serialize(l.leankor__LogTime__c)+',"ResolvedTime" :';
            if(l.leankor__Resolved__C == true){
                dt += JSON.serialize(l.leankor__ResolvedTime__C)+',"TaskDueDate" :'; 
            }else{
                dt += '"","TaskDueDate" :';
            }
            if(l.leankor__TaskDueDate__c != null){
                dt += JSON.serialize(l.leankor__TaskDueDate__c)+'}'; 
            }else{
                dt += '""}';
            }
            IssueLogs i = (IssueLogs)JSON.deserialize(dt,IssueLogs.Class); // Converting DateTime to required format 2015-04-01T20:15:00.000Z
            IssueLogs ilog = new  IssueLogs();
                ilog.Id  = l.Id;
                ilog.Subject = (l.Name == null ? '' :l.Name);
                ilog.Detail = (l.leankor__Detail__C == null ? '' : l.leankor__Detail__C);
                ilog.KanbanCardID = l.leankor__KanbanCard__C;
                ilog.LogTime = i.LogTime;
                ilog.Probability = l.leankor__Probability__C;
                ilog.StatusType = l.leankor__StatusType__C;
                ilog.TaskID = (l.leankor__Task__C == null ? '' :l.leankor__Task__C);
                ilog.Weight = l.leankor__Weight__C;
                ilog.Score = l.leankor__Score__c; 
                ilog.Resolved = l.leankor__Resolved__C;
                ilog.ResolvedTime = i.ResolvedTime;
                ilog.TaskDueDate = i.TaskDueDate;
                ilog.AssignedTo = (l.leankor__AssignedTo__C == null ? '' :l.leankor__AssignedTo__C);
                ilog.SmallPhotoUrl = UserRecords.get(l.OwnerId);
				//******SS 10.06.2018 ******//
            	//Added RiskMitigation field
				iLog.riskMitigation = l.leankor__RiskMitigation__c==null?'':l.leankor__RiskMitigation__c;
            iLogs.add(ilog);
        }
        return iLogs;
    }


    /** Remote method for remove Issuelog__c records and It takes IssueLog Id. */
    @RemoteAction
    Global static String removeIssueLogs(String LogID){
        //Check CRUD / FLC behavior 
        IssueLogBehaviour issueLogBehaviour = new IssueLogBehaviour();
        if (
            !issueLogBehaviour.isAccessible() ||
            !issueLogBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        List<leankor__IssueLog__c> issueLogs = [Select Id,
                                                        leankor__KanbanCard__c,
                                                        leankor__AssignedTo__c 
                                                    From leankor__IssueLog__c
                                                    Where Id = :logId
                                                    Limit 1];

        for (leankor__IssueLog__c issueLog : issueLogs) {
            issueLog.leankor__KanbanCard__c = null;
            issueLog.leankor__AssignedTo__c = null;
        }

        try{
            update issueLogs;
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return 'Success';
    }

    @AuraEnabled
    public static String removeIssueLog(String issueLogId) {
        // Check if issueLogId is valid
        if (String.isBlank(issueLogId)) {
            throw new Util.LeanException('Error: Invalid Log ID');
        }

        try {
            // Call the existing RemoteAction method to remove the issue log
            String result = removeIssueLogs(issueLogId);

            // Return the result ('Success' or an error message)
            return result;
        } catch (Exception ex) {
            // Handle any exceptions thrown by the RemoteAction method
            System.debug('Error : ' + ex.getMessage());
            throw new Util.LeanException('ERROR: ' + ex.getMessage());
        }
    }



    /** Remote method for update Issuelog__c record and It takes IssueLog object. */
    @RemoteAction
    Global static String updateIssueLogs(IssueLogs logs){
        //Check CRUD / FLC behavior 
        IssueLogBehaviour issueLogBehaviour = new IssueLogBehaviour();
        if (
            !issueLogBehaviour.isAccessible() ||
            !issueLogBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        //******SS 10.06.2018 ******//
		//Added field RiskMitigation__c
        leankor__IssueLog__c issueLog = [SELECT Id,
                                                leankor__Detail__c,
                                                leankor__KanbanCard__c,
                                                leankor__LogTime__c,
                                                leankor__Probability__c,
                                                leankor__StatusType__c,
                                                leankor__Task__c,
                                                leankor__Weight__c,
                                                Name,
                                                OwnerId,
                                                leankor__Resolved__C,
                                                leankor__ResolvedTime__C,
                                                leankor__Score__c,
                                                leankor__TaskDueDate__c,
                                                leankor__AssignedTo__c,
                                                leankor__RiskMitigation__c 
                                            FROM leankor__IssueLog__c 
                                            WHERE Id =: logs.Id 
                                            LIMIT 1];
        issueLog.Name = logs.Subject;
        issueLog.leankor__Detail__C = logs.Detail;
        issueLog.leankor__KanbanCard__C = logs.KanbanCardID;
        issueLog.leankor__LogTime__C = ((logs.LogTime != null  || logs.LogTime != '')?((DateTime)JSON.deserialize(logs.LogTime, DateTime.class)) : issueLog.leankor__LogTime__C);
        issueLog.leankor__Probability__C = logs.Probability;
        issueLog.leankor__StatusType__C = logs.StatusType;
        issueLog.leankor__Task__C = (logs.TaskID == null ? '' : logs.TaskID) ;
        issueLog.leankor__Weight__C = logs.Weight;
        issueLog.leankor__Score__c = logs.Score;
        issueLog.leankor__Resolved__C = logs.Resolved;
        issueLog.leankor__TaskDueDate__C = ((logs.TaskID != null  || logs.TaskID != '')?((DateTime) JSON.deserialize(logs.TaskDueDate, DateTime.class)) : null);
        issueLog.leankor__AssignedTo__c = (logs.AssignedTo == '' ? null : logs.AssignedTo);
		//Assign riskMitigation value
		issueLog.leankor__RiskMitigation__c = logs.riskMitigation==null?'':logs.riskMitigation;
        if(logs.Resolved == true){
            issueLog.leankor__ResolvedTime__C =  ((logs.ResolvedTime != null  || logs.ResolvedTime != '')?((DateTime) JSON.deserialize(logs.ResolvedTime, DateTime.class)) : issueLog.leankor__ResolvedTime__C);
        }
        try{
            DataBase.Update(issueLog,true);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return 'Success';
    }

    @AuraEnabled
    public static String updateIssueLogs(IssueLogData logData) {
        System.debug('Records on List are '+logData);

        // Validate input
        if (logData == null || String.isBlank(logData.id)) {
            throw new Util.LeanException('Error: Invalid Log Data');
        }

       // try {
            // Convert IssueLogData to the IssueLogs object used by the existing method
            IssueLogs log = new IssueLogs();
            log.Id = logData.id;
            log.Subject = logData.subject;
            log.Detail = logData.detail;
            log.KanbanCardID = logData.kanbanCardId;
            log.LogTime = logData.logTime;
            log.Probability = logData.probability;
            log.StatusType = logData.statusType;
            log.TaskID = logData.taskId;
            log.Weight = logData.weight;
            log.Score = logData.score;
            log.Resolved = logData.resolved;
            log.ResolvedTime = logData.resolvedTime;
            log.TaskDueDate = logData.taskDueDate;
            log.AssignedTo = logData.assignedTo;
            log.RiskMitigation = logData.riskMitigation;

            // Call the existing RemoteAction method
            String result = updateIssueLogs(log);

            // Return the result
            return result;

       /* } catch (Exception ex) {
            // Handle any exceptions thrown by the RemoteAction method
            System.debug('Error : ' + ex.getMessage());
            throw new Util.LeanException('ERROR: ' + ex.getMessage());
        }*/
    }



    /** Remote method for create Issuelog__c record and It takes IssueLog object. */
    @RemoteAction
    Global static IssueLogs createIssueLogs(IssueLogs logs){
        //Check CRUD / FLC behavior 
        IssueLogBehaviour issueLogBehaviour = new IssueLogBehaviour();
        if (
            !issueLogBehaviour.isAccessible() ||
            !issueLogBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

		//******SS 10.06.2018 ******//
		//Added field RiskMitigation
        leankor__IssueLog__c issueLog = new leankor__IssueLog__c(
            Name = logs.Subject,
            leankor__Detail__C = logs.Detail,
            leankor__KanbanCard__C = logs.KanbanCardID,
            leankor__LogTime__C =  ((DateTime)JSON.deserialize(logs.LogTime, DateTime.class)),
            leankor__Probability__C = logs.Probability,
            leankor__StatusType__C = logs.StatusType,
            leankor__Task__C = logs.TaskID,
            leankor__Weight__C = logs.Weight,
            leankor__Resolved__C = logs.Resolved,
            leankor__Score__c = logs.Score,
            leankor__TaskDueDate__c = (logs.TaskDueDate == '' ? null : ((DateTime) JSON.deserialize(logs.TaskDueDate, DateTime.class)) ),
				leankor__AssignedTo__c = (logs.AssignedTo == '' ? null : logs.AssignedTo),
				leankor__RiskMitigation__c = logs.riskMitigation==null?'':logs.riskMitigation
        );
        try{
            DataBase.Insert(issueLog,true);
            logs.Id = issueLog.Id;
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return (new IssueLogs());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return logs;
    }
    @AuraEnabled
    public static IssueLogData createIssueLogRecords(IssueLogData logs) {
        IssueLogData response = new IssueLogData();
        
        try {
            // Create a new IssueLogData object for the created log
            leankor.KanbanController.IssueLogs createdLogs = new leankor.KanbanController.IssueLogs();

            // Populate createdLogs with values from logs
            createdLogs.id = logs.id; // Use correct casing for properties
            createdLogs.subject = logs.subject;
            createdLogs.detail = logs.detail;
            createdLogs.kanbanCardID = logs.kanbanCardID;
            createdLogs.logTime = logs.logTime;
            createdLogs.probability = logs.probability;
            createdLogs.statusType = logs.statusType;
            createdLogs.taskID = logs.taskID;
            createdLogs.weight = logs.weight;
            createdLogs.resolved = logs.resolved;
            createdLogs.score = logs.score;
            createdLogs.taskDueDate = logs.taskDueDate;
            createdLogs.assignedTo = logs.assignedTo;
            createdLogs.riskMitigation = logs.riskMitigation;

            // Call the existing createIssueLogs method with createdLogs
            leankor.KanbanController.IssueLogs responseLogs = createIssueLogs(createdLogs);

            // Populate response with the values from responseLogs
            response.Id = responseLogs.Id;
            response.Subject = responseLogs.Subject;
            response.Detail = responseLogs.Detail;
            response.KanbanCardID = responseLogs.KanbanCardID;
            response.LogTime = responseLogs.LogTime;
            response.Probability = responseLogs.Probability;
            response.StatusType = responseLogs.StatusType;
            response.TaskID = responseLogs.TaskID;
            response.Weight = responseLogs.Weight;
            response.Resolved = responseLogs.Resolved;
            response.Score = responseLogs.Score;
            response.TaskDueDate = responseLogs.TaskDueDate;
            response.AssignedTo = responseLogs.AssignedTo;
            response.riskMitigation = responseLogs.riskMitigation;

        } catch (Util.LeanException ex) {
            System.debug('Error: ' + ex.getMessage());
            response.Subject = 'Error occurred'; // Optionally set a message
            response.Detail = ex.getMessage(); // Include error detail in response
        }

        return response;
    }



    //
    // This Method Is Use for Get card In Order
    //
    @RemoteAction
    Global static String manageKanbanOrder(List<leankor.RealTimeController.Kanban> remoteKanbans){
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !kanbanCardBehaviour.isAccessible() || 
            !kanbanCardBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        Map<String,Decimal> remoteKanbanMap = new Map<String,Decimal>();
        List<String> remoteIds = new List<String>();
        for(leankor.RealTimeController.Kanban k : remoteKanbans){
            remoteIds.add(k.Id);
            remoteKanbanMap.put(k.Id, k.Order);
        }
        List<leankor__KanbanCard__c> KanbanRecords = [SELECT Id,Name, leankor__GUID__C, leankor__Order__C FROM leankor__KanbanCard__c WHERE Id IN :remoteIds LIMIT 9999];
        for(leankor__KanbanCard__C k : KanbanRecords){
            k.leankor__Order__c = remoteKanbanMap.get(k.Id);
        }
        try{
            DataBase.Update(KanbanRecords,true);
            
        }catch(DMLException ex){
            System.debug('Error :'+ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return JSON.serialize(remoteIds);
        //return 'Success';
    }
    //
    // This Inner Method Is Use for Hyper Jump Card Records
    //    
    Global class Hyperjump{
        Global Id oldVSID;
        Global Id newVSID;
        Global String BoardType;
        Global String TemplateID;
        Global String ZoneForceID;
        Global String LinkVSID;
        Global String LinkCardID;
        Global String LinkBoardType;
    }
    //
    // This Method Is Use for Hyper Jump of Card
    //
    @RemoteAction
    Global static String HyperjumpToBoard(Hyperjump remoteObject, String someJSONdata){
        //Check CRUD / FLC behavior 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ProjectScheduleBlackoutBehaviour ProjectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        ZoneBehavior zoneBehavior = new ZoneBehavior();
        if (
            !valueStreamBehavior.isAccessible() ||
            !ProjectScheduleBlackoutBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isUpdateable() ||
            !masterContainerBehaviour.isAccessible() ||
            !swimlaneBehavior.isAccessible() ||
            !zoneBehavior.isAccessible() 
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        String ServerSessionID = UserInfo.getSessionId();
        String SomeJSONData_m = '';
        leankor.RealTimeController.StateChangePackage SCP = (leankor.RealTimeController.StateChangePackage)JSON.deserialize(SomeJSONData, leankor.RealTimeController.StateChangePackage.class);
        SCP.ValueStreamOld = remoteObject.newVSID;
        SomeJSONData_m=JSON.serialize(SCP);
        boolean TBtaskchecker;
        
        leankor__valuestream__c oldVS = [Select Id,
                                            leankor__SevenDayWorkWeek__c 
                                        From leankor__valuestream__c 
                                        Where Id = :remoteObject.oldVSID 
                                        Limit 1];

        Boolean ISoldonseven= oldVS.leankor__SevenDayWorkWeek__c;
        
        leankor__valuestream__c newVSlog = [Select Id, 
                                                Name, 
                                                leankor__SevenDayWorkWeek__c, 
                                                leankor__BoardType__c,
                                                leankor__TaskDateCheck__c,
                                                leankor__ProjectBoardStartDateTime__c,
                                                leankor__ProjectBoardEndDateTime__c
                                            From leankor__valuestream__c 
                                            Where Id = :remoteObject.newVSID 
                                            Limit 1];
        Boolean IsTaskcard = false;
        Boolean IStrgonseven= newVSlog.leankor__SevenDayWorkWeek__c;
        TBtaskchecker = newVSlog.leankor__TaskDateCheck__c;
        
        // Date: 06/12/2019 - changes related to blackout.
        List<leankor__ProjectScheduleBlackout__c> projectBlackOutList = [SELECT
                                                                        leankor__EndDate__c,
                                                                        leankor__StartDate__c
                                                                       FROM leankor__ProjectScheduleBlackout__c
                                                                       WHERE leankor__ProjectBoard__c =:newVSlog.Id
                                                                       LIMIT 9999 ];         



    Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;
    Integer firstDayOfWeek= firstDay==null || firstDay<0  || firstDay > 6?1:firstDay.intValue();

        Util.WorkWeek workWeek = new Util.workWeek(firstDayOfWeek, IStrgonseven ? 7 : 5, projectBlackOutList);

        leankor.RealTimeController.StateChangePackage SCP2 = (leankor.RealTimeController.StateChangePackage)JSON.deserialize(SomeJSONData_m, leankor.RealTimeController.StateChangePackage.class);
        //21/Dec/2023 :updating isSuccessorRecalculate field for parent card.
        Set<String> cardLinksIds =  new set<String>();
        if(remoteObject.LinkCardID != null && remoteObject.LinkCardID != '')
        {
        	cardLinksIds.add(remoteObject.LinkCardID);
        }
        leankor__KanbanCard__c remoteKanban = [SELECT Id,
                                                    leankor__ValueStreamCardLink__c,
                                                    leankor__ValueStreamLink__c,
                                                    leankor__ValueStreamLink__r.leankor__Boardtype__c,
                                                    leankor__Zone__c,
                                                    leankor__Swimlane__c,
                                                    leankor__MasterContainer__C,
                                                    Name,
                                                    leankor__Height__c,
                                                    leankor__Width__c,
                                                    leankor__Order__c,
                                                    leankor__KanbanCardTemplate__c,
                                                    leankor__ValueStream__c,
                                                    leankor__ZoneGUID__c,
                                                    leankor__Title__C,
                                                    leankor__Color__c,
                                                    leankor__JSONDefinition__C,
                                                    (Select Id,
                                                           leankor__KanbanCard__r.leankor__valuestream__c,
                                                           leankor__ConstraintDateTime__c,
                                                           leankor__ScheduleConstraint__r.leankor__Type__c
                                                        From leankor__ScheduleModes__r 
                                                        Limit 1),
                                                    leankor__JSONData__C,
                                                    leankor__Monday__c,
                                                    leankor__Tuesday__c,
                                                    leankor__Wednesday__c,
                                                    leankor__Thursday__c,
                                                    leankor__Friday__c,
                                                    leankor__Saturday__c,
                                                    leankor__Sunday__c,
                                                    leankor__WeekCalendar__c  
                                                FROM leankor__KanbanCard__c 
                                                WHERE Id =:SCP2.Id 
                                                LIMIT 1];
        remoteKanban.leankor__ValueStream__C = remoteObject.newVSID;
        remoteKanban.leankor__KanbanCardTemplate__c = remoteObject.TemplateID;
        remoteKanban.leankor__Color__c = SCP.Color;
        remoteKanban.leankor__Title__c = SCP.Title;
        //06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
        //remoteKanban.leankor__JSONDefinition__c = SCP.JSONDefinition;
        //remoteKanban.leankor__JSONData__c = SCP.JSONData;
        remoteKanban.leankor__Height__c = SCP.Height;
        remoteKanban.leankor__Width__c = SCP.Width;
        remoteKanban.leankor__ValueStreamCardLink__c = ((remoteObject.LinkCardID== ''||remoteObject.LinkCardID== null )?remoteKanban.leankor__ValueStreamCardLink__c :remoteObject.LinkCardID);
        
        SCP2.ValueStreamCardLink = ((remoteObject.LinkCardID =='' || remoteObject.LinkCardID == null ) ? remoteKanban.leankor__ValueStreamCardLink__c : remoteObject.LinkCardID ) ;
        SCP2.ValueStreamLinkBoardType = ((remoteObject.LinkBoardType == '' ||remoteObject.LinkBoardType == null )? remoteKanban.leankor__ValueStreamLink__r.leankor__Boardtype__c : remoteObject.LinkBoardType );
        SCP2.ValueStreamLinkID =  ((remoteObject.LinkVSID == '' || remoteObject.LinkVSID == null) ? remoteKanban.leankor__ValueStreamLink__c : remoteObject.LinkVSID);
        remoteKanban.leankor__ValueStreamLink__c = ((remoteObject.LinkVSID== '' || remoteObject.LinkVSID== null )?remoteKanban.leankor__ValueStreamLink__c :remoteObject.LinkVSID);       
        if(remoteObject.BoardType == 'Kanban Board' || remoteObject.BoardType == 'Plan Board'){
            if(remoteObject.ZoneForceID == null || remoteObject.ZoneForceID == ''){
                List<leankor__MasterContainer__C> mContainers = [SELECT Id,leankor__GUID__c,leankor__Order__c,leankor__Type__c FROM leankor__MasterContainer__c WHERE leankor__ValueStream__c =: remoteObject.newVSID ORDER BY leankor__Order__c ASC NULLS LAST LIMIT 9999];
                String Left_MC ='';
                if(mContainers.Size() >  0){
                    Left_MC = mContainers[0].Id; // Getting left most MC Id
                    for(leankor__MasterContainer__C m : mContainers){
                        if(m.leankor__Type__C == 'Backlog'){        
                            Left_MC = m.Id; // Getting backlog type MC Id
                        } //End of If
                    } // End of for loop
                } // End of If
                List<leankor__Swimlane__c> List_SW =[SELECT Id,Name,leankor__Order__c FROM leankor__Swimlane__c WHERE leankor__MasterContainer__c = :Left_MC and  leankor__ValueStream__c = :remoteObject.newVSID ORDER BY leankor__Order__c DESC  NULLS LAST limit 9999];
                String left_most_SW = List_SW[0].ID;
                List<leankor__Zone__c> List_zone =[SELECT Id,Name,leankor__Swimlane__c,leankor__Swimlane__r.leankor__MasterContainer__C,leankor__Order__c,leankor__GUID__c FROM leankor__Zone__c WHERE leankor__Swimlane__c= :left_most_SW  and  leankor__ValueStream__c = :remoteObject.newVSID ORDER BY leankor__Order__c ASC  NULLS LAST Limit 9999];
                String LM_Zone = List_zone[0].leankor__GUID__c;
                List<leankor__KanbanCard__c> List_Cards = [SELECT Id,name,leankor__Order__c,leankor__ValueStream__c,leankor__ZoneGUID__c FROM leankor__KanbanCard__c WHERE leankor__ZoneGUID__c = :LM_Zone and  leankor__ValueStream__c = :remoteObject.newVSID Order by leankor__Order__c DESC  NULLS LAST];
                remoteKanban.leankor__Order__C = (List_Cards.Size() > 0 ? List_Cards[0].leankor__Order__C : 0) + 1; 
                SCP2.ZoneID = LM_Zone;
                SCP2.MCForceID = Left_MC ;//List_zone[0].leankor__Swimlane__r.leankor__MasterContainer__C ;
                SCP2.SWForceID = left_most_SW ;//List_zone[0].leankor__Swimlane__c ;
                SCP2.ZoneForceID =List_zone[0].ID ;
                SCP2.ItemType = 'KC';
            }else{
                leankor__Zone__c ZoneLog = [SELECT Id, leankor__GUID__C, leankor__ValueStreamCardLink__c, leankor__ValueStreamLink__c, leankor__Swimlane__c, leankor__Swimlane__r.leankor__MasterContainer__C FROM leankor__Zone__c WHERE ID = :remoteObject.ZoneForceID];
                SCP2.ZoneID = ZoneLog.leankor__GUID__C;
                SCP2.MCForceID =  ZoneLog.leankor__Swimlane__r.leankor__MasterContainer__C;//List_zone[0].leankor__Swimlane__r.leankor__MasterContainer__C ;
                SCP2.SWForceID =  ZoneLog.leankor__Swimlane__c ;//List_zone[0].leankor__Swimlane__c ;
                SCP2.ZoneForceID = ZoneLog.ID ;
                SCP2.ItemType = 'KC';
            }
        }else{
            remoteKanban.leankor__ZoneGUID__C = '';
            SCP2.ZoneTitle = '';
            SCP2.LeavedZoneTitle = '';
            SCP2.LeavedZoneID = '';
            SCP2.ZoneID = '';
            SCP2.MCForceID = NULL ;//List_zone[0].leankor__Swimlane__r.leankor__MasterContainer__C ;
            SCP2.SWForceID = NULL;
            SCP2.ZoneForceID = NULL;
            SCP2.ItemType = 'KC'; 
        }    
        remoteKanban.leankor__ZoneGUID__C = SCP2.ZoneID;
        remoteKanban.leankor__MasterContainer__C = SCP2.MCForceID;
        remoteKanban.leankor__Swimlane__c = SCP2.SWForceID ;
        remoteKanban.leankor__Zone__c = SCP2.ZoneForceID;

        //Pratiksha : 01/Dec/2023 : Changes for WeekCalendar cloning card by multiSelect and Target board has 7 day workweek.
        Set<String> weekDays = new Set<String>();
        if(IStrgonseven == true){
            if(remoteKanban.leankor__Monday__c == false && remoteKanban.leankor__Tuesday__c == false && remoteKanban.leankor__Wednesday__c == false &&  remoteKanban.leankor__Thursday__c == false &&  remoteKanban.leankor__Friday__c == false &&  remoteKanban.leankor__Saturday__c == false &&  remoteKanban.leankor__Sunday__c == false){
                remoteKanban.leankor__Monday__c = true;
                remoteKanban.leankor__Tuesday__c = true;
                remoteKanban.leankor__Wednesday__c = true;
                remoteKanban.leankor__Thursday__c = true;
                remoteKanban.leankor__Friday__c = true;
                remoteKanban.leankor__Saturday__c = true;
                remoteKanban.leankor__Sunday__c = true;
                remoteKanban.leankor__weekCalendar__c = null;
            }else{
                weekDays.add(remoteKanban.leankor__Monday__c == false ? 'Mon' : 'false');
                weekDays.add(remoteKanban.leankor__Tuesday__c == false ? 'Tue' : 'false');
                weekDays.add(remoteKanban.leankor__Wednesday__c == false ? 'Wed' : 'false');
                weekDays.add(remoteKanban.leankor__Thursday__c == false ? 'Thu' : 'false');
                weekDays.add(remoteKanban.leankor__Friday__c == false ? 'Fri' : 'false');
                weekDays.add(remoteKanban.leankor__Saturday__c == false ? 'Sat' : 'false');
                weekDays.add(remoteKanban.leankor__Sunday__c == false ? 'Sun' : 'false');
            }
        }else{
            remoteKanban.leankor__Monday__c = true;
            remoteKanban.leankor__Tuesday__c = true;
            remoteKanban.leankor__Wednesday__c = true;
            remoteKanban.leankor__Thursday__c = true;
            remoteKanban.leankor__Friday__c = true;
            remoteKanban.leankor__Saturday__c = true;
            remoteKanban.leankor__Sunday__c = true;
            remoteKanban.leankor__weekCalendar__c = null;
        }
        Util.weekDays = weekDays;
        
        Integer ED =  integer.valueof(SCP2.EstimatedDuration);
        if(SCP2.DurationUnits == 'Hours'){
            if(math.mod(ED,8) > 0){
                ED= Integer.valueof(ED/8) + 1;
            }else{
                ED= Integer.valueof(ED/8);
            }
        }else if(SCP2.DurationUnits == 'Years'){
            ED= Integer.valueof(ED*365);
        }else if(SCP2.DurationUnits == 'Months'){
            ED= Integer.valueof(ED*30);
        }else if(SCP2.DurationUnits == 'Minutes'){
            integer temphours;
            if(math.mod(ED,60) >0 ){
                temphours= Integer.valueof(ED/60) + 1;
            }else{
                temphours= Integer.valueof(ED/60);
            }
            if(math.mod(temphours,8) >0){
                ED= Integer.valueof(temphours/8) + 1;
            }else{
                ED= Integer.valueof(temphours/8);
            }
        }else if(SCP2.DurationUnits == 'Weeks'){
            ED= Integer.valueof(ED*5);
        }

        // Date: 06/12/2019 - changes for blackout
        SCP2.StartDate = workWeek.getNextWorkingDay(SCP2.StartDate);
        Datetime tempcalDuedate = SCP2.StartDate;
        if(SCP2.DurationUnits == 'Years'){
            tempcalDuedate = tempcalDuedate.addYears(integer.valueof(SCP2.EstimatedDuration));
            tempcalDuedate = tempcalDuedate -1 ;
        }else if(SCP2.DurationUnits == 'Months'){
            tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(SCP2.EstimatedDuration));
            tempcalDuedate = tempcalDuedate -1 ;
        }else{
            
            ED = (ED == 0 || ED == null? 1: ED);
            tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, ED-1);
        }
        tempcalDuedate = workWeek.getNextWorkingDay(tempcalDuedate);
        remoteKanban.leankor__StartDateTime__c = SCP2.StartDate;
        remoteKanban.leankor__DueDateTime__c = tempcalDuedate;
        IsTaskcard = true;
        SCP2.DueDate =remoteKanban.leankor__DueDateTime__c;

        
        //Changes : Check constraint setting is enables and ALAP/ASAP card will be on ProjectNode dates of Target Board.
        if (remoteKanban.leankor__ScheduleModes__r.size() > 0 && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
            for(leankor__ScheduleMode__c schedulemode : remoteKanban.leankor__ScheduleModes__r){
                if(schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c == 'assoonaspossible'){
                    //Date: 06/12/2019 - changes for blackout
                    SCP2.StartDate = workWeek.getNextWorkingDay(newVSlog.leankor__ProjectBoardStartDateTime__c);
                    tempcalDuedate = SCP2.StartDate;
                    if(SCP2.DurationUnits == 'Years'){
                        tempcalDuedate = tempcalDuedate.addYears(integer.valueof(SCP2.EstimatedDuration));
                        tempcalDuedate = tempcalDuedate -1 ;
                    }else if(SCP2.DurationUnits == 'Months'){
                        tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(SCP2.EstimatedDuration));
                        tempcalDuedate = tempcalDuedate -1 ;
                    }else{
                        
                        ED = (ED == 0 || ED == null? 1: ED);
                        tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, ED-1);
                    }
                    tempcalDuedate = workWeek.getNextWorkingDay(tempcalDuedate);
                    remoteKanban.leankor__StartDateTime__c = SCP2.StartDate;
                    remoteKanban.leankor__DueDateTime__c = tempcalDuedate;
                    SCP2.DueDate =remoteKanban.leankor__DueDateTime__c;
                }

                if(schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c == 'aslateaspossible'){
                    SCP2.DueDate = workWeek.getNextWorkingDay(newVSlog.leankor__ProjectBoardEndDateTime__c);
                    Datetime tempcalstartdate = SCP2.DueDate;
                    if(SCP2.DurationUnits == 'Years'){
                        tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(SCP2.EstimatedDuration));
                        tempcalstartdate = tempcalstartdate +1 ;
                    }else if(SCP2.DurationUnits == 'Months'){
                        tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(SCP2.EstimatedDuration));
                        tempcalstartdate = tempcalstartdate +1 ;
                    }else{                                                         
                        // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                        ED = (ED == 0 ? 1: ED);                                                    
                        tempcalstartdate = workWeek.nextBusinessDate(tempcalstartdate, -(ED-1));      
                    }
                    SCP2.StartDate = workWeek.getPreviousWorkingDay(tempcalstartdate);
                    remoteKanban.leankor__StartDateTime__c = SCP2.StartDate;
                    remoteKanban.leankor__DueDateTime__c = SCP2.DueDate;
                }
            }
            //Set isIsConstraintRecalculate = true when we are hyper jump a card from another board.
            remoteKanban.leankor__IsConstraintRecalculate__c = true; 
            SCP2.isConstraintRecalculate = true;
        }

        /**

        if(!IStrgonseven){ //5
            if(ISoldonseven){ //7
            // Date: 12/6/2019 - 
            SCP2.StartDate = 
        	Datetime tempcalDuedate = SCP2.StartDate;
                if(SCP2.DurationUnits == 'Weeks'){
                    ED = integer.valueof(SCP2.EstimatedDuration)*5;
                }
                if(SCP2.DurationUnits == 'Years'){
                tempcalDuedate = tempcalDuedate.addYears(integer.valueof(SCP2.EstimatedDuration));
                tempcalDuedate = tempcalDuedate -1 ;
            }else if(SCP2.DurationUnits == 'Months'){
                tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(SCP2.EstimatedDuration));
                tempcalDuedate = tempcalDuedate -1 ;
            }else{
                for(integer i = 1 ;i<ED;i++ ){
                    tempcalDuedate = tempcalDuedate+1;
                    //ss 05.03.2018
                    //Call for method to Get working day escaping non working day
						tempcalDuedate = Util.readNextWorkingDateTime(workWeek,tempcalDuedate);
                    /*if(tempcalDuedate.format('E') == 'Sat' || tempcalDuedate.format('E') == 'Sun'){
                        tempcalDuedate = tempcalDuedate+1;
                    }
                    if(tempcalDuedate.format('E') == 'Sat' || tempcalDuedate.format('E') == 'Sun'){
                        tempcalDuedate = tempcalDuedate+1;
                    }*/
                    //ss 05.03.2018
                //}
            //}
			//ss 05.03.2018
			//Get non working days of week
        	/**Map<String, Integer> mapNonWorkingDays= workWeek.readNonWorkingDays();        	
			//Check SCP2.StartDate is not in working days and non working day 1st or 2nd
            if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(SCP2.StartDate.format('EEEE')) == 1)){
                    SCP2.StartDate = SCP2.StartDate + 2;
                    if(ED==1){
                    tempcalDuedate = tempcalDuedate + 2;
                    }else{
                    tempcalDuedate = tempcalDuedate + 1;
                    }
            }else if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(SCP2.StartDate.format('EEEE')) == 2)){
                    SCP2.StartDate = SCP2.StartDate + 1;
                tempcalDuedate = tempcalDuedate + 1;                                
                }
            //Call for method to Get working day escaping non working day
				tempcalDuedate = Util.readNextWorkingDateTime(workWeek,tempcalDuedate);
            /*if(SCP2.StartDate.format('E') == 'sat'){
                SCP2.StartDate = SCP2.StartDate + 2;
                if(ED==1){
                    tempcalDuedate = tempcalDuedate + 2;
                }else{
                    tempcalDuedate = tempcalDuedate + 1;
                }
            }else if(SCP2.StartDate.format('E') == 'Sun'){
                SCP2.StartDate = SCP2.StartDate + 1;
                tempcalDuedate = tempcalDuedate + 1;                                
                }
            if(tempcalDuedate.format('E') == 'Sat' || tempcalDuedate.format('E') == 'Sun'){
                tempcalDuedate = tempcalDuedate+1;
            }
            if(tempcalDuedate.format('E') == 'Sat' || tempcalDuedate.format('E') == 'Sun'){
                tempcalDuedate = tempcalDuedate+1;
            }*/
            
            //ss 05.03.2018
             /**   remoteKanban.leankor__StartDateTime__c = SCP2.StartDate;
            remoteKanban.leankor__DueDateTime__c = tempcalDuedate; 
                IsTaskcard = true;
                SCP2.DueDate =remoteKanban.leankor__DueDateTime__c;
            }            
        }else if(IStrgonseven){//7
            if(!ISoldonseven){ // 5
                if(SCP2.DurationUnits == 'Weeks'){
                    ED= Integer.valueof(SCP2.EstimatedDuration*7);
                }
            Datetime tempcalDuedate = SCP2.StartDate;
            if(SCP2.DurationUnits == 'Years'){
                tempcalDuedate = tempcalDuedate.addYears(integer.valueof(SCP2.EstimatedDuration));
                tempcalDuedate = tempcalDuedate -1 ;
            }else if(SCP2.DurationUnits == 'Months'){
                tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(SCP2.EstimatedDuration));
                tempcalDuedate = tempcalDuedate -1 ;
            }else{
                for(integer i = 1 ;i<ED;i++ ){
                    tempcalDuedate = tempcalDuedate+1;
                }
            }
            remoteKanban.leankor__StartDateTime__c = SCP2.StartDate;
            remoteKanban.leankor__DueDateTime__c = tempcalDuedate;
                IsTaskcard = true;
                SCP2.DueDate =remoteKanban.leankor__DueDateTime__c;
            }            
        }
        */

        try{
            Update remoteKanban;
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            return 'Failed';
        }
        if(IsTaskcard || TBtaskchecker){
            List<task> Tsklogs = new List<task>();
            //leankor__KanbanCard__c Cardwithtask = [select Id,leankor__Valuestream__r.leankor__TaskDateCheck__c,leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,leankor__StartDateTime__c,leankor__DueDateTime__c,(Select Id,ActivityDate from Tasks where IsDeleted = false) from leankor__KanbanCard__c where ID = :remoteKanban.ID All Rows];
            //Removed subquery for Task object
            try{
                leankor__KanbanCard__c Cardwithtask = [SELECT Id, 
                                                            leankor__Valuestream__r.leankor__TaskDateCheck__c, 
                                                            leankor__Valuestream__r.leankor__SevenDayWorkWeek__c, 
                                                            leankor__StartDateTime__c,
                                                            leankor__DueDateTime__c 
                                                            FROM leankor__KanbanCard__c 
                                                            WHERE ID = :remoteKanban.ID];
	            //SS 28.03.2018
	            //Modifications to allow query on archived Task records and to increase efficiency of queries involving Task object 
                for(Task Tsk :[SELECT Id,
                                        ActivityDate 
                                    FROM Task 
                                    WHERE What.Type = 'leankor__KanbanCard__c' 
                                        AND IsDeleted = false 
                                        AND WhatId =:Cardwithtask.Id 
                                    LIMIT 9999 All Rows]){
	                if(Tsk.ActivityDate!=null){
		                datetime TskDuedate = Datetime.newInstance(Tsk.ActivityDate.year(),Tsk.ActivityDate.month(),Tsk.ActivityDate.day(), 1, 1, 1);
                    //ss 05.03.2018
                    if((!Cardwithtask.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c)){
                    	
                        //Get Working days escaping non working days for Task
							Tsk.ActivityDate = Util.readNextWorkingDate(workWeek,TskDuedate,Tsk.ActivityDate);
                    }
                    /*if((!Cardwithtask.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) && TskDuedate.format('E') == 'Sat'){
		                    Tsk.ActivityDate = Tsk.ActivityDate + 2;
		                }else if((!Cardwithtask.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) && TskDuedate.format('E') == 'Sun'){
		                    Tsk.ActivityDate = Tsk.ActivityDate + 1;
                    }*/
                    //ss 05.03.2018
		                if(Tsk.ActivityDate > Date.valueOf(Cardwithtask.leankor__DueDateTime__c)&& Cardwithtask.leankor__Valuestream__r.leankor__TaskDateCheck__c ){
		                    Tsk.ActivityDate = Date.valueOf(Cardwithtask.leankor__DueDateTime__c);
		                }else if (Tsk.ActivityDate < Date.valueOf(Cardwithtask.leankor__StartDateTime__c)&& Cardwithtask.leankor__Valuestream__r.leankor__TaskDateCheck__c){
		                    Tsk.ActivityDate = Date.valueOf(Cardwithtask.leankor__StartDateTime__c);
		                }
		                Tsklogs.add(tsk);
	                }
	            }    
	            /*for(Task Tsk :Cardwithtask.Tasks){
	                datetime TskDuedate = Datetime.newInstance(Tsk.ActivityDate.year(),Tsk.ActivityDate.month(),Tsk.ActivityDate.day(), 1, 1, 1);
	                if((!Cardwithtask.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) && TskDuedate.format('E') == 'Sat'){
	                    Tsk.ActivityDate = Tsk.ActivityDate + 2;
	                }else if((!Cardwithtask.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) && TskDuedate.format('E') == 'Sun'){
	                    Tsk.ActivityDate = Tsk.ActivityDate + 1;
	                }
	                if(Tsk.ActivityDate > Date.valueOf(Cardwithtask.leankor__DueDateTime__c)&& Cardwithtask.leankor__Valuestream__r.leankor__TaskDateCheck__c ){
	                    Tsk.ActivityDate = Date.valueOf(Cardwithtask.leankor__DueDateTime__c);
	                }else if (Tsk.ActivityDate < Date.valueOf(Cardwithtask.leankor__StartDateTime__c)&& Cardwithtask.leankor__Valuestream__r.leankor__TaskDateCheck__c){
	                    Tsk.ActivityDate = Date.valueOf(Cardwithtask.leankor__StartDateTime__c);
	                }
	                Tsklogs.add(tsk);
	            }*/
	            //SS 28.03.2018
            } catch(QueryException ex)
            {
            	System.debug('Error : '+ex.getMessage());
            	//return 'No Task';
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            try{
                //Update Tsklogs;
                leankor.OpenTaskRestriction.updateTask(Tsklogs);
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
            	//return 'Failed';
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }
        SCP2.BoardType=newVSlog.leankor__BoardType__c;
        SCP2.SWeek = newVSlog.leankor__SevenDayWorkWeek__c;
        SCP2.ValueStream = remoteObject.newVSID;
        //SCP2.ValueStreamName = newVSlog.Name;
        SCP2.TemplateID = remoteObject.TemplateID;
        SCP2.ValueStreamOld= oldVS.ID;
        
        List<leankor__KanbanCard__c> HyperJumpCards = new List<leankor__KanbanCard__c>();
        HyperJumpCards.add(remoteKanban);
        
        // Tilak:27.05.2020
        // leankor.realtimeController.KCupdatePVcard(JSON.serialize(HyperJumpCards));
        leankor.RealTimeController.updateParentCards(HyperJumpCards);
	    
	    //yj-2 Nov 2017
	    changeValueStreamOnHyperJump(HyperJumpCards,remoteObject.newVSID);
        //21/Dec/2023 :updating isSuccessorRecalculate field for parent card.
        leankor.RealTimeController.updateIsSuccessorRecalculate(cardLinksIds);
		
	    //26.09.2017 : for Generic Streamin and Bulk call
        SCP2.successorsArray = JSON.serialize(leankor.RealTimeController.gskanbanCardIds);
        leankor.RealTimeController.gskanbanCardIds.clear();
        
        // Ashutosh : 23/02/2021 - Fixes added for "Send broadcast message after successfully record save".
        leankor.RealTimeController.kanbanStateChange(remoteObject.oldVSID, 'Hyper-leave',ServerSessionID, SomeJSONData_m);  // broadcasting to current board.

        SomeJSONData_m = JSON.serialize(SCP2);
		
        leankor.RealTimeController.kanbanStateChange(remoteObject.newVSID, 'Hyper-arrive',ServerSessionID, SomeJSONData_m);  
        return SomeJSONData_m;
    }//End of Method
    //
    // This Inner Method Is Use for Cloneing Card Records .
    //
    
    
    /*------------------------------------------------------------
    Author:         Yash
    Company:        Leankor
    Description:    updating parent card valuestreamLink when card is hyperjump to another board
    Inputs:         List of kanbanCards and new valuestream Id
    Returns:        void
	------------------------------------------------------------*/
    public static void changeValueStreamOnHyperJump(List<leankor__KanbanCard__c> kanbanCards , String newVSID){
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
       
        try{
            List<leankor__KanbanCard__c> kcList = new List<leankor__KanbanCard__c>();
            List < leankor.realtimeController.bulkStreaming > ListJSONrecords = New List < leankor.realtimeController.bulkStreaming > ();
            Set<String> kanbanCardIds = new Set<String>();
            for(leankor__KanbanCard__c kc : [SELECT Id,
                                                leankor__ValueStream__c, 
                                                leankor__ValueStreamLink__c 
                                            FROM leankor__KanbanCard__c 
                                            WHERE leankor__ValueStreamCardLink__c IN: kanbanCards 
                                            LIMIT 9999]){
                kc.leankor__ValueStreamLink__c = newVSID;
	       		kcList.add(kc);
	       		 
	       		leankor.realTimeController.CardStreamingPackage RemoteKanban = new leankor.realTimeController.CardStreamingPackage();
				               
                kanbanCardIds.add(kc.Id);
				               
                RemoteKanban.Id = kc.Id;                        
                RemoteKanban.Verb = 'UpdateMultipleKanbanCards';    
	
			    //broadcasting for other Board when card is hyperjump so valuestream will be change 
                /*leankor.realtimeController.bulkStreaming ListJSONLog = New leankor.realtimeController.bulkStreaming();

	            ListJSONLog.SomeJSONData = JSON.Serialize(RemoteKanban);
                ListJSONLog.VSID =  kc.leankor__ValueStream__c;                    
                ListJSONLog.SessionID = userinfo.getsessionID();
                ListJSONLog.Verb = 'UpdateMultipleKanbanCards';*/
                  					
                //ListJSONrecords.add(ListJSONLog);
	        }	       	       	       	       
	        update kcList;	       
            
            RealTimeController.BroadcastEventPayload broadcastEventPayload = new RealTimeController.BroadcastEventPayload();
            broadcastEventPayload.cardIds = kanbanCardIds;

            //broadcasting for other Board when card is hyperjump so valuestream will be change 
            leankor.realtimeController.bulkStreaming ListJSONLog = New leankor.realtimeController.bulkStreaming();

            ListJSONLog.SomeJSONData = JSON.Serialize(broadcastEventPayload);                  
            ListJSONLog.SessionID = userinfo.getsessionID();
            ListJSONLog.Verb = 'UpdateMultipleKanbanCards'; 
            ListJSONrecords.add(ListJSONLog);

	        leankor.realtimeController.defaultLinkBroadcasting(ListJSONrecords, 'UpdateMultipleKanbanCards');
        }catch(Exception ex){
    		//return;
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
    }


    @RemoteAction
    Global static String CloneKanbanCard(ID VSID, String FinalDate,Boolean TaskVerb, String someJSONData,String mySessionID){
        //Check CRUD / FLC behavior 
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ProjectScheduleBlackoutBehaviour ProjectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour(); 
        if (
            !valueStreamBehavior.isAccessible() ||
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isCreateable() ||
            !ProjectScheduleBlackoutBehaviour.isAccessible() ||
            !scheduleModeBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isAccessible() ||
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isCreateable() ||
            !feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
    	
        String oldKanbanID = '';
        Integer otherDifference = 0;
        Datetime TempFinalDate = (DateTime)JSON.deserialize(FinalDate, DateTime.class);//DateTime.ValueOf(FinalDate); // Change latter >> need to update this string to date time as input.
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(SomeJSONData, leankor.RealTimeController.Kanban.class);
        oldKanbanID = remoteKanban.Id;

        /**Variables for cloning constraqint data */
        Integer startDateConstraintDifference = 0;
        Integer dueDateconstraintDifference = 0;
        String tempConstraintType = remoteKanban.ConstraintType;
        
        remoteKanban.GUID = oldKanbanID +'-'+system.now().gettime();
        Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = GanttTaskBoard.getScheduleConstraints();
            
        //RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries    
        //Map<Id,User> allUserMap = getAllUser();
          
        //getting card's RA and SM records for cloning
        //RS 28/11/2019 Added Owner.IsActive to query
        Map<Id, leankor__KanbanCard__C> mapOfRemoteKanbanCards = new Map<Id, leankor__KanbanCard__C>([Select Id,
                                                                                                            leankor__HarveyBallDoneDate__c,
                                                                                                            leankor__PromiseCompletionDate__c,
                                                                                                            leankor__ValueStreamLink__c,
                                                                                                            leankor__ValueStreamCardLink__c,
                                                                                                            leankor__StartDateTime__C,
                                                                                                            leankor__DueDateTime__C,
                                                                                                            (Select Id,
                                                                                                                    leankor__ManuallyScheduled__c,
                                                                                                                    leankor__Mode__c,
                                                                                                                    leankor__EffortUnits__c,
                                                                                                                    leankor__EffortActual__c,
                                                                                                                    leankor__KanbanCard__c,
                                                                                                                    leankor__KanbanCard__r.leankor__valuestream__c,
                                                                                                                    leankor__ConstraintDateTime__c,
                                                                                                                    leankor__ScheduleConstraint__r.leankor__Type__c
                                                                                                                    //leankor__Readonly__c
                                                                                                                From leankor__ScheduleModes__r 
                                                                                                                Limit 1),
                                                                                                            (Select 
                                                                                                                    Id,
                                                                                                                    leankor__AssignedTo__c,
                                                                                                                    leankor__KanbanCard__c,
                                                                                                                    leankor__CompletedDate__c,
                                                                                                                    leankor__KanbanCard__r.leankor__valuestream__c,
                                                                                                                    leankor__PercentAllocation__c,
                                                                                                                    leankor__PercentCompleted__c,
                                                                                                                    Name,
                                                                                                                    leankor__ExpenseAccount__c,
                                                                                                                    leankor__ExpenseSubCategory__c,
                                                                                                                    leankor__ExpenseCategory__c,
                                                                                                                    leankor__ExternalHourlyRate__c,
                                                                                                                    leankor__InternalHourlyRate__c,
                                                                                                                    leankor__ResourceType__c,
                                                                                                                    leankor__ProjectFinancial__c,
                                                                                                                    leankor__AssignedTo__r.IsActive                            
                                                                                                                From leankor__ResourceAssignments__r),                               
                                                                                                             RecordType.Name,
                                                                                                             leankor__CardID__c,
                                                                                                             leankor__valueStream__r.leankor__BoardType__c,
                                                                                                             leankor__valueStream__r.leankor__SevenDayWorkWeek__c,
                                                                                                             leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                                                                            Owner.IsActive,
                                                                                                            leankor__Monday__c,
                                                                                                            leankor__Tuesday__c,
                                                                                                            leankor__Wednesday__c,
                                                                                                            leankor__Thursday__c,
                                                                                                            leankor__Friday__c,
                                                                                                            leankor__Saturday__c,
                                                                                                            leankor__Sunday__c,
                                                                                                            leankor__WeekCalendar__c                                          
                                                                                                    From leankor__KanbanCard__c 
                                                                                                    Where Id = :remoteKanban.Id
                                                                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
                                                                                                        And leankor__IsRecordDeleted__c = false
                                                                                                    Order By leankor__Order__c Desc Nulls Last
                                                                                                    Limit 9999]);
        String stringWithQuotes;
        stringWithQuotes = '\'' + oldKanbanID + '\'';

        Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();
        Map<Id, leankor__KanbanCard__C> kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__C>();
        List<String> cardIdList = new List<String>{remoteKanban.Id};
        KanbanController.FieldSetRecord singleFieldSetRecord = KanbanController.getAllFieldsetAndFieldDataForCloning(cardIdList, 'leankor__KanbanCard__c');

        if(singleFieldSetRecord.allFields.size() > 0){
            String soql ='Select Id'+ singleFieldSetRecord.allFieldsInStringFormat + ' From leankor__KanbanCard__c Where Id In ('+stringWithQuotes+') Limit 50000';
            kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__c>((List<leankor__KanbanCard__c>)Database.query(soql));
        }
        if (mapOfRemoteKanbanCards.values().size() == 0) {
			return 'failure';
		}

        //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar While Cloning the KanbanCard from UI and API also.
        Set<String> weekDays = new Set<String>();
        if(mapOfRemoteKanbanCards.values().leankor__valueStream__r.leankor__SevenDayWorkWeek__c){
            //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar
            if(mapOfRemoteKanbanCards.values().leankor__Monday__c == false && mapOfRemoteKanbanCards.values().leankor__Tuesday__c == false && mapOfRemoteKanbanCards.values().leankor__Wednesday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Thursday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Friday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Saturday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Sunday__c == false){
                remoteKanban.Monday = true;
                remoteKanban.Tuesday = true;
                remoteKanban.Wednesday = true;
                remoteKanban.Thursday = true;
                remoteKanban.Friday = true;
                remoteKanban.Saturday = true;
                remoteKanban.Sunday = true;
            }else{
                remoteKanban.Monday = mapOfRemoteKanbanCards.values().leankor__Monday__c;
                remoteKanban.Tuesday = mapOfRemoteKanbanCards.values().leankor__Tuesday__c;
                remoteKanban.Wednesday = mapOfRemoteKanbanCards.values().leankor__Wednesday__c;
                remoteKanban.Thursday = mapOfRemoteKanbanCards.values().leankor__Thursday__c;
                remoteKanban.Friday = mapOfRemoteKanbanCards.values().leankor__Friday__c;
                remoteKanban.Saturday = mapOfRemoteKanbanCards.values().leankor__Saturday__c;
                remoteKanban.Sunday = mapOfRemoteKanbanCards.values().leankor__Sunday__c;
                remoteKanban.weekCalendar = mapOfRemoteKanbanCards.values().leankor__WeekCalendar__c;
            
                weekDays.add(remoteKanban.Monday == false ? 'Mon' : 'false');
                weekDays.add(remoteKanban.Tuesday == false ? 'Tue' : 'false');
                weekDays.add(remoteKanban.Wednesday == false ? 'Wed' : 'false');
                weekDays.add(remoteKanban.Thursday == false ? 'Thu' : 'false');
                weekDays.add(remoteKanban.Friday == false ? 'Fri' : 'false');
                weekDays.add(remoteKanban.Saturday == false ? 'Sat' : 'false');
                weekDays.add(remoteKanban.Sunday == false ? 'Sun' : 'false');
            }
        }    
        Util.weekDays = weekDays;

        // getting the schedulemode records because removing the hardcode
        Map<Id, leankor__ScheduleMode__c> mapOfScheduleMode = new Map<Id, leankor__ScheduleMode__c>();
        for(leankor__ScheduleMode__c schedulemode : mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ScheduleModes__r){
            mapOfScheduleMode.put(schedulemode.Id, schedulemode);
            //Changes : Check constraint setting is enables or not.
            if (mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ScheduleModes__r.size() > 0 && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                remoteKanban.ConstraintDate = remoteKanban.ConstraintDate == null ? mapOfScheduleMode.get(schedulemode.Id).leankor__ConstraintDateTime__c : remoteKanban.ConstraintDate;
                tempConstraintType = tempConstraintType == null ? mapOfScheduleMode.get(schedulemode.Id).leankor__ScheduleConstraint__r.leankor__Type__c : tempConstraintType;
            }
        }
        /**SS 07.05.2018
        Note - Using Date.valueOf() we are loosing time value of DateTime variable. So New dates are created using year,Month, Day**/ 
        //otherDifference =(Date.valueOf(remoteKanban.DueDate)).daysBetween(Date.valueOf(TempFinalDate));//Integer.ValueOf(remoteKanban.EstimatedDuration) - otherDifference;
        otherDifference =(Date.newInstance(remoteKanban.DueDate.year(),remoteKanban.DueDate.month(),remoteKanban.DueDate.day())).daysBetween(Date.newInstance(TempFinalDate.year(),TempFinalDate.month(),TempFinalDate.day()));
        
        /**finding diffrence startdate/dueDate with ConstraintDate */
        startDateConstraintDifference=remoteKanban.ConstraintDate != null ? (Date.newInstance(remoteKanban.StartDate.year(),remoteKanban.StartDate.month(),remoteKanban.StartDate.day())).daysBetween(Date.newInstance(remoteKanban.ConstraintDate.year(),remoteKanban.ConstraintDate.month(),remoteKanban.ConstraintDate.day())) : 0;
        dueDateconstraintDifference = remoteKanban.ConstraintDate != null ? (Date.newInstance(remoteKanban.DueDate.year(),remoteKanban.DueDate.month(),remoteKanban.DueDate.day())).daysBetween(Date.newInstance(remoteKanban.ConstraintDate.year(),remoteKanban.ConstraintDate.month(),remoteKanban.ConstraintDate.day())) : 0;

        /**SS 07.05.2018**/
        if(remoteKanban.DueDate < TempFinalDate){
            remoteKanban.StartDate = remoteKanban.StartDate + math.abs(otherDifference) ;
        }else{ 
            remoteKanban.StartDate = remoteKanban.StartDate -  math.abs(otherDifference) ;//remoteKanban.DueDate - remoteKanban.EstimatedDuration;
        }
        remoteKanban.StartDate = Datetime.newInstance(remoteKanban.StartDate.year(),remoteKanban.StartDate.month(), remoteKanban.StartDate.day(),TempFinalDate.hour(),TempFinalDate.minute(),TempFinalDate.second());
        // 11/04/2023 : Time will be Cloned while cloning the card From API
        remoteKanban.DueDate = Datetime.newInstance(TempFinalDate.year(),TempFinalDate.month(), TempFinalDate.day(),mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__DueDateTime__C.hour(),mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__DueDateTime__C.minute(),mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__DueDateTime__C.second());
        
        //remoteKanban.DueDate = TempFinalDate;
        if(remoteKanban.Left != null){
            remoteKanban.Left += remoteKanban.Width+3;
        }
        leankor__valuestream__c VS = [SELECT ID,
                                        leankor__SevenDayWorkWeek__c,
                                        leankor__TaskDatecheck__c 
                                    FROM leankor__valuestream__c 
                                    WHERE ID= :VSID 
                                    LIMIT 1];

        // Date: 05/11/2019 - Changes related to black out
        // Getting the existing Project Schedule Blackout records. 
        List<leankor__ProjectScheduleBlackout__c> blackOutList = [SELECT Id,
                                                                        leankor__EndDate__c,
                                                                        leankor__StartDate__c
                                                                    FROM leankor__ProjectScheduleBlackout__c
                                                                    WHERE leankor__ProjectBoard__c =: VS.Id
                                                                    LIMIT 9999 ];
       
        //SS 03.05.2018
        //Get first day of week from Custom Setting
        Integer firstDayOfWeek =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c == null ?1 : leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c.intValue();   
        firstDayOfWeek= firstDayOfWeek==null || firstDayOfWeek<0  || firstDayOfWeek > 6?1:firstDayOfWeek;
        //Create instance of WorkWeek which provides Working week days information
        // Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, VS.leankor__SevenDayWorkWeek__c? 7: 5, blackOutList); // Changes for blackout 
        //SS 03.05.2018


        //In case if due date occured on non-working day.
        remoteKanban.DueDate = workWeek.getNextWorkingDay(remoteKanban.DueDate);
        Datetime tempcalstartdate = remoteKanban.DueDate; 

        // Calculation of Estimated Duration
        Integer ED =  integer.valueof(remoteKanban.EstimatedDuration);
        if(remoteKanban.DurationUnits == 'Hours'){
            if(math.mod(ED,8) > 0){
                ED= Integer.valueof(ED/8) + 1;
            }else{
                ED= Integer.valueof(ED/8);
            }
        }else if(remoteKanban.DurationUnits == 'Years'){
            ED= Integer.valueof(ED*365);
        }else if(remoteKanban.DurationUnits == 'Months'){
            ED= Integer.valueof(ED*30);
        }else if(remoteKanban.DurationUnits == 'Minutes'){
            integer temphours;
            if(math.mod(ED,60) >0 ){
                temphours= Integer.valueof(ED/60) + 1;
            }else{
                temphours= Integer.valueof(ED/60);
            }
            if(math.mod(temphours,8) >0){
                ED= Integer.valueof(temphours/8) + 1;
            }else{
                ED= Integer.valueof(temphours/8);
            }
        }else if(remoteKanban.DurationUnits == 'Weeks'){
            ED= Integer.valueof(ED*5);
        }
        if(!VS.leankor__SevenDayWorkWeek__c){
            if(remoteKanban.DurationUnits == 'Months'){
                ED= Integer.valueof(remoteKanban.EstimatedDuration*20);
            }
            if(remoteKanban.DurationUnits == 'Years'){
                tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(remoteKanban.EstimatedDuration));
                tempcalstartdate = tempcalstartdate +1 ;
            }else if(remoteKanban.DurationUnits == 'Months'){
                tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(remoteKanban.EstimatedDuration));
                tempcalstartdate = tempcalstartdate +1 ;
            }else{ 

                // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                ED = (ED == 0 || ED == null ? 1: ED);
                
                // Date: 14/11/2019 
                tempcalstartdate = workWeek.nextBusinessDate(tempcalstartdate, -(ED-1));
                /**for(integer i = 1 ;i< ED; i++){
                    tempcalstartdate = tempcalstartdate-1;
                //ss 03.05.2018
                //Call for method to Get working day escaping non working days
					tempcalstartdate = Util.readPreviousWorkingDateTime(workWeek,tempcalstartdate);
                    
                /*if(tempcalstartdate.format('E') == 'Sat' || tempcalstartdate.format('E') == 'Sun'){
                        tempcalstartdate = tempcalstartdate-1;
                    }
                    if(tempcalstartdate.format('E') == 'Sat' || tempcalstartdate.format('E') == 'Sun'){
                        tempcalstartdate = tempcalstartdate-1;
                }*/
                //}
                    }

            remoteKanban.StartDate = workWeek.getPreviousWorkingDay(tempcalstartdate);
            TempFinalDate = remoteKanban.DueDate;

        }else{
            
        Datetime tempcalDuedate = remoteKanban.DueDate;
            if(remoteKanban.DurationUnits == 'Weeks'){
                ED= Integer.valueof(remoteKanban.EstimatedDuration*7);
            }
            if(remoteKanban.DurationUnits == 'Years'){
            tempcalDuedate = tempcalDuedate.addYears(-integer.valueof(remoteKanban.EstimatedDuration));
            tempcalDuedate = tempcalDuedate +1 ;
        }else if(remoteKanban.DurationUnits == 'Months'){
            tempcalDuedate = tempcalDuedate.addMonths(-integer.valueof(remoteKanban.EstimatedDuration));
            tempcalDuedate = tempcalDuedate +1 ;
        }else{ 

                // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                ED = (ED == 0 ? 1: ED);

                // Date: 14/11/2019 
                tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, -(ED-1));
                /**for(integer i = 1 ;i<ED;i++ ){
                tempcalDuedate = tempcalDuedate-1;
                }*/
            }
        	remoteKanban.StartDate = workWeek.getPreviousWorkingDay(tempcalDuedate);
            TempFinalDate = remoteKanban.DueDate;
        }  
        //adding RA and SM reocords
        remoteKanban.schedulemodeList = mapOfRemoteKanbanCards.values().leankor__ScheduleModes__r;
		remoteKanban.resourceAssignmentList = mapOfRemoteKanbanCards.values().leankor__ResourceAssignments__r;
		
		// yj : 06 Nov. 2017 Checking user is active or not. No Need to code here
        //remoteKanban.OwnerId = allUserMap.get(remoteKanban.OwnerId).IsActive ? remoteKanban.OwnerId : UserInfo.getUserId();
        //remoteKanban.OwnerId = allUserMap.containsKey(remoteKanban.OwnerId) ? UserInfo.getUserId() : remoteKanban.OwnerId;
        // yj : 06 Nov. 2017
        
         // YJ 21.11.2017 cloning harveyballdonedate and PromiseCompletionDate
        RemoteKanban.HarveyBallDoneDate = mapOfRemoteKanbanCards.values().leankor__HarveyBallDoneDate__c;
        RemoteKanban.PromiseCompletionDate = mapOfRemoteKanbanCards.values().leankor__PromiseCompletionDate__c;
        
        // Date : 22/10/19 using wrapper class instance instead of Serialization.              
        //List<String> KanbanList = new List<String>();
        List<RealTimeController.Kanban> kanbanList = new List<RealTimeController.Kanban>();
        //KanbanList.add(JSON.Serialize(remoteKanban));
       	//RS 28/11/2019 Added Owner.IsActive in object
    	RemoteKanban.ownerIsActive = mapOfRemoteKanbanCards.values().Owner.IsActive;  	

        /**setting Constraint values null */
        RemoteKanban.ConstraintDate = null;
        RemoteKanban.ConstraintType = null;
        /**calculating the constraintDates with startDate/dueDate if constraint type is not null or blank*/
        //Changes : Check constraint setting is enabel or not.
        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
            if (String.isNotBlank(tempConstraintType)) {
                RemoteKanban.ConstraintType = scheduleConstraints.get(tempConstraintType).Id;
                //RemoteKanban.ConstraintDate = (new List<String>{'startnoearlierthan','startnolaterthan','muststarton'}.contains(tempConstraintType)) ? RemoteKanban.StartDate + startDateConstraintDifference : RemoteKanban.DueDate + dueDateConstraintDifference;
                RemoteKanban.ConstraintDate = (new List<String>{'aslateaspossible','assoonaspossible'}.contains(tempConstraintType)) ? null : (new List<String>{'startnoearlierthan','startnolaterthan','muststarton'}.contains(tempConstraintType)) ? RemoteKanban.StartDate + startDateConstraintDifference :RemoteKanban.DueDate + dueDateconstraintDifference;
            }
            RemoteKanban.isConstraintRecalculate = true;
        }
        // 05/04/2023 added code for SingleClone API To Check Constraint Violation
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        KanbanController.KanbanCardConstraintViolation violationResult = new KanbanController.KanbanCardConstraintViolation();
        if(String.isNotBlank(remoteKanban.ValueStreamLinkID) && String.isNotBlank(remoteKanban.ValueStreamCardLink)){
            KanbanCard checkCard = new KanbanCard();
            checkCard.name = remoteKanban.Name;
            checkCard.valueStream = remoteKanban.ValueStream;
            checkCard.startDateTime = remoteKanban.StartDate;
            checkCard.dueDateTime = remoteKanban.DueDate;
            checkCard.valueStreamLink = remoteKanban.ValueStreamLinkID; //remoteObject.LinkVSID;
            checkCard.valueStreamCardLink = remoteKanban.ValueStreamCardLink;//remoteObject.LinkCardID;
            checkCard.isUpdateValueStreamCardLink = true;
            //We are commenting this code because we don't need to check constraint on source card and we are also not passing Id of KanbanCard.
            /*if(remoteKanban.ValueStreamLinkID != mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ValueStreamLink__c
               || remoteKanban.ValueStreamCardLink != mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ValueStreamCardLink__c
            ){
                checkCard.isUpdateValueStreamCardLink = true;
            }*/
            cardsToCheck.add(checkCard);
        }
        //18/05/23 : Pratiksha : Previously we were checking constraint violation while cloning the card(ASAP/ALAP) but now we will clone card on same date, if card has ASAP/ALAP.
        if(new List<String>{'assoonaspossible','aslateaspossible'}.contains(tempConstraintType) && KanbanController.isCalledFromSingleCloneAPI){
            remoteKanban.StartDate = mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__StartDateTime__c;
            remoteKanban.DueDate = mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__DueDateTime__c;
            /*KanbanCard checkCard = new KanbanCard();
            checkCard.Id = remoteKanban.Id;
            checkCard.name = remoteKanban.Name;
            checkCard.valueStream = remoteKanban.ValueStream;
            checkCard.startDateTime = remoteKanban.StartDate;
            checkCard.dueDateTime = remoteKanban.DueDate;
            checkCard.valueStreamLink = null; //remoteObject.LinkVSID;
            checkCard.valueStreamCardLink = null;//remoteObject.LinkCardID;
            checkCard.isUpdateValueStreamCardLink = false;
            cardsToCheck.add(checkCard);*/
        }

        Leankor__KanbanCard__c kanbanCardRecord = mapOfRemoteKanbanCards.values();
        remoteKanban.kanbanCustomField = new leankor__KanbanCard__c();	// Initialization of inner class variable
        //if(kanbanCardRecord.leankor__valuestream__r.leankor__boardtype__c == 'UberBoard'){
        if(kanbanCardRecord.leankor__valuestream__r.leankor__boardtype__c == 'UberBoard' || kanbanCardRecord.leankor__valuestream__r.leankor__boardtype__c == 'Kanban Board'){
            if(kanbaCardIdandFields.containsKey(kanbanCardRecord.Id)){
                remoteKanban.kanbanCustomField = kanbaCardIdandFields.get(kanbanCardRecord.Id);
                remoteKanban.kanbanCustomField.Id = null;
            }
        }
        else{
            if(kanbaCardIdandFields.get(kanbanCardRecord.Id)!=null){
                //Map<String, Object> fieldsToValue = kanbaCardIdandFields.get(kanbanCardRecord.Id).getPopulatedFieldsAsMap();
                if(String.isNotBlank(kanbanCardRecord.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)){// Checking  fieldset on the category.
                    //19/04/2023 : If any fieldSet is already deleted then we were facing ("Attempt to de-reference a null object") so we are preventing by adding the condition.
                    if(fieldSetMap.get(String.valueOf(kanbanCardRecord.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)) != null){
                        Map<String, Object> fieldsToValue = kanbaCardIdandFields.get(kanbanCardRecord.Id).getPopulatedFieldsAsMap();
                        for(String Fields:singleFieldSetRecord.fieldSetAndFields.get(String.valueOf(kanbanCardRecord.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c))){
                            if(fieldsToValue.containsKey(fields)){
                                remoteKanban.kanbanCustomField.put(fields, fieldsToValue.get(fields));
                            }

                        }
                    }
                }
            }
        }
        kanbanList.add(remoteKanban);
       
        //Pratiksha : 03/April/2023 :checking constraint While cloning board the with updating links.
        if(!cardsToCheck.isEmpty()){
            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                violationResult = KanbanController.getConstraintViolation(cardsToCheck, false);
            }
            if(!violationResult.isEmpty()){
                System.debug('Constraint is Violated.....');
                if(KanbanController.isCalledFromSingleCloneAPI){
                    throw new Util.LeanException('Constraint is Violated');
                }
                return Json.serialize(violationResult);
            }
        }
        List<leankor__KanbanCard__c> newKanbanCards = leankor.RealTimeController.CreateKanbanCard(VSID, KanbanList, true);                              
        //Changes : Check Constraint Setting is enable or not.
        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){                            
            remoteKanban.ConstraintType = tempConstraintType;
        }
		List<leankor.realTimeController.taskUsers> taskUsersList = new List<leankor.realTimeController.taskUsers>();
        
        if(newKanbanCards.Size() > 0){
            remoteKanban.Id = newKanbanCards[0].Id;
            remoteKanban.ForceID = newKanbanCards[0].Id;
            remoteKanban.OwnerId = newKanbanCards[0].OwnerId;
            remoteKanban.TaskComments = 0;           
            if(TaskVerb == true){
            	
            	//RS 28/11/2019 Added Owner.IsActive to query                
                List<Task> kanbanTaskList = [SELECT ActivityDate,
                                                    Description,
                                                    Id,
                                                    OwnerId,
                                                    Owner.Name,
                                                    Priority,
                                                    Status,
                                                    Subject,
                                                    WhatId,
                                                    Owner.IsActive 
                                                FROM Task 
                                                WHERE (WhatId =:oldKanbanID AND IsDeleted = false) 
                                                ORDER BY CreatedDate ASC NUllS LAST 
                                                LIMIT 9999 All Rows]; //CreatedDate
                if(kanbanTaskList.Size() > 0){
                    List<Task> TaskList = new List<Task>();
                    //Preparing Map for filter task feature : Kanban Board.
					Map<String, String> taskOwnerMap = New Map<String, String>();
					
                    for(Task t : kanbanTaskList){
                        Task Tsk = new Task();
                        Tsk.Priority    =   t.Priority;
                        //RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries
                        //Tsk.OwnerID = allUserMap.containsKey(t.OwnerID) ? UserInfo.getUserId() : t.OwnerID;
                        Tsk.OwnerID = t.Owner.IsActive ? t.OwnerId : UserInfo.getUserId() ;                        
                        Tsk.Subject     =   (t.Subject == null ? '' :t.Subject);
                        Tsk.Status      =   t.Status;
                        Tsk.ActivityDate=  (Date.valueOf(t.ActivityDate)+otherDifference);

                        if (VS.leankor__SevenDayWorkWeek__c && Util.weekDays.size() > 1) {
                            DateTime taskDateTime = workWeek.getNextWorkingDay(DateTime.newInstance(Tsk.ActivityDate.year(), Tsk.ActivityDate.month(), Tsk.ActivityDate.day(), newKanbanCards[0].leankor__StartDateTime__c.hour(), newKanbanCards[0].leankor__StartDateTime__c.minute(), newKanbanCards[0].leankor__StartDateTime__c.second()));
                            Tsk.ActivityDate = taskDateTime.date();
                        }
                        
                        if(!VS.leankor__SevenDayWorkWeek__c){
                            datetime TskDuedate = Datetime.newInstance(Tsk.ActivityDate.year(),Tsk.ActivityDate.month(), Tsk.ActivityDate.day(), 1, 1, 1);
							Tsk.ActivityDate = Util.readPreviousWorkingDate(workWeek,TskDuedate,Tsk.ActivityDate);
                        /**Note - Using TempFinalDate, tempcalstartdate variables for getting TskActivityDate also replacing values in 
                        DueDate,StartDate for card. So New date variables are created using year,Month, Day**/
                        Date tempTskFinalDate = Date.newInstance(TempFinalDate.year(), TempFinalDate.month(), TempFinalDate.day());
                        Date tempTskstartdate = Date.newInstance(tempcalstartdate.year(), tempcalstartdate.month(), tempcalstartdate.day());
                        if(Tsk.ActivityDate > tempTskFinalDate && VS.leankor__TaskDatecheck__c){
                            Tsk.ActivityDate = tempTskFinalDate;
                        }else if (Tsk.ActivityDate < tempTskstartdate && VS.leankor__TaskDatecheck__c){
                            Tsk.ActivityDate = tempTskstartdate;
                            }
                        //End****SS 05.07.2018    
                        }
                        Tsk.WhatID      =   newKanbanCards[0].Id;
                        Tsk.Description =   (t.Description == null ? '' : t.Description);
                        TaskList.add(Tsk);
                    taskOwnerMap.put(t.OwnerId,t.Owner.Name);
                    }
                    try{
                        Database.insert(TaskList,false);
                        //Task filter code added for clone feature. preparing list to send back to Kanban Board. 
						for(Task t:TaskList){
							leankor.realTimeController.taskUsers taskUser = new leankor.realTimeController.taskUsers(t.Id,t.OwnerId, taskOwnerMap.get(t.OwnerId));
							taskUsersList.add(taskUser);
						}
						remoteKanban.TaskUserNames = taskUsersList;
                    }catch(DMLException ex){
                        System.debug('Error : '+ex.getMessage());
                        //return 'Failed';
                        //25/04/2023 : We are Throwing Exception
			            throw new Util.LeanException('ERROR:' + ex.getMessage());
                    }
                    List<FeedItem> Feeds=new List<FeedItem>();
                    remoteKanban.TaskComments = TaskList.Size();
                    for(Task Tsk:TaskList){
                        FeedItem Post=new FeedItem();
                        Post.ParentID=Tsk.Id;
                        Post.Type='CreateRecordEvent';
                        Feeds.add(Post);
                    }
                    try{
                        insert Feeds;
                    } catch (DmlException e){
                        System.debug(e.getMessage());
                        //25/04/2023 : We are Throwing Exception
			            throw new Util.LeanException('ERROR:' + e.getMessage());
                    }
                }// End of If
            }// End of If
            remoteKanban.ItemType = String.isNotBlank(remoteKanban.ItemType) ? remoteKanban.ItemType : 'KC';
			remoteKanban.LinkedCardVerb = 'CardHierarchyToOther';
            //26.09.2017 : for Generic Streamin and Bulk call
            remoteKanban.successorsArray = JSON.serialize(leankor.RealTimeController.gskanbanCardIds);
            leankor.RealTimeController.gskanbanCardIds.clear();
            remoteKanban.schedulemodeList = null;
		    remoteKanban.resourceAssignmentList = null;
            someJSONData = JSON.serialize(remoteKanban);
            leankor.RealTimeController.kanbanStateChange(VSID, 'CreateKanbanCard',mySessionID, someJSONData);
            
        }// End of If
            
        return someJSONData;
        
    }// End of Method.   
    //
    // This Method Is Use for Get Value Stream records Card Records
    //
    Global static List<leankor__ValueStream__c> getValueStreams(){
        // Tilak - 05/03/2020 - Changes for filtering soft deleted record and removing null condition in where clause.
        List<leankor__ValueStream__c> valLst = new List<leankor__ValueStream__c>();
        for(leankor__ValueStream__c vs: [SELECT 
                                            Id,
                                            Name,
                                            leankor__BoardType__c, 
                                            leankor__ProjectRoom__c,
                                            leankor__ProjectRoom__r.Name 
                                        FROM leankor__ValueStream__c 
                                        WHERE leankor__BoardType__c != 'Card Hierarchy' 
                                            AND leankor__isRecordDeleted__c = false]){
            if(String.isNotBlank(vs.leankor__ProjectRoom__c)){
                valLst.add(vs);
            }                               
        }

        return valLst;
    }
    Global class MCHyperJumpLog{
        Global String TargetVSID;
        Global String TragetVSID;// deprecated 
        Global String DefaultCardtemplateID;
        Global Boolean IsClone ;
        Global String LinkVSID;
        Global String LinkCardID;
        Global String ColumnID;
        Global List<String> CardIDs;
        Global Boolean sendBroadcastMessage;
        global String projectEventCustomPayload;
        global String projectId;
    }


    @remoteAction
    Global static string allMCCardsHyperJump(MCHyperJumpLog remoteObject ){
        //Check CRUD / FLC behavior
        ZoneBehavior zoneBehavior = new ZoneBehavior();
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        ProjectScheduleBlackoutBehaviour ProjectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
        Boolean isGS = false;
        List<leankor.RealTimeController.bulkStreaming> bulkStreams = new List<leankor.RealTimeController.bulkStreaming>();
        final Integer BROADCAST_REQUEST_LIMIT = 40;
        if (
            !zoneBehavior.isAccessible() ||
            !masterContainerBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isUpdateable() ||
            !scheduleModeBehavior.isAccessible() || 
            !resourceAssignmentBehavior.isAccessible() ||
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isCreateable() ||
            !feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable() ||
            !kanbanCardTemplateBehaviour.isAccessible() ||
            !ProjectScheduleBlackoutBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();
        //Map<String, Schema.SObjectField> fieldMapKanbanCardForClone = new DescribeSchema().getObjectFieldsForClone('leankor__KanbanCard__c'); 
        Map<Id, leankor__KanbanCard__C> kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__C>();
        //Map<String, Schema.SObjectField> fieldDescribeMap = new Map<String, Schema.SObjectField>();
        leankor__Zone__c  ZoneLogs= new leankor__Zone__c();
        String someJSONData;
        if(!string.IsBlank(remoteObject.ColumnID)){
            ZoneLogs= [SELECT ID,
                                leankor__GUID__c,
                                leankor__Swimlane__c,
                                leankor__Swimlane__r.leankor__MasterContainer__C 
                            FROM leankor__Zone__c 
                            WHERE ID = :remoteObject.ColumnID 
                            LIMIT 1];
        }
        Boolean IsTBseven,IsTBtaskcheck = false;
    	Util.WorkWeek workWeek;
        List<leankor__MasterContainer__C> mContainers = [SELECT Id,
                                                            leankor__GUID__c,
                                                            leankor__Order__c,
                                                            leankor__Type__c 
                                                        FROM leankor__MasterContainer__c 
                                                        WHERE leankor__ValueStream__c = :remoteObject.TargetVSID 
                                                        ORDER BY leankor__Order__c ASC NULLS LAST 
                                                        LIMIT 9999];
        
        String Left_MC ='';
        if(mContainers.Size() >  0){
            Left_MC = mContainers[0].Id; // Getting left most MC Id
            for(leankor__MasterContainer__C m : mContainers){
                if(m.leankor__Type__C == 'Backlog'){        
                    Left_MC = m.Id; // Getting backlog type MC Id
                } //End of If
            } // End of for loop
        } // End of If
        List<leankor__Swimlane__c> List_SW =[SELECT Id,Name,leankor__Order__c FROM leankor__Swimlane__c WHERE leankor__MasterContainer__c = :Left_MC and  leankor__ValueStream__c = :remoteObject.TargetVSID ORDER BY leankor__Order__c DESC  NULLS LAST limit 9999];
        // Ashutosh : 20/09/2021 : There is no swimlane in WB, so this code will create exception.
        // String left_most_SW = List_SW[0].ID;
        String left_most_SW = List_SW.size() > 0 ? List_SW[0].ID : null;
        List<leankor__Zone__c> List_zone =[SELECT Id,Name,leankor__Swimlane__c,leankor__Swimlane__r.leankor__MasterContainer__C,leankor__Order__c,leankor__GUID__c FROM leankor__Zone__c WHERE leankor__Swimlane__c= :left_most_SW  and  leankor__ValueStream__c = :remoteObject.TargetVSID ORDER BY leankor__Order__c ASC  NULLS LAST Limit 9999];
        // Ashutosh : 20/09/2021 : There is no Zone in WB, so this code will create exception.
        // String LM_ZoneGUID = List_zone[0].leankor__GUID__c;
        // String LM_ZoneID=List_zone[0].ID;
        String LM_ZoneGUID = List_zone.size() > 0 ? List_zone[0].leankor__GUID__c : null;
        String LM_ZoneID= List_zone.size() > 0 ? List_zone[0].ID : null;
        List<leankor__KanbanCard__c> Targetboardcard =  new List<leankor__KanbanCard__c>();
        List<leankor__KanbanCard__c> HyperJumpCards =  new List<leankor__KanbanCard__c>();
        Map<String,List<Task>> HyperJumpCardTasks =  new Map<String,List<Task>>();
        Set<String> broadCastcardIds = new Set<String>();
        String projectId = remoteObject.projectId;
        

        Targetboardcard = !string.IsBlank(remoteObject.ColumnID) ?
    								[SELECT ID,leankor__Order__c  FROM leankor__KanbanCard__c 
    										WHERE leankor__ValueStream__c = :remoteObject.TargetVSID AND leankor__zoneGUID__c = :ZoneLogs.leankor__GUID__c 
		        							      AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false  AND leankor__IsRecordDeleted__c = false
											ORDER BY leankor__Order__c ASC  NULLS LAST LIMIT 9999] :
									[SELECT Id,leankor__Order__c FROM leankor__KanbanCard__c 
									   		WHERE leankor__ZoneGUID__c = :LM_ZoneGUID And  leankor__ValueStream__c = :remoteObject.TargetVSID
										   		  And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false And leankor__IsRecordDeleted__c = false 
										   	Order by leankor__Order__c ASC  NULLS LAST Limit 9999];		 
											 
        integer Neworder = 2;
        Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = GanttTaskBoard.getScheduleConstraints();
        KanbanController.FieldSetRecord singleFieldSetRecord = new KanbanController.FieldSetRecord();
        if (remoteObject.CardIDs.size() > 0){ 
 		  //Added filter for excluding softDeleted card or VS
 		  //RS 28/11/2019 Added Owner.IsActive to query
 		    HyperJumpCards = [SELECT 
 		  							Id,
                                    leankor__ValueStream__r.leankor__BoardType__c,
                           			(SELECT 
                             	   			Id,
                             	   			leankor__ManuallyScheduled__c,
                             	   			leankor__Mode__c,
                             	   			leankor__EffortUnits__c,
                             	   			leankor__EffortActual__c,
                             	   			leankor__KanbanCard__c,
                             				leankor__KanbanCard__r.leankor__valuestream__c,
                                            leankor__ConstraintDateTime__c,
                                            leankor__ScheduleConstraint__r.leankor__Type__c
                                            //leankor__Readonly__c  
                             			From leankor__ScheduleModes__r 
                             			Limit 1),
                             		(Select 
                             				Id,
                             				leankor__AssignedTo__c,
                             				leankor__KanbanCard__c,
                             				leankor__CompletedDate__c,
                             				leankor__KanbanCard__r.leankor__valuestream__c,
                             				leankor__PercentAllocation__c,
                             				leankor__PercentCompleted__c,
                             				Name,
                             				leankor__ExpenseAccount__c,
                                            leankor__ExpenseSubCategory__c,
                                            leankor__ExpenseCategory__c,
                                            leankor__ExternalHourlyRate__c,
           									leankor__InternalHourlyRate__c,
           									leankor__ResourceType__c,
                                            leankor__ProjectFinancial__c,
           									leankor__AssignedTo__r.IsActive                             				 
                             			FROM leankor__ResourceAssignments__r),
                             		leankor__CardID__c,
                             		leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                             		leankor__Valuestream__r.leankor__TaskDatecheck__c,
                             		leankor__Point__c,
                             		leankor__EffortRemaining__c,
                             		leankor__Account__c,
                             		leankor__ActualDuration__c,
                             		leankor__Actual_Time_Taken__c,
                             		leankor__Bottom__c,
                             		leankor__Budgeted_Time__c,
                             		leankor__BudgetTimeComplete__c,
                             		leankor__BudgetTimeRemaining__c,
                             		leankor__CardDetails__c,
                             		leankor__Case__c,
                             		leankor__CmpID__c,
                             		leankor__Color__c,
                             		leankor__CompletionVariance__c,
                             		leankor__Contact__c,
                             		leankor__CostofCompletedWork__c,
                             		leankor__CSSLayout__c,
                             		leankor__DateColor__c,
                             		leankor__AcceptanceCriteria__c,
                             		leankor__DescriptionLong__c,
                             		leankor__Description__c,
                             		leankor__DueDateTime__c,
                             		leankor__DueDate__c,
                             		leankor__DurationUnits__c,
                             		leankor__EstimatedDuration__c,
                             		leankor__FinancialBudgetRemaining__c,
                             		leankor__GUID__c,
                             		leankor__HarveyBallDoneDate__c,
                             		leankor__Height__c,
                             		leankor__IsCompletedOnTime__c,
                             		leankor__JSONData__c,
                             		leankor__JSONDefinition__c,
                             		leankor__KanbanCardTemplate__c,
                             		leankor__Left__c,
                             		leankor__MasterContainer__c,
                             		leankor__OnBudget__c,
                             		leankor__OnQuality__c,
                             		leankor__OnTime__c,
                             		leankor__Opportunity__c,
                             		leankor__Order__c,
                             		leankor__KanbanCardTemplate__r.Name,
                             		leankor__OriginalFinancialBudget__c,
                             		leankor__PercentComplete2__c,
                             		leankor__Priority__c,
                             		leankor__PromiseCompletionDate__c,
                             		leankor__StartDateTime__c,
                             		leankor__StartDate__c,
                             		leankor__State__c,
                             		leankor__Swimlane__c,
                             		leankor__Title__c,
                             		leankor__Top__c,
                             		leankor__UrlLink__c,
                             		leankor__ValueStreamCardLink__c,
                             		leankor__ValueStreamLink__c,
                             		leankor__ValueStream__c,
                             		leankor__Width__c,
                             		leankor__X__c,
                             		leankor__Y__c,
                             		leankor__ZoneGUID__c,
                             		leankor__Zone__c,
                             		leankor__IsAtRisk__c,
                             		leankor__IsOnHold__c,
                             		Name,
                             		OwnerId,
                             		Owner.IsActive,
                                    RecordType.Name,
                                    leankor__IsConstraintRecalculate__c,
                                    leankor__Monday__c,
                                    leankor__Tuesday__c,
                                    leankor__Wednesday__c,
                                    leankor__Thursday__c,
                                    leankor__Friday__c,
                                    leankor__Saturday__c,
                                    leankor__Sunday__c,
                                    leankor__WeekCalendar__c
                             	FROM leankor__KanbanCard__c 
                             	WHERE Id In :remoteObject.CardIDs 
                             	    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
        							AND leankor__IsRecordDeleted__c = false 
                             	ORDER BY 
                             		leankor__ZoneGUID__c,
                             		leankor__Order__c Asc Nulls First 
                             	LIMIT 10000];
                             	                       	
            String totalCardIds = '';                       
            for(String kanbanCardid : remoteObject.CardIDs){
                String singleId = '\''+kanbanCardid+'\'';
                if(totalCardIds!=''){ 
                    totalCardIds+=',';   //add a comma if this isn't the first one
                }  
                totalCardIds += singleId;
            }

            singleFieldSetRecord = KanbanController.getAllFieldsetAndFieldDataForCloning(remoteObject.CardIDs, 'leankor__KanbanCard__c');
            if(singleFieldSetRecord.allFields.size() > 0){
                String soql ='Select Id'+ singleFieldSetRecord.allFieldsInStringFormat + ' From leankor__KanbanCard__c Where Id In ('+totalCardIds+') Limit 50000';
                kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__c>((List<leankor__KanbanCard__c>)Database.query(soql));
            }
            
                              
            if (HyperJumpCards.isEmpty()) {
                return null;
            }
            else{
            //query all task records including archived                    
            //RS 28/11/2019 Added Owner.IsActive to query                    
                List<Task> Tasksdata = 
                                    [SELECT 
                                            ActivityDate,
                                            Description,
                                            Id,
                                            OwnerId,
                                            Priority,
                                            Status,
                                            Subject,
                                            WhatId,
                                            Owner.IsActive 
                                        FROM Task 
                                        where What.Type = 'leankor__KanbanCard__c' AND IsDeleted = false AND WhatId IN: HyperJumpCards 
                                        Order By CreatedDate ASC NUllS LAST 
                                        limit 9999 All Rows];
                if (!TasksData.isEmpty()) {
                    for (Task t : Tasksdata) {
                        List<Task> tkData = HyperJumpCardTasks.containsKey(t.WhatId) ? HyperJumpCardTasks.get(t.WhatId) : new List<Task>();
                        tkData.add(t);
                        HyperJumpCardTasks.put(t.WhatId, tkData);
                    }
                }
            }                             
          //SS 28.03.18                            
        }
        string oldvs;
        if(HyperJumpCards.size() >0){
            oldvs = HyperJumpCards[0].leankor__ValueStream__c;
        }
        Map<String,leankor__KanbanCardTemplate__c> TemplateMap = new Map<String,leankor__KanbanCardTemplate__c>();

        
        // Date: 04/11/2019 - Getting the existing Project Schedule Blackout records. 
        List<leankor__ProjectScheduleBlackout__c> projectBlackOutList = [SELECT
                                                                        leankor__EndDate__c,
                                                                        leankor__StartDate__c
                                                                       FROM leankor__ProjectScheduleBlackout__c
                                                                       WHERE leankor__ProjectBoard__c =:remoteObject.TargetVSID
                                                                       LIMIT 9999 ];                                                            

        /*SS 17.08.2018*/
        //Added filter for excluding softDeleted VS
        List<leankor__KanbanCardTemplate__c> TargetCardsTemplates = [Select Id,
                                                                            leankor__Valuestream__r.leankor__TaskDateCheck__c,
                                                                            leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
                                                                            leankor__ValueStream__c,
                                                                            leankor__Color__c,
                                                                            Name,
                                                                            leankor__ValueStream__r.leankor__ProjectBoardStartDateTime__c,
                                                                            leankor__ValueStream__r.leankor__ProjectBoardEndDateTime__c,
                                                                            leankor__FieldSetName__c
                                                                        From leankor__KanbanCardTemplate__c 
                                                                        Where leankor__ValueStream__c = :remoteObject.TargetVSID 
                                                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false  
                                                                        Limit 9999];
        IsTBseven = TargetCardsTemplates[0].leankor__Valuestream__r.leankor__SevenDayWorkWeek__c;
    
        Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;   
        Integer firstDayOfWeek= firstDay==null || firstDay<0  || firstDay > 6?1:firstDay.intValue();

        // Date: 05/11/2019 - Changes for blackout
        // workWeek = new Util.WorkWeek(firstDayOfWeek, IsTBseven?7:5);
        workWeek = new Util.WorkWeek(firstDayOfWeek, IsTBseven?7:5, projectBlackOutList);
            
        IsTBtaskcheck = TargetCardsTemplates[0].leankor__Valuestream__r.leankor__TaskDateCheck__c;
        for( leankor__KanbanCardTemplate__c TempLog :TargetCardsTemplates){
            IsTBseven = TargetCardsTemplates[0].leankor__Valuestream__r.leankor__SevenDayWorkWeek__c;
            TemplateMap.put(TempLog.Name,TempLog);
        }
        map<String,String> MapCloneLogs = new map<String,String>();
        List<leankor__KanbanCard__c> Clonelist = New List<leankor__KanbanCard__c>();
        List<leankor.RealTimeController.Kanban> JSONKanban =  New List<leankor.RealTimeController.Kanban>();
        List<Task> TaskList = new List<Task>();
        // List<Task> kanbanTaskList = [SELECT ActivityDate,Description,Id,OwnerId,Priority,Status,Subject,WhatId FROM Task Where WhatId IN :HyperJumpCards Order By ActivityDate DESC NUllS LAST Limit 999];
        //Ashutosh : 13/09/2021 : condition added for remoteObject.DefaultCardtemplateID is not blank. 
		leankor__KanbanCardTemplate__c tempName = new leankor__KanbanCardTemplate__c();
        if(String.isNotBlank(remoteObject.DefaultCardtemplateID)){
            tempName= [Select 
							Id,
							Name,
							leankor__Color__c,
                            leankor__FieldSetName__c
						From leankor__KanbanCardTemplate__c 
						Where Id =: remoteObject.DefaultCardtemplateID];
        }      
        
        //updating isSuccessorRecalculate field
        Set<String> cardLinksIds =  new set<String>();
        if(remoteObject.LinkCardID != null && remoteObject.LinkCardID != '')
        {
        	cardLinksIds.add(remoteObject.LinkCardID);
        }
        
        //04/April/2023 : We have added code for Hybrid constraint while Multiple hyperJump the card with updating links.        
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        KanbanController.KanbanCardConstraintViolation violationResult = new KanbanController.KanbanCardConstraintViolation();
        Set<String> boardnames = new Set<String>();
        leankor__KanbanCardTemplate__c tempCategoryData = new leankor__KanbanCardTemplate__c();
        for(leankor__KanbanCard__c CardsLog :HyperJumpCards){

            if(!remoteObject.IsClone){ // For Hyper Jump 

                CardsLog.leankor__MasterContainer__c = (Left_MC == '' ? Null : Left_MC );
                CardsLog.leankor__MasterContainer__c = (ZoneLogs.leankor__Swimlane__r.leankor__MasterContainer__c ==Null ? CardsLog.leankor__MasterContainer__c :ZoneLogs.leankor__Swimlane__r.leankor__MasterContainer__c);
                //Neworder = (CardsLog.leankor__Order__c > Neworder ? Integer.valueof(CardsLog.leankor__Order__c) : Neworder); 
				// 01 July 2022 : Changes to make a consistent MultipleHyperjump API with multiple Hyperjump cards from UI(there is inconsistency with category). 
                if(TemplateMap.containsKey(CardsLog.leankor__KanbanCardTemplate__r.Name)){
                //if(String.isBlank(remoteObject.DefaultCardtemplateID)){   
                    leankor__KanbanCardTemplate__c tempKCT = TemplateMap.get(CardsLog.leankor__KanbanCardTemplate__r.Name);
                    CardsLog.leankor__KanbanCardTemplate__c =  tempKCT.ID;
                    CardsLog.leankor__Color__c= tempKCT.leankor__Color__c;
                }else{ 
                    CardsLog.leankor__Title__c =tempName.name ;
                    CardsLog.leankor__Color__c= tempName.leankor__Color__c;
                    CardsLog.leankor__KanbanCardTemplate__c = remoteObject.DefaultCardtemplateID;
                }
                CardsLog.leankor__Swimlane__c = (left_most_SW == ''? Null :left_most_SW);
                CardsLog.leankor__Swimlane__c = (ZoneLogs.leankor__Swimlane__c == Null ? CardsLog.leankor__Swimlane__c: ZoneLogs.leankor__Swimlane__c);
                CardsLog.leankor__Zone__c = (LM_ZoneID == '' ? Null :LM_ZoneID);
                CardsLog.leankor__Zone__c = (ZoneLogs.ID == null ? CardsLog.leankor__Zone__c :ZoneLogs.ID);
                CardsLog.leankor__ZoneGUID__c = LM_ZoneGUID;
                CardsLog.leankor__ZoneGUID__c = ((ZoneLogs.leankor__GUID__c == '' || ZoneLogs.leankor__GUID__c == Null)? CardsLog.leankor__ZoneGUID__c :ZoneLogs.leankor__GUID__c);
                CardsLog.leankor__ValueStream__c = remoteObject.TargetVSID;
                //05/07/2022 : Changes for fixing the link issue in MultipleHyperJumpAction.
                CardsLog.leankor__ValueStreamCardLink__c = String.isBlank(remoteObject.LinkVSID) ? CardsLog.leankor__ValueStreamCardLink__c : remoteObject.LinkCardID;
                CardsLog.leankor__ValueStreamLink__c = String.isBlank(remoteObject.LinkVSID) ? CardsLog.leankor__ValueStreamLink__c : remoteObject.LinkVSID;
                CardsLog.leankor__Order__c = Neworder;
                Neworder++;
                
                //Pratiksha : 11/Nov/2023 : Changes for WeekCalendar cloning card by multiSelect and Target board has 7 day workweek.
                Set<String> weekDays = new Set<String>();
                if(IsTBseven == true){
                    if(CardsLog.leankor__Monday__c == false && CardsLog.leankor__Tuesday__c == false && CardsLog.leankor__Wednesday__c == false &&  CardsLog.leankor__Thursday__c == false &&  CardsLog.leankor__Friday__c == false &&  CardsLog.leankor__Saturday__c == false &&  CardsLog.leankor__Sunday__c == false){
                        CardsLog.leankor__Monday__c = true;
                        CardsLog.leankor__Tuesday__c = true;
                        CardsLog.leankor__Wednesday__c = true;
                        CardsLog.leankor__Thursday__c = true;
                        CardsLog.leankor__Friday__c = true;
                        CardsLog.leankor__Saturday__c = true;
                        CardsLog.leankor__Sunday__c = true;
                        CardsLog.leankor__weekCalendar__c = null;
                    }else{
                        weekDays.add(CardsLog.leankor__Monday__c == false ? 'Mon' : 'false');
                        weekDays.add(CardsLog.leankor__Tuesday__c == false ? 'Tue' : 'false');
                        weekDays.add(CardsLog.leankor__Wednesday__c == false ? 'Wed' : 'false');
                        weekDays.add(CardsLog.leankor__Thursday__c == false ? 'Thu' : 'false');
                        weekDays.add(CardsLog.leankor__Friday__c == false ? 'Fri' : 'false');
                        weekDays.add(CardsLog.leankor__Saturday__c == false ? 'Sat' : 'false');
                        weekDays.add(CardsLog.leankor__Sunday__c == false ? 'Sun' : 'false');
                    }
                }else{
                    CardsLog.leankor__Monday__c = true;
                    CardsLog.leankor__Tuesday__c = true;
                    CardsLog.leankor__Wednesday__c = true;
                    CardsLog.leankor__Thursday__c = true;
                    CardsLog.leankor__Friday__c = true;
                    CardsLog.leankor__Saturday__c = true;
                    CardsLog.leankor__Sunday__c = true;
                    CardsLog.leankor__weekCalendar__c = null;
                }
                Util.weekDays = weekDays;
                
                Integer ED =  integer.valueof(CardsLog.leankor__EstimatedDuration__c);
                if(CardsLog.leankor__DurationUnits__c == 'Hours'){
                    if(math.mod(ED,8) > 0){
                        ED= Integer.valueof(ED/8) + 1;
                    }else{
                        ED= Integer.valueof(ED/8);
                    }
                }else if(CardsLog.leankor__DurationUnits__c == 'Years'){
                    ED= Integer.valueof(ED*365);
                }else if(CardsLog.leankor__DurationUnits__c == 'Months'){
                    ED= Integer.valueof(ED*30);
                }else if(CardsLog.leankor__DurationUnits__c == 'Minutes'){
                    integer temphours;
                    if(math.mod(ED,60) >0 ){
                        temphours= Integer.valueof(ED/60) + 1;
                    }else{
                        temphours= Integer.valueof(ED/60);
                    }
                    if(math.mod(temphours,8) >0){
                        ED= Integer.valueof(temphours/8) + 1;
                    }else{
                        ED= Integer.valueof(temphours/8);
                    }
                }else if(CardsLog.leankor__DurationUnits__c == 'Weeks'){
                    ED= Integer.valueof(ED*5);
                } 

                //Date: 14/11/2019 
                // If start date occured on blackout- Getting the next working day in that case
                CardsLog.leankor__StartDateTime__c = workweek.getNextWorkingDay(CardsLog.leankor__StartDateTime__c); 
				
				//Using new method for date calculation.             
                Datetime tempcalDuedate = CardsLog.leankor__StartDateTime__c;
                if(CardsLog.leankor__DurationUnits__c == 'Years'){
                        tempcalDuedate = tempcalDuedate.addYears(-integer.valueof(CardsLog.leankor__EstimatedDuration__c));
                        tempcalDuedate = tempcalDuedate +1 ;
                }else if(CardsLog.leankor__DurationUnits__c == 'Months'){
                        tempcalDuedate = tempcalDuedate.addMonths(-integer.valueof(CardsLog.leankor__EstimatedDuration__c));
                        tempcalDuedate = tempcalDuedate +1 ;
                }else{
                     //Pratiksha: 14/06/2023 : In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                     ED = (ED == 0 || ED == Null ? 1: ED); 
                     tempcalDuedate= workweek.nextBusinessDate(tempcalDuedate,ED-1);	
                }
                CardsLog.leankor__DueDateTime__c = workweek.getNextWorkingDay(tempcalDuedate); 	
                //Changes : Check constraint setting is enables and ALAP/ASAP card will be on ProjectNode dates of Target Board.
                if (CardsLog.leankor__ScheduleModes__r.size() > 0 && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    for(leankor__ScheduleMode__c schedulemode : CardsLog.leankor__ScheduleModes__r){
                        if(schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c == 'assoonaspossible'){
                            CardsLog.leankor__StartDateTime__c = workWeek.getNextWorkingDay(TargetCardsTemplates[0].leankor__Valuestream__r.leankor__ProjectBoardStartDateTime__c);
                            tempcalDuedate = CardsLog.leankor__StartDateTime__c;
                            if(CardsLog.leankor__DurationUnits__c == 'Years'){
                                tempcalDuedate = tempcalDuedate.addYears(integer.valueof(CardsLog.leankor__EstimatedDuration__c));
                                tempcalDuedate = tempcalDuedate -1 ;
                            }else if(CardsLog.leankor__DurationUnits__c == 'Months'){
                                tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(CardsLog.leankor__EstimatedDuration__c));
                                tempcalDuedate = tempcalDuedate -1 ;
                            }else{
                                ED = (ED == 0 || ED == null? 1: ED);
                                tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, ED-1);
                            }
                            tempcalDuedate = workWeek.getNextWorkingDay(tempcalDuedate);
                            CardsLog.leankor__DueDateTime__c = tempcalDuedate;
                        }

                        if(schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c == 'aslateaspossible'){
                            CardsLog.leankor__DueDateTime__c = workWeek.getNextWorkingDay(TargetCardsTemplates[0].leankor__Valuestream__r.leankor__ProjectBoardEndDateTime__c);
                            Datetime tempcalstartdate = CardsLog.leankor__DueDateTime__c;
                            if(CardsLog.leankor__DurationUnits__c == 'Years'){
                                tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(CardsLog.leankor__EstimatedDuration__c));
                                tempcalstartdate = tempcalstartdate +1 ;
                            }else if(CardsLog.leankor__DurationUnits__c == 'Months'){
                                tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(CardsLog.leankor__EstimatedDuration__c));
                                tempcalstartdate = tempcalstartdate +1 ;
                            }else{                                                         
                                // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                                ED = (ED == 0 ? 1: ED);                                                    
                                tempcalstartdate = workWeek.nextBusinessDate(tempcalstartdate, -(ED-1));      
                            }
                            tempcalstartdate = workWeek.getPreviousWorkingDay(tempcalstartdate);
                            CardsLog.leankor__StartDateTime__c = tempcalstartdate;
                        }
                    }
                    //Set isIsConstraintRecalculate = true when we are hyper jump a card from another board.
                    CardsLog.leankor__IsConstraintRecalculate__c = true; 
                }

                //30/march/2023 : Changes added for multipleHyper api if we are updating linking, then we will checking constraint.
                if(isCalledFromMultipleAPI == true && String.isNotBlank(remoteObject.LinkVSID) && String.isNotBlank(remoteObject.LinkCardID)){
                    KanbanCard checkCard = new KanbanCard();
                    checkCard.Id = CardsLog.Id;
                    checkCard.name = CardsLog.Name;
                    checkCard.valueStream = CardsLog.leankor__ValueStream__c;
                    checkCard.startDateTime = CardsLog.leankor__StartDateTime__c;
                    checkCard.dueDateTime =  CardsLog.leankor__DueDateTime__c;
                    checkCard.isUpdateValueStreamCardLink = true;
                    checkCard.valueStreamLink = remoteObject.LinkVSID;
                    checkCard.valueStreamCardLink = remoteObject.LinkCardID;
                    cardsToCheck.add(checkCard);
                }							
                broadCastcardIds.add(CardsLog.Id);						
            }else{ // For cloning

                leankor.RealTimeController.Kanban Clonelog =  New leankor.RealTimeController.Kanban();
                
                    Clonelog.GUID = CardsLog.Id+'-'+system.now().gettime();
                    Clonelog.Id = CardsLog.Id;
                    Clonelog.CardID = CardsLog.leankor__CardID__c;
                    Clonelog.MCForceID = (Left_MC == '' ? Null : Left_MC );
                    Clonelog.MCForceID = (ZoneLogs.leankor__Swimlane__r.leankor__MasterContainer__c == Null ? Clonelog.MCForceID :ZoneLogs.leankor__Swimlane__r.leankor__MasterContainer__c);
                    //Neworder = (CardsLog.leankor__Order__c > Neworder ? Integer.valueof(CardsLog.leankor__Order__c) : Neworder);
                    Clonelog.Order = Neworder; //CardsLog.leankor__Order__c;
                    Neworder++;
                    Clonelog.Title = CardsLog.leankor__Title__c;
                    Clonelog.Color= CardsLog.leankor__Color__c;
                    if(TemplateMap.containsKey(CardsLog.leankor__KanbanCardTemplate__r.Name)){
                        leankor__KanbanCardTemplate__c tempKCT = TemplateMap.get(CardsLog.leankor__KanbanCardTemplate__r.Name); 
                        Clonelog.TemplateID =  tempKCT.ID;
                        Clonelog.Color= tempKCT.leankor__Color__c;
                        tempCategoryData = tempKCT;
                    }else{ 
                        Clonelog.Title =tempName.name ;
                        Clonelog.Color= tempName.leankor__Color__c;
                        Clonelog.TemplateID = remoteObject.DefaultCardtemplateID;
                        tempCategoryData = tempName;
                    }
                    MapCloneLogs.put(CardsLog.ID,Clonelog.GUID);
                    Clonelog.SWForceID = (left_most_SW == ''? Null :left_most_SW);
                    Clonelog.SWForceID = (ZoneLogs.leankor__Swimlane__c == Null ? Clonelog.SWForceID: ZoneLogs.leankor__Swimlane__c);
                    Clonelog.ZoneForceID = (LM_ZoneID == '' ? Null :LM_ZoneID);
                    Clonelog.ZoneForceID = (ZoneLogs.ID == null ? Clonelog.ZoneForceID :ZoneLogs.ID);
                    Clonelog.ZoneID = LM_ZoneGUID;
                    Clonelog.ZoneID = ((ZoneLogs.leankor__GUID__c == '' || ZoneLogs.leankor__GUID__c == Null) ? Clonelog.ZoneID :ZoneLogs.leankor__GUID__c);
                    CLonelog.Point = CardsLog.leankor__Point__c;
                    CLonelog.EffortRemaining = integer.valueof(CardsLog.leankor__EffortRemaining__c);
                    Clonelog.ValueStream =  remoteObject.TargetVSID;
                    Clonelog.Account = CardsLog.leankor__Account__c;
                    Clonelog.Bottom = CardsLog.leankor__Bottom__c;
                    Clonelog.CaseID= CardsLog.leankor__Case__c;
                    Clonelog.CmpID= CardsLog.leankor__CmpID__c;
                    Clonelog.Contact= CardsLog.leankor__Contact__c;
                    Clonelog.DateColor= CardsLog.leankor__DateColor__c;
                    Clonelog.Description= CardsLog.leankor__DescriptionLong__c;
                    Clonelog.AcceptanceCriteria= CardsLog.leankor__AcceptanceCriteria__c;
                    Clonelog.DueDate= CardsLog.leankor__DueDateTime__c;
                    Clonelog.DurationUnits= CardsLog.leankor__DurationUnits__c;
                    Clonelog.EstimatedDuration= CardsLog.leankor__EstimatedDuration__c;
                    Clonelog.Height= CardsLog.leankor__Height__c;
                    Clonelog.JSONData= CardsLog.leankor__JSONData__c;
                    Clonelog.JSONDefinition= CardsLog.leankor__JSONDefinition__c;              
                    Clonelog.Left= CardsLog.leankor__Left__c;
                    Clonelog.OnBudget= CardsLog.leankor__OnBudget__c;
                    Clonelog.OnQuality = CardsLog.leankor__OnQuality__c;
                    Clonelog.OnTime = CardsLog.leankor__OnTime__c;
                    Clonelog.Opportunity = CardsLog.leankor__Opportunity__c;
                    Clonelog.HarveyBall = string.valueof(CardsLog.leankor__PercentComplete2__c);
                    Clonelog.Priority = Integer.valueof(CardsLog.leankor__Priority__c);
                    Clonelog.StartDate = CardsLog.leankor__StartDateTime__c;
                    Clonelog.State = CardsLog.leankor__State__c;
                    Clonelog.Top = CardsLog.leankor__Top__c;
                    Clonelog.UrlLink = CardsLog.leankor__UrlLink__c;
                    //05/07/2022 : Changes for fixing the link issue in MultipleClone API.
                    Clonelog.ValueStreamCardLink = String.isBlank(remoteObject.LinkVSID) ? CardsLog.leankor__ValueStreamCardLink__c : remoteObject.LinkCardID;
                    Clonelog.ValueStreamLinkID = String.isBlank(remoteObject.LinkVSID) ? CardsLog.leankor__ValueStreamLink__c : remoteObject.LinkVSID;
                    Clonelog.Width = CardsLog.leankor__Width__c;
                    Clonelog.X = CardsLog.leankor__X__c;
                    Clonelog.Y = CardsLog.leankor__Y__c;
                    Clonelog.Name = CardsLog.Name;
                    Clonelog.isAtRisk = CardsLog.leankor__IsAtRisk__c;
					Clonelog.isOnHold = CardsLog.leankor__IsOnHold__c;
                    
                    // yj : 06 Nov. 2017 checking user is active or not.No Need to add code here
                    //Clonelog.OwnerId = allUserMap.get(CardsLog.OwnerId).IsActive ? CardsLog.OwnerId : UserInfo.getUserId();
                    //Clonelog.OwnerId = allUserMap.containsKey(CardsLog.OwnerId) ? UserInfo.getUserId() : CardsLog.OwnerId;
                    // yj : 06 Nov. 2017
                    Clonelog.OwnerId = CardsLog.OwnerId;
                    //RS 28/11/2019 Added Owner.IsActive in object
    				Clonelog.ownerIsActive = CardsLog.Owner.IsActive;
                    clonelog.ItemType = CardsLog.recordType.name;

                //Pratiksha : 11/Nov/2023 : Changes for WeekCalendar cloning card by multiSelect and Target board has 7 day workweek.
                Set<String> weekDays = new Set<String>();
                if(IsTBseven == true){
                    if(CardsLog.leankor__Monday__c == false && CardsLog.leankor__Tuesday__c == false && CardsLog.leankor__Wednesday__c == false &&  CardsLog.leankor__Thursday__c == false &&  CardsLog.leankor__Friday__c == false &&  CardsLog.leankor__Saturday__c == false &&  CardsLog.leankor__Sunday__c == false){
                        Clonelog.Monday = true;
                        Clonelog.Tuesday = true;
                        Clonelog.Wednesday = true;
                        Clonelog.Thursday = true;
                        Clonelog.Friday = true;
                        Clonelog.Saturday = true;
                        Clonelog.Sunday = true;
                    }else{
                        Clonelog.Monday = CardsLog.leankor__Monday__c;
                        Clonelog.Tuesday = CardsLog.leankor__Tuesday__c;
                        Clonelog.Wednesday = CardsLog.leankor__Wednesday__c;
                        Clonelog.Thursday = CardsLog.leankor__Thursday__c;
                        Clonelog.Friday = CardsLog.leankor__Friday__c;
                        Clonelog.Saturday = CardsLog.leankor__Saturday__c;
                        Clonelog.Sunday = CardsLog.leankor__Sunday__c;
                        Clonelog.weekCalendar = CardsLog.leankor__WeekCalendar__c;

                        weekDays.add(Clonelog.Monday == false ? 'Mon' : 'false');
                        weekDays.add(Clonelog.Tuesday == false ? 'Tue' : 'false');
                        weekDays.add(Clonelog.Wednesday == false ? 'Wed' : 'false');
                        weekDays.add(Clonelog.Thursday == false ? 'Thu' : 'false');
                        weekDays.add(Clonelog.Friday == false ? 'Fri' : 'false');
                        weekDays.add(Clonelog.Saturday == false ? 'Sat' : 'false');
                        weekDays.add(Clonelog.Sunday == false ? 'Sun' : 'false');
                    }
                }
                Util.weekDays = weekDays;
                //Date: 14/11/2019 
                // If start date occured on blackout- Getting the next working day in that case
                Clonelog.StartDate = workweek.getNextWorkingDay(CardsLog.leankor__StartDateTime__c); 

                Datetime TempFinalDate = Clonelog.DueDate;
                Datetime tempcalstartdate = Clonelog.StartDate;
                
                    Integer ED =  integer.valueof(Clonelog.EstimatedDuration);
                    if(Clonelog.DurationUnits == 'Hours'){
                        Decimal tempED= ED/8;
                        if(tempED > Integer.valueof(ED/8)){
                            ED= Integer.valueof(ED/8) + 1;
                        }else{
                            ED= Integer.valueof(ED/8);
                        }
                    }else if(Clonelog.DurationUnits == 'Years'){
                        ED= Integer.valueof(ED*365);
                    }else if(Clonelog.DurationUnits == 'Months'){
                        ED= Integer.valueof(ED*30);
                    }else if(Clonelog.DurationUnits == 'Minutes'){
                        Decimal tempED= ED/60;
                        if(tempED > Integer.valueof(ED/60)){
                            ED= Integer.valueof(ED/60) + 1;
                        }else{
                            ED= Integer.valueof(ED/60);
                        }
                        decimal tempDayED = ED/8;
                        if(tempDayED > Integer.valueof(ED/8)){
                            ED= Integer.valueof(ED/8) + 1;
                        }else{
                            ED= Integer.valueof(ED/8);
                        }
                    }else if(Clonelog.DurationUnits == 'Weeks'){
                        ED= Integer.valueof(ED*5);
                    } 

                //Date : 11/11/19  - Using new date calculation method.          
                if(Clonelog.DurationUnits == 'Years'){
                        tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(Clonelog.EstimatedDuration));
                        tempcalstartdate = tempcalstartdate +1 ;
                }else if(Clonelog.DurationUnits == 'Months'){
                        tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(Clonelog.EstimatedDuration));
                        tempcalstartdate = tempcalstartdate +1 ;
                }else{
                    //Pratiksha: 24/05/2023 : In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                    ED = (ED == 0 || ED == Null ? 1: ED); 
                    tempcalstartdate = workweek.nextBusinessDate(tempcalstartdate,(ED-1));	
                }
                Clonelog.DueDate = workweek.getNextWorkingDay(tempcalstartdate);
                TempFinalDate = Clonelog.DueDate;   
                //adding RA and SM for cloning
                Clonelog.schedulemodeList = CardsLog.leankor__ScheduleModes__r;
		        Clonelog.resourceAssignmentList = CardsLog.leankor__ResourceAssignments__r;  
                Clonelog.HarveyBallDoneDate = CardsLog.leankor__HarveyBallDoneDate__c;
                Clonelog.PromiseCompletionDate = CardsLog.leankor__PromiseCompletionDate__c;
                 
                
                
                
                //Changes : Check Constraint setting enable or not.
                if(CardsLog.leankor__ScheduleModes__r.size() > 0 && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS ){
                    Clonelog.ConstraintDate = (CardsLog.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null)?CardsLog.leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                    Clonelog.ConstraintType = (CardsLog.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r != null)?scheduleConstraints.get(CardsLog.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c).Id:null;
                }
                //Changes : Check constraint setting is enables and ALAP/ASAP card will be on ProjectNode dates of Target Board.
                if (CardsLog.leankor__ScheduleModes__r.size() > 0 && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                    for(leankor__ScheduleMode__c schedulemode : CardsLog.leankor__ScheduleModes__r){
                        if(schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c == 'assoonaspossible'){
                            Clonelog.StartDate = workWeek.getNextWorkingDay(TargetCardsTemplates[0].leankor__Valuestream__r.leankor__ProjectBoardStartDateTime__c);
                            Datetime tempcalDuedate = Clonelog.StartDate;
                            if(Clonelog.DurationUnits == 'Years'){
                                tempcalDuedate = tempcalDuedate.addYears(integer.valueof(Clonelog.EstimatedDuration));
                                tempcalDuedate = tempcalDuedate -1 ;
                            }else if(Clonelog.DurationUnits == 'Months'){
                                tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(Clonelog.EstimatedDuration));
                                tempcalDuedate = tempcalDuedate -1 ;
                            }else{
                                ED = (ED == 0 || ED == null? 1: ED);
                                tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, ED-1);
                            }
                            tempcalDuedate = workWeek.getNextWorkingDay(tempcalDuedate);
                            Clonelog.DueDate = tempcalDuedate;
                        }

                        if(schedulemode.leankor__ScheduleConstraint__r.leankor__Type__c == 'aslateaspossible'){
                            Clonelog.DueDate = workWeek.getNextWorkingDay(TargetCardsTemplates[0].leankor__Valuestream__r.leankor__ProjectBoardEndDateTime__c);
                            Datetime tempstartdate = Clonelog.DueDate;
                            if(Clonelog.DurationUnits == 'Years'){
                                tempstartdate  = tempstartdate.addYears(-integer.valueof(Clonelog.EstimatedDuration));
                                tempstartdate  = tempstartdate +1 ;
                            }else if(Clonelog.DurationUnits == 'Months'){
                                tempstartdate  = tempstartdate.addMonths(-integer.valueof(Clonelog.EstimatedDuration));
                                tempstartdate  = tempstartdate  +1 ;
                            }else{                                                         
                                // In case of milestone, estimate duration is zero. So we assigned one for sake of date calculation.
                                ED = (ED == 0 ? 1: ED);                                                    
                                tempstartdate  = workWeek.nextBusinessDate(tempstartdate , -(ED-1));      
                            }
                            Clonelog.StartDate = workWeek.getPreviousWorkingDay(tempstartdate );
                        }
                    }
                    //Set isIsConstraintRecalculate = true when we are hyper jump a card from another board.
                    Clonelog.isConstraintRecalculate = true;
                }
                //30/march/2023 : Changes added for multipleClone api if we are updating linking, then we are checking constraint.
                if(isCalledFromMultipleAPI == true &&  String.isNotBlank(remoteObject.LinkVSID)&& String.isNotBlank(remoteObject.LinkCardID)){
                    KanbanCard checkCard = new KanbanCard();
                    checkCard.Id = CardsLog.Id;
                    checkCard.name = CardsLog.Name;
                    checkCard.valueStream = CardsLog.leankor__ValueStream__c;
                    checkCard.startDateTime = Clonelog.StartDate;
                    checkCard.dueDateTime = Clonelog.DueDate;
                    checkCard.isUpdateValueStreamCardLink = true;
                    checkCard.valueStreamLink = remoteObject.LinkVSID;
                    checkCard.valueStreamCardLink = remoteObject.LinkCardID;
                    cardsToCheck.add(checkCard);
                }
                boardnames.add(CardsLog.leankor__ValueStream__r.leankor__BoardType__c);

                Clonelog.kanbanCustomField = new leankor__KanbanCard__c();	// Initialization of inner class variable.
                //if(CardsLog.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard'){
                if(CardsLog.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard' || CardsLog.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board'){
                    if(kanbaCardIdandFields.containsKey(CardsLog.Id)){
                    
                        Clonelog.kanbanCustomField = kanbaCardIdandFields.get(CardsLog.Id);
                        Clonelog.kanbanCustomField.Id = null;
                    }
                }
                else{
                    if(kanbaCardIdandFields.get(CardsLog.Id)!=null){
                        Map<String, Object> fieldsToValue = kanbaCardIdandFields.get(CardsLog.Id).getPopulatedFieldsAsMap();
                        // Checking  fieldset on the category.
                        if(String.isNotBlank(tempCategoryData.leankor__FieldSetName__c)){ 
                            //19/04/2023 : If any fieldSet is already deleted then we were facing ("Attempt to de-reference a null object") so we are preventing by adding the condition.
                            if(fieldSetMap.get(String.valueOf(tempCategoryData.leankor__FieldSetName__c)) != null){
                                //Map<String, Object> fieldsToValue = kanbaCardIdandFields.get(CardsLog.Id).getPopulatedFieldsAsMap();
                                for(String Fields:singleFieldSetRecord.fieldSetAndFields.get(String.valueOf(tempCategoryData.leankor__FieldSetName__c))){
                                    if(fieldsToValue.containsKey(fields)){
                                        Clonelog.kanbanCustomField.put(fields, fieldsToValue.get(fields));
                                    }
                                }

                            }
                        }
                    }
                } 
                 
                JSONKanban.add(Clonelog);
                if(HyperJumpCardTasks.get(CardsLog.Id) != null && HyperJumpCardTasks.get(CardsLog.Id).Size() > 0){
                    for(Task t :HyperJumpCardTasks.get(CardsLog.Id)){
                        if(CardsLog.ID == t.whatID ){
                            Task Tsk = new Task();
                            Tsk.Priority    =   t.Priority;
                            //RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries
                            //Tsk.OwnerID = allUserMap.containsKey(t.OwnerID) ? UserInfo.getUserId() : t.OwnerID ;
                            Tsk.OwnerID = t.Owner.IsActive ? t.OwnerId : UserInfo.getUserId() ;                           
                            Tsk.Subject     =   (t.Subject == null ? 'Other' :t.Subject);
                            Tsk.Status      =   t.Status;
                            Tsk.ActivityDate=  t.ActivityDate;
                            datetime TskDuedate = Datetime.newInstance(Tsk.ActivityDate.year(),Tsk.ActivityDate.month(), Tsk.ActivityDate.day(), 0, 0, 0);
                            
                            /**Note - Using TempFinalDate, tempcalstartdate variables for getting TskActivityDate also replacing values in 
                            DueDate,StartDate for card. So New date variables are created using year,Month, Day**/
                            Date tempTskFinalDate = Date.newInstance(TempFinalDate.year(), TempFinalDate.month(), TempFinalDate.day());
                            Date tempTskstartdate = Date.newInstance(tempcalstartdate.year(), tempcalstartdate.month(), tempcalstartdate.day());
                            
                            if(!IsTBseven){
                        	//Get Working days escaping non working days for Task
                        		Tsk.ActivityDate = Util.readNextWorkingDate(workWeek,TskDuedate,Tsk.ActivityDate);
							    if(Tsk.ActivityDate > tempTskFinalDate &&(IsTBtaskcheck )){
                                	Tsk.ActivityDate = tempTskFinalDate;
                                }else if (Tsk.ActivityDate < tempTskstartdate &&(IsTBtaskcheck)){
                                	Tsk.ActivityDate = tempTskstartdate;
                            }
                            }else if(IsTBtaskcheck){
                            	if(Tsk.ActivityDate > tempTskFinalDate){
                                    Tsk.ActivityDate = tempTskFinalDate;
                                }else if (Tsk.ActivityDate < tempTskFinalDate){
                                    Tsk.ActivityDate = tempTskFinalDate;
       							}
                            }
                            
                            Tsk.WhatID      =   Cardslog.ID;
                            Tsk.Description =   (t.Description == null ? '' : t.Description);
                            TaskList.add(Tsk);
                        }
                    }
                }
                //ss 28.03.2018
            }
        }
        //30/march/2023 : checking constraint for MultipleHyperJump and MultiplClone API.
        if(!cardsToCheck.isEmpty()){
            Boolean constraintsEnabled = Boolean.valueOf(leankor__LeanConstants__c.getInstance(UserInfo.getProfileId()).get('leankor__AllowSchedulingConstraints__c'));
            if(constraintsEnabled) {
                violationResult = KanbanController.getConstraintViolation(cardsToCheck, false);
            }
        }
        Map<string,string> Newlogmap = new map<string,string>();
       // Date : 22/10/19 using wrapper class instance instead of Serialization.
        /*List<String> KanbanList = new List<String>();
        for(leankor.RealTimeController.Kanban remoteKanban: JSONKanban){
        	
            KanbanList.add(JSON.Serialize(remoteKanban));
        }*/
        // Ashutosh : 28/09/2021 : Variables added for broadcasting.
        List<Id> kanbanCardIds = new List<Id>();
        Set<String> broadcastingBoardIds = new Set<String>();
        Map<String, List<String>> broadcastContentMap =  new Map<String, List<String>>();
        leankor.RealTimeController.flowWithGSForAPI = true;
        leankor.RealTimeController.isCalledAPI = true;
        try{
            if(!remoteObject.IsClone){
                if(violationResult.isEmpty()){
                   
                    DataBase.Update(HyperJumpCards, false);
                
                    if (!HyperJumpCards.isEmpty()) {
                        //Tilak:27.05.2020
                        //leankor.realtimeController.KCupdatePVcard(JSON.serialize(HyperJumpCards));
                        leankor.RealTimeController.updateParentCards(HyperJumpCards);
                    }	
                    changeValueStreamOnHyperJump(HyperJumpCards,remoteObject.TargetVSID);
                                    
                    //upadting IsSuccesserRecalculate
                    leankor.RealTimeController.updateIsSuccessorRecalculate(cardLinksIds);
                    List<task> Taskupdate = New List<task>();
                    List<leankor__Kanbancard__c> KanbanCardsLog = 
                        [SELECT 
                                Id,
                                leankor__StartDateTime__c,
                                leankor__DueDateTime__c,
                                leankor__ValueStream__c 
                            FROM leankor__Kanbancard__c 
                            WHERE Id IN: HyperJumpCards 
                            LIMIT 9999];
                    Map<String, List<Task>> taskLogMap= new Map<String, List<Task>>(); 	
                    //Query for task record	
                    for(Task tsk: [SELECT 
                                            Id,
                                            ActivityDate, WhatId 
                                        FROM Task 
                                        WHERE What.Type = 'leankor__KanbanCard__c' 
                                            AND WhatId IN: HyperJumpCards 
                                            AND IsDeleted = false 
                                        LIMIT 9999
                                        All Rows]) {
                        List<Task> tempTaskList= taskLogMap.containsKey(tsk.WhatId) ? taskLogMap.get(tsk.WhatId) : new List<Task>();
                        tempTaskList.add(tsk);
                        taskLogMap.put(tsk.WhatId, tempTaskList);
                    }
                    
                    for(leankor__Kanbancard__c CardsLog : KanbanCardsLog) {
                        kanbanCardIds.add(cardsLog.Id);
                        broadcastingBoardIds.add(CardsLog.leankor__ValueStream__c);
                        if(taskLogMap.get(CardsLog.Id)!=null && taskLogMap.get(CardsLog.Id).size()>0) {
                        
                            for(Task t : taskLogMap.get(CardsLog.Id)) {
                                Task Tsk = new Task();
                                tsk.ID = t.ID;
                                Tsk.ActivityDate=  t.ActivityDate;
                                datetime TskDuedate = Datetime.newInstance(Tsk.ActivityDate.year(),Tsk.ActivityDate.month(), Tsk.ActivityDate.day(), 0, 0, 0);
                                if(!IsTBseven){
                                    Tsk.ActivityDate = Util.readPreviousWorkingDate(workWeek,TskDuedate,Tsk.ActivityDate);
                                    if(Tsk.ActivityDate > Date.valueOf(CardsLog.leankor__DueDateTime__c)){
                                        Tsk.ActivityDate = Date.valueOf(CardsLog.leankor__DueDateTime__c);
                                    }else if (Tsk.ActivityDate < Date.valueOf(CardsLog.leankor__StartDateTime__c)){
                                        Tsk.ActivityDate = Date.valueOf(CardsLog.leankor__StartDateTime__c);
                                    }
                                }else if(IsTBtaskcheck){
                                    if(Tsk.ActivityDate > Date.valueOf(CardsLog.leankor__DueDateTime__c)){
                                        Tsk.ActivityDate = Date.valueOf(CardsLog.leankor__DueDateTime__c);
                                    }else if (Tsk.ActivityDate < Date.valueOf(CardsLog.leankor__StartDateTime__c)){
                                        Tsk.ActivityDate = Date.valueOf(CardsLog.leankor__StartDateTime__c);
                                    }                       
                                }
                                Taskupdate.add(Tsk);
                            }//end for loop
                        }
                    }//end for loop		
                    try{
                        //Update Taskupdate;
                        leankor.OpenTaskRestriction.updateTask(Taskupdate);
                    }catch(DMLException ex){
                        System.debug('Error : '+ex.getMessage());
                        //return 'Failed';
                        //25/04/2023 : We are Throwing Exception
			            throw new Util.LeanException('ERROR:' + ex.getMessage());
                    } 
                }
            }else{
                if(violationResult.isEmpty()){
                   
                    //RS 28/11/2019 Removed allUserMap variable	        
                    //List<leankor__KanbanCard__c> Clonersult = leankor.RealTimeController.CreateKanbanCard(remoteObject.TargetVSID, JSONKanban, true,allUserMap);
                    
                    // Create Kanban Cards.
                    List<leankor__KanbanCard__c> clonedCards = leankor.RealTimeController.CreateKanbanCard(remoteObject.TargetVSID, JSONKanban, true);
                    if(boardnames.contains('UberBoard')){
                        List<leankor__KanbanCard__c> kanbanCardList =  KanbanToGanttController.linkKanbanCards(clonedCards);
                    }

                    for(leankor__Kanbancard__C clonedCard :clonedCards){
                        kanbanCardIds.add(clonedCard.Id);
                        broadcastingBoardIds.add(clonedCard.leankor__ValueStream__c);
                        Newlogmap.put(clonedCard.leankor__GUID__C,clonedCard.Id);
                    }
                }
            }
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        
        for(Task utsk:TaskList){
            String NEWGUID = MapCloneLogs.get(utsk.WhatID);
            utsk.WhatID = Newlogmap.get(NEWGUID);
        }
        try{
        //Database.insert(TaskList,false);
            insert TaskList;
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        List<FeedItem> Feeds=new List<FeedItem>();
        for(Task Tsk:TaskList){
            FeedItem Post=new FeedItem();
                Post.ParentID=Tsk.Id;
                Post.Type='CreateRecordEvent';
            Feeds.add(Post);
        }
        try{
            insert Feeds;
        } catch (DmlException e){
            System.debug(e.getMessage());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        if(Targetboardcard.size() > 0){
            for(leankor__KanbanCard__c KCLogs :Targetboardcard){
                KCLogs.leankor__Order__c = Neworder + 1;
                Neworder = Neworder + 1;
            }
            try{
                Update Targetboardcard;
            } catch (DmlException e){
                System.debug(e.getMessage());
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + e.getMessage());
            }
        }
        List<Id> kanbanCardsForBroadCast = new List<Id>();
        Integer broadCastingIdsSize = 0;
        for(String broadCastcardId : BroadCastcardIds ){
            if(broadCastingIdsSize < 45){
                kanbanCardsForBroadCast.add(broadCastcardId);
                broadCastingIdsSize++;
            }
            else{
                break;
            }
        }
        // Ashutosh : 16/09/2021 : Code added for insert platformEvent.
        if(remoteObject.sendBroadcastMessage == true){
            if(kanbanCardIds.size() <= BROADCAST_REQUEST_LIMIT){
                System.debug('kanbanCardIds.size() => '+kanbanCardIds.size());
                for(String valueStreamId : broadcastingBoardIds){
                    leankor.RealTimeController.bulkStreaming tempStreaming = new leankor.RealTimeController.bulkStreaming();
                    leankor.RealTimeController.DirectLinkCardLog tempLog = new leankor.RealTimeController.DirectLinkCardLog();
                    tempLog.cardIds = kanbanCardIds;
                    tempLog.ValueStreamID = valueStreamId;
                    tempLog.multipleAPIName = remoteObject.IsClone ? 'MultipleClone' : 'MultipleHyperJump';
                    tempStreaming.VSID = valueStreamId;
                    tempStreaming.Verb = 'ManageAffectedCards';
                   // tempStreaming.Verb = 'ManageEffectedCards';
                    tempStreaming.SessionID = UserInfo.getSessionId();
                    tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
                    bulkStreams.add(tempStreaming);
                }
                leankor.RealTimeController.sendBroadcast(bulkStreams, 'ManageAffectedCards');
               // leankor.RealTimeController.sendBroadcast(bulkStreams, 'ManageEffectedCards');
			}else {
				broadcastContentMap.put('', new List<String>(broadcastingBoardIds));
				System.debug('broadcastContentMap => '+broadcastContentMap);
				GenericStreamingController.sendBroadcastForBulkRecords('ManageBulkCards', broadcastContentMap, UserInfo.getSessionId());
            }
            if (isGS) {		
				broadcastContentMap.put('', new List<String>(leankor.realtimeController.gskanbanCardIds));   	 	
				GenericStreamingController.sendBroadcastForBulkRecords('UpdateMultipleKanbanCards', broadcastContentMap, UserInfo.getSessionId()); 	
        	}
            // Ashutosh : 28/09/2021 : sending broadcast from api for GS,PE and Pt.
            if (!remoteObject.IsClone) {
                
                List<leankor.RealTimeController.bulkStreaming> streamingDataList = new List<leankor.RealTimeController.bulkStreaming>();
                leankor.RealTimeController.bulkStreaming streamingData = new leankor.RealTimeController.bulkStreaming();
                leankor.RealTimeController.DirectLinkCardLog dataLog = new leankor.RealTimeController.DirectLinkCardLog();
                dataLog.cardIds = kanbanCardsForBroadCast;
                dataLog.multipleAPIName = 'MultipleHyperJump';
                dataLog.TargetVSID = remoteObject.TargetVSID;
                dataLog.SourceVSID = oldvs;
                dataLog.IsClone = remoteObject.IsClone;
                streamingData.VSID = oldvs;
                streamingData.Verb = 'RemoveMCChildren';
                streamingData.SessionID = UserInfo.getSessionId();
                streamingData.SomeJSONData = JSON.Serialize(dataLog);
                streamingDataList.add(streamingData);
                leankor.RealTimeController.sendBroadcast(streamingDataList, 'RemoveMCChildren');
            }
        }
        //04/04/2023 : we have Shifted ProjectEvent code in new method.
        if(violationResult.isEmpty()){
            KanbanController.createProjectEvent(projectId, remoteObject.IsClone, remoteObject.projectEventCustomPayload, JSON.serialize(kanbanCardIds));
        }
        User UserName = [SELECT Id,Name FROM User WHERE Id =: userinfo.getUserID() ];
        HyperJumpData hyperJumpData = new HyperJumpData();
        hyperJumpData.ValueStreamOld = oldvs;
        hyperJumpData.ValueStreamOwnerName = UserName.Name;
        hyperJumpData.ValueStreamID = remoteObject.TargetVSID;
        hyperJumpData.IsClone = remoteObject.Isclone;
        someJSONData = JSON.serialize(hyperJumpData);
     	HyperJumpData hyperJumpRemoveData = new HyperJumpData();
        hyperJumpRemoveData.ValueStreamOwnerName = UserName.Name;
        hyperJumpRemoveData.TargetVSID = remoteObject.TargetVSID;
        hyperJumpRemoveData.SourceVSID = oldvs;
        hyperJumpRemoveData.IsClone = false;
        hyperJumpRemoveData.cardIds = kanbanCardsForBroadCast;
        String someJSONData2 = JSON.serialize(hyperJumpRemoveData);
        if(remoteObject.sendBroadcastMessage == null){
            try{
                leankor.RealTimeController.KanbanStateChange(remoteObject.TargetVSID, 'BulkHyperjump', UserInfo.getSessionId(), someJSONData);
                    if (!remoteObject.IsClone) {
                        System.debug(someJSONData2);
                        leankor.RealTimeController.KanbanStateChange(oldvs, 'RemoveMCChildren', UserInfo.getSessionId(), someJSONData2);
                    }
            } catch (Exception e){
                System.debug('ERROR: while : Creating Kanban Card ' + e.getMessage());
                //25/04/2023 : We are Throwing Exception
                throw new Util.LeanException('ERROR:' + e.getMessage());
            }
        }
        // String someJSONData = '{"OldVS":"'+oldvs+'","ValueStreamOwnerName" : "'+UserName.Name+'","ValueStreamID" :"'+ remoteObject.TargetVSID+'","IsClone" :"'+ remoteObject.Isclone+'","CardIds" :"'+leankor.RealTimeController.gskanbanCardIds+'"}';
        leankor.RealTimeController.gskanbanCardIds.clear();
        //Pratiksha : 19/Sep/2023 : We shifted this ProjectEvent code at last of all execution, When Constraint is violate while running the API then Event will fire.
        if(!violationResult.isEmpty()){
            System.debug('Constraint is violated');
            KanbanController.createProjectEvent(projectId, remoteObject.IsClone, remoteObject.projectEventCustomPayload, Json.serialize(violationResult));
        }
        return someJSONData;   
    }


    //04/04/2023 : Created new method for fire the ProjectEvent.
    private static void createProjectEvent(String projectId, Boolean isClone ,String customPayload, String jsonPayload) {
        //Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in Another try/Catch block.
        try{
            //------------------- BEGIN platform event broadcast
            if(String.isNotBlank(projectId) && leankor.Util.getSObjectName(projectId) == 'leankor__ProjectRoom__c'){
                leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();

                projectEvent.leankor__EventCategory__c = isClone ? 'Cloning' : 'HyperJumping';
                projectEvent.leankor__EventName__c = isClone ? 'EndCloneWorkItem' : 'EndHyperJumpWorkItem';
                projectEvent.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
                projectEvent.leankor__ProjectID__c = projectId;
                projectEvent.leankor__UserID__c = UserInfo.getUserId();
                projectEvent.leankor__CustomPayload__c = customPayload;
                projectEvent.leankor__JSONPayload__c = jsonPayload;
        
                // Call method to publish events
                Database.SaveResult saveResult = EventBus.publish(projectEvent);
                //Update EventUuid in projectRoom object.
                if (!saveResult.isSuccess()){
                    // quick error processing, no need to Rollback
                    for (Database.Error error : saveResult.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
                    }
                    // continue on because a failed platform event is no big deal ; do NOT rollback
                }   
            }
            //------------------- END platform event broadcast 
        }catch(Exception ex){
            System.debug('ERROR :: '+ex.getMessage());
        } 
   }

    public class HyperJumpData{
        public String ValueStreamOld;
        public String ValueStreamOwnerName;
        public String ValueStreamID;
        public boolean IsClone;
        public String TargetVSID;
        public String SourceVSID;
        public List<String> CardIDs;
    }

     
   @RemoteAction
    Global static List<CreateFilter> getFilterRecords (String valustreamId) {
        //Check CRUD / FLC behavior 
        FilterBehaviour FilterBehaviour = new FilterBehaviour();
        if (!FilterBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<CreateFilter> restultLogs = new List<CreateFilter>();
        for(leankor__Filter__c getFilters : [SELECT Id,
                                                    leankor__OwnerData__c,
                                                    leankor__BoardURL__c, 
                                                    leankor__DefaultFilter__c, 
                                                    leankor__FilterON__c, 
                                                    leankor__User__c,
                                                    leankor__PriorityData__c,
                                                    leankor__StickerData__c,
                                                    leankor__CategoryData__c,
                                                    leankor__PortfolioLinkData__c,
                                                    leankor__ValueStream__c,
                                                    Name,
                                                    OwnerId,
                                                    leankor__FeatureData__c, 
                                                    leankor__MiniatureName__c,
                                                    leankor__PercentCompleteRangeFilter__c ,
                                                    leankor__VisibleColumnWidth__c,
                                                    leankor__GanttDividerSize__c,
                                              		leankor__ValueStream__r.leankor__BoardType__c
                                                FROM leankor__Filter__c 
                                                WHERE leankor__ValueStream__c = :valustreamId 
                                                    AND leankor__User__c =:UserInfo.getUserId() 
                                                ORDER BY SystemModstamp 
                                                LIMIT 49999]) {
            CreateFilter filterLog = new CreateFilter();
            filterLog.CategoryName = String.isBlank(getFilters.leankor__CategoryData__c) ? '' :getFilters.leankor__CategoryData__c.unescapeHtml3() ;
            filterLog.OwnerName = String.isBlank(getFilters.leankor__OwnerData__c) ? '' :getFilters.leankor__OwnerData__c.unescapeHtml3();
            filterLog.PortfolioLinkCards = String.isBlank(getFilters.leankor__PortfolioLinkData__c) ? '' :getFilters.leankor__PortfolioLinkData__c.unescapeHtml3();
            filterLog.PriorityName = String.isBlank(getFilters.leankor__PriorityData__c) ? '' : getFilters.leankor__PriorityData__c.unescapeHtml3();
            filterLog.StickerName = String.isBlank(getFilters.leankor__StickerData__c) ? '' :getFilters.leankor__StickerData__c.unescapeHtml3();
            filterLog.ValueStream = getFilters.leankor__ValueStream__c;
            filterLog.User = getFilters.leankor__User__c;
            filterLog.ID = getFilters.ID;
            filterLog.FilterName = getFilters.Name;
            filterLog.IsFilterON = getFilters.leankor__FilterON__c;
            filterLog.IsDefaultFilter = getFilters.leankor__DefaultFilter__c;
            filterLog.BoardURL = getFilters.leankor__BoardURL__c;
            filterLog.FeatureData = String.isBlank(getFilters.leankor__FeatureData__c) ? '':getFilters.leankor__FeatureData__c.unescapeHtml3();
            filterLog.visibleColumnWidth = String.isBlank(getFilters.leankor__VisibleColumnWidth__c) ? '' : getFilters.leankor__VisibleColumnWidth__c.unescapeHtml3();
            if (getFilters.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard') {
                filterLog.ganttDividerSize = getFilters.leankor__GanttDividerSize__c;  
            }
            //Date: 26/07/2019
            filterLog.MiniatureName = getFilters.leankor__MiniatureName__c;
            //Date :11/09/19
            filterLog.PercentCompleteRange =   String.isBlank(getFilters.leankor__PercentCompleteRangeFilter__c)?'':getFilters.leankor__PercentCompleteRangeFilter__c;
            restultLogs.add(filterLog);
        }
        //if(restultLogs.size()<=0){
            //CreateFilter filterLog = new CreateFilter();
            //restultLogs.add(filterLog);            
        //}
        return restultLogs;
    }   


    Global class CreateFilter {
        Global string CategoryName;
        Global string FilterName;
        Global string OwnerName;
        Global string PortfolioLinkCards;
        Global string ValueStream;
        Global string ID;
        Global string OwnerId;
        Global string User;
        Global boolean IsFilterON;
        Global boolean IsDefaultFilter;
        Global string BoardURL;
        Global string PriorityName;
        Global string StickerName;
        global Boolean isFilterONUpdate;
        global String FeatureData;
        //Date: 26/07/2019
        Public string MiniatureName;
        //Date :11/09/19
        public String PercentCompleteRange;
        
        public string visibleColumnWidth;
        public Decimal ganttDividerSize;
    }


     @RemoteAction
     Global static Boolean deleteFilterRecords(list<string> FilterID){
        //Check CRUD / FLC behavior 
        FilterBehaviour FilterBehaviour = new FilterBehaviour();
        if (
            !FilterBehaviour.isAccessible() ||
            !FilterBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        List<leankor__Filter__c> filters = new List<leankor__Filter__c>();
        for(leankor__Filter__c filter : [Select Id,
                                        leankor__ValueStream__c,
                                        leankor__User__c 
                                    From leankor__Filter__c 
                                    Where Id In :filterId]){

            filter.leankor__ValueStream__c = null;
            filter.leankor__User__c = null;
            filters.add(filter);
        }
        try{
            update filters;
            return true;
        }catch (Exception e){
            System.debug('ERROR: while : updating filter records ' + e.getMessage());
            //return false;
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
        }
     } 


     @RemoteAction
     Global static CreateFilter createFilterRecords(List<CreateFilter> fliterLogs){
        //Check CRUD / FLC behavior 
        FilterBehaviour FilterBehaviour = new FilterBehaviour();
        if (
            !FilterBehaviour.isAccessible() ||
            !FilterBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__Filter__c> filterInsertLogs = new List<leankor__Filter__c>();
        CreateFilter restultLog = new CreateFilter();
        for(CreateFilter fliterObjLog :fliterLogs){
            leankor__Filter__c filterLog = new leankor__Filter__c();
                filterLog.leankor__CategoryData__c = fliterObjLog.CategoryName;
                filterLog.leankor__OwnerData__c = fliterObjLog.OwnerName;
                filterLog.leankor__PortfolioLinkData__c = fliterObjLog.PortfolioLinkCards;
                filterLog.leankor__ValueStream__c = fliterObjLog.ValueStream;
                filterLog.Name = fliterObjLog.FilterName;
                filterLog.OwnerId = fliterObjLog.User;
                filterLog.leankor__User__c = fliterObjLog.User;
                filterLog.leankor__PriorityData__c = fliterObjLog.PriorityName;
                filterLog.leankor__StickerData__c = fliterObjLog.StickerName;
                filterLog.leankor__FilterON__c = fliterObjLog.IsFilterON;
                filterLog.leankor__DefaultFilter__c = fliterObjLog.IsDefaultFilter;
                filterLog.leankor__BoardURL__c = fliterObjLog.BoardURL;
                filterLog.leankor__FeatureData__c= fliterObjLog.FeatureData;
                filterLog.leankor__VisibleColumnWidth__c= fliterObjLog.visibleColumnWidth;
                filterLog.leankor__GanttDividerSize__c = fliterObjLog.ganttDividerSize != null ? fliterObjLog.ganttDividerSize : 0;

                //Date: 26/07/2019
                filterLog.leankor__MiniatureName__c= fliterObjLog.MiniatureName;
                //Date :11/09/19
            	filterLog.leankor__PercentCompleteRangeFilter__c =  fliterObjLog.PercentCompleteRange;
            	
            filterInsertLogs.add(filterLog);
        }
        try{
            insert filterInsertLogs;
            restultLog.CategoryName = filterInsertLogs[0].leankor__CategoryData__c;
            restultLog.OwnerName = filterInsertLogs[0].leankor__OwnerData__c;
            restultLog.PortfolioLinkCards = filterInsertLogs[0].leankor__PortfolioLinkData__c;
            restultLog.ValueStream = filterInsertLogs[0].leankor__ValueStream__c;
            restultLog.FilterName = filterInsertLogs[0].Name;
            restultLog.ID = filterInsertLogs[0].ID;
            restultLog.IsFilterON = filterInsertLogs[0].leankor__FilterON__c;
			restultLog.IsDefaultFilter = filterInsertLogs[0].leankor__DefaultFilter__c;
			restultLog.BoardURL = filterInsertLogs[0].leankor__BoardURL__c;
			restultLog.User = filterInsertLogs[0].leankor__User__c;
			restultLog.PriorityName = (filterInsertLogs[0].leankor__PriorityData__c == null ? '' : filterInsertLogs[0].leankor__PriorityData__c);
		    restultLog.StickerName = (filterInsertLogs[0].leankor__StickerData__c== null ? '' :filterInsertLogs[0].leankor__StickerData__c);
            restultLog.FeatureData=(filterInsertLogs[0].leankor__FeatureData__c== null ? '' :filterInsertLogs[0].leankor__FeatureData__c);
            restultLog.visibleColumnWidth = (filterInsertLogs[0].leankor__VisibleColumnWidth__c == null ? '' : filterInsertLogs[0].leankor__VisibleColumnWidth__c);
            restultLog.ganttDividerSize = filterInsertLogs[0].leankor__GanttDividerSize__c;
            //Date: 26/07/2019
            restultLog.MiniatureName= filterInsertLogs[0].leankor__MiniatureName__c;
            //Date :11/09/19
            restultLog.PercentCompleteRange = (filterInsertLogs[0].leankor__PercentCompleteRangeFilter__c== null ? '': filterInsertLogs[0].leankor__PercentCompleteRangeFilter__c);
            return restultLog;
         }catch (Exception e){
            System.debug('ERROR: while : Inserting filter records ' + e.getMessage());
            //return new CreateFilter();
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
         }
    }

    /***
     * Company : Leankor
     * Description : This Method used to create/update Filter records.
     * Input :  List of CreateFilter "List<CreateFilter>" inner class Object.
     * Output : List of created/updated Filter record if form of list of CreateFilter "List<CreateFilter>" inner class Object.
    */
    @RemoteAction
     global static List<CreateFilter> setMultipleFilterRecords(List<CreateFilter> fliterLogs){
        //Check CRUD / FLC behavior 
        FilterBehaviour FilterBehaviour = new FilterBehaviour();
        if (
            !FilterBehaviour.isAccessible() ||
            !FilterBehaviour.isCreateable() ||
            !FilterBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        List<leankor__Filter__c> filterInsertLogs = new List<leankor__Filter__c>();
        List<CreateFilter> restultLogs = new List<CreateFilter>();
        for(CreateFilter fliterObjLog :fliterLogs){
            leankor__Filter__c filterLog = new leankor__Filter__c();
            if(!fliterObjLog.isFilterONUpdate){
                filterLog.leankor__CategoryData__c = fliterObjLog.CategoryName;
                filterLog.leankor__OwnerData__c = fliterObjLog.OwnerName;
                filterLog.leankor__PortfolioLinkData__c = fliterObjLog.PortfolioLinkCards;
                filterLog.leankor__ValueStream__c = fliterObjLog.ValueStream;
                filterLog.Name = fliterObjLog.FilterName;
                filterLog.OwnerId = fliterObjLog.User;
                filterLog.leankor__User__c = fliterObjLog.User;
                filterLog.leankor__PriorityData__c = fliterObjLog.PriorityName;
                filterLog.leankor__StickerData__c = fliterObjLog.StickerName;
                filterLog.leankor__FilterON__c = fliterObjLog.IsFilterON;
                filterLog.leankor__DefaultFilter__c = fliterObjLog.IsDefaultFilter;
                filterLog.leankor__BoardURL__c = fliterObjLog.BoardURL;
                if(String.isNotBlank(fliterObjLog.ID) && fliterObjLog.ID != null){
			    	filterLog.Id= fliterObjLog.ID;
                }

                filterLog.leankor__MiniatureName__c= fliterObjLog.MiniatureName;
            	filterLog.leankor__PercentCompleteRangeFilter__c =  fliterObjLog.PercentCompleteRange;
            }else{ 
                filterLog.Id = fliterObjLog.ID;            
                filterLog.leankor__FilterON__c = fliterObjLog.IsFilterON; 
            }
            	
            filterInsertLogs.add(filterLog);
        }
        try{
            upsert filterInsertLogs;
            List<leankor__Filter__c> updatedFilterInsertLogs = [Select Id,
                                                                        Name,
                                                                        leankor__BoardURL__c, 
                                                                        leankor__DefaultFilter__c, 
                                                                        leankor__FilterON__c, 
                                                                        leankor__User__c,
                                                                        leankor__PriorityData__c,
                                                                        leankor__StickerData__c,
                                                                        leankor__CategoryData__c,
                                                                        leankor__OwnerData__c,
                                                                        leankor__PortfolioLinkData__c,
                                                                        leankor__ValueStream__c,
                                                                        leankor__FeatureData__c, 
                                                                        leankor__MiniatureName__c,
                                                                        leankor__PercentCompleteRangeFilter__c 
                                                                    From leankor__Filter__c 
                                                                    Where ID In: filterInsertLogs];
            
            for(leankor__Filter__c filter : updatedFilterInsertLogs) {
                CreateFilter restultLog = new CreateFilter();
                restultLog.CategoryName = filter.leankor__CategoryData__c;
                restultLog.OwnerName = filter.leankor__OwnerData__c;
                restultLog.PortfolioLinkCards = filter.leankor__PortfolioLinkData__c;
                restultLog.ValueStream = filter.leankor__ValueStream__c;
                restultLog.FilterName = filter.Name;
                restultLog.ID = filter.ID;
                restultLog.IsFilterON = filter.leankor__FilterON__c;
                restultLog.IsDefaultFilter = filter.leankor__DefaultFilter__c;
                restultLog.BoardURL = filter.leankor__BoardURL__c;
                restultLog.User = filter.leankor__User__c;
                restultLog.PriorityName = (filter.leankor__PriorityData__c == null ? '' : filter.leankor__PriorityData__c);
                restultLog.StickerName = (filter.leankor__StickerData__c== null ? '' :filter.leankor__StickerData__c);
                //restultLog.FeatureData=(filter.leankor__FeatureData__c== null ? '' :filter.leankor__FeatureData__c);
                //Date: 26/07/2019
                restultLog.MiniatureName= filter.leankor__MiniatureName__c;
                //Date :11/09/19
                restultLog.PercentCompleteRange = (filter.leankor__PercentCompleteRangeFilter__c== null ? '': filter.leankor__PercentCompleteRangeFilter__c);
                restultLogs.add(restultLog);
            }
            return restultLogs;
         }
         catch (Exception e){
            System.debug('ERROR: while : Inserting filter records ' + e.getMessage());
            throw new leankor.GanttTaskBoard.LeanException('Exception Error: ' + e.getMessage());
        }
    }

     /***
     * Company : Leankor
     * Description : This Method used to create/update Filter records feature data.
     * Input :  List of CreateFilter "List<CreateFilter>" inner class Object.
     * Output : List of created/updated Filter record if form of list of CreateFilter "List<CreateFilter>" inner class Object.
    */
    @RemoteAction
    global static List<CreateFilter> setFilterFeatureData(List<CreateFilter> fliterLogs){
        //Check CRUD / FLC behavior 
        FilterBehaviour FilterBehaviour = new FilterBehaviour();
        if (
            !FilterBehaviour.isAccessible() ||
            !FilterBehaviour.isCreateable() ||
            !FilterBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        List<leankor__Filter__c> filterInsertLogs = new List<leankor__Filter__c>();
        CreateFilter restultLog = new CreateFilter();
        List<CreateFilter> restultLogs = new List<CreateFilter>();
        for(CreateFilter fliterObjLog :fliterLogs){
            leankor__Filter__c filterLog = new leankor__Filter__c();
                filterLog.leankor__ValueStream__c = fliterObjLog.ValueStream;
                filterLog.leankor__BoardURL__c = fliterObjLog.BoardURL;
                System.debug('==> fliterObjLog.ID => '+fliterObjLog.ID);
                if(String.isNotBlank(fliterObjLog.ID) && fliterObjLog.ID != null){
			    	filterLog.Id= fliterObjLog.ID;
				}
            
			    filterLog.leankor__FeatureData__c= fliterObjLog.FeatureData;
                filterLog.leankor__User__c = fliterObjLog.User;
                filterLog.OwnerId = fliterObjLog.User;     	
            filterInsertLogs.add(filterLog);
        }
        try{
            upsert filterInsertLogs;
            for(leankor__Filter__c filter : filterInsertLogs) {
                restultLog.ValueStream = filter.leankor__ValueStream__c;
                restultLog.BoardURL = filter.leankor__BoardURL__c;
                restultLog.ID = filter.ID;
                restultLog.User = filter.leankor__User__c;
                restultLog.FeatureData=(filter.leankor__FeatureData__c== null ? '' :filter.leankor__FeatureData__c);
                restultLogs.add(restultLog);
            }
            return restultLogs;
         }catch (Exception e){
            System.debug('ERROR: while : Inserting filter records ' + e.getMessage());
            //return new List<CreateFilter>();
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
         }
    }

    @AuraEnabled
    public static CreateFilterRequest updateFilterData(CreateFilterRequest filterLogs) {
        // Validate input
        if (filterLogs == null) {
            throw new Util.LeanException('Error: filterLogs cannot be null');
        }
        
        // Convert CreateFilterRequest to CreateFilter
        KanbanController.CreateFilter createFilter = new  KanbanController.CreateFilter();
        createFilter.CategoryName = filterLogs.categoryName;
        createFilter.FilterName = filterLogs.filterName;
        createFilter.OwnerName = filterLogs.ownerName;
        createFilter.PortfolioLinkCards = filterLogs.portfolioLinkCards;
        createFilter.ValueStream = filterLogs.valueStream;
        createFilter.ID = filterLogs.id;
        createFilter.OwnerId = filterLogs.ownerId;
        createFilter.User = filterLogs.user;
        createFilter.IsFilterON = filterLogs.isFilterON;
        createFilter.IsDefaultFilter = filterLogs.isDefaultFilter;
        createFilter.BoardURL = filterLogs.boardURL;
        createFilter.PriorityName = filterLogs.priorityName;
        createFilter.StickerName = filterLogs.stickerName;
        createFilter.MiniatureName = filterLogs.miniatureName;
        createFilter.PercentCompleteRange = filterLogs.percentCompleteRange;
        createFilter.visibleColumnWidth = filterLogs.visibleColumnWidth;
        createFilter.ganttDividerSize = filterLogs.ganttDividerSize;
        
        // Call existing updateFilterRecords method with CreateFilter
        KanbanController.CreateFilter resultLogs = KanbanController.updateFilterRecords(createFilter);
        
        // Map resultLogs to CreateFilterRequest for response
        CreateFilterRequest response = new CreateFilterRequest();
        response.categoryName = String.isBlank(resultLogs.CategoryName) ? '' : resultLogs.CategoryName;
        response.ownerName = String.isBlank(resultLogs.OwnerName) ? '' : resultLogs.OwnerName;
        response.portfolioLinkCards = String.isBlank(resultLogs.PortfolioLinkCards) ? '' : resultLogs.PortfolioLinkCards;
        response.valueStream = resultLogs.ValueStream;
        response.id = resultLogs.ID;
        response.isFilterON = resultLogs.IsFilterON;
        response.isDefaultFilter = resultLogs.IsDefaultFilter;
        response.boardURL = resultLogs.BoardURL;
        response.user = resultLogs.User;
        response.priorityName = (resultLogs.PriorityName == null ? '' : resultLogs.PriorityName);
        response.stickerName = (resultLogs.StickerName == null ? '' : resultLogs.StickerName);
        response.featureData     = (resultLogs.FeatureData == null ? '' : resultLogs.FeatureData);
        response.visibleColumnWidth = (resultLogs.visibleColumnWidth == null ? '' : resultLogs.visibleColumnWidth);
        response.ganttDividerSize = resultLogs.ganttDividerSize == null ? null : resultLogs.ganttDividerSize;
        response.miniatureName = String.isBlank(resultLogs.MiniatureName) ? '' : resultLogs.MiniatureName; 
        response.percentCompleteRange = (resultLogs.PercentCompleteRange == null ? '' : resultLogs.PercentCompleteRange);

        return response;


    }


    @RemoteAction
    Global static CreateFilter updateFilterRecords(CreateFilter fliterLogs) {
        //Check CRUD / FLC behavior 
        FilterBehaviour FilterBehaviour = new FilterBehaviour();
        if (
            !FilterBehaviour.isAccessible() ||
            !FilterBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        CreateFilter restultLog = new CreateFilter();
        leankor__Filter__c getFilterrecords = [SELECT Id,
                                                    Name,
                                                    leankor__BoardURL__c, 
                                                    leankor__DefaultFilter__c, 
                                                    leankor__FilterON__c, 
                                                    leankor__User__c,
                                                    leankor__PriorityData__c,
                                                    leankor__StickerData__c,
                                                    leankor__CategoryData__c,
                                                    leankor__OwnerData__c,
                                                    leankor__PortfolioLinkData__c,
                                                    leankor__ValueStream__c,
                                                    leankor__FeatureData__c, 
                                                    leankor__MiniatureName__c,
                                                    leankor__PercentCompleteRangeFilter__c ,
                                                    leankor__VisibleColumnWidth__c,
                                               		leankor__GanttDividerSize__c,
                                                    leankor__ValueStream__r.leankor__BoardType__c
                                                FROM leankor__Filter__c 
                                                WHERE ID = :Fliterlogs.ID 
                                                LIMIT 1];
            
            if(!Fliterlogs.isFilterONUpdate){
	            getFilterrecords.leankor__CategoryData__c = fliterLogs.CategoryName;
	            getFilterrecords.leankor__OwnerData__c = fliterLogs.OwnerName;
	            getFilterrecords.leankor__PortfolioLinkData__c = fliterLogs.PortfolioLinkCards;
	            getFilterrecords.Name = fliterLogs.filterName;
	            getFilterrecords.leankor__FilterON__c = fliterLogs.IsFilterON ;
				getFilterrecords.leankor__DefaultFilter__c = fliterLogs.IsDefaultFilter;
				getFilterrecords.leankor__BoardURL__c = fliterLogs.BoardURL;
				getFilterrecords.leankor__User__c = fliterLogs.User;
				getFilterrecords.leankor__PriorityData__c = fliterLogs.PriorityName;
			    getFilterrecords.leankor__StickerData__c = fliterLogs.StickerName;
                 if (getFilterrecords.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard') {
                    getFilterrecords.leankor__GanttDividerSize__c = fliterLogs.ganttDividerSize;
                }
				if(String.isNotBlank(fliterLogs.FeatureData)){
			    	getFilterrecords.leankor__FeatureData__c=fliterLogs.FeatureData;
				}
                if(String.isNotBlank(fliterLogs.visibleColumnWidth)) {
			    	getFilterrecords.leankor__VisibleColumnWidth__c = fliterLogs.visibleColumnWidth;
				}
				    //Date: 26/07/2019
				getFilterrecords.leankor__MiniatureName__c=fliterLogs.MiniatureName;
				//Date :11/09/19
               getFilterrecords.leankor__PercentCompleteRangeFilter__c =  fliterLogs.PercentCompleteRange;
            }else{            
 				getFilterrecords.leankor__FilterON__c = fliterLogs.IsFilterON;           
            }
            
        try{
            update getFilterrecords;
            restultLog.CategoryName = String.isBlank(getFilterrecords.leankor__CategoryData__c) ? '' :getFilterrecords.leankor__CategoryData__c;
            restultLog.OwnerName = String.isBlank(getFilterrecords.leankor__OwnerData__c) ? '' :getFilterrecords.leankor__OwnerData__c;
            restultLog.PortfolioLinkCards = String.isBlank(getFilterrecords.leankor__PortfolioLinkData__c) ? '' :getFilterrecords.leankor__PortfolioLinkData__c;
            restultLog.ValueStream = getFilterrecords.leankor__ValueStream__c;
            restultLog.ID = getFilterrecords.ID;
            restultLog.IsFilterON = getFilterrecords.leankor__FilterON__c;
			restultLog.IsDefaultFilter = getFilterrecords.leankor__DefaultFilter__c;
			restultLog.BoardURL = getFilterrecords.leankor__BoardURL__c;
			restultLog.User = getFilterrecords.leankor__User__c;
			restultLog.PriorityName = (getFilterrecords.leankor__PriorityData__c == null ? '' : getFilterrecords.leankor__PriorityData__c);
    		restultLog.StickerName = (getFilterrecords.leankor__StickerData__c== null ? '' :getFilterrecords.leankor__StickerData__c);
    		restultLog.FeatureData = (getFilterrecords.leankor__FeatureData__c== null ? '' : getFilterrecords.leankor__FeatureData__c);
            restultLog.visibleColumnWidth = (getFilterrecords.leankor__VisibleColumnWidth__c == null ? '' : getFilterrecords.leankor__VisibleColumnWidth__c);
 			if (getFilterrecords.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard') {
                restultLog.ganttDividerSize = getFilterrecords.leankor__GanttDividerSize__c;
            }    		
            restultLog.MiniatureName= String.isBlank(getFilterrecords.leankor__MiniatureName__c) ? '' : getFilterrecords.leankor__MiniatureName__c; 
            //Date :11/09/19
            restultLog.PercentCompleteRange=( getFilterrecords.leankor__PercentCompleteRangeFilter__c== null ? '': getFilterrecords.leankor__PercentCompleteRangeFilter__c);
            return restultLog;
        }catch (Exception e) {
            System.debug('ERROR: while : Inserting filter records ' + e.getMessage());
            //return new CreateFilter();
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
        }
    }


    global class clonestartboard{
        Global string StartDate;
        Global Boolean TaskVerb;
        Global string someJSONData;
    }


    @RemoteAction
    Global static String cloneCardwithStartDate(ID VSID,clonestartboard clonelog,string mySessionID){
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        ProjectScheduleBlackoutBehaviour ProjectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isCreateable() ||
            !scheduleModeBehavior.isAccessible() ||
            !resourceAssignmentBehavior.isAccessible() ||
            !ProjectScheduleBlackoutBehaviour.isAccessible() ||
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isCreateable() ||
            !feedItemBehaviour.isAccessible() ||
            !feedItemBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        String oldKanbanID = '';
        Integer otherDifference = 0;
        Datetime TempStartDate = (DateTime)JSON.deserialize(clonelog.StartDate, DateTime.class);
        
        leankor.RealTimeController.Kanban remoteKanban = (leankor.RealTimeController.Kanban)JSON.deserialize(clonelog.SomeJSONData, leankor.RealTimeController.Kanban.class);
        oldKanbanID = remoteKanban.Id;

        /**Variables for cloning constraqint data */
        Integer startDateConstraintDifference = 0;
        Integer dueDateconstraintDifference = 0;
        String tempConstraintType = remoteKanban.ConstraintType;
		//making GUID for cloning RA and Sm
         remoteKanban.GUID = oldKanbanID +'-'+system.now().gettime();
        Map<String, leankor__ScheduleConstraint__c> scheduleConstraints = GanttTaskBoard.getScheduleConstraints();
        //getting records for RA and Sm
        //Added filter for excluding softDeleted card or VS							
        //RS 28/11/2019 Added Owner.IsActive to query							
        Map<Id, leankor__KanbanCard__C> mapOfRemoteKanbanCards = new Map<Id, leankor__KanbanCard__C>([Select Id,
                                                                                                            leankor__HarveyBallDoneDate__c,
                                                                                                            leankor__PromiseCompletionDate__c,
                                                                                                            leankor__ValueStreamLink__c,
                                                                                                            leankor__ValueStreamCardLink__c,
                                                                                                            leankor__StartDateTime__C,
                                                                                                            leankor__DueDateTime__C,
                                                                                                            (Select Id,
                                                                                                                    leankor__ManuallyScheduled__c,
                                                                                                                    leankor__Mode__c,
                                                                                                                    leankor__EffortUnits__c,
                                                                                                                    leankor__EffortActual__c,
                                                                                                                    leankor__KanbanCard__c,
                                                                                                                    leankor__KanbanCard__r.leankor__valuestream__c,
                                                                                                                   leankor__ConstraintDateTime__c,
                                                                                                                   leankor__ScheduleConstraint__r.leankor__Type__c
                                                                                                                   //leankor__Readonly__c
                                                                                                               From leankor__ScheduleModes__r 
                                                                                                               Limit 1),
                                                                                                            (Select 
                                                                                                                    Id,
                                                                                                                    leankor__AssignedTo__c,
                                                                                                                    leankor__KanbanCard__c,
                                                                                                                    leankor__CompletedDate__c,
                                                                                                                    leankor__KanbanCard__r.leankor__valuestream__c,
                                                                                                                    leankor__PercentAllocation__c,
                                                                                                                    leankor__PercentCompleted__c,
                                                                                                                    Name,
                                                                                                                    leankor__ExpenseAccount__c,
                                                                                                                    leankor__ExpenseSubCategory__c,
                                                                                                                    leankor__ExpenseCategory__c,
                                                                                                                    leankor__ExternalHourlyRate__c,
                                                                                                                    leankor__InternalHourlyRate__c,
                                                                                                                    leankor__ResourceType__c,
                                                                                                                    leankor__ProjectFinancial__c,
                                                                                                                    leankor__AssignedTo__r.IsActive                            
                                                                                                                From leankor__ResourceAssignments__r),                               
                                                                                                            RecordType.Name,
                                                                                                            leankor__CardID__c,
                                                                                                            leankor__valueStream__r.leankor__BoardType__c,
                                                                                                            leankor__valueStream__r.leankor__SevenDayWorkWeek__c,
                                                                                                            leankor__KanbanCardTemplate__r.leankor__FieldSetName__c,
                                                                                                            Owner.IsActive,
                                                                                                            leankor__Monday__c,
                                                                                                            leankor__Tuesday__c,
                                                                                                            leankor__Wednesday__c,
                                                                                                            leankor__Thursday__c,
                                                                                                            leankor__Friday__c,
                                                                                                            leankor__Saturday__c,
                                                                                                            leankor__Sunday__c,
                                                                                                            leankor__WeekCalendar__c                                           
                                                                                                    From leankor__KanbanCard__c 
                                                                                                    Where Id = :remoteKanban.Id
                                                                                                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false 
                                                                                                        And leankor__IsRecordDeleted__c = false
                                                                                                    Order By leankor__Order__c Desc Nulls Last
                                                                                                    Limit 9999]);

        String stringWithQuotes;
        stringWithQuotes = '\'' + oldKanbanID + '\'';

        Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();
        Map<Id, leankor__KanbanCard__C> kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__C>();
        List<String> cardIdList = new List<String>{remoteKanban.Id};
        KanbanController.FieldSetRecord singleFieldSetRecord = KanbanController.getAllFieldsetAndFieldDataForCloning(cardIdlist, 'leankor__KanbanCard__c');
        if(singleFieldSetRecord.allFields.size() > 0){
            String soql ='Select Id'+ singleFieldSetRecord.allFieldsInStringFormat + ' From leankor__KanbanCard__c Where Id In ('+stringWithQuotes+') Limit 50000';
            kanbaCardIdandFields = new Map<Id, leankor__KanbanCard__c>((List<leankor__KanbanCard__c>)Database.query(soql));
        }


        
		if (mapOfRemoteKanbanCards.values().size() == 0) {
			return 'failure';
		}

        //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar While Cloning the KanbanCard from UI and API also.
        Set<String> weekDays = new Set<String>();
        if(mapOfRemoteKanbanCards.values().leankor__valueStream__r.leankor__SevenDayWorkWeek__c){
            //Pratiksha : 13/Oct/2023 : Changes for WeekCalendar
            if(mapOfRemoteKanbanCards.values().leankor__Monday__c == false && mapOfRemoteKanbanCards.values().leankor__Tuesday__c == false && mapOfRemoteKanbanCards.values().leankor__Wednesday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Thursday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Friday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Saturday__c == false &&  mapOfRemoteKanbanCards.values().leankor__Sunday__c == false){
                remoteKanban.Monday = true;
                remoteKanban.Tuesday = true;
                remoteKanban.Wednesday = true;
                remoteKanban.Thursday = true;
                remoteKanban.Friday = true;
                remoteKanban.Saturday = true;
                remoteKanban.Sunday = true;
            }else{
                remoteKanban.Monday = mapOfRemoteKanbanCards.values().leankor__Monday__c;
                remoteKanban.Tuesday = mapOfRemoteKanbanCards.values().leankor__Tuesday__c;
                remoteKanban.Wednesday = mapOfRemoteKanbanCards.values().leankor__Wednesday__c;
                remoteKanban.Thursday = mapOfRemoteKanbanCards.values().leankor__Thursday__c;
                remoteKanban.Friday = mapOfRemoteKanbanCards.values().leankor__Friday__c;
                remoteKanban.Saturday = mapOfRemoteKanbanCards.values().leankor__Saturday__c;
                remoteKanban.Sunday = mapOfRemoteKanbanCards.values().leankor__Sunday__c;
                remoteKanban.weekCalendar = mapOfRemoteKanbanCards.values().leankor__WeekCalendar__c;
          
                weekDays.add(remoteKanban.Monday == false ? 'Mon' : 'false');
                weekDays.add(remoteKanban.Tuesday == false ? 'Tue' : 'false');
                weekDays.add(remoteKanban.Wednesday == false ? 'Wed' : 'false');
                weekDays.add(remoteKanban.Thursday == false ? 'Thu' : 'false');
                weekDays.add(remoteKanban.Friday == false ? 'Fri' : 'false');
                weekDays.add(remoteKanban.Saturday == false ? 'Sat' : 'false');
                weekDays.add(remoteKanban.Sunday == false ? 'Sun' : 'false');
            }
        }
        Util.weekDays = weekDays;

        // getting the value schedulemode record because remove the hardcode
        Map<Id, leankor__ScheduleMode__c> mapOfScheduleMode = new Map<Id, leankor__ScheduleMode__c>();
        for(leankor__ScheduleMode__c schedulemode : mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ScheduleModes__r){
            mapOfScheduleMode.put(schedulemode.Id, schedulemode);
            //Changes : Check constraint setting enable or not.
            if (mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ScheduleModes__r.size() > 0 && realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                remoteKanban.ConstraintDate = remoteKanban.ConstraintDate == null ? mapOfScheduleMode.get(schedulemode.Id).leankor__ConstraintDateTime__c : remoteKanban.ConstraintDate;
                tempConstraintType = tempConstraintType == null ? mapOfScheduleMode.get(schedulemode.Id).leankor__ScheduleConstraint__r.leankor__Type__c : tempConstraintType;
            }
        }	
         // Getting the existing Project Schedule Blackout records. 
        List<leankor__ProjectScheduleBlackout__c> projectBlackOutList = [SELECT Id,
                                                                        leankor__EndDate__c,
                                                                        leankor__ProjectBoard__c,
                                                                        leankor__StartDate__c
                                                                    FROM leankor__ProjectScheduleBlackout__c
                                                                    WHERE leankor__ProjectBoard__c =: VSID
                                                                    LIMIT 9999];
		
		//RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries
        // yj : 06 Nov. 2017 getting all user        
        //Map<Id,User> allUserMap = getAllUser();
        // yj : 06 Nov. 2017 
        
        //remoteKanban.Id = '';
        //otherDifference =(Date.newInstance(TempStartDate.year(),TempStartDate.month(),TempStartDate.day())).daysBetween(Date.newInstance(remoteKanban.StartDate.year(),remoteKanban.StartDate.month(),remoteKanban.StartDate.day()));
        otherDifference =(Date.newInstance(remoteKanban.StartDate.year(),remoteKanban.StartDate.month(),remoteKanban.StartDate.day())).daysBetween(Date.newInstance(TempStartDate.year(),TempStartDate.month(),TempStartDate.day()));
        
        /**finding diffrence startdate/dueDate with ConstraintDate */
        startDateConstraintDifference=remoteKanban.ConstraintDate != null ? (Date.newInstance(remoteKanban.StartDate.year(),remoteKanban.StartDate.month(),remoteKanban.StartDate.day())).daysBetween(Date.newInstance(remoteKanban.ConstraintDate.year(),remoteKanban.ConstraintDate.month(),remoteKanban.ConstraintDate.day())) : 0;
        dueDateconstraintDifference = remoteKanban.ConstraintDate != null ? (Date.newInstance(remoteKanban.DueDate.year(),remoteKanban.DueDate.month(),remoteKanban.DueDate.day())).daysBetween(Date.newInstance(remoteKanban.ConstraintDate.year(),remoteKanban.ConstraintDate.month(),remoteKanban.ConstraintDate.day())) : 0;

        if(remoteKanban.StartDate < TempStartDate){
            remoteKanban.DueDate = remoteKanban.DueDate + math.abs(otherDifference) ;
        }else{ 
            remoteKanban.DueDate = remoteKanban.DueDate - math.abs(otherDifference) ;
        }
        remoteKanban.DueDate = Datetime.newInstance(remoteKanban.DueDate.year(),remoteKanban.DueDate.month(), remoteKanban.DueDate.day(),TempStartDate.hour(),TempStartDate.minute(),TempStartDate.second());
        Datetime TempFinalDate = remoteKanban.DueDate;
        // 11/04/2023 : Time will be Cloned while cloning the card From API
        remoteKanban.StartDate = Datetime.newInstance(TempStartDate.year(),TempStartDate.month(), TempStartDate.day(),mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__StartDateTime__C.hour(),mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__StartDateTime__C.minute(),mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__StartDateTime__C.second());
        if(remoteKanban.Left != null){
            remoteKanban.Left += remoteKanban.Width+3;  
        }
               
        leankor__valuestream__c VS = [select ID,leankor__SevenDayWorkWeek__c,leankor__TaskDatecheck__c from leankor__valuestream__c where ID= :VSID LIMIT 1];
	    Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;   
	    Integer firstDayOfWeek= firstDay==null || firstDay<0  || firstDay > 6?1:firstDay.intValue();
	    
        //Date: 04/11/2019 - Changes for blackout
        //Util.WorkWeek workWeek= new Util.WorkWeek(firstDayOfWeek, VS.leankor__SevenDayWorkWeek__c?7:5)
        Util.WorkWeek workWeek= new Util.WorkWeek(firstDayOfWeek, VS.leankor__SevenDayWorkWeek__c?7:5, projectBlackOutList);
        
        remoteKanban.StartDate = workweek.getNextWorkingDay(remoteKanban.StartDate);
        Datetime tempcalDuedate = remoteKanban.StartDate; 
        
        // Calculating ED
        Integer ED =  integer.valueof(remoteKanban.EstimatedDuration);
        if(remoteKanban.DurationUnits == 'Hours'){
            if(math.mod(ED,8) > 0){
                ED= Integer.valueof(ED/8) + 1;
            }else{
                ED= Integer.valueof(ED/8);
            }
        }else if(remoteKanban.DurationUnits == 'Years'){
            ED= Integer.valueof(ED*365);
        }else if(remoteKanban.DurationUnits == 'Months'){
            ED= Integer.valueof(ED*30);
        }else if(remoteKanban.DurationUnits == 'Minutes'){
            integer temphours;
            if(math.mod(ED,60) >0 ){
                temphours= Integer.valueof(ED/60) + 1;
            }else{
                temphours= Integer.valueof(ED/60);
            }
            if(math.mod(temphours,8) >0){
                ED= Integer.valueof(temphours/8) + 1;
            }else{
                ED= Integer.valueof(temphours/8);
            }
        }else if(remoteKanban.DurationUnits == 'Weeks'){
            ED= Integer.valueof(ED*5);
        }       
        if(!VS.leankor__SevenDayWorkWeek__c){
            if(remoteKanban.DurationUnits == 'Years'){
            	tempcalDuedate = tempcalDuedate.addYears(integer.valueof(remoteKanban.EstimatedDuration));
            	tempcalDuedate = tempcalDuedate -1 ;
            }else if(remoteKanban.DurationUnits == 'Months'){
            	tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(remoteKanban.EstimatedDuration));
            	tempcalDuedate = tempcalDuedate -1 ;
            }else{ 

                // In case of milestone estimate duration is zero. So we assign one for sake of date calculation.
                ED = (ED == 0 ? 1: ED);

                //Date: 14/11/2019 - Calling new method for geting due date.
                tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, ED-1);
                /**
                for(integer i = 1 ;i< ED;i++ ){
                    tempcalDuedate = tempcalDuedate + 1;
                //ss 04.05.2018
                //Calculate WorkingWeekDays escaping non working day according to first day of week
					tempcalDuedate = Util.readNextWorkingDateTime(workWeek,tempcalDuedate);
                /*if(tempcalDuedate.format('E') == 'Sat' || tempcalDuedate.format('E') == 'Sun'){
                    tempcalDuedate = tempcalDuedate + 1;
                }
                if(tempcalDuedate.format('E') == 'Sat' || tempcalDuedate.format('E') == 'Sun'){
                    tempcalDuedate = tempcalDuedate + 1;
            }
        //ss 04.05.2018
                }*/
        
            }
            // In case if due date occured on non-working day. Then getting next working day.
            remoteKanban.DueDate = workWeek.getNextWorkingDay(tempcalDuedate);
            TempFinalDate = remoteKanban.DueDate;

        }else{//For Seven days work week

            if(remoteKanban.DurationUnits == 'Weeks'){
                ED= Integer.valueof(remoteKanban.EstimatedDuration*7);
            }
            if(remoteKanban.DurationUnits == 'Years'){
            tempcalDuedate = tempcalDuedate.addYears(integer.valueof(remoteKanban.EstimatedDuration));
            tempcalDuedate = tempcalDuedate -1 ;
        }else if(remoteKanban.DurationUnits == 'Months'){
            tempcalDuedate = tempcalDuedate.addMonths(integer.valueof(remoteKanban.EstimatedDuration));
            tempcalDuedate = tempcalDuedate -1 ;
        }else{  
                
                // In case of milestone estimate duration is zero. So we assigned one for sake of date calculation.
                ED = (ED == 0 ? 1: ED);

                //Date: 14/11/2019
                tempcalDuedate = workWeek.nextBusinessDate(tempcalDuedate, ED-1);
                /*for(integer i = 1 ;i<ED;i++ ){
                tempcalDuedate = tempcalDuedate + 1;
                }*/
            }
        	// In case if due date occured on non-working day. Then getting next working day.
            remoteKanban.DueDate = workWeek.getNextWorkingDay(tempcalDuedate);
            TempFinalDate = remoteKanban.DueDate;        
        }  
        
        //adding RA and SM for cloning      
        remoteKanban.schedulemodeList = mapOfRemoteKanbanCards.values().leankor__ScheduleModes__r;
		remoteKanban.resourceAssignmentList = mapOfRemoteKanbanCards.values().leankor__ResourceAssignments__r;
                
        RemoteKanban.HarveyBallDoneDate = mapOfRemoteKanbanCards.values().leankor__HarveyBallDoneDate__c;
        RemoteKanban.PromiseCompletionDate = mapOfRemoteKanbanCards.values().leankor__PromiseCompletionDate__c; 
         // Date : 22/10/19 using wrapper class instance instead of Serialization.
        //List<String> KanbanList = new List<String>();
        //KanbanList.add(JSON.Serialize(remoteKanban)); 
        List<realTimeController.Kanban> KanbanList = new List<realTimeController.Kanban>();
        //RS 28/11/2019 Added Owner.IsActive in object
    	RemoteKanban.ownerIsActive = mapOfRemoteKanbanCards.values().Owner.IsActive;
        
        /**setting Constraint values null */
        RemoteKanban.ConstraintDate = null;
        RemoteKanban.ConstraintType = null;
        /**calculating the constraintDates with startDate/dueDate if constraint type is not null or blank*/
        //Changes : Check Constraint setting is enable or not.
        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
            if (String.isNotBlank(tempConstraintType)) {
                RemoteKanban.ConstraintType = scheduleConstraints.get(tempConstraintType).Id;
                RemoteKanban.ConstraintDate = (new List<String>{'assoonaspossible','aslateaspossible'}.contains(tempConstraintType)) ? null : ((new List<String>{'startnoearlierthan','startnolaterthan','muststarton'}.contains(tempConstraintType)) ? RemoteKanban.StartDate + startDateConstraintDifference : RemoteKanban.DueDate + dueDateConstraintDifference);
            }
            remoteKanban.isConstraintRecalculate = true;
        }
        //RS 28/11/2019 Removed allUserMap variable                   		
		//List<leankor__KanbanCard__c> newKanbanCards = leankor.RealTimeController.CreateKanbanCard(VSID, KanbanList, true,allUserMap);

        //05/04/2023 added code for SingleClone API To Check ConstraintViolation
        List<KanbanCard> cardsToCheck = new List<KanbanCard>();
        KanbanController.KanbanCardConstraintViolation violationResult = new KanbanController.KanbanCardConstraintViolation();
        if(String.isNotBlank(remoteKanban.ValueStreamLinkID) && String.isNotBlank(remoteKanban.ValueStreamCardLink)){
            KanbanCard checkCard = new KanbanCard();
            checkCard.name = remoteKanban.Name;
            checkCard.valueStream = remoteKanban.ValueStream;
            checkCard.startDateTime = remoteKanban.StartDate;
            checkCard.dueDateTime = remoteKanban.DueDate;
            checkCard.valueStreamLink = remoteKanban.ValueStreamLinkID; //remoteObject.LinkVSID;
            checkCard.valueStreamCardLink = remoteKanban.ValueStreamCardLink;//remoteObject.LinkCardID;
            checkCard.isUpdateValueStreamCardLink = true;
            //We are commenting this code because we don't need to check constraint on source card and we are also not passing Id of KanbanCard.
            /*if(remoteKanban.ValueStreamLinkID != mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ValueStreamLink__c // remove the hardcode
               || remoteKanban.ValueStreamCardLink != mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__ValueStreamCardLink__c // remove the hardcode
            ){
                checkCard.isUpdateValueStreamCardLink = true;
            }*/
            cardsToCheck.add(checkCard);
        }
        //18/05/23 : Pratiksha : Previously we were checking constraint violation while cloning the card(ASAP/ALAP) but now we will clone card on same date, if card has ASAP/ALAP.
        if(new List<String>{'assoonaspossible','aslateaspossible'}.contains(tempConstraintType) && KanbanController.isCalledFromSingleCloneAPI){
            remoteKanban.StartDate = mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__StartDateTime__c;
            remoteKanban.DueDate = mapOfRemoteKanbanCards.get(remoteKanban.Id).leankor__DueDateTime__c;
            /*KanbanCard checkCard = new KanbanCard();
            checkCard.Id = remoteKanban.Id;
            checkCard.name = remoteKanban.Name;
            checkCard.valueStream = remoteKanban.ValueStream;
            checkCard.startDateTime = remoteKanban.StartDate;
            checkCard.dueDateTime = remoteKanban.DueDate;
            checkCard.valueStreamLink = null; //remoteObject.LinkVSID;
            checkCard.valueStreamCardLink = null;//remoteObject.LinkCardID;
            checkCard.isUpdateValueStreamCardLink = false;
            cardsToCheck.add(checkCard);*/
        }

        Leankor__KanbanCard__c kanbanCardRecord = mapOfRemoteKanbanCards.values();
        remoteKanban.kanbanCustomField = new leankor__KanbanCard__c();	// Initialization of inner class variable
        //if(kanbanCardRecord.leankor__valuestream__r.leankor__boardtype__c == 'UberBoard'){
            if(kanbanCardRecord.leankor__valuestream__r.leankor__boardtype__c == 'UberBoard' || kanbanCardRecord.leankor__valuestream__r.leankor__boardtype__c =='Kanban Board' ){
            if(kanbaCardIdandFields.containsKey(kanbanCardRecord.Id)){
                remoteKanban.kanbanCustomField = kanbaCardIdandFields.get(kanbanCardRecord.Id);
                remoteKanban.kanbanCustomField.Id = null;
            }
        }
        else{
            if(kanbaCardIdandFields.get(kanbanCardRecord.Id)!=null){
                //Map<String, Object> fieldsToValue = kanbaCardIdandFields.get(kanbanCardRecord.Id).getPopulatedFieldsAsMap();
                if(String.isNotBlank(kanbanCardRecord.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)){// Checking  fieldset on the category.
                    //19/04/2023 : If any fieldSet is already deleted then we were facing ("Attempt to de-reference a null object") so we are preventing by adding the condition.
                    if(fieldSetMap.get(String.valueOf(kanbanCardRecord.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c)) != null){
                        Map<String, Object> fieldsToValue = kanbaCardIdandFields.get(kanbanCardRecord.Id).getPopulatedFieldsAsMap();
                        for(String Fields:singleFieldSetRecord.fieldSetAndFields.get(String.valueOf(kanbanCardRecord.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c))){
                            if(fieldsToValue.containsKey(fields)){
                                remoteKanban.kanbanCustomField.put(fields, fieldsToValue.get(fields));
                            }

                        }
                    }
                }
            }
        }

        
        KanbanList.add(remoteKanban); 
        if(!cardsToCheck.isEmpty()){
            if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS) {
                violationResult = KanbanController.getConstraintViolation(cardsToCheck, false);
            }
            if(!violationResult.isEmpty()){
                System.debug('Constraint is Violated.....');
                if(KanbanController.isCalledFromSingleCloneAPI){
                    throw new Util.LeanException('Constraint is Violated');
                }
                return Json.serialize(violationResult);
            }
        }
        List<leankor__KanbanCard__c> newKanbanCards = leankor.RealTimeController.CreateKanbanCard(VSID, KanbanList, true);
        //Changes : Check Constraint setting is enable or not.
        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
            remoteKanban.ConstraintType = tempConstraintType;
        }
        //Preparing list for filter task feature : Kanban Board.
        List<leankor.realTimeController.taskUsers> taskUsersList = new List<leankor.realTimeController.taskUsers>();
        if(newKanbanCards.Size() > 0){
            remoteKanban.Id = newKanbanCards[0].Id;
            remoteKanban.ForceID = newKanbanCards[0].Id;
            remoteKanban.OwnerId = newKanbanCards[0].OwnerId;
            remoteKanban.TaskComments = 0;           
            if(clonelog.TaskVerb == true){
        		//RS 28/11/2019 Added Owner.IsActive to query
        		List<Task> kanbanTaskList = [SELECT ActivityDate,Description,Id,OwnerId,Owner.Name,Priority,Status,Subject,WhatId,Owner.IsActive 
                									FROM Task 
                									Where (WhatId In (Select id from leankor__KanbanCard__c where Id=:oldKanbanId And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false And leankor__IsRecordDeleted__c = false) 
                										  AND IsDeleted = false) 
                								    Order By CreatedDate ASC NUllS LAST Limit 999 All Rows]; //CreatedDate

               //Preparing Map for filter task feature : Kanban Board.
                Map<String, String> taskOwnerMap = New Map<String, String>();
                if(kanbanTaskList.Size() > 0){
                    List<Task> TaskList = new List<Task>();
                    for(Task t : kanbanTaskList){
                    	taskOwnerMap.put(t.OwnerId, t.Owner.Name);
                        Task Tsk = new Task();
                        Tsk.Priority    =   t.Priority;
                        //RS 28/11/2019 Instead of querying user record added owner.IsActive field in queries 
                        //Tsk.OwnerID = allUserMap.containsKey(t.OwnerId) ? UserInfo.getUserId() : t.OwnerId;
                        Tsk.OwnerID = t.Owner.IsActive ? t.OwnerId : UserInfo.getUserId() ;
                        Tsk.Subject     =   (t.Subject == null ? '' :t.Subject);
                        Tsk.Status      =   t.Status;
                        Tsk.ActivityDate=  (Date.valueOf(t.ActivityDate)+otherDifference);
                        
                        if (VS.leankor__SevenDayWorkWeek__c && Util.weekDays.size() > 1) {
                            DateTime taskDateTime = workWeek.getNextWorkingDay(DateTime.newInstance(Tsk.ActivityDate.year(), Tsk.ActivityDate.month(), Tsk.ActivityDate.day(), newKanbanCards[0].leankor__StartDateTime__c.hour(), newKanbanCards[0].leankor__StartDateTime__c.minute(), newKanbanCards[0].leankor__StartDateTime__c.second()));
                            Tsk.ActivityDate = taskDateTime.date();
                        }

                        if(!VS.leankor__SevenDayWorkWeek__c){
                            datetime TskDuedate = Datetime.newInstance(Tsk.ActivityDate.year(),Tsk.ActivityDate.month(), Tsk.ActivityDate.day(), 1, 1, 1);

	                        //Get Working days escaping non working days for Task
							Tsk.ActivityDate = Util.readNextWorkingDate(workWeek,TskDuedate,Tsk.ActivityDate);
                                                    	
							/**Note - Using TempFinalDate, tempcalstartdate variables for getting TskActivityDate also replacing values in 
	                        DueDate,StartDate for card. So New date variables are created using year,Month, Day**/
	                        Date tempTskFinalDate = Date.newInstance(TempFinalDate.year(), TempFinalDate.month(), TempFinalDate.day());
	                        Date tempTskstartdate = Date.newInstance(remoteKanban.StartDate.year(), remoteKanban.StartDate.month(), remoteKanban.StartDate.day());
	                        if(Tsk.ActivityDate > tempTskFinalDate && VS.leankor__TaskDatecheck__c){
                                Tsk.ActivityDate = tempTskFinalDate;
                            }else if (Tsk.ActivityDate < tempTskstartdate && VS.leankor__TaskDatecheck__c){
                                Tsk.ActivityDate = tempTskstartdate;
                            }
                        }
                        Tsk.WhatID      =   newKanbanCards[0].Id;
                        Tsk.Description =   (t.Description == null ? '' : t.Description);
                        TaskList.add(Tsk);
                    }
                    
                    try {
                        Database.insert(TaskList,false);
                       //Task filter code added for clone feature. preparing list to send back to Kanban Board. 
                        for(Task t:TaskList){
	                        leankor.realTimeController.taskUsers taskUser = new leankor.realTimeController.taskUsers(t.Id,t.OwnerId, taskOwnerMap.get(t.OwnerId));
	                        taskUsersList.add(taskUser);
                        }
                        remoteKanban.TaskUserNames = taskUsersList;
                    }catch(DMLException ex){
                        System.debug('Error : '+ex.getMessage());
                        //return 'Failed';
                        //25/04/2023 : We are Throwing Exception
			            throw new Util.LeanException('ERROR:' + ex.getMessage());
                    }
                    List<FeedItem> Feeds=new List<FeedItem>();
                    remoteKanban.TaskComments = TaskList.Size();
                    for(Task Tsk:TaskList){
                        FeedItem Post=new FeedItem();
                        Post.ParentID=Tsk.Id;
                        Post.Type='CreateRecordEvent';
                        Feeds.add(Post);
                    }
                    try{
                        insert Feeds;
                    } catch (DmlException e){
                        System.debug(e.getMessage());
                        //25/04/2023 : We are Throwing Exception
			            throw new Util.LeanException('ERROR:' + e.getMessage());
                    }
                }// End of If
            }// End of If
            remoteKanban.ItemType = String.isNotBlank(remoteKanban.ItemType) ? remoteKanban.ItemType : 'KC';
            remoteKanban.LinkedCardVerb = 'CardHierarchyToOther';
            //26.09.2017 : for Generic Streamin and Bulk call
            remoteKanban.successorsArray = JSON.serialize(leankor.RealTimeController.gskanbanCardIds);
            leankor.RealTimeController.gskanbanCardIds.clear();
            remoteKanban.schedulemodeList = null;
		    remoteKanban.resourceAssignmentList = null;
            clonelog.someJSONData = JSON.serialize(remoteKanban);
            leankor.RealTimeController.kanbanStateChange(VSID, 'CreateKanbanCard',mySessionID, clonelog.someJSONData);
        }// End of If
        return clonelog.someJSONData;
    }// End of Method.
    

    //Added new parameter WorkWeek for WorkingWeekday calculation
    // calculating number of days between two dates 
    public static Integer daysBetweenExcludingWeekends(Datetime StartDate, Datetime EndDate,Boolean IsSevenday, Util.WorkWeek workWeek) {
		//Date 02/07/19 
	    Integer count = (StartDate.dateGMT()).daysBetween(EndDate.dateGMT());
	    Integer finalcount = count;
	    
	    // if seven day workweek is true than not excluding weekends.
	    if(IsSevenday){ return finalcount;}
	    
	    // if seven day workweek is false than excluding weekends.
		if(StartDate <= EndDate){
			for(Integer i = 1 ; i<=count ; i++) {      
				StartDate = StartDate + 1;
                //checking saturday and sunday if condition is true than counting is getting '-1'       
				if(workWeek!=null && startDate!=null){
            if (!workWeek.isWorkingDay(startDate.format('EEEE'))) {
				   finalcount = finalcount - 1;
				}      
				}
            /*if (startDate.format('E') == 'Sat' || startDate.format('E') == 'Sun'){                
			finalcount = finalcount - 1;
			}*/      
			}			
		}else{   
			for(Integer i = -1 ; i>=count ; i--) {      
                StartDate = StartDate - 1;      
				if(workWeek!=null && startDate!=null){
            if (!workWeek.isWorkingDay(startDate.format('EEEE'))) {
				   finalcount = finalcount + 1;
				}      
				}
				      
            /*if (StartDate.format('E') == 'Sat' || StartDate.format('E') == 'Sun') {
			finalcount = finalcount + 1;
			}*/      
			}
		}	
		return finalcount;  
	}
	
	public static Datetime nextBusinessDate(Datetime currentBusinessDate,Boolean flag){
	  return null;
    }
    
    //Added new parameter WorkWeek for WorkingWeekday calculation
    // calculating next Date to add number of days excluding weekends.
    public static Datetime nextBusinessDate(Datetime currentBusinessDate,Integer dateDifference ,Boolean flag, Util.WorkWeek workWeek) {    
	    Datetime businessDate = currentBusinessDate;
	    if(flag) {
		     for(Integer i=1; i<= dateDifference ; i++){
			 	 
			 	 businessDate = businessDate + 1;
            //Calculate WorkingWeekDays according to first day of week
				businessDate = Util.readNextWorkingDateTime(workWeek,businessDate);
            /*if(businessDate.format('E') == 'Sat' )
		  {
			businessDate = businessDate+2;
	      }else if(businessDate.format('E') == 'Sun')
		  {
			businessDate = businessDate+1;
            }*/                             	
		  }                             	
		}else{		
		  
		   for(Integer i=-1; i >= dateDifference ; i--){
		   	  
		   	  businessDate = businessDate - 1;
            //Calculate WorkingWeekDays according to first day of week
				businessDate = Util.readPreviousWorkingDateTime(workWeek,businessDate);
            /*if(businessDate.format('E') == 'Sat' )
		  {
			businessDate = businessDate-1;
	      }else if(businessDate.format('E') == 'Sun')
		  {
			businessDate = businessDate-2;
            }*/
		  }
		
		}
	    return businessDate;
	}
    
		
    /*------------------------------------------------------------
    Author:         Narendra Wadkar
    Company:        Leankor
    Description:    Getting Content version records for respective object i.e. KanbanCard, ValueStream etc.
    Inputs:         object FileInputWrapper
    Returns:        List<FeedItem>
    ------------------------------------------------------------*/
    @RemoteAction
    global static List<ChatterFileContent> getAssociatedFiles(FileInputWrapper fiw){
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ContentVersionBehaviour contentVersionBehaviour = new ContentVersionBehaviour();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !contentVersionBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior 

        List<ChatterFileContent> fileConentList = new List<ChatterFileContent>();
        Set<String> contentVersionIdList = new Set<String>();
        Map<Id, ContentVersion> contentVersionMap;
        
        if(fiw.filePublishLocation == 'ValueStream'){
            // Tilak - 05/03/2020 - Changes for filtering soft deleted record and removing null condition in where clause.
            Map<Id,leankor__KanbanCard__c> allVSCards = 
                new Map<Id,leankor__KanbanCard__c> ([SELECT 
                                                        Id,
                                                        Name 
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE leankor__ValueStream__c IN: fiw.publishLocationIds
                                                        AND leankor__isRecordDeleted__c = false]);
            fiw.publishLocationIds.AddAll(allVSCards.keySet());
        }//End of if
        
        if(!fiw.publishLocationIds.isEmpty()){
            List<FeedItem> fileFeedItems =leankor.OpenTaskRestriction.getFileFeedItem(fiw.publishLocationIds);
            for(FeedItem item : fileFeedItems){
                                    
                //if(item.RelatedRecordId != NULL)
                //{   
                    //adding attachment and multiple attachment
                    if(item.FeedAttachments.size()>0)
                    {					
                        for(FeedAttachment fat : item.FeedAttachments)
                        {   
                            if(String.isNotBlank(fat.RecordId) && !contentVersionIdList.contains(fat.RecordId))
                            {
                                fileConentList.add(new ChatterFileContent(fat.Id,
                                                                        item.LastModifiedDate,
                                                                        item.LinkUrl,
                                                                        item.ParentId,
                                                                        fat.RecordId,
                                                                        item.Status,
                                                                        item.SystemModstamp,
                                                                        BLANKTEXT,
                                                                        item.Type,
                                                                        BLANKTEXT,
                                                                        BLANKTEXT,
                                                                        BLANKTEXT,
                                                                        BLANKTEXT));
                                contentVersionIdList.add(fat.RecordId);
                            }
                        }
                    }
                    
                    //adding attchment of inside in comment 
                    if(item.FeedComments.size()>0)
                    {					
                        for(FeedComment fct : item.FeedComments)
                        {   
                            if(String.isNotBlank(fct.RelatedRecordId) && !contentVersionIdList.contains(fct.RelatedRecordId))
                            {
                                fileConentList.add(new ChatterFileContent(fct.Id,
                                                                        fct.SystemModstamp,
                                                                        item.LinkUrl,
                                                                        fct.ParentId,
                                                                        fct.RelatedRecordId,
                                                                        item.Status,
                                                                        fct.SystemModstamp,
                                                                        BLANKTEXT,
                                                                        item.Type,
                                                                        BLANKTEXT,
                                                                        BLANKTEXT,
                                                                        BLANKTEXT,
                                                                        BLANKTEXT));
                                contentVersionIdList.add(fct.RelatedRecordId);
                            }
                        }
                    }
                //}
                
            }//End of loop
            contentVersionMap = new Map<Id, ContentVersion>([SELECT Id,
                                                                    Title,
                                                                    ContentDocumentId, 
                                                                    ContentDocument.LatestPublishedVersionId, 
                                                                    ExternalDocumentInfo1,ExternalDataSourceId, 
                                                                    ContentLocation 
                                                                FROM ContentVersion 
                                                                WHERE Id IN :contentVersionIdList]);
        }//End of if
        
        for(ChatterFileContent item : fileConentList){
            if(contentVersionMap.containsKey(item.RelatedRecordId)){
                ContentVersion cv = contentVersionMap.get(item.RelatedRecordId);
                item.Title = cv.Title;
                item.ContentDocumentId = cv.ContentDocumentId;
                item.ContentLocation = cv.ContentLocation;
                item.ExternalDocumentInfo1 = cv.ExternalDocumentInfo1;
                item.ExternalDataSourceId = cv.ExternalDataSourceId;
                //We are  using this value to open preview file in community
                item.latestPublishedVersionId = cv.ContentDocument.LatestPublishedVersionId; 
            }//End of if
        
        }//End of loop
        
        return fileConentList;
    }

     @AuraEnabled
    public static List<LwcChatterFileContent> getAssociatedFiles(FileInputData fileInputData) {
    
        ContentVersionBehaviour contentVersionBehaviour = new ContentVersionBehaviour();
        if (!contentVersionBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        } 
        try {
            FileInputWrapper fileInputWrapper = new FileInputWrapper();
            fileInputWrapper.filePublishLocation = fileInputData.filePublishLocation;
            fileInputWrapper.publishLocationIds = fileInputData.publishLocationIds;

            List<ChatterFileContent> chatterContentList = getAssociatedFiles(fileInputWrapper);

            List<LwcChatterFileContent> lwcContentList = new List<LwcChatterFileContent>();
            for (ChatterFileContent cfc : chatterContentList) {
            LwcChatterFileContent lwc = new LwcChatterFileContent();
            lwc.Id = cfc.Id;
            lwc.LastModifiedDate = cfc.LastModifiedDate;
            lwc.LinkUrl = cfc.LinkUrl;
            lwc.ParentId = cfc.ParentId;
            lwc.RelatedRecordId = cfc.RelatedRecordId;
            lwc.Status = cfc.Status;
            lwc.SystemModstamp = cfc.SystemModstamp;
            lwc.Title = cfc.Title;
            lwc.Type = cfc.Type;
            lwc.ExternalDocumentInfo1 = cfc.ExternalDocumentInfo1;
            lwc.ContentLocation = cfc.ContentLocation;
            lwc.ExternalDataSourceId = cfc.ExternalDataSourceId;
            lwc.ContentDocumentId = cfc.ContentDocumentId;
            lwc.externalDocumentInfo2 = cfc.externalDocumentInfo2;
            lwc.name = cfc.name;
            lwc.documentId = cfc.documentId;
            lwc.sourceType = cfc.sourceType;
            lwc.comments = cfc.comments;
            lwc.latestPublishedVersionId = cfc.latestPublishedVersionId;
            lwcContentList.add(lwc);
        }

        return lwcContentList;
        } catch (Exception ex) {
			throw new Util.LeanException('ERROR:' + ex.getMessage());
		}
        
    }

    


    
    /*------------------------------------------------------------
    Author:         Narendra Wadkar
    Company:        Leankor
    Description:    Wrapper class for input in method getAssociatedFiles.
    ------------------------------------------------------------*/
    global class FileInputWrapper{
	global String filePublishLocation;
	global List<Id> publishLocationIds;
    }
    
    /*------------------------------------------------------------
    Author:         Narendra Wadkar
    Company:        Leankor
    Description:    Delete original file from salesforce. 
    Inputs:         ContentVersionId
    Returns:        String (Success / Failed)
    ------------------------------------------------------------*/
    @RemoteAction
        @AuraEnabled

    global static String deleteAssociatedFile(String jsonString){
                System.debug(jsonString);
        //06/04/2022 : Changes for delete the file from only selected kanbancard.
        leankor.KanbanController.deleteFileWrapper deleteFileData = (leankor.KanbanController.deleteFileWrapper)JSON.deserialize(jsonString, leankor.KanbanController.deleteFileWrapper.class);
        return leankor.OpenFeedItemRestriction.deleteFiles(deleteFileData);
        }
        
    /*------------------------------------------------------------
    Author:         Narendra Wadkar
    Company:        Leankor
    Description:    Wrapper class that is used to return values in method getAssociatedFiles. 
				It contain combine wrapper version for FeedItem and ContentVersion.
    ------------------------------------------------------------*/
    
   global class ChatterFileContent {

    @AuraEnabled
    global Id Id;

    @AuraEnabled
    global DateTime LastModifiedDate;

    @AuraEnabled
    global String LinkUrl;

    @AuraEnabled
    global String ParentId;

    @AuraEnabled
    global String RelatedRecordId;

    @AuraEnabled
    global String Status;

    @AuraEnabled
    global DateTime SystemModstamp;

    @AuraEnabled
    global String Title;

    @AuraEnabled
    global String Type;

    @AuraEnabled
    global String ExternalDocumentInfo1;

    @AuraEnabled
    global String ContentLocation;

    @AuraEnabled
    global String ExternalDataSourceId;

    @AuraEnabled
    global String ContentDocumentId;

    // RS 06/09/2018 
    @AuraEnabled
    public String externalDocumentInfo2;	

    @AuraEnabled
    public String name;

    @AuraEnabled
    public String documentId;

    @AuraEnabled
    public String sourceType;

    @AuraEnabled
    public Integer comments;  	

    // Using this value to preview files in communities
    @AuraEnabled
    public String latestPublishedVersionId;

    // Default constructor 
    global ChatterFileContent() {}

    // Overloaded constructor 
    global ChatterFileContent(
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

			
    /*------------------------------------------------------------
    Author:         Yash
    Company:        Leankor
    Description:    getting package version 
    Inputs:         -----
    Returns:        String (version number)
    ------------------------------------------------------------*/
    @RemoteAction
    global static String getPackageVersion(){
            
            String packageVersion = '';                
		try{
			if(System.requestVersion().patch() != null){
                     packageVersion = System.requestVersion().major() +'.'+ System.requestVersion().minor()+'.'+System.requestVersion().patch();    
			}else{
                     packageVersion = System.requestVersion().major() +'.'+ System.requestVersion().minor();    
			}
			
		}catch(Exception ex){
			System.debug('Exception : '+ex.getMessage());
			//return '1.0';
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
		}
		
		return packageVersion;
    }
    
    /*------------------------------------------------------------
    Author:         Yash
    Company:        Leankor
    Description:    getting Zones of KanbanBoard 
    Inputs:         -----
    Returns:        List of Zones as String
    ------------------------------------------------------------*/  
    public String getKanbanBoardZones(){
        //Check CRUD / FLC behavior 
        ZoneBehavior zoneBehavior = new ZoneBehavior();
        if (!zoneBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
            List<leankor.RealTimeController.Zone> zoneList = new List<leankor.RealTimeController.Zone>();
            /*SS 24.07.2018*/
            //Added leankor__Swimlane__r.leankor__MasterContainer__c, for KB peformance                    
            for(leankor__Zone__c z : [ Select leankor__Bottom__c,leankor__CardsPerRow__c,
                                  leankor__CaseStatus__c,leankor__CmpID__c,
                                  leankor__CompletionRateUnits__c,leankor__CompletionRate__c,
                                  leankor__CSSLayout__c,leankor__DefaultHeight__c,
                                  leankor__DefaultWidth__c,leankor__EntryFlowName__c,
                                  leankor__ExitFlowName__c,leankor__GUID__c,
                                  leankor__Height__c,leankor__Help__c,leankor__JSONDefinition__c,                              
                                  leankor__kanbanSequence__c,leankor__LeadTime__c,
                                  leankor__Left__c,leankor__Limit__c,leankor__OpportunityStageName__c,
                                  leankor__Order__c,leankor__ParentZone__c,leankor__Swimlane__c,
                                  leankor__Swimlane__r.leankor__MasterContainer__c,
                                  leankor__Top__c,leankor__Unit__c,
                                  leankor__UrlLink__c,leankor__ValueStreamCardLink__c,
                                  leankor__ValueStreamLink__c,leankor__ValueStream__c,
                                  leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__zoneMode__c,
                                  Name, leankor__ValueStreamLink__r.leankor__BoardType__c from leankor__Zone__c Where leankor__ValueStream__c =: this.valueStreamId limit 49999]){
                
                leankor.RealTimeController.Zone zObject = new leankor.RealTimeController.Zone();
                
                zObject.ForceID = z.Id;
                zObject.Height = z.leankor__Height__c;
                zObject.Width = z.leankor__Width__c;
                zObject.Top = z.leankor__Top__c;
                zObject.Unit = z.leankor__Unit__c;
                zObject.Left = z.leankor__Left__c;
                zObject.UrlLink = z.leankor__UrlLink__c;
                zObject.X = z.leankor__X__c;
                zObject.Y = z.leankor__Y__c;
                zObject.CardsPerRow = z.leankor__CardsPerRow__c;
                zObject.Title = z.Name;
                zObject.GUID = z.leankor__GUID__c;
                zObject.Bottom = z.leankor__Bottom__c;
                zObject.CmpID = z.leankor__CmpID__c;
                zObject.CSSLayout = z.leankor__CSSLayout__c;
                zObject.JSONDefinition = z.leankor__JSONDefinition__c;
                zObject.ValueStream = z.leankor__ValueStream__c;
                zObject.ValueStreamLinkID = z.leankor__ValueStreamLink__c;
                zObject.ValueStreamCardLink = z.leankor__ValueStreamCardLink__c;
                zObject.ValueStreamLinkBoardType = z.leankor__ValueStreamLink__r.leankor__BoardType__c;
                zObject.EntryFlowName = z.leankor__EntryFlowName__c;
                zObject.ExitFlowName = z.leankor__ExitFlowName__c;
                zObject.LeadTime = z.leankor__LeadTime__c;
                zObject.CompletionRate = z.leankor__CompletionRate__c;
                zObject.CompletionRateUnits = z.leankor__CompletionRateUnits__c;
                zObject.ZoneMode = z.leankor__zoneMode__c;
                zObject.KanbanSequence = z.leankor__kanbanSequence__c;
                zObject.DefaultHeight = z.leankor__DefaultHeight__c;            
                zObject.DefaultWidth = z.leankor__DefaultWidth__c;
                zObject.ZoneStatus = z.leankor__CaseStatus__c;
                zObject.TaskLimit = z.leankor__Limit__c;
                zObject.Order = z.leankor__Order__c;
                zObject.Swimlane = z.leankor__Swimlane__c;
                zObject.ParentZone = z.leankor__ParentZone__c;
                zObject.ZoneOpportunityStage = z.leankor__OpportunityStageName__c;
                zObject.Help = z.leankor__Help__c;
                //Added only for KB load
                zObject.ZoneTemplate = z.leankor__Swimlane__r.leankor__MasterContainer__c;
                
                
                zoneList.add(zObject);                                
            }       
            
           return JSON.serialize(zoneList);
    }
    
    
    /*------------------------------------------------------------
    Author:         Yash
    Company:        Leankor
    Description:    getting Markers of KanbanBoard 
    Inputs:         -----
    Returns:        List of Marker as String
    ------------------------------------------------------------*/  
     public String getKanbanBoardMarkers(){
         //Check CRUD / FLC behavior 
         MarkerBehaviour markerBehaviour = new MarkerBehaviour();
         AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
         if (
             !markerBehaviour.isAccessible() ||
             !attachmentBehaviour.isAccessible()
         ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
         }
         //Check CRUD / FLC behavior 
        
            List<leankor.RealTimeController.Marker> markerList = new List<leankor.RealTimeController.Marker>();
   			Map<Id, leankor.RealTimeController.Marker> markerMap = new Map<Id, leankor.RealTimeController.Marker>();
                                
            for(leankor__Marker__c m : [SELECT leankor__Bottom__c,leankor__CmpID__c,leankor__CSSLayout__c,
                                    leankor__GUID2__c,leankor__Height__c,
                                    leankor__JSONData__c,leankor__JSONDefinition__c,
                                    leankor__Left__c,leankor__LockState__c,
                                    leankor__Sticker__c,leankor__TextLabel__c,
                                    leankor__Top__c,leankor__Type__c,leankor__UrlLink__c,
                                    leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,
                                    leankor__ValueStreamLink__r.leankor__BoardType__c,
                                    leankor__ValueStreamLink__r.Name,
                                    leankor__ValueStreamCardLink__r.Name,
                                    leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
									leankor__ValueStreamLink__r.leankor__ProjectRoom__r.Name,
                                    leankor__ValueStream__c,leankor__Width__c,leankor__X__c,
                                    leankor__Y__c,leankor__ZIndex__c,Name FROM leankor__Marker__c 
                                    Where leankor__ValueStream__c =: this.valueStreamId limit 49999]){
                
                leankor.RealTimeController.Marker mObject = new leankor.RealTimeController.Marker();
                
                mObject.ForceID = m.Id;
                mObject.Height = Integer.valueof(m.leankor__Height__c);
                mObject.Width = Integer.valueof(m.leankor__Width__c);
                mObject.Top = Integer.valueof(m.leankor__Top__c);
                mObject.Left = Integer.valueof(m.leankor__Left__c);
                mObject.Type = m.leankor__Type__c;
                mObject.X = Integer.valueof(m.leankor__X__c);
                mObject.Y = Integer.valueof(m.leankor__Y__c);
                mObject.ZIndex = Integer.valueof(m.leankor__ZIndex__c);
                mObject.TextLabel = m.leankor__TextLabel__c;
                mObject.Name = m.Name;
                mObject.GUID = m.leankor__GUID2__c;
                mObject.Bottom = Integer.valueof(m.leankor__Bottom__c);
                mObject.CmpID = m.leankor__CmpID__c;
                mObject.CSSLayout = m.leankor__CSSLayout__c;
                mObject.JSONDefinition = m.leankor__JSONDefinition__c;
                mObject.JSONData = m.leankor__JSONData__c;
                mObject.ValueStreamID = m.leankor__ValueStream__c;
                mObject.VSLink = m.leankor__ValueStreamLink__c;
                mObject.ValueStreamCardLink = m.leankor__ValueStreamCardLink__c;
                mObject.ValueStreamLinkBoardType = m.leankor__ValueStreamLink__r.leankor__BoardType__c;
                mObject.StickerID = m.leankor__Sticker__c;
                mObject.UrlLink = m.leankor__UrlLink__c;
                mObject.LockState = m.leankor__LockState__c;
                
                mObject.LinkProjectRoomName = m.leankor__ValueStreamLink__r.leankor__ProjectRoom__r.Name == null ? '' : m.leankor__ValueStreamLink__r.leankor__ProjectRoom__r.Name;
                mObject.LinkProjectRoomId = m.leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? '' : m.leankor__ValueStreamLink__r.leankor__ProjectRoom__c;
                mObject.LinkValueStreamName = m.leankor__ValueStreamLink__r.Name == null ? '' : m.leankor__ValueStreamLink__r.Name;
                mObject.LinkCardName = m.leankor__ValueStreamCardLink__r.Name == null ? '' : m.leankor__ValueStreamCardLink__r.Name;

                               
                if(m.leankor__Sticker__c == null && m.leankor__Type__c !='Label')
                    markerMap.put(m.Id,mObject);
                 else   
                    markerList.add(mObject); 
            }       
            
           for(Attachment a : [Select Id,ContentType,ParentId from Attachment where ParentId IN : markerMap.keySet()]){
     
             if(markerMap.containsKey(a.parentId)){
                 leankor.RealTimeController.Marker tempMarker = markerMap.get(a.parentId);
                     tempMarker.AttachmentID = a.Id;
                     tempMarker.ContentType = a.ContentType;
                 markerList.add(tempMarker);
             }
     
          }
     
     return JSON.serialize(markerList);
    }
        
    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    getting kanban cards of KanbanBoard 
    Inputs:         -----
    Returns:        List of kanban cards as String
    ------------------------------------------------------------*/  
    public List<leankor.RealTimeController.Kanban> getKanbanBoardKanbanCards(String valueStreamId){
    
      List<leankor.RealTimeController.Kanban> kanbanCardList = new List<leankor.RealTimeController.Kanban>();
      
      //getting record through this "getBoardKanbanCards" due custom field
      //leankor.RealTimeController instance = new leankor.RealTimeController(this.TheValueStream);     
      /*SS 12.08.2018*/
	  //If Fsl is enabled then get FSL data count for cards(activity)			
      // RK : 08/03/2021 - Changes : FSL issue fixes for Kanban Board not loading. 		
	  Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>{valueStreamId},'Valuestream');

      List<leankor__KanbanCard__c> kanbanCards = [ Select id,
                                                        leankor__ProjectRoom__c,
                                                        leankor__State__c,
                                                        leankor__Height__c,
                                                        leankor__UrlLink__c,
                                                        leankor__Width__c,
                                                        leankor__Top__c,
                                                        leankor__Left__c,
                                                        leankor__X__c,
                                                        leankor__Y__c,
                                                        leankor__Point__c,
                                                        leankor__KanbanCardTemplate__r.Name,
                                                        leankor__GUID__c,
                                                        leankor__Bottom__c,
                                                        leankor__CmpID__c,
                                                        leankor__CSSLayout__c,
                                                        leankor__JSONDefinition__c,
                                                        leankor__JSONData__c,
                                                        leankor__ZoneGUID__c,
                                                        leankor__Zone__c,
                                                        leankor__Swimlane__c,
                                                        leankor__MasterContainer__c,
                                                        leankor__ValueStream__c,
                                                        leankor__kanbanCardTemplate__c,
                                                        leankor__DescriptionLong__c,
                                                        OwnerId,
                                                        Owner.Name,
                                                        Name,
                                                        leankor__kanbanCardTemplate__r.leankor__Color__c,
                                                        leankor__Opportunity__r.StageName,
                                                        leankor__Opportunity__c,
                                                        leankor__ValueStreamLink__c,
                                                        leankor__ValueStreamCardLink__c,
                                                        leankor__ValueStreamLink__r.leankor__BoardType__c,
                                                        leankor__ValueStreamCardLink__r.Name,
                                                        leankor__ValueStreamLink__r.leankor__ProjectRoom__c,
                                                        leankor__ValueStreamLink__r.Name,
                                                        leankor__Priority__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__DurationUnits__c,
                                                        leankor__DateColor__c,
                                                        leankor__PercentComplete2__c,
                                                        leankor__Contact__c,
                                                        leankor__Contact__r.Name,
                                                        leankor__Account__c,
                                                        leankor__Account__r.Name,
                                                        leankor__Case__c,
                                                        leankor__Case__r.Subject,
                                                        leankor__Order__c,
                                                        leankor__Opportunity__r.Name,
                                                        leankor__OnBudget__c,
                                                        leankor__OnQuality__c,
                                                        leankor__OnTime__c,
                                                        leankor__IsAtRisk__c,
                                                        leankor__IsOnHold__c,
                                                        leankor__EffortRemaining__c,
                                                        CreatedDate,
                                                        LastModifiedDate,
                                                        leankor__StartDateTime__c,
                                                        leankor__AcceptanceCriteria__c,
                                                        leankor__CardID__c,
                                                        leankor__IsSuccessorRecalculate__c,
                                                        leankor__Case__r.CaseNumber,
                                                        leankor__Case__r.Status,
                                                        (Select Id,
                                                                leankor__ConstraintDateTime__c,
                                                                leankor__ScheduleConstraint__r.leankor__Type__c,
                                                                leankor__Mode__c,
                                                                leankor__ManuallyScheduled__c
                                                            From leankor__ScheduleModes__r 
                                                            Limit 1),
                                                        leankor__Case__r.Priority,
                                                        leankor__Monday__c,
                                                        leankor__Tuesday__c,
                                                        leankor__Wednesday__c,
                                                        leankor__Thursday__c,
                                                        leankor__Friday__c,
                                                        leankor__Saturday__c,
                                                        leankor__Sunday__c,
                                                        leankor__WeekCalendar__c
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c =: valueStreamId
                                                        And leankor__KanbanCard__c.leankor__isRecordDeleted__c = false
                                                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                        And RecordType.Name =: 'ActivityCard'
                                                    Limit 49999 ];
                                                    
        
        //24/Feb/2023 : Changes added for showing parent Card Constraint data in CV.
        Map<String, leankor__ScheduleMode__c> cardLinkScheduleMode;
        if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
            cardLinkScheduleMode = leankor.RealTimeControllerHelper.getParentCardConstraintData(kanbanCards);
        }
        // Changes - RK : 23/11/2020 : Changes for decrease heap size of this method.
        for(Integer kbPointer = 0; kbPointer < kanbanCards.size();){
	  //SS 08.10.2019
      //Exclude records with null Vs / Project	
            if(String.isNotBlank(kanbanCards[kbPointer].leankor__ProjectRoom__c)){
                leankor.RealTimeController.Kanban kbObject = new leankor.RealTimeController.Kanban();
      
                kbObject.ForceID = kanbanCards[kbPointer].Id;
                kbObject.State = kanbanCards[kbPointer].leankor__State__c;
                kbObject.Height = kanbanCards[kbPointer].leankor__Height__c;
                kbObject.UrlLink = kanbanCards[kbPointer].leankor__UrlLink__c;
                kbObject.Width = kanbanCards[kbPointer].leankor__Width__c;
                kbObject.Top = kanbanCards[kbPointer].leankor__Top__c;
                kbObject.Left = kanbanCards[kbPointer].leankor__Left__c;
                kbObject.X = kanbanCards[kbPointer].leankor__X__c;
                kbObject.Y = kanbanCards[kbPointer].leankor__Y__c;
                kbObject.Point = kanbanCards[kbPointer].leankor__Point__c;
                kbObject.Title = kanbanCards[kbPointer].leankor__KanbanCardTemplate__r.Name;
                kbObject.GUID = kanbanCards[kbPointer].leankor__GUID__c;    
                kbObject.Bottom = kanbanCards[kbPointer].leankor__Bottom__c;
                kbObject.CmpID = kanbanCards[kbPointer].leankor__CmpID__c;
                kbObject.CSSLayout = kanbanCards[kbPointer].leankor__CSSLayout__c;
                kbObject.JSONDefinition = kanbanCards[kbPointer].leankor__JSONDefinition__c;
                kbObject.JSONData = kanbanCards[kbPointer].leankor__JSONData__c;
                kbObject.ZoneID = kanbanCards[kbPointer].leankor__ZoneGUID__c;
                kbObject.ZoneForceID = kanbanCards[kbPointer].leankor__Zone__c;
                kbObject.MCForceID = kanbanCards[kbPointer].leankor__Swimlane__c;
                kbObject.SWForceID = kanbanCards[kbPointer].leankor__MasterContainer__c;
                kbObject.ValueStream = kanbanCards[kbPointer].leankor__ValueStream__c;
                kbObject.TemplateID = kanbanCards[kbPointer].leankor__kanbanCardTemplate__c;
                kbObject.Description = kanbanCards[kbPointer].leankor__DescriptionLong__c;
                kbObject.OwnerID = kanbanCards[kbPointer].OwnerId;
                kbObject.OwnerName = kanbanCards[kbPointer].Owner.Name; 
                kbObject.Name = kanbanCards[kbPointer].Name;
                kbObject.Color = kanbanCards[kbPointer].leankor__kanbanCardTemplate__r.leankor__Color__c;
                kbObject.OpportunityStage  = kanbanCards[kbPointer].leankor__Opportunity__r.StageName;
                kbObject.ValueStreamLinkID = kanbanCards[kbPointer].leankor__ValueStreamLink__c;
                kbObject.ValueStreamCardLink = kanbanCards[kbPointer].leankor__ValueStreamCardLink__c;
                kbObject.ValueStreamLinkBoardType = kanbanCards[kbPointer].leankor__ValueStreamLink__r.leankor__BoardType__c;
                kbObject.ValueStreamCardLinkName = kanbanCards[kbPointer].leankor__ValueStreamCardLink__r.Name ;
                kbObject.ValueStreamLinkIDName = kanbanCards[kbPointer].leankor__ValueStreamLink__r.Name;
                kbObject.Priority = Integer.valueof(kanbanCards[kbPointer].leankor__Priority__c);
                kbObject.DueDate = kanbanCards[kbPointer].leankor__DueDateTime__c; 
                kbObject.EstimatedDuration = kanbanCards[kbPointer].leankor__EstimatedDuration__c;
                kbObject.DurationUnits = kanbanCards[kbPointer].leankor__DurationUnits__c;
                kbObject.DateColor = kanbanCards[kbPointer].leankor__DateColor__c;
                kbObject.HarveyBall = string.valueof(kanbanCards[kbPointer].leankor__PercentComplete2__c);
                kbObject.Contact = kanbanCards[kbPointer].leankor__Contact__c;
                kbObject.ContactName = kanbanCards[kbPointer].leankor__Contact__r.Name;
                kbObject.Account = kanbanCards[kbPointer].leankor__Account__c;
                kbObject.AccountName = kanbanCards[kbPointer].leankor__Account__r.Name;
                kbObject.CaseID = kanbanCards[kbPointer].leankor__Case__c;
                kbObject.CaseSubject = kanbanCards[kbPointer].leankor__Case__r.Subject;
                //SS 27.08.2018
	            //CaseNumber may contain characters so use string instead of decimal type
	            //kbObject.CaseNumber  =(kb.leankor__Case__r != null && kb.leankor__Case__r.CaseNumber != null) ? Decimal.valueOf(kb.leankor__Case__r.CaseNumber) : null ; // Decimal.valueOf(kb.leankor__Case__r.CaseNumber);            
                kbObject.caseNumber2  = (kanbanCards[kbPointer].leankor__Case__r != null && kanbanCards[kbPointer].leankor__Case__r.CaseNumber != null) ? kanbanCards[kbPointer].leankor__Case__r.CaseNumber : null ; 
                kbObject.CaseStatus = kanbanCards[kbPointer].leankor__Case__r.Status;
                kbObject.CasePriority = kanbanCards[kbPointer].leankor__Case__r.Priority; 
                kbObject.Opportunity = kanbanCards[kbPointer].leankor__Opportunity__c;
                kbObject.Order = kanbanCards[kbPointer].leankor__Order__c;
                kbObject.OpportunityName = kanbanCards[kbPointer].leankor__Opportunity__r.Name;
                kbObject.OnBudget = kanbanCards[kbPointer].leankor__OnBudget__c;
                kbObject.OnQuality = kanbanCards[kbPointer].leankor__OnQuality__c;
                kbObject.OnTime = kanbanCards[kbPointer].leankor__OnTime__c;
	            // Date: 27/05/2019
                kbObject.isAtRisk = kanbanCards[kbPointer].leankor__IsAtRisk__c;
                kbObject.isOnHold = kanbanCards[kbPointer].leankor__IsOnHold__c;
                kbObject.EffortRemaining = kanbanCards[kbPointer].leankor__EffortRemaining__c;
                kbObject.CreateDate =string.valueof(kanbanCards[kbPointer].CreatedDate);
                kbObject.LastModifiedDate = string.valueof(kanbanCards[kbPointer].LastModifiedDate);
                kbObject.StartDate = kanbanCards[kbPointer].leankor__StartDateTime__c;       
                kbObject.AcceptanceCriteria = kanbanCards[kbPointer].leankor__AcceptanceCriteria__c;
                kbObject.CardID = kanbanCards[kbPointer].leankor__CardID__c;     
                kbObject.IsSuccessorRecalculate = kanbanCards[kbPointer].leankor__IsSuccessorRecalculate__c; 
                //24/Feb/2023 : Changes added for showing parent Card Constraint data in KB.
                if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                    kbObject.ConstraintType = String.isNotBlank(kanbanCards[kbPointer].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c) ? kanbanCards[kbPointer].leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__r.leankor__Type__c : null;
                    kbObject.ConstraintDate = kanbanCards[kbPointer].leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c != null ? kanbanCards[kbPointer].leankor__ScheduleModes__r[0].leankor__ConstraintDateTime__c : null;
                    if(String.isNotBlank(kanbanCards[kbPointer].leankor__ValueStreamCardLink__c) &&(kanbanCards[kbPointer].leankor__ValueStreamLink__r.leankor__BoardType__c =='UberBoard' || kanbanCards[kbPointer].leankor__ValueStreamLink__r.leankor__BoardType__c =='Plan Board')){
                        leankor__ScheduleMode__c scheduleModeRecord = cardLinkScheduleMode.get(kanbanCards[kbPointer].leankor__ValueStreamCardLink__c);
                        kbObject.parentCardConstraintType = String.isNotBlank(scheduleModeRecord.leankor__ScheduleConstraint__r.leankor__Type__c) ? scheduleModeRecord.leankor__ScheduleConstraint__r.leankor__Type__c : null;
                        kbObject.parentCardConstraintDate = scheduleModeRecord.leankor__ConstraintDateTime__c!= null  ? scheduleModeRecord.leankor__ConstraintDateTime__c : null;
                    }   
                }
                kbObject.SchedulingMode = kanbanCards[kbPointer].leankor__ScheduleModes__r[0].leankor__Mode__c != null ? kanbanCards[kbPointer].leankor__ScheduleModes__r[0].leankor__Mode__c : null;
                kbObject.ManuallyScheduled = kanbanCards[kbPointer].leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                //SS 12.08.2018
	            //Add fsl Data info with KanbanCard instance
                kbObject.LinkProjectRoomID = kanbanCards[kbPointer].leankor__ValueStreamLink__r.leankor__ProjectRoom__c == null ? '' : kanbanCards[kbPointer].leankor__ValueStreamLink__r.leankor__ProjectRoom__c;
                kbObject.workOrderCount = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? fslDataInfo.get(kanbanCards[kbPointer].Id).workOrderCount : 0;
                kbObject.serviceAppointmentCount = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? ( fslDataInfo.get(kanbanCards[kbPointer].Id).serviceAppointmentCount!=null ? fslDataInfo.get(kanbanCards[kbPointer].Id).serviceAppointmentCount  : null ) : 0;
                kbObject.fslSchedStartDateTime = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? ( fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedStartDateTime!=null ? fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedStartDateTime : null ): null;
                kbObject.fslSchedDueDateTime = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? ( fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedDueDateTime!=null ? fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedDueDateTime: null) : null;
	            
                //Pratiksha : 18/Jan/2024 : Passing these true value for all the days field those have null/false value in days for existing KBC records
                if(kanbanCards[kbPointer].leankor__Monday__c == false && kanbanCards[kbPointer].leankor__Tuesday__c == false && kanbanCards[kbPointer].leankor__Wednesday__c == false &&  kanbanCards[kbPointer].leankor__Thursday__c == false &&  kanbanCards[kbPointer].leankor__Friday__c == false &&  kanbanCards[kbPointer].leankor__Saturday__c == false &&  kanbanCards[kbPointer].leankor__Sunday__c == false){
                    kbObject.Monday = true;
                    kbObject.Tuesday = true;
                    kbObject.Wednesday = true;
                    kbObject.Thursday = true;
                    kbObject.Friday = true;
                    kbObject.Saturday = true;
                    kbObject.Sunday = true;
                }else{
                    //Pratiksha : 11/Oct/2023 : Passing these week day onLoad on KB.
                    kbObject.Monday = kanbanCards[kbPointer].leankor__Monday__c;
                    kbObject.Tuesday = kanbanCards[kbPointer].leankor__Tuesday__c;
                    kbObject.Wednesday = kanbanCards[kbPointer].leankor__Wednesday__c;
                    kbObject.Thursday = kanbanCards[kbPointer].leankor__Thursday__c;
                    kbObject.Friday = kanbanCards[kbPointer].leankor__Friday__c;
                    kbObject.Saturday = kanbanCards[kbPointer].leankor__Saturday__c;
                    kbObject.Sunday = kanbanCards[kbPointer].leankor__Sunday__c;
                    kbObject.weekCalendar = kanbanCards[kbPointer].leankor__WeekCalendar__c;
                }

                
	            kanbanCardList.add(kbObject);
                kanbanCards.remove(kbPointer);
            }else {
                kbPointer++;
            }
      }
      
        kanbanCards.clear();
        //return JSON.serialize(kanbanCardList);
        return kanbanCardList;
    }   
    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    getting MasterContainers of KanbanBoard 
    Inputs:         -----
    Returns:        List of MasterContainers as String
    ------------------------------------------------------------*/  
    
    public String getKanbanBoardMasterContainers(){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        if (!masterContainerBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor.KanbanController.MasterContainer> masterContainerList = new List<leankor.KanbanController.MasterContainer>();
        
        for(leankor__MasterContainer__c mc : [SELECT Id,leankor__Unit__c ,Name,leankor__Height__c,leankor__Width__c,
                                        leankor__Top__c,leankor__Left__c,leankor__Title__c,leankor__GUID__c,leankor__CmpID__c,
                                        leankor__ValueStream__c,leankor__Limit__c,leankor__Order__c,leankor__Color__c,
                                        leankor__IsCardAvailable__c,leankor__Type__c 
                                    FROM leankor__MasterContainer__c 
                                    WHERE leankor__ValueStream__c =: this.valueStreamId 
                                    LIMIT 49999 ]){
    
        leankor.KanbanController.MasterContainer mcObject = new leankor.KanbanController.MasterContainer();
     
            mcObject.ForceID=mc.Id;
            mcObject.Unit=mc.leankor__Unit__c;
            mcObject.Name = mc.Name ;
            mcObject.Height=mc.leankor__Height__c;
            mcObject.Width=mc.leankor__Width__c;
            mcObject.Top=mc.leankor__Top__c;
            mcObject.Left=mc.leankor__Left__c;
            mcObject.Title= mc.leankor__Title__c ;
            mcObject.GUID= mc.leankor__GUID__c ;
            mcObject.CmpID= mc.leankor__CmpID__c ;
            mcObject.ValueStreamID=mc.leankor__ValueStream__c;
            mcObject.Limits =mc.leankor__Limit__c;
            mcObject.Order =mc.leankor__Order__c;
            mcObject.Color =mc.leankor__Color__c;
            mcObject.isCardAvailable =mc.leankor__IsCardAvailable__c;
            mcObject.Type =mc.leankor__Type__c;

            masterContainerList.add(mcObject);  
        }   
        
        return JSON.serialize(masterContainerList);
    }       

    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    getting Swimlane of KanbanBoard 
    Inputs:         -----
    Returns:        List of Swimlane as String
    ------------------------------------------------------------*/  
    
    public String getKanbanBoardSwimlanes(){
        //Check CRUD / FLC behavior 
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        if (!swimlaneBehavior.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        List<leankor.KanbanController.Swimlane> swimlaneList = new List<leankor.KanbanController.Swimlane>();
            
        for(leankor__Swimlane__c sl : [SELECT Id,leankor__Unit__c,Name,leankor__Height__c,leankor__Width__c,
                                            leankor__Top__c,leankor__Left__c,leankor__Title__c,leankor__Help__c,leankor__GUID__c,leankor__CmpID__c,
                                            leankor__ValueStream__c,leankor__Limit__c,leankor__Order__c,leankor__Color__c,
                                            leankor__IsCardAvailable__c,leankor__CardPerRow__c,
                                            leankor__MasterContainer__c 
                                        FROM leankor__Swimlane__c 
                                        WHERE leankor__ValueStream__c =: this.valueStreamId 
                                        LIMIT 49999]){
        
        leankor.KanbanController.Swimlane slObject = new leankor.KanbanController.Swimlane();
        
            slObject.ForceID=sl.Id;
            slObject.Name= sl.Name ;
            slObject.CardPerRow =sl.leankor__CardPerRow__c;
            slObject.CmpID= sl.leankor__CmpID__c ;
            slObject.Color=sl.leankor__Color__c;
            slObject.GUID= sl.leankor__GUID__c ;
            slObject.Height=sl.leankor__Height__c;
            slObject.Help=sl.leankor__Help__c;
            slObject.isCardAvailable=sl.leankor__IsCardAvailable__c;
            slObject.Left=sl.leankor__Left__c;
            slObject.Limits=sl.leankor__Limit__c;
            slObject.MasterContainer =sl.leankor__MasterContainer__c;
            slObject.Order=sl.leankor__Order__c;
            slObject.Title= sl.leankor__Title__c ;
            slObject.Top=sl.leankor__Top__c;
            slObject.ValueStreamID=sl.leankor__ValueStream__c;
            slObject.Unit=sl.leankor__Unit__c;
            slObject.Width=sl.leankor__Width__c; 
        
            swimlaneList.add(slObject); 
        }   
            
        return JSON.serialize(swimlaneList);
    }

    /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    getting chart of KanbanBoard 
    Inputs:         -----
    Returns:        List of chart as String
    ------------------------------------------------------------*/  
    
    public String getKanbanBoardCharts(){
        //Check CRUD / FLC behavior
        ChartBehaviour chartBehaviour = new ChartBehaviour();
        if (!chartBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
    List<leankor.RealTimeController.Chart> chartList = new List<leankor.RealTimeController.Chart>();
        
    for(leankor__Chart__c chart : [select Id,Name,leankor__Height__c,leankor__Width__c,
                                        leankor__Top__c,leankor__Left__c,leankor__GUID__c,leankor__CmpID__c,
                                        leankor__ValueStream__c,leankor__X__c,leankor__Y__c,leankor__LockState__c,
                                        leankor__ReportId__c,leankor__DeveloperName__c,leankor__Filter__c,leankor__Format__c,
                                        leankor__Size__c,leankor__ChartURL__c,leankor__JSONData__c,
                                        leankor__OnlyShowChart__c from leankor__Chart__c where leankor__ValueStream__c =: this.valueStreamId limit 49999 ]){
    
     leankor.RealTimeController.Chart cObject = new leankor.RealTimeController.Chart();
     
            cObject.ForceID=chart.Id;
            cObject.Name=chart.Name;
            cObject.Id=chart.leankor__GUID__c;
            cObject.Height=integer.valueOf(chart.leankor__Height__c);
            cObject.Width=integer.valueOf(chart.leankor__Width__c);
            cObject.Top=integer.valueOf(chart.leankor__Top__c);
            cObject.Left=integer.valueOf(chart.leankor__Left__c);
            cObject.X=integer.valueOf(chart.leankor__X__c);
            cObject.Y=integer.valueOf(chart.leankor__Y__c);
            cObject.GUID=chart.leankor__GUID__c;
            cObject.ValueStreamID=chart.leankor__ValueStream__c;
            cObject.CmpID=chart.leankor__CmpID__c;
            cObject.LockState =chart.leankor__LockState__c; 
            cObject.ReportId =chart.leankor__ReportId__c;
            cObject.DeveloperName =chart.leankor__DeveloperName__c;
            cObject.Filter =chart.leankor__Filter__c;
            cObject.Format =chart.leankor__Format__c;
            cObject.Size =chart.leankor__Size__c;          
            cObject.ChartURL =chart.leankor__ChartURL__c;
            cObject.JSONData =chart.leankor__JSONData__c;
            cObject.OnlyShowChart =chart.leankor__OnlyShowChart__c; 
    
            chartList.add(cObject); 
    }   
        return JSON.serialize(chartList);
    }
    
    /*------------------------------------------------------------
	    Author:         Yash Jain
	    Company:        Leankor
	    Description:    Getting ServiceAppointmentRecords of kanbancards
	    Inputs:         List of KanbanCard Ids
	    Returns:        List<FieldServiceLigtning>
	    ------------------------------------------------------------*/
	    
	    @Readonly
	    @RemoteAction
	    global static List<FieldServiceLigtning> getServiceAppointmentRecords(List<String> kanbanCardIds){
	    		    		 		
	    	List<FieldServiceLigtning> result = new List<FieldServiceLigtning>();	    		    	
	    	try{	    			    				    			    	
		    	if(kanbanCardIds.size() > 0  && kanbanCardIds != null){		    		
	    	      String soql1 = 'Select KanbanCard__c,(Select AppointmentNumber,ParentRecordId,SchedStartTime, SchedEndTime From ServiceAppointments), Id,WorkOrderNumber From WorkOrder ';	    		
				  /*String cardIDs = '';	  
				  for(String t : kanbanCardIds){
					  cardIDs =  cardIDs + '\''+ t + '\',';
				  }*/
				  // rbo 02.26.18 KanbanCard__c field is an FSL custom field and not part of the managed package  
				  //soql1 += ' where KanbanCard__c IN (' + cardIDs.substring(0,cardIDs.length() - 1) + ')' + ' ORDER BY CreatedDate DESC limit 49999';
				  //soql1 += ' where KanbanCard__c IN (' + cardIDs.substring(0,cardIDs.length() - 1) + ')' + ' ORDER BY CreatedDate DESC limit 49999';
				
				//ss 25.04.2018 Use method listIdsToString for converting list of ids to String
				soql1 += ' where KanbanCard__c IN (' + listIdsToString(kanbanCardIds) + ')' + ' ORDER BY CreatedDate DESC limit 49999';
				// rbo 02.26.18
								
		    	List<sObject> workOrderList = Database.query(soql1);
		    	List<String> serviceAppointmentIds = new List<String>();
		    	
		    	for(sObject wo : workOrderList)
		    	{		    		
		    		for(sObject sa : wo.getSobjects('ServiceAppointments')){
			    		FieldServiceLigtning fsl = new FieldServiceLigtning();
			    		fsl.cardId = String.valueof(wo.get('KanbanCard__c'));			    					    		
			    		fsl.appointmentNumber = String.valueof(sa.get('AppointmentNumber'));
			    		fsl.serviceAppointmentId = String.valueof(sa.get('Id'));
			    		fsl.workOrderNumber = String.valueof(wo.get('WorkOrderNumber'));
			    		fsl.workOrderId = String.valueof(wo.get('Id'));			    					    		
			    		fsl.startDateTime = sa.get('SchedStartTime') != null ? (DateTime)JSON.deserialize(JSON.serialize(sa.get('SchedStartTime')), DateTime.class) : null;
			    		fsl.dueDateTime = sa.get('SchedEndTime') != null ? (DateTime)JSON.deserialize(JSON.serialize(sa.get('SchedEndTime')), DateTime.class) : null;			    					    		
			    		serviceAppointmentIds.add(fsl.serviceAppointmentId);
			    		result.add(fsl);
		    		}			    		
	    		}
	    		Map<Id,Sobject> serviceAppMap = getUserResources(serviceAppointmentIds);
	    		
	    		//ss 27.04.2018 commented for serviceCRewMember
	    		//call method for getting all resources including serviceResource and crewMember
				//Map<Id,List<RelatedRecord>> serviceAppMap = getUserResources(serviceAppointmentIds);
				//ss 27.04.2018 commented for serviceCRewMember			    				    			    			    			    			    			
    			for(FieldServiceLigtning fsl : result){	    				    					    				
    				sObject wot = serviceAppMap.get(fsl.serviceAppointmentId);
    				//ss 27.04.2018 commented for serviceCRewMember
    				//List<RelatedRecord> listOfResources = serviceAppMap.get(fsl.serviceAppointmentId);
    				/*if(listOfResources.size()>0)
      				{
      					fsl.Resources=listOfResources;
      				}*/
      				//ss 27.04.2018 commented for serviceCRewMember
    				if(wot != null){		    					  	    					  						    						    						    					    					   			   								
						//RS 16.4.2018 To get all the assigned resources 
						list<RelatedRecord> listOfResources = new list<RelatedRecord>();	    							    						
						for(sObject rd : wot.getSobjects('ServiceResources')){
    						RelatedRecord resource = new RelatedRecord();
    						resource.Id = String.valueof(rd.getSobject('ServiceResource').get('Id'));	
    						resource.Name = String.valueof(rd.getSobject('ServiceResource').get('Name'));
    						//If Service resource type is crew then we show crew icon else show User icon 
    						if(rd.getSobject('ServiceResource').get('ResourceType')=='C'){
    							resource.smallPhotoUrl = '/img/icon/service_crew32.png';
    						} else {
							resource.smallPhotoUrl = String.valueof(rd.getSobject('ServiceResource').getSobject('RelatedRecord').get('SmallPhotoUrl'));							
    						}
							listOfResources.add(resource); 	    						
						}
						fsl.Resources = listOfResources ; 				    						    						    					    					   			   								
      				}
      			}
      			//ss 25.04.2018	    						
				}	    						
	    	}catch(Exception ex){
	    		//return new List<FieldServiceLigtning>();
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + ex.getMessage());
	    	}
	    	return result; 	    		    	    		    	
	    }	    
	    private static Map<Id,Sobject> getUserResources(List<String> serviceAppointmentIds){	        		
    		List<sObject> typelist = new List<sObject>(); 
    		Map<Id,Sobject> serviceAppMap =  new Map<Id,Sobject>();  	
    		if(serviceAppointmentIds.size() > 0  && serviceAppointmentIds != null){		    		
    			  //Added resource type field in query	    		
	    	      String soql1 = ' Select ID,(SELECT Id, ServiceAppointmentId,ServiceResourceId,ServiceResource.RelatedRecordId,ServiceResource.Name,ServiceResource.RelatedRecord.SmallPhotoUrl, ServiceResource.ResourceType FROM ServiceResources ORDER BY SystemModstamp DESC) from ServiceAppointment ';	    		
				  soql1 += ' where Id IN (' + listIdsToString(serviceAppointmentIds) + ')' + ' limit 49999';	
	    		  typelist = Database.query(soql1);
	    		  
	    		  for(sObject tl : typelist){
	    		    serviceAppMap.put(tl.Id , tl);
	    		  }			    	  		    	 	    	
    		}	    		
    		return serviceAppMap;	    			    		
	    }
	    
	    //ss 27.04.2018 commented for serviceCRewMember
	    /*------------------------------------------------------------
        Author:         Suraj Sen
        Company:        Leankor
        Description:    Getting resources (ServiceResource and CrewMembers)
        Inputs:         List of ServiceAppointment  Id ()
        Returns:        Map<Id,List<RelatedRecord>>
        ------------------------------------------------------------*/
	    /*private static Map<Id,List<RelatedRecord>> getUserResources(List<String> serviceAppointmentIds){	        		
    		List<sObject> typelist = new List<sObject>();
    		
    		Map<Id,List<RelatedRecord>> ResourceMap = new Map<Id,List<RelatedRecord>>();
    		try{   	
	    		if(serviceAppointmentIds.size() > 0  && serviceAppointmentIds != null){
	    			   //query for Service appointment and subquery for AssignedResource (relationship name ServiceResources)		    		
		    	      String soql1 = ' Select ID,(SELECT ServiceAppointmentId,ServiceResource.Id FROM ServiceResources ORDER BY SystemModstamp DESC) from ServiceAppointment ';	    		
					  soql1 += ' where Id IN (' +listIdsToString(serviceAppointmentIds)+ ')' + ' limit 49999';	
		    		  typelist = Database.query(soql1);
		    		  List<String> ServiceResourceIds = new List<String>();
		    		  //loop over service appointment records
		    		  for(sObject tl : typelist){
		    		  	list<RelatedRecord> listOfResources = new list<RelatedRecord>();
		    		  	//Dynamically get AssignedResource records from sObject 
						for(sObject rd : tl.getSobjects('ServiceResources')){
							//Dynamically get AssignedResource records from sObject 
							ServiceResourceIds.add(String.valueof(rd.getSobject('ServiceResource').get('Id')));							
	    }	
		    		  }	
		    		 //get All resources (ServiceResource and CrewMember)
		    		 Map<Id,List<RelatedRecord>> serviceAppMap =  getServiceResourceWithCrewMembers(ServiceResourceIds);
		    		 for(sObject tl : typelist){
		    		 	list<RelatedRecord> listOfResources = new list<RelatedRecord>();
		    		 	//Dynamically get AssignedResource records from sObject for mapping from response
		    		 	for(sObject rd : tl.getSobjects('ServiceResources')){
		    		 		List<RelatedRecord> tempList = new List<RelatedRecord>();
		    		 		//get ServiceResource Id
			    		 	String tempId = String.valueOf(rd.getSobject('ServiceResource').get('Id'));
			    		 	//check if ServiceResource id is in map if contains then assign list to templist otherwise assign new instance
			    		 	tempList = serviceAppMap.containsKey(tempId) ? serviceAppMap.get(tempId) : new List<RelatedRecord>();
			    		 	//add all resources to list
			    		  	listOfResources.addAll(tempList);
		    		 	}
		    		 	//put list of resource with SA id as a key
		    		  	ResourceMap.put(tl.Id,listOfResources);
		    		  } 
	    	    
	    		}
    		}catch(Exception ex)
    		{
    			System.debug('Error occured while getting resources: '+ex);
    			return new Map<Id,List<RelatedRecord>>();
    		}	    		
    		return ResourceMap;	    			    		
	    }
	    /*------------------------------------------------------------
        Author:         Suraj Sen
        Company:        Leankor
        Description:    Getting resources (ServiceResource and CrewMembers)
        Inputs:         List of ServiceResource Id ()
        Returns:        Map<Id,List<RelatedRecord>>
        ------------------------------------------------------------*/
	    /*private static Map<Id,List<RelatedRecord>> getServiceResourceWithCrewMembers(List<String> serviceResourceIds){
	    	List<sObject> typelist = new List<sObject>();
	    	Map<Id,List<RelatedRecord>> mapRecords= new Map<Id,List<RelatedRecord>>();
	    	try{ 
		    	if(serviceResourceIds.size() > 0  && serviceResourceIds != null){
		    		 //Query for ServiceResource records with subquery for ServiceCrewMembers filter by serviceResourceIds
		    		  String soql1 = ' SELECT RelatedRecord.Id, RelatedRecord.Name, RelatedRecord.SmallPhotoUrl,(select StartDate, EndDate, ServiceResource.RelatedRecordId,ServiceResource.RelatedRecord.Name,ServiceResource.RelatedRecord.SmallPhotoUrl FROM ServiceCrewMembers) from ServiceResource';	    		
					  soql1 += ' where Id IN (' + listIdsToString(serviceResourceIds) + ')' + ' limit 49999';	
		    		  typelist = Database.query(soql1);
		    		  list<RelatedRecord> listOfResources = new list<RelatedRecord>();
		    		  for(sObject ServiceResource : typeList){
		    		  	//Add serviceResource RelatedRecord detail to innerClass. 
		    		  	RelatedRecord resource = new RelatedRecord();
		    		  	//Get field values of sObject and its child Records Dynamically  
		    		  	resource.Id = String.valueof(ServiceResource.getSobject('RelatedRecord').get('Id'));
		    		    resource.Name = String.valueof(ServiceResource.getSobject('RelatedRecord').get('Name'));
						resource.smallPhotoUrl = String.valueof(ServiceResource.getSobject('RelatedRecord').get('SmallPhotoUrl'));
						resource.type = 'AssignedResource';
						//if serviceResource have crew members then add crewsMember's serviceResource's RelatedRecord detail to innerClass.
						for(sObject ServiceCrewMembmer : ServiceResource.getSobjects('ServiceCrewMembers')){
							RelatedRecord resourceMember = new RelatedRecord();
		    		  		resourceMember.Id = String.valueof(ServiceCrewMembmer.getSobject('ServiceResource').getSobject('RelatedRecord').get('Id'));
		    		    	resourceMember.Name = String.valueof(ServiceCrewMembmer.getSobject('ServiceResource').getSobject('RelatedRecord').get('Name'));
							resourceMember.smallPhotoUrl = String.valueof(ServiceCrewMembmer.getSobject('ServiceResource').getSobject('RelatedRecord').get('SmallPhotoUrl'));
							resourceMember.startDate = String.valueof(ServiceCrewMembmer.get('StartDate'));
							resourceMember.endDate = String.valueof(ServiceCrewMembmer.get('EndDate'));
							resourceMember.type = 'CrewMember';
							listOfResources = mapRecords.containsKey(String.valueOf(ServiceResource.get('Id'))) ? mapRecords.get(String.valueOf(ServiceResource.get('Id'))) : new list<RelatedRecord>();
							listOfResources.add(resourceMember);
							mapRecords.put(String.valueOf(ServiceResource.get('Id')), listOfResources);
						}
						listOfResources = mapRecords.containsKey(String.valueOf(ServiceResource.get('Id'))) ? mapRecords.get(String.valueOf(ServiceResource.get('Id'))) : new list<RelatedRecord>();
						listOfResources.add(resource);
						//prepare map of ServiceResourceId with list of Resources
						mapRecords.put(String.valueOf(ServiceResource.get('Id')), listOfResources);
		    		  }
		    	}
	    	}catch(Exception ex)
	    	{
	    		System.debug('Error occured at getting crew members : '+ex);
	    		return new Map<Id,List<RelatedRecord>>();
	    	}		
	    return mapRecords;
	    }*/	
	    //ss 27.04.2018 commented for serviceCRewMember	    
	    global class FieldServiceLigtning{	    
            @AuraEnabled
            public String cardId { get; set; }

            @AuraEnabled
            public String appointmentNumber { get; set; }

            @AuraEnabled
            public String serviceAppointmentId { get; set; }

            @AuraEnabled
            public String workOrderNumber { get; set; }

            @AuraEnabled
            public String workOrderId { get; set; }

            @AuraEnabled
            public DateTime startDateTime { get; set; }

            @AuraEnabled
            public DateTime dueDateTime { get; set; }

            @AuraEnabled
            public String resourceName { get; set; }

            @AuraEnabled
            public String smallPhotoUrl { get; set; }

            @AuraEnabled
            public String workTypeName { get; set; }

            @AuraEnabled
            public String subject { get; set; }

            @AuraEnabled
            public List<RelatedRecord> resources { get; set; }

            @AuraEnabled
            public String folderName { get; set; }

            @AuraEnabled
            public String projectName { get; set; }

            @AuraEnabled
            public String projectBoardName { get; set; }

            @AuraEnabled
            public String cardName { get; set; }	 	    	   	    	    
	    }  
	    
	    Global class WorkOrderType{	    		    
		    global String Id;
		    global String WorkOrderNumber;		
		    global ServiceAppointments ServiceAppointments;
		    global ServiceAppointments ServiceResources;
		    global String WorkOrderType;
		    global String Subject;
		    global RelatedRecord WorkType;
	    }
	    Global class ServiceAppointments{	    		    
		    global Integer totalSize;
		    global Boolean done;		
		    global List<RecordsData> records;		    	   	    	    
	    }  
	    Global class RecordsData{	    		    
		    global String ParentRecordId;
		    global String Id;		
		    global String AppointmentNumber;
		    global String SchedStartTime;
		    global String SchedEndTime;		    
		    global ServiceResource ServiceResource;		    	   	    	    
	    } 	    
	    Global class ServiceResource{	    		    
		    global String RelatedRecordId;
		    global RelatedRecord RelatedRecord;				   	    	   	    	    
	    }
	    Global class RelatedRecord{	    
	    	global String Id;		    
		    global String Name;
		    global String SmallPhotoUrl;		
		    //ss 27.04.2018 commented for serviceCRewMember
			//global String startDate;
			//global String endDate;		    		
			//global String type;
			//ss 27.04.2018 commented for serviceCRewMember		    		
	    }	    
	    @RemoteAction
	    global static Boolean checkFSLManageApp(){	    
	    	Boolean isManaged;
			try{
			  isManaged = UserInfo.isCurrentUserLicensed('FSL');
			}catch(Exception ex){
			  isManaged = false;
			  return isManaged;
			}
		//Rs 18/5/2018 Changed return statement to check whether kanbancard field exist in workorder object. 
		//return isManaged == true ? new DescribeSchema().isFieldExistInSobject('WorkOrder','leankor__KanbanCard__c') : false;
		// RS 05/12/2018 For Availability of FSL features in Leankor application
		return isManaged ; 
	    }
	    
    /*------------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	Check field exist in given sObject or not.  
	Inputs: 		-
	Returns: 		boolean
	------------------------------------------------------------*/
    @RemoteAction
    global static Boolean checkFieldExistInSobject(){	    
    	return new DescribeSchema().isFieldExistInSobject('WorkOrder','KanbanCard__c');
    }
    
	 /***	
	 * Author : Rahul Solanki 
	 * INPUT:  Valuestream Id.
	 * OUTPUT: Return filtered list of User records.
	 * This Method is use to get Filtered User records .
	 */
	@ RemoteAction
	Global static List < User > getFilteredUsers(String VSID){
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior(); 
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        UserBehaviour userBehaviour = new UserBehaviour();
        if (
            !kanbanCardBehaviour.isAccessible() ||
            !resourceAssignmentBehavior.isAccessible() ||
            !taskBehaviour.isAccessible() ||
            !userBehaviour.isAccessible()
        ) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records'); 
        }
        //Check CRUD / FLC behavior 
        
        Set < String > allRelatedUserID = new Set < String > ();
        List < USer > users = new List < User > ();
		try {	
            // Tilak - 05/03/2020 - Changes for filtering soft deleted record and removing null condition in where clause.		
            List <leankor__KanbanCard__c> kanbans = [SELECT 
                                                        Id, 
                                                        OwnerID 
                                                    FROM leankor__KanbanCard__c 
                                                    WHERE leankor__ValueStream__c = : VSID 
                                                        AND leankor__isRecordDeleted__c = false
                                                    LIMIT 49999];
            if (kanbans.size() > 0) {
                for (leankor__KanbanCard__c kanban: kanbans) {
                    allRelatedUserID.add(kanban.OwnerID);
                }
            }
            //Date :15/07/19 To return Resource User Records on PG 
            List<leankor__ResourceAssignment__c> ResourceAssignmentList = [SELECT 
                                                        				Id, 
                                                        				leankor__AssignedTo__c,
                                                        				leankor__AssignedTo__r.name                                                        
                                                    				FROM leankor__ResourceAssignment__c 
                                                                    WHERE leankor__KanbanCard__c IN:kanbans 
                                                                        AND leankor__KanbanCard__r.leankor__ValueStream__r.leankor__BoardType__c ='UberBoard'
                                                                    LIMIT 49999 ];                 
            if(ResourceAssignmentList.size()>0){
            	for(leankor__ResourceAssignment__c  resource:ResourceAssignmentList){
            		 allRelatedUserID.add(resource.leankor__AssignedTo__c);
            	}
            
            }
            //SS 28.03.2018
            //modified to query Task records in a separate list and refactored code to fix Techical Debt
            /*List < leankor__KanbanCard__c > KanbanCards = [Select Id, (Select Id, OwnerID from Tasks where IsDeleted = false)from leankor__KanbanCard__c where leankor__ValueStream__c = : VSID limit 9999 All Rows];
            for (leankor__KanbanCard__c k: KanbanCards) {
                for (Task t: k.Tasks) {
                    AllRelatedUserID.add(t.OwnerID);
                }
            }*/            
            
            /*List < leankor__KanbanCard__c > KanbanCards = 
            											[Select 
            													Id 
            												from leankor__KanbanCard__c 
            												where leankor__ValueStream__c = : VSID limit 9999];*/
            for(Task t: 
            			[SELECT 
            					Id, 
            					OwnerID 
            				FROM Task 
                            WHERE What.Type = 'leankor__KanbanCard__c' 
                                AND WhatId IN:kanbans 
                                AND IsDeleted = false 
            				LIMIT 49999 All Rows]){
                allRelatedUserID.add(t.OwnerID);
            }            
            //SS 28.03.2018
            users = 
            		[SELECT 
            				Id, 
            				Name, 
            				Email, 
            				FirstName, 
            				LastName, 
            				SmallPhotoUrl, 
            				Username, 
            				UserType 
            			FROM User 
                 		WHERE Id in: allRelatedUserID 
            			LIMIT 49999];
        } catch (QueryException ex) {
            System.debug('Error : ' + ex.getMessage());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return users;
    } 
    
        /***
         * Given a Task Id list, returns key stats
         * INPUT: List of Task ID
         * OUTPUT: object with stats
	 * USAGE : It will use in Task Chatter count.
	 */  
    public static Map<Id,Integer> getTaskChatterCounts(List<Task> taskIds) {				
	
        Map<Id,Integer> mapFeed = new Map<Id,Integer>();
		
		try{
            /*
            *Modified By :Ashutosh Gour
            *Modification : Modification for making SOQL selective and remove negative selection.
            */
			//List<TaskFeed> taskfeedLog = [SELECT Id, ParentId FROM TaskFeed WHERE ParentId IN: TaskIds AND Type != 'CreateRecordEvent' limit 49999];
            List<TaskFeed> taskfeedLog = new List<TaskFeed>();
            for (TaskFeed tf : [SELECT 
                                    Id, 
                                    ParentId,
                                    Type
                                FROM TaskFeed 
                                WHERE ParentId IN: TaskIds 
                                LIMIT 49999]) {
                if (tf.Type != 'CreateRecordEvent') {
                    taskfeedLog.add(tf);
                }
            }
			for (TaskFeed task: taskfeedLog){				
                if(mapFeed.containsKey(task.ParentId)){									
                    Integer i = mapFeed.get(task.ParentId);
	                i += 1;
                    mapFeed.put(task.ParentId, i);	                
				}else{					
                    mapFeed.put(task.ParentId, 1);				
				}
                }                                       
            }catch(Exception e){           
                //return new Map<Id,Integer>();
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + e.getMessage());
            }                                   
        return mapFeed;
    } 
    
	@ RemoteAction
	Global static List<leankor.RealTimeController.KanbanChatterStats> getTaskChatterStats(List<Id> taskIds){
            List<leankor.RealTimeController.KanbanChatterStats> kCSL = new List<leankor.RealTimeController.KanbanChatterStats>();		
            leankor.RealTimeController.KanbanChatterStats kCS = new leankor.RealTimeController.KanbanChatterStats();				
        try {
                /*
                *Modified By :Ashutosh Gour
                *Modification : Modification for making SOQL selective and remove negative selection.
                */
                //kCS.TaskChatterCount = [SELECT count() FROM TaskFeed WHERE ParentId IN: TaskIds AND Type != 'CreateRecordEvent' limit 49999];
                List<TaskFeed> taskFeedList = new List<TaskFeed>();
                for (TaskFeed tf : [SELECT Id, Type FROM TaskFeed WHERE ParentId IN: TaskIds LIMIT 49999]) {
                    if (tf.Type != 'CreateRecordEvent') {
                        taskFeedList.add(tf);
                    }
                }
                kCS.TaskChatterCount = taskFeedList.size();
                kCSL.add(kCS);
            } catch (Exception e) {
                System.debug('ERROR: trying to get kanban comment count');
                //return new List<leankor.RealTimeController.KanbanChatterStats>();
                //25/04/2023 : We are Throwing Exception
			    throw new Util.LeanException('ERROR:' + e.getMessage());
            }      
    
            return kCSL;
    }
    
    //Converts list of Id to a String
    Public static String listIdsToString(List<String> recordIds){
		  String cardIDs = '';    
	      for(Id t : (List<Id>) recordIds){
	          cardIDs =  cardIDs + '\''+ t + '\',';
	      }
	return cardIDs.substring(0,cardIDs.length() - 1);
    }     
    
	/*------------------------------------------------------------
	    Author:         Rahul Solanki,Suraj Sen
	    Company:        Leankor
	    Description:    Inner class for category data 	    
	------------------------------------------------------------*/
	public class TemplateData{	
		public String id ;
		public String templateId;
		public String fieldSetName; 
	}
	
	//Date :01/11/19 create New wrapper class to Define  JsonDefinition and JsonData.
    public class JsonDescription{
		public String jsonDefinitions;
		public String jsonData;
	
    }
    
	/*------------------------------------------------------------
	    Author:         Rahul Solanki,Suraj Sen
	    Company:        Leankor
	    Description:    Getting json data of kanbancard when we change category 
	    Inputs:         string 
	    Returns:        string
	------------------------------------------------------------*/
	@deprecated
    @remoteAction     
	global static string readJSONDataByCategory(string templateData){
		String serializeJSON ;	
		/*Map<String, Schema.SObjectField> fieldMapKanbanCard = realTimeController.fieldMapKanbanCard ; 	
		KanbanSerializer kSObject = new KanbanSerializer();	
		describeSchema dSObject = new describeSchema();	
		TemplateData tmpData = (TemplateData)JSON.Deserialize(TemplateData,TemplateData.class);
		
		JsonDescription jsonDataDescription=new JsonDescription();
		kanbanSerializer kbs=new kanbanSerializer();
		
		try{
			Set<String> allFields = fieldMapKanbanCard.keyset();
			Set<String> allOtherFields = new Set<String>();		
				allOtherFields.addAll(allFields);	
			
				Set<String> referenceFieldNames = dSObject.getReferenceFieldName(fieldMapKanbanCard);
				allOtherFields.addAll(referenceFieldNames); 		
				allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__Color__c');
				allOtherFields.add('leankor__Opportunity__r.StageName');
				allOtherFields.add('leankor__ValueStreamLink__r.leankor__BoardType__c');
				allOtherFields.add('leankor__Case__r.Subject');
				allOtherFields.add('leankor__Case__r.Status');
				allOtherFields.add('leankor__Case__r.Priority');
		        allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__FieldSetName__c');
		            
		    List<leankor__kanbancard__c> boardKanbanCard = dSObject.dynamicFieldQuery('leankor__KanbanCard__c', allOtherFields, 
		                'WHERE Id = ' + '\'' + tmpData.id + '\'');            
		           
			boardKanbanCard[0].leankor__KanbanCardTemplate__r.leankor__FieldSetName__c = tmpData.fieldSetName;
			boardKanbanCard[0].leankor__KanbanCardTemplate__c = tmpData.templateId; 
		    //Date : 01/11/19 return stringify jsonDefinitions and  JsonData .
		    //serializeJSON = kSObject.serializeData(boardKanbanCard[0],fieldMapKanbanCard);
            jsonDataDescription.jsonData=kSObject.serializeData(boardKanbanCard[0],fieldMapKanbanCard);		 
		    jsonDataDescription.jsonDefinitions=kbs.serializeHeader('leankor__KanbanCard__c', tmpData.fieldSetName,realTimeController.UIHeaderSettings,realTimeController.UIItemSettings,fieldMapKanbanCard);
			system.debug(serializeJSON);
			serializeJSON=JSON.serialize(jsonDataDescription);	
		}catch(Exception e ){	
			//return serializeJSON;	
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}*/
		return serializeJSON;
    }
    

    global class JsonDescriptionFieldSet{
		public Map<String, Object> jsonDefinitions;
		public Map<String, Object> jsonData;
        public Map<String, Object> config;
        public Boolean isReadOnly = false;
    }
    
    @remoteAction     
	global static JsonDescriptionFieldSet newReadJSONDataByCategory(String templateData) {

		Map<String, Schema.SObjectField> fieldMapKanbanCard = realTimeController.fieldMapKanbanCard; 	
		KanbanSerializer kanbanSerializerInsatance = new KanbanSerializer();	
		DescribeSchema describeSchemaInstance = new DescribeSchema();	
		TemplateData tmpData = (TemplateData)JSON.Deserialize(templateData, TemplateData.class);
        JsonDescriptionFieldSet jsonDescriptionInstance = new JsonDescriptionFieldSet();
		kanbanSerializer kanbanSerializers = new kanbanSerializer();
		
        try {
			Set<String> allFields = fieldMapKanbanCard.keyset();
			Set<String> allOtherFields = new Set<String>();		
            allOtherFields.addAll(allFields);	
            Set<String> referenceFieldNames = describeSchemaInstance.getReferenceFieldName(fieldMapKanbanCard);
            allOtherFields.addAll(referenceFieldNames); 		
            allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__Color__c');
            allOtherFields.add('leankor__Opportunity__r.StageName');
            allOtherFields.add('leankor__ValueStreamLink__r.leankor__BoardType__c');
            allOtherFields.add('leankor__Case__r.Subject');
            allOtherFields.add('leankor__Case__r.Status');
            allOtherFields.add('leankor__Case__r.Priority');
            allOtherFields.add('leankor__KanbanCardTemplate__r.leankor__FieldSetName__c');        
		    List<leankor__kanbancard__c> boardKanbanCard = describeSchemaInstance.dynamicFieldQuery('leankor__KanbanCard__c', allOtherFields, 'Where Id = ' + '\'' + tmpData.id + '\'');              
			boardKanbanCard[0].leankor__KanbanCardTemplate__r.leankor__FieldSetName__c = tmpData.fieldSetName;
			boardKanbanCard[0].leankor__KanbanCardTemplate__c = tmpData.templateId; 
            List<String> fieldsetWithonlyReadAccess = new List<String>();
            for (leankor__ProjectBoardWorkFieldSet__c singleRecord : [Select Id,
                                                                            Name,
                                                                            leankor__FieldSetName__c,
                                                                            leankor__ProjectBoard__c,
                                                                            UserRecordAccess.HasReadAccess,
                                                                            UserRecordAccess.HasEditAccess
                                                                        From leankor__ProjectBoardWorkFieldSet__c
                                                                        Where leankor__ProjectBoard__c =:boardKanbanCard[0].leankor__ValueStream__c
                                                                            And leankor__FieldSetName__c =:tmpData.fieldSetName
                                                                        Limit 50000]) {
    
                if(singleRecord.UserRecordAccess.HasReadAccess == true && singleRecord.UserRecordAccess.HasEditAccess == false) {
                    fieldsetWithonlyReadAccess.add(singleRecord.leankor__FieldSetName__c);
                }
            }

            if(fieldsetWithonlyReadAccess.contains(tmpData.fieldSetName)) {
                jsonDescriptionInstance.isReadOnly = true;
            }

            jsonDescriptionInstance.jsonData = kanbanSerializerInsatance.customFieldsData(boardKanbanCard[0], fieldMapKanbanCard);		 
		    jsonDescriptionInstance.jsonDefinitions = kanbanSerializers.customMetadataHeader('leankor__KanbanCard__c', tmpData.fieldSetName, realTimeController.UIHeaderSettings, realTimeController.UIItemSettings, fieldMapKanbanCard);
            jsonDescriptionInstance.config = KanbanSerializer.configPartOfHeaderSettings;
		}
        
        catch(Exception e ) {		
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}

		return jsonDescriptionInstance;

    }
    





    
	/** Class will use to take and return records to LeankorJS end in required format. */
	
    global class StatusLogs {
    
    @AuraEnabled
    public String id { get; set; }
    
    @AuraEnabled
    public String onBudget { get; set; }
    
    @AuraEnabled
    public String onQuality { get; set; }
    
    @AuraEnabled
    public String onTime { get; set; }
    
    @AuraEnabled
    public String percentComplete { get; set; }
    
    @AuraEnabled
    public String detail { get; set; }
    
    @AuraEnabled
    public String kanbanCard { get; set; }
    
    @AuraEnabled
    public String createdDate { get; set; }
    
    // Constructor
    public StatusLogs() {
        // Initialize properties if needed
    }
}
    
	/*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    Remote method for getting StatusLogs of KanbanCard
    Inputs:         String KanbanID
    Returns:        List<StatusLogs>
    ------------------------------------------------------------*/  
	@RemoteAction
	Global Static List<StatusLogs> getStatusLogs(list<String> KanbanID){
        //Check CRUD / FLC behavior 
        StatusLogBehaviour StatusLogBehaviour = new StatusLogBehaviour();
        if (!StatusLogBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

		List<StatusLogs> wrapperStatusLogs = new List<StatusLogs>();		
        List<leankor__StatusLog__c> statusLogsList = [SELECT Id, 
                                                            CreatedDate,
                                                            Name,
                                                            leankor__Detail__c,
                                                            leankor__KanbanCard__c,
                                                            leankor__OnBudget__c,
                                                            leankor__OnQuality__c,
                                                            leankor__OnTime__c,
                                                            leankor__PercentComplete__c 
                                                        FROM leankor__StatusLog__c 
                                                        WHERE leankor__KanbanCard__C IN : KanbanID 
                                                        ORDER BY CreatedDate DESC 
                                                        LIMIT 49999];
		
		for(leankor__StatusLog__c statusLog : statusLogsList){
			String dt='{"CreatedDate": '+JSON.serialize(StatusLog.CreatedDate)+'}';
			StatusLogs sL = (StatusLogs)JSON.deserialize(dt,StatusLogs.Class);			
			StatusLogs statusLogObj = new  StatusLogs();
			statusLogObj.id  = statusLog.Id;
			statusLogObj.onBudget = statusLog.leankor__OnBudget__c;
			statusLogObj.onQuality = statusLog.leankor__OnQuality__c;
			statusLogObj.onTime = statusLog.leankor__OnTime__c;
			statusLogObj.percentComplete = string.ValueOf(statusLog.leankor__PercentComplete__c);
			statusLogObj.detail = statusLog.leankor__Detail__c;
			statusLogObj.kanbanCard = statusLog.leankor__KanbanCard__c;
			statusLogObj.createdDate = sL.CreatedDate;								
			wrapperStatusLogs.add(statusLogObj);
		}
		return wrapperStatusLogs;
	}	
		

    global class StatusLogsData {
        List<StatusLogs> statusLogs;
        Map<Id, leankor__KanbanCard__c> kanbanCards;
    }

    
    @AuraEnabled
    public static StatusLogRecord retrieveStatusRecords(List<String> kanbanCardIds) {
        StatusLogRecord response = new StatusLogRecord();
        
        try {
            // Call the existing method to read status records
            StatusLogsData statusLogsData = readStatusRecords(kanbanCardIds);
            
            // Populate the response object with data
            for(StatusLogs statusLog : statusLogsData.StatusLogs){ // Corrected here
                StatusLogs logRecord = new StatusLogs();
                logRecord.id = statusLog.id;
                logRecord.createdDate = statusLog.createdDate;
                logRecord.detail = statusLog.detail;
                logRecord.kanbanCard = statusLog.kanbanCard;
                logRecord.onBudget = statusLog.onBudget;
                logRecord.onQuality = statusLog.onQuality;
                logRecord.onTime = statusLog.onTime;
                logRecord.percentComplete = statusLog.percentComplete;

                response.statusLogs.add(logRecord); // Add to the list
            }
            response.kanbanCards = statusLogsData.kanbanCards;
        } catch (Exception e) {
            // Handle any exceptions and log the error message
            System.debug('Error retrieving status records: ' + e.getMessage());
        }

        return response;
    }



    

    @RemoteAction
	global Static StatusLogsData readStatusRecords(list<String> kanbanCardIds) {
        StatusLogsData result = new StatusLogsData();
        List<StatusLogs> wrapperStatusLogs = new List<StatusLogs>();		
        List<leankor__StatusLog__c> statusLogsList = [Select Id, 
                                                            CreatedDate,
                                                            Name,
                                                            leankor__Detail__c,
                                                            leankor__KanbanCard__c,
                                                            leankor__OnBudget__c,
                                                            leankor__OnQuality__c,
                                                            leankor__OnTime__c,
                                                            leankor__PercentComplete__c 
                                                        From leankor__StatusLog__c 
                                                        Where leankor__KanbanCard__C In :kanbanCardIds 
                                                        Order By CreatedDate DESC 
                                                        Limit 50000];
		
		for(leankor__StatusLog__c statusLog : statusLogsList){
			String dt='{"CreatedDate": '+JSON.serialize(StatusLog.CreatedDate)+'}';
			StatusLogs sL = (StatusLogs)JSON.deserialize(dt,StatusLogs.Class);			
			StatusLogs statusLogObj = new  StatusLogs();
			statusLogObj.id  = statusLog.Id;
			statusLogObj.onBudget = statusLog.leankor__OnBudget__c;
			statusLogObj.onQuality = statusLog.leankor__OnQuality__c;
			statusLogObj.onTime = statusLog.leankor__OnTime__c;
			statusLogObj.percentComplete = string.ValueOf(statusLog.leankor__PercentComplete__c);
			statusLogObj.detail = statusLog.leankor__Detail__c;
			statusLogObj.kanbanCard = statusLog.leankor__KanbanCard__c;
			statusLogObj.createdDate = sL.CreatedDate;								
			wrapperStatusLogs.add(statusLogObj);
		}
        result.StatusLogs = wrapperStatusLogs;

        
        result.kanbanCards = new Map<Id, leankor__KanbanCard__c>([Select Id, 
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c
                                From leankor__KanbanCard__c
                                Where Id In :kanbanCardIds]);
        
        return result;
    }
		
	/*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    Remote method for create leankor__StatusLog__c record
    				and It takes statusLog object.
    Inputs:         StatusLogs logs
    Returns:        StatusLogs
    ------------------------------------------------------------*/
	@RemoteAction
	Global static List<kanbancontroller.StatusLogs> createStatusLogs(list<kanbancontroller.StatusLogs> logs){
        //Check CRUD / FLC behavior 
        StatusLogBehaviour StatusLogBehaviour = new StatusLogBehaviour();
        if (
            !StatusLogBehaviour.isAccessible() ||
            !StatusLogBehaviour.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

		map<string,leankor__StatusLog__c> statusLogMap = new map<string,leankor__StatusLog__c>();
		list<leankor__StatusLog__c> statusLogList = new list<leankor__StatusLog__c>();
			for(kanbancontroller.StatusLogs sl : logs){
				leankor__StatusLog__c statusLog = new leankor__StatusLog__c(				
						leankor__OnBudget__c = sl.onBudget,
						leankor__OnQuality__c = sl.onQuality,
						leankor__OnTime__c =  sl.onTime,
						leankor__PercentComplete__c = decimal.Valueof(sl.percentComplete),
						leankor__Detail__c = sl.detail,
						leankor__KanbanCard__c = sl.kanbanCard								
						);
				statusLogList.add(statusLog);		
			}
		
		try{
			DataBase.Insert(statusLogList,true);
			system.debug('statusLogList' + statusLogList);
			
			//Querying becoz CreatedDate is not available after insert
						
            list<leankor__StatusLog__c> newStatusLogList = [SELECT id,
                                                                CreatedDate,
                                                                leankor__OnBudget__c,
                                                                leankor__OnQuality__c,
                                                                leankor__OnTime__c,
                                                                leankor__PercentComplete__c,
                                                                leankor__Detail__c,
                                                                leankor__KanbanCard__c 
                                                            FROM leankor__StatusLog__c 
                                                            WHERE Id IN: statusLogList 
                                                            LIMIT 49999];  
			
			for(leankor__StatusLog__c statusLogWithId : newStatusLogList ){
				statusLogMap.put(statusLogWithId.leankor__KanbanCard__c, statusLogWithId);			
			}
			for(kanbancontroller.StatusLogs l :logs){
				if(statusLogMap.containsKey(l.kanbanCard)){
					system.debug('statusLogMap.get(l.kanbanCard).CreatedDate' + statusLogMap.get(l.kanbanCard).CreatedDate);
					String dt='{"CreatedDate": '+JSON.serialize(statusLogMap.get(l.kanbanCard).CreatedDate)+'}';
					StatusLogs sLDate = (StatusLogs)JSON.deserialize(dt,StatusLogs.Class);			
					l.id = statusLogMap.get(l.kanbanCard).Id;
					l.createdDate = sLDate.createdDate;
				}			
			}			
			
		}catch(DMLException ex){
			System.debug('Error : '+ex.getMessage());
			//return (new list<kanbancontroller.StatusLogs>());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
		}
		return logs;
    }
    @AuraEnabled
    public static List<StatusLogData> createStatusLogs(List<StatusLogData> statusLogDataList) {
        // List to store the converted data for passing to the createStatusLogs method
        List<kanbancontroller.StatusLogs> kanbanStatusLogsList = new List<kanbancontroller.StatusLogs>();

        // Convert StatusLogData to kanbancontroller.StatusLogs
        for (StatusLogData statusLogData : statusLogDataList) {
            kanbancontroller.StatusLogs kanbanStatusLog = new kanbancontroller.StatusLogs();
            kanbanStatusLog.id = statusLogData.id;
            kanbanStatusLog.onBudget = statusLogData.onBudget;
            kanbanStatusLog.onQuality = statusLogData.onQuality;
            kanbanStatusLog.onTime = statusLogData.onTime;
            kanbanStatusLog.percentComplete = statusLogData.percentComplete;
            kanbanStatusLog.detail = statusLogData.detail;
            kanbanStatusLog.kanbanCard = statusLogData.kanbanCard;
            kanbanStatusLogsList.add(kanbanStatusLog);
        }

        // Call the existing RemoteAction method to create the status logs
        List<kanbancontroller.StatusLogs> createdKanbanStatusLogs = createStatusLogs(kanbanStatusLogsList);

        // Convert the result from kanbancontroller.StatusLogs back to StatusLogData
        List<StatusLogData> createdStatusLogDataList = new List<StatusLogData>();

        for (kanbancontroller.StatusLogs createdKanbanStatusLog : createdKanbanStatusLogs) {
            StatusLogData createdStatusLogData = new StatusLogData();
            createdStatusLogData.id = createdKanbanStatusLog.id;
            createdStatusLogData.onBudget = createdKanbanStatusLog.onBudget;
            createdStatusLogData.onQuality = createdKanbanStatusLog.onQuality;
            createdStatusLogData.onTime = createdKanbanStatusLog.onTime;
            createdStatusLogData.percentComplete = createdKanbanStatusLog.percentComplete;
            createdStatusLogData.detail = createdKanbanStatusLog.detail;
            createdStatusLogData.kanbanCard = createdKanbanStatusLog.kanbanCard;
            createdStatusLogData.createdDate = createdKanbanStatusLog.createdDate; // Assuming StatusLogData has a createdDate field
            createdStatusLogDataList.add(createdStatusLogData);
        }

        // Return the converted result
        return createdStatusLogDataList;
    }




    
	/** Class will use to take and return records timeCard's duration picklist values */
	Global Class TimeCardDuration{
		Global String label;
		Global String value;		
		/*SS 03.08.2018*/
		//Added for specifying default picklist value
		Global Boolean isDefaultValue;		
    }
    
	/*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        leankor
    Description:    Remote method for getting TimeCard's Duration picklist values.
    Inputs:         -
    Returns:        list<TimeCardDuration>
    Modified :		SS  04.09.2018 for Default picklist value
    ------------------------------------------------------------*/
	@RemoteAction
	Global Static list<TimeCardDuration> getTimeCardDurationValues(){
		list<TimeCardDuration> tcdList = new list<TimeCardDuration>();
		try{
			Schema.DescribeFieldResult fieldResult = leankor__TimeCard__c.fields.leankor__Duration__c.getDescribe();
			List<Schema.Picklistentry> schemaPicklistEntry =  fieldResult.getpicklistvalues(); 
	
			for(Schema.Picklistentry picklistEntry  : schemaPicklistEntry ){
				TimeCardDuration tcd = new TimeCardDuration();
				tcd.label = picklistEntry.getLabel();
				tcd.value = picklistEntry.getValue();			
				tcd.isDefaultValue = picklistEntry.isDefaultValue();			
				tcdList.add(tcd);		
			}		
			if(String.isBlank((String)fieldResult.getDefaultValue()))
			{
			   tcdList[0].isDefaultValue= true;
			}		
		} catch (Exception e){
		
			system.debug(e);
			//return tcdList;
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}		
		return tcdList; 	
	}
    global class BoardOnLoadConfig {
        // Input parameter
        public String boardName;
        public String valueStreamId;
        public List<String> remoteCardIDs;
        // Return Parameters
        public List<leankor__KanbanCardTemplate__c> kanbanCardTemplates;
        public leankor__Preference__c preference;
        public List<leankor.RealTimeController.Kanban> kanbanBoardCards;
        public realTimeController.GlueforceData glueforceData;
        public KanbanController.SprintDetail sprintDetails = new KanbanController.SprintDetail();
    }

    public class SprintDetail {
        public Datetime sprintStartDate;
        public Integer daysPerSprint;
        public Boolean isAgile;
        public Boolean sevenDayWorkWeek;
        public Datetime sprintEndDate;
        public Decimal unCompletedPoint;
        public Decimal totalPoint;
    }

    @RemoteAction
    global static BoardOnLoadConfig getBoardRemoteConfig(BoardOnLoadConfig config) {
        // Call the method to get the data for onLoad
        BoardOnLoadConfig boardConfig = new BoardOnLoadConfig();
            if(String.isNotBlank(config.boardName))
            {
                if(String.isNotBlank(config.valueStreamId) && (config.valueStreamId InstanceOf Id) && (Id.valueOf(config.valueStreamId).getSobjectType().getDescribe().getName() == 'leankor__ValueStream__c'))  
                {
                    RealTimeControllerHelper.updateProjectBoardDates(new Set<String>{config.valueStreamId});
                    PageSetupController.thisValueStream = new leankor__ValueStream__c(id=config.ValueStreamId);
                    boardConfig.kanbanCardTemplates = RealTimeController.getKanbanCardTemplates(config.valueStreamId); 
                    boardConfig.kanbanBoardCards = new leankor.KanbanController().getKanbanBoardKanbanCards(config.ValueStreamId);
                    boardConfig.sprintDetails = readProjectBoardPoints(config.valueStreamId);
                }
                boardConfig.preference = PageSetupController.getPreference(config.boardName.toLowerCase());
            }
            
        return boardConfig;
    }   
	
    /*----------------------------------------------------------------------------------------------
     Description : Calculate Sprint end date by using sprint start date and day per sprint.
     Input       : valueStreamId - board id.
     Output      : retrun Sprint details.
     -----------------------------------------------------------------------------------------------*/  
    @TestVisible
    private static KanbanController.SprintDetail readProjectBoardPoints(String valueStreamId){
        KanbanController.SprintDetail sprintDetail = new KanbanController.SprintDetail();
        Set<String> masterContainerTypeFilters = new Set<String>{'Archive', 'Backlog', 'Regular'};
        leankor__ValueStream__c valueStream = [Select Id,
                                                    leankor__SprintStartDate__c,
                                                    leankor__DaysPerSprint__c,
                                                    leankor__IsAgile__c,
                                                    leankor__SevenDayWorkWeek__c
                                                From leankor__ValueStream__c
                                                Where Id =: valueStreamId
                                                    And leankor__IsRecordDeleted__c = false];
         if(valueStream.leankor__IsAgile__c == true){
            sprintDetail.sprintStartDate = valueStream.leankor__SprintStartDate__c != null ? valueStream.leankor__SprintStartDate__c : null;
            sprintDetail.daysPerSprint = (valueStream.leankor__DaysPerSprint__c != null) ? (Integer)valueStream.leankor__DaysPerSprint__c : 0;
            sprintDetail.isAgile = valueStream.leankor__IsAgile__c;
            sprintDetail.sevenDayWorkWeek = valueStream.leankor__SevenDayWorkWeek__c;
            sprintDetail.sprintEndDate = (sprintDetail.sprintStartDate != null && sprintDetail.daysPerSprint> 0) ? Util.getSprintEndDate(valueStream): null ;
            AggregateResult  projectBoardPoints = Util.readWorkItemPoints(valueStream.id, masterContainerTypeFilters);
            sprintDetail.unCompletedPoint = (Decimal)projectBoardPoints.get('uncompletedPoints');
            sprintDetail.totalPoint = (Decimal)projectBoardPoints.get('totalPoints');
        }
        return sprintDetail;
    }

	@RemoteAction
    global static Map<String, leankor__KanbanCard__c> getZoneKanbanCards(List<String> zoneIds) {
        Map<String, leankor__KanbanCard__c> kanbanCardMap = new Map<String, leankor__KanbanCard__c>();
        try {
            for(leankor__KanbanCard__c kc : [SELECT Id,
                                                    Name,
                                                    leankor__Order__c,
                                                    leankor__GUID__c,
                                                    leankor__ValueStream__c
                                                FROM leankor__KanbanCard__c
                                                WHERE leankor__Zone__c IN: zoneIds 
                                                    AND leankor__IsRecordDeleted__c = false
                                                    AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                LIMIT 49999]){
                kanbanCardMap.put(kc.leankor__GUID__c, kc);
            }
        } catch (Exception e) {
            System.debug('ERROR: while getting kanban card : ' + e.getMessage());
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        return kanbanCardMap;
    }

    @RemoteAction
    global static  BoardOnLoadConfig getBoardRemoteConfigForCalendarView(BoardOnLoadConfig config) {
        //Call the method to get the data for onLoad 
        BoardOnLoadConfig boardConfig = new BoardOnLoadConfig();
            if(String.isNotBlank(config.boardName))
            {
                if(String.isNotBlank(config.valueStreamId))
                {
                    PageSetupController.thisValueStream = new leankor__ValueStream__C(id=config.ValueStreamId);
                    boardConfig.glueforceData = realTimeController.getCardsWithStickerInfo(config.ValueStreamId);
                    boardConfig.kanbanCardTemplates = RealTimeController.getKanbanCardTemplates(config.valueStreamId); 
                }
            }
        return boardConfig;
    }
    
    //=================================================================================
    //Changes for Remove reload POP.
    @RemoteAction
    global static List <realtimeController.kanban> readKanbanCardBulkRecord(List<String> valueStreamList, List<String> cardIds){
        
        List<leankor.RealTimeController.Kanban> kanbanCardList = new List<leankor.RealTimeController.Kanban>();
        
        Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = new Map<String, FieldServiceUtilityController.RecordDetails>();
        if (valueStreamList.size() > 0) {	
            fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(valueStreamList,'Valuestream');
        }else{
            List<String> boardIds = new List<String>();
            for (leankor__KanbanCard__c cards : [Select id, leankor__ValueStream__c from leankor__KanbanCard__c  Where id IN : cardIds]) {
                boardIds.add(cards.leankor__ValueStream__c);
            }
            fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(boardIds,'Valuestream');

        }
        List<leankor__KanbanCard__c> kanbanCards = [ Select id,
                                                        leankor__ProjectRoom__c,
                                                        leankor__State__c,
                                                        leankor__Height__c,
                                                        leankor__UrlLink__c,
                                                        leankor__Width__c,
                                                        leankor__Top__c,
                                                        leankor__Left__c,
                                                        leankor__X__c,
                                                        leankor__Y__c,
                                                        leankor__Point__c,
                                                        leankor__KanbanCardTemplate__r.Name,
                                                        leankor__GUID__c,
                                                        leankor__Bottom__c,
                                                        leankor__CmpID__c,
                                                        leankor__CSSLayout__c,
                                                        leankor__JSONDefinition__c,
                                                        leankor__JSONData__c,
                                                        leankor__ZoneGUID__c,
                                                        leankor__Zone__c,
                                                        leankor__Swimlane__c,
                                                        leankor__MasterContainer__c,
                                                        leankor__ValueStream__c,
                                                        leankor__kanbanCardTemplate__c,
                                                        leankor__DescriptionLong__c,
                                                        OwnerId,
                                                        Owner.Name,
                                                        Name,
                                                        leankor__kanbanCardTemplate__r.leankor__Color__c,
                                                        leankor__Opportunity__r.StageName,
                                                        leankor__Opportunity__c,
                                                        leankor__ValueStreamLink__c,
                                                        leankor__ValueStreamCardLink__c,
                                                        leankor__ValueStreamLink__r.leankor__BoardType__c,
                                                        leankor__ValueStreamCardLink__r.Name,
                                                        leankor__ValueStreamLink__r.Name,
                                                        leankor__Priority__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__DurationUnits__c,
                                                        leankor__DateColor__c,
                                                        leankor__PercentComplete2__c,
                                                        leankor__Contact__c,
                                                        leankor__Contact__r.Name,
                                                        leankor__Account__c,
                                                        leankor__Account__r.Name,
                                                        leankor__Case__c,
                                                        leankor__Case__r.Subject,
                                                        leankor__Order__c,
                                                        leankor__Opportunity__r.Name,
                                                        leankor__OnBudget__c,
                                                        leankor__OnQuality__c,
                                                        leankor__OnTime__c,
                                                        leankor__IsAtRisk__c,
                                                        leankor__IsOnHold__c,
                                                        leankor__EffortRemaining__c,
                                                        CreatedDate,
                                                        LastModifiedDate,
                                                        leankor__StartDateTime__c,
                                                        leankor__AcceptanceCriteria__c,
                                                        leankor__CardID__c,
                                                        leankor__IsSuccessorRecalculate__c,
                                                        leankor__Case__r.CaseNumber,
                                                        leankor__Case__r.Status,
                                                        leankor__Case__r.Priority,
                                                        leankor__IsConstraintRecalculate__c,
                                                        leankor__Monday__c,
                                                        leankor__Tuesday__c,
                                                        leankor__Wednesday__c,
                                                        leankor__Thursday__c,
                                                        leankor__Friday__c,
                                                        leankor__Saturday__c,
                                                        leankor__Sunday__c,
                                                        leankor__WeekCalendar__c  
                                                    From leankor__KanbanCard__c 
                                                    Where (leankor__ValueStream__c IN: valueStreamList
                                                        OR id IN: cardIds)
                                                        And leankor__KanbanCard__c.leankor__isRecordDeleted__c = false
                                                        And leankor__ValueStream__r.leankor__isRecordDeleted__c = false 
                                                        And RecordType.Name =: 'ActivityCard'
                                                    Limit 49999 ];
      
        for(Integer kbPointer = 0; kbPointer < kanbanCards.size();){
	  
            if(String.isNotBlank(kanbanCards[kbPointer].leankor__ProjectRoom__c)){
	            leankor.RealTimeController.Kanban kbObject = new leankor.RealTimeController.Kanban();
      
                kbObject.ForceID = kanbanCards[kbPointer].Id;
                kbObject.State = kanbanCards[kbPointer].leankor__State__c;
                kbObject.Height = kanbanCards[kbPointer].leankor__Height__c;
                kbObject.UrlLink = kanbanCards[kbPointer].leankor__UrlLink__c;
                kbObject.Width = kanbanCards[kbPointer].leankor__Width__c;
                kbObject.Top = kanbanCards[kbPointer].leankor__Top__c;
                kbObject.Left = kanbanCards[kbPointer].leankor__Left__c;
                kbObject.X = kanbanCards[kbPointer].leankor__X__c;
                kbObject.Y = kanbanCards[kbPointer].leankor__Y__c;
                kbObject.Point = kanbanCards[kbPointer].leankor__Point__c;
                kbObject.Title = kanbanCards[kbPointer].leankor__KanbanCardTemplate__r.Name;
                kbObject.GUID = kanbanCards[kbPointer].leankor__GUID__c;    
                kbObject.Bottom = kanbanCards[kbPointer].leankor__Bottom__c;
                kbObject.CmpID = kanbanCards[kbPointer].leankor__CmpID__c;
                kbObject.CSSLayout = kanbanCards[kbPointer].leankor__CSSLayout__c;
                kbObject.JSONDefinition = kanbanCards[kbPointer].leankor__JSONDefinition__c;
                kbObject.JSONData = kanbanCards[kbPointer].leankor__JSONData__c;
                kbObject.ZoneID = kanbanCards[kbPointer].leankor__ZoneGUID__c;
                kbObject.ZoneForceID = kanbanCards[kbPointer].leankor__Zone__c;
                kbObject.MCForceID = kanbanCards[kbPointer].leankor__MasterContainer__c;
                kbObject.SWForceID = kanbanCards[kbPointer].leankor__Swimlane__c;
                kbObject.ValueStream = kanbanCards[kbPointer].leankor__ValueStream__c;
                kbObject.TemplateID = kanbanCards[kbPointer].leankor__kanbanCardTemplate__c;
                kbObject.Description = kanbanCards[kbPointer].leankor__DescriptionLong__c;
                kbObject.OwnerID = kanbanCards[kbPointer].OwnerId;
                kbObject.OwnerName = kanbanCards[kbPointer].Owner.Name; 
                kbObject.Name = kanbanCards[kbPointer].Name;
                kbObject.Color = kanbanCards[kbPointer].leankor__kanbanCardTemplate__r.leankor__Color__c;
                kbObject.OpportunityStage  = kanbanCards[kbPointer].leankor__Opportunity__r.StageName;
                kbObject.ValueStreamLinkID = kanbanCards[kbPointer].leankor__ValueStreamLink__c;
                kbObject.ValueStreamCardLink = kanbanCards[kbPointer].leankor__ValueStreamCardLink__c;
                kbObject.ValueStreamLinkBoardType = kanbanCards[kbPointer].leankor__ValueStreamLink__r.leankor__BoardType__c;
                kbObject.ValueStreamCardLinkName = kanbanCards[kbPointer].leankor__ValueStreamCardLink__r.Name ;
                kbObject.ValueStreamLinkIDName = kanbanCards[kbPointer].leankor__ValueStreamLink__r.Name;
                kbObject.Priority = Integer.valueof(kanbanCards[kbPointer].leankor__Priority__c);
                kbObject.DueDate = kanbanCards[kbPointer].leankor__DueDateTime__c; 
                kbObject.EstimatedDuration = kanbanCards[kbPointer].leankor__EstimatedDuration__c;
                kbObject.DurationUnits = kanbanCards[kbPointer].leankor__DurationUnits__c;
                kbObject.DateColor = kanbanCards[kbPointer].leankor__DateColor__c;
                kbObject.HarveyBall = string.valueof(kanbanCards[kbPointer].leankor__PercentComplete2__c);
                kbObject.Contact = kanbanCards[kbPointer].leankor__Contact__c;
                kbObject.ContactName = kanbanCards[kbPointer].leankor__Contact__r.Name;
                kbObject.Account = kanbanCards[kbPointer].leankor__Account__c;
                kbObject.AccountName = kanbanCards[kbPointer].leankor__Account__r.Name;
                kbObject.CaseID = kanbanCards[kbPointer].leankor__Case__c;
                kbObject.CaseSubject = kanbanCards[kbPointer].leankor__Case__r.Subject;
                kbObject.caseNumber2 = (kanbanCards[kbPointer].leankor__Case__r != null && kanbanCards[kbPointer].leankor__Case__r.CaseNumber != null) ? kanbanCards[kbPointer].leankor__Case__r.CaseNumber : null ; 
                kbObject.CaseStatus = kanbanCards[kbPointer].leankor__Case__r.Status;
                kbObject.CasePriority = kanbanCards[kbPointer].leankor__Case__r.Priority; 
                kbObject.Opportunity = kanbanCards[kbPointer].leankor__Opportunity__c;
                kbObject.Order = kanbanCards[kbPointer].leankor__Order__c;
                kbObject.OpportunityName = kanbanCards[kbPointer].leankor__Opportunity__r.Name;
                kbObject.OnBudget = kanbanCards[kbPointer].leankor__OnBudget__c;
                kbObject.OnQuality = kanbanCards[kbPointer].leankor__OnQuality__c;
                kbObject.OnTime = kanbanCards[kbPointer].leankor__OnTime__c;
                kbObject.isAtRisk = kanbanCards[kbPointer].leankor__IsAtRisk__c;
                kbObject.isOnHold = kanbanCards[kbPointer].leankor__IsOnHold__c;
                kbObject.EffortRemaining  = kanbanCards[kbPointer].leankor__EffortRemaining__c;
                kbObject.CreateDate = string.valueof(kanbanCards[kbPointer].CreatedDate);
                kbObject.LastModifiedDate = string.valueof(kanbanCards[kbPointer].LastModifiedDate);
                kbObject.StartDate = kanbanCards[kbPointer].leankor__StartDateTime__c;       
                kbObject.AcceptanceCriteria = kanbanCards[kbPointer].leankor__AcceptanceCriteria__c;
                kbObject.CardID = kanbanCards[kbPointer].leankor__CardID__c;     
                kbObject.IsSuccessorRecalculate = kanbanCards[kbPointer].leankor__IsSuccessorRecalculate__c;     
                kbObject.workOrderCount = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? fslDataInfo.get(kanbanCards[kbPointer].Id).workOrderCount : 0;
                kbObject.serviceAppointmentCount = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? ( fslDataInfo.get(kanbanCards[kbPointer].Id).serviceAppointmentCount!=null ? fslDataInfo.get(kanbanCards[kbPointer].Id).serviceAppointmentCount  : null ) : 0;
                kbObject.fslSchedStartDateTime = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? ( fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedStartDateTime!=null ? fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedStartDateTime : null ): null;
                kbObject.fslSchedDueDateTime = fslDataInfo.containsKey(kanbanCards[kbPointer].Id) ? ( fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedDueDateTime!=null ? fslDataInfo.get(kanbanCards[kbPointer].Id).fslSchedDueDateTime: null) : null;
                kbObject.Monday = kanbanCards[kbPointer].leankor__Monday__c;
                kbObject.Tuesday = kanbanCards[kbPointer].leankor__Tuesday__c;
                kbObject.Wednesday = kanbanCards[kbPointer].leankor__Wednesday__c;
                kbObject.Thursday = kanbanCards[kbPointer].leankor__Thursday__c;
                kbObject.Friday = kanbanCards[kbPointer].leankor__Friday__c;
                kbObject.Saturday = kanbanCards[kbPointer].leankor__Saturday__c;
                kbObject.Sunday = kanbanCards[kbPointer].leankor__Sunday__c;
                kbObject.weekCalendar = kanbanCards[kbPointer].leankor__weekCalendar__c;
                if(realTimeController.ALLOW_SCHEDULING_CONSTRAINTS){
                    kbObject.isConstraintRecalculate = kanbanCards[kbPointer].leankor__IsConstraintRecalculate__c;
                } 
                kanbanCardList.add(kbObject);
                kanbanCards.remove(kbPointer);
            }else {
                kbPointer++;
	        }
      }kanbanCards.clear();
        return kanbanCardList;
    }

    //06/12/2021 : Inner class for delete file data.
   public class DeleteFileWrapper{
        public String relatedRecordId;
        public String parentId;
    }

	public class KanbanCardRecord {
        public KanbanCard current = new KanbanCard();
        public KanbanCard next = new KanbanCard();
    }


    public class DaysBetweenDates {
        public Integer startDates = 0;
        public Integer dueDates = 0;
    }


    public class KanbanCardConstraint {
        public KanbanCardRecord kanbanCardRecord = new KanbanCardRecord();
        public ScheduleMode scheduleModeRecord = new ScheduleMode();
        public Boolean isEmpty() {
            return scheduleModeRecord.isEmpty();
        }
    }
    

    global class KanbanCardConstraintViolation {
        public KanbanCardRecord kanbanCardRecord = new KanbanCardRecord();
        public DaysBetweenDates daysBetweenDates = new DaysBetweenDates();
        public KanbanCardConstraint kanbanCardConstraint = new KanbanCardConstraint();
        public Boolean isEmpty() {
            return kanbanCardConstraint.isEmpty();
        }
    }


    public class KanbanCardLink {
        Map<Id, leankor__KanbanCard__c> kanbanCardRecords = new Map<Id, leankor__KanbanCard__c>();
        Map<Id, Map<Date, Integer>> startDates = new Map<Id, Map<Date, Integer>>();
        Map<Id, Map<Date, Integer>> dueDates = new Map<Id, Map<Date, Integer>>();
    }

	// validate input parameters
    @TestVisible
    private static Boolean isValidConstraintViolationRequest(KanbanCard kanbanCardRecord) {        
        Boolean isBlankKanbanCard = String.isBlank(kanbanCardRecord.id);
        Boolean isBlankKanbanCardLink = String.isBlank(kanbanCardRecord.valueStreamCardLink) 
                                        && String.isBlank(kanbanCardRecord.valueStreamLink);
        Boolean isValidValueStream = String.isNotBlank(kanbanCardRecord.valueStream)
                                        && Util.getSObjectName(kanbanCardRecord.valueStream) == 'leankor__ValueStream__c';
        Boolean isValidKanbanCard = !isBlankKanbanCard
                                        && Util.getSObjectName(kanbanCardRecord.id) == 'leankor__KanbanCard__c';
        Boolean isValidKanbanCardLink = !isBlankKanbanCardLink
                                        && Util.getSObjectName(kanbanCardRecord.valueStreamCardLink) == 'leankor__KanbanCard__c'
                                        && Util.getSObjectName(kanbanCardRecord.valueStreamLink) == 'leankor__ValueStream__c';

        return isValidValueStream
            && isBlankKanbanCard ? isValidKanbanCardLink : isValidKanbanCard
            && isBlankKanbanCardLink ? true : isValidKanbanCardLink
            && kanbanCardRecord.startDateTime != null
            && kanbanCardRecord.dueDateTime != null
            && kanbanCardRecord.dueDateTime.date() >= kanbanCardRecord.startDateTime.date();
    }

	// overloaded method with 2 different parameter types
    // validate constraint of KBC
    // returns a KanbanCardConstraint
    @TestVisible
    private static KanbanCardConstraint getKanbanCardConstraint(KanbanCardConstraint currentKanbanCardConstraint, KanbanCard nextKanbanCardRecord) {
        KanbanCardConstraint kanbanCardConstraint = new KanbanCardConstraint();
        
        if (currentKanbanCardConstraint.kanbanCardRecord.current.startDateTime.date() != nextKanbanCardRecord.startDateTime.date() 
        || currentKanbanCardConstraint.kanbanCardRecord.current.dueDateTime.date() != nextKanbanCardRecord.dueDateTime.date()) {            
            Boolean setConstraint = false;
             //default constraint type for empty constraint type or empty constraint date
         /*   String constraintType = (String.isBlank(currentKanbanCardConstraint.scheduleModeRecord.constraintType) 
                || currentKanbanCardConstraint.scheduleModeRecord.constraintDateTime == null)
                    ? (currentKanbanCardConstraint.kanbanCardRecord.current.isScheduleBackward 
                        ? 'aslateaspossible' 
                        : 'assoonaspossible')
                    : currentKanbanCardConstraint.scheduleModeRecord.constraintType;*/

            String constraintType = currentKanbanCardConstraint.scheduleModeRecord.constraintType;
            switch on constraintType {
                when 'startnoearlierthan' {
                    if(currentKanbanCardConstraint.kanbanCardRecord.current.isScheduleBackward || (isCalledFromMultipleAPI == true)){
                        //10/may/2023 :We haved OR condition because ob KB/QuickAction if we changes SD then DD was automatically changes, so in this case constraint should be violate.
                        setConstraint = nextKanbanCardRecord.startDateTime.date() < currentKanbanCardConstraint.scheduleModeRecord.constraintDateTime.date()
                        && (nextKanbanCardRecord.dueDateTime.date() == currentKanbanCardConstraint.kanbanCardRecord.current.dueDateTime.date()
                        || nextKanbanCardRecord.dueDateTime.date() < currentKanbanCardConstraint.kanbanCardRecord.current.dueDateTime.date());
                    }
                }
                when 'startnolaterthan' {
                    setConstraint = nextKanbanCardRecord.startDateTime.date() > currentKanbanCardConstraint.scheduleModeRecord.constraintDateTime.date();                   
                }
                when 'muststarton' {
                    setConstraint = nextKanbanCardRecord.startDateTime.date() != currentKanbanCardConstraint.scheduleModeRecord.constraintDateTime.date();
                }
                when 'mustfinishon' {
                    setConstraint = nextKanbanCardRecord.dueDateTime.date() != currentKanbanCardConstraint.scheduleModeRecord.constraintDateTime.date();
                }
                when 'finishnoearlierthan' {
                    //constraint has to use the UI if current start date is not the same as next start date and current end date is not the same as next end date,
                    //UI automatically changes it to startnoearlierthan (in forward planning) or finishnolaterthan (in backward planning)
                    setConstraint = (nextKanbanCardRecord.startDateTime.date() != currentKanbanCardConstraint.kanbanCardRecord.current.startDateTime.date()
                        && nextKanbanCardRecord.dueDateTime.date() != currentKanbanCardConstraint.kanbanCardRecord.current.dueDateTime.date())
                        || nextKanbanCardRecord.dueDateTime.date() < currentKanbanCardConstraint.scheduleModeRecord.constraintDateTime.date();
                }
                when 'finishnolaterthan' {
                    if(!currentKanbanCardConstraint.kanbanCardRecord.current.isScheduleBackward || (isCalledFromMultipleAPI == true)){
                        setConstraint = nextKanbanCardRecord.dueDateTime.date() > currentKanbanCardConstraint.scheduleModeRecord.constraintDateTime.date();
                    }
                }
                when 'assoonaspossible' {
                    //constraint has to use the UI if current start date is not the same as next start date and current end date is not the same as next end date, 
                    //UI automatically changes it to startnoearlierthan (in forward planning) or finishnolaterthan (in backward planning)
                    setConstraint = nextKanbanCardRecord.startDateTime.date() != currentKanbanCardConstraint.kanbanCardRecord.current.startDateTime.date()
                        || nextKanbanCardRecord.dueDateTime.date() != currentKanbanCardConstraint.kanbanCardRecord.current.dueDateTime.date();
                }
                when 'aslateaspossible' {
                    //constraint has to use the UI if current start date is not the same as next start date and current end date is not the same as next end date, 
                    //UI automatically changes it to startnoearlierthan (in forward planning) or finishnolaterthan (in backward planning)
                    setConstraint = nextKanbanCardRecord.startDateTime.date() != currentKanbanCardConstraint.kanbanCardRecord.current.startDateTime.date()
                        || nextKanbanCardRecord.dueDateTime.date() != currentKanbanCardConstraint.kanbanCardRecord.current.dueDateTime.date();
                }
            }
            if (setConstraint) {
                kanbanCardConstraint = currentKanbanCardConstraint;
            }
        }

        return kanbanCardConstraint;
    }

	// overloaded method with 6 parameters, this is called inside a loop so do not perform SOQL or DML
    // gets the nearest constraint violation by traversing successors of the KanbanCard record being scheduled
    // currentKanbanCardConstraint - KanbanCard constraint record
    // nextKanbanCardRecord - adjusted schedule of KanbanCard record
    // daysBetweenDates - contains number of days between dates, between current and next records
    // predecessorSuccessors - successors of KanbanCard record
    // successorPredecessors - predecessors of KanbanCard record
    // successorScheduleModes - schedule modes of all successors of KanbanCard record
    // returns a KanbanCardConstraint
    @TestVisible
    private static KanbanCardConstraint getKanbanCardConstraint(KanbanCardConstraint currentKanbanCardConstraint, KanbanCard nextKanbanCardRecord, DaysBetweenDates daysBetweenDates, Map<Id, List<leankor__Dependency__c>> predecessorSuccessors, Map<Id, List<leankor__Dependency__c>> successorPredecessors, Map<Id, leankor__ScheduleMode__c> successorScheduleModes) {
        KanbanCardConstraint kanbanCardConstraint = new KanbanCardConstraint();
       // if KanbanCard has successors, then check for constraint violation
        if (String.isNotBlank(nextKanbanCardRecord.id) 
        && predecessorSuccessors.containsKey(nextKanbanCardRecord.id)) {        
            // traverse dependencies of the KanbanCard to check for constraint violation
            List<leankor__Dependency__c> kanbanCardDependencies = predecessorSuccessors.get(nextKanbanCardRecord.id);

            for (leankor__Dependency__c kanbanCardDependency : kanbanCardDependencies) {
                if (Dependency.DEPENDENCYTYPES.contains(kanbanCardDependency.leankor__SuccessorType__c) 
                && successorScheduleModes.containsKey(kanbanCardDependency.leankor__Successor__c)) {
                    KanbanCard nextKanbanCardSchedule = getNextKanbanCardSchedule(kanbanCardDependency.leankor__Successor__r, daysBetweenDates, kanbanCardDependency, successorPredecessors);
                    leankor__ScheduleMode__c scheduleMode = successorScheduleModes.get(kanbanCardDependency.leankor__Successor__c);
                    KanbanCardConstraint successorKanbanCardConstraint = new KanbanCardConstraint();

                    setKanbanCardConstraint(successorKanbanCardConstraint, kanbanCardDependency.leankor__Successor__r, nextKanbanCardSchedule, scheduleMode);

                    // get constraint violation of the dependent KBC record
                    kanbanCardConstraint = getKanbanCardConstraint(successorKanbanCardConstraint, nextKanbanCardSchedule);

                    // recursively check for constraint violation
                    if (kanbanCardConstraint.isEmpty()) {
                        kanbanCardConstraint = getKanbanCardConstraint(successorKanbanCardConstraint, nextKanbanCardSchedule, daysBetweenDates, predecessorSuccessors, successorPredecessors, successorScheduleModes);
                    } else {
                        break;
                    }
                }
            }
        }        
        
        return kanbanCardConstraint;
    }

	 // translate the schedule
    /*
    Dependency Translations

    1. Finish To Start
    if successor is not "Manually Scheduled"
        moving the predecessor will move the start date of the successor to the end date (plus lead/lag) of the predecessor
    endif
    
    2. Start To Finish
    if successor is not "Manually Scheduled"
        moving the predecessor will move the end date of the successor to start date (plus lead/lag) of the predecessor
    endif
    
    3. Start To Start
    if successor is not "Manually Scheduled"
        moving the predecessor will move the start date of the successor to the start date (plus lead/lag) of the predecessor
    endif
    
    4.Finish To Finish
    if successor is not "Manually Scheduled"
        moving the predecessor will move the end date of the successor to the end date (plus lead/lag) of the predecessor
    endif
    */
    @TestVisible
    private static KanbanCard getNextKanbanCardSchedule(leankor__KanbanCard__c currentKanbanCardSchedule, DaysBetweenDates daysBetweenDates, leankor__Dependency__c dependency, Map<Id, List<leankor__Dependency__c>> successorPredecessors) {
        KanbanCard nextKanbanCardSchedule = new KanbanCard();
        nextKanbanCardSchedule.id = currentKanbanCardSchedule.Id;
        nextKanbanCardSchedule.name = currentKanbanCardSchedule.Name;

        switch on dependency.leankor__SuccessorType__c {
            when 'Finish To Start' {
                /*
                if (daysBetweenDates.startDates < 0 || daysBetweenDates.dueDates < 0) {
                    if (successorPredecessors.containsKey(currentKanbanCardSchedule.id)) {
                        leankor__Dependency__c predecessor = getNearestPredecessor(successorPredecessors.get(currentKanbanCardSchedule.id));
                        if (predecessor != null) {
                            // TBD
                        }
                    }
                }
                */

                nextKanbanCardSchedule.startDateTime = currentKanbanCardSchedule.leankor__StartDateTime__c.addDays(daysBetweenDates.startDates); // TBD: factor in calculation for 5-day work week, blackout days, and lag/lead
                nextKanbanCardSchedule.dueDateTime = currentKanbanCardSchedule.leankor__DueDateTime__c.addDays(daysBetweenDates.startDates); // TBD: factor in calculation for 5-day work week, blackout days, and lag/lead        
            }
            when 'Start To Finish' {
            }
            when 'Start To Start' {
            }
            when 'Finish To Finish' {
            }
        }

        return nextKanbanCardSchedule;
    }

	@TestVisible
    private static void setKanbanCardRecord(KanbanCardRecord kanbanCardRecord, leankor__KanbanCard__c currentKanbanCard, KanbanCard nextKanbanCard) {
        kanbanCardRecord.current.id = currentKanbanCard.Id;
        kanbanCardRecord.current.name = currentKanbanCard.Name;
        kanbanCardRecord.current.startDateTime = currentKanbanCard.leankor__StartDateTime__c;
        kanbanCardRecord.current.dueDateTime = currentKanbanCard.leankor__DueDateTime__c;
        kanbanCardRecord.current.isScheduleBackward = currentKanbanCard.leankor__ValueStream__r.leankor__ScheduleBackward__c;
        kanbanCardRecord.current.boardType = currentKanbanCard.leankor__ValueStream__r.leankor__BoardType__c;
        kanbanCardRecord.current.boardName =currentKanbanCard.leankor__ValueStream__r.Name;
        kanbanCardRecord.current.itemType = currentKanbanCard.RecordType.Name;
        kanbanCardRecord.current.projectID= currentKanbanCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
        kanbanCardRecord.current.valueStream= currentKanbanCard.leankor__ValueStream__c;
        kanbanCardRecord.next.id = nextKanbanCard.id;
        kanbanCardRecord.next.name = nextKanbanCard.Name;
        kanbanCardRecord.next.startDateTime = nextKanbanCard.startDateTime;
        kanbanCardRecord.next.dueDateTime = nextKanbanCard.dueDateTime;
        kanbanCardRecord.next.itemType = nextKanbanCard.itemType;
        kanbanCardRecord.next.projectID = nextKanbanCard.projectID;
        kanbanCardRecord.next.valueStream= nextKanbanCard.valueStream;
    }

	 // store values of days in-between old and new which will be used to calculate the new schedule
    // TBD: to skip blackout dates and weekends in case of a 5-day work week
    @TestVisible
    private static void setDaysBetweenDates(DaysBetweenDates daysBetweenDates, leankor__KanbanCard__c currentKanbanCard, KanbanCard nextKanbanCardRecord) {
        daysBetweenDates.startDates = currentKanbanCard.leankor__StartDateTime__c.Date().daysBetween(nextKanbanCardRecord.startDateTime.Date());
        daysBetweenDates.dueDates = currentKanbanCard.leankor__DueDateTime__c.Date().daysBetween(nextKanbanCardRecord.dueDateTime.Date());
    }


    @TestVisible
    private static void setScheduleModeRecord(ScheduleMode scheduleModeRecord, leankor__ScheduleMode__c scheduleMode) {
        scheduleModeRecord.id = scheduleMode.Id;
        scheduleModeRecord.constraintType = scheduleMode.leankor__ScheduleConstraint__r.Type__c;
        scheduleModeRecord.constraintDescription = scheduleMode.leankor__ScheduleConstraint__r.leankor__Description__c;
        scheduleModeRecord.constraintDateTime = scheduleMode.leankor__ConstraintDateTime__c;
        scheduleModeRecord.manuallyScheduled = scheduleMode.leankor__ManuallyScheduled__c;
    }


    @TestVisible
    private static void setKanbanCardConstraint(KanbanCardConstraint kanbanCardConstraint, leankor__KanbanCard__c currentKanbanCard, KanbanCard nextKanbanCard, leankor__ScheduleMode__c scheduleMode) {
        setKanbanCardRecord(kanbanCardConstraint.kanbanCardRecord, currentKanbanCard, nextKanbanCard);
        setScheduleModeRecord(kanbanCardConstraint.scheduleModeRecord, scheduleMode);
    }

	// create a map of schedule modes
    @TestVisible
    private static Map<Id, leankor__ScheduleMode__c> getScheduleModeCards(Set<Id> kanbanCardIds) {
        Map<Id, leankor__ScheduleMode__c> scheduleModeCards = new Map<Id, leankor__ScheduleMode__c>();
        for (leankor__ScheduleMode__c scheduleMode : ScheduleMode.readScheduleModes(kanbanCardIds)) {
            // only add the latest ScheduleMode record into the map
            // this is a workaround to the ScheduleMode having multiple records --- bug! 
            if (scheduleModeCards.containsKey(scheduleMode.leankor__KanbanCard__c) ? scheduleModeCards.get(scheduleMode.leankor__KanbanCard__c).CreatedDate < scheduleMode.CreatedDate : true) {
                scheduleModeCards.put(scheduleMode.leankor__KanbanCard__c, scheduleMode);
            }
        }
        
        return scheduleModeCards;
    }

	 // create a set of dependent cards
    @TestVisible
    private static Set<Id> getDependentCardIds(List<leankor__Dependency__c> dependencies) {
        Set<Id> dependentCardIds = new Set<Id>();   

        for (leankor__Dependency__c dependency : dependencies) {
            dependentCardIds.add(dependency.leankor__Successor__c);    
        }

        return dependentCardIds;
    }

	// nextKanbanCardRecords = list of KanbanCard
    // checkDependencyConstraint = true to validate constraints of successors, otherwise false
    // returns the KBC that causes the constraint violation
    // TEST CASES:
        // case 1: updating a work item's schedule, KanbanCard
        //          id != null, valueStreamLink = null, valueStreamCardLink = null, isUpdateValueStreamCardLink = false
        // case 2: updating a work item's schedule and changing linked worked item at the same time, KanbanCard
        //          id != null, valueStreamLink != null, valueStreamCardLink != null, isUpdateValueStreamCardLink = true
        // case 3: updating a work item's schedule and removing linked worked item at the same time, KanbanCard
        //          id != null, valueStreamLink = null, valueStreamCardLink = null, isUpdateValueStreamCardLink = true
        // case 4: creating a new work item and linking at the same time, KanbanCard
        //          id = null, valueStreamLink != null, valueStreamCardLink != null, isUpdateValueStreamCardLink = true
    @RemoteAction
    global static KanbanCardConstraintViolation getConstraintViolation(List<KanbanCard> nextKanbanCardRecords, Boolean checkDependencyConstraint) {
        KanbanCardConstraintViolation kanbanCardConstraintViolation = new KanbanCardConstraintViolation();
        Set<Id> setOfValueStreamIds = new Set<Id>();
        Set<Id> setOfNextKanbanCardRecords = new Set<Id>();
        Set<Id> setOfNextKanbanCardLinkRecords = new Set<Id>();
        Set<String> setOfRecordTypeNames = new Set<String>{'ActivityCard', 'MileStoneCard'};
        List<KanbanCard> kanbanCardLinkRecords = new List<KanbanCard>();

        for (KanbanCard nextKanbanCardRecord : nextKanbanCardRecords) {
            if (isValidConstraintViolationRequest(nextKanbanCardRecord)) {
                setOfValueStreamIds.add(nextKanbanCardRecord.valueStream);
                setOfNextKanbanCardRecords.add(nextKanbanCardRecord.id);
                // nextKanbanCardRecord.isUpdateValueStreamCardLink flag to signal the change of ValueStreamCardLink (create and link, change link, remove link)
                // store data for validating constraints of parent work item
                if (nextKanbanCardRecord.isUpdateValueStreamCardLink
                && String.isNotBlank(nextKanbanCardRecord.valueStreamLink)        
                && String.isNotBlank(nextKanbanCardRecord.valueStreamCardLink)) {
                    setKanbanCardLinkRecords(
                        kanbanCardLinkRecords,
                        nextKanbanCardRecord.valueStream,
                        nextKanbanCardRecord.valueStreamLink,
                        nextKanbanCardRecord.valueStreamCardLink,
                        nextKanbanCardRecord.startDateTime,
                        nextKanbanCardRecord.dueDateTime);
                    setOfValueStreamIds.add(nextKanbanCardRecord.valueStreamLink);

                    // store work item that needs to change its parent work item
                    //setOfNextKanbanCardLinkRecords.add(nextKanbanCardRecord.id);
                    setOfNextKanbanCardLinkRecords.add(nextKanbanCardRecord.valueStreamCardLink);
                }
            } else {
                System.debug('Error: InvalidParameterValueException returned from KanbanController.getConstraintViolation(' + nextKanbanCardRecord + ').');                
                throw new Util.LeanException('Error: InvalidParameterValueException returned from KanbanController.getConstraintViolation(' + nextKanbanCardRecord + ').');    
            }
        }

        // remove null element
        setOfNextKanbanCardRecords.remove(null);
        setOfNextKanbanCardLinkRecords.remove(null);

        if (setOfNextKanbanCardRecords.isEmpty() && setOfNextKanbanCardLinkRecords.isEmpty()) {
            System.debug('Error: InvalidParameterValueException returned from KanbanController.getConstraintViolation(' + nextKanbanCardRecords + ').');
            throw new Util.LeanException('Error: NoDataFoundException returned from KanbanController.getConstraintViolation(' + nextKanbanCardRecords + ').');
        } else {
            //List<leankor__KanbanCard__c> currentKanbanCards = KanbanCard.readKanbanCards(setOfNextKanbanCardRecords, setOfRecordTypeNames);
            List<leankor__KanbanCard__c> currentKanbanCards = setOfNextKanbanCardRecords.isEmpty() 
                                                            ? new List<leankor__KanbanCard__c>()
                                                            : KanbanCard.readKanbanCards(setOfNextKanbanCardRecords, setOfRecordTypeNames);
            
            // updating a work item's schedule but not changing its parent work item (linked)
            // store data for validating constraints of parent work item (linked)
            for (leankor__KanbanCard__c currentKanbanCard : currentKanbanCards) {
                setOfValueStreamIds.add(currentKanbanCard.leankor__ValueStream__c);
                // store data only if it does not exist in setOfNextKanbanCardLinkRecords
                if (String.isNotBlank(currentKanbanCard.leankor__ValueStreamLink__c)
                && String.isNotBlank(currentKanbanCard.leankor__ValueStreamCardLink__c)
                && !setOfNextKanbanCardLinkRecords.contains(currentKanbanCard.Id)) {
                    setKanbanCardLinkRecords(
                        kanbanCardLinkRecords,
                        currentKanbanCard.leankor__ValueStream__c,
                        currentKanbanCard.leankor__ValueStreamLink__c,
                        currentKanbanCard.leankor__ValueStreamCardLink__c,
                        currentKanbanCard.leankor__StartDateTime__c,
                        currentKanbanCard.leankor__DueDateTime__c);
                    setOfValueStreamIds.add(currentKanbanCard.leankor__ValueStreamLink__c);
                }
            }

            if (currentKanbanCards.isEmpty() && setOfNextKanbanCardLinkRecords.isEmpty()) {
                System.debug('Error: NoDataFoundException returned from KanbanController.getConstraintViolation(' + nextKanbanCardRecords + ').');
                throw new Util.LeanException('Error: NoDataFoundException returned from KanbanController.getConstraintViolation(' + nextKanbanCardRecords + ').');
            } else {
                // linked cards
                KanbanCardLink kanbanCardLink = new KanbanCardLink();
                setKanbanCardLink(kanbanCardLink, kanbanCardLinkRecords, setOfRecordTypeNames);

                // there is no need to validate constraints of successors if checkDependencyConstraint = false
                //Boolean checkDependencyConstraint = false; // TBD: value will be taken from either Custom Settings or Custom Metadata Type
                List<leankor__Dependency__c> dependencies = (checkDependencyConstraint == null ? false : checkDependencyConstraint) 
                                                        ? Dependency.readDependency(setOfValueStreamIds) 
                                                        : new List<leankor__Dependency__c>();

                kanbanCardConstraintViolation = getKanbanCardConstraintViolation(new Map<Id, leankor__KanbanCard__c>(currentKanbanCards), nextKanbanCardRecords, dependencies, kanbanCardLink);
            }
        }
        return kanbanCardConstraintViolation;
    }

	// store data for validating constraints of parent work item (linked)
    // kanbanCardLinkRecords is pass by reference
    private static void setKanbanCardLinkRecords(List<KanbanCard> kanbanCardLinkRecords, Id valueStream, Id valueStreamLink, Id valueStreamCardLink, Datetime startDateTime, Datetime dueDateTime) {
        KanbanCard kanbanCardLinkRecord = new KanbanCard();
        kanbanCardLinkRecord.valueStream = valueStream;
        kanbanCardLinkRecord.valueStreamLink = valueStreamLink;
        kanbanCardLinkRecord.valueStreamCardLink = valueStreamCardLink;
        kanbanCardLinkRecord.startDateTime = startDateTime;
        kanbanCardLinkRecord.dueDateTime = dueDateTime;
        kanbanCardLinkRecords.add(kanbanCardLinkRecord);
    }

	 // overloaded method with 3 different parameter types, don't call this inside a loop as it has SOQLs
    // returns a list of ChoiceConstraintViolation
    @TestVisible
    private static KanbanCardConstraintViolation getKanbanCardConstraintViolation(Map<Id, leankor__KanbanCard__c> currentKanbanCardRecords, List<KanbanCard> nextKanbanCardRecords, List<leankor__Dependency__c> dependencies, KanbanCardLink kanbanCardLink) {
        KanbanCardConstraintViolation kanbanCardConstraintViolation = new KanbanCardConstraintViolation();        
        Set<Id> successorIds = new Set<Id>();
        Map<Id, List<leankor__Dependency__c>> successorPredecessors = new Map<Id, List<leankor__Dependency__c>>();
        Map<Id, List<leankor__Dependency__c>> predecessorSuccessors = new Map<Id, List<leankor__Dependency__c>>();
        Map<Id, leankor__ScheduleMode__c> successorScheduleModes = new Map<Id, leankor__ScheduleMode__c>();

        if (!dependencies.isEmpty()) {        
            // map of successor's predecessors --> key is successor, value is list of predecessors
            successorPredecessors = Dependency.getSuccessorDependencyMap(dependencies);

            // map of predecessor's successors --> key is predecessor, value is list of successors
            predecessorSuccessors = Dependency.getPredecessorDependencyMap(dependencies);
            
            for (List<leankor__Dependency__c> dependency : predecessorSuccessors.values()) {
                successorIds.addAll(getDependentCardIds(dependency));
            }

            successorScheduleModes = getScheduleModeCards(successorIds);
        }

        for (KanbanCard nextKanbanCardRecord : nextKanbanCardRecords) {
            if (kanbanCardConstraintViolation.isEmpty()) {
                if (String.isBlank(nextKanbanCardRecord.Id)) { // create new work item and link at the same time
                    if (nextKanbanCardRecord.isUpdateValueStreamCardLink
                    && String.isNotBlank(nextKanbanCardRecord.valueStreamLink)
                    && String.isNotBlank(nextKanbanCardRecord.valueStreamCardLink)) {
                        // case 4: creating a new work item and linking at the same time
                        //          id = null, valueStreamLink != null, valueStreamCardLink != null, isUpdateValueStreamCardLink = true
                        setKanbanCardConstraintViolation(kanbanCardConstraintViolation, nextKanbanCardRecord, kanbanCardLink, nextKanbanCardRecord.valueStreamCardLink);
                    }
                } else {
                    leankor__KanbanCard__c currentKanbanCardRecord = currentKanbanCardRecords.get(nextKanbanCardRecord.Id);
                    if (currentKanbanCardRecord != null) {        
                        setKanbanCardRecord(kanbanCardConstraintViolation.kanbanCardRecord, currentKanbanCardRecord, nextKanbanCardRecord);
                        setDaysBetweenDates(kanbanCardConstraintViolation.daysBetweenDates, currentKanbanCardRecord, nextKanbanCardRecord);
                        // case 1: updating a work item's schedule
                        //          id != null, valueStreamLink = null, valueStreamCardLink = null, isUpdateValueStreamCardLink = false
                        setKanbanCardConstraintViolation(kanbanCardConstraintViolation, currentKanbanCardRecord, nextKanbanCardRecord);
                        
                        if (kanbanCardConstraintViolation.isEmpty()) {
                            // case 2: updating a work item's schedule and changing linked worked item at the same time
                            //          id != null, valueStreamLink != null, valueStreamCardLink != null, isUpdateValueStreamCardLink = true                                
                            // case 3: updating a work item's schedule and removing linked worked item at the same time
                            //          id != null, valueStreamLink = null, valueStreamCardLink = null, isUpdateValueStreamCardLink = true

                            // no need to validate if link is being removed (nextKanbanCardRecord.valueStreamCardLink is blank)
                            
                            Id valueStreamCardLinkId = nextKanbanCardRecord.isUpdateValueStreamCardLink &&  (String.isNotBlank(nextKanbanCardRecord.valueStreamCardLink) ? (kanbanCardLink.kanbanCardRecords.get(nextKanbanCardRecord.valueStreamCardLink).leankor__ValueStream__r.leankor__ProjectRoom__c == currentKanbanCardRecord.leankor__ValueStream__r.leankor__ProjectRoom__c) : false)
                                                        ? nextKanbanCardRecord.valueStreamCardLink
                                                        : currentKanbanCardRecord.leankor__ValueStreamCardLink__c;

                            String teampBoardType = nextKanbanCardRecord.isUpdateValueStreamCardLink
                                                        ? (String.isNotBlank(nextKanbanCardRecord.valueStreamCardLink) ? kanbanCardLink.kanbanCardRecords.get(nextKanbanCardRecord.valueStreamCardLink).leankor__ValueStream__r.leankor__BoardType__c : '')
                                                        : (String.isNotBlank(currentKanbanCardRecord.leankor__ValueStreamCardLink__c) && !nextKanbanCardRecord.notCheckConstraintOnParent ? (kanbanCardLink.kanbanCardRecords.get(currentKanbanCardRecord.leankor__ValueStreamCardLink__c) != null ? kanbanCardLink.kanbanCardRecords.get(currentKanbanCardRecord.leankor__ValueStreamCardLink__c).leankor__ValueStream__r.leankor__BoardType__c : '') : '');
                         if (String.isNotBlank(valueStreamCardLinkId) && (teampBoardType == 'UberBoard' || teampBoardType == 'Plan Board')) {
                                // validate constraint of the parent KBC (linked)
                                setKanbanCardConstraintViolation(kanbanCardConstraintViolation, nextKanbanCardRecord, kanbanCardLink, valueStreamCardLinkId);   
                            }
                            
                        }
                        // 3. if current KBC record has no constraint but has successors then continue to validate constraints of these successors 
                        if (kanbanCardConstraintViolation.isEmpty() 
                        && !currentKanbanCardRecord.leankor__PredecessorDependencies__r.isEmpty()) {
                            // validate constraints of all successors, to check if there is any violation
                            KanbanCardConstraint currentKanbanCardConstraint = new KanbanCardConstraint();
                            setKanbanCardConstraint(currentKanbanCardConstraint, currentKanbanCardRecord, nextKanbanCardRecord, currentKanbanCardRecord.leankor__ScheduleModes__r[0]);

                            // validate constraint of the current KBC record
                            kanbanCardConstraintViolation.kanbanCardConstraint = getKanbanCardConstraint(currentKanbanCardConstraint, nextKanbanCardRecord, kanbanCardConstraintViolation.daysBetweenDates, predecessorSuccessors, successorPredecessors, successorScheduleModes);
                        }
                    }
                }
            } else {
                break;
            }
        }

        return kanbanCardConstraintViolation;     
    }
    private static void setKanbanCardConstraintViolation(KanbanCardConstraintViolation kanbanCardConstraintViolation, leankor__KanbanCard__c currentKanbanCardRecord, KanbanCard nextKanbanCardRecord, Map<Id, List<leankor__Dependency__c>> predecessorSuccessors, Map<Id, List<leankor__Dependency__c>> successorPredecessors, Map<Id, leankor__ScheduleMode__c> successorScheduleModes) {
        // validate constraints of all successors, to check if there is any violation
        KanbanCardConstraint currentKanbanCardConstraint = new KanbanCardConstraint();
        setKanbanCardConstraint(currentKanbanCardConstraint, currentKanbanCardRecord, nextKanbanCardRecord, currentKanbanCardRecord.leankor__ScheduleModes__r[0]);

        // validate constraint of the current KBC record
        kanbanCardConstraintViolation.kanbanCardConstraint = getKanbanCardConstraint(currentKanbanCardConstraint, nextKanbanCardRecord, kanbanCardConstraintViolation.daysBetweenDates, predecessorSuccessors, successorPredecessors, successorScheduleModes);
    }

    private static void setKanbanCardConstraintViolation(KanbanCardConstraintViolation kanbanCardConstraintViolation, leankor__KanbanCard__c currentKanbanCardRecord, KanbanCard nextKanbanCardRecord) {
        // validate constraint of the current KBC record
        if (kanbanCardConstraintViolation.daysBetweenDates.startDates != 0 
        || kanbanCardConstraintViolation.daysBetweenDates.dueDates != 0) {
            // validate constraint of the current KBC 
            if (!currentKanbanCardRecord.leankor__ScheduleModes__r.isEmpty()) {
                KanbanCardConstraint currentKanbanCardConstraint = new KanbanCardConstraint();
                setKanbanCardConstraint(currentKanbanCardConstraint, currentKanbanCardRecord, nextKanbanCardRecord, currentKanbanCardRecord.leankor__ScheduleModes__r[0]);
                // get constraint violation of the current KBC record
                kanbanCardConstraintViolation.kanbanCardConstraint = getKanbanCardConstraint(currentKanbanCardConstraint, nextKanbanCardRecord);
            }
        }
    }
    private static void setKanbanCardConstraintViolation(KanbanCardConstraintViolation kanbanCardConstraintViolation, KanbanCard nextKanbanCardRecord, KanbanCardLink kanbanCardLink, Id valueStreamCardLinkId) {
        leankor__KanbanCard__c currentKanbanCardLinkParentRecord = kanbanCardLink.kanbanCardRecords.get(valueStreamCardLinkId);
        if (currentKanbanCardLinkParentRecord != null
        && !currentKanbanCardLinkParentRecord.leankor__ScheduleModes__r.isEmpty()) {
            KanbanCard nextKanbanCardLinkParentRecord =  new KanbanCard(); // this is the parent KBC
            // set startDateTime of nextKanbanCardLinkParentRecord
            Date currentKanbanCardLinkParentRecordStartDate = currentKanbanCardLinkParentRecord.leankor__StartDateTime__c.Date();
            if (nextKanbanCardRecord.startDateTime.Date() > currentKanbanCardLinkParentRecordStartDate) {
                Map<Date, Integer> mapGetStartDates = kanbanCardLink.startDates.get(valueStreamCardLinkId);
                nextKanbanCardLinkParentRecord.startDateTime = mapGetStartDates == null 
                                                                ? nextKanbanCardRecord.startDateTime 
                                                                : (mapGetStartDates.get(currentKanbanCardLinkParentRecordStartDate) > 1 
                                                                    ? currentKanbanCardLinkParentRecord.leankor__StartDateTime__c 
                                                                    : nextKanbanCardRecord.startDateTime);
            } else {
                nextKanbanCardLinkParentRecord.startDateTime = nextKanbanCardRecord.startDateTime;
            }

            // set dueDateTime of nextKanbanCardLinkParentRecord
            Date currentKanbanCardLinkParentRecordDueDate = currentKanbanCardLinkParentRecord.leankor__DueDateTime__c.Date();
            if (nextKanbanCardRecord.dueDateTime.Date() < currentKanbanCardLinkParentRecordDueDate) {
                Map<Date, Integer> mapGetDueDates = kanbanCardLink.dueDates.get(valueStreamCardLinkId);
                nextKanbanCardLinkParentRecord.dueDateTime = mapGetDueDates == null 
                                                            ? nextKanbanCardRecord.dueDateTime 
                                                            : (mapGetDueDates.get(currentKanbanCardLinkParentRecordDueDate) > 1 
                                                                ? currentKanbanCardLinkParentRecord.leankor__DueDateTime__c 
                                                                : nextKanbanCardRecord.dueDateTime);
            } else {
                nextKanbanCardLinkParentRecord.dueDateTime = nextKanbanCardRecord.dueDateTime;
            }

            if (nextKanbanCardLinkParentRecord.startDateTime != currentKanbanCardLinkParentRecord.leankor__StartDateTime__c
            || nextKanbanCardLinkParentRecord.dueDateTime != currentKanbanCardLinkParentRecord.leankor__DueDateTime__c) {
                KanbanCardConstraint currentKanbanCardConstraint = new KanbanCardConstraint();
                setKanbanCardConstraint(currentKanbanCardConstraint, currentKanbanCardLinkParentRecord, nextKanbanCardLinkParentRecord, currentKanbanCardLinkParentRecord.leankor__ScheduleModes__r[0]);
                // get constraint violation of the current KBC record
                kanbanCardConstraintViolation.kanbanCardConstraint = getKanbanCardConstraint(currentKanbanCardConstraint, nextKanbanCardLinkParentRecord);
            }                        
        }
    }


    // pass by reference kanbanCardLink
    @TestVisible
    private static void setKanbanCardLink(KanbanCardLink kanbanCardLink, List<KanbanCard> kanbanCards, Set<String> setOfRecordTypeNames) {
        Set<Id> setOfKanbanCardLinkIds = new Set<Id>();
        for (KanbanCard kanbanCard : kanbanCards) {
            setOfKanbanCardLinkIds.add(kanbanCard.valueStreamCardLink);

            Map<Date, Integer> mapPutStartDates = new Map<Date, Integer>();
            Map<Date, Integer> mapGetStartDates = kanbanCardLink.startDates.get(kanbanCard.valueStreamCardLink);
            setKanbanCardLinkDates(mapPutStartDates, mapGetStartDates, kanbanCard.startDateTime.Date());
            kanbanCardLink.startDates.put(kanbanCard.valueStreamCardLink, mapPutStartDates); 
        
            Map<Date, Integer> mapPutDueDates = new Map<Date, Integer>();
            Map<Date, Integer> mapGetDueDates = kanbanCardLink.dueDates.get(kanbanCard.valueStreamCardLink);
            setKanbanCardLinkDates(mapPutDueDates, mapGetDueDates, kanbanCard.dueDateTime.Date());
            kanbanCardLink.dueDates.put(kanbanCard.valueStreamCardLink, mapPutDueDates);
        }
        KanbanCardLink.kanbanCardRecords = setOfKanbanCardLinkIds.isEmpty() 
                                            ? new Map<Id, leankor__KanbanCard__c>() 
                                            : new Map<Id, leankor__KanbanCard__c>(KanbanCard.readKanbanCards(setOfKanbanCardLinkIds, setOfRecordTypeNames));
    }


    // count records of linked cards group by date and store into a map
    // pass by reference mapPutKanbanCardDates and mapGetKanbanCardDates
    @TestVisible
    private static void setKanbanCardLinkDates(Map<Date, Integer> mapPutKanbanCardDates, Map<Date, Integer> mapGetKanbanCardDates, Date kanbanCardDate) {
        Integer recordCount = 0;
        Integer currentCount = 0;
        
        if (mapGetKanbanCardDates != null) {
            mapPutKanbanCardDates.putAll(mapGetKanbanCardDates);
            currentCount = mapGetKanbanCardDates.get(kanbanCardDate);
            recordCount = currentCount == null ? 0 : currentCount;
        }
        
        mapPutKanbanCardDates.put(kanbanCardDate, recordCount + 1);       
    }    
    //-------------- end constraints -------------------------//

    // We will save all required Fieldsets and their Fields data in this inner class, which we use in the clone functionality.
    public class FieldSetRecord {
        public Set<String> allFields;
        public String allFieldsInStringFormat;
        public Map<String, Set<String>> fieldSetAndFields;
    }

    /*------------------------------------------------------------------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The Field Which Present inside FieldSet 
	    Inputs:         List of Record Id and Object Name  
	    Returns:        Return a FieldSetRecord object that contains all the required information needed for the cloning process 
	---------------------------------------------------------------------------------------------*/
    public static FieldSetRecord getAllFieldsetAndFieldDataForCloning(List<Id> ids, String sObjectName) {
        KanbanController.FieldSetRecord singleFieldSetRecord = new KanbanController.FieldSetRecord();
        Map<String,Boolean> fieldSetRecords = new Map<String,Boolean>();
        Boolean isFieldSetAvailable = false;
        Set<Schema.DisplayType> fieldTypeSupport = new Set<Schema.DisplayType>{
                                                                                Schema.DisplayType.BOOLEAN,
                                                                                Schema.DisplayType.CURRENCY,
                                                                                Schema.DisplayType.DATE,
                                                                                Schema.DisplayType.DOUBLE,
                                                                                Schema.DisplayType.PICKLIST,
                                                                                Schema.DisplayType.REFERENCE,
                                                                                Schema.DisplayType.STRING,
                                                                                Schema.DisplayType.URL,
                                                                                Schema.DisplayType.PERCENT
                                                                                };

        if (sObjectName == 'leankor__KanbanCard__c') {
            isFieldSetAvailable = true;
            List<Id> valueStremId = new List<Id>();
            List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                                  Name,
                                                                  leankor__ValueStream__c,
                                                                  leankor__KanbanCardTemplate__r.leankor__FieldSetName__c
                                                                From leankor__KanbanCard__c 
                                                                Where id In :ids
                                                                Limit 50000];

            for (leankor__KanbanCard__c singleId : kanbanCardList) {
                fieldSetRecords.put(singleId.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c, isFieldSetAvailable);
                valueStremId.add(singleId.leankor__ValueStream__c);
            }

            List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSetList = [Select Id,
                                                                                              Name,
                                                                                              leankor__FieldSetName__c,
                                                                                              leankor__ProjectBoard__c
                                                                                            From leankor__ProjectBoardWorkFieldSet__c
                                                                                            Where leankor__ProjectBoard__c In :valueStremId
                                                                                            Limit 50000];

            for(leankor__ProjectBoardWorkFieldSet__c singleRecord : projectBoardWorkFieldSetList){
                fieldSetRecords.put(singleRecord.leankor__FieldSetName__c, isFieldSetAvailable);
            }

        }
        
        if (sObjectName == 'leankor__ValueStream__c') {
            isFieldSetAvailable = true;
            List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                                  Name,
                                                                  leankor__ValueStream__c,
                                                                  leankor__KanbanCardTemplate__r.leankor__FieldSetName__c
                                                                From leankor__KanbanCard__c 
                                                                Where leankor__ValueStream__c In :ids
                                                                Limit 50000];

            for(leankor__KanbanCard__c singleId : kanbanCardList){
                fieldSetRecords.put(singleId.leankor__KanbanCardTemplate__r.leankor__FieldSetName__c, isFieldSetAvailable);
            }

            List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSetList = [Select Id,
                                                                                                Name,
                                                                                                leankor__FieldSetName__c,
                                                                                                leankor__ProjectBoard__c
                                                                                            From leankor__ProjectBoardWorkFieldSet__c
                                                                                            Where leankor__ProjectBoard__c In: ids
                                                                                            Limit 50000];

            for (leankor__ProjectBoardWorkFieldSet__c singleRecord : projectBoardWorkFieldSetList) {
                fieldSetRecords.put(singleRecord.leankor__FieldSetName__c, isFieldSetAvailable);
            }

        }

        Map<String, Schema.SObjectField> fieldDescribeMap = leankor__KanbanCard__c.getSObjectType().getDescribe().fields.getMap();                                                               
        Boolean isFirst = true;
        Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();
        Set<String> fieldNames = new Set<String>();
        String customFields = '';
        Map<String, Set<String>> specificFieldSetAndFieldsData = new Map<String, Set<String>>();
		Schema.SObjectField fieldDescribe;

        for (String singleFieldsetName : fieldSetMap.keySet()) {
            String modifiedFieldsetName = singleFieldsetName;
            Set<String> fieldsRecords = new Set<String>();

            if (fieldSetRecords.containsKey(modifiedFieldsetName) && fieldSetRecords.get(modifiedFieldsetName)) {

                for (Schema.FieldSetMember fields : fieldSetMap.get(singleFieldsetName).getFields()) {

                    //if (fields.getFieldPath().containsIgnoreCase('__c')) {

                    if((!fields.getFieldPath().containsIgnoreCase('leankor__')) && (fields.getFieldPath().containsIgnoreCase('__c'))) {

                        if (fieldTypeSupport.contains(fields.getType())) {
                            fieldDescribe = fieldDescribeMap.get(fields.getFieldPath());

                            if (fieldDescribe!=null) {

                                if (fieldDescribe.getDescribe().isUpdateable() && !fieldDescribe.getDescribe().isCalculated() && !fieldDescribe.getDescribe().isAutoNumber()) {
                                    String fieldName = fields.getFieldPath();
                                    fieldsRecords.add(fieldName);

                                    if (!fieldNames.contains(fieldName)) {
                                        fieldNames.add(fieldName);
                                        
                                        if (isFirst) {
                                            customFields += ',';
                                        }

                                        customFields += fieldName+',';
                                        isFirst = false;
                                    }

                                 }

                             }

                         }

                     }

                 }

             }

            specificFieldSetAndFieldsData.put(singleFieldsetName,fieldsRecords);
        }

        if(!String.isBlank(customFields)){
            customFields = customFields.removeEnd(',');
        }

        singleFieldSetRecord.allFields = fieldNames;
        singleFieldSetRecord.allFieldsInStringFormat = customFields;
        singleFieldSetRecord.fieldSetAndFields = specificFieldSetAndFieldsData;
        return singleFieldSetRecord; // return statement
    }
}