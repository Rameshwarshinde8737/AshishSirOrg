global with sharing class CloneProjectSFAction {
    global class CloneProjectRequest {
        @InvocableVariable(label='Folder id of source project' description='The folder id where the project to be cloned is located.')
            global String sourceFolderId;
        @InvocableVariable(label='Folder name of source project' description='The folder name where the project to be cloned is located. This is not needed if “Folder id of source project” is defined.')
            global String sourceFolderName;         
        @InvocableVariable(label='Project id of source project' description='The project id of the project to be cloned. If this is defined, there is no need to define “Folder id of source project” or “Folder name of source project” or “Project name of source project”.')
            global String sourceProjectId;          
        @InvocableVariable(label='Project name of source' description='The project name of the project to be cloned.” is defined.')
            global String sourceProjectName;            
        @InvocableVariable(label='Folder id of target project' description='The folder id where the cloned project is to be located.”')
            global String targetFolderId;           
        @InvocableVariable(label='Folder name of target project' description='The folder name where the cloned project is to be located. This is not needed if “Folder id of target project” is defined.')
            global String targetFolderName;
        @InvocableVariable(label='Project name of target project' description='The project name of the cloned project.' required=true)
            global String targetProjectName;
        @InvocableVariable(label='Project start date time' description='The start date of the cloned project in date and time data type. If this is defined, there is no need to specify “Project due date time”.')
            global DateTime targetProjectStartDateTime;
        @InvocableVariable(label='Project due date time' description='The due date of the cloned project in date and time data type. Define this if “Project start date time” is not defined. “Project start date time” takes precedence, meaning it is only used if “Project start date time” is not defined.')
            global DateTime targetProjectDueDateTime;
        @InvocableVariable(label='Plan Gantt' description='Set to true if Plan Gantt will be cloned.')
            global Boolean planGantt;
        @InvocableVariable(label='Roll Up' description='Set to true if Roll Up will be cloned.')
            global Boolean rollUp;
        @InvocableVariable(label='Project Board' description='Set to true if Project board(s) will be cloned.')
            global Boolean projectBoard;
        @InvocableVariable(label='White Board' description='Set to true if Whiteboard(s) will be cloned.')
            global Boolean whiteBoard;
        @InvocableVariable(label='Dash Board' description='Set to true if Dashboard(s) will be cloned.')
            global Boolean dashBoard;           
        @InvocableVariable(label='Expenses' description='Set to true if Expenses will be cloned.')
            global Boolean expenses;    
        @InvocableVariable(label='Return Portfolio Hierarchy' description='Set to true if Hierarchy of Portfolio will be returned as a List of strings.')
            global Boolean returnPortfolioHierarchy;            
        @InvocableVariable(label='Relink cloned project id' description='The project id of cloned project to relink items within. If this is defined, the API will only execute relinking and not cloning making values of the other parameters unnecessary.')
            global String relinkClonedProjectId;
        @InvocableVariable(label='Set of project board types within the source project' description='The board types of all project boards within the project that is being cloned. This is used to validate completion of cloning boards.')
            global List<String> projectBoardTypes;
        @InvocableVariable(label='Total cards of all project boards within the source project' description='The total number of cards of all project boards within the project that is being cloned. This is used to validate completion of cloning boards.')
            global Integer totalCardsOfSourceProjectBoards;           
		@InvocableVariable(label='Files' description='Set to true if Files will be cloned.')     
			global Boolean cloneFiles;
		@InvocableVariable(label='Custom Fields' description='Set to true if Custom Fields will be cloned.')     
			global Boolean cloneCustomFields;
		@InvocableVariable(label='Project Launch date time' description='The launch date of the cloned project in date and time data type. Define this if “Project start date time” and "Project due date time" are not defined.')          	
			global Datetime targetLaunchDateTime; 
		@InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            global String projectEventCustomPayload;
        @InvocableVariable(label='Clone KanbanCard Stickers' description='Set to true if Clone All Sticker on Face of KanbanCards')
            global Boolean cardStickerVerb; 
            global String targetStartDate;             
            global String targetDueDate;
            global String navigationVerb;  
            global boolean isplancloned;
            global String sessionID;  		
            public integer firstDayOfWeek;
            public boolean sevenDayWorkWeek;
            public String targetLaunchDate;
            public Boolean isCloneWithLaunchDate;
            public Integer totalNumberOfSourceProjectBoards;
            public Map<Id, List<leankor__Expense__c>> relinkClonedExpenses;
    } 

    @InvocableMethod
    global static List<CloneProjectRequest> cloneProjects(List<CloneProjectRequest> requests) {
        List<CloneProjectAction.CloneProjectRequest> cloneProjectActionRequests = new List<CloneProjectAction.CloneProjectRequest>();
        List<CloneProjectAction.CloneProjectResult> cloneProjectActionResults = new List<CloneProjectAction.CloneProjectResult>();
        for(CloneProjectRequest request : requests){
            CloneProjectAction.CloneProjectRequest cloneProjectActionRequest = new CloneProjectAction.CloneProjectRequest();
            cloneProjectActionRequest.sourceFolderId = request.sourceFolderId;
            cloneProjectActionRequest.sourceFolderName = request.sourceFolderName;
            cloneProjectActionRequest.sourceProjectId = request.sourceProjectId;
            cloneProjectActionRequest.sourceProjectName = request.sourceProjectName;
            cloneProjectActionRequest.targetFolderId = request.targetFolderId;
            cloneProjectActionRequest.targetFolderName = request.targetFolderName;
            cloneProjectActionRequest.targetProjectName = request.targetProjectName;
            cloneProjectActionRequest.targetProjectStartDateTime = request.targetProjectStartDateTime;
            cloneProjectActionRequest.targetProjectDueDateTime = request.targetProjectDueDateTime;
            cloneProjectActionRequest.planGantt = request.planGantt;
            cloneProjectActionRequest.rollUp = request.rollUp;
            cloneProjectActionRequest.projectBoard = request.projectBoard;
            cloneProjectActionRequest.whiteBoard = request.whiteBoard;
            cloneProjectActionRequest.dashBoard = request.dashBoard;
            cloneProjectActionRequest.expenses = request.expenses;
            cloneProjectActionRequest.returnPortfolioHierarchy = request.returnPortfolioHierarchy;
            cloneProjectActionRequest.relinkClonedProjectId = request.relinkClonedProjectId;
            cloneProjectActionRequest.projectBoardTypes = request.projectBoardTypes;
            cloneProjectActionRequest.totalCardsOfSourceProjectBoards = request.totalCardsOfSourceProjectBoards;
            cloneProjectActionRequest.cloneFiles = request.cloneFiles;
            cloneProjectActionRequest.cloneCustomFields = request.cloneCustomFields;
            cloneProjectActionRequest.targetLaunchDateTime = request.targetLaunchDateTime;
            cloneProjectActionRequest.projectEventCustomPayload = request.projectEventCustomPayload;
            cloneProjectActionRequest.cardStickerVerb = request.cardStickerVerb;

            cloneProjectActionRequests.add(cloneProjectActionRequest);
        }

        cloneProjectActionResults = leankor.CloneProjectAction.cloneProjects(cloneProjectActionRequests);
        return requests;
    }
}