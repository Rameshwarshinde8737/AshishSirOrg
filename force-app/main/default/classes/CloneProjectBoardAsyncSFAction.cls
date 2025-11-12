global with sharing class CloneProjectBoardAsyncSFAction {
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
        @InvocableVariable(label='Files' description='Set to true if Files will be cloned.')     
			global Boolean cloneFiles;
		@InvocableVariable(label='Custom Fields' description='Set to true if Custom Fields will be cloned.')     
			global Boolean cloneCustomFields;    
        @InvocableVariable(label='Project Board Launch date time' description='The launch date of the cloned project board in date and time data type. Define this if “Project board start date time” and “Project board due date time” are not defined.')     
            global DateTime projectBoardLaunchDate;
        @InvocableVariable(label='Project Room Id' description='Id of the Project Room where Board is located. If this is defined, there is no need to define “Project Room” or “Folder Name of source room”.')
        	global String ProjectRoomId;
        @InvocableVariable(label='Project Room Id Target' description='Id of the Project Room in which to place the cloned Board. If this is defined, there is no need to define “Project Room Target” or “Target Folder Name”.')        	
        	global String TargetRoomId;
        @InvocableVariable(label='Project Board Id' description='Id of the Board to be cloned. If this is defined, there is no need to define “Project Board Name” or “Folder Name of source room”.')        	        	
        	global String ProjectBoardId;            
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            global String projectEventCustomPayload;
            public String checkCloneProject;
		    public String targetDateString;
            public String initialDateString;
            public String projectBoardLaunchDateString;
            public Boolean kanbanVerb;
            public Boolean stickerVerb;
            public Boolean markerVerb;        
            public Boolean taskVerb;
            public Boolean chartVerb;
            public Boolean kanbanTemplateVerb;
            public Boolean zoneVerb;
            public Boolean isprojectclone;
            public String sessionID;
            public Boolean isAsynchBoardCloneFromUI;
    }  

    @InvocableMethod
    global static List<CloneProjectBoardRequest> cloneProjectBoard(List<CloneProjectBoardRequest> requests) {
        List<CloneProjectBoardAsyncAction.CloneProjectBoardRequest> cloneProjectBoardRequests = new List<CloneProjectBoardAsyncAction.CloneProjectBoardRequest>();
        List<CloneProjectBoardAsyncAction.CloneProjectBoardResult> cloneProjectBoardResults = new List<CloneProjectBoardAsyncAction.CloneProjectBoardResult>();

        for(CloneProjectBoardRequest request : requests){
            Leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest cloneProjectBoardRequest = new Leankor.CloneProjectBoardAsyncAction.CloneProjectBoardRequest();
            cloneProjectBoardRequest.FolderName = request.FolderName;
            cloneProjectBoardRequest.ProjectRoom = request.ProjectRoom;
            cloneProjectBoardRequest.ProjectBoard = request.ProjectBoard;
            cloneProjectBoardRequest.TargetFolderName = request.TargetFolderName;
            cloneProjectBoardRequest.TargetRoom = request.TargetRoom;
            cloneProjectBoardRequest.TargetBoard = request.TargetBoard;
            cloneProjectBoardRequest.TargetDate = request.TargetDate;
            cloneProjectBoardRequest.LinkFolderName = request.LinkFolderName;
            cloneProjectBoardRequest.LinkRoomName = request.LinkRoomName;
            cloneProjectBoardRequest.LinkBoardName = request.LinkBoardName;
            cloneProjectBoardRequest.LinkKanbanCardName = request.LinkKanbanCardName;
            cloneProjectBoardRequest.LinkedBoardId = request.LinkedBoardId;
            cloneProjectBoardRequest.LinkedCardId = request.LinkedCardId;
            cloneProjectBoardRequest.initialDate = request.initialDate;
            cloneProjectBoardRequest.ProjectRoomId = request.ProjectRoomId;
            cloneProjectBoardRequest.TargetRoomId = request.TargetRoomId;
            cloneProjectBoardRequest.ProjectBoardId = request.ProjectBoardId;
            cloneProjectBoardRequest.cloneFiles = request.cloneFiles;
            cloneProjectBoardRequest.cloneCustomFields = request.cloneCustomFields;
            cloneProjectBoardRequest.projectBoardLaunchDate = request.projectBoardLaunchDate;
            cloneProjectBoardRequest.projectEventCustomPayload = request.projectEventCustomPayload;
            cloneProjectBoardRequests.add(cloneProjectBoardRequest);
        }
        
        cloneProjectBoardResults = leankor.CloneProjectBoardAsyncAction.cloneProjectBoard(cloneProjectBoardRequests);
        return requests;
    }
}