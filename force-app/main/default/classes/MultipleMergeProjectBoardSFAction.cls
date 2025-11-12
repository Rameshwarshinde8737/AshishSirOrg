global with sharing class MultipleMergeProjectBoardSFAction {
    global class MultipleMergeProjectBoardActionRequest{
        @InvocableVariable(label = 'Source Board Ids' description = 'IDs of the Project Board which to be merge.')
            global List<String> SourceBoardId;
        @InvocableVariable(label = 'Target Board Id' description = 'ID of the Project Board where to be merge.')
            global String TargetBoardId;
        @InvocableVariable(label='Due Date' description='Provide the final Due Date for the Card farthest in the future.')
            global DateTime TargetDate;
        @InvocableVariable(label='Link Board Id' description='ID of the Link Board to Linked with merge Cards.')
            global String LinkBoardId;        
        @InvocableVariable(label='Link Kanban Card ID' description='Name of Link Kanban Card Which to linked with merge Cards .')
            global String LinkKanbanCardId;
        @InvocableVariable(label = 'Is Master Container' required=true description = 'Verb, which check merge Board with MC  .')
            global Boolean WithMC;
        @InvocableVariable(label='Start Date' description='Provide the initial Start Date for the Card farthest in the future.')
            global DateTime initialDate;
    }

    @InvocableMethod 
    global static List<MultipleMergeProjectBoardActionRequest> multipleMergeProjectBoard(List<MultipleMergeProjectBoardActionRequest> requests){
        List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest> multipleMergeProjectBoardActionRequests = new List<leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest>();
        for(MultipleMergeProjectBoardActionRequest request : requests){
            leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest multipleMergeProjectBoardActionRequest = new leankor.MultipleMergeProjectBoardAction.MultipleMergeProjectBoardActionRequest();
            multipleMergeProjectBoardActionRequest.SourceBoardId = request.SourceBoardId;
            multipleMergeProjectBoardActionRequest.TargetBoardId = request.TargetBoardId;
            multipleMergeProjectBoardActionRequest.TargetDate = request.TargetDate;
            multipleMergeProjectBoardActionRequest.LinkBoardId = request.LinkBoardId;
            multipleMergeProjectBoardActionRequest.LinkKanbanCardId = request.LinkKanbanCardId;
            multipleMergeProjectBoardActionRequest.WithMC = request.WithMC;
            multipleMergeProjectBoardActionRequest.initialDate = request.initialDate;

            multipleMergeProjectBoardActionRequests.add(multipleMergeProjectBoardActionRequest);
        }
        leankor.MultipleMergeProjectBoardAction.multipleMergeProjectBoard(multipleMergeProjectBoardActionRequests);
        return requests;
    }
}