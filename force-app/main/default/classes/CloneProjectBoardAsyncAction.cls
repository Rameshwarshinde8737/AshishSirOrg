/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  CloneProjectBoardAsyncAction.cls
* CLASS: CloneProjectBoardAsyncAction
* USAGE: manages for Cloning Project Board(ValueStream__c) in async mode.
*/
global with sharing class CloneProjectBoardAsyncAction implements Queueable {

    //Pratiksha : 22/09/2021 - Changes for Async Board clone.
    public static Boolean isClonedBoard = false;
    public static leankor__ValueStream__c newValueStream;
    public static leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
    private leankor.CloneProjectBoardAction.CloneProjectBoardRequest cloneProjectBoardRequest;
    public CloneProjectBoardAsyncAction(ApexPages.StandardController StdController){}
    public CloneProjectBoardAsyncAction(leankor.CloneProjectBoardAction.CloneProjectBoardRequest cloneProjectBoardRequest) {
        this.cloneProjectBoardRequest = cloneProjectBoardRequest;
    }
    

    @InvocableMethod
    global static List<CloneProjectBoardResult> CloneProjectBoard(List<CloneProjectBoardRequest> clonedata) {
        
        // Added Security code for sentize user Input(
        for(CloneProjectBoardRequest cloneRequests : clonedata){
            if((String.isNotBlank(cloneRequests.LinkedBoardId) && Util.getSObjectName(cloneRequests.LinkedBoardId) != 'leankor__ValueStream__c')
            || (String.isNotBlank(cloneRequests.LinkedCardId) && Util.getSObjectName(cloneRequests.LinkedCardId) != 'leankor__KanbanCard__c')
            || (String.isNotBlank(cloneRequests.ProjectRoomId) && Util.getSObjectName(cloneRequests.ProjectRoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(cloneRequests.TargetRoomId) && Util.getSObjectName(cloneRequests.TargetRoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(cloneRequests.ProjectBoardId) && Util.getSObjectName(cloneRequests.ProjectBoardId) != 'leankor__ValueStream__c')){
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        
        List<CloneProjectBoardResult>  results = new List<CloneProjectBoardResult>();

        for (CloneProjectBoardRequest remoteinput : clonedata) {
            cloneBoard(remoteinput);
        }

        return results;
    }
    
    
    //Assign values to CloneProjectBoardAction's request Instance from Async class 
    //We are using CloneProjectBoardAction's object in  our cloning
    //Need to assign all request values to that object
    public static void cloneBoard(CloneProjectBoardRequest requestData) {
    	leankor.CloneProjectBoardAction.CloneProjectBoardRequest request = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
        request.FolderName = requestData.FolderName;
        request.ProjectRoom = requestData.ProjectRoom;
        request.ProjectBoard = requestData.ProjectBoard;
        request.TargetFolderName = requestData.TargetFolderName;
        request.TargetRoom = requestData.TargetRoom;
        request.TargetBoard = requestData.TargetBoard;
        request.TargetDate = requestData.TargetDate;
        request.LinkFolderName = requestData.LinkFolderName;
        request.LinkRoomName = requestData.LinkRoomName;
        request.LinkBoardName = requestData.LinkBoardName;
        request.LinkKanbanCardName = requestData.LinkKanbanCardName;
        request.LinkedBoardId = requestData.LinkedBoardId;    	 
        request.LinkedCardId = requestData.LinkedCardId;
        request.initialDate = requestData.initialDate;
        request.cloneFiles = requestData.cloneFiles;
        request.cloneCustomFields = requestData.cloneCustomFields;
        request.projectBoardLaunchDate = requestData.projectBoardLaunchDate;
        request.ProjectRoomId = requestData.ProjectRoomId;
        request.TargetRoomId = requestData.TargetRoomId;
        request.ProjectBoardId = requestData.ProjectBoardId;
        request.projectEventCustomPayload = requestData.projectEventCustomPayload;
        request.checkCloneProject = 'StopOriginalkanbanCardUpdate';
        //asyncCloneBoard(JSON.Serialize(request));

        // 29/05/2021 - Changes : Changes for clone board from UI and also from API.
        request.kanbanVerb = requestData.isAsynchBoardCloneFromUI == true ? requestData.kanbanVerb == true ? true : false : true;
        request.stickerVerb = requestData.isAsynchBoardCloneFromUI == true ? requestData.stickerVerb == true ? true : false : true;
        request.markerVerb = requestData.isAsynchBoardCloneFromUI == true ? requestData.markerVerb == true ? true : false : true;
        request.taskVerb = requestData.isAsynchBoardCloneFromUI == true ? requestData.taskVerb == true ? true : false : true;
        request.chartVerb = requestData.isAsynchBoardCloneFromUI == true ? requestData.chartVerb == true ? true : false : true;
        request.kanbanTemplateVerb = requestData.kanbanTemplateVerb;
        request.zoneVerb = requestData.zoneVerb;
        request.isplancloned = requestData.isprojectclone;
        request.sessionID = requestData.sessionID;
        CloneProjectBoardAsyncAction cloneProjectBoardRequest = new CloneProjectBoardAsyncAction(request);
        System.enqueueJob(cloneProjectBoardRequest);
    }
    
	
	@Future
	public Static void asyncCloneBoard(String requestString) {
        KanbanCardBehaviour checkKanbanCardBehaviour = new KanbanCardBehaviour();
        if (!checkKanbanCardBehaviour.isAccessible() || 
            !checkKanbanCardBehaviour.isUpdateable()){
            throw new Util.LeanException('Error: No access to records');
        }
		CloneProjectBoardAction.CloneProjectBoardResult result = CloneProjectBoardAction.clonedBoard((CloneProjectBoardAction.CloneProjectBoardRequest)JSON.deserialize(requestString, CloneProjectBoardAction.CloneProjectBoardRequest.class));
        
        // update IsSuccessorRecalculate of parent KBC for auto-translation
        if (String.isNotBlank(result.ClonedID) && result.ClonedID InstanceOf Id) {
            List<leankor__KanbanCard__c> kanbanCards = 
                [Select Id, 
                        leankor__IsSuccessorRecalculate__c, 
                        leankor__ValueStreamCardLink__c
                    From leankor__KanbanCard__c
                    Where leankor__ValueStream__c = :result.ClonedID
                        And leankor__ValueStreamCardLink__c != null
                    With Security_Enforced];
            
            Set<Id> valueStreamCardLinks = new Set<Id>();
            for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                valueStreamCardLinks.add(kanbanCard.leankor__ValueStreamCardLink__c);
            }
            
            List<leankor__KanbanCard__c> updateKanbanCards = new List<leankor__KanbanCard__c>();
            for (Id valueStreamCardLink : valueStreamCardLinks) {
                updateKanbanCards.add(new leankor__KanbanCard__c(Id = valueStreamCardLink, leankor__IsSuccessorRecalculate__c = true));    
            }
                
            if (updateKanbanCards.size() > 0) {
                update updateKanbanCards;
            }
        }
    }

    
	public void execute(QueueableContext context) { 
        //Pratiksha : 06/07/2021 - Changes : Here we will create remaining record for clone board by using another process to decreate CPU time Limit.
        //CloneProjectAction.isClonedProject = true;
        //28/03/2021 : We have shifted the code for EndCloneBoard Project Event broadcast in anaother batch so that we have use isAsyncBoard variable.
        CloneProjectAction.isAsyncBoard = true;
        //Pratiksha : 22/09/2021 - Changes for getting data while cloning board.
        CloneProjectBoardAsyncAction.isClonedBoard = true;
        //25/03/2021 - Preparing Project Event data for EndCloneBoard that we publish in another batch.
        try{
            leankor.CloneProjectBoardAction.clonedBoard(this.cloneProjectBoardRequest);
            /*if(newValueStream != null ){
                createProjectEvent(newValueStream.leankor__ProjectRoom__c, JSON.serialize(new List<String>{newValueStream.Id}), this.cloneProjectBoardRequest.projectEventCustomPayload);
            }*/
        }catch(Exception e){
            createProjectEvent(newValueStream.leankor__ProjectRoom__c, e.getMessage(), this.cloneProjectBoardRequest.projectEventCustomPayload);
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }  
        try{ 
            //Pratiksha : 13/Sep/2023 : We have moved this ProjectEvent code in Another try/Catch block.
            if(newValueStream != null ){
                //Pratiksha ; 22/09/2021 - Changes for KanbanCard's sticker should not be cloned when board cloning.
                CloneProjectRemainingRecord cloneProjectrequest = new CloneProjectRemainingRecord(CloneProjectAction.newKanbanCardsStatic, CloneProjectAction.valueStreamIdStatic, CloneProjectAction.kanbanCardIdsForStickerStatic, CloneProjectAction.mapWithOldKanbanCardStatic, cloneProjectBoardRequest.stickerVerb, pe, null);
                Database.executeBatch(cloneProjectrequest);
                createProjectEvent(newValueStream.leankor__ProjectRoom__c, JSON.serialize(new List<String>{newValueStream.Id}), this.cloneProjectBoardRequest.projectEventCustomPayload);
                Database.SaveResult pe_result = EventBus.publish(pe);
                // quick error processing, no need to Rollback
                if (!pe_result.isSuccess()){
                    for(Database.Error err : pe_result.getErrors()) {
                        System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                    // continue on because a failed platform event is no big deal ; do NOT rollback
                }
            } 
        }catch(Exception ex){
            System.debug('ERROR :: '+ex.getMessage());
        }
    }

    //07/April/2023 : New method created for fire the project Event.
    public static void createProjectEvent(Id projectId, String jsonPayload, String projectEventCustomPayload){
        pe.leankor__EventCategory__c = 'Cloning';
        pe.leankor__EventName__c = 'EndCloneBoard';
        pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
        pe.leankor__ProjectID__c = projectId;//{Project Id, force.com ID, of the target board};
        pe.leankor__UserID__c = UserInfo.getUserId();
        pe.leankor__JSONPayload__c = jsonPayload;//{JSON List<string> of board ids}   ---> target ValueStream force.com Ids 
        pe.leankor__CustomPayload__c = projectEventCustomPayload;
    }


    Global Class CloneProjectBoardRequest {
    	@invocableVariable(label='Folder Name of SourceRoom' description='Name of the Folder where its Room would located.')
            Global String FolderName;
        @invocableVariable(label='Project Room' description='Name of the Project Room where Board is located.')
            Global String ProjectRoom;
        @invocableVariable(label='Project Board Name' description='Name of the Board to be cloned.')
            Global String ProjectBoard;
        @invocableVariable(label='Target Folder Name' description='Name of Folder of the Room in which to place the cloned Board.')
            Global String TargetFolderName;
        @invocableVariable(label='Project Room Target' description='Name of the Room in which to place the cloned Board. ')
            Global String TargetRoom;
        @invocableVariable(label='New Project Board Name' description='Name of the new Board.')
            Global String TargetBoard;
        @invocableVariable(label='Due Date' description='Provide the final Due Date for the Card farthest in the future.')
            Global DateTime TargetDate;
        @invocableVariable(label='Linked Folder Name' description='Name of the Linked Folder where Linked Room would located.')
            Global String LinkFolderName; 
        @invocableVariable(label='Link Room Name' description='Name of the Link Project Room where Linked Board is located.')
            Global String LinkRoomName;
        @invocableVariable(label='Link Board Name' description='Name of the Link Board to Linked with Cloned Cards.')
            Global String LinkBoardName;
        @invocableVariable(label='Link Kanban Card Name' description='Name of Link Kanban Card Which to linked with cloned Cards .')
            Global String LinkKanbanCardName;
        @invocableVariable(label='Link Board Id' description='ID of the Link Board to Linked with merge Cards.')
            Global String LinkedBoardId;        
        @invocableVariable(label='Linked Card ID' description='Name of Link Kanban Card Which to linked.')
            Global String LinkedCardId;
        @invocableVariable(label='Start Date' description='Provide the initial Start Date for the Card farthest in the future.')
            Global DateTime initialDate;
        @InvocableVariable(label='Files' description='Set to true if Files will be cloned.')     
			Global Boolean cloneFiles;
		@InvocableVariable(label='Custom Fields' description='Set to true if Custom Fields will be cloned.')     
			Global Boolean cloneCustomFields;    
        @InvocableVariable(label='Project Board Launch date time' description='The launch date of the cloned project board in date and time data type. Define this if “Project board start date time” and “Project board due date time” are not defined.')     
            Global DateTime projectBoardLaunchDate;
        @InvocableVariable(label='Project Room Id' description='Id of the Project Room where Board is located. If this is defined, there is no need to define “Project Room” or “Folder Name of source room”.')
        	Global String ProjectRoomId;
        @InvocableVariable(label='Project Room Id Target' description='Id of the Project Room in which to place the cloned Board. If this is defined, there is no need to define “Project Room Target” or “Target Folder Name”.')        	
        	Global String TargetRoomId;
        @InvocableVariable(label='Project Board Id' description='Id of the Board to be cloned. If this is defined, there is no need to define “Project Board Name” or “Folder Name of source room”.')        	        	
        	Global String ProjectBoardId;            
        @InvocableVariable(label='Project Event Custom Payload' description='Data to be delivered by the project event platform.')
            Global String projectEventCustomPayload;
        public String checkCloneProject;
		
		public String targetDateString;
        public String initialDateString;
        public String projectBoardLaunchDateString;
        public Boolean kanbanVerb;
        public Boolean stickerVerb;
        public Boolean markerVerb;        
        public Boolean taskVerb;
        public Boolean chartVerb;
        public Boolean kanbanTemplateVerb;
        public Boolean zoneVerb;
        public Boolean isprojectclone;
        public String sessionID;
        public Boolean isAsynchBoardCloneFromUI;
    }  



    global Class CloneProjectBoardResult{
        @invocableVariable(label='New Project Board ID' description='The unique ID of the Board which was cloned')
            Global String ClonedID;
    }
	
	/***
     * Company : Leankor
     * Description : This Method used clone boards in asynch mode.
     * Input :  List of cloneProjectBoardRequests "List<CloneProjectBoardRequest>" inner class Object.
     * Output : List of created/updated Filter record if form of list of CloneProjectBoardRequest "List<CloneProjectBoardRequest>" inner class Object.
    */
    //29/05/2021 - Changes : Changes for make asynchronous process while clone board from UI.
    @RemoteAction
    global static String asyncCloneProjectBoard( List<CloneProjectBoardRequest> cloneProjectBoardRequests ){

        // Added Security code for sentize user Input(
        for(CloneProjectBoardRequest cloneRequests : cloneProjectBoardRequests){
            if((String.isNotBlank(cloneRequests.LinkedBoardId) && Util.getSObjectName(cloneRequests.LinkedBoardId) != 'leankor__ValueStream__c')
            || (String.isNotBlank(cloneRequests.LinkedCardId) && Util.getSObjectName(cloneRequests.LinkedCardId) != 'leankor__KanbanCard__c')
            || (String.isNotBlank(cloneRequests.ProjectRoomId) && Util.getSObjectName(cloneRequests.ProjectRoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(cloneRequests.TargetRoomId) && Util.getSObjectName(cloneRequests.TargetRoomId) != 'leankor__ProjectRoom__c')
            || (String.isNotBlank(cloneRequests.ProjectBoardId) && Util.getSObjectName(cloneRequests.ProjectBoardId) != 'leankor__ValueStream__c')){
                throw new Util.LeanException('Error: Invalid input');
            }
        }
      
        for(CloneProjectBoardAsyncAction.CloneProjectBoardRequest cloneProjectBoardRequest : cloneProjectBoardRequests)
        {   
            if(String.isNotBlank(cloneProjectBoardRequest.targetDateString)){
                cloneProjectBoardRequest.TargetDate = (DateTime)JSON.deserialize(cloneProjectBoardRequest.targetDateString, Datetime.class);
            }
            if(String.isNotBlank(cloneProjectBoardRequest.initialDateString)){
                cloneProjectBoardRequest.initialDate = (DateTime)JSON.deserialize(cloneProjectBoardRequest.initialDateString, Datetime.class);
            }
            if(String.isNotBlank(cloneProjectBoardRequest.projectBoardLaunchDateString)){
                cloneProjectBoardRequest.projectBoardLaunchDate = (DateTime)JSON.deserialize(cloneProjectBoardRequest.projectBoardLaunchDateString, Datetime.class);
            }
			cloneProjectBoardRequest.isAsynchBoardCloneFromUI = true;
        }    
        List<CloneProjectBoardResult> cloneprojectBoardResult = CloneProjectBoardAsyncAction.CloneProjectBoard(cloneProjectBoardRequests);
        return 'Sucsess';
    }
}