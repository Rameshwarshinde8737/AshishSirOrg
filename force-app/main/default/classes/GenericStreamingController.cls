global with sharing class GenericStreamingController {

  	private Integer replayFrom {get; set;}
  	/*NW 14AUG17 : After complete implementation of generic streaming, can use custom setting version variable.
                Currently custom setting version is 32.0 and Generic Streaming version v39.0.*/  
  	/*Changes made on 5 Feb 2019*/
  	//private static String version = 'v39.0';
  	@TestVisible
	private static final String VERSION = 'v'+leankor__LeanConstants__c.getInstance().leankor__StreamingAPIVersion__c;
	//20/March/2024 : Currently we are deprecating Broadcasting channel, So broadcast should ot fire in PE, so we are setting true value.
	private static final Boolean IS_USING_PLATFORM_EVENT = true;
  	private static final String baseChannelName ='/u/Leankor/Navigation/Project/';
  	private static final String LEANKORNAV ='LeankorNAV';
  	public GenericStreamingController(Util controller){}
	global GenericStreamingController() {
    	this.replayFrom = -1;
   	}

	global GenericStreamingController(ApexPages.StandardSetController controller) {}
	global GenericStreamingController(ApexPages.StandardController StdController) {}


  	@RemoteAction
  	global static String broadcastNotification(String verb, String jsonData){
    	String channel = getStreamingChannel(verb);
    	String channelId = getChannelId(channel);
  		return channelId;
  	}
  
	global static String broadcastBulkNotification(String verb, List<String> jsonDataList){
		return '';
  	}
  
  	//@future(callout = true)
  	public Static void broadcastNotificationAsync(String verb,List<String> jsonDataList){
    	broadcastBulkNotificationForSingleChannel(verb, jsonDataList);
  	}
  
	/*** This will return the channel name for the defined verb ***/
  	global static String getStreamingChannel(String verb){
   		String channelName = baseChannelName+LEANKORNAV;
   		return  channelName;
	} 
 
 	/*** This will return the channel name for the defined verb ***/
  	global static String getStreamingChannel(String verb, Id ValueStreamID){
		String channelName = baseChannelName+LEANKORNAV;
		return  channelName;
  	} 

	@TestVisible
  	private static String getChannelId(String channel){
		//Seems like there is no way to get the list of channels per package. So better not to query all channels 
		//get the Channel id of a given channel. Will use this Id in POST URI
		//To enable dynamic streaming channels in your org, from Setup, enter User Interface in the Quick Find box, then select User Interface and enable Enable Dynamic Streaming Channel Creation
		String channelId = '';
		List<StreamingChannel> channelList = [Select Id 
												From StreamingChannel
												Where Name = :channel
												With Security_Enforced];

		//Recreate the channels if it is missing in the database
		if (channelList.isEmpty() || channelList == null) {
		channelId = createChannel(channel);
		} else {
		channelId = channelList[0].Id;
		}    
		return channelId;
  	}

  	@TestVisible
  	private static String createChannel(String channel){
	  	if ((!StreamingChannel.sObjectType.getDescribe().isAccessible() 
		||  !StreamingChannel.sObjectType.getDescribe().isCreateable()) 
		&& (Network.getnetworkid() == null)) {
			throw new Util.LeanException('Error: No access to records');
		}
	
		//If the channel is missing this will create the channel
		StreamingChannel sc = new StreamingChannel();
		sc.Name = channel;
		try {
			insert sc;
		} catch(Exception exp){
			throw new Util.LeanException('ERROR:' + exp.getMessage());
		}
		return sc.Id;
	}

	@TestVisible
  	private static void pushToChannel(String payload, String endPoint,String userSessionId){
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();
		req.setEndpoint(System.URL.getOrgDomainUrl().toExternalForm() + endPoint);
		req.setMethod('POST');
		req.setBody(payload);
		req.setCompressed(true); 
		req.setHeader('content-type', 'application/json');
		// Date: 03/12/2019 - IsScheduleRecalculate broadcast is not working when Project schedule blackout record created from starndard record page.
    	req.setHeader('Authorization', 'OAuth '+ UserInfo.getSessionId());
		try {
        	res = http.send(req);
		} catch(System.CalloutException exp) {
        	System.debug('CalloutException ' + exp);
		} catch(System.Exception exp) {
			System.debug(' Exception : '+exp.getMessage());
		}
  	}

	@future(callout = true)
   	public Static void pushToChannelAsync(String payload, String endPoint,String userSessionId){
    	pushToChannel(payload, endPoint,userSessionId);
   	}

   	//Ashutosh : 08/12/2021 : This method executes when broadcasting is calling from trigger 
	public Static void pushToChannelAsyncForTrigger(String payload, String endPoint,String userSessionId){
		pushToChannel(payload, endPoint,userSessionId);
	}
    
  	@TestVisible
  	private static String getPostURI(String channelId){
		//This will return the POST URI for a given channel
		String uri = '';
		uri = '/services/data/' + VERSION + '/sobjects/StreamingChannel/' + channelId + '/push';
		return uri;
	}

	public class ToastWrapper {  
		public List<String> ValueStreamID ;
		public String verb ;   
	}

	@TestVisible
  	//RS 30.06.2018 Changes this methods return type from Void to list<Database.SaveResult>
  	//public static void createRealtimeTracker(String VSID , String Verb, List<String> SomeJSONData, String SessionID){
	public static list<Database.SaveResult> createRealtimeTracker(String VSID , String Verb, List<String> SomeJSONData, String SessionID){
    	//insert a record into the leankor__RealtimeTracker__c object
		//RS 30.06.2018 For atomic transaction added this variable to get the save result
		list<Database.SaveResult> realTimeTrackerSaveResult; 
        List<leankor__RealtimeTracker__c> aRealtimeTrackerList = new List<leankor__RealtimeTracker__c>(); 
        //Instance to hold List of broadcast events
        List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>(); 
        //if(!String.isBlank(VSID)){
		// Ashutosh : 09/12/2021 : Fixes added for reducing SomeJson Data size.
		Set<String> broadcastVerbs = new Set<String> {
            'ManageDependency',
            'DeleteKanbanCard',
            'MoveKanbanCard',
            'CreateKanbanCard',
            'UpdateKanbanCard',
            'Hyper-leave',
            'Hyper-arrive',
            'ManageSticker'
        };
		if(broadcastVerbs.contains(Verb)){
			for (Integer i = 0; i < SomeJSONData.size(); i++) {
				SomeJSONData[i] = JSON.serialize(JSON.deserialize(SomeJSONData[i], RealTimeController.ManageStateChangePackage.Class));
			}
		}
        for(String str : SomeJSONData){
        	leankor__RealtimeTracker__c aRealtimeTracker = new leankor__RealtimeTracker__c();
            leankor.realTimeController.JSONGroup MyJSONGroup = new leankor.realTimeController.JSONGroup();
            aRealtimeTracker.leankor__ValueStream__c =  String.isBlank(VSID) ? null : VSID;
            aRealtimeTracker.leankor__SessionID__c = SessionID;
            aRealtimeTracker.leankor__KanbanVerb__c = Verb;// verb for MainNAV page = LeankorNAV, create new verb for project gantt
            if(IS_USING_PLATFORM_EVENT){
				//prepare content for Broadcast  and add to List of Events
				broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(verb, str, SessionID));
			}
            if (!leankor.realTimeController.putJSONGroup(str, MyJSONGroup)){
                // string was too large
                	//System.debug('ERROR: JSON String too large for broadcasting [' + Verb + '] for NAVpage ' );
                	//RS 23/10/2018 In case of large string only the required field will be broadcasted  
                	leankor__RealtimeTracker__c realTimeRecord = createRTForSelectedData(str,aRealtimeTracker);
	                if(realTimeRecord != null){
	                	aRealtimeTrackerList.add(realTimeRecord);            
	                }
            } else {
                aRealtimeTrackerList.add(assignJsonData(aRealtimeTracker, myJSONGroup));
            }
        }
           
        //RS 18/10/2018 For show toast broadcast
		//SS 22.10.2018 Show Notification broadcast on different boards 	
        if (verb == 'ShowToast' || verb == 'ShowNotification') {
        	for (String str : SomeJSONData) {
        		ToastWrapper toastWrapperInstance = (ToastWrapper)JSON.deserialize(str, ToastWrapper.class);
				if (IS_USING_PLATFORM_EVENT) {
					//prepare content for Broadcast  and add to List of Events
					broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(verb, str, SessionID));
				}
                
        		for (string vssId : toastWrapperInstance.ValueStreamID) {
        			leankor__RealtimeTracker__c aRealtimeTracker = new leankor__RealtimeTracker__c();
		            leankor.realTimeController.JSONGroup MyJSONGroup = new leankor.realTimeController.JSONGroup();
		            aRealtimeTracker.leankor__ValueStream__c =  vssId;
		            aRealtimeTracker.leankor__SessionID__c = SessionID;
		            aRealtimeTracker.leankor__KanbanVerb__c = verb;// verb for MainNAV page = LeankorNAV, create new verb for project gantt
		            
		            if (!leankor.realTimeController.putJSONGroup(str, MyJSONGroup)){
		                // string was too large
	                	System.debug('ERROR: JSON String too large for broadcasting [' + Verb + '] for NAVpage ' );
	            	} else {
						aRealtimeTrackerList.add(assignJsonData(aRealtimeTracker,myJSONGroup));
					}
				}
			}
        }
             
        try {
        	//RS 30.06.2018 For atomic transaction. 
            //insert aRealtimeTrackerList;
                       
            /*SS 14.05.2019*/
            //Changes for Security rule
            //Move CRUD operation to without sharing class
            //realTimeTrackerSaveResult = Database.insert(aRealtimeTrackerList,true);
            realTimeTrackerSaveResult = OpenTaskRestriction.insertRealTimeTrackers(aRealtimeTrackerList);     
			if (IS_USING_PLATFORM_EVENT && broadcastEvents.size() > 0) {  
				//Publish Broadcast Event notification
				LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);     
			}
        } catch (DmlException e){
        	realTimeTrackerSaveResult = null;
            System.debug('ERROR:' + e.getMessage() + ' while creating RealtimeTracker entry [' + Verb + '] for NAVPage ');
			//25/04/2023 : We are Throwing Exception
            //throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        return realTimeTrackerSaveResult; 
  	}

	@TestVisible
	private static String buildBulkPayload(List<GSPayload> payloadList) {
		//this build the REST JSON. Name of the JSON is pushEvents and has payload and userIds attributes
		String payload = '';
		payload = '{ "pushEvents": [ ';
		
		for (GSPayload gs :  payloadList) {
			String serializedJSON = (gs.serializedJSON).escapeEcmaScript();
			payload = payload + '{';
			payload = payload + ' "payload": " ' + serializedJSON + '",';
			payload = payload + '"userIds": []';
			payload = payload + '},';
		}
		payload = payload.removeEnd(',');
		payload = payload + '] }';
		return payload;
	}
  
  	private class GSPayload{
		private String serializedJSON;
		private List<Id> userIdList;
		
		private GSPayload(String serializedJSON, List<Id> userIdList) {
			this.serializedJSON = serializedJSON;
			this.userIdList = userIdList;
		}
  	}
  
  	//RS 23/10/2018 In case of large string only the required field will be broadcasted 
   	public class JSONWrapper {  
		public string Id;
		public String Name;
		public String GUID;
		public String verb;         
	}
  
   /*-----------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    To create RT record for necessary data in case of large JSON    
    Inputs:         string jsonData, leankor__RealtimeTracker__c realTime
    Returns:        leankor__RealtimeTracker__c
    -----------------------------------------------------------------*/
   public static leankor__RealtimeTracker__c createRTForSelectedData(string jsonData, leankor__RealtimeTracker__c realTime) {
		try {
			JSONWrapper deserializeKanbanCard = (JSONWrapper)JSON.deserialize(jsonData, JSONWrapper.class);  	
			realTime.leankor__JSONDataSmall__c = JSON.serialize(deserializeKanbanCard);
		} catch (DmlException e){        	
			realTime = null; 
		} 	
		return realTime; 
	} 
  
	/*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Send broadcast for bulk data in both GS and PT
    Inputs:         String Verb, Map<String,List<String>> broadcastContentMap, String SessionID
    Returns:        -
	Comments :		Still needs to refactor code
    ------------------------------------------------------------*/
  	public static void sendBroadcastForBulkRecords(String Verb, Map<String,List<String>> broadcastContentMap, String SessionID) {
		RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();
		if (!realtimeTrackerBehavior.isCreateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
	
		//insert a record into the leankor__RealtimeTracker__c object
		List<leankor__RealtimeTracker__c> aRealtimeTrackerList = new List<leankor__RealtimeTracker__c>();
		List<String> gsJsonList = new List<String>();
    	//Instance to hold List of broadcast events
		List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
    
		//20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
		Boolean isGS = false;
		//20/March/2024 : Currently we are deprecating Broadcasting channel, So broadcast should ot fire in PE, so we are setting true value.
		Boolean isPE = true;
		if (broadcastContentMap.size()>0) {   
			for (String boardId : broadcastContentMap.keyset()) {
				List<List<String>> listOfList = new List<List<String>>();
				List<String> strData= 	broadcastContentMap.get(boardId);
				List<String> longData = new List<String>();
				List < String > longData1;
				for (String strList : strData) {
					if (longData.size()<60) {
						longData.add(strList);
					} else {
						longData1 = new List <String>();
						longData1.addAll(longData);
						listOfList.add(longData1);
						longData.clear();
					}
				}
				listOfList.add(longData);
				for (List<String> jsonIdList : listOfList) {
					leankor.realtimeController.bulkStreaming streamData = new leankor.realtimeController.bulkStreaming();
					streamData.cardIds = jsonIdList;
					streamData.verb = Verb;
					streamData.sessionID = SessionID;
					String jsonData = json.serialize(streamData);
					if (isPE) {
                		broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(verb, jsonData, SessionID));
                	} else if(isGS) {
						gsJsonList.add(jsonData);
					} else {	
						//GenericStreamingController.broadcastNotificationAsync(verb, new List<String>{jsonData});
						leankor__RealtimeTracker__c aRealtimeTracker = new leankor__RealtimeTracker__c();
						leankor.realTimeController.JSONGroup MyJSONGroup = new leankor.realTimeController.JSONGroup();
						if (String.isNotBlank(boardId)) {
							aRealtimeTracker.leankor__ValueStream__c =  boardId;
						}
						
						aRealtimeTracker.leankor__SessionID__c = SessionID;
						aRealtimeTracker.leankor__KanbanVerb__c = Verb;// verb for MainNAV page = LeankorNAV, create new verb for project gantt
						if (!leankor.realTimeController.putJSONGroup(jsonData, MyJSONGroup)) {
							// string was too large
							System.debug('ERROR: JSON String too large for broadcasting [' + Verb + '] for NAVpage ' );
						} else {
							aRealtimeTrackerList.add(assignJsonData(aRealtimeTracker, myJSONGroup));
						}
					}
				}
			}
		}
		try {
			//RS 30.06.2018 For atomic transaction. 
			//Send broadcast for the available content
			if (isPE && broadcastEvents.size()>0) {
				LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);
			} else if(gsJsonList.size()>0){
				GenericStreamingController.broadcastNotificationAsync(verb, gsJsonList);
			} else {
				Database.insert(aRealtimeTrackerList,true);
			}     
		} catch (DmlException e){
			System.debug('ERROR:' + e.getMessage() + ' while creating RealtimeTracker entry [' + Verb + '] for NAVPage ');
		}
  	}	
  
  	public static list<Database.SaveResult> tempCreateRTForMultipleBoards(String Verb, Map<String,List<String>> broadcastContentMap, String SessionID){
		RealtimeTrackerBehavior checkRealtimeTrackerBehavior = new RealtimeTrackerBehavior();
		if (!checkRealtimeTrackerBehavior.isCreateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		list<Database.SaveResult> realTimeTrackerSaveResult;
		List<leankor__RealtimeTracker__c> aRealtimeTrackerList = new List<leankor__RealtimeTracker__c>();
        List<leankor__BroadcastEvent__e> broadcastEvents = new List<leankor__BroadcastEvent__e>();
        Set<String> boardIdSet = new Set<String>();
		if (broadcastContentMap.size()>0) {   
			for (String boardId : broadcastContentMap.keyset()) {
				List<List<String>> listOfList = new List<List<String>>();
				List<String> strData= 	broadcastContentMap.get(boardId);
				List<String> longData = new List<String>();
				List < String > longData1;
				for (String strList : strData) {
					if (longData.size()<60) {
						longData.add(strList);
					} else {
						longData1 = new List < String > ();
						longData1.addAll(longData);
						listOfList.add(longData1);
						longData.clear();
					}
				}
				listOfList.add(longData);
				for (List<String> jsonIdList : listOfList) {
					leankor.realtimeController.bulkStreaming streamData = new leankor.realtimeController.bulkStreaming();
					streamData.cardIds = jsonIdList;
					streamData.verb = Verb;
					streamData.sessionID = SessionID;
					String jsonData = json.serialize(streamData);
					if (IS_USING_PLATFORM_EVENT) {
						broadcastEvents.add(LeankorPlatformEvents.prepareBroadcastEvent(Verb, jsonData, SessionID));
					}
					leankor__RealtimeTracker__c aRealtimeTracker = new leankor__RealtimeTracker__c();
					leankor.realTimeController.JSONGroup MyJSONGroup = new leankor.realTimeController.JSONGroup();
					aRealtimeTracker.leankor__ValueStream__c =  boardId;
					aRealtimeTracker.leankor__SessionID__c = SessionID;
					aRealtimeTracker.leankor__KanbanVerb__c = Verb;// verb for MainNAV page = LeankorNAV, create new verb for project gantt
					if (!leankor.realTimeController.putJSONGroup(jsonData, MyJSONGroup)){
						// string was too large
						System.debug('ERROR: JSON String too large for broadcasting [' + Verb + '] for NAVpage ' );
					} else {
						aRealtimeTrackerList.add(assignJsonData(aRealtimeTracker, myJSONGroup));
					}
				}
			}
		}
        realTimeTrackerSaveResult = Database.insert(aRealtimeTrackerList,true);     
		if (IS_USING_PLATFORM_EVENT && broadcastEvents.size() > 0) {    
			LeankorPlatformEvents.publishBroadcastEvent(broadcastEvents);  
		}         
        return realTimeTrackerSaveResult; 
  	}
  
  	/*-------------------------------------------------------------------------
		Company: 		Leankor
		Description: 	Use for Single channel Broadcast
		Inputs: 		verb, List <String> channelIdList
		Returns: 		String
	--------------------------------------------------------------------------------*/
	public static String broadcastBulkNotificationForSingleChannel(String verb, List<String> jsonDataList){
	  	String channelId;
		String uri  ;
		string vs; 
		List<GSPayload> gsJSONList = new List<GSPayload>();
		try {
			for(String jsonData : jsonDataList) {
				if (verb == 'createTask') {
					realTimeController.TaskData TD = (realTimeController.TaskData)JSON.deserialize(jsonData, realTimeController.TaskData.class);
				 	vs = TD.ValueStream;
				} else if(verb == 'PopUp') {
					KanbanController.PopUp PU = (KanbanController.PopUp)JSON.deserialize(jsonData, KanbanController.PopUp.class);
				 	vs = PU.ValueStream;
				} else if (verb == 'UpdateRuntimeBoard') {
					KanbanController.PopUp PU = (KanbanController.PopUp)JSON.deserialize(jsonData, KanbanController.PopUp.class);	
					vs = PU.ValueStreamID;      			
				} else {
				    realTimeController.CardStreamingPackage CSP = (realTimeController.CardStreamingPackage)JSON.deserialize(jsonData, realTimeController.CardStreamingPackage.class);
				   	vs = CSP.ValueStream; 	
				}
			    gsJSONList.add(new GSPayload(jsonData, null)); 
			}
			    
			channelId = getChannelIdForSingleChannel();
			uri = getPostURI(channelId);
			string payload = buildBulkPayload(gsJSONList);
			//Ashutosh : 08/12/2021 : Preventing future method calling from trigger
			if (ProjectScheduleBlackoutTriggerHandler.isCalledFromTrigger == true) {
				pushToChannelAsyncForTrigger(payload, uri,UserInfo.getSessionId());
			} else {
				pushToChannelAsync(payload, uri,UserInfo.getSessionId());
			}
		} catch(Exception e) {
		  	System.debug('ERROR:' + e.getMessage());
		}
		return 'Broadcast is Successfully complated';
	}
  
	/*-------------------------------------------------------------------------
		Company: 		Leankor
		Description: 	Use for Single channel Broadcast
		Inputs: 		verb, List <String> channelIdList
		Returns: 		String
	--------------------------------------------------------------------------------*/
	private static String getChannelIdForSingleChannel(){
	   	String channelId = '';
		try {
			List<StreamingChannel> channelList = [Select Id 
													From StreamingChannel
													Where Name = :(baseChannelName+'LeankorNAV')
													With Security_Enforced 
													Limit 1];
		
			if (channelList.isEmpty()) {
				channelId = createChannel();
			} else {
				channelId = channelList[0].Id;
			}    
		}catch(Exception e){
			System.debug('ERROR:' + e.getMessage());
		}
		return channelId;
	}
	  
	/*-------------------------------------------------------------------------
		Company: 		Leankor
		Description: 	Use to create Streaming Channel		
		Returns: 		String
	--------------------------------------------------------------------------------*/
	@TestVisible
	private static String createChannel(){
		if (!StreamingChannel.sObjectType.getDescribe().isCreateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		StreamingChannel sc = new StreamingChannel();
	    sc.Name = (baseChannelName +'LeankorNAV');
		try {
			insert sc;
		} catch(Exception exp){
		  throw new Util.LeanException('ERROR:' + exp.getMessage());
		}
		return sc.Id;
	}

	public static leankor__RealtimeTracker__c assignJsonData(leankor__RealtimeTracker__c realData, leankor.realTimeController.JSONGroup json) {
		realData.leankor__JSONDataSmall__c = json.JSON1;
		realData.leankor__JSONDataSmall2__c = json.JSON2;
		realData.leankor__JSONDataSmall3__c = json.JSON3;
		realData.leankor__JSONDataSmall4__c = json.JSON4;
		realData.leankor__JSONDataSmall5__c = json.JSON5;
		realData.leankor__JSONDataSmall6__c = json.JSON6;
		realData.leankor__JSONDataSmall7__c = json.JSON7;
		realData.leankor__JSONDataSmall8__c = json.JSON8;
		return realData;
	}
}