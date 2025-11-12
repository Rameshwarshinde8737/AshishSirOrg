/*---------------------------------------------------------------------------------------
* Copyright 2012-2016 Leankor All rights reserved
Author      :   
Company     :   Leankor
Description :   An API class for cloning remaining record project          
Test Class  :   CloneProjectRemainingRecordTest
---------------------------------------------------------------------------------------*/
global with sharing class CloneProjectRemainingRecord implements Database.Batchable<sObject>{
    
    private List<leankor__KanbanCard__c > newKanbanCards = new List <leankor__KanbanCard__c> (); 
    private String valueStreamId;
	private List <Id> kanbanCardIdsForSticker = new List <Id> ();
    private Map<String,String> mapWithOldKanbanCard = new Map<String,String>();
    private Boolean cardStickerVerb = false;
    private leankor__ProjectEvent__e projectEvent; 
    private CloneProjectAction.CloneProjectRequest request;
	
	// parameterized constructor
    //Pratiksha : 25/03/2021 - leankor__ProjectEvent__e parameter added in this constuctor.
	public CloneProjectRemainingRecord(List<leankor__KanbanCard__c > newKanbanCards, String valueStreamId, List<Id> kanbanCardIdsForSticker, Map<String, String> mapWithOldKanbanCard, Boolean cardStickerVerb, leankor__ProjectEvent__e projectEvent, CloneProjectAction.CloneProjectRequest request) {
        this.newKanbanCards = newKanbanCards;
        this.valueStreamId = valueStreamId;
        this.kanbanCardIdsForSticker = kanbanCardIdsForSticker;
        this.mapWithOldKanbanCard = mapWithOldKanbanCard;
        this.cardStickerVerb = cardStickerVerb;
        this.projectEvent = projectEvent;
        this.request = request;
    }
	
	// default constructor
    public CloneProjectRemainingRecord(){
        
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC){
        
		/*Here we will create remaining record for clone project by using another process to decreate CPU time Limit. */
        String query = '';
        query = 'SELECT ID FROM leankor__KanbanCard__c LIMIT 1';
        return Database.getQueryLocator(query);
    }
	
	global void execute(Database.BatchableContext BC, List<leankor__KanbanCard__c> scope){

        //Check CRUD / FLC behavior
        ProjectRoomBehaviour project =  new ProjectRoomBehaviour();
        if(!project.isAccessible() || !project.isDeletable()){
                System.abortJob(BC.getJobId());
        }

		//Changes For Sticker cloning
       	if(this.cardStickerVerb == true){
            CloneProjectRemainingRecord.cloneCardsSticker(kanbanCardIdsForSticker, mapWithOldKanbanCard);
        }
       
        /*Here we will create remaining record for clone project by using another process to decreate CPU time Limit. */
		createClonedRemainingRecords(newKanbanCards, valueStreamId);
        // 25/03/2021 - Publish the project event for AsyncBoard.
		//Ramanand : 11/Sep/2023 - Changes : Changing ProjectEvent structure now will publish EndClone ProjectEvent from isBroadcast method. 
        /*if(this.projectEvent != null){
            Database.SaveResult pe_result = EventBus.publish(this.projectEvent);
	
			// quick error processing, no need to Rollback
			if (!pe_result.isSuccess()){
			    for(Database.Error err : pe_result.getErrors()) {
			        System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
			    }
				// continue on because a failed platform event is no big deal ; do NOT rollback
			}         
        } */   
	}
	
	global void finish(Database.BatchableContext bc){
        
    }
	
	
	/*------------------------------------------------------------
    Company:        Leankor
    Description:    This method will create remaining record for cloning project. 
    Inputs:         List<leankor__KanbanCard__c > newKanbanCards, String valueStreamId.
    Returns:        None.
    ------------------------------------------------------------*/
	private void createClonedRemainingRecords(List<leankor__KanbanCard__c > newKanbanCards, String valueStreamId){
        //Check CRUD / FLC behavior		
        SubscriberBehavior subscriberBehavior = new SubscriberBehavior(); 
        EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();
        if (!subscriberBehavior.isAccessible() || 
            !subscriberBehavior.isUpdateable() || 
            !subscriberBehavior.isCreateable() ||
            !entitySubscriptionBehaviour.isAccessible() ||
            !entitySubscriptionBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<leankor.RealTimeController.ZoneKanbanAction> zoneKanbanList = new List<leankor.RealTimeController.ZoneKanbanAction>();
        List<leankor.RealTimeController.ChatterFeed> chatterFeeds = new List<leankor.RealTimeController.ChatterFeed>();
        if (newKanbanCards.size() > 0) {
            List < leankor__Preference__c > preferences = new List < leankor__Preference__c > ();
            //Checking VSID as another parameter. If availabel than assuming single card / cards are coming from same ValueStream / Project Board.
            if (valueStreamId != '') {
                preferences = [Select Id, 
                                    Name, 
                                    leankor__ValueStream__r.leankor__BoardType__c,
                                    leankor__CardPastDueDate__c, 
                                    leankor__DerivedFrom__c, 
                                    leankor__FollowOnChatter__c, 
                                    leankor__GUID__c, 
                                    leankor__Moved__c, 
                                    leankor__PercentDone__c, 
                                    leankor__SubscribeToCard__c, 
                                    leankor__TaskPastDueDate__c, 
                                    leankor__isTaskCompleted__c, 
                                    leankor__ValueStream__c, 
                                    OwnerId 
                                From leankor__Preference__c 
                                Where leankor__ValueStream__c = : valueStreamId 
                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE
                                    And OwnerId In (Select Id 
                                                        From User) 
                                With Security_Enforced
                                Limit 10000];
            } else {
                // Blanck Value Stream Id in case of trigger on Case.
                Set<String> valueStreamIds = new Set <String>();
                //In case of trigger need to find each Value Stream Id.
                for (leankor__KanbanCard__c kanban : newKanbanCards) {
                    valueStreamIds.add(kanban.leankor__ValueStream__c); 
                }
                preferences = [Select Id, 
                                    Name, 
                                    leankor__ValueStream__r.leankor__BoardType__c,
                                    leankor__CardPastDueDate__c, 
                                    leankor__DerivedFrom__c, 
                                    leankor__FollowOnChatter__c, 
                                    leankor__GUID__c, 
                                    leankor__Moved__c, 
                                    leankor__PercentDone__c, 
                                    leankor__SubscribeToCard__c, 
                                    leankor__TaskPastDueDate__c, 
                                    leankor__isTaskCompleted__c, 
                                    leankor__ValueStream__c, 
                                    OwnerID 
                                From leankor__Preference__c 
                                Where leankor__ValueStream__c In: valueStreamIds 
                                    And leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE
                                    And OwnerID In (Select Id 
                                                        From User)
                                With Security_Enforced
                                Limit 10000];
            }
            List<leankor__Subscriber__c> subscribers = new List<leankor__Subscriber__c>();
            List<EntitySubscription> entitySubscriptionList = new List<EntitySubscription>();
            List<sobject> ESsobjectList = new List<EntitySubscription>();
            if (preferences.size() > 0) {
                for (leankor__KanbanCard__c kanban: [Select Id,
                                                            leankor__ValueStream__r.Name,
                                                            RecordType.Name,
                                                            leankor__ProjectRoom__c, 
                                                            leankor__TemplateBoard__c,
                                                            leankor__MasterContainer__r.leankor__Type__c,
                                                            leankor__KanbanCardTemplate__c,
                                                            leankor__ValueStream__c, 
                                                            leankor__ValueStream__r.leankor__BoardType__c,
                                                            leankor__ValueStream__r.leankor__ProjectRoom__c, 
                                                            leankor__ZoneGUID__c, 
                                                            Name, 
                                                            OwnerId 
                                                        From leankor__KanbanCard__c 
                                                        Where Id In: newKanbanCards
                                                            And leankor__IsRecordDeleted__c = FALSE
                                                        With Security_Enforced]) {
                    // preparing data for bulk enter the zone method
                    if (Kanban.leankor__ZoneGUID__C != '' && Kanban.leankor__ZoneGUID__C != null) {
                        RealTimeController.ZoneKanbanAction zoneKanbanAction = new  RealTimeController.ZoneKanbanAction();
                        zoneKanbanAction.KanbanID = Kanban.Id;
                        zoneKanbanAction.ZoneID = Kanban.leankor__ZoneGUID__C;
                        zoneKanbanAction.SwimlaneID = '';
                        zoneKanbanAction.MasterContainerID = '';
                        zoneKanbanAction.VSID = Kanban.leankor__ValueStream__C;
                        zoneKanbanAction.Action = 'Entered Zone';
                        zoneKanbanAction.SessionID = UserInfo.getSessionId();
                        zoneKanbanList.add(zoneKanbanAction);
                    }
                    
                    for (leankor__Preference__c preference : preferences) {
                       
                        if (valueStreamId != '' || preference.leankor__ValueStream__c == Kanban.leankor__ValueStream__c) {
                        //this is for subcriber of card
                            if (preference.leankor__SubscribeToCard__c == 'all' || (preference.leankor__SubscribeToCard__c).contains(kanban.leankor__KanbanCardTemplate__c)) {
                                leankor__Subscriber__c Sub = new leankor__Subscriber__c(
                                    Name = Kanban.Name,
                                    leankor__KanbanCard__c = Kanban.Id,
                                    leankor__SubscriberID__c = preference.OwnerID,
                                    leankor__Moved__c = preference.leankor__Moved__c,
                                    leankor__PercentDone__c = preference.leankor__PercentDone__c,
                                    leankor__CardPastDueDate__c = preference.leankor__CardPastDueDate__c,
                                    leankor__TaskPastDueDate__c = preference.leankor__TaskPastDueDate__c,
                                    leankor__isTaskCompleted__c = (preference.leankor__isTaskCompleted__c ? preference.leankor__isTaskCompleted__c : false),
                                    leankor__Flag__c = 1,
                                    leankor__Preference__c = preference.Id,
                                    leankor__SubscriberKey__c = Kanban.Id + '-' + preference.OwnerID);
                                subscribers.add(Sub);
                            } //End of if
                           
                            //this is for My Preference of card                             
                            if (preference.leankor__FollowOnChatter__c == 'all' || (preference.leankor__FollowOnChatter__c).contains(Kanban.leankor__KanbanCardTemplate__c)) {
                                if (Network.getnetworkid() != null) {
                                    sobject ESsobject = New EntitySubscription();
                                    ESsobject.put('ParentID', Kanban.Id);
                                    ESsobject.put('NetworkID', Network.getnetworkid());
                                    ESsobject.put('SubscriberID', preference.OwnerID);
                                    ESsobjectList.add(ESsobject);
                                } else {
                                    EntitySubscription entitySubscription = new EntitySubscription(ParentID = Kanban.Id, SubscriberId = preference.OwnerID);
                                    entitySubscriptionList.add(entitySubscription);
                                }
                            } //End of If
                        }
                    }
                     //End of Preference Loop 
                } //End of Kanban Card Loop
                Database.Upsertresult[]sResult;
                try {
                    if (subscribers.size() > 0) {
                        Schema.Sobjectfield ExternField1 = leankor__Subscriber__c.Fields.leankor__SubscriberKey__c;
                        sResult = Database.upsert(subscribers, ExternField1, true);
                    }
                    if (entitySubscriptionList.size() > 0) {
                        ChatterAutoFollow.createAutoFollow(entitySubscriptionList);
                    }
                    if (ESsobjectList.size() > 0) {
                        insert ESsobjectList;
                    }
                } catch (Exception e) {
                    //25/04/2023 : We are Throwing Exception
                    throw new Util.LeanException('ERROR:' + e.getMessage());
                } //End of catch
            }//End of IF Prefences
                                }
        
        if(!zoneKanbanList.isEmpty()){
            RealTimeController.enterTheZoneBulkify(zoneKanbanList);
        }
                
        RealTimeController.createChatterFeed(chatterFeeds, 'CreateKanbanCard'); 
    }

    public static void cloneCardsSticker(List <Id> kanbanCardIdsForSticker, Map<String,String> mapWithOldKanbanCard){
        KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour();
        if (!kanbanCardStickerBehaviour.isAccessible() ||
            !kanbanCardStickerBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records'); 
        }
        
        List<leankor__KanbanCardSticker__c> listOfStickers = new List<leankor__KanbanCardSticker__c>();
        //Pratiksha - 22/09/2021 : Changes for Clone KanbanCard's Sticker Asynchrously....
        if(kanbanCardIdsForSticker.size() > 0 && mapWithOldKanbanCard.size() > 0 ){
                 
            for(leankor__KanbanCardSticker__c kanbanSticker : [Select Id, 
                                                                    leankor__Sticker__c ,
                                                                    leankor__Kanbancard__c
                                                                From leankor__KanbanCardSticker__c 
                                                                Where leankor__KanbanCard__c IN : kanbanCardIdsForSticker
                                                                With Security_Enforced
                                                                Limit 50000]){
                if(mapWithOldKanbanCard.keySet().contains(kanbanSticker.leankor__Kanbancard__c)){
                    leankor__KanbanCardSticker__c sticker = new leankor__KanbanCardSticker__c();
                    sticker.leankor__kanbanCard__c = mapWithOldKanbanCard.get(kanbanSticker.leankor__Kanbancard__c);
                    sticker.leankor__Sticker__c = kanbanSticker.leankor__Sticker__c;
                    listOfStickers.add(sticker);
                }
            } 
            if(listOfStickers.size()>0){
                try{
                    Database.insert(listOfStickers,true);
                }catch(Exception e){
                    //25/04/2023 : We are Throwing Exception
                    throw new Util.LeanException('ERROR:' + e.getMessage());
                }
                listOfStickers.clear();
            }
        }   
    }
}