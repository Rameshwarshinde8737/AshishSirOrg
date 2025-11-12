/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  RemoveKanbanCardStickerAction.cls
* CLASS: RemoveKanbanCardStickerAction
* USAGE: Remove sticker from kanban card .
*/
global with sharing class RemoveKanbanCardStickerAction {

    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    global class StickerDataRequest {
        @InvocableVariable(label='Kanban Card ID' description='You must provide either this Card ID.' )
        global Id KanbanID;

        @InvocableVariable(label='Sticker ID' description='You must provide stickerID which to be Remove on card.' )
        global Id StickerID;
            
        @InvocableVariable(label='Sticker Name' description='You must provide stickerName which to Remove add on card.' )
        global String StickerName;
    }
    

    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    global class StickerDataResult { 
        @InvocableVariable(label='RemoveResult' description='Result of deleted kanban Card Sticker (True/False)' )
        global Boolean result;
    }


    // This is execute method for API calls
    @InvocableMethod 
    global static List<StickerDataResult> RemoveCardStickerAction(List<StickerDataRequest> remoteRequest) {
        for(StickerDataRequest stickerData : remoteRequest){
            if (String.isNotBlank(stickerData.KanbanID) && Util.getSObjectName(stickerData.KanbanID) != 'leankor__KanbanCard__c'||  
                String.isNotBlank(stickerData.StickerID) && Util.getSObjectName(stickerData.StickerID) != 'leankor__Sticker__c') {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<StickerDataResult>  result = new List<StickerDataResult>();

        for (StickerDataRequest remoteinput : remoteRequest) {
            StickerDataResult Returndata = new StickerDataResult();
            Boolean response = removeCardSticker(remoteinput);
            Returndata.result = response;
            result.add(Returndata);            
        }

        return result;
    }


    public static Boolean removeCardSticker(StickerDataRequest request) { 
        //Check CRUD / FLC behavior
        KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour(); 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardStickerBehaviour.isUpdateable() ||
            !kanbanCardBehaviour.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		} 
		//Check CRUD / FLC behavior

        try {           
            List<leankor__Sticker__c> sticker = null;
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
                                                        leankor__JSONData__c, 
                                                        leankor__JSONDefinition__c, 
                                                        leankor__KanbanCardTemplate__c, 
                                                        leankor__Left__c, leankor__OnBudget__c, 
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
                                                        leankor__ValueStreamLink__r.leankor__BoardType__c,
                                                        leankor__ValueStream__c, 
                                                        leankor__Width__c, 
                                                        leankor__X__c, 
                                                        leankor__Y__c,
                                                        leankor__ZoneGUID__c,
                                                        Name,
                                                        OwnerId, 
                                                        leankor__BoardType__c 
                                                    From leankor__KanbanCard__c
                                                    Where Id =: request.KanbanID 
                                                    Limit 1];
            Id StickerID = request.StickerID;
            
            if (StickerID == null) {                
                // Tilak Raj Mahale: 24.08.2020 - Chanages related to remove non- selective queries
                // sticker = [SELECT ID,Name From leankor__Sticker__c Where Name=:request.StickerName  AND (leankor__ValueStream__c=NULL or leankor__ValueStream__c=:KanbanCard.leankor__ValueStream__c) ];
                sticker = [Select Id, 
                                    Name, 
                                    leankor__ValueStream__c
                                From leankor__Sticker__c 
                                Where Name =: request.StickerName 
                                With Security_Enforced
								Limit 50000];

                for (leankor__Sticker__c stckr : sticker) {
                    if (stckr.leankor__ValueStream__c == null || (stckr.leankor__ValueStream__c == KanbanCard.leankor__ValueStream__c)) {
                        StickerID = stckr.Id;
                        break;
            } 
                }
                //StickerID = sticker[0].ID;      
            } 

            List<leankor__KanbanCardSticker__c> kanbanCardStickers = [Select Id,
                                                                            leankor__Sticker__c,
                                                                            leankor__KanbanCard__c
                                                                        From leankor__KanbanCardSticker__c 
                                                                        Where leankor__KanbanCard__c =:request.kanbanId 
                                                                            And leankor__Sticker__c =:stickerId
                                                                        With Security_Enforced
                                                                        Limit 1];
            if (!kanbanCardStickers.isEmpty()) {
                for (leankor__KanbanCardSticker__c kanbanCardSticker : kanbanCardStickers) {
                    kanbanCardSticker.leankor__Sticker__c = null;
                    kanbanCardSticker.leankor__KanbanCard__c = null;
                }
            } else {
                return false;
            }
        
            List<Database.SaveResult> DBResult = Database.update(kanbanCardStickers);

            for (Database.SaveResult res: DBResult) {
                if (res.isSuccess()) {
                    leankor.RealTimeController.StateChangePackage remoteKanban = new leankor.RealTimeController.StateChangePackage();
                    remoteKanban.Id = KanbanCard.Id;
                    remoteKanban.ForceID = KanbanCard.Id;
                    remoteKanban.GUID = KanbanCard.leankor__GUID__c;
                    remoteKanban.Title = KanbanCard.leankor__Title__C;
                    remoteKanban.Name = KanbanCard.Name;
                    remoteKanban.Top = KanbanCard.leankor__Top__c;
                    remoteKanban.Bottom = KanbanCard.leankor__Bottom__c;
                    remoteKanban.Left = KanbanCard.leankor__Left__C;
                    remoteKanban.Width = KanbanCard.leankor__Width__C;
                    remoteKanban.Height = KanbanCard.leankor__Height__C;
                    remoteKanban.X = KanbanCard.leankor__X__C;
                    remoteKanban.Y = KanbanCard.leankor__Y__C;
                    remoteKanban.JSONDefinition = KanbanCard.leankor__JSONDefinition__C;
                    remoteKanban.JSONData = KanbanCard.leankor__JSONData__c;
                    remoteKanban.TemplateID = KanbanCard.leankor__KanbanCardTemplate__C;
                    remoteKanban.Color = KanbanCard.leankor__Color__c;
                    remoteKanban.Description = KanbanCard.leankor__DescriptionLong__C;
                    remoteKanban.DueDate = KanbanCard.leankor__DueDateTime__C;
                    remoteKanban.EstimatedDuration = KanbanCard.leankor__EstimatedDuration__C;
                    remoteKanban.DurationUnits = KanbanCard.leankor__DurationUnits__C;
                    remoteKanban.Priority = KanbanCard.leankor__Priority__C;
                    remoteKanban.OwnerID = KanbanCard.OwnerID;
                    remoteKanban.HarveyBall = KanbanCard.leankor__PercentComplete2__c;
                    remoteKanban.ValueStreamCardLink =  KanbanCard.leankor__ValueStreamCardLink__C;
                    remoteKanban.ValueStreamLinkID =  KanbanCard.leankor__ValueStreamLink__C;
                    remoteKanban.ValueStream =  KanbanCard.leankor__ValueStream__c;
                    remoteKanban.Account = ( KanbanCard.leankor__Account__C == null ? '' : KanbanCard.leankor__Account__C );
                    remoteKanban.Opportunity = (KanbanCard.leankor__Opportunity__C == null ? '' : KanbanCard.leankor__Opportunity__C);
                    remoteKanban.Contact = (KanbanCard.leankor__Contact__C  == null ? '' : KanbanCard.leankor__Contact__C);
                    remoteKanban.CaseID = (KanbanCard.leankor__Case__C  == null ? '' : KanbanCard.leankor__Case__C );
                    remoteKanban.Order = (KanbanCard.leankor__Order__C  == null ? 0 : KanbanCard.leankor__Order__C );
                    remoteKanban.OnBudget = (KanbanCard.leankor__OnBudget__C == null ? 'Green' : KanbanCard.leankor__OnBudget__C);
                    remoteKanban.OnQuality = (KanbanCard.leankor__OnQuality__C == null ? 'Green' : KanbanCard.leankor__OnQuality__C);
                    remoteKanban.OnTime = (KanbanCard.leankor__OnTime__C == null ? 'Green' : KanbanCard.leankor__OnTime__C);
                    remoteKanban.StartDate = (KanbanCard.leankor__StartDateTime__C == null ? System.Now() : KanbanCard.leankor__StartDateTime__C);
                    remoteKanban.ZoneID = (KanbanCard.leankor__ZoneGUID__C == null ? '': KanbanCard.leankor__ZoneGUID__C);
                    remoteKanban.ValueStreamLinkBoardType = KanbanCard.leankor__ValueStreamLink__r.leankor__BoardType__C;
                    remoteKanban.flowWithGS = true; 
                    String someJSONData = JSON.Serialize(remoteKanban);
                     
                    // For Sticker we have now changed the verb, instead of 'UpdateKanbanCard'
        			// This board condition needs to be removed when code is Optimised from UI to manage Stickers
                    // We are added ManageSticker verb for all the boards because updatekanbancard verb it is not working for remove sticker broadcasting
                    leankor.RealTimeController.KanbanStateChange(KanbanCard.leankor__ValueStream__c, 'ManageSticker', UserInfo.getSessionId(), someJSONData);
                }

                return true;      
            }
            
            return false;      
        
        } catch (DmlException e) {
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
    }
}