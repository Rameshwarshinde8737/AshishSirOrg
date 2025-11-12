/**
 Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 FILE: OpportunityTriggerHandler.cls
 CLASS: OpportunityTriggerHandler
*/
Public with sharing class OpportunityTriggerHandler{
    //
    // This  method is rune On Insert Of opportunity and create Card on dependent of Automation Templates.
    //
    public void OnAfterInsert(Object[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
        Boolean Opportunity_recordtype = false ;
        integer DateDiffrence = 0;
    List<leankor.RealTimeController.bulkStreaming> tempBulkStreamingData = new List<leankor.RealTimeController.bulkStreaming>();
    List<String> JSONList = new List<String>();
    List<leankor.realTimeController.TaskData> taskJSONs = New List<leankor.realTimeController.TaskData>();
        Opportunity[] Newopporunities = (Opportunity[]) newObjects;
        //RS 29/11/2019 Added Owner.IsActive to query
        list<leankor__AutomationTemplate__c> Autmationlogs = [ SELECT Owner.IsActive,leankor__JSONDefinition__c,leankor__ColumnTitle__c,leankor__StartDate__c,leankor__KanbanCardTemplate__r.leankor__Color__c,leankor__ValueStreamLink__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__r.leankor__BoardType__c,leankor__KanbanCardTemplate__r.Name,leankor__ValueStream__r.leankor__BoardType__c,leankor__ValueStream__r.leankor__PointPicklist__c,owner.Name,leankor__Account__c,leankor__Account__r.Name,leankor__zone__r.leankor__Swimlane__c,leankor__zone__r.leankor__Swimlane__r.leankor__MasterContainer__c,leankor__Zone__r.leankor__GUID__c,leankor__EndDate__c,leankor__GUID__c,leankor__KanbanCardTemplate__c,leankor__ProjectRoom__c,leankor__RecordTypeID__c,leankor__RecordTypeName__c,leankor__RoleId__c,leankor__RoleName__c,leankor__StageName__c,leankor__ValueStream__c,leankor__Zone__c,Name,OwnerId,leankor__KanbanCardTemplate__r.leankor__Width__c,leankor__KanbanCardTemplate__r.leankor__Title__c,leankor__KanbanCardTemplate__r.leankor__Height__c,leankor__KanbanCardTemplate__r.leankor__JSONData__C,leankor__KanbanCardTemplate__r.leankor__JSONDefinition__C,(SELECT Id,leankor__ActivityDate__c,leankor__GUID__c,leankor__AutomationTemplate__c,leankor__Description__c,leankor__Priority__c,leankor__Status__c,Name,OwnerId FROM leankor__AutomationTemplate__c.leankor__TaskTemplates__r ) FROM leankor__AutomationTemplate__c Limit 9999];
        List<UserRole> AllRoles = [select Id,Name, ParentRoleId from UserRole LIMIT 49999];
        Map<String,String> newKanbanMap = new Map<String,String>();
        List<leankor.realTimeController.TaskData> TaskLogs = New List<leankor.realTimeController.TaskData>();
        List<RecordType> RecordTypes = leankor.realtimeController.getActiveRecordType('Opportunity');
        set<String> opptype = New Set<string>();
        For(RecordType RecordType1 : RecordTypes){
            opptype.add(RecordType1.id);
        }
        Integer tempCount = 1;
        for(Opportunity myOpportunity : Newopporunities){
           for(leankor__AutomationTemplate__c newautomationlog :Autmationlogs){

                Boolean AccountFlag = false;
               if(opptype.Size()>0 && myOpportunity.get('RecordTypeId') == newautomationlog.leankor__RecordTypeId__c){
                        Opportunity_recordtype = true;
                       
                }else if(opptype.Size() == 0){
                    Opportunity_recordtype = true;
                }else{
                    Opportunity_recordtype = false;
                }
                //Checking matching account Id available or not . if not matching then template accountId should be null.
                if(myOpportunity.AccountId == newautomationlog.leankor__Account__c || (newautomationlog.leankor__Account__c == null && myOpportunity.AccountId != null)){
                    AccountFlag = true;
                }//End of If                
              set<String> DownRolesId = leankor.ProjectBoardCarousel.GetDownrolesId(newautomationlog.leankor__RoleId__c,AllRoles);
               if(myOpportunity.StageName == newautomationlog.leankor__StageName__c && Opportunity_recordtype &&(DownRolesId.contains(Userinfo.getUserRoleId()) || Userinfo.getUserRoleId()==null ) && AccountFlag){
                    leankor.realtimeController.Kanban card = new leankor.realtimeController.Kanban();
                        card.Priority = 4;
                        card.ValueStreamCardLink = (newautomationlog.leankor__ValueStreamCardLink__c == Null ? '' :newautomationlog.leankor__ValueStreamCardLink__c);
                        card.ValueStreamLinkID = (newautomationlog.leankor__ValueStreamLink__c == null ? '' :newautomationlog.leankor__ValueStreamLink__c);
                        card.ValueStreamLinkBoardType = (newautomationlog.leankor__ValueStreamLink__r.leankor__BoardType__c == Null ? '' :newautomationlog.leankor__ValueStreamLink__r.leankor__BoardType__c);
                        card.CmpID = 'ext-kanban-'+tempCount;
                        card.OwnerName = newautomationlog.owner.Name ;
                        card.BoardType = newautomationlog.leankor__ValueStream__r.leankor__BoardType__c;
                        card.OnBudget = 'Green';
                        card.OnQuality = 'Green';
                        card.OnTime = 'Green';
                        card.HarveyBall = '0';
                        if(newautomationlog.leankor__ValueStream__r.leankor__PointPicklist__c != null){
                            List<Integer> ListPoint = (List<Integer>)JSON.Deserialize(newautomationlog.leankor__ValueStream__r.leankor__PointPicklist__c, List<integer>.class);
                            card.point = (ListPoint.size() <= 0 ?1 : ListPoint[0]);
                        }
                        Date dToday = myOpportunity.CloseDate;
                        card.OpportunityStage = myOpportunity.stageName ;
                        DateDiffrence = newautomationlog.leankor__EndDate__c.Date().daysBetween(datetime.newInstance(dToday.year(), dToday.month(),dToday.day()).Date()) ;
                      //  card.JSONData = (newautomationlog.leankor__KanbanCardTemplate__c == Null? '{}':newautomationlog.leankor__KanbanCardTemplate__r.leankor__JSONData__C);
                        card.JSONData = Json.serialize(myOpportunity);
                        card.JSONDefinition =  (newautomationlog.leankor__JSONDefinition__c == Null ? '{}': newautomationlog.leankor__JSONDefinition__c);
                        card.JSONDefinition = (card.JSONDefinition).unescapeHtml4();
                         //card.JSONDefinition =  (newautomationlog.leankor__KanbanCardTemplate__c == Null ? '{}':newautomationlog.leankor__KanbanCardTemplate__r.leankor__JSONDefinition__C);
                        card.ZoneID = newautomationlog.leankor__Zone__r.leankor__GUID__c;
                        card.SWForceID = newautomationlog.leankor__Zone__r.leankor__Swimlane__c;
                        card.MCForceID = newautomationlog.leankor__Zone__r.leankor__Swimlane__r.leankor__MasterContainer__c;
                        card.ZoneForceID = newautomationlog.leankor__Zone__c;
                        card.ZoneTitle = (newautomationlog.leankor__ColumnTitle__c == Null ? '' :newautomationlog.leankor__ColumnTitle__c); 
                        card.TemplateName = newautomationlog.leankor__KanbanCardTemplate__r.Name ;
                        card.EstimatedDuration = newautomationlog.leankor__StartDate__c.Date().daysBetween(newautomationlog.leankor__EndDate__c.Date())+1; //Calculate this one
                        card.DurationUnits = 'Days';
                        card.Color = (newautomationlog.leankor__KanbanCardTemplate__c == Null? '#FAFFBD' :newautomationlog.leankor__KanbanCardTemplate__r.leankor__Color__c); 
                        card.GUID = myOpportunity.Id+'-'+System.Now().getTime()+'-k'+tempCount;
                        card.Name = myOpportunity.Name;
                        card.Name = card.Name.mid(0, 80);
                        card.DueDate = datetime.newInstance(dToday.year(), dToday.month(),dToday.day(), 01, 01, 01);
                        card.OwnerId = newautomationlog.OwnerId;
                        card.Description = (myOpportunity.Description == null ? '' : myOpportunity.Description);
                        card.ValueStream = newautomationlog.leankor__ValueStream__c;
                        card.Account = (newautomationlog.leankor__Account__c == null ? '' :newautomationlog.leankor__Account__c);
                        card.AccountName = (newautomationlog.leankor__Account__c == null ? '' : newautomationlog.leankor__Account__r.Name);
                        card.Opportunity = (myOpportunity.ID == null ? '' :myOpportunity.ID );
                        card.OpportunityName = (myOpportunity.ID == null ? '' : myOpportunity.Name);
                        card.leavedZoneId ='';
                        card.StartDate = newautomationlog.leankor__StartDate__c + DateDiffrence;
                        card.Order = 999 ; //DateTime.now().getTime();
                        card.Width = (newautomationlog.leankor__KanbanCardTemplate__c == Null? 150 :newautomationlog.leankor__KanbanCardTemplate__r.leankor__Width__c) ;
                        card.Height = (newautomationlog.leankor__KanbanCardTemplate__c == Null? 100 :newautomationlog.leankor__KanbanCardTemplate__r.leankor__Height__c);
                        card.Title = newautomationlog.leankor__KanbanCardTemplate__r.Name;
                        card.TemplateId = newautomationlog.leankor__KanbanCardTemplate__c;
                        card.TaskComments = newautomationlog.leankor__TaskTemplates__r.size();
                        card.EffortRemaining =integer.valueof(card.EstimatedDuration);
                        card.X = 100;
                        card.Y = 100;
                        card.Top = 2100;
                        card.Left = 2100;
                        card.Bottom = 0;
                        card.CaseTrigger = true;  
                        card.BoardType=newautomationlog.leankor__ValueStream__r.leankor__BoardType__c;                       
                        //RS 29/11/2019 Added Owner.IsActive in object
                        card.ownerIsActive = newautomationlog.owner.IsActive;                     
                    String JSONPackage=JSON.serialize(card);
                    JSONList.add(JSONPackage);
         
            IF(newautomationlog.leankor__TaskTemplates__r.size()>0){
                  for( leankor__TaskTemplate__c tasklog : newautomationlog.leankor__TaskTemplates__r){
                      leankor.realTimeController.TaskData taskJSON = New leankor.realTimeController.TaskData();
                        taskJSON.Priority = tasklog.leankor__Priority__c;
                        taskJSON.OwnerId = tasklog.OwnerId;
                        taskJSON.Subject = tasklog.Name;
                        taskJSON.Status = tasklog.leankor__Status__c;
                        DateTime TasDate = tasklog.leankor__ActivityDate__c + DateDiffrence;
                        if(TasDate < (card.StartDate)){
                        taskJSON.ActivityDate = String.ValueOf(card.StartDate);
                        }else if(TasDate > card.DueDate ){
                        taskJSON.ActivityDate = String.Valueof(card.DueDate);
                        }else {
                        taskJSON.ActivityDate =String.ValueOf(TasDate);
                        }
                        taskJSON.WhatId = card.GUID;
                        taskJSON.Description = (tasklog.leankor__Description__c == null ? '' :tasklog.leankor__Description__c);
                        taskJSON.ValueStream = newautomationlog.leankor__ValueStream__c;
                      taskJSONs.add(taskJSON);
                      
                    }    
                  }
         
         } // End Of If
                tempCount++;
            }  // End Of Loop
        } // End Of Loop
        
        //RS 13.03.2019 Fix for opportunity card broadcast is not working on kb 
        List<String> newInstanceKanbanCards = new List<String>(JSONList); 
        
        List<leankor__KanbanCard__C> KanbanCards = leankor.realtimeController.createkanbancard('',JSONList);
       
       if(KanbanCards.Size() > 0){
       		
       		//creating default RA and SM                      
	        leankor.GanttTaskBoard.CreateScheduleMode(KanbanCards);
	        leankor.GanttTaskBoard.CreateDefaultResourceAssignment(KanbanCards);                                  
      
            for(leankor__KanbanCard__C kanban : KanbanCards){ 
              newKanbanMap.put(kanban.leankor__GUID__C,kanban.Id);
            }//End of for loop
          
      for(leankor.RealTimeController.TaskData tempString : taskJSONs){ 
      String tempWhatId = (newKanbanMap.ContainsKey(tempString.WhatId) ? newKanbanMap.get(tempString.WhatId) : null);
      tempString.WhatId = tempWhatId;
      }
      
      List<leankor.realTimeController.TaskData> resultTask = new List<leankor.realTimeController.TaskData>();
      if(taskJSONs.Size() > 0){
      
        try {
            resultTask = leankor.RealTimeController.InsertTask(taskJSONs);
        }catch(Exception ex){
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        
        
      }
      
       }
       
      //RS 13.03.2019 Fix for opportunity card broadcast is not working on kb       
	  //for(String tempString: JSONList){
	    for(String tempString: newInstanceKanbanCards){  
      leankor.realtimeController.Kanban remoteCard  = (leankor.realtimeController.Kanban) JSON.Deserialize(tempString, leankor.realtimeController.Kanban.Class);
      remoteCard.Id = newKanbanMap.get(remoteCard.GUID);
      remoteCard.ForceID = newKanbanMap.get(remoteCard.GUID);
       String tempJSONPackage =JSON.serialize(remoteCard);
              leankor.RealTimeController.bulkStreaming tempStreaming = new leankor.RealTimeController.bulkStreaming();
        tempStreaming.VSID = remoteCard.ValueStream;
        tempStreaming.Verb = 'CreateKanbanCard';
        tempStreaming.SessionID = UserInfo.getSessionId();
        tempStreaming.SomeJSONData = tempJSONPackage;
        if(remoteCard.Id != Null && remoteCard.Id != ''){
            tempBulkStreamingData.add(tempStreaming);
        }      
      }//End of Loop
       leankor.RealTimeController.manageBulkStreaming(tempBulkStreamingData,'CreateKanbanCard');
    }// End OF Method

}// End of Class