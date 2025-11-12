/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  MoveKanbanCardAction.cls
* CLASS: MoveKanbanCardAction
* USAGE: manages to Upadte Record like Swimlanes,MasterContainer,zone MC of Card .
*/
global with sharing class MoveKanbanCardAction {
    //
    // This is Process method for Move KanbanCard BY API calls
    //
	private static Boolean generateWorkBreakdownStructure;


    @InvocableMethod
    global static Void  moveKanbanCardProcess(List<KanbanCardRequest> requests) {
		for (KanbanCardRequest request : requests) {
			if (String.isNotBlank(request.Id) && Util.getSObjectName(request.Id) != 'leankor__KanbanCard__c') {
				throw new Util.LeanException('Error: Invalid input');
			}
			generateWorkBreakdownStructure = request.generateWorkBreakdownStructure;
		}

       List<KanbanCardRequest> kanbanRequestList = new  List<KanbanCardRequest>();
       List<leankor__Kanbancard__c> kanbancardList = new List<leankor__Kanbancard__c>();
       Savepoint sp = Database.setSavepoint();
       for (KanbanCardRequest request : requests) {
           if (request.kanbancardList.size() > 0) {     
           		kanbancardList.addAll(request.kanbancardList);    		                  
           } else {
           	   kanbanRequestList.add(request);            
           }           
        } 
        List<leankor.RealTimeController.Kanban> remoteKanbancardList;
        try {
			if (kanbancardList.size() > 0) { 
				remoteKanbancardList = moveMultipleKanbanCards(kanbancardList);
			}
			else if (kanbanRequestList.size() > 0) {
				remoteKanbancardList = moveKanbanCard(kanbanRequestList);
			}  
			if (remoteKanbancardList.size() > 0) {
				updateMovedCards(remoteKanbancardList);
			}             
        } catch (Exception e) {
        	Database.rollback(sp);
            throw new Util.LeanException(e.getMessage());  
             
    	}
    }
    /*-----------------------------------------------------------------------
      Company: 		Leankor
      Description: 	This Method updating moved kanban cards.     
      Input : 		List<leankor.RealTimeController.Kanban> 
      OutPut : 		void 
      Date: 		18/12/18
      
    -------------------------------------------------------------------------------*/
    public static void updateMovedCards( List<leankor.RealTimeController.Kanban> remoteKanbancardList) {
    	List<leankor.realtimeController.bulkStreaming> listJSONrecords = new List<leankor.realtimeController.bulkStreaming>();
		Set<String> valueStreamIds = new Set<String>();
    	for (leankor.RealTimeController.Kanban remotekanban : remoteKanbancardList) {			
			leankor.realtimeController.bulkStreaming listJSONLog = new leankor.realtimeController.bulkStreaming();
			listJSONLog.someJSONData = JSON.Serialize(remotekanban);
			listJSONLog.VSID = remotekanban.ValueStream;
			listJSONLog.Verb = 'MoveKanbanCard';
			listJSONLog.SessionID = UserInfo.getSessionId();	  	 
			listJSONrecords.add(listJSONLog);	
			valueStreamIds.add(remotekanban.valueStream);			 
	 	}	

		if (generateWorkBreakdownStructure == true) {
			CreateKanbanCardsQueueable.updateProjectWBS(valueStreamIds);
		}
		try{		 	
		 	//call manageBulkStreaming method for updating kanban cards data.
         	leankor.realtimeController.manageBulkStreaming(listJSONrecords, 'MoveKanbanCard');
       	} catch (Exception e){
            throw new Util.LeanException(e.getMessage());
       	}
    }
    
    /*------------------------------------------------------------
	Company: 		Leankor
	Description:    This method return List of kanban card instance for DML of multiple kanban cards.
	Inputs: 		List<KanbanCardRequest> (flow for request instance)
	Returns: 		List<leankor.RealTimeController.Kanban>
	Date: 			13/12/18
	------------------------------------------------------------*/    
    public static List<leankor.RealTimeController.Kanban> moveKanbanCard(List<KanbanCardRequest> requestList) { 
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
		List<leankor__Kanbancard__c> kanbanCards = new List<leankor__Kanbancard__c>();
		List<String> tempKanbanIds = new List<String>();
		Map<Id, leankor__Kanbancard__c> mapOfKanbancard = new Map<Id, leankor__Kanbancard__c>(); 
		List<String> valueStreamIds = new List<String>();     							
		Map<Id, leankor__Zone__c> mapOfzone = new Map<Id, leankor__Zone__c>(); 
		List<String> someJSONDataList = new List<String>();
	    List<leankor.RealTimeController.Kanban> remoteKanbancardList = new List<leankor.RealTimeController.Kanban>();    							
	  	List<String> zoneIds = new List<String>();
	  	for (KanbanCardRequest request : requestList) {
			String tempKanbanId = request.Id;
			if (tempKanbanId == null || tempKanbanId == '') {
					tempKanbanId = request.CardURL.substringAfter('cardid=');
            }           												         		
			tempKanbanIds.add(tempKanbanId);			
	   	}	  
       	try{
          //get all kanban card records based on request id.
          kanbanCards = [Select Id,
		  						leankor__cardID__c,
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
								leankor__cardDetails__c,
								leankor__case__c,
								leankor__cmpID__c,
								leankor__color__c,
								leankor__completionVariance__c,
								leankor__contact__c,
								leankor__cSSLayout__c,
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
								leankor__MasterContainer__c,
								leankor__Zone__c,
								leankor__Swimlane__c 
							From leankor__KanbanCard__c Where Id In :tempKanbanIds  
							Limit 50000]; 
       	} catch (Exception e) {
            throw new Util.LeanException(e.getMessage());
        }                 
	    for (leankor__Kanbancard__c kanbancard:kanbanCards) {
			valueStreamIds.add(kanbancard.leankor__ValueStream__c);
			mapOfKanbancard.put(kanbancard.id,kanbancard);
			// Date :19/09/19 add old zone ids into List to get zonekanbanAction records.
			zoneIds.add(kanbancard.leankor__Zone__c);
		}
		//get all zones from  kanban card valuestream .								    				
		List<leankor__Zone__c> zones = [Select Id,
												Name,leankor__GUID__C,leankor__Swimlane__r.name,leankor__Swimlane__C,
												leankor__Swimlane__r.leankor__MasterContainer__C,leankor__Swimlane__r.leankor__MasterContainer__r.name,
												leankor__valuestream__c 
											From leankor__Zone__C 
											Where leankor__ValueStream__C =:valueStreamIds 
											With Security_Enforced 
											Limit 49999];					
		Boolean flag = false;
		for (leankor__Zone__c zone : zones) {
			for (KanbanCardRequest request:requestList) {		 			 				      		     

				// Abhishek Joshi (04/08/2022) if inside a Flow we are not send Kanbancard id only URL we send,so at that time card id Which is present in URL assign to request.id
				if (String.isBlank(request.Id) && String.isNotBlank(request.CardURL)) {
					request.id = request.CardURL.substringAfter('cardid=');
				}	 			 				      		     
		       	if (mapOfKanbancard.get(request.Id).leankor__valuestream__c == zone.leankor__valuestream__c) {	       	
					if (request.ColumnName ==zone.name && request.MCName == zone.leankor__Swimlane__r.leankor__MasterContainer__r.name && request.SwimlaneName==zone.leankor__Swimlane__r.name) {
						mapOfzone.put(request.Id, zone);			       	 				       	 			       	 	
						flag = true;
					}
					else if (request.ColumnName == zone.name && request.MCName == zone.leankor__Swimlane__r.leankor__MasterContainer__r.Name && String.isBlank(request.SwimlaneName)) {		       	 		 	
							mapOfzone.put(request.Id,zone);			       	 		       	 	
						flag = true;
					} else if (request.MCName == zone.leankor__Swimlane__r.leankor__MasterContainer__r.Name && request.SwimlaneName==zone.leankor__Swimlane__r.name && String.isBlank(request.ColumnName)) {
						mapOfzone.put(request.Id,zone);			       	 	   				       	 	  
						flag = true;
					} else if (request.MCName == zone.leankor__Swimlane__r.leankor__MasterContainer__r.Name && String.isBlank(request.ColumnName) && String.isBlank(request.SwimlaneName)) {
						mapOfzone.put(request.Id,zone);		       	 					       	 		 	
						flag = true;
					}
					else if (request.ColumnName == zone.name && String.isBlank(request.MCName) && String.isBlank(request.SwimlaneName)) {
						mapOfzone.put(request.Id,zone);		       	 				       	 			
						flag = true;
					}
					else if (request.ColumnName == zone.name && request.SwimlaneName==zone.leankor__Swimlane__r.name && String.isBlank(request.MCName)) {
						// 09/01/2020 
						// changes : 
						mapOfzone.put(request.Id,zone);	
						flag = true;
					} else if (request.SwimlaneName == zone.leankor__Swimlane__r.name && String.isBlank(request.MCName) && String.isBlank(request.ColumnName)) {
						// 08/01/2020 
						// changes : 
						mapOfzone.put(request.Id,zone);		
						flag = true;
					} else {
						// 08/01/2020 
						// changes : if MCName || SwimlaneName || ColumnName are blank or wrong then set default Master Container
						if (zone.leankor__Swimlane__r.leankor__MasterContainer__r.Name == 'BackLog') {
							mapOfZone.put(request.Id,zone);		      							      						 							      					
						}
					}			       	 		
		       	}
		    }		 		 		 
			if (flag == true) {
				break;
			}		
		}		
		//Date :23/09/19 get zoneKanbanAction records.		
        List <leankor__ZoneKanbanAction__c > zoneKanbanActions = [Select CreatedDate, 
																		Id, leankor__ActionType2__c, 
																		leankor__KanbanCard2__c, leankor__ValueStream__c, leankor__Zone2__c, 
																		Name, leankor__WaitTime2__c 
																	From leankor__ZoneKanbanAction__c
																	Where leankor__KanbanCard2__c In :tempKanbanIds  
																		And leankor__Zone2__c In :zoneIds 
																		And leankor__ActionType2__c = 'Entered Zone' 
																	With Security_Enforced
																	Order By CreatedDate Desc Nulls First 
																	Limit 4999];		
        //To create zoneKanbanAction records.
        String zoneKanbanAction = createZkaRecords(tempKanbanIds,mapOfKanbancard,mapOfzone,zoneKanbanActions);      		
		
		for (leankor__Kanbancard__c kanbanCard:kanbanCards) {					
		    		leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
					remoteKanban.Id = kanbanCard.id;
					remoteKanban.CardId = kanbanCard.leankor__cardID__c;
					remoteKanban.ForceID = kanbanCard.id;
					remoteKanban.Point = kanbanCard.leankor__Point__c;
					remoteKanban.UrlLink = kanbanCard.leankor__UrlLink__c;
					remoteKanban.GUID = kanbanCard.leankor__GUID__c; 
					remoteKanban.Title = (kanbanCard.leankor__Title__c == null ? '' : kanbanCard.leankor__Title__c); 
					remoteKanban.Name =  kanbanCard.Name;
					remoteKanban.Top = ( kanbanCard.leankor__Top__c == null ? 2100 : kanbanCard.leankor__Top__c);
					remoteKanban.Bottom = (kanbanCard.leankor__Bottom__c == null ? 0 : kanbanCard.leankor__Bottom__c);
					remoteKanban.Left = (kanbanCard.leankor__Left__c == null ? 2100 : kanbanCard.leankor__Left__c);
					remoteKanban.Width = (kanbanCard.leankor__Width__c == null ? 170 : kanbancard.leankor__Width__c);
					remoteKanban.Height = (kanbanCard.leankor__Height__c == null ? 85 :kanbanCard.leankor__Height__c);
					RemoteKanban.X = (kanbanCard.leankor__X__c == null ? 0 : kanbanCard.leankor__X__c);
					remoteKanban.Y = (kanbanCard.leankor__Y__c == null ? 0 : kanbanCard.leankor__Y__c);
					remoteKanban.JSONDefinition = (kanbanCard.leankor__JSONDefinition__c == null ? '{}' : kanbanCard.leankor__JSONDefinition__c);
					remoteKanban.JSONData =(kanbanCard.leankor__JSONData__c == null ? '{}' : kanbanCard.leankor__JSONData__c);
					remoteKanban.TemplateID = kanbanCard.leankor__KanbanCardTemplate__c;
					remoteKanban.Color = kanbanCard.leankor__color__c; 
					remoteKanban.AcceptanceCriteria = (kanbanCard.leankor__AcceptanceCriteria__c == null ? '': kanbanCard.leankor__AcceptanceCriteria__c);
					remoteKanban.Description = (kanbanCard.leankor__DescriptionLong__c == null ? '': kanbanCard.leankor__DescriptionLong__c);
					remoteKanban.DueDate = (kanbanCard.leankor__DueDateTime__c == null ? System.Now(): kanbanCard.leankor__DueDateTime__c);
					remoteKanban.EstimatedDuration = ( kanbanCard.leankor__EstimatedDuration__c == null ? 1 :kanbanCard.leankor__EstimatedDuration__c );
					remoteKanban.DurationUnits = (kanbanCard.leankor__DurationUnits__c == null ? 'Days': kanbanCard.leankor__DurationUnits__c );
					remoteKanban.Priority = (kanbanCard.leankor__Priority__c == null ? 0 : Integer.ValueOf(kanbanCard.leankor__Priority__c));
					remoteKanban.OwnerID = kanbanCard.OwnerID;
					remoteKanban.HarveyBall = (kanbanCard.leankor__PercentComplete2__c == null ? '0' : String.ValueOf(kanbanCard.leankor__PercentComplete2__c));
					remoteKanban.ValueStreamCardLink = (kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__c);
					remoteKanban.ValueStreamLinkID = (kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__c );
					remoteKanban.ValueStream = kanbanCard.leankor__ValueStream__c;
					remoteKanban.Account = (kanbanCard.leankor__Account__c == null ?'' : kanbanCard.leankor__Account__c );
					remoteKanban.Opportunity =(kanbanCard.leankor__Opportunity__c == null ?'' : kanbanCard.leankor__Opportunity__c );
					remoteKanban.Contact = (kanbanCard.leankor__contact__c == null ?'' : kanbanCard.leankor__contact__c );
					remoteKanban.CaseID = (kanbanCard.leankor__case__c == null ?'' : kanbanCard.leankor__case__c );
					remoteKanban.Order = (kanbanCard.leankor__Order__c == null ?0 : kanbanCard.leankor__Order__c );
					remoteKanban.OnBudget = (kanbanCard.leankor__OnBudget__c == null ?'Green' : kanbanCard.leankor__OnBudget__c );
					remoteKanban.OnQuality = (kanbanCard.leankor__OnQuality__c == null ?'Green' : kanbanCard.leankor__OnQuality__c );
					remoteKanban.OnTime =(kanbanCard.leankor__OnTime__c == null ?'Green' : kanbanCard.leankor__OnTime__c );
					remoteKanban.StartDate = (kanbanCard.leankor__StartDateTime__c == null ? System.Now() : kanbanCard.leankor__StartDateTime__c );
					remoteKanban.KanbanUrl = 'https://' + DomainCreator.getOrgMyDomainHostname();
					remoteKanban.flowWithGS = true;  //Rs 12/12/2017  for gs in flow
					if (KanbanCard.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board') {
						remoteKanban.KanbanUrl += (new PageReference('/apex/leankor__KanbanBoard').getUrl())+'?Id='+kanbanCard.leankor__ValueStream__c+'&cardid=';
					} else if (kanbanCard.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
						remoteKanban.KanbanUrl +=(new PageReference('/apex/leankor__PortfolioView').getUrl())+'?Id='+kanbanCard.leankor__ValueStream__c+'&cardid=';
					} else {
						remoteKanban.KanbanUrl +=(new PageReference('/apex/leankor__VisualKanban').getUrl())+'?Id='+kanbanCard.leankor__ValueStream__c+'&cardid=';
					} 
					remoteKanban.LeavedZoneID = (kanbanCard.leankor__ZoneGUID__c == null ? '' : kanbanCard.leankor__ZoneGUID__c );																	
					if (zones.Size() > 0) {																		   
				   		leankor__Zone__c zone =mapOfzone.get(kanbanCard.id);				  				  	
				    		if (zone!=null) {
				    			remoteKanban.ZoneID = zone.leankor__GUID__c;
								remoteKanban.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
								remoteKanban.SWForceID =zone.leankor__Swimlane__c;													
								remoteKanban.ZoneforceID =zone.ID;
								remoteKanban.ZoneTitle = zone.Name;								
				    		}										   				   
					}											
					remoteKanban.State = (remoteKanban.ZoneID == null ? 'nozone' : 'inzone');
					remoteKanbancardList.add(remoteKanban);					    					
		}		
		return remoteKanbancardList;
	} 
	
    /*------------------------------------------------------------
	Company: 		Leankor
	Description:    This method return List of kanban card instance for DML of multiple kanban cards.
	Inputs: 		List<leankor__Kanbancard__c>
	Returns: 		List<leankor.RealTimeController.Kanban>
	Date: 			13/12/18
	------------------------------------------------------------*/  
    public static List<leankor.RealTimeController.Kanban> moveMultipleKanbanCards(List<leankor__Kanbancard__c> kbrequestList) { 
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
       	List<leankor__Kanbancard__c>  kanbanCards = new List<leankor__Kanbancard__c>();
      	List<String> tempKanbanIds=new List<String>();  
        //put request id and kanban card record.							 
	  	Map<Id,leankor__Kanbancard__c> mapOfKanbancard=new Map<Id,leankor__Kanbancard__c>();
	  	List<String> someJSONDataList = new List<String>();
	  	//put request kanbancard id and zone record.
	  	Map<Id,leankor__Zone__c> mapOfZone=new Map<Id,leankor__Zone__c>();
	    List<leankor.RealTimeController.Kanban> remoteKanbancardList = new List<leankor.RealTimeController.Kanban>();
	    List<Id> requestZoneId = new List<Id>();
	    List<Id> requestSwimlaneId = new List<Id>();
	    List<Id> requestMasterContainerId = new List<Id>();
	    List<String> requestzoneGuidId = new List<String>();
	    //add list of request kanban card id if request mc && sw && zone is null or blank.
	    List<Id> requestId = new List<Id>();
	    //add valuestream ids from kanbacard records for geting zones. 
	    List<Id> valueStreamIds = new List<Id>();	  
	  	for (leankor__Kanbancard__c request: kbrequestList) {
			String tempKanbanId = request.Id;			         												         		
			tempKanbanIds.add(tempKanbanId);											
			if (String.isNotBlank(request.leankor__Zone__c)) {
				requestZoneId.add(request.leankor__Zone__c);
	   		}	  
			else if (String.isNotBlank(request.leankor__ZoneGUID__c)) {
				requestzoneGuidId.add(request.leankor__ZoneGUID__c);
			}
			else if (String.isNotBlank(request.leankor__Swimlane__c)) {
				requestSwimlaneId.add(request.leankor__Swimlane__c);
			}
			else if (String.isNotBlank(request.leankor__Mastercontainer__c)) {
			     requestMasterContainerId.add(request.leankor__Mastercontainer__c);
			} else {
				requestId.add(request.id);
			}							
	   	}	  
        	//get all kanban card records based on request kanbancard ids.
       	kanbanCards = [Select Id,
	   							leankor__cardID__c,
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
								leankor__cardDetails__c,
								leankor__case__c,
								leankor__cmpID__c,
								leankor__color__c,
								leankor__completionVariance__c,
								leankor__contact__c,
								leankor__cSSLayout__c,
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
							Where Id In :tempKanbanIds 
							Limit 50000]; 
       List<String> zoneIds=new List<String>();
        for (leankor__Kanbancard__c kb:kanbanCards) {
        	mapOfKanbancard.put(kb.id,kb);
        	// Date :19/09/19 add old zone ids into List to get zonekanbanAction records.
			zoneIds.add(kb.leankor__Zone__c);
        	if (requestId.size() > 0) {
        		valueStreamIds.add(kb.leankor__ValueStream__c); 
        	} 
        }
        List<leankor__Zone__c> zones= new List<leankor__Zone__c>(); 
        //get all zones based on request mc,sw,zone,zoneguid.        	
       	zones = [Select Id,
						Name,leankor__GUID__C,leankor__Swimlane__r.name,leankor__Swimlane__C,leankor__Swimlane__r.leankor__MasterContainer__C,
						leankor__Swimlane__r.leankor__MasterContainer__r.name,leankor__valuestream__c 
					From leankor__Zone__c 
					Where (Id In :requestZoneId 
							Or leankor__Swimlane__C In :requestSwimlaneId 
							Or leankor__Swimlane__r.leankor__MasterContainer__C In :requestMasterContainerId 
							Or leankor__Guid__c In :requestzoneGuidId 
							Or leankor__valuestream__c In :valueStreamIds)  
					With Security_Enforced
					Limit 49999];	                 		       
       	if (zones.size()>0) {			
		    for (leankor__Kanbancard__c request:kbrequestList) {
		     	for (leankor__Zone__c zone:zones) {
		     		//compare with request valuestream id and zone valuestream id.
		    		if (mapOfKanbancard.get(request.id).leankor__ValueStream__c==zone.leankor__ValueStream__c) {		      				
		    		    //
		    		    if (String.isBlank(request.leankor__Zone__c) && String.isBlank(request.leankor__ZoneGUID__c)&& String.isBlank(request.leankor__Mastercontainer__c)&& String.isBlank(request.leankor__SwimLane__c)){
		    				if (zone.leankor__Swimlane__r.leankor__MasterContainer__r.Name == 'BackLog') {
		    					mapOfZone.put(request.id,zone);		      					
		    					break;     					
		    				}
		    			} else if(request.leankor__Zone__c ==zone.id) {
		    				mapOfZone.put(request.id,zone);
		    			    break;   
		    			} else if(request.leankor__ZoneGUID__c==zone.leankor__GUID__c) {
		    				mapOfZone.put(request.id,zone);		      				    
		    			    break;
		    			} else if(request.leankor__SwimLane__c== zone.leankor__SwimLane__c) {
		    			    mapOfZone.put(request.id,zone);	      				   
		    			    break;		      				  	   
		    			}else if ( request.leankor__Mastercontainer__c==zone.leankor__SwimLane__r.leankor__Mastercontainer__c ) {
		    				mapOfZone.put(request.id,zone);		      					
		    				break;    				
						}
					}     	         			   
		    	}
			}					   
		}    	         			   
		//Date :23/09/19 get zoneKanbanAction records.	
        List <leankor__ZoneKanbanAction__c > zoneKanbanActions = [Select CreatedDate,
																		Id, leankor__ActionType2__c, leankor__KanbanCard2__c, leankor__ValueStream__c, 
																		leankor__Zone2__c, Name, leankor__WaitTime2__c 
																	From leankor__ZoneKanbanAction__c 
																	Where leankor__KanbanCard2__c In :tempKanbanIds  
																		And leankor__Zone2__c In :zoneIds 
																		And leankor__ActionType2__c = 'Entered Zone' 
																	With Security_Enforced
																	Order By CreatedDate Desc Nulls First 
																	Limit 4999];		
       //To create zoneKanbanAction records.
        String zoneKanbanAction = createZkaRecords(tempKanbanIds, mapOfKanbancard, mapOfzone, zoneKanbanActions);      	
        		        			   
		for (leankor__Kanbancard__c kbrequest : kbrequestList) {
				//get kanban cards Data from map.
				leankor__Kanbancard__c	kanbanCard = mapOfKanbancard.get(kbrequest.Id);	
				//get zone data.
				leankor__Zone__c zoneData;
				if (zones.size() > 0) {
					zoneData=mapOfZone.get(kbrequest.Id);									
				}
				Id valuestreamId=String.isBlank(kbrequest.leankor__ValueStream__c) ? zoneData.leankor__ValueStream__c : kbrequest.leankor__ValueStream__c;							
		   		leankor.RealTimeController.Kanban remoteKanban = new leankor.RealTimeController.Kanban();
				remoteKanban.Id = kanbanCard.id;
				remoteKanban.CardId = kanbanCard.leankor__cardID__c;
				remoteKanban.ForceID = kanbanCard.id;
				remoteKanban.Point = kanbanCard.leankor__Point__c;
				remoteKanban.UrlLink = kanbanCard.leankor__UrlLink__c;
				remoteKanban.GUID = kanbanCard.leankor__GUID__c; 
				remoteKanban.Title = (kanbanCard.leankor__Title__c == null ? '' : kanbanCard.leankor__Title__c); 
				remoteKanban.Name =  kanbanCard.Name;
				remoteKanban.Top = ( kanbanCard.leankor__Top__c == null ? 2100 : kanbanCard.leankor__Top__c);
				remoteKanban.Bottom = (kanbanCard.leankor__Bottom__c == null ? 0 : kanbanCard.leankor__Bottom__c);
				remoteKanban.Left = (kanbanCard.leankor__Left__c == null ? 2100 : kanbanCard.leankor__Left__c);
				remoteKanban.Width = (kanbanCard.leankor__Width__c == null ? 170 : kanbancard.leankor__Width__c);
				remoteKanban.Height = (kanbanCard.leankor__Height__c == null ? 85 :kanbanCard.leankor__Height__c);
				remoteKanban.X = (kanbanCard.leankor__X__c == null ? 0 : kanbanCard.leankor__X__c);
				remoteKanban.Y = (kanbanCard.leankor__Y__c == null ? 0 : kanbanCard.leankor__Y__c);
				remoteKanban.JSONDefinition = (kanbanCard.leankor__JSONDefinition__c == null ? '{}' : kanbanCard.leankor__JSONDefinition__c);
				remoteKanban.JSONData = (kanbanCard.leankor__JSONData__c == null ? '{}' : kanbanCard.leankor__JSONData__c);
				remoteKanban.TemplateID = kanbanCard.leankor__KanbanCardTemplate__c;
				remoteKanban.Color = kanbanCard.leankor__color__c; 
				remoteKanban.AcceptanceCriteria = (kanbanCard.leankor__AcceptanceCriteria__c == null ? '': kanbanCard.leankor__AcceptanceCriteria__c);
				remoteKanban.Description = (kanbanCard.leankor__DescriptionLong__c == null ? '': kanbanCard.leankor__DescriptionLong__c);
				remoteKanban.DueDate = (kanbanCard.leankor__DueDateTime__c == null ? System.Now(): kanbanCard.leankor__DueDateTime__c);
				remoteKanban.EstimatedDuration = ( kanbanCard.leankor__EstimatedDuration__c == null ? 1 :kanbanCard.leankor__EstimatedDuration__c);
				remoteKanban.DurationUnits = (kanbanCard.leankor__DurationUnits__c == null ? 'Days': kanbanCard.leankor__DurationUnits__c );
				remoteKanban.Priority = (kanbanCard.leankor__Priority__c == null ? 0 : Integer.ValueOf(kanbanCard.leankor__Priority__c));
				remoteKanban.OwnerID = kanbanCard.OwnerID;
				remoteKanban.HarveyBall = (kanbanCard.leankor__PercentComplete2__c == null ? '0' : String.ValueOf(kanbanCard.leankor__PercentComplete2__c));
				remoteKanban.ValueStreamCardLink = (kanbanCard.leankor__ValueStreamCardLink__c == null ? '' : kanbanCard.leankor__ValueStreamCardLink__c);
				remoteKanban.ValueStreamLinkID = (kanbanCard.leankor__ValueStreamLink__c == null ? '' : kanbanCard.leankor__ValueStreamLink__c);
				remoteKanban.ValueStream = valuestreamId;
				remoteKanban.Account = (kanbanCard.leankor__Account__c == null ?'' : kanbanCard.leankor__Account__c);
				remoteKanban.Opportunity =(kanbanCard.leankor__Opportunity__c == null ?'' : kanbanCard.leankor__Opportunity__c);
				remoteKanban.Contact = (kanbanCard.leankor__contact__c == null ?'' : kanbanCard.leankor__contact__c);
				remoteKanban.CaseID = (kanbanCard.leankor__case__c == null ?'' : kanbanCard.leankor__case__c);
				remoteKanban.Order = (kanbanCard.leankor__Order__c == null ?0 : kanbanCard.leankor__Order__c);
				remoteKanban.OnBudget = (kanbanCard.leankor__OnBudget__c == null ?'Green' : kanbanCard.leankor__OnBudget__c);
				remoteKanban.OnQuality = (kanbanCard.leankor__OnQuality__c == null ?'Green' : kanbanCard.leankor__OnQuality__c);
				remoteKanban.OnTime = (kanbanCard.leankor__OnTime__c == null ? 'Green' : kanbanCard.leankor__OnTime__c);
				remoteKanban.StartDate = (kanbanCard.leankor__StartDateTime__c == null ? System.Now() : kanbanCard.leankor__StartDateTime__c);
				remoteKanban.KanbanUrl = 'https://' + DomainCreator.getOrgMyDomainHostname();
				remoteKanban.flowWithGS = true;  
				if (kanbanCard.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board') {
					remoteKanban.KanbanUrl += (new PageReference('/apex/leankor__KanbanBoard').getUrl()) + '?Id=' + valuestreamId + '&cardid=';
				} else if (kanbanCard.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View') {
					remoteKanban.KanbanUrl += (new PageReference('/apex/leankor__PortfolioView').getUrl()) + '?Id=' + valuestreamId + '&cardid=';
				} else {
					remoteKanban.KanbanUrl += (new PageReference('/apex/leankor__VisualKanban').getUrl())+'?Id=' + valuestreamId + '&cardid=';
				} 						
				remoteKanban.LeavedZoneID = (kanbanCard.leankor__ZoneGUID__c == null ? '' : kanbanCard.leankor__ZoneGUID__c );																																								   				   					  				  					    				    					    				    					    		
				remoteKanban.ZoneID = String.isBlank(kbrequest.leankor__ZoneGUID__c) ? zoneData.leankor__Guid__c:kbrequest.leankor__ZoneGUID__c;
				remoteKanban.MCForceID = String.isBlank(kbrequest.leankor__MasterContainer__c) ? zoneData.leankor__Swimlane__r.leankor__MasterContainer__c : kbrequest.leankor__MasterContainer__c;					
				remoteKanban.SWForceID = String.isBlank(kbrequest.leankor__Swimlane__c) ? zoneData.leankor__Swimlane__c : kbrequest.leankor__Swimlane__c;																		
				remoteKanban.ZoneforceID = String.isBlank(kbrequest.leankor__Zone__c) ? zoneData.id:kbrequest.leankor__Zone__c;					
				//remoteKanban.ZoneTitle = zone.Name;																	    												   				   															
				remoteKanban.State = (remoteKanban.ZoneID == null ? 'nozone' : 'inzone');
				remoteKanbancardList.add(remoteKanban);					    					
			}	
			updateMovedCards(remoteKanbancardList);	
			return remoteKanbancardList;
	}     

	/*
		Date :23/09/19
		To create zoneKanbanAction records.
		TO count kanbancard records on old zone and new Zone.
	*/
	public static String createZkaRecords(List<String> requestIds, Map<Id,leankor__Kanbancard__c> mapOfOldzone, Map<Id,leankor__Zone__c>mapOfNewzone, List<leankor__ZoneKanbanAction__c> enterZoneRecords){			
		ZoneBehavior checkZoneBehaviour = new ZoneBehavior();
		ZoneKanbanActionBehavior checkZoneKanbanActionBehavior = new ZoneKanbanActionBehavior();
		if (!checkZoneBehaviour.isUpdateable() ||
			!checkZoneKanbanActionBehavior.isCreateable()) {
			return '';
		}
		String returnString = 'success';       
		Double decHours = 0;
		Decimal diffMin = 0;
		Decimal totalTime = 0;
		Integer kanbanCount = 1;
		Integer KanbanCount1 = 1;

		//Calculate Wait time if zKanbanAction.action == 'Left Zone'
		Map<Id, Decimal> mapOfTotalTime = new Map<Id, Decimal>();		
		//create zka records.
		List<leankor__ZoneKanbanAction__c> zoneKanbanActionList = new List<leankor__ZoneKanbanAction__c>();
		List<String> zoneIds = new List<String>();
		Map<String,String> mapOfzones = new Map<String, String>(); 
		//calculate WaitTime  from  old zone ZoneKanbanAction and use If zKanbanAction.action is Left zone .
		if (enterZoneRecords.Size() > 0) {
			for (leankor__ZoneKanbanAction__c  enterZone : enterZoneRecords) {
				DateTime leftZoneTime = System.Now();
				kanbanCount = -1;
				if (leftZoneTime.isSameDay(enterZone.CreatedDate)) {
					// Checking Kanban Card enter and left the zone is same or not.
					decHours = (((leftZoneTime.getTime()) / 1000 / 60) - ((enterZone.CreatedDate.getTime()) / 1000 / 60)) / 60;
					diffMin = (((leftZoneTime.getTime()) / 1000 / 60) - ((enterZone.CreatedDate.getTime()) / 1000 / 60)) - (decHours * 60);
					totalTime = decHours + (diffMin / 100);
				} else {
					Integer diffInDays = enterZone.CreatedDate.date().daysBetween(leftZoneTime.date());
					datetime sameDayEndDate = enterZone.CreatedDate.addDays(diffInDays);
					decHours = (((leftZoneTime.getTime()) / 1000 / 60) - ((sameDayEndDate.getTime()) / 1000 / 60)) / 60;
					diffMin = (((leftZoneTime.getTime()) / 1000 / 60) - ((sameDayEndDate.getTime()) / 1000 / 60)) - (decHours * 60);
					decHours = (diffInDays * 8) + decHours;
					totalTime = decHours + (diffMin / 100);
				}
				mapOfTotalTime.put(enterZone.leankor__KanbanCard2__c,totalTime);           	
			}                              
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
					zoneKanbanAction.leankor__Swimlane__c = oldZoneData.leankor__Swimlane__c;  
					zoneKanbanAction.leankor__MasterContainer__c = oldZoneData.leankor__MasterContainer__c;             
					zoneKanbanAction.leankor__OtherZone__c = newZoneData.id;                   
					zoneKanbanAction.leankor__OtherSwimlane__c =  newZoneData.leankor__Swimlane__c;
					zoneKanbanAction.leankor__OtherMasterContainer__c =  newZoneData.leankor__Swimlane__r.leankor__MasterContainer__c;
					zoneKanbanAction.leankor__ValueStream__c = oldZoneData.leankor__ValueStream__c;
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
					zoneKanbanAction1.leankor__Swimlane__c =newZoneData.leankor__Swimlane__c;
					zoneKanbanAction1.leankor__MasterContainer__c =  newZoneData.leankor__Swimlane__r.leankor__MasterContainer__c;
					zoneKanbanAction1.leankor__OtherZone__c = oldZoneData.leankor__Zone__c;
					zoneKanbanAction1.leankor__OtherSwimlane__c =oldZoneData.leankor__Swimlane__c;
					zoneKanbanAction1.leankor__OtherMasterContainer__c = oldZoneData.leankor__MasterContainer__c;
					zoneKanbanAction1.leankor__ValueStream__c = oldZoneData.leankor__ValueStream__c;
					zoneKanbanAction1.leankor__SessionID__c = UserInfo.getSessionId();
					zoneKanbanAction1.leankor__ActionType2__c = 'Entered Zone';                                                            
					zoneKanbanAction1.leankor__WaitTime2__c = 0; 
					
					zoneKanbanActionList.add(zoneKanbanAction1); 
					//add zone ids into the List to   count kanbancard on zone.  
					zoneIds.add(zoneKanbanAction1.leankor__Zone2__c);  
			 	} 
			}                                                                         
         } 
		//create   List of  zoneKanbanAction records.     
		if (zoneKanbanActionList.size() > 0) {
			Insert zoneKanbanActionList; 
		}                                               		
		//To get map of zone based on New zone Id and Old Zone Id	       
        Map <Id, leankor__Zone__c> mapOfCurrentZone = new Map <Id, leankor__Zone__c>([Select Id, 			   																
																								leankor__KanbanCardCount2__c, 																			
																								Name																			
																							From leankor__Zone__c 
																							Where Id In :zoneIds 
																							With Security_Enforced
																							Limit 49999]);        									
		for (String zone:zoneIds) {										
			// KanbanCard Count is decrease if  zka action is Left zone.										
			if (mapOfzones.containsKey(zone)) {										
				mapOfCurrentZone.get(zone).leankor__KanbanCardCount2__c += KanbanCount;
			} else {					
				mapOfCurrentZone.get(zone).leankor__KanbanCardCount2__c += KanbanCount1;
			} 
		} 
		if (leankor__Zone__c.sObjectType.getDescribe().isUpdateable()) {
			DataBase.update(new List<leankor__Zone__c> (mapOfCurrentZone.values()));
		}      
		return returnString;
	}
	   
    //
    // This is Request method for Invocable Method which contain defination on IN variable for API calls
    //
    global class KanbanCardRequest{   
        @invocableVariable(label='Kanban Card Id' description='The ID of the Card.')
            global String Id;
        @invocableVariable(label = 'URL' description = 'The URL obtained by clicking on the Copy URL button.')
            global string CardURL;
        @invocableVariable(label = 'Master Container Name' description = 'The string name of the Master Container to where the Card is moved.')
            global String MCName;
        @invocableVariable(label = 'Swimlane Name' description = 'The string name of the Swimlane to where the Card is moved.')
            global String SwimlaneName;
        @invocableVariable(label = 'Column Name' description = 'The string name of the Column to where the Card is moved.')
            global String ColumnName;
        @invocableVariable(label = 'Sobject Kanbancard List' description = 'The List of kanbabancard to where List of card is moved.')
            global List<leankor__Kanbancard__c> KanbancardList =new List<leankor__Kanbancard__c>();    
		@InvocableVariable(label = 'Enable to generate Work Breakdown Structure' description = 'Generate Work Breakdown Structure for KanbanCard sObjects.')
			global Boolean generateWorkBreakdownStructure = false;
    }    
    //
    // This method is for Bulk records of cards API calls
    //
    /*Public static Void MoveKanbanCard(KanbanCardRequest request) { 
        leankor__Kanbancard__c KanbanCard = new leankor__Kanbancard__c();
        String tempKanbanId = request.Id;
        if(tempKanbanId == null || tempKanbanId == ''){
            tempKanbanId = request.CardURL.substringAfter('cardid=') ;
        }
        Try{
            KanbanCard =[SELECT Id,leankor__CardID__c,leankor__Point__c,leankor__AcceptanceCriteria__c,leankor__Account__c,leankor__UrlLink__c,leankor__ActualDuration__c,leankor__Actual_Time_Taken__c,leankor__Bottom__c,leankor__Budgeted_Time__c,leankor__BudgetTimeComplete__c,leankor__BudgetTimeRemaining__c,leankor__CardDetails__c,leankor__Case__c,leankor__CmpID__c,leankor__Color__c,leankor__CompletionVariance__c,leankor__Contact__c,leankor__CSSLayout__c,leankor__DateColor__c,leankor__DescriptionLong__c,leankor__Description__c,leankor__DueDateTime__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__EstimatedDuration__c,leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__IsCompletedOnTime__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__Left__c,leankor__OnBudget__c,leankor__OnQuality__c,leankor__OnTime__c,leankor__Opportunity__c,leankor__Order__c,leankor__PercentComplete2__c,leankor__Priority__c,leankor__PromiseCompletionDate__c,leankor__StartDateTime__c,leankor__StartDate__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__ZoneGUID__c,Name,OwnerId,LastModifiedDate,leankor__ValueStream__r.leankor__BoardType__C FROM leankor__KanbanCard__c Where Id =:tempKanbanId  limit 1]; 
        } catch (Exception e){
            System.debug('ERROR: DML Exception ' + e.getMessage());
        }
        leankor.RealTimeController.Kanban RemoteKanban = new leankor.RealTimeController.Kanban();
        RemoteKanban.Id = tempKanbanId;
        RemoteKanban.CardId = KanbanCard.leankor__CardID__c;
        RemoteKanban.ForceID = tempKanbanId;
        RemoteKanban.Point = KanbanCard.leankor__Point__c;
        RemoteKanban.UrlLink = KanbanCard.leankor__UrlLink__c;
        RemoteKanban.GUID = KanbanCard.leankor__GUID__C; 
        RemoteKanban.Title = (KanbanCard.leankor__Title__C == null ? '' : KanbanCard.leankor__Title__C); 
        RemoteKanban.Name =  KanbanCard.Name;
        RemoteKanban.Top = ( KanbanCard.leankor__Top__C == null ? 2100 : KanbanCard.leankor__Top__C);
        RemoteKanban.Bottom = (KanbanCard.leankor__Bottom__c == null ? 0 : KanbanCard.leankor__Bottom__c);
        RemoteKanban.Left = (KanbanCard.leankor__Left__C == null ? 2100 : KanbanCard.leankor__Left__C);
        RemoteKanban.Width = (KanbanCard.leankor__Width__C == null ? 170 : KanbanCard.leankor__Width__C);
        RemoteKanban.Height = (KanbanCard.leankor__Height__c == null ? 85 :KanbanCard.leankor__Height__C);
        RemoteKanban.X = (KanbanCard.leankor__X__C == null ? 0 : KanbanCard.leankor__X__C);
        RemoteKanban.Y = (KanbanCard.leankor__Y__C == null ? 0 : KanbanCard.leankor__Y__C);
        RemoteKanban.JSONDefinition = (KanbanCard.leankor__JSONDefinition__c == null ? '{}' : KanbanCard.leankor__JSONDefinition__c);
        RemoteKanban.JSONData =(KanbanCard.leankor__JSONData__c == null ? '{}' : KanbanCard.leankor__JSONData__c);
        RemoteKanban.TemplateID = KanbanCard.leankor__KanbanCardTemplate__C;
        RemoteKanban.Color = KanbanCard.leankor__Color__c; 
        RemoteKanban.AcceptanceCriteria = (KanbanCard.leankor__AcceptanceCriteria__c == null ? '': KanbanCard.leankor__AcceptanceCriteria__c);
        RemoteKanban.Description = (KanbanCard.leankor__DescriptionLong__C == null ? '': KanbanCard.leankor__DescriptionLong__C);
        RemoteKanban.DueDate = (KanbanCard.leankor__DueDateTime__c == null ? System.Now(): KanbanCard.leankor__DueDateTime__c);
        RemoteKanban.EstimatedDuration = ( KanbanCard.leankor__EstimatedDuration__C == null ? 1 :KanbanCard.leankor__EstimatedDuration__C );
        RemoteKanban.DurationUnits = (KanbanCard.leankor__DurationUnits__c == null ? 'Days': KanbanCard.leankor__DurationUnits__c );
        RemoteKanban.Priority = (KanbanCard.leankor__Priority__C == null ? 0 : Integer.ValueOf(KanbanCard.leankor__Priority__C));
        RemoteKanban.OwnerID = KanbanCard.OwnerID;
        RemoteKanban.HarveyBall = (KanbanCard.leankor__PercentComplete2__c == null ? '0' : String.ValueOf(KanbanCard.leankor__PercentComplete2__c));
        RemoteKanban.ValueStreamCardLink = (KanbanCard.leankor__ValueStreamCardLink__C == null ? '' : KanbanCard.leankor__ValueStreamCardLink__C);
        RemoteKanban.ValueStreamLinkID = (KanbanCard.leankor__ValueStreamLink__C == null ? '' : KanbanCard.leankor__ValueStreamLink__C );
        RemoteKanban.ValueStream = KanbanCard.leankor__ValueStream__C;
        RemoteKanban.Account = (KanbanCard.leankor__Account__C == null ?'' : KanbanCard.leankor__Account__C );
        RemoteKanban.Opportunity =(KanbanCard.leankor__Opportunity__C == null ?'' : KanbanCard.leankor__Opportunity__C );
        RemoteKanban.Contact = (KanbanCard.leankor__Contact__C == null ?'' : KanbanCard.leankor__Contact__C );
        RemoteKanban.CaseID = (KanbanCard.leankor__Case__C == null ?'' : KanbanCard.leankor__Case__C );
        RemoteKanban.Order = (KanbanCard.leankor__Order__C == null ?0 : KanbanCard.leankor__Order__C );
        RemoteKanban.OnBudget = (KanbanCard.leankor__OnBudget__C == null ?'Green' : KanbanCard.leankor__OnBudget__C );
        RemoteKanban.OnQuality = (KanbanCard.leankor__OnQuality__C == null ?'Green' : KanbanCard.leankor__OnQuality__C );
        RemoteKanban.OnTime =(KanbanCard.leankor__OnTime__C == null ?'Green' : KanbanCard.leankor__OnTime__C );
        RemoteKanban.StartDate = (KanbanCard.leankor__StartDateTime__C == null ? System.Now() : KanbanCard.leankor__StartDateTime__C );
        RemoteKanban.KanbanUrl = URL.getSalesforceBaseUrl().toExternalForm();
        RemoteKanban.flowWithGS = true;  //Rs 12/12/2017  for gs in flow
        if(KanbanCard.leankor__ValueStream__r.leankor__BoardType__c == 'Kanban Board'){
            RemoteKanban.KanbanUrl +=(new PageReference('/apex/leankor__KanbanBoard').getUrl())+'?Id='+KanbanCard.leankor__ValueStream__c+'&cardid=';
        } else if(KanbanCard.leankor__ValueStream__r.leankor__BoardType__c == 'Portfolio View'){
            RemoteKanban.KanbanUrl +=(new PageReference('/apex/leankor__PortfolioView').getUrl())+'?Id='+KanbanCard.leankor__ValueStream__c+'&cardid=';
        } else{
            RemoteKanban.KanbanUrl +=(new PageReference('/apex/leankor__VisualKanban').getUrl())+'?Id='+KanbanCard.leankor__ValueStream__c+'&cardid=';
        } 
        RemoteKanban.LeavedZoneID = (KanbanCard.leankor__ZoneGUID__C == null ? '' : KanbanCard.leankor__ZoneGUID__C );
        List<leankor__Zone__c> zones = new List<leankor__Zone__c>();
        try{
            if(request.MCName != null  && request.SwimlaneName != null && request.ColumnName != null){
                zones = [Select Id,Name,leankor__GUID__C,leankor__Swimlane__C,leankor__Swimlane__r.leankor__MasterContainer__C from leankor__Zone__C Where Name =:request.ColumnName AND  leankor__Swimlane__r.Name =:request.SwimlaneName AND leankor__ValueStream__C =:KanbanCard.leankor__ValueStream__C Limit 1];
                if(zones.Size() > 0){
                    RemoteKanban.ZoneID = zones[0].leankor__GUID__C;
                    RemoteKanban.MCForceID = zones[0].leankor__Swimlane__r.leankor__MasterContainer__C;
                    RemoteKanban.SWForceID = zones[0].leankor__Swimlane__c;
                    RemoteKanban.ZoneforceID = zones[0].ID;
                    RemoteKanban.ZoneTitle = zones[0].Name;
                }
            }else if((request.MCName != null  && request.SwimlaneName == null && request.ColumnName != null) || (request.MCName == null  && request.SwimlaneName == null && request.ColumnName != null)){
                zones = [Select Id,Name,leankor__GUID__C,leankor__Swimlane__C,leankor__Swimlane__r.leankor__MasterContainer__C from leankor__Zone__C Where Name =:request.ColumnName  AND leankor__ValueStream__C =:KanbanCard.leankor__ValueStream__C Limit 1];
                if(zones.Size() > 0){
                    RemoteKanban.ZoneID = zones[0].leankor__GUID__C;
                    RemoteKanban.MCForceID = zones[0].leankor__Swimlane__r.leankor__MasterContainer__C;
                    RemoteKanban.SWForceID = zones[0].leankor__Swimlane__c;
                    RemoteKanban.ZoneforceID = zones[0].ID;
                    RemoteKanban.ZoneTitle = zones[0].Name;
                }
            }else if(request.MCName != null  && request.SwimlaneName != null && request.ColumnName == null){
                List<leankor__Swimlane__C> swimlanes = [SELECT Id,leankor__MasterContainer__c,Name,(Select Id,Name,leankor__GUID__C,leankor__Swimlane__r.leankor__MasterContainer__C from leankor__Swimlane__C.leankor__Zones__r) FROM leankor__Swimlane__c Where Name =:request.SwimlaneName AND  leankor__MasterContainer__r.Name =:request.MCName AND leankor__ValueStream__C =:KanbanCard.leankor__ValueStream__C Limit 1];
                if(swimlanes.Size() > 0 ){
                    if(Swimlanes[0].leankor__Zones__r.Size() > 0){
                        RemoteKanban.ZoneID = Swimlanes[0].leankor__Zones__r[0].leankor__GUID__C;
                        RemoteKanban.MCForceID = Swimlanes[0].leankor__Zones__r[0].leankor__Swimlane__r.leankor__MasterContainer__C;
                        RemoteKanban.SWForceID = Swimlanes[0].leankor__Zones__r[0].leankor__Swimlane__c;
                        RemoteKanban.ZoneforceID = Swimlanes[0].leankor__Zones__r[0].ID;
                        RemoteKanban.ZoneTitle = request.SwimlaneName;
                    }
                }
            }else if(request.MCName != null  && request.SwimlaneName == null && request.ColumnName == null){
                List<leankor__Swimlane__C> swimlanes = [SELECT Id,leankor__MasterContainer__c,Name,(Select Id,Name,leankor__GUID__C,leankor__Swimlane__r.leankor__MasterContainer__C from leankor__Swimlane__C.leankor__Zones__r) FROM leankor__Swimlane__c Where leankor__MasterContainer__r.Name =:request.MCName AND leankor__ValueStream__C =:KanbanCard.leankor__ValueStream__C Limit 1];
                if(swimlanes.Size() > 0 ){
                    if(Swimlanes[0].leankor__Zones__r.Size() > 0){
                        RemoteKanban.ZoneID = Swimlanes[0].leankor__Zones__r[0].leankor__GUID__C;
                        RemoteKanban.MCForceID = Swimlanes[0].leankor__Zones__r[0].leankor__Swimlane__r.leankor__MasterContainer__C;
                        RemoteKanban.SWForceID = Swimlanes[0].leankor__Zones__r[0].leankor__Swimlane__c;
                        RemoteKanban.ZoneforceID = Swimlanes[0].leankor__Zones__r[0].ID;
                        RemoteKanban.ZoneTitle = request.MCName;
                    }
                }
            }else if(request.MCName != null  && request.SwimlaneName != null && request.ColumnName != null){
                if(KanbanCard.leankor__ValueStream__r.leankor__BoardType__C == 'Kanban Board'){
                    List<leankor__ValueStream__C> ProjectBoards  = [Select Id,Name,leankor__BoardType__C,(Select Id,Name,leankor__Type__C,leankor__Order__C,leankor__ValueStream__c from leankor__ValueStream__c.leankor__Master_Containers__r order by leankor__order__c),(Select Id,Name,leankor__Order__C,leankor__ValueStream__c,leankor__MasterContainer__C from leankor__ValueStream__c.leankor__Swimlanes__r ORDER BY leankor__Order__c ),(Select Id,Name,leankor__Order__C,leankor__ValueStream__c,leankor__Swimlane__C,leankor__GUID__C,leankor__Swimlane__r.leankor__MasterContainer__C from leankor__ValueStream__c.leankor__Zones__r ORDER BY leankor__Order__c ) from leankor__ValueStream__c Where Id =: KanbanCard.leankor__ValueStream__c Limit 1];
                    String Left_MC ='';
                    String left_SW ='';
                    Left_MC = ProjectBoards[0].leankor__Master_Containers__r[0].Id; // Getting left most MC Id
                    for(leankor__MasterContainer__C mc : ProjectBoards[0].leankor__Master_Containers__r){
                        if(mc.leankor__Type__C == 'Backlog'){
                            Left_MC = mc.Id; // Getting backlog type MC Id
                        } //End of If
                    }//End of Loop
                    for(leankor__Swimlane__C sw : ProjectBoards[0].leankor__Swimlanes__r) { 
                        if(Left_MC == sw.leankor__MasterContainer__c){
                            left_SW = sw.Id;
                            break;
                        }
                    }
                    for(leankor__Zone__C zone : ProjectBoards[0].leankor__Zones__r){
                        if(left_SW == zone.leankor__Swimlane__c){
                            RemoteKanban.ZoneID = zone.leankor__GUID__C;
                            RemoteKanban.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__C;
                            RemoteKanban.SWForceID = zone.leankor__Swimlane__c;
                            RemoteKanban.ZoneforceID = zone.ID;
                            RemoteKanban.ZoneTitle = zone.Name;
                            break;
                        }
                    }
                }else{
                    RemoteKanban.ZoneID = '';
                    RemoteKanban.MCForceID = '';
                    RemoteKanban.SWForceID = '';
                    RemoteKanban.ZoneforceID = '';
                    RemoteKanban.ZoneTitle = '';
                }
            }
            RemoteKanban.State = (RemoteKanban.ZoneID == null ? 'nozone' : 'inzone');
        } catch (Exception e){
            System.debug('ERROR: DML Exception ' + e.getMessage());
        }
        String someJSONData = JSON.Serialize(RemoteKanban);
        someJSONData = JSON.Serialize(RemoteKanban);
        system.debug(someJSONData.length()); 
        try{
            leankor.RealTimeController.KanbanStateChange(KanbanCard.leankor__ValueStream__C, 'MoveKanbanCard', UserInfo.getSessionId(), someJSONData);
        } catch (Exception e){
            System.debug('ERROR: while : Moving Card In project board' + e.getMessage());
            throw new MoveKanbancardAction.LeanException(e.getMessage());
        }
    }*/
}