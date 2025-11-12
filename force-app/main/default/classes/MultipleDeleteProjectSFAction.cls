/*********************************************************************************
* Company     : Leankor
* Description : manages to Delete Project 
*********************************************************************************/ 
global with sharing class MultipleDeleteProjectSFAction {

    global class ProjectRequest {
		@InvocableVariable(label = 'List of Project sObjects' description = 'List of Project records to delete.')
		    global List <leankor__ProjectRoom__c> projectRequests;
		@InvocableVariable(label = 'Send Broadcast Message' description = 'Send the broadcast message on affected board.')
		    global Boolean sendBroadcastMessage = false;        
		@InvocableVariable(label = 'Project Id' description = 'Id of project intended to receive the data to be delivered by the project event platform.')
		    global String projectId;
		@InvocableVariable(label = 'Project Event Custom Payload' description = 'Data to be delivered by the project event platform.')
		    global String projectEventCustomPayload;
	}

    /*------------------------------------------------------------
	    Company:        Leankor
	    Description:    Delete the Project 
	    Inputs:         List of ProjectRequest
	    Returns:        List of ProjectRequest
	------------------------------------------------------------*/
    @InvocableMethod
    global static List<ProjectRequest> deleteProjectProcess(List<ProjectRequest> projectRequests){
        List<Leankor.MultipleDeleteProjectAction.ProjectRequest> allRequest = new List<Leankor.MultipleDeleteProjectAction.ProjectRequest>();
        for(MultipleDeleteProjectSFAction.ProjectRequest singleRequest : projectRequests){
            Leankor.MultipleDeleteProjectAction.ProjectRequest request = new Leankor.MultipleDeleteProjectAction.ProjectRequest();
            request.projectRequests = singleRequest.projectRequests;
            request.sendBroadcastMessage = singleRequest.sendBroadcastMessage;
            request.projectId = singleRequest.projectId;
            request.projectEventCustomPayload = singleRequest.projectEventCustomPayload;

            allRequest.add(request);
        }
        Leankor.MultipleDeleteProjectAction.deleteProjectProcess(allRequest);
        return projectRequests;

    }
}