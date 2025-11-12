global with sharing class CreateProjectBoardSFAction {
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

    @InvocableMethod
    global static List<ProjectBoardRequest>  createProjectBoard(List<ProjectBoardRequest> requests) {
        List<CreateProjectBoardAction.ProjectBoardRequest> projectBoardRequests = new List<CreateProjectBoardAction.ProjectBoardRequest>();

        for(ProjectBoardRequest request : requests){
            CreateProjectBoardAction.ProjectBoardRequest projectBoardRequest = new CreateProjectBoardAction.ProjectBoardRequest(); 
            projectBoardRequest.ProjectBoardName = request.ProjectBoardName;
            projectBoardRequest.ProjectFolderName = request.ProjectFolderName;
            projectBoardRequest.ProjectFolderID = request.ProjectFolderID;
            projectBoardRequest.ProjectRoomId = request.ProjectRoomId;
            projectBoardRequest.ProjectRoomName = request.ProjectRoomName;
            projectBoardRequest.BoardType = request.BoardType;
            projectBoardRequest.CardURL = request.CardURL;
            projectBoardRequest.PointPicklist = request.PointPicklist;
            projectBoardRequest.DaysPerSprint = request.DaysPerSprint;
            projectBoardRequest.IsAgile = request.IsAgile;
            projectBoardRequest.PortfolioMode = request.PortfolioMode;
            projectBoardRequest.SevenDayWorkWeek = request.SevenDayWorkWeek;
            projectBoardRequest.SprintStartDate = request.SprintStartDate;
            projectBoardRequest.Effortindicator = request.Effortindicator;
            projectBoardRequest.LinkedFolderName = request.LinkedFolderName;
            projectBoardRequest.LinkedRoomName = request.LinkedRoomName;
            projectBoardRequest.LinkedBoardName = request.LinkedBoardName;
            projectBoardRequest.LinkedBoardId = request.LinkedBoardId;
            projectBoardRequest.LinkedCardName = request.LinkedCardName;
            projectBoardRequest.LinkedCardId = request.LinkedCardId;
            projectBoardRequest.DefaultCategory = request.DefaultCategory;
            projectBoardRequest.DisableCalendarView = request.DisableCalendarView;
            projectBoardRequest.IsTemplateBoard = request.IsTemplateBoard;
            projectBoardRequest.DisableTaskAsMiniature = request.DisableTaskAsMiniature;

            projectBoardRequests.add(projectBoardRequest);
        }
        leankor.CreateProjectBoardAction.createProjectBoard(projectBoardRequests);
        return requests;
    }
}