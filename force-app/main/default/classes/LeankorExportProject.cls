@RestResource(urlMapping='/v1/extract-projects/*')
global with sharing class LeankorExportProject {
    @HttpPost
    global static List<MultipleExportProjectBoardAction.MultipleExportProjectBoardResult> exportProjects (List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest> requests) {
        List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest> requestList = new List<MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest>();

        for (MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest request : requests) {
            MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest addRequest = new MultipleExportProjectBoardAction.MultipleExportProjectBoardRequest();
            addRequest.projectId = request.projectId;
            addRequest.vsId = request.vsId;
            addRequest.isReturnJSONString = request.isReturnJSONString;
            addRequest.isWriteFile = request.isWriteFile;
            requestList.add(addRequest);
        }

        return MultipleExportProjectBoardAction.exportProjectBoardProcess(requestList);
    }
}