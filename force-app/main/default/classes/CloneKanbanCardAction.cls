/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CloneKanbanCardAction.cls
* CLASS: CloneKanbanCardAction
* USAGE: manages for Cloning Card .
*/
global with sharing Class CloneKanbanCardAction {
    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    global Class CloneKanbanCardRequest{
        @invocableVariable(label = 'Due Date' description = 'The deadline for the deliverable.' )
            global DateTime FinalDate;
        @invocableVariable(label = 'Start Date' description = 'The start date for the deliverable.' )
            global DateTime StartDate;
        @invocableVariable(label = 'Kanban Card ID' description = 'You must provide either this Card ID or the URL obtained from the Copy URL button.' )
            global ID KanbanID;
        @invocableVariable(label = 'URL' description = 'The URL obtained from clicking on the Copy URL button of a Card.')
            global String CardURL;
         // Linked Folder,Linked Room, Linked Board, Linked Card
        @invocableVariable(label = 'Linked Folder Name' description = 'Name of the Linked Folder where Linked Room would located.')
            global String LinkedFolderName;       
        @invocableVariable(label = 'Linked Room Name' description = 'Name of the Link Project Room where Linked Board is located.')
            global String LinkedRoomName;
        @invocableVariable(label = 'Linked Board Name' description = 'Name of the Link Board to Linked .')
            global String LinkedBoardName;
        @invocableVariable(label = 'Link Board Id' description = 'ID of the Link Board to Linked with merge Cards.')
            global String LinkedBoardId;        
        @invocableVariable(label = 'Linked Card Name' description = 'Name of Link Kanban Card Which to linked.')
            global String LinkedCardName;
        @invocableVariable(label = 'Linked Card ID' description = 'Name of Link Kanban Card Which to linked.')
            global String LinkedCardId;        
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
		    global Boolean generateWorkBreakdownStructure = false;        
    }
    global Class CloneKanbanCardResult {
        @invocableVariable(label = 'New Kanbancard ID' description = '' )
        global ID kanbanCardId;
    }
    //
    // This method is for clone kanban card by API calls
    // INPUT :- Invocable variables which mentioned in method (CloneKanbanCardRequest)
    // OUTPUT :- Void 
    // 
    @InvocableMethod
    global static void CloneKanbanCards(List<CloneKanbanCardRequest> requests) {
        // Abhishek : 11/10/2022 : Added Security code for sentize user Input
        for (CloneKanbanCardRequest cloneRequests : requests) {
            if ((String.isNotBlank(cloneRequests.KanbanID) && Util.getSObjectName(cloneRequests.KanbanID) != 'leankor__KanbanCard__c')
            ||(String.isNotBlank(cloneRequests.LinkedBoardId) && Util.getSObjectName(cloneRequests.LinkedBoardId) != 'leankor__ValueStream__c')
            ||(String.isNotBlank(cloneRequests.LinkedCardId) && Util.getSObjectName(cloneRequests.LinkedCardId) != 'leankor__KanbanCard__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<CloneKanbanCardResult> returnList = new List<CloneKanbanCardResult>();
        for (CloneKanbanCardRequest request : requests) {
            request.FinalDate = ((request.FinalDate == NULL && request.StartDate==null) ? system.now() : request.FinalDate);
            CloneKanbanCardResult returnId = new CloneKanbanCardResult();
            string result = cloneKanbanCardRecord(request);
            returnId.kanbanCardId = result;
            returnList.add(returnId);
        }
    // return  returnList ;
    } 

    public static String cloneKanbanCardRecord(CloneKanbanCardRequest request) {
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!taskBehaviour.isAccessible() || !kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        String mySessionID = UserInfo.getSessionId();
        leankor__Kanbancard__c oldKanbanCard = New leankor__Kanbancard__c ();
        String tempKanbanId = request.KanbanID;       
        
        leankor__Portfolio__c linkFolder = new leankor__Portfolio__c();            
        leankor__ValueStream__c linkBoard = new leankor__ValueStream__c();
        leankor__ProjectRoom__c linkRoom = new leankor__ProjectRoom__c();
        leankor__KanbanCard__c linkCard = New leankor__Kanbancard__c();
        try {
            if (request.LinkedCardId == null || request.LinkedCardId == '') {
                if (request.LinkedCardName != '' && request.LinkedCardName != Null) {
                    if (request.LinkedBoardId == null || request.LinkedBoardId == '') {
                        if (request.LinkedBoardName != '' && request.LinkedBoardName != Null && request.LinkedRoomName != '' && request.LinkedRoomName != Null ) {
                            if (request.LinkedFolderName != '' && request.LinkedFolderName != Null) {
                                LinkCard = [Select Id,
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c,leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name 
                                                From leankor__Kanbancard__c 
                                                Where Name = :request.LinkedCardName
                                                    And leankor__ValueStream__r.Name =:request.LinkedBoardName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name=:request.LinkedRoomName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name = :request.LinkedFolderName  
                                                With Security_Enforced 
                                                Limit 1];
                            } else {
                                LinkCard = [Select Id,
                                                    Name,
                                                    leankor__ValueStream__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                    leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name 
                                                From leankor__Kanbancard__c
                                                Where Name = :request.LinkedCardName 
                                                    And leankor__ValueStream__r.Name =:request.LinkedBoardName 
                                                    And leankor__ValueStream__r.leankor__ProjectRoom__r.Name=:request.LinkedRoomName 
                                                With Security_Enforced 
                                                Limit 1];
                            }
                        }
                    } else {
                        LinkCard = [Select Id,
                                            Name,
                                            leankor__ValueStream__c,
                                            leankor__ValueStream__r.leankor__ProjectRoom__c,
                                            leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name  
                                        From leankor__Kanbancard__c 
                                        Where Name = :request.LinkedCardName 
                                            And leankor__ValueStream__c =:request.LinkedBoardId
                                        With Security_Enforced
                                        Limit 1];
                    }
                }   
            } else {
                    LinkCard = [Select Id,
                                        Name,
                                        leankor__ValueStream__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name From leankor__Kanbancard__c 
                                        Where Id =:request.LinkedCardId  
                                        With Security_Enforced 
                                        Limit 1];
            }
            if (LinkCard.ID == Null) {
                if (request.LinkedBoardId==null || request.LinkedBoardId=='') {
                    if (request.LinkedBoardName != '' && request.LinkedBoardName != Null && request.LinkedRoomName != '' && request.LinkedRoomName != Null) {
                        if (request.LinkedFolderName != '' && request.LinkedFolderName != Null) {
                            LinkRoom = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c
                                            Where Name = :request.LinkedRoomName 
                                                And leankor__Portfolio__c =:LinkFolder.ID 
                                            With Security_Enforced 
                                            Limit 1];
                        } else {
                            LinkRoom = [Select Id,
                                                Name 
                                            From leankor__ProjectRoom__c 
                                            Where Name = :request.LinkedRoomName  
                                            With Security_Enforced  
                                            Limit 1];
                        } 
                        LinkBoard= [Select Id,
                                            Name 
                                        From leankor__ValueStream__c 
                                        Where Name =:request.LinkedBoardName 
                                            And leankor__ProjectRoom__c =:LinkRoom.ID 
                                        With Security_Enforced  
                                        Limit 1];         
                    }
                } else {
                    LinkBoard = [Select Id,
                                        Name,
                                        leankor__ProjectRoom__c
                                    From leankor__ValueStream__c 
                                    Where ID = :request.LinkedBoardId 
                                    With Security_Enforced  
                                    Limit 1]; 

                    LinkRoom = [Select Id,
                                        Name,
                                        leankor__Portfolio__c  
                                        From leankor__ProjectRoom__c 
                                        Where Id = :LinkBoard.leankor__ProjectRoom__c
                                        With Security_Enforced  
                                        Limit 1 ];
                // LinkFolder = [Select Id,Name From leankor__Portfolio__c Where ID = :LinkRoom.leankor__Portfolio__c  Limit 1 ];
                }
            } else {
                LinkBoard.ID=LinkCard.leankor__ValueStream__c;
                LinkRoom.ID=LinkCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
            // LinkFolder.ID = LinkCard.leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__c;
            } 
        } catch (Exception e) {
                //25/04/2023 : We are Throwing Exception
                throw new Util.LeanException('ERROR:' + e.getMessage());
        }       
                
        if (tempKanbanId == null || tempKanbanId == '') {
            tempKanbanId = request.CardURL.substringAfter('cardid=') ;
        }      
        try{
            //ss 28.03.2018
            //modified to query Task records in a separate list
            //oldKanbanCard = [Select Id,(Select Id from Tasks), leankor__AcceptanceCriteria__c,leankor__CardID__c,LastModifiedDate,leankor__Point__c,leankor__EffortRemaining__c,leankor__UrlLink__c,CreatedDate, leankor__Account__c,leankor__ActualDuration__c,leankor__Actual_Time_Taken__c,leankor__Bottom__c,leankor__Budgeted_Time__c,leankor__BudgetTimeComplete__c,leankor__BudgetTimeRemaining__c,leankor__CardDetails__c,leankor__Case__c,leankor__CmpID__c,leankor__Color__c,leankor__CompletionVariance__c,leankor__Contact__c,leankor__CSSLayout__c,leankor__DateColor__c,leankor__DescriptionLong__c,leankor__Description__c,leankor__DueDateTime__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__EstimatedDuration__c,leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__IsCompletedOnTime__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__Left__c,leankor__OnBudget__c,leankor__OnQuality__c,leankor__OnTime__c,leankor__Opportunity__c,leankor__MasterContainer__c,leankor__Swimlane__c,leankor__Zone__c,leankor__Order__c,leankor__PercentComplete2__c,leankor__Priority__c,leankor__PromiseCompletionDate__c,leankor__StartDateTime__c,leankor__StartDate__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStreamLink__r.leankor__BoardType__C,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__ZoneGUID__c,Name,OwnerId FROM leankor__KanbanCard__c Where ID =:tempKanbanId Limit 1];
            //removed subquery for Task object
            oldKanbanCard = [Select Id,
                                    leankor__AcceptanceCriteria__c,
                                    leankor__CardID__c,
                                    leankor__SeriesNumber__c,
                                    LastModifiedDate,
                                    leankor__Point__c,
                                    leankor__EffortRemaining__c,
                                    leankor__UrlLink__c,
                                    CreatedDate, 
                                    leankor__Account__c,
                                    leankor__ActualDuration__c,
                                    leankor__Actual_Time_Taken__c,
                                    leankor__Bottom__c,
                                    leankor__Budgeted_Time__c,
                                    leankor__BudgetTimeComplete__c,
                                    leankor__BudgetTimeRemaining__c,
                                    leankor__CardDetails__c,
                                    leankor__Case__c,
                                    leankor__CmpID__c,
                                    leankor__Color__c,
                                    leankor__CompletionVariance__c,
                                    leankor__Contact__c,
                                    leankor__CSSLayout__c,
                                    leankor__DateColor__c,
                                    leankor__DescriptionLong__c,
                                    leankor__Description__c,
                                    leankor__DueDateTime__c,
                                    leankor__DueDate__c,
                                    leankor__DurationUnits__c,
                                    leankor__EstimatedDuration__c,
                                    leankor__GUID__c,
                                    leankor__HarveyBallDoneDate__c,
                                    leankor__Height__c,
                                    leankor__IsCompletedOnTime__c,
                                    leankor__JSONData__c,
                                    leankor__JSONDefinition__c,
                                    leankor__KanbanCardTemplate__c,
                                    leankor__Left__c,
                                    leankor__OnBudget__c,
                                    leankor__OnQuality__c,
                                    leankor__OnTime__c,
                                    leankor__Opportunity__c,
                                    leankor__MasterContainer__c,
                                    leankor__Swimlane__c,
                                    leankor__Zone__c,
                                    leankor__Order__c,
                                    leankor__PercentComplete2__c,
                                    leankor__Priority__c,
                                    leankor__PromiseCompletionDate__c,
                                    leankor__StartDateTime__c,
                                    leankor__StartDate__c,
                                    leankor__State__c,
                                    leankor__Title__c,
                                    leankor__Top__c,
                                    leankor__ValueStreamCardLink__c,
                                    leankor__ValueStreamLink__c,
                                    leankor__ValueStreamLink__r.leankor__BoardType__C,
                                    leankor__ValueStream__c,
                                    leankor__Width__c,
                                    leankor__X__c,
                                    leankor__Y__c,
                                    leankor__ZoneGUID__c,
                                    Name,
                                    OwnerId,
                                    RecordType.Name
                            From leankor__KanbanCard__c 
                            Where Id =:tempKanbanId 
                            Limit 1];
            //ss 28.03.2018
        } catch (Exception e) {
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }

        leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
        remoteKanban.Id = oldKanbanCard.Id;
        remoteKanban.ForceID = oldKanbanCard.Id;
        remoteKanban.AcceptanceCriteria= oldKanbanCard.leankor__AcceptanceCriteria__c;
        remoteKanban.CardId = oldKanbanCard.leankor__CardID__c;
        remoteKanban.seriesNumber = Integer.valueOf(oldKanbanCard.leankor__SeriesNumber__c); 
        remoteKanban.GUID = oldKanbanCard.Id+'-'+System.now().getTime()+'-k01';
        remoteKanban.Title = oldKanbanCard.leankor__Title__C;
        remoteKanban.Name = oldKanbanCard.Name;
        remoteKanban.Top = oldKanbanCard.leankor__Top__c;
        remoteKanban.Point = oldKanbanCard.leankor__Point__c;
        remoteKanban.EffortRemaining = integer.valueof(oldKanbanCard.leankor__EffortRemaining__c);
        remoteKanban.Bottom = oldKanbanCard.leankor__Bottom__c;
        remoteKanban.Left = oldKanbanCard.leankor__Left__C;
        remoteKanban.Width = oldKanbanCard.leankor__Width__C;
        remoteKanban.Height = oldKanbanCard.leankor__Height__C;
        remoteKanban.X = oldKanbanCard.leankor__X__C;
        remoteKanban.Y = oldKanbanCard.leankor__Y__C;
        remoteKanban.JSONDefinition = oldKanbanCard.leankor__JSONDefinition__C;
        remoteKanban.JSONData = oldKanbanCard.leankor__JSONData__c;
        remoteKanban.TemplateID = oldKanbanCard.leankor__KanbanCardTemplate__C;
        remoteKanban.Color = oldKanbanCard.leankor__Color__c;
        remoteKanban.Description = oldKanbanCard.leankor__DescriptionLong__C;
        remoteKanban.DueDate = oldKanbanCard.leankor__DueDate__C;
        remoteKanban.EstimatedDuration = oldKanbanCard.leankor__EstimatedDuration__C;
        remoteKanban.DurationUnits = oldKanbanCard.leankor__DurationUnits__C;
        remoteKanban.Priority = Integer.ValueOf(oldKanbanCard.leankor__Priority__C);
        remoteKanban.OwnerID = oldKanbanCard.OwnerID;
        remoteKanban.HarveyBall = String.ValueOf(oldKanbanCard.leankor__PercentComplete2__c);
        remoteKanban.ValueStreamCardLink =  (linkCard.ID == null ? oldKanbanCard.leankor__ValueStreamCardLink__C : linkCard.ID); //oldKanbanCard.leankor__ValueStreamCardLink__C;
        remoteKanban.ValueStreamLinkID =  (linkBoard.ID == null ? oldKanbanCard.leankor__ValueStreamLink__C : linkBoard.ID) ;//oldKanbanCard.leankor__ValueStreamLink__C;
        remoteKanban.ValueStream =  oldKanbanCard.leankor__ValueStream__c;
        remoteKanban.Account = ( oldKanbanCard.leankor__Account__C == null ? '' : oldKanbanCard.leankor__Account__C );
        remoteKanban.Opportunity = (oldKanbanCard.leankor__Opportunity__C == null ? '' : oldKanbanCard.leankor__Opportunity__C);
        remoteKanban.Contact = (oldKanbanCard.leankor__Contact__C  == null ? '' : oldKanbanCard.leankor__Contact__C);
        remoteKanban.CaseID = (oldKanbanCard.leankor__Case__C  == null ? '' : oldKanbanCard.leankor__Case__C );
        remoteKanban.Order = (oldKanbanCard.leankor__Order__C  == null ? 0 : oldKanbanCard.leankor__Order__C );
        remoteKanban.OnBudget = (oldKanbanCard.leankor__OnBudget__C == null ? 'Green' : oldKanbanCard.leankor__OnBudget__C);
        remoteKanban.OnQuality = (oldKanbanCard.leankor__OnQuality__C == null ? 'Green' : oldKanbanCard.leankor__OnQuality__C);
        remoteKanban.OnTime = (oldKanbanCard.leankor__OnTime__C == null ? 'Green' : oldKanbanCard.leankor__OnTime__C);
        remoteKanban.StartDate = oldKanbanCard.leankor__StartDate__C;
        remoteKanban.UrlLink = oldKanbanCard.leankor__UrlLink__C;
        remoteKanban.ZoneID = (oldKanbanCard.leankor__ZoneGUID__C == null ? '': oldKanbanCard.leankor__ZoneGUID__C);
        remoteKanban.ZoneForceID = (oldKanbanCard.leankor__Zone__C == null ? '': oldKanbanCard.leankor__Zone__C);
        remoteKanban.MCForceID = (oldKanbanCard.leankor__MasterContainer__c == null ? '': oldKanbanCard.leankor__MasterContainer__c);
        remoteKanban.SWForceID = (oldKanbanCard.leankor__Swimlane__c == null ? '': oldKanbanCard.leankor__Swimlane__c);
        remoteKanban.LastModifiedDate =JSON.Serialize(oldKanbanCard.LastModifiedDate);
        remoteKanban.ValueStreamLinkBoardType = oldKanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__C;
        remoteKanban.flowWithGS = true;  
        if ((remoteKanban.ZoneID != null ||  remoteKanban.ZoneID != '') && request.generateWorkBreakdownStructure == false) {
            List<leankor__KanbanCard__c> kanbanCardList = [Select Id, 
                                                                    Name, 
                                                                    leankor__Order__c 
                                                                From leankor__KanbanCard__c 
                                                                Where leankor__ZoneGUID__c =:remoteKanban.ZoneID 
                                                                With Security_Enforced
                                                                Order By leankor__Order__C Desc Nulls Last 
                                                                Limit 500000];
            if (kanbanCardList.Size() > 0) {
                remoteKanban.Order = kanbanCardList[0].leankor__Order__c;
            }
        } 


        remoteKanban.ItemType = oldKanbanCard.RecordType.Name;// 13/06/2023 : cloning Recordtype Name from API

        String someJSONData = JSON.Serialize(remoteKanban);
        Boolean TaskVerb = false;
        String resultId ;
    
        if (String.isBlank(tempKanbanId)) {
            return 'Failed : Null Id';	        	
        }
        else  {
            //query all task records including archived
            //Modifications to allow query on archived Task records and to increase efficiency of queries involving Task object 
            List<Task> oldTaskData = 
                    [Select 
                            Id 
                        From Task 
                        where What.Type = 'leankor__KanbanCard__c' 
                            And WhatId=:tempKanbanId 
                            And IsDeleted=false 
                        limit 9999
                        All Rows];
            if (oldTaskData.Size() > 0) {
                    TaskVerb = true;
            } else {
                    TaskVerb = false;
            }
        }
        
        // 05/04/2023 added code for Constraint Check 
        try {
            String result; 
            KanbanController.isCalledFromSingleCloneAPI = true;
            if (request.FinalDate != null) {
            	result =leankor.KanbanController.CloneKanbanCard(oldKanbanCard.leankor__ValueStream__C, JSON.Serialize(request.FinalDate), TaskVerb, someJSONData ,mySessionID);
            } else {
            	leankor.KanbanController.clonestartboard clonedata = new leankor.KanbanController.clonestartboard();
	            	clonedata.StartDate = JSON.Serialize(request.StartDate);
	            	clonedata.TaskVerb = TaskVerb;
	            	clonedata.someJSONData = someJSONData;
                    result = leankor.KanbanController.CloneCardwithStartDate(oldKanbanCard.leankor__ValueStream__C, clonedata,mySessionID);
            }
            leankor.realTimeController.CardStreamingPackage CSP = (leankor.realTimeController.CardStreamingPackage)JSON.deserialize(result, leankor.realTimeController.CardStreamingPackage.class);
            resultId = CSP.ID;

            if (String.isNotBlank(remoteKanban.ValueStream) && request.generateWorkBreakdownStructure == true) {
                CreateKanbanCardsQueueable.updateProjectWBS(new Set<String>{remoteKanban.ValueStream});
            }

        } catch (Exception e) {
            throw new Util.LeanException('ERROR: while :Cloning kanban Card ' + e.getMessage());
        }
        return resultId;
    }
}