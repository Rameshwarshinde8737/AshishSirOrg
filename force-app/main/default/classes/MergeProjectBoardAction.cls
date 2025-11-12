/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  MergeProjectBoardAction.cls
* CLASS: MergeProjectBoardAction
* USAGE: MergeProjectBoardAction .
*/
global with sharing class MergeProjectBoardAction {

	// rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
	//public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c'};
	// rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type

    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    global class MergeProjectBoardRequest {
        @InvocableVariable(label = 'Source Board Name' description = 'String name of the Board which to be merge.' required=true)
            global String SourceBoardName;
        @InvocableVariable(label='Source Folder Name' description='Name of the Folder where its Room would located.')
            global String SourceFolderName;
        @InvocableVariable(label = 'Source Room Name' description = 'String name of the room where Board is located.' required=true)
            global String SourceRoomName;   
        @InvocableVariable(label = 'Source Board Id' description = 'ID of the Project Board which to be merge.')
            global String SourceBoardId;
        @InvocableVariable(label = 'Target Board Name' description = 'String name of the Board where to be merge.' required=true)
            global String TargetBoardName;
        @InvocableVariable(label='Target Folder Name' description='Name of the Folder where its Room would located.')
            global String TargetFolderName;
        @InvocableVariable(label = 'Target Room Name' description = 'String  name of the room where merge Board is located.' required=true)
            global String TargetRoomName;   
        @InvocableVariable(label = 'Target Board Id' description = 'ID of the Project Board where to be merge.')
            global String TargetBoardId;
        @InvocableVariable(label='Due Date' description='Provide the final Due Date for the Card farthest in the future.')
            global DateTime TargetDate;
        @InvocableVariable(label='Link Folder Name' description='Name of the Linked Folder where Linked Room would located.')
            global String LinkFolderName; 
        @InvocableVariable(label='Link Room Name' description='Name of the Link Project Room where Linked Board is located.')
            global String LinkRoomName;
        @InvocableVariable(label='Link Board Name' description='Name of the Link Board to Linked with merge Cards.')
            global String LinkBoardName;
        @InvocableVariable(label='Link Board Id' description='ID of the Link Board to Linked with merge Cards.')
            global String LinkBoardId;        
        @InvocableVariable(label='Link Kanban Card Name' description='Name of Link Kanban Card Which to linked with merge Cards .')
            global String LinkKanbanCardName;
        @InvocableVariable(label='Link Kanban Card ID' description='Name of Link Kanban Card Which to linked with merge Cards .')
            global String LinkKanbanCardId;
        @InvocableVariable(label = 'Is Master Container' required=true description = 'Verb, which check merge Board with MC  .')
            global Boolean WithMC;
        @InvocableVariable(label='Start Date' description='Provide the initial Start Date for the Card farthest in the future.')
            global DateTime initialDate;
     }
    //
    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    //
    global class MergeProjectBoardResult { 
        @InvocableVariable(label = 'Kanban Card Id' description = 'Id of new merge Kanban Card')
            global Id KanbanCardId;
         @InvocableVariable(label = 'Kanban Card Id List' description = 'Id of new merge Kanban Card List')
            global List<Id> KanbanCardIds = new List<Id>();
    }
    //
    // This is execute method for API calls
    //
    
    @InvocableMethod 
    global static List<MergeProjectBoardResult> MergeProjectBoard(List<MergeProjectBoardRequest> requests) {
        for (MergeProjectBoardRequest request : requests) {
            if (String.isNotBlank(request.SourceBoardId) && Util.getSObjectName(request.SourceBoardId) != 'leankor__ValueStream__c') {
				throw new Util.LeanException('Error: Invalid input');
			}
        }
        List<MergeProjectBoardResult> results = new List<MergeProjectBoardResult>();
       
        Integer TempCount = 1;
        for (MergeProjectBoardRequest request : requests) {
            try { 
                List<leankor__KanbanCard__c> MData = MergeProjectBoardProcess(request);
                MergeProjectBoardResult remoteResult = new MergeProjectBoardResult() ;
                   
                for (leankor__KanbanCard__c KanbanCard : MData) {   
                   remoteResult.KanbanCardIds.add(KanbanCard.Id);               
                }      
                results.add(remoteResult);
            } catch (Exception ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }
        return results;
    }
    public static List<leankor__KanbanCard__c> MergeProjectBoardProcess(MergeProjectBoardRequest request) { 
        MasterContainerBehaviour checkMasterContainerBehaviour = new MasterContainerBehaviour();
        SwimlaneBehavior checkSwimlaneBehavior = new SwimlaneBehavior();
        ZoneBehavior checkZoneBehavior = new ZoneBehavior();
        KanbanCardTemplateBehaviour checkKanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        KanbanCardBehaviour checkKanbanCardBehaviour = new KanbanCardBehaviour();
        TaskBehaviour checkTaskBehaviour = new TaskBehaviour();
        FeedItemBehaviour checkFeedItemBehaviour = new FeedItemBehaviour();
        StickerBehavior checkStickerBehavior = new StickerBehavior();
        KanbanCardStickerBehaviour checkKanbanCardStickerBehaviour = new KanbanCardStickerBehaviour();
        AttachmentBehaviour checkAttachmentBehaviour = new AttachmentBehaviour();
        IssueLogBehaviour checkIssueLogBehaviour = new IssueLogBehaviour();
        TimeCardBehavior checkTimeCardBehavior = new TimeCardBehavior();
        OpportunityBehaviour opportunityBehaviour = new OpportunityBehaviour();
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();

        if (!checkKanbanCardTemplateBehaviour.isCreateable() ||
            !checkKanbanCardTemplateBehaviour.isUpdateable() ||
            !checkSwimlaneBehavior.isCreateable() ||
            !checkSwimlaneBehavior.isUpdateable() ||
            !checkZoneBehavior.isCreateable() ||
            !checkZoneBehavior.isUpdateable() ||
            !checkMasterContainerBehaviour.isCreateable() ||
            !checkMasterContainerBehaviour.isUpdateable() ||
            !checkKanbanCardBehaviour.isCreateable() ||
            !checkKanbanCardBehaviour.isUpdateable() ||
            !checkTaskBehaviour.isCreateable() ||
            !checkTaskBehaviour.isUpdateable() ||
            !checkFeedItemBehaviour.isCreateable() ||
            !checkFeedItemBehaviour.isUpdateable() ||
            !checkStickerBehavior.isCreateable() ||
            !checkStickerBehavior.isUpdateable() ||
            !checkKanbanCardStickerBehaviour.isCreateable() ||
            !checkKanbanCardStickerBehaviour.isUpdateable() ||
            !checkAttachmentBehaviour.isCreateable() ||
            !checkAttachmentBehaviour.isUpdateable() ||
            !checkIssueLogBehaviour.isCreateable() ||
            !checkIssueLogBehaviour.isUpdateable() ||
            !checkTimeCardBehavior.isCreateable() ||
            !checkTimeCardBehavior.isUpdateable() ||
            !OpportunityBehaviour.isCreateable() ||
            !OpportunityBehaviour.isUpdateable() ||
            !dependencyBehaviour.isCreateable()) {
			throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior
        
        List<leankor__KanbanCard__c> MergeKanbanCards = new List<leankor__KanbanCard__c>();  
        leankor__ValueStream__c SourceBoard = new leankor__ValueStream__c();
        leankor__ValueStream__c TargetBoard = new leankor__ValueStream__c();
        leankor__ValueStream__c linkBoard = new leankor__ValueStream__c();
        leankor__ProjectRoom__c linkRoom = new leankor__ProjectRoom__c();
        leankor__KanbanCard__c linkCard = new leankor__Kanbancard__c();
        try {                
            if (request.SourceBoardId == null || request.SourceBoardId == '') {
                if (request.SourceBoardName != '' && request.SourceBoardName != Null && request.SourceRoomName != '' && request.SourceRoomName != Null) {
                    leankor__ProjectRoom__c sourceRoom = null;
                    if (request.sourcefolderName != null && request.sourcefolderName != '' ){
                    	sourceRoom = [Select Id,
                                            Name 
                                        From leankor__ProjectRoom__c 
                                        Where Name = :request.SourceRoomName 
                                            And leankor__portfolio__r.name = :request.sourcefolderName 
                                        With Security_Enforced
                                        Limit 1 ];
                    } else {
                    	sourceRoom = [Select Id,
                                            Name 
                                        From leankor__ProjectRoom__c 
                                        Where Name = :request.SourceRoomName 
                                        With Security_Enforced
                                        Limit 1 ];
                    }  
                    SourceBoard = [Select Id,
                                        Name,
                                        (Select Id,
                                                Name 
                                            From leankor__ValueStream__c.leankor__Kanbans__r),
                                        leankor__BoardType__c,leankor__ValueStreamLink__c,
                                        leankor__ValueStreamCardLink__c 
                                    From leankor__ValueStream__c 
                                    Where Name = :request.SourceBoardName 
                                        And leankor__ProjectRoom__c =:sourceRoom.Id 
                                    With Security_Enforced
                                    Limit 1];
                }
            }
            if (request.TargetBoardId == null || request.TargetBoardId == '') {
                if (request.TargetBoardName != '' && request.TargetBoardName != Null && request.TargetRoomName != '' && request.TargetRoomName != Null){
                    leankor__ProjectRoom__c targetRoom = new leankor__ProjectRoom__c();
                    if (request.TargetfolderName != null && request.TargetfolderName != '' ) {
                    	targetRoom = [Select Id,
                                            Name 
                                        From leankor__ProjectRoom__c 
                                        Where Name = :request.TargetRoomName 
                                            And leankor__portfolio__r.name = :request.TargetfolderName 
                                        With Security_Enforced
                                        Limit 1 ];
                    } else {
                    	targetRoom = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.TargetRoomName 
                                            With Security_Enforced
                                            Limit 1 ];
                    }   
                    TargetBoard = [Select Id,
                                        Name,
                                        (Select Id,
                                                Name 
                                            From leankor__ValueStream__c.leankor__Kanbans__r),
                                        leankor__BoardType__c,
                                        leankor__ValueStreamLink__c,
                                        leankor__ValueStreamCardLink__c 
                                    From leankor__ValueStream__c 
                                    Where Name = :request.TargetBoardName 
                                        And leankor__ProjectRoom__c =:targetRoom.Id 
                                    With Security_Enforced
                                    Limit 1];     
                }
            }
            if (request.LinkKanbanCardId == null || request.LinkKanbanCardId == '') {
                if (request.LinkKanbanCardName != '' && request.LinkKanbanCardName != null) {
                    if (request.LinkBoardId == null || request.LinkBoardId == ''){
                        if (request.LinkBoardName != '' && request.LinkBoardName != Null && request.LinkRoomName != '' && request.LinkRoomName != null){
                        	if (request.LinkfolderName != null && request.LinkfolderName != '') {
                        		linkCard = [Select Id, 
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c 
                                                From leankor__Kanbancard__c 
                                                Where Name = :request.LinkKanbanCardName 
                                                    And leankor__ValueStream__r.Name =:request.LinkBoardName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name =:request.LinkRoomName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name = :request.LinkfolderName 
                                                With Security_Enforced
                                                Limit 1];
                        	} else {
                            	linkCard = [Select Id,
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c 
                                                From leankor__Kanbancard__c 
                                                Where Name = :request.LinkKanbanCardName 
                                                    And leankor__ValueStream__r.Name =:request.LinkBoardName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name=:request.LinkRoomName 
                                                With Security_Enforced
                                                Limit 1];
                        	}
                        }
                    } else {
                        linkCard = [Select Id,
                                            Name,
                                            leankor__ValueStream__c,
                                            leankor__ValueStream__r.leankor__ProjectRoom__c  
                                        From leankor__Kanbancard__c 
                                        Where Name = :request.LinkKanbanCardName 
                                            And leankor__ValueStream__c =:request.LinkBoardId 
                                        With Security_Enforced
                                        Limit 1];
                    }
                }   
            } else {
                if (request.LinkBoardId == null || request.LinkBoardId == '') {
                    linkCard = [Select Id,
                                        Name,
                                        leankor__ValueStream__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__c 
                                    From leankor__Kanbancard__c  
                                    Where Id = :request.LinkKanbanCardId 
                                    With Security_Enforced
                                    Limit 1];
                } else {
                    linkCard = [Select Id,
                                        Name,
                                        leankor__ValueStream__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__c 
                                    From leankor__Kanbancard__c 
                                    Where Id = :request.LinkKanbanCardId 
                                        And leankor__ValueStream__c =:request.LinkBoardId 
                                    With Security_Enforced    
                                    Limit 1];     
                }
            }
            if (linkCard.ID == null) {
                if (request.LinkBoardId == null || request.LinkBoardId == '') {
                    if (request.LinkBoardName != '' && request.LinkBoardName != null && request.LinkRoomName != '' && request.LinkRoomName != null) {
                        if (request.LinkfolderName != null && request.LinkfolderName != '') {
                        	linkRoom = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.LinkRoomName 
                                                And leankor__portfolio__r.Name = :request.LinkfolderName 
                                            With Security_Enforced
                                            Limit 1 ];
                        } else {
                        	linkRoom = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.LinkRoomName
                                            With Security_Enforced
                                            Limit 1 ];
                        }   
                        linkBoard = [Select Id,
                                            Name 
                                        From leankor__ValueStream__c 
                                        Where Name =:request.LinkBoardName 
                                            And leankor__ProjectRoom__c =:linkRoom.Id 
                                        With Security_Enforced
                                        Limit 1];         
                    }
                } else {
                    linkBoard = [Select Id,
                                        Name,
                                        leankor__ProjectRoom__c 
                                    From leankor__ValueStream__c 
                                    Where Id = :request.LinkBoardId  
                                    With Security_Enforced
                                    Limit 1]; 
                    linkRoom = [Select Id,
                                        Name 
                                    From leankor__ProjectRoom__c 
                                    Where Id = :linkBoard.leankor__ProjectRoom__c 
                                    With Security_Enforced
                                    Limit 1 ];
                }
            } else {
                linkBoard.Id = linkCard.leankor__ValueStream__c;
                linkRoom.Id = linkCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
            }
        } catch (Exception e){
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        //===============cBoard Object ========================================
        String vsId = (request.TargetBoardId == null ? TargetBoard.Id : request.TargetBoardId);
        String realVsId = (request.SourceBoardId == null ? SourceBoard.Id : request.SourceBoardId);        
        String linkCloneRoomID = (linkRoom.Id == null ? '' : linkRoom.Id);
        String linkCloneVSID = (linkBoard.Id == null ? '' : linkBoard.Id);
        String linkCloneKanbanCardId = (linkCard.Id == null ? '' : linkCard.Id);   
        //===============================Find left Most Zone=============================
        leankor__ValueStream__c Boardtype = [Select Id,
                                                    leankor__ValueStreamCardLink__c,
                                                    leankor__ValueStreamLink__c,
                                                    leankor__SevenDayWorkWeek__c,
                                                    (Select Id 
                                                        From leankor__Kanban_Cards__r),
                                                    leankor__BoardType__c,
                                                    Owner.Name,
                                                    Name 
                                                From leankor__ValueStream__c 
                                                Where Id =:vsId 
                                                With Security_Enforced
                                                Limit 1]; 
        Boolean targetBoardiIsWeekendBoard = Boardtype.leankor__SevenDayWorkWeek__c;
        String boardTypeTemp = Boardtype.leankor__BoardType__c;
        String valueStreamOwner = Boardtype.Owner.name;
        integer newkcorder = Boardtype.leankor__kanban_cards__r.size()+10;
        String leftMasterContainer = '';
        String leftMostSwimlane = '';
        String leftMostZone = '';
        String leftMostZoneId = '';
        Map<String,String> materContainerIds = new  Map<String,String>();
        Map<String,String> swimlanesTemp = new  Map<String,String>();   
        Map<String,String> zoneIds = new  Map<String,String>(); 
        Map<String,String> zoneguIds = new  Map<String,String>();                   
        //Added variable for getting first day of week from custom setting 	
	    Integer firstDayOfWeek = leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c == null ? 1 : leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c.intValue();   
   		firstDayOfWeek= firstDayOfWeek == null || firstDayOfWeek<0  || firstDayOfWeek > 6 ? 1 : firstDayOfWeek;
	    //Create instance of WorkWeek which provides Working week days information
	    Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek, 5);
	    if (boardTypeTemp == 'Kanban Board') {
            // Start MC clone
            List<leankor__MasterContainer__C> mContainers = MultipleMergeProjectBoardAction.getMasterContainerData(new Set<String>{vsId});
            if (request.WithMC) {
                List<leankor__MasterContainer__c> oldMContainers = MultipleMergeProjectBoardAction.getMasterContainerData(new Set<String>{realVsId});
                List<leankor__MasterContainer__c> masterContainers=new List<leankor__MasterContainer__c>();
                Set<String> masterContainerSet = new Set<String>();
                Set<String> oldMCIds = new Set<String>();
                Map<String,String> newMCIDs = new Map<String,String>(); 
                decimal neworder = 0;
                for (leankor__MasterContainer__c nmc : mContainers) { 
                    masterContainerSet.add(nmc.Name); 
                    newMCIDs.put(nmc.Name,nmc.Id);
                    if (nmc.leankor__Order__c != null) {
                        neworder = nmc.leankor__Order__c;
                    } else {
                        neworder = neworder+1;
                    }
                } 
                for (leankor__MasterContainer__C MC : oldMContainers) {
                    if (!masterContainerSet.contains(MC.Name)) { 
                        materContainerIds.put(MC.Id,MC.Name);
                        oldMCIds.add(MC.Id);
                        neworder = neworder+1; 
                        MasterContainers.add(MultipleMergeProjectBoardAction.assignData(mC, vsId, neworder));                    
                    } else {
                        String newID=newMCIDs.get(MC.Name);
                        materContainerIds.put(MC.Id,newID);
                    }
                }
                try {
                    DataBase.Insert(masterContainers, false);
                } catch(DMLException ex) {
                    throw new Util.LeanException('ERROR:' + ex.getMessage());
                }
                for (leankor__MasterContainer__C MSCT : masterContainers) {
                    String tId= MSCT.Name;
                    MSCT.Name = materContainerIds.get(tId);
                    materContainerIds.put(tId,MSCT.Id); // Getting Old mastercontainer id from new collection.
                }
                try {
                    DataBase.Update(masterContainers, false);
                } catch(DMLException ex) {
                    throw new Util.LeanException('ERROR:' + ex.getMessage());
                }
                //End MC Clone 
                //Start of Swimlane Clone
                List<leankor__Swimlane__c> newSwimlanes = KanbanController.readSwimlanes(new Set<String>{vsId});
                List<leankor__Swimlane__c> oldSwimlanes = KanbanController.readSwimlanes(new Set<String>{realVsId});
                Set<String> swimlaneSet = new Set<String>();
                Set<String> oldSwimlaneIds = new Set<String>();
                Map<String,String> newSWIDs = new Map<String,String>();
                List<decimal> sworderlist = new List<decimal>();
                decimal newSWorder = 0;
                for (leankor__Swimlane__c nsw :newSwimlanes) { 
                    swimlaneSet.add(nsw.Name); 
                    newSWIDs.put(nsw.Name,nsw.Id);
                    sworderlist.add(nsw.leankor__Order__c);
                    // Sort them, which means that the highest value comes last
                    newSWorder=newSWorder+1; 
                } 
                sworderlist.sort();
                if(sworderlist[sworderlist.size()-1]>newSWorder){
                    newSWorder=sworderlist[sworderlist.size()-1];
                }              
                List<leankor__Swimlane__c> Swimlanes = new List<leankor__Swimlane__c>();
                for(leankor__Swimlane__c s : oldSwimlanes){
                    if(oldMCIds.contains(s.leankor__MasterContainer__c)){
                        swimlanesTemp.put(s.Id,s.Name);
                        oldSwimlaneIds.add(s.Id);
                        newSWorder=newSWorder+1;   
                        leankor__Swimlane__c swim = MultipleMergeProjectBoardAction.assignSwimlane(s, newSWorder, vsId);      
                        swim.leankor__MasterContainer__c = materContainerIds.get(s.leankor__MasterContainer__c);     
                        Swimlanes.add(swim);
                    }else{
                        string flag = null;
                        string swimMC = materContainerIds.get(s.leankor__MasterContainer__c);
                        for(leankor__Swimlane__c nswim :newSwimlanes){
                            if (nswim.Name == s.Name && nswim.leankor__MasterContainer__c==swimMC){
                                flag =nswim.Id;
                            }                       
                        }
                        if(flag!= null){
                            swimlanesTemp.put(s.Id,flag);
                        }else{
                            swimlanesTemp.put(s.Id,s.Name);
                            oldSwimlaneIds.add(s.Id);
                            newSWorder=newSWorder+1; 
                            leankor__Swimlane__c swim = MultipleMergeProjectBoardAction.assignSwimlane(s, newSWorder, vsId);      
                            swim.leankor__MasterContainer__c = materContainerIds.get(s.leankor__MasterContainer__c);     
                            Swimlanes.add(swim);                              
                        }                
                    }               
                }
                try {
                    DataBase.Insert(Swimlanes, false);
                } catch(DMLException ex){
                    throw new Util.LeanException('ERROR:' + ex.getMessage());
                }
                for(leankor__Swimlane__c Swimlan : Swimlanes){
                    String sId= Swimlan.Name;
                    Swimlan.Name = swimlanesTemp.get(sId);
                    swimlanesTemp.put(sId,Swimlan.Id); // Getting Old Swimlane id from new collection.
                }
                try{
                    DataBase.Update(Swimlanes, false);
                }Catch(DMLException ex){
                    throw new Util.LeanException('ERROR:' + ex.getMessage());
                }
                //End of Swimlane Clone
                //start of Zone Clone
                List<leankor__Zone__c> newZones = CloneProjectPlanGanttBatch.getZones(new Set<String>{vsId});
                List<leankor__Zone__c> oldZones = CloneProjectPlanGanttBatch.getZones(new Set<String>{realVsId});
                Set<String> ZoneSet = new Set<String>();
                Set<String> OldZNIds = new Set<String>();
                Map<String,String> newZoneIDs = new  Map<String,String>();
                 List<decimal> ZNorderlist = new List<decimal>();
                decimal newZoneorder=0;
                for (leankor__Zone__c ZN :newZones) { 
                    ZoneSet.add(ZN.Name); 
                    newZoneIDs.put(ZN.Name,ZN.Id);
                    ZNorderlist.add(ZN.leankor__Order__c);
                    // Sort them, which means that the highest value comes last
                    newZoneorder=newZoneorder+1;
                }
                ZNorderlist.sort();
                if (ZNorderlist[ZNorderlist.size()-1]>newZoneorder) {
                    newZoneorder=ZNorderlist[ZNorderlist.size()-1];
                }  
                
                List<leankor__Zone__c> NewZoneList = new List<leankor__Zone__c>();
                for (leankor__Zone__c Z : oldZones) {
                    Integer rand = Math.round(Math.random()*10000);
                    if (oldSwimlaneIds.contains(Z.leankor__Swimlane__c)) {
                        zoneIds.put(Z.Id,Z.Name);
                        zoneguIds.put(Z.leankor__GUID__c,Z.Id+'-'+rand+'-sl00');
                        OldZNIds.add(Z.Id);
                        newZoneorder=newZoneorder+1;  
                        leankor__Zone__c newZone = MultipleMergeProjectBoardAction.assignZone(z, vsId, rand); 
                        newZone.leankor__Order__c = newZoneorder;
                        newZone.leankor__Swimlane__c = swimlanesTemp.get(Z.leankor__Swimlane__c);       
                        NewZoneList.add(NewZone);
                    } else {
                        String flag = null;
                        String flagGUID = null;
                        String ZoneSwim = swimlanesTemp.get(Z.leankor__Swimlane__c);
                        for (leankor__Zone__c NZone :newZones) { 
                            if (NZone.Name == Z.Name && NZone.leankor__Swimlane__c==ZoneSwim){
                                flag = NZone.Id;
                                flagGUID = NZone.leankor__GUID__c;
                            }                       
                        }
                        if (flag!= null) {
                            zoneIds.put(Z.Id,flag);
                            zoneguIds.put(Z.leankor__GUID__c,flagGUID);
                        } else {
                            zoneIds.put(Z.Id,Z.Name);
                            zoneguIds.put(Z.leankor__GUID__c,Z.Id+'-'+rand+'-sl00');
                            OldZNIds.add(Z.Id);
                            newZoneorder=newZoneorder+1; 
                            leankor__Zone__c newZone = MultipleMergeProjectBoardAction.assignZone(z, vsId, rand); 
                            newZone.leankor__Order__c = Z.leankor__Order__c;
                            newZone.leankor__Swimlane__c = swimlanesTemp.get(Z.leankor__Swimlane__c);  
                            NewZoneList.add(NewZone);                       
                        }                
                    }               
                }
                try {
                    DataBase.Insert(NewZoneList, false);
                } catch (DMLException ex) {
                    throw new Util.LeanException('ERROR:' + ex.getMessage());
                }
                for (leankor__Zone__c zone : NewZoneList) {
                    String zId= zone.Name;
                    zone.Name = zoneIds.get(zId);
                    zoneIds.put(zId,zone.Id); // Getting Old Zone id from new collection.
                        
                }
                try {
                    DataBase.Update(NewZoneList, false);
                } catch (DMLException ex) {
                    throw new Util.LeanException('ERROR:' + ex.getMessage());
                }                       
                //End of Zone Clone 
                //Update Height and Width of MC & Swimlane
                MultipleMergeProjectBoardAction.updateHeightWidth(vsId); 
            } else {
                if (mContainers.Size() > 0) { 
                    leftMasterContainer = mContainers[0].Id; // Getting left most MC Id
                    for (leankor__MasterContainer__C m : mContainers) {
                        if (m.leankor__Type__C == 'Backlog') {        
                            leftMasterContainer = m.Id; // Getting backlog type MC Id
                        } 
                    } 
                } 
                List<leankor__Swimlane__c> list_SW = MultipleMergeProjectBoardAction.getSwimlane(leftMasterContainer, vsId);
                leftMostSwimlane = list_SW[0].ID;
                List<leankor__Zone__c> listZone = MultipleMergeProjectBoardAction.getZone(leftMostSwimlane, vsId);
                leftMostZone = listZone[0].leankor__GUID__c;
                leftMostZoneId = listZone[0].ID;
            } 
        }
        //==========================Clone KanbanCardTemplates=============
        
        // Template Start 
        Map<String,String> templateIDs = new  Map<String,String>();   
        Map<String,String> newtemplateIDs = new  Map<String,String>();   
        List<leankor__KanbanCardTemplate__C> newkanbanTempates = MultipleMergeProjectBoardAction.getTemplateData(new Set<String>{vsId});
        Set<String> templateSet = new Set<String>(); 
        for (leankor__KanbanCardTemplate__c t :newkanbanTempates) { 
            templateSet.add(t.leankor__Title__c); 
            newtemplateIDs.put(t.leankor__Title__c,T.Id);
        } 
        List<leankor__KanbanCardTemplate__C> cloneTemplates = new List<leankor__KanbanCardTemplate__C>();
        List<leankor__KanbanCardTemplate__C> kanbanTempates = MultipleMergeProjectBoardAction.getTemplateData(new Set<String>{realVsId});
        for (leankor__KanbanCardTemplate__C kct : kanbanTempates) {
            if (!templateSet.contains(kct.leankor__Title__c)) {
                templateIDs.put(kct.Id,kct.leankor__Title__c);
                cloneTemplates.add(MultipleMergeProjectBoardAction.assignTemplateData(kct, vsId));
            } else {
                String newID = newtemplateIDs.get(kct.leankor__Title__c);
                templateIDs.put(kct.Id,newID);
            }
        }
        try {
            DataBase.Insert(cloneTemplates, false);
        } catch (DMLException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        for (leankor__KanbanCardTemplate__C kct : cloneTemplates) {
            String tId = kct.leankor__Title__c;
            kct.leankor__Title__c = templateIDs.get(tId);
            templateIDs.put(tId,kct.Id); // Getting Old template id from new collection.
        }
        try {
            DataBase.Update(cloneTemplates, false);
        } catch(DMLException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        // Template End 
        //----------------KanbanCard----------------------------------
        List<Task> kanbanTaskList = New list<Task>();
        DateTime FinalDate,initialDate,largestDueDateTime,minstartDateTime; 
        List<leankor__KanbanCard__c> RemoteKanbanCards = new List<leankor__KanbanCard__c> ();
        Map<String, List<Task>> RemoteKanbanCardTasksMap= new Map<String, List<Task>>();
        if (request.initialDate != null) {
            initialDate = request.initialDate;
            //Removed subquery for Task record
            //RS 28/11/2019 Added Owner.IsActive to query
            RemoteKanbanCards = MultipleMergeProjectBoardAction.readCardWithStart(new Set<String>{realVsId});
            if(RemoteKanbanCards.size()<0) {
                return null;
            } else {			
	            // query task records and put results in a list        	
	            //RS 28/11/2019 Added Owner.IsActive to query        	
	            RemoteKanbanCardTasksMap = MultipleMergeProjectBoardAction.getTask(RemoteKanbanCards);			
	            minstartDateTime = RemoteKanbanCards[0].leankor__StartDateTime__c;
            }
        } else {
            FinalDate = request.TargetDate != null ? request.TargetDate : system.now();
            //RS 28/11/2019 Added Owner.IsActive to query
            remoteKanbanCards = MultipleMergeProjectBoardAction.readCardWithDue(new Set<String>{realVsId});
            if (RemoteKanbanCards.size()<0) {
                return null;
            } else {			
	            // query task records and put results in a list        	
	            RemoteKanbanCardTasksMap = MultipleMergeProjectBoardAction.getTask(RemoteKanbanCards);		 
                largestDueDateTime = RemoteKanbanCards[0].leankor__DueDateTime__c;
            }
        }
        if (RemoteKanbanCards.Size() > 0) {
            List<realTimeController.Kanban> NewKanbanCards = new List<realTimeController.Kanban>();
            Map<String,Decimal> mapKanbanCardDifference = new Map<String,Decimal>();
            List<leankor__Dependency__c> dependList = MultipleMergeProjectBoardAction.getDependency(RemoteKanbanCards);     
           // List<leankor__Dependency__c> DependencyList = new List<leankor__Dependency__c>();   
            
            for (leankor__KanbanCard__c RemoteKanban : RemoteKanbanCards) {
                //refactored code to fix Techical Debt
                if (RemoteKanbanCardTasksMap.get(RemoteKanban.Id) != null && RemoteKanbanCardTasksMap.get(RemoteKanban.Id).size()>0) {
                    kanbanTaskList.addAll(RemoteKanbanCardTasksMap.get(RemoteKanban.Id));
                }
                String tempID = templateIDs.get(RemoteKanban.leankor__KanbanCardTemplate__c);
                DateTime tempDueDateTime,tempStartDateTime;
                Decimal otherDifference;
                if(initialDate != null ){
                    Integer difference = (RemoteKanban.leankor__StartDateTime__C.date()).daysBetween(minstartDateTime.date()); 
                    tempStartDateTime = (difference == 0 ? initialDate : initialDate - difference); 
                    Decimal tempEstimation = RemoteKanban.leankor__EstimatedDuration__c;
                    tempEstimation = ((Date.valueOf(RemoteKanban.leankor__DueDateTime__C)).daysBetween(Date.valueOf(tempStartDateTime))) - tempEstimation; 
                    tempDueDateTime = (tempEstimation < 0 ? ((DateTime.ValueOf(tempStartDateTime)) - tempEstimation) : RemoteKanban.leankor__DueDateTime__C);  
                    otherDifference = ((RemoteKanban.leankor__StartDateTime__C.date()).daysBetween(tempstartDateTime.date()));
                    if (remoteKanban.leankor__startDateTime__C < tempstartDateTime) {
                        tempDueDateTime = remoteKanban.leankor__DueDateTime__C + math.abs(otherDifference) ;
                    } else { 
                        tempDueDateTime = remoteKanban.leankor__DueDateTime__C -  math.abs(otherDifference) ;//remoteKanban.DueDate - remoteKanban.EstimatedDuration;
                    }
                } else {
                    Integer difference = (RemoteKanban.leankor__DueDateTime__c.date()).daysBetween(largestDueDateTime.date()); 
                    tempDueDateTime = (difference == 0 ? FinalDate : FinalDate - difference); 
                    Decimal tempEstimation = RemoteKanban.leankor__EstimatedDuration__c;
                    Decimal newtempEstimation = (Date.valueOf(RemoteKanban.leankor__StartDateTime__C).daysBetween(Date.valueOf(tempDueDateTime)))- tempEstimation;
                    tempStartDateTime = (tempEstimation < 0 ? ((DateTime.ValueOf(tempDueDateTime)) + tempEstimation) : RemoteKanban.leankor__StartDateTime__C);
                    otherDifference = ((RemoteKanban.leankor__DueDateTime__C.date()).daysBetween(tempDueDateTime.date()));
                    if (remoteKanban.leankor__DueDateTime__C < tempDueDateTime) {
                        tempStartDateTime = remoteKanban.leankor__StartDateTime__C + math.abs(otherDifference) ;
                    } else { 
                        tempStartDateTime = remoteKanban.leankor__StartDateTime__C -  math.abs(otherDifference) ;//remoteKanban.DueDate - remoteKanban.EstimatedDuration;
                    }
                }
                mapKanbanCardDifference.put(RemoteKanban.Id,otherDifference);
                leankor.RealTimeController.Kanban NewKanban = new leankor.RealTimeController.Kanban();
                Integer randm = Math.round(Math.random()*10000);
                if (RemoteKanban.leankor__Valuestream__r.leankor__PointPicklist__c != null) {
                    List<Integer> ListPoint = (List<Integer>)JSON.Deserialize(RemoteKanban.leankor__Valuestream__r.leankor__PointPicklist__c, List<Integer>.class);
                    NewKanban.point = (ListPoint.size() <= 0 ? 1: ListPoint[0]);
                }
                NewKanban.OwnerId = RemoteKanban.OwnerId;
                NewKanban.cardID = RemoteKanban.leankor__CardID__c; 
                newKanban.EffortRemaining = RemoteKanban.leankor__EffortRemaining__c;
                NewKanban.OnBudget = (RemoteKanban.leankor__OnBudget__c == null ? 'Green' : RemoteKanban.leankor__OnBudget__C);
                NewKanban.OnQuality = (RemoteKanban.leankor__OnQuality__C == null ? 'Green' : RemoteKanban.leankor__OnQuality__C);
                NewKanban.OnTime = (RemoteKanban.leankor__OnTime__C == null ? 'Green' : RemoteKanban.leankor__OnTime__C);
                NewKanban.AcceptanceCriteria = RemoteKanban.leankor__AcceptanceCriteria__c;
                NewKanban.UrlLink = RemoteKanban.leankor__UrlLink__c;
                NewKanban.GUID = RemoteKanban.Id+'-'+randm+'-sl00';
                NewKanban.Title= RemoteKanban.leankor__Title__c;
                NewKanban.Name = RemoteKanban.Name;
                NewKanban.Bottom = RemoteKanban.leankor__Bottom__c;
                NewKanban.Width = RemoteKanban.leankor__Width__c;
                NewKanban.Height = RemoteKanban.leankor__Height__c;
                if (boardTypeTemp =='Kanban Board') {
                    NewKanban.X = RemoteKanban.leankor__X__c;
                    NewKanban.Y = RemoteKanban.leankor__Y__c;
                    NewKanban.Top = RemoteKanban.leankor__Top__c;
                    NewKanban.Left = RemoteKanban.leankor__Left__c;
                } else {
                    NewKanban.X = 100;
                    NewKanban.Y = 100;
                    NewKanban.Top = 2100;
                    NewKanban.Left = 2100;              
                }
                NewKanban.ValueStream = vsId;
                NewKanban.TemplateID = tempID;
                NewKanban.EstimatedDuration = RemoteKanban.leankor__EstimatedDuration__c;
                NewKanban.Color = RemoteKanban.leankor__Color__c;  // EjB7: added color and JSONDefinition
                NewKanban.JSONDefinition = RemoteKanban.leankor__JSONDefinition__c;
                NewKanban.JSONData = RemoteKanban.leankor__JSONData__c;
                //NewKanban.DueDate = tempDueDateTime;
                NewKanban.DueDate = Datetime.newInstance(tempDueDateTime.year(),tempDueDateTime.month(), tempDueDateTime.day(),RemoteKanban.leankor__DueDateTime__C.hour(),RemoteKanban.leankor__DueDateTime__C.minute(),RemoteKanban.leankor__DueDateTime__C.second());//tempDueDateTime; 
                NewKanban.DurationUnits = RemoteKanban.leankor__DurationUnits__c;  // EjB11: added duration units picklist string
                NewKanban.Priority = Integer.ValueOF(RemoteKanban.leankor__Priority__c); //EjB14: added priority
                NewKanban.HarveyBall = String.ValueOF(RemoteKanban.leankor__PercentComplete2__c);//field for Harvay Ball in percentage 
                NewKanban.Order = NewKCorder ; 
                NewKCorder = NewKCorder+1;//(RemoteKanban.leankor__Order__C == null ? 0 : Integer.ValueOF(RemoteKanban.leankor__Order__c));
                NewKanban.DateColor = RemoteKanban.leankor__DateColor__c; //field for foreground color of Date value  
                NewKanban.Description = RemoteKanban.leankor__DescriptionLong__c;
                //NewKanban.ValueStreamCardLink =  (linkCloneVSID == '' ? RemoteKanban.leankor__ValueStreamCardLink__c : (linkCloneKanbanCardId == '' ? null : linkCloneKanbanCardId));  //RemoteKanban.leankor__ValueStreamCardLink__c; 
                //NewKanban.ValueStreamLinkID = (linkCloneVSID == '' ? RemoteKanban.leankor__ValueStreamLink__c : linkCloneVSID);//RemoteKanban.leankor__ValueStreamLink__c ; 
                NewKanban.ValueStreamLinkID = (RemoteKanban.leankor__ValueStreamLink__c== null ? (linkCloneVSID == '' ? RemoteKanban.leankor__ValueStreamLink__c : linkCloneVSID) :RemoteKanban.leankor__ValueStreamLink__c);
                NewKanban.ValueStreamCardLink = (RemoteKanban.leankor__ValueStreamCardLink__c== null ? (linkCloneVSID == '' ? RemoteKanban.leankor__ValueStreamCardLink__c : (linkCloneKanbanCardId == '' ? null : linkCloneKanbanCardId)):RemoteKanban.leankor__ValueStreamCardLink__c);
                NewKanban.Account = RemoteKanban.leankor__Account__c;
                NewKanban.Contact = RemoteKanban.leankor__Contact__c;
                NewKanban.CaseID = RemoteKanban.leankor__Case__c;
                //NewKanban.StartDate = tempStartDateTime;
                NewKanban.StartDate = Datetime.newInstance(tempStartDateTime.year(),tempStartDateTime.month(), tempStartDateTime.day(),RemoteKanban.leankor__StartDateTime__C.hour(),RemoteKanban.leankor__StartDateTime__C.minute(),RemoteKanban.leankor__StartDateTime__C.second());//tempStartDateTime; 
                Integer ED =  integer.valueof(NewKanban.EstimatedDuration);
                if (NewKanban.DurationUnits == 'Hours') {
                    Decimal tempED= ED/8;
                    if (tempED > Integer.valueof(ED/8)) {
                        ED = Integer.valueof(ED/8) + 1;
                    } else {
                        ED = Integer.valueof(ED/8);
                    }
                } else if (NewKanban.DurationUnits == 'Years') {
                    ED = Integer.valueof(ED*365);
                } else if (NewKanban.DurationUnits == 'Months') {
                    ED = Integer.valueof(ED*30);
                } else if (NewKanban.DurationUnits == 'Minutes') {
                    Decimal tempED= ED/60;
                    if (tempED > Integer.valueof(ED/60)) {
                        ED = Integer.valueof(ED/60) + 1;
                    } else {
                        ED = Integer.valueof(ED/60);
                    }
                    decimal tempDayED = ED/8;
                    if (tempDayED > Integer.valueof(ED/8)) {
                        ED = Integer.valueof(ED/8) + 1;
                    } else{
                        ED = Integer.valueof(ED/8);
                    }
                } else if(NewKanban.DurationUnits == 'Weeks'){
                    ED = Integer.valueof(ED*5);
                } 
                //Get non working days of week
				Map<String, Integer> mapNonWorkingDays = workWeek.readNonWorkingDays();
				//ss 09.05.2018 
                if (!targetBoardiIsWeekendBoard && (initialDate == null)) {
                    datetime tempcalstartdate = NewKanban.DueDate;
                	if (NewKanban.DurationUnits == 'Years') {
                        tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(NewKanban.EstimatedDuration));
                    	tempcalstartdate = tempcalstartdate +1 ;
                    } else if(NewKanban.DurationUnits == 'Months') {
                        tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(NewKanban.EstimatedDuration));
                    	tempcalstartdate = tempcalstartdate +1 ;
                    } else {
	                    for (integer i = 1 ;i< ED;i++ ) {
	                        tempcalstartdate = tempcalstartdate-1;
	                        //Calculate WorkingWeekDays escaping non working day according to first day of week
							tempcalstartdate = Util.readPreviousWorkingDateTime(workWeek,tempcalstartdate);
	                    }
	                }
                    //Check DueDate is not in working days and in non working day it is 1st or 2nd
					if (!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(NewKanban.DueDate.format('EEEE')) == 1)) {
						NewKanban.DueDate = NewKanban.DueDate - 1;
                        tempcalstartdate = tempcalstartdate - 1;
					} else if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(NewKanban.DueDate.format('EEEE')) == 2)) {
						NewKanban.DueDate = NewKanban.DueDate - 2;
                        if (ED == 1) {
                            tempcalstartdate = tempcalstartdate + 2;
                        } else {
                            tempcalstartdate = tempcalstartdate - 1;
                        }
					}
			        //Calculate WorkingWeekDays escaping non working day according to first day of week
					tempcalstartdate = Util.readPreviousWorkingDateTime(workWeek,tempcalstartdate);
                    NewKanban.StartDate = tempcalstartdate;         
                } else if (!targetBoardiIsWeekendBoard && (initialDate != null)) {
                    datetime tempcalduedate = NewKanban.StartDate;
                    if (NewKanban.DurationUnits == 'Years') {
                        tempcalduedate = tempcalduedate.addYears(integer.valueof(NewKanban.EstimatedDuration));
                    	tempcalduedate = tempcalduedate -1 ;
                    } else if(NewKanban.DurationUnits == 'Months') {
                        tempcalduedate = tempcalduedate.addMonths(integer.valueof(NewKanban.EstimatedDuration));
                    	tempcalduedate = tempcalduedate -1 ;
                    } else {
	                    for (integer i = 1 ;i<ED;i++ ) {
	                        tempcalduedate = tempcalduedate+1;
	                        //ss 04.05.2018
	                        //Calculate WorkingWeekDays escaping non working day according to first day of week
							tempcalduedate = Util.readNextWorkingDateTime(workWeek,tempcalduedate);
	                    }
	                }
                    //Check DueDate is not in working days and in non working day it is 1st or 2nd
					if (!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(NewKanban.StartDate.format('EEEE')) == 1)) {
						NewKanban.StartDate = NewKanban.StartDate + 2;
                        if (ED == 1) {
                            tempcalduedate = tempcalduedate + 2;
                        } else {
                            tempcalduedate = tempcalduedate + 1;
                        }
					} else if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(NewKanban.StartDate.format('EEEE')) == 2)) {
						NewKanban.StartDate = NewKanban.StartDate + 1;
                        tempcalduedate = tempcalduedate + 1;
					}
                    //Calculate WorkingWeekDays escaping non working day according to first day of week
					tempcalduedate = Util.readNextWorkingDateTime(workWeek,tempcalduedate);
                    NewKanban.DueDate = tempcalduedate;                         
                } else {
                    if (NewKanban.DurationUnits == 'Weeks') {
                        ED = Integer.valueof(NewKanban.EstimatedDuration*7);
                    }
                    if (initialDate != null) {
                        datetime tempcalduedate = NewKanban.StartDate;
                        if (NewKanban.DurationUnits == 'Years') {
	                        tempcalduedate = tempcalduedate.addYears(integer.valueof(NewKanban.EstimatedDuration));
	                    	tempcalduedate = tempcalduedate -1 ;
	                    } else if(NewKanban.DurationUnits == 'Months') {
	                        tempcalduedate = tempcalduedate.addMonths(integer.valueof(NewKanban.EstimatedDuration));
	                    	tempcalduedate = tempcalduedate -1 ;
	                    } else {
	                        for (integer i = 1 ;i<ED;i++ ) {
	                            tempcalduedate = tempcalduedate+1;
	                        }
                        }
                        NewKanban.DueDate = tempcalduedate;
                    }else{
                        datetime tempcalstartdate = NewKanban.DueDate;
                        if(NewKanban.DurationUnits == 'Years'){
	                        tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(NewKanban.EstimatedDuration));
	                    	tempcalstartdate = tempcalstartdate +1 ;
	                    }else if(NewKanban.DurationUnits == 'Months'){
	                        tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(NewKanban.EstimatedDuration));
	                    	tempcalstartdate = tempcalstartdate +1 ;
	                    }else{ 
	                        for(integer i = 1 ;i<ED;i++ ){
	                            tempcalstartdate = tempcalstartdate-1;
	                        }
                        }
                        NewKanban.StartDate = tempcalstartdate;
                    }
                }
                NewKanban.Opportunity = RemoteKanban.leankor__Opportunity__C;
                if(request.WithMC){                     
                    NewKanban.ZoneID = (zoneguIds.get(RemoteKanban.leankor__ZoneGUID__c)!=null)?zoneguIds.get(RemoteKanban.leankor__ZoneGUID__c):'';
                    NewKanban.MCForceID =(materContainerIds.get(RemoteKanban.leankor__MasterContainer__c)!=null)?materContainerIds.get(RemoteKanban.leankor__MasterContainer__c):'';
                    NewKanban.SWForceID =(swimlanesTemp.get(RemoteKanban.leankor__Swimlane__c)!=null) ?swimlanesTemp.get(RemoteKanban.leankor__Swimlane__c):'';
                    NewKanban.ZoneForceID =(zoneIds.get(RemoteKanban.leankor__Zone__c)!=null) ?zoneIds.get(RemoteKanban.leankor__Zone__c):'';
                }else{
                    NewKanban.ZoneID = leftMostZone;
                    NewKanban.MCForceID =leftMasterContainer;
                    NewKanban.SWForceID =leftMostSwimlane;
                    NewKanban.ZoneForceID =leftMostZoneId;
                }
                NewKanban.ownerIsActive = RemoteKanban.Owner.IsActive;    
                NewKanbanCards.add(NewKanban);             
            }
            try {                                                                                                                                                                                                                                                                                                                                                                                                                                             
            	// Date : 23/10/19 using wrapper class instance instead of Serialization.                                                                                                                                                                                                                                                                                                                                                                                                                     
               // MergeKanbanCards = leankor.realTimeController.createKanbanCard(vsId,NewKanbanCards);
                MergeKanbanCards = leankor.realTimeController.createKanbanCards(vsId,NewKanbanCards);
            } catch (Exception ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }          
            //----------------KanbanCard End----------------------------------
            Map<String,String> mapKanbanCard = MultipleMergeProjectBoardAction.cloneDependency(vsId, dependList);
            Map<String,String> oldNewTask = MultipleMergeProjectBoardAction.cloneTask(kanbanTaskList, workWeek, mapKanbanCard, initialDate, mapKanbanCardDifference, targetBoardiIsWeekendBoard);
            MultipleMergeProjectBoardAction.cloneIssueLog(RemoteKanbanCards, mapKanbanCard, mapKanbanCardDifference, oldNewTask);
            MultipleMergeProjectBoardAction.cloneTimeCard(RemoteKanbanCards, mapKanbanCard, mapKanbanCardDifference, oldNewTask);
            MultipleMergeProjectBoardAction.cloneStickers(new List<String>{realVsId}, vsId, mapKanbanCard, RemoteKanbanCards);    
            if(!string.isBlank(linkCloneVSID) && !string.isBlank(linkCloneKanbanCardId)){
		        List<leankor.RealTimeController.DirectLinkCardLog> DefaultLinks = new List<leankor.RealTimeController.DirectLinkCardLog>();
				leankor.RealTimeController.DirectLinkCardLog DefaultLog = new leankor.RealTimeController.DirectLinkCardLog();
					DefaultLog.ValueStreamId = vsId;
					DefaultLog.LinkRoomId = linkCloneRoomID;
					DefaultLog.LinkValueStreamId = linkCloneVSID;
					DefaultLog.LinkKanbanCardId = linkCloneKanbanCardId;
					DefaultLog.OldLinkKanbanCardId = Boardtype.leankor__ValueStreamCardLink__c;
					DefaultLog.OldLinkValueStreamId = Boardtype.leankor__ValueStreamLink__c; 
					DefaultLog.MySessionId = UserInfo.getSessionId();
					DefaultLinks.add(DefaultLog);
				String setdefault = leankor.RealTimeController.UpdateDefaultLink(DefaultLinks);				
			}
            //Ashutosh : 19/02/2021 : Send broadcast message after successfully record save.
            //Rs 19/12/2017 Added flowWithGS variable in json for Gs with flow 
            String someJSONData = '{"ValueStreamOwnerName" : "'+valueStreamOwner+'","ValueStreamID" :"'+ vsId+'" , "flowWithGS" : true}';             
            try{
                leankor.RealTimeController.KanbanStateChange(vsId, 'UpdateRuntimeBoard', UserInfo.getSessionId(), someJSONData);
            } catch (Exception e){
                throw new Util.LeanException('ERROR:' + e.getMessage());
            }
        }
        return MergeKanbanCards; 
    }
}