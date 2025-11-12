/**
* Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
* FILE:  GetCardsAction.cls
* CLASS: GetCardsAction
* USAGE: Returns all cards on a board.
*/
Global with sharing class GetCardsAction{

    //
    // This is the Request method for an Invocable Method which contains definitions of input variables for API calls
    //
    Global class KanbanRequest{
        @invocableVariable(label='Board Name' description='The Project Board Name.' )
            Global String BoardName;
        @invocableVariable(label='Folder Name of Room' description='Name of the Folder where its Room would located.')
            Global String FolderName;
        @invocableVariable(label='Room Name' description='The Project Room Name.' )
            Global String RoomName;
        @invocableVariable(label='Board ID' description='The Project Board ID.' )
            Global String BoardId;
    }

    //
    // This is execute method for Invocable Method which contain Input Of definition on input variable for API calls
    //
    @InvocableMethod 
    Global static List<KanbanRecordResult> GetKanbanCardsAction(List<KanbanRequest> remoteRequest){
        for(KanbanRequest request : remoteRequest){
            if(String.isNotBlank(request.BoardId) && Util.getSObjectName(request.BoardId) != 'leankor__ValueStream__c') {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        List<KanbanRecordResult> results = new List<KanbanRecordResult>();
        for(KanbanRequest request :remoteRequest){   
            results.addAll(getKanbanCardRecords(request));
        }
        return results;
    }
    
    //
    // This bulk records for API calls
    //
    public static List<KanbanRecordResult> getKanbanCardRecords(KanbanRequest request){  
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        List<leankor__KanbanCard__c>  records = New List<leankor__KanbanCard__c> (); 
        List<KanbanRecordResult> results = New List<KanbanRecordResult>();
               
        if (request.BoardId != null && request.BoardId != '') {
            try{    
                records =[Select leankor__Account__c,
                                leankor__AcceptanceCriteria__c,
                                leankor__CardID__c,
                                leankor__Color__c,
                                leankor__Contact__c,
                                leankor__DescriptionLong__c,
                                leankor__Description__c,
                                leankor__DueDateTime__c,
                                leankor__DurationUnits__c,
                                leankor__EffortRemaining__c,
                                leankor__EstimatedDuration__c,
                                leankor__KanbanCardTemplate__c,
                                leankor__KanbanCardTemplate__r.Name,
                                leankor__Left__c,
                                leankor__MasterContainer__c,
                                leankor__MasterContainer__r.Name,
                                leankor__OnBudget__c,
                                leankor__OnQuality__c,
                                leankor__OnTime__c,
                                leankor__Opportunity__c,
                                leankor__PercentComplete2__c,
                                leankor__Point__c,
                                leankor__Priority__c,
                                leankor__StartDateTime__c,
                                leankor__Swimlane__c,
                                leankor__Swimlane__r.Name,
                                leankor__Title__c,
                                leankor__UrlLink__c,
                                leankor__ValueStreamCardLink__c,
                                leankor__ValueStreamLink__c,
                                leankor__ValueStream__c,
                                leankor__ValueStream__r.Name,
                                leankor__Zone__c,
                                leankor__Zone__r.Name,
                                Name,
                                OwnerId  
                            From leankor__KanbanCard__c 
                            Where leankor__ValueStream__r.Id = :request.BoardId 
                            Limit 49999];
            } catch (Exception e){
                //return results;
                //25/04/2023 : We are Throwing Exception
	            throw new Util.LeanException('ERROR:' + e.getMessage());
            }
        } else if (request.FolderName != null && request.FolderName != '' && request.RoomName != null && request.RoomName != '' && request.BoardName != null && request.BoardName != '') {
            try{    
                /*
                *Modified By : Ashutosh Gour
                *modification : Modification for 200K record issue make Soql Selective and remove negative selection and manage it by apex
                */
                for (leankor__kanbancard__c record : [Select leankor__Account__c,
                                                        leankor__AcceptanceCriteria__c,
                                                        leankor__CardID__c,
                                                        leankor__Color__c,
                                                        leankor__Contact__c,
                                                        leankor__DescriptionLong__c,
                                                        leankor__Description__c,
                                                        leankor__DueDateTime__c,
                                                        leankor__DurationUnits__c,
                                                        leankor__EffortRemaining__c,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__KanbanCardTemplate__c,
                                                        leankor__KanbanCardTemplate__r.Name,
                                                        leankor__Left__c,leankor__MasterContainer__c,
                                                        leankor__MasterContainer__r.Name,
                                                        leankor__OnBudget__c,
                                                        leankor__OnQuality__c,
                                                        leankor__OnTime__c,
                                                        leankor__Opportunity__c,
                                                        leankor__PercentComplete2__c,
                                                        leankor__Point__c,leankor__Priority__c,
                                                        leankor__StartDateTime__c,
                                                        leankor__Swimlane__c,
                                                        leankor__Swimlane__r.Name,
                                                        leankor__Title__c,
                                                        leankor__UrlLink__c,
                                                        leankor__ValueStreamCardLink__c,
                                                        leankor__ValueStreamLink__c,
                                                        leankor__ValueStream__c,
                                                        leankor__ValueStream__r.Name,
                                                        leankor__Zone__c,
                                                        leankor__Zone__r.Name,
                                                        Name,OwnerId 
                                                    From leankor__KanbanCard__c 
                                                    Where leankor__ValueStream__r.Name = :request.BoardName 
                                                        And leankor__ValueStream__r.leankor__ProjectRoom__r.Name = :request.RoomName 
                                                        And leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__portfolio__r.Name = :request.FolderName 
                                                    Limit 49999]) {
                    if (record.leankor__ValueStream__c != null) {
                        records.add(record);
                    }           
                }
            } catch (Exception e){
                //return results;
                //25/04/2023 : We are Throwing Exception
	            throw new Util.LeanException('ERROR:' + e.getMessage());
            }
            
        } else {
            return results;
        }
        
        // if the code gets to here, the Records array should have some values or be empty
               
        KanbanRecordResult result = New KanbanRecordResult();
            
        result.KanbanCards.addAll(records);
        results.add(result);
      
        return results;
    }
    
    //
    // This is Result method for Invocable Method which contain defination on IN variable for API calls
    //
    Global Class KanbanRecordResult{ 
        @invocableVariable(label = 'Kanban Cards' description = 'Cards of selected Board')
            Global List<leankor__KanbanCard__c> KanbanCards = new List<leankor__KanbanCard__c>();
    }

} // end Global Class GetCardsAction