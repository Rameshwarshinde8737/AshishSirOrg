global with sharing class CreateTaskSFAction {
    global class TaskDataRequest{
        @InvocableVariable(label='Priority' description='Task Priority' )
            global String Priority;
        @InvocableVariable(label='Owner ID' description='Task Owner ID')
            global String OwnerId;
        @InvocableVariable(label='Subject' description='Subject On Task')
            global String Subject;
        @InvocableVariable(label='Status' description='Status Of The Task')
            global String Status;
        @InvocableVariable(label='Due Date' description='Due Date Of Task' )
            global Date ActivityDate;
        @InvocableVariable(label='Related To' description='Kanban Card ID on which Task is display')
            global String WhatId;
        @InvocableVariable(label = 'URL' description = 'The URL obtained by clicking on the Copy URL button.')
            global String CardURL;        
        @InvocableVariable(label='Description' description='Task description')
            global String Description;
    }

    @InvocableMethod 
    global static List<TaskDataRequest> insertTaskAction(List<TaskDataRequest> requests){
        List<leankor.CreateTaskAction.TaskDataRequest> taskDataRequests = new List<leankor.CreateTaskAction.TaskDataRequest>();
        for(TaskDataRequest request : requests){
            leankor.CreateTaskAction.TaskDataRequest taskDataRequest = new leankor.CreateTaskAction.TaskDataRequest();
            taskDataRequest.Priority = request.Priority;
            taskDataRequest.OwnerId = request.OwnerId;
            taskDataRequest.Subject = request.Subject;
            taskDataRequest.Status = request.Status;
            taskDataRequest.ActivityDate = request.ActivityDate;
            taskDataRequest.WhatId = request.WhatId;
            taskDataRequest.CardURL = request.CardURL;
            taskDataRequest.Description = request.Description;

            taskDataRequests.add(taskDataRequest);
        }

        leankor.CreateTaskAction.insertTaskAction(taskDataRequests);
        return requests;
    }
}