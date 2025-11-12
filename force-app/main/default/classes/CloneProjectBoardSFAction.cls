/*********************************************************************************
* Company     : Leankor
* Description : manages for Cloning Project Board(ValueStream__c)
 *********************************************************************************/ 
global with sharing class CloneProjectBoardSFAction {
    
     global class CloneProjectBoardRequest {
    	@InvocableVariable(label='Folder Name of SourceRoom' description='Name of the Folder where its Room would located.')
            global String FolderName;
        @InvocableVariable(label='Project Room' description='Name of the Project Room where Board is located.')
            global String ProjectRoom;
        @InvocableVariable(label='Project Board Name' description='Name of the Board to be cloned.')
            global String ProjectBoard;
        @InvocableVariable(label='Target Folder Name' description='Name of Folder of the Room in which to place the cloned Board.')
            global String TargetFolderName;
        @InvocableVariable(label='Project Room Target' description='Name of the Room in which to place the cloned Board. ')
            global String TargetRoom;
        @InvocableVariable(label='New Project Board Name' description='Name of the new Board.')
            global String TargetBoard;
        @InvocableVariable(label='Due Date' description='Provide the final Due Date for the Card farthest in the future.')
            global DateTime TargetDate;
        @InvocableVariable(label='Linked Folder Name' description='Name of the Linked Folder where Linked Room would located.')
            global String LinkFolderName; 
        @InvocableVariable(label='Link Room Name' description='Name of the Link Project Room where Linked Board is located.')
            global String LinkRoomName;
        @InvocableVariable(label='Link Board Name' description='Name of the Link Board to Linked with Cloned Cards.')
            global String LinkBoardName;
        @InvocableVariable(label='Link Kanban Card Name' description='Name of Link Kanban Card Which to linked with cloned Cards .')
            global String LinkKanbanCardName;
        @InvocableVariable(label='Link Board Id' description='ID of the Link Board to Linked with merge Cards.')
            global String LinkedBoardId;        
        @InvocableVariable(label='Linked Card ID' description='Name of Link Kanban Card Which to linked.')
            global String LinkedCardId;
        @InvocableVariable(label='Start Date' description='Provide the initial Start Date for the Card farthest in the future.')
            global DateTime initialDate;
        @InvocableVariable(label='Project Room Id' description='Id of the Project Room where Board is located. If this is defined, there is no need to define “Project Room” or “Folder Name of source room”.')
        	global String ProjectRoomId;
        @InvocableVariable(label='Project Room Id Target' description='Id of the Project Room in which to place the cloned Board. If this is defined, there is no need to define “Project Room Target” or “Target Folder Name”.')        	
        	global String TargetRoomId;
        @InvocableVariable(label='Project Board Id' description='Id of the Board to be cloned. If this is defined, there is no need to define “Project Board Name” or “Folder Name of source room”.')        	        	
        	global String ProjectBoardId;

            Global boolean isplancloned;
            // 10.12.2016 for clone project : stop previous kanban card update
            Global String checkCloneProject;
        @InvocableVariable(label='Files' description='Set to true if Files will be cloned.')     
			global Boolean cloneFiles;
		@InvocableVariable(label='Custom Fields' description='Set to true if Custom Fields will be cloned.')     
			global Boolean cloneCustomFields;    
        @InvocableVariable(label='Project Board Launch date time' description='The launch date of the cloned project board in date and time data type. Define this if “Project board start date time” and “Project board due date time” are not defined.')     
            global DateTime projectBoardLaunchDate;
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            global String projectEventCustomPayload;
            public Boolean stickerVerb;     
            public Boolean taskVerb; 
            public Boolean markerVerb; 
            public Boolean chartVerb;      
            public Boolean kanbanVerb;
            public Boolean zoneVerb;
            public Boolean kanbanTemplateVerb;
            public String sessionID;
    }

    /*------------------------------------------------------------
	    Company:        Leankor
	    Description:    Getting data of all The Field Which Present inside FieldSet
	    Inputs:         List of CloneProjectBoardRequest
	    Returns:        List of CloneProjectBoardRequest
	------------------------------------------------------------*/
    @InvocableMethod
    global Static List<CloneProjectBoardRequest> CloneProjectBoard(List<CloneProjectBoardSFAction.CloneProjectBoardRequest> clonedata){
        List<CloneProjectBoardAction.CloneProjectBoardRequest> allRequest = new List<CloneProjectBoardAction.CloneProjectBoardRequest>();
        for(CloneProjectBoardSFAction.CloneProjectBoardRequest singleRequest : clonedata){
            
            Leankor.CloneProjectBoardAction.CloneProjectBoardRequest request = new Leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
            request.FolderName = singleRequest.FolderName;
            request.ProjectRoom = singleRequest.ProjectRoom;
            request.ProjectBoard = singleRequest.ProjectBoard;
            request.TargetFolderName = singleRequest.TargetFolderName;
            request.TargetRoom = singleRequest.TargetRoom;
            request.TargetBoard = singleRequest.TargetBoard;
            request.TargetDate = singleRequest.TargetDate;
            request.LinkFolderName = singleRequest.LinkFolderName;
            request.LinkRoomName = singleRequest.LinkRoomName;
            request.LinkBoardName = singleRequest.LinkBoardName;
            request.LinkKanbanCardName = singleRequest.LinkKanbanCardName;
            request.LinkedBoardId = singleRequest.LinkedBoardId;
            request.LinkedCardId = singleRequest.LinkedCardId;
            request.initialDate = singleRequest.initialDate;
            request.ProjectRoomId = singleRequest.ProjectRoomId;
            request.TargetRoomId = singleRequest.TargetRoomId;
            request.ProjectBoardId = singleRequest.ProjectBoardId;
            request.cloneFiles = singleRequest.cloneFiles;
            request.cloneCustomFields = singleRequest.cloneCustomFields;
            request.projectBoardLaunchDate = singleRequest.projectBoardLaunchDate;
            request.projectEventCustomPayload = singleRequest.projectEventCustomPayload;
            allRequest.add(request);
        }
        Leankor.CloneProjectBoardAction.CloneProjectBoard(allRequest);
        return clonedata;
    }

  }