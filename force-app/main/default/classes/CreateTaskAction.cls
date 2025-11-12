/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CreateTaskAction.cls
* CLASS: CreateTaskAction
* USAGE: manages to Create Task On Card .
*/
global with sharing class CreateTaskAction{
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    
    global class TaskDataRequest{
        @InvocableVariable(label = 'Priority' description = 'Task Priority' )
            global String Priority;
        @InvocableVariable(label = 'Owner ID' description = 'Task Owner ID')
            global String OwnerId;
        @InvocableVariable(label = 'Subject' description = 'Subject On Task')
            global String Subject;
        @InvocableVariable(label = 'Status' description = 'Status Of The Task')
            global String Status;
        @InvocableVariable(label = 'Due Date' description = 'Due Date Of Task' )
            global Date ActivityDate;
        @InvocableVariable(label = 'Related To' description = 'Kanban Card ID on which Task is display')
            global String WhatId;
        @InvocableVariable(label = 'URL' description = 'The URL obtained by clicking on the Copy URL button.')
            global String CardURL;        
        @InvocableVariable(label = 'Description' description = 'Task description')
            global String Description;
    }
    

    // This is execute method for API calls
    @InvocableMethod 
    global static List<insertTaskResult> insertTaskAction(List<TaskDataRequest> remoteRequest){
        //Added Security code for sentize user Input
        for (TaskDataRequest createtaskRequest : remoteRequest) {
            if ((String.isNotBlank(createtaskRequest.WhatId) && Util.getSObjectName(createtaskRequest.WhatId) != 'leankor__KanbanCard__c')){
                throw new Util.LeanException('Error: Invalid input');
            }
        }  
        List<insertTaskResult>  result = new List<insertTaskResult>();
        result.addall(CreateTask(remoteRequest));
        return result;
    }
    

    /*
      Date :30/11/18.
      Input: List<TaskDataRequest>.
      OutPut: List<insertTaskResult>.
      Description : Creating List of Task  .
    */
    public static List<insertTaskResult> CreateTask(List<TaskDataRequest> requestList){
        List<leankor.realTimeController.TaskData> tempObjectlist = new List<leankor.realTimeController.TaskData> ();       
		List<insertTaskResult> resultList = new List<insertTaskResult>();
		List<String> kanbancardIds = new List<String>();
		List<String> jsonListData = new List<String> ();	
		List<String> jsonListData1 = new List<String>();
        //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
		Boolean isGs = false;

		for(TaskDataRequest request : requestList){
		    String tempKanbanId = request.WhatId;
			if(tempKanbanId == null || tempKanbanId == ''){
				tempKanbanId = request.CardURL.substringAfter('cardid=') ;
            }
			kanbancardIds.add(tempKanbanId);
		}   
		
        List<leankor__KanbanCard__c>  kanbancards = [Select Id,
															leankor__Guid__c,
															Name,
															leankor__ValueStream__C,
															leankor__ValueStream__r.leankor__SevenDayWorkWeek__c 
														From leankor__KanbanCard__C 
														Where Id IN:kanbancardIds 
														With Security_Enforced
														Limit 49999];         
        for(TaskDataRequest request : requestList){			
		 	leankor.realTimeController.TaskData tempObject = new leankor.realTimeController.TaskData(); 
		   for(leankor__KanbanCard__C kanban :kanbancards){							
				if(request.whatid==kanban.id){				
					tempObject.Priority=(request.Priority == null ? 'Normal' : request.Priority);
					tempObject.OwnerId = (request.OwnerId == null ? UserInfo.getUserId() : request.OwnerId);
					tempObject.Subject = (request.subject == null ? 'Other' : request.subject);
					tempObject.Status = (request.Status == null ? 'Not Started' : request.Status);
					Date tempActivityDate = (request.ActivityDate == null ? System.today() : request.ActivityDate);
					datetime tskDuedate = Datetime.newInstance(tempActivityDate.year(),tempActivityDate.month(), tempActivityDate.day(), 0, 0, 0);
					if(!kanban.leankor__ValueStream__r.leankor__SevenDayWorkWeek__c){					          
						leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
						Integer firstDayOfWeek = leanConstant.leankor__FirstDayOfTheWeek__c == null || leanConstant.leankor__FirstDayOfTheWeek__c > 6 || leanConstant.leankor__FirstDayOfTheWeek__c < 0 ? 1 :leanConstant.leankor__FirstDayOfTheWeek__c.intValue();	
						Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek,5);        
						tempActivityDate = Util.readNextWorkingDate(workWeek,tskDuedate,tempActivityDate);
					}
					Date tempStartDate = tempActivityDate  ;//- 1
					tempObject.ActivityDate=  String.ValueOf(tempActivityDate);
					tempObject.StartDate = datetime.newInstance(tempStartDate.year(), tempStartDate.month(),tempStartDate.day());
					tempObject.DueDate = datetime.newInstance(tempActivityDate.year(), tempActivityDate.month(),tempActivityDate.day());
					tempObject.WhatId =kanban.id;
					tempObject.Description= (request.Description == null ? '' : request.Description);					
					tempObject.verb= (isGs==true? null: 'CreateTask'); 
					tempObject.flowWithGS = true; 				
					tempObject.ValueStream = kanban.leankor__ValueStream__C ; 
					tempObjectlist.add(tempObject);								
				}
			}			
        }
        
        List<leankor.realTimeController.TaskData> tempreturnlist = leankor.realTimeController.insertTask(tempObjectlist);				
		Integer taskvalue=0;
		for(leankor.realTimeController.TaskData tempreturn:tempreturnlist){							
		    InsertTaskResult result =New InsertTaskResult();
			result.taskID = tempreturn.ID;
			if(result.taskID != null){										
			    tempObjectlist[taskvalue].Id = result.taskID;																										
				}																		
			resultList.add(result);	
		    taskvalue++;									
		}	

		List<leankor.realtimeController.bulkStreaming> listJSONrecords = new List<leankor.realtimeController.bulkStreaming>();
		for(leankor__KanbanCard__C kanbancard:kanbancards){	
			List<leankor.realtimeController.ChatterFeedStats> chatterFeedStatList =leankor.realtimeController.getAllChatterStats(kanbancard.leankor__ValueStream__C);
		  	for(leankor.realtimeController.ChatterFeedStats chatterFeedState:chatterFeedStatList){
		     	if(kanbancard.id==chatterFeedState.id){
		          	ChatterFeedStats newchatterfeed =new ChatterFeedStats();
		             	newchatterfeed.verb= (isGs==true? null: 'NewChatterComments');
		              	newchatterfeed.id= chatterFeedState.id;
		              	newchatterfeed.Guid=kanbancard.leankor__Guid__c;
		              	newchatterfeed.TaskCount=chatterFeedState.TaskCount;
		              	newchatterfeed.CountUnDoneTask=chatterFeedState.CountUnDoneTask;
		              	newchatterfeed.TaskComments=chatterFeedState.TaskCount;		              		              			           				              
		              	newchatterfeed.ValueStream = kanbancard.leankor__ValueStream__C;	              		              			           				              
		            leankor.realtimeController.bulkStreaming listJSONLog = New leankor.realtimeController.bulkStreaming();
				 		listJSONLog.SomeJSONData = JSON.Serialize(newchatterfeed);
				 		listJSONLog.VSID = kanbancard.leankor__ValueStream__C;
				 		listJSONLog.Verb = 'NewChatterComments';
				 		listJSONLog.SessionID = UserInfo.getSessionId();	  	 
			  	 		listJSONrecords.add(listJSONLog);
			  	 		
			  	 if(isGs == true)
		 		   {			 		 			 		 
			 		 string verb = 'NewChatterComments';
			 		 string kanbanJSONData = JSON.serialize(newchatterfeed); 
			 		 kanbanJSONData = kanbanJSONData.removeEndIgnoreCase('}');
					 kanbanJSONData +=  ',"'+'verb'+'":'+'"'+verb+'"'+'}';		 		
			 		 jsonListData.add(kanbanJSONData);
		 		   } 
		     	}		
		  	}		  		  		
		}	
						
		List<leankor.realtimeController.bulkStreaming> listJSONrecords1 = new List<leankor.realtimeController.bulkStreaming>();				 	
		for(leankor.realTimeController.TaskData tempObject:tempObjectlist){	
		 	   if(isGs == true)
		 		 {			 		 			 		 
			 		 string verb = 'CreateTask';
			 		 string kanbanJSONData = JSON.serialize(tempObject); 
			 		 kanbanJSONData = kanbanJSONData.removeEndIgnoreCase('}');
					 kanbanJSONData +=  ',"'+'verb'+'":'+'"'+verb+'"'+'}';		 		
			 		 jsonListData.add(kanbanJSONData);
		 		 } 
		        leankor.realtimeController.bulkStreaming listJSONLog = New leankor.realtimeController.bulkStreaming();
				 listJSONLog.SomeJSONData = JSON.Serialize(tempObject);
				 listJSONLog.VSID = tempObject.ValueStream;
				 listJSONLog.Verb = 'CreateTask';
				 listJSONLog.SessionID = UserInfo.getSessionId();	  	 
			  	 listJSONrecords1.add(listJSONLog);			  	 			  	 				 		
		}	
		// call manageBulkStreaming method for broadcast.	 	 	 		 		
		leankor.realtimeController.manageBulkStreaming(listJSONrecords1, 'CreateTask');
		leankor.realtimeController.manageBulkStreaming(listJSONrecords, 'NewChatterComments');
		if(isGs == true){							
				GenericStreamingController.broadcastNotificationAsync('CreateTask',jsonListData);
		}																											
        return resultList;
    }   

    
    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    global class insertTaskResult{ 
        @InvocableVariable(label = 'Task Id' description = 'Id of New Task')
            global ID taskID;
    }

    public class ChatterFeedStats{
       public String Id;
       public Decimal TaskCount;  
       public Integer CountUnDoneTask; 
       public Decimal TaskComments;
       public String verb;
       public Integer ChatterComments;
       public String Guid;
       public String ValueStream;
    }
}