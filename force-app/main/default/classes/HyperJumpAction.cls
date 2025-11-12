/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  HyperJumpAction.cls
* CLASS: HyperJumpAction
* USAGE: manages to Upadte Record of Valuestream of Card .
*/
Global with sharing class HyperJumpAction{
//
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    global class HyperJumpRequest{
        @invocableVariable(label = 'Kanban Card ID' description = 'Kanban Card ID' )
            global String KanbanCardID;
        @invocableVariable(label = 'KanbanCard Name' description = 'The Title found on the front of the Card.')
            global  String KanbanName;
        @invocableVariable(label = 'Name Of Present Board' description = 'The Project Board name.' required=true)
            global String OldVSName;
        @invocableVariable(label = 'Name Of HyperJump Room' description = 'The Project Room name to where you want the card to travel.')
            global String NewPRName;
        @invocableVariable(label = 'Name Of HyperJump Board' description = 'The Project Board name to where you want the card to travel.' required=true)
            global String NewVSName;
        @invocableVariable(label = 'Template Name' description = 'The Category of Card that is valid for the target Project Board. The current Category may not be available on Target Board.' required=true)
            global  String TemplateName;
        @invocableVariable(label = 'Board Type' description = 'Describe the type of board' )
            global String BoardType;
        @invocableVariable(label = 'Old ValueStream ID' description = 'Old ValueStream ID' )
            global String OldVSId;      
        @invocableVariable(label = 'New ValueStream ID' description = 'New ValueStream ID' )
            global String NewVSId;      
        @InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
            global Boolean generateWorkBreakdownStructure = false; 
    }
    //
    // This Method Is API Jump Card From One Board To other Board by API calls
    //
    @InvocableMethod
    global static Void hyperjumpToBoard(List<HyperJumpRequest> remoteObjectinput){
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible() ) {
            throw new Util.LeanException('Error: No access to records');
        }
        for (HyperJumpRequest request : remoteObjectinput) {
            if ((String.isNotBlank(request.KanbanCardID) && Util.getSObjectName(request.KanbanCardID) != 'leankor__KanbanCard__c') ||
            (String.isNotBlank(request.OldVSId) && Util.getSObjectName(request.OldVSId) != 'leankor__ValueStream__c') ||
            (String.isNotBlank(request.NewVSId) && Util.getSObjectName(request.NewVSId) != 'leankor__ValueStream__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        for (HyperJumpRequest remoteObject :remoteObjectinput) {
            leankor__KanbanCard__c KanbanID = new leankor__KanbanCard__c();
            String TempKanbanCardID = '';
                         
            if (remoteObject.KanbanCardID == null || remoteObject.KanbanCardID == '') {
                KanbanID = [Select Id 
                                From leankor__kanbanCard__c 
                                Where Name =:remoteObject.KanbanName
                                With Security_Enforced
                                Limit 1];
                TempKanbanCardID = KanbanID.ID;
            } else {
                TempKanbanCardID = remoteObject.KanbanCardID;
            }
            
            leankor__ValueStream__c OldVSId = new leankor__ValueStream__c();
            /*
            if (String.isBlank(remoteObject.OldVSId) {
                OldVSID = [Select ID From leankor__ValueStream__c Where Name =:remoteObject.OldVSName Limit 1];
            }
            else {
                OldVSID = [Select ID From leankor__ValueStream__c Where Name =:remoteObject.OldVSId];
            }
            */
            
            OldVSID = String.isBlank(remoteObject.OldVSId) 
                ? [Select Id 
                        From leankor__ValueStream__c 
                        Where Name =:remoteObject.OldVSName 
                            And leankor__IsRecordDeleted__c = false 
                        With Security_Enforced
                        Limit 1]
                : [Select Id 
                        From leankor__ValueStream__c 
                        Where Id =:remoteObject.OldVSId
                        With Security_Enforced];

            leankor__ValueStream__c NewVSID = new leankor__ValueStream__c();
            /*
            if (remoteObject.NewPRName == null || remoteObject.NewPRName == '') {
                NewVSID = [Select ID,leankor__BoardType__c From leankor__ValueStream__c Where Name =:remoteObject.NewVSName AND  leankor__ProjectRoom__r.Name != null Limit 1];
            } else {
                NewVSID = [Select ID,leankor__BoardType__c From leankor__ValueStream__c Where Name =:remoteObject.NewVSName AND leankor__ProjectRoom__r.Name =:remoteObject.NewPRName Limit 1];
            }
            */

            if (String.isBlank(remoteObject.NewVSId)) {
                /*
                if (String.isBlank(remoteObject.NewPRName)) {
                    NewVSID = [Select ID, leankor__BoardType__c From leankor__ValueStream__c Where Name = :remoteObject.NewVSName AND leankor__ProjectRoom__r.Name != null Limit 1];
                }
                else {
                    NewVSID = [Select ID,leankor__BoardType__c From leankor__ValueStream__c Where Name =:remoteObject.NewVSName AND leankor__ProjectRoom__r.Name =:remoteObject.NewPRName Limit 1]
                }
                */

                NewVSID = String.isBlank(remoteObject.NewPRName) 
                    ? [Select Id,
                                leankor__BoardType__c 
                            From leankor__ValueStream__c 
                            Where Name = :remoteObject.NewVSName And leankor__ProjectRoom__r.Name != null 
                                And leankor__IsRecordDeleted__c = false 
                            With Security_Enforced
                            Limit 1]
                    : [Select Id,
                                leankor__BoardType__c
                            From leankor__ValueStream__c 
                            Where Name = :remoteObject.NewVSName 
                                And leankor__ProjectRoom__r.Name =:remoteObject.NewPRName 
                                And leankor__IsRecordDeleted__c = false 
                            With Security_Enforced
                            Limit 1];

            } else {
                NewVSID = [Select Id,
                                    leankor__BoardType__c 
                                From leankor__ValueStream__c 
                                Where Id = :remoteObject.NewVSId
                                With Security_Enforced];
            }

            leankor__KanbanCardTemplate__C templateId = new leankor__KanbanCardTemplate__C(); 
            List<leankor__KanbanCardTemplate__C> templateList = [Select Id,
                                                                        leankor__Color__c,
                                                                        leankor__Height__c,
                                                                        leankor__JSONData__c,
                                                                        leankor__JSONDefinition__c,
                                                                        leankor__Title__c,leankor__Width__c,
                                                                        Name 
                                                                    From leankor__KanbanCardTemplate__C 
                                                                    Where Name =:remoteObject.TemplateName 
                                                                        And leankor__ValueStream__c =:NewVSID.Id 
                                                                    With Security_Enforced
                                                                    Limit 9999];
            if (templateList.Size() > 0) {
                templateId = templateList[0];
            } else {
                templateId = [Select Id,
                                    leankor__Color__c,
                                    leankor__Height__c,
                                    leankor__JSONData__c,
                                    leankor__JSONDefinition__c,
                                    leankor__Title__c,
                                    leankor__Width__c,
                                    Name 
                                From leankor__KanbanCardTemplate__C
                                With Security_Enforced
                                Limit 1];
            }
            leankor__Kanbancard__c oldKanbanCard = [Select Id,
                                                        leankor__EffortRemaining__c,
                                                        leankor__point__c,
                                                        leankor__Account__c,
                                                        leankor__UrlLink__c,
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
                                                        leankor__ValueStream__c,
                                                        leankor__Width__c,
                                                        leankor__X__c,
                                                        leankor__Y__c,
                                                        leankor__ZoneGUID__c,
                                                        Name,
                                                        OwnerId,
                                                        LastModifiedDate,
                                                        leankor__ValueStreamLink__r.leankor__BoardType__C
                                                    From leankor__KanbanCard__c
                                                    Where Id =:TempKanbanCardID 
                                                        And leankor__ValueStream__c =:OldVSID.Id 
                                                    Limit 1];
            //Date: 10/12/2019 Querying user data
			map<string,User> userData = new map<string,User>([Select id,
                                                                        IsActive, 
                                                                        Name 
                                                                    From User 
                                                                    Where id =: oldKanbanCard.OwnerID]);
		    
            oldKanbanCard.leankor__KanbanCardTemplate__c = templateId.ID;
            leankor.RealTimeController.Kanban RemoteKanban = new leankor.RealTimeController.Kanban();
            RemoteKanban.Id = oldKanbanCard.Id;
            RemoteKanban.Point = oldKanbanCard.leankor__Point__c;
            RemoteKanban.EffortRemaining = integer.valueof(oldKanbanCard.leankor__EffortRemaining__c);
            RemoteKanban.ForceID = oldKanbanCard.Id;
            RemoteKanban.GUID = oldKanbanCard.leankor__GUID__c;
            RemoteKanban.Title = templateId.leankor__Title__C;
            RemoteKanban.Name = oldKanbanCard.Name;
            RemoteKanban.UrlLink=oldKanbanCard.leankor__urllink__c;
            RemoteKanban.Top = oldKanbanCard.leankor__Top__c;
            RemoteKanban.Bottom = oldKanbanCard.leankor__Bottom__c;
            RemoteKanban.Left = oldKanbanCard.leankor__Left__C;
            RemoteKanban.Width = templateId.leankor__Width__C;
            RemoteKanban.Height = templateId.leankor__Height__C;
            RemoteKanban.X = oldKanbanCard.leankor__X__C;
            RemoteKanban.Y = oldKanbanCard.leankor__Y__C;
            RemoteKanban.JSONDefinition = (templateId.leankor__JSONDefinition__C == null ? '' : templateId.leankor__JSONDefinition__C);
            RemoteKanban.JSONData = (templateId.leankor__JSONData__c == null ? '' : templateId.leankor__JSONData__c);
            RemoteKanban.templateId = oldKanbanCard.leankor__KanbanCardTemplate__C;
            RemoteKanban.Color = (templateId.leankor__Color__c == null ? '#bdbffc' : templateId.leankor__Color__c);
            RemoteKanban.Description = oldKanbanCard.leankor__DescriptionLong__C;
            RemoteKanban.DueDate = oldKanbanCard.leankor__DueDate__C;
            RemoteKanban.EstimatedDuration = oldKanbanCard.leankor__EstimatedDuration__C;
            RemoteKanban.DurationUnits = oldKanbanCard.leankor__DurationUnits__C;
            RemoteKanban.Priority = Integer.ValueOf(oldKanbanCard.leankor__Priority__C);          
			RemoteKanban.HarveyBall = String.ValueOf(oldKanbanCard.leankor__PercentComplete2__c);
            // Date: 10/12/2019 - Active user changes
           // RemoteKanban.OwnerID = oldKanbanCard.OwnerID;
            if (userData.containsKey(oldKanbanCard.OwnerID)) {	
                RemoteKanban.OwnerID = userData.get(oldKanbanCard.OwnerID).IsActive ? oldKanbanCard.OwnerID : UserInfo.getUserId();
            } else {
                RemoteKanban.OwnerID = oldKanbanCard.OwnerID;
            }
            RemoteKanban.ValueStreamCardLink =  oldKanbanCard.leankor__ValueStreamCardLink__C;
            RemoteKanban.ValueStreamLinkID =  oldKanbanCard.leankor__ValueStreamLink__C;
            RemoteKanban.ValueStream =  oldKanbanCard.leankor__ValueStream__c;
            RemoteKanban.Account = ( oldKanbanCard.leankor__Account__C == null ? '' : oldKanbanCard.leankor__Account__C );
            RemoteKanban.Opportunity = (oldKanbanCard.leankor__Opportunity__C == null ? '' : oldKanbanCard.leankor__Opportunity__C);
            RemoteKanban.Contact = (oldKanbanCard.leankor__Contact__C  == null ? '' : oldKanbanCard.leankor__Contact__C);
            RemoteKanban.CaseID = (oldKanbanCard.leankor__Case__C  == null ? '' : oldKanbanCard.leankor__Case__C );
            RemoteKanban.Order = (oldKanbanCard.leankor__Order__C  == null ? 0 : oldKanbanCard.leankor__Order__C );
            RemoteKanban.OnBudget = (oldKanbanCard.leankor__OnBudget__C == null ? 'Green' : oldKanbanCard.leankor__OnBudget__C);
            RemoteKanban.OnQuality = (oldKanbanCard.leankor__OnQuality__C == null ? 'Green' : oldKanbanCard.leankor__OnQuality__C);
            RemoteKanban.OnTime = (oldKanbanCard.leankor__OnTime__C == null ? 'Green' : oldKanbanCard.leankor__OnTime__C);
            RemoteKanban.StartDate = oldKanbanCard.leankor__StartDate__C;
            RemoteKanban.ZoneID = (oldKanbanCard.leankor__ZoneGUID__C == null ? '': oldKanbanCard.leankor__ZoneGUID__C);
            RemoteKanban.LastModifiedDate =JSON.Serialize(oldKanbanCard.LastModifiedDate);
            RemoteKanban.ValueStreamLinkBoardType = oldKanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__C;
            RemoteKanban.flowWithGS = true;  //Rs 12/12/2017  for gs in flow
            String someJSONdata = JSON.serialize(RemoteKanban);
            leankor.KanbanController.Hyperjump tempObject = new leankor.KanbanController.Hyperjump();
            tempObject.oldVSID = OldVSID.ID;
            tempObject.NewVSID = NewVSID.ID;
            tempObject.BoardType = NewVSID.leankor__BoardType__c;
            tempObject.templateId = templateId.ID;
            try{
                String output =leankor.KanbanController.HyperjumpToBoard(tempObject,someJSONdata);
                if(remoteObject.generateWorkBreakdownStructure == true) {
                    CreateKanbanCardsQueueable.updateProjectWBS(new Set<String>{remoteKanban.ValueStream});
                }
            } catch (Exception e){
                //25/04/2023 : We are Throwing Exception
	            throw new Util.LeanException('ERROR:' + e.getMessage());
            }
        }
    }
}