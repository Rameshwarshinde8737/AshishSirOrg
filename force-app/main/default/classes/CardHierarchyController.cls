/**
 Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 FILE: CardHierarchyController.cls
 CLASS: CardHierarchyController
*/
Global with sharing class CardHierarchyController {
    
    Global CardHierarchyController(ApexPages.StandardController controller) {       
    }
    private static List<String> resoruceList;
    // This Is Inner Class For MacsterContainer and with its child
    Global Class TempMasterContainer
    {
        Global Integer ChildCount;
    Global String Id;
    Global String Name;
    Global String ParentID;
    Global TempMasterContainer(){
    
    }
    Global TempMasterContainer(String Id,String Name,String ParentID, Integer ChildCount){
        this.Id = Id;
        this.Name = Name;
        this.ChildCount = ChildCount;
        this.ParentID = ParentID;
    }
}
    // This Inner Method Is Use Resource Records and Gantt Old records On Load.
    Global class CardHierarchyResourceScheduler
    {
        Global Set<leankor.kanbanToGanttController.CardResource> CardResources;
        Global  List<leankor.realTimeController.ProjectBoard> CardHierarchyView;
        Global List<leankor.kanbanToGanttController.MasterContainer> CardHierarchyTaskView;
        Global list<leankor.GanttTaskBoard.ResourceAssignment> ResourceAssignmentData;
        /*SS 21.08.2018*/
        //Added variables for preventing additional loops on UI side
        //relatedVSIds will have all related VsIds(linked card's vsId etc.)
        //successorRecalculateCardIds will have cardIds (which have isSuccessorRecalculate= true)
        public Set<String> relatedVSIds;
        public Set<String> successorRecalculateCardIds;
        public Boolean hasEditAccess;
        //Date :27/11/19
        public Map<String, List<ProjectScheduleBlackout__c>> projectScheduleBlackouts;
        Global CardHierarchyResourceScheduler(Set<leankor.kanbanToGanttController.CardResource> CardResources,List<leankor.realTimeController.ProjectBoard> CardHierarchyView){
            this.CardResources = CardResources;
            this.CardHierarchyView = CardHierarchyView;   
        }
        Global CardHierarchyResourceScheduler(Set<leankor.kanbanToGanttController.CardResource> CardResources,List<leankor.realTimeController.ProjectBoard> CardHierarchyView,List<leankor.kanbanToGanttController.MasterContainer> CalenderTaskView){
            this.CardResources = CardResources;
            this.CardHierarchyView = CardHierarchyView;
            this.CardHierarchyTaskView = CalenderTaskView;   
        }
    }

    /*
       "getResources" Is Remote Action Method which is usse for Geting records of Board With Other Card and task
       INPUT :- VSID=ValueStream, KanbanID=CardID, remoteVerb = Board Name 
       OUTPUT :- ProjectBoard Records.
    */
    @RemoteAction
    Global static CardHierarchyResourceScheduler getResources(String VSID,String KanbanID,String remoteVerb){
        
        //Abhishek : 11/10/2022 : Added Security code for sentize user Input
        if ((String.isNotBlank(KanbanID) && Util.getSObjectName(KanbanID) != 'leankor__KanbanCard__c') 
        || (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c')) {
            throw new Util.LeanException('Error: Invalid input');
        }

         //Date: 03/05/2019
         // Getting data without sharing
         return leankor.RealTimeControllerHelper.getResources_Helper(VSID, KanbanID, remoteVerb);
    }
    
    //
    // This Method Is Use Resource(RS) Records On Load.
    // INPUT: List of OwnerID for Getting all KanbanCards and All Task
    // OUTPUT: List Of all KanbanCard and task Shorted by OwnerIDs.
    // 
    
    //***** SS 20.06.2018 *****//
    public static List<String> UserStandard;
    public static List<String> UserNonStandard;
    public static boolean IscurrentUserPartner = false;
    public static Date beginDate;
    public static Date endDate;
    public static leankor.KanbanToGanttController.MasterContainer filterData;
    public static List<leankor__KanbanCard__c> AddCardNSU;
    
    @RemoteAction
    Global Static leankor.KanbanToGanttController.ResourceScheduler getKanbanCardsByResourceOnCH(list<String> ResourceIDs,List<String> ValueStreamID,String KanbanID, String VSID,String CHVerb){

        //Abhishek : 11/10/2022 : Added Security code for sentize user Input
        for(String resourceRecord : ResourceIDs){
            if (String.isNotBlank(resourceRecord) && Util.getSObjectName(resourceRecord) != 'User'){
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        for(String valueStreamRecord : ValueStreamID){
            if (String.isNotBlank(valueStreamRecord) && Util.getSObjectName(valueStreamRecord) != 'leankor__ValueStream__c'){
               throw new Util.LeanException('Error: Invalid input');
            }
        }
        if(String.isNotBlank(kanbanID) && Util.getSObjectName(kanbanID) != 'leankor__KanbanCard__c'){
            throw new Util.LeanException('Error: Invalid input');
        }

        UserBehaviour userBehaviour = new UserBehaviour();
        if (!userBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        
        filterData = (leankor.KanbanToGanttController.MasterContainer)JSON.deserialize(VSID,leankor.KanbanToGanttController.MasterContainer.class);     
        beginDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.StartDate), DateTime.class));
        endDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.DueDate), DateTime.class));
        
        List<User> PartnerUser =[SELECT Id, Usertype FROM User WHERE ID IN :ResourceIDs];
        List<User> AdminUser =[SELECT Id, Usertype FROM User WHERE ID IN :ResourceIDs];
        UserStandard = new List<String> ();
        UserNonStandard = new List<String> ();
        IscurrentUserPartner = false;
        if(Userinfo.getUserType()!='Standard'){
            IscurrentUserPartner = true;
            for(User PUser : PartnerUser){
                if(PUser.Usertype != 'Standard') UserNonStandard.add(PUser.ID);
            }
            for(User Usercheck :AdminUser){
                if(Usercheck.Usertype == 'Standard') UserStandard.add(Usercheck.ID);
            }
        }
        if(IscurrentUserPartner){
            ResourceIDs.clear();
            IF(UserNonStandard.size() > 0){
                ResourceIDs.addall(UserNonStandard);
            }
        }
        ValueStreamID = ValueStreamID;
        List<leankor.KanbanToGanttController.MasterContainer> ReturnList = New List<leankor.KanbanToGanttController.MasterContainer>();
        List<leankor.KanbanToGanttController.MasterContainer> returnedCards = getAssociatedCardsOfResources(ResourceIds,ValueStreamID,KanbanID,CHVerb);
        if(returnedCards != null)
        {
            ReturnList.addAll(returnedCards);
        }
        
        List<leankor.KanbanToGanttController.MasterContainer> taskLogList=  new List<leankor.KanbanToGanttController.MasterContainer>();
        List<leankor.KanbanToGanttController.MasterContainer> returnedTasks = getAssociatedTaskOfResources(ResourceIds, AddCardNSU, ValueStreamID);
        if(returnedTasks != null)
        {
        taskLogList.addAll(returnedTasks);
        }
        
        if(IscurrentUserPartner){
            ResourceIDs.addall(UserStandard);
        }
        
        Set<leankor.KanbanToGanttController.CardResource> cardResources = new Set<leankor.KanbanToGanttController.CardResource>();
        if(filterData.lastCardId =='' || filterData.lastTaskId == '')
        {
            List<User> UserList = [Select Id,Name,SmallPhotoURL from User Where Id IN :ResourceIDs limit 49999];
            for(User u : UserList){
                leankor.KanbanToGanttController.CardResource tempResource = new leankor.KanbanToGanttController.CardResource(u.Id,u.Name,u.SmallPhotoURL);
                cardResources.add(tempResource);
            }
        }
        
        return (new leankor.KanbanToGanttController.ResourceScheduler(ReturnList,taskLogList,cardResources));
    }

    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    List Of all KanbanCard Filtered by ResourceIds
    Inputs:         List of Resource Ids
    Returns:        List<MasterContainer>
    ------------------------------------------------------------*/
    @TestVisible
    private static List<leankor.KanbanToGanttController.MasterContainer> getAssociatedCardsOfResources(List<String> ResourceIds, List<String> ValueStreamID,String KanbanID,String CHVerb){
        if(filterData.lastCardId==null) {
            return new List<leankor.KanbanToGanttController.MasterContainer>();
        }
        String lastCardId=filterData.lastCardId;
        AddCardNSU = new List<leankor__KanbanCard__c>();
        List<leankor__KanbanCard__c> CardsList = new List<leankor__KanbanCard__c>();
        
        List<leankor.KanbanToGanttController.MasterContainer> ReturnList = New List<leankor.KanbanToGanttController.MasterContainer>();
        Map<String,String> MapOfVS = New Map<String,String>();    
        Map<String,String> MapOfKanbanName = New Map<String,String>();
        Set<String> AllRelatedCards = new Set<String>();
        Set<String> tempVSIDs = new Set<String>();
        List<leankor__Dependency__c> dependencies = new List<leankor__Dependency__c>();
        if(String.isBlank(lastCardId))
        {
            CardsList = new List<leankor__KanbanCard__c>();
            for (leankor__KanbanCard__c card : [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c,
                                                        leankor__valueStream__r.leankor__BoardType__c,
                                                        leankor__StartDateTime__c,
                                                        leankor__DueDateTime__c,
                                                        OwnerID,
                                                        leankor__EstimatedDuration__c,
                                                        leankor__DurationUnits__c,
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                        leankor__valuestream__r.leankor__Istemplateboard__c
                                                    From leankor__KanbanCard__c 
                                                    Where  RecordType.Name = 'ActivityCard'
                                                        And OwnerID IN :ResourceIDs 
                                                        And ((leankor__StartDate__c >= :beginDate And leankor__StartDate__c <=:endDate) 
                                                        Or (leankor__DueDate__c <= :endDate and leankor__DueDate__c >= :beginDate) 
                                                        Or (leankor__StartDate__c <= :beginDate AND leankor__DueDate__c >= :endDate))
                                                    With Security_Enforced
                                                    Order By Id, CreatedDate Asc 
                                                    Limit 9999]) {
                if (card.leankor__ValueStream__c != Null && 
                    card.leankor__Valuestream__r.leankor__projectroom__c != null && 
                    !card.leankor__valuestream__r.leankor__Istemplateboard__c) {
                        CardsList.add(card);
                    }
            }            
            
            if(UserStandard.size()>0 && IscurrentUserPartner)
            {
                AddCardNSU = [Select Id,
                                        Name,
                                        leankor__ValueStream__c,
                                        leankor__valueStream__r.leankor__BoardType__c,
                                        leankor__StartDateTime__c,leankor__DueDateTime__c,
                                        OwnerID,
                                        leankor__EstimatedDuration__c,
                                        leankor__DurationUnits__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__c
                                    From leankor__KanbanCard__c 
                                    Where leankor__ValueStream__C IN :ValueStreamID 
                                        And (OwnerID IN : ResourceIDs OR OwnerID IN : UserStandard) 
                                        And leankor__ValueStreamCardLink__c = :KanbanID 
                                        And leankor__ValueStreamLink__c = :filterData.ValueStreamID 
                                        And RecordType.Name = 'ActivityCard' 
                                        And ((leankor__StartDate__c >= : beginDate and leankor__StartDate__c <=: endDate) OR (leankor__DueDate__c <= : endDate and leankor__DueDate__c >= : beginDate) OR(leankor__StartDate__c <= : beginDate AND leankor__DueDate__c >= : endDate))
                                    With Security_Enforced
                                    Order BY Id, CreatedDate Asc
                                    Limit 9999];
                CardsList.addall(AddCardNSU); 
            }
            //------------------For CH Only--------------
            if(IscurrentUserPartner && (KanbanID != Null || KanbanID != '') && (filterData.ValueStreamID != Null || filterData.ValueStreamID != '')){
                // remove cards which are not dependent.
                if(CHverb == 'other'){
                    
                    CardsList.clear();                
                    CardsList = [Select Id,
                                        Name,
                                        leankor__ValueStream__c,
                                        leankor__valueStream__r.leankor__BoardType__c,
                                        leankor__StartDateTime__c,
                                        leankor__DueDateTime__c,
                                        OwnerID,
                                        leankor__EstimatedDuration__c,
                                        leankor__DurationUnits__c,
                                        leankor__ValueStream__r.leankor__ProjectRoom__c
                                    From leankor__KanbanCard__c 
                                    Where Id =:KanbanID 
                                        And leankor__ValueStream__c =:filterData.ValueStreamID
                                        And RecordType.Name = 'ActivityCard' 
                                        And (
                                            (leankor__StartDate__c >= :beginDate And leankor__StartDate__c <= :endDate) 
                                            Or (leankor__DueDate__c <= :endDate And leankor__DueDate__c >= :beginDate) 
                                            Or (leankor__StartDate__c <= :beginDate And leankor__DueDate__c >= :endDate)
                                        )
                                    With Security_Enforced
                                    Order By Id,CreatedDate
                                    Limit 9999];
                    
                    ValueStreamID.clear();
                    ValueStreamID.add(filterData.ValueStreamID);
                }
                
                //------------ CH Code---
                
                tempVSIDs.addall(ValueStreamID);
                dependencies = getDependnecy(tempVSIDs);
                
                Map<String,Set<String>> KanbanMap = new Map<String,Set<String>>(); 
                for(leankor__Dependency__C d : dependencies){
                    tempVSIDs.add(d.leankor__ValueStream__c);
                    if(d.leankor__KanbanCard__r.leankor__ValueStream__c != null){
                        tempVSIDs.add(d.leankor__KanbanCard__r.leankor__ValueStream__c);
                    }
                    if(d.leankor__Successor__r.leankor__ValueStream__c != null){
                        tempVSIDs.add(d.leankor__Successor__r.leankor__ValueStream__c);
                    }
                    if(d.leankor__Predecessor__r.leankor__ValueStream__c != null){
                        tempVSIDs.add(d.leankor__Predecessor__r.leankor__ValueStream__c);
                    }
                }
                //dependencies = [SELECT Id,leankor__GUID__c,leankor__KanbanCard__c,leankor__Predecessor__r.leankor__ValueStreamCardLink__c, leankor__Predecessor__r.leankor__ValueStreamLink__c,leankor__Predecessor__c,leankor__Successor__c,leankor__Successor__r.leankor__ValueStreamCardLink__c, leankor__Successor__r.leankor__ValueStreamLink__c,leankor__ValueStream__c,Name FROM leankor__Dependency__c Where leankor__Predecessor__r.leankor__ValueStream__c IN :tempVSIDs OR leankor__Successor__r.leankor__ValueStream__c  IN :tempVSIDs OR leankor__ValueStream__c  IN :tempVSIDs limit 49999];
                dependencies = getDependnecy(tempVSIDs);
        
                for(leankor__Dependency__c dp : dependencies){
                    
                    Set<String> tempSetSuccessor = KanbanMap.ContainsKey(dp.leankor__Predecessor__c) ? KanbanMap.get(dp.leankor__Predecessor__c) : new Set<String>();
                    tempSetSuccessor.add(dp.leankor__Successor__c);
                    KanbanMap.put(dp.leankor__Predecessor__c,tempSetSuccessor );
                    
                    Set<String> tempSetPredecessor = KanbanMap.ContainsKey(dp.leankor__Successor__c) ? KanbanMap.get(dp.leankor__Successor__c) : new Set<String>();
                    tempSetPredecessor.add(dp.leankor__Predecessor__c);
                    KanbanMap.put(dp.leankor__Successor__c,tempSetPredecessor);
                }
                for(leankor__KanbanCard__c k : CardsList){
                    Set<String> kanbanIDs = new Set<String>();
                    AllRelatedCards.add(k.Id);
                    if(KanbanMap.ContainsKey(k.Id) == true){ 
                        kanbanIDs =  KanbanMap.get(k.Id);   
                        for(Integer j=0; j <5; j++){
                            for(Integer i=0; i < kanbanIDs.Size(); i++ ){
                                String tempString = (new list<string>(kanbanIDs))[i];
                                AllRelatedCards.add(tempString);
                                Set<String> tempIDs = KanbanMap.get(tempString);
                                kanbanIDs.addAll(tempIDs);
                            }
                        }
                        kanbanIDs.clear();
                    }
                }
                CardsList = new List<leankor__KanbanCard__c>();
                for (leankor__KanbanCard__c card : [Select Id, 
                                                            Name, 
                                                            leankor__ValueStream__c, 
                                                            leankor__valueStream__r.leankor__BoardType__c, 
                                                            leankor__StartDateTime__c, 
                                                            leankor__DueDateTime__c, 
                                                            OwnerID, 
                                                            leankor__EstimatedDuration__c, 
                                                            leankor__DurationUnits__c, 
                                                            leankor__ValueStream__r.leankor__ProjectRoom__c, 
                                                            leankor__valueStream__r.leankor__Istemplateboard__c, 
                                                            RecordType.Name 
                                                    From leankor__KanbanCard__c 
                                                    Where Id In :AllRelatedCards 
                                                        And ( 
                                                            (leankor__StartDate__c >= :beginDate And leankor__StartDate__c <= :endDate) 
                                                            Or (leankor__DueDate__c <= :endDate And leankor__DueDate__c >= :beginDate) 
                                                            Or (leankor__StartDate__c <= :beginDate And leankor__DueDate__c >= :endDate)
                                                        )
                                                    With Security_Enforced
                                                    Order By Id, CreatedDate, leankor__StartDateTime__c 
                                                    Limit 49999]) {
                    if (card.leankor__ValueStream__c!=null && card.leankor__Valuestream__r.leankor__projectroom__c != null && !card.leankor__valueStream__r.leankor__Istemplateboard__c && card.RecordType.Name != 'FolderCard') {
                        CardsList.add(card);
                    } 
                }
            }            
        }
        else
        {                            
            CardsList = new List<leankor__KanbanCard__c>();
            for (leankor__KanbanCard__c card : [Select Id,
                                                        Name,
                                                        leankor__ValueStream__c,
                                                        leankor__valueStream__r.leankor__BoardType__c, 
                                                        leankor__StartDateTime__c, 
                                                        leankor__DueDateTime__c, 
                                                        OwnerID, 
                                                        leankor__EstimatedDuration__c, 
                                                        leankor__DurationUnits__c, 
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c, 
                                                        leankor__valueStream__r.leankor__Istemplateboard__c 
                                                    From leankor__KanbanCard__c 
                                                    Where RecordType.Name = 'ActivityCard' 
                                                        And OwnerID In :ResourceIDs 
                                                        And ((leankor__StartDate__c >= :beginDate And leankor__StartDate__c <= :endDate) 
                                                            Or (leankor__DueDate__c <= :endDate And leankor__DueDate__c >= :beginDate) 
                                                            Or (leankor__StartDate__c <= :beginDate And leankor__DueDate__c >= :endDate)
                                                        ) 
                                                        And Id > :lastCardId
                                                    With Security_Enforced 
                                                    Order By Id, CreatedDate Asc 
                                                    Limit 9999]) { 
                if (card.leankor__ValueStream__c != Null && card.leankor__Valuestream__r.leankor__projectroom__c != null && !card.leankor__valuestream__r.leankor__Istemplateboard__c) {
                    cardsList.add(card);    
                }
            }
            
            if(UserStandard.size()>0 && IscurrentUserPartner)
            {
                AddCardNSU = [Select Id, 
                                        Name, 
                                        leankor__ValueStream__c, 
                                        leankor__valueStream__r.leankor__BoardType__c, 
                                        leankor__StartDateTime__c, 
                                        leankor__DueDateTime__c, 
                                        OwnerID, 
                                        leankor__EstimatedDuration__c, 
                                        leankor__DurationUnits__c, 
                                        leankor__ValueStream__r.leankor__ProjectRoom__c 
                                From leankor__KanbanCard__c 
                                Where leankor__ValueStream__c In :ValueStreamID 
                                        And ( 
                                            OwnerID In :ResourceIDs 
                                            Or OwnerID In :UserStandard 
                                        ) 
                                        And leankor__ValueStreamCardLink__c = :KanbanID 
                                        And leankor__ValueStreamLink__c = :filterData.ValueStreamID 
                                        And RecordType.Name = 'ActivityCard' 
                                        And ( 
                                            (leankor__StartDate__c >= :beginDate And leankor__StartDate__c <= :endDate) 
                                            Or (leankor__DueDate__c <= :endDate And leankor__DueDate__c >= :beginDate) 
                                            Or (leankor__StartDate__c <= :beginDate And leankor__DueDate__c >= :endDate)
                                        ) 
                                        And Id > :lastCardId
                                With Security_Enforced   
                                Order By Id, CreatedDate Asc 
                                Limit 9999];
                
                CardsList.addall(AddCardNSU); 
            }
            //------------------For CH Only--------------
            if(IscurrentUserPartner && (KanbanID != Null || KanbanID != '') && (filterData.ValueStreamID != Null || filterData.ValueStreamID != '')){
                // remove cards which are not dependent.
                if(CHverb == 'other'){
                    
                    CardsList.clear();                
                    CardsList = [Select Id, 
                                        Name, 
                                        leankor__ValueStream__c, 
                                        leankor__valueStream__r.leankor__BoardType__c, 
                                        leankor__StartDateTime__c, 
                                        leankor__DueDateTime__c, 
                                        OwnerID, 
                                        leankor__EstimatedDuration__c, 
                                        leankor__DurationUnits__c, 
                                        leankor__ValueStream__r.leankor__ProjectRoom__c 
                                    From leankor__KanbanCard__c 
                                    Where ( 
                                            Id = :KanbanID 
                                            And leankor__ValueStream__c = :filterData.ValueStreamID 
                                    ) 
                                    And RecordType.Name = 'ActivityCard' 
                                    And ( 
                                        (leankor__StartDate__c >= :beginDate And leankor__StartDate__c <= :endDate) 
                                        Or (leankor__DueDate__c <= :endDate And leankor__DueDate__c >= :beginDate) 
                                        Or (leankor__StartDate__c <= :beginDate And leankor__DueDate__c >= :endDate) 
                                    ) 
                                    And Id > :lastCardId 
                                    With Security_Enforced 
                                    Limit 9999];
                    
                    ValueStreamID.clear();
                    ValueStreamID.add(filterData.ValueStreamID);
                }
                
                //------------ CH Code---
                
                tempVSIDs.addall(ValueStreamID);
                dependencies = getDependnecy(tempVSIDs);

                Map<String,Set<String>> KanbanMap = new Map<String,Set<String>>(); 
                for(leankor__Dependency__C d : dependencies){
                    tempVSIDs.add(d.leankor__ValueStream__c);
                    if(d.leankor__KanbanCard__r.leankor__ValueStream__c != null){
                        tempVSIDs.add(d.leankor__KanbanCard__r.leankor__ValueStream__c);
                    }
                    if(d.leankor__Successor__r.leankor__ValueStream__c != null){
                        tempVSIDs.add(d.leankor__Successor__r.leankor__ValueStream__c);
                    }
                    if(d.leankor__Predecessor__r.leankor__ValueStream__c != null){
                        tempVSIDs.add(d.leankor__Predecessor__r.leankor__ValueStream__c);
                    }
                }
                dependencies = getDependnecy(tempVSIDs);
                for(leankor__Dependency__c dp : dependencies){
                    Set<String> tempSetSuccessor = KanbanMap.ContainsKey(dp.leankor__Predecessor__c) ? KanbanMap.get(dp.leankor__Predecessor__c) : new Set<String>();
                    tempSetSuccessor.add(dp.leankor__Successor__c);
                    KanbanMap.put(dp.leankor__Predecessor__c,tempSetSuccessor );
                    
                    Set<String> tempSetPredecessor = KanbanMap.ContainsKey(dp.leankor__Successor__c) ? KanbanMap.get(dp.leankor__Successor__c) : new Set<String>();
                    tempSetPredecessor.add(dp.leankor__Predecessor__c);
                    KanbanMap.put(dp.leankor__Successor__c,tempSetPredecessor);
                    
                }
                
                for(leankor__KanbanCard__c k : CardsList){
                    Set<String> kanbanIDs = new Set<String>();
                    AllRelatedCards.add(k.Id);
                    if(KanbanMap.ContainsKey(k.Id) == true){ 
                        kanbanIDs =  KanbanMap.get(k.Id);   
                        for(Integer j=0; j <5; j++){
                            for(Integer i=0; i < kanbanIDs.Size(); i++ ){
                                String tempString = (new list<string>(kanbanIDs))[i];
                                AllRelatedCards.add(tempString);
                                Set<String> tempIDs = KanbanMap.get(tempString);
                                kanbanIDs.addAll(tempIDs);
                            }
                        }
                        kanbanIDs.clear();
                    }
                }
            }
        }
        
        for(leankor__KanbanCard__c KnbnCard : CardsList){
            leankor.KanbanToGanttController.MasterContainer card = New leankor.KanbanToGanttController.MasterContainer ();
                
                MapOfVS.Put(KnbnCard.ID,KnbnCard.leankor__ValueStream__c);
                MapOfKanbanName.put(KnbnCard.Id,KnbnCard.Name);
                //MapOfVSName.Put(KnbnCard.leankor__ValueStream__c,KnbnCard.leankor__ValueStream__r.Name);
                
                card.ID = KnbnCard.ID ;
                card.StartDate = JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
                card.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__C);
                card.ResourceId = KnbnCard.OwnerID ;
                card.Name = KnbnCard.Name;
                //---------------
                Card.ValueStreamID = KnbnCard.leankor__ValueStream__c;
                Card.ValueStream = KnbnCard.leankor__ValueStream__c;
                Card.ProjectRoomID = KnbnCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
                card.ForceID=KnbnCard.id;
                card.EstimatedDuration=KnbnCard.leankor__EstimatedDuration__c;
                if(KnbnCard.leankor__DurationUnits__c=='Days') card.DurationUnits='d';
                else if(KnbnCard.leankor__DurationUnits__c=='Weeks') card.DurationUnits='w';
                else if(KnbnCard.leankor__DurationUnits__c=='Hours') card.DurationUnits='h';
                else if(KnbnCard.leankor__DurationUnits__c=='Months') card.DurationUnits='mo';
                else if(KnbnCard.leankor__DurationUnits__c=='Years') card.DurationUnits='y';
                else if(KnbnCard.leankor__DurationUnits__c=='Minutes') card.DurationUnits='mi';
                
                card.ItemType='KC';
                card.leaf=true;
                        
                card.BoardType =(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'Plan Board' ? 'Kanban Board' :(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'DashBoard' ? 'WhiteBoard' :KnbnCard.leankor__valueStream__r.leankor__BoardType__c));
                
            ReturnList.Add(card);
        }
        return ReturnList;
    }
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    List Of all KanbanCard Filtered by ResourceIds
    Inputs:         List of Resource Ids
    Returns:        List<MasterContainer>
    ------------------------------------------------------------*/
    @TestVisible
    private static List<leankor.KanbanToGanttController.MasterContainer> getAssociatedTaskOfResources(List<String> ResourceIds, List<leankor__KanbanCard__c> AddVSCard, List<String> ValueStreamID){
        if(filterData.lastTaskId==null) {
            return new List<leankor.KanbanToGanttController.MasterContainer>();
        }
        
        String lastTaskId=filterData.lastTaskId;
        List<leankor.KanbanToGanttController.MasterContainer> ReturnList= new List< leankor.KanbanToGanttController.MasterContainer>();
        Map<String,String> MapOfVS = New Map<String,String>();    
        Map<String,String> MapOfKanbanName = New Map<String,String>();
        List<leankor__KanbanCard__c > cardsList = new List<leankor__KanbanCard__c >();
        String lastCardId=filterData.lastCardId;
        List<Task> TaskList = new List<Task>();
        if(!String.isBlank(lastTaskId))
        {
            try{
                //SS 19.03.2018
                //Modified query for retriving task records including archived records      
                //Dharma 
                TaskList = new List<Task>();

                Set<Id> whatIds = new Set<Id>();
                List<Task> kanbanCardTask = new List<Task>();

                for(Task tsk: [SELECT Id,Priority,OwnerID,
                           Subject,Status,ActivityDate,
                           WhatID,Description,Owner.Name,
                           LastModifiedDate,CreatedDate FROM Task  
                           WHERE (OwnerId IN :ResourceIDs
                                  AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                  AND IsDeleted = false) 
                           AND WhatId IN 
                           (   
                               Select ID 
                               FROM leankor__KanbanCard__c WHERE 
                               leankor__valuestream__r.leankor__Istemplateboard__c = false  
                               AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                               AND leankor__MasterContainer__r.leankor__Type__c != 'Template'
                           )
                           AND id >: lastTaskId
                           ORDER BY Id, CreatedDate
                           limit 9999 All Rows]){ //AND WhatID != NULL 

                    whatIds.add(tsk.WhatId);
                    kanbanCardTask.add(tsk);
                }

                if(!whatIds.isEmpty()){
                    Set<Id> kanbanCardIds = new Set<Id>();
                    for (leankor__KanbanCard__c kanbanCard : [Select Id, 
                                                                    leankor__Valuestream__c, 
                                                                    leankor__Valuestream__r.leankor__ProjectRoom__c 
                                                                From leankor__KanbanCard__c 
                                                                Where Id In :whatIds
                                                                With Security_Enforced]) {

                        if(kanbanCard.leankor__Valuestream__c != NULL && 
                           kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__C != NULL){
                            kanbanCardIds.add(kanbanCard.Id);
                        }
                    }

                    if(!kanbanCardIds.isEmpty()){
                        for(Task tsk: kanbanCardTask){
                            if(kanbanCardIds.contains(tsk.WhatId)){
                                TaskList.add(tsk);
                            }
                        }
                    }
                }    
                
                if(UserStandard.size()>0 && IscurrentUserPartner){
                    //Dharma 
                    //SS 19.03.2018
                    //Modified query for retriving task records including archived records

                    Set<Id> kanbanCardIds = new Set<Id>();
                    List<Task> Taskpartner = new List<Task>();

                    for(Task tsk: [SELECT Id, Priority,
                                             OwnerID,Subject,Status,ActivityDate,
                                             WhatID,Description,Owner.Name,
                                             LastModifiedDate,CreatedDate FROM Task  
                                             WHERE (OwnerId IN :UserStandard AND WhatID IN :CardsList 
                                                    AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                                    AND IsDeleted = false)
                                             AND WhatId in 
                                             (   
                                                 SELECT ID 
                                                 FROM leankor__KanbanCard__c WHERE 
                                                 leankor__valuestream__r.leankor__Istemplateboard__c = false  
                                                 AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                                                 AND leankor__MasterContainer__r.leankor__Type__c != 'Template'
                                             )
                                             AND id >: lastTaskId
                                             ORDER BY Id, CreatedDate
                                             limit 9999 All Rows]){
                        Taskpartner.add(tsk);
                        kanbanCardIds.add(tsk.WhatId);
                    }

                    if(!kanbanCardIds.isEmpty()){
                        Set<Id> partnerKanbanCardIds = new Set<Id>();
                        for (leankor__KanbanCard__c kCard : [Select Id, 
                                                                    leankor__Valuestream__c, 
                                                                    leankor__Valuestream__r.leankor__ProjectRoom__c 
                                                            From leankor__KanbanCard__c 
                                                            Where Id In :kanbanCardIds
                                                            With Security_Enforced]) {
                                                            
                            if(kCard.leankor__Valuestream__c != NULL && 
                               kCard.leankor__Valuestream__r.leankor__ProjectRoom__C != NULL){
                                    partnerKanbanCardIds.add(kCard.Id);
                               }
                        }

                        if(!partnerKanbanCardIds.isEmpty()){
                            for(Task tsk: Taskpartner){
                                if(partnerKanbanCardIds.contains(tsk.WhatId)){
                                    TaskList.add(tsk);
                                }
                            }
                        }
                    }
                }
                
            }catch(Exception ex){
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            
            List<String> tempCardID = New List<String>();
            for(task LogTask :TaskList){
                tempCardID.add(LogTask.WhatID);
            }
            CardsList.clear();
            CardsList = new List<leankor__KanbanCard__c>();
            for (leankor__KanbanCard__c card : [Select Id, 
                                                        leankor__ValueStream__c, 
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c, 
                                                        leankor__ValueStream__r.leankor__IsTemplateBoard__c, 
                                                        leankor__ValueStream__r.leankor__BoardType__c, 
                                                        Name, 
                                                        leankor__MasterContainer__r.leankor__Type__c 
                                                    From leankor__KanbanCard__c 
                                                    Where Id In :tempCardID 
                                                    With Security_Enforced 
                                                    Order By Id, CreatedDate Asc 
                                                    Limit 49999]) { 
                if (card.leankor__MasterContainer__r.leankor__Type__c != 'Template' && card.leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' && !card.leankor__valuestream__r.leankor__Istemplateboard__c
                    && card.leankor__Valuestream__r.leankor__ProjectRoom__c != NULL && card.leankor__Valuestream__c != NULL) {
                    CardsList.add(card);
                }
            }
            
            if(UserStandard.size()>0 && IscurrentUserPartner)
            {
                TaskList.clear();
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                TaskList =[select Id,Priority,OwnerID,Subject,
                           Status,ActivityDate,WhatID,
                           Description,Owner.Name,
                           LastModifiedDate,CreatedDate 
                           from Task  where (OwnerId IN :ResourceIDs 
                                             AND WhatID IN :CardsList 
                                             AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                             AND IsDeleted = false)
                           AND id >: lastTaskId ORDER BY Id, CreatedDate ASC
                           limit 9999 All Rows]; 
                
                List<leankor__Kanbancard__c> VScards = new List<leankor__Kanbancard__c>();
                for (leankor__KanbanCard__c card : [Select Id, 
                                                            leankor__ValueStream__c, 
                                                            leankor__ValueStream__r.leankor__IsTemplateBoard__c, 
                                                            leankor__MasterContainer__r.leankor__Type__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c In :ValueStreamID 
                                                        With Security_Enforced 
                                                        Order By Id, CreatedDate Asc 
                                                        Limit 9999]) {
                    if (!card.leankor__Valuestream__r.leankor__Istemplateboard__c && card.leankor__MasterContainer__r.leankor__Type__c != 'Template') {
                        VScards.add(card);
                    }
                }
                
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                List<Task> Taskstandard =[select Id,Priority,OwnerID,
                                          Subject,Status,ActivityDate,
                                          WhatID,Description,Owner.Name,
                                          LastModifiedDate,CreatedDate 
                                          from Task  where (OwnerId IN :UserStandard 
                                                            AND WhatID IN :VScards 
                                                            AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                                            AND IsDeleted = false)
                                          AND id >: lastTaskId ORDER BY Id, CreatedDate ASC
                                          limit 9999 All Rows];
                
                TaskList.addall(Taskstandard);
            }
        }
        else{
            try{
                //SS 19.03.2018//Dharma 
                //Modified query for retriving task records including archived records

                TaskList = new List<Task>();

                Set<Id> whatIds = new Set<Id>();
                List<Task> kanbanCardTask = new List<Task>();

                for(Task tsk: [SELECT Id,Priority,OwnerID,
                           Subject,Status,ActivityDate,
                           WhatID,Description,Owner.Name,
                           LastModifiedDate,CreatedDate FROM Task  
                           WHERE (OwnerId IN :ResourceIDs
                                  AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                  AND IsDeleted = false) 
                           AND WhatId IN 
                           (   
                               Select ID 
                               FROM leankor__KanbanCard__c WHERE 
                               leankor__valuestream__r.leankor__Istemplateboard__c = false  
                               AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                               AND leankor__MasterContainer__r.leankor__Type__c != 'Template'
                           )
                           ORDER BY Id, CreatedDate
                           limit 9999 All Rows]){ //AND WhatID != NULL 

                    whatIds.add(tsk.WhatId);
                    kanbanCardTask.add(tsk);
                }

                if(!whatIds.isEmpty()){
                    Set<Id> kanbanCardIds = new Set<Id>();
                    for (leankor__KanbanCard__c kanbanCard : [Select Id, 
                                                                        leankor__ValueStream__c, 
                                                                        leankor__ValueStream__r.leankor__ProjectRoom__c 
                                                                From leankor__KanbanCard__c 
                                                                Where Id In :whatIds 
                                                                With Security_Enforced]) { 
                                                             
                    if (kanbanCard.leankor__Valuestream__c != NULL && 
                        kanbanCard.leankor__Valuestream__r.leankor__ProjectRoom__C != NULL) {
                        kanbanCardIds.add(kanbanCard.Id);
                    }
                }
                    
                    if(!kanbanCardIds.isEmpty()){
                        for(Task tsk: kanbanCardTask){
                            if(kanbanCardIds.contains(tsk.WhatId)){
                                TaskList.add(tsk);
                            }
                        }
                    }
                }
                
                if(UserStandard.size()>0 && IscurrentUserPartner){
                    //SS 19.03.2018 //Dharma
                    //Modified query for retriving task records including archived records

                    Set<Id> kanbanCardIds = new Set<Id>();
                    List<Task> Taskpartner = new List<Task>();

                    for(Task tsk: [SELECT Id, Priority,
                                             OwnerID,Subject,Status,ActivityDate,
                                             WhatID,Description,Owner.Name,
                                             LastModifiedDate,CreatedDate FROM Task  
                                             WHERE (OwnerId IN :UserStandard AND WhatID IN :CardsList 
                                                    AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                                    AND IsDeleted = false)
                                             AND WhatId in 
                                             (   
                                                 SELECT ID 
                                                 FROM leankor__KanbanCard__c WHERE 
                                                 leankor__valuestream__r.leankor__Istemplateboard__c = false  
                                                 AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' 
                                                 AND leankor__MasterContainer__r.leankor__Type__c != 'Template'
                                             )
                                             ORDER BY Id, CreatedDate
                                             limit 9999 All Rows]){
                        Taskpartner.add(tsk);
                        kanbanCardIds.add(tsk.WhatId);
                    }

                    if(!kanbanCardIds.isEmpty()){
                        Set<Id> partnerKanbanCardIds = new Set<Id>();
                        for (leankor__KanbanCard__c kCard : [Select Id, 
                                                                    leankor__ValueStream__c, 
                                                                    leankor__ValueStream__r.leankor__ProjectRoom__c 
                                                            From leankor__KanbanCard__c 
                                                            Where Id In :kanbanCardIds 
                                                            With Security_Enforced]) { 
                                                            
                            if (kCard.leankor__Valuestream__c != NULL && 
                                kCard.leankor__Valuestream__r.leankor__ProjectRoom__C != NULL) {
                                    partnerKanbanCardIds.add(kCard.Id);
                                }
                        }
                        
                        if(!partnerKanbanCardIds.isEmpty()){
                            for(Task tsk: Taskpartner){
                                if(partnerKanbanCardIds.contains(tsk.WhatId)){
                                    TaskList.add(tsk);
                                }
                            }
                        }
                    }
                }
                
            }catch(Exception ex){
                throw new Util.LeanException('ERROR:' + ex.getMessage());
            }
            
            List<String> tempCardID = New List<String>();
            for(task LogTask :TaskList){
                tempCardID.add(LogTask.WhatID);
            }
            CardsList.clear();

            CardsList = new List<leankor__KanbanCard__c>();
            for (leankor__KanbanCard__c card : [Select Id, 
                                                        leankor__ValueStream__c, 
                                                        leankor__ValueStream__r.leankor__ProjectRoom__c, 
                                                        leankor__ValueStream__r.leankor__IsTemplateBoard__c, 
                                                        leankor__ValueStream__r.leankor__BoardType__c, 
                                                        leankor__MasterContainer__r.leankor__Type__c, 
                                                        Name 
                                                    From leankor__KanbanCard__c 
                                                    Where Id In :tempCardID 
                                                    With Security_Enforced 
                                                    Order By Id, CreatedDate Asc 
                                                    Limit 49999]) {
                if (card.leankor__Valuestream__c != NULL && card.leankor__Valuestream__r.leankor__ProjectRoom__c != null && !card.leankor__valuestream__r.leankor__Istemplateboard__c && card.leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View' && card.leankor__MasterContainer__r.leankor__Type__c != 'Template') {
                    CardsList.add(card);
                }
            }            
            
            if(UserStandard.size()>0 && IscurrentUserPartner)
            {
                TaskList.clear();
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                TaskList =[select Id,Priority,OwnerID,Subject,
                           Status,ActivityDate,WhatID,
                           Description,Owner.Name,
                           LastModifiedDate,CreatedDate 
                           from Task  where (OwnerId IN :ResourceIDs 
                                             AND WhatID IN :CardsList 
                                             AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                             AND IsDeleted = false)
                           ORDER BY Id, CreatedDate ASC
                           limit 9999 All Rows]; 
                
                List<leankor__Kanbancard__c> VScards = new List<leankor__Kanbancard__c>();
                for (leankor__KanbanCard__c card : [Select Id, 
                                                            leankor__ValueStream__c, 
                                                            leankor__ValueStream__r.leankor__IsTemplateBoard__c, 
                                                            leankor__MasterContainer__r.leankor__Type__c 
                                                        From leankor__KanbanCard__c 
                                                        Where leankor__ValueStream__c In :ValueStreamID 
                                                        With Security_Enforced 
                                                        Order By Id, CreatedDate Asc 
                                                        Limit 9999]) {
                    if (!card.leankor__Valuestream__r.leankor__Istemplateboard__c && card.leankor__MasterContainer__r.leankor__Type__c != 'Template') {
                        VScards.add(card);
                    }
                }
                
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                List<Task> Taskstandard =[select Id,Priority,OwnerID,
                                          Subject,Status,ActivityDate,
                                          WhatID,Description,Owner.Name,
                                          LastModifiedDate,CreatedDate 
                                          from Task  where (OwnerId IN :UserStandard 
                                                            AND WhatID IN :VScards 
                                                            AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                                            AND IsDeleted = false)
                                          ORDER BY Id, CreatedDate ASC
                                          limit 9999 All Rows];
                
                TaskList.addall(Taskstandard);
            }
            
        }
        for(leankor__KanbanCard__c k :CardsList){
            MapOfVS.put(k.ID,k.leankor__ValueStream__c);
            MapOfKanbanName.put(k.Id,k.Name);
        }
        
        for(Task t : TaskList){
            if(t.whatID != Null && MapOfVS.ContainsKey(t.WhatId)){
                Date tempActivityDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);
                Date tempDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate)  ;//- 1
                leankor.KanbanToGanttController.MasterContainer card = New leankor.KanbanToGanttController.MasterContainer ();
                leankor__ValueStream__C tempVSRecord = new leankor__ValueStream__C();
                    card.ID = t.ID ;
                    card.ValueStreamID = (MapOfVS.containsKey(t.WhatID) ? MapOfVS.get(t.WhatID):'');
                    
                    card.StartDate = JSON.Serialize(Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 10, 01, 01));
                    card.DueDate =  JSON.Serialize(Datetime.newInstanceGmt(tempActivityDate.year(), tempActivityDate.month(), tempActivityDate.day(), 10, 01, 01));
                    card.ResourceId = t.OwnerID ;
                    card.Name = t.Subject;
                    // -----------------
                    card.EstimatedDuration = 1;
                    card.DurationUnits = 'd';
                    card.OwnerID = t.OwnerID;
                    card.OwnerName = t.Owner.Name;
                    //card.SmallPhotoUrl =  UserRecords.get(t.OwnerID);
                    card.Priority = (t.Priority == 'Normal'? 0 :(t.Priority == 'Low' ? 1 : 2) );
                    card.Subject = t.Subject;
                    card.Status =  t.Status;
                    card.Description = t.Description;
                    card.WhatId = t.WhatId;
                    card.ItemType='Task';
                    card.expanded = false;
                    card.leaf = true;
                    //------------------
                ReturnList.Add(card);
            }
        }  
       return ReturnList;
    } 
    
    /** YJ - 14 Nov 2017
    * Modified method for lazy loading on RS in CH
    * Added filter StartDate and DueDate
    * Reduce unnecessary field for increase performance 
    */  
     
    /*@RemoteAction
    Global Static leankor.KanbanToGanttController.ResourceScheduler getKanbanCardsByResourceOnCH(list<String> ResourceIDs,List<String> ValueStreamID,String KanbanID, String VSID,String CHVerb){
                       
        leankor.KanbanToGanttController.MasterContainer filterData = (leankor.KanbanToGanttController.MasterContainer)JSON.deserialize(VSID,leankor.KanbanToGanttController.MasterContainer.class);     
        
        Date beginDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.StartDate), DateTime.class));
        Date endDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(filterData.DueDate), DateTime.class));
        
        List<User> PartnerUser =[SELECT Id FROM User WHERE Usertype != 'Standard' AND ID IN :ResourceIDs];
        List<User> AdminUser =[SELECT Id FROM User WHERE Usertype = 'Standard' AND ID IN :ResourceIDs];
        List<String> UserStandard = new List<String> ();
        List<String> UserNonStandard = new List<String> ();
        boolean IscurrentUserPartner = false;
        if(Userinfo.getUserType()!='Standard'){
            IscurrentUserPartner = true;
            for(User PUser : PartnerUser){
            UserNonStandard.add(PUser.ID);
            }
            for(User Usercheck :AdminUser){
            UserStandard.add(Usercheck.ID);
            }
        }
        if(IscurrentUserPartner){
            ResourceIDs.clear();
            IF(UserNonStandard.size() > 0){
                ResourceIDs.addall(UserNonStandard);
            }
        }
        //List<String> relatedCards = New List<string>();
        List<leankor__KanbanCard__c> AddCardNSU = New List<leankor__KanbanCard__c> ();
        //List<leankor__KanbanCard__c> AddVSCard = new List<leankor__KanbanCard__c>();
        
        List<leankor__KanbanCard__c> CardsList =[Select Id,leankor__valueStream__r.leankor__BoardType__c,Name,leankor__ValueStream__c,leankor__StartDateTime__c,leankor__DueDateTime__c,
                                              OwnerID,leankor__EstimatedDuration__c,leankor__DurationUnits__c,leankor__ValueStream__r.leankor__ProjectRoom__c
                                              from leankor__KanbanCard__c 
                                              Where leankor__ValueStream__C != Null AND RecordType.Name = 'ActivityCard' 
                                              AND  leankor__Valuestream__r.leankor__projectroom__c != null 
                                              AND leankor__valuestream__r.leankor__Istemplateboard__c = false 
                                              AND OwnerID IN : ResourceIDs 
                                              AND ((leankor__StartDate__c >= : beginDate and leankor__StartDate__c <=: endDate) OR (leankor__DueDate__c <= : endDate and leankor__DueDate__c >= : beginDate) OR(leankor__StartDate__c <= : beginDate AND leankor__DueDate__c >= : endDate))
                                              limit 49999];
        
        if(UserStandard.size()>0 && IscurrentUserPartner)
        {
            AddCardNSU = [Select Id,leankor__valueStream__r.leankor__BoardType__c,Name,leankor__ValueStream__c,leankor__StartDateTime__c,leankor__DueDateTime__c,
                         OwnerID,leankor__EstimatedDuration__c,leankor__DurationUnits__c,leankor__ValueStream__r.leankor__ProjectRoom__c 
                         from leankor__KanbanCard__c 
                         Where leankor__ValueStream__C IN :ValueStreamID 
                         AND ( OwnerID IN : ResourceIDs OR OwnerID IN : UserStandard ) 
                         AND leankor__ValueStreamCardLink__c = :KanbanID 
                         AND leankor__ValueStreamLink__c = :filterData.ValueStreamID 
                         AND RecordType.Name = 'ActivityCard' 
                         AND ((leankor__StartDate__c >= : beginDate and leankor__StartDate__c <=: endDate) OR (leankor__DueDate__c <= : endDate and leankor__DueDate__c >= : beginDate) OR(leankor__StartDate__c <= : beginDate AND leankor__DueDate__c >= : endDate))
                         limit 49999];
            
            //AddVSCard =[Select Id,leankor__UrlLink__c,leankor__CardID__c,leankor__point__c,Name,leankor__ValueStream__r.Name,leankor__EffortRemaining__c,leankor__Order__c,leankor__Opportunity__C,leankor__Opportunity__r.Name,leankor__Account__r.Id,leankor__Account__r.Name,leankor__Actual_Time_Taken__c,leankor__Bottom__c,leankor__Budgeted_Time__c,leankor__Case__c,leankor__Case__r.Id,leankor__Case__r.Subject,leankor__Case__r.Status,leankor__Case__r.Priority,leankor__Case__r.CaseNumber,leankor__Color__c,leankor__CompletionVariance__c,leankor__CmpID__c,leankor__Contact__r.Id,leankor__Contact__r.Name,leankor__CSSLayout__c,leankor__DateColor__c,leankor__Description__c,leankor__AcceptanceCriteria__c,leankor__DescriptionLong__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__ActualDuration__c,leankor__EstimatedDuration__c,leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__IsCompletedOnTime__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__KanbanCardTemplate__r.Name,leankor__Left__c,leankor__PercentComplete2__c,leankor__Priority__c,leankor__PromiseCompletionDate__c,leankor__StartDate__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStream__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__ZoneGUID__c,OwnerID,Owner.Name,leankor__valueStream__r.leankor__BoardType__c,leankor__ValueStreamLink__r.leankor__BoardType__c,leankor__DueDateTime__c,RecordType.Name,leankor__OnBudget__c,leankor__OnQuality__c,leankor__OnTime__c,leankor__StartDateTime__c from leankor__KanbanCard__c Where leankor__ValueStream__C IN :ValueStreamID AND OwnerID IN : UserStandard AND leankor__ValueStreamCardLink__c = :KanbanID AND leankor__ValueStreamLink__c = :VSID AND RecordType.Name = 'ActivityCard' limit 49999];
            
            //AddCardNSU.addall(AddVSCard);
            CardsList.addall(AddCardNSU); 
        }
        
        List<leankor.KanbanToGanttController.MasterContainer> ReturnList = New List<leankor.KanbanToGanttController.MasterContainer>();
        Map<String,String> MapOfVS = New Map<String,String>();    
        Map<String,String> MapOfKanbanName = New Map<String,String>();
        //Integer tempGanttId =1;
        
        //------------------For CH Only--------------
        if(IscurrentUserPartner && (KanbanID != Null || KanbanID != '') && (filterData.ValueStreamID != Null || filterData.ValueStreamID != '')){
        // remove cards which are not dependent.
            if(CHverb == 'other'){
                
                CardsList.clear();                
                CardsList = [Select Id,leankor__valueStream__r.leankor__BoardType__c,Name,leankor__ValueStream__c,leankor__StartDateTime__c,leankor__DueDateTime__c,OwnerID,leankor__EstimatedDuration__c,leankor__DurationUnits__c
                             from leankor__KanbanCard__c 
                             Where (Id =:KanbanID AND leankor__ValueStream__c =:filterData.ValueStreamID) 
                             AND RecordType.Name = 'ActivityCard' 
                             AND ((leankor__StartDate__c >= : beginDate and leankor__StartDate__c <=: endDate) OR (leankor__DueDate__c <= : endDate and leankor__DueDate__c >= : beginDate) OR(leankor__StartDate__c <= : beginDate AND leankor__DueDate__c >= : endDate))
                             Limit 49999];
                             
                ValueStreamID.clear();
                ValueStreamID.add(filterData.ValueStreamID);
            }
            
            //------------ CH Code---
            Set<String> AllRelatedCards = new Set<String>();
            Set<String> tempVSIDs = new Set<String>();
            tempVSIDs.addall(ValueStreamID);
            List<leankor__Dependency__c> dependencies = [SELECT Id,leankor__GUID__c,leankor__Predecessor__r.leankor__ValueStream__c,leankor__KanbanCard__c,leankor__Successor__r.leankor__ValueStream__c,leankor__KanbanCard__r.leankor__ValueStream__c,leankor__Predecessor__c,leankor__Successor__c,leankor__ValueStream__c,Name FROM leankor__Dependency__c Where leankor__Predecessor__r.leankor__ValueStream__c IN :tempVSIDs OR leankor__Successor__r.leankor__ValueStream__c  IN :tempVSIDs OR leankor__ValueStream__c  IN :tempVSIDs limit 49999];
            Map<String,Set<String>> KanbanMap = new Map<String,Set<String>>(); 
            for(leankor__Dependency__C d : dependencies){
                tempVSIDs.add(d.leankor__ValueStream__c);
                if(d.leankor__KanbanCard__r.leankor__ValueStream__c != null){
                    tempVSIDs.add(d.leankor__KanbanCard__r.leankor__ValueStream__c);
                   // relatedCards.add(d.leankor__KanbanCard__c);
                }
                if(d.leankor__Successor__r.leankor__ValueStream__c != null){
                    tempVSIDs.add(d.leankor__Successor__r.leankor__ValueStream__c);
                     //relatedCards.add(d.leankor__Successor__c);
                }
                if(d.leankor__Predecessor__r.leankor__ValueStream__c != null){
                    tempVSIDs.add(d.leankor__Predecessor__r.leankor__ValueStream__c);
                     //relatedCards.add(d.leankor__Predecessor__c);
                }
            }
            dependencies = [SELECT Id,leankor__GUID__c,leankor__KanbanCard__c,leankor__Predecessor__r.leankor__ValueStreamCardLink__c, leankor__Predecessor__r.leankor__ValueStreamLink__c,leankor__Predecessor__c,leankor__Successor__c,leankor__Successor__r.leankor__ValueStreamCardLink__c, leankor__Successor__r.leankor__ValueStreamLink__c,leankor__ValueStream__c,Name FROM leankor__Dependency__c Where leankor__Predecessor__r.leankor__ValueStream__c IN :tempVSIDs OR leankor__Successor__r.leankor__ValueStream__c  IN :tempVSIDs OR leankor__ValueStream__c  IN :tempVSIDs limit 49999];
            for(leankor__Dependency__c dp : dependencies){
                if(KanbanMap.ContainsKey(dp.leankor__Predecessor__c) == true){
                    Set<String> tempSet = KanbanMap.get(dp.leankor__Predecessor__c);
                    tempSet.add(dp.leankor__Successor__c);
                    KanbanMap.put(dp.leankor__Predecessor__c,tempSet);
                }else{
                    Set<String> tempSet = new Set<String>();
                    tempSet.add(dp.leankor__Successor__c);
                    KanbanMap.put(dp.leankor__Predecessor__c,tempSet);
                }
            if(KanbanMap.ContainsKey(dp.leankor__Successor__c) == true){
                Set<String> tempSet = KanbanMap.get(dp.leankor__Successor__c);
                tempSet.add(dp.leankor__Predecessor__c);
                KanbanMap.put(dp.leankor__Successor__c,tempSet);
            }else{
                Set<String> tempSet = new Set<String>();
                tempSet.add(dp.leankor__Predecessor__c);
                KanbanMap.put(dp.leankor__Successor__c,tempSet);
            }
        
        }
        for(leankor__KanbanCard__c k : CardsList){
            Set<String> kanbanIDs = new Set<String>();
            AllRelatedCards.add(k.Id);
            if(KanbanMap.ContainsKey(k.Id) == true){ 
                kanbanIDs =  KanbanMap.get(k.Id);   
                for(Integer j=0; j <5; j++){
                    for(Integer i=0; i < kanbanIDs.Size(); i++ ){
                        String tempString = (new list<string>(kanbanIDs))[i];
                        AllRelatedCards.add(tempString);
                        Set<String> tempIDs = KanbanMap.get(tempString);
                        kanbanIDs.addAll(tempIDs);
                    }
                 }
                 kanbanIDs.clear();
             }
         }
         //---
         CardsList = [select Id,Name,leankor__ValueStream__c,leankor__valueStream__r.leankor__BoardType__c,leankor__StartDateTime__c,leankor__DueDateTime__c,
                     OwnerID,leankor__EstimatedDuration__c,leankor__DurationUnits__c,leankor__ValueStream__r.leankor__ProjectRoom__c
                     from leankor__KanbanCard__c 
                     WHERE Id IN :AllRelatedCards  and leankor__ValueStream__c!=null 
                     AND  leankor__Valuestream__r.leankor__projectroom__c != null 
                     AND  leankor__valueStream__r.leankor__Istemplateboard__c = false 
                     AND RecordType.Name != 'FolderCard'
                     AND ((leankor__StartDate__c >= : beginDate and leankor__StartDate__c <=: endDate) OR (leankor__DueDate__c <= : endDate and leankor__DueDate__c >= : beginDate) OR(leankor__StartDate__c <= : beginDate AND leankor__DueDate__c >= : endDate)) 
                     ORDER BY  leankor__StartDateTime__c   LIMIT 49999];
        // CardsList.addall(TempCards);
        }
        
        For(leankor__KanbanCard__c KnbnCard : CardsList){
            leankor.KanbanToGanttController.MasterContainer card = New leankor.KanbanToGanttController.MasterContainer ();
                
                //card.CardID=knbnCard.leankor__CardID__c;
                //Card.ValueStreamName = KnbnCard.leankor__ValueStream__r.Name;
                MapOfVS.Put(KnbnCard.ID,KnbnCard.leankor__ValueStream__c);
                MapOfKanbanName.put(KnbnCard.Id,KnbnCard.Name);
                //MapOfVSName.Put(KnbnCard.leankor__ValueStream__c,KnbnCard.leankor__ValueStream__r.Name);
                
                card.ID = KnbnCard.ID ;
                card.StartDate = JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
                card.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__C);
                card.ResourceId = KnbnCard.OwnerID ;
                card.Name = KnbnCard.Name;
                //---------------
                Card.ValueStreamID = KnbnCard.leankor__ValueStream__c;
                Card.ValueStream = KnbnCard.leankor__ValueStream__c;
                Card.ProjectRoomID = KnbnCard.leankor__ValueStream__r.leankor__ProjectRoom__c;
                card.ForceID=KnbnCard.id;
                card.EstimatedDuration=KnbnCard.leankor__EstimatedDuration__c;
                if(KnbnCard.leankor__DurationUnits__c=='Days') card.DurationUnits='d';
                else if(KnbnCard.leankor__DurationUnits__c=='Weeks') card.DurationUnits='w';
                else if(KnbnCard.leankor__DurationUnits__c=='Hours') card.DurationUnits='h';
                else if(KnbnCard.leankor__DurationUnits__c=='Months') card.DurationUnits='mo';
                else if(KnbnCard.leankor__DurationUnits__c=='Years') card.DurationUnits='y';
                else if(KnbnCard.leankor__DurationUnits__c=='Minutes') card.DurationUnits='mi';
                
                card.ItemType='KC';
                card.leaf=true;
                //card.StartDate = KnbnCard.leankor__StartDateTime__c <= KnbnCard.leankor__DueDateTime__c ? 
                                                                                //JSON.Serialize(KnbnCard.leankor__StartDateTime__c) :
                                                                                //JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                //card.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                //card.Point = KnbnCard.leankor__point__c;
                //card.PercentDone=KnbnCard.leankor__PercentComplete2__c;
                //card.Title=KnbnCard.leankor__KanbanCardTemplate__r.Name;
                //card.Top=Integer.valueOf(KnbnCard.leankor__Top__c);
                //card.Bottom=Integer.valueOf(KnbnCard.leankor__Bottom__c);
                //card.Left=Integer.valueOf(KnbnCard.leankor__Left__c);
                //card.Width=Integer.valueOf(KnbnCard.leankor__Width__c);
                //card.Height=Integer.valueOf(KnbnCard.leankor__Height__c);
                //card.X=Integer.valueOf(KnbnCard.leankor__x__c);
                //card.Y=Integer.valueOf(KnbnCard.leankor__Y__c);
                //card.JSONData=KnbnCard.leankor__JSONData__c;
                //card.JSONDefinition=KnbnCard.leankor__JSONDefinition__c;
                //card.EffortRemaining = Integer.valueof(KnbnCard.leankor__EffortRemaining__c);
                //card.State=KnbnCard.leankor__State__c;
                //card.ZoneID=(KnbnCard.leankor__ZoneGUID__c==null?'':KnbnCard.leankor__ZoneGUID__c);
                //card.MCForceID = (KnbnCard.leankor__MasterContainer__c == Null ? '' :KnbnCard.leankor__MasterContainer__c);
                //card.SWForceID = (KnbnCard.leankor__Swimlane__c == Null ? '' :KnbnCard.leankor__Swimlane__c);
                //card.ZoneForceID = (KnbnCard.leankor__Zone__c == Null? '' :KnbnCard.leankor__Zone__c);
                //card.TemplateID=(KnbnCard.leankor__KanbanCardTemplate__c==null?'':KnbnCard.leankor__KanbanCardTemplate__c);
                //card.TemplateName=KnbnCard.leankor__KanbanCardTemplate__r.Name;
                //card.Color=(KnbnCard.leankor__KanbanCardTemplate__r.leankor__Color__c=='' ? KnbnCard.leankor__Color__c:KnbnCard.leankor__KanbanCardTemplate__r.leankor__Color__c);
                //card.Priority=Integer.valueOf(KnbnCard.leankor__Priority__c);
                //card.HarveyBall=string.valueOf(KnbnCard.leankor__PercentComplete2__c);
                //card.DateColor=KnbnCard.leankor__DateColor__c;
                //card.Description=KnbnCard.leankor__DescriptionLong__c;
               //card.AcceptanceCriteria=KnbnCard.leankor__AcceptanceCriteria__c;
                //card.ValueStreamCardLink=(KnbnCard.leankor__ValueStreamCardLink__c==null?'':KnbnCard.leankor__ValueStreamCardLink__c);
                //card.ValueStreamLinkID=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__c);
                //card.ValueStreamLinkBoardType=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__r.leankor__BoardType__c);
                //card.Account=(KnbnCard.leankor__Account__r.Id==null?'':KnbnCard.leankor__Account__r.Id);
                //card.Contact=(KnbnCard.leankor__Contact__r.Id==null?'':KnbnCard.leankor__Contact__r.Id);
                //card.CaseID=(KnbnCard.leankor__Case__r.Id==null?'':KnbnCard.leankor__Case__r.Id);
                //card.Opportunity=(KnbnCard.leankor__Opportunity__c==null?'':KnbnCard.leankor__Opportunity__c);
                //card.OpportunityName=(KnbnCard.leankor__Opportunity__c==null?'':KnbnCard.leankor__Opportunity__r.Name);
                //card.CmpID=KnbnCard.leankor__CmpID__c;
                //card.GUID=KnbnCard.leankor__GUID__c;
                //card.OwnerID=KnbnCard.OwnerID;
                //card.OwnerName = KnbnCard.Owner.Name;
                //card.AccountName=(KnbnCard.leankor__Account__r.Name==null?'':KnbnCard.leankor__Account__r.Name);
                //card.ContactName=(KnbnCard.leankor__Contact__r.Name==null?'':KnbnCard.leankor__Contact__r.Name);
                //card.CaseSubject= (KnbnCard.leankor__Case__c == null ?'':(KnbnCard.leankor__Case__r.Subject == null ? 'Case : '+KnbnCard.leankor__Case__r.CaseNumber :KnbnCard.leankor__Case__r.Subject));                
                //card.CaseStatus=(KnbnCard.leankor__Case__r.Status==null?'':KnbnCard.leankor__Case__r.Status);  
                //card.CasePriority=(KnbnCard.leankor__Case__r.Priority==null?'':KnbnCard.leankor__Case__r.Priority); 
                //card.CaseTrigger=false;
                //card.ZoneTitle='';
                //card.LeavedZoneTitle='';
                //card.Base64Drawing='';
                //card.Base64FileType=''; 
                //card.KanbanUrl='';
                card.BoardType =(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'Plan Board' ? 'Kanban Board' :(KnbnCard.leankor__valueStream__r.leankor__BoardType__c == 'DashBoard' ? 'WhiteBoard' :KnbnCard.leankor__valueStream__r.leankor__BoardType__c));
                //card.SmallPhotoUrl = UserRecords.get(KnbnCard.OwnerId);
                //card.Order = KnbnCard.leankor__Order__c; //(KnbnCard.leankor__Order__c== null? tempOrder :KnbnCard.leankor__Order__c);
                //card.OnBudget = KnbnCard.leankor__OnBudget__c;
                //card.OnQuality = KnbnCard.leankor__OnQuality__c;
                //card.OnTime = KnbnCard.leankor__OnTime__c;
                //card.OwnerName = KnbnCard.Owner.Name;
                //card.UrlLink = KnbnCard.leankor__UrlLink__c;
                //---------------
            //tempGanttId++;
            ReturnList.Add(card);
        }
        
         List<Task> TaskList = new List<Task>();
         try{
         //SS 19.03.2018
         //Modified query for retriving task records including archived records         
         TaskList =[select Id,Priority,OwnerID,
                    Subject,Status,ActivityDate,
                    WhatID,Description,Owner.Name,
                    LastModifiedDate,CreatedDate from Task  
                    where (OwnerId IN :ResourceIDs
                    AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                    AND IsDeleted = false) limit 49999 All Rows]; //AND WhatID != NULL 
            
            if(UserStandard.size()>0 && IscurrentUserPartner){
                //SS 19.03.2018
                //Modified query for retriving task records including archived records
                List<Task> Taskpartner =[select Id,Priority,
                                        OwnerID,Subject,Status,ActivityDate,
                                        WhatID,Description,Owner.Name,
                                        LastModifiedDate,CreatedDate from Task  
                                        where (OwnerId IN :UserStandard AND WhatID IN :CardsList 
                                        AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                        AND IsDeleted = false) 
                                        limit 49999 All Rows];
                TaskList.addall(Taskpartner);
            }
            
         }catch(Exception ex){
            System.debug(ex.getMessage());
         }
         
         List<String> tempCardID = New List<String>();
         for(task LogTask :TaskList){
             tempCardID.add(LogTask.WhatID);
         }
         CardsList.clear();
         CardsList = [Select ID,leankor__Valuestream__c,
                    Name from leankor__KanbanCard__c 
                    Where Id IN: tempCardID and leankor__Valuestream__c != NULL 
                    AND leankor__Valuestream__r.leankor__ProjectRoom__c != NULL 
                    AND leankor__valuestream__r.leankor__boardtype__c != 'Portfolio View'];
         
         if(UserStandard.size()>0 && IscurrentUserPartner)
         {
            TaskList.clear();
            //SS 19.03.2018
            //Modified query for retriving task records including archived records
            TaskList =[select Id,Priority,OwnerID,Subject,
                        Status,ActivityDate,WhatID,
                        Description,Owner.Name,
                        LastModifiedDate,CreatedDate 
                        from Task  where (OwnerId IN :ResourceIDs 
                        AND WhatID IN :CardsList 
                        AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                        AND IsDeleted = false)
                        limit 49999 All Rows]; 
                         
            List<leankor__Kanbancard__c> VScards = [select Id From leankor__Kanbancard__c where leankor__valuestream__c IN :ValueStreamID limit 49999];
            //SS 19.03.2018
            //Modified query for retriving task records including archived records
            List<Task> Taskstandard =[select Id,Priority,OwnerID,
                                      Subject,Status,ActivityDate,
                                      WhatID,Description,Owner.Name,
                                      LastModifiedDate,CreatedDate 
                                      from Task  where (OwnerId IN :UserStandard 
                                      AND WhatID IN :VScards 
                                      AND ActivityDate >= : beginDate and ActivityDate <=: endDate
                                      AND IsDeleted = false)
                                      limit 49999 All Rows];
                                      
            TaskList.addall(Taskstandard);
         }
         for(leankor__KanbanCard__c k :CardsList){
             MapOfVS.put(k.ID,k.leankor__ValueStream__c);
             MapOfKanbanName.put(k.Id,k.Name);
         }
        List<leankor__ValueStream__c> VSList = [Select Id,Name,leankor__ProjectRoom__c,leankor__ProjectRoom__r.Name from leankor__ValueStream__c Where Id IN :MapOfVS.Values() Limit 49999];
        
        //Map<String,leankor__ValueStream__C> MapOfVSName = new Map<String,leankor__ValueStream__C>(); 
        //for(leankor__ValueStream__C vs : VSList){
        //MapOfVSName.put(vs.Id, vs);
        //}
        
        for(Task t : TaskList){
            if(t.whatID != Null && MapOfVS.ContainsKey(t.WhatId)){
                Date tempActivityDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate);
                Date tempDate = (t.ActivityDate == null ? Date.ValueOf(t.LastModifiedDate) : t.ActivityDate)  ;//- 1
                leankor.KanbanToGanttController.MasterContainer card = New leankor.KanbanToGanttController.MasterContainer ();
                leankor__ValueStream__C tempVSRecord = new leankor__ValueStream__C();
                    card.ID = t.ID ;
                    //card.KanbanCardName = (MapOfKanbanName.containsKey(t.WhatID) ? MapOfKanbanName.get(t.WhatID):'');
                    card.ValueStreamID = (MapOfVS.containsKey(t.WhatID) ? MapOfVS.get(t.WhatID):'');
                    //card.ValueStream = (MapOfVS.containsKey(t.WhatID) ? MapOfVS.get(t.WhatID):'');
                    //Card.ValueStreamName = (MapOfVSName.containsKey(card.ValueStreamID) ? MapOfVSName.get(card.ValueStreamID):'');
                    //tempVSRecord = (MapOfVSName.containsKey(card.ValueStreamID) ? MapOfVSName.get(card.ValueStreamID): (new leankor__ValueStream__c()) );
                    //Card.ValueStreamName =(tempVSRecord == null ? '' : tempVSRecord.Name);
                    //Card.ProjectRoomName =(tempVSRecord == null ? '' : tempVSRecord.leankor__ProjectRoom__r.Name);
                    //Card.ProjectRoomID =(tempVSRecord == null ? '' : tempVSRecord.leankor__ProjectRoom__c);
                    //Card.PercentDone = (t.Status == 'Completed' ? 100 : 0);
                    card.StartDate = JSON.Serialize(Datetime.newInstanceGmt(tempDate.year(), tempDate.month(), tempDate.day(), 10, 01, 01));
                    card.DueDate =  JSON.Serialize(Datetime.newInstanceGmt(tempActivityDate.year(), tempActivityDate.month(), tempActivityDate.day(), 10, 01, 01));
                    card.ResourceId = t.OwnerID ;
                    card.Name = t.Subject;
                    // -----------------
                    card.EstimatedDuration = 1;
                    card.DurationUnits = 'd';
                    card.OwnerID = t.OwnerID;
                    card.OwnerName = t.Owner.Name;
                    //card.SmallPhotoUrl =  UserRecords.get(t.OwnerID);
                    card.Priority = (t.Priority == 'Normal'? 0 :(t.Priority == 'Low' ? 1 : 2) );
                    card.Subject = t.Subject;
                    card.Status =  t.Status;
                    card.Description = t.Description;
                    card.WhatId = t.WhatId;
                    card.ItemType='Task';
                    card.expanded = false;
                    card.leaf = true;
                    //------------------
                //tempGanttId++;
                ReturnList.Add(card);
            }
        }  
            //return ReturnList;
        if(IscurrentUserPartner){
            ResourceIDs.addall(UserStandard);
        }
       
       List<User> UserList = [Select Id,Name,SmallPhotoURL from User Where Id IN :ResourceIDs limit 49999];
       Set<leankor.KanbanToGanttController.CardResource> cardResources = new Set<leankor.KanbanToGanttController.CardResource>();
        for(User u : UserList){
            leankor.KanbanToGanttController.CardResource tempResource = new leankor.KanbanToGanttController.CardResource(u.Id,u.Name,u.SmallPhotoURL);
            cardResources.add(tempResource);
        } 
       return (new leankor.KanbanToGanttController.ResourceScheduler(ReturnList,cardResources));
    }*/
    //
    // This Method Is Use get Zone Records On Load.
    // INPUT: GUID form KanbanCard.
    // OUTPUT : Zone records for input GUID
    //       
    @RemoteAction
    Global static leankor.KanbanToGanttController.MasterContainer getVSHierarchyRecord(String requestedID){
        leankor__Zone__c Zone =[SELECT Id,leankor__Swimlane__c,leankor__ValueStream__c,leankor__Swimlane__r.leankor__MasterContainer__c,leankor__Swimlane__r.leankor__MasterContainer__r.name,leankor__ValueStream__r.name,leankor__ValueStream__r.leankor__Boardtype__C FROM leankor__Zone__c Where leankor__GUID__C =:requestedID  Limit 1];
        leankor.KanbanToGanttController.MasterContainer VSLog = new leankor.KanbanToGanttController.MasterContainer();
            VSLog.Id=Zone.leankor__ValueStream__c;
            VSLog.Name=Zone.leankor__ValueStream__r.name;
            if(Zone.leankor__ValueStream__r.leankor__Boardtype__C != 'WhiteBoard' && Zone.leankor__ValueStream__r.leankor__Boardtype__C != 'DashBoard'){
                List<leankor__Swimlane__c> SWdata = [Select Id, 
                                                            Name, 
                                                            (Select Id, 
                                                                    leankor__GUID__c 
                                                            From leankor__Zones__r) 
                                                    From leankor__Swimlane__c 
                                                    Where leankor__MasterContainer__c = :Zone.leankor__Swimlane__r.leankor__MasterContainer__c 
                                                    With Security_Enforced];
                List<leankor.KanbanToGanttController.MasterContainer> MCListLog = new List<leankor.KanbanToGanttController.MasterContainer>();
                if(SWdata.size()==1 && SWdata[0].leankor__zones__r.size()==1){
                    leankor.KanbanToGanttController.MasterContainer MCLog = new leankor.KanbanToGanttController.MasterContainer();
                        MCLog.Id=Zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                        MCLog.Name=Zone.leankor__Swimlane__r.leankor__MasterContainer__r.name;
                        MCLog.GUID = requestedID;
                        MCLog.children = new List<leankor.KanbanToGanttController.MasterContainer>();
                    MCListLog.add(MCLog);                   
                }else{
                    for(leankor__Swimlane__c Swlog : SWdata){
                        if(Swlog.id == Zone.leankor__Swimlane__c){
                            if(Swlog.leankor__zones__r.size() == 1){
                                leankor.KanbanToGanttController.MasterContainer MCLog = new leankor.KanbanToGanttController.MasterContainer();
                                    MCLog.Id=Zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                    MCLog.Name=Zone.leankor__Swimlane__r.leankor__MasterContainer__r.name;
                                    List<leankor.KanbanToGanttController.MasterContainer> SWListLog = new List<leankor.KanbanToGanttController.MasterContainer>();
                                    leankor.KanbanToGanttController.MasterContainer SWzoneLog = new leankor.KanbanToGanttController.MasterContainer();
                                        SWzoneLog.Id = Swlog.Id;
                                        SWzoneLog.Name = Swlog.Name;
                                        SWzoneLog.GUID = requestedID;
                                        SWzoneLog.children = new List<leankor.KanbanToGanttController.MasterContainer>();
                                    SWListLog.add(SWzoneLog);
                                    MCLog.children = SWListLog;
                                MCListLog.add(MCLog);
                            }else{
                                leankor.KanbanToGanttController.MasterContainer MCLog = new leankor.KanbanToGanttController.MasterContainer();
                                    MCLog.Id=Zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                    MCLog.Name=Zone.leankor__Swimlane__r.leankor__MasterContainer__r.name;
                                    list<leankor.KanbanToGanttController.MasterContainer> childListlog = new list<leankor.KanbanToGanttController.MasterContainer>();
                                    leankor.KanbanToGanttController.MasterContainer child = leankor.KanbanToGanttController.getZoneRecord(requestedID);                   
                                    child.children = new List<leankor.KanbanToGanttController.MasterContainer>();
                                    childListlog.add(child);
                                    MCLog.children =ChildListLog;
                                MCListLog.add(MCLog);
                            }
                        }
                    }
                
                }
                /*List<leankor.KanbanToGanttController.MasterContainer> MCListLog = new List<leankor.KanbanToGanttController.MasterContainer>();
                leankor.KanbanToGanttController.MasterContainer MCLog = new leankor.KanbanToGanttController.MasterContainer();
                    MCLog.Id=Zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                    MCLog.Name=Zone.leankor__Swimlane__r.leankor__MasterContainer__r.name;
                    list<leankor.KanbanToGanttController.MasterContainer> childListlog = new list<leankor.KanbanToGanttController.MasterContainer>();
                    leankor.KanbanToGanttController.MasterContainer child = leankor.KanbanToGanttController.getZoneRecord(requestedID);                           
                    childListlog.add(child);
                    MCLog.children =ChildListLog;
                MCListLog.add(MCLog);*/
                VSLog.children = MCListLog;
            }else{
                list<leankor.KanbanToGanttController.MasterContainer> childListlog = new list<leankor.KanbanToGanttController.MasterContainer>();
                leankor.KanbanToGanttController.MasterContainer child = leankor.KanbanToGanttController.getZoneRecord(requestedID);
                child.children = new List<leankor.KanbanToGanttController.MasterContainer>();                          
                childListlog.add(child);
            VSLog.children = childListlog;      
            }              
        return VSLog;
    }

    private static List<leankor__Dependency__c> getDependnecy(Set<String> boardIds) {
        return [Select Id, 
                            leankor__GUID__c, 
                            leankor__Predecessor__r.leankor__ValueStream__c, 
                            leankor__KanbanCard__c, 
                            leankor__Successor__r.leankor__ValueStream__c, 
                            leankor__KanbanCard__r.leankor__ValueStream__c, 
                            leankor__Predecessor__r.leankor__ValueStreamCardLink__c, 
                            leankor__Predecessor__r.leankor__ValueStreamLink__c, 
                            leankor__Successor__r.leankor__ValueStreamCardLink__c, 
                            leankor__Successor__r.leankor__ValueStreamLink__c, 
                            leankor__Predecessor__c, 
                            leankor__Successor__c, 
                            leankor__ValueStream__c, 
                            Name 
                    From leankor__Dependency__c 
                    Where leankor__Predecessor__r.leankor__ValueStream__c In :boardIds 
                            Or leankor__Successor__r.leankor__ValueStream__c In :boardIds 
                            Or leankor__ValueStream__c In :boardIds
                    With Security_Enforced
                    Limit 50000];
    }
}