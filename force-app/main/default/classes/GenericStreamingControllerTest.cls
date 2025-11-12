@isTest
private class GenericStreamingControllerTest implements HttpCalloutMock {
    
    @isTest 
    static void testCreateChannel() {
    	leankor__LeanConstants__c customsetting = 
            new leankor__LeanConstants__c(
                leankor__StreamingAPIVersion__c = 40.0
                );
        try{
            DataBase.insert(customsetting,false);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
        }
        GenericStreamingController gsController = new GenericStreamingController();
        String id = leankor.GenericStreamingController.getChannelId('/u/Leankor/Navigation/Project/LeankorNAV');

        System.assertNotEquals(null, id);
		
        List<StreamingChannel> channelList = [SELECT Id FROM StreamingChannel WHERE Name = '/u/Leankor/Navigation/Project/LeankorNAV'];
        System.assertEquals(1, channelList.size());

        String uri = leankor.GenericStreamingController.getPostURI('LeankorNAV');
        System.assertEquals('/services/data/'+leankor.GenericStreamingController.VERSION+'/sobjects/StreamingChannel/LeankorNAV' + '/push', uri);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new leankor.TestInvocableMethods());
        List<string> jsonList = new List<string>();        
        leankor.realTimeController.TaskData tempObject = new leankor.realTimeController.TaskData();
        tempObject.Priority='Normal';
        tempObject.Subject ='XYZ';
        tempObject.Status = 'Not Started';
        tempObject.verb= 'createTask';
        string jsonTask = JSON.serialize(tempObject);
        jsonList.add(jsonTask);
        system.assert(GenericStreamingController.broadcastNotification('createTask', jsonTask)!= Null);
        GenericStreamingController.broadcastNotificationAsync('createTask',jsonList);
        
        User u = TestDataFactory.createStandardUser('Leankor');
        list<leankor__Portfolio__c> folder = TestDataFactory.createFolder('Test Folder', 1);
        list<leankor__ProjectRoom__c> project = TestDataFactory.createProjects('Test Project', folder, 1);
        List<leankor__ValueStream__c> vStream = TestDataFactory.createValueStream(project, 'Kanban Board', u);
        leankor__KanbanCardTemplate__c template = TestDataFactory.createKanbanCardTemplate(vStream[0]); 
        List<leankor__KanbanCard__c> kclist = TestDataFactory.createKanbanCard(vStream[0],template,20,NULL,u);
        leankor.KanbanController.PopUp PU = new leankor.KanbanController.PopUp();
        PU.CardID = kclist[0].Id;
   		PU.YES= 'Save';
   		PU.NO = 'cancel';   		
   		PU.customMessage = 'Hello';
   		PU.verb = 'PopUp';   		
		string jsonPop = JSON.serialize(PU);
		jsonList.clear();
		jsonList.add(jsonPop);
		system.assert(GenericStreamingController.broadcastNotification('PopUp', jsonPop)!= Null);
        GenericStreamingController.broadcastNotificationAsync('PopUp',jsonList);
                
        string someJSONData = '{"ValueStreamOwnerName" : "'+UserInfo.getName()+'","ValueStreamID" :"'+ vStream[0].Id+'" ,"verb" : "UpdateRuntimeBoard"}';
        List<String> jsonArray = new List<String>();
        jsonArray.add(someJSONData);
        jsonList.clear();
		jsonList.add(someJSONData);
		system.assert(GenericStreamingController.broadcastNotification('UpdateRuntimeBoard', someJSONData)!= Null);
        GenericStreamingController.broadcastNotificationAsync('UpdateRuntimeBoard',jsonList);
        
        leankor.RealTimeController.Kanban RemoteKanban = new leankor.RealTimeController.Kanban();
        	RemoteKanban.Name = 'Activity' ;        	
        	RemoteKanban.ValueStream = vStream[0].Id;
       	 	RemoteKanban.GUID = String.valueOf(system.now().getTime());
        	RemoteKanban.CardID = '1';
        	RemoteKanban.Title = 'Activity ';
        	RemoteKanban.Priority = 2;        	
        	RemoteKanban.StartDate = System.today();
        	RemoteKanban.DueDate = System.today().addDays(1);
        	RemoteKanban.HarveyBall = '50';      	
        	
        	jsonList.clear();
        	string jsonKB = JSON.serialize(RemoteKanban);
			jsonList.add(jsonKB);
		system.assert(GenericStreamingController.broadcastNotification('CreateKanbanCard', jsonKB)!= Null);
		
		
	    GenericStreamingController.broadcastNotificationAsync('CreateKanbanCard',jsonList);
	        
	    GenericStreamingController.createRealtimeTracker(vStream[0].Id,'CreateKanbanCard',jsonList,userinfo.getuserid());   
        
        leankor.GenericStreamingController.ToastWrapper toastWrapper = new leankor.GenericStreamingController.ToastWrapper();
        List <String> vs = new List <String>();
        vs.add(vStream[0].Id);
        toastWrapper.ValueStreamID = vs;
        toastWrapper.verb = 'ShowToast';
        jsonList.clear();
        jsonList.add(Json.serialize(toastWrapper));
        GenericStreamingController.createRealtimeTracker(vStream[0].Id,'ShowToast',jsonList,userinfo.getuserid()); 
        
        string someJSONData1 = '{"Id" :"'+kclist[0].Id +'","verb" : "MoveKanbanCard"}';  
        leankor__RealtimeTracker__c aRealtimeTrackerNav = new leankor__RealtimeTracker__c();
        aRealtimeTrackerNav.leankor__ValueStream__c =  null;
        aRealtimeTrackerNav.leankor__SessionID__c = UserInfo.getSessionId();
        aRealtimeTrackerNav.leankor__KanbanVerb__c = 'MoveKanbanCard';
        aRealtimeTrackerNav.leankor__JSONDataSmall__c  = someJSONData1;	
        GenericStreamingController.createRTForSelectedData(someJSONData1,aRealtimeTrackerNav);   	
        
        Map<String,List<String>> broadcastContentMap = new Map<String,List<String>> ();
        broadcastContentMap.put(vStream[0].Id, jsonArray);
        leankor.GenericStreamingController.tempCreateRTForMultipleBoards('ShowToast',broadcastContentMap, userInfo.getSessionId() );
        Test.stopTest();
        	
    }
        	       	        
    public HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"status":"success"}');
		res.setStatusCode(200);
		return res; 
    }
    
    @isTest 
    static void createChannelTest(){
        String result = leankor.GenericStreamingController.createChannel();
        System.assert(String.isNotBlank(result));
        List<StreamingChannel> streamingChannels = [SELECT Id FROM StreamingChannel LIMIT 9999];
        System.assert(streamingChannels.size() > 0);
    }
    
    
}