/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  MultipleMergeProjectBoardAction.cls
* CLASS: MultipleMergeProjectBoardAction
* USAGE: MultipleMergeProjectBoardAction .
*/
global with sharing class MultipleMergeProjectBoardAction{

	// rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
	public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c', 'leankor__KanbanCardSticker__c'};
	// rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
	
    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    global class MultipleMergeProjectBoardActionRequest{
        @InvocableVariable(label = 'Source Board Ids' description = 'IDs of the Project Board which to be merge.')
            global List<String> sourceBoardId;
        @InvocableVariable(label = 'Target Board Id' description = 'ID of the Project Board where to be merge.')
            global String targetBoardId;
        @InvocableVariable(label ='Due Date' description ='Provide the final Due Date for the Card farthest in the future.')
            global DateTime targetDate;
        @InvocableVariable(label ='Link Board Id' description='ID of the Link Board to Linked with merge Cards.')
            global String linkBoardId;        
        @InvocableVariable(label ='Link Kanban Card ID' description ='Name of Link Kanban Card Which to linked with merge Cards .')
            global String linkKanbanCardId;
        @InvocableVariable(label = 'Is Master Container' required = true description = 'Verb, which check merge Board with MC  .')
            global Boolean withMC;
        @InvocableVariable(label ='Start Date' description = 'Provide the initial Start Date for the Card farthest in the future.')
            global DateTime initialDate;
    }
    
    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    global class MultipleMergeProjectBoardActionResult{ 
         @InvocableVariable(label = 'Kanban Card Id List' description = 'Ids of new merge Kanban Card ')
            global List<leankor__KanbanCard__c> kanbanCardIds = new List<leankor__KanbanCard__c>();
    }
    
  
    @InvocableMethod 
    global static List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionResult> MultipleMergeProjectBoard(List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> requests){
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
        DependencyBehaviour checkDependencyBehaviour = new DependencyBehaviour();

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
            !checkDependencyBehaviour.isCreateable() ||
            !checkDependencyBehaviour.isUpdateable()
        ) {
			throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior
        
        List<MultipleMergeProjectBoardActionResult> newrstKanbancards = new List<MultipleMergeProjectBoardActionResult>();
        List<leankor__KanbanCard__c> mergeKanbancards =new List<leankor__KanbanCard__c>();  
        //--------------Source record from DB--------------------------
        List<leankor__ValueStream__c> sourceBoards = [Select Id,
                                                            Owner.name,
                                                            Name,
                                                            leankor__BoardType__c,
                                                            leankor__ValueStreamLink__c,
                                                            leankor__ValueStreamCardLink__c 
                                                        From leankor__ValueStream__c 
                                                        Where ID In :requests[0].SourceBoardId 
                                                        With Security_Enforced
                                                        Limit 9999];
        List<leankor__MasterContainer__c> sBMasterContainer = getMasterContainerData(new Set<String>(requests[0].SourceBoardId));
        List<leankor__MasterContainer__c> tBMasterContainer = getMasterContainerData(new Set<String>{requests[0].TargetBoardId});
        List<leankor__Swimlane__c> sBSwimlane = KanbanController.readSwimlanes(new Set<String>(requests[0].SourceBoardId));
        List<leankor__Swimlane__c> tBSwimlane = KanbanController.readSwimlanes(new Set<String>{requests[0].TargetBoardId});
        List<leankor__Zone__c> sBZone = CloneProjectPlanGanttBatch.getZones(new Set<String>(requests[0].SourceBoardId));
        List<leankor__Zone__c> tBZone = CloneProjectPlanGanttBatch.getZones(new Set<String>{requests[0].TargetBoardId});
        List<leankor__KanbanCardTemplate__c> sBTemplates = getTemplateData(new Set<String>(requests[0].SourceBoardId));
        List<leankor__KanbanCardTemplate__c> tBTemplates = getTemplateData(new Set<String>{requests[0].TargetBoardId});
        
        leankor__ValueStream__c targetBoard = [Select 
                                                    Id,
                                                    leankor__SevenDayWorkWeek__c,
                                                    leankor__projectroom__c,
                                                    Owner.name,
                                                    Name,
                                                    leankor__BoardType__c, 
                                                    leankor__ValueStreamLink__c, 
                                                    leankor__ValueStreamCardLink__c 
                                                From leankor__ValueStream__c 
                                                Where Id =:requests[0].TargetBoardId 
                                                With Security_Enforced
                                                Limit 1];
        
        List<leankor__Kanbancard__c> kCSize = [Select Id,
                                                        leankor__Order__c 
                                                    From leankor__Kanbancard__c
                                                    Where leankor__Valuestream__c = :requests[0].TargetBoardId 
                                                    With Security_Enforced
                                                    Order By leankor__Order__c Desc Nulls Last 
                                                    Limit 9999];
        boolean tBisweekendboard = targetBoard.leankor__SevenDayWorkWeek__c;
        integer newKCOrder = kCSize.size();
        if (kCSize.size()>0) {
            newKCOrder = integer.valueof(kCSize[0].leankor__Order__c);
        }
        if (newKCOrder < kCSize.size()) {
            newKCOrder = kCSize.size();
        }
        string btype = targetBoard.leankor__BoardType__C;
        string vSOwnerID=targetBoard.Owner.name;
        String left_MC ='';
        String left_most_SW='';
        String lM_Zone='';
        String lM_zoneID='';
        Map<String,String> mCIDs = new  Map<String,String>();
        Map<String,String> sWIDs = new  Map<String,String>();   
        Map<String,String> zoneIDs = new  Map<String,String>(); 
        Map<String,String> zoneGUIIDs = new  Map<String,String>();
        Map<String,String> newSWGUIDmap = new  Map<String,String>();
        string linkCloneVSID = (requests[0].LinkBoardID == null ? '' : requests[0].LinkBoardID);
        string linkCloneKanbanCardID = (requests[0].LinkKanbanCardId == null ? '' : requests[0].LinkKanbanCardId);
        //ss 04.05.2018
        //Added variable for getting first day of week from custom setting 	
	    Integer firstDayOfWeek =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c == null ?1 : leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c.intValue();   
   		firstDayOfWeek = firstDayOfWeek==null || firstDayOfWeek<0  || firstDayOfWeek > 6?1:firstDayOfWeek;
   		//Create instance of WorkWeek which provides Working week days information
	    Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek,5);
	    //---------------------------------------
        if(requests[0].WithMC){
            //--------------------------------------Start MC Clone-----------------------------------
            List<leankor__MasterContainer__c> masterContainers = new List<leankor__MasterContainer__c>();
            set<string> mCSet = new set<string>();
            set<string> oldMCIds = new set<string>();
            Map<String,String> newMCIDs = new  Map<String,String>();
            Map<String,String> mapnameMCIDs = new  Map<String,String>();
            Map<String,String> namemapIDMC = new  Map<String,String>();
            decimal neworder=0;
            for(leankor__MasterContainer__c nmc : tBMasterContainer){ 
                mCSet.add(nmc.Name);
                newMCIDs.put(nmc.Name,nmc.Id);
                if(nmc.leankor__Order__c!=null){
                 neworder=nmc.leankor__Order__c;
                }else{
                    neworder=neworder+1;
                }
            }
            for(leankor__MasterContainer__c mC : sBMasterContainer){
                if(!mCSet.contains(MC.Name)){ 
                    mCIDs.put(MC.Id,MC.Name);
                    oldMCIds.add(MC.Id);
                    neworder=neworder+1;     
                    masterContainers.add(assignData(mC, requests[0].TargetBoardId, neworder));
                }else{
                    String newID=newMCIDs.get(MC.Name);
                    if(newID == null){
                        mapnameMCIDs.put(MC.Name,MC.ID);
                    }
                    mCIDs.put(MC.Id,newID);
                }
                
            }
            try {
                DataBase.Insert(masterContainers, false);
            } catch(DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            for (leankor__MasterContainer__c mSCT : masterContainers) {
                String tId= mSCT.Name;
                mSCT.Name = mCIDs.get(tId);
                mCIDs.put(tId,mSCT.Id); // Getting Old mastercontainer id from new collection.
                if(mapnameMCIDs.containskey(mSCT.Name)){
                    mCIDs.put(mapnameMCIDs.get(mSCT.Name),mSCT.ID);
                }
                namemapIDMC.put(mSCT.id,mSCT.Name);
                newMCIDs.put(mSCT.Name,mSCT.id);
            }
            try {
                DataBase.Update(masterContainers, false);
            } catch(DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            //--------------------------------------End MC Clone-----------------------------------
            //-------------------Start of SW Clone---------------------------
            set<string> oldSWIds = new set<string>();
            string mClogID,mClogID2;
            Map<String,String> newSWIDs = new  Map<String,String>();
            Map<String,String> gUIDMapSW = new  Map<String,String>();
            List<decimal> sworderlist =new List<decimal>();
            decimal newSWorder=0;
            for(leankor__Swimlane__c nsw : tBSwimlane){ 
                newSWIDs.put(nsw.Name,nsw.Id);
                sworderlist.add(nsw.leankor__Order__c);
                newSWorder=newSWorder+1; 
            } 
            sworderlist.sort();
            if(sworderlist[sworderlist.size()-1]>newSWorder){
                newSWorder=sworderlist[sworderlist.size()-1];
            }              
            List<leankor__Swimlane__c> swimlanes = new List<leankor__Swimlane__c>();
            for(leankor__Swimlane__c s : sBSwimlane){
                if(oldMCIds.contains(s.leankor__MasterContainer__c)){
                    sWIDs.put(s.Id,s.Name);
                    oldSWIds.add(s.Id);
                    newSWorder=newSWorder+1;
                    if(mCIDs.get(s.leankor__MasterContainer__c)== null){
                        mClogID = newMCIDs.get(s.leankor__MasterContainer__r.name);
                    }else{
                        mClogID = mCIDs.get(s.leankor__MasterContainer__c);
                    }  
                    leankor__Swimlane__c swim = assignSwimlane(s, newSWorder, requests[0].TargetBoardId);      
                    swim.leankor__MasterContainer__c = mClogID;
                    swimlanes.add(Swim);
                }else{
                    string flag = null;
                    string swimMC = mCIDs.get(s.leankor__MasterContainer__c);
                    if(mapnameMCIDs.containskey(s.leankor__MasterContainer__r.name)){
                        for(leankor__Swimlane__c swlog :swimlanes){
                            if(sWIDs.get(swlog.name) == s.name && namemapIDMC.get(swlog.leankor__MasterContainer__c) == s.leankor__MasterContainer__r.name ){
                                gUIDMapSW.put(swlog.leankor__GUID__c,s.id);
                                flag= swlog.leankor__GUID__c ;
                            }
                        }
                    }
                    for(leankor__Swimlane__c nswim : tBSwimlane){
                        if (nswim.Name == s.Name && nswim.leankor__MasterContainer__c==swimMC){
                            flag =nswim.Id;
                        }                       
                    }
                    if(flag!= null){
                        sWIDs.put(s.Id,flag);
                    }else{
                        if(mCIDs.get(s.leankor__MasterContainer__c)== null){
                            mClogID2 = newMCIDs.get(s.leankor__MasterContainer__r.name);
                        }else{
                            mClogID2 = mCIDs.get(s.leankor__MasterContainer__c);
                        }
                        sWIDs.put(s.Id,s.Name);
                        oldSWIds.add(s.Id);
                        newSWorder=newSWorder+1; 
                        leankor__Swimlane__c swim = assignSwimlane(s, newSWorder, requests[0].TargetBoardId);      
                        swim.leankor__MasterContainer__c = mClogID2;
                        swimlanes.add(Swim);                        
                    }                
                }               
            }
            try{
                DataBase.Insert(swimlanes, false);
            }Catch(DMLException ex){
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            for(leankor__Swimlane__c Swimlan : swimlanes){
                newSWGUIDmap.put(Swimlan.leankor__GUID__c,Swimlan.ID);
                String sId= Swimlan.Name;
                Swimlan.Name = sWIDs.get(sId);
                sWIDs.put(sId,Swimlan.Id); // Getting Old Swimlane id from new collection.
                if(gUIDMapSW.containskey(Swimlan.leankor__GUID__c)){
                    sWIDs.put(gUIDMapSW.get(Swimlan.leankor__GUID__c),Swimlan.Id);
                }
            }
            try{
                DataBase.Update(swimlanes, false);
            }Catch(DMLException ex){
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            //------------------------End of Swimlane Clone--------------
            //-----------------------start of Zone Clone---------------------
            set<string> zoneSet = new set<string>();
            set<string> oldZNIds = new set<string>();
            Map<String,String> newZoneIDs = new  Map<String,String>();
            string sWID;
            List<decimal> zNorderlist =new List<decimal>();
            decimal newZoneorder=0;
            for(leankor__Zone__c zN :tBZone){ 
                zoneSet.add(zN.Name); 
                newZoneIDs.put(zN.Name,zN.Id);
                zNorderlist.add(zN.leankor__Order__c);
                newZoneorder=newZoneorder+1;
            }
            zNorderlist.sort();
            if(zNorderlist[zNorderlist.size()-1]>newZoneorder){
                newZoneorder=zNorderlist[zNorderlist.size()-1];
            }       
            List<leankor__Zone__c> newZoneList = new List<leankor__Zone__c>();
           // for(leankor__ValueStream__c SourceBoard :SourceBoards){
                for(leankor__Zone__c Z : sBZone){ //SourceBoard.leankor__Zones__r 
                    Integer rand = Math.round(Math.random()*10000);
                    if(oldSWIds.contains(z.leankor__Swimlane__c)){
                        zoneIDs.put(z.Id,z.Name);
                        zoneGUIIDs.put(z.leankor__GUID__c,z.Id+'-'+rand+'-sl00');
                        oldZNIds.add(z.Id);
                        newZoneorder=newZoneorder+1;
                        if(newSWGUIDmap.containskey(sWIDs.get(z.leankor__Swimlane__c))){
                            sWID = newSWGUIDmap.get(sWIDs.get(z.leankor__Swimlane__c));
                        }else{
                            sWID = sWIDs.get(z.leankor__Swimlane__c);
                        }   
                        leankor__Zone__c newZone = assignZone(z, requests[0].TargetBoardId, rand); 
                        newZone.leankor__Order__c = newZoneorder;
                        newZone.leankor__Swimlane__c = sWID;
                        newZoneList.add(newZone);
                    }else{
                        string flag = null;
                        string flagGUID=null;
                        string zoneSwim;
                        if(newSWGUIDmap.containskey(sWIDs.get(z.leankor__Swimlane__c))){
                            zoneSwim = newSWGUIDmap.get(sWIDs.get(z.leankor__Swimlane__c));
                        }else{
                            zoneSwim = sWIDs.get(z.leankor__Swimlane__c);
                        }
                        //string zoneSwim = sWIDs.get(z.leankor__Swimlane__c);
                        for(leankor__Zone__c nZone : tBZone){ 
                            if (nZone.Name == z.Name && nZone.leankor__Swimlane__c==zoneSwim){
                                flag =nZone.Id;
                                flagGUID=nZone.leankor__GUID__c;
                            }                       
                        }
                        if(flag!= null){
                            zoneIDs.put(z.Id,flag);
                            zoneGUIIDs.put(z.leankor__GUID__c,flagGUID);
                        }else{
                            zoneIDs.put(z.Id,z.Name);
                            zoneGUIIDs.put(z.leankor__GUID__c,z.Id+'-'+rand+'-sl00');
                            oldZNIds.add(z.Id);
                            newZoneorder=newZoneorder+1;
                            string sWlogID;
                            if(newSWGUIDmap.containskey(sWIDs.get(z.leankor__Swimlane__c))){
                                sWlogID = newSWGUIDmap.get(sWIDs.get(z.leankor__Swimlane__c));
                            }else{
                                sWlogID = sWIDs.get(z.leankor__Swimlane__c);
                            } 
                            leankor__Zone__c newZone = assignZone(z, requests[0].TargetBoardId, rand); 
                            newZone.leankor__Order__c = z.leankor__Order__c;
                            newZone.leankor__Swimlane__c = sWID; 
                            newZoneList.add(NewZone);                       
                        }                
                    }               
                }
            //}
            try{
                DataBase.Insert(newZoneList, false);
            }Catch(DMLException ex){
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            for(leankor__Zone__c zone : newZoneList){
                String zId= zone.Name;
                zone.Name = zoneIDs.get(zId);
                zoneIDs.put(zId,zone.Id); // Getting Old Zone id from new collection.
                    
            }
            try{
                DataBase.Update(newZoneList, false);
            }Catch(DMLException ex){
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }                       
            //-----------------------------End of Zone Clone ----------------------
            //Update Height and Width of MC & Swimlane
            updateHeightWidth(requests[0].TargetBoardId);
            //------------------Manage MC Hights and width-------------------------
        }else{
            if(tBMasterContainer.Size() >  0){
                left_MC = tBMasterContainer[0].Id; // Getting left most MC Id
                for(leankor__MasterContainer__c m : tBMasterContainer){
                    if(m.leankor__Type__C == 'Backlog'){        
                        left_MC = m.Id; // Getting backlog type MC Id
                    } //End of If
                } // End of for loop
            } // End of If
            List<leankor__Swimlane__c> list_SW = getSwimlane(left_MC, requests[0].TargetBoardId);
            left_most_SW = list_SW[0].ID;
            List<leankor__Zone__c> list_zone = getZone(left_most_SW, requests[0].TargetBoardId);
            lM_Zone = list_zone[0].leankor__GUID__c;
            lM_zoneID = list_zone[0].ID;
        }
        //==========================Clone KanbanCardTemplates=============
        Map<String,String> templateIDs = new  Map<String,String>();   
        Map<String,String> newtemplateIDs = new  Map<String,String>();
        list<leankor__KanbanCardTemplate__C> kCTleft = new list <leankor__KanbanCardTemplate__C>();
        set<string> templateSet = new set<string>();
        List<leankor__KanbanCardTemplate__C> cloneTemplates = new List<leankor__KanbanCardTemplate__C>();
        for (leankor__KanbanCardTemplate__C t : tBTemplates) { 
            templateSet.add(T.Name); 
            newtemplateIDs.put(T.Name,T.Id);
        }
        for(leankor__KanbanCardTemplate__C kct : sBTemplates){
            if(!templateSet.contains(kct.Name)){
                templateIDs.put(kct.Id,kct.Name);
                templateSet.add(kct.Name);
                cloneTemplates.add(assignTemplateData(kct, requests[0].TargetBoardId));
            }else{
                String newID=newtemplateIDs.get(kct.Name);
                if(newID == null){
                    kCTleft.add(kct);
                }
                templateIDs.put(kct.Id,newID);
            }
        }
        
        try{
            DataBase.Insert(cloneTemplates, false);
        }Catch(DMLException ex){
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        for(leankor__KanbanCardTemplate__C kct : cloneTemplates){
            String tId= kct.leankor__Title__c;
            kct.leankor__Title__c = templateIDs.get(tId);
            templateIDs.put(tId,kct.Id); // Getting Old template id from new collection.
            for(leankor__KanbanCardTemplate__C log :kCTleft){
                if(log.name == kct.name){
                    templateIDs.put(log.id,kct.Id);
                }
            }
        }
        try {
            DataBase.Update(cloneTemplates, false);
        } catch(DMLException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        //------------------Template End--------------------
        //----------------KanbanCard----------------------------------
        List<Task> kanbanTaskList = new List<Task>();
        DateTime finalDate,initialDate,largestDueDateTime,minstartDateTime; 
        List<leankor__KanbanCard__c> remoteKanbanCards = new List<leankor__KanbanCard__c> ();
        
        Map<String, List<Task>> remoteKanbanCardTasksMap = new Map<String, List<Task>>();
        if (requests[0].initialDate != null ) {
            initialDate = requests[0].initialDate;
            remoteKanbanCards = readCardWithStart(new Set<String>(requests[0].SourceBoardId));
			if (remoteKanbanCards.size()<0) {
	        	return null;
            } else {			
	            // query task records and put results in a list        	
	            remoteKanbanCardTasksMap = getTask(remoteKanbanCards);			
	            			 
	            minstartDateTime = remoteKanbanCards[0].leankor__StartDateTime__c;
	        }  
        } else {
                FinalDate = requests[0].TargetDate != null ? requests[0].TargetDate : system.now();
 				remoteKanbanCards = readCardWithDue(new Set<String>(requests[0].SourceBoardId));
            if (remoteKanbanCards.size()<0) {
            	return null;
            } else {			
                // query task records and put results in a list        	
                remoteKanbanCardTasksMap = getTask(remoteKanbanCards);	 
            	largestDueDateTime = (remoteKanbanCards.size()>0 ?remoteKanbanCards[0].leankor__DueDateTime__C : system.now());
            }
        }
        
        //ss 29.03.2018
        if(remoteKanbanCards.Size() > 0){
        	//Date :23/10/19
           // List<String> newKanbanCards=new List<String>();
           List<realTimeController.Kanban> newKanbanCards = new List<realTimeController.Kanban>();
            Map<String,Decimal> mapKanbanCardDifference = new Map<String,Decimal>();
            // get all related dependency.
            List<leankor__Dependency__c> dependList = getDependency(remoteKanbanCards);   
            
            for (leankor__KanbanCard__c remoteKanban : remoteKanbanCards) {
                string sWlogcardID;
                if (remoteKanbanCardTasksMap.get(remoteKanban.Id) != null && remoteKanbanCardTasksMap.get(remoteKanban.Id).size()>0) {
                	kanbanTaskList.addAll(remoteKanbanCardTasksMap.get(remoteKanban.Id));
                }
                String tempID = templateIDs.get(remoteKanban.leankor__KanbanCardTemplate__c);
                DateTime tempDueDateTime,tempStartDateTime;
                Decimal otherDifference;
                if(initialDate != null ){
                    Integer difference = (remoteKanban.leankor__StartDateTime__C.date()).daysBetween(minstartDateTime.date()); 
                    tempStartDateTime = (difference == 0 ? initialDate : initialDate - difference); 
                    Decimal tempEstimation = remoteKanban.leankor__EstimatedDuration__c;
                    tempEstimation = ((Date.valueOf(remoteKanban.leankor__DueDateTime__C)).daysBetween(Date.valueOf(tempStartDateTime))) - tempEstimation; 
                    tempDueDateTime = (tempEstimation < 0 ? ((DateTime.ValueOf(tempStartDateTime)) - tempEstimation) : remoteKanban.leankor__DueDateTime__C);  
                    otherDifference = ((remoteKanban.leankor__StartDateTime__C.date()).daysBetween(tempstartDateTime.date()));
                    if(remoteKanban.leankor__startDateTime__C < tempstartDateTime){
                        tempDueDateTime = remoteKanban.leankor__DueDateTime__C + math.abs(otherDifference) ;
                    }else{ 
                        tempDueDateTime = remoteKanban.leankor__DueDateTime__C -  math.abs(otherDifference) ;//remoteKanban.DueDate - remoteKanban.EstimatedDuration;
                    }
                }else{
                    Integer difference = (remoteKanban.leankor__DueDateTime__C.date()).daysBetween(largestDueDateTime.date()); 
                    tempDueDateTime = (difference == 0 ? FinalDate : FinalDate - difference); 
                    Decimal tempEstimation = remoteKanban.leankor__EstimatedDuration__c;
                    tempEstimation = ((Date.valueOf(remoteKanban.leankor__StartDateTime__C)).daysBetween(Date.valueOf(tempDueDateTime))) - tempEstimation; 
                    tempStartDateTime = (tempEstimation < 0 ? ((DateTime.ValueOf(tempDueDateTime)) + tempEstimation) : remoteKanban.leankor__StartDateTime__C);
                    otherDifference = ((remoteKanban.leankor__DueDateTime__C.date()).daysBetween(tempDueDateTime.date()));
                    if(remoteKanban.leankor__DueDateTime__C < tempDueDateTime){
                        tempStartDateTime = remoteKanban.leankor__StartDateTime__C + math.abs(otherDifference) ;
                    }else{ 
                        tempStartDateTime = remoteKanban.leankor__StartDateTime__C -  math.abs(otherDifference) ;//remoteKanban.DueDate - remoteKanban.EstimatedDuration;
                    }
                }
                mapKanbanCardDifference.put(remoteKanban.Id,otherDifference);
                leankor.RealTimeController.Kanban newKanban = new leankor.RealTimeController.Kanban();
                Integer randm = Math.round(Math.random()*10000);
                if(remoteKanban.leankor__Valuestream__r.leankor__PointPicklist__c != null){
                    List<Integer> listPoint = (List<Integer>)JSON.Deserialize(remoteKanban.leankor__Valuestream__r.leankor__PointPicklist__c, List<integer>.class);
                    newKanban.point = (listPoint.size() <= 0 ? 1: listPoint[0]);
                }
                newKanban.OwnerId=remoteKanban.OwnerId;
                newKanban.EffortRemaining = remoteKanban.leankor__EffortRemaining__c;
                newKanban.cardID =remoteKanban.leankor__CardID__c;
                newKanban.AcceptanceCriteria = remoteKanban.leankor__AcceptanceCriteria__c;
                newKanban.UrlLink =remoteKanban.leankor__UrlLink__c;
                newKanban.GUID = remoteKanban.Id+'-'+randm+'-sl00';
                newKanban.Title= remoteKanban.leankor__Title__c;
                newKanban.Name = remoteKanban.Name;
                newKanban.Bottom = remoteKanban.leankor__Bottom__c;
                newKanban.Width = remoteKanban.leankor__Width__c;
                newKanban.Height = remoteKanban.leankor__Height__c;
                if(Btype=='Kanban Board'){
                    newKanban.X = remoteKanban.leankor__X__c;
                    newKanban.Y = remoteKanban.leankor__Y__c;
                    newKanban.Top = remoteKanban.leankor__Top__c;
                    newKanban.Left = remoteKanban.leankor__Left__c;
                }else{
                    newKanban.X = 100;
                    newKanban.Y = 100;
                    newKanban.Top = 2100;
                    newKanban.Left = 2100;              
                }
                newKanban.ValueStream = targetBoard.ID;
                newKanban.TemplateID = tempID;
                newKanban.EstimatedDuration = remoteKanban.leankor__EstimatedDuration__c;
                newKanban.OnBudget = (remoteKanban.leankor__OnBudget__C == null ? 'Green' : remoteKanban.leankor__OnBudget__C);
                newKanban.OnQuality = (remoteKanban.leankor__OnQuality__C == null ? 'Green' : remoteKanban.leankor__OnQuality__C);
                newKanban.OnTime = (remoteKanban.leankor__OnTime__C == null ? 'Green' : remoteKanban.leankor__OnTime__C);
                newKanban.Color = remoteKanban.leankor__Color__c;  // EjB7: added color and JSONDefinition
                newKanban.JSONDefinition = remoteKanban.leankor__JSONDefinition__c;
                newKanban.JSONData = remoteKanban.leankor__JSONData__c;
                newKanban.DueDate = Datetime.newInstance(tempDueDateTime.year(),tempDueDateTime.month(), tempDueDateTime.day(),remoteKanban.leankor__DueDateTime__C.hour(),remoteKanban.leankor__DueDateTime__C.minute(),remoteKanban.leankor__DueDateTime__C.second());//tempDueDateTime; 
                newKanban.DurationUnits = remoteKanban.leankor__DurationUnits__c;  // EjB11: added duration units picklist string
                newKanban.Priority = Integer.ValueOF(remoteKanban.leankor__Priority__c); //EjB14: added priority
                newKanban.HarveyBall = String.ValueOF(remoteKanban.leankor__PercentComplete2__c);//field for Harvay Ball in percentage 
                newKanban.Order = newKCOrder;
                newKCOrder = newKCOrder+1; //(remoteKanban.leankor__Order__C == null ? 0 : Integer.ValueOF(remoteKanban.leankor__Order__c));
                newKanban.DateColor = remoteKanban.leankor__DateColor__c; //field for foreground color of Date value  
                newKanban.Description = remoteKanban.leankor__DescriptionLong__c;
                //newKanban.ValueStreamCardLink =  (linkCloneVSID == '' ? remoteKanban.leankor__ValueStreamCardLink__c : (linkCloneKanbanCardID == '' ? null : linkCloneKanbanCardID));  //remoteKanban.leankor__ValueStreamCardLink__c;
                newKanban.ValueStreamLinkID = (remoteKanban.leankor__ValueStreamLink__c== null ? (linkCloneVSID == '' ? remoteKanban.leankor__ValueStreamLink__c : linkCloneVSID) :remoteKanban.leankor__ValueStreamLink__c);//remoteKanban.leankor__ValueStreamLink__c ;
                newKanban.ValueStreamCardLink = (remoteKanban.leankor__ValueStreamCardLink__c== null ? (linkCloneVSID == '' ? remoteKanban.leankor__ValueStreamCardLink__c : (linkCloneKanbanCardID == '' ? null : linkCloneKanbanCardID)):remoteKanban.leankor__ValueStreamCardLink__c); 
                //newKanban.ValueStreamLinkID = (linkCloneVSID == '' ? remoteKanban.leankor__ValueStreamLink__c : linkCloneVSID);//remoteKanban.leankor__ValueStreamLink__c ; 
                newKanban.Account = remoteKanban.leankor__Account__c;
                newKanban.Contact = remoteKanban.leankor__Contact__c;
                newKanban.CaseID = remoteKanban.leankor__Case__c;
                newKanban.StartDate = Datetime.newInstance(tempStartDateTime.year(),tempStartDateTime.month(), tempStartDateTime.day(),remoteKanban.leankor__StartDateTime__C.hour(),remoteKanban.leankor__StartDateTime__C.minute(),remoteKanban.leankor__StartDateTime__C.second());//tempStartDateTime; 
                newKanban.Opportunity = remoteKanban.leankor__Opportunity__C;
                if(requests[0].WithMC){
                    if(newSWGUIDmap.containskey(sWIDs.get(remoteKanban.leankor__Swimlane__c))){
                        sWlogcardID = newSWGUIDmap.get(sWIDs.get(remoteKanban.leankor__Swimlane__c));
                    }else{
                        sWlogcardID = sWIDs.get(remoteKanban.leankor__Swimlane__c);
                    }                 
                    newKanban.ZoneID = (zoneGUIIDs.get(remoteKanban.leankor__ZoneGUID__c)!=null)?zoneGUIIDs.get(remoteKanban.leankor__ZoneGUID__c):'';
                    newKanban.MCForceID =(mCIDs.get(remoteKanban.leankor__MasterContainer__c)!=null)?mCIDs.get(remoteKanban.leankor__MasterContainer__c):'';
                    newKanban.SWForceID = (sWlogcardID != null ? sWlogcardID : '');//(sWIDs.get(remoteKanban.leankor__Swimlane__c)!=null) ?sWIDs.get(remoteKanban.leankor__Swimlane__c):'';
                    newKanban.ZoneForceID =(zoneIDs.get(remoteKanban.leankor__Zone__c)!=null) ?zoneIDs.get(remoteKanban.leankor__Zone__c):'';
                }else{
                    newKanban.ZoneID = lM_Zone;
                    newKanban.MCForceID =left_MC;
                    newKanban.SWForceID =left_most_SW;
                    newKanban.ZoneForceID =lM_zoneID;
                }
                Integer eD =  integer.valueof(newKanban.EstimatedDuration);
                if(newKanban.DurationUnits == 'Hours'){
                    Decimal tempED= ED/8;
                    if(tempED > Integer.valueof(ED/8)){
                        ED= Integer.valueof(ED/8) + 1;
                    }else{
                        ED= Integer.valueof(ED/8);
                    }
                }else if(newKanban.DurationUnits == 'Years'){
                    ED= Integer.valueof(ED*365);
                }else if(newKanban.DurationUnits == 'Months'){
                    ED= Integer.valueof(ED*30);
                }else if(newKanban.DurationUnits == 'Minutes'){
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
                }else if(newKanban.DurationUnits == 'Weeks'){
                    ED= Integer.valueof(ED*5);
                } 
                //Get non working days of week
				Map<String, Integer> mapNonWorkingDays= workWeek.readNonWorkingDays();
				if(!TBisweekendboard && (initialDate == null)){
                    datetime tempcalstartdate = newKanban.DueDate;
                    if(newKanban.DurationUnits == 'Years'){
                        tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(newKanban.EstimatedDuration));
                    	tempcalstartdate = tempcalstartdate +1 ;
                    }else if(newKanban.DurationUnits == 'Months'){
                        tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(newKanban.EstimatedDuration));
                    	tempcalstartdate = tempcalstartdate +1 ;
                    }else{
	                    for(integer i = 1 ;i< ED;i++ ){
	                        tempcalstartdate = tempcalstartdate-1;
	                        //Calculate WorkingWeekDays escaping non working day according to first day of week
							tempcalstartdate = Util.readPreviousWorkingDateTime(workWeek,tempcalstartdate);
	                    }
	                }
                    //Check DueDate is not in working days and in non working day it is 1st or 2nd
					if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(newKanban.DueDate.format('EEEE')) == 1)){
						newKanban.DueDate = newKanban.DueDate - 1;
                        tempcalstartdate = tempcalstartdate - 1;
					}else if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(newKanban.DueDate.format('EEEE')) == 2)){
						newKanban.DueDate = newKanban.DueDate - 2;
                        if(ED==1){
                            tempcalstartdate = tempcalstartdate + 2;
                        }else{
                            tempcalstartdate = tempcalstartdate - 1;
                        }
					}
                    //Calculate WorkingWeekDays escaping non working day according to first day of week
					tempcalstartdate = Util.readPreviousWorkingDateTime(workWeek,tempcalstartdate);
                    newKanban.StartDate = tempcalstartdate;         
                }else if(!TBisweekendboard && (initialDate != null)){
                    datetime tempcalduedate = newKanban.StartDate;
                    if(newKanban.DurationUnits == 'Years'){
                        tempcalduedate = tempcalduedate.addYears(integer.valueof(newKanban.EstimatedDuration));
                    	tempcalduedate = tempcalduedate -1 ;
                    }else if(newKanban.DurationUnits == 'Months'){
                        tempcalduedate = tempcalduedate.addMonths(integer.valueof(newKanban.EstimatedDuration));
                    	tempcalduedate = tempcalduedate -1 ;
                    }else{
	                    for(integer i = 1 ;i<ED;i++ ){
	                        tempcalduedate = tempcalduedate+1;
	                        //Calculate WorkingWeekDays escaping non working day according to first day of week
							tempcalduedate = Util.readNextWorkingDateTime(workWeek,tempcalduedate);
	                    }
	                }
                    //ss 04.05.2018
                    //Check DueDate is not in working days and in non working day it is 1st or 2nd
					if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(newKanban.StartDate.format('EEEE')) == 1)){
						newKanban.StartDate = newKanban.StartDate + 2;
                        if(ED==1){
                            tempcalduedate = tempcalduedate + 2;
                        }else{
                            tempcalduedate = tempcalduedate + 1;
                    }
					}else if(!mapNonWorkingDays.isEmpty() && (mapNonWorkingDays.get(newKanban.StartDate.format('EEEE')) == 2)){
						newKanban.StartDate = newKanban.StartDate + 1;
                        tempcalduedate = tempcalduedate + 1;
					}
                    //Calculate WorkingWeekDays escaping non working day according to first day of week
					tempcalduedate = Util.readNextWorkingDateTime(workWeek,tempcalduedate);
                    newKanban.DueDate = tempcalduedate;                         
                }else{
                    if(newKanban.DurationUnits == 'Weeks'){
                        ED= Integer.valueof(newKanban.EstimatedDuration*7);
                    }
                    if(initialDate != null){
                        datetime tempcalduedate = newKanban.StartDate;
                        if(newKanban.DurationUnits == 'Years'){
                            tempcalduedate = tempcalduedate.addYears(integer.valueof(newKanban.EstimatedDuration));
                        	tempcalduedate = tempcalduedate -1 ;
                        }else if(newKanban.DurationUnits == 'Months'){
                            tempcalduedate = tempcalduedate.addMonths(integer.valueof(newKanban.EstimatedDuration));
                        	tempcalduedate = tempcalduedate -1 ;
                        }else{
	                        for(integer i = 1 ;i<ED;i++ ){
	                            tempcalduedate = tempcalduedate+1;
	                        }
                        }
                        newKanban.DueDate = tempcalduedate;
                    }else{
                        datetime tempcalstartdate = newKanban.DueDate; 
                        if(newKanban.DurationUnits == 'Years'){
                            tempcalstartdate = tempcalstartdate.addYears(-integer.valueof(newKanban.EstimatedDuration));
                        	tempcalstartdate = tempcalstartdate +1 ;
                        }else if(newKanban.DurationUnits == 'Months'){
                            tempcalstartdate = tempcalstartdate.addMonths(-integer.valueof(newKanban.EstimatedDuration));
                        	tempcalstartdate = tempcalstartdate +1 ;
                        }else{ 
	                        for(integer i = 1 ;i<ED;i++ ){
	                            tempcalstartdate = tempcalstartdate-1;
	                        }
                        }
                        newKanban.StartDate = tempcalstartdate;
                    }
                } 
              // Date : 23/10/19 using wrapper class instance instead of Serialization.
               // newKanbanCards.add(JSON.Serialize(newKanban));  
               //RS 28/11/2019 Added Owner.IsActive in object
    			newKanban.ownerIsActive = remoteKanban.Owner.IsActive;  
                newKanbanCards.add(newKanban);   
            }
            try{
            	// Date : 23/10/19 using wrapper class instance instead of Serialization.
                //mergeKanbancards = leankor.realTimeController.createKanbanCard(targetBoard.ID,newKanbanCards);
                mergeKanbancards = leankor.realTimeController.createKanbanCards(targetBoard.ID,newKanbanCards);
            }catch(Exception ex){
                    throw new Util.LeanException('ERROR:' + ex.getMessage());
            }         
            Map<String,String> mapKanbanCard = MultipleMergeProjectBoardAction.cloneDependency(targetBoard.Id, dependList);
            Map<String,String> oldNewTask = MultipleMergeProjectBoardAction.cloneTask(kanbanTaskList, workWeek, mapKanbanCard, initialDate, mapKanbanCardDifference, TBisweekendboard);
            cloneIssueLog(remoteKanbanCards, mapKanbanCard, mapKanbanCardDifference, oldNewTask);
            cloneTimeCard(remoteKanbanCards, mapKanbanCard, mapKanbanCardDifference, oldNewTask); 
            cloneStickers(requests[0].SourceBoardId, requests[0].TargetBoardId, mapKanbanCard, remoteKanbanCards);  
            String someJSONData = '{"ValueStreamOwnerName" : "'+vSOwnerID+'","ValueStreamID" :"'+ requests[0].TargetBoardId+'","flowWithGS" : true}';
            try{
                leankor.RealTimeController.KanbanStateChange(requests[0].TargetBoardId, 'UpdateRuntimeBoard', UserInfo.getSessionId(), someJSONData);
            } catch (Exception e){
                throw new Util.LeanException('ERROR:' + e.getMessage());
            }
        }
        MultipleMergeProjectBoardActionResult rstKanbancards = new MultipleMergeProjectBoardActionResult();
        List<leankor__KanbanCard__c>  records = new List<leankor__KanbanCard__c> (); 
        try{
            records = [Select leankor__Account__c,
                                leankor__AcceptanceCriteria__c,
                                leankor__CardID__c,
                                leankor__Color__c,
                                leankor__Contact__c,
                                leankor__DescriptionLong__c,
                                leankor__Description__c,
                                leankor__DueDateTime__c,
                                leankor__DurationUnits__c,
                                leankor__EffortRemaining__c,
                                leankor__EstimatedDuration__c,
                                leankor__KanbanCardTemplate__c,
                                leankor__KanbanCardTemplate__r.Name,leankor__Left__c,leankor__MasterContainer__c,
                                leankor__MasterContainer__r.Name,leankor__OnBudget__c,leankor__OnQuality__c,leankor__OnTime__c,
                                leankor__Opportunity__c,leankor__PercentComplete2__c,leankor__Point__c,leankor__Priority__c,
                                leankor__StartDateTime__c,leankor__Swimlane__c,leankor__Swimlane__r.Name,leankor__Title__c,
                                leankor__UrlLink__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,
                                leankor__ValueStream__r.Name,leankor__Zone__c,leankor__Zone__r.Name,Name,OwnerId  
                            From leankor__KanbanCard__c Where Id In :mergeKanbancards 
                            Limit 9999];
        } catch (Exception e){
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        //START---------------------------- set defult link--------------------
        if(!string.isBlank(requests[0].LinkBoardId) && !String.isBlank(requests[0].LinkKanbanCardId)){
	        List<leankor.RealTimeController.DirectLinkCardLog> defaultLinks = new List<leankor.RealTimeController.DirectLinkCardLog>();
			leankor.RealTimeController.DirectLinkCardLog defaultLog = new leankor.RealTimeController.DirectLinkCardLog();
				DefaultLog.ValueStreamId = requests[0].TargetBoardId;
				DefaultLog.LinkRoomId = targetBoard.leankor__projectroom__c;
				DefaultLog.LinkValueStreamId = requests[0].LinkBoardId;
				DefaultLog.LinkKanbanCardId = requests[0].LinkKanbanCardId;
				DefaultLog.OldLinkKanbanCardId = targetBoard.leankor__ValueStreamCardLink__c;
				DefaultLog.OldLinkValueStreamId = targetBoard.leankor__ValueStreamLink__c; 
				DefaultLog.MySessionId = UserInfo.getSessionId();
			DefaultLinks.add(DefaultLog);	
			String setdefault = leankor.RealTimeController.UpdateDefaultLink(DefaultLinks);
        }
		//END ----- set defult link---------------------------
        rstKanbancards.KanbanCardIds.addall(records);
        newrstKanbancards.add(rstKanbancards);
        return newrstKanbancards;
    }
    
    public static List<leankor__KanbanCard__c> readCardWithStart(Set<String> boardIds) {
        return [Select Id,
                        leankor__EffortRemaining__c,
                        leankor__OnBudget__C,
                        leankor__OnQuality__C,
                        leankor__OnTime__C,
                        leankor__AcceptanceCriteria__c,
                        leankor__CardID__c,
                        leankor__Valuestream__r.leankor__PointPicklist__c,
                        leankor__Point__c,
                        leankor__MasterContainer__c,
                        leankor__Swimlane__c,
                        leankor__Zone__c,
                        leankor__UrlLink__c,
                        leankor__Account__c,
                        leankor__ActualDuration__c,
                        leankor__Actual_Time_Taken__c,
                        leankor__Bottom__c,
                        leankor__Budgeted_Time__c,
                        leankor__Case__c,
                        leankor__CmpID__c,
                        leankor__Color__c,
                        leankor__CompletionVariance__c,
                        leankor__Contact__c,
                        leankor__CSSLayout__c,
                        leankor__DateColor__c,
                        leankor__DescriptionLong__c,
                        leankor__Description__c,
                        leankor__DueDate__c,
                        leankor__DurationUnits__c,
                        leankor__EstimatedDuration__c,
                        leankor__GUID__c,
                        leankor__HarveyBallDoneDate__c,
                        leankor__Height__c,
                        leankor__IsCompletedOnTime__c,
                        leankor__JSONData__c,
                        leankor__JSONDefinition__c,
                        leankor__KanbanCardTemplate__c,
                        leankor__Left__c,
                        leankor__Opportunity__c,
                        leankor__Order__c,
                        leankor__PercentComplete2__c,
                        leankor__Priority__c,
                        leankor__PromiseCompletionDate__c,
                        leankor__StartDate__c,
                        leankor__State__c,
                        leankor__Title__c,
                        leankor__Top__c,
                        leankor__ValueStreamCardLink__c,
                        leankor__ValueStreamLink__c,
                        leankor__ValueStream__c,
                        leankor__Width__c,
                        leankor__X__c,
                        leankor__Y__c,
                        leankor__ZoneGUID__c,
                        Name,
                        OwnerId,
                        leankor__StartDateTime__C,
                        leankor__DueDateTime__c,
                        Owner.IsActive 
                    From leankor__KanbanCard__c 
                    Where leankor__ValueStream__c In :boardIds 
                    With Security_Enforced
                    Order By leankor__StartDateTime__c Asc Nulls First 
                    Limit 9999];

    }

    public static List<leankor__KanbanCard__c> readCardWithDue(Set<String> boardIds) {
        return [Select Id,
                        leankor__EffortRemaining__c,
                        leankor__OnBudget__C,
                        leankor__OnQuality__C,
                        leankor__OnTime__C,
                        leankor__AcceptanceCriteria__c,
                        leankor__CardID__c,
                        leankor__Valuestream__r.leankor__PointPicklist__c,
                        leankor__Point__c,
                        leankor__MasterContainer__c,
                        leankor__Swimlane__c,
                        leankor__Zone__c,
                        leankor__UrlLink__c,
                        leankor__Account__c,
                        leankor__ActualDuration__c,
                        leankor__Actual_Time_Taken__c,
                        leankor__Bottom__c,
                        leankor__Budgeted_Time__c,
                        leankor__Case__c,
                        leankor__CmpID__c,
                        leankor__Color__c,
                        leankor__CompletionVariance__c,
                        leankor__Contact__c,
                        leankor__CSSLayout__c,
                        leankor__DateColor__c,
                        leankor__DescriptionLong__c,
                        leankor__Description__c,
                        leankor__DueDate__c,
                        leankor__DurationUnits__c,
                        leankor__EstimatedDuration__c,
                        leankor__GUID__c,
                        leankor__HarveyBallDoneDate__c,
                        leankor__Height__c,
                        leankor__IsCompletedOnTime__c,
                        leankor__JSONData__c,
                        leankor__JSONDefinition__c,
                        leankor__KanbanCardTemplate__c,
                        leankor__Left__c,
                        leankor__Opportunity__c,
                        leankor__Order__c,
                        leankor__PercentComplete2__c,
                        leankor__Priority__c,
                        leankor__PromiseCompletionDate__c,
                        leankor__StartDate__c,
                        leankor__State__c,
                        leankor__Title__c,
                        leankor__Top__c,
                        leankor__ValueStreamCardLink__c,
                        leankor__ValueStreamLink__c,
                        leankor__ValueStream__c,
                        leankor__Width__c,
                        leankor__X__c,
                        leankor__Y__c,
                        leankor__ZoneGUID__c,
                        Name,
                        OwnerId,
                        leankor__StartDateTime__C,
                        leankor__DueDateTime__c,
                        Owner.IsActive 
                    From leankor__KanbanCard__c 
                    Where leankor__ValueStream__c In :boardIds
                    With Security_Enforced 
                    Order By leankor__DueDateTime__c Desc Nulls First 
                    Limit 9999];
    }

    public static Map<String, List<Task>> getTask(List<leankor__KanbanCard__c> cards) {
        Map<String, List<Task>> cardTasksMap = new Map<String, List<Task>>();
        for(Task task : [Select 
                                ActivityDate,
                                Description,
                                Id,
                                OwnerId,
                                Priority,
                                Status,
                                Subject,
                                WhatId,
                                Owner.IsActive 
                            From Task 
                            Where What.Type = 'leankor__KanbanCard__c' 
                                And IsDeleted = false 
                                And WhatId In :cards
                            Limit 9999
                            All Rows]) {
	        List<Task> taskList = cardTasksMap.containsKey(task.WhatId) ? cardTasksMap.get(task.WhatId) :  new List<Task>();
            taskList.add(task);
	        cardTasksMap.put(task.WhatId, taskList);		
	    }
        return cardTasksMap;
    }

    public static List<leankor__Dependency__c> getDependency(List<leankor__KanbanCard__c> cards) {
        return [Select Id,
                        leankor__LagLead__c,
                        leankor__LagLeadUnit__c,
                        leankor__GUID__c,
                        leankor__ValueStream__c,
                        leankor__KanbanCard__C,
                        leankor__Predecessor__c,
                        leankor__Predecessor__r.leankor__ValueStream__c,
                        leankor__PredecessorType__c,
                        leankor__Successor__c,
                        leankor__Successor__r.leankor__ValueStream__c,
                        leankor__SuccessorType__c 
                    From leankor__Dependency__c 
                    Where leankor__Predecessor__c In :cards 
                        OR leankor__Successor__c In :cards 
                    With Security_Enforced 
                    Limit 9999]; 

    }
    
    public static List<leankor__Zone__c> getZone(String leftMostSW, String boardId) {
        return [Select Id,
                        leankor__GUID__c 
                    From leankor__Zone__c 
                    Where leankor__Swimlane__c = :leftMostSW  
                        And leankor__ValueStream__c = :boardId 
                    With Security_Enforced
                    Order By leankor__Order__c Asc Nulls Last 
                    Limit 1];
    }

    public static List<leankor__Swimlane__c> getSwimlane(String leftMC, String boardId) {
        return [Select Id
                    From leankor__Swimlane__c 
                    Where leankor__MasterContainer__c = :leftMC 
                        And leankor__ValueStream__c = :boardId 
                    With Security_Enforced    
                    Order By leankor__Order__c Desc Nulls Last 
                    Limit 1];
    }

    public static List<leankor__MasterContainer__c> getMasterContainerData(Set<String> boardIds) {
        return [Select Id,
                        Name,
                        leankor__Color__c, 
                        leankor__Unit__c,
                        leankor__CmpID__c,
                        leankor__GUID__c,
                        leankor__Height__c,
                        leankor__IsCardAvailable__c,
                        leankor__Left__c,
                        leankor__Limit__c,
                        leankor__Order__c,
                        leankor__Title__c,
                        leankor__Top__c,
                        leankor__Type__C,
                        leankor__ValueStream__c,
                        leankor__Width__c 
                    From leankor__MasterContainer__c 
                    Where leankor__ValueStream__c In :boardIds 
                    With Security_Enforced
                    Order By leankor__Order__c Asc Nulls Last 
                    Limit 9999];
    }

    public static List<leankor__KanbanCardTemplate__c> getTemplateData(Set<String> boardIds) {
        return [Select Id,
                        leankor__AssetID__c,
                        leankor__Color__c,
                        leankor__CSSLayout__c,
                        leankor__DerivedFrom__c,
                        leankor__Height__c,
                        leankor__JSONData__c,
                        leankor__JSONDefinition__c,
                        leankor__Title__c,
                        leankor__ValueStream__c,
                        leankor__Width__c,
                        Name,
                        OwnerId 
                    From leankor__KanbanCardTemplate__c 
                    Where leankor__ValueStream__c In :boardIds 
                    With Security_Enforced 
                    Limit 9999];
    }

    public static List<leankor__MasterContainer__c> finalMContainer(Set<String> boardIds) {
        return  [Select Id, 
                        leankor__Height__c, 
                        leankor__Width__c, 
                        leankor__ValueStream__c 
                    From leankor__MasterContainer__c 
                    Where leankor__ValueStream__c In :boardIds 
                    With Security_Enforced
                    Limit 9999]; 
    }

    public static List<leankor__Swimlane__c> finalSwimlane(Set<String> boardIds) {
        return [Select Id,
                        leankor__CardPerRow__c,
                        leankor__Height__c, 
                        leankor__Width__c, 
                        leankor__MasterContainer__c,
                        leankor__ValueStream__c 
                    From leankor__Swimlane__c 
                    Where leankor__ValueStream__c In :boardIds 
                    With Security_Enforced
                    Limit 9999];
    }
    public static List<leankor__Zone__c> finalZone(Set<String> boardIds) {
        return [Select Id,
                        leankor__CardsPerRow__c,
                        leankor__Height__c, 
                        leankor__Width__c, 
                        leankor__Swimlane__c,
                        leankor__ValueStream__c 
                    From leankor__Zone__c 
                    Where leankor__ValueStream__c In :boardIds 
                    With Security_Enforced
                    Limit 9999];
    }

    public static Map<String,String> cloneDependency(String boardId, List<leankor__Dependency__c> dependencies) {
        Map<String,String> mapKanbanCard = new Map<String,String>();
        List<leankor__Dependency__c> dependencyList = new List<leankor__Dependency__c>();  
        for (leankor__KanbanCard__c kanban : [Select Id,
                                                    leankor__GUID__c 
                                                From leankor__KanbanCard__c 
                                                Where leankor__ValueStream__c = :boardId
                                                With Security_Enforced 
                                                Limit 9999]) { 
            String oldKanbanId = (kanban.leankor__GUID__c).SubStringBefore('-');  
            mapKanbanCard.put(oldKanbanId, kanban.Id);
        }
        if (!dependencies.isEmpty()) {
            for (leankor__Dependency__c dependency : dependencies) {
                if ((mapKanbanCard.containsKey(dependency.leankor__Successor__c)) || (mapKanbanCard.containsKey(dependency.leankor__Predecessor__c))) {
                    leankor__Dependency__c d = new leankor__Dependency__c(
                    leankor__GUID__c = dependency.Id+'-'+System.Now().getTime()+'-d', // Need to make dynamic GUID.
                    leankor__ValueStream__c = (boardId == dependency.leankor__ValueStream__c ? boardId : dependency.leankor__ValueStream__c),
                    leankor__Predecessor__c =  (mapKanbanCard.containsKey(dependency.leankor__Predecessor__c) ? mapKanbanCard.get(dependency.leankor__Predecessor__c) : dependency.leankor__Predecessor__c),
                    leankor__Successor__c = (mapKanbanCard.containsKey(dependency.leankor__Successor__c) ? mapKanbanCard.get(dependency.leankor__Successor__c) : dependency.leankor__Successor__c),
                    leankor__SuccessorType__c = dependency.leankor__SuccessorType__c,
                    leankor__LagLead__c = dependency.leankor__LagLead__c,
                    leankor__LagLeadUnit__c = dependency.leankor__LagLeadUnit__c);
                    dependencyList.add(d);
                }
            }
            try {
                Database.insert(dependencyList,false);
            } catch (DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }
        return mapKanbanCard;
    }

    public static Map<String,String> cloneTask(List<Task> tasks, Util.WorkWeek workWeek, Map<String,String> mapKanbanCard, DateTime initialDate, Map<String,Decimal> cardDifference, Boolean isSeven) {
        Map<String,String> oldNewTask = new Map<String,String>();
        Map<String,Integer> mapKanbanCardTask = new Map<String,Integer>();
        if (!tasks.isEmpty()) {
            List<Task> taskList = new List<Task>();
            for (Task temp : tasks) {
                if (mapKanbanCard.containsKey(temp.WhatID) == true) {
                    Task task = new Task();
                    task.Priority = temp.Priority;
                    task.OwnerID = temp.OwnerID;
                    task.Subject = temp.id;
                    task.Status = temp.Status;
                    task.ActivityDate = (Date.valueOf(temp.ActivityDate)+(Integer.ValueOf(cardDifference.get(temp.WhatId))));
                    datetime TskDuedate = Datetime.newInstance(task.ActivityDate.year(),task.ActivityDate.month(), task.ActivityDate.day(), 0, 0, 0);
                    if (!isSeven) {
                        //Get Working days escaping non working days for Task
                        if (initialDate != null) {
                            task.ActivityDate = Util.readNextWorkingDate(workWeek,TskDuedate,task.ActivityDate);
                        } else if (initialDate == null) {
                            task.ActivityDate = Util.readPreviousWorkingDate(workWeek,TskDuedate,task.ActivityDate);
                        }
                    }
                    task.WhatID = mapKanbanCard.get(temp.WhatID);
                    task.Description = (temp.Description == null ? '' : temp.Description);
                    taskList.add(task);
                    oldNewTask.put(temp.Id,temp.Subject);
                    if (!mapKanbanCardTask.containsKey(mapKanbanCard.get(temp.WhatID))) {
                        mapKanbanCardTask.put(mapKanbanCard.get(temp.WhatID), 1);
                    } else {
                        integer cnt = mapKanbanCardTask.get(mapKanbanCard.get(temp.WhatID));
                        cnt = cnt+1;                    
                        mapKanbanCardTask.put(mapKanbanCard.get(temp.WhatID), cnt);                    
                    }                                          
                }                    
            }
            try {
                Database.insert(taskList, true);
            } catch (DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            List<FeedItem> feeds = new List<FeedItem>();
            for (Task tsk : taskList) {
                FeedItem post = new FeedItem();
                post.ParentID = tsk.Id;
                post.Type = 'CreateRecordEvent';
                feeds.add(post);
                
                String oldtaskid = tsk.Subject;
                tsk.Subject = oldNewTask.get(tsk.Subject);
                oldNewTask.put(oldtaskid,tsk.id);                    
            }
            try {
                leankor.OpenTaskRestriction.updateTask(taskList);
                insert feeds;
            } catch (DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }
        return oldNewTask;
    }

    public static void cloneIssueLog(List<leankor__KanbanCard__c> cards, Map<String,String> cardMap, Map<String,Decimal> cardDiff, Map<String,String> oldNewTask) {
        List<leankor__IssueLog__c> logs = [Select Id,
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
                                                From leankor__IssueLog__c 
                                                Where leankor__KanbanCard__c In :cards
                                                With Security_Enforced 
                                                Limit 49999];
   
        List<leankor__IssueLog__c> issueLogList = new List<leankor__IssueLog__c>();
        if (!logs.isEmpty()) {
            for (leankor__IssueLog__c log : logs) {
                leankor__IssueLog__c issueLog = new leankor__IssueLog__c(
                    Name = log.Name,
                    leankor__Detail__c = log.leankor__Detail__c,
                    leankor__KanbanCard__c = cardMap.get(log.leankor__KanbanCard__c) ,
                    leankor__LogTime__c = (Date.valueOf(log.leankor__LogTime__c)+(Integer.ValueOf(cardDiff.get(log.leankor__KanbanCard__c)))),
                    leankor__Probability__C = log.leankor__Probability__c,
                    leankor__StatusType__c= log.leankor__StatusType__c,
                    leankor__Task__c = oldNewTask.get(log.leankor__Task__c),
                    leankor__Weight__c = log.leankor__Weight__c,
                    leankor__Resolved__c = log.leankor__Resolved__c,
                    leankor__ResolvedTime__c = log.leankor__ResolvedTime__c,
                    leankor__Score__c = log.leankor__Score__c,
                    leankor__TaskDueDate__c = (Date.valueOf(log.leankor__TaskDueDate__c)+(Integer.ValueOf(cardDiff.get(log.leankor__KanbanCard__c)))),
                    leankor__AssignedTo__c = log.leankor__AssignedTo__c,
                    leankor__RiskMitigation__c = log.leankor__RiskMitigation__c
                );
                issueLogList.add(issueLog);
            }
            try {
                DataBase.Insert(issueLogList, true);
            } catch (DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());        
            }
        }
    }

    public static void cloneTimeCard(List<leankor__KanbanCard__c> cards, Map<String,String> cardMap, Map<String,Decimal> cardDiff, Map<String,String> oldNewTask) {
        List<leankor__TimeCard__c> timeCards = [Select Id,
                                                        leankor__Subject__c,
                                                        leankor__Description__c,
                                                        leankor__Assign_a_User__c,
                                                        leankor__Duration__c,
                                                        leankor__Estimation__c,
                                                        leankor__Hours__c,
                                                        leankor__KanbanCard__c,
                                                        leankor__LogTime__c,
                                                        leankor__Task__c,
                                                        leankor__TaskDueDate__c,
                                                        leankor__AssignedTo__c 
                                                    From leankor__TimeCard__c 
                                                    Where leankor__KanbanCard__c In :cards 
                                                    With Security_Enforced
                                                    Limit 9999];
   
        List<leankor__TimeCard__c> timeCardList =new List<leankor__TimeCard__c>();
        for (leankor__TimeCard__c timeCard : timeCards) {
            leankor__TimeCard__c card = new leankor__TimeCard__c(
            leankor__LogTime__c  = timeCard.leankor__LogTime__c,
            leankor__Description__c  = timeCard.leankor__Description__c,
            leankor__Duration__c  = timeCard.leankor__Duration__c,
            leankor__Estimation__c = timeCard.leankor__Estimation__c,
            leankor__Subject__c = timeCard.leankor__Subject__c,
            leankor__Task__c = oldNewTask.get(timeCard.leankor__Task__c),
            leankor__Hours__c = timeCard.leankor__Hours__c,
            leankor__KanbanCard__c = cardMap.get(timeCard.leankor__KanbanCard__c),
            leankor__TaskDueDate__c =  (Date.valueOf(timeCard.leankor__TaskDueDate__c)+(Integer.ValueOf(cardDiff.get(timeCard.leankor__KanbanCard__C)))),
            leankor__AssignedTo__C =   timeCard.leankor__AssignedTo__C,
            leankor__Assign_a_User__c = timeCard.leankor__Assign_a_User__c 
            );
            timeCardList.add(card);
        }
        try {
            DataBase.insert(timeCardList, true);
        } catch (DMLException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());         
        }
    }
    
    public static List<leankor__Sticker__c> getStickers(Set<String> boardIds) {
        return [Select Id,
                        leankor__ValueStream__c,
                        Name,
                        OwnerId 
                    From leankor__Sticker__c 
                    Where leankor__ValueStream__c In :boardIds 
                        Or leankor__ValueStream__c = Null 
                    With Security_Enforced
                    Limit 9999];
    }

    public static void cloneStickers(List<String> sourceBoards, String targetBoard, Map<String,String> mapKanbanCard, List<leankor__KanbanCard__c> cards) {
        List<leankor__Sticker__c> sourceStickers = getStickers(new Set<String>(sourceBoards));
        List<leankor__Sticker__c> targetStickers = getStickers(new Set<String>{targetBoard});

        List<leankor__Sticker__c> cloneList = new List<leankor__Sticker__c>();
        List<leankor__Sticker__c> filterList = new List<leankor__Sticker__c>();
        Map<String,String> newStickerIds = new Map<String,String>();
        Set<String> stickerSet = new Set<String>(); 
        Map<String,String> stickerIds = new Map<String,String>();
        if (!targetStickers.isEmpty()) {
            for (leankor__Sticker__c tStickers : targetStickers) { 
                stickerSet.add(tStickers.Name); 
                newStickerIDs.put(tStickers.Name,tStickers.Id);
            } 
        }

        List<leankor__Sticker__c> cloneStickers = new List<leankor__Sticker__c>();
        if (!sourceStickers.isEmpty()) {
            for (leankor__Sticker__c sSticker : sourceStickers) {
                if (!stickerSet.contains(sSticker.Name)) {
                    stickerIds.put(sSticker.Id, sSticker.Name);
                    filterList.add(sSticker);
                    leankor__Sticker__c stk = new leankor__Sticker__c(
                        leankor__ValueStream__c = targetBoard, 
                        Name = sSticker.Id, 
                        OwnerId = sSticker.OwnerId
                    );
                    cloneList.add(stk);
                } else {
                    String newId = newStickerIds.get(sSticker.Name);
                    stickerIds.put(sSticker.Id, newId);
                }
            }
            try {
                DataBase.Insert(cloneList, false);
            } catch(DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            for (leankor__Sticker__c cloned : cloneList) {
                String tId = cloned.Name;
                cloned.Name = stickerIDs.get(tId);
                stickerIDs.put(tId, cloned.Id); 
            }
            try {
                DataBase.Update(cloneList, false);
            } catch(DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }

            if (!filterList.isEmpty()) {
                createAttachment(filterList, stickerIds);
            }

            if (!stickerIds.isEmpty() && !cards.isEmpty()) {
                addStickerOnCards(stickerIds, mapKanbanCard, cards);
            }
        }
    }

    public static void createAttachment(List<leankor__Sticker__c> filterList, Map<String,String> stickerIds) {
        List<Attachment> newAttchments = new List<Attachment>();
        for (Attachment[] att : [Select Body, 
                                        BodyLength, 
                                        ContentType, 
                                        Description, 
                                        Id,
                                        Name, 
                                        OwnerId, 
                                        ParentId 
                                    From Attachment 
                                    Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
                                        And ParentId In :filterList 
                                    Limit 9999]) {
            for (Integer iCount = 0; iCount < att.size(); iCount++) {					        
                Attachment newAttach = new Attachment(
                    Name = att[iCount].Name,
                    ContentType = att[iCount].ContentType,
                    ParentID = stickerIDs.get(att[iCount].ParentId),
                    Body = att[iCount].Body
                );
                newAttchments.add(newAttach);        
            }
        }		
        try {
            DataBase.Insert(newAttchments,true); 
        } catch(DMLException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
    }

    public static void addStickerOnCards(Map<String,String> stickerIds, Map<String,String> mapKanbanCard, List<leankor__KanbanCard__c> cards) {
        List<leankor__KanbanCardSticker__c> kCSList = [Select Id,
                                                            leankor__KanbanCard__c,
                                                            leankor__Sticker__c 
                                                        From leankor__KanbanCardSticker__c 
                                                        Where leankor__KanbanCard__c In :cards 
                                                        With Security_Enforced 
                                                        Limit 9999];
        List<leankor__KanbanCardSticker__c> newKCSList = new List<leankor__KanbanCardSticker__c>();
        if (!kCSList.isEmpty()) {
            for (leankor__KanbanCardSticker__c cs : kCSList ) {
                leankor__KanbanCardSticker__c kCS = new leankor__KanbanCardSticker__c(
                    leankor__KanbanCard__c = mapKanbanCard.get(cs.leankor__KanbanCard__c),
                    leankor__Sticker__c = stickerIds.get(cs.leankor__Sticker__c)    
                );  
                newKCSList.add(kCS);
            }
            try {
                DataBase.Insert(newKCSList,false); 
            } catch(DMLException ex) {
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
        }
    }

    public static void updateHeightWidth(String targetBoardId) {
        List<leankor__MasterContainer__c> finaleMC = finalMContainer(new Set<String>{targetBoardId});   
        List<leankor__Swimlane__c> finaleSW = finalSwimlane(new Set<String>{targetBoardId}); 
        List<leankor__Zone__c>  finalZone = finalZone(new Set<String>{targetBoardId});
        Map<String,integer> finaleMCmap = new Map<String,integer>();
        Map<String,integer> finaleMCZNmap = new Map<String,integer>();
        Map<String,integer> finalSWmap = new Map<String,integer>();
        for (leankor__Zone__c fZ : finalZone) {
            if (finalSWmap.containsKey(fZ.leankor__Swimlane__c)) {
                integer zcount = finalSWmap.get(fZ.leankor__Swimlane__c)+integer.valueof(fZ.leankor__CardsPerRow__c);
                finalSWmap.put(fZ.leankor__Swimlane__c,zcount);                            
            } else {
                finalSWmap.put(fZ.leankor__Swimlane__c,integer.valueof(fZ.leankor__CardsPerRow__c));
            }                  
        }
        for (leankor__Swimlane__c fSW : finaleSW) {
            integer zno = finalSWmap.get(fSW.Id);
            zno = (zno < fSW.leankor__CardPerRow__c ? integer.valueof(fSW.leankor__CardPerRow__c) : zno);
            fSW.leankor__Width__c = (209 * zno)+1;
            if (finaleMCZNmap.containsKey(fSW.leankor__MasterContainer__c)) {
                integer zcnt = finaleMCZNmap.get(fSW.leankor__MasterContainer__c);
                if (zno>zcnt) {
                    finaleMCZNmap.put(fSW.leankor__MasterContainer__c,zno);
                }                        
            } else {
                finaleMCZNmap.put(fSW.leankor__MasterContainer__c,zno);
            }
            
            if (finaleMCmap.containsKey(fSW.leankor__MasterContainer__c)) {
                integer swcount = finaleMCmap.get(fSW.leankor__MasterContainer__c)+1;//integer.valueof(fSW.leankor__CardPerRow__c);
                finaleMCmap.put(fSW.leankor__MasterContainer__c,swcount);                          
            } else {
                finaleMCmap.put(fSW.leankor__MasterContainer__c,1);//integer.valueof(fSW.leankor__CardPerRow__c));
            }                                      
        }
        List<Integer> mapValues = finaleMCmap.values();
        // Sort them, which means that the highest value comes last
        mapValues.sort();
        Integer sWno = mapvalues[mapvalues.size()-1];
        for (leankor__MasterContainer__c fMC : finaleMC) {
            Integer mZno = finaleMCZNmap.get(fMC.Id);
            fMC.leankor__Width__c = (209 * mZno)+2;
            fMC.leankor__Height__c= (320 * sWno)+32;
        }
        try {
            DataBase.Update(finaleMC, false);
            DataBase.Update(finaleSW, false);
        } catch(DMLException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }   
    }

    public static leankor__MasterContainer__c assignData(leankor__MasterContainer__c mcData, String boardId, decimal neworder) {
        leankor__MasterContainer__c mData = new leankor__MasterContainer__c(
            Name = mcData.Id, 
            leankor__Color__c = mcData.leankor__Color__c,
            leankor__Unit__c = mcData.leankor__Unit__c,
            leankor__CmpID__c = mcData.leankor__CmpID__c,
            leankor__GUID__c =mcData.Id+'-'+System.now().getTime()+'-sl00',
            leankor__Height__c = mcData.leankor__Height__c,
            leankor__IsCardAvailable__c = mcData.leankor__IsCardAvailable__c,
            leankor__Left__c = mcData.leankor__Left__c,
            leankor__Limit__c = mcData.leankor__Limit__c,
            leankor__Order__c = neworder, 
            leankor__Title__c = mcData.leankor__Title__c,
            leankor__Top__c = mcData.leankor__Top__c,
            leankor__Type__C = mcData.leankor__Type__C,
            leankor__ValueStream__c =  boardId,
            leankor__Width__c = mcData.leankor__Width__c
        ); 
        return mData;
    }

    public static leankor__Swimlane__c assignSwimlane(leankor__Swimlane__c swim, decimal newSWorder, String boardId) {
        leankor__Swimlane__c swimlane = new leankor__Swimlane__c(
            Name = swim.Id, 
            leankor__CardPerRow__c = swim.leankor__CardPerRow__c,
            leankor__CmpID__c = swim.leankor__CmpID__c,
            leankor__Unit__c = swim.leankor__Unit__c,
            leankor__Color__c = swim.leankor__Color__c,
            leankor__GUID__c = swim.Id+'-'+System.now().getTime()+'-sl00',
            leankor__Height__c = swim.leankor__Height__c,
            leankor__Help__c = swim.leankor__Help__c,
            leankor__IsCardAvailable__c = swim.leankor__IsCardAvailable__c,
            leankor__Left__c = swim.leankor__Left__c,
            leankor__Limit__c = swim.leankor__Limit__c,
            leankor__Order__c = newSWorder,
            leankor__Title__c = swim.leankor__Title__c,
            leankor__Top__c = swim.leankor__Top__c,
            leankor__ValueStream__c = boardId,
            leankor__Width__c = swim.leankor__Width__c
        );
        return swimlane;
    }

    public static leankor__Zone__c assignZone(leankor__Zone__c zone, String boardId, Integer num) {
        leankor__Zone__c newZone = new leankor__Zone__c(
            Name = zone.Id,
            leankor__UrlLink__c = zone.leankor__UrlLink__c,
            leankor__GUID__c = zone.Id+'-'+num+'-sl00',
            leankor__Title__c = zone.leankor__Title__c,
            leankor__Unit__c = zone.leankor__Unit__c,
            leankor__Top__c = zone.leankor__Top__c,
            leankor__Bottom__c = zone.leankor__Bottom__c,
            leankor__Left__c = zone.leankor__Left__c, 
            leankor__Width__c = zone.leankor__Width__c,
            leankor__Height__c = zone.leankor__Height__c,
            leankor__X__c = zone.leankor__X__c,
            leankor__OpportunityStageName__c = zone.leankor__OpportunityStageName__c,
            leankor__Y__c = zone.leankor__Y__c ,
            leankor__EntryFlowName__c = zone.leankor__EntryFlowName__c,
            leankor__ExitFlowName__c = zone.leankor__ExitFlowName__c, 
            leankor__ValueStream__c = boardId,
            leankor__zoneMode__c = zone.leankor__zoneMode__c ,
            leankor__kanbanSequence__c = zone.leankor__kanbanSequence__c, 
            leankor__ValueStreamLink__c = zone.leankor__ValueStreamLink__c,
            leankor__ValueStreamCardLink__c = zone.leankor__ValueStreamCardLink__c,
            leankor__DefaultWidth__c = zone.leankor__DefaultWidth__c, 
            leankor__DefaultHeight__c =zone.leankor__DefaultHeight__c,
            leankor__CaseStatus__c = zone.leankor__CaseStatus__c,
            leankor__CardsPerRow__c = zone.leankor__CardsPerRow__c ,
            leankor__Help__c = zone.leankor__Help__c,
            leankor__Limit__c = zone.leankor__Limit__c ,
            leankor__ParentZone__c = zone.leankor__ParentZone__c
        );
        return  newZone;
    }

    public static leankor__KanbanCardTemplate__c assignTemplateData(leankor__KanbanCardTemplate__c template, String boardId) {
        leankor__KanbanCardTemplate__c data = new leankor__KanbanCardTemplate__c(
            leankor__Color__c = template.leankor__Color__c, 
            leankor__CSSLayout__c = template.leankor__CSSLayout__c, 
            leankor__DerivedFrom__c = null,
            leankor__Height__c = template.leankor__Height__c, 
            leankor__JSONData__c = template.leankor__JSONData__c, 
            leankor__JSONDefinition__c = template.leankor__JSONDefinition__c, 
            leankor__Title__c = template.Id, // Putting Old template id to find old record from new collection of kanbanTempates. 
            leankor__ValueStream__c = boardId, 
            leankor__Width__c = template.leankor__Width__c, 
            Name = template.Name, 
            OwnerId = template.OwnerId
        );
        return data;
    }
}