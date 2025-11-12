global with sharing class MergeProjectBoardSFAction {
    global class MergeProjectBoardRequest{
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

    @InvocableMethod 
    global static List<MergeProjectBoardRequest> MergeProjectBoard(List<MergeProjectBoardRequest> requests){
        List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest> mergeProjectBoardRequests = new List<leankor.MergeProjectBoardAction.MergeProjectBoardRequest>();
        for(MergeProjectBoardRequest request : requests){
            leankor.MergeProjectBoardAction.MergeProjectBoardRequest mergeProjectBoardRequest = new leankor.MergeProjectBoardAction.MergeProjectBoardRequest();
            mergeProjectBoardRequest.SourceBoardName = request.SourceBoardName;
            mergeProjectBoardRequest.SourceFolderName = request.SourceFolderName;
            mergeProjectBoardRequest.SourceRoomName = request.SourceRoomName;
            mergeProjectBoardRequest.SourceBoardId = request.SourceBoardId;
            mergeProjectBoardRequest.TargetBoardName = request.TargetBoardName;
            mergeProjectBoardRequest.TargetFolderName = request.TargetFolderName;
            mergeProjectBoardRequest.TargetRoomName = request.TargetRoomName;
            mergeProjectBoardRequest.TargetBoardId = request.TargetBoardId;
            mergeProjectBoardRequest.TargetDate = request.TargetDate;
            mergeProjectBoardRequest.LinkFolderName = request.LinkFolderName;
            mergeProjectBoardRequest.LinkRoomName = request.LinkRoomName;
            mergeProjectBoardRequest.LinkBoardName = request.LinkBoardName;
            mergeProjectBoardRequest.LinkBoardId = request.LinkBoardId;
            mergeProjectBoardRequest.LinkKanbanCardName = request.LinkKanbanCardName;
            mergeProjectBoardRequest.LinkKanbanCardId = request.LinkKanbanCardId;
            mergeProjectBoardRequest.WithMC = request.WithMC;
            mergeProjectBoardRequest.initialDate = request.initialDate;

            mergeProjectBoardRequests.add(mergeProjectBoardRequest);
        }
        leankor.MergeProjectBoardAction.mergeProjectBoard(mergeProjectBoardRequests);
        return requests;
    }
}