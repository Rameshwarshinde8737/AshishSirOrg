/**
 * Company : Leankor
 * FILE : MoveKanbanCard.cls
 * CLASS : MoveKanbanCard
 * USAGE : Helper class of MultipleMoveKanbanCardAction.cls.
 */

public with sharing class MoveKanbanCard {
    
    // Default Constructor
    public MoveKanbanCard() {

    } 

    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to move kanban cards.
    Inputs:         List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests
    Returns:        -
    ------------------------------------------------------------*/
    public static void moveKanbanCards(List<MultipleMoveKanbanCardAction.KanbanCardRequest> kanbanCardRequests) {
        for(MultipleMoveKanbanCardAction.KanbanCardRequest request : kanbanCardRequests){
            moveKanbanCards(request);
        }
    }

    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Overloaded method of moveKanbanCards.
    Inputs:         MultipleMoveKanbanCardAction.KanbanCardRequest request
    Returns:        -
    ------------------------------------------------------------*/
    public static void moveKanbanCards(MultipleMoveKanbanCardAction.KanbanCardRequest request) {
        try{
            System.enqueueJob(new MoveKanbanCardsQueueable(request, true));
        }catch(Exception e){
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
    }


   /*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Kanban zones in map.
    Inputs:         MultipleMoveKanbanCardAction.KanbanCardRequest request, List<leankor__Zone__c> zones, Map<Id,leankor__Kanbancard__c> kanbanCardMap
    Returns:        Map<Id,leankor__Zone__c>.
    ------------------------------------------------------------*/
    public static Map<Id,leankor__Zone__c> getKanbanZoneMap(MultipleMoveKanbanCardAction.KanbanCardRequest request, List<leankor__Zone__c> zones, Map<Id,leankor__Kanbancard__c> kanbanCardMap){
        Map<Id,leankor__Zone__c> kanbanZoneMap = new Map<Id,leankor__Zone__c>();

        for (leankor__Kanbancard__c kanban : request.kanbanCardList) {
            // It might possible that record has been deleted.
            if (!kanbanCardMap.containsKey(kanban.Id)) {
                continue;
            }

            for (leankor__Zone__c zone : zones) {
                // Compare with kanban valuestream id and zone valuestream id.
                if (kanbanCardMap.get(kanban.id).leankor__ValueStream__c == zone.leankor__ValueStream__c) {		      				
                    if(String.isBlank(kanban.leankor__Zone__c) && String.isBlank(kanban.leankor__ZoneGUID__c) && String.isBlank(kanban.leankor__MasterContainer__c) && String.isBlank(kanban.leankor__SwimLane__c)){
                        if(zone.leankor__Swimlane__r.leankor__MasterContainer__r.Name == 'BackLog'){
                            kanbanZoneMap.put(kanban.id, zone);	     					
                            break;     					
                        }
                    } else if(kanban.leankor__Zone__c == zone.id) {
                        kanbanZoneMap.put(kanban.id, zone);
                        break;   
                    } else if (kanban.leankor__ZoneGUID__c == zone.leankor__GUID__c) {
                        kanbanZoneMap.put(kanban.id, zone);		    				    
                        break;
                    } else if (kanban.leankor__SwimLane__c == zone.leankor__SwimLane__c) {
                        kanbanZoneMap.put(kanban.id, zone);	   			   
                        break;		      				  	   
                    } else if (kanban.leankor__MasterContainer__c == zone.leankor__SwimLane__r.leankor__MasterContainer__c) {
                        kanbanZoneMap.put(kanban.id, zone);					
                        break;    				
                    }
                }     	         			   
            }
        }
        
        return kanbanZoneMap;
    }
    
    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Kanban Cards.
    Inputs:         List<String> kanbanCardIds
    Returns:        List<leankor__KanbanCard__c>.
    ------------------------------------------------------------*/
    public static List<leankor__KanbanCard__c> readKanbanCards(List<String> kanbanCardIds) {
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible() ) {
            throw new Util.LeanException('Error: No access to records');
        }
        return [Select Id,
                    leankor__CardID__c,
                    leankor__Point__c,
                    leankor__AcceptanceCriteria__c,
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
                    leankor__ValueStream__r.leankor__BoardType__c,
                    leankor__Zone__c,
                    leankor__Swimlane__c,
                    leankor__Swimlane__r.leankor__MasterContainer__c,
                    leankor__MasterContainer__c 
                From leankor__KanbanCard__c 
                Where Id In :kanbanCardIds 
                    And leankor__isRecordDeleted__c = false
                Limit 50000];
    }
    
    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Zones.
    Inputs:         List<Id> zoneIds, List<Id> swimlaneIds, List<Id> masterContainerIds, List<String> zoneGuidIds, List<Id> valueStreamIds
    Returns:        List<leankor__Zone__c>.
    ------------------------------------------------------------*/
    public static List<leankor__Zone__c> readZones(List<Id> zoneIds, List<Id> swimlaneIds, List<Id> masterContainerIds, List<String> zoneGuidIds, List<Id> valueStreamIds) {
        return [Select Id,
                    Name,
                    leankor__GUID__c,
                    leankor__Swimlane__r.Name,
                    leankor__Swimlane__c,
                    leankor__Swimlane__r.leankor__MasterContainer__c,
                    leankor__Swimlane__r.leankor__MasterContainer__r.Name,
                    leankor__valuestream__c 
                From leankor__Zone__c 
                Where (Id In :zoneIds 
                    Or leankor__Swimlane__c In :swimlaneIds 
                    Or leankor__Swimlane__r.leankor__MasterContainer__c In :masterContainerIds 
                    Or leankor__Guid__c In :zoneGuidIds 
                    Or leankor__valuestream__c In :valueStreamIds) 
                With Security_Enforced
                Limit 50000];
    }

    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Read Zone Kanban Actions.
    Inputs:         List<String> kanbanCardIds, Set<String> zoneIds
    Returns:        List<leankor__ZoneKanbanAction__c>.
    ------------------------------------------------------------*/
    public static List<leankor__ZoneKanbanAction__c> readZoneKanbanActions(List<String> kanbanCardIds, Set<String> zoneIds) {
        return [Select Id,
                    CreatedDate,
                    leankor__ActionType2__c,
                    leankor__KanbanCard2__c,
                    leankor__ValueStream__c,
                    leankor__Zone2__c, 
                    Name, 
                    leankor__WaitTime2__c 
                From leankor__ZoneKanbanAction__c 
                Where leankor__KanbanCard2__c In :kanbanCardIds 
                    And leankor__Zone2__c In :zoneIds 
                    And leankor__ActionType2__c = 'Entered Zone' 
                With Security_Enforced
                Order By CreatedDate Desc Nulls First 
                Limit 5000];	
    }
}