/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: ProjectBoardCarousel.cls
 * CLASS: PortfolioController
 * * * *
*/
global with Sharing class ProjectBoardCarousel {
    // rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
    public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c'};
    // rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type

    private static final String BLANKTEXT ='';
    private static final String DT_DAYSTART_SUFFIC = 'T00:00:00Z';
    private static final String DT_DAYEND_SUFFIC = 'T23:59:59Z';
    // 10/08/2020 This variable is used to define base URL for KanbanCardQuickAction page. 
    public static String leankorBaseURL { get; private set; }
    
    public ProjectBoardCarousel(Util controller) {}
    global ProjectBoardCarousel(ApexPages.StandardController controller) {}
    global ProjectBoardCarousel() {}
    global static List<leankor__ValueStream__c> theValueStreams {get; set;}
    global static List<leankor__ProjectRoom__c> theProjectRooms {get; set;}

    public static Set<String> MASTERCONTAINERTYPEFILTERS_CONST = new Set<String>{'Archive', 'Backlog', 'Regular'};
    public static Set<String> BOARDTYPEFILTERS_CONST = new Set<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard'};
    public static final Set<String> BOARDTYPEFILTERS_NONCARDHIERARCHY_CONST = new Set<String>{'Whiteboard', 'Plan Board', 'Kanban Board', 'DashBoard', 'Portfolio View', 'UberBoard'};
    //18/Jan/2023 : This variable is used for when we update Activity date from MyWork and we want changes the isConstraintRecalculate field value for that Acitivity.
    public static Boolean isConstraintRecalculateForActivityFromMyWork = false;
    public static Boolean isCalledFromQuickAction = false;
    @TestVisible
    private static final String VERSION ='v55.0';
    global ProjectBoardCarousel(ApexPages.StandardSetController controller) {
        theProjectRooms = [Select Id, 
                                Name, 
                                OwnerId 
                            From leankor__ProjectRoom__c 
                            With Security_Enforced
                            Limit 49999];
    }
  

    @RemoteAction
    global static User getuserlog() {
        UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        return PageSetupController.getCurrentUserRecord();
    }
  

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method Is use To get ValueStream records in ProjectBoard(Inner calss) Peramenters. 
    Inputs:         -
    Returns:        List<leankor.RealTimeController.ProjectBoard>
    ------------------------------------------------------------*/
    @RemoteAction
    global static List<leankor.RealTimeController.ProjectBoard> getValueStreams() {
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
        for (leankor__ValueStream__c vs: [Select 
                                            Id,
                                            leankor__BoardType__c,
                                            leankor__CaseCardCategory__c,
                                            leankor__CaseRecordType__c,
                                            leankor__CaseSynchronization__c,
                                            leankor__CaseType__c,
                                            leankor__ProjectRoom__c,
                                            leankor__ValueStreamCardLink__c,
                                            leankor__ValueStreamLink__c,
                                            Name,
                                            OwnerId,
                                            Owner.Name,
                                            (Select Id,
                                                    Name,
                                                    ContentType,
                                                    ParentId 
                                                From Attachments 
                                                Where Name Like '%preview%' 
                                                Limit 1
                                            ) 
                                        From Leankor__ValueStream__c 
                                        Where Leankor__isRecordDeleted__c = false
                                        Order By SystemModstamp Desc 
                                        Limit 50000]) {

            if(vs.Leankor__ProjectRoom__c != null && vs.Leankor__Boardtype__c != 'Plan Board' && vs.Leankor__Boardtype__c != 'Dashboard'){
                vsList.add(vs);
            }
        }
        ValueStreamCarouselController.theValueStreams = vsList;

        List<leankor.realTimeController.ProjectBoard> pBoards = new List<leankor.realTimeController.ProjectBoard>();
        for (leankor__ValueStream__c vs :ValueStreamCarouselController.theValueStreams) {  
            String attchID='';

            for(Attachment att:vs.Attachments){
                attchID = att.Id;
                break;
            }

            leankor.RealTimeController.ProjectBoard pb = new leankor.RealTimeController.ProjectBoard();
            pb.Id = vs.Id;
            pb.Name =  vs.Name;
            pb.OwnerID =  vs.OwnerId;
            pb.OwnerName = vs.Owner.Name;
            pb.BoardType =  vs.leankor__BoardType__c;
            pb.CaseCardCategory =  vs.leankor__CaseCardCategory__c;
            pb.CaseRecordType =  vs.leankor__CaseRecordType__c;
            pb.CaseSynchronization =  vs.leankor__CaseSynchronization__c;
            pb.CaseType =  vs.leankor__CaseType__c;
            pb.ProjectRoom =  vs.leankor__ProjectRoom__c;
            pb.ValueStreamCardLink =  (vs.leankor__ValueStreamCardLink__c == null ? '' : vs.leankor__ValueStreamCardLink__c);
            pb.ValueStreamLinkID =  (vs.leankor__ValueStreamLink__c == null ? '' :vs.leankor__ValueStreamLink__c) ;
            pb.AttachmentID = attchID;

            pBoards.add(pb);
        }

        return pBoards;
    } 
        

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method Is use To get records OF Board Type in Picklist.    
    Inputs:         -
    Returns:        List<Schema.Picklistentry>
    ------------------------------------------------------------*/
    @RemoteAction 
    global static List<Schema.Picklistentry> getBoardTypes() {
        return leankor__ValueStream__c.fields.leankor__BoardType__c.getDescribe().getpicklistvalues();
    }

    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method Is use To get KanbanCards records of Given VSID.    
    Inputs:         vsId
    Returns:        List<leankor__KanbanCard__c>
    ------------------------------------------------------------*/
    @RemoteAction
    global static List<leankor__KanbanCard__c> getKanbanCards(String vsId) {
        if (String.isNotBlank(vsId) && Util.getSObjectName(vsId) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        return realtimeController.getKanbanCards(vsId);
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This inner class is used for Project Room Records to send on LeankorJS end. 
    ------------------------------------------------------------*/
    global class ProjectRoom {
        global String Id;
        global String Name;
        global String OwnerID;
    }

    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method Is use to Create Project Room.  
    Inputs:         PrjName
    Returns:        ProjectRoom
    ------------------------------------------------------------*/
    @RemoteAction
    global static ProjectRoom createProjectRoom(String PrjName) {
        //Check CRUD / FLC behavior
       /* PortfolioBehaviour portfolio = new PortfolioBehaviour();
        ProjectRoomBehaviour projectRoom = new ProjectRoomBehaviour();
        if (
            !portfolio.isCreateable() || 
            !projectRoom.isCreateable()
        ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior

        ProjectRoom pRoom = new ProjectRoom();
        leankor__Portfolio__c roomPortfolio= new leankor__Portfolio__c(Name = PrjName);
        DataBase.Insert(roomPortfolio,true);  

        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = PrjName, leankor__Portfolio__c = roomPortfolio.ID);
        Database.SaveResult sResult;

        try {
            sResult = DataBase.Insert(project,true);
        } catch (DmlException e){
            //return new leankor.ProjectBoardCarousel.ProjectRoom();
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }

        if (sResult.isSuccess() == true) {
            pRoom.Id = project.Id;
            pRoom.Name = project.Name;
            pRoom.OwnerID = project.OwnerId;
        }*/

        return new ProjectRoom();  
    }

    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This method is used to Update Project Room.
    Inputs:         String PrjID,String PrjName
    Returns:        String
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static String updateProjectRoom(String PrjID,String PrjName) { 
        /*
        if (String.isNotBlank(PrjID) && Util.getSObjectName(PrjID) != 'leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoom = new ProjectRoomBehaviour();
        if (!projectRoom.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior
        
        leankor__ProjectRoom__C prjRoom = [Select Id, 
                                                    Name 
                                                From leankor__ProjectRoom__c 
                                                Where Id =: PrjID 
                                                With Security_Enforced
                                                Limit 1];
        prjRoom.Name = PrjName;

        try {
            DataBase.Update(prjRoom, true);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        */
        return 'Success';
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method Is use to Delete Project Room.
    Inputs:         String PrjID
    Returns:        String
    ------------------------------------------------------------*/
    @RemoteAction
    @AuraEnabled
    global static String deleteProjectRoom(String PrjID) { 
        if (String.isNotBlank(PrjID) && Util.getSObjectName(PrjID) != 'leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        ProjectLaunchBehavior projectLaunchBehavior = new ProjectLaunchBehavior();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!projectLaunchBehavior.isDeletable() || 
            !kanbanCardTemplateBehaviour.isDeletable() || 
            !kanbanCardTemplateBehaviour.isUpdateable() || 
            !dependencyBehaviour.isUpdateable() ||
            !valueStreamBehavior.isUpdateable() ||
            !projectRoomBehaviour.isDeletable()
        ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }   
        //Check CRUD / FLC behavior

        leankor__ProjectRoom__c prjRoom = [Select Id, 
                                                    Name 
                                                From leankor__ProjectRoom__c 
                                                Where Id =: PrjID 
                                                With Security_Enforced
                                                Limit 1];
        List<leankor__ProjectLaunchBehavior__c > projectLaunchBehaviorList =[Select Id 
                                                                                    From leankor__ProjectLaunchBehavior__c 
                                                                                Where leankor__Project__c =:PrjID
                                                                                With Security_Enforced];
        try {
            Database.delete(projectLaunchBehaviorList ,false);
        } catch(DMLException ex) {
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<Leankor__KanbanCardTemplate__c> kanbanCardTemplate = new List<Leankor__KanbanCardTemplate__c>();
        for(Leankor__KanbanCardTemplate__c kcTemplate: [Select Id,
                                                                Leankor__DerivedFrom__c,
                                                                Leankor__DerivedFrom__r.Leankor__DerivedFrom__c,
                                                                Leankor__ProjectRoom__c,
                                                                Leankor__ValueStream__c,
                                                                Name 
                                                            From Leankor__KanbanCardTemplate__c 
                                                            Where Leankor__ProjectRoom__c = :PrjID 
                                                            With Security_Enforced
                                                            Limit 1000 ]){

            if(kcTemplate.Leankor__ValueStream__c == null && kcTemplate.Leankor__DerivedFrom__c != null ){
                kanbanCardTemplate.add(kcTemplate);
            }
        }

        List<Leankor__KanbanCardTemplate__c> allVSKCT = new List<Leankor__KanbanCardTemplate__c>(); // level 3 update
        for(Leankor__KanbanCardTemplate__c kcardTemplate: [Select Id,
                                                                    Leankor__DerivedFrom__c,
                                                                    Leankor__ProjectRoom__c,
                                                                    Leankor__ValueStream__c,
                                                                    Name 
                                                                From Leankor__KanbanCardTemplate__c 
                                                                Where Leankor__DerivedFrom__c In : kanbanCardTemplate 
                                                                With Security_Enforced
                                                                Limit 1000 ]){

            if(kcardTemplate.Leankor__ValueStream__c != null){
                allVSKCT.add(kcardTemplate);
            }
        }

        Map<String, String> kanbanCardTemplateMap = new Map<String, String>();
        for (leankor__KanbanCardTemplate__c kanbanCardTemplateLog : kanbanCardTemplate) {
            kanbanCardTemplateMap.put(kanbanCardTemplateLog.leankor__DerivedFrom__c, kanbanCardTemplateLog.leankor__DerivedFrom__r.leankor__DerivedFrom__c);
        }

        for (leankor__KanbanCardTemplate__c vsKCTlog :allVSKCT){
            if (kanbanCardTemplateMap.containskey(vsKCTlog.leankor__DerivedFrom__c)) {
                vsKCTlog.leankor__DerivedFrom__c = kanbanCardTemplateMap.get(vsKCTlog.leankor__DerivedFrom__c);
            } else {
                vsKCTlog.leankor__DerivedFrom__c = null;
            }
        }

        try {
            DataBase.update (allVSKCT,false);
            Database.delete(kanbanCardTemplate,false);
        } catch(DMLException ex) {
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        
        List<Leankor__KanbanCardTemplate__c> globalORGKCT = new List<Leankor__KanbanCardTemplate__c>(); // level 0
        for(Leankor__KanbanCardTemplate__c kcardTemplate: [Select Id, 
                                                                    Leankor__DerivedFrom__c, 
                                                                    Leankor__ValueStream__c 
                                                                From Leankor__KanbanCardTemplate__c 
                                                                Where Leankor__ProjectRoom__c = :PrjID 
                                                                With Security_Enforced
                                                                Limit 10000]){

            if(kcardTemplate.Leankor__DerivedFrom__c == null && kcardTemplate.Leankor__ValueStream__c == null){
                globalORGKCT.add(kcardTemplate);
            }
        }

        if (allVSKCT.size() <= [Select Count() 
                                            From Leankor__KanbanCardTemplate__c 
                                            Where Leankor__DerivedFrom__c In :globalORGKCT
                                            With Security_Enforced]) {
            Delete globalORGKCT;
        }
    
        List<String> projectIds = new List<String>();
        projectIds.add(PrjID);
        //18.05.2017 call method to delete link of linked cards
        leankor.realTimeController.removeLinkedCard(projectIds);
                
        // Date: 02/05/2019 - To get records without sharing enforcement.  
        List<leankor__Dependency__c> dependencies = leankor.RealTimeControllerHelper.deleteProjectRoom_Helper(PrjID);  
            
        //RS 04/02/2018 To fix highlight issue when project is deleted  
        Set<String> kbIds = new Set<String>(); 
        
        for (leankor__Dependency__c dependency : dependencies) {
            kbIds.add(dependency.leankor__Predecessor__c);
            kbIds.add(dependency.leankor__Successor__c);

            //Changes added for soft deleting Dependency records.
            dependency.leankor__Predecessor__c = null;
            dependency.leankor__Successor__c = null;
            dependency.leankor__ValueStream__c = null;
        }       
            
        try {
            if (dependencies.size() > 0) {
                update dependencies;
            }   
         
            //RS 04/02/2018 
            FixKanbanDataBatch fb = new FixKanbanDataBatch();
            fb.updateIsExternal([Select Id, 
                                        leankor__IsExternallyDependent__c, 
                                        (Select Id, 
                                        leankor__Predecessor__r.leankor__ValueStream__c, 
                                        leankor__Successor__r.leankor__ValueStream__c 
                                    From leankor__PredecessorDependencies__r), 
                                        (Select Id, 
                                        leankor__Predecessor__r.leankor__ValueStream__c, 
                                        leankor__Successor__r.leankor__ValueStream__c 
                                    From leankor__SuccessorDependencies__r) 
                                    From leankor__kanbancard__c 
                                    Where Id In: kbIds
                                    With Security_Enforced]);
            //RS 04/02/2018       
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());  
        }
        
        List<leankor__ValueStream__c> valueStreamList = [Select 
                                                            Id,
                                                            leankor__isRecordDeleted__c 
                                                        From leankor__ValueStream__c 
                                                        Where leankor__ProjectRoom__c =:PrjID 
                                                            And leankor__isRecordDeleted__c = false 
                                                        With Security_Enforced
                                                        Limit 10000];
        List<String> valueStreamIdList = new List<String>();
        for (leankor__ValueStream__c vs: valueStreamList) {
            vs.leankor__isRecordDeleted__c = true;
            valueStreamIdList.add(vs.Id);
        }
        // Ashutosh : 08/03/2021 - Changes : Cards not soft deleted after delete project
        List<leankor__KanbanCard__c> kanbanCardList = [Select 
                                                        Id,
                                                        leankor__isRecordDeleted__c
                                                    From leankor__KanbanCard__c
                                                    Where leankor__ValueStream__c In :valueStreamIdList
                                                    With Security_Enforced];
        for(leankor__KanbanCard__c kanbanCard : kanbanCardList){
            kanbanCard.leankor__isRecordDeleted__c = true;
        }
        
        try {
            Update kanbanCardList;
            Update valueStreamList;
            Delete prjRoom;     
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());       
        }    

        return 'Success';
    }

   
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to Create Project ProjectBoard
    Inputs:         String prjName, String projectRoomId, String boardType, String projectBoardId, String kanbanCardId
    Returns:        leankor.RealTimeController.ProjectBoard
    ------------------------------------------------------------*/
    @RemoteAction
    global static leankor.RealTimeController.ProjectBoard createProjectBoard(String prjName, String projectRoomId, String boardType, String projectBoardId, String kanbanCardId) {
        if (String.isBlank(projectRoomId)|| Util.getSObjectName(projectRoomId) != 'leankor__ProjectRoom__c'
        || (String.isNotBlank(kanbanCardId) && Util.getSObjectName(kanbanCardId) != 'leankor__KanbanCard__c')
        || (String.isNotBlank(projectBoardId) && Util.getSObjectName(projectBoardId) != 'leankor__ValueStream__c')) {
                throw new ProjectBoardCarouselException('Error: Invalid input');
        }

        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
        UserRoleBehaviour userRoleBehaviour = new UserRoleBehaviour();
        if (!valueStreamBehavior.isCreateable() 
        || !attachmentBehaviour.isAccessible() 
        || !attachmentBehaviour.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        // creating default template when project board successfully created
        // finding nopreview according the board type
        String defaultAttName = boardType == 'Portfolio View' 
            || boardType == 'Card Hierarchy' 
                ? 'ganttpreview' 
                : (boardType == 'Kanban Board' 
                    || boardType == 'Plan Board'
                        ? 'kanbanpreview' 
                        : 'nopreview');

        StaticResource defaultAtt = [Select Body, 
                                            Name, 
                                            ContentType 
                                        From StaticResource 
                                        Where Name = :defaultAttName
                                        Limit 1];

        if (defaultAtt == null) {
            throw new ProjectBoardCarouselException('Error: Missing image static resource');
        }

        String suffix = defaultAtt.ContentType == 'image/jpeg' || defaultAtt.ContentType == 'image/jpg'
                ? '.jpg'
                : (defaultAtt.ContentType == 'image/gif' 
                    ? '.gif' 
                    : '.png');        
                    
        leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getInstance();        
        Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null 
            || leanConstant.leankor__FirstDayOfTheWeek__c > 6 
            || leanConstant.leankor__FirstDayOfTheWeek__c < 0 
                ? 1 
                : leanConstant.leankor__FirstDayOfTheWeek__c.intValue();

        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, leanConstant.leankor__SevenDayWorkWeek__c ? 7 : 5);
        Datetime projectBoardDateTime = boardType == 'UberBoard' || boardType == 'WhiteBoard' 
                ? Util.readNextWorkingDateTime(workWeek, System.now()) 
                : null;
        leankor__ValueStream__c projectBoard = new leankor__ValueStream__c(
            Name = prjName.length() > 80 ? prjName.substring(0, 79) + ')' : prjName, // why add parenthesis?
            leankor__SprintStartDate__c = null,
            leankor__PointPicklist__c = String.isBlank(leanConstant.leankor__PointSequence__c) ? '[]' : leanConstant.leankor__PointSequence__c,
            leankor__DaysPerSprint__c = null,            
            leankor__IsAgile__c = false,
            leankor__Effortindicator__c = 'Days',
            leankor__ProjectRoom__c = projectRoomId,
            leankor__BoardType__c = boardType,
            leankor__ValueStreamLink__c = String.isBlank(projectBoardId) ? null : projectBoardId,
            leankor__ValueStreamCardLink__c = String.isBlank(kanbanCardId) ? null : kanbanCardId,
            leankor__DefaultCategory__c = null,
            leankor__DisableCalendarView__c = false,
            leankor__IsTemplateBoard__c = false,
            leankor__DefaultOwnerID__c = userinfo.getUserID(),
            leankor__SevenDayWorkWeek__c = leanConstant.leankor__SevenDayWorkWeek__c,
            leankor__PortfolioMode__c  = boardType == 'Plan Board',
            leankor__DisableTaskAsMiniature__c = false,
            leankor__EffortUnits__c = String.isBlank(leanConstant.leankor__EffortUnits__c) ? 'Days' : leanConstant.leankor__EffortUnits__c,
            leankor__ManuallyScheduled__c = leanConstant.leankor__ManuallyScheduled__c != null ? leanConstant.leankor__ManuallyScheduled__c : false,
            leankor__Mode__c = String.isBlank(leanConstant.leankor__Mode__c) ? 'Normal' : leanConstant.leankor__Mode__c,
            leankor__ProjectBoardStartDateTime__c = projectBoardDateTime,
            leankor__ProjectBoardEndDateTime__c = projectBoardDateTime,
            //15/Feb/2023 : Changes added for Task Date check variable, If we are creating Board/Project then custom setting value will be assign in Custom field.
            leankor__TaskDateCheck__c = (boardType != 'UberBoard') ? (!leanConstant.leankor__AvoidTaskDueDateCheck__c) : true
        );                                
        List<Attachment> attachments = new List<Attachment>();                               
        Savepoint sp = Database.setSavepoint();
        try {
            insert projectBoard;

            // create attachment
            
            Attachment att = new Attachment();
            att.body = defaultAtt.body;
            att.name = defaultAtt.name + suffix;
            att.contentType = defaultAtt.contentType;
            att.ParentId = projectBoard.Id;
            attachments.add(att);
            insert attachments;
 
        // create default Kanban Board
            if (boardType == 'Kanban Board' 
            || boardType == 'Plan Board' 
            || boardType == 'DashBoard') {
                leankor.KanbanController.CloneBoard cloneBoard = new leankor.KanbanController.CloneBoard();
                cloneBoard.VSID = projectBoard.Id;
                cloneBoard.RealVSID = '';
                cloneBoard.KanbanVerb = false;
                cloneBoard.KanbanTemplateVerb = true;
                cloneBoard.StickerVerb = false;
                cloneBoard.TaskVerb = false;
                cloneBoard.ZoneVerb = true;
                cloneBoard.MarkerVerb = boardType == 'DashBoard';
                cloneBoard.ChartVerb = boardType == 'DashBoard';
                cloneBoard.BoardType = boardType;
                cloneBoard.LinkCloneRoomID = '';
                cloneBoard.LinkCloneVSID = '';
                cloneBoard.LinkCloneKanbanCardID = '';
                cloneBoard.isBoardclone = true;

                if (boardType == 'DashBoard') {
                    for(Leankor__Valuestream__c valueStream : [Select Id, 
                                                                        Name, 
                                                                        Leankor__ProjectRoom__c 
                                                                    From Leankor__ValueStream__c 
                                                                    Where Name = '_System_DashBoard' 
                                                                        And Leankor__BoardType__c = 'DashBoard'
                                                                    With Security_Enforced]) {
                        if(valueStream.Leankor__ProjectRoom__c == null) {
                            cloneBoard.RealVSID = valueStream.Id;
                        break;
                        }
                    }
                }

                KanbanController.CloneSystemBoard(cloneBoard);

            } else {
                // create and add local KanbanCardTemplate
                List<KanbanCardTemplate> newKanbanCardTemplates = new List<KanbanCardTemplate>();
                KanbanCardTemplate newKanbanCardTemplate = new KanbanCardTemplate();
                for(String key : KanbanCardTemplate.KANBANCARD_TEMPLATES.keySet()) {
                    newKanbanCardTemplate = new KanbanCardTemplate(projectBoard, KanbanCardTemplate.KANBANCARD_TEMPLATES.get(key));
                    newKanbanCardTemplate.setKanbanBoardKanbanCardTemplate(newKanbanCardTemplate);
                    newKanbanCardTemplates.add(newKanbanCardTemplate);
                }
           
                // create and add server KanbanCardTemplate
                List<leankor__KanbanCardTemplate__c> kanbanCardTemplates = KanbanCardTemplate.createKanbanCardTemplates(newKanbanCardTemplates);

                // update ValueStream with default KanbanCardTemplate
                leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c(
                    leankor__DefaultCategory__c = kanbanCardTemplates[0].Id, 
                    Id = projectBoard.Id, 
                    leankor__PortfolioMode__c = false);

                List<leankor__ValueStream__c> valueStreamRecords = new List<leankor__ValueStream__c>();
                valueStreamRecords.add(valueStreamRecord);
                ValueStream.updateValueStream(valueStreamRecords);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw new ProjectBoardCarouselException('Error: ' + e.getmessage());
        }
        

        // if a user is able to insert the record then it automatically has CRUD access, no need to query access
/*         List<leankor__Valuestream__C> valueStreams = [Select Id, 
                                                            UserRecordAccess.HasReadAccess, 
                                                            UserRecordAccess.HasEditAccess, 
                                                            UserRecordAccess.HasDeleteAccess 
                                                        From leankor__Valuestream__c 
                                                        Where Id = :projectBoard.Id 
                                                        Limit 1]; */
        
        leankor.RealTimeController.ProjectBoard projectBoardRecord = new leankor.RealTimeController.ProjectBoard();
        projectBoardRecord.Id = projectBoard.Id;
        projectBoardRecord.Name = projectBoard.Name;
        projectBoardRecord.OwnerID = projectBoard.OwnerId;
        projectBoardRecord.BoardType = projectBoard.leankor__BoardType__c;
        projectBoardRecord.CaseCardCategory = projectBoard.leankor__CaseCardCategory__c;
        projectBoardRecord.CaseRecordType = projectBoard.leankor__CaseRecordType__c;
        projectBoardRecord.CaseSynchronization = projectBoard.leankor__CaseSynchronization__c;
        projectBoardRecord.CaseType = projectBoard.leankor__CaseType__c;
        projectBoardRecord.ProjectRoom = projectBoard.leankor__ProjectRoom__c;
        projectBoardRecord.ValueStreamCardLink = projectBoard.leankor__ValueStreamCardLink__c;
        projectBoardRecord.ValueStreamLinkID = projectBoard.leankor__ValueStreamLink__c;
        projectBoardRecord.AttachmentID = attachments.size() > 0 ? attachments[0].Id : '';
        
/*      projectBoardRecord.hasReadAccess = valueStreams[0].UserRecordAccess.HasReadAccess;
        projectBoardRecord.hasEditAccess = valueStreams[0].UserRecordAccess.HasEditAccess;
        projectBoardRecord.hasDeleteAccess = valueStreams[0].UserRecordAccess.HasDeleteAccess;
 */     
        // if a user is able to insert the record then it automatically has CRUD access 
        projectBoardRecord.hasReadAccess = true;
        projectBoardRecord.hasEditAccess = true;
        projectBoardRecord.hasDeleteAccess = true;        

        return projectBoardRecord;
    }


    global class PastDue {
        String PersonName;
        String PersonPhotoUrl;
        Integer NumberOfCardsCompleted;
        Integer NumberOfCardsDue;
        Integer NumberOfTaskCompleted;
        Integer NumberOfTaskDue;

        global PastDue(){}

        global PastDue(String PersonName,String PersonPhotoUrl,Integer NumberOfCardsCompleted,Integer NumberOfCardsDue,Integer NumberOfTaskDue,Integer NumberOfTaskCompleted){
            this.PersonName  = PersonName;
            this.PersonPhotoUrl  = PersonPhotoUrl;
            this.NumberOfCardsCompleted  = NumberOfCardsCompleted;
            this.NumberOfCardsDue  = NumberOfCardsDue;
            this.NumberOfTaskCompleted  = NumberOfTaskCompleted;
            this.NumberOfTaskDue  = NumberOfTaskDue;
        }
    } 


    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    Remove Project Board for the Leankor users only.
    Inputs:         String VSID
    Returns:        String
    ------------------------------------------------------------*/
    @RemoteAction
    @AuraEnabled
    global static String removeProjectBoard(String VSID) {
        if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        MarkerBehaviour markerBehaviour = new MarkerBehaviour();
        ZoneBehavior zoneBehavior = new ZoneBehavior();
        if (!valueStreamBehavior.isUpdateable() ||
            !kanbanCardBehaviour.isUpdateable() ||
            !markerBehaviour.isUpdateable() || 
            !zoneBehavior.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior

        String returnString = 'Success';
        leankor__ValueStream__c valueStream = [Select Id 
                                                        From leankor__ValueStream__c 
                                                        Where Id =: VSID
                                                        With Security_Enforced
                                                        Limit 1];
        valueStream.leankor__ProjectRoom__c = null; // putting null to remove project board from the any project room.
        valueStream.leankor__isRecordDeleted__c = true; // softdeleted record field is updating as true.
        
        try {
            DataBase.update(valueStream, true);
        } catch(DMLException ex) {
            //return 'Failed';
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
          
        List<leankor__KanbanCard__c> cards = [Select 
                                                Id,
                                                leankor__GUID__c 
                                            From leankor__KanbanCard__c 
                                            Where leankor__ValueStream__c =: valueStream.Id  
                                                And leankor__isRecordDeleted__c = false
                                            With Security_Enforced
                                            Limit 10000];

        List<String> cardIds = new List<String>(); 
        for (leankor__KanbanCard__c temp : cards) {
            cardIds.add(temp.leankor__GUID__c);
            temp.leankor__isRecordDeleted__c = true;//softdeleted kanban card record field is updating as true.           
        }

        try {          
            Update cards;
            // Call method to delete link of linked cards
            leankor.realTimeController.removeLinkedCard(cardIds);

        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__Marker__c> markers = [Select Id 
                                                    From leankor__Marker__c 
                                                    Where leankor__ValueStreamLink__c =: valueStream.Id 
                                                    With Security_Enforced
                                                    Limit 10000];
        for (leankor__Marker__c temp : markers) {
            temp.leankor__ValueStreamCardLink__c = null;
            temp.leankor__ValueStreamLink__c = null;
        }

        try {
            DataBase.update(markers,true);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__Zone__c> zones = [Select Id 
                                                FROM leankor__Zone__c 
                                                Where leankor__ValueStreamLink__c =: valueStream.Id 
                                                With Security_Enforced
                                                Limit 10000];
        for (leankor__Zone__c temp : zones) {
            temp.leankor__ValueStreamCardLink__c = null;
            temp.leankor__ValueStreamLink__c = null;
        }

        try {
            DataBase.update(zones, true);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__ValueStream__c> valueStreamList = [Select Id 
                                                                From leankor__ValueStream__c 
                                                                Where leankor__ValueStreamLink__c =:valueStream.Id 
                                                                With Security_Enforced
                                                                Limit 10000];
        for (leankor__ValueStream__c temp : valueStreamList) {
            temp.leankor__ValueStreamCardLink__c = null;
            temp.leankor__ValueStreamLink__c = null;
        }

        try {
            DataBase.Update(valueStreamList,true);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        return returnString;
    }
  

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method Is use to get User Preference(permission) on Board Display to per user.
    Inputs:         Preference userPref
    Returns:        Preference
    ------------------------------------------------------------*/
    @RemoteAction
    global static Preference getPreference(Preference userPref) {
        if (String.isNotBlank(userPref.valuestream) && Util.getSObjectName(userPref.valuestream) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        PreferenceBehaviour preference = new PreferenceBehaviour();
        if(!preference.isUpdateable() ||
            !preference.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }  
        //Check CRUD / FLC behavior      
        
        String valueStream = '';
        leankor__Preference__c userPreference = new leankor__Preference__c();
        if (userPref.valuestream != '') {
            valueStream = userPref.valuestream;
        }
        
        List<leankor__Preference__c> preferenceList = [Select 
                                                            Id, 
                                                            Name, 
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
                                                            OwnerId 
                                                        From leankor__Preference__c 
                                                        Where leankor__ValueStream__c =: valueStream 
                                                            And OwnerId =: UserInfo.getUserId() 
                                                        With Security_Enforced
                                                        Limit 1];
    
        // If there are no user preference, create a one or update the existing one
        if (preferenceList.isEmpty()) {
            userPref.derivedfrom = '';
            userPreference.Name = userPref.Name;
            userPreference.leankor__GUID__c = userPref.guid;
            userPreference.leankor__FollowOnChatter__c = userPref.followonchatter;
            userPreference.leankor__SubscribeToCard__c = userPref.subscribetocard;
            userPreference.leankor__CardPastDueDate__c = userPref.cardpastduedate;
            userPreference.leankor__Moved__c = userPref.moved;
            userPreference.leankor__PercentDone__c = userPref.percentdone;
            userPreference.leankor__TaskPastDueDate__c = userPref.taskpastduedate;
            userPreference.leankor__isTaskCompleted__c = (UserPref.isTaskCompleted != null ? UserPref.isTaskCompleted : false);
            userPreference.leankor__ValueStream__c = (userPref.valuestream== '' ? null : userPref.valuestream);
            userPreference.leankor__DerivedFrom__c =  (userPref.derivedfrom == '' ? null : userPref.derivedfrom);

            Database.upsert(userPreference, leankor__Preference__c.Fields.leankor__GUID__c, true); 
            userPref.Id = userPreference.Id;

        } else {  //If there is a user preference in the database, return the values
            userPref.derivedfrom = preferenceList[0].Id;
            userPref.Id = preferenceList[0].Id;
            userPref.GUID = preferenceList[0].leankor__GUID__C; 
            userPref.FollowOnChatter = preferenceList[0].leankor__FollowOnChatter__c;
            userPref.SubscribeToCard = preferenceList[0].leankor__SubscribeToCard__c;
            userPref.CardPastDueDate = preferenceList[0].leankor__CardPastDueDate__c;
            userPref.Moved = preferenceList[0].leankor__Moved__c; 
            userPref.PercentDone = preferenceList[0].leankor__PercentDone__c;
            userPref.TaskPastDueDate = preferenceList[0].TaskPastDueDate__c; 
            userPref.ValueStream = preferenceList[0].leankor__ValueStream__c;
            userPref.DerivedFrom = preferenceList[0].leankor__DerivedFrom__C;      
            userPref.isTaskCompleted = preferenceList[0].leankor__isTaskCompleted__c;     
        }

        return userPref;
    }    

  
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Inner class is used to Give User Preference records to LeankorJS End.  
    ------------------------------------------------------------*/
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
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method Is use to Set User Preference(permission) on Board Display to per user.
    Inputs:         Preference userPref
    Returns:        Preference
    ------------------------------------------------------------*/
    @RemoteAction
    global static Preference setUserPreferenceAndSecurity(Preference userPref) {
        //Check CRUD / FLC behavior
        PreferenceBehaviour preference = new PreferenceBehaviour();
        if (!preference.isUpdateable() ||
            !preference.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }  
        //Check CRUD / FLC behavior

        leankor__Preference__c userPreference;
        userPreference = new leankor__Preference__c (
            Name = userPref.Name,
            leankor__GUID__c = userPref.GUID,
            leankor__FollowOnChatter__c = userPref.FollowOnChatter,
            leankor__SubscribeToCard__c = userPref.SubscribeToCard,
            leankor__CardPastDueDate__c = userPref.CardPastDueDate,
            leankor__Moved__c = userPref.Moved,
            leankor__PercentDone__c = userPref.PercentDone,
            leankor__TaskPastDueDate__c = userPref.TaskPastDueDate
        );

        Database.UpsertResult uResult;
        try {
            // GUID is the external unique key to match
            Schema.SobjectField externfield = leankor__Preference__c.Fields.leankor__GUID__c;
            uResult = Database.upsert(userPreference, externfield, true); 

            userPref.Id = userPreference.Id;
            userPref.GUID = userPreference.leankor__GUID__C;
            userPref.FollowOnChatter = userPreference.leankor__FollowOnChatter__c;
            userPref.SubscribeToCard = userPreference.leankor__SubscribeToCard__c;
            userPref.CardPastDueDate = userPreference.leankor__CardPastDueDate__c;
            userPref.Moved = userPreference.leankor__Moved__c; 
            userPref.PercentDone = userPreference.leankor__PercentDone__c;
            userPref.TaskPastDueDate = userPreference.TaskPastDueDate__c;
            userPref.ValueStream = userPreference.leankor__ValueStream__c;
            userPref.DerivedFrom = userPreference.leankor__DerivedFrom__c;

        }catch (DmlException e) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }

        return userPref;
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to delete ProjectBoard from Carousel.
    Inputs:         -
    Returns:        PageReference
    ------------------------------------------------------------*/
    global PageReference DeleteProjectBoard() {
        // 10/08/2020 Changes for URL Redirection Attack salesforce security.
        String VSID = System.currentPageReference().getParameters().get('Id');
        if(VSID.startsWith('/')){
            VSID = VSID.replaceFirst('/','');
        }
        if(String.isBlank(VSID) || ! (VSID instanceof Id)) throw new GanttTaskBoard.LeanException('ERROR: BoardId invalid');
        String prefixString = DeleteBoard(VSID);      
        PageReference customPage =  new PageReference('/'+prefixString);
        customPage.setRedirect(true);

        return customPage;
    }

    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to delete ProjectBoard
    Inputs:         String VSID
    Returns:        String
    ------------------------------------------------------------*/
    global static String DeleteBoard(String VSID) {
        if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();    
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        ValuestreamBehavior valuestreamBehavior = new ValuestreamBehavior();
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();
        ChartBehaviour chartBehaviour = new ChartBehaviour();
        PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
        SecurityBehavior securityBehavior = new SecurityBehavior();
        RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();
        TaskTemplateBehavior taskTemplateBehavior = new TaskTemplateBehavior();
        AutomationTemplateBehaviour automationTemplateBehaviour = new AutomationTemplateBehaviour();
        SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
        ZoneBehavior zoneBehavior = new ZoneBehavior();
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour(); 
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour(); 
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior(); 
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour(); 
        StickerBehavior stickerBehavior = new StickerBehavior();
        MarkerBehaviour markerBehaviour = new MarkerBehaviour();
        ZoneKanbanActionBehavior zoneKanbanActionBehavior = new ZoneKanbanActionBehavior();
        StatusLogBehaviour statusLogBehaviour = new StatusLogBehaviour();
        FilterBehaviour filterBehaviour = new FilterBehaviour(); 
        if (!kanbanCardBehaviour.isDeletable() ||
            !kanbanCardTemplateBehaviour.isDeletable() ||
            !valuestreamBehavior.isDeletable() ||
            !chartBehaviour.isUpdateable() ||
            !preferenceBehaviour.isUpdateable() ||
            !securityBehavior.isUpdateable() ||
            !realtimeTrackerBehavior.isDeletable() ||
            !taskTemplateBehavior.isDeletable() ||
            !automationTemplateBehaviour.isUpdateable() ||
            !swimlaneBehavior.isUpdateable() ||
            !zoneBehavior.isUpdateable() ||
            !masterContainerBehaviour.isUpdateable() ||
            !dependencyBehaviour.isUpdateable() ||
            !taskBehaviour.isAccessible() || 
            !taskBehaviour.isDeletable() ||
            !kanbanCardStickerBehaviour.isUpdateable() ||
            !subscriberBehavior.isUpdateable() ||
            !scheduleModeBehavior.isUpdateable() ||
            !resourceAssignmentBehavior.isUpdateable() ||
            !attachmentBehaviour.isAccessible() || 
            !attachmentBehaviour.isDeletable() ||
            !stickerBehavior.isDeletable() ||
            !markerBehaviour.isUpdateable() ||
            !zoneKanbanActionBehavior.isDeletable() ||
            !statusLogBehaviour.isDeletable() ||
            !filterBehaviour.isUpdateable() 
        ) {
			throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        if(String.isBlank(VSID) || ! (VSID instanceof Id)) throw new GanttTaskBoard.LeanException('ERROR: BoardId invalid');
        //String prefixString = '/'+VSID.substring(0,3);
        String prefixString = VSID.substring(0,3);
         
        List<leankor__ValueStream__c> vsl = [Select Id, 
                                                    Name, 
                                                    leankor__CaseType__c 
                                                From leankor__ValueStream__c 
                                                Where Id =: VSID 
                                                With Security_Enforced
                                                Limit 1];
        List<leankor__Chart__c> charts = [Select Id, 
                                                leankor__ValueStream__c 
                                            From leankor__Chart__c 
                                            Where leankor__ValueStream__c = :vsl 
                                            With Security_Enforced
                                            Limit 10000];

        if (!charts.isEmpty()) {
            for (leankor__Chart__c chart : charts) {
                chart.leankor__ValueStream__c = null;
            }
        }

        try {
                update charts;
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__Preference__c>  preferences = [Select Id, 
                                                            leankor__DerivedFrom__c,
                                                            leankor__ValueStream__c
                                                        From leankor__Preference__c 
                                                        Where leankor__ValueStream__c In :vsl 
                                                        With Security_Enforced
                                                        Limit 10000];
                                                    
        for (leankor__Preference__c preference : preferences) {
            preference.leankor__DerivedFrom__c = null;
            preference.leankor__ValueStream__c = null;
        } 

        try {
            Database.update(preferences, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__Security__c>  securities = [Select Id, 
                                                        leankor__ValueStream__c ,
                                                        leankor__UserRoleId__c  
                                                    From leankor__Security__c 
                                                    Where leankor__ValueStream__c In :vsl 
                                                    With Security_Enforced
                                                    Limit 10000];

        for (leankor__Security__c security : securities) {
            security.leankor__ValueStream__c = null;
            security.leankor__UserRoleId__c= null;
        }
                                                    
        try {
            Database.update(securities, false);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        
        List<leankor__RealtimeTracker__c> realtimeTrackers = new List<leankor__RealtimeTracker__c>();      
        realtimeTrackers = [Select Id, 
                                    Name 
                                From leankor__RealtimeTracker__c 
                                Where leankor__ValueStream__c In: vsl 
                                With Security_Enforced
                                Limit 9999];
        while (realtimeTrackers.Size() > 0) { 
            try {
                Database.delete(realtimeTrackers,false);
            } catch(DMLException ex) {
                //25/04/2023 : We are Throwing Exception
                throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
            }
            realtimeTrackers = [Select Id, 
                                        Name 
                                    From leankor__RealtimeTracker__c 
                                    Where leankor__ValueStream__c In: vsl 
                                    With Security_Enforced
                                    Limit 9999];
        }
        
        List<leankor__ZoneKanbanAction__c> zonekanbanActions = new List<leankor__ZoneKanbanAction__c>();
        zonekanbanActions = [Select Id, 
                                    Name 
                                From leankor__ZoneKanbanAction__c 
                                Where leankor__ValueStream__c In: vsl 
                                With Security_Enforced 
                                Limit 9999];
        
        while (zonekanbanActions.Size() > 0) {
            try {
                Database.delete(zonekanbanActions,false);
            } catch(DMLException ex) {
                //25/04/2023 : We are Throwing Exception
                throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
            }
            zonekanbanActions = [SELECT Id, Name FROM leankor__ZoneKanbanAction__c WHERE leankor__ValueStream__c IN: vsl LIMIT 9999];
        }
        
        List<leankor__AutomationTemplate__c> automationTemplates = [Select Id, 
                                                                            leankor__ValueStream__c, 
                                                                            leankor__ProjectRoomLink__c, 
                                                                            leankor__ProjectRoom__c, 
                                                                            leankor__ValueStreamCardLink__c, 
                                                                            leankor__ValueStreamLink__c, 
                                                                            leankor__KanbanCardTemplate__c, 
                                                                            leankor__Account__c, 
                                                                            leankor__Zone__c
                                                                        From leankor__AutomationTemplate__c
                                                                        Where leankor__ValueStream__c = :vsl
                                                                        Limit 10000];

        for (leankor__AutomationTemplate__c automationTemplate : automationTemplates) {
            automationTemplate.leankor__ValueStream__c = null;
            automationTemplate.leankor__ProjectRoomLink__c = null;
            automationTemplate.leankor__ProjectRoom__c = null;
            automationTemplate.leankor__ValueStreamCardLink__c = null;
            automationTemplate.leankor__ValueStreamLink__c = null; 
            automationTemplate.leankor__KanbanCardTemplate__c = null; 
            automationTemplate.leankor__Account__c = null;
            automationTemplate.leankor__Zone__c = null;
        }
        
        List<leankor__TaskTemplate__c> taskTemplates = [Select Id, 
                                                                leankor__AutomationTemplate__c 
                                                            From leankor__TaskTemplate__c 
                                                            Where leankor__AutomationTemplate__c In :automationTemplates 
                                                            With Security_Enforced
                                                            Limit 10000];

        for (leankor__TaskTemplate__c taskTemplate : taskTemplates) {
            taskTemplate.leankor__AutomationTemplate__c = null;
        }
        try {
            if (!taskTemplates.isEmpty()) {
                update taskTemplates;
            }
            if (!automationTemplates.isEmpty()) {
                update automationTemplates;
            }
        } catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
            
        List<leankor__Zone__c> zones = [Select Id, 
                                                leankor__ParentZone__c, 
                                                leankor__ZoneTemplate__c, 
                                                leankor__ValueStreamLink__c, 
                                                leankor__ValueStream__c, 
                                                leankor__Swimlane__c,
                                                leankor__ValueStreamCardLink__c  
                                            From leankor__Zone__c 
                                            Where leankor__ValueStream__c In :vsl 
                                            With Security_Enforced
                                            Limit 10000];
                                    
        for (leankor__Zone__c zone : zones) {
            zone.leankor__ParentZone__c = null;
            zone.leankor__ZoneTemplate__c = null; 
            zone.leankor__ValueStreamLink__c = null;
            zone.leankor__ValueStream__c  = null;
            zone.leankor__Swimlane__c = null;
            zone.leankor__ValueStreamCardLink__c = null;
        }
        try {
            Database.update(zones, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__Swimlane__c> swimlanes = [Select Id,  
                                                        leankor__MasterContainer__c, 
                                                        leankor__ValueStream__c 
                                                    From leankor__Swimlane__c 
                                                    Where leankor__ValueStream__c = :vsl 
                                                    With Security_Enforced
                                                    Limit 10000];

        for (leankor__Swimlane__c swimlane : swimlanes) {
            swimlane.leankor__MasterContainer__c = null;
            swimlane.leankor__ValueStream__c = null;
        }
        try {
            Database.update(swimlanes, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__MasterContainer__c> masterContainers = [Select Id,
                                                                    leankor__ValueStream__c
                                                                    From leankor__MasterContainer__c 
                                                                Where leankor__ValueStream__c =: vsl 
                                                                With Security_Enforced
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
            }

        List<leankor__Sticker__c> sticker = [Select Id 
                                                From leankor__Sticker__c 
                                                Where leankor__ValueStream__c In: vsl 
                                                With Security_Enforced
                                                Limit 9999];
        List <leankor__KanbanCard__c> KanbanCards = [Select Id, 
                                                        Name, 
                                                            (Select Id,
                                                                    leankor__KanbanCard__c,
                                                                    leankor__ScheduleConstraint__c
                                                                From leankor__ScheduleModes__r ), 
                                                            (Select Id,
                                                                    leankor__KanbanCard__c,
                                                                    leankor__AssignedTo__c,
                                                                    leankor__ResourceType__c,
                                                                    leankor__ProjectFinancial__c
                                                                From leankor__ResourceAssignments__r) 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c In :vsl 
                                                            And leankor__isRecordDeleted__c = false
                                                        With Security_Enforced
                                                        Limit 10000];

        List<leankor__ScheduleMode__c> smList = new List<leankor__ScheduleMode__c>();
        List<leankor__ResourceAssignment__c> raList = new List<leankor__ResourceAssignment__c>();
        for (leankor__KanbanCard__c sm: KanbanCards) {
            if (sm.leankor__ScheduleModes__r.size() > 0  && sm.leankor__ScheduleModes__r != null) {
                sm.leankor__ScheduleModes__r[0].leankor__KanbanCard__c = null;
                sm.leankor__ScheduleModes__r[0].leankor__ScheduleConstraint__c = null;
                smList.add(sm.leankor__ScheduleModes__r);
            }
            if (sm.leankor__ResourceAssignments__r.size() > 0 && sm.leankor__ResourceAssignments__r != null) {
                for (leankor__ResourceAssignment__c resource : sm.leankor__ResourceAssignments__r) {
                    resource.leankor__KanbanCard__c = null;
                    resource.leankor__AssignedTo__c = null;
                    resource.leankor__ResourceType__c = null;
                    resource.leankor__ProjectFinancial__c = null;
                    raList.add(resource);
                }
            }
        }

        /*Map<String, Schema.SObjectType> check_pkg = Schema.getGlobalDescribe();
        if (check_pkg.get('EntitySubscription') != null) {
            List<Sobject> Entity =[SELECT Id,ParentId FROM EntitySubscription WHERE ParentId In :KanbanCards limit 999]; 
            try {
                Database.delete(Entity,false);
            } catch(DMLException ex) {
                System.debug('Error : '+ex.getMessage());
                //25/04/2023 : We are Throwing Exception
                throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
            }
        }*/
      
        List<Task> tsk = [SELECT Id FROM Task WHERE (whatId IN: KanbanCards AND IsDeleted = false) LIMIT 9999 ALL ROWS];
        try {
            Database.delete(tsk, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        List<leankor__KanbanCardSticker__c> kcStickers = [Select Id,
                                                                leankor__Sticker__c,
                                                                leankor__KanbanCard__c
                                                            From leankor__KanbanCardSticker__c 
                                                            Where leankor__KanbanCard__c In: KanbanCards 
                                                            With Security_Enforced
                                                            Limit 10000];       

        for (leankor__KanbanCardSticker__c kcSticker : kcStickers) {
            kcSticker.leankor__Sticker__c = null;
            kcSticker.leankor__KanbanCard__c = null;
        }

        List<leankor__Subscriber__c> subscribers = [Select Id,
                                                            leankor__KanbanCard__c, 
                                                            leankor__Preference__c,
                                                            leankor__SubscriberId__c 
                                                        From leankor__Subscriber__c 
                                                        Where leankor__KanbanCard__c In :kanbanCards
                                                        With Security_Enforced
                                                        Limit 10000];

        for (leankor__Subscriber__c subscriber : subscribers) {
            subscriber.leankor__KanbanCard__c = null;
            subscriber.leankor__Preference__c = null;
            subscriber.leankor__SubscriberId__c = null;
        }
        try {
            Database.update(subscribers,false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__Marker__c> markers = [Select Id, 
                                                    leankor__ValueStream__c, 
                                                    leankor__ValueStreamCardLink__c,  
                                                    leankor__ValueStreamLink__c, 
                                                    leankor__Sticker__c  
                                                From leankor__Marker__c 
                                                Where leankor__ValueStream__c In :vsl 
                                                With Security_Enforced
                                                Limit 10000];

        for (leankor__Marker__c marker : markers) {
            marker.leankor__ValueStream__c = null;
            marker.leankor__ValueStreamCardLink__c = null;  
            marker.leankor__ValueStreamLink__c  = null;
            marker.leankor__Sticker__c = null;
        }
        List<Attachment> attchs = new List<Attachment>();
        for (Attachment[] att : [SELECT Id FROM Attachment WHERE Parent.Type IN :SETSTICKERSOBJECTS_CONST AND (ParentId IN :vsl OR Parentid IN :KanbanCards OR Parentid IN :markers or Parentid IN :sticker) LIMIT 9999]) {
            attchs.addAll(att);
        }
        // rbo 08.07.17 

        List<leankor__StatusLog__c> statusLogs = [Select Id, 
                                                        leankor__KanbanCard__c  
                                                    From leankor__StatusLog__c 
                                                    Where leankor__KanbanCard__c In :kanbanCards 
                                                    With Security_Enforced
                                                    Limit 10000];
        
        for (leankor__StatusLog__c statusLog :statusLogs) {
            statusLog.leankor__KanbanCard__c = null;
        }                                            
        try {
            Database.update(statusLogs, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        try{
            Database.delete(attchs, true);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        try {
            Database.update(markers, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        try {
            Database.delete(sticker, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        try {
            update kcStickers;
        } catch(DMLException ex){
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        try {
            Database.update (smList, false);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        try {
            Database.update (raList, false);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        try {
            Database.delete(KanbanCards, false);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__KanbanCardTemplate__C> kanbanTemplate = [Select Id 
                                                                    From leankor__KanbanCardTemplate__c 
                                                                    Where leankor__ValueStream__c In: vsl 
                                                                    With Security_Enforced
                                                                    Limit 9999];
        try {
            Database.delete(kanbanTemplate, false);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        
        List<leankor__Filter__c> filters = [Select Id,
                                                leankor__ValueStream__c,
                                                leankor__User__c 
                                            From leankor__Filter__c 
                                            Where  leankor__ValueStream__c In :vsl
                                            With Security_Enforced
                                            Limit 10000];

        for(leankor__Filter__c filter : filters){                                  
            filter.leankor__ValueStream__c = null;
            filter.leankor__User__c = null;
            filters.add(filter);
        }
        try {
            update filters;
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        
        /*** Changes made on 23 Feb 2019 : Now we have only one channel
        List<String>  pushTopicIDs=new List<String>();
        for(leankor__ValueStream__C vs: vsl){
            pushTopicIDs.add('RT'+vs.Id);
        }
       
        List<PushTopic> pushTopics=[SELECT Id,Name,Query,SystemModstamp FROM PushTopic where Name in :pushTopicIDs Limit 9999];
        try {
        Database.delete(pushTopics,false);
        } catch (DMLException ex) {
            System.debug('Error : ' + ex.getMessage());
        }***/
        
        try {
            Database.delete(vsl, false);
        } catch (DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        return prefixString;
    }


    global PageReference RedirectVS() {
        String vsId = System.currentPageReference().getParameters().get('Id');
        if (String.isBlank(vsId) || ! (vsId instanceof Id)) {
             throw new GanttTaskBoard.LeanException('ERROR: BoardId invalid');
        }
        PageReference customPage;
        try {
            leankor__ValueStream__c vsl = [Select Id,
                                                Name,
                                                leankor__CaseType__c 
                                                From leankor__ValueStream__c 
                                                Where Id =:vsId 
                                                With Security_Enforced
                                                Limit 1];
            customPage = new ApexPages.StandardController(vsl).view();
        } catch(Exception ex) {
            String prefixString = '/'+vsId.substring(0,3);
            customPage = new PageReference(prefixString);
            customPage.setRedirect(true);
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        customPage.setRedirect(true);

        return customPage;
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Inner class is used for Automation records to LeankorJS end.   
    ------------------------------------------------------------*/
    global class Automation {
        global List<RecordType> RecordTypes;
        //global List<UserRole> UserRoles;
        global List<tempUserRoleClass> UserRoles;
        global List<Schema.PicklistEntry> StageNames;
        global List<User> OwnerName;
        global Set<RoleLog> RoleHierarchy;
    }

    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to get Automation records.
    Inputs:         String VSID
    Returns:        String
    ------------------------------------------------------------*/
    
    @remoteAction
    global Static Automation getAutomationData (String SobjectName, String PicklistFieldName) {
        Automation returnLists= New Automation();
        /*
        returnLists.RecordTypes =[ SELECT Id,Name,SobjectType FROM RecordType WHERE IsActive = True And SobjectType = :SobjectName Limit 49999];

        returnLists.OwnerName = new List<User>();
        for(User usr: [SELECT Id, FirstName, LastName, ProfileId, UserType FROM User WHERE IsActive = True LIMIT 49999]){
            if(usr.UserType != 'CsnOnly'){
                returnLists.OwnerName.add(usr);
            }
        }   

        returnLists.StageNames= Leankor.ProjectBoardCarousel.getPicklist(SobjectName,PicklistFieldName);
        returnLists.RoleHierarchy = Leankor.ProjectBoardCarousel.getRoleHierarchy();
        */
        return returnLists;
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to get Picklist Value Of Field (Dynamic Method).
    Inputs:         String SobjectName, String labelName
    Returns:        List<Schema.PicklistEntry>
    ------------------------------------------------------------*/
    @RemoteAction
    global Static List<Schema.PicklistEntry> getPicklist(String SobjectName, String labelName){
        Map<String, Schema.SObjectType> globalDescribe =Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> globalDescribeField = globalDescribe.get(SobjectName).getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValue = globalDescribeField.get(labelName).getDescribe().getPicklistValues();

        return picklistValue ;
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to get get Project Rooms (ID,Name).
    Inputs:         -
    Returns:        List<leankor__ProjectRoom__c>
    ------------------------------------------------------------*/
    @RemoteAction
    @AuraEnabled
    global static List<leankor__ProjectRoom__c> getProjectRooms() {
        List<leankor__ProjectRoom__c> ProjectRooms;
        List<String> folderIDs = new List<String>();
        List<leankor__Portfolio__c> folder;
        
        try {
            //RS 1/10/2018 Prohibit Platform user on accessing the secured project/board through My Work.
            folder = [SELECT Id, UserRecordAccess.HasReadAccess FROM leankor__Portfolio__c LIMIT 49999];
                        
            for (leankor__Portfolio__c f : folder) {
                if (f.UserRecordAccess.HasReadAccess) {
                    folderIDs.add(f.Id);
                } 
            }
            
            ProjectRooms = new List<Leankor__ProjectRoom__c>();
            for (Leankor__ProjectRoom__c projRoom: [Select Id,
                                                            Name, 
                                                            OwnerID, 
                                                            Leankor__Portfolio__c, 
                                                            Leankor__Portfolio__r.Name 
                                                        From Leankor__ProjectRoom__c 
                                                        Where Leankor__Portfolio__c In :folderIDs 
                                                        With Security_Enforced
                                                        Order By Name 
                                                        Limit 49999]){
                if(projRoom.Leankor__Portfolio__c != null) {
                    ProjectRooms.add(projRoom);
                }
            }
        
        } catch (QueryException ex) {
           // return new List<leankor__ProjectRoom__c>();
           //25/04/2023 : We are Throwing Exception
           throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        return ProjectRooms;
    }
   
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Inner class is used For Automationtemplate records .   
    ------------------------------------------------------------*/
    global class AutomationTemplate {
        global string Id;
        global string RecordTypeName;
        global string RecordTypeId;
        global string RoleName;
        global string RoleId;
        global string AccountId;
        global string AccountName;
        global string StageName;
        global string RoomId;
        global string RoomName;
        global DateTime TemplateEndDate;
        global DateTime TemplateStartDate;
        global string KanbanCardTemplateId;
        global string KanbanCardTemplateName;
        global string ProjectBoardId;
        global string ProjectBoardName;
        global string ColumnId;
        global string ColumnTitle;
        global string GUID;
        global string OwnerId;
        global string OwnerName;
        global integer TaskCount;
        global integer CustomFieldCount;
        global String SmallPhotoUrl;
        global String LinkProjectRoomId;
        global String LinkProjectRoomName;
        global String LinkValueStreamId;
        global String LinkValueStreamName;
        global String LinkKanbanTemplateId;
        global String ValueStreamCardLinkId;
        global String ValueStreamCardLinkName;
        global Boolean WithLinkVerb;
        global String JSONData;
        global String JSONDefinition;
    }
    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to Delete Automation template records .
    Inputs:         List<String> templateID
    Returns:        Boolean
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static Boolean deleteAutomationTemplate(List<String> templateID) {  
        /* 
        for(String template : templateID){
            if (String.isNotBlank(template) && Util.getSObjectName(template) != 'leankor__AutomationTemplate__c') {
                throw new ProjectBoardCarouselException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior
        AutomationTemplateBehaviour automationTemplateBehaviour = new AutomationTemplateBehaviour();
        if (
            !automationTemplateBehaviour.isAccessible() || 
            !automationTemplateBehaviour.isUpdateable()
        ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        List<leankor__AutomationTemplate__c> automationTemplates = [Select Id, 
                                                                            leankor__ValueStream__c, 
                                                                            leankor__ProjectRoomLink__c, 
                                                                    leankor__ProjectRoom__c, 
                                                                            leankor__ValueStreamCardLink__c, 
                                                                            leankor__ValueStreamLink__c, 
                                                                            leankor__KanbanCardTemplate__c, 
                                                                            leankor__Account__c, 
                                                                            leankor__Zone__c
                                                                From leankor__AutomationTemplate__c 
                                                                        Where Id = :templateId
                                                                Limit 10000];
        
        for (leankor__AutomationTemplate__c automationTemplate : automationTemplates) {
            automationTemplate.leankor__ValueStream__c = null;
            automationTemplate.leankor__ProjectRoomLink__c = null;
            automationTemplate.leankor__ProjectRoom__c = null;
            automationTemplate.leankor__ValueStreamCardLink__c = null;
            automationTemplate.leankor__ValueStreamLink__c = null; 
            automationTemplate.leankor__KanbanCardTemplate__c = null; 
            automationTemplate.leankor__Account__c = null;
            automationTemplate.leankor__Zone__c = null;
        }
        try {
            update automationTemplates;
        } catch (DmlException e) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        */
        return true;
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to Create Automation template records .
    Inputs:         List<String> AutoLogs
    Returns:        List<leankor__AutomationTemplate__C>
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static List<leankor__AutomationTemplate__C> createAutomationTemplate(List<String> AutoLogs) {
        List<leankor__AutomationTemplate__c> newAutoLogs = new List<leankor__AutomationTemplate__c>();
        /*
        //Check CRUD / FLC behavior
        AutomationTemplateBehaviour automationTemplateBehaviour = new AutomationTemplateBehaviour();
        if (!automationTemplateBehaviour.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        for (String tempAutoLog  : AutoLogs) {
            AutomationTemplate autoLog = (AutomationTemplate) JSON.deserialize(tempAutoLog,AutomationTemplate.class);
            leankor__AutomationTemplate__c newAutoLog = new leankor__AutomationTemplate__c();
            newAutoLog.leankor__RoleId__c = autoLog.RoleId;
            newAutoLog.leankor__Account__c = (autoLog.AccountId  == '' ? null :autoLog.AccountId);
            newAutoLog.OwnerID = autoLog.OwnerId;
            newAutoLog.leankor__Zone__c = (autoLog.ColumnId == '' ? null : autoLog.ColumnId);
            newAutoLog.leankor__ColumnTitle__c = autoLog.ColumnTitle;
            newAutoLog.leankor__GUID__c = autoLog.GUID;
            newAutoLog.leankor__KanbanCardTemplate__c = (autoLog.KanbanCardTemplateId == '' ? null :autoLog.KanbanCardTemplateId);
            newAutoLog.leankor__ValueStream__c = (autoLog.ProjectBoardId == '' ? null : autoLog.ProjectBoardId);
            newAutoLog.leankor__RecordTypeName__c = autoLog.RecordTypeName;
            newAutoLog.leankor__RecordTypeID__c = autoLog.RecordTypeId;
            newAutoLog.leankor__RoleName__c = autoLog.RoleName;
            newAutoLog.leankor__ProjectRoom__c = (autoLog.RoomId == '' ? null : autoLog.RoomId);
            newAutoLog.leankor__StageName__c = autoLog.StageName;
            newAutoLog.leankor__EndDate__c = autoLog.TemplateEndDate;
            newAutoLog.leankor__StartDate__c = autoLog.TemplateStartDate;
            newAutoLog.leankor__JSONDefinition__c = autoLog.JSONDefinition; //'{}';// Need to get from KanbanCardTemplate.
            newAutoLog.leankor__JSONData__c = autoLog.JSONData;

            newAutoLogs.add(newAutoLog);
        }

        try {
            Database.insert(newAutoLogs, true);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }  
        */
        return newAutoLogs;
    }
   

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to Update Automation template records .
    Inputs:         List<String> AutoLogs
    Returns:        Boolean
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static Boolean updateAutomationTemplate(List<String> AutoLogs) { 
        /*
        //Check CRUD / FLC behavior
        AutomationTemplateBehaviour automationTemplateBehaviour = new AutomationTemplateBehaviour();
        if (!automationTemplateBehaviour.isUpdateable() ||
            !automationTemplateBehaviour.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Set<String> tempKanbanCardTemplateList = new Set<String>();
        List<leankor.RealTimeController.bulkStreaming> tempBulkStreamingData = new List<leankor.RealTimeController.bulkStreaming>();
        Map<Id, leankor__KanbanCardTemplate__c> PortfolioKanbanCardTemplateMap = new Map<Id, leankor__KanbanCardTemplate__c>();
        List<AutomationTemplate> tempAutomationTemplateList = new List<AutomationTemplate>();
        List<leankor__KanbanCardTemplate__c> PortfolioKanbanCardTemplateList = new List<leankor__KanbanCardTemplate__c>();
        Map<String,String> GUIDMap = new Map<String,String>();
        Map<String,String> newKanbanMap = new Map<String,String>();
       //Date :23/10/19
       // List<String> JSONList = new List<String>();
        List<realTimeController.Kanban> newkanbanCards =new List<realTimeController.Kanban>();
        for(String tempAutomationTemp  : AutoLogs){
            AutomationTemplate tempAutomationTemplate = (AutomationTemplate) JSON.deserialize(tempAutomationTemp,AutomationTemplate.class);
            if(tempAutomationTemplate.LinkKanbanTemplateId != null && tempAutomationTemplate.WithLinkVerb == true){
                tempKanbanCardTemplateList.add(tempAutomationTemplate.LinkKanbanTemplateId);
                tempAutomationTemplateList.add(tempAutomationTemplate);
            }
        }

        Integer tempcount = 0;
        if (tempAutomationTemplateList.Size() > 0) {
            PortfolioKanbanCardTemplateList = [SELECT Id, leankor__Color__c, leankor__DerivedFrom__c, leankor__Height__c, leankor__JSONData__c, leankor__JSONDefinition__c, leankor__Title__c, leankor__ValueStream__c, leankor__Width__c, Name, OwnerId FROM leankor__KanbanCardTemplate__c WHERE Id IN: tempKanbanCardTemplateList With Security_Enforced LIMIT 9999];
            PortfolioKanbanCardTemplateMap.putAll(PortfolioKanbanCardTemplateList);

            for (AutomationTemplate tempAutomationTemplate  : tempAutomationTemplateList) {
                leankor__KanbanCardTemplate__c PortfolioTemplate = (PortfolioKanbanCardTemplateMap.ContainsKey(tempAutomationTemplate.LinkKanbanTemplateId) ? PortfolioKanbanCardTemplateMap.get(tempAutomationTemplate.LinkKanbanTemplateId) : (new leankor__KanbanCardTemplate__C()));        
                leankor.realtimeController.Kanban card = new leankor.realtimeController.Kanban();
                    card.Priority = 4;
                    card.OnBudget = 'Green';
                    card.OnQuality = 'Green';
                    card.OnTime = 'Green';
                    card.HarveyBall = '0';
                    integer DateDiffrence = tempAutomationTemplate.TemplateStartDate.Date().daysBetween(tempAutomationTemplate.TemplateEndDate.Date()) ;
                    card.EstimatedDuration = DateDiffrence; 
                    card.DurationUnits = 'Days';
                    card.Color = (PortfolioTemplate.leankor__Color__C != null ? PortfolioTemplate.leankor__Color__C : '#d3fcc1');
                    card.GUID = tempAutomationTemplate.LinkValueStreamId+'-'+System.now().getTime()+'-'+tempcount;
                    GUIDMap.put(tempAutomationTemplate.GUID,card.GUID);
                    card.Name = (tempAutomationTemplate.ValueStreamCardLinkName == '' ? PortfolioTemplate.Name :tempAutomationTemplate.ValueStreamCardLinkName);
                    card.DueDate = tempAutomationTemplate.TemplateEndDate;
                    card.OwnerId = tempAutomationTemplate.OwnerId;
                    card.ValueStream = tempAutomationTemplate.LinkValueStreamId;
                    card.StartDate = tempAutomationTemplate.TemplateStartDate;
                    card.Order = 1;
                    card.Width = (PortfolioTemplate.leankor__Width__C != null ? PortfolioTemplate.leankor__Width__C : 170);
                    card.Height = (PortfolioTemplate.leankor__Width__C != null ? PortfolioTemplate.leankor__Width__C : 120);
                    card.Title = (tempAutomationTemplate.ValueStreamCardLinkName == '' ? PortfolioTemplate.Name :tempAutomationTemplate.ValueStreamCardLinkName);
                    card.TemplateId = (PortfolioTemplate.Id != null ? PortfolioTemplate.Id : tempAutomationTemplate.LinkKanbanTemplateId);
                    card.JSONData = '{}';
                    card.JSONDefinition = (PortfolioTemplate.Id != null ? PortfolioTemplate.leankor__JSONDefinition__c : '{}');
                    card.X = 100;
                    card.Y = 100;
                    card.Top = 2100;
                    card.Left = 2100;
                    card.Bottom = 0;
                tempcount++;
                //Date :23/10/19
                //String JSONPackage = JSON.serialize(card);
                //JSONList.add(JSONPackage);
                newkanbanCards.add(card);
            }
            
            //RS 14.03.2019 
            // Date : 23/10/19 using wrapper class instance instead of Serialization.
            //List<String> newInstanceKanbanCards = new List<String>(JSONList); 
            //List<leankor__KanbanCard__C> KanbanCards = leankor.realtimeController.createkanbancard('',JSONList);
            List<leankor__KanbanCard__C> KanbanCards = leankor.realtimeController.createkanbancards('',newkanbanCards);
            if (KanbanCards.size() > 0) {
                for(leankor__KanbanCard__C kanban : KanbanCards){  
                  newKanbanMap.put(kanban.leankor__GUID__C,kanban.Id);
                }         
            }   

            //Date :23/10/19   
            //for(String tempString: newInstanceKanbanCards){
            for (leankor.realtimeController.Kanban remoteCard : newkanbanCards) {
                //leankor.realtimeController.Kanban remoteCard  = (leankor.realtimeController.Kanban) JSON.Deserialize(tempString, leankor.realtimeController.Kanban.class);
                remoteCard.Id = newKanbanMap.get(remoteCard.GUID);
                remoteCard.ForceID = newKanbanMap.get(remoteCard.GUID);
                String tempJSONPackage =JSON.serialize(remoteCard);
                leankor.RealTimeController.bulkStreaming tempStreaming = new leankor.RealTimeController.bulkStreaming();
                tempStreaming.VSID = remoteCard.ValueStream;
                tempStreaming.Verb = 'CreateKanbanCard';
                tempStreaming.SessionID = UserInfo.getSessionId();
                tempStreaming.SomeJSONData = tempJSONPackage;

                tempBulkStreamingData.add(tempStreaming);      
            }

            leankor.RealTimeController.sendBroadcast(tempBulkStreamingData, 'CreateKanbanCard');
        }

        List<leankor__AutomationTemplate__c> NewAutoLogList = new List<leankor__AutomationTemplate__c>();
        for (String tempAutoLog  : AutoLogs) {
            AutomationTemplate RecordLog = (AutomationTemplate) JSON.deserialize(tempAutoLog,AutomationTemplate.class);
            leankor__AutomationTemplate__c NewAutoLog = new leankor__AutomationTemplate__c();
            NewAutoLog.leankor__RoleId__c = RecordLog.RoleId;
            NewAutoLog.leankor__Account__c = (RecordLog.AccountId == '' ? null : RecordLog.AccountId);
            NewAutoLog.OwnerID = RecordLog.OwnerId;
            NewAutoLog.leankor__Zone__c = (RecordLog.ColumnId == '' ? null : RecordLog.ColumnId);
            NewAutoLog.leankor__ColumnTitle__c = RecordLog.ColumnTitle;
            NewAutoLog.leankor__GUID__c = RecordLog.GUID;
            NewAutoLog.leankor__KanbanCardTemplate__c = (RecordLog.KanbanCardTemplateId == '' ? null : RecordLog.KanbanCardTemplateId);
            NewAutoLog.leankor__ValueStream__c = (RecordLog.ProjectBoardId == '' ? null : RecordLog.ProjectBoardId);
            NewAutoLog.leankor__RecordTypeName__c = RecordLog.RecordTypeName;
            NewAutoLog.leankor__RecordTypeID__c = (RecordLog.RecordTypeId == '' ? null :RecordLog.RecordTypeId);
            NewAutoLog.leankor__RoleName__c = RecordLog.RoleName;
            NewAutoLog.leankor__ProjectRoom__c = (RecordLog.RoomId == '' ? null : RecordLog.RoomId);
            NewAutoLog.leankor__StageName__c = RecordLog.StageName;
            NewAutoLog.leankor__EndDate__c = RecordLog.TemplateEndDate;
            NewAutoLog.leankor__StartDate__c = RecordLog.TemplateStartDate; 

            if (RecordLog.WithLinkVerb) {
                String cardGUID = GUIDMap.get(RecordLog.GUID);
                NewAutoLog.leankor__ValueStreamCardLink__c = newKanbanMap.get(cardGUID);
            } 
            if (!RecordLog.WithLinkVerb) {
                NewAutoLog.leankor__ValueStreamCardLink__c = (RecordLog.ValueStreamCardLinkId == '' ? null:RecordLog.ValueStreamCardLinkId);
            }

            NewAutoLog.leankor__ValueStreamLink__c =  (RecordLog.LinkValueStreamId == '' ? null :RecordLog.LinkValueStreamId);
            NewAutoLog.leankor__ProjectRoomLink__c = (RecordLog.LinkProjectRoomId == ''? null :RecordLog.LinkProjectRoomId);

            NewAutoLogList.add(NewAutoLog);
        }

        List<DataBase.UpsertResult> uResults;
        try {
            Schema.Sobjectfield ExternField = leankor__AutomationTemplate__c.Fields.leankor__GUID__c;
            uResults = Database.upsert(NewAutoLogList, ExternField, true);
        } catch (DmlException e) {
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        */
        return true;  
    } 

    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to get Automation Records
    Inputs:         -
    Returns:        List<String> - (List of JSON Automation Template)
    ------------------------------------------------------------*/
    
    @RemoteAction
    global Static List<String> getAutomationTemplate() {    
        List<String> TemplateList = New List<String>();
        /*
        Set<String> UsreID = New set<String>();

        List<leankor__AutomationTemplate__c> TempRecords = [SELECT Id,(Select ID From leankor__CustomFields__r),(Select ID From leankor__TaskTemplates__r),leankor__ValueStreamCardLink__c,leankor__ValueStreamCardLink__r.Name,leankor__ValueStreamLink__c,leankor__ValueStreamLink__r.Name,leankor__ProjectRoomLink__c,leankor__ProjectRoomLink__r.Name,leankor__ColumnTitle__c,leankor__Account__c,Owner.Name,leankor__StartDate__c,leankor__Account__r.Name,leankor__EndDate__c,leankor__GUID__c,leankor__KanbanCardTemplate__c,leankor__KanbanCardTemplate__r.Name,leankor__ProjectRoom__c,leankor__ProjectRoom__r.Name,leankor__RecordTypeID__c,leankor__RecordTypeName__c,leankor__RoleId__c,leankor__RoleName__c,leankor__StageName__c,leankor__ValueStream__c,leankor__ValueStream__r.Name,leankor__Zone__c,Name,OwnerId FROM leankor__AutomationTemplate__c With Security_Enforced LIMIT 49999];
        for (leankor__AutomationTemplate__c RemoteTemplate: TempRecords) {
            UsreID.add(RemoteTemplate.Owner.Id);
        }

        List<User> users = [Select Id, FirstName,Email, LastName, Name, Username, Alias, UserRoleId, SmallPhotoUrl FROM User WHERE ID IN :UsreID Limit 49999];
        Boolean LinkFlag = true;
        Map<Id, String> UserRecords = new Map<Id, String>();
        for (User u : users) {
            UserRecords.put(u.Id,u.SmallPhotoUrl);
        } 

        for (leankor__AutomationTemplate__c RemoteTemplate: TempRecords) {
            AutomationTemplate Template = New AutomationTemplate();
            Template.Id = RemoteTemplate.Id;
            Template.RecordTypeName = (RemoteTemplate.leankor__RecordTypeName__c == null ? '' :RemoteTemplate.leankor__RecordTypeName__c);
            Template.RecordTypeId = (RemoteTemplate.leankor__RecordTypeID__c == null ? '' :RemoteTemplate.leankor__RecordTypeID__c);
            Template.RoleName = (RemoteTemplate.leankor__RoleName__c == null ? '' :RemoteTemplate.leankor__RoleName__c);
            Template.RoleId = (RemoteTemplate.leankor__RoleId__c == null ? '' :RemoteTemplate.leankor__RoleId__c);
            Template.AccountId = (RemoteTemplate.leankor__Account__c == null ? '' : RemoteTemplate.leankor__Account__c);
            Template.AccountName = (RemoteTemplate.leankor__Account__c == null ? '' : RemoteTemplate.leankor__Account__r.Name);
            Template.StageName = (RemoteTemplate.leankor__StageName__c == null ? '' :RemoteTemplate.leankor__StageName__c);
            Template.RoomId = (RemoteTemplate.leankor__ProjectRoom__c == null ? '' :RemoteTemplate.leankor__ProjectRoom__c);
            Template.RoomName = (RemoteTemplate.leankor__ProjectRoom__c == null ? '' :RemoteTemplate.leankor__ProjectRoom__r.Name);
            Template.TemplateEndDate = RemoteTemplate.leankor__EndDate__c;
            Template.TemplateStartDate = RemoteTemplate.leankor__StartDate__c;
            Template.KanbanCardTemplateId = (RemoteTemplate.leankor__KanbanCardTemplate__c == null ? '' : RemoteTemplate.leankor__KanbanCardTemplate__c);
            Template.KanbanCardTemplateName = (RemoteTemplate.leankor__KanbanCardTemplate__c == null ? '' :RemoteTemplate.leankor__KanbanCardTemplate__r.Name);
            Template.ProjectBoardId = (RemoteTemplate.leankor__ValueStream__c == null ? '' : RemoteTemplate.leankor__ValueStream__c);
            Template.ProjectBoardName = (RemoteTemplate.leankor__ValueStream__c == null ? '' : RemoteTemplate.leankor__ValueStream__r.Name);
            Template.ColumnId = (RemoteTemplate.leankor__Zone__c == null ? '' :RemoteTemplate.leankor__Zone__c);
            Template.ColumnTitle = (RemoteTemplate.leankor__ColumnTitle__c == null ? '' : RemoteTemplate.leankor__ColumnTitle__c);
            Template.GUID = RemoteTemplate.leankor__GUID__c;
            Template.OwnerId = RemoteTemplate.OwnerId;
            Template.OwnerName = RemoteTemplate.Owner.Name;
            Template.LinkProjectRoomName = (RemoteTemplate.leankor__ProjectRoomLink__c == Null ? '':RemoteTemplate.leankor__ProjectRoomLink__r.Name);
            Template.LinkProjectRoomId = (RemoteTemplate.leankor__ProjectRoomLink__c == Null ? '' :RemoteTemplate.leankor__ProjectRoomLink__c);
            Template.LinkValueStreamName = (RemoteTemplate.leankor__ValueStreamLink__c== Null ? '' :RemoteTemplate.leankor__ValueStreamLink__r.Name);
            Template.LinkValueStreamId = (RemoteTemplate.leankor__ValueStreamLink__c == Null ? '' :RemoteTemplate.leankor__ValueStreamLink__c);
            Template.ValueStreamCardLinkId = (RemoteTemplate.leankor__ValueStreamCardLink__c == Null ?'' :RemoteTemplate.leankor__ValueStreamCardLink__c);
            Template.ValueStreamCardLinkName = (RemoteTemplate.leankor__ValueStreamCardLink__c ==  Null  ? '':RemoteTemplate.leankor__ValueStreamCardLink__r.Name);
            Template.SmallPhotoUrl = UserRecords.get(RemoteTemplate.Owner.Id);
            Template.TaskCount = RemoteTemplate.leankor__TaskTemplates__r.size();         
            Template.CustomFieldCount = RemoteTemplate.leankor__Customfields__r.size();

            TemplateList.add(JSON.Serialize(Template));
        }
        */
        return TemplateList;
    }

    
    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to get Column And Category Records
    Inputs:         String VSID
    Returns:        RequiredData 
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static RequiredData getColumnAndCategory(String VSID) {
        RequiredData  returnRecords = new RequiredData(); 
        /*
        if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        List<leankor__KanbanCardTemplate__C> KanbanCardTemplates = leankor.RealTimeController.getKanbanCardTemplates(VSID);
        set<ColumnHierarchy> ColumnHierarchy = getColumnHierarchy(VSID);
        
        returnRecords.ColumnWithName = ColumnHierarchy;
        returnRecords.KanbanCardTemplates = KanbanCardTemplates;
        returnRecords.DefaultColumn = getdefultcolumn(VSID);
        */
        return returnRecords;
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Inner class is for Column records.
    ------------------------------------------------------------*/
    global class ColumnRecords {
        String ColumnId;
        String ColumnTitle;

        global ColumnRecords(String ColumnId, String ColumnTitle) {
            this.ColumnId = ColumnId;
            this.ColumnTitle = ColumnTitle; 
        }
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Inner class is for Column records with Column Hierarchy.
    ------------------------------------------------------------*/
    global class RequiredData {
        set<ColumnHierarchy> ColumnWithName;
        List<leankor__KanbanCardTemplate__c> KanbanCardTemplates;
        ColumnHierarchy DefaultColumn ;
    }
   

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Inner class is for Task Template.
    ------------------------------------------------------------*/
    global class TaskTemplate {
        global String Id;
        global String Subject;
        global String Description;
        global String OwnerId;
        global String OwnerName;
        global DateTime DueDate;
        global String AutomationTemplateId;
        global String Priority;
        global String Status;
        global String GUID;
        global String SmallPhotoUrl;
    }
  

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to create Task Template
    Inputs:         List<String> TaskLogs - (Json of Task template)
    Returns:        List<leankor__TaskTemplate__c> - (list of task template Object)
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static List<leankor__TaskTemplate__c> createTaskTemplate(List<String> TaskLogs) {
        List<leankor__TaskTemplate__c> NewTaskLogs = new List<leankor__TaskTemplate__c>();
        /*
        //Check CRUD / FLC behavior 
        TaskTemplateBehavior taskTemplateBehavior = new TaskTemplateBehavior();
        if (!taskTemplateBehavior.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        for (String tempTaskLog  : TaskLogs) {
            TaskTemplate TaskLog = (TaskTemplate) JSON.Deserialize(tempTAskLog, TaskTemplate.class);
            leankor__TaskTemplate__c NewTaskLog = New leankor__TaskTemplate__c();    
            NewTaskLog.Name = (TaskLog.Subject == ''? 'Other' :TaskLog.Subject);
            NewTaskLog.leankor__GUID__c = TaskLog.GUID;
            NewTaskLog.leankor__Description__c = TaskLog.Description;
            NewTaskLog.OwnerId = (TaskLog.OwnerId == '' ? UserInfo.getUserId() :TaskLog.OwnerId)   ;
            NewTaskLog.leankor__ActivityDate__c = TaskLog.DueDate;
            NewTaskLog.leankor__AutomationTemplate__c = TaskLog.AutomationTemplateId;
            NewTaskLog.leankor__Priority__c =  TaskLog.Priority;
            NewTaskLog.leankor__Status__c =  TaskLog.Status;

            NewTaskLogs.add(NewTaskLog);
        } 

        try {
            Database.insert(NewTaskLogs, true);
        } catch (DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        */   
        return NewTaskLogs;
    }
    

    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to get Task Template
    Inputs:         List<String> AutoLogID - (Json of Automation template)
    Returns:        List<String> - (list of task template in JSon)
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static List<String> getTaskTemplate(List<String> AutoLogID) {
        List<String> tasklist = new List<String>();
        /*
        UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }

        for(String automLog : AutoLogID){
            if (String.isNotBlank(automLog) && Util.getSObjectName(automLog) != 'leankor__AutomationTemplate__c') {
                throw new ProjectBoardCarouselException('Error: Invalid input');
            }
        }
        
        Set<String> UserID = new Set<String>();

        List<leankor__TaskTemplate__c> TaskRecords = [Select Id,
                                                                leankor__ActivityDate__c,
                                                                leankor__GUID__c,
                                                                leankor__AutomationTemplate__c,
                                                                leankor__Status__c,
                                                                leankor__Description__c,
                                                                leankor__Priority__c,
                                                                Name,
                                                                OwnerId,
                                                                Owner.Name 
                                                            From leankor__TaskTemplate__c 
                                                            Where leankor__AutomationTemplate__c In :AutoLogID 
                                                            With Security_Enforced
                                                            Limit 50000];
        for (leankor__TaskTemplate__c UserRecord : TaskRecords) {
            UserID.add(UserRecord.OwnerId);
        }

        List<User> users = [Select Id, 
                                    FirstName,
                                    Email, 
                                    LastName, 
                                    Name, 
                                    Username, 
                                    Alias, 
                                    UserRoleId, 
                                    SmallPhotoUrl  
                                From User 
                                Where Id In: UserID 
                                Limit 50000];
        Map<Id, String> UserRecords = new Map<Id, String>();
        for (User u : users) {
            UserRecords.put(u.Id,u.SmallPhotoUrl);
        }  

        for (leankor__TaskTemplate__c TaskRecord : TaskRecords) {
            TaskTemplate returntask = new TaskTemplate();
            returntask.Id = TaskRecord.Id;
            returntask.GUID = TaskRecord.leankor__GUID__c;
            returntask.Subject = (TaskRecord.Name == NULL ? '' :TaskRecord.Name);
            returntask.Status = TaskRecord.leankor__Status__c;
            returntask.Priority = TaskRecord.leankor__Priority__c;
            returntask.AutomationTemplateId = TaskRecord.leankor__AutomationTemplate__c;
            returntask.DueDate = TaskRecord.leankor__ActivityDate__c;
            returntask.OwnerId = TaskRecord.OwnerId;
            returntask.OwnerName = TaskRecord.Owner.Name;
            returntask.SmallPhotoUrl = UserRecords.get(TaskRecord.OwnerId);
            returntask.Description = TaskRecord.leankor__Description__c;

            tasklist.add(JSON.Serialize(returntask));
        }
        */
        return tasklist;
    }


    /*------------------------------------------------------------  
    Company:        Leankor
    Description:    This Method is used to delete Task Template
    Inputs:         List<String> TaskIDs - (Json of Task Template)
    Returns:        Boolean
    ------------------------------------------------------------*/
    
    @RemoteAction
    global static Boolean deleteTaskTemplate(List<String> TaskIDs) {
        /*
        for(String task : TaskIDs){
            if (String.isNotBlank(task) && Util.getSObjectName(task) != 'leankor__TaskTemplate__c') {
                throw new ProjectBoardCarouselException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior 
        TaskTemplateBehavior taskTemplateBehavior = new TaskTemplateBehavior();
        if (!taskTemplateBehavior.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__TaskTemplate__c> taskRecords = [Select Id, 
                                                            leankor__AutomationTemplate__c, 
                                                            leankor__GUID__c 
                                                        From leankor__TaskTemplate__c 
                                                        Where Id In :TaskIDs 
                                                        With Security_Enforced 
                                                        Limit 9999];
        
        for(leankor__TaskTemplate__c taskRecord : taskRecords) {
            taskRecord.leankor__AutomationTemplate__c = null;
        }

        try {
            Database.update(TaskRecords, true);
        } catch (DmlException e) {
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        */
        return true ;
    }


    /**
     * This Method use for Update Task Template .
     * Input : Json of Task Template
     * Output : True/false
     */
    
    @RemoteAction
    global static Boolean updateTaskTemplate(List<String> RemoteTaskLog) {
        /*
        //Check CRUD / FLC behavior 
        TaskTemplateBehavior taskTemplateBehavior = new TaskTemplateBehavior();
        if (!taskTemplateBehavior.isCreateable() ||
            !taskTemplateBehavior.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__TaskTemplate__c> updateTaskLogList = new List<leankor__TaskTemplate__c>();
        for (String tempRemoteTask : RemoteTaskLog) { 
            TaskTemplate RemoteTask = (TaskTemplate) JSON.Deserialize(tempRemoteTask, TaskTemplate.class);
            leankor__TaskTemplate__c tsk = new leankor__TaskTemplate__c();
            tsk.Name = RemoteTask.Subject;
            tsk.leankor__GUID__c = RemoteTask.GUID;
            tsk.leankor__Status__c =RemoteTask.Status;
            tsk.leankor__Priority__c = RemoteTask.Priority;
            tsk.leankor__AutomationTemplate__c = RemoteTask.AutomationTemplateId;
            tsk.leankor__ActivityDate__c = RemoteTask.DueDate;
            tsk.OwnerId = RemoteTask.OwnerID;
            tsk.leankor__Description__c = RemoteTask.Description;

            updateTaskLogList.add(tsk);
        }    

        List<DataBase.UpsertResult> uResults;
        try {
            Schema.Sobjectfield ExternField = leankor__TaskTemplate__c.Fields.leankor__GUID__c;
            uResults = Database.upsert(updateTaskLogList, ExternField, true);
        } catch (DmlException e) {
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        */
        return true;
    }


    /**
     * This Method is use to get project board records on LeankorJS end in LeankorJS vareable(Project Board inner class). 
     * Input : Project Room ID
     * Output : List of Valuestream Recods.
     */
    
    @Remoteaction
    global static List<leankor.realTimeController.ProjectBoard> getProjectBoards (String roomID) {
        List<leankor.realTimeController.ProjectBoard> pBoards = new List<leankor.realTimeController.ProjectBoard>();
        /*
        if (String.isNotBlank(roomID)  && Util.getSObjectName(roomID) != 'leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        List<leankor__ValueStream__c> VSLog = leankor.realTimeController.getValueStreams(roomID);
        
        
        for (leankor__ValueStream__c vs : VSLog) {
            leankor.RealTimeController.ProjectBoard pb = new leankor.RealTimeController.ProjectBoard();
            pb.Id = vs.Id;
            pb.Name =  vs.Name;
            pb.BoardType =  vs.leankor__BoardType__c;
            pb.ProjectRoom =  vs.leankor__ProjectRoom__c;

            pBoards.add(pb);
        }
        */
        return pBoards;
    }

    
    // This Inner Method  Use for Custom Field 
    global class FieldsValues {
        global String FieldLabel; // CustomFieldLabel ;
        global String FieldAPIName; //CustomFieldAPIName;
        global String KanbanLabel;
        global String KanbanAPIName;
        global String FieldType; // Type ;
        global String DataType;
        global Boolean isActive;
    }

    //
    // This Inner Method  Use to get Sobject Standard field with data type.
    // Input : AutomationTemplateId,Sobject Name.
    // Output : List of Filed Value (Inner class).
    //
    
    @RemoteAction
    global static List<FieldsValues> getSobjectFields(String AutomationTemplateId,String ObjectName){
        List<FieldsValues> result = new List<FieldsValues>();
        /*
        if (String.isNotBlank(AutomationTemplateId) && Util.getSObjectName(AutomationTemplateId) != 'leankor__AutomationTemplate__C') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        SObjectType accountType = Schema.getGlobalDescribe().get(ObjectName);
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        List<leankor__CustomFields__c> myCustomFields = [Select Id,
                                                                Name,
                                                                leankor__CustomFieldAPIName__c 
                                                            From leankor__CustomFields__c 
                                                            Where leankor__AutomationTemplate__c =:AutomationTemplateId 
                                                            With Security_Enforced
                                                            Limit 49999];
        Map<String,Boolean> tempCustomValues = new Map<String,Boolean>();
        for(leankor__CustomFields__c cf : myCustomFields){
            tempCustomValues.put(cf.leankor__CustomFieldAPIName__c,true);
        }
        for(Schema.SObjectField sfield :mfields.Values()){
            FieldsValues field = new FieldsValues();
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!dfield.isCustom()){
                field.FieldAPIName = dfield.getname();
                field.FieldLabel = dfield.getLabel();
                field.DataType = String.Valueof(dfield.getType());
                if(tempCustomValues.ContainsKey(field.FieldAPIName)){
                    field.isActive = true;
                }else{
                    field.isActive = false;
                }
                if(dfield.isCustom()){
                    field.FieldType = 'Custom';
                }else{
                    field.FieldType = 'Standard';
                }
                result.add(field);
            }
        }
        */
        return result;
    }


    //
    // This Method Use for Custom Field 
    // Input : Automation ID In Which JSON Save ,List of string Filed Value (Inner class).
    // Output : List Of JSONData of CustomFields
    //
    
    @RemoteAction
    global static List<leankor__CustomFields__c> manageCustomField(String AutomationTemplateId, List<String> JSONStrnigLogs){
        List<leankor__CustomFields__c> createLogs = New List<leankor__CustomFields__c>();
        /*
        if (String.isNotBlank(AutomationTemplateId) && Util.getSObjectName(AutomationTemplateId) != 'leankor__AutomationTemplate__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        CustomFieldsBehaviour customFieldsBehaviour = new CustomFieldsBehaviour();
        AutomationTemplateBehaviour automationTemplateBehaviour = new AutomationTemplateBehaviour();
        if (!customFieldsBehaviour.isDeletable() ||
            !customFieldsBehaviour.isCreateable() ||
            !automationTemplateBehaviour.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior 

        List<leankor__CustomFields__c> myCustomFields = [Select Id,
                                                                Name 
                                                            From leankor__CustomFields__c 
                                                            Where leankor__AutomationTemplate__c =:AutomationTemplateId 
                                                            With Security_Enforced
                                                            Limit 9999];
        if(myCustomFields.Size() > 0){
            try{
                    Database.Delete(myCustomFields,false);
                }catch(DMLException ex){
                    throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());   
                }
            }
            leankor__AutomationTemplate__C template = [Select Id,
                                                            Name,
                                                            leankor__GUID__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__KanbanCardTemplate__r.Name,
                                                            leankor__JSONData__c,
                                                            leankor__JSONDefinition__c 
                                                        From leankor__AutomationTemplate__c 
                                                        Where Id =:AutomationTemplateId
                                                        With Security_Enforced
                                                        Limit 1];
            String tempJSONDefinition = '{"showFields":{"title":"edit","forceid":"protected"},"modelFieldsToFlow":{ "kanbancard":{"forceid":"kanbanId"},"zone":{"forceid":"zoneId"},"global":{"vsId":"vsId","sessionId":"sessionId"}},"config":{"xtype":"fieldset","itemId":"formExtendPanelKanban","style":"font-size: .9em;","title":"Extended Info","instructions":"Card '+template.leankor__KanbanCardTemplate__r.Name+' Additional Info.","items":[';
            String tempString = '';        
            for(string ObjectLog  : JSONStrnigLogs){
                FieldsValues recordlog = (FieldsValues) JSON.Deserialize(ObjectLog, FieldsValues.class);
                leankor__CustomFields__c createLog =  New leankor__CustomFields__c();
                    createLog.leankor__AutomationTemplate__c = AutomationTemplateId;
                    createLog.leankor__CustomFieldAPIName__c = recordlog.FieldAPIName;
                    createLog.Name = recordlog.FieldLabel;
                    createLog.leankor__Kanbanlabel__c = recordlog.KanbanLabel;
                    createLog.leankor__KanbanAPIName__c = recordlog.KanbanAPIName;
                    createLog.leankor__Type__c = recordlog.FieldType;
                    createLogs.add(createLog);
                if(recordlog.DataType == 'BOOLEAN'){
                    tempString +='{"xtype" : "checkboxfield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'","labelAlign":"left"},';
                }else If(recordlog.DataType == 'TEXTAREA'){
                    tempString +='{"xtype" : "textareafield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'"},';
                }else If(recordlog.DataType == 'PERCENT'){
                    tempString +='{"xtype" : "sliderfield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'", "value" : 50 , "minValue" : 0 , "maxValue" : 100},';
                }else If(recordlog.DataType == 'CURRENCY' || recordlog.DataType == 'DOUBLE' || recordlog.DataType == 'INTEGER'){
                    tempString +='{"xtype" : "numberfield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'"},';
                }else If(recordlog.DataType == 'DATE' || recordlog.DataType == 'DATETIME'){
                    tempString +='{"xtype" : "datepickerfield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'"},';
                }else If(recordlog.DataType == 'PICKLIST'){
                    //tempString +='{"xtype" : "selectfield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'","options":[{"text":"First Option","value":"first"},{"text":"Second Option","value":"second"},{"text":"Third Option","value":"third"}]},';
                    tempString +='{"xtype" : "selectfield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'","options":[';
                    List<Schema.PicklistEntry> picklistValues = leankor.ProjectBoardCarousel.getPicklist('Opportunity', recordlog.FieldAPIName);
                    String picklistString = '';
                    for(Schema.PicklistEntry pl : picklistValues){
                        picklistString += '{"text":"'+pl.label+'","value":"'+pl.value+'"},';
                    }
                    if(picklistString != ''){
                        picklistString = picklistString.substring(0,picklistString.length()-1);
                    }                
                    tempString += picklistString+']},';
                }else{
                    tempString +='{"xtype" : "textfield", "name" : "'+recordlog.FieldAPIName+'", "label": "'+recordlog.FieldLabel+'"},';
                }       
            }
            if(tempString != ''){
                tempString = tempString.substring(0, tempString.length()-1);
                tempJSONDefinition += tempString+']}}';
            }else{
                tempJSONDefinition = '';
            }   
            if(createLogs.Size() > 0 ){
            try{
                Database.Insert(createLogs,false);
            }catch(DMLException ex){
                throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
            }
        } 
        template.leankor__JSONDefinition__c = tempJSONDefinition.escapeHtml4();
        template.leankor__JSONData__c ='{}';
        try{
            Database.Update(template,false);
        }catch(DMLException ex){
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        */
        return createLogs;
    } 


    // This Method Use to create Role Hierarchy.
    // Input : Automation ID In Which JSON Save ,List of string Filed Value (Inner class).
    // Output : List Of JSONData of CustomFields
    global class tempUserRoleClass {
        global String Id;
        global String Name;
        global String ParentRoleId;
        global Integer level;
    }


    global class RoleLog {
        global string Name ;
        global String RoleId;
        global Boolean leaf;
        global set<RoleLog> SubordinateRoles;
    }


    // This Method Use to create Role Hierarchy.
    // Input : Void
    // Output : List of List formate role Hierarchy.
    @RemoteAction
    global Static Set<RoleLog> getRoleHierarchy() {
        UserRoleBehaviour userRoleBehaviour = new UserRoleBehaviour();
        if (!userRoleBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        List<UserRole> allRole = [Select Id,
                                        Name, 
                                        ParentRoleId 
                                    From UserRole 
                                    Where PortalType = 'None' 
                                    Order By ParentRoleId Asc Nulls First 
                                    Limit 49999];
        Set<RoleLog> roleHierarchy = new Set<RoleLog>();
        RoleLog tempRole = new RoleLog();
        tempRole.leaf = false;
        tempRole.Name = 'RoleHierarchy';
        tempRole.SubordinateRoles = getSubordinateRoles(null, allRole);
        roleHierarchy.add(tempRole);
        
        return roleHierarchy;    
    } 


    // This method use for sub child of role.
    global static Set<RoleLog> getSubordinateRoles(String PID, List<UserRole> rolelist) {
        Set<RoleLog> remainingSubordinateRoles = new Set<RoleLog> ();
        for(UserRole children: rolelist)
        {
            if(children.ParentRoleId == PID)
            {
                RoleLog TempRole1 = New RoleLog();
                    TempRole1.RoleId = children.ID ;
                    TempRole1.Name = children.Name;
                    TempRole1.leaf = false;
                    TempRole1.SubordinateRoles = getSubordinateRoles(TempRole1.RoleId,rolelist);
                
                    if(TempRole1.SubordinateRoles.size() == 0){
                        TempRole1.leaf = true;
                    }
                
                remainingSubordinateRoles.add(TempRole1);
            } 
        } 

        return remainingSubordinateRoles;
    }


    // This Inner Method Use to column Hierarchy.
    global class ColumnHierarchy {
        global String ColumnName;
        global String ColumnId;
        global boolean leaf;
        global integer CountChild; 
        global Set<ColumnHierarchy> SubChildRecords;
    }


    // This Method Use to create Column Hierarchy.
    // Input : VSID for which Hierarchy.
    // Output : List Of JSONData of Column Hierarchy.
    @RemoteAction
    global static Set<ColumnHierarchy> getColumnHierarchy(String VSID) {
        if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        Set<ColumnHierarchy> columnWhite = new Set<ColumnHierarchy>();
        Set<ColumnHierarchy> finalHierarchys = new Set<ColumnHierarchy>();
        Set<ColumnHierarchy> ColumnPort = New Set<ColumnHierarchy>();
        leankor__ValueStream__c vsLog = [Select Id,
                                                Name,
                                                leankor__BoardType__c 
                                            From leankor__ValueStream__c 
                                            Where ID = :VSID
                                            With Security_Enforced];
        List<leankor__Zone__c> allZone = [Select Id,
                                                leankor__Swimlane__c,
                                                leankor__ValueStream__c,
                                                Name 
                                            From leankor__Zone__c 
                                            Where leankor__ValueStream__c = :VSID 
                                            With Security_Enforced
                                            Order By  leankor__Order__C ASC NULLS LAST 
                                            Limit 49999];
        
        if(VSLog.leankor__BoardType__c == 'Kanban Board'  || VSLog.leankor__BoardType__c == 'Plan Board'){
            List<leankor__MasterContainer__c> AllMC = [Select Id,
                                                            Name,
                                                            leankor__ValueStream__c  
                                                        From leankor__MasterContainer__c 
                                                        Where leankor__ValueStream__c = :VSID  
                                                        With Security_Enforced
                                                        Order By  leankor__Order__C ASC NULLS LAST  
                                                        Limit 49999];
            List<leankor__Swimlane__c> AllSwimlane = [Select Id,
                                                            leankor__MasterContainer__c,
                                                            leankor__ValueStream__c,
                                                            Name 
                                                        From leankor__Swimlane__c 
                                                        Where leankor__ValueStream__c =:VSID  
                                                        With Security_Enforced
                                                        Order By  leankor__Order__C ASC NULLS LAST  
                                                        LIMIT 49999];
            for(leankor__MasterContainer__c MCLog : AllMC){
                ColumnHierarchy FinalHierarchy = new ColumnHierarchy();
                    FinalHierarchy.ColumnName = MCLog.Name ;
                    FinalHierarchy.ColumnId = MCLog.Id;
                    FinalHierarchy.SubChildRecords = getchildSwimlane(FinalHierarchy.ColumnId,AllSwimlane,AllZone);
                    FinalHierarchy.leaf = false;
                    FinalHierarchy.CountChild = FinalHierarchy.SubChildRecords.size();
                  if(FinalHierarchy.CountChild == 1){
                        Set <ColumnHierarchy> tempList = new Set<ColumnHierarchy>();
                        for(ColumnHierarchy getsingleZoneID :FinalHierarchy.SubChildRecords){
                            set<ColumnHierarchy> delsw = new set<ColumnHierarchy>();
                            if(FinalHierarchy.SubChildRecords.size() == 1 && getsingleZoneID.SubChildRecords.size() > 1){
                                for(ColumnHierarchy singleZoneID : getsingleZoneID.SubChildRecords){
                                    ColumnHierarchy delSWs = new ColumnHierarchy();
                                        delSWs.ColumnName = singleZoneID.ColumnName ;
                                        delSWs.ColumnId = singleZoneID.ColumnId;
                                        delSWs.leaf = true ;
                                    delsw.add(delSWs);
                                   // getsingleZoneID.SubChildRecords;
                                }
                                tempList.add(getsingleZoneID);
                                FinalHierarchy.leaf = false;
                                FinalHierarchy.SubChildRecords = delsw;
                            }
                            if(getsingleZoneID.CountChild == 1){
                                FinalHierarchy.ColumnId = getsingleZoneID.ColumnId;
                                tempList.add(getsingleZoneID);
                                FinalHierarchy.leaf = true;
                                FinalHierarchy.CountChild = 0;
                            }  //End of IF
                        } 
                        FinalHierarchy.SubChildRecords.removeAll(tempList);
                  } // End of IF
                    if(FinalHierarchy.CountChild == 0){
                        FinalHierarchy.leaf = true;
                    } // End of If
                finalHierarchys.add(FinalHierarchy);
            }// End Of For Loop
        } else if(VSLog.leankor__BoardType__c == 'Whiteboard'){
                for(leankor__Zone__c zonelog :AllZone ){
                    ColumnHierarchy WBColumn = New ColumnHierarchy();
                        WBColumn.ColumnName = zonelog.Name ;
                        WBColumn.ColumnId = zonelog.ID;
                        WBColumn.leaf = true ;
                    columnWhite.add(WBColumn);
               }            
           // return columnWhite;
        }

        Set<ColumnHierarchy> ColumnHierarchys = new Set<ColumnHierarchy>();
        ColumnHierarchy Column = New ColumnHierarchy();
        Column.ColumnName = 'ColumnHierarchys' ;
        Column.ColumnId = '';
        if (VSLog.leankor__BoardType__c == 'Kanban Board' || VSLog.leankor__BoardType__c == 'Plan Board') {
            Column.SubChildRecords = finalHierarchys ;
        } else if (VSLog.leankor__BoardType__c == 'Portfolio View') {
            Column.SubChildRecords = ColumnPort ;
        } else if (VSLog.leankor__BoardType__c == 'Whiteboard') {
            Column.SubChildRecords = columnWhite ;
        }
        Column.leaf = false;
        ColumnHierarchys.add(Column);
        
        return ColumnHierarchys;
    }


    global static Set<ColumnHierarchy> getchildSwimlane(String MCId, List<leankor__Swimlane__c> swList, List<leankor__Zone__c> Zonelist) {
        Set<ColumnHierarchy> SwimlaneHierarchys = New Set<ColumnHierarchy>();
        List<ColumnHierarchy> tempList = new List<ColumnHierarchy>();
        for (leankor__Swimlane__c swLog : swList) {
            if (swLog.leankor__MasterContainer__c == MCId) {
                ColumnHierarchy SWHierarchy = New ColumnHierarchy();
                    SWHierarchy.ColumnName = swLog.Name ;
                    SWHierarchy.ColumnId = swLog.Id;
                    SWHierarchy.SubChildRecords = getchildZone(SWHierarchy.ColumnId,Zonelist);
                    SWHierarchy.leaf = false;
                    SWHierarchy.CountChild = SWHierarchy.SubChildRecords.size();
                    if(SWHierarchy.CountChild == 1){
                        for(ColumnHierarchy getchildZoneID :SWHierarchy.SubChildRecords){
                            SWHierarchy.ColumnId = getchildZoneID.ColumnId;
                            tempList.add(getchildZoneID);
                            SWHierarchy.leaf = true;
                        } 
                        SWHierarchy.SubChildRecords.removeAll(tempList);
                    }//End of IF
                    if(SWHierarchy.SubChildRecords.size() == 0){
                        SWHierarchy.leaf = true;
                    } // End of If
                SwimlaneHierarchys.add(SWHierarchy); 
            } // End of If  
        }// End Of For Loop

        return SwimlaneHierarchys;
    }


    global static Set<ColumnHierarchy> getchildZone(String SWId, List<leankor__Zone__c> zonedata) {
        Set<ColumnHierarchy> ZoneHierarchys = New Set<ColumnHierarchy>();
        
        for (leankor__Zone__c zoneLog : zonedata) {
            if (zoneLog.leankor__Swimlane__c == SWId) {
                ColumnHierarchy ZoneHierarchy = New ColumnHierarchy();
                ZoneHierarchy.ColumnName = zoneLog.Name ;
                ZoneHierarchy.ColumnId = zoneLog.Id;
                ZoneHierarchy.leaf = true;
                ZoneHierarchy.CountChild = 0;

                ZoneHierarchys.add(ZoneHierarchy);  
            } 
        }
        return ZoneHierarchys;
    }


    // Method link with columnHierarchy to get sub column. 
    global static Set<String> GetDownrolesId(String RoleID, List<UserRole> AllRole) {
        Set<String> setRolesID = new Set<String>();
        setRolesID.add(RoleID);
        Set<String> holdItemsToAdd = new Set<String>();
        for (integer i = 0; i <= 7; i++) {
            for(String setRoleID : setRolesID){
                for(UserRole RoleLog : AllRole){
                    if(RoleLog.ParentRoleId == setRoleID){
                        holdItemsToAdd.add(RoleLog.ID);
                    }
                }
            }
        }
        setRolesID.addAll(holdItemsToAdd);

        return setRolesID;
    }
    

    // This Method Use to Get Default Column .
    // Input : VSID for which Defalut Column records 
    // Output : get default column records (left most)
    
    global static ColumnHierarchy getdefultcolumn(String VSID){
        ColumnHierarchy white = New ColumnHierarchy();
        /*
        white.ColumnName = '';
        white.ColumnId = '';
        Leankor__ValueStream__c VSLog = [Select Id,
                                                Name,
                                                Leankor__BoardType__c 
                                            From Leankor__ValueStream__c 
                                            Where Id = :VSID 
                                            With Security_Enforced
                                            Limit 1];
        if(VSLog.Leankor__BoardType__c == 'Kanban Board'){
            Leankor__MasterContainer__C MC = [Select Id,
                                                    Name,
                                                    (Select Id, 
                                                            Name, 
                                                            Leankor__MasterContainer__c, 
                                                            Leankor__ValueStream__c 
                                                        From Leankor__MasterContainer__c.Leankor__Swimlanes__r) 
                                                From Leankor__MasterContainer__c 
                                                Where Leankor__ValueStream__c =:VSID 
                                                With Security_Enforced
                                                Order By Leankor__Order__C ASC NULLS LAST 
                                                Limit 1];
            
            integer mcSwimlanesCount = 0;
            for(Leankor__Swimlane__c ln: MC.Leankor__Swimlanes__r){
                if(ln.Leankor__ValueStream__C != null){
                    mcSwimlanesCount += 1;
                }
            }

            Leankor__Swimlane__C Swimlane = [Select Id,
                                                    Name,
                                                    (Select Id, 
                                                            Name, 
                                                            Leankor__Swimlane__C, 
                                                            Leankor__ValueStream__C 
                                                        From Leankor__Swimlane__C.Leankor__Zones__r) 
                                                From Leankor__Swimlane__C 
                                                Where Leankor__ValueStream__C =:VSID 
                                                    And Leankor__MasterContainer__C =:MC.Id 
                                                With Security_Enforced
                                                Order By Leankor__Order__C ASC NULLS LAST 
                                                Limit 1];
            
            integer swimlaneZoneCount = 0;
            String zoneName = '';
            for(Leankor__Zone__c zone: Swimlane.Leankor__Zones__r){
                if(zone.Leankor__ValueStream__C != null){
                    swimlaneZoneCount += 1;

                    if(String.isBlank(white.ColumnName)){
                        white.ColumnName =  zone.Name;
                        zoneName = zone.Name;
                    }

                    if(String.isBlank(white.ColumnId)){
                        white.ColumnId =  zone.Id;
                    }
                }
            }

            if(mcSwimlanesCount == 1 && swimlaneZoneCount == 1){
                white.ColumnName = MC.Name;
            }else if(mcSwimlanesCount == 1 && swimlaneZoneCount > 1){
                white.ColumnName = zoneName;
            }else if(mcSwimlanesCount > 1 && swimlaneZoneCount == 1){
                white.ColumnName = Swimlane.Name;
            }
        }
        */
        return white;  
    }

    
    @RemoteAction
    global static Map<String,PastDue> getUserWorkStatus(String VS) { 
        Map<String,PastDue> PersonMap = new Map<String,PastDue>();
        /*
        UserBehaviour userBehaviour = new UserBehaviour();
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!userBehaviour.isAccessible() ||
            !taskBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }

        if (String.isNotBlank(VS) && Util.getSObjectName(VS) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        Set<String> UsereID = New Set<String>();
        Map<String, String> UserRecords = new Map<String, String>();
        
        Map<String, List<Task>> TaskDueMap= new Map<String, List<Task>>();
        // Tilak - 05/03/2020 - Changes for filtering soft deleted record and removing null condition in where clause.
        List<leankor__KanbanCard__c> CardsDue = [Select leankor__PercentComplete2__c,
                                                        leankor__ValueStream__C, 
                                                        OwnerId,
                                                        Owner.Name 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__c  =:VS 
                                                        And leankor__isRecordDeleted__c = false
                                                    With Security_Enforced
                                                    Limit 9999];

        if(CardsDue.size()<0) {
            return null;
        } else{
            // query task records and put results in a list         
            for(Task tk : [Select OwnerId,
                                Owner.Name,
                                Status,
                                WhatId
                            From Task 
                            Where What.Type = 'leankor__KanbanCard__c' 
                                And IsDeleted = false 
                                And WhatId In :CardsDue
                            limit 9999
                            All Rows]) {
                 List<Task> tempTaskList = TaskDueMap.containsKey(tk.WhatId) ? TaskDueMap.get(tk.WhatId) : new List<Task>();
                 tempTaskList.add(tk);
                 TaskDueMap.put(tk.WhatId, tempTaskList);
            }
        }       
        for(leankor__KanbanCard__c ar: CardsDue){
            PastDue pd= PersonMap.get(ar.OwnerId);
            if(pd != Null){
                pd.NumberOfCardsCompleted = (ar.leankor__PercentComplete2__c == 100 ? pd.NumberOfCardsCompleted +1 : pd.NumberOfCardsCompleted) ;
                pd.NumberOfCardsDue = pd.NumberOfCardsDue +1;
                //UsereID.add(ar.OwnerId);
                PersonMap.put(ar.OwnerId,pd);
                if(TaskDueMap.get(ar.Id) != null && TaskDueMap.get(ar.Id).size()>0)
                {
                    for(Task Tasklog :TaskDueMap.get(ar.Id)){
                        PastDue pdt= PersonMap.get(Tasklog.OwnerId);
                        if(pdt != Null){
                            pdt.NumberOfTaskCompleted = (Tasklog.Status == 'Completed'?pdt.NumberOfTaskCompleted +1 : pdt.NumberOfTaskCompleted) ;
                            pdt.NumberOfTaskDue = pdt.NumberOfTaskDue+1;
                            //UsereID.add(Tasklog.OwnerId);
                            PersonMap.put(Tasklog.OwnerId,pdt);
                        }else{
                            integer addNumberOfTaskCompleted = (Tasklog.Status == 'Completed'? 1 :0) ;
                            //integer addNumberOfTaskDue = 1;
                            UsereID.add(Tasklog.OwnerId);
                            PersonMap.put(Tasklog.OwnerId,New pastDue(Tasklog.Owner.Name,'',0,0,1,addNumberOfTaskCompleted));
                        }
                    }
                }
            }else{
                integer addNumberOfCardsCompleted = (ar.leankor__PercentComplete2__c == 100 ? 1 : 0 ) ;
                UsereID.add(ar.OwnerId);
                PersonMap.put(ar.OwnerId,New pastDue(ar.Owner.Name,'',addNumberOfCardsCompleted,1,0,0));
                if(TaskDueMap.get(ar.Id) != null && TaskDueMap.get(ar.Id).size()>0)
                {
                    for(Task Tasklog :TaskDueMap.get(ar.Id)){
                        PastDue pdt= PersonMap.get(Tasklog.OwnerId);
                        if(pdt != Null){
                            pdt.NumberOfTaskCompleted = (Tasklog.Status == 'Completed'?pdt.NumberOfTaskCompleted +1 : pdt.NumberOfTaskCompleted) ;
                            pdt.NumberOfTaskDue = pdt.NumberOfTaskDue+1;
                            //UsereID.add(Tasklog.OwnerId);
                            PersonMap.put(Tasklog.OwnerId,pdt);
                        }else{
                            integer addNumberOfTaskCompleted = (Tasklog.Status == 'Completed'? 1 :0) ;
                            //integer addNumberOfTaskDue = 1;
                            UsereID.add(Tasklog.OwnerId);
                            PersonMap.put(Tasklog.OwnerId,New pastDue(Tasklog.Owner.Name,'',0,0,1,addNumberOfTaskCompleted));
                        }
                    }
                }   
            }
        }
        //ss 29.03.2018
        List<User> users = [Select Id, 
                                    FirstName,
                                    Email, 
                                    LastName, 
                                    Name, 
                                    Username, 
                                    Alias,
                                    UserRoleId, 
                                    SmallPhotoUrl  
                                From User 
                                Where Id In :UsereID 
                                Limit 49999];
        for(User u : users){
            PastDue pdUser= PersonMap.get(u.id);
            pdUser.PersonPhotoUrl = u.SmallPhotoUrl;
            PersonMap.put(u.id,pdUser);
        } 
        */
        return PersonMap;
    }


    @RemoteAction
    global static boolean getFirstInstallValue() {
       leankor__LeanConstants__c LeanConstant= leankor__LeanConstants__c.getInstance();
       return LeanConstant.leankor__FirstInstall__c;
    }

    
    @RemoteAction
    global static leankor.ProjectBoardCarousel.portfoliodata getSampleBoard() {
        leankor.ProjectBoardCarousel.portfoliodata sampleRoom = new leankor.ProjectBoardCarousel.portfoliodata();
        /*
        //Check CRUD / FLC behavior
        KanbanCardBehaviour KanbanCardBehaviour = new KanbanCardBehaviour();
        if (!KanbanCardBehaviour.isCreateable() ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor.ProjectBoardCarousel.portfoliodata> sampledata = new List<leankor.ProjectBoardCarousel.portfoliodata>();
        leankor.ProjectBoardCarousel.portfoliodata samplelog = new leankor.ProjectBoardCarousel.portfoliodata();
        samplelog.name= 'Sample Folder';
        sampledata.add(samplelog);
        List<leankor.ProjectBoardCarousel.portfoliodata> sampleportfolio =createPortfolio(sampledata);
        samplelog.Name = 'Sample Project';
        samplelog.ParentPortfolio = sampleportfolio[0].ID;
        leankor.ProjectBoardCarousel.portfoliodata SampleRoom = createProjects(samplelog);
        leankor.RealTimeController.ProjectBoard SampleBoard = leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Kanban Board','','');
        list<leankor__KanbanCardTemplate__c> kctId  = [Select Id 
                                                            From leankor__KanbanCardTemplate__c 
                                                            Where leankor__ValueStream__c = :SampleBoard.Id
                                                            With Security_Enforced 
                                                            Limit 9999];
        
        leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
        Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 :leanConstant.leankor__FirstDayOfTheWeek__c.intValue();         
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
        
        //Check today is working day if not then get next working day date.
        DateTime currentWorkingDayDateTime = workWeek.isWorkingDay(system.now().format('EEEE'))?system.now():Util.readNextWorkingDateTime(workWeek,System.now());
 
        leankor__KanbanCard__c samplecard  = new leankor__KanbanCard__c();
        samplecard.Name ='Sample card';
        samplecard.OwnerId=userinfo.getuserid();
        samplecard.leankor__DescriptionLong__c ='This is a sample long description of the work details';
        samplecard.leankor__Title__c ='Sample work item';
        samplecard.leankor__ValueStream__c = Sampleboard.ID;
        //SS 22.05.2018
        //Dates are assigning after check for current day is WorkingDay 
        samplecard.leankor__StartDatetime__c = currentWorkingDayDateTime; 
        samplecard.leankor__DueDateTime__c = currentWorkingDayDateTime;
        //samplecard.leankor__StartDatetime__c = system.now();
        //samplecard.leankor__DueDateTime__c = system.Now();
        //SS 22.05.2018
        samplecard.leankor__EstimatedDuration__c = 1;
        samplecard.leankor__GUID__c = system.now() +'ONLOAD';
        samplecard.leankor__KanbanCardTemplate__c = kctId[0].Id;

        try {
            DataBase.insert(samplecard,false);
        } catch (DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__LeanConstants__c> Customsetting = [SELECT Id, leankor__FirstInstall__c FROM leankor__LeanConstants__c LIMIT 9999];
        for (leankor__LeanConstants__c updatelog :Customsetting ) {
            updatelog.leankor__FirstInstall__c = false;
        }

        try {
            DataBase.update(Customsetting, false);
        } catch (DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        */
        return SampleRoom; 
    }   


    // This for only new carousal design
    global class ProjectRoomHierarchy {
        global string Id;
        global string Name;
        global String BoardType;
        global boolean leaf;
        global List<ProjectRoomHierarchy> ChildRecords;
        global string CssLayout;
        global String RoomId;
        global string ValueStreamLinkID;
        global string ValueStreamCardLink;
        global string KanbanCardId;  
        global String UrlLink;
        public boolean hasEditAccess;
        public boolean hasReadAccess;
        public boolean hasDeleteAccess; 
        public boolean disableCalendarView;
    }
    
    
    //RS 22.04.2019 Modified method for security role changes
    @RemoteAction
    global static List <ProjectRoomHierarchy> getProjectBoardHierarchy(String projectRoomID, String RoomName) {   	
        if (String.isNotBlank(projectRoomID) && Util.getSObjectName(projectRoomID) != 'leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        } 	
		List<ProjectRoomHierarchy> setOfRoom = new List<ProjectRoomHierarchy>();
		Set<String> hierarchyView = new Set<String>();		
		// Checks object level security
		Boolean hasCreateAccessForVS = leankor__ValueStream__c.sObjectType.getDescribe().isCreateable(); 
		Boolean hasReadAccessForVS =leankor__ValueStream__c.sObjectType.getDescribe().isAccessible();	
					
		List<leankor__ProjectRoom__c> projectRoom = [select id, UserRecordAccess.HasEditAccess from leankor__ProjectRoom__c where id = : projectRoomID limit 1];	
	    // Date: 27/04/19   To get valuestream records without security enforce. 
	    List <leankor__ValueStream__c> valuestreams = RealTimeControllerHelper.readDefaultBoard(projectRoomID);		    
	    //RS 22.04.2019 Added read,edit,delete access fields
	    /*List < leankor__ValueStream__c > valuestreams = [SELECT Id, leankor__UrlLink__c, leankor__BoardType__c, leankor__ValueStreamLink__c,
														leankor__ValueStreamCardLink__c, leankor__ProjectRoom__c, leankor__ProjectRoom__r.name,
														Name, UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess,
														UserRecordAccess.HasReadAccess,leankor__ProjectRoom__r.UserRecordAccess.HasEditAccess FROM leankor__ValueStream__c
														WHERE leankor__ProjectRoom__c = : projectRoomID and leankor__IsRecordDeleted__c = false
														ORDER BY Name limit 49999];*/	   	
															       	  
        /** Date: 18/09/2019 - To overcome the limit of 200 records of UserRecordAccess object*/ 
        Map <Id, leankor__ValueStream__c> vsSecurityMap = new Map<Id,leankor__ValueStream__c>([SELECT Id,
                                                                                            UserRecordAccess.HasEditAccess,
                                                                                            UserRecordAccess.HasReadAccess,
                                                                                            UserRecordAccess.HasDeleteAccess 
                                                                                        FROM leankor__ValueStream__c 
                                                                                        WHERE Id in : valuestreams]);                                                      	
															       	  
		List <leankor__ProjectLaunchBehavior__c> projectSetup = [Select Id, 
                                                                        leankor__Module__c, 
                                                                        leankor__Module__r.Name,
																        leankor__Module__r.leankor__Boardtype__c, 
                                                                        leankor__Project__c
																    From leankor__ProjectLaunchBehavior__c 
                                                                    Where leankor__Project__c = : projectRoomID
                                                                    With Security_Enforced 
                                                                    Limit 49999];	
		
		for (leankor__ProjectLaunchBehavior__c projectLaunchBehaviorLog: projectSetup) {
			hierarchyView.add(projectLaunchBehaviorLog.leankor__Module__r.leankor__Boardtype__c);
			hierarchyView.add(projectLaunchBehaviorLog.leankor__Module__r.Name);
		}		
		
		List < ProjectRoomHierarchy > tempPlanBoard = boardHierarchy(projectRoomID, 'Plan Board', valuestreams);
		List < ProjectRoomHierarchy >  tempUberBoard = boardHierarchy(projectRoomID, 'UberBoard', valuestreams);
		List < ProjectRoomHierarchy >  tempDash = boardHierarchy(projectRoomID, 'DashBoard', valuestreams); 
		   
		if(hasReadAccessForVS){
					
			if (tempUberBoard.size() > 0) {				
				//if(tempUberBoard[0].hasReadAccess){
                if(vsSecurityMap.containsKey(tempUberBoard[0].Id) ){    
					ProjectRoomHierarchy uberBoard = new ProjectRoomHierarchy();
                    uberBoard.Id = tempUberBoard[0].Id;
                    // 19-06-2020 Changes for implement edit board name feature for PG.
					uberBoard.Name = tempUberBoard[0].Name;
					uberBoard.ChildRecords = new List < ProjectRoomHierarchy > ();
					uberBoard.CssLayout = 'advanceoption';
					uberBoard.BoardType = 'UberBoard';
                    uberBoard.RoomId = projectRoomID;
                
					//uberBoard.CssLayout = 'advanceoption lmenuoption';
					//uberBoard.hasReadAccess = tempUberBoard[0].hasReadAccess;
		            //uberBoard.hasEditAccess = tempUberBoard[0].hasEditAccess;
		            //uberBoard.hasDeleteAccess = tempUberBoard[0].hasDeleteAccess;
                    uberBoard.hasReadAccess = true;    
                    uberBoard.hasEditAccess = vsSecurityMap.get(tempUberBoard[0].Id).UserRecordAccess.hasEditAccess;
                    uberBoard.hasDeleteAccess = vsSecurityMap.get(tempUberBoard[0].Id).UserRecordAccess.hasDeleteAccess;
                    uberBoard.disableCalendarView=tempUberBoard[0].disableCalendarView;
					
					if (hierarchyView.contains('_System_UberBoard')) {
						setOfRoom.add(uberBoard);
					}
				}
			} else {			
				if(hasCreateAccessForVS){		
					leankor.RealTimeController.ProjectBoard newUberBoard = leankor.ProjectBoardCarousel.createProjectBoard('Plan Board(' + RoomName + ')', projectRoomID, 'UberBoard', '', '');
					ProjectRoomHierarchy uberBoard = new ProjectRoomHierarchy();
					uberBoard.Id = uberBoard.Id;
					uberBoard.Name = newUberBoard.Name;
					uberBoard.ChildRecords = new List < ProjectRoomHierarchy > ();
					uberBoard.BoardType = 'UberBoard';
					uberBoard.CssLayout = 'advanceoption';
					uberBoard.RoomId = projectRoomID;
					uberBoard.CssLayout = 'advanceoption lmenuoption';
					uberBoard.hasReadAccess = newUberBoard.hasReadAccess;
		            uberBoard.hasEditAccess = newUberBoard.hasEditAccess;
		            uberBoard.hasDeleteAccess = newUberBoard.hasDeleteAccess;
					if (hierarchyView.contains('_System_UberBoard')) {
						setOfRoom.add(uberBoard);
					}
				}
			}	
			
			if (tempPlanBoard.size() > 0) {
				//if(tempPlanBoard[0].hasReadAccess){
                if(vsSecurityMap.containsKey(tempPlanBoard[0].Id)){        
					ProjectRoomHierarchy planBoard = new ProjectRoomHierarchy();
					planBoard.Id = tempPlanBoard[0].Id;
                    // 19-06-2020 Changes for implement edit board name feature for Roll-up board.
					planBoard.Name = tempPlanBoard[0].Name;
					planBoard.ChildRecords = new List < ProjectRoomHierarchy > ();
					planBoard.CssLayout = 'advanceoption';
					planBoard.BoardType = 'Plan Board';
					planBoard.RoomId = projectRoomID;
					//planBoard.hasReadAccess = tempPlanBoard[0].hasReadAccess;
		            //planBoard.hasEditAccess = tempPlanBoard[0].hasEditAccess;
		            //planBoard.hasDeleteAccess = tempPlanBoard[0].hasDeleteAccess;
                    planBoard.hasReadAccess = true;    
                    planBoard.hasEditAccess = vsSecurityMap.get(tempPlanBoard[0].Id).UserRecordAccess.hasEditAccess;
                    planBoard.hasDeleteAccess = vsSecurityMap.get(tempPlanBoard[0].Id).UserRecordAccess.hasDeleteAccess;
					if (hierarchyView.contains('_System_PlanBoard')) {
						setOfRoom.add(planBoard);
					}
					planBoard.disableCalendarView=tempPlanBoard[0].disableCalendarView;
			  }
			} else {			
				if(hasCreateAccessForVS){	
					leankor.RealTimeController.ProjectBoard newPlanBoard = leankor.ProjectBoardCarousel.createProjectBoard('Roll-Up(' + RoomName + ')', projectRoomID, 'Plan Board', '', '');
					ProjectRoomHierarchy planBoard = new ProjectRoomHierarchy();
					planBoard.Id = newPlanBoard.Id;
					planBoard.Name = newPlanBoard.Name;
					planBoard.ChildRecords = new List < ProjectRoomHierarchy > ();
					planBoard.BoardType = 'Plan Board';
					planBoard.CssLayout = 'advanceoption';
					planBoard.RoomId = projectRoomID;
					planBoard.hasReadAccess = newPlanBoard.hasReadAccess;
		            planBoard.hasEditAccess = newPlanBoard.hasEditAccess;
		            planBoard.hasDeleteAccess = newPlanBoard.hasDeleteAccess;
					if (hierarchyView.contains('_System_PlanBoard')) {
						setOfRoom.add(planBoard);
					}
				}
			}
				
			ProjectRoomHierarchy projRoomHierarchy = new ProjectRoomHierarchy();
			projRoomHierarchy.Id = 'Project Boards';
            projRoomHierarchy.Name = 'ProjectBoards';
			projRoomHierarchy.RoomId = projectRoomID;

			//Instead of ReadRecordSecurity we are now using reference fields from sObject
			//i.e. UserRecordAccess.HasEditAccess from leankor__ValueStream__c
            /**
            projRoomHierarchy.ChildRecords = boardHierarchy(projectRoomID, 'Kanban Board', valuestreams); 
			*/
            List <ProjectRoomHierarchy> projectBoardList = new List <ProjectRoomHierarchy>();
            for(ProjectRoomHierarchy board : boardHierarchy(projectRoomID, 'Kanban Board', valuestreams)){
                board.hasReadAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.HasReadAccess : false;    
                board.hasEditAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasEditAccess : false;
                board.hasDeleteAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasDeleteAccess : false;
                projectBoardList.add(board);
            }
            projRoomHierarchy.ChildRecords = projectBoardList;

			if (hierarchyView.contains('_System_Board')) {
				setOfRoom.add(projRoomHierarchy);
			}		
				
			ProjectRoomHierarchy whiteBoard = new ProjectRoomHierarchy();
			whiteBoard.Id = 'Whiteboards';
			whiteBoard.Name = 'Whiteboards';
			whiteBoard.RoomId = projectRoomID;
			/** Date : 18/09/2019
            whiteBoard.ChildRecords = boardHierarchy(projectRoomID, 'WhiteBoard', valuestreams); */
            List <ProjectRoomHierarchy> whiteBoardList = new List <ProjectRoomHierarchy>();
            for(ProjectRoomHierarchy board : boardHierarchy(projectRoomID, 'WhiteBoard', valuestreams)){
                board.hasReadAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.HasReadAccess : false;    
                board.hasEditAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasEditAccess : false;
                board.hasDeleteAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasDeleteAccess : false;
                whiteBoardList.add(board);
            }
            whiteBoard.ChildRecords = whiteBoardList;

			if (hierarchyView.contains('_System_Whiteboard')) {
				setOfRoom.add(whiteBoard);
			}	
					
			if (tempDash.size() > 0  ) {		
				// Date: 03/04/2019 - Only those dashboard are added those have read only access.
				List <ProjectRoomHierarchy> tempDashWithAccess = new List <ProjectRoomHierarchy>();
				for(ProjectRoomHierarchy dashBoardInstance: tempDash){
					/**if(dashBoardInstance.hasReadAccess){
						tempDashWithAccess.add(dashBoardInstance);
					}*/
                    if(vsSecurityMap.containsKey(dashBoardInstance.Id)){
                    	//On dashboard all the action were disabled
                    	//Issue occured after changes done to remove use of UserRecordSecurity 
                    	dashBoardInstance.hasReadAccess = vsSecurityMap.get(dashBoardInstance.Id).UserRecordAccess.HasReadAccess;    
                		dashBoardInstance.hasEditAccess = vsSecurityMap.get(dashBoardInstance.Id).UserRecordAccess.hasEditAccess;
                		dashBoardInstance.hasDeleteAccess = vsSecurityMap.get(dashBoardInstance.Id).UserRecordAccess.hasDeleteAccess;
                        tempDashWithAccess.add(dashBoardInstance);
					}
				}
				
				ProjectRoomHierarchy dashBoard = new ProjectRoomHierarchy();
				dashBoard.Id = 'Dashboards';
				dashBoard.Name = 'Dashboards';
				dashBoard.RoomId = projectRoomID;
				dashBoard.ChildRecords = tempDashWithAccess;
				if (hierarchyView.contains('_System_DashBoard')) {
					setOfRoom.add(dashBoard);
				}
				
			} else {
		        if(hasCreateAccessForVS ){
					leankor.RealTimeController.ProjectBoard newDashBoard = leankor.ProjectBoardCarousel.createProjectBoard(RoomName + ' DashBoard', projectRoomID, 'DashBoard', '', '');
					ProjectRoomHierarchy dashBoard = new ProjectRoomHierarchy();
					dashBoard.Id = 'Dashboards';
					dashBoard.Name = 'Dashboards';
					dashBoard.RoomId = projectRoomID;
					List < ProjectRoomHierarchy > setDashBoards = new List < ProjectRoomHierarchy > ();
					ProjectRoomHierarchy dashBoardHierarchy = new ProjectRoomHierarchy();
					dashBoardHierarchy.Id = newDashBoard.Id;
					dashBoardHierarchy.Name = RoomName + ' DashBoard';
					dashBoardHierarchy.BoardType = 'DashBoard';
					dashBoardHierarchy.leaf = true;
					dashBoardHierarchy.hasReadAccess = newDashBoard.hasReadAccess;
			        dashBoardHierarchy.hasEditAccess = newDashBoard.hasEditAccess;
			        dashBoardHierarchy.hasDeleteAccess = newDashBoard.hasDeleteAccess;
					setDashBoards.add(dashBoardHierarchy);
					dashBoard.ChildRecords = setDashBoards;
					if (hierarchyView.contains('_System_DashBoard')) {
						setOfRoom.add(dashBoard);
					}
		        }
			}	
					
			ProjectRoomHierarchy portfolioView = new ProjectRoomHierarchy();
			portfolioView.Id = 'Portfolio View';
            portfolioView.Name = 'PortfolioView';
			portfolioView.RoomId = projectRoomID;
			/** Date: 18/09/2019
            portfolioView.ChildRecords = boardHierarchy(projectRoomID, 'Portfolio View', valuestreams);*/          
            List <ProjectRoomHierarchy> portfolioBoardList = new List <ProjectRoomHierarchy>();
            for(ProjectRoomHierarchy board : boardHierarchy(projectRoomID, 'Portfolio View', valuestreams)){
                board.hasReadAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.HasReadAccess : false;    
                board.hasEditAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasEditAccess : false;
                board.hasDeleteAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasDeleteAccess : false;
                portfolioBoardList.add(board);
            }
            portfolioView.ChildRecords = portfolioBoardList;

			if (portfolioView.ChildRecords.Size() > 0) {
				setOfRoom.add(portfolioView);
			}
		
			ProjectRoomHierarchy cardHierarchy = new ProjectRoomHierarchy();
			cardHierarchy.Id = 'Card Hierarchy';
            cardHierarchy.Name = 'CardHierarchy';
			cardHierarchy.RoomId = projectRoomID;
			/** Date: 18/09/2019
            cardHierarchy.ChildRecords = boardHierarchy(projectRoomID, 'Card Hierarchy', valuestreams);*/
            List <ProjectRoomHierarchy> boardHierarchyList = new List <ProjectRoomHierarchy>();
            for(ProjectRoomHierarchy board : boardHierarchy(projectRoomID, 'Card Hierarchy', valuestreams)){
                board.hasReadAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.HasReadAccess : false;    
                board.hasEditAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasEditAccess : false;
                board.hasDeleteAccess = vsSecurityMap.containsKey(board.Id) ? vsSecurityMap.get(board.Id).UserRecordAccess.hasDeleteAccess : false;
                boardHierarchyList.add(board);
            }
            cardHierarchy.ChildRecords = boardHierarchyList;

			if (cardHierarchy.ChildRecords.Size() > 0) {
				setOfRoom.add(cardHierarchy);
			}
			
			//*Note - We can move Network related common code to a new class
			
			//For community need to add community suffix name in the Url of Expenses and ProjectSetup
			String networkId =Network.getNetworkId() ;
			if(String.isNotBlank(networkId)){
				for(sObject tempNetwork : Database.query('Select Id, UrlPathPrefix from Network where id = : networkId')){
					if(tempNetwork.get('UrlPathPrefix')!=null){
						 //If suffix exists then replace networkId with community suffix name
						 networkId = (String)tempNetwork.get('UrlPathPrefix');
					} else{
						//If community does not have any suffix then make networkId blank
						networkId= '';
					}
				}
			}	
			if(projectRoom[0].UserRecordAccess.HasEditAccess){
				ProjectRoomHierarchy expenses = new ProjectRoomHierarchy();
				//If user is in community add Community suffix name to Url
				expenses.Id='';
				if(String.isNotBlank(networkId)){
					expenses.Id = networkId+'/';
				}
				expenses.Id += 'apex/leankor__ExpensesPage?RID=' + projectRoomID;

				expenses.Name = 'Financials';
				expenses.RoomId = projectRoomID;
				expenses.ChildRecords = new List < ProjectRoomHierarchy > ();
			
				expenses.CssLayout = 'advanceoption lmenuoption';
				if (hierarchyView.contains('Financials')) {
					setOfRoom.add(expenses);
				}		
			}		
			
			ProjectRoomHierarchy projectSettings = new ProjectRoomHierarchy();
			//If user is in community add Community suffix name to Url
			projectSettings.Id='';
			if(String.isNotBlank(networkId)){
				projectSettings.Id = networkId+'/';
			}
			projectSettings.Id += 'apex/leankor__ProjectSetup?ID=' + projectRoomID;
            projectSettings.Name = 'ProjectSetup';
			projectSettings.RoomId = projectRoomID;
			projectSettings.ChildRecords = new List < ProjectRoomHierarchy > ();
			projectSettings.CssLayout = 'advanceoption lmenuoption';
			setOfRoom.add(projectSettings);
      	}
      	      
		return setOfRoom;
    }

    @AuraEnabled(cacheable = true)
    public static List <ProjectRoomHierarchyData> getProjectBoardHierarchyAura(String projectRoomID, String RoomName){
        try {
           List<ProjectRoomHierarchy> projectRoomHierarchy = getProjectBoardHierarchy(projectRoomID,RoomName);
           List<ProjectRoomHierarchyData> result = new  List<ProjectRoomHierarchyData>();
           for (ProjectRoomHierarchy hierarchy : projectRoomHierarchy) {
                ProjectRoomHierarchyData hierarchyData = new ProjectRoomHierarchyData();
                hierarchyData.Id                = hierarchy.Id;
                hierarchyData.Name              = hierarchy.Name;
                hierarchyData.BoardType         = hierarchy.BoardType;
                hierarchyData.leaf              = hierarchy.leaf;
                //hierarchyData.ChildRecords      = hierarchy.ChildRecords;  // assuming hierarchy.ChildRecords is already List<ProjectRoomHierarchyData>
                hierarchyData.CssLayout         = hierarchy.CssLayout;
                hierarchyData.RoomId            = hierarchy.RoomId;
                hierarchyData.ValueStreamLinkID = hierarchy.ValueStreamLinkID;
                hierarchyData.ValueStreamCardLink = hierarchy.ValueStreamCardLink;
                hierarchyData.KanbanCardId      = hierarchy.KanbanCardId;
                hierarchyData.UrlLink           = hierarchy.UrlLink;
                hierarchyData.hasEditAccess     = hierarchy.hasEditAccess;
                hierarchyData.hasReadAccess     = hierarchy.hasReadAccess;
                hierarchyData.hasDeleteAccess   = hierarchy.hasDeleteAccess;
                hierarchyData.disableCalendarView = hierarchy.disableCalendarView;
                
                if (hierarchy.ChildRecords != null && !hierarchy.ChildRecords.isEmpty()) {
                hierarchyData.ChildRecords = new List<ProjectRoomHierarchyData>();
                for (ProjectRoomHierarchy child : hierarchy.ChildRecords) {
                    ProjectRoomHierarchyData childData = new ProjectRoomHierarchyData();
                    childData.Id                   = child.Id;
                    childData.Name                 = child.Name;
                    childData.BoardType            = child.BoardType;
                    childData.leaf                 = child.leaf;
                    childData.CssLayout            = child.CssLayout;
                    childData.RoomId               = child.RoomId;
                    childData.ValueStreamLinkID    = child.ValueStreamLinkID;
                    childData.ValueStreamCardLink  = child.ValueStreamCardLink;
                    childData.KanbanCardId         = child.KanbanCardId;
                    childData.UrlLink              = child.UrlLink;
                    childData.hasEditAccess        = child.hasEditAccess;
                    childData.hasReadAccess        = child.hasReadAccess;
                    childData.hasDeleteAccess      = child.hasDeleteAccess;
                    childData.disableCalendarView  = child.disableCalendarView;

                    // If grandchildren exist and you need them, you’d recurse here via a helper.
                    hierarchyData.ChildRecords.add(childData);
                }
            }

            result.add(hierarchyData);
        }

        return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    global static List<ProjectRoomHierarchy> boardHierarchy(string RoomId, string Boardtype, List<leankor__ValueStream__c> listforBoardHierarchy){
        
        List<ProjectRoomHierarchy> listofBoards = new List<ProjectRoomHierarchy>();

        /** Date: 18/09/2019 -  Removed this code because of limitation of 200 records in UserRecordAccess Object.
        //Date 22/07/19 add record id in set to avoid duplicate id.
        Set<String> ids = new Set<String>();
        for(leankor__ValueStream__c vs : listforBoardHierarchy){
            ids.add(vs.Id);
        }
        // Get all the record access in a map for given boards 
        //Date :22/07/19  .
        Map <String, UserRecordAccess> recordAccessMap =  readRecordSecurity(new List<String>(ids));
        */
        
        for(leankor__ValueStream__c vs :listforBoardHierarchy) {
            
            if(vs.leankor__ProjectRoom__c == RoomId && vs.leankor__BoardType__c == Boardtype){              
                ProjectRoomHierarchy obj_roomhierarchy = new ProjectRoomHierarchy();
                obj_roomhierarchy.Id = vs.Id;
                obj_roomhierarchy.Name = vs.Name;
                obj_roomhierarchy.BoardType = vs.leankor__BoardType__c;
                //vj 31/12/19
                obj_roomhierarchy.disableCalendarView=vs.leankor__DisableCalendarView__c;                    
                //RS 23/04/2019 
                //obj_roomhierarchy.hasReadAccess = recordAccessMap.get(vs.Id).HasReadAccess;
                //obj_roomhierarchy.hasEditAccess = recordAccessMap.get(vs.Id).HasEditAccess;
                //obj_roomhierarchy.hasDeleteAccess = recordAccessMap.get(vs.Id).HasDeleteAccess;
                                    
                if(Boardtype =='DashBoard'){
                    obj_roomhierarchy.UrlLink = vs.leankor__UrlLink__c;
                }
                    if(Boardtype =='Card Hierarchy'){
                    obj_roomhierarchy.ValueStreamLinkID = vs.leankor__ValueStreamLink__c ;
                    obj_roomhierarchy.ValueStreamCardLink =vs.leankor__ValueStreamCardLink__c ;
                    }
                    //obj_roomhierarchy.CssLayout= 'advanceoption';
                    obj_roomhierarchy.leaf = true;
                
                //Date: 03/05/2019 : Condition is added to prevent from getting boards of a project if don't have any access.
                //listofBoards.add(obj_roomhierarchy);
                if(!(obj_roomhierarchy.hasReadAccess == false && (Boardtype == 'WhiteBoard' || Boardtype == 'Kanban Board'  || Boardtype == 'DashBoard'))){
                    listofBoards.add(obj_roomhierarchy);
                }
                
                if(Boardtype == 'Plan Board'){
                    break;
                }
            }
        }
        return listofBoards;
    }
    
      
     global class PortfolioHierarchy {
    
        @AuraEnabled global String Id { get; set; }
        @AuraEnabled global String Name { get; set; }
        @AuraEnabled global Boolean leaf { get; set; }
        @AuraEnabled global String RoomType { get; set; }
        @AuraEnabled global String ParentPortfolio { get; set; }
        @AuraEnabled global Set<PortfolioHierarchy> ChildRecords { get; set; }
        @AuraEnabled global String OwnerId { get; set; }
        @AuraEnabled global DateTime MinDate { get; set; }
        @AuraEnabled global DateTime MaxDate { get; set; }
        @AuraEnabled global String StartDate { get; set; }
        @AuraEnabled global String DueDate { get; set; }
        @AuraEnabled global String OwnerName { get; set; }
        @AuraEnabled global String BoardMaxDueDate { get; set; }
        @AuraEnabled global Decimal PercentDone { get; set; }        
        @AuraEnabled global Decimal AllBudgetedTime { get; set; }
        @AuraEnabled global Decimal AllBudgetTimeComplete { get; set; }
        @AuraEnabled global Decimal AllBudgetTimeRemaining { get; set; }
        @AuraEnabled global String BoardId { get; set; }
        @AuraEnabled global String verb { get; set; }
        @AuraEnabled global String RoomId { get; set; }
    
        // Access flags
        @AuraEnabled global Boolean hasEditAccess { get; set; }
        @AuraEnabled global Boolean hasReadAccess { get; set; }
        @AuraEnabled global Boolean hasDeleteAccess { get; set; }
    
        // Constructor
        global PortfolioHierarchy() {
            ChildRecords = new Set<PortfolioHierarchy>();
        }
    }
  
  
    //private static map<string,leankor.ProjectBoardCarousel.PortfolioHierarchy> PlanPortfolioHierarchyData = new map<String,leankor.ProjectBoardCarousel.PortfolioHierarchy>();
    // we have to depricated this methods   
    @RemoteAction @ReadOnly 
    global static Set<PortfolioHierarchy> getPortfolioHierarchyNav(){ return new Set<PortfolioHierarchy>(); } 
           
    @RemoteAction
    global static Set<PortfolioHierarchy> getPortfolioHierarchy( ) { return new Set<PortfolioHierarchy>();}
    
    global static Set<PortfolioHierarchy> Childroomrecords(string portfolioId, List<leankor__ProjectRoom__c> roomList){              
        return new Set<PortfolioHierarchy>();
    }
    //
                  
    @remoteAction 
    @ReadOnly 
    global static Set<PortfolioHierarchy> getPortHierarchy(portfoliodata port) {  

        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();    
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();      
        if (!portfolioBehaviour.isAccessible() ||
            !projectRoomBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }  

        if (String.isNotBlank(port.Id) && Util.getSObjectName(port.Id) != 'leankor__Portfolio__c' && Util.getSObjectName(port.Id) != 'leankor__ProjectRoom__c')  {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
         List<leankor__Portfolio__c> portfolioList = new List<leankor__Portfolio__c>();
         List<leankor__ProjectRoom__c> roomList = new List<leankor__ProjectRoom__c>(); 
         
         //RS 22.04.2019 Added HasEditAccess in the queries 
         // verb is ResourceManagementView then only getting portfolio and projects data without kanban card calculation of projects and except Template Project
         if(port.navigationVerb == 'ResourceManagementView')
         {                                                                    
            //get child Portfolio(Folder)
            portfolioList = [SELECT Id, Name, leankor__ParentPortfolio__c,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess,UserRecordAccess.HasReadAccess FROM leankor__Portfolio__c where leankor__ParentPortfolio__c =: port.Id ORDER BY Name LIMIT 49999];           
            //get child Project Room filter by Parent Id and isTemplateProject = false
            roomList = [SELECT Id, Name, leankor__Portfolio__c,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess,UserRecordAccess.HasReadAccess FROM leankor__ProjectRoom__c where leankor__Portfolio__c =: port.Id AND leankor__IsTemplateProject__c = false ORDER BY Name LIMIT 49999];
                      
            return childPortfolioHierarchy(port.Id, portfolioList, roomList);
         }
            
         // verb is cloneProject than only getting project data with kanban card calculation of project
         if(port.navigationVerb == 'cloneProject')
         {
           
           roomList = [SELECT Id, Name, leankor__Portfolio__c, leankor__ProjectManager__c, leankor__DueDate__c, leankor__ProjectManager__r.Name,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess,UserRecordAccess.HasReadAccess FROM leankor__ProjectRoom__c where Id =: port.Id ORDER BY Name limit 1];
           
         }else{         
           //get all portfolio data
           portfolioList = [SELECT Id, Name, leankor__ParentPortfolio__c,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess,UserRecordAccess.HasReadAccess FROM leankor__Portfolio__c where leankor__ParentPortfolio__c =: port.Id ORDER BY Name LIMIT 49999];           
           //get all Project rooms
           roomList = [SELECT Id, Name, leankor__Portfolio__c, leankor__ProjectManager__c, leankor__DueDate__c, leankor__ProjectManager__r.Name,UserRecordAccess.HasEditAccess,UserRecordAccess.HasDeleteAccess,UserRecordAccess.HasReadAccess FROM leankor__ProjectRoom__c where leankor__Portfolio__c =: port.Id ORDER BY Name LIMIT 49999];     
         }
         
         // verb is leankorNav than only getting portfolio and projects data without kanban card calculation of projects        
         if(port.navigationVerb == 'LeankorNav')
         {                                                            
            return childPortfolioHierarchy(port.Id, portfolioList, roomList);
         }
                                                
         Set<PortfolioHierarchy> portfolioHierarchySet = new Set<PortfolioHierarchy>();
         Set<String> ganttProjectSet = new Set<String>();
         Map<Id, AggregateResult> cardDueDatesMap = new Map<Id, AggregateResult>();
         Map<Id, AggregateResult> activityDueDatesMap = new Map<Id, AggregateResult>();
           
        //Keep a track of _System_UberBoard records
        // rbo 03.19.17
        for(leankor__ProjectLaunchBehavior__c b : [Select leankor__Project__c,
                                                            leankor__Project__r.Name 
                                                        From leankor__ProjectLaunchBehavior__c 
                                                        Where leankor__Module__r.leankor__BoardType__c = '_System_UberBoard' 
                                                            And leankor__Project__c In :roomList 
                                                        With Security_Enforced 
                                                        Limit 49999]){
            ganttProjectSet.add(b.leankor__Project__c);
        }    
                   
        //get all project boards
        // Tilak - 05/03/2020 - Changes for filtering soft deleted record and removing null condition in where clause.
        List<leankor__Valuestream__c> boardList = [Select Id,
                                                            leankor__BoardType__c,
                                                            leankor__ProjectRoom__c,
                                                            Name, 
                                                            leankor__ProjectRoom__r.leankor__ProjectManager__c, 
                                                            leankor__ProjectRoom__r.leankor__ProjectManager__r.Name
                                                        From leankor__ValueStream__c 
                                                        Where (leankor__BoardType__c = 'UberBoard' 
                                                                Or leankor__BoardType__c = 'Plan Board') 
                                                            And leankor__ProjectRoom__c In :roomList 
                                                            And leankor__isRecordDeleted__c = false
                                                        With Security_Enforced
                                                        Limit 49999]; 

        //Aggregate results to get MIN and MAX project dates
        // Date: 06/05/2019 - To get records without sharing
        AggregateResult[] cardDueDates = leankor.RealTimeControllerHelper.getPortHierarchy_HelperForCards(boardList);

        //Add aggregate results to a Map
        for(AggregateResult  r : cardDueDates)
        {        
            String pRoom = (String)r.get('leankor__ProjectRoom__c');
            if(ganttProjectSet.contains(pRoom) && (String)r.get('leankor__BoardType__c') == 'UberBoard')
            {
                cardDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            } else if(!ganttProjectSet.contains(pRoom) && (String)r.get('leankor__BoardType__c') == 'Plan Board'){
                cardDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            }
        }                            

        //Aggregate results to get budget time calculations         
        //If Plan Gantt and Roll up both available, use only Plan Gantt for the % calculation.    
        // Date: 06/05/2019 - To get records without sharing 
        AggregateResult[] activityDueDates = leankor.RealTimeControllerHelper.getPortHierarchy_HelperForActivity(boardList); 

        //Add aggregate results to a Map
        for(AggregateResult  r : activityDueDates)
        {
            String pRoom = (String)r.get('leankor__ProjectRoom__c');

            if(ganttProjectSet.contains(pRoom) && (String)r.get('leankor__BoardType__c') == 'UberBoard')
            {
                activityDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            } else if(!ganttProjectSet.contains(pRoom) && (String)r.get('leankor__BoardType__c') == 'Plan Board'){
                activityDueDatesMap.put((String)r.get('leankor__ProjectRoom__c'), r);
            }
            
        }
        
        return addChildNodes(port.Id, portfolioList, roomList, cardDueDatesMap, activityDueDatesMap);                               
    }

    @AuraEnabled
    public static List<PortfolioHierarchyData> getPortHierarchyAura(portfolioRecord port) {
        try {
            System.debug(port);
            // 1) Map top-level input (portfolioRecord) -> existing method’s input (Portfoliodata)
            Portfoliodata req = new Portfoliodata();
            if (port != null) {
                req.Id              = port.Id;
                req.Name            = port.Name;
                req.ParentPortfolio = port.ParentPortfolio;
                req.type            = port.type;
                req.PlanBoardID     = port.PlanBoardID;
                req.navigationVerb  = port.navigationVerb;
                req.methodName      = port.methodName;
                req.sourceProjectId = port.sourceProjectId;
                req.planGantt       = port.planGantt;
                req.hasEditAccess   = port.hasEditAccess;
                req.hasReadAccess   = port.hasReadAccess;
                req.hasDeleteAccess = port.hasDeleteAccess;
            }

            // 2) Call the existing, read-only method
            Set<PortfolioHierarchy> portFolio = getPortHierarchy(req);
            System.debug(portFolio.size());
            System.debug(portFolio);

             List<PortfolioHierarchyData> results = new List<PortfolioHierarchyData>();

            // Map each PortfolioHierarchy -> PortfolioHierarchyData
            for (PortfolioHierarchy data : portFolio) {
                PortfolioHierarchyData hierarchy = new PortfolioHierarchyData();

                hierarchy.Id                   = data.Id;
                hierarchy.Name                 = data.Name;
                hierarchy.leaf                 = data.leaf;
                hierarchy.RoomType             = data.RoomType;
                hierarchy.ParentPortfolio      = data.ParentPortfolio;
                hierarchy.ChildRecords         = (data.ChildRecords != null) 
                                                ? new List<PortfolioHierarchyData>(data.ChildRecords.size()) 
                                                : new List<PortfolioHierarchyData>();
                hierarchy.OwnerId              = data.OwnerId;
                hierarchy.MinDate              = data.MinDate;
                hierarchy.MaxDate              = data.MaxDate;
                hierarchy.StartDate            = data.StartDate;
                hierarchy.DueDate              = data.DueDate;
                hierarchy.OwnerName            = data.OwnerName;
                hierarchy.BoardMaxDueDate      = data.BoardMaxDueDate;
                hierarchy.PercentDone          = data.PercentDone;
                hierarchy.AllBudgetedTime      = data.AllBudgetedTime;
                hierarchy.AllBudgetTimeComplete= data.AllBudgetTimeComplete;
                hierarchy.AllBudgetTimeRemaining= data.AllBudgetTimeRemaining;
                hierarchy.BoardId              = data.BoardId;
                hierarchy.verb                 = data.verb;
                hierarchy.RoomId               = data.RoomId;
                hierarchy.hasEditAccess        = data.hasEditAccess;
                hierarchy.hasReadAccess        = data.hasReadAccess;
                hierarchy.hasDeleteAccess      = data.hasDeleteAccess;

                results.add(hierarchy);
            }
            return results;  

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    global class PortfolioHierarchyTimeSheet {
        global string Id;
        global string Name;
        global boolean leaf;
        global String RoomType;
        global String ParentPortfolio;
        global Set<PortfolioHierarchy> ChildRecords;
        global string OwnerId;
        global DateTime MinDate;
        global DateTime MaxDate;
        global string StartDate;
        global string DueDate;
        global string OwnerName; 
        global string BoardMaxDueDate;
        global Decimal PercentDone;        
        global Decimal AllBudgetedTime;
        global Decimal AllBudgetTimeComplete;
        global Decimal AllBudgetTimeRemaining;
        global String BoardId;
        global String verb;
        global String RoomId;
	    //RS 22.04.2019 Added variable to check Access for folder and project
	    public boolean hasEditAccess;
	    public boolean hasReadAccess;
	    public boolean hasDeleteAccess; 
        global String ParentProjectRoom;
        global String ParentValueStream;
        global String BoardType;
        global String KanbanCardType;
        global String RecordType;

    }

     /*
    Description - This method used for return hierarchy data for folder/project/board/card for TimeSheet.
    Input - Object of Portfoliodata Inner class.
    Output - List of PortfolioHierarchyTimeSheet inner class.
    */

    @remoteAction 
    global static Set<PortfolioHierarchyTimeSheet> getPortHierarchyForTimeSheet(portfoliodata port) {
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();    
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();    
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior(); 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour(); 
        if (!portfolioBehaviour.isAccessible() ||
            !projectRoomBehaviour.isAccessible() ||
            !valueStreamBehavior.isAccessible() ||
            !kanbanCardBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }  
        if (String.isNotBlank(port.Id) && (Util.getSObjectName(port.Id) != 'leankor__Portfolio__c'
            && Util.getSObjectName(port.Id) != 'leankor__ProjectRoom__c' 
            && Util.getSObjectName(port.Id) != 'leankor__ValueStream__c')) {
                throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        List<leankor__Portfolio__c> portfolioList = new List<leankor__Portfolio__c>();
        List<leankor__ProjectRoom__c> roomList = new List<leankor__ProjectRoom__c>(); 
        Set<PortfolioHierarchyTimeSheet> portfolioHierarchyTimeSheet  = new Set<PortfolioHierarchyTimeSheet>();    
        
        if(port.navigationVerb == 'FolderChild'){
            //get child Portfolio(Folder)
            portfolioList = [Select Id, 
                                    Name, 
                                    leankor__ParentPortfolio__c,
                                    UserRecordAccess.HasEditAccess,
                                    UserRecordAccess.HasDeleteAccess,
                                    UserRecordAccess.HasReadAccess 
                                From leankor__Portfolio__c 
                                Where leankor__ParentPortfolio__c =: port.Id 
                                Order By Name 
                                Limit 50000];           
            //get child Project Room filter by Parent Id and isTemplateProject = false
            roomList = [Select Id, 
                                Name, 
                                leankor__Portfolio__c,
                                UserRecordAccess.HasEditAccess,
                                UserRecordAccess.HasDeleteAccess,
                                UserRecordAccess.HasReadAccess 
                            From leankor__ProjectRoom__c 
                            Where leankor__Portfolio__c =: port.Id 
                            And leankor__IsTemplateProject__c = false 
                            Order By Name 
                            Limit 50000];
            for (leankor__ProjectRoom__c projectRoom: roomList) {        
                PortfolioHierarchyTimeSheet portfolioHierarchy = new PortfolioHierarchyTimeSheet();
                portfolioHierarchy.Id = projectRoom.Id;
                portfolioHierarchy.Name = projectRoom.Name;
                portfolioHierarchy.RoomType = 'Room';
                portfolioHierarchy.ParentPortfolio = projectRoom.leankor__Portfolio__c;
                portfolioHierarchy.leaf = false;
                //RS 22.04.2019 Added Access info for security role 
                portfolioHierarchy.hasReadAccess = projectRoom.UserRecordAccess.HasReadAccess;
                portfolioHierarchy.hasEditAccess = projectRoom.UserRecordAccess.HasEditAccess;
                portfolioHierarchy.hasDeleteAccess = projectRoom.UserRecordAccess.HasDeleteAccess;
                portfolioHierarchyTimeSheet.add(portfolioHierarchy);  
            }

            for(leankor__Portfolio__c p : portfolioList) {         
                PortfolioHierarchyTimeSheet portfolioHierarchy = new PortfolioHierarchyTimeSheet();               
                portfolioHierarchy.Name = p.Name;
                portfolioHierarchy.ID = p.ID;
                portfolioHierarchy.RoomType = 'Portfolio';
                portfolioHierarchy.ParentPortfolio = p.leankor__ParentPortfolio__c;
                portfolioHierarchy.leaf = false;
                // portfolioHierarchy.ChildRecords = childPortfolioHierarchy(p.ID, portfolioList, roomList);
                portfolioHierarchy.ChildRecords = new Set<PortfolioHierarchy>();            
                //RS 22.04.2019 Added Access info for security role 
                portfolioHierarchy.hasReadAccess = p.UserRecordAccess.HasReadAccess;
                portfolioHierarchy.hasEditAccess = p.UserRecordAccess.HasEditAccess;
                portfolioHierarchy.hasDeleteAccess = p.UserRecordAccess.HasDeleteAccess;     

                portfolioHierarchyTimeSheet.add(portfolioHierarchy);                  
            }
        }          
        
        if(port.navigationVerb == 'ProjectChild'){
            for( leankor__ValueStream__c valueStream : [Select Id, 
                                                                Name, 
                                                                leankor__BoardType__c, 
                                                                leankor__ProjectRoom__c, 
                                                                leankor__ProjectRoom__r.Name, 
                                                                UserRecordAccess.HasEditAccess,
                                                                UserRecordAccess.HasDeleteAccess,
                                                                UserRecordAccess.HasReadAccess 
                                                            From leankor__ValueStream__c 
                                                            Where leankor__ProjectRoom__c =: port.Id
                                                                And leankor__BoardType__c In :BOARDTYPEFILTERS_NONCARDHIERARCHY_CONST
                                                                And leankor__isRecordDeleted__c = false 
                                                            Limit 50000]){
                PortfolioHierarchyTimeSheet portfolioHierarchy = new PortfolioHierarchyTimeSheet(); 
                portfolioHierarchy.Name = valueStream.Name;
                portfolioHierarchy.ID = valueStream.Id;
                portfolioHierarchy.RoomType = 'Board';
                portfolioHierarchy.ParentProjectRoom = valueStream.leankor__ProjectRoom__c;
                portfolioHierarchy.BoardType = valueStream.leankor__BoardType__c;                                          
                portfolioHierarchy.leaf = false;
                // portfolioHierarchy.ChildRecords = childPortfolioHierarchy(p.ID, portfolioList, roomList);
                portfolioHierarchy.ChildRecords = new Set<PortfolioHierarchy>();            
                //RS 22.04.2019 Added Access info for security role 
                portfolioHierarchy.hasReadAccess = valueStream.UserRecordAccess.HasReadAccess;
                portfolioHierarchy.hasEditAccess = valueStream.UserRecordAccess.HasEditAccess;
                portfolioHierarchy.hasDeleteAccess = valueStream.UserRecordAccess.HasDeleteAccess;     
        
                portfolioHierarchyTimeSheet.add(portfolioHierarchy);
            }   
        }

        if(port.navigationVerb == 'BoardChild'){
            for(leankor__KanbanCard__c kanbanCard : [Select 
                                                        Id,
                                                        Name,
                                                        leankor__ValueStream__c, 
                                                        RecordType.Name, 
                                                        RecordTypeId,
                                                        UserRecordAccess.HasEditAccess,
                                                        UserRecordAccess.HasDeleteAccess,
                                                        UserRecordAccess.HasReadAccess 
                                                    FROM leankor__KanbanCard__c
                                                    WHERE leankor__ValueStream__c =: port.Id  
                                                        AND leankor__isRecordDeleted__c = false
                                                        AND leankor__ValueStream__r.leankor__isRecordDeleted__c = false
                                                    LIMIT 50000]){
                PortfolioHierarchyTimeSheet portfolioHierarchy = new PortfolioHierarchyTimeSheet(); 
                portfolioHierarchy.Name = kanbanCard.Name;
                portfolioHierarchy.ID = kanbanCard.Id;
                portfolioHierarchy.RoomType = 'KanbanCard';
                portfolioHierarchy.RecordType = kanbanCard.RecordTypeId;
                portfolioHierarchy.ParentValueStream = kanbanCard.leankor__ValueStream__c;
                portfolioHierarchy.KanbanCardType = kanbanCard.RecordType.Name;                                         
                portfolioHierarchy.leaf = true;
                // portfolioHierarchy.ChildRecords = childPortfolioHierarchy(p.ID, portfolioList, roomList);
                portfolioHierarchy.ChildRecords = new Set<PortfolioHierarchy>();            
                //RS 22.04.2019 Added Access info for security role 
                portfolioHierarchy.hasReadAccess = kanbanCard.UserRecordAccess.HasReadAccess;
                portfolioHierarchy.hasEditAccess = kanbanCard.UserRecordAccess.HasEditAccess;
                portfolioHierarchy.hasDeleteAccess = kanbanCard.UserRecordAccess.HasDeleteAccess;     

                portfolioHierarchyTimeSheet.add(portfolioHierarchy);
            }
        }
        
        return portfolioHierarchyTimeSheet;
    }

    public static Set<PortfolioHierarchy> addChildNodes(Id parentId, List<leankor__Portfolio__c> portfolioList, List<leankor__ProjectRoom__c> roomList,
                    Map<Id, AggregateResult> cardDueDatesMap, Map<Id, AggregateResult> activityDueDatesMap){
        Set<PortfolioHierarchy> portfolioHierarchySet = new Set<PortfolioHierarchy>();

        //Add projects to the top level portfolio
        portfolioHierarchySet.addAll(addProjects(parentId, roomList, cardDueDatesMap, activityDueDatesMap));

        //Iterate child portfolio and add to the hierarchy
        for(leankor__Portfolio__c p : portfolioList)
        {          
                PortfolioHierarchy portfolioHierarchy = new PortfolioHierarchy();
                portfolioHierarchy.Id = p.Id;
                portfolioHierarchy.Name = p.Name ;
                portfolioHierarchy.RoomType = 'Portfolio'; 
                portfolioHierarchy.ParentPortfolio = p.leankor__ParentPortfolio__c; 
                //24/04/19
                portfolioHierarchy.hasReadAccess =  p.UserRecordAccess.HasReadAccess;
                portfolioHierarchy.hasEditAccess =  p.UserRecordAccess.HasEditAccess;
                portfolioHierarchy.hasDeleteAccess =  p.UserRecordAccess.HasDeleteAccess;
                //
        portfolioHierarchy.ChildRecords = new Set<PortfolioHierarchy>();//addChildNodes(p.Id, portfolioList, roomList, cardDueDatesMap, activityDueDatesMap);            
                portfolioHierarchySet.add(portfolioHierarchy);               
        }

        return portfolioHierarchySet;
    }

    
    public static Set<PortfolioHierarchy> addProjects(Id parentId, List<leankor__ProjectRoom__c> roomList,
        Map<Id, AggregateResult> cardDueDatesMap, Map<Id, AggregateResult> activityDueDatesMap){
        Set<PortfolioHierarchy> portfolioHierarchySet = new Set<PortfolioHierarchy>();
        //Iterate all projects and add to the hierarchy
        for(leankor__ProjectRoom__c r : roomList)
        {
                PortfolioHierarchy portfolioHierarchy = new PortfolioHierarchy();
                portfolioHierarchy.Id = r.Id;
                portfolioHierarchy.Name = r.Name ;
                portfolioHierarchy.RoomType = 'Room';
                portfolioHierarchy.leaf = true;
                portfolioHierarchy.ParentPortfolio = r.leankor__Portfolio__c;
                portfolioHierarchy.DueDate = String.Valueof(r.leankor__DueDate__c);
                portfolioHierarchy.PercentDone = 0;   
                portfolioHierarchy.AllBudgetedTime = 0;
                portfolioHierarchy.AllBudgetTimeComplete = 0;
                portfolioHierarchy.AllBudgetTimeRemaining = 0;                             
                //02.02.2017 yj added one more Field for project Owner Name to display on portfolio 
                portfolioHierarchy.OwnerName = r.leankor__ProjectManager__r.name;                           

                //Add MIN/MAX dates to the project hierarchy record
                AggregateResult res = cardDueDatesMap.get(r.Id);
                if(res != null)
                {
                    //portfolioHierarchy.MinDate = (DateTime)res.get('expr0');
                    //portfolioHierarchy.MaxDate = (DateTime)res.get('expr1');
                    portfolioHierarchy.BoardMaxDueDate = String.Valueof((DateTime)res.get('expr1'));
                }

                //Add budget dates dates to the project hierarchy record
                res = activityDueDatesMap.get(r.Id);
                if(res != null)
                {
                    portfolioHierarchy.AllBudgetedTime = (Decimal)res.get('expr2');
                    portfolioHierarchy.AllBudgetTimeComplete = (Decimal)res.get('expr0');
                    portfolioHierarchy.AllBudgetTimeRemaining = (Decimal)res.get('expr1');

                    if(portfolioHierarchy.AllBudgetedTime != 0)
                    {
            portfolioHierarchy.PercentDone = (portfolioHierarchy.AllBudgetedTime - portfolioHierarchy.AllBudgetTimeRemaining) * 100 / portfolioHierarchy.AllBudgetedTime;
          }  
                }  
                // Date : 24/04/19 
                portfolioHierarchy.hasReadAccess =  r.UserRecordAccess.HasReadAccess;
                portfolioHierarchy.hasEditAccess =  r.UserRecordAccess.HasEditAccess;
                portfolioHierarchy.hasDeleteAccess =  r.UserRecordAccess.HasDeleteAccess;     
                portfolioHierarchySet.add(portfolioHierarchy);
            
        }

        return portfolioHierarchySet;
    }

         
    global static Set<PortfolioHierarchy> childPortfolioHierarchy(String parentId, List<leankor__Portfolio__c> portfolioList, List<leankor__ProjectRoom__c> roomList) {
        Set<PortfolioHierarchy> portfolioHierarchySet  = new Set<PortfolioHierarchy>();       
        for (leankor__ProjectRoom__c r: roomList) {        
            PortfolioHierarchy portfolioHierarchy = new PortfolioHierarchy();
            portfolioHierarchy.Id = r.Id;
            portfolioHierarchy.Name = r.Name;
            portfolioHierarchy.RoomType = 'Room';
            portfolioHierarchy.ParentPortfolio = r.leankor__Portfolio__c;
            portfolioHierarchy.leaf = true;
            //RS 22.04.2019 Added Access info for security role 
            portfolioHierarchy.hasReadAccess = r.UserRecordAccess.HasReadAccess;
            portfolioHierarchy.hasEditAccess = r.UserRecordAccess.HasEditAccess;
            portfolioHierarchy.hasDeleteAccess = r.UserRecordAccess.HasDeleteAccess;
            portfolioHierarchySet.add(portfolioHierarchy);  
        }

        for(leankor__Portfolio__c p : portfolioList) {         
            PortfolioHierarchy portfolioHierarchy = new PortfolioHierarchy();               
            portfolioHierarchy.Name = p.Name;
            portfolioHierarchy.ID = p.ID;
            portfolioHierarchy.RoomType = 'Portfolio';
            portfolioHierarchy.ParentPortfolio = p.leankor__ParentPortfolio__c;
            portfolioHierarchy.leaf = false;
            // portfolioHierarchy.ChildRecords = childPortfolioHierarchy(p.ID, portfolioList, roomList);
            portfolioHierarchy.ChildRecords = new Set<PortfolioHierarchy>();            
            //RS 22.04.2019 Added Access info for security role 
            portfolioHierarchy.hasReadAccess = p.UserRecordAccess.HasReadAccess;
            portfolioHierarchy.hasEditAccess = p.UserRecordAccess.HasEditAccess;
            portfolioHierarchy.hasDeleteAccess = p.UserRecordAccess.HasDeleteAccess;     

            portfolioHierarchySet.add(portfolioHierarchy);                  
        }

        return portfolioHierarchySet;
    }  


    //----- --------------------- FolderHierarchy on Moving any projects and folders-----------------------------------
    @RemoteAction
    global static Set<PortfolioHierarchy> getFolderHierarchy() {
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        if (!portfolioBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        Set<PortfolioHierarchy> Portfolio = new Set<PortfolioHierarchy>();
        List<leankor__Portfolio__c> PortfolioLogs = [Select Id, 
                                                            Name, 
                                                            leankor__ParentPortfolio__c, 
                                                            leankor__PortfolioNumber__c,
                                                            UserRecordAccess.HasEditAccess 
                                                        From leankor__Portfolio__c 
                                                        Order By Name Asc Nulls First,leankor__ParentPortfolio__c 
                                                        LIMIT 49999];
        
        for(leankor__Portfolio__c PortfolioLog : PortfolioLogs) {
            if (PortfolioLog.leankor__ParentPortfolio__c == null && PortfolioLog.UserRecordAccess.HasEditAccess) {
                PortfolioHierarchy obj_Portfoliohierarchy = new PortfolioHierarchy();
                obj_Portfoliohierarchy.Id = PortfolioLog.ID;
                obj_Portfoliohierarchy.Name = PortfolioLog.Name ;
                obj_Portfoliohierarchy.RoomType = 'Portfolio';
                obj_Portfoliohierarchy.leaf = false;
                obj_Portfoliohierarchy.ChildRecords = childFolderHierarchy(PortfolioLog.ID,PortfolioLogs);

                Portfolio.add(obj_Portfoliohierarchy);
            }
        }

        return Portfolio;
    }


    global static Set<PortfolioHierarchy> childFolderHierarchy(String parentId,list<leankor__Portfolio__c> ListOfPortfolio) {
        Set<PortfolioHierarchy> SetofchildPortfolio  = new Set<PortfolioHierarchy>();

        for (leankor__Portfolio__c childOfPF :ListOfPortfolio) {
            if (childOfPF.leankor__ParentPortfolio__c == parentId && childOfPF.UserRecordAccess.HasEditAccess) {
                PortfolioHierarchy obj_childPF = new PortfolioHierarchy();
                obj_childPF.Name = childOfPF.Name;
                obj_childPF.ID = childOfPF.ID;
                obj_childPF.RoomType = 'Portfolio';
                obj_childPF.leaf = false;
                obj_childPF.ParentPortfolio = childOfPF.leankor__ParentPortfolio__c;
                obj_childPF.ChildRecords = childFolderHierarchy(childOfPF.ID,ListOfPortfolio);

                SetofchildPortfolio.add(obj_childPF);      
            }
        }

        return SetofchildPortfolio;
    }
    //--------------------------------------------------------------------------------------------------------------------------------------
    
    
    global class portfoliodata {
        global string Id;
        global string Name;
        global string ParentPortfolio;
        global string type;
        global String PlanBoardID ;
        global String navigationVerb;       
        global string methodName;
        global string sourceProjectId;
        global Boolean planGantt;        
        public boolean hasEditAccess;
        public boolean hasReadAccess;
        public boolean hasDeleteAccess;    
    } 


    @RemoteAction
    global static List<portfoliodata> createPortfolio(List<portfoliodata> createPFlog) {
        //Check CRUD / FLC behavior
        PortfolioBehaviour pfolio = new PortfolioBehaviour();
        if (!pfolio.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<portfoliodata> result = new List<portfoliodata>();
        List<leankor__Portfolio__c> insertLog = new List<leankor__Portfolio__c> ();
        
        for(portfoliodata pfData : createPFlog) {
            leankor__Portfolio__c log = new leankor__Portfolio__c ();
            log.Name= pfData.Name;
            log.leankor__ParentPortfolio__c = pfData.ParentPortfolio;

            insertLog.add(log);
        } 

        try {
            DataBase.insert(insertLog, false);
        } catch (DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
  
        List<leankor__Portfolio__c> folders = [SELECT 
                                                    Id,
                                                    Name,
                                                    leankor__ParentPortfolio__c,
                                                    UserRecordAccess.HasEditAccess,
                                                    UserRecordAccess.HasReadAccess,
                                                    UserRecordAccess.HasDeleteAccess 
                                                FROM leankor__Portfolio__c 
                                                WHERE Id IN: insertLog 
                                                LIMIT 999];        

        for (leankor__Portfolio__c pfData : folders) {
            portfoliodata resultLog = new portfoliodata ();
            resultLog.Id = pfData.ID;
            resultLog.Name = pfData.Name;
            resultLog.ParentPortfolio = pfData.leankor__ParentPortfolio__c ;
            resultLog.hasEditAccess = pfData.UserRecordAccess.HasEditAccess;
            resultLog.hasReadAccess = pfData.UserRecordAccess.HasReadAccess;
            resultLog.hasDeleteAccess = pfData.UserRecordAccess.HasDeleteAccess; 
            result.add(resultLog);
        }

        return result;
    }
  
  
    // Create New Folder invokes this method.
    @RemoteAction
    global static Set<PortfolioHierarchy> createListPortfolio(List<Portfoliodata> portfoliodataList) {
        //Check CRUD / FLC behavior
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        if (!portfolioBehaviour.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior

        Set<PortfolioHierarchy> result = new Set<PortfolioHierarchy>();
        List<leankor__Portfolio__c> portfolioList = new List<leankor__Portfolio__c> ();
        for (Portfoliodata p: portfoliodataList) {
            leankor__Portfolio__c portfolio = new leankor__Portfolio__c();

            portfolio.Name = p.Name;
            portfolio.leankor__ParentPortfolio__c = p.ParentPortfolio;

            portfolioList.add(portfolio);
        }
        //insert new Folder list to the database
        DataBase.insert(portfolioList, false);

        leankor.ProjectBoardCarousel.PortfolioHierarchy Port = new leankor.ProjectBoardCarousel.PortfolioHierarchy();
        Port.ID = portfolioList[0].Id;
        Port.Name = portfolioList[0].Name;
        Port.ParentPortfolio = portfolioList[0].leankor__ParentPortfolio__c;
        Port.RoomType = 'Portfolio';
        //Date :26/04/19
        leankor__Portfolio__c folder = [select id,UserRecordAccess.HasEditAccess,UserRecordAccess.HasReadAccess,UserRecordAccess.HasDeleteAccess from leankor__Portfolio__c where id=:portfolioList[0].id Limit 1];
        Port.hasEditAccess=folder.UserRecordAccess.HasEditAccess;
        Port.hasReadAccess=folder.UserRecordAccess.HasReadAccess;
        Port.hasDeleteAccess=folder.UserRecordAccess.HasDeleteAccess; 
        
        result.add(Port);

        return result;     
    } 

    @AuraEnabled
    public static List<PortfolioHierarchyData> createListPortfolioAura(List<portfolioRecord> portfoliodataList) {
        List<Portfoliodata> requests = new List<Portfoliodata>();
        for (portfolioRecord record :portfoliodataList ) {
            Portfoliodata request = new Portfoliodata();
            request.Id              = record.Id;
            request.Name            = record.Name;
            request.ParentPortfolio = record.ParentPortfolio;
            request.type            = record.type;
            request.PlanBoardID     = record.PlanBoardID;
            request.navigationVerb  = record.navigationVerb;
            request.methodName      = record.sourceProjectId;
            request.planGantt       = record.planGantt;
            request.hasEditAccess   = record.hasEditAccess;
            request.hasReadAccess   = record.hasReadAccess;
            request.hasDeleteAccess = record.hasDeleteAccess;
            requests.add(request);
        }
        Set<PortfolioHierarchy> portFolio = createListPortfolio(requests);

        // Prepare the output list
        List<PortfolioHierarchyData> results = new List<PortfolioHierarchyData>();

        // Map each PortfolioHierarchy -> PortfolioHierarchyData
        for (PortfolioHierarchy data : portFolio) {
            PortfolioHierarchyData hierarchy = new PortfolioHierarchyData();

            hierarchy.Id                   = data.Id;
            hierarchy.Name                 = data.Name;
            hierarchy.leaf                 = data.leaf;
            hierarchy.RoomType             = data.RoomType;
            hierarchy.ParentPortfolio      = data.ParentPortfolio;
            hierarchy.ChildRecords         = (data.ChildRecords != null) 
                                            ? new List<PortfolioHierarchyData>(data.ChildRecords.size()) 
                                            : new List<PortfolioHierarchyData>();
            hierarchy.OwnerId              = data.OwnerId;
            hierarchy.MinDate              = data.MinDate;
            hierarchy.MaxDate              = data.MaxDate;
            hierarchy.StartDate            = data.StartDate;
            hierarchy.DueDate              = data.DueDate;
            hierarchy.OwnerName            = data.OwnerName;
            hierarchy.BoardMaxDueDate      = data.BoardMaxDueDate;
            hierarchy.PercentDone          = data.PercentDone;
            hierarchy.AllBudgetedTime      = data.AllBudgetedTime;
            hierarchy.AllBudgetTimeComplete= data.AllBudgetTimeComplete;
            hierarchy.AllBudgetTimeRemaining= data.AllBudgetTimeRemaining;
            hierarchy.BoardId              = data.BoardId;
            hierarchy.verb                 = data.verb;
            hierarchy.RoomId               = data.RoomId;
            hierarchy.hasEditAccess        = data.hasEditAccess;
            hierarchy.hasReadAccess        = data.hasReadAccess;
            hierarchy.hasDeleteAccess      = data.hasDeleteAccess;

            results.add(hierarchy);
        }
        return results;  
    }

    @RemoteAction
    global static Set<PortfolioHierarchy> updatePortfolio(List<portfoliodata> updatePFlog) {
        for(portfoliodata port : updatePFlog){
            if (String.isNotBlank(port.Id) && Util.getSObjectName(port.Id) != 'leankor__Portfolio__c') {
                throw new ProjectBoardCarouselException('Error: Invalid input');
            }  
        } 
        //Check CRUD / FLC behavior
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        if (!portfolioBehaviour.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        } 
        //Check CRUD / FLC behavior

        List<leankor__Portfolio__c> updatelog = new List<leankor__Portfolio__c> ();
        for(portfoliodata PFdata : updatePFlog){
            leankor__Portfolio__c Log = new leankor__Portfolio__c ();
                Log.ID = PFdata.ID;
                Log.Name= PFdata.Name;
                Log.leankor__ParentPortfolio__c = PFdata.ParentPortfolio;
            updatelog.add(log);
        }
        try{
            DataBase.Update(updatelog,false);
        }catch(DMLException ex){
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        /* no need this for loop
        for(leankor__Portfolio__c PFdata : updatelog){
            portfoliodata resultLog = new portfoliodata ();
            resultLog.Id = PFdata.ID;
            resultLog.Name =PFdata.Name;
            resultLog.ParentPortfolio =PFdata.leankor__ParentPortfolio__c ;
            result.add(resultLog);
        }*/
        
        return new Set<PortfolioHierarchy>();   
    }


    @RemoteAction
    global static portfoliodata createProjects(portfoliodata prjLogs) {
        if (String.isNotBlank(prjLogs.ParentPortfolio) && Util.getSObjectName(prjLogs.ParentPortfolio) != 'leankor__Portfolio__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        } 
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour ProjectRoomBehaviour = new ProjectRoomBehaviour();
        if (
            !ProjectRoomBehaviour.isAccessible() ||
            !ProjectRoomBehaviour.isCreateable()
        ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor.ProjectBoardCarousel.portfoliodata proom = new leankor.ProjectBoardCarousel.portfoliodata();          
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name = Prjlogs.name, leankor__Portfolio__c = prjLogs.ParentPortfolio);
        Database.SaveResult sResult;

        try {
            sResult = DataBase.Insert(project,true);
            List<ProjectRoomHierarchy> createboards = getProjectBoardHierarchy(project.Id,project.Name);
            //Date : 05/06/19 add query to checking security.
            project =[select Id,
                            Name,
                            leankor__Portfolio__c ,
                            UserRecordAccess.HasEditAccess,
                            UserRecordAccess.HasReadAccess,
                            UserRecordAccess.HasDeleteAccess 
                            from  leankor__ProjectRoom__c where id =: project.id Limit 1];
        } catch (DmlException e){
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        string result = createprojectlaunch(project.ID);
        if(sResult.isSuccess() == true){
            leankor__valuestream__c ganttplanBoard = [Select Id,
                                                            Name 
                                                        From leankor__Valuestream__c 
                                                        Where leankor__projectroom__c = :project.Id 
                                                            And leankor__BoardType__c = 'UberBoard' 
                                                        With Security_Enforced
                                                        Limit 1];
            proom.PlanBoardID = ganttplanBoard.ID;
            proom.Id = project.Id;
            proom.Name = project.Name;
            proom.ParentPortfolio = project.leankor__Portfolio__c;
            //Date : 05/06/19
            proom.hasEditAccess=project.UserRecordAccess.HasEditAccess;
            proom.hasReadAccess=project.UserRecordAccess.HasReadAccess;
            proom.hasDeleteAccess=project.UserRecordAccess.HasDeleteAccess;  
        }

        return proom;  
    }


    @RemoteAction
    global static Set<PortfolioHierarchy> createListProjects(portfoliodata Prjlogs) {
        if(String.isNotBlank(Prjlogs.ParentPortfolio) && Util.getSObjectName(Prjlogs.ParentPortfolio) != 'leankor__Portfolio__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        ProjectRoomBehaviour ProjectRoomBehaviour = new ProjectRoomBehaviour();
        if (!ProjectRoomBehaviour.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }

       leankor.ProjectBoardCarousel.PortfolioHierarchy PRoom = new leankor.ProjectBoardCarousel.PortfolioHierarchy();      
                        
        Set < PortfolioHierarchy > room = new Set < PortfolioHierarchy >();
        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name=Prjlogs.name, 
                                                                leankor__Portfolio__c = Prjlogs.ParentPortfolio,
                                                                leankor__AutoAssignResource__c = leankor__LeanConstants__c.getInstance().leankor__AutoAssignResourceToActivity__c,
                                                                leankor__IsDependencyAckRecalculate__c=leankor__LeanConstants__c.getInstance().leankor__IsDependencyAckRecalculate__c
                                                                );
        
        Database.SaveResult sResult;
        try {
            sResult = DataBase.Insert(project,true);
            
            //RS 22.04.2019 Added condition to user can create board or not 
            if (leankor__valuestream__c.sObjectType.getDescribe().isCreateable()) {
                List<ProjectRoomHierarchy> createboards = getProjectBoardHierarchy(project.Id,project.Name);
            }
        } catch (DmlException e) {
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }       

        String result = createprojectlaunch(project.ID);
        leankor__ProjectRoom__c projectRoom =[SELECT Id, UserRecordAccess.HasEditAccess, UserRecordAccess.HasReadAccess, UserRecordAccess.HasDeleteAccess FROM leankor__ProjectRoom__c WHERE Id =: project.id LIMIT 1];        

        PRoom.Id = project.id;
        PRoom.Name = project.name; 
        PRoom.ParentPortfolio = project.leankor__Portfolio__c;
        PRoom.RoomType ='Room';
        PRoom.leaf = true;                        
        PRoom.PercentDone = 0;              
        PRoom.hasEditAccess = projectRoom.UserRecordAccess.HasEditAccess;
        PRoom.hasReadAccess = projectRoom.UserRecordAccess.HasReadAccess;
        PRoom.hasDeleteAccess = projectRoom.UserRecordAccess.HasDeleteAccess;  
                     
        room.add(PRoom);
                          
        return room;      
    }


    @AuraEnabled
    public static List<PortfolioHierarchyData> createListProjectsAura(portfolioRecord Prjlogs) {
        try {

            Portfoliodata request = new Portfoliodata();
            request.Id              = Prjlogs.Id;
            request.Name            = Prjlogs.Name;
            request.ParentPortfolio = Prjlogs.ParentPortfolio;
            request.type            = Prjlogs.type;
            request.PlanBoardID     = Prjlogs.PlanBoardID;
            request.navigationVerb  = Prjlogs.navigationVerb;
            request.methodName      = Prjlogs.sourceProjectId;
            request.planGantt       = Prjlogs.planGantt;
            request.hasEditAccess   = Prjlogs.hasEditAccess;
            request.hasReadAccess   = Prjlogs.hasReadAccess;
            request.hasDeleteAccess = Prjlogs.hasDeleteAccess;
            Set<PortfolioHierarchy> portFolio = createListProjects(request);

            // Prepare the output list
            List<PortfolioHierarchyData> results = new List<PortfolioHierarchyData>();

            // Map each PortfolioHierarchy -> PortfolioHierarchyData
            for (PortfolioHierarchy data : portFolio) {
                PortfolioHierarchyData hierarchy = new PortfolioHierarchyData();

                hierarchy.Id                   = data.Id;
                hierarchy.Name                 = data.Name;
                hierarchy.leaf                 = data.leaf;
                hierarchy.RoomType             = data.RoomType;
                hierarchy.ParentPortfolio      = data.ParentPortfolio;
                hierarchy.ChildRecords         = (data.ChildRecords != null) 
                                            ? new List<PortfolioHierarchyData>(data.ChildRecords.size()) 
                                            : new List<PortfolioHierarchyData>();
                hierarchy.OwnerId              = data.OwnerId;
                hierarchy.MinDate              = data.MinDate;
                hierarchy.MaxDate              = data.MaxDate;
                hierarchy.StartDate            = data.StartDate;
                hierarchy.DueDate              = data.DueDate;
                hierarchy.OwnerName            = data.OwnerName;
                hierarchy.BoardMaxDueDate      = data.BoardMaxDueDate;
                hierarchy.PercentDone          = data.PercentDone;
                hierarchy.AllBudgetedTime      = data.AllBudgetedTime;
                hierarchy.AllBudgetTimeComplete= data.AllBudgetTimeComplete;
                hierarchy.AllBudgetTimeRemaining= data.AllBudgetTimeRemaining;
                hierarchy.BoardId              = data.BoardId;
                hierarchy.verb                 = data.verb;
                hierarchy.RoomId               = data.RoomId;
                hierarchy.hasEditAccess        = data.hasEditAccess;
                hierarchy.hasReadAccess        = data.hasReadAccess;
                hierarchy.hasDeleteAccess      = data.hasDeleteAccess;

                results.add(hierarchy);
            }
            return results;  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    global static string createprojectlaunch(string PorjectID) {
        //Check CRUD / FLC behavior
        ProjectLaunchBehavior projectLaunchBehaviorSecurity = new ProjectLaunchBehavior();
        if (!projectLaunchBehaviorSecurity.isCreateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__ProjectLaunchBehavior__c> insertlist = new List<leankor__ProjectLaunchBehavior__c>();
        List<leankor__Module__c> moduleLog = [Select Id,
                                                    leankor__SetUp__c,
                                                    Name 
                                                From leankor__Module__c 
                                                Where leankor__SetUp__c = true 
                                                With Security_Enforced
                                                Order By leankor__Order__c Asc Nulls First 
                                                Limit 10];
        
        for (leankor__Module__c M :moduleLog) {
            if (M.Name != 'Roll Up') {
                leankor__ProjectLaunchBehavior__c projectLB = new leankor__ProjectLaunchBehavior__c();
                projectLB.leankor__Module__c = M.ID;
                projectLB.leankor__Project__c = PorjectID;
                insertlist.add(projectLB);
            }
        }

        Insert insertlist;
        return 'Success';
    }


    // Update Name of the Value Stream Using Kanban Carousel.
    @RemoteAction
    global static String updateProjectBoard(leankor.RealTimeController.ProjectBoard pb) {
        if (String.isNotBlank(pb.Id) && Util.getSObjectName(pb.Id) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isUpdateable() ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String returnString = 'Success';
        leankor__ValueStream__c vs = [Select Id, 
                                            Name, 
                                            leankor__IsTemplateBoard__c 
                                        From leankor__ValueStream__c 
                                        Where Id =: pb.Id 
                                        With Security_Enforced
                                        Limit 1];
        vs.Name = pb.Name;
        vs.leankor__IsTemplateBoard__c = pb.IsTemplateBoard;

        try {
            DataBase.update(vs, true);
        } catch(DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        return returnString;
    }


    // This Method Is use to Update Project Room.
    @RemoteAction
    global static Set<PortfolioHierarchy> updateProjects(portfoliodata Prjlogs) {
        if (String.isNotBlank(Prjlogs.Id) && Util.getSObjectName(Prjlogs.Id) != 'leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ProjectRoomBehaviour projectRoom = new ProjectRoomBehaviour();

        if (!valueStreamBehavior.isUpdateable() || 
            !projectRoom.isUpdateable() ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__ProjectRoom__C prjRoom = [Select Id, 
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Id =: Prjlogs.Id 
                                            With Security_Enforced
                                            Limit 1];
        prjRoom.Name = Prjlogs.Name;
        try {
            DataBase.Update(prjRoom, true);
            List<leankor__valuestream__c> VS = [Select Id,  
                                                        Name, 
                                                        leankor__BoardType__c 
                                                    From leankor__valuestream__c 
                                                    Where leankor__ProjectRoom__c= :Prjlogs.ID 
                                                        And leankor__BoardType__c In ('Plan Board','UberBoard') 
                                                    With Security_Enforced
                                                    Limit 2];
            
            for(leankor__valuestream__c v : VS) {
                if (v.leankor__BoardType__c == 'UberBoard') {
                    v.Name= 'Plan Board(' +Prjlogs.Name +')';
                    //03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
                    if (v.Name.length() > 80) {
                        v.Name = v.Name.substring(0,79);
                        v.Name = v.Name+')';       
                    }
                    //
                }

                if (v.leankor__BoardType__c == 'Plan Board') {
                    v.Name= 'Roll-up(' +Prjlogs.Name +')';
                    //03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
                    if (v.Name.length() > 80) {
                        v.Name = v.Name.substring(0,79);
                        v.Name = v.Name+')';       
                    }
                    //
                }
            }
            DataBase.Update(VS, true);
        } catch(DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        
        return new Set<PortfolioHierarchy>();
    }

    @RemoteAction
    @AuraEnabled
    global static string removePortfolio(List<string> portfolioIds) {

        for (String portfolioId : portfolioIds ) {    
             if (String.isNotBlank(portfolioId) && (Util.getSObjectName(portfolioId) != 'leankor__Portfolio__c' )) {	
				throw new ProjectBoardCarouselException('Error: Invalid input');
            }
        }
        
        //Check CRUD / FLC behavior
        ProjectLaunchBehavior projectLaunchBehavior = new ProjectLaunchBehavior();
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();

        if (!projectLaunchBehavior.isDeletable() 
        || !projectRoomBehaviour.isDeletable() 
        || !portfolioBehaviour.isDeletable() 
        || !valueStreamBehavior.isUpdateable()
        || !kanbanCardBehaviour.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        } 

        //Check CRUD / FLC behavior

        Savepoint savePoint = Database.setSavepoint();
        try {
            List<leankor__Portfolio__c> deletePortfolios = RealTimeControllerHelper.getAllChildFolders(portfolioIds);
        
            List<leankor__Portfolio__c> portfolioList = [Select Id, 
                                                                Name 
                                                           From leankor__Portfolio__c
                                                           Where Id In :portfolioIds
                                                           With Security_Enforced 
                                                           Limit 10000];

            deletePortfolios.addAll(portfolioList);
            
            List<leankor__ProjectRoom__c> projectRoomList = leankor.RealTimeControllerHelper.getAllProjectOfFolderWithoutSharing(deletePortfolios);

            List<String> projectRoomIds = new List<String>();
            
            for (leankor__ProjectRoom__c projectRoom : projectRoomList) {
                projectRoomIds.add(projectRoom.Id);
            }

            leankor.realTimeController.removeLinkedCard(projectRoomIds);    

            List<String> valueStreamIdList = new List<String>();

         if (getQueryRowsCount() > 0 ) {
            List<leankor__ValueStream__c> valueStreamList = [Select Id,
                                                                    leankor__isRecordDeleted__c 
                                                                From leankor__ValueStream__c 
                                                                Where leankor__ProjectRoom__c In :projectRoomIds
                                                                    And leankor__isRecordDeleted__c = false
                                                                With Security_Enforced
                                                                Limit :getQueryRowsCount()];

            for (leankor__ValueStream__c valueStream  : valueStreamList) {
                valueStream.leankor__isRecordDeleted__c = true;
                valueStreamIdList.add(valueStream.Id);
            }
         
              update valueStreamList; 
            
            }

            if (getQueryRowsCount() > 0 ) {
                List<leankor__kanbanCard__c> kanbanCardList = [Select Id,
                                                                    leankor__isRecordDeleted__c
                                                                From leankor__KanbanCard__c
                                                                Where leankor__ValueStream__c In :valueStreamIdList 
                                                                    And leankor__isRecordDeleted__c = false
                                                                With Security_Enforced 
                                                                Limit :getQueryRowsCount()];

                for (leankor__KanbanCard__c kanbanCard : kanbanCardList) {
                    kanbanCard.leankor__isRecordDeleted__c = true;
                }

              update kanbanCardList;
                
            }

            List<leankor__ValueStream__c> remainingValueStreams  = [Select Id,
                                                                             leankor__isRecordDeleted__c
                                                                        From leankor__ValueStream__c 
                                                                        Where leankor__ProjectRoom__c In :projectRoomIds 
                                                                             And leankor__isRecordDeleted__c = false
                                                                        With Security_Enforced
                                                                        Limit 1];

            Integer remainingKanbanCards = [Select count()
                                                From leankor__KanbanCard__c 
                                                Where (leankor__ValueStream__c In :valueStreamIdList 
                                                        Or leankor__ValueStream__c In :remainingValueStreams
                                                        Or leankor__ValueStream__r.leankor__isRecordDeleted__c = true) 
                                                        And leankor__isRecordDeleted__c = false
                                                With Security_Enforced
                                                Limit 1];

            if (remainingValueStreams.size() > 0 || remainingKanbanCards > 0) {


			    if(!Test.isRunningTest()) {

                System.enqueueJob(new SoftDeleteRecordQueueable(projectRoomIds));

            }
        }

            delete deletePortfolios; 

        } catch(exception ex) { 

          Database.rollback(savePoint);    

          throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());          
        } 
    
        return 'Success';

    }

    private static Integer getQueryRowsCount() {
	    /*If we perform dml operation on 9999 records then dmlRow count will be 10000 and in case of exception
         rollback performed then it will count one dml row means total 10001.then exception occurs for dml rows 10001.
         So that is why we have used limit counter 9998 */
         return 9998 - Limits.getQueryRows();
         
	}

    @RemoteAction
    global static Set<PortfolioHierarchy> getSamplePortfolio() {
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        LeanConstantsBehaviour leanConstantsBehaviour = new LeanConstantsBehaviour();
        if (!kanbanCardBehaviour.isCreateable() ||
            !leanConstantsBehaviour.isAccessible() ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor.ProjectBoardCarousel.portfoliodata> sampledata = new List<leankor.ProjectBoardCarousel.portfoliodata>();
        leankor.ProjectBoardCarousel.portfoliodata samplelog = new leankor.ProjectBoardCarousel.portfoliodata();
        samplelog.name = 'Sample Folder';
        sampledata.add(samplelog);
        List<leankor.ProjectBoardCarousel.portfoliodata> sampleportfolio =createPortfolio(sampledata);
        samplelog.Name = 'Sample Project';
        samplelog.ParentPortfolio = sampleportfolio[0].ID;
        leankor.ProjectBoardCarousel.portfoliodata SampleRoom= createProjects(samplelog);
        leankor.RealTimeController.ProjectBoard SampleBoard =leankor.ProjectBoardCarousel.createProjectBoard('Project Board',SampleRoom.ID,'Kanban Board','','');
        List<leankor__KanbanCardTemplate__c> kctId  = [Select Id 
                                                            From leankor__KanbanCardTemplate__c 
                                                            Where leankor__ValueStream__c = :SampleBoard.Id 
                                                            With Security_Enforced
                                                            Limit 9999];
        List<leankor__KanbanCard__c> sampleCardList = new  List<leankor__KanbanCard__c>();

        leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
        Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 :leanConstant.leankor__FirstDayOfTheWeek__c.intValue();         
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek,5);
        
        //Check today is working day if not then get next working day date.
        DateTime currentWorkingDayDateTime = workWeek.isWorkingDay(system.now().format('EEEE'))?system.now():Util.readNextWorkingDateTime(workWeek,System.now());
        //SS 22.05.2018
        
        leankor__KanbanCard__c samplecard  = new leankor__KanbanCard__c();
        samplecard.Name ='Sample card';
        samplecard.OwnerId=userinfo.getuserid();
        samplecard.leankor__DescriptionLong__c ='This is a sample long description of the work details';
        samplecard.leankor__Title__c ='Sample work item';
        samplecard.leankor__ValueStream__c = Sampleboard.ID;
        //SS 22.05.2018
        //Dates are assigning after check for current day is WorkingDay 
        samplecard.leankor__StartDatetime__c = currentWorkingDayDateTime; 
        samplecard.leankor__DueDateTime__c = currentWorkingDayDateTime;
        samplecard.leankor__EstimatedDuration__c = 1;
        samplecard.leankor__GUID__c = system.now() +'ONLOAD';
        samplecard.leankor__KanbanCardTemplate__c = kctId[0].Id;
        samplecard.RecordtypeId = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
       
        sampleCardList.add(samplecard);
       
        try {
            DataBase.insert(sampleCardList,false);
            //creating default RA and SM for sample card
            leankor.GanttTaskBoard.CreateScheduleMode(sampleCardList);
            leankor.GanttTaskBoard.CreateDefaultResourceAssignment(sampleCardList);

        } catch(DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        List<leankor__LeanConstants__c> Customsetting = [Select Id, 
                                                                leankor__FirstInstall__c 
                                                            From leankor__LeanConstants__c 
                                                            Limit 9999];
        for (leankor__LeanConstants__c updatelog :Customsetting ) {
            updatelog.leankor__FirstInstall__c = false;
        }

        try {
            DataBase.update(Customsetting, false);
        } catch (DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        } 

        return leankor.realtimeKanbanController.getPortfoliofilterHierarchy();
    }


     global class KanbanCardData {
        global string Name;
        global list<leankor.ProjectBoardCarousel.Card> ChildRecords;
        global integer ChildCount;
        global string Color;
        global Integer PriorityIndex;
        global String Id;
    }
    
    global class Card implements Comparable {
        @AuraEnabled
    global String Name { get; set; }
    
    @AuraEnabled
    global String Id { get; set; }
    
    @AuraEnabled
    global DateTime DueDate { get; set; }
    
    @AuraEnabled
    global String ValueStream { get; set; }
    
    @AuraEnabled
    global String ValueStreamName { get; set; }
    
    @AuraEnabled
    global String ItemType { get; set; }
    
    @AuraEnabled
    global String BoardType { get; set; }
    
    @AuraEnabled
    global Boolean leaf { get; set; }
    
    @AuraEnabled
    global String ProjectID { get; set; }
    
    @AuraEnabled
    global String DurationUnits { get; set; }
    
    @AuraEnabled
    global Decimal EstimatedDuration { get; set; }
    
    @AuraEnabled
    global Decimal Priority { get; set; }
    
    @AuraEnabled
    global String TaskPriority { get; set; }
    
    @AuraEnabled
    global String GUID { get; set; }
    
    @AuraEnabled
    global String KanbanCardTemplate { get; set; }
    
    @AuraEnabled
    global String KanbanCardTemplateName { get; set; }
    
    @AuraEnabled
    global String OnBudget { get; set; }
    
    @AuraEnabled
    global String OnQuality { get; set; }
    
    @AuraEnabled
    global String OnTime { get; set; }
    
    @AuraEnabled
    global DateTime StartDate { get; set; }
    
    @AuraEnabled
    global String Title { get; set; }
    
    @AuraEnabled
    global String Description { get; set; }
    
    @AuraEnabled
    global String RecordTypeId { get; set; }
    
    @AuraEnabled
    global String ProjectRoomName { get; set; }
    
    @AuraEnabled
    global Decimal HarveyBall { get; set; }
    
    @AuraEnabled
    global String OwnerID { get; set; }
    
    @AuraEnabled
    global String OwnerName { get; set; }
    
    @AuraEnabled
    global String WhatName { get; set; }
    
    @AuraEnabled
    global String WhatID { get; set; }
    
    @AuraEnabled
    global String Status { get; set; }
    
    @AuraEnabled
    global Integer ChatterCount { get; set; }
    
    @AuraEnabled
    global List<Attachment> Sticker { get; set; }
    
    @AuraEnabled
    global Decimal Point { get; set; }
    
    @AuraEnabled
    global Decimal Order { get; set; }
    
    @AuraEnabled
    global Decimal EffortRemaining { get; set; }
    
    @AuraEnabled
    global Boolean SevenDayWorkWeek { get; set; }
    
    @AuraEnabled
    global DateTime CreatedDate { get; set; }
    
    @AuraEnabled
    global DateTime LastModifiedDate { get; set; }
    
    @AuraEnabled
    global String pointPickList { get; set; }
    
    @AuraEnabled
    global String CardID { get; set; }
    
    @AuraEnabled
    global String TemplateID { get; set; }
    
    @AuraEnabled
    global String CmpID { get; set; }
    
    @AuraEnabled
    global String JSONDefinition { get; set; }
    
    @AuraEnabled
    global String JSONData { get; set; }
    
    @AuraEnabled
    global String ValueStreamCardLink { get; set; }
    
    @AuraEnabled
    global String ValueStreamLinkID { get; set; }
    
    @AuraEnabled
    global String ValueStreamCardLinkName { get; set; }
    
    @AuraEnabled
    global String ValueStreamLinkIDName { get; set; }
    
    @AuraEnabled
    global String ValueStreamLinkBoardType { get; set; }
    
    @AuraEnabled
    global String Account { get; set; }
    
    @AuraEnabled
    global String Contact { get; set; }
    
    @AuraEnabled
    global String ForceID { get; set; }
    
    @AuraEnabled
    global String Opportunity { get; set; }
    
    @AuraEnabled
    global String OpportunityName { get; set; }
    
    @AuraEnabled
    global String OpportunityStage { get; set; }
    
    @AuraEnabled
    global String ContactName { get; set; }
    
    @AuraEnabled
    global String CaseID { get; set; }
    
    @AuraEnabled
    global String CaseSubject { get; set; }
    
    @AuraEnabled
    global String CaseStatus { get; set; }
    
    @AuraEnabled
    global String CasePriority { get; set; }
    
    @AuraEnabled
    global String ZoneID { get; set; }
    
    @AuraEnabled
    global String ZoneTitle { get; set; }
    
    @AuraEnabled
    global String ZoneForceID { get; set; }
    
    @AuraEnabled
    global String MCForceID { get; set; }
    
    @AuraEnabled
    global String SWForceID { get; set; }
    
    @AuraEnabled
    global String LeavedZoneTitle { get; set; }
    
    @AuraEnabled
    global String LeavedZoneID { get; set; }
    
    @AuraEnabled
    global String CreateDate { get; set; }
    
    @AuraEnabled
    global String Extensions { get; set; }
    
    @AuraEnabled
    global String UrlLink { get; set; }
    
    @AuraEnabled
    global String AcceptanceCriteria { get; set; }
    
    @AuraEnabled
    global Decimal Width { get; set; }
    
    @AuraEnabled
    global Decimal Height { get; set; }
    
    @AuraEnabled
    global Decimal Top { get; set; }
    
    @AuraEnabled
    global Decimal Bottom { get; set; }
    
    @AuraEnabled
    global Decimal Left { get; set; }
    
    @AuraEnabled
    global Decimal X { get; set; }
    
    @AuraEnabled
    global Decimal Y { get; set; }
    
    @AuraEnabled
    global String resourceId { get; set; }
    
    @AuraEnabled
    global Decimal percentCompleted { get; set; }
    
    @AuraEnabled
    global String State { get; set; }
    
    @AuraEnabled
    global String Color { get; set; }
    
    @AuraEnabled
    global String AccountName { get; set; }
    
    @AuraEnabled
    global String AssignToId { get; set; }
    
    @AuraEnabled
    global Boolean IsSuccessorRecalculate { get; set; }
    
    @AuraEnabled
    global String DueDateStatus { get; set; }
    
    @AuraEnabled
    global Integer filesCount { get; set; }
    
    @AuraEnabled
    public Boolean hasReadAccessForProject { get; set; }
    
    @AuraEnabled
    public Boolean hasReadAccessForValueStream { get; set; }
    
    @AuraEnabled
    public Boolean SWeek { get; set; }
    
    @AuraEnabled
    public String Category { get; set; }
    
    @AuraEnabled
    public String MasterContainer { get; set; }
    
    @AuraEnabled
    public String Swimlane { get; set; }
    
    @AuraEnabled
    public String Zone { get; set; }
 
        public Card(){}    
                        
        public Integer compareTo(Object myworkRecord1) {    
            leankor.ProjectBoardCarousel.Card myworkRecord = (leankor.ProjectBoardCarousel.Card)myworkRecord1;

            String SourceDueDate = dateFormatter(DueDate.dateGMT());
            String compareDate = dateFormatter(myworkRecord.DueDate.dateGMT());
            Integer i = SourceDueDate.CompareTo(compareDate);
            
            if (i == 0) {
                String prjName = myworkRecord.ProjectRoomName != null ? myworkRecord.ProjectRoomName : '';
                ProjectRoomName = ProjectRoomName != null ? ProjectRoomName : '';         
                i = ProjectRoomName.CompareTo(prjName);

                if (i == 0) {
                    String vsName = myworkRecord.ValueStreamName != null ? myworkRecord.ValueStreamName : '';
                    ValueStreamName = ValueStreamName != null ? ValueStreamName : '';
                    i = ValueStreamName.CompareTo(vsName);

                    if (i == 0) {
                        String cmpType = myworkRecord.ItemType != null ? myworkRecord.ItemType : '';
                        ItemType = ItemType != null ? ItemType : '';
                        i = ItemType.CompareTo(cmpType);                        
                        
                        if (i == 0) {
                            String cardName = myworkRecord.Name != null ? myworkRecord.Name : '';
                            Name = Name != null ? Name : '';
                            
                            i = Name.CompareTo(cardName);
                        }
                    }
                } 
            }
                
            return i;
        }
    }  

         
    @ReadOnly 
    @RemoteAction
    global static List<KanbanCardData> getCardHierarchyNav() {  
        return new List<KanbanCardData>();   
    }   


    @RemoteAction
    global static List<KanbanCardData> getCardHierarchy() {
        return new List<KanbanCardData>();
    } 


    @RemoteAction
    global static List<leankor.ProjectBoardCarousel.Card> getMyWorkItems(String type) {
        return new List<leankor.ProjectBoardCarousel.Card>();
    } 

    
    //DCO 1/30/2018 AuraEnabled method to get my work item list
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static String getMyWorkItemListToLightning(String type) {   
        return JSON.serialize(getMyWorkItemList(type));        
    }
    //DCO 1/30/2018
    
    //DCO 1/30/2018 AuraEnabled method to get my work filter list
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static String getMyWorkItemsByFilterToLightning(String JSONFilterObj) {
        String returnString = '';
        try {
            returnString = JSON.serialize(getMyWorkItemsByFilter((WorkFilter)(JSON.deserialize(JSONFilterObj, WorkFilter.class))));
        }
        catch(Exception e) {
            returnString = e.getMessage();
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        return returnString;
    }
    //DCO 1/30/2018

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static String getMyWorkItemsByFilterToLightningAll(String JSONFilterObj, List<String> itemTypes) {
        String returnString = '';
        List<leankor.ProjectBoardCarousel.Card> cards = new List<leankor.ProjectBoardCarousel.Card>();
        try {
            WorkFilter workFilter = (WorkFilter) JSON.deserialize(JSONFilterObj, WorkFilter.class);
            for(String itemType : itemTypes) {
                workFilter.itemType = itemType;
                cards.addAll(getMyWorkItemsByFilter(workFilter));
            }
            returnString = JSON.serialize(cards);

        } catch(Exception e) {
            returnString = e.getMessage();
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }

        return returnString;
    }
          
    @ReadOnly 
    @RemoteAction
    global static List<KanbanCardData> getMyWorkItemList(String filterData) {
        WorkFilter workFilter =(WorkFilter)JSON.deserialize(filterData, WorkFilter.class);
        String type = workFilter.filterType;
        workFilter.isMyWorkTaskLoad = getMyWorkTaskLoad();
        WorkFilter.itemType = BLANKTEXT;
            
        if (type.equalsIgnoreCase('WORKBYPROJECT')) {
        
            return getWorkByProject(workFilter);
        } else if(type.equalsIgnoreCase('COMPLETEDWORK')) {

            return getCompletedWork(workFilter.isMyWorkTaskLoad); 
        }else if(type.equalsIgnoreCase('PRIORITYWORK')){
        
            return getPriorityWork(workFilter);
        }else if(type.equalsIgnoreCase('WORKBYTYPE')){
        
            return getWorkByType(workFilter);
        }else{          
            
            return getWorkByDueDate(workFilter); // default filter - by dueDate        
        }
    } 

    @AuraEnabled
    public  static List<KanbanCardResponse> getMyWorkItemListAura(String filterData) {
        try {
           List<KanbanCardData> kanbandata = getMyWorkItemList(filterData);

            // Convert to the response type expected by Lightning
            List<KanbanCardResponse> response = new List<KanbanCardResponse>();
            for (KanbanCardData data : kanbandata) {
               KanbanCardResponse kanban = new KanbanCardResponse();
               kanban.Name = data.Name;
               kanban.ChildCount = data.ChildCount;
               kanban.Color = data.Color;
               kanban.PriorityIndex = data.PriorityIndex;
               kanban.Id = data.Id;
               kanban.ChildRecords = data.ChildRecords;
               response.add(kanban);
            }
            return response;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @TestVisible
    private static String getSoftDeletedKanbanCards(){
        String dynQuerySoftDeletedCards = 'SELECT Id '+ 
                                            'FROM leankor__KanbanCard__c '+ 
                                            'WHERE (leankor__ValueStream__r.leankor__IsRecordDeleted__c = TRUE '+ 
                                            'OR leankor__IsRecordDeleted__c = TRUE '+ 
                                            'OR leankor__ValueStream__r.leankor__IsTemplateBoard__c = true '+ 
                                            'OR leankor__MasterContainer__r.leankor__Type__c = \'Template\') ';
        
        return dynQuerySoftDeletedCards;
    }   
    
    
    @TestVisible
    private static Boolean isKanbanCardHasTasks() {
        List<Task> kanbanCardList = [SELECT Id FROM Task WHERE (What.Type = 'leankor__KanbanCard__c' AND IsDeleted = false) LIMIT 1];
        
        if (kanbanCardList == null || kanbanCardList.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }

    
    // Get MyWorkTaskLoad value from custom setting
    @RemoteAction
    global static Boolean getMyWorkTaskLoad(){
        return leankor__LeanConstants__c.getInstance().leankor__MyWorkLoadsTasks__c;
    }
    

    // Updating MyWorkTaskLoad value
    @RemoteAction
    @AuraEnabled
    global static Boolean updateMyWorkTaskLoad(Boolean myWorkLoadsTasks) {
        //Check CRUD / FLC behavior
        LeanConstantsBehaviour leanConstantsBehaviour = new LeanConstantsBehaviour();
        if (
            !leanConstantsBehaviour.isAccessible() ||
            !leanConstantsBehaviour.isUpdateable()
        ) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor__LeanConstants__c LeanConstant = leankor__LeanConstants__c.getOrgDefaults();
        LeanConstant.leankor__MyWorkLoadsTasks__c = myWorkLoadsTasks;
        
        try {
            update LeanConstant;
        } catch(Exception ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        return LeanConstant.leankor__MyWorkLoadsTasks__c;
    }

    
    @TestVisible
    private static List<KanbanCardData> getCompletedWork(Boolean isMyWorkTaskLoad) { 
        List<KanbanCardData> result = new List<KanbanCardData>();
        //07.07.2017 commenting code for now because we are hiding completed section from my work
        return result;
    }
  

    // Inner class of filter on my work.
    global class WorkFilter {   
        global String filterType;      
        global Integer priorityType;
        global String projectId;
        global String itemType;
        global String dueDateType;
        global String completedType;    
        public Boolean isMyWorkTaskLoad; 
        public String rangeStartDate;
        public String rangeEndDate;
    } 


    // Added @ReadOnly annotation to getMyWorkItemsByFilter and created new method getWIByFilterReadOnly for calling it
    @RemoteAction
    @ReadOnly
    global static List<leankor.ProjectBoardCarousel.Card> getWIByFilterReadOnly(WorkFilter filterObj) {
        if (String.isNotBlank(filterObj.projectId) && Util.getSObjectName(filterObj.projectId) != 'Leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        return getMyWorkItemsByFilter(filterObj);
    }

    @AuraEnabled
    @RemoteAction
    @ReadOnly
    global static List<leankor.ProjectBoardCarousel.Card> getWIByFilter(String filterData) {
        WorkFilter filterObj =(WorkFilter)JSON.deserialize(filterData, WorkFilter.class);
        if (String.isNotBlank(filterObj.projectId) && Util.getSObjectName(filterObj.projectId) != 'Leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        return getMyWorkItemsByFilter(filterObj);
    }
    

    // This method return data of mywork when click on tab as lazy loading.
    @RemoteAction
    global static List<leankor.ProjectBoardCarousel.Card> getMyWorkItemsByFilter(WorkFilter filterObj) {
        if (String.isNotBlank(filterObj.projectId) && Util.getSObjectName(filterObj.projectId) != 'Leankor__ProjectRoom__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }             
        /*getting my work item data filter by dueDate and type */          
        if(filterObj.filterType.equalsIgnoreCase('WORKBYDUEDATE') && String.isNotBlank(filterObj.dueDateType))
        {
          return getWorkItemsByDueDate(filterObj);
                                 
        }
        /*getting my work item data filter by project and projectId */   
        else if(filterObj.filterType.equalsIgnoreCase('WORKBYPROJECT') && String.isNotBlank(filterObj.projectId)){
        
          return getWorkItemsByProject(filterObj);
          
        }
        /*getting my work item data filter by priority and Priority type */   
        else if(filterObj.filterType.equalsIgnoreCase('PRIORITYWORK')){
        
          return getPriorityWorkItems(filterObj);
                 
        }
        /*getting my work item data filter by type and recordtype */   
        else if(filterObj.filterType.equalsIgnoreCase('WORKBYTYPE') && String.isNotBlank(filterObj.itemType)){
          
          return getWorkItemsByType(filterObj);
                       
        }
        /*getting my work item data filter by completed work and tyoe */   
        else if(filterObj.filterType.equalsIgnoreCase('COMPLETEDWORK') && String.isNotBlank(filterObj.completedType)){
               
          return getCompletedWorkItems(filterObj);                       
        }
                                       
        return new List<leankor.ProjectBoardCarousel.Card>();
    }
    

    //getting itmes by  DueDate filter
    @TestVisible
    private static List<leankor.ProjectBoardCarousel.Card> getWorkItemsByDueDate(WorkFilter filterObj){
          //Change limits from 250 to 500
          //Integer recLimit = 250;       
          Integer recLimit = 500;
        List<leankor.ProjectBoardCarousel.Card> kcCards = new List<leankor.ProjectBoardCarousel.Card>();
          List<leankor__KanbanCard__c> kclist = new List<leankor__KanbanCard__c>();
          List<leankor__KanbanCard__c> kclist1 = new List<leankor__KanbanCard__c>();
          List<Task> KCTaskLogs = new List<Task>();
          Boolean isTask = false;
          
          /*SS 23.07.2018*/
          //List<String> softDeletedCardList = getSoftDeletedKanbanCards();
          String dynQuerySoftDeletedCards = getSoftDeletedKanbanCards();
          
          //first we are checking myworktaskload is true or not
          if(getMyWorkTaskLoad())
          {
            //checking task is available or not
                isTask = isKanbanCardHasTasks();
          }
          
          // Date: 04/11/2019 - Changes related to date range filter
          //kclist1 = getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID',KCTaskLogs,filterObj.dueDateType);
          filterObj.itemType = filterObj.dueDateType;
          kclist1 = getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID',KCTaskLogs,filterObj);
                
        kcCards = getCardDataByList(filterObj , kclist1);
        
        //checking istask available or not
            if(isTask)
            {
                /*SS 23.07.2018*/
                //KCTaskLogs =  getIncompleteTaskList_1(recLimit, softDeletedCardList,filterObj.dueDateType);dynQuerySoftDeletedCards
                KCTaskLogs =  getIncompleteTaskList_1(recLimit, dynQuerySoftDeletedCards,filterObj);
                /**/
             
          /* getting task with kanban card data as format of inner class object variable */
            kcCards.addAll(getTaskDataByList(filterObj,KCTaskLogs));
            }
          
        kcCards.sort();

        return kcCards;        
    }
    

    //getting itmes by  Project filter
    @TestVisible
    private static List<leankor.ProjectBoardCarousel.Card> getWorkItemsByProject(WorkFilter filterObj){
        
        // Date: 04/11/2019
        filterObj.itemType = BLANKTEXT;
         //Change limits from 250 to 500
          //Integer recLimit = 250;       
          Integer recLimit = 500;       
        List<leankor.ProjectBoardCarousel.Card> kcCards = new List<leankor.ProjectBoardCarousel.Card>();
          List<leankor__KanbanCard__c> kclist = new List<leankor__KanbanCard__c>();
          List<leankor__KanbanCard__c> kclist1 = new List<leankor__KanbanCard__c>();
          List<Task> KCTaskLogs = new List<Task>();
          Boolean isTask = false;
          Set<Id> cards =  RealTimeControllerHelper.getProjectCards(filterObj); 
          //first we are checking myworktaskload is true or not
        if(getMyWorkTaskLoad()){

            //checking task is available or not
                isTask = isKanbanCardHasTasks();
          }
          
        //kclist = getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID', KCTaskLogs,BLANKTEXT);  
        kclist = getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID', KCTaskLogs,filterObj);
                                        
        for(leankor__KanbanCard__C k : kclist){
            
            if(cards.contains(k.Id)){
                
                kclist1.add(k);
            }
        }
                              
        kcCards = getCardDataByList(filterObj , kclist1);
          
          //checking istask available or not
        if(isTask){

            /*SS 23.07.2018*/
            //callin method and getting softdeleted and template card data
            
            //List<String> softDeletedCardList = getSoftDeletedKanbanCards(); 
            //List<Task> tasklist = getIncompleteTaskList_1(recLimit,softDeletedCardList, BLANKTEXT);
            
            String dynQuerySoftDeletedCards = getSoftDeletedKanbanCards(); 
            /**LastChange */
            //List<Task> tasklist = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, BLANKTEXT);
            List<Task> tasklist = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, filterObj);
            
            for(Task t : tasklist){
                 if(cards.contains(t.WhatId)){
                    KCTaskLogs.add(t);
                 }
            }
              
            /* getting task with kanban card data as format of inner class object variable */
            KCcards.addAll(getTaskDataByList(filterObj,KCTaskLogs));
          }
          
        KCcards.sort();

        return KCcards;
    }
    
    //getting itmes by  CompletedWork filter
    @TestVisible
    private static List<leankor.ProjectBoardCarousel.Card> getCompletedWorkItems(WorkFilter filterObj){
          List<leankor.ProjectBoardCarousel.Card> KCcards = new List<leankor.ProjectBoardCarousel.Card>();
          return KCcards;  
    }
    

    // Getting itmes by  Priority filter
    @TestVisible
    private static List<leankor.ProjectBoardCarousel.Card> getPriorityWorkItems(WorkFilter filterObj){
        
      //Change limits from 250 to 500
          //Integer recLimit = 250;       
          Integer recLimit = 500;       
          List<leankor.ProjectBoardCarousel.Card> KCcards = new List<leankor.ProjectBoardCarousel.Card>();
          List<leankor__KanbanCard__c> kclist = new List<leankor__KanbanCard__c>();
          List<leankor__KanbanCard__c> kclist1 = new List<leankor__KanbanCard__c>();
          List<Task> KCTaskLogs = new List<Task>();
          Boolean isTask = false;
          
          //first we are checking myworktaskload is true or not
        if(getMyWorkTaskLoad()){
            
            //checking task is available or not
                isTask = isKanbanCardHasTasks();
          }
          
        //kclist =  getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID', KCTaskLogs, BLANKTEXT); 
        filterObj.itemType = BLANKTEXT;
        kclist =  getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID', KCTaskLogs, filterObj); 
          
          for(leankor__KanbanCard__C k : kclist){
            
                 if(k.leankor__Priority__c == filterObj.priorityType) {
                
                    kclist1.add(k);
                 }
            }
          KCcards = getCardDataByList(filterObj , kclist1);
          
        if(isTask){

            String taskPriority = filterObj.priorityType == 1 ? 'High' :(filterObj.priorityType == 2 ? 'Normal' : ( filterObj.priorityType == 3 ? 'Low': null));
            
            // creating dynamic query for task.
            if(taskPriority != null){
                        
            
            /*SS 23.07.2018*/
            //callin method and getting softdeleted and template card data
            //List<String> softDeletedCardList = getSoftDeletedKanbanCards(); 
            //List<Task> tasklist = getIncompleteTaskList_1(recLimit,softDeletedCardList, BLANKTEXT);
            
            String dynQuerySoftDeletedCards = getSoftDeletedKanbanCards(); 
                //List<Task> tasklist = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, BLANKTEXT);
                List<Task> tasklist = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, filterObj);
                
            for(Task t : tasklist){
                 if(t.Priority == taskPriority){
                    KCTaskLogs.add(t);
                 }
            }
              /* getting task with kanban card data as format of inner class object variable */
              KCcards.addAll(getTaskDataByList(filterObj,KCTaskLogs));
            }
          }
           
         KCcards.sort();
           return KCcards;        
    }


    // Getting itmes by type filter
    @TestVisible
    private static List<leankor.ProjectBoardCarousel.Card> getWorkItemsByType(WorkFilter filterObj){
      
       //Change limits from 250 to 500
          //Integer recLimit = 250;       
          Integer recLimit = 500;       
        List<leankor.ProjectBoardCarousel.Card> kcCardsActivity = new List<leankor.ProjectBoardCarousel.Card>();
        List<leankor__KanbanCard__c> kcList = new List<leankor__KanbanCard__c>();        
        List<leankor__KanbanCard__c> kcList1 = new List<leankor__KanbanCard__c>();        
        List<Task> KCTaskLogs = new List<Task>();
                         
        // Date: 09/11/2019 - Chanages related to date rage filter on mywork
        String itemType =  filterObj.itemType;
        filterObj.itemType = BLANKTEXT;                         
      
        if(itemType.equalsIgnoreCase('TASK')){
        
        Boolean isTask = false;
        
        //first we are checking myworktaskload is true or not
            if(getMyWorkTaskLoad()){
                
        //checking task is available or not
            isTask = isKanbanCardHasTasks();
      }
          
            if(isTask){
          /*SS 23.07.2018*/
          //List<String> softDeletedCardList = getSoftDeletedKanbanCards(); 
          //KCTaskLogs = getIncompleteTaskList_1(recLimit,softDeletedCardList, BLANKTEXT);
          
          String dynQuerySoftDeletedCards = getSoftDeletedKanbanCards();
                //Date: 04/11/2019
                //KCTaskLogs = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, BLANKTEXT); 
                KCTaskLogs = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, filterObj);
                filterObj.itemType = itemType; // After querying the data we need to set the itemType values to input values.
          /**/
            /* getting task with kanban card data as format of inner class object variable */
            kcCardsActivity = getTaskDataByList(filterObj,KCTaskLogs);
        }

        }else{

      KCTaskLogs = new List<Task>();
            //Date: 04/11/2019
            //kclist =  getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID', KCTaskLogs, BLANKTEXT);
            kclist =  getIncompleteKanbanCardList(recLimit,'WORKBYPROJECTID', KCTaskLogs, filterObj);
            filterObj.itemType = itemType; // After querying the data we need to set the itemType values to input values. 

      for(leankor__KanbanCard__C kanban : kclist){

      //***** SS 22.06.2018 *****// 
      /*if(filterObj.itemType.equalsIgnoreCase('MILESTONE') && kanban.RecordType.Name == 'MileStoneCard' && kanban.leankor__Boardtype__c == 'UberBoard'){
        kcList1.add(kanban);    
      }*/
      //Now we have milestone on other board (CV) also
      if(filterObj.itemType.equalsIgnoreCase('MILESTONE') && kanban.RecordType.Name == 'MileStoneCard'){
        kcList1.add(kanban);        
      }
      //***** SS 22.06.2018 *****//
      else if(filterObj.itemType.equalsIgnoreCase('ACTIVITY') && kanban.RecordType.Name == 'ActivityCard'  && kanban.leankor__Boardtype__c == 'UberBoard'){
        kcList1.add(kanban);        
      }else if(filterObj.itemType.equalsIgnoreCase('CARD') && kanban.RecordType.Name == 'ActivityCard'  && kanban.leankor__Boardtype__c != 'UberBoard'){
        kcList1.add(kanban);              
      }
      
      }
      kcCardsActivity = getCardDataByList(filterObj,kcList1);
      }      
      
      kcCardsActivity.sort();
      return kcCardsActivity;        
    }
    
    //getting kanbancard data as inner class format----------
    @TestVisible
    private static List<leankor.ProjectBoardCarousel.Card> getCardDataByList(WorkFilter filterObj , List<leankor__KanbanCard__c> kclist){
        
        List<leankor.ProjectBoardCarousel.Card> KCcards = new List<leankor.ProjectBoardCarousel.Card>();
        Map<string,Attachment> MapstickerAtt = new Map<string,Attachment> ();
        MapstickerAtt = getStickerAttchments(filterObj.dueDateType , 500 , kclist);
        //Get Files count and chatter count  for kanban cards.
        Map<String,GanttTaskBoard.RecordCount> mapOfCatterFilesdCount =new Map<String,GanttTaskBoard.RecordCount>();
        List<String> cards=new List<String>();
        //Date 22/07/19 add record id in set to avoid duplicate record.
        Set<String> allRecords =new Set<String>();
        for(leankor__KanbanCard__c kb:kclist){
            cards.add(kb.id);
            allRecords.add(kb.leankor__ValueStream__r.leankor__ProjectRoom__c);
            allRecords.add(kb.leankor__ValueStream__c);
        }       
        //Date :24/07/19 change to checking security access for Board and project.
        //UserRecordAccess sObject has limitation, can query only up to 200 record IDs so we are not using readRecordSecurity method.  
        Map<Id,leankor__ValueStream__c> vsSecurityMap = new Map<Id,leankor__ValueStream__c>([Select Id,UserRecordAccess.HasEditAccess,UserRecordAccess.HasReadAccess,UserRecordAccess.HasDeleteAccess from  leankor__ValueStream__c where Id in : allRecords]);
        Map<Id,leankor__ProjectRoom__c> projSecurityMap = new Map<Id,leankor__ProjectRoom__c>([Select Id,UserRecordAccess.HasEditAccess,UserRecordAccess.HasReadAccess,UserRecordAccess.HasDeleteAccess from  leankor__ProjectRoom__c where Id in : allRecords]);
        mapOfCatterFilesdCount=leankor.GanttTaskBoard.readRelatedRecordCount(cards);
        Date currentDate = System.today();         
        /*DateTime dateTimeStart = dateFormatter(currentDate) + DT_DAYSTART_SUFFIC;
        DateTime dateTimeEnd = dateFormatter(currentDate) + DT_DAYEND_SUFFIC;
        DateTime dateTimeEndWeek = dateFormatter(getStartOfTheWeek(currentDate).addDays(6)) + DT_DAYEND_SUFFIC;*/
        //DateTime dateTimeStart = (DateTime)Json.deserialize(Json.serialize(dateFormatter(currentDate) + DT_DAYSTART_SUFFIC), DateTime.class);
        //DateTime dateTimeEnd = (DateTime)Json.Deserialize(Json.serialize(dateFormatter(currentDate) + DT_DAYEND_SUFFIC), DateTime.class);
        //DateTime dateTimeEndWeek = (DateTime)Json.Deserialize(json.serialize(dateFormatter(getStartOfTheWeek(currentDate).addDays(6)) + DT_DAYEND_SUFFIC), DateTime.class);
        
        /** Date: 01/10/2019 : Covertion of current zone dateTime to GMT datetime  */  
        Date weekEnd = Util.getStartOfTheWeek(currentDate).addDays(6);  
        Date monthEnd = Util.getStartOfTheWeek(weekEnd).addDays(30); 
        DateTime dateTimeStart = getStartOfDay(currentDate);
        DateTime dateTimeEnd = getEndOfDay(currentDate);
        DateTime dateTimeEndWeek = getEndofDay(weekEnd);
        DateTime dateTimeEndMonth = getEndofDay(monthEnd);

        // Date: 07/01/2020 ------------------------------
        Set<Id> mcIds = new Set<Id>();
        Map<Id, Integer> mcMap = new Map<Id, Integer>();
        Map<Id, Integer> swMap = new Map<Id, Integer>();

        for (leankor__KanbanCard__c kanban: kclist){
            mcIds.add(kanban.leankor__MasterContainer__c);  
            mcIds.add(kanban.leankor__Swimlane__c);    
        }

        List <AggregateResult> resultSW = [Select leankor__MasterContainer__c mc,  
                                                    count(Id) swCount 
                                                From leankor__Swimlane__c 
                                                Where leankor__MasterContainer__c In :mcIds
                                                With Security_Enforced
                                                Group By leankor__MasterContainer__c];

        for(AggregateResult result: resultSW){
            if((Integer)result.get('swCount') > 1){
                mcMap.put((Id)result.get('mc'), (Integer)result.get('swCount'));
            }
        }

        List <AggregateResult> resultZone = [Select leankor__Swimlane__c sw,  
                                                    count(Id) zoneCount 
                                                From leankor__Zone__c 
                                                Where leankor__Swimlane__c In :mcIds
                                                With Security_Enforced
                                                Group By leankor__Swimlane__c];
        for(AggregateResult result: resultZone){
            if((Integer)result.get('zoneCount') > 1){
                swMap.put((Id)result.get('sw'), (Integer)result.get('zoneCount'));
            }
        }
        //07/06/2021 - Changes : Changes for sticker order on MyWork
        List<leankor__Sticker__c> listOfStickers = [Select Id,
                                                            Name
                                                        From leankor__Sticker__c 
                                                        With Security_Enforced
                                                        Order By Name
                                                        Limit 10000];
        listOfStickers.sort();                                            

        
        for (leankor__KanbanCard__c KC: kclist) {
            leankor.ProjectBoardCarousel.Card KClog = new leankor.ProjectBoardCarousel.Card();
            
            /*
             we are commenting those fields which dont need on my work.this fields was using to handle broadcast
             but better performance we are using another method for priority update and broadcasting so my work performance will
             be improve and will be reduce heap size limit also.
            */
            KClog.Name = KC.Name;
            KClog.Id = KC.ID;           
            KClog.Priority = KC.leankor__Priority__c == null || KC.leankor__Priority__c == 0 ? 4 : KC.leankor__Priority__c;
            KClog.DueDate = KC.leankor__DueDateTime__c;//JSON.Serialize(KC.leankor__DueDateTime__c);
            // rbo 07.18.2018
            KClog.DueDateStatus = 
                (KC.leankor__DueDateTime__c < dateTimeStart) ? 'OVERDUE' : (KC.leankor__DueDateTime__c >= dateTimeStart && KC.leankor__DueDateTime__c < dateTimeEnd) 
                        ? 'DUE TODAY' : (KC.leankor__DueDateTime__c > dateTimeEnd && KC.leankor__DueDateTime__c <= dateTimeEndWeek) 
                            ? 'THIS WEEK' : (KC.leankor__DueDateTime__c > dateTimeEndWeek && KC.leankor__DueDateTime__c <= dateTimeEndMonth)
                            ? 'NEXT 30 DAYS' : (KC.leankor__DueDateTime__c > dateTimeEndMonth) ? 'LATER' : '';
            // rbo 07.18.2018            
            KClog.StartDate = KC.leankor__StartDateTime__c;
            KClog.ValueStream = KC.leankor__ValueStream__c;
            KClog.ValueStreamName = (KC.leankor__ValueStream__r.leankor__BoardType__C == 'UberBoard' ? 'Plan Gantt' : (KC.leankor__ValueStream__r.leankor__BoardType__C == 'Plan Board' ? 'Roll-Up': KC.leankor__ValueStream__r.Name));
            KClog.BoardType = KC.leankor__ValueStream__r.leankor__BoardType__C;
            KClog.GUID = KC.leankor__GUID__c;
            KClog.Title = KC.leankor__Title__c;
            //KClog.ProjectRoomName = KC.leankor__ValueStream__r.leankor__projectroom__r.name;
            KClog.ProjectRoomName = KC.leankor__projectRoom__C;                
            KClog.HarveyBall = KC.leankor__PercentComplete2__c;
            KClog.OwnerID = KC.OwnerId;
            KClog.OwnerName = KC.Owner.Name;
            KClog.ForceID = KC.Id;
            //RS 12/09/2018 
            KClog.ValueStreamCardLink = KC.leankor__valuestreamcardlink__c == null ? '' : KC.leankor__valuestreamcardlink__c;
            //RS 26/10/2018 Added IssuccessorRecalculate 
            //Date :02/11/19 check IsScheduleRecalculate.  if IsSuccessorRecalculate or IsScheduleRecalculate true ,value of IsSuccessorRecalculate is set true as per discuss with ui dev.
            KClog.IsSuccessorRecalculate = (KC.leankor__IsSuccessorRecalculate__c ||KC.leankor__ValueStream__r.leankor__IsScheduleRecalculate__c)?true:false;
            
            // Date: 03/02/2019 - changes to return the this fields on my work.
            KClog.Description = KC.leankor__DescriptionLong__c;
            KClog.Category = KC.leankor__KanbanCardTemplate__r.Name;
            KClog.MasterContainer = KC.leankor__MasterContainer__r.Name;
            if(mcMap.containsKey(KC.leankor__MasterContainer__c)){
                KClog.Swimlane = KC.leankor__Swimlane__r.Name;
            }
            if(swMap.containsKey(KC.leankor__Swimlane__c)){
                KClog.Zone = KC.leankor__Zone__r.Name;
            }
			// Pratiksha : 07/06/2021 - Changes : Changes for sticker order on MyWork
            List<String> stickerIdList = new List<String>();
            if(KC.leankor__KanbanCardStickers__r.size()>0)
            {
                List<Attachment> attobject= new List<Attachment>();
                for(leankor__KanbanCardSticker__c KCstick: KC.leankor__KanbanCardStickers__r)
                {
                    if(MapstickerAtt.containskey(KCstick.leankor__Sticker__c)){
                        stickerIdList.add(KCstick.leankor__Sticker__c);
                        //attobject.add(MapstickerAtt.get(KCstick.leankor__Sticker__c));
                    }
                }
                List<String> sortedStickerList = new List<String>();
               
                for(leankor__Sticker__c sticker : listOfStickers){
                    if(stickerIdList.contains(sticker.id)){
                    sortedStickerList.add(sticker.id);
                }
                }
                for(String stickerId : sortedStickerList){
                    attobject.add(MapstickerAtt.get(stickerId)); 
                }
                if(attobject.size() >0)
                {
                    KClog.Sticker = attobject;
                }
            }
            
            if(mapOfCatterFilesdCount.containskey(KC.ID)){
                //commented on 17/04/19  using mapOfCatterFilesdCount.
               // KClog.chattercount = Mapchattercount.get(KC.ID);
                // Date : 17/04/19 
                leankor.GanttTaskBoard.RecordCount chatterFileCount=mapOfCatterFilesdCount.get(KC.ID);
                KClog.filesCount= chatterFileCount.filesCount;
                KClog.chattercount =chatterFileCount.chattersCount;
            }else{
                KClog.chattercount = 0;
                KClog.filesCount=0;
            }            
                        
            //KClog.ProjectID = KC.leankor__ValueStream__r.leankor__ProjectRoom__C;
            KClog.leaf = true;
            //***** SS 21.06.2018 *****//
            //After milestone added on CV we have changed the condition for Item Type
            /*if(KClog.BoardType != 'UberBoard'){
                KClog.ItemType = 'CARD';
                if(KClog.BoardType == 'Plan Board'){
                    KClog.ItemType = (KC.RecordType.Name=='MilestoneCard'?'MILESTONE': 'CARD');
                }
            }else{
                KClog.ItemType = (KC.RecordType.Name=='ActivityCard'?'ACTIVITY' : (KC.RecordType.Name=='MilestoneCard'?'MILESTONE' : 'CARD'));               
            }*/
            //If board Type is not uberBoard then item type can be card/milestone(only on CV) 
            //On uberboard card is named as Activity
            if(KClog.BoardType != 'UberBoard')
            {
                KClog.ItemType = KC.RecordType.Name=='ActivityCard'?'CARD':'MILESTONE';
                //KClog.ItemType = KC.RecordType.Name=='ActivityCard'?'Card':'Milestone';
            }
            else
            {
                 KClog.ItemType = (KC.RecordType.Name=='ActivityCard'?'ACTIVITY' : 'MILESTONE');
                 //KClog.ItemType = (KC.RecordType.Name=='ActivityCard'?'Activity' : 'Milestone');
            }
            //***** SS 21.06.2018 *****//
            if(KC.RecordType.Name=='ActivityCard'){
              KCLog.resourceId = KC.leankor__ResourceAssignments__r[0].Id;
              KCLog.AssignToId = KC.leankor__ResourceAssignments__r[0].leankor__AssignedTo__c;
              KClog.percentCompleted = KC.leankor__ResourceAssignments__r[0].leankor__PercentCompleted__c == null ? 0 : KC.leankor__ResourceAssignments__r[0].leankor__PercentCompleted__c;
            }
            KClog.ProjectID = KC.leankor__ValueStream__r.leankor__ProjectRoom__C;           
            //Date :24/07/19 change to checking security access for Board and project.
            //UserRecordAccess sObject has limitation, can query only up to 200 record IDs so we are not using readRecordSecurity method.  
            /*KClog.hasReadAccessForProject=mapAccess.containsKey(KC.leankor__ValueStream__r.leankor__ProjectRoom__c) ? mapAccess.get(KC.leankor__ValueStream__r.leankor__ProjectRoom__c).HasReadAccess : false;    
            KClog.hasReadAccessForValueStream=mapAccess.containsKey(KC.leankor__ValueStream__c) ? mapAccess.get(KC.leankor__ValueStream__c).HasReadAccess : false;*/
            KClog.hasReadAccessForProject=projSecurityMap.containsKey(KC.leankor__ValueStream__r.leankor__ProjectRoom__c) ? projSecurityMap.get(KC.leankor__ValueStream__r.leankor__ProjectRoom__c).UserRecordAccess.HasReadAccess : false;    
            KClog.hasReadAccessForValueStream=vsSecurityMap.containsKey(KC.leankor__ValueStream__c) ? vsSecurityMap.get(KC.leankor__ValueStream__c).UserRecordAccess.HasReadAccess : false;
            //Date :19/11/19 added SevenDayWorkWeek field.
            KClog.SWeek=KC.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c!=null ? KC.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c:false;
            KCcards.add(KClog);          
        }
        
        return KCcards;
    }
    

    //getting task data as inner class format----------
    @TestVisible
    private static List<leankor.ProjectBoardCarousel.Card> getTaskDataByList(WorkFilter filterObj,List<Task> KCTaskLogs){
    
      List<leankor.ProjectBoardCarousel.Card> KCcards = new List<leankor.ProjectBoardCarousel.Card>();
      
      map<string,Integer> Mapchattercount = new map<string,Integer> ();
      map<ID,leankor__Kanbancard__c> Kclogs = new map<ID,leankor__Kanbancard__c>();
      
      set<string> CardsID = new set<string>();
        //set<string> TaskIDs = new set<string>();
            
      for(Task KCTask : KCTaskLogs ){
           CardsID.add(KCTask.WhatID);
           //TaskIDs.add(KCTask.ID);
      }
             
      //get chatter feeds for tasks
        Mapchattercount = getTaskChatterCount(KCTaskLogs);
        
        // Date: 03/05/2019 -  To get data without sharing 
        /*if(filterObj.projectId != null)
        {
          Kclogs = new Map<ID,leankor__Kanbancard__c>([Select ID, leankor__MasterContainer__r.leankor__Type__c,Name,leankor__ValueStream__c,leankor__ValueStream__r.Name,leankor__ValueStream__r.leankor__BoardType__C,leankor__ValueStream__r.leankor__ProjectRoom__C,leankor__ProjectRoom__c, leankor__ValueStream__r.leankor__ProjectRoom__r.UserRecordAccess.HasReadAccess, leankor__ValueStream__r.UserRecordAccess.HasReadAccess from leankor__KanbanCard__c where ID IN :CardsID AND  leankor__ValueStream__r.leankor__ProjectRoom__c =: filterObj.projectId limit 49999]);
        }else{       
          Kclogs = new Map<ID,leankor__Kanbancard__c>([Select ID,Name,leankor__ValueStream__c,leankor__ValueStream__r.Name,leankor__ValueStream__r.leankor__BoardType__C,leankor__ValueStream__r.leankor__ProjectRoom__C,leankor__ProjectRoom__c, leankor__ValueStream__r.leankor__ProjectRoom__r.UserRecordAccess.HasReadAccess, leankor__ValueStream__r.UserRecordAccess.HasReadAccess from leankor__KanbanCard__c where ID IN :CardsID limit 49999]);
        }*/
        
        // Date: 15/05/2019 - Geting data without sharing
        Kclogs = leankor.RealTimeControllerHelper.getTaskDataByList_Helper(CardsID, filterObj.projectId);
        //Date 22/07/19 add record id into set to avoid duplicate id.
        Set<String> accessIdList = new Set<String>();
        for(Id id : Kclogs.keySet()){
            accessIdList.add(Kclogs.get(id).leankor__ValueStream__r.leankor__ProjectRoom__c);
            accessIdList.add(Kclogs.get(id).leankor__ValueStream__c);
        }
        //Date :24/07/19 change to checking security access for Board and project.
        //UserRecordAccess sObject has limitation, can query only up to 200 record IDs so we are not using readRecordSecurity method.  
        Map<Id,leankor__ValueStream__c> vsSecurityMap = new Map<Id,leankor__ValueStream__c>([Select Id,UserRecordAccess.HasEditAccess,UserRecordAccess.HasReadAccess,UserRecordAccess.HasDeleteAccess from  leankor__ValueStream__c where Id in : accessIdList]);
        Map<Id,leankor__ProjectRoom__c> projSecurityMap = new Map<Id,leankor__ProjectRoom__c>([Select Id,UserRecordAccess.HasEditAccess,UserRecordAccess.HasReadAccess,UserRecordAccess.HasDeleteAccess from  leankor__ProjectRoom__c where Id in : accessIdList]);
        //Map <String, UserRecordAccess> recordAccessMap =  readRecordSecurity(new List<String>(accessIdList));
        // rbo 07.18.2018
        Date currentDate = System.today();         
        /*DateTime dateTimeStart = dateFormatter(currentDate) + DT_DAYSTART_SUFFIC;
        DateTime dateTimeEnd = dateFormatter(currentDate) + DT_DAYEND_SUFFIC;
        DateTime dateTimeEndWeek = dateFormatter(getStartOfTheWeek(currentDate).addDays(6)) + DT_DAYEND_SUFFIC;*/
        DateTime dateTimeStart = (DateTime)Json.deserialize(Json.serialize(dateFormatter(currentDate) + DT_DAYSTART_SUFFIC), DateTime.class);
        DateTime dateTimeEnd = (DateTime)Json.Deserialize(Json.serialize(dateFormatter(currentDate) + DT_DAYEND_SUFFIC), DateTime.class);
        DateTime dateTimeEndWeek = (DateTime)Json.Deserialize(json.serialize(dateFormatter(Util.getStartOfTheWeek(currentDate).addDays(6)) + DT_DAYEND_SUFFIC), DateTime.class);
        // rbo 07.18.2018 
             
        for (Task KCTask :KCTaskLogs) {
            if (Kclogs.containskey(KCTask.WhatID)) {
                leankor.ProjectBoardCarousel.Card KCtasklog = new leankor.ProjectBoardCarousel.Card();
                leankor__Kanbancard__c KC= Kclogs.get(KCTask.WhatID);               
                KCtasklog.Name= KCTask.Subject;
                KCtasklog.Id= KCTask.ID;
                KCtasklog.Status = KCTask.Status;
                KCtasklog.OwnerID = KCTask.OwnerId;
                KCtasklog.OwnerName = KCTask.Owner.Name;
                KCtasklog.Description = (KCTask.Description== null? '':KCTask.Description);
                KCtasklog.TaskPriority = KCTask.Priority;
                KCtasklog.ValueStream = KC.leankor__ValueStream__c; 
                KCtasklog.ValueStreamName = (KC.leankor__ValueStream__r.leankor__BoardType__C == 'UberBoard' ? 'Plan Gantt' : (KC.leankor__ValueStream__r.leankor__BoardType__C == 'Plan Board' ? 'Roll-Up': KC.leankor__ValueStream__r.Name));
                KCtasklog.BoardType = KC.leankor__ValueStream__r.leankor__BoardType__C;
                KCtasklog.ProjectRoomName = KC.leankor__ProjectRoom__c;
                KCtasklog.ProjectID = KC.leankor__ValueStream__r.leankor__ProjectRoom__C;
                KCtasklog.WhatName = KC.Name;
                KCtasklog.WhatID = KCTask.WhatID;
                KCtasklog.DueDate = Datetime.newInstanceGmt(KCTask.ActivityDate.year(),KCTask.ActivityDate.month(), KCTask.ActivityDate.day(), 10, 01, 01);
                //Date :24/07/19 change to checking security access for Board and project.
                KCtasklog.hasReadAccessForProject =  projSecurityMap.get(KC.leankor__ValueStream__r.leankor__ProjectRoom__c).UserRecordAccess.HasReadAccess;
                KCtasklog.hasReadAccessForValueStream = vsSecurityMap.get(KC.leankor__ValueStream__c).UserRecordAccess.HasReadAccess;
                // rbo 07.18.2018
                /*KClog.DueDateStatus = 
                    (KCtasklog.DueDate < dateTimeStart) ? 'OVERDUE' : (KCtasklog.DueDate >= dateTimeStart && KCtasklog.DueDate < dateTimeEnd) 
                            ? 'DUE TODAY' : (KCtasklog.DueDate > dateTimeEnd && KCtasklog.DueDate <= dateTimeEndWeek) 
                                ? 'THIS WEEK' : (KCtasklog.DueDate > dateTimeEndWeek) ? 'LATER' : '';*/
                KCtasklog.DueDateStatus = 
                    (KCtasklog.DueDate < dateTimeStart) ? 'OVERDUE' : (KCtasklog.DueDate >= dateTimeStart && KCtasklog.DueDate < dateTimeEnd) 
                            ? 'DUE TODAY' : (KCtasklog.DueDate > dateTimeEnd && KCtasklog.DueDate <= dateTimeEndWeek) 
                            ? 'THIS WEEK' : (KCtasklog.DueDate > dateTimeEndWeek) ? 'LATER' : '';               
                KCtasklog.ItemType='TASK';
                if(Mapchattercount.containskey(KCtasklog.ID)) {
                    KCtasklog.chattercount = Mapchattercount.get(KCTask.ID);
                } else {
                    KCtasklog.chattercount = 0;
                }
                KCtasklog.leaf = true;
                KCcards.add(KCtasklog);
            }
        }  
        return KCcards;  
    }
    

    //-------------getting stickers for kanban card---------
    @TestVisible
    private static Map<String, Attachment> getStickerAttchments(String dueType, Integer recLimit, List<leankor__KanbanCard__c> kanbanList){
        Map<String, Attachment> stickerMap = new Map<String, Attachment>();
        List<Id> sticketIdList = new List<Id>();

        // rbo 08.07.17 this is part of the Technical Debt 
        // 1. Changed the LIMIT number to 49999
        // 2. Converted to SOQL for LOOPS   
        /*
        for(leankor__KanbanCardSticker__c sticker : [SELECT Id, leankor__KanbanCard__c, leankor__Sticker__c FROM leankor__KanbanCardSticker__c WHERE leankor__KanbanCard__c In :kanbanList]){
            sticketIdList.add(sticker.leankor__Sticker__c);
        }
        */

        for (leankor__KanbanCardSticker__c[] sticker : [Select Id, 
                                                                leankor__Sticker__c 
                                                            From leankor__KanbanCardSticker__c 
                                                            Where leankor__KanbanCard__c In :kanbanList 
                                                            With Security_Enforced
                                                            Limit 9999]){
            for (Integer iCount = 0; iCount < sticker.size(); iCount++) {
                sticketIdList.add(sticker[iCount].leankor__Sticker__c);
            }
        }

        for (Attachment[] att : [Select Id, 
                                        ParentId 
                                    From Attachment 
                                    Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                        And ParentId In :sticketIdList 
                                    Limit 9999]) {
            for (Integer iCount = 0; iCount < att.size(); iCount++) {                           
                stickerMap.put(att[iCount].ParentId, att[iCount]);
            }
        }           
        return stickerMap;
    }
    

    //-------------getting Chatter Count for task---------
    @TestVisible
    private static Map<String, Integer> getTaskChatterCount(List<Task> taskList){
        Map<String, Integer> chatterCount = new Map<String, Integer>();

        Integer count = 0;
        for(TaskFeed tf: [SELECT ParentId, Type FROM TaskFeed WHERE ParentId IN :taskList]){
            if(tf.Type != 'CreateRecordEvent'){
                if(chatterCount.containskey(tf.ParentId)){
                    count = chatterCount.get(tf.ParentId);
                    chatterCount.put(tf.ParentId, count+1);
                } else {
                    chatterCount.put(tf.ParentId, 1);
                }
            }
        }

        return chatterCount;
    }

    //making formatter date.
    @TestVisible
    private static String dateFormatter(Date originalDate){
        DateTime dt = DateTime.newInstance(originalDate.year(), originalDate.month(), originalDate.day());

        return dt.format('yyyy-MM-dd');
    }
    
    
    //update priority and handle broadcast mywork to board
    @RemoteAction
    @AuraEnabled
    global static void updatePriority(String priorityData1) { 
         leankor.realTimeController.StateChangePackage priorityData =(leankor.realTimeController.StateChangePackage)JSON.deserialize(priorityData1, leankor.realTimeController.StateChangePackage.class);
        if (String.isNotBlank(priorityData.Id) && Util.getSObjectName(priorityData.Id) != 'leankor__KanbanCard__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        
        if (!kanbanCardBehaviour.isUpdateable()) 
        {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor.realtimeController.bulkStreaming > ListJSONrecords = new List<leankor.realtimeController.bulkStreaming>();
        leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
        kc.Id = priorityData.Id;
        kc.leankor__Priority__c = priorityData.Priority;
        
        // Updating card with priority
        try {
            update kc;
        } catch(DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        
        // Making data for broadcasting
        leankor.realTimeController.CardStreamingPackage RemoteKanban = new leankor.realTimeController.CardStreamingPackage();
        RemoteKanban.Id = priorityData.Id;
        RemoteKanban.Name = priorityData.Name;                  
        RemoteKanban.ValueStream  = priorityData.ValueStream;   
                        
        leankor.realtimeController.bulkStreaming ListJSONLog = new leankor.realtimeController.bulkStreaming();

        ListJSONLog.SomeJSONData = JSON.Serialize(RemoteKanban);
        ListJSONLog.VSID =  priorityData.ValueStream;                    
        ListJSONLog.SessionID = priorityData.sessionId;
        ListJSONLog.Verb = 'UpdateKanbanCard';
        ListJSONrecords.add(ListJSONLog);
        
        //calling method for broadcast mean inerting data into realtimetracker object
        leankor.realtimeController.defaultLinkBroadcasting(ListJSONrecords, 'UpdateKanbanCard');
    }
    
    
    @remoteAction
    global static List<portfoliodata> getParentportfolio()
    {
        List<portfoliodata> result = new List<portfoliodata>();
        /*
        List<Leankor__Portfolio__c> Insertlog = [Select id, 
                                                        Name,
                                                        Leankor__ParentPortfolio__c 
                                                    From Leankor__Portfolio__c 
                                                    With Security_Enforced
                                                    Order By Name Asc
                                                    Limit 50000];
        
        for(leankor__Portfolio__c PFdata : Insertlog){

            if(PFdata.Leankor__ParentPortfolio__c == null){
                portfoliodata resultLog = new portfoliodata ();
                resultLog.Id = PFdata.ID;
                resultLog.Name =PFdata.Name;
                resultLog.ParentPortfolio =PFdata.Leankor__ParentPortfolio__c ;
                result.add(resultLog);
            }
        }
        */
        return result;
    }

    
    @RemoteAction
    global static List<portfoliodata> getChildportfolio(string parentID) {
        List<portfoliodata> result = new List<portfoliodata>();
        /*
        if (String.isNotBlank(parentID) && Util.getSObjectName(parentID) != 'leankor__Portfolio__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        
        List<leankor__Portfolio__c> Insertlog = [Select id,
                                                    Name,
                                                    leankor__ParentPortfolio__c 
                                                From leankor__Portfolio__c 
                                                Where leankor__ParentPortfolio__c = :parentID 
                                                With Security_Enforced
                                                Order By Name Asc Nulls First 
                                                Limit 49999];

        for(leankor__Portfolio__c PFdata : Insertlog){
            portfoliodata resultLog = new portfoliodata ();
            resultLog.Id = PFdata.ID;
            resultLog.Name =PFdata.Name;
            resultLog.ParentPortfolio =PFdata.leankor__ParentPortfolio__c ;
            result.add(resultLog);
        }
        */
        return result;
    }


    @RemoteAction
    global static Set<PortfolioHierarchy> moveRoom(List<portfoliodata> updatePFlog) {
        for(portfoliodata pfData:updatePFlog){
            if(String.isNotBlank(pfData.Id) && (Util.getSObjectName(pfData.Id) != 'leankor__ProjectRoom__c'
            && Util.getSObjectName(pfData.Id) != 'leankor__Portfolio__c')) {
                throw new ProjectBoardCarouselException('Error: Invalid input');
            }
        }
        //Check CRUD / FLC behavior
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        ExpenseBehaviour expenseBehaviour = new ExpenseBehaviour();
        if (!portfolioBehaviour.isUpdateable() || 
            !projectRoomBehaviour.isUpdateable() ||
            !expenseBehaviour.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<portfoliodata> result = new List<portfoliodata>();
        List<leankor__Portfolio__c> updatelog = new List<leankor__Portfolio__c>();
        List<leankor__ProjectRoom__c> updateRoomlog = new List<leankor__ProjectRoom__c>();
        for (portfoliodata pFdata : updatePFlog) {
            if (pFdata.type == 'Room' || pFdata.type == 'Projects') {
                leankor__ProjectRoom__c roomLog = new leankor__ProjectRoom__c();
                roomLog.ID = pFdata.ID;
                roomLog.Name = pFdata.Name;
                roomLog.leankor__Portfolio__c = pFdata.ParentPortfolio;
                updateRoomlog.add(RoomLog);
            } else {
                leankor__Portfolio__c log = new leankor__Portfolio__c ();
                log.ID = pFdata.ID;
                log.Name = pFdata.Name;
                log.leankor__ParentPortfolio__c = pFdata.ParentPortfolio;
                updatelog.add(log);
            }
        }

        try {
            DataBase.Update(updatelog,false);
            DataBase.Update(updateRoomlog,false);
            Database.Update(updateFinancials(updateRoomlog), true);
        } catch (DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
       
        return new Set<PortfolioHierarchy>();   
    }
    

    public static List<leankor__Expense__c> updateFinancials(List<leankor__ProjectRoom__c> updateRooms) {   
        List<leankor__Expense__c> financials = new List<leankor__Expense__c>();
        
        for (leankor__Expense__c finance : [Select
                                                    Id, 
                                                    leankor__Portfolio__c 
                                                From leankor__Expense__c 
                                                Where leankor__Project__c In :updateRooms 
                                                With Security_Enforced
                                                Limit 49999]) {     
            
            finance.leankor__Portfolio__c = updateRooms[0].leankor__Portfolio__c;       
            financials.add(finance);        
        }
    
        return financials;
    }
    
    
    // This Method Is use to Create Project ProjectBoard.
    @RemoteAction
    @AuraEnabled
    global static List<ProjectRoomHierarchy> createListProjectBoard(String PrjName,String ProjectRoomId,String BoardType,String ProjectBoardId,String KanbanCardId){
        if ((String.isNotBlank(ProjectRoomId) && Util.getSObjectName(ProjectRoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(ProjectBoardId) && Util.getSObjectName(ProjectBoardId) != 'leankor__ValueStream__c')
            || (String.isNotBlank(KanbanCardId) && Util.getSObjectName(KanbanCardId) != 'leankor__KanbanCard__c')) {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        List<ProjectRoomHierarchy> boardList = new List<ProjectRoomHierarchy>();
        
        leankor.RealTimeController.ProjectBoard Pb = leankor.ProjectBoardCarousel.createProjectBoard(PrjName,ProjectRoomId,BoardType,ProjectBoardId,KanbanCardId);
        
        leankor__projectroom__c roomname = [Select Id, 
                                                    Name, 
                                                    leankor__IsTemplateProject__c 
                                                From leankor__projectroom__c 
                                                Where ID =: ProjectRoomId
                                                With Security_Enforced];

        Pb.IsTemplateBoard = roomname.leankor__IsTemplateProject__c;
        updateProjectBoard(Pb);
        
        ProjectRoomHierarchy board = new ProjectRoomHierarchy();
        board.Id = Pb.Id;
        board.Name = PrjName;               
        board.BoardType = BoardType;
        board.RoomId = ProjectRoomId;
        board.leaf = true;        
        board.hasEditAccess = Pb.hasEditAccess;  
        board.hasReadAccess = Pb.hasReadAccess;  
        board.hasDeleteAccess = Pb.hasDeleteAccess;  
               
        boardList.add(board);
              
        return boardList;  
    }

    @AuraEnabled 
    public static List<ProjectRoomHierarchyData>  createListProjectBoardAura(String prjName,String projectRoomId,String boardType,String projectBoardId,String kanbanCardId){
        try {
            System.debug(prjName);
            List<ProjectRoomHierarchy> projectRoomHierarchy = createListProjectBoard(prjName,projectRoomId,boardType,projectBoardId,kanbanCardId);
            List<ProjectRoomHierarchyData> boardList = new List<ProjectRoomHierarchyData>();
            for (ProjectRoomHierarchy roomHierarchy :projectRoomHierarchy) {
                ProjectRoomHierarchyData board = new ProjectRoomHierarchyData();
                board.Id = roomHierarchy.Id;
                board.name = prjName;               
                board.boardType = boardType;
                board.RoomId = ProjectRoomId;
                board.leaf = true;        
                board.hasEditAccess = roomHierarchy.hasEditAccess;  
                board.hasReadAccess = roomHierarchy.hasReadAccess;  
                board.hasDeleteAccess = roomHierarchy.hasDeleteAccess; 
                boardList.add(board);
            }
            return boardList;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** Update Name of the Value Stream Using Kanban Carousel*/
    @RemoteAction
    global static List<ProjectRoomHierarchy> updateListProjectBoard(leankor.RealTimeController.ProjectBoard pb) {
        if (String.isNotBlank(pb.Id) && Util.getSObjectName(pb.Id) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        
        if (!valueStreamBehavior.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        String returnString = 'Success';
        leankor__ValueStream__c VS = [Select Id, 
                                            leankor__projectroom__c, 
                                            leankor__projectroom__r.Name, 
                                            Name 
                                        From leankor__ValueStream__c 
                                        Where Id =: pb.Id 
                                        With Security_Enforced
                                        Limit 1];
        VS.Name = pb.Name;

        try {
            DataBase.update(VS, true);
        } catch(DMLException ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }

        return new List<ProjectRoomHierarchy>();
    }


    @RemoteAction
    global static Boolean checkUserAccessRecord(String someJSONData) {
        leankor.ProjectBoardCarousel.PortfolioHierarchy jsonItemData = (leankor.ProjectBoardCarousel.PortfolioHierarchy)JSON.deserialize(SomeJSONData,leankor.ProjectBoardCarousel.PortfolioHierarchy.class);
    
        UserRecordAccess URA = [SELECT RecordId,HasReadAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: jsonItemData.Id ];
        
        return URA.HasReadAccess; 
    }
    

    global class ResourcePercentCompleted {   
        global List<Id> RAIds;
        global List<Id> KanbanCardIds;
        global Decimal percentComplete;
        global String JSONString;
        global String mySessionID;     
        global String ValueStreamId;
        global Decimal HarveyBall;
        global String KanbanIds;     
    } 

        
    public static Boolean updateActivityPercentageComplete(List<Id> kanbanCardIdList) {
        //Check CRUD / FLC behavior
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        
        if (!resourceAssignmentBehavior.isUpdateable()){
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__ResourceAssignment__c> raList = new List<leankor__ResourceAssignment__c>();
        //if list if empty, don't procced with the logic
        if (kanbanCardIdList.isEmpty() || kanbanCardIdList == null || kanbanCardIdList.size() == 0) {
            return false;
        }

        //get the Kanbancard list
        Map<Id, leankor__KanbanCard__c> kanbanCardMap = new Map<Id, leankor__KanbanCard__c>([Select Id, 
                                                                                                    leankor__PercentComplete2__c 
                                                                                                From leankor__KanbanCard__c 
                                                                                                Where Id In :kanbanCardIdList
                                                                                                With Security_Enforced]);

        //get the RA list based
        for(leankor__ResourceAssignment__c ra : [Select Id, 
                                                        leankor__KanbanCard__c, 
                                                        leankor__PercentCompleted__c,
                                                        leankor__CompletedDate__c 
                                                    From leankor__ResourceAssignment__c 
                                                    Where leankor__KanbanCard__c In :kanbanCardIdList
                                                    With Security_Enforced]){
            
            leankor__KanbanCard__c kard = kanbanCardMap.get(ra.leankor__KanbanCard__c);
              //when we update percent complete of RA equals 100% then we update completed date of RA
              if(ra.leankor__PercentCompleted__c == 100){
                
                ra.leankor__PercentCompleted__c = kard.leankor__PercentComplete2__c;
                
              }else{               
                ra.leankor__PercentCompleted__c = kard.leankor__PercentComplete2__c;
                ra.leankor__CompletedDate__c = ra.leankor__PercentCompleted__c == 100 ? DateTime.now() : ra.leankor__CompletedDate__c ;                             
              }
            raList.add(ra);
        }

        try {
           Update raList; 
        } catch(DmlException e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }        

        return true;
    }


    //This methods accepts list of kanban card ids and update Kanban card % completed based on % allocated  
    public static boolean raPercentageAllocatedChanged(List<Id> kanbanCardList) {
        //check if resource assignment list is not null or empty
        if (kanbanCardList.isEmpty() || kanbanCardList == null || kanbanCardList.size() == 0) {
            return false;        
        }

        return updatePercentageAllocated(kanbanCardList);
    }

    
    //DCO 1/30/2018 AuraEnabled method to update resource allocation
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static string updateRAPercentageCompletedLightning(String stringRApercentComplete) {
        String returnString = '';
        List<ResourcePercentCompleted> RApercentComplete;
        try {
            RApercentComplete = (List<ResourcePercentCompleted>) JSON.deserialize(stringRApercentComplete, List<ResourcePercentCompleted>.class);
            RApercentComplete[0].mySessionID = UserInfo.getSessionId();
            returnString = JSON.serialize(updateRAPercentageCompleted_1(RApercentComplete));
        } catch (Exception e) {
            returnString = 'ERROR: ' + e.getMessage();
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        
        return returnString;
    }
    //DCO 1/30/2018
    

    //this method update leankor__PercentCompleted__c from user changes on my work Items.
    // need to depricate
    @RemoteAction
    global static string updateRAPercentageCompleted(List<ResourcePercentCompleted> RApercentComplete) {     
        return '';
    }


    // This method update leankor__PercentCompleted__c from user changes on my work Items.
    @RemoteAction
    global static List<ResourcePercentCompleted> updateRAPercentageCompleted_1(List<ResourcePercentCompleted> RApercentComplete) {     
        for(ResourcePercentCompleted r : RApercentComplete){
            for(Id ra : r.KanbanCardIds){
                if ((String.isNotBlank(ra) && Util.getSObjectName(ra) != 'leankor__KanbanCard__c')){
                    throw new ProjectBoardCarouselException('Error: Invalid input');
                }
            }
        
            for(Id ra : r.RAIds){
                if(String.isNotBlank(ra) && Util.getSObjectName(ra) != 'leankor__ResourceAssignment__c'){
                    throw new ProjectBoardCarouselException('Error: Invalid input');
                }
            }
        }
        //Check CRUD / FLC behavior
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
        
        if (!resourceAssignmentBehavior.isUpdateable()){
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__ResourceAssignment__c> result = new List<leankor__ResourceAssignment__c>();                      
        for(leankor__ResourceAssignment__c ra : [Select Id,
                                                        leankor__CompletedDate__c,
                                                        leankor__PercentCompleted__c 
                                                    From leankor__ResourceAssignment__c 
                                                    Where Id In :RApercentComplete[0].RAIds
                                                    With Security_Enforced]){ 
                                                                    
             ra.leankor__CompletedDate__c = (RApercentComplete[0].percentComplete == 100 && RApercentComplete[0].percentComplete != ra.leankor__PercentCompleted__c ? DateTime.now() : ra.leankor__CompletedDate__c);
             ra.leankor__PercentCompleted__c = RApercentComplete[0].percentComplete;
                                                                                      
             result.add(ra); 
        }        
        try {       
            update result;  
        }catch (DmlException e){           
            //return new List<ResourcePercentCompleted>();
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        
        //calculate percent again according change percent on RA
        Boolean flag = raPercentageCompleteChanged(RApercentComplete[0].KanbanCardIds);       
        
        //getting PercentComplete
        List<leankor__KanbanCard__c> kclist = [Select Id,
                                                        leankor__PercentComplete2__c,
                                                        leankor__Valuestream__c 
                                                    From leankor__KanbanCard__c 
                                                    Where Id In : RApercentComplete[0].KanbanCardIds
                                                    With Security_Enforced]; 
        
        //deserialize and assign new HarveyBall and again serialize to string
        leankor.realTimeController.CardStreamingPackage SCP = (leankor.realTimeController.CardStreamingPackage)JSON.deserialize(RApercentComplete[0].JSONString, leankor.realTimeController.CardStreamingPackage.class);       
        
        //leankor.realTimeController.CardStreamingPackage SCPnew = new leankor.realTimeController.CardStreamingPackage();            
        SCP.HarveyBall = kclist[0].leankor__PercentComplete2__c;        
        SCP.State =  'Unable';
             
        String result1 = JSON.serialize(SCP);
        
        //calling kanbanstatechange method for UpdateHarveyBall
        leankor.realTimeController.manageStatechange(kclist[0].leankor__Valuestream__c,'UpdateHarveyBall',result1,RApercentComplete[0].mySessionID);       
        
        List<ResourcePercentCompleted> rpcList = new List<ResourcePercentCompleted>();
        
        ResourcePercentCompleted rpc = new ResourcePercentCompleted();
        rpc.JSONString = result1;
        rpc.HarveyBall = kclist[0].leankor__PercentComplete2__c;
        rpc.ValueStreamId = kclist[0].leankor__Valuestream__c;
        rpc.KanbanIds = JSON.serialize(leankor.RealTimeController.gskanbanCardIds);
        leankor.RealTimeController.gskanbanCardIds.clear();
  
        rpcList.add(rpc);
        
        return rpcList;
    }
    

    // This method accepts list of Kanban card ids, calculate individual % completed and update the Kanban card % complete
    public static boolean raPercentageCompleteChanged(List<Id> kanbanCardList) {        
        //check if resource assignment list is not null or empty
        if (kanbanCardList.isEmpty() || kanbanCardList == null || kanbanCardList.size() == 0) {
            return false;
        }

        return updatePercentageAllocated(kanbanCardList);
    }
  

    @TestVisible
    private static Boolean updatePercentageAllocated(List<Id> kanbanCardList) {
        Map<Id, List<leankor__ResourceAssignment__c>> raMap = new Map<Id, List<leankor__ResourceAssignment__c>>();

        //Find the RA records / activity ids for the given RA record list.
        List<leankor__ResourceAssignment__c> raList = [Select Id, 
                                                            leankor__KanbanCard__c, 
                                                            leankor__PercentCompleted__c, 
                                                            leankor__PercentAllocation__c,
                                                            leankor__ResourceType__c 
                                                        From leankor__ResourceAssignment__c 
                                                    Where leankor__KanbanCard__c In :kanbanCardList 
                                                    With Security_Enforced                                                     
                                                    Order By leankor__KanbanCard__c];

        //find all RA records under each activity
        for(leankor__ResourceAssignment__c r : raList){
            //Do not include RA related to Resource Type in %cent Calculation
            // Now we will include RA related to Resource Type in %cent Calculation.
            if(raMap.containsKey(r.leankor__KanbanCard__c)){
                List<leankor__ResourceAssignment__c> ra = raMap.get(r.leankor__KanbanCard__c);
                ra.add(r);
                raMap.put(r.leankor__KanbanCard__c, ra);
            } else {
                List<leankor__ResourceAssignment__c> ra = new List<leankor__ResourceAssignment__c>();
                ra.add(r);
                raMap.put(r.leankor__KanbanCard__c, ra);
            }
        }
        updateKanbanCardPercentageCompleted(raMap, kanbanCardList);
        return true;
    }


    @TestVisible
    private static void updateKanbanCardPercentageCompleted(Map<Id, List<leankor__ResourceAssignment__c>> raMap, List<Id> kanbanCardList) {
        //Check CRUD / FLC behavior
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isUpdateable()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor__KanbanCard__c> updatedCardList = new List<leankor__KanbanCard__c>();
        //Get all Kanban card record list
        List<leankor__KanbanCard__c> cardList = [Select Id,
                                                    leankor__PercentComplete2__c,
                                                    leankor__ValueStreamCardLink__c 
                                                From leankor__KanbanCard__c
                                                Where Id In :raMap.keySet() 
                                                With Security_Enforced
                                                Limit 9999];

        for (leankor__KanbanCard__c k : cardList) {
            k.leankor__PercentComplete2__c = computeKBPercentageCompleted(raMap.get(k.Id)).round().intValue();
            updatedCardList.add(k);
        }
        
        update updatedCardList;
        //leankor.realtimeController.KCupdatePVcard(JSON.serialize(updatedCardList));
        leankor.RealTimeController.updateParentCards(updatedCardList);
    }


    // This method accepts a RA, calculate individual % completed and update the Kanban card % complete
    @TestVisible
    private static Decimal computeKBPercentageCompleted(List<leankor__ResourceAssignment__c> raList){
        Decimal totalAllocated = 0;
        Decimal totaKBCompleted = 0;

        for (leankor__ResourceAssignment__c ra : raList) {
            totalAllocated = totalAllocated + ra.leankor__PercentAllocation__c;
        }

        for (leankor__ResourceAssignment__c ra : raList) {
            totaKBCompleted = totaKBCompleted + computeRAPercentageCompleted(ra, totalAllocated);
        }        
  
        return totaKBCompleted;
    }


    // This method calculate % completed contribution to a KB
    @TestVisible
    private static Decimal computeRAPercentageCompleted(leankor__ResourceAssignment__c ra, Decimal totalRA){
        Decimal raContributionToKB = 0;
        raContributionToKB = (ra.leankor__PercentCompleted__c == null ? 0 :  ra.leankor__PercentCompleted__c)* (ra.leankor__PercentAllocation__c  / (totalRA == 0 ? 1 : totalRA));

        //round to 2 decimal points before return the value
        return raContributionToKB.setScale(2);
    }
             
    // This method calculate % completed contribution to a KB
    @RemoteAction
    @AuraEnabled
    global static void insertRealTimeTrackerRecord(Id ValueStreamID, String Verb, String SomeJSONData, String SessionID) {
        System.debug('insertRealTimeTrackerRecord' + ValueStreamID);
     
        if (String.isNotBlank(ValueStreamID) && Util.getSObjectName(ValueStreamID) != 'leankor__ValueStream__c') {
         
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        List<String> JSONList = new List<String>{SomeJSONData};
        leankor.GenericStreamingController.createRealtimeTracker(ValueStreamID ,Verb, JSONList, SessionID);     
    }
    
  
    /*SS 23.07.2018*/
    //Change parameter  List<String> softDeletedCardList to String dynQuerySoftDeletedCards
    @TestVisible
    private static List<SObject> getIncompleteTaskList_1(Integer recLimit, String dynQuerySoftDeletedCards, WorkFilter filterData) {
        String itemType = filterData.itemType;
        List<SObject> taskList = new List<SObject>();
        List<SObject> filteredTaskList = new List<SObject>();
        List<SObject> FinalTaskList = new List<SObject>();
        
        String queryString = '';
        //ss 11.05.2018 
        //Date currentDate = Date.today();
        //Date weekStart = currentDate.toStartofWeek();   //Sunday
        //Date weekEnd = weekStart.addDays(6);            //Saturday
        
        Date currentDate = System.today();
        //getStartOfTheWeek() method will return startDayOfWeek which is used for calculating last day of week
        Date weekEnd = Util.getStartOfTheWeek(currentDate).addDays(6);              
        Date monthEnd = weekEnd.addDays(30); 
                     
        //ss 11.05.2018
        /*String soql = 'SELECT Id, Subject, ActivityDate,Priority, leankor__CompletedDate__c,Status,WhatID, Owner.Name,OwnerId,Description ' +
                                    'FROM Task WHERE OwnerID= \'' + userinfo.getuserID() + '\' AND ' +
                                        'Status != \'Completed\' AND  ' +
                                        'What.Type = \'leankor__KanbanCard__c\' AND ' +
                                        'WhatID NOT IN :softDeletedCardList ';*/
        /*SS 23.07.2018*/                       
        //Instead of passing kanbanCardRecord list now pass dyn query for kanbanCard which will be queried as where clause query                 
        /*String soql = 'SELECT Id, Subject, ActivityDate,Priority,Status,WhatID, Owner.Name,OwnerId,Description ' +
                                    'FROM Task WHERE (OwnerID= \'' + userinfo.getuserID() + '\' AND ' +
                                        'Status != \'Completed\' AND  ' +
                                        'What.Type = \'leankor__KanbanCard__c\' AND ' +
                                        'WhatID NOT IN :softDeletedCardList ';*/
        
        Map<Id, sObject> parentRecords = new Map<Id, sObject>(Database.query(dynQuerySoftDeletedCards));

        String soql = 'SELECT Id, Subject, ActivityDate,Priority,Status,WhatID, Owner.Name,OwnerId,Description ' +
                                    'FROM Task WHERE (OwnerID= \'' + userinfo.getuserID() + '\' AND ' +
                                        'What.Type = \'Leankor__KanbanCard__c\' ';
                                                                                
        String endAlias =' AND IsDeleted = false) ORDER BY ActivityDate LIMIT ' + recLimit;                               
        
        //if(itemType == BLANKTEXT || itemType == 'OVERDUE'){
        if(itemType == BLANKTEXT || itemType == 'MWOverdue'){
            queryString = soql + ' AND ActivityDate < ' + dateFormatter(currentDate) +endAlias;
            filteredTaskList.addAll(Database.query(queryString));
        }
        
        //if(itemType == BLANKTEXT || itemType == 'DUE TODAY'){
        if(itemType == BLANKTEXT || itemType == 'MWDueToday'){
            queryString = soql + ' AND ActivityDate = ' + dateFormatter(currentDate) +endAlias;
            filteredTaskList.addAll(Database.query(queryString));
         }
        
        //if(itemType == BLANKTEXT || itemType == 'THIS WEEK'){ 
        if(itemType == BLANKTEXT || itemType == 'MWThisWeek'){ 
            queryString = soql + ' AND ActivityDate > ' + dateFormatter(currentDate)  + ' AND ActivityDate <= ' + dateFormatter(weekEnd) +endAlias;
            filteredTaskList.addAll(Database.query(queryString));
        }
        
        //if(itemType == BLANKTEXT || itemType == 'NEXT 30 DAYS'){ 
        if(itemType == BLANKTEXT || itemType == 'MWNext30Days'){ 
            queryString = soql + ' AND ActivityDate > ' + dateFormatter(weekEnd)  + ' AND ActivityDate <= ' + dateFormatter(monthEnd) +endAlias;
            filteredTaskList.addAll(Database.query(queryString));
        }
            
        //if(itemType == BLANKTEXT || itemType == 'LATER'){
        if(itemType == BLANKTEXT || itemType == 'MWLater'){
            queryString = soql + ' AND ActivityDate > ' + dateFormatter(monthEnd) + endAlias;
            filteredTaskList.addAll(Database.query(queryString));
        }
        
        // Date: 09/11/2019 - Changes related to date range filter on mywork
        Set<String> cardIDs = new Set<String>();        
        
        if (String.isNotBlank(String.valueOf(filterData.rangeStartDate)) && String.isNotBlank(String.valueOf(filterData.rangeEndDate))) { 
            // From UI side only start of the day passed in GMT for start and due date
            Datetime startDateRange = ((DateTime)JSON.deserialize('"'+filterData.rangeStartDate+'"', DateTime.class));
            Datetime endDateRange = (DateTime)JSON.deserialize('"'+filterData.rangeEndDate+'"', DateTime.class);
            endDateRange = (endDateRange + 1).addSeconds(-1); // To get the end of the day
        
            for(SObject t : filteredTaskList){         
                Task tsk = (Task)t;
                if(tsk.Status != 'Completed' && !parentRecords.containsKey(tsk.WhatID)){
                    if (tsk.ActivityDate >= startDateRange && tsk.ActivityDate <= endDateRange){       
                        cardIDs.add(tsk.WhatID);
                    }
                }
            }
        } else {

            /** yj 30.03.2018-checking card is available or not for Task*/      
            for(SObject t : filteredTaskList){         
                Task tsk = (Task)t;
                if(tsk.Status != 'Completed' && !parentRecords.containsKey(tsk.WhatID)){
                    cardIDs.add(tsk.WhatID);
                }
            }
        }

        // Date: 04/11/2019 
        Map<ID,leankor__Kanbancard__c> kcLogs = cardIDs.size()>0? new Map<ID,leankor__Kanbancard__c>([Select ID 
                                                                                                            From leankor__KanbanCard__c 
                                                                                                            Where Id In :cardIDs 
                                                                                                            With Security_Enforced
                                                                                                            Limit 49999]) 
                                                                : new Map<ID,leankor__Kanbancard__c>();
    
        for(SObject KCTask :filteredTaskList){
            Task tsk = (Task)KCTask;
            if(kcLogs.containskey(tsk.WhatID) && tsk.Status != 'Completed'){
                FinalTaskList.add(KCTask);
            }
        }
        
        return FinalTaskList;
    }
        

    @TestVisible
    private static List<SObject> getIncompleteKanbanCardList(Integer recLimit, String projectFlag, List<Task> taskIdSet, WorkFilter filterData) {
        String itemType = filterData.itemType;
        List<sObject> allKanbancards = new List<sObject>();
        List<sObject> filteredKanbancards = new List<sObject>();
        
        // Date: 06/01/2020- more fields are added in query
        String startAlias = 'SELECT Id, Name,'
                    +' Leankor__IsSuccessorRecalculate__c,'
                    +' Leankor__ValueStreamCardLink__c,'
                    +' Leankor__Boardtype__c,'
                    +' RecordType.Name,' 
                    +' Leankor__DueDateTime__c,'
                    +' Leankor__StartDateTime__c,Leankor__Priority__c,'
                    +' Leankor__ValueStream__r.Leankor__ProjectRoom__r.Leankor__Portfolio__c,'
                    +' Leankor__ValueStream__r.Leankor__ProjectRoom__r.UserRecordAccess.HasReadAccess,'
                    +' Leankor__ValueStream__r.UserRecordAccess.HasReadAccess,'
                    +' Leankor__ValueStream__r.Leankor__SevenDayWorkWeek__c,'
                    +' Leankor__DescriptionLong__c,' 
                    +' Leankor__KanbanCardTemplate__r.name, '
                    +' Leankor__MasterContainer__r.Name,'
                    +' Leankor__Swimlane__r.Name,'
                    +' Leankor__Zone__r.Name,'
                    +' leankor__PercentComplete2__c,'
                    +' leankor__MasterContainer__r.leankor__Type__c';
        String endAlias ='ORDER BY Leankor__DueDateTime__c,Leankor__StartDateTime__c,Leankor__ValueStream__r.Leankor__projectroom__r.name, Leankor__ValueStream__c, Leankor__ValueStream__r.name   ASC LIMIT ' + recLimit;
        String queryString = '';

        //ss 11.05.2018 
        //Date currentDate = Date.today();
        //Date weekStart = currentDate.toStartofWeek();   //Sunday
        //Date weekEnd = weekStart.addDays(6);            //Saturday
        
        Date currentDate = System.today();
        
        //getStartOfTheWeek() method will return startDayOfWeek which is used for calculating last day of week
        Date weekEnd = Util.getStartOfTheWeek(currentDate).addDays(6);              
        Date monthEnd = weekEnd.addDays(30);             

        /** Date: 01/10/2019 : Covertion of current zone dateTime to GMT datetime  */   
       
        String dayStartString = getStartOfDayTime(currentDate);
        String dayEndString = getEndOfDayTime(currentDate);
        String weekEndString = getEndOfDayTime(weekEnd);
        String monthEndString = getEndOfDayTime(monthEnd);

        //ss 11.05.2018
        // Date: 06/01/2020 - more fields are added into the query
        if(projectFlag == 'WORKBYPROJECT'){
            startAlias = 'SELECT Id, leankor__IsSuccessorRecalculate__c,Name,leankor__ValueStreamCardLink__c,leankor__ValueStream__c,  leankor__ValueStream__r.leankor__ProjectRoom__c,leankor__ProjectRoom__c, leankor__DueDateTime__c,leankor__StartDateTime__c, leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c, leankor__ValueStream__r.leankor__ProjectRoom__r.UserRecordAccess.HasReadAccess, leankor__ValueStream__r.UserRecordAccess.HasReadAccess,leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,leankor__ValueStream__r.leankor__IsScheduleRecalculate__c, leankor__DescriptionLong__c,leankor__KanbanCardTemplate__r.name, leankor__MasterContainer__r.Name, leankor__Swimlane__r.Name, leankor__Zone__r.Name, leankor__PercentComplete2__c, leankor__MasterContainer__r.leankor__Type__c';
        } else if(projectFlag == 'WORKBYPROJECTID'){
            startAlias =  'Select ID,Name,leankor__IsSuccessorRecalculate__c,leankor__ValueStreamCardLink__c,leankor__BoardType__c,(SELECT Id,leankor__AssignedTo__c,leankor__PercentCompleted__c FROM leankor__ResourceAssignments__r WHERE leankor__AssignedTo__c = \'' + userinfo.getUserID() + '\'), (SELECT Id, leankor__KanbanCard__c, leankor__Sticker__c, Name FROM leankor__KanbanCardStickers__r),leankor__DueDateTime__c,leankor__StartDateTime__c,leankor__Priority__c,leankor__GUID__c, leankor__Title__c, leankor__ValueStream__c, leankor__ValueStream__r.name, leankor__projectRoom__C,RecordType.Name, leankor__PercentComplete2__c, leankor__ValueStream__r.leankor__BoardType__C, leankor__ValueStream__r.leankor__ProjectRoom__C, OwnerId, Owner.Name, leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c, leankor__ValueStream__r.leankor__ProjectRoom__r.UserRecordAccess.HasReadAccess, leankor__ValueStream__r.UserRecordAccess.HasReadAccess,leankor__ValueStream__r.leankor__SevenDayWorkWeek__c,leankor__ValueStream__r.leankor__IsScheduleRecalculate__c,leankor__DescriptionLong__c,leankor__KanbanCardTemplate__r.name, leankor__MasterContainer__r.Name, leankor__Swimlane__r.Name, leankor__Zone__r.Name, leankor__MasterContainer__r.leankor__Type__c';
        }
        
        String resourceAssignmentQuery = 'SELECT Leankor__KanbanCard__c, Leankor__PercentCompleted__c FROM Leankor__ResourceAssignment__c WHERE ' +
               'Leankor__AssignedTo__c = \'' + UserInfo.getUserID() + '\' AND Leankor__KanbanCard__r.RecordType.Name =\'ActivityCard\'';

        List<sObject> tempList = Database.query(resourceAssignmentQuery);
        Set<Id> resourceAssignmentIds = new Set<Id>();
        for(sObject obj: tempList){
            if((((Decimal) obj.get('Leankor__PercentCompleted__c'))) != 100){
                resourceAssignmentIds.add((Id)obj.get('Leankor__KanbanCard__c'));
            }
        }

            String soql = startAlias + ' FROM Leankor__KanbanCard__c where ' +
               'Id IN: resourceAssignmentIds AND Leankor__ValueStream__r.Leankor__IsTemplateBoard__c = false ' +
               'AND '+ //Leankor__MasterContainer__r.Leankor__Type__c != \'Template\' AND '+
               'Leankor__IsRecordDeleted__c = false AND Leankor__ValueStream__r.Leankor__IsRecordDeleted__c = false ';
               
        
                //if(itemType == '' || itemType == 'OVERDUE'){
                if(itemType == '' || itemType == 'MWOverdue'){
                    //queryString = soql + ' AND Leankor__DueDateTime__c < ' + dateFormatter(currentDate) + DT_DAYSTART_SUFFIC +endAlias;
                    queryString = soql + ' AND Leankor__DueDateTime__c < ' + dayStartString + ' ' + endAlias;
                    //filteredKanbancards.addAll( Database.query(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                }
                
                //if(itemType == '' || itemType == 'DUE TODAY'){
                if(itemType == '' || itemType == 'MWDueToday'){
                    //queryString = soql + ' AND Leankor__DueDateTime__c >=' + dateFormatter(currentDate) +DT_DAYSTART_SUFFIC+' AND Leankor__DueDateTime__c <' + dateFormatter(currentDate) +DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND Leankor__DueDateTime__c >=' + dayStartString +' AND Leankor__DueDateTime__c <' + dayEndString +' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                }
                
                //if(itemType == '' || itemType == 'THIS WEEK'){
                if(itemType == '' || itemType == 'MWThisWeek'){
                    //queryString = soql + ' AND Leankor__DueDateTime__c > ' + dateFormatter(currentDate)  + DT_DAYEND_SUFFIC+' AND Leankor__DueDateTime__c <= ' + dateFormatter(weekEnd) + DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND Leankor__DueDateTime__c > ' + dayEndString +' AND Leankor__DueDateTime__c <= ' + weekEndString +' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                }
                
                //if(itemType == '' || itemType == 'NEXT 30 DAYS'){
                if(itemType == '' || itemType == 'MWNext30Days'){
                    //queryString = soql + ' AND Leankor__DueDateTime__c > ' + dateFormatter(weekEnd)  + DT_DAYEND_SUFFIC+' AND Leankor__DueDateTime__c <= ' + dateFormatter(monthEnd) + DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND Leankor__DueDateTime__c > ' + weekEndString +' AND Leankor__DueDateTime__c <= ' + monthEndString+' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                }
                
                //if(itemType == '' || itemType == 'LATER'){
                if(itemType == '' || itemType == 'MWLater'){
                    //queryString = soql + ' AND Leankor__DueDateTime__c > ' + dateFormatter(monthEnd) +DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND Leankor__DueDateTime__c > ' + monthEndString +' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                }
        
            
             soql = startAlias + ' FROM leankor__KanbanCard__c where  OwnerID= \'' + userinfo.getuserID() + '\' AND ' +
             //***** SS 20.06.2018 *****//
             //Removed filter for getting Milestone of Calender View also
             'RecordType.Name = \'MilestoneCard\' AND leankor__ValueStream__r.leankor__IsTemplateBoard__c = false AND ' +
               //'leankor__Boardtype__c = \'UberBoard\' AND RecordType.Name = \'MilestoneCard\' AND leankor__ValueStream__r.leankor__IsTemplateBoard__c = false AND ' +
             //***** SS 20.06.2018 *****//             
               //'Leankor__MasterContainer__r.Leankor__Type__c IN: MASTERCONTAINERTYPEFILTERS_CONST AND ' +
               'leankor__IsRecordDeleted__c = false AND leankor__ValueStream__r.leankor__IsRecordDeleted__c = false ';
               
                
                //if(itemType == '' || itemType == 'OVERDUE'){
                if(itemType == '' || itemType == 'MWOverdue'){
                    //queryString = soql + ' AND leankor__DueDateTime__c < ' + dateFormatter(currentDate) +DT_DAYSTART_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND leankor__DueDateTime__c < ' + dayStartString +' '+endAlias;
                    //filteredKanbancards.addAll( Database.query(queryString));
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));

                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                }
                
                //if(itemType == '' || itemType == 'DUE TODAY'){
                if(itemType == '' || itemType == 'MWDueToday'){
                    //queryString = soql + ' AND leankor__DueDateTime__c >=' + dateFormatter(currentDate) + DT_DAYSTART_SUFFIC+' AND leankor__DueDateTime__c <' + dateFormatter(currentDate) + DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND leankor__DueDateTime__c >=' + dayStartString +' AND leankor__DueDateTime__c <' + dayEndString +' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                }
                
                //if(itemType == '' || itemType == 'THIS WEEK'){
                if(itemType == '' || itemType == 'MWThisWeek'){
                    //queryString = soql + ' AND leankor__DueDateTime__c > ' + dateFormatter(currentDate)  + DT_DAYEND_SUFFIC+' AND leankor__DueDateTime__c <= ' + dateFormatter(weekEnd) + DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND leankor__DueDateTime__c > ' + dayEndString +' AND leankor__DueDateTime__c <= ' + weekEndString +' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                }
                
                //if(itemType == '' || itemType == 'NEXT 30 DAYS'){
                if(itemType == '' || itemType == 'MWNext30Days'){
                    //queryString = soql + ' AND Leankor__DueDateTime__c > ' + dateFormatter(weekEnd)  + DT_DAYEND_SUFFIC+' AND Leankor__DueDateTime__c <= ' + dateFormatter(monthEnd) + DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND Leankor__DueDateTime__c > ' + weekEndString +' AND Leankor__DueDateTime__c <= ' + monthEndString +' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                }
                
                //if(itemType == '' || itemType == 'LATER'){
                if(itemType == '' || itemType == 'MWLater'){
                    //queryString = soql + ' AND leankor__DueDateTime__c > ' + dateFormatter(monthEnd) + DT_DAYEND_SUFFIC+' '+endAlias;
                    queryString = soql + ' AND leankor__DueDateTime__c > ' + monthEndString +' '+endAlias;
                    //filteredKanbancards.addAll(Database.query(queryString));
                    //filteredKanbancards.addAll(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(queryString));
                    tempList = Database.query(queryString);
                    for(sObject obj: tempList){
                        Boolean isMSTypeTemplate = obj.getSobject('leankor__MasterContainer__r') == null ? false : obj.getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                        if((((Decimal) obj.get('Leankor__PercentComplete2__c'))) != 100 && !isMSTypeTemplate){
                            filteredKanbancards.add(obj);
                        }
                    }
                }
        
        
        if(projectFlag == 'WORKBYPROJECT' && taskIdSet.Size() > 0){     
            //getting kanban card data according task.          
            String soql1 =  startAlias + ' FROM Leankor__KanbanCard__c where Leankor__ValueStream__r.Leankor__IsTemplateBoard__c = false ' +
                            'AND Leankor__Boardtype__c IN: BOARDTYPEFILTERS_CONST AND Leankor__IsRecordDeleted__c = false AND '+
                            'Leankor__ValueStream__r.Leankor__IsRecordDeleted__c = false';  //AND Leankor__MasterContainer__r.Leankor__Type__c IN: MASTERCONTAINERTYPEFILTERS_CONST';
          
            /*If tasks are available, use task ids in the soql*/             
            if(taskIdSet.size() > 0  && taskIdSet != null){
                String whatIdList = '';
  
                for(Task t : taskIdSet){
                    whatIdList =  whatIdList + '\''+ t.WhatId + '\',';
                }
  
                soql1 += ' AND Id IN (' + whatIdList.substring(0,whatIdList.length() - 1) + ')';
                soql1 += ' ORDER BY leankor__DueDateTime__c,leankor__ValueStream__r.leankor__projectroom__r.name, leankor__ValueStream__c, leankor__ValueStream__r.name   ASC '; 
              
                //maping kanban card Id with kanban card object
                //RS 03/05/2019 Commented for security role and querying in without sharing class  
                map<Id,sobject> kcMap = new  map<Id,sobject>(Database.Query(soql1));
                //map<Id,sobject> kcMap = new  map<Id,sobject>(RealTimeControllerHelper.getIncompleteKanbanCardListHelper(soql1));
        
        
                //counting task according kanban card map contains task whatId.        
                for(Task t : taskIdSet){      
                    Boolean isMSTypeTemplate = kcMap.get(t.WhatId).getSobject('leankor__MasterContainer__r') == null ? false : kcMap.get(t.WhatId).getSobject('leankor__MasterContainer__r').get('leankor__Type__c') == 'Template' ? true : false;
                    if(kcMap.containsKey(t.WhatId) && !isMSTypeTemplate){
                        filteredKanbancards.add(kcMap.get(t.WhatId));
                    }              
                }
            }
        }


        if(String.isNotBlank(String.valueOf(filterData.rangeStartDate)) && String.isNotBlank(String.valueOf(filterData.rangeEndDate))){
            
            // From UI side only start of the day passed in GMT for start and due date
            Datetime startDateRange = ((DateTime)JSON.deserialize('"'+filterData.rangeStartDate+'"', DateTime.class));
            Datetime endDateRange = (DateTime)JSON.deserialize('"'+filterData.rangeEndDate+'"', DateTime.class);
            endDateRange = (endDateRange + 1).addSeconds(-1); // To get the end of the day

            for(leankor__KanbanCard__c kcFilter : (List<leankor__KanbanCard__c>) filteredKanbancards){

                if(kcFilter.leankor__DueDateTime__c >= startDateRange && kcFilter.leankor__DueDateTime__c <= endDateRange){

                    if(String.isNotBlank(kcFilter.leankor__ValueStream__c) && String.isNotBlank(kcFilter.leankor__ValueStream__r.leankor__ProjectRoom__c) &&  String.isNotBlank(kcFilter.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c) )
                    {
                        allKanbancards.add(kcFilter);
                    }
                }
            }
         } else {
            //Do not include card's which does not have Valuestream or Project value
            //Card's witout Valuestream or Project value were showing on MyWork with different filters
            for(leankor__KanbanCard__c kcFilter : (List<leankor__KanbanCard__c>) filteredKanbancards){

                if(String.isNotBlank(kcFilter.leankor__ValueStream__c) && String.isNotBlank(kcFilter.leankor__ValueStream__r.leankor__ProjectRoom__c) &&  String.isNotBlank(kcFilter.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c) )
                {
                    allKanbancards.add(kcFilter);
                }
            }
        }

        filteredKanbanCards.clear();
        return allKanbancards;
    }


    
     //-----------This method return cards and task count according Priority Levels----------   
    @TestVisible
    private static List<KanbanCardData> getPriorityWork(WorkFilter filterData){

        List<KanbanCardData> result = new List<KanbanCardData>();
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        List<Task> taskList = new List<Task>();
        //List<String> softDeletedCardList = new List<String>(); 
        String dynQuerySoftDeletedCards;
        Map<String,Integer> componentCount = new Map<String,Integer>{'HIGH' => 0,
                                                                  'CRITICAL' => 0,
                                                                  'MEDIUM' => 0,
                                                                  'NORMAL' => 0,
                                                                  'LOW' => 0,
                                                                  'NONE' => 0};
        //Change limits from 250 to 500
          //Integer recLimit = 250;       
          Integer recLimit = 500;
        Boolean isTask = false;
        //first we are checking myworktaskload is true or not
        if(filterData.isMyWorkTaskLoad){

             //checking task is available or not
              isTask = isKanbanCardHasTasks();
        }
        
        if(isTask){
            //get the soft deleted Kanban Card list
            /*SS 23.07.2018*/
            //softDeletedCardList = getSoftDeletedKanbanCards();
            //taskList = getIncompleteTaskList_1(recLimit,softDeletedCardList, BLANKTEXT);
            
            dynQuerySoftDeletedCards = getSoftDeletedKanbanCards();
            //taskList = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, BLANKTEXT); 
            taskList = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, filterData); 
            
            for(Task t : taskList){
                Integer taskCount = 1;
                    String priorityFlag = '';
                    
                    if(t.priority == 'High')
                    priorityFlag = 'HIGH';
                    else if(t.priority == 'Normal')
                    priorityFlag = 'NORMAL';
                    else if(t.priority == 'Low')
                    priorityFlag = 'LOW';
                    else
                    priorityFlag = 'NONE';
                    
                    taskCount += componentCount.get(priorityFlag);
                    componentCount.put(priorityFlag,taskCount);
            }
        }
        
        //kanbanCardList = getIncompleteKanbanCardList(recLimit, BLANKTEXT ,taskList, BLANKTEXT);
        kanbanCardList = getIncompleteKanbanCardList(recLimit, BLANKTEXT ,taskList, filterData);
        for(leankor__KanbanCard__C kanban : kanbanCardList){
                Integer kanbanCount = 1;
                String priorityFlag = '';
                    
                    if(kanban.leankor__Priority__c == 1.0)
                    priorityFlag = 'CRITICAL';
                    else if(kanban.leankor__Priority__c == 2.0)
                    priorityFlag = 'MEDIUM';
                    else if(kanban.leankor__Priority__c == 3.0)
                    priorityFlag = 'LOW';
                    else
                    priorityFlag = 'NONE';
                
                    kanbanCount += componentCount.get(priorityFlag);
                    componentCount.put(priorityFlag,kanbanCount);
                
            }
            
        /* there is four type on my work when we filer by Priority
        * 1. Critical 
        * 2. Medium
        * 3. Low 
        * 4. None
        *-----------------------------------------------*/      
        for(Integer i = 1; i <= 4 ;i++)
        {       
            Integer cards;
            KanbanCardData DueCard = new KanbanCardData();
                                
            DueCard.Name = (i==1 ? 'MWCritical' : ( i==2 ? 'MWMedium' : (i==3 ? 'MWLow' : 'None')));                    
            //DueCard.Name = (i==1 ? 'CRITICAL/HIGH' : ( i==2 ? 'MEDIUM/NORMAL' : (i==3 ? 'LOW' : 'NONE')));
            DueCard.ChildRecords = new List<leankor.ProjectBoardCarousel.Card>();
            DueCard.Color = (i==1 ? '#fb7874' : ( i==2 ? '#009fdf' : (i==3 ? '#57c868' : '#9fa3a5')));
            DueCard.priorityIndex = i;
            
            if(i==1){
               cards = componentCount.get('HIGH')+ componentCount.get('CRITICAL');
            }else if(i==2){
               cards = componentCount.get('NORMAL')+ componentCount.get('MEDIUM');
            }else if(i==3){
                cards = componentCount.get('LOW');        
            }else{
              cards = componentCount.get('NONE'); 
            }
            
             DueCard.ChildCount = cards;
            
            result.add(DueCard);
                    
        }   
        return result;
    }
    
     //-----------This method return cards and task count according Due Date----------    
    @TestVisible
    private static List<KanbanCardData> getWorkByDueDate(WorkFilter filterData){
        
        List<KanbanCardData> result = new List<KanbanCardData>();
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        List<Task> taskList = new List<Task>();
        /*SS 23.07.2018*/
        //List<String> softDeletedCardList = new List<String>();
        String dynQuerySoftDeletedCards; 
        Map<String,Integer> componentCount = new Map<String,Integer>{'OVERDUE' => 0,
                                                                  'DUE TODAY' => 0,
                                                                  'THIS WEEK' => 0,
                                                                  'NEXT 30 DAYS' =>0,
                                                                  'LATER' => 0};
        //Change limits from 250 to 500
        //Integer recLimit = 250;       
        Integer recLimit = 500;
        Boolean isTask = false;
        //ss 11.05.2018 
        //Date currentDate = Date.today();
        //Date weekStart = currentDate.toStartofWeek();   //Sunday
        //Date weekEnd = weekStart.addDays(6);            //Saturday
        
        Date currentDate = System.today();
        
        //getStartOfTheWeek() method will return startDayOfWeek which is used for calculating last day of week
        Date weekEnd = Util.getStartOfTheWeek(currentDate).addDays(6);              
        Date monthEnd = weekEnd.addDays(30);  

        //ss 11.05.2018      
        //first we are checking myworktaskload is true or not
        if(filterData.isMyWorkTaskLoad)
        {
             //checking task is available or not
              isTask = isKanbanCardHasTasks();
        }
        
        if(isTask){
            //get the soft deleted Kanban Card list
            /*SS 23.07.2018*/
            //softDeletedCardList = getSoftDeletedKanbanCards();
            //taskList = getIncompleteTaskList_1(recLimit,softDeletedCardList, BLANKTEXT);
            
            dynQuerySoftDeletedCards = getSoftDeletedKanbanCards();
            //taskList = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, BLANKTEXT); 
            taskList = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, filterData); 
            
            for(Task t : taskList){
                Integer taskCount = 1;
                    if(t.ActivityDate < currentDate){
                        taskCount += componentCount.get('OVERDUE');
                        componentCount.put('OVERDUE',taskCount);
                    }else if(t.ActivityDate == currentDate){
                        taskCount += componentCount.get('DUE TODAY');
                        componentCount.put('DUE TODAY',taskCount);
                    }else if(t.ActivityDate > currentDate && t.ActivityDate <= weekEnd){
                        taskCount += componentCount.get('THIS WEEK');
                        componentCount.put('THIS WEEK',taskCount);
                }else if(t.ActivityDate > weekEnd && t.ActivityDate <= monthEnd){
                    taskCount += componentCount.get('NEXT 30 DAYS');
                    componentCount.put('NEXT 30 DAYS',taskCount);
                }else if(t.ActivityDate > monthEnd){
                        taskCount += componentCount.get('LATER');
                        componentCount.put('LATER',taskCount);
                    }
            }
        }
        
        //kanbanCardList = getIncompleteKanbanCardList(recLimit, BLANKTEXT,taskList, BLANKTEXT);
        kanbanCardList = getIncompleteKanbanCardList(recLimit, BLANKTEXT,taskList, filterData);
        
        /**Time dayStart = Time.newInstance(0, 0, 0, 0);
        Time dayEnd = Time.newInstance(23, 59, 59, 0);
        DateTime currentDateStart = DateTime.newInstanceGmt(currentDate, dayStart);
        DateTime currentDateEnd = DateTime.newInstanceGmt(currentDate, dayEnd);
        DateTime weekEndDateTime = DateTime.newInstanceGmt(weekEnd, dayEnd);
        DateTime monthEndDateTime = DateTime.newInstanceGmt(monthEnd, dayEnd);*/
        
        /** Date: 01/10/2019 : Covertion of current zone dateTime to GMT datetime  */ 
        DateTime currentDateStart = getStartOfDay(currentDate);
        DateTime currentDateEnd = getEndOfDay(currentDate);
        DateTime weekEndDateTime = getEndofDay(weekEnd);
        DateTime monthEndDateTime = getEndofDay(monthEnd);
        
        for(leankor__KanbanCard__C kanban : kanbanCardList){
        
                Integer kanbanCount = 1;
                if(kanban.leankor__DueDateTime__c < currentDateStart){
                        kanbanCount += componentCount.get('OVERDUE');
                        componentCount.put('OVERDUE',kanbanCount);
                    }else if(kanban.leankor__DueDateTime__c >= currentDateStart && kanban.leankor__DueDateTime__c < currentDateEnd){
                        kanbanCount += componentCount.get('DUE TODAY');
                        componentCount.put('DUE TODAY',kanbanCount);
                    }else if(kanban.leankor__DueDateTime__c > currentDateEnd && kanban.leankor__DueDateTime__c <= weekEndDateTime){
                        kanbanCount += componentCount.get('THIS WEEK');
                        componentCount.put('THIS WEEK',kanbanCount);
            }else if(kanban.leankor__DueDateTime__c > weekEndDateTime && kanban.leankor__DueDateTime__c <= monthEndDateTime){
                kanbanCount += componentCount.get('NEXT 30 DAYS');
                componentCount.put('NEXT 30 DAYS',kanbanCount);
            }else if(kanban.leankor__DueDateTime__c > monthEndDateTime){
                        kanbanCount += componentCount.get('LATER');
                        componentCount.put('LATER',kanbanCount);
                    }
            }
            
        /* there is four type on my work when we filter by DueDate.
        * 1. OVERDUE 
        * 2. DUE TODAY 
        * 3. THIS WEEK 
        * 4. LATER
        *-----------------------------------------------*/      
        for(Integer i = 1; i <= 5;i++){  
                 
            Integer cards;
            //List<SObject> tasks = new List<SObject>();
            
            KanbanCardData DueCard = new KanbanCardData();
            DueCard.Name = (i==1 ? 'MWOverdue' : ( i==2 ? 'MWDueToday' : (i==3 ? 'MWThisWeek' : (i==4 ? 'MWNext30Days' : 'MWLater'))));
            //DueCard.Name = (i==1 ? 'OVERDUE' : ( i==2 ? 'DUE TODAY' : (i==3 ? 'THIS WEEK' : (i==4 ? 'NEXT 30 DAYS' : 'LATER'))));
            DueCard.ChildRecords = new List<leankor.ProjectBoardCarousel.Card>();
            DueCard.Color = (i==1 ? '#ee7575' : ( i==2 ? '#fcc485' : (i==3 ? '#13a3e0' : (i==4? '#00008b' : '#4a4a4a'))));
                                                              
            if(i==1){
                                             
                 cards = componentCount.get('OVERDUE');
                                            
            }else if(i==2){
              
                 cards = componentCount.get('DUE TODAY');                        
            }else if(i==3){
                 
                 cards = componentCount.get('THIS WEEK');
            }else if(i==4){     
                cards = componentCount.get('NEXT 30 DAYS');                
            }else{ 
               
            cards = componentCount.get('LATER');
                 
            }
            
            DueCard.ChildCount = cards;
            
            result.add(DueCard);
                    
        }              
        return result;   
    }
    
    //-----------This method return cards and task count according Type ----------   
    @TestVisible
    private static List<KanbanCardData> getWorkByType(WorkFilter filterData){

        List<KanbanCardData> result = new List<KanbanCardData>();
        List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();
        List<Task> taskList = new List<Task>();
        /*SS 23.07.2018*/
        //List<String> softDeletedCardList = new List<String>();
        String dynQuerySoftDeletedCards;
        
        Map<String,Integer> componentCount = new Map<String,Integer>{ 'MILESTONE' => 0,
                                                                      'ACTIVITY' => 0,
                                                                      'CARD' => 0,
                                                                      'TASK' => 0};
        //Change limits from 250 to 500
        //Integer recLimit = 250;       
        Integer recLimit = 500;
        Boolean isTask = false;
        //first we are checking myworktaskload is true or not
        if(filterData.isMyWorkTaskLoad)
        {
             //checking task is available or not
              isTask = isKanbanCardHasTasks();
        }
        
        if(isTask){
            //get the soft deleted Kanban Card list
            /*SS 23.07.2018*/
            //softDeletedCardList = getSoftDeletedKanbanCards();
            //taskList = getIncompleteTaskList_1(recLimit,softDeletedCardList, BLANKTEXT);
                
            dynQuerySoftDeletedCards = getSoftDeletedKanbanCards();
            //taskList = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, BLANKTEXT); 
            taskList = getIncompleteTaskList_1(recLimit,dynQuerySoftDeletedCards, filterData); 
            
            componentCount.put('TASK',taskList.Size());
            }
        
        //kanbanCardList = getIncompleteKanbanCardList(recLimit, BLANKTEXT,taskList, BLANKTEXT);
        kanbanCardList = getIncompleteKanbanCardList(recLimit, BLANKTEXT,taskList, filterData);
        for(leankor__KanbanCard__C kanban : kanbanCardList){
                Integer kanbanCount = 1;
                String typeFlag = '';
                    
                    //***** SS 22.06.2018 *****//                   
                    /*if(kanban.RecordType.Name == 'MileStoneCard' && kanban.leankor__Boardtype__c == 'UberBoard')
                    typeFlag = 'MILESTONE';*/
                    //Now we have milestone on other board (CV) also
                    if(kanban.RecordType.Name == 'MileStoneCard')
                    typeFlag = 'MILESTONE';
                    //***** SS 22.06.2018 *****//
                    else if(kanban.RecordType.Name == 'ActivityCard'  && kanban.leankor__Boardtype__c == 'UberBoard')
                    typeFlag = 'ACTIVITY';
                    else if(kanban.RecordType.Name == 'ActivityCard'  && kanban.leankor__Boardtype__c != 'UberBoard')
                    typeFlag = 'CARD';
                    
                    kanbanCount += componentCount.get(typeFlag);
                    componentCount.put(typeFlag,kanbanCount);
                
            }
        
        /* there is three type on my work when we filter by type.
        * 1. Milestone
        * 2. Activity 
        * 3. Card 
        * 4. Task 
        *-----------------------------------------------*/      
        for(Integer i = 1; i <= 4 ;i++)
        {       
            Integer cards = 0;
            List<SObject> tasks = new List<SObject>();
            
            KanbanCardData DueCard = new KanbanCardData();
            
            DueCard.Name = (i==1 ? 'Milestone' : ( i==2 ? 'Activity' : (i==3 ? 'Card' : 'Task')));
            DueCard.ChildRecords = new List<leankor.ProjectBoardCarousel.Card>();
            DueCard.Color = (i==1 ? '#ee7575' : ( i==2 ? '#fcc485' : (i==3 ? '#13a3e0' : '#4a4a4a')));
                        
            if(i==1){
                 cards = componentCount.get('MILESTONE');
                 DueCard.Name = 'MILESTONE';
            }else if(i==2){
                cards = componentCount.get('ACTIVITY');                        
                DueCard.Name = 'ACTIVITY';                    
            }else if(i==3){
                cards = componentCount.get('CARD');
                DueCard.Name = 'CARD';
            }else{ 
                cards = componentCount.get('TASK');
                DueCard.Name = 'TASK';
            }
            
            DueCard.ChildCount = cards;
            result.add(DueCard);
        } 
            
        return result;
    } 
    
     //-----------This method return cards and task count according projects----------
    @TestVisible
    private static List<KanbanCardData> getWorkByProject(WorkFilter filterData){
        
        List<KanbanCardData> result = new List<KanbanCardData>();
        //Change limits from 250 to 500
        //Integer recLimit = 250;       
        Integer recLimit = 500;
        /**/
        //passing black list we have logic inside getKanbanCardListbyProject method
        //List<String> softDeletedCardList = new  List<String>();
        //String dynQuerySoftDeletedCards ;
        /**/
        List<SObject> taskList = new  List<SObject>();
        
        if(filterData.isMyWorkTaskLoad && isKanbanCardHasTasks()){
          //getting task         
          String dynQuerySoftDeletedCards = getSoftDeletedKanbanCards();         
          //taskList = getIncompleteTaskList_1(recLimit, dynQuerySoftDeletedCards, BLANKTEXT);
            taskList = getIncompleteTaskList_1(recLimit, dynQuerySoftDeletedCards, filterData);
        }
               
        //getting kanban cards and cards associate with Task
        //List<SObject> cardList = getIncompleteKanbanCardList(recLimit,'WORKBYPROJECT',taskList, BLANKTEXT);
        List<SObject> cardList = getIncompleteKanbanCardList(recLimit,'WORKBYPROJECT',taskList, filterData);
            
        //map project id with List of kanban cards
        Map<Id,List<leankor__KanbanCard__c>> projectMap = new Map<Id,List<leankor__KanbanCard__c>>();
        
        try{       
                   
            //maping list of kanbancards associate with projectId
            for(SObject s : cardList)
            {
                  leankor__KanbanCard__c c = (leankor__KanbanCard__c)s;
                    
                  if(projectMap.containsKey(c.leankor__ValueStream__r.leankor__ProjectRoom__c)){
                        
                        List<leankor__KanbanCard__c> cards = projectMap.get(c.leankor__ValueStream__r.leankor__ProjectRoom__c);
                        cards.add(c);
                        
                        projectMap.put(c.leankor__ValueStream__r.leankor__ProjectRoom__c,cards);
                                                                  
                  }else{
                                        
                        List<leankor__KanbanCard__c> cards = new List<leankor__KanbanCard__c>();
                        cards.add(c); 
                                              
                        projectMap.put(c.leankor__ValueStream__r.leankor__ProjectRoom__c,cards);
                                              
                  }      
            }
        }catch(Exception ex){            
                //return new List<KanbanCardData>(); 
                //25/04/2023 : We are Throwing Exception
                throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());    
        }
        
        try{            
            //differentiate according to project Id.     
            Integer i = 1;
            for(Id projectId : projectMap.keySet()){
              
                KanbanCardData cardCountByProject = new KanbanCardData();
                
                //05.Sep.2017 : checking Null pointer exception
                String roomId = projectMap.get(projectId)[0].leankor__ValueStream__r.leankor__ProjectRoom__c;
                
                cardCountByProject.Id = roomId == null ? '' : roomId ; 
                cardCountByProject.Name = roomId == null ? '': projectMap.get(projectId)[0].leankor__ProjectRoom__c;
                
                cardCountByProject.ChildRecords = new List<leankor.ProjectBoardCarousel.Card>();
                cardCountByProject.Color = (i==1 ? '#D3D3D3' : ( i==2 ? '#A9A9A9' : '#808080'));
                cardCountByProject.ChildCount = projectMap.get(projectId).size();           
                
                result.add(cardCountByProject);
                
                i++;
                //if i greater than 4 so color code will be repeat next four project. 
                if(i > 2){
                    i = 1;          
                }    
                
                }                            
         
        }catch(Exception ex){            
                //return new List<KanbanCardData>();
                //25/04/2023 : We are Throwing Exception
                throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());     
        } 
            
        return result;
    }
    
    /*
    Method : updatekanbanCardDate
    Input : kanbanCard previous schedule Data (Dates and Estimation) and new schedule Data (Dates and Estimation).
    Descrition : update kanban card data in DB and will broadcast on boards
    */
    @RemoteAction
    @AuraEnabled
    global static String updatekanbanCardDates(String previosData , String newData)
    {      
        //18/Jan/2023 : We are setting this variable= true, for setting isConstraintRecalculate= true for the Activty whose dates are changes from MyWork.
        isConstraintRecalculateForActivityFromMyWork = true;
        //RS 13/09/2018 USing GS To fix mywork broadcast issue when updating child broadcast should arive on parent plangantt
        String kanbanIds ;          
        Set < String > boardIds  = new Set < String >();        
        try{
            leankor.RealTimeController.bulkStreaming cardData = (leankor.RealTimeController.bulkStreaming)JSON.deserialize(newData , leankor.RealTimeController.bulkStreaming.class);   
            kanbanIds =  leankor.realtimeController.kanbanStateChange(cardData.VSID, cardData.Verb, cardData.SessionID, cardData.SomeJSONData);    
        }catch(Exception ex){            
                //return 'Failed';
                //25/04/2023 : We are Throwing Exception
                throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());     
        }
        
        //RS 03/11/2018 Mywork issue when all boards are open 
        leankor.RealTimeController.ExternalDependent externalDepen = (leankor.RealTimeController.ExternalDependent)JSON.deserialize(kanbanIds , leankor.RealTimeController.ExternalDependent.class);    
        List<leankor__kanbancard__c > externalValueStreamIds = [select leankor__valuestream__c from leankor__kanbancard__c where Id In : externalDepen.externalCardIDs];
        
        for(leankor__kanbancard__c kc : externalValueStreamIds){
            boardIds.add(kc.leankor__valuestream__c);
        }
        
        externalDepen.externalValuestreamIDs = GanttTaskBoard.getExternallyDependentVSIds(boardIds);    
        
        //RS 13/09/2018 USing GS To fix mywork broadcast issue when updating child broadcast should arive on parent plangantt
        //String kanbanIds = JSON.serialize(leankor.RealTimeController.gskanbanCardIds);        
        leankor.RealTimeController.gskanbanCardIds.clear();
        //return kanbanIds;
        return JSON.Serialize(externalDepen);
    }
    
    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Method validates if card violates any constraints and calls getConstraintViolation method from KanbanController class 
    Inputs:         String previousData, String newData
    Returns:        String 
    ------------------------------------------------------------*/    
    public static String validateKanbanCardDates(String previousData , String newData)
    {          
        KanbanController.KanbanCardConstraintViolation constraintsViolated = new KanbanController.KanbanCardConstraintViolation();
        leankor.RealTimeController.bulkStreaming cardData = (leankor.RealTimeController.bulkStreaming)JSON.deserialize(newData , leankor.RealTimeController.bulkStreaming.class);   
        leankor.RealTimeController.Kanban moreCardData = (leankor.RealTimeController.Kanban)JSON.deserialize(cardData.SomeJSONData, leankor.RealTimeController.Kanban.class);
        leankor.RealTimeController.Kanban prevCardData = (leankor.RealTimeController.Kanban)JSON.deserialize(previousData, leankor.RealTimeController.Kanban.class);
        Boolean checkDepConst = false;
          
        List<leankor__KanbanCard__c> changedDatesCard = new List<leankor__KanbanCard__c>();
        leankor__KanbanCard__c cardUpdated = new leankor__KanbanCard__c();
        Set<Id> cardId = new Set<Id>();
        cardId.add(moreCardData.Id);
        
        List<leankor__KanbanCard__c> cardInfo = leankor.KanbanCard.readKanbanCards(cardId);

        if(moreCardData.StartDate != null) {
            cardInfo[0].leankor__StartDateTime__c = moreCardData.StartDate;
        }
        if(moreCardData.DueDate != null) {
            cardInfo[0].leankor__DueDateTime__c = moreCardData.DueDate;
        } 
        if(moreCardData.EstimatedDuration != null) {
            cardInfo[0].leankor__EstimatedDuration__c = moreCardData.EstimatedDuration;
        }
        
        changedDatesCard.add(cardInfo[0]);  

        constraintsViolated = UpdateKanbanCard.checkConstraintValidation(changedDatesCard, checkDepConst);

        return JSON.Serialize(constraintsViolated);
    }
    
    /*------------------------------------------------------------
        Author:         Yash Jain
        Company:        Leankor
        Description:    Creating and updating lightning dashboard
        Inputs:         Board details in form of object
        Returns:        List<ProjectRoomHierarchy>
        ------------------------------------------------------------*/
    @RemoteAction
    global static List<ProjectRoomHierarchy> createLightningDashBoard(ProjectRoomHierarchy prh) {
        if ((String.isNotBlank(prh.RoomId) && Util.getSObjectName(prh.RoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(prh.Id) && Util.getSObjectName(prh.Id) != 'leankor__valuestream__c')
            || (String.isNotBlank(prh.KanbanCardId) && Util.getSObjectName(prh.KanbanCardId) != 'leankor__KanbanCard__c')) {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
       
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        
        if (!valueStreamBehavior.isUpdateable()){
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<ProjectRoomHierarchy>  getBoardList = new List<ProjectRoomHierarchy>(); 
        //Create a savepoint
        Savepoint sp = Database.setSavepoint();
        try {
            // if id is null or blank than we create new dashboard with url
            if(prh.Id != null && prh.Id != '') {   
                leankor__ValueStream__c projectBoard = new leankor__ValueStream__c();            
                projectBoard.Id = prh.Id;
                projectBoard.Name = prh.Name;
                projectBoard.leankor__UrlLink__c = prh.UrlLink;             
                
                Update projectBoard;    
                              
            } else {   
                getBoardList = createListProjectBoard(prh.Name,prh.RoomId,prh.BoardType,prh.Id,prh.KanbanCardId);
                leankor__ValueStream__c projectBoard = new leankor__ValueStream__c();
                projectBoard.Id = getBoardList[0].Id;
                projectBoard.leankor__UrlLink__c = prh.UrlLink;
                        
                Update projectBoard;
                
                getBoardList[0].UrlLink = prh.UrlLink;
            }
        } catch(Exception ex) {
            //if any exception will occur then all trancsection will be Rollback
            Database.rollback(sp);
            //return new List<ProjectRoomHierarchy>();
            //25/04/2023 : We are Throwing Exception
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
                         
        return getBoardList;    
    }
   
    /*------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    Auraenabled method for getting card data for 
                    mywork date quick action
    Component:      CmpDateEdit 
    Inputs:         String kanbanJSON, String boardVerb
    Returns:        String
    Date:           27/3/2018
    ------------------------------------------------------------*/      
    @AuraEnabled
    global static string getKanbanCard(String kanbanJSON, String boardVerb) {           
        if (String.isNotBlank(kanbanJSON) && String.isNotBlank(boardVerb)) {
            return JSON.serialize(realTimeController.getKanbanCardRecord(kanbanJSON,boardVerb));  
        } else {
            return 'Failed';
        }
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    Auraenabled method for updating card data for 
                    mywork date quick action
    Component:      CmpDateEdit
    Inputs:         String previousData , String newData
    Returns:        -
    Date:           27/3/2018
    ------------------------------------------------------------*/             
    @AuraEnabled
    global static void updateKbCardDates(String previousData , String newData){
        isCalledFromQuickAction = true;
        updatekanbanCardDates(previousData , newData);        
    }

    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Aura enabled method for validating card dates for cmpdateedit aura component
    Inputs:         String previousData, String newData
    Returns:        String 
    ------------------------------------------------------------*/
    @AuraEnabled
    public static String validateKbCardDates(String previousData , String newData){
        return validateKanbanCardDates(previousData , newData);        
    }


    /*------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    Auraenabled method for getting Task data for 
                    mywork date quick action
    Component:      CmpDateEdit
    Inputs:         String recordId
    Returns:        Task
    Date:           27/3/2018
    ------------------------------------------------------------*/     
    @AuraEnabled
    global static Task getTaskData(String recordId){
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!taskBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        if (String.isNotBlank(recordId) && Util.getSObjectName(recordId) != 'Task') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        Task t = [Select Id, 
                        Priority, 
                        OwnerID, 
                        Subject, 
                        Status, 
                        ActivityDate, 
                        WhatID, 
                        Description, 
                        CreatedDate, 
                        Owner.Name 
                    From Task 
                    Where Id =:recordId];
       return t ;          
    }


    //RS 7/5/2018 Inner class for CustomSettings, use this class for getting custom settings fields for lightning component  
    global class CustomSettings {
        @AuraEnabled public Integer firstDayOfWeek ;    
        @AuraEnabled public Boolean disableDateInMyWork ;    
        @AuraEnabled public Boolean isGS ;
        @AuraEnabled public String sessionId ;     
    }
    

    /*------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    Auraenabled method for getting leankor__FirstDayOfTheWeek__c 
                    value from custom settings.
    Component:      CmpDateEdit
    Inputs:         -
    Returns:        CustomSettings
    Date:           7/5/2018
    ------------------------------------------------------------*/ 
    //09/09/2021 : Changes Public method to Global for release update.     
    @AuraEnabled
    global static CustomSettings getCustomSettingValue(){
        CustomSettings cs = new CustomSettings();
        //decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;
        leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
        decimal firstDay =  leanConstant.leankor__FirstDayOfTheWeek__c;     
        cs.firstDayOfWeek =  firstDay == null || firstDay < 0  || firstDay > 6 ? 1 : firstDay.intValue();
        cs.disableDateInMyWork = leanConstant.leankor__DisableDateInMyWork__c;
        //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
        cs.isGS = false;
        cs.sessionId = UserInfo.getSessionId();
        
        return cs;
    }
    
    /*------------------------------------------------------------
    Author:         Suraj Sen 
    Company:        Leankor
    Description:    Check user has access to respective Folder 
    Inputs:         recordIds of Valuestream
    Returns:        Boolean value true if user has access otherwise false
    Date:           03.10.2018
    ------------------------------------------------------------*/      
    @RemoteAction
    global static Boolean isBoardAccessible(List<String> recordIds){
        Boolean flag = false;
        try {
            if (!(recordIds.size()>0)) {
                return flag;
            }
            for (UserRecordAccess recordAccess : [Select RecordId, 
                                                        HasReadAccess 
                                                    From UserRecordAccess 
                                                    Where RecordId In :recordIds 
                                                        And UserId =:UserInfo.getUserId()]){
                flag = recordAccess.HasReadAccess;
            }
        } catch(Exception ex) {
            throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
        }
        return flag;
    }
    
    /*-------------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    Innerclass for checking create access for folder,project,
                    valuestream     
    ------------------------------------------------------------*/
    global class ObjectAccess{      
        public boolean hasCreateAccessForFolder;
        public boolean hasCreateAccessForProject;
        public boolean hasCreateAccessForValuestream;  
        public boolean hasReadAccess;
        public boolean hasEditAccess;
        public boolean hasDeleteAccess;   
        public String recordId; 
    }
    
    /*--------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    checking create access for folder,project,valuestream   
    Inputs:         -
    Returns:        ObjectAccess    
    ------------------------------------------------------------*/
    @remoteaction
    global static ObjectAccess checkBaseSecurity() {
      
        ObjectAccess oa = new ObjectAccess();
        
        try {
            oa.hasCreateAccessForFolder = leankor__Portfolio__c.sObjectType.getDescribe().isCreateable();
            oa.hasCreateAccessForProject = leankor__ProjectRoom__c.sObjectType.getDescribe().isCreateable();
            oa.hasCreateAccessForValuestream = leankor__ValueStream__c.sObjectType.getDescribe().isCreateable();
        } catch (Exception e) {
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }
        return oa;
    }
    
    // Date: 02/05/2019
    @Remoteaction
    global static Map <String, UserRecordAccess> readRecordSecurity(List<String> ids) {
        
        Map <String, UserRecordAccess> recordAccessMap =  new Map <String, UserRecordAccess> ();
        for(UserRecordAccess recordAccessInstance: [SELECT RecordId, HasReadAccess,HasEditAccess,HasDeleteAccess FROM UserRecordAccess WHERE UserId = : userinfo.getuserid() AND RecordId IN: ids]){                                         
            recordAccessMap.put(recordAccessInstance.RecordId, recordAccessInstance);
        }           
        return recordAccessMap;     
    }
    
    /*--------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    checking access for folder,project,valuestream  
    Inputs:         List<String> recordIds
    Returns:        Boolean 
    ------------------------------------------------------------*/
    webservice static Boolean isAccessible(List<String> recordIds){
        return isBoardAccessible(recordIds);
    }
    /*--------------------------------------------------------------    
    Company:        Leankor
    Description:    Check board edit access if board has not edit access method return list of Board data.
    Inputs:         String Projectid,Boolean planBoard,Boolean projectBoard,Boolean whiteBoard,Boolean UberBoard,Boolean DashBoard
    Returns:        List<leankor__ValueStream__c>   
    Date   : 28/05/19
    ------------------------------------------------------------*/
    @RemoteAction
    global Static List<leankor__ValueStream__c> readProjectAccessWithBoards(leankor.CloneProjectAction.CloneProjectRequest cloneProjectRequest) {
       
       if (String.isNotBlank(cloneProjectRequest.sourceProjectId) && Util.getSObjectName(cloneProjectRequest.sourceProjectId) != 'leankor__ProjectRoom__c') {

           throw new ProjectBoardCarouselException('Error: Invalid input');
       }

       List<String> boardTypes = new List<String>();

       List<leankor__ValueStream__c> valueStreamList = new List<leankor__ValueStream__c>();

       Map<Id, UserRecordAccess> checkEditAccess = new Map<Id, UserRecordAccess>();
       
      try{
               if (cloneProjectRequest.rollUp) {
                   boardTypes.add('Plan Board');
               }

               if (cloneProjectRequest.projectBoard) {
                   boardTypes.add('Kanban Board');          
               } 

               if (cloneProjectRequest.whiteBoard) {
                   boardTypes.add('Whiteboard');
               } 

               if (cloneProjectRequest.planGantt) {
                   boardTypes.add('UberBoard');
               } 
               
               if (cloneProjectRequest.dashBoard) {
                   boardTypes.add('Dashboard');
               }
        
               List<leankor__ValueStream__c> valueStreams = RealTimeControllerHelper.readBoards(cloneProjectRequest.sourceProjectId, boardTypes);      

               for (leankor__ValueStream__c valueStream : valueStreams) {
                   checkEditAccess.put(valueStream.Id, valueStream.UserRecordAccess);
               }
               
               for (leankor__ValueStream__c valuestream : valueStreams) {                   
                   leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
                      if (!checkEditAccess.containsKey(valuestream.Id) && !checkEditAccess.get(valuestream.Id).HasEditAccess) {
                          valueStreamRecord.Name = valuestream.Name;
                          valueStreamRecord.Id = valuestream.Id;              
                          valueStreamList.add(valueStreamRecord);

                       }
               }

       } catch (Exception ex) {

         throw new ProjectBoardCarouselException('ERROR:' + ex.getMessage());
      }
  
       return valueStreamList;

    }
      /*
       Company:         Leankor
        Description:    Check boards,projects,folders edit access. return sobject records if edit access false.
        Inputs:         List<String>
        Returns:        List<Sobject>   
        Date : 03/06/19   
     */  
    @RemoteAction
    global static List<SobjectData> readFolderHierarchySecurity(List<String> folderId) {
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        if (!portfolioBehaviour.isAccessible()) {
            throw new ProjectBoardCarouselException('Error: No access to records');
        }
        for (String folder : folderId) {
            if (String.isNotBlank(folder) && Util.getSObjectName(folder) != 'leankor__Portfolio__c') {
                throw new ProjectBoardCarouselException('Error: Invalid input');
            }
        }
    
        List<Sobject> sobjectList = new List<Sobject>();

        List<SobjectData> sobjectList1 = new List<SobjectData>();
        //Date 22/07/19 add record id into set to avoid duplicate id.
        Set<String>  sobjectIds = new Set<String>();
        
        Map<String, UserRecordAccess> checkEditAccess = new Map<String, UserRecordAccess>();
    
        Map<Id, UserRecordAccess> userRecordAccessMap = new Map<Id, UserRecordAccess>();
            
        try {
            
        List<leankor__Portfolio__c> folders = leankor.RealTimeControllerHelper.getAllChildFolders(folderId);  

        List<leankor__Portfolio__c> folderList = [Select 
                                                       Id, 
                                                       UserRecordAccess.HasEditAccess, 
                                                       Name 
                                                   From leankor__Portfolio__c 
                                                   Where Id In :folderId 
                                                   Limit 10000];
        
        for (leankor__Portfolio__c folder : folderList) {
            userRecordAccessMap.put(folder.Id, folder.UserRecordAccess);
        }
        
        folders.addAll(folderList); 
        
        sobjectList.addAll(folders);    
        //get Lis of project from folder.
        List<leankor__ProjectRoom__c> projectList = leankor.RealTimeControllerHelper.getAllProjectOfFolderWithoutSharing(folders);
        
        for (leankor__ProjectRoom__c project : projectList) {
            userRecordAccessMap.put(project.Id, project.UserRecordAccess);
        }
       
        sobjectList.addAll(projectList);
        
        //get List of Boards from projects.
        List<leankor__ValueStream__c> valueStreamList = RealTimeControllerHelper.readBoards(projectList);
        
        for (leankor__ValueStream__c valueStream : valueStreamList) {
            userRecordAccessMap.put(valueStream.Id, valueStream.UserRecordAccess);
        }
        
        sobjectList.addAll(valueStreamList);
        
        for (SObject obj : sobjectList) {
            sobjectIds.add(obj.Id);
        }
    
        for (Id id : sobjectIds) {
            if (userRecordAccessMap.containsKey(id)) {
                checkEditAccess.put(id, userRecordAccessMap.get(id));
            }
        } 
        
        for (Sobject obj : sobjectList) {                   
            SobjectData sobj = new SobjectData();                         
            // Check sobject record access from record IDs
            if (checkEditAccess.containsKey(obj.Id) && !checkEditAccess.get(obj.Id).HasEditAccess) {   
                sobj.Id = obj.Id;               
                sobj.Name = (String)obj.get('Name');                                
                sobj.sobjectType = obj.Id.getSObjectType().getDescribe().getLabel();
                sobjectList1.add(sobj);
            }
        } 
    
        } catch (Exception ex) {
            throw new ProjectBoardCarouselException('ERROR: ' + ex.getMessage());
        }

        return sobjectList1;
    }

    @AuraEnabled
    public static  List<SobjectRecord> facthFolderHierarchySecurity(List<String> folderId) {
        try {
            List<SobjectData> objectData = readFolderHierarchySecurity(folderId);
            List<SobjectRecord> sObjectDataList = new  List<SobjectRecord>();

            for(SobjectData data : objectData) {
                SobjectRecord sObjectData = new SobjectRecord();
                sObjectData.Id = data.Id;
                sObjectData.Name= data.Name;
                sObjectData.sobjectType = data.sobjectType;
                sObjectDataList.add(sObjectData);
            }

        return sObjectDataList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    global class SobjectData {
        public String Id;
        public String Name;
        public String sobjectType;
    }
    
    global class QuickActions{  
        public string name; 
        public string icon;
        public string type;
        public string cmpName;  
    }
    
    /*--------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    getting quick action from object
    Inputs:         string objName
    Returns:        List <QuickActions> 
    ------------------------------------------------------------*/
    @remoteAction
    global static List <QuickActions> readObjQuickActions(string objName) {
        system.debug(objName);
        List <QuickActions> qaList = new List<QuickActions>();
        //map<string,QuickAction.DescribeAvailableQuickActionResult> mapAvailableQuickActionResult = new map<string,QuickAction.DescribeAvailableQuickActionResult>();
        
        List < String > quickActionType = new List < String > {
            'LightningComponent',
            'Flow',
            'VisualforcePage'
        };
     //   try {
            String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
           
            String networkId = Network.getNetworkId();
            if(String.isNotBlank(networkId)){
                baseUrl = leankor.OpenFeedItemRestriction.getNetworkUrl(networkId, 'https://' + DomainCreator.getOrgMyDomainHostname());
                /*for(sObject tempNetwork : Database.query('Select Id, UrlPathPrefix from Network where id = : networkId')){
                    if(tempNetwork.get('UrlPathPrefix')!=null){            
                        baseUrl =URL.getSalesforceBaseUrl().toExternalForm()+'/'+tempNetwork.get('UrlPathPrefix');
                    }
                }*/
            }
                        
            //Map < String, Object > root = (Map < String, Object > )JSON.deserializeUntyped(res.getbody());
            //string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/ui-api/actions/record/' + objName;
            string recordUrl = 'callout:leankor__OrdNameCred/services/data/'+VERSION+'/ui-api/actions/record/' + objName;
            Map < String,Object > root = (Map < String, Object > )JSON.deserializeUntyped(RealTimeControllerHelper.getQuickActions(recordUrl));
            Map < String, Object > myMapObjects = (Map < String, Object > )(root.get('actions'));
            Map < String, Object > myMapObjects1 = (Map < String, Object > )myMapObjects.get(objName);
            
            for (Object obj: ((List < Object > )myMapObjects1.get('actions'))) {            
                if (((Map < String, Object > )obj).get('subtype') != null) {
                    if (quickActionType.contains((string)((Map < String, Object > )obj).get('subtype'))) {                      
                        //Map < String,Object > root1 = (Map < String, Object > )JSON.deserializeUntyped(RealTimeControllerHelper.getQuickActions(URL.getSalesforceBaseUrl().toExternalForm() + (string)((Map < String, Object > )obj).get('actionTarget')));
                        Map < String,Object > root1 = (Map < String, Object > )JSON.deserializeUntyped(RealTimeControllerHelper.getQuickActions('callout:leankor__OrdNameCred'+(string)((Map < String, Object > )obj).get('actionTarget')));

                        if (!root1.isEmpty()) {
                            string subType = (string)((Map < String, Object > )root1).get('type');
                            string lightningCmpName = (string)((Map < String, Object > )root1).get('lightningComponentQualifiedName');
                            string vfName = (string)((Map < String, Object > )root1).get('visualforcePageName');
                            string flowName = (string)((Map < String, Object > )root1).get('flowDevName');
                            QuickActions qa = new QuickActions();
                            qa.name = (string)((Map < String, Object > )root1).get('label');
                            qa.icon = (string)((Map < String, Object > )root1).get('iconUrl');
                            qa.cmpName = subType == 'LightningComponent' ? lightningCmpName : subType == 'VisualforcePage' ? vfName : subType == 'Flow' ? flowName : null;
                            qa.type = subType;
                            qaList.add(qa);
                        }                       
                    }       
                }
            }
        
       /* }catch(Exception e){
            throw new ProjectBoardCarouselException('ERROR:' + e.getMessage());
        }*/
                
        
        return qaList;
    }
    
    @AuraEnabled
    public static List <QuickAction> readObjQuickAction(string objName) {
       List <QuickActions> result = readObjQuickActions(objName);
 
         List <QuickAction> qaList = new List<QuickAction>();
            for(QuickActions qa : result){
               QuickAction action = new QuickAction();
                action.name = qa.name;
                action.icon = qa.icon;
                action.cmpName = qa.cmpName;
                action.type = qa.type;
                qaList.add(action);
            }
        return qaList;
    }
    /*--------------------------------------------------------------
    Author:         Rahul Solanki 
    Company:        Leankor
    Description:    redirect to the given page name 
    Inputs:         string pageName
    Returns:        PageReference   
    ------------------------------------------------------------*/
    @remoteAction
    global static PageReference quickActionRedirect() {     
        String pageType = EncodingUtil.urlEncode(apexpages.currentpage().getparameters().get('type'),'UTF-8'); 
        //Pratiksha : 27/Jan/2024 : Issue fixes for Saving record from Quick action target url providing different url from VF page.
        if(pageType =='LightningComponent' || pageType == 'Flow'){
            if (String.isNotBlank(Network.getNetworkId())) {
                leankorBaseURL = 'https://' + DomainCreator.getExperienceCloudSitesHostname();
            } else {
                leankorBaseURL = 'https://' + DomainCreator.getVisualforceHostname('leankor');
            }
        } else {
            leankorBaseURL = 'https://' + DomainCreator.getOrgMyDomainHostname();
        }

        if(pageType =='VisualforcePage') {
            String pageName = EncodingUtil.urlEncode(apexpages.currentpage().getparameters().get('cmpName'),'UTF-8');
            String pageRecordId = EncodingUtil.urlEncode(apexpages.currentpage().getparameters().get('rid'),'UTF-8');
            String pageParam = String.isBlank(pageRecordId) ? '' : '?id=' + pageRecordId;           
            String baseUrl = '';
            String networkId = Network.getNetworkId();
            //Community user does not access over getOrgDomainUrl its related components         
            //PageReference pageRef = new PageReference(URL.getOrgDomainUrl().toExternalForm() + '/apex/' + pageName + pageParam);
            if(String.isNotBlank(networkId)){
                baseUrl = leankor.OpenFeedItemRestriction.getNetworkUrl(networkId,'https://' + DomainCreator.getExperienceCloudSitesHostname()
                )+'/';
            }
            else {
                baseUrl = RealTimeController.getOrgBaseURL();
            }   
            PageReference pageRef = new PageReference(baseUrl + pageName + pageParam);
            return pageRef;
        } else {
            return null;
        }
    }       
            
            
   //Date :14/11/19 
    global class CalculateDates{
        
        @AuraEnabled
        public DateTime startDateTime;
        @AuraEnabled
        public DateTime dueDateTime;
        @AuraEnabled
        public Integer estimateDuration;
            
    }
    
     //Date :14/11/19  To calculate StartDate and DueDate . call from  cmpDateEdit Aura Component.
    @AuraEnabled(cacheable=true)
    global static CalculateDates quickActionDateEdit(DateTime startdate, DateTime duedate, Integer estimateDuration,String durationUnit, String valuestreamid){
        if (String.isNotBlank(valuestreamid) && Util.getSObjectName(valuestreamid) != 'leankor__ValueStream__c') {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        
        // Inner class Instance to return the values. 
        CalculateDates dates=new CalculateDates(); 
        // To get the blackout records
        Map <String,List<ProjectScheduleBlackout__c>> mapOfprojectScheduleBlackout = new Map<String,List<ProjectScheduleBlackout__c>>(); 
        //get vs record.
        leankor__valuestream__c valuestream = [Select Id,
                                                    leankor__SevenDayWorkWeek__c 
                                                From leankor__valuestream__c 
                                                Where Id =:valuestreamid 
                                                With Security_Enforced
                                                Limit 1];
        //check borad Seven Day WorkWeek.
        Boolean isSevenDay = valuestream.leankor__SevenDayWorkWeek__c;
        Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;          
        integer firstDayOfWeek= firstDay==null || firstDay<0  || firstDay > 6?1:firstDay.intValue();
        
        List<String> vsIds=new List<String>(); 
        vsIds.add(valuestream.Id);
        //
        leankor.ProjectScheduleBlackout.Blackouts blackouts =new leankor.ProjectScheduleBlackout.Blackouts();       
        blackouts.boardIds = vsIds;       
        //To get ProjectScheduleBlackout records.
        mapOfprojectScheduleBlackout = leankor.ProjectScheduleBlackout.readProjectScheduleBlackouts(blackouts);         
        
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, isSevenDay ? 7: 5, mapOfprojectScheduleBlackout.get(valuestream.Id));
        
        if(startdate!=null){
                dates.startDateTime = workweek.getNextWorkingDay(startdate); 
        } 
        if(duedate!=null){
            dates.dueDateTime = workweek.getNextWorkingDay(duedate);
        }                   
        if(estimateDuration != null){
            //calculate Due Date from Start Date and ED.
            DateTime tempcalduedate = dates.startDateTime;
            Integer ED = estimateDuration;
        
            Switch on durationUnit {        
                when 'Hours'{               
                    if(math.mod(estimateDuration,8) > 0){
                        
                        ED= Integer.valueof(estimateDuration/8) + 1;
                    }else{
                        
                        ED= Integer.valueof(estimateDuration/8);
                    }
                }
                when 'Years'{
                    ED= Integer.valueof(estimateDuration*365);
                }
                when 'Months'{
                    ED= Integer.valueof(estimateDuration*30);
                }
                when 'Minutes'{
                    integer temphours;
                    if(math.mod(estimateDuration,60) >0 ){
                        temphours= Integer.valueof(estimateDuration/60) + 1;
                    }else{
                        temphours= Integer.valueof(estimateDuration/60);
                    }
                    if(math.mod(temphours,8) >0){
                        ED= Integer.valueof(temphours/8) + 1;
                    }else{
                        ED= Integer.valueof(temphours/8);
                    }
                }
                when 'Weeks'{               
                    ED= Integer.valueof(isSevenDay ? estimateDuration*7: estimateDuration*5);
                    
                }
            }
              
            if(durationUnit == 'Years'){
                tempcalduedate = tempcalduedate.addYears(integer.valueof(estimateDuration));
                tempcalduedate = tempcalduedate -1 ;
            }else if(durationUnit == 'Months'){
                tempcalduedate = tempcalduedate.addMonths(integer.valueof(estimateDuration));
                tempcalduedate = tempcalduedate -1 ;
            }else if(durationUnit != 'Months' && durationUnit!= 'Years' ){
                tempcalduedate = workWeek.nextBusinessDate(tempcalduedate, ED-1);
            }
            
            tempcalduedate =    workweek.getNextWorkingDay(tempcalduedate);         
            dates.dueDateTime= tempcalduedate;
           
            
        }else{
            //calculate EstimateDuration bw start date and due Date.
            Integer dateDifference = workWeek.getBusinessDays(dates.startDateTime.date(), dates.dueDateTime.date())+1;            
            Switch on durationUnit {        
                when 'Hours'{               
                    
                    dateDifference = dateDifference*8;
                }
                when 'Years'{
                    
                    dateDifference = Integer.valueof( dates.startDateTime.dateGmt().daysbetween(dates.dueDateTime.dateGmt()) / 365);
                }
                when 'Months'{                   
                    dateDifference = Integer.valueof( dates.startDateTime.dateGmt().daysbetween(dates.dueDateTime.dateGmt())/30);                   
                    /*if(math.mod(dateDifference,30) >0 ){
                        dateDifference= Integer.valueof(dateDifference/30) + 1;
                    }else{
                        dateDifference= Integer.valueof(dateDifference/30);
                    }*/
                }
                when 'Minutes'{
                    
                    dateDifference = dateDifference*8*60;
                }
                when 'Weeks'{       
                    if(dateDifference<(isSevenDay ? 7: 5)){
                        dateDifference=(isSevenDay ? 7: 5); 
                        dates.dueDateTime = workweek.getNextWorkingDay(startdate+(isSevenDay ? 7: 5));              
                    }               
                    dateDifference = Integer.valueof(dateDifference /(isSevenDay ? 7: 5));                  
                }
                
            }
            
            dates.estimateDuration = dateDifference;
        }
        return dates;
            
    }

    @AuraEnabled(cacheable=true)
    global static CalculateDates quickActionDateEditWithWeekCalendar(DateTime startdate, DateTime duedate, Integer estimateDuration,String durationUnit, String valuestreamid, String cardId){
        if ((String.isNotBlank(valuestreamid) && Util.getSObjectName(valuestreamid) != 'leankor__ValueStream__c') || 
            (String.isNotBlank(cardId) && Util.getSObjectName(cardId) != 'leankor__KanbanCard__c')) {
            throw new ProjectBoardCarouselException('Error: Invalid input');
        }
        // Inner class Instance to return the values. 
        CalculateDates dates=new CalculateDates(); 
        // To get the blackout records
        Map <String,List<ProjectScheduleBlackout__c>> mapOfprojectScheduleBlackout = new Map<String,List<ProjectScheduleBlackout__c>>(); 
        //get vs record.
        leankor__valuestream__c valuestream = [Select Id,
                                                    leankor__SevenDayWorkWeek__c 
                                                From leankor__valuestream__c 
                                                Where Id =:valuestreamid 
                                                With Security_Enforced
                                                Limit 1];

        leankor__KanbanCard__c cardData = [Select Id,
                                                leankor__Monday__c,
                                                leankor__Tuesday__c,
                                                leankor__Wednesday__c,
                                                leankor__Thursday__c,
                                                leankor__Friday__c,
                                                leankor__Saturday__c,
                                                leankor__Sunday__c,
                                                leankor__WeekCalendar__c
                                            From leankor__KanbanCard__c
                                            Where Id =: cardId
                                            With Security_Enforced
                                            Limit 1];

        Set<String> weekDays = new Set<String>();
        //if(isConstraintRecalculateForActivityFromMyWork == true && valuestream.leankor__SevenDayWorkWeek__c){
        if(valuestream.leankor__SevenDayWorkWeek__c){
            weekDays.add(cardData.leankor__Monday__c == false ? 'Mon' : 'false');
            weekDays.add(cardData.leankor__Tuesday__c == false ? 'Tue' : 'false');
            weekDays.add(cardData.leankor__Wednesday__c == false ? 'Wed' : 'false');
            weekDays.add(cardData.leankor__Thursday__c == false ? 'Thu' : 'false');
            weekDays.add(cardData.leankor__Friday__c == false ? 'Fri' : 'false');
            weekDays.add(cardData.leankor__Saturday__c == false ? 'Sat' : 'false');
            weekDays.add(cardData.leankor__Sunday__c == false ? 'Sun' : 'false');
        }
        Util.weekDays = weekDays;
        
        //check borad Seven Day WorkWeek.
        Boolean isSevenDay = valuestream.leankor__SevenDayWorkWeek__c;
        Decimal firstDay =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c;          
        integer firstDayOfWeek= firstDay==null || firstDay<0  || firstDay > 6?1:firstDay.intValue();
        
        List<String> vsIds=new List<String>(); 
        vsIds.add(valuestream.Id);
        //
        leankor.ProjectScheduleBlackout.Blackouts blackouts =new leankor.ProjectScheduleBlackout.Blackouts();       
        blackouts.boardIds = vsIds;       
        //To get ProjectScheduleBlackout records.
        mapOfprojectScheduleBlackout = leankor.ProjectScheduleBlackout.readProjectScheduleBlackouts(blackouts);         
        
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, isSevenDay ? 7: 5, mapOfprojectScheduleBlackout.get(valuestream.Id));
        
        if(startdate!=null){
                dates.startDateTime = workweek.getNextWorkingDay(startdate); 
        } 
        if(duedate!=null){
            dates.dueDateTime = workweek.getNextWorkingDay(duedate);
        }                   
        if(estimateDuration != null){
            //calculate Due Date from Start Date and ED.
            DateTime tempcalduedate = dates.startDateTime;
            Integer ED = estimateDuration;
        
            Switch on durationUnit {        
                when 'Hours'{               
                    if(math.mod(estimateDuration,8) > 0){
                        
                        ED= Integer.valueof(estimateDuration/8) + 1;
                    }else{
                        
                        ED= Integer.valueof(estimateDuration/8);
                    }
                }
                when 'Years'{
                    ED= Integer.valueof(estimateDuration*365);
                }
                when 'Months'{
                    ED= Integer.valueof(estimateDuration*30);
                }
                when 'Minutes'{
                    integer temphours;
                    if(math.mod(estimateDuration,60) >0 ){
                        temphours= Integer.valueof(estimateDuration/60) + 1;
                    }else{
                        temphours= Integer.valueof(estimateDuration/60);
                    }
                    if(math.mod(temphours,8) >0){
                        ED= Integer.valueof(temphours/8) + 1;
                    }else{
                        ED= Integer.valueof(temphours/8);
                    }
                }
                when 'Weeks'{               
                    ED= Integer.valueof(isSevenDay ? estimateDuration*7: estimateDuration*5);
                    
                }
            }
              
            if(durationUnit == 'Years'){
                tempcalduedate = tempcalduedate.addYears(integer.valueof(estimateDuration));
                tempcalduedate = tempcalduedate -1 ;
            }else if(durationUnit == 'Months'){
                tempcalduedate = tempcalduedate.addMonths(integer.valueof(estimateDuration));
                tempcalduedate = tempcalduedate -1 ;
            }else if(durationUnit != 'Months' && durationUnit!= 'Years' ){
                tempcalduedate = workWeek.nextBusinessDate(tempcalduedate, ED-1);
            }
            
            tempcalduedate =    workweek.getNextWorkingDay(tempcalduedate);         
            dates.dueDateTime= tempcalduedate;
           
            
        }else{
            //calculate EstimateDuration bw start date and due Date.
            Integer dateDifference = workWeek.getBusinessDays(dates.startDateTime.date(), dates.dueDateTime.date())+1;  
                 
            Switch on durationUnit {        
                when 'Hours'{               
                    
                    dateDifference = dateDifference*8;
                }
                when 'Years'{
                    
                    dateDifference = Integer.valueof( dates.startDateTime.dateGmt().daysbetween(dates.dueDateTime.dateGmt()) / 365);
                }
                when 'Months'{                   
                    dateDifference = Integer.valueof( dates.startDateTime.dateGmt().daysbetween(dates.dueDateTime.dateGmt())/30);                   
                }
                when 'Minutes'{
                    
                    dateDifference = dateDifference*8*60;
                }
                when 'Weeks'{       
                    if(dateDifference<(isSevenDay ? 7: 5)){
                        dateDifference=(isSevenDay ? 7: 5); 
                        dates.dueDateTime = workweek.getNextWorkingDay(startdate+(isSevenDay ? 7: 5));              
                    }               
                    dateDifference = Integer.valueof(dateDifference /(isSevenDay ? 7: 5));                  
                }
                
            }
            
            if (valuestream.leankor__SevenDayWorkWeek__c && Util.weekDays.size() > 1) {
                Integer index = 0;
                Integer count = 0;
                DateTime tempStartDate = dates.startDateTime;
                while (index < dateDifference) {
                    if (!(Util.weekDays.contains((tempStartDate).format('E')))) {
                        count++;
                    }
                    index++;
                    tempStartDate = tempStartDate.addDays(1);
                }
                dateDifference = count;
            }
            dates.estimateDuration = dateDifference;
        }
        return dates;
            
    }

    //---------- Some utility method's to get start/end dateTime of the day. -----------
    public static String getStartOfDayTime(Datetime currentDateTime){

        Datetime startDateTime = DateTime.newInstance(currentDateTime.dateGmt(), currentDateTime.timeGmt());
        return String.valueOf(startDateTime.formatGmt('yyyy-MM-dd') +'T'+startDateTime.timeGmt());
    }

    public static String getEndOfDayTime(Datetime currentDateTime){

        Time myTime = Time.newInstance(23, 59, 59, 0);
        Datetime endDateTime = Datetime.newInstance(currentDateTime.dateGmt(), myTime );
        return String.valueOf(endDateTime.formatGmt('yyyy-MM-dd') +'T'+endDateTime.timeGmt());
    }

    public static Datetime getStartOfDay(Datetime currentDateTime){

        return DateTime.newInstance(currentDateTime.dateGmt(), currentDateTime.timeGmt());
    }

    public static Datetime getEndOfDay(Datetime currentDateTime){

        Time myTime = Time.newInstance(23, 59, 59, 0);
        return Datetime.newInstance(currentDateTime.dateGmt(), myTime );
    }
    //------------------------------------------------------------------
    
    // 29/09/2020 - This method used for get custom labels translation values lightning component.
    //09/09/2021 : Changes Public method to Global for release update. 
    @AuraEnabled(cacheable=true)
    global static Map<String, String> getLabelsForConsumers(String componentName) {
        Set<String> consumers = new Set<String>{'LeankorBase', 'LeankorCalendar', componentName};
        
        return leankor.LabelProvider.getLabelsForConsumers(consumers);
    }
 
    //09/09/2021 : Changes Public method to Global for release update. 
    @AuraEnabled(cacheable=true)
    global static Boolean checkTranslationLanguageActive() {
        return leankor__LeanConstants__c.getInstance().leankor__UseCustomLabels__c;
    }

    global class ProjectBoardCarouselException extends Exception{}
}