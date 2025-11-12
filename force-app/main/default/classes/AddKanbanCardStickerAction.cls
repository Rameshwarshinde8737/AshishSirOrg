/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  AddKanbanCardStickerAction.cls
* CLASS: AddKanbanCardStickerAction
* USAGE: Add sticker to kanban card .
*/
global with sharing class AddKanbanCardStickerAction{
    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    Global class StickerDataRequest{
       @invocableVariable(label='Kanban Card ID' description='You must provide either this Card ID.' )
            Global ID KanbanID;

        @invocableVariable(label='Sticker ID' description='You must provide stickerID which to be add on card.' )
            Global ID StickerID;
            
        @invocableVariable(label='Sticker Name' description='You must provide stickerName which to be add on card.' )
            Global String StickerName;
    }
    //
    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    //
    Global Class StickerDataResult{ 
         @invocableVariable(label='KanbanCardStickerID' description='ID of Kanban Card Sticker.' )
            Global ID KanbanCardStickerID;
    }


    //
    // This is execute method for API calls
    //
    
    @InvocableMethod 
    Global static List<StickerDataResult> AddCardStickerAction(List<StickerDataRequest> remoteRequest){
        //Abhishek : 12/10/2022 : Added Security code for sentize user Input
        for (StickerDataRequest request : remoteRequest){
            if ((String.isNotBlank(request.KanbanID) && Util.getSObjectName(request.KanbanID) != 'leankor__KanbanCard__c')
            || (String.isNotBlank(request.StickerID) && Util.getSObjectName(request.StickerID) != 'leankor__Sticker__c')){
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<StickerDataResult>  result = new List<StickerDataResult>();
        for(StickerDataRequest remoteinput : remoteRequest){
            StickerDataResult ReturnID = new StickerDataResult();
            string ResultID = AddCardSticker(remoteinput);
            ReturnID.KanbanCardStickerID = ResultID;
            result.add(ReturnID);
            
        }
        return result;
    }

    public static String AddCardSticker(StickerDataRequest request) { 
        String result = '';
        KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour();
        StickerBehavior checkStickerBehavior = new StickerBehavior();
        KanbanCardBehaviour checkKanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardStickerBehaviour.isAccessible() ||
            !kanbanCardStickerBehaviour.isCreateable() ||
            !checkStickerBehavior.isAccessible() ||
            !checkKanbanCardBehaviour.isAccessible()) {
            	throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__Sticker__c> stickers = new List<leankor__Sticker__c>();
        leankor__KanbanCard__c KanbanCard = [Select Id,
                                                    LastModifiedDate,
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
                                                    leankor__ValueStreamLink__r.leankor__BoardType__C,
                                                    leankor__ValueStream__c,
                                                    leankor__Width__c,
                                                    leankor__X__c,
                                                    leankor__Y__c,
                                                    leankor__ZoneGUID__c,
                                                    Name,OwnerId, 
                                                    leankor__BoardType__c  
                                                From leankor__KanbanCard__c
                                                Where Id=:request.KanbanID
                                                With Security_Enforced 
                                                limit 1];
        String StickerID = request.StickerID;
        if(StickerID == null){                
            for(leankor__Sticker__c sticker : [Select Id,
                                                    Name,
                                                    leankor__ValueStream__c 
                                                From leankor__Sticker__c 
                                                Where Name=:request.StickerName
                                                With Security_Enforced]){
                if(sticker.leankor__ValueStream__c == NULL || sticker.leankor__ValueStream__c == KanbanCard.leankor__ValueStream__c) {
                    stickers.add(sticker);
                }
            }                
        } else{
            for(leankor__Sticker__c sticker : [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c 
                                                        From leankor__Sticker__c 
                                                        Where ID=:StickerID
                                                With Security_Enforced]){
                if (sticker.leankor__ValueStream__c == NULL || sticker.leankor__ValueStream__c == KanbanCard.leankor__ValueStream__c) {
                    stickers.add(sticker);
                }
            }                
        }            
        StickerID=stickers[0].ID;
        List<leankor__KanbanCardSticker__c> KCSList= [Select Id 
                                                        From leankor__KanbanCardSticker__c 
                                                        Where leankor__KanbanCard__c =:request.KanbanID 
                                                            And leankor__Sticker__c =:StickerID
                                                        With Security_Enforced 
                                                        Limit 1];
        if (KCSList.isEmpty()){
            
            if(!stickers.isEmpty()){
                leankor__KanbanCardSticker__c KCS = new leankor__KanbanCardSticker__c(
                            leankor__KanbanCard__c = request.KanbanID,
                            leankor__Sticker__c = stickers[0].ID     //request.StickerID 
                );
                try{
                    Database.SaveResult DBResult= Database.insert(KCS);
                    if(DBResult.isSuccess()){
                        leankor.RealTimeController.StateChangePackage RemoteKanban = new leankor.RealTimeController.StateChangePackage();
                        RemoteKanban.Id = KanbanCard.Id;
                        RemoteKanban.ForceID = KanbanCard.Id;
                        RemoteKanban.GUID = KanbanCard.leankor__GUID__c;
                        RemoteKanban.Title = KanbanCard.leankor__Title__C;
                        RemoteKanban.Name = KanbanCard.Name;
                        RemoteKanban.Top = KanbanCard.leankor__Top__c;
                        RemoteKanban.Bottom = KanbanCard.leankor__Bottom__c;
                        RemoteKanban.Left = KanbanCard.leankor__Left__C;
                        RemoteKanban.Width = KanbanCard.leankor__Width__C;
                        RemoteKanban.Height = KanbanCard.leankor__Height__C;
                        RemoteKanban.X = KanbanCard.leankor__X__C;
                        RemoteKanban.Y = KanbanCard.leankor__Y__C;
                        //06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue. 
                        //RemoteKanban.JSONDefinition = KanbanCard.leankor__JSONDefinition__C;
                        //RemoteKanban.JSONData = KanbanCard.leankor__JSONData__c;
                        RemoteKanban.TemplateID = KanbanCard.leankor__KanbanCardTemplate__C;
                        RemoteKanban.Color = KanbanCard.leankor__Color__c;
                        RemoteKanban.Description = KanbanCard.leankor__DescriptionLong__C;
                        RemoteKanban.DueDate = KanbanCard.leankor__DueDateTime__C;
                        RemoteKanban.EstimatedDuration = KanbanCard.leankor__EstimatedDuration__C;
                        RemoteKanban.DurationUnits = KanbanCard.leankor__DurationUnits__C;
                        RemoteKanban.Priority = KanbanCard.leankor__Priority__C;
                        RemoteKanban.OwnerID = KanbanCard.OwnerID;
                        RemoteKanban.HarveyBall = KanbanCard.leankor__PercentComplete2__c;
                        RemoteKanban.ValueStreamCardLink =  KanbanCard.leankor__ValueStreamCardLink__C;
                        RemoteKanban.ValueStreamLinkID =  KanbanCard.leankor__ValueStreamLink__C;
                        RemoteKanban.ValueStream =  KanbanCard.leankor__ValueStream__c;
                        RemoteKanban.Account = ( KanbanCard.leankor__Account__C == null ? '' : KanbanCard.leankor__Account__C );
                        RemoteKanban.Opportunity = (KanbanCard.leankor__Opportunity__C == null ? '' : KanbanCard.leankor__Opportunity__C);
                        RemoteKanban.Contact = (KanbanCard.leankor__Contact__C  == null ? '' : KanbanCard.leankor__Contact__C);
                        RemoteKanban.CaseID = (KanbanCard.leankor__Case__C  == null ? '' : KanbanCard.leankor__Case__C );
                        RemoteKanban.Order = (KanbanCard.leankor__Order__C  == null ? 0 : KanbanCard.leankor__Order__C );
                        RemoteKanban.OnBudget = (KanbanCard.leankor__OnBudget__C == null ? 'Green' : KanbanCard.leankor__OnBudget__C);
                        RemoteKanban.OnQuality = (KanbanCard.leankor__OnQuality__C == null ? 'Green' : KanbanCard.leankor__OnQuality__C);
                        RemoteKanban.OnTime = (KanbanCard.leankor__OnTime__C == null ? 'Green' : KanbanCard.leankor__OnTime__C);
                        RemoteKanban.StartDate = (KanbanCard.leankor__StartDateTime__C == null ? System.Now() : KanbanCard.leankor__StartDateTime__C);
                        RemoteKanban.ZoneID = (KanbanCard.leankor__ZoneGUID__C == null ? '': KanbanCard.leankor__ZoneGUID__C);
                        RemoteKanban.ValueStreamLinkBoardType = KanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__C;
                        RemoteKanban.flowWithGS = true;  //Rs 12/12/2017  for gs in flow 
                        String someJSONData = JSON.Serialize(RemoteKanban);
                        /*SS 01-04-2020*/
                        // Send Sticker broadcast with Verb ManageSticker
                        leankor.RealTimeController.KanbanStateChange(KanbanCard.leankor__ValueStream__c, 'ManageSticker', UserInfo.getSessionId(), someJSONData);
                    }
            }
                catch (DmlException e){
                   throw new Util.LeanException('Error : ' + e.getmessage());
        }
                result = KCS.ID;      
        }
        }else{
            result = KCSList[0].ID;
    }
       return result;
    }
}