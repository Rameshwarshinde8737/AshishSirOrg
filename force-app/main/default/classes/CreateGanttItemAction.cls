global with sharing class CreateGanttItemAction {
		
	public static Map<String, Boolean> kanbanCardManuallyScheduledMap = new Map<String, Boolean>();
	public static Boolean calledFromMPPImport = false;

	global CreateGanttItemAction(ApexPages.StandardController StdController){}
	global class GanttItems{               
           global String valueStreamId;                            
           global List<String> cardData;
           global List<String> dependencyData; 
    }
    
    
    public class GanttWrapper{
    	public Map<String, leankor__KanbanCard__c> targetKanbanCards;
	    public Set<String> parentIds;
	}
	

    /*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description:    Created Gantt Items
	Inputs: 		GanttItems request 
					(Create GanttItems in separated transcation
					Initially creating all activities/AG/Milestone 
					which are processed in chunk of 1000 records in a single transcation
					when all AC/AG/MS are inserted then creating dependency records in next transcation)
	Returns: 		String (Success / Fail)
	Date: 			14.2.20
	------------------------------------------------------------*/
    @RemoteAction
    global static String createGanttItemsByMpp(GanttItems request) {
		// Added Security code for sentize user Input
        if((String.isNotBlank(request.valueStreamId) && Util.getSObjectName(request.valueStreamId) != 'leankor__ValueStream__c')){
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
		//Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if(
			!kanbanCardBehaviour.isAccessible() ||
			!kanbanCardBehaviour.isCreateable()
		){
			System.debug('Error: No access to create records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior
		
    	//Create a savepoint
		Savepoint sp = Database.setSavepoint();
		try{
			//ganttItem needs to  be inserted
	    	if(request.cardData.size()>0){
	    		Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();
	    		Set<String> parentIds = new Set<String>();   	   	    		
				
				//Get RecordType info		
			    map<String,Id> recordTypeMap = new map<String,Id>();
		    	for(Schema.RecordTypeInfo rt : Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfos()){
		    		recordTypeMap.put(rt.getDeveloperName(),rt.getRecordTypeId());
		    	}
		    	
		    	//Prepare KanbanCard reocrd instance for insertion
		    	GanttWrapper ganttWrapper = prepareKanbanCardRecord(request.valueStreamId, request.cardData,recordTypeMap);
			    if(!ganttWrapper.targetKanbanCards.isEmpty()){
	    			insert ganttWrapper.targetKanbanCards.values();
	    		}
	    		
	    		//Update linking of the Items
	    		linkGanttItems(request.valueStreamId , ganttWrapper.targetKanbanCards, parentids);

				calledFromMPPImport = true;

	    		//creating schedule mode records for kanbancards		
	    		leankor.GanttTaskBoard.CreateScheduleMode(ganttWrapper.targetKanbanCards.values());
	    	
	    	} else if (request.dependencyData.size() > 0){
	    		//Create dependency records for the board.
				addDependenciesToItems(request.valueStreamId, request.dependencyData);
	    	} else {
	    		removeMPPMaping(request.valueStreamId);
	    	}
    	}
    	catch(Exception ex){
			//if any exception will occur then all transaction will be Rollback
			Database.rollback(sp);
			//25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());			
			//return 'fail';
		}			
		return 'Success';
    }
	
	
    //Prepare KanbanCard record for insertion
    private static GanttWrapper prepareKanbanCardRecord(String valueStreamId, List<String> jsonDataList, map<String,Id> recordTypeMap){
    	//Use Wrapper class to collect data
    	GanttWrapper ganttWrapper = new GanttWrapper();
    	ganttWrapper.targetKanbanCards = new Map<String, leankor__KanbanCard__c>();
    	ganttWrapper.parentIds = new Set<String>();
    	
    	for(String jsonData : jsonDataList){
 	  	   leankor.KanbanToGanttController.MasterContainer card = (leankor.KanbanToGanttController.MasterContainer)JSON.deserialize(jsonData,(leankor.KanbanToGanttController.MasterContainer.Class));               
           leankor__KanbanCard__c kc = new leankor__KanbanCard__c();               
           kc.Name = card.Name.length() > 80 ? card.Name.substring(0,79): card.Name;
           kc.leankor__GUID__c =  card.GUID;
		   kc.RecordTypeId = recordTypeMap.get(card.ItemType);			   
		   kc.OwnerID = card.OwnerID;
		   kc.leankor__CardID__c = card.CardID;		
		   kc.leankor__Title__c = card.Title;
		   kc.leankor__Point__c = card.Point;
		   kc.leankor__ValueStream__c = valueStreamId;
		   kc.leankor__KanbanCardTemplate__c = card.TemplateID;
		   kc.leankor__EstimatedDuration__c = card.EstimatedDuration;
		   kc.leankor__Color__c = card.Color;
		   kc.leankor__OnTime__c = card.OnTime;             
		   //06/Nov/2023 :Removing use of JSONdata and JsonDefinition field to fix heap size issue.        
		   //kc.leankor__JSONDefinition__c = card.JSONDefinition;
		   //kc.leankor__JSONData__c = card.JSONData;
		   kc.leankor__DurationUnits__c = card.DurationUnits;
		   kc.leankor__Priority__c = card.Priority;
		   kc.leankor__PercentComplete2__c = card.PercentDone;
		   kc.leankor__Order__c = card.Order;		   
		   kc.leankor__OnBudget__c = card.OnBudget ;
		   kc.leankor__OnQuality__c = card.OnQuality ;
		   kc.leankor__DueDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(card.DueDate), DateTime.class);			   
		   kc.leankor__DueDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(card.DueDate), DateTime.class));
		   kc.leankor__StartDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(card.StartDate), DateTime.class);
		   kc.leankor__StartDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(card.StartDate), DateTime.class));			   			   
		   
		   //mapping for linking and dependency records
		   kc.leankor__ZoneGUID__c = card.Id;
		   kc.leankor__Description__c = card.parentId;
		   
		   //If parent items are inserted in previous transaction and child are inserting in this transaction
		   //need to update linking for the child item
		   if(String.isNotBlank(kc.leankor__ZoneGUID__c) && !ganttWrapper.targetKanbanCards.containsKey(kc.leankor__ZoneGUID__c)){
		   	 ganttWrapper.parentIds.add(card.parentId);
		   }	

		   if(String.isNotBlank(kc.leankor__GUID__c)) {
				kanbanCardManuallyScheduledMap.put(kc.leankor__GUID__c, card.ManuallyScheduled);
		   }
		   
		   ganttWrapper.targetKanbanCards.put(kc.leankor__ZoneGUID__c, kc);	   		                                                                                                                                                                                                                                            			
    	}
    	return ganttWrapper;
	}
	

    //Update linking of the GanttItems
	@TestVisible
	private static void linkGanttItems(String vsID, Map<String, leankor__KanbanCard__c> targetKanbanCards, Set<String> parentids){
		//Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if(!kanbanCardBehaviour.isAccessible()){
			System.debug('Error: No access to records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior

    	Map<String,leankor__KanbanCard__c> parentMap = new Map<String,leankor__KanbanCard__c>();
    	//If the Parent item is created in previous transcation and child item in next transaction
    	//then need to update linking from the queries record 
    	for(leankor__KanbanCard__c kc : [SELECT Id, 
    										leankor__Description__c 
    									FROM leankor__KanbanCard__c 
    									WHERE Id in : parentids 
    										AND leankor__IsRecordDeleted__c = false]){
			parentMap.put(kc.leankor__Description__c, kc);
    	}
    	//update linking
    	linkGanttItems(vsID, targetKanbanCards, parentMap);
    }
	
	
    //mapping for parent-child relationship and create dependency  
	@TestVisible 
    private static List<leankor__KanbanCard__c> linkGanttItems(String vsID , Map<String, leankor__KanbanCard__c> targetKanbanCards, Map<String,leankor__KanbanCard__c> parentMap) {           		
		//Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if(
			!kanbanCardBehaviour.isAccessible() ||
			!kanbanCardBehaviour.isUpdateable()
		){
			System.debug('Error: No access to update records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior				

        List<leankor__KanbanCard__c> pgItems= new List<leankor__KanbanCard__c>(); 
        Map<String, String> dependencyMap = new Map<String, String>();                   
		for (leankor__KanbanCard__c newKanbanCard : targetKanbanCards.values()){
			//Excluding the root item remove MPP Maping field values from the Kanban Record 				
	    	if(newKanbanCard.leankor__Description__c != 'root' ){
	    		//If parent record is in same collection then get details from the same collection
	    		//Else get parent details from the queried Map collection
				if(targetKanbanCards.containsKey(newKanbanCard.leankor__Description__c)){
					newKanbanCard.leankor__ValueStreamCardLink__c = targetKanbanCards.get(newKanbanCard.leankor__Description__c).Id;
	    			newKanbanCard.leankor__ValueStreamLink__c = targetKanbanCards.get(newKanbanCard.leankor__Description__c).leankor__ValueStream__c;
				} else if(parentMap.containsKey(newKanbanCard.leankor__Description__c)){
					newKanbanCard.leankor__ValueStreamCardLink__c = parentMap.get(newKanbanCard.leankor__Description__c).Id;
	    			newKanbanCard.leankor__ValueStreamLink__c = parentMap.get(newKanbanCard.leankor__Description__c).leankor__ValueStream__c;	
				}
	    		pgItems.add(newKanbanCard);
	    	}			               			 				 						
 		} 		
		if (pgItems.size() > 0){
	 		update pgItems;
	 	}			 		
 		return pgItems;
	}


	@TestVisible
	//Create dependency for the GanttItems of the board
    private static void addDependenciesToItems(String vsID,List<String> dependencyData){
    	Map<String,leankor__KanbanCard__c> ganttItemMap = new Map<String,leankor__KanbanCard__c>();
    	//Query all KanbanCard records from the board
    	for(leankor__KanbanCard__c ganttItem : readGanttRecords(vsID)){
    		ganttItemMap.put(ganttItem.leankor__ZoneGUID__c, ganttItem);
    	}
    	//Create Dependency records
    	createDependencyRecords(vsID, ganttItemMap ,dependencyData);
	}
	
	@TestVisible
    private static List<leankor__KanbanCard__c> readGanttRecords(String vsID){
		//Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if(!kanbanCardBehaviour.isAccessible()){
			System.debug('Error: No access to records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior

		return [SELECT 
						Id, 
						leankor__ZoneGUID__c, 
						leankor__Description__c 
					FROM leankor__KanbanCard__c 
					WHERE leankor__ValueStream__c =: vsID 
						AND leankor__IsRecordDeleted__c= false 
					LIMIT 9999];
	}   
	
	@TestVisible
	//Create dependency records.
	private static void createDependencyRecords(String vsID ,Map<String, leankor__KanbanCard__c> targetKanbanCards, List<String> dependencyData){	
		//Check CRUD / FLC behavior
		DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
		if(
			!dependencyBehaviour.isAccessible() ||
			!dependencyBehaviour.isCreateable()
		){
			System.debug('Error: No access to create records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior

		List<leankor__Dependency__c> dependencyList = prepareDependencyRecords(vsID ,targetKanbanCards, dependencyData);   					
		if(!dependencyList.isEmpty()){
			insert dependencyList;
		}	
		/*//Remove MPP Maping from the KanbanCard record.
		removeMPPMaping(targetKanbanCards.values());*/	
		
	}   

	@TestVisible
	//Prepare dependency records for insertion.
	private static List<leankor__Dependency__c> prepareDependencyRecords(String vsID ,Map<String, leankor__KanbanCard__c> targetKanbanCards, List<String> dependencyData){
		List<leankor__Dependency__c> dependencyList = new List<leankor__Dependency__c>();
		for (String jsonData : dependencyData){			
			leankor.RealTimeController.Dependency dp = (leankor.RealTimeController.Dependency)JSON.deserialize(jsonData, leankor.RealTimeController.Dependency.class);			
			leankor__Dependency__c d = new leankor__Dependency__c();
			d.leankor__GUID__c = dp.Id;
            d.leankor__ValueStream__c = vsID;
			d.leankor__Predecessor__c = targetKanbanCards.get(dp.FromID).Id;
			d.leankor__Successor__c = targetKanbanCards.get(dp.To).Id;
			d.leankor__LagLead__c = dp.Lag;
			d.leankor__LagLeadUnit__c = dp.LagUnit;
		  //d.leankor__LagLeadDuration__c = dp.LagLeadDuration;
			d.leankor__SuccessorType__c = (dp.Type == 0 ? 'Start To Start' : (dp.Type == 1 ? 'Start To Finish' : (dp.Type == 2 ? 'Finish To Start' : 'Finish To Finish')));			
			dependencyList.add(d);
		}
		return dependencyList;
	}
	
	@TestVisible
	//Read all gantt Records and remove mapping
	//Remove MPP Maping
	private static void removeMPPMaping(String vsId){
		removeMPPMaping(readGanttRecords(vsID));
	}


	@TestVisible
	//Remove MPP Maping
	private static void removeMPPMaping(List<leankor__KanbanCard__c> ganttItems){
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if(
			!kanbanCardBehaviour.isAccessible() ||
			!kanbanCardBehaviour.isUpdateable() 
		){
			System.debug('Error: No access to update records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior
		
		for(leankor__KanbanCard__c ganttItem : ganttItems){
			if(ganttItem.leankor__Description__c != 'root'){
	    		ganttItem.leankor__ZoneGUID__c = null;
	    		ganttItem.leankor__Description__c = null;
	    		System.debug(ganttItem);
	    	}
		}
		update ganttItems;
	}                   
	

	/*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description:    Rollback all inserted data from Gantt
	Inputs: 		GanttItems request 
					(Using valueStreamId from the instance)
	Returns: 		String (Success / Fail)
	Date: 			14.2.20
	------------------------------------------------------------*/
    @RemoteAction
    global static String rollbackGanttData(GanttItems request){
		// Added Security code for sentize user Input
        if((String.isNotBlank(request.valueStreamId) && Util.getSObjectName(request.valueStreamId) != 'leankor__ValueStream__c')){
            System.debug('Error: Invalid input');
            throw new Util.LeanException('Error: Invalid input');
        }
		//Check CRUD / FLC behavior
		KanbanCardBehaviour kanbanCardBehaviour = new kanbanCardBehaviour();
		if(
			!kanbanCardBehaviour.isAccessible() ||
			!kanbanCardBehaviour.isDeletable()
		){
			System.debug('Error: No access to delete records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior

    	try {
    		//Delete are KanbanCard  record from the board.
    		delete  [SELECT Id FROM leankor__kanbanCard__c WHERE leankor__ValueStream__c =: request.valueStreamId LIMIT 9999 ];
    		
    		//Call future method for deletion of further dependency and schedule Mode record of the Gantt board.
    		deleteGanttSubItems(request.valueStreamId);
    	}catch(Exception ex){
    		//return 'fail';
			//25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + ex.getMessage());
    	}
		return 'success';
	}
	
    
    //**Note - To avoid governor limits deletion is separated.
    //Future method for deletion of Dependency and Schedule Mode record of the Gantt Board
    @TestVisible
	@Future
    private static void deleteGanttSubItems(String valueStreamId){
		ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
		DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
		if(
			!scheduleModeBehavior.isAccessible() ||
			!scheduleModeBehavior.isUpdateable() ||
			!dependencyBehaviour.isAccessible() ||
			!dependencyBehaviour.isUpdateable() 
		){
			System.debug('Error: No access to records');
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior

    	List<leankor__ScheduleMode__c> scheduleModes = new List<leankor__ScheduleMode__c>();
		for (leankor__ScheduleMode__c scheduleMode : [Select Id,
															leankor__KanbanCard__c,
															leankor__ScheduleConstraint__c
														From leankor__ScheduleMode__c
														Where leankor__kanbanCard__c In (Select Id From leankor__kanbanCard__c Where leankor__ValueStream__c =: valueStreamId) 
														Limit 10000]){
					
			scheduleMode.leankor__KanbanCard__c = null;
			scheduleMode.leankor__ScheduleConstraint__c = null;
			scheduleModes.add(scheduleMode);
	}
		update scheduleModes;
	
		List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();

		for (leankor__Dependency__c dependency : [Select Id,
														leankor__ValueStream__c,
														leankor__Successor__c,
														leankor__Predecessor__c
													From leankor__Dependency__c 
													Where leankor__ValueStream__c =: valueStreamId 
													Limit 10000]){

			dependency.leankor__ValueStream__c = null;
			dependency.leankor__Successor__c = null;
			dependency.leankor__Predecessor__c = null;
			dependencies.add(dependency);
		}

		update dependencies;
	}
	

    /*@RemoteAction
    global static String createGanttItemsByMpp(GanttItems request)
    {   	
    	List<leankor__KanbanCard__c> kanbanCardList = new List<leankor__KanbanCard__c>();   	   	    		
		//Create a savepoint
		Savepoint sp = Database.setSavepoint();	
		try{			
		    map<String,Id> recordTypeMap = new map<String,Id>();	
		    for(RecordType rt : [SELECT Id,DeveloperName From RecordType Where SobjectType = 'leankor__KanbanCard__c']){
		   		recordTypeMap.put(rt.DeveloperName,rt.Id);		     
		    }		    		    
			for(String jsonData : request.cardData){    			
 	  		   leankor.KanbanToGanttController.MasterContainer card = (leankor.KanbanToGanttController.MasterContainer)JSON.deserialize(jsonData,(leankor.KanbanToGanttController.MasterContainer.Class));               
               leankor__KanbanCard__c kc = new leankor__KanbanCard__c();               
               kc.Name = card.Name.length() > 80 ? card.Name.substring(0,79): card.Name;
               kc.leankor__GUID__c =  card.GUID;
			   kc.RecordTypeId = recordTypeMap.get(card.ItemType);			   
			   kc.OwnerID = card.OwnerID;
			   kc.leankor__CardID__c = card.CardID;		
			   kc.leankor__Title__c = card.Title;
			   kc.leankor__Point__c = card.Point;
			   kc.leankor__ValueStream__c = request.valueStreamId;
			   kc.leankor__KanbanCardTemplate__c = card.TemplateID;
			   kc.leankor__EstimatedDuration__c = card.EstimatedDuration;
			   kc.leankor__Color__c = card.Color;
			   kc.leankor__OnTime__c = card.OnTime;             
			   kc.leankor__JSONDefinition__c = card.JSONDefinition;
			   kc.leankor__JSONData__c = card.JSONData;
			   kc.leankor__DurationUnits__c = card.DurationUnits;
			   kc.leankor__Priority__c = card.Priority;
			   kc.leankor__PercentComplete2__c = card.PercentDone;
			   kc.leankor__Order__c = card.Order;		   
			   kc.leankor__OnBudget__c = card.OnBudget ;
			   kc.leankor__OnQuality__c = card.OnQuality ;
			   kc.leankor__DueDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(card.DueDate), DateTime.class);			   
			   kc.leankor__DueDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(card.DueDate), DateTime.class));
			   kc.leankor__StartDateTime__c = (DateTime)JSON.deserialize(JSON.serialize(card.StartDate), DateTime.class);
			   kc.leankor__StartDate__c = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(card.StartDate), DateTime.class));			   			   
			   //mapping for linking
			   kc.leankor__ZoneGUID__c = card.Id;
			   kc.leankor__Description__c = card.parentId;			   		                                                                                                                        
               kanbanCardList.add(kc);                                                                                                                    			
    		}   		
    		if(!kanbanCardList.isEmpty()){
    			insert kanbanCardList;
    		}   		
    		List<leankor__KanbanCard__c> newkanbanCardList = linkKanbanCards(request.valueStreamId , kanbanCardList , request.dependencyData);   		
    		//creating schedule mode records for kanbancards		
    		leankor.GanttTaskBoard.CreateScheduleMode(newkanbanCardList); 
    		
    		//leankor.realtimeController.KCupdatePVcard(JSON.serialize(newkanbanCardList));  
    				   		    		   		
		}catch(Exception ex){
			//if any exception will occur then all trancsection will be Rollback
			Database.rollback(sp);			
			return 'fail';
		}			
		return 'Success';
    }   
    //mapping for parent-child relationship and create dependency   
    private static List<leankor__KanbanCard__c> linkKanbanCards(String vsID , List<leankor__KanbanCard__c> newKanbanCards , List<String> dependencyData)
	{           							       			
        Map<String, leankor__KanbanCard__c> targetKanbanCards = new Map<String, leankor__KanbanCard__c>();
        Map<String, String> dependencyMap = new Map<String, String>();                   
		for (leankor__KanbanCard__c newKanbanCard: newKanbanCards){			
			targetKanbanCards.put(newKanbanCard.leankor__ZoneGUID__c, newKanbanCard);						
		}	
		// createing dependency records		
		createDependencyRecords(vsID , targetKanbanCards,dependencyData);           
		for (leankor__KanbanCard__c newKanbanCard : newKanbanCards){ 				
	    	if(newKanbanCard.leankor__Description__c != 'root')
	    	{
	    		newKanbanCard.leankor__ValueStreamCardLink__c = targetKanbanCards.get(newKanbanCard.leankor__Description__c).Id;
	    		newKanbanCard.leankor__ValueStreamLink__c = targetKanbanCards.get(newKanbanCard.leankor__Description__c).leankor__ValueStream__c;
	    		//newKanbanCard.leankor__ZoneGUID__c = null;
	    		//newKanbanCard.leankor__Description__c = null;
	    	}			               			 				 						
 		} 		
		if (newKanbanCards.size() > 0){
	 		update newKanbanCards;
	 	}			 		
 		return newKanbanCards.size() > 0 ? newKanbanCards : new List<leankor__KanbanCard__c>();
	}    
	//creating dependency records.
	private static void createDependencyRecords(String vsID ,Map<String, leankor__KanbanCard__c> targetKanbanCards, List<String> dependencyData){	
		List<leankor__Dependency__c> dependencyList = new List<leankor__Dependency__c>();
		for (String jsonData : dependencyData){			
			leankor.RealTimeController.Dependency dp = (leankor.RealTimeController.Dependency)JSON.deserialize(jsonData, leankor.RealTimeController.Dependency.class);			
			leankor__Dependency__c d = new leankor__Dependency__c();
			d.leankor__GUID__c = dp.Id;
            d.leankor__ValueStream__c = vsID;
			d.leankor__Predecessor__c = targetKanbanCards.get(dp.FromID).Id;
			d.leankor__Successor__c = targetKanbanCards.get(dp.To).Id;
			d.leankor__LagLead__c = dp.Lag;
			d.leankor__LagLeadUnit__c = dp.LagUnit;
			d.leankor__LagLeadDuration__c = dp.LagLeadDuration;
			d.leankor__SuccessorType__c = (dp.Type == 0 ? 'Start To Start' : (dp.Type == 1 ? 'Start To Finish' : (dp.Type == 2 ? 'Finish To Start' : 'Finish To Finish')));			
			DependencyList.add(d);
		}   					
		if(!DependencyList.isEmpty()){
			insert DependencyList;
		}		
	}*/				
}