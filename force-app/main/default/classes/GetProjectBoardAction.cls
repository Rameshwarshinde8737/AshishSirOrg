/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  GetProjectBoardAction.cls
* CLASS: GetProjectBoardAction
* USAGE: manages to Get record of Porject Board .
*/
Global with sharing class GetProjectBoardAction{
    //
    // This method is for get Project Board ID BY API calls
    //
    @InvocableMethod
    Global static List<ProjectBoardResult>  getProjectBoard(List<ProjectBoardRequest> requests){
        List<ProjectBoardResult> results = new List<ProjectBoardResult>();
        for (ProjectBoardRequest request : requests) {
            results.addAll(findProjectBoard(request));
        }
        return results;
    } 
    //
    // This use for bulk API Recoeds And Return ProjectBoardIDs
    //
    public static List<ProjectBoardResult> findProjectBoard(ProjectBoardRequest request) { 
        List<leankor__ValueStream__C> ValueStreamList =  new List<leankor__ValueStream__C> ();
        try {
        	if (request.ProjectFolderName!=Null && request.ProjectFolderName!='') {
        		ValueStreamList = [Select Id, 
                                            Name 
                                        From leankor__ValueStream__c
                                        Where Name =:request.ProjectBoardName
                                            And  leankor__ProjectRoom__r.Name =:request.ProjectRoomName 
                                            And leankor__ProjectRoom__r.leankor__Portfolio__r.Name = :request.ProjectFolderName 
                                        With Security_Enforced
                                        Limit 9999];
        	} else {
            	ValueStreamList = [Select Id, 
                                            Name 
                                        From leankor__ValueStream__c
                                    Where Name =:request.ProjectBoardName 
                                        And  leankor__ProjectRoom__r.Name =:request.ProjectRoomName 
                                    With Security_Enforced
                                    Limit 9999];
        	}
        } catch (Exception e) {
            //25/04/2023 : We are Throwing Exception
	        throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        List<ProjectBoardResult> ProjectBoardIDList = new List<ProjectBoardResult>();
        for (leankor__ValueStream__C vs : ValueStreamList) {
            ProjectBoardResult ProjectBoard = new ProjectBoardResult();
            String VSID = vs.Id;
            ProjectBoard.ProjectBoardId =(VSID).substring(0, 15);
            ProjectBoardIDList.add(ProjectBoard);
        }
        return ProjectBoardIDList;
    }
    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    Global class ProjectBoardRequest{   
        @invocableVariable(label = 'Project Board Name' description = 'The name of the Project Board.' required=true)
            Global String ProjectBoardName;
        @invocableVariable(label = 'Project Room Name' description = 'The name of the Project Room in which the Project Board resides.' required=true)
            Global String ProjectRoomName;
        @invocableVariable(label='Project Folder Name' description='Name of the Folder where its Room would located.')
            Global String ProjectFolderName;
    }
    //
    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    //
    Global class ProjectBoardResult{    
        @invocableVariable(label = 'Project Board ID' description = 'The ID of the Project Board.' required=true)
            Global String ProjectBoardId;
    }
}