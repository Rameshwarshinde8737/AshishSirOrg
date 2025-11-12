/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CreateProjectBoardAction.cls
* CLASS: CreateProjectBoardAction
* USAGE: manages to Create Project Board  .
*/
global with sharing class CreateProjectBoardAction {

    // This is execute method for Invocable Method for API calls
    @InvocableMethod
    global static List<ProjectBoardResult>  CreateProjectBoard(List<ProjectBoardRequest> requests) { 
        // Added Security code for sentize user Input(
		for(ProjectBoardRequest projectBoardRequest : requests){
			if((String.isNotBlank(projectBoardRequest.ProjectFolderID) && Util.getSObjectName(projectBoardRequest.ProjectFolderID) != 'leankor__Portfolio__c')
			|| (String.isNotBlank(projectBoardRequest.ProjectRoomId) && Util.getSObjectName(projectBoardRequest.ProjectRoomId) != 'leankor__ProjectRoom__c')
			|| (String.isNotBlank(projectBoardRequest.LinkedBoardId) && Util.getSObjectName(projectBoardRequest.LinkedBoardId) != 'leankor__ValueStream__c')
			|| (String.isNotBlank(projectBoardRequest.LinkedCardId) && Util.getSObjectName(projectBoardRequest.LinkedCardId) != 'leankor__KanbanCard__c')
			){
				throw new Util.LeanException('Error: Invalid input');
			}
		}
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour project =  new ProjectRoomBehaviour();
        ValueStreamBehavior vStream = new ValueStreamBehavior();
        KanbanCardBehaviour kanbanCard = new KanbanCardBehaviour();
        PortfolioBehaviour portfolio = new PortfolioBehaviour();
        KanbanCardTemplateBehaviour cardTemplate = new KanbanCardTemplateBehaviour();
        SecurityBehavior security = new SecurityBehavior();
        
        if (!project.isAccessible() 
        || !vStream.isAccessible() 
        || !kanbanCard.isAccessible() 
        || !portfolio.isAccessible()
        || !vStream.isCreateable()
        || !cardTemplate.isCreateable() 
        || !security.isCreateable()
        || !vStream.isUpdateable() 
        || !security.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }   

        //Check CRUD / FLC behavior
        
        List<ProjectBoardResult> results = new List<ProjectBoardResult>();
        for (ProjectBoardRequest request : requests) {
            results.add(findProjectBoard(request));
        }

        return results;
    } 


    // This Method is use to manage bulk API Calls
    public static ProjectBoardResult findProjectBoard(ProjectBoardRequest request) { 
        //Check CRUD / FLC behavior
        PortfolioBehaviour portfolioBehaviour = new PortfolioBehaviour();
        ProjectRoomBehaviour projectRoomBehaviour =  new ProjectRoomBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();

        if (
            !portfolioBehaviour.isAccessible() ||
            !projectRoomBehaviour.isAccessible() || 
            !valueStreamBehavior.isAccessible() ||
            !valueStreamBehavior.isUpdateable() ||
            !kanbanCardTemplateBehaviour.isAccessible() ||
            !kanbanCardBehaviour.isAccessible()
        ) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        leankor.RealTimeController.ProjectBoard  NewProjectBoard = new  leankor.RealTimeController.ProjectBoard ();
        ID FolderID = request.ProjectFolderID;
        ID RoomID = request.ProjectRoomId;
                
        if (RoomID == null || RoomID == '') {
            //if(request.LinkedRoomName != '' && request.LinkedRoomName != Null){
                List<leankor__ProjectRoom__C> ProjectRooms = null;
                if (request.ProjectFolderName != '' && request.ProjectFolderName != null) {
                        ProjectRooms = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.ProjectRoomName 
                                                And leankor__portfolio__r.Name = : request.ProjectFolderName
                                            With Security_Enforced 
                                            Limit 9999];
                } else {
                        ProjectRooms = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.ProjectRoomName
                                            With Security_Enforced
                                            Limit 9999];
                }

                if (ProjectRooms.Size() > 0) {
                    RoomID = ProjectRooms[0].Id;
                }
            //} 
        } else {
            List<leankor__ProjectRoom__C> ProjectRooms = [Select Id,
                                                                Name 
                                                            From leankor__ProjectRoom__c 
                                                            Where Name = :request.ProjectRoomName 
                                                            With Security_Enforced
                                                            Limit 9999];//AND leankor__portfolio__c = :request.ProjectFolderID
            if (ProjectRooms.Size() > 0 ) { 
                RoomID = ProjectRooms[0].Id;
            }
        }
        try{    
            if (request.BoardType == 'Card Hierarchy') {
                /* leankor__KanbanCard__c Card = [SELECT ID, leankor__ValueStream__c FROM leankor__KanbanCard__c where Name =:request.CardName Limit 1 ];
                ID cardID = Card.ID ;
                ID BoardID = Card.leankor__ValueStream__c ; */
                String BoardID18 = request.CardURL.substringAfter('?Id=');
                String BoardID = BoardID18.substring(0, 15);
                String CardID18 = request.CardURL.substringAfter('cardid=') ;
                String CardID = CardID18.substring(0, 15);
                NewProjectBoard  = leankor.ProjectBoardCarousel.createProjectBoard(request.ProjectBoardName,RoomID ,request.BoardType,BoardID,CardID);
             } else {
                NewProjectBoard  = leankor.ProjectBoardCarousel.createProjectBoard(request.ProjectBoardName,RoomID,request.BoardType,'','');
             }
        } catch (Exception e) {
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }

        leankor__ValueStream__c VS = [Select Id,
                                            (Select ID 
                                                From leankor__Kanban_Card_Templates__r),
                                            leankor__DefaultCategory__c,
                                            leankor__DisableCalendarView__c,
                                            leankor__IsTemplateBoard__c,
                                            leankor__DefaultOwnerID__c,
                                            leankor__Effortindicator__c,
                                            leankor__IsAgile__c,leankor__SprintStartDate__c,
                                            leankor__PointPicklist__c,
                                            leankor__DaysPerSprint__c,
                                            leankor__BoardType__c,
                                            leankor__ValueStreamCardLink__c,
                                            leankor__ValueStreamLink__c,
                                            leankor__BackgroundHeight__c,
                                            leankor__BackgroundWidth__c,
                                            leankor__JSONSnapshot__c,
                                            leankor__KanbanCardCount__c,
                                            leankor__KanbanCardThroughput__c,
                                            leankor__ProjectRoom__c,
                                            leankor__Portfolio__c,
                                            leankor__ValueStreamTemplate__c,
                                            Name,
                                            OwnerId,
                                            leankor__CaseType__c,
                                            leankor__CaseSynchronization__c 
                                        From leankor__ValueStream__c 
                                        Where Id =:NewProjectBoard.Id 
                                        Limit 1];
        leankor__ValueStream__c LinkBoard = new leankor__ValueStream__c();
        leankor__ProjectRoom__c LinkRoom = new leankor__ProjectRoom__c();
        leankor__KanbanCard__c LinkCard = New leankor__Kanbancard__c();
        //leankor__Portfolio__c LinkFolder = new leankor__Portfolio__c();

        try{
            if (request.LinkedCardId == null || request.LinkedCardId=='') {
                if (request.LinkedCardName != '' && request.LinkedCardName != null) {
                    if (request.LinkedBoardId==null || request.LinkedBoardId=='') {
                        if (request.LinkedBoardName != '' && request.LinkedBoardName != null && request.LinkedRoomName != '' && request.LinkedRoomName != null) {
                        	if (request.LinkedFolderName != '' && request.LinkedFolderName != null) {
                        		LinkCard =[Select Id,
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c 
                                                From leankor__Kanbancard__c 
                                                Where Name = :request.LinkedCardName 
                                                    And leankor__ValueStream__r.Name =:request.LinkedBoardName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name=:request.LinkedRoomName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c = :request.LinkedFolderName 
                                                With Security_Enforced
                                                Limit 1];
                        	} else { 
                            	LinkCard =[Select Id,
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c 
                                                From leankor__Kanbancard__c 
                                                Where Name = :request.LinkedCardName 
                                                    And leankor__ValueStream__r.Name =:request.LinkedBoardName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name=:request.LinkedRoomName
                                                With Security_Enforced 
                                                Limit 1];
                        	}
                        }
                    } else {
                        LinkCard =[Select Id,
                                            Name,
                                            leankor__ValueStream__c,
                                            leankor__ValueStream__r.leankor__ProjectRoom__c 
                                        From leankor__Kanbancard__c 
                                        Where Name = :request.LinkedCardName 
                                            And leankor__ValueStream__c =:request.LinkedBoardId 
                                        With Security_Enforced
                                        Limit 1];
                    }
                }   
            } else {
                LinkCard =[Select Id,
                                    Name,
                                    leankor__ValueStream__c,
                                    leankor__ValueStream__r.leankor__ProjectRoom__c  
                                From leankor__Kanbancard__c  
                                Where Id = :request.LinkedCardId 
                                With Security_Enforced
                                Limit 1]; 
            }

            if (LinkCard.ID == null) {
                if (request.LinkedBoardId == null || request.LinkedBoardId =='') {
                    if(request.LinkedBoardName != '' && request.LinkedBoardName != Null && request.LinkedRoomName != '' && request.LinkedRoomName != Null){
                    	if(request.LinkedFolderName != '' && request.LinkedFolderName != Null){
                        	LinkRoom =[Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.LinkedRoomName 
                                                And leankor__Portfolio__r.Name =:request.LinkedFolderName 
                                            With Security_Enforced
                                            Limit 1];
                    	}else{
                    		LinkRoom =[Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.LinkedRoomName 
                                            With Security_Enforced
                                            Limit 1];
                    	}   
                        LinkBoard=[Select Id,
                                            Name 
                                        From leankor__ValueStream__c 
                                        Where Name =:request.LinkedBoardName 
                                            And leankor__ProjectRoom__c =:LinkRoom.Id 
                                        With Security_Enforced
                                        Limit 1];         
                    }
                } else {
                    LinkBoard=[Select Id,
                                        Name,
                                        leankor__ProjectRoom__c 
                                    From leankor__ValueStream__c 
                                    Where Id = :request.LinkedBoardId  
                                    With Security_Enforced
                                    Limit 1]; 

                    LinkRoom =[Select Id,
                                        Name,
                                        leankor__Portfolio__c 
                                    From leankor__ProjectRoom__c
                                    Where Id = :LinkBoard.leankor__ProjectRoom__c 
                                    With Security_Enforced
                                    Limit 1 ];
                    //LinkFolder = [SELECT ID,Name FROM leankor__Portfolio__c WHERE ID = :LinkRoom.leankor__Portfolio__c Limit 1];
                }
            } else {
                LinkBoard.ID=LinkCard.leankor__ValueStream__c;
                LinkRoom.ID=LinkCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
                //LinkFolder.ID = LinkCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c;
            }
        } catch (Exception e) {
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }

        leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();  
        vs.leankor__SprintStartDate__c = (request.SprintStartDate == null ? null : request.SprintStartDate) ;
        vs.leankor__PointPicklist__c = (request.PointPicklist == '' ? leanConstant.leankor__PointSequence__c :request.PointPicklist) ;
        vs.leankor__DaysPerSprint__c = (request.DaysPerSprint == null ? null : request.DaysPerSprint);
        vs.leankor__IsAgile__c = (request.IsAgile == null ? false :request.IsAgile);
        vs.leankor__Effortindicator__c = ((request.Effortindicator == '' || request.Effortindicator == null) ? 'Days' :request.Effortindicator);
        
        if (request.BoardType != 'Card Hierarchy') {
        	vs.leankor__ProjectRoomLink__c = (LinkRoom.ID == null ? null: LinkRoom.ID) ;
        	vs.leankor__ValueStreamLink__c = (LinkBoard.ID == null ? null : LinkBoard.ID) ;
        	vs.leankor__ValueStreamCardLink__c = (LinkCard.ID == null ? null : LinkCard.ID);
        }

        vs.leankor__SevenDayWorkWeek__c = ((request.SevenDayWorkWeek == Null ) ? false : request.SevenDayWorkWeek);
        vs.leankor__DisableTaskAsMiniature__c = ((request.DisableTaskAsMiniature == Null ) ? false : request.DisableTaskAsMiniature);
        vs.leankor__PortfolioMode__c = ((request.PortfolioMode == Null ) ? false : request.PortfolioMode);
        
        if (vs.leankor__Kanban_Card_Templates__r.size() > 0) {
            vs.leankor__DefaultCategory__c = vs.leankor__Kanban_Card_Templates__r[0].ID;
        }

        vs.leankor__DisableCalendarView__c = ((request.DisableCalendarView == null) ? false : request.DisableCalendarView);
        vs.leankor__IsTemplateBoard__c = ((request.IsTemplateBoard == Null ) ? false : request.IsTemplateBoard);
        vs.leankor__DefaultOwnerID__c = userinfo.getuserID();
        
        try {
            DataBase.Update(vs, false);
        } catch(DMLException ex) {
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
                        
        ProjectBoardResult ProjectBoard = new ProjectBoardResult();
        String VSID = NewProjectBoard.Id;
        ProjectBoard.ProjectBoardId =(VSID).substring(0, 15);

        return ProjectBoard;
    }


    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    global class ProjectBoardRequest {      
        @InvocableVariable(label = 'Project Board Name' description = 'String name of the Board.' required=true)
            global String ProjectBoardName;
        @InvocableVariable(label='Project Folder Name' description='Name of the Folder where its Room would located.')
            global String ProjectFolderName;
        @InvocableVariable(label='Project Folder ID' description='ID of the Folder where its Room would located.')
            global String ProjectFolderID;    
        @InvocableVariable(label = 'Project Room Id' description = 'ID of the Project Room.')
            global String ProjectRoomId;
        @InvocableVariable(label = 'Project Room Name' description = 'String name of the room.' required=true)
            global String ProjectRoomName;    
        @InvocableVariable(label = 'Board Type' description = 'String name of the Project Board Type. Whiteboard, Kanban Board, Portfolio View or Card Hierarchy.' required=true)
            global String BoardType;
        @InvocableVariable(label = 'CardURL' description = 'The URL obtained by clicking on the Copy URL button.(Only For Card Hierarchy Board)')
            global string CardURL ;           
       // Linked Folder, Linked Room, Linked Board, Linked Card
        @InvocableVariable(label='Points Values' description='Points values for board. eg: [1,2,3,4,.....]')
            global String PointPicklist;
        @InvocableVariable(label='DaysPerSprint' description='Number of days per sprint.')
            global Decimal DaysPerSprint;
        @InvocableVariable(label='IS Agile Board' description='IS agile mode on for the board.')
            global Boolean IsAgile;
        @InvocableVariable(label=' Is Parent Board' description='Make this board as Parent Board.')
            global Boolean PortfolioMode;
        @InvocableVariable(label='IS Board work as Seven days' description='IS Seven days week on for the board.')
            global Boolean SevenDayWorkWeek;
        @InvocableVariable(label='Sprint Start Date Time' description='start date for first sprint.')
            global Datetime SprintStartDate ;
        @InvocableVariable(label='Effort Indicator' description='This field change card indicator for board (Days,Hours,Point).')
            global String Effortindicator;
        @InvocableVariable(label='Linked Folder Name' description='Name of the Linked Folder where Linked Room would located.')
            global String LinkedFolderName; 
        @InvocableVariable(label='Linked Room Name' description='Name of the Link Project Room where Linked Board is located.')
            global String LinkedRoomName;
        @InvocableVariable(label='Linked Board Name' description='Name of the Link Board to Linked .')
            global String LinkedBoardName;
        @InvocableVariable(label='Link Board Id' description='ID of the Link Board to Linked with merge Cards.')
            global String LinkedBoardId;        
        @InvocableVariable(label='Linked Card Name' description='Name of Link Kanban Card Which to linked.')
            global String LinkedCardName;
        @InvocableVariable(label='Linked Card ID' description='Name of Link Kanban Card Which to linked.')
            global String LinkedCardId; 
        @InvocableVariable(label='Default Category ID' description='This field is use for Inbound emails')            
            global String DefaultCategory ;
        @InvocableVariable(label='Disable Calendar View' description='Is board display calendar view ?')
            global Boolean DisableCalendarView ;
        @InvocableVariable(label='IsTemplateBoard' description='Make Current Board As a template Board ?') 
            global boolean IsTemplateBoard ;
        @InvocableVariable(label='Disable Calendar Task View' description='Is board display calendar task view ?')
            global Boolean DisableTaskAsMiniature ;                  
    }


    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    global class ProjectBoardResult {    
        @InvocableVariable(label = 'Project Board Id' description = 'ID of the new Project Board. ' required = true)
            global String ProjectBoardId;
    }
}