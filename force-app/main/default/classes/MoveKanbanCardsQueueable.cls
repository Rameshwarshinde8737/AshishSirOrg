/**
 * Company : Leankor
 * FILE : MoveKanbanCardsQueueable.cls
 * CLASS : MoveKanbanCardsQueueable
 * USAGE : Move kanbanCards Records.
 */

public with sharing class MoveKanbanCardsQueueable implements Queueable {
    
    private  List< RealTimeController.bulkStreaming > listJSONrecords;
    private Boolean isSendBroadcastMessage;
   
    private MultipleMoveKanbanCardAction.KanbanCardRequest request;
    private List<String> kanbanIds ;
    private Map<Id,leankor__Kanbancard__c> kanbanCardMap ;
    private Map<Id,leankor__Zone__c> kanbanZoneMap ;
    private List<leankor__ZoneKanbanAction__c> zoneKanbanActions ; 
    private Map<Id, Decimal> mapOfTotalTime ;
    private Boolean isFirstCallToMove = false;
    private Set<String> valueStreamIds;
    
    //Constructor for First batch
    public MoveKanbanCardsQueueable(MultipleMoveKanbanCardAction.KanbanCardRequest request, Boolean isFirstCallToMove) {
        this.request = request;
        this.isFirstCallToMove  = isFirstCallToMove ;
    }

    //Constructor for Second batch
    public MoveKanbanCardsQueueable(List<String> kanbanIds, Map<Id,leankor__Kanbancard__c> kanbanCardMap, Map<Id,leankor__Zone__c> kanbanZoneMap, List<leankor__ZoneKanbanAction__c> zoneKanbanActions , Map<Id, Decimal> mapOfTotalTime, Set<String> valueStreamIds, MultipleMoveKanbanCardAction.KanbanCardRequest request) {
        this.kanbanIds = kanbanIds ;
        this.kanbanCardMap = kanbanCardMap ;
        this.kanbanZoneMap =  kanbanZoneMap ;
        this.zoneKanbanActions = zoneKanbanActions ; 
        this.mapOfTotalTime = mapOfTotalTime ;
        this.request = request;
        this.valueStreamIds = valueStreamIds;
    }
    
    public void execute(QueueableContext context) {
        RealTimeController.flowWithGSForAPI = true;
        if (this.isFirstCallToMove) {
            moveKanbanCards(request);
        } else {

            if (request.generateWorkBreakdownStructure == true) {
                CreateKanbanCardsQueueable.updateProjectWBS(valueStreamIds);
            }

            //Calling another batch for remaining records for decrease heap size.
            createZkaRecordsForRemainingCards(kanbanIds, kanbanCardMap, kanbanZoneMap, zoneKanbanActions, mapOfTotalTime);
        }
    }


    /*------------------------------------------------------------
    Company:        Leankor
    Description:    Used to move bulk kanban cards. 
    Inputs:         Object of MultipleMoveKanbanCardAction.KanbanCardRequest class.
    Returns:        -
    ------------------------------------------------------------*/
    public static void moveKanbanCards(MultipleMoveKanbanCardAction.KanbanCardRequest request) {
        List<Id> requestZoneId = new List<Id>();
	    List<Id> requestSwimlaneId = new List<Id>();
	    List<Id> requestMasterContainerId = new List<Id>();
        List<String> requestzoneGuidId = new List<String>();
        List<Id> requestId = new List<Id>();
        List<Id> valueStreamIds = new List<Id>();
        List<String> kanbanIds = new List<String>();  
        Set<String> zoneIds = new Set<String>();
        List<leankor__Zone__c> zones = new List<leankor__Zone__c>(); 	
        Map<Id,leankor__Kanbancard__c> kanbanCardMap = new Map<Id,leankor__Kanbancard__c>();
        Map<Id,leankor__Zone__c> kanbanZoneMap = new Map<Id,leankor__Zone__c>();
        
        String projectId;
		String projectEventCustomPayload;
        Map<String, List<String>> broadcastContentMap =  new Map<String, List<String>>();
        Set<String> broadcastingBoardIds = new Set<String>();
        List<Id> kanbanCardIds = new List<Id>();
        List<leankor__Kanbancard__c> moveKanbanCardList = new List<leankor__Kanbancard__c>();
        // used for broadcast.
		List<RealTimeController.bulkStreaming> bulkStreams = new List<RealTimeController.bulkStreaming>();
        final Integer BROADCAST_REQUEST_LIMIT = 40;
        RealtimeController.flowWithGSForAPI = true;
        
        for (leankor__Kanbancard__c kanban : request.kanbanCardList) {	         												         		
            kanbanIds.add(kanban.Id);	                                
               
            if (String.isNotBlank(kanban.leankor__Zone__c)) {
                requestZoneId.add(kanban.leankor__Zone__c);
            } else if (String.isNotBlank(kanban.leankor__ZoneGUID__c)) {
                requestzoneGuidId.add(kanban.leankor__ZoneGUID__c);
            } else if (String.isNotBlank(kanban.leankor__Swimlane__c)) {
                requestSwimlaneId.add(kanban.leankor__Swimlane__c);
            } else if (String.isNotBlank(kanban.leankor__MasterContainer__c)) {
                requestMasterContainerId.add(kanban.leankor__MasterContainer__c);
            } else {
                requestId.add(kanban.id);
            }							
        }
            
        if (String.isNotBlank(request.projectId)) {
            projectId = request.projectId;
        }
        if (String.isNotBlank(request.projectEventCustomPayload)) {
            projectEventCustomPayload = request.projectEventCustomPayload;
        }
        
        // Read the cards.
        for (leankor__Kanbancard__c kanban : MoveKanbanCard.readKanbanCards(kanbanIds)) {
        	kanbanCardMap.put(kanban.Id, kanban);
            zoneIds.add(kanban.leankor__Zone__c);
        	if (requestId.size() > 0) {
        		valueStreamIds.add(kanban.leankor__ValueStream__c); 
            } 
        }

        // Get all zones based on request mc,sw,zone,zoneguid. 
       	zones = MoveKanbanCard.readZones(requestZoneId, requestSwimlaneId, requestMasterContainerId, requestzoneGuidId, valueStreamIds);
        // If no record found then no need to do anything
        if (zones.size() == 0) {
            throw new Util.LeanException('No related board, zone, master container and swimlane found');
        }
       
        //clear for decrease heap size.
        requestZoneId.clear();
        requestSwimlaneId.clear();
        requestMasterContainerId.clear();
        requestzoneGuidId.clear();
        requestId.clear();
        valueStreamIds.clear();
        
        // Get kanban>>Zone map 
        kanbanZoneMap = MoveKanbanCard.getKanbanZoneMap(request, zones, kanbanCardMap);
        zones.clear();
        
        List<leankor__ZoneKanbanAction__c> zoneKanbanActions = MoveKanbanCard.readZoneKanbanActions(kanbanIds, zoneIds); 
        zoneIds.clear();
        
        leankor__Zone__c zoneData;
        // Process the request
        for (leankor__Kanbancard__c kanban : request.kanbanCardList) 
        {
            // It might possible that record has been deleted.
            if (!kanbanCardMap.containsKey(kanban.Id)) {
                continue;
            }
                
            // Get zone data.
            if (kanbanZoneMap.containsKey(kanban.Id)) {	
                zoneData = kanbanZoneMap.get(kanban.Id);									
            }

            // Get the kanban card
            leankor__Kanbancard__c	kanbanCard = kanbanCardMap.get(kanban.id);	
            																																								   				   					  				  					    				    					    				    					    		
            kanbanCard.leankor__ZoneGUID__c = String.isBlank(kanban.leankor__ZoneGUID__c) ? zoneData.leankor__Guid__c : kanban.leankor__ZoneGUID__c;
            kanbanCard.leankor__MasterContainer__c = String.isBlank(kanban.leankor__MasterContainer__c) ? zoneData.leankor__Swimlane__r.leankor__MasterContainer__c : kanban.leankor__MasterContainer__c;					
            kanbanCard.leankor__Swimlane__c = String.isBlank(kanban.leankor__Swimlane__c) ? zoneData.leankor__Swimlane__c : kanban.leankor__Swimlane__c;																		
            kanbanCard.leankor__Zone__c = String.isBlank(kanban.leankor__Zone__c) ? zoneData.id : kanban.leankor__Zone__c;																						    												   				   															
            kanbanCard.leankor__State__c = (kanban.leankor__ZoneGUID__c == null ? 'nozone' : 'inzone');
            
            moveKanbanCardList.add(kanbanCard);
            broadcastingBoardIds.add(kanbanCard.leankor__ValueStream__c);

            kanbanCardIds.add(kanban.id);
          
        } // End of sObject loop
       
        Savepoint sp = Database.setSavepoint();
        try {	
            for (String  valueStreamId: broadcastingBoardIds ) {
                realtimeController.bulkStreaming listJSONLog = new realtimeController.bulkStreaming();
                listJSONLog.kanbansObjectList = moveKanbanCardList;
                listJSONLog.VSID = valueStreamId;
                listJSONLog.Verb = 'updateKanbancards';
                listJSONLog.SessionID = UserInfo.getSessionId();
                
                // Calling manageBulkStreaming to move the KanbanCard records
                realtimeController.manageBulkStreaming(listJSONLog, true);
            }

            //Pratiksha : Calling newly created method for calculating wait time & then called batch for create remaining records (ZoneKanbanAction). 
            Map<Id, Decimal> totalWaitTime = waitTimeForZoneKanbanAction(zoneKanbanActions);
            if (!Test.isRunningTest()) {
                System.enqueueJob(new MoveKanbanCardsQueueable(kanbanIds, kanbanCardMap, kanbanZoneMap, zoneKanbanActions , totalWaitTime, broadcastingBoardIds, request));
            }
            kanbanIds.clear();
            kanbanCardMap.clear();
            kanbanZoneMap.clear();
            zoneKanbanActions.clear();
            
            if (request.sendBroadcastMessage == true) {
                if (kanbanCardIds.size() <= BROADCAST_REQUEST_LIMIT) {
                    for (String  valueStreamId: broadcastingBoardIds) {
                        RealTimeController.bulkStreaming tempStreaming = new RealTimeController.bulkStreaming();
                        RealTimeController.DirectLinkCardLog tempLog = new RealTimeController.DirectLinkCardLog();
                        tempLog.cardIds = kanbanCardIds;
                        tempLog.ValueStreamID = valueStreamId;
                        tempLog.multipleAPIName = 'MultipleMove';

                        tempStreaming.VSID = valueStreamId;
						tempStreaming.Verb = 'ManageAffectedCards';
						tempStreaming.SessionID = UserInfo.getSessionId();
						tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
						bulkStreams.add(tempStreaming);
                    }
                    RealTimeController.sendBroadcast(bulkStreams, 'ManageAffectedCards');
                } else {
                    broadcastContentMap.put('', new List<String>(broadcastingBoardIds)); 
                    GenericStreamingController.sendBroadcastForBulkRecords('ManageBulkCards', broadcastContentMap, UserInfo.getSessionId());
                }
            }

            /*//------------------- BEGIN platform event broadcast
			if(String.isNotBlank(request.projectId) && Util.getSObjectName(request.projectId) == 'leankor__ProjectRoom__c'){
                leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();
                projectEvent.leankor__EventCategory__c = 'Moving';
                projectEvent.leankor__EventName__c = 'EndMoveWorkItem';
                projectEvent.leankor__IsAPIGenerated__c = true;
                projectEvent.leankor__ProjectID__c = request.projectId;
                projectEvent.leankor__UserID__c = UserInfo.getUserId();
                projectEvent.leankor__CustomPayload__c = request.projectEventCustomPayload;
                projectEvent.leankor__JSONPayload__c = JSON.serialize(kanbanCardIds);

                // Call method to publish events
                Database.SaveResult saveResult = EventBus.publish(projectEvent);
                // quick error processing, no need to Rollback
                if (!saveResult.isSuccess()){
                    for (Database.Error error : saveResult.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
                    }
                    // continue on because a failed platform event is no big deal ; do NOT rollback
                }
            }	
			//------------------- END platform event broadcast*/
        } catch (Exception e) {
            Database.rollback(sp);
            throw new Util.LeanException(e.getMessage());
        } 
        
        //Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in Another try/Catch block.
        try {
            //------------------- BEGIN platform event broadcast
			if (String.isNotBlank(request.projectId) && Util.getSObjectName(request.projectId) == 'leankor__ProjectRoom__c') {
                leankor__ProjectEvent__e projectEvent = new leankor__ProjectEvent__e();
                projectEvent.leankor__EventCategory__c = 'Moving';
                projectEvent.leankor__EventName__c = 'EndMoveWorkItem';
                projectEvent.leankor__IsAPIGenerated__c = true;
                projectEvent.leankor__ProjectID__c = request.projectId;
                projectEvent.leankor__UserID__c = UserInfo.getUserId();
                projectEvent.leankor__CustomPayload__c = request.projectEventCustomPayload;
                projectEvent.leankor__JSONPayload__c = JSON.serialize(kanbanCardIds);

                // Call method to publish events
                Database.SaveResult saveResult = EventBus.publish(projectEvent);
                // quick error processing, no need to Rollback
                if (!saveResult.isSuccess()) {
                    for (Database.Error error : saveResult.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
                    }
                    // continue on because a failed platform event is no big deal ; do NOT rollback
                }
            }	
			//------------------- END platform event broadcast
        } catch(Exception ex) {
            System.debug('ERROR :: '+ex.getMessage());
        }
    }

    /*
		Date :17/06/2021
		To create zoneKanbanAction records for remaining Cards Ids.
		To count kanbancard records on old zone and new Zone for remaining Cards Ids.
	*/
    @TestVisible
	private static void createZkaRecordsForRemainingCards(List<String> requestIds, Map<Id,leankor__Kanbancard__c> mapOfOldzone, Map<Id,leankor__Zone__c>mapOfNewzone, List<leankor__ZoneKanbanAction__c> enterZoneRecords, Map<Id, Decimal> mapOfTotalTime) {			
		Integer kanbanCount = 1;
		Integer KanbanCount1= 1;

		//create ZoneKanbanAction records.
		List<leankor__ZoneKanbanAction__c> zoneKanbanActionList =new List<leankor__ZoneKanbanAction__c>();
		Set<String> zoneIds=new Set<String>();
		Map<String,String> mapOfzones=new Map<String,String>(); 
        if (enterZoneRecords.Size() > 0) {
            kanbanCount = -1;                             
		}             			
		leankor__ZoneKanbanAction__c zoneKanbanAction;
		leankor__ZoneKanbanAction__c zoneKanbanAction1; 
		leankor__Zone__c newZoneData =new leankor__Zone__c();    	   	
		leankor__Kanbancard__c oldZoneData=new leankor__Kanbancard__c();           
		
        //create  zoneKanbanAction Data.      
        for (String requestid: requestIds) { 
			if (mapOfNewzone.containsKey(requestid)) {
				newZoneData = mapOfNewzone.get(requestid);  
			} 
			if (mapOfOldzone.containsKey(requestid)) {
				oldZoneData = mapOfOldzone.get(requestid);
			}      	 	      	   				 		       		
        	zoneKanbanAction = new leankor__ZoneKanbanAction__c();
        	zoneKanbanAction1 = new leankor__ZoneKanbanAction__c();        			    				 	    		      		        		        		    	        			
			
			if (String.isNotBlank(newZoneData.Id)  &&  String.isNotBlank(oldZoneData.leankor__Zone__c)) {					
			 	if (newZoneData.Id !=oldZoneData.leankor__Zone__c) {		 	 	
					//create  ZoneKanbanAction data with Left Zone action. 
					zoneKanbanAction.leankor__KanbanCard2__c = requestid;                    
					zoneKanbanAction.leankor__Zone2__c = oldZoneData.leankor__Zone__c;  
					zoneKanbanAction.leankor__Swimlane__c = oldZoneData.leankor__Swimlane__C;  
					zoneKanbanAction.leankor__MasterContainer__c = oldZoneData.leankor__MasterContainer__c;             
					zoneKanbanAction.leankor__OtherZone__c = newZoneData.id;                   
					zoneKanbanAction.leankor__OtherSwimlane__c =  newZoneData.leankor__Swimlane__C;
					zoneKanbanAction.leankor__OtherMasterContainer__c =  newZoneData.leankor__Swimlane__r.leankor__MasterContainer__c;
					zoneKanbanAction.leankor__ValueStream__c = oldZoneData.leankor__ValueStream__C;
					zoneKanbanAction.leankor__SessionID__c = UserInfo.getSessionId();
					zoneKanbanAction.leankor__ActionType2__c = 'Left Zone';                                       
					zoneKanbanAction.leankor__WaitTime2__c = mapOfTotalTime.get(requestid); 										
					zoneKanbanActionList.add(zoneKanbanAction);  
					//add zone ids into the List to  count kanbancards on zone.
					zoneIds.add(zoneKanbanAction.leankor__Zone2__c); 
					//add old zone data into the map.
					mapOfzones.put(oldZoneData.leankor__Zone__c,oldZoneData.leankor__Zone__c);                                             		        				
					
					//create  ZoneKanbanAction data with Entered Zone action.     			
					zoneKanbanAction1.leankor__KanbanCard2__c = requestid;                   
					zoneKanbanAction1.leankor__Zone2__c = newZoneData.id;
					zoneKanbanAction1.leankor__Swimlane__c =newZoneData.leankor__Swimlane__C;
					zoneKanbanAction1.leankor__MasterContainer__c =  newZoneData.leankor__Swimlane__r.leankor__MasterContainer__c;
					zoneKanbanAction1.leankor__OtherZone__c = oldZoneData.leankor__Zone__c;
					zoneKanbanAction1.leankor__OtherSwimlane__c =oldZoneData.leankor__Swimlane__C;
					zoneKanbanAction1.leankor__OtherMasterContainer__c = oldZoneData.leankor__MasterContainer__c;
					zoneKanbanAction1.leankor__ValueStream__c = oldZoneData.leankor__ValueStream__C;
					zoneKanbanAction1.leankor__SessionID__c = UserInfo.getSessionId();
					zoneKanbanAction1.leankor__ActionType2__c = 'Entered Zone';                                                            
					zoneKanbanAction1.leankor__WaitTime2__c = 0; 
					
					zoneKanbanActionList.add(zoneKanbanAction1); 
					//add zone ids into the List to   count kanbancard on zone.  
					zoneIds.add(zoneKanbanAction1.leankor__Zone2__c);  
			 	} 
			} 
		} 
	    mapOfTotalTime.clear();
		requestIds.clear();
		//create List of zoneKanbanAction records.     
		if (zoneKanbanActionList.size() > 0) {
			Insert zoneKanbanActionList; 
		}  
		
		zoneKanbanActionList.clear();
		//To get map of zone based on New zone Id and Old Zone Id	       
        Map <Id, leankor__Zone__c> mapOfCurrentZone = new Map <Id, leankor__Zone__c>([Select Id, 			   																
                                                                                    leankor__KanbanCardCount2__c, 																			
                                                                                    Name																			
                                                                                From leankor__Zone__c 
                                                                                Where Id In :zoneIds 
                                                                                Limit 50000]);        									
		for (String zone:zoneIds) {										
			// KanbanCard Count is decrease if  zka action is Left zone.										
			if (mapOfzones.containsKey(zone)) {										
				mapOfCurrentZone.get(zone).leankor__KanbanCardCount2__c+= KanbanCount;
			} else {					
				mapOfCurrentZone.get(zone).leankor__KanbanCardCount2__c += KanbanCount1;
			} 
		}
		zoneIds.clear();
		mapOfzones.clear();
		
		if (leankor__Zone__c.sObjectType.getDescribe().isUpdateable()) {
				DataBase.update(new List<leankor__Zone__c> (mapOfCurrentZone.values()));
		} 

		mapOfCurrentZone.clear();
	}
    


    /*
		Date :17/06/2021
		To Calculate Wait time if zKanbanAction.action == 'Left Zone'
	*/
    public static Map<Id, Decimal> waitTimeForZoneKanbanAction( List<leankor__ZoneKanbanAction__c> enterZoneRecords) {			
		String returnString = 'success';       
		Double decHours = 0;
		Decimal diffMin = 0;
		Decimal totalTime = 0;
		
		//Calculate Wait time if zKanbanAction.action == 'Left Zone'
		Map<Id, Decimal> mapOfTotalTime =new Map<Id, Decimal>();		
		//calculate WaitTime  from  old zone ZoneKanbanAction and use If zKanbanAction.action is Left zone .
		if (enterZoneRecords.Size() > 0) {
			for (leankor__ZoneKanbanAction__c  enterZone : enterZoneRecords) {
				DateTime leftZoneTime = System.Now();
				if (leftZoneTime.isSameDay(enterZone.CreatedDate)) {
					// Checking Kanban Card enter and left the zone is same or not.
					decHours = (((leftZoneTime.getTime()) / 1000 / 60) - ((enterZone.CreatedDate.getTime()) / 1000 / 60)) / 60;
					diffMin = (((leftZoneTime.getTime()) / 1000 / 60) - ((enterZone.CreatedDate.getTime()) / 1000 / 60)) - (decHours * 60);
					totalTime = decHours + (diffMin / 100);
				} else {
					Integer DiffInDays = enterZone.CreatedDate.date().daysBetween(leftZoneTime.date());
					datetime SameDayEndDate = enterZone.CreatedDate.addDays(DiffInDays);
					decHours = (((leftZoneTime.getTime()) / 1000 / 60) - ((SameDayEndDate.getTime()) / 1000 / 60)) / 60;
					diffMin = (((leftZoneTime.getTime()) / 1000 / 60) - ((SameDayEndDate.getTime()) / 1000 / 60)) - (decHours * 60);
					decHours = (DiffInDays * 8) + decHours;
					totalTime = decHours + (diffMin / 100);
				}
				mapOfTotalTime.put(enterZone.leankor__KanbanCard2__c,totalTime);           	
			}                              
		}             			
		return mapOfTotalTime;
	}
}