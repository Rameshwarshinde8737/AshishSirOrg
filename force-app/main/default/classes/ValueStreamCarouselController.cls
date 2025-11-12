/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE: ValueStreamCarousel.cls
* CLASS: ValueStreamCarousel
* USAGE: Displays a pick list of Value Streams in a graphical manner
*/

global with sharing class ValueStreamCarouselController{

    global ValueStreamCarouselController(ApexPages.StandardController controller) {

    }


    global ValueStreamCarouselController() {

    }

    // rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
	public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c'};
	// rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
    
    // primary list of objects managed by this controller 
    public static  List<leankor__ValueStream__c> theValueStreams {get;set;}
    public  List<leankor__ProjectRoom__c> theProjectRooms {get;set;}
        
    public String selectedRoomId {get;set;}    
        
    // wrapper class to save the base64encoded form of the attachments for Visualforce
    global class WrapperAttachment {
        // getters and setters required for visibility into a visualforce page!
        global String AttID {get;set;}
        global String ContentType {get;set;}
        global String base64Body {get;set;}
        global String parentName {get;set;}
        global String valueStreamId {get;set;}
        global String boardType {get;set;}
        
        // constructor class for when you just need an empty container
        global WrapperAttachment (){
            ContentType = '';
            base64Body = '';
            parentName = '';
            boardType= '';
        }
        
        // constructor class for when you just need an empty container, but with the parent's name set
        global WrapperAttachment (String pName){
            ContentType = '';
            base64Body = '';
            boardType= '';
            parentName = pName;
        }
        
        // constructor class for when you have an attachment to transform and wrapp
        global WrapperAttachment (Attachment att, String pName){
            if (att != null){
                ContentType = att.ContentType;
                parentName = pName;
                boardType= '';
                base64Body = EncodingUtil.Base64Encode(att.body);
                AttID = att.Id;
            } else {
                ContentType = '';
                base64Body = '';
                parentName = '';
                boardType= '';
                AttID = '';
            }
        }
        global WrapperAttachment (Attachment att, String pName, String brdType){
            if (att != null){
                ContentType = att.ContentType;
                parentName = pName;
                boardType= brdType;
                base64Body = EncodingUtil.Base64Encode(att.body);
                AttID = att.Id;
            } else {
                ContentType = '';
                base64Body = '';
                parentName = '';
                boardType= '';
                AttID ='';
            }
        }
        
        global WrapperAttachment (String vsId,String pName){
            ContentType = '';
            base64Body = '';
            boardType= '';
            parentName = pName;
            valueStreamId =vsId;
        }
        
          
        global WrapperAttachment (String vsId,Attachment att, String pName){
            if (att != null){
                ContentType = att.ContentType;
                parentName = pName;
                base64Body = EncodingUtil.Base64Encode(att.body);
                valueStreamId =vsId;
                AttID = att.Id;
            } else {
                ContentType = '';
                base64Body = '';
                parentName = '';
                valueStreamId ='';
                AttID = '';
            }
        }    
    }
    
    // used in Visualforce pages to map a project room object to its attachments quickly
    // NOTE: this is not a class, it's a list variable with getters and setters
    public transient Map<ID, List<WrapperAttachment>> mapPRAttachments = new Map<ID, List<WrapperAttachment>>();
    
    public Map<ID, List<WrapperAttachment>> getmapPRAttachments() {
            if(mapPRAttachments == null){
                mapPRAttachments = new Map<ID, List<WrapperAttachment>>();   
            }
            return mapPRAttachments;
    }
    
   	public ValueStreamCarouselController(ApexPages.StandardSetController stdSetController) {
		AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
		if (!attachmentBehaviour.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		}
		List<Attachment> attList = null;
		List<WrapperAttachment> waList = null;
		Map<Id, List<Attachment>> attachmentMap = new Map<Id, List<Attachment>> ();
		
		// ask the parent for a reference to the list of valuestreams
		this.theProjectRooms = (List<leankor__ProjectRoom__c>)stdSetController.getRecords();
		
		if (this.theProjectRooms.size() == 0){
			this.selectedRoomId = '';
		} else {
			// when we first open up, just grab the first Id to allow ValueStreams to load
			this.selectedRoomId = this.theProjectRooms[0].Id;
		}
			
		for(Attachment att : [Select Name, 
										Body, 
										ContentType,
										ParentId 
									From Attachment 
									Where ParentId In: this.theProjectRooms 
										And Name LIKE '%preview%' 
										And Parent.Type In :SETSTICKERSOBJECTS_CONST 
									Limit 1]) {			
			List<Attachment> attachments = attachmentMap.ContainsKey(att.ParentId) ? attachmentMap.get(att.ParentId) : new List<Attachment>();
			attachments.add(att);
			attachmentMap.put(att.ParentId, attachments);
		}    
		// for each project room object, get the attachments and create base64 variants using wrapper class
		for (leankor__ProjectRoom__c pr : this.theProjectRooms){
			
			try {
				attList = attachmentMap.get(pr.Id);
			} catch (DmlException e) {
				throw new Util.LeanException('ERROR:' + e.getMessage());
			}
			
			// if no record return, the value remains null
			if (attList == null || (attList.size() == 0)) {
				waList = new List<WrapperAttachment>();
				waList.add(new WrapperAttachment(pr.Name));
				mapPRAttachments.put( pr.Id, waList);
			} else {
				// create a wrapper attachment list and stuff it with base64 encoded bodies
				// the for loop should only execute once in the early versions of this prototype
				waList = new List<WrapperAttachment>();
				for (Attachment att : attList){
					waList.add(new WrapperAttachment(att, pr.Name));
				}
				mapPRAttachments.put( pr.Id, waList);
				attList = null;
			}
		}
		
		// load initial set of value streams based on our first project room
		ValueStreamCarouselController.ValueStreamCarousel(this.selectedRoomId);
	}

	@RemoteAction
	global static Map<ID, List<WrapperAttachment>> ValueStreamCarousel(String roomId) {
		if (String.isNotBlank(roomId) && (Util.getSObjectName(roomId) != 'leankor__ProjectRoom__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
		if(!valueStreamBehavior.isAccessible()){
			throw new Util.LeanException('Error: No access to records');
		}
	 
		Map<Id, List<WrapperAttachment>> mapVSAttachments = new Map<Id, List<WrapperAttachment>>();
		List<Attachment> attList = new List<Attachment>();
		List<WrapperAttachment> waList = new List<WrapperAttachment>();
		List<Attachment> attachmentList=new List<Attachment>();
		
		
		// ask the parent for a reference to the list of valuestreams with its attachments
		ValueStreamCarouselController.theValueStreams = [Select 
																Id, 
																Name,
																leankor__BoardType__c,
																(Select 
																		Id, 
																		Name, 
																		contentType, 
																		ParentId 
																	From Attachments 
																	Where Name Like '%preview%' 
																		And Parent.Type In :SETSTICKERSOBJECTS_CONST 
																		Limit 1) 
															From leankor__ValueStream__c 
															Where leankor__ProjectRoom__c = :roomId 
															Order By SystemModstamp Desc 
															Limit 50000];
		
		for (leankor__ValueStream__c vs : ValueStreamCarouselController.theValueStreams){
			for(Attachment att : vs.Attachments){
				if(att.ParentId == vs.Id && att.Name.contains('preview')){
					waList = new List<WrapperAttachment>();
					att.body = Blob.valueof('');
					waList.add(new WrapperAttachment(att, vs.Name, (vs.leankor__BoardType__c!=null?vs.leankor__BoardType__c:'')));
					mapVSAttachments.put(vs.Id, waList);        
				}		
			}
		}
		return mapVSAttachments; 
	}
	    
	@RemoteAction
	global static leankor__ProjectRoom__c createProjectRoom(String PrjName){
		//Check CRUD / FLC behavior
		ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
		if (!projectRoomBehaviour.isCreateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior
	
	    leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name=PrjName );
	    try {
	        Insert project;
	    } catch (DmlException e){
	        throw new Util.LeanException('ERROR:' + e.getMessage());
	    }
	    return project;  
	}
	    
	@RemoteAction
	global static leankor__ValueStream__c createProjectBoard(String PrjName,String ProjectRoomId,String BoardType,String ProjectBoardId,String KanbanCardId){
		
		//Check CRUD / FLC behavior
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
		AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
		if (!valueStreamBehavior.isCreateable()	||
			!attachmentBehaviour.isCreateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior
		if (String.isNotBlank(ProjectRoomId) && (Util.getSObjectName(ProjectRoomId) != 'leankor__ProjectRoom__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
		if (String.isNotBlank(ProjectBoardId) && (Util.getSObjectName(ProjectBoardId) != 'leankor__ValueStream__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
		if (String.isNotBlank(KanbanCardId) && (Util.getSObjectName(KanbanCardId) != 'leankor__KanbanCard__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
	
		List<Attachment> attachments=new List<Attachment>();
		String suffix = '';
		leankor__ValueStream__c projectBoard = new leankor__ValueStream__c(
		Name = PrjName,
		leankor__ProjectRoom__c = (ProjectRoomId ==''?null:ProjectRoomId),
		leankor__BoardType__c = BoardType,
		leankor__ValueStreamLink__c = (ProjectBoardId == ''?null:ProjectBoardId),
		leankor__ValueStreamCardLink__c = (KanbanCardId ==''?null :KanbanCardId)
		);
		try {
		insert projectBoard;
		} catch (DmlException e){
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		//StaticResource defaultAtt=[select body,name,contentType from staticresource where name= 'nopreview' limit 1];
		StaticResource defaultAtt;
			// finding nopreview according the board type.
			if(projectBoard.leankor__BoardType__c == 'Portfolio View' || projectBoard.leankor__BoardType__c == 'Card Hierarchy'){
				defaultAtt = [Select Body,
										Name,
										ContentType 
									From Staticresource 
									Where Name = 'ganttpreview'
									Limit 1];
			}else if(projectBoard.leankor__BoardType__c == 'Kanban Board'){
				defaultAtt = [Select Body,
										Name,
										ContentType 
									From Staticresource 
									Where Name = 'kanbanpreview' 
									Limit 1];
			}else{
				defaultAtt = [Select Body,
										Name,
										ContentType 
									From Staticresource 
									Where Name= 'nopreview' 
									Limit 1];
			}
			if (defaultAtt.ContentType == 'image/jpeg' || defaultAtt.ContentType == 'image/jpg'){
				suffix = '.jpg';        
			}
			else if (defaultAtt.ContentType == 'image/gif') {
				suffix = '.gif';
			} else {
				suffix = '.png';
			}
			Attachment att=new Attachment();
				att.body=defaultAtt.body;
				att.name=defaultAtt.name+suffix;
				att.contentType=defaultAtt.contentType;
				att.ParentId=projectBoard.Id;
				attachments.add(att);
				
		try{
			insert attachments;
		}catch(DMLException ex){
			throw new Util.LeanException('ERROR:' + ex.getMessage());
		}
		
		// create default Kanban Board
		if(projectBoard.leankor__BoardType__c == 'Kanban Board'){
		leankor.KanbanController.CloneBoard cBoard =new leankor.KanbanController.CloneBoard();
			cBoard.VSID = projectBoard.Id;
			cBoard.RealVSID = '';
			cBoard.KanbanVerb = false;
			cBoard.KanbanTemplateVerb = false;
			cBoard.StickerVerb = false;
			cBoard.TaskVerb = false;        
			KanbanController.CloneSystemBoard(cBoard);
		}
		return projectBoard;  
	}

	
	@RemoteAction
	global static List<leankor__ProjectRoom__c> rebuildProjectRoom(){
		List<leankor__ProjectRoom__c> prrooms = new  List<leankor__ProjectRoom__c>();
		/*
		AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
		if (!attachmentBehaviour.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		}
	
		// rbo 08.19.17 get all Ids of stickers which will be used to filter attachment object
		List <leankor__ProjectRoom__c> stickerIDs = [Select Id 
														From leankor__ProjectRoom__c
														With Security_Enforced
														Order By SystemModstamp DESC 
														Limit 9999];
		// rbo 08.19.17
			
		Map<Id, Attachment> mapAttachments = new Map <Id, Attachment>();    										 
		try {
			// rbo 08.19.17 use stickerIds to filter attachment object, this should improve the performance of the query	
			//for (Attachment[] att : [SELECT Id, Body FROM Attachment WHERE Parent.Type IN :SETSTICKERSOBJECTS_CONST AND ParentId IN (Select Id from leankor__ProjectRoom__c) LIMIT 9999]) {		
			for (Attachment[] att : [Select Id, 
											Body 
										From Attachment 
										Where ParentId In :stickerIDs 
										Limit 9999]) {		
			// rbo 08.19.17	
				mapAttachments.putAll(att);
			} 
		} catch (Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		
		// YJ 08.08.17 
		// 1. Added Parent.Type to make the query to Attachment faster 
		// 2. Changed the LIMIT number to 9999
		// 3. Converted to SOQL for LOOPS
		List<leankor__ProjectRoom__c> prrooms = new  List<leankor__ProjectRoom__c>();        
		try
		{
			// rbo 08.19.17 use stickerIds to filter attachment object, this should improve the performance of the query
			//for (leankor__ProjectRoom__c[] pr : [Select Id,(Select Id,Name, ContentType from Attachments where Parent.Type IN :SETSTICKERSOBJECTS_CONST), Name from leankor__ProjectRoom__c  ORDER BY SystemModstamp DESC Limit 9999] ){
			for (leankor__ProjectRoom__c[] pr : [Select Id, 
														(Select Id, 
																Name, 
																ContentType 
															From Attachments 
															Where ParentID In :stickerIDs), 
														Name 
													From leankor__ProjectRoom__c 
													Where Id In :stickerIDs
													With Security_Enforced]) {
			// rbo 08.19.17    
				for (Integer iCount = 0; iCount < pr.size(); iCount++)
				{
					for (Attachment att : pr[iCount].Attachments){	               
							att.Description = EncodingUtil.Base64Encode(att.Body);	               
					}
				}
			}
		}catch (Exception e){
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}  
		*/     
		return prrooms;   	
	}

	@RemoteAction
	global static leankor__Preference__c getPreference(Preference userPref){
		//Check CRUD / FLC behavior
		PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
		if (!preferenceBehaviour.isCreateable() ||
			!preferenceBehaviour.isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior

		if (String.isNotBlank(userPref.valuestream) && (Util.getSObjectName(userPref.valuestream) != 'leankor__ValueStream__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
		List<leankor__Preference__c> Pref = [Select Id,
													Name,
													leankor__CardPastDueDate__c,
													leankor__DerivedFrom__c,
													leankor__FollowOnChatter__c,
													leankor__GUID__c,
													leankor__Moved__c,
													leankor__PercentDone__c, 
													leankor__SubscribeToCard__c, 
													leankor__TaskPastDueDate__c, 
													leankor__ValueStream__c,
													OwnerId 
												From leankor__Preference__c 
												Where leankor__ValueStream__c =: userPref.valuestream 
													And OwnerId =: UserInfo.getUserId() 
												With Security_Enforced
												Limit 1];
			leankor__Preference__c userPreference;
			
			if(Pref.size()==0){
				if(userPref.valuestream !=''){
					try{
						leankor__Preference__c globalPref = new leankor__Preference__c();
						for(leankor__Preference__c preference : [Select Id,
																		Name,
																		leankor__ValueStream__c 
																	From leankor__Preference__c 
																	Where OwnerId =: UserInfo.getUserId() 
																	With Security_Enforced
																	Limit 1]){
							if(preference.leankor__ValueStream__c == ''){
								globalPref = preference;
								break;
							}
						}
						userPref.derivedfrom = globalPref.Id;
					}catch(QueryException e){
						userPref.derivedfrom='';
						throw new Util.LeanException('ERROR:' + e.getMessage());
					}
				}
				userPreference=new leankor__Preference__c(
				Name = userPref.Name,
				leankor__GUID__c = userPref.guid,
				leankor__FollowOnChatter__c = userPref.followonchatter,
				leankor__SubscribeToCard__c = userPref.subscribetocard,
				leankor__CardPastDueDate__c = userPref.cardpastduedate,
				leankor__Moved__c = userPref.moved,
				leankor__PercentDone__c = userPref.percentdone,
				leankor__TaskPastDueDate__c = userPref.taskpastduedate,
				leankor__ValueStream__c = (userPref.valuestream==''? null : userPref.valuestream),
				leankor__DerivedFrom__c =  (userPref.derivedfrom ==''? null : userPref.derivedfrom)
				);
				Database.Upsertresult uResult;
				try {
					// GUID is the external unique key to match
					Schema.Sobjectfield externfield = leankor__Preference__c.Fields.leankor__GUID__c;
					uResult = Database.upsert(userPreference, externfield, true); 
				} catch (DmlException e) {
					throw new Util.LeanException('ERROR:' + e.getMessage());
				}
			}else{
				return Pref[0];
			}
		return userPreference;
	}

	global Class Preference
	{
			global String id;
			global String name;
			global String guid;
			global String currentUser;
			global String followonchatter;
			global String subscribetocard;
			global String valuestream;
			global Boolean ownereditcard;
			global Boolean ownermovecard;
			global String valuestreamowner;
			global List<String> Categories;
			global Boolean cardpastduedate;
			global Boolean taskpastduedate;
			global Boolean moved;
			global Boolean percentdone;
			global Integer flag;
			global String derivedfrom;
	}

	@RemoteAction
	global static leankor__Preference__c setUserPreferenceAndSecurity(Preference userPref) { 
		//Check CRUD / FLC behavior
		PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
		if (!preferenceBehaviour.isCreateable() ||
			!preferenceBehaviour.isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior
		leankor__Preference__c userPreference;
		
		userPreference=new leankor__Preference__c(
		Name = userPref.Name,
		leankor__GUID__c = userPref.guid,
		leankor__FollowOnChatter__c = userPref.followonchatter,
		leankor__SubscribeToCard__c = userPref.subscribetocard,
		leankor__CardPastDueDate__c = userPref.cardpastduedate,
		leankor__Moved__c = userPref.moved,
		leankor__PercentDone__c = userPref.percentdone,
		leankor__TaskPastDueDate__c = userPref.taskpastduedate
		);
		
		Database.Upsertresult uResult;
		try {
		// GUID is the external unique key to match
		Schema.Sobjectfield externfield = leankor__Preference__c.Fields.leankor__GUID__c;
		uResult = Database.upsert(userPreference, externfield, true); 
		
		} catch (DmlException e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return userPreference;
	}

	
	@RemoteAction
    global static List<WrapperAttachment> ValueStreamSenchaCarousel(String roomId){
		List<WrapperAttachment> waList = new List<WrapperAttachment>();
		/*
		if (String.isNotBlank(roomId) && (Util.getSObjectName(roomId) != 'leankor__ProjectRoom__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
		AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour();
		if (!attachmentBehaviour.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		}
       	List<Attachment> attList = null;
        List<WrapperAttachment> waList = new List<WrapperAttachment>();
        
        // rbo 08.07.17 
		// 1. Added Parent.Type to make the query to Attachment faster 
		// 2. Changed the LIMIT number to 9999

        // ask the parent for a reference to the list of valuestreams
        ValueStreamCarouselController.theValueStreams = [Select Id, 
																Name 
															From leankor__ValueStream__c 
															Where leankor__ProjectRoom__c = :roomId
															With Security_Enforced];
        
        // rbo 08.19.17 use stickerIds to filter attachment object, this should improve the performance of the query
        //attList = [Select Name, Body, ContentType,ParentId from Attachment where ParentId in ( SELECT Id FROM leankor__ValueStream__c WHERE leankor__ProjectRoom__c = :roomId) and Name LIKE '%preview%' AND Parent.Type IN :SETSTICKERSOBJECTS_CONST limit 9999];
        attList = [Select Name, 
							Body, 
							ContentType, 
							ParentId 
						From Attachment 
						Where ParentId In :ValueStreamCarouselController.theValueStreams And Name 
						Like '%preview%' 
						Limit 1000];
        // rbo 08.19.17
        
        // for each value stream object, get the attachments and create base64 variants using wrapper class
        for (leankor__ValueStream__c vs : ValueStreamCarouselController.theValueStreams){
            // if no record return, the name of the parent value stream is returned only
            if(attList== null || (attList.size() == 0)){
               	waList.add(new WrapperAttachment(vs.Id,vs.Name));
                continue;
            }else{     
                Integer i=0,j=0;
                boolean flag=false; 
                for (Attachment att : attList){ 
            		if(att.ParentId ==vs.Id){
						waList.add(new WrapperAttachment(vs.Id,att, vs.Name));
						flag =true;
						j=i;
						break;   
                	}else{
						if(i==attList.size()-1){
							waList.add(new WrapperAttachment(vs.Id,vs.Name));
						}
               		}
               		i++; 
            	}
				if(flag){
					attList.remove(j);
				}         
        	}
    	}
		*/
        return waList;
    } 
    
   
    public List<leankor__ValueStream__c> getValueStreams(){

        return leankor.KanbanController.getValueStreams() ;
    }
    
    @RemoteAction
    global Static List<leankor__KanbanCard__c> getKanbanCards(String vsId){
        
        return realtimeController.getKanbanCards(vsId);
    }

    public List<Schema.Picklistentry> getBoardTypes(){
     return leankor__ValueStream__c.fields.leankor__BoardType__c.getDescribe().getpicklistvalues();
    }
     
	
    @RemoteAction
    global static realTimeController.ProjectBoard getVSLinkedCard(String VSID) {
		realTimeController.ProjectBoard board = new realTimeController.ProjectBoard();
		/*
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
		if (!valueStreamBehavior.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		}
		if (String.isNotBlank(VSID) && (Util.getSObjectName(VSID) != 'leankor__ValueStream__c')) {
			throw new Util.LeanException('Error: Invalid input');
		}
		leankor__ValueStream__c VS = [Select Id,
											leankor__BoardType__c,
											leankor__CaseCardCategory__c,
											leankor__CaseRecordType__c,
											leankor__CaseSynchronization__c,
											leankor__CaseType__c,
											leankor__KanbanCardCount__c,
											leankor__KanbanCardThroughput__c,
											leankor__ProjectRoom__c,
											leankor__ValueStreamCardLink__c,
											leankor__ValueStreamLink__c,
											Name,
											OwnerId 
										From leankor__ValueStream__c 
										Where Id =: VSID 
										Limit 1 ];
	    realTimeController.ProjectBoard board = new realTimeController.ProjectBoard();
	    if(VS != null){
			board.Name =VS.Name;
			board.ValueStreamLinkID =VS.leankor__ValueStreamLink__c;
			board.ValueStreamCardLink = VS.leankor__ValueStreamCardLink__c;
	    }
		*/
	    return board;
    }


}