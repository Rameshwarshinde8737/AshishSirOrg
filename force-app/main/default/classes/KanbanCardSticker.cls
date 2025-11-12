/**************************************************************************
 * Author     : Reynald Ocampo
 * Description: KanbanCardSticker standard controller
 **************************************************************************/ 
public with sharing class KanbanCardSticker {

    // copy stickers of KanbanCard records from the source records
    // kanbanCards must include the GUID field
    public static List<leankor__KanbanCardSticker__c> cloneKanbanCardStickers(List<leankor__KanbanCard__c> kanbanCards) {
        List<leankor__KanbanCardSticker__c> cloneKanbanCardStickers = new List<leankor__KanbanCardSticker__c>();
        Map<Id, Id> sourceKanbanCardIds = getMapSourceKanbanCardIds(kanbanCards);
        
        if (sourceKanbanCardIds.isEmpty()) {
            return cloneKanbanCardStickers;
        }

        // if (sourceKanbanCardIds != null) {
        Map<Id, Set<Id>> tagetKanbanCardStickerIds = getMapTargetKanbanCardStickerIds(readKanbanCardStickers(new Set<Id>(sourceKanbanCardIds.values())));
            List<leankor__KanbanCardSticker__c> sourceKanbanCardStickers = readKanbanCardStickers(sourceKanbanCardIds.keySet());
        
            for (leankor__KanbanCardSticker__c sourceKanbanCardSticker : sourceKanbanCardStickers) {
                Id clonedKanbanCardId = sourceKanbanCardIds.get(sourceKanbanCardSticker.leankor__KanbanCard__c);
                if (clonedKanbanCardId != null) {
                    Set<Id> stickerIds = tagetKanbanCardStickerIds == null ? null : tagetKanbanCardStickerIds.get(clonedKanbanCardId);
                    // add only if sticker is not associated to KanbanCard
                    if (stickerIds == null ? true : !stickerIds.contains(sourceKanbanCardSticker.leankor__Sticker__c)) {
                        cloneKanbanCardStickers.add(
                            new leankor__KanbanCardSticker__c(
                                leankor__KanbanCard__c = clonedKanbanCardId, 
                                leankor__Sticker__c = sourceKanbanCardSticker.leankor__Sticker__c
                            )
                        );
                    }
                }
            }

            if (cloneKanbanCardStickers.size() > 0) {
                createKanbanCardStickers(cloneKanbanCardStickers);
            }
        // }
        
        return cloneKanbanCardStickers;
    }


	/*--------------------------------------------------------------------------------
    Description:    Overloaded method of createKanbanCardStickers
    Inputs     :    Object of MultipleCreateKanbanCardAction.KanbanCardRequest class
    --------------------------------------------------------------------------------*/
    public static List<leankor__KanbanCardSticker__c> createKanbanCardStickers(MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest request) {
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>();
        
        try {
            kanbanCardStickers = createKanbanCardStickers(request.kanbanCardRequest, request.stickerRequest);
            broadcastKanbanCardStickers(kanbanCardStickers, request);
        } catch(Exception e) {
            throw e;
        }

        return kanbanCardStickers;
	}


	/*--------------------------------------------------------------------------------
    Description:    Broadcast KanbanCardSticker records via Platform Event 
    Inputs     :    Object of leankor__KanbanCardSticker__c
                    Object of MultipleCreateKanbanCardAction.KanbanCardRequest class
    --------------------------------------------------------------------------------*/
    public static void broadcastKanbanCardStickers(List<leankor__KanbanCardSticker__c> kanbanCardStickers, MultipleAddKanbanCardStickerAction.MultipleAddKanbanCardStickerRequest request) {
        if (kanbanCardStickers.isEmpty()) {
            return;
        }

        Set<Id> kanbanCardIds = new Set<Id>();

        for (leankor__KanbanCardSticker__c kanbanCardSticker : kanbanCardStickers) {
            if (kanbanCardSticker.leankor__KanbanCard__c != null) {
                kanbanCardIds.add(kanbanCardSticker.leankor__KanbanCard__c);
            }
        }

        try {
            String jsonPayload = JSON.serialize(kanbanCardIds);

            if (request.sendBroadcastMessage) {
                // create a platform event of type BroadcastEvent for broadcasting to Leankor App
                LeankorOperationController.sendBroadcast('ReloadWorkItemStickers', jsonPayload, userInfo.getSessionId());
            }

            if (Util.getSObjectName(request.projectId) == 'leankor__ProjectRoom__c') {
                // create a platform event of type ProjectEvent for broadcasting to non-Leankor App
                LeankorPlatformEvents platformEvents = new LeankorPlatformEvents();
                platformEvents.projectId = request.projectId;
                platformEvents.customPayload = request.projectEventCustomPayload;
                platformEvents.eventCategory = 'Creating';
                platformEvents.eventName = 'EndCreateWorkItemSticker';
                platformEvents.jsonPayload = jsonPayload;

                leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();
                platformEvents.createPlatformEvents(projectEvent);
            }
        } catch(Exception e) {
            throw e;
        }
    }


    /*--------------------------------------------------------------------------------
    Description:    Overloaded method of createKanbanCardStickers
    Inputs     :    List<leankor__KanbanCard__c> and List<leankor__Sticker__c>
    --------------------------------------------------------------------------------*/
    public static List<leankor__KanbanCardSticker__c> createKanbanCardStickers(List<leankor__KanbanCard__c> kanbanCards, List<leankor__Sticker__c> stickers) {
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = new List<leankor__KanbanCardSticker__c>();

        if (kanbanCards.isEmpty() || stickers.isEmpty()) {
            return kanbanCardStickers;
        }

        List<leankor__KanbanCardSticker__c> addKanbanCardStickers = new List<leankor__KanbanCardSticker__c>();

        try {
            List<leankor__KanbanCard__c> kanbanCardValueStreams = KanbanCard.readKanbanCards(kanbanCards);
            List<leankor__Sticker__c> kanbanStickers = Sticker.readStickers(stickers);
            Map<Id, Set<Id>> tagetKanbanCardStickerIds = getMapTargetKanbanCardStickerIds(readKanbanCardStickers((new Map<Id, leankor__KanbanCard__c>(kanbanCardValueStreams)).keySet()));

            for (leankor__Sticker__c kanbanSticker : kanbanStickers) {    
                for (leankor__KanbanCard__c kanbanCardValueStream : kanbanCardValueStreams) {
                    if (kanbanCardValueStream.leankor__ValueStream__c == kanbanSticker.leankor__ValueStream__c || kanbanSticker.leankor__ValueStream__c == null) {
                        Set<Id> stickerIds = tagetKanbanCardStickerIds == null ? null : tagetKanbanCardStickerIds.get(kanbanCardValueStream.Id);
                        // add only if sticker is not associated to KanbanCard
                        if (stickerIds == null ? true : !stickerIds.contains(kanbanSticker.Id)) {
                            addKanbanCardStickers.add(
                                new leankor__KanbanCardSticker__c(
                                    leankor__KanbanCard__c = kanbanCardValueStream.Id, 
                                    leankor__Sticker__c = kanbanSticker.Id
                                )
                            );
                        }
                    }
                }
            }
        
            if (addKanbanCardStickers.size() > 0) {
                kanbanCardStickers = createKanbanCardStickers(addKanbanCardStickers);
            }
        } catch(Exception e) {
            throw e;
        }

        return kanbanCardStickers;
    }


    public static List<leankor__KanbanCardSticker__c> createKanbanCardStickers(List<leankor__KanbanCardSticker__c> kanbanCardStickers) {        
        //Check CRUD   
		KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour();

		if (!kanbanCardStickerBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD 
       
        try {
            insert kanbanCardStickers;
        } catch(DMLException e){
            throw e;
        }
        return kanbanCardStickers;
    }


    public static List<leankor__KanbanCardSticker__c> updateKanbanCardStickers(List<leankor__KanbanCardSticker__c> kanbanCardStickers) {
        //Check CRUD   
		KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour();
		if (!kanbanCardStickerBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD 

        try {
            update kanbanCardStickers;
        } catch(DMLException e){
            throw e;
        }
        return kanbanCardStickers;
    }
    

    public static List<leankor__KanbanCardSticker__c> readKanbanCardStickers(Set<Id> kanbanCards) {
        List<leankor__KanbanCardSticker__c> kanbanCardStickers = 
            [Select 
                    leankor__KanbanCard__c, 
                    leankor__KanbanCard__r.leankor__ValueStream__c, 
                    leankor__Sticker__c,
                    leankor__Sticker__r.Name
                From leankor__KanbanCardSticker__c 
                Where leankor__KanbanCard__c In :kanbanCards
                With Security_Enforced
                Limit 50000];

        removeKanbanCardStickers(kanbanCardStickers);

        return kanbanCardStickers;
    }


	// pass by reference
    // remove null elements 
	@TestVisible
    private static void removeKanbanCardStickers(List<leankor__KanbanCardSticker__c> kanbanCardStickers) {
        Integer index = 0;
        while (index < kanbanCardStickers.size()) {
            leankor__KanbanCardSticker__c kanbanCardSticker = kanbanCardStickers.get(index);
            if(kanbanCardSticker.leankor__KanbanCard__c == null || kanbanCardSticker.leankor__Sticker__c == null) {
                kanbanCardStickers.remove(index);
            } else {
                index++;
            }
        }
    }


	@TestVisible
    private static Map<Id, Set<Id>> getMapTargetKanbanCardStickerIds(List<leankor__KanbanCardSticker__c> kanbanCardStickers) {
        Map<Id, Set<Id>> targetKanbanCardStickerIds = new Map<Id, Set<Id>>();
        for (leankor__KanbanCardSticker__c kanbanCardSticker : kanbanCardStickers) {
            Set<Id> stickerIds = new Set<Id>();
            stickerIds.add(kanbanCardSticker.leankor__Sticker__c);
            
            Set<Id> targetStickerIds = targetKanbanCardStickerIds.get(kanbanCardSticker.leankor__KanbanCard__c);
            if (targetStickerIds != null) {
                stickerIds.addAll(targetStickerIds);
            }
            targetKanbanCardStickerIds.put(kanbanCardSticker.leankor__KanbanCard__c, stickerIds);
        }
        return targetKanbanCardStickerIds;
    }


    // clonedKanbanCards must include the GUID field
	@TestVisible
    private static Map<Id, Id> getMapSourceKanbanCardIds(List<leankor__KanbanCard__c> clonedKanbanCards) {
        Map<Id, Id> sourceKanbanCardIds = new Map<Id, Id>();
        try {
            for (leankor__KanbanCard__c clonedKanbanCard : clonedKanbanCards) {                
                Id sourceKanbanCardId = getIdFromGUID(clonedKanbanCard.leankor__GUID__c);
                if (sourceKanbanCardId != null) {
                    sourceKanbanCardIds.put(sourceKanbanCardId, clonedKanbanCard.Id);
                }
            }
        } catch(TypeException e) {
            throw e;
        }
        return sourceKanbanCardIds;
    }

    
	@TestVisible
    private static Id getIdFromGUID(String valueGUID) {
        Id sourceKanbanCardId = null;
        if (String.isNotBlank(valueGUID)) {
        	String parsedGUID = (valueGUID).subStringBefore('-');
            if (parsedGUID InstanceOf Id) {
            	Id kanbanCardId = Id.valueOf(parsedGUID);
                sourceKanbanCardId = kanbanCardId.getSObjectType().getDescribe().getName() == 'leankor__KanbanCard__c' ? kanbanCardId : null;
            }
		}
        return sourceKanbanCardId;
    }

    public static List<leankor__KanbanCardSticker__c> upsertKanbanCardStickers(List<leankor__KanbanCardSticker__c> kanbanCardStickers) {
        //Check CRUD   
		KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour();
		if (!kanbanCardStickerBehaviour.isCreateable()
            || !kanbanCardStickerBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD 

        try {
            upsert kanbanCardStickers;
        } catch(DMLException e){
            throw e;
        }
        return kanbanCardStickers;
    }

    public static void upsertKanbanCardStickers(Set<Leankor__KanbanCardSticker__c> newStickers, Set<Id> workItemIds) {
        // Validate input
        if ((newStickers == null || newStickers.isEmpty()) && (workItemIds.isEmpty() || workItemIds == null)) {
            return;
        }
        for (Leankor__KanbanCardSticker__c existingRecord : [Select Id,
                                                                    leankor__KanbanCard__c, 
                                                                    leankor__Sticker__c
                                                                From Leankor__KanbanCardSticker__c
                                                                Where leankor__KanbanCard__c In :workItemIds
                                                                With Security_Enforced
                                                                Limit 10000]) {

            existingRecord.leankor__KanbanCard__c = null;
            existingRecord.leankor__Sticker__c = null;
            newStickers.add(existingRecord);                                                        
        }
        // Insert new records
        if (!newStickers.isEmpty()) {
            upsertKanbanCardStickers(new List<leankor__KanbanCardSticker__c>(newStickers));
        }
    }
}