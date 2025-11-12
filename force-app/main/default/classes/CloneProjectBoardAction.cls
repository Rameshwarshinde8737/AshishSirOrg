/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CloneProjectBoardAction.cls
* CLASS: CloneProjectBoardAction
* USAGE: manages for Cloning Project Board(ValueStream__c) .
*/
global with sharing Class CloneProjectBoardAction{
    //
    // This is Invocable Method for Clone the Project Board By API calls
    // INPUT :- 
    //
    @InvocableMethod
    Global Static List<CloneProjectBoardResult> CloneProjectBoard(List<CloneProjectBoardRequest> clonedata) {
        //Added Security code for sentize user Input
        for (CloneProjectBoardRequest cloneRequests : clonedata) {
            if ((String.isNotBlank(cloneRequests.LinkedBoardId) && Util.getSObjectName(cloneRequests.LinkedBoardId) != 'leankor__ValueStream__c')
            || (String.isNotBlank(cloneRequests.LinkedCardId) && Util.getSObjectName(cloneRequests.LinkedCardId) != 'leankor__KanbanCard__c')
            || (String.isNotBlank(cloneRequests.ProjectRoomId) && Util.getSObjectName(cloneRequests.ProjectRoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(cloneRequests.TargetRoomId) && Util.getSObjectName(cloneRequests.TargetRoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(cloneRequests.ProjectBoardId) && Util.getSObjectName(cloneRequests.ProjectBoardId) != 'leankor__ValueStream__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<CloneProjectBoardResult>  results = new List<CloneProjectBoardResult>(); 

        for (CloneProjectBoardRequest remoteinput : clonedata) {
            results.add(clonedBoard(remoteinput));
        }
        return results;
    }   
    
    Public Static CloneProjectBoardResult clonedBoard(CloneProjectBoardRequest requestData) {
        leankor__ProjectRoom__c ProjectRoom = new leankor__ProjectRoom__c();
        leankor__ProjectRoom__c getProjectroom = new leankor__ProjectRoom__c();
        leankor__ProjectRoom__c LinkProjectRoom = new leankor__ProjectRoom__c();
        leankor__ValueStream__c BoardToBeClone = new leankor__ValueStream__c();
		leankor__ValueStream__c BoardNotToBeClone = new leankor__ValueStream__c();
        leankor__ValueStream__c LinkBoard = new leankor__ValueStream__c();
        leankor__KanbanCard__c LinkCard = new leankor__Kanbancard__c();

		// rbo 11.23.16 moved this here to return this value if any error is encountered
		CloneProjectBoardResult Result = new CloneProjectBoardResult();		
        //
        Savepoint sp = Database.setSavepoint();
        try{
            if (requestData.LinkedCardId==null || requestData.LinkedCardId=='') {
                if (requestData.LinkKanbanCardName != '' && requestData.LinkKanbanCardName != Null) {
                    if (requestData.LinkedBoardId==null || requestData.LinkedBoardId=='') {
                        if (requestData.LinkBoardName != '' && requestData.LinkBoardName != Null && requestData.LinkRoomName != '' && requestData.LinkRoomName != Null) {
                        	if (requestData.LinkFolderName != '' && requestData.LinkFolderName != Null) {
                        		LinkCard =[Select Id,
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name
                                                From leankor__Kanbancard__c 
                                                Where Name = :requestData.LinkKanbanCardName 
                                                    And leankor__ValueStream__r.Name =:requestData.LinkBoardName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name=:requestData.LinkRoomName
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name =:requestData.LinkFolderName 
                                                With Security_Enforced  
                                                Limit 1];
                        	} else {
                             	LinkCard =[Select Id,
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c,leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name 
                                                From leankor__Kanbancard__c 
                                                Where Name = :requestData.LinkKanbanCardName 
                                                    And leankor__ValueStream__r.Name =:requestData.LinkBoardName
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name=:requestData.LinkRoomName 
                                                With Security_Enforced 
                                                Limit 1];
                        	}
                        }
                    } else { 
                        LinkCard =[Select Id,
                                            Name,
                                            leankor__ValueStream__c,
                                            leankor__ValueStream__r.leankor__ProjectRoom__c,leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name  
                                        From leankor__Kanbancard__c
                                        Where Name =:requestData.LinkKanbanCardName 
                                            And leankor__ValueStream__c =:requestData.LinkedBoardId 
                                        With Security_Enforced  
                                        Limit 1];
                    }
                }   
            } else {
                LinkCard =[Select Id,
                                    Name,
                                    leankor__ValueStream__c,
                                    leankor__ValueStream__r.leankor__ProjectRoom__c,leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name
                                From leankor__Kanbancard__c  
                                Where Id =:requestData.LinkedCardId 
                                With Security_Enforced  
                                Limit 1];
            }
            if (LinkCard.ID == Null) {
                if (requestData.LinkedBoardId==null || requestData.LinkedBoardId=='') {
                    if (requestData.LinkBoardName != '' && requestData.LinkBoardName != Null && requestData.LinkRoomName != '' && requestData.LinkRoomName != Null) {
                    	if (requestData.LinkFolderName != '' && requestData.LinkFolderName != Null) {
                    		LinkProjectRoom =[Select Id,
                                                        Name 
                                                    From leankor__ProjectRoom__c 
                                                    Where Name = :requestData.LinkRoomName
                                                        And leankor__Portfolio__r.Name  = :requestData.LinkFolderName
                                                    With Security_Enforced 
                                                    Limit 1 ]; 
                    	} else {
                        	LinkProjectRoom =[Select Id,
                                                        Name 
                                                        From leankor__ProjectRoom__c
                                                        Where Name = :requestData.LinkRoomName 
                                                        With Security_Enforced 
                                                        Limit 1 ];   
                    	}
                        LinkBoard = [Select Id,
                                                Name 
                                            From leankor__ValueStream__c 
                                            Where Name =:requestData.LinkBoardName 
                                                And leankor__ProjectRoom__c =:requestData.LinkRoomName 
                                            With Security_Enforced  
                                            Limit 1];         
                    }
                } else {
                    LinkBoard=[Select Id,
                                        Name,
                                        leankor__ProjectRoom__c,leankor__ProjectRoom__r.leankor__Portfolio__r.Name 
                                        From leankor__ValueStream__c
                                        Where Id = :requestData.LinkedBoardId 
                                        With Security_Enforced  
                                        Limit 1]; 
                                        
                    LinkProjectRoom = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Id = :LinkBoard.leankor__ProjectRoom__c 
                                            With Security_Enforced 
                                            Limit 1 ];
                }
            } else {
                LinkBoard.Id = LinkCard.leankor__ValueStream__c;
                LinkProjectRoom.Id = LinkCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
            }
            
            if (requestData.TargetRoomId != null) {
            	ProjectRoom = [Select Id,
                                        Name 
                                    From leankor__ProjectRoom__c
                                    Where Id = :requestData.TargetRoomId  
                                    With Security_Enforced
                                    Limit 1 ];
            }else if (requestData.TargetFolderName != null && requestData.TargetFolderName != '') {
            	ProjectRoom = [Select Id,
                                        Name 
                                    From leankor__ProjectRoom__c
                                    Where Name = :requestData.TargetRoom 
                                        And leankor__Portfolio__r.name = :requestData.TargetFolderName 
                                    With Security_Enforced 
                                    Limit 1 ];
            } else {          
            	ProjectRoom = [Select Id,
                                        Name
                                    From leankor__ProjectRoom__c 
                                    Where Name = :requestData.TargetRoom 
                                    With Security_Enforced  
                                    Limit 1 ];
            }
            if (requestData.ProjectRoomId != null) {
             	getProjectroom =[Select Id,
                                        Name 
                                        From leankor__ProjectRoom__c 
                                        Where Id = :requestData.ProjectRoomId
                                        With Security_Enforced 
                                        Limit 1];
            }  else if (requestData.FolderName != null && requestData.FolderName != '') {
             	getProjectroom =[Select Id,
                                        Name
                                        From leankor__ProjectRoom__c 
                                        Where Name = :requestData.ProjectRoom 
                                            And leankor__Portfolio__r.name = :requestData.FolderName 
                                        With Security_Enforced  
                                        Limit 1];
            } else {
            	getProjectroom =[Select Id,
                                        Name 
                                    From leankor__ProjectRoom__c 
                                    Where Name = :requestData.ProjectRoom 
                                    With Security_Enforced  
                                    Limit 1];
            }
            
			// rbo 11.23.16 made this to return only the ID, the other fields are not even used
			//BoardToBeClone =[Select ID,Name,(Select Id,Name from leankor__ValueStream__c.leankor__Kanbans__r),leankor__BoardType__C,leankor__ValueStreamLink__c,leankor__ValueStreamCardLink__c From leankor__ValueStream__c Where Name = :requestData.ProjectBoard AND leankor__ProjectRoom__c =: getProjectroom.ID Limit 1];
			if (requestData.ProjectBoardId != null) {
				BoardToBeClone =[Select Id
                                    From leankor__ValueStream__c 
                                    Where Id =: requestData.ProjectBoardId 
                                        And leankor__ProjectRoom__c =: getProjectroom.Id
                                    With Security_Enforced  
                                    Limit 1];
			} else {
				BoardToBeClone =[Select Id 
                                    From leankor__ValueStream__c 
                                    Where Name = :requestData.ProjectBoard 
                                        And leankor__ProjectRoom__c =: getProjectroom.Id  
                                    With Security_Enforced  
                                    Limit 1];
			}
		} catch (Exception e) {
            // rbo 11.23.16 move this here to return this value if any error is encountered
			return Result; // this returns an empty CloneProjectBoardResult		
        }  
            
        leankor.RealTimeController.ProjectBoardClone TempBoard = New leankor.RealTimeController.ProjectBoardClone();
        TempBoard.PrjName = requestData.TargetBoard;
        TempBoard.ProjectRoomId = ProjectRoom.Id;
        TempBoard.ParentVS = BoardToBeClone.Id;
        TempBoard.LinkCloneRoomID = (LinkProjectRoom.ID == Null ? '':LinkProjectRoom.ID);
        TempBoard.LinkCloneVSID = (LinkBoard.ID == NUll ? '' :LinkBoard.ID);
        TempBoard.LinkCloneKanbanCardID = (LinkCard.ID == Null ? '' :LinkCard.ID);
        TempBoard.Isrecalculate = true;
             
        leankor__ValueStream__c  newProjectBoard = leankor.RealTimeController.createProjectBoard(TempBoard);
        CloneProjectBoardAsyncAction.newValueStream = newProjectBoard;
        leankor.KanbanController.cloneboard tempObject = new leankor.KanbanController.cloneboard();
        tempObject.VSID = newProjectBoard.ID ;
        tempObject.RealVSID = BoardToBeClone.ID;
        tempObject.LinkCloneRoomID =(LinkProjectRoom.ID == Null ? '':LinkProjectRoom.ID) ;
        tempObject.LinkCloneVSID = (LinkBoard.ID == NUll ? '' :LinkBoard.ID);
        tempObject.LinkCloneKanbanCardID = (LinkCard.ID == Null ? '' :LinkCard.ID);
        /*if (BoardToBeClone.leankor__Kanbans__r.Size() >0) {
            tempObject.KanbanVerb = true;
       	} else {
            tempObject.KanbanVerb = true;
        }*/        
        tempObject.KanbanVerb = true; // basically the same as above, no need to check BoardToBeClone.leankor__Kanbans__r.Size()
        //
        
        //29/05/2021 - Changes :Checking for Project Clone(PG-Synchronously) and Board clone from API
        tempObject.BoardType = newProjectBoard.leankor__BoardType__C;
        tempObject.KanbanTemplateVerb = requestData.kanbanTemplateVerb == false ? false :true ;
        tempObject.StickerVerb = requestData.stickerVerb == false ? false :true ;
        tempObject.TaskVerb =  requestData.taskVerb == false ? false :true ;
        tempObject.MarkerVerb =  requestData.markerVerb == false ? false : true ;
        tempObject.ChartVerb =  requestData.chartVerb == false ? false : true ;
        tempObject.KanbanVerb =  requestData.kanbanVerb == false ? false :true ;
        tempObject.ZoneVerb =  requestData.zoneVerb == false ? false :true ;
        tempObject.isprojectclone = requestData.isplancloned;
        tempObject.cloneFiles = requestData.cloneFiles;
        tempObject.cloneCustomFields = requestData.cloneCustomFields;
        //Date: 18/06/2019
        if (requestData.projectBoardLaunchDate != null) {
        	tempObject.projectBoardLaunchDate = JSON.serialize(requestData.projectBoardLaunchDate);
        }
        tempObject.oldStartDateTime = newProjectBoard.leankor__ProjectBoardStartDateTime__c; // 11/04/2023 : create board with start date time from valuestream for API
        tempObject.oldEndDateTime = newProjectBoard.leankor__ProjectBoardEndDateTime__c;    // 11/04/2023 : create board with end date time from valuestream for API

        // 10.12.2016 for clone project : stop previous kanban card update
        tempObject.checkcloneproject = requestData.checkCloneProject == '' ? '' : requestData.checkCloneProject ;
        if (requestData.initialDate != null ) {
        	tempObject.FinalStartDate = JSON.Serialize(requestData.initialDate);
        }else if (requestData.TargetDate != null ) {
        	tempObject.FinalDate = JSON.Serialize(requestData.TargetDate);
        } else {
        	tempObject.FinalStartDate = JSON.Serialize(system.now());
        }
        
        // rbo 11.23.16 moved this above
		//CloneProjectBoardResult Result = New CloneProjectBoardResult();
		//
		
		Result.ClonedID = newProjectBoard.ID;
		
		try {												
			// rbo 11.23.16 remoteResult is not used
			//String remoteResult = leankor.KanbanController.CloneSystemBoard(tempObject);
			String response = leankor.KanbanController.CloneSystemBoard(tempObject);
			// rbo 11.23.16
			if (response == 'Success') {
                // rbo 11.23.16 re-link cards of the newly clones board
                linkKanbanCards(tempObject.VSID);
                
    
                //28.05.2021 broadCast for Async Clone Board
                // used for broadcast.
                List<leankor.RealTimeController.bulkStreaming> bulkStreams = new List<leankor.RealTimeController.bulkStreaming>();
                leankor.RealTimeController.bulkStreaming tempStreaming = new leankor.RealTimeController.bulkStreaming();
                leankor.RealTimeController.DirectLinkCardLog tempLog = new leankor.RealTimeController.DirectLinkCardLog();
                tempLog.OldValueStreamId = tempObject.RealVSID;
                tempLog.ValueStreamId = tempObject.VSID;
                tempLog.MySessionId = requestData.sessionID;
    
                tempStreaming.VSID = tempObject.RealVSID;
                tempStreaming.Verb = 'ManageAsyncBoardClone';
                tempStreaming.SessionID = UserInfo.getSessionId();
                tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
                bulkStreams.add(tempStreaming);    
              
                leankor.RealTimeController.sendBroadcast(bulkStreams, 'ManageAsyncBoardClone');
              
                /** 25/03/2021 - We have to send "EndCloneBoard" broadcast for PG(Plan Gantt) when cloning project because now we have 
                    shifted EndCloneBoard platform event for all asyncBoard code in CloneProjectRemainingRecord batch(that is another process) and we are not calling CloneProjectRemainingRecord batch for the PG board, 
                    with that reason from here we are sending EndCloneBoard Platform event for the PG but not for Async board becuse we already sending from CloneProjectRemainingRecord batch class.*/
                if (!CloneProjectAction.isAsyncBoard) {
                    //Fire platform event to notify receiver that cloning completed
                    //Specially for CloneProjectBoardAsyncAction
                    createProjectEvent(newProjectBoard.leankor__ProjectRoom__c, JSON.serialize(new List<String>{newProjectBoard.ID}) ,requestData.projectEventCustomPayload);
                }
                //------------------- END platform event broadcast 
            }  
	 		// rbo 11.23.16
		} catch (Exception e) {
			System.debug('ERROR: while :Cloning Project Board ' + e.getMessage());
           // Database.rollback(sp);
            if (e.getMessage().contains('constraintCardName') && CloneProjectBoardAsyncAction.isClonedBoard == true) {
                leankor.RealTimeController.DirectLinkCardLog constraintViolation = (leankor.RealTimeController.DirectLinkCardLog)JSON.deserialize(e.getMessage().removeStart('Exception Error: '), leankor.RealTimeController.DirectLinkCardLog.class);
                List<leankor.RealTimeController.bulkStreaming> bulkStreams = new List<leankor.RealTimeController.bulkStreaming>();
                leankor.RealTimeController.bulkStreaming tempStreaming = new leankor.RealTimeController.bulkStreaming();
                leankor.RealTimeController.DirectLinkCardLog tempLog = new leankor.RealTimeController.DirectLinkCardLog();
                tempLog.OldValueStreamId = tempObject.RealVSID;
                //tempLog.ValueStreamId = tempObject.VSID;
                tempLog.MySessionId = requestData.sessionID;
                tempLog.currentCardName = constraintViolation.currentCardName;
                tempLog.constraintDescription = constraintViolation.constraintDescription;
                tempLog.constraintCardName = constraintViolation.constraintCardName;
                tempLog.boardName = constraintViolation.boardName;
                tempLog.constraintCardId = constraintViolation.constraintCardId;
                tempLog.violatedBoardType = constraintViolation.violatedBoardType;
                tempLog.violatedBoardId = constraintViolation.violatedBoardId;
                tempLog.projectID = constraintViolation.projectID;
                tempStreaming.Verb = 'ManageAsyncBoardClone';
                tempStreaming.SessionID = UserInfo.getSessionId();
                tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
                bulkStreams.add(tempStreaming);    
                leankor.RealTimeController.sendBroadcast(bulkStreams, 'ManageAsyncBoardClone');
                createProjectEvent(null,e.getMessage(),requestData.projectEventCustomPayload);
            }
            //throw new Util.LeanException(e.getMessage());
        }		
		return Result;
    }

    //07/April/2023 : New method created for fire the project Event.
    public static void createProjectEvent(Id projectId, String jsonPayload, String projectEventCustomPayload) {
        //Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in try/Catch block.
        try{
            leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
            pe.leankor__EventCategory__c = 'Cloning';
            pe.leankor__EventName__c = 'EndCloneBoard';
            pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
            pe.leankor__ProjectID__c = projectId;//{Project Id, force.com ID, of the target board};
            pe.leankor__UserID__c = UserInfo.getUserId();
            pe.leankor__JSONPayload__c = jsonPayload;//{JSON List<string> of board ids}   ---> target ValueStream force.com Ids 
            pe.leankor__CustomPayload__c = projectEventCustomPayload;
            // Call method to publish events
            Database.SaveResult pe_result = EventBus.publish(pe);
            // quick error processing, no need to Rollback 
            if (!pe_result.isSuccess()) {
                for(Database.Error err : pe_result.getErrors()) {
                    System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            // continue on because a failed platform event is no big deal ; do NOT rollback
            }
        }catch(Exception ex) {
            System.debug('ERROR :: '+ex.getMessage());
        }
    }

	
	// rbo 11.23.16
	// method to update links of cards after cloning
	// reurns a List<leankor__KanbanCard__c> of updated cards
	public static List<leankor__KanbanCard__c> linkKanbanCards(Id boardId)
	{    
        KanbanCardBehaviour checkKanbanCardBehaviour = new KanbanCardBehaviour();
        if (!checkKanbanCardBehaviour.isAccessible() || 
            !checkKanbanCardBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }    
        Integer updatedCards = 0;        
        leankor__KanbanCard__c emptyKanbanCard = new leankor__KanbanCard__c();
 
 		List<leankor__KanbanCard__c> newKanbanCards =[Select Id,
                                                                leankor__ValueStream__c,
                                                                leankor__ValueStreamLink__c,
                                                                leankor__ValueStreamCardLink__c,
                                                                leankor__ValueStreamCardLink__r.leankor__ValueStream__c,
                                                                leankor__GUID__c,
                                                                leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__BoardType__c	            			
                                                            From leankor__KanbanCard__c
                                                            Where leankor__ValueStream__c = :boardId
                                                            With Security_Enforced
                                                            Order By leankor__Order__c Asc Nulls Last];		
					       			
        Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();           
		for (leankor__KanbanCard__c newKanbanCard: newKanbanCards)
		{
			String kanbanCardGUID = (newKanbanCard.leankor__GUID__c).SubStringBefore('-');
			if (String.isNotBlank(kanbanCardGUID))
			{
				targetKanbanCards.put(kanbanCardGUID, newKanbanCard);
			}
		}
            
		for (leankor__KanbanCard__c newKanbanCard : newKanbanCards)
 		{ 				
	    	// Is card's project board the same as card's link project board?
	    	if 
	        (
	        	String.isNotBlank(newKanbanCard.leankor__ValueStreamCardLink__c) &&
	            (newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__BoardType__c == 'UberBoard' || newKanbanCard.leankor__ValueStreamCardLink__r.leankor__ValueStream__c == newKanbanCard.leankor__ValueStreamLink__c)
	        )
			{
				leankor__KanbanCard__c targetKanbanCard = targetKanbanCards.get(newKanbanCard.leankor__ValueStreamCardLink__c);
                if (targetKanbanCard != emptyKanbanCard && targetKanbanCard != null)
                { 						
 					newKanbanCard.leankor__ValueStreamCardLink__c = targetKanbanCard.Id;
 					newKanbanCard.leankor__ValueStreamLink__c = newKanbanCard.leankor__ValueStream__c;
					updatedCards++;
                }
			} 				
 		}
  		
		if (updatedCards > 0)
	 	{
	 		update newKanbanCards;
	 	}			
  		
 		return updatedCards > 0 ? newKanbanCards : new List<leankor__KanbanCard__c>();
	}
	
    Global Class CloneProjectBoardRequest {
    	@invocableVariable(label='Folder Name of SourceRoom' description='Name of the Folder where its Room would located.')
            Global String FolderName;
        @invocableVariable(label='Project Room' description='Name of the Project Room where Board is located.')
            Global String ProjectRoom;
        @invocableVariable(label='Project Board Name' description='Name of the Board to be cloned.')
            Global String ProjectBoard;
        @invocableVariable(label='Target Folder Name' description='Name of Folder of the Room in which to place the cloned Board.')
            Global String TargetFolderName;
        @invocableVariable(label='Project Room Target' description='Name of the Room in which to place the cloned Board. ')
            Global String TargetRoom;
        @invocableVariable(label='New Project Board Name' description='Name of the new Board.')
            Global String TargetBoard;
        @invocableVariable(label='Due Date' description='Provide the final Due Date for the Card farthest in the future.')
            Global DateTime TargetDate;
        @invocableVariable(label='Linked Folder Name' description='Name of the Linked Folder where Linked Room would located.')
            Global String LinkFolderName; 
        @invocableVariable(label='Link Room Name' description='Name of the Link Project Room where Linked Board is located.')
            Global String LinkRoomName;
        @invocableVariable(label='Link Board Name' description='Name of the Link Board to Linked with Cloned Cards.')
            Global String LinkBoardName;
        @invocableVariable(label='Link Kanban Card Name' description='Name of Link Kanban Card Which to linked with cloned Cards .')
            Global String LinkKanbanCardName;
        @invocableVariable(label='Link Board Id' description='ID of the Link Board to Linked with merge Cards.')
            Global String LinkedBoardId;        
        @invocableVariable(label='Linked Card ID' description='Name of Link Kanban Card Which to linked.')
            Global String LinkedCardId;
        @invocableVariable(label='Start Date' description='Provide the initial Start Date for the Card farthest in the future.')
            Global DateTime initialDate;
        
        @InvocableVariable(label='Project Room Id' description='Id of the Project Room where Board is located. If this is defined, there is no need to define “Project Room” or “Folder Name of source room”.')
        	Global String ProjectRoomId;
        @InvocableVariable(label='Project Room Id Target' description='Id of the Project Room in which to place the cloned Board. If this is defined, there is no need to define “Project Room Target” or “Target Folder Name”.')        	
        	Global String TargetRoomId;
        @InvocableVariable(label='Project Board Id' description='Id of the Board to be cloned. If this is defined, there is no need to define “Project Board Name” or “Folder Name of source room”.')        	        	
        	Global String ProjectBoardId;
        	
            Global boolean isplancloned;
            // 10.12.2016 for clone project : stop previous kanban card update
            Global String checkCloneProject;
        @InvocableVariable(label='Files' description='Set to true if Files will be cloned.')     
			Global Boolean cloneFiles;
		@InvocableVariable(label='Custom Fields' description='Set to true if Custom Fields will be cloned.')     
			Global Boolean cloneCustomFields;    
            // Date: 18/06/2019 - For launch board with project launch date.
        @InvocableVariable(label='Project Board Launch date time' description='The launch date of the cloned project board in date and time data type. Define this if “Project board start date time” and “Project board due date time” are not defined.')     
            Global DateTime projectBoardLaunchDate;
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            Global String projectEventCustomPayload;            
            
            public Boolean stickerVerb;     
            public Boolean taskVerb; 
            public Boolean markerVerb; 
            public Boolean chartVerb;      
            public Boolean kanbanVerb;
            public Boolean zoneVerb;
            public Boolean kanbanTemplateVerb;
            public String sessionID;
    }
     
    Global Class CloneProjectBoardResult{
        @invocableVariable(label='New Project Board ID' description='The unique ID of the Board which was cloned')
            Global String ClonedID;
    }
}