/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: PortfolioController.cls
 * CLASS: PortfolioController
*/
Global with sharing class PortfolioController {
    Global PortfolioController (ApexPages.StandardController controller) {
    }
    //
    // This Method Is use To get records on Load for Portfolio Board.
    //
    Global class CardResource{
        Global String Id;
        Global String Name;
      //  GlobalString SmallPhotoUrl;
        
        Global CardResource(String Id,String Name){
            this.Id = Id;
            this.Name = Name; 
        //    this.SmallPhotoUrl = SmallPhotoUrl;  
        }
    }
    Global class PortfolioResourceRecords{
        Global Set<CardResource> ResourcesData;
        Global List<leankor.realTimeController.KanbanTemplate> PortfolioCardView;
        
        Global PortfolioResourceRecords(set<CardResource> ResourcesData,List<leankor.realTimeController.KanbanTemplate> PortfolioCardView){
            this.ResourcesData = ResourcesData;
            this.PortfolioCardView = PortfolioCardView;   
        }
    
    }
    
    global static PortfolioResourceRecords getResources(String VSID){
        /*
        UserBehaviour userBehaviour = new UserBehaviour();
        KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
        if (!userBehaviour.isAccessible() || !kanbanCardTemplateBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        if (String.isNotBlank(VSID) && Util.getSObjectName(VSID) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        List<leankor__KanbanCardTemplate__c> KanbanTemps=leankor.realTimeController.getKanbanCardTemplates(VSID);
        List<leankor__KanbanCardTemplate__c> KanbanTemplates = [Select Id, 
                                                                        Name,
                                                                        leankor__JSONData__c,
                                                                        leankor__JSONDefinition__c,
                                                                        leankor__Title__c,
                                                                        leankor__Width__c,
                                                                        leankor__Height__c,
                                                                        leankor__ValueStream__c,
                                                                        leankor__DerivedFrom__c,
                                                                        leankor__Color__c,
                                                                        leankor__CSSLayout__c,
                                                                        (Select Id,
                                                                                leankor__CardID__c,
                                                                                Name,
                                                                                leankor__AcceptanceCriteria__c,
                                                                                leankor__StartDateTime__c,
                                                                                leankor__DueDateTime__C,
                                                                                leankor__Opportunity__C,
                                                                                leankor__Opportunity__r.Name,
                                                                                leankor__Account__r.Id,
                                                                                leankor__Account__r.Name,
                                                                                leankor__Actual_Time_Taken__c,
                                                                                leankor__Bottom__c,
                                                                                leankor__Budgeted_Time__c,
                                                                                leankor__Case__C,
                                                                                leankor__Case__r.Id,
                                                                                leankor__Case__r.Subject,
                                                                                leankor__Case__r.Status,
                                                                                leankor__Case__r.Priority,
                                                                                leankor__Case__r.CaseNumber,
                                                                                leankor__Color__c,
                                                                                leankor__CompletionVariance__c,
                                                                                leankor__CmpID__c,
                                                                                leankor__Contact__r.Id,
                                                                                leankor__Contact__r.Name,
                                                                                leankor__CSSLayout__c,
                                                                                leankor__DateColor__c,
                                                                                leankor__Description__c,
                                                                                leankor__DescriptionLong__c,
                                                                                leankor__DueDate__c,
                                                                                leankor__DurationUnits__c,
                                                                                leankor__ActualDuration__c,
                                                                                leankor__EstimatedDuration__c,
                                                                                leankor__EffortRemaining__c,
                                                                                leankor__GUID__c,
                                                                                leankor__HarveyBallDoneDate__c,
                                                                                leankor__Height__c,
                                                                                leankor__IsCompletedOnTime__c,
                                                                                leankor__JSONData__c,
                                                                                leankor__JSONDefinition__c,
                                                                                leankor__KanbanCardTemplate__c,
                                                                                leankor__Left__c,
                                                                                leankor__PercentComplete2__c,
                                                                                leankor__Priority__c,
                                                                                leankor__PromiseCompletionDate__c,
                                                                                leankor__StartDate__c,
                                                                                leankor__State__c,
                                                                                leankor__Title__c,
                                                                                leankor__Top__c,
                                                                                leankor__ValueStream__c,
                                                                                leankor__ValueStreamCardLink__c,
                                                                                leankor__ValueStreamLink__c,
                                                                                leankor__Width__c,
                                                                                leankor__X__c,
                                                                                leankor__Y__c,
                                                                                leankor__ZoneGUID__c,
                                                                                OwnerID,
                                                                                Owner.Name,
                                                                                leankor__valueStream__r.leankor__BoardType__c,
                                                                                leankor__ValueStreamLink__r.leankor__BoardType__c 
                                                                            From leankor__KanbanCards__r 
                                                                            Where leankor__ValueStream__c =:VSID 
                                                                            Order By  leankor__StartDate__c
                                                                            Limit 49999) 
                                                                        From leankor__KanbanCardTemplate__c 
                                                                        Where leankor__ValueStream__c =:VSID
                                                                        Order By Name 
                                                                        Limit 49999];
        Integer Count;
        List<String> UserID = New List<String>();
        List<leankor.realTimeController.KanbanTemplate> KanbanCardTemplateList=new List<leankor.realTimeController.KanbanTemplate>();
        Integer TempSize=KanbanTemplates.size();
        if (TempSize > 0) {
            DateTime tempDueDate;
            for (leankor__KanbanCardTemplate__c KCTemplate : KanbanTemplates) {
                Count=0;
                leankor.realTimeController.KanbanTemplate KCTemp=new leankor.realTimeController.KanbanTemplate();
                KCTemp.Id=KCTemplate.Id;
                KCTemp.Name=KCTemplate.Name;
                List<leankor.KanbanToGanttController.MasterContainer> KanbanCardList=new List<leankor.KanbanToGanttController.MasterContainer>();
                Integer KCSize=KCTemplate.leankor__KanbanCards__r.size();
                if (KCSize > 0) {
                    for (leankor__KanbanCard__c KnbnCard : KCTemplate.leankor__KanbanCards__r) {
                        if (Count==0) {
                            if (KnbnCard.leankor__StartDateTime__c <= KnbnCard.leankor__DueDateTime__c) {
                                KCTemp.StartDate = JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
                                tempDueDate=KnbnCard.leankor__DueDateTime__c;
                                Count++;
                            }
                        }
                        if (tempDueDate<=KnbnCard.leankor__DueDate__c) {
                            tempDueDate=KnbnCard.leankor__DueDate__c;
                        }
                        leankor.KanbanToGanttController.MasterContainer KC=new leankor.KanbanToGanttController.MasterContainer();
                        KC.Id=KnbnCard.id;
                        KC.ForceID=KnbnCard.id;
                        KC.CardID=knbnCard.leankor__CardID__c;
                        KC.Name=KnbnCard.name;
                        KC.EstimatedDuration=KnbnCard.leankor__EstimatedDuration__c;
                        KC.EffortRemaining = integer.valueof(KnbnCard.leankor__EffortRemaining__c);
                        if(KnbnCard.leankor__DurationUnits__c=='Days') KC.DurationUnits='d';
                        else if(KnbnCard.leankor__DurationUnits__c=='Weeks') KC.DurationUnits='w';
                        else if(KnbnCard.leankor__DurationUnits__c=='Hours') KC.DurationUnits='h';
                        else if(KnbnCard.leankor__DurationUnits__c=='Months') KC.DurationUnits='mo';
                        else if(KnbnCard.leankor__DurationUnits__c=='Years') KC.DurationUnits='y';
                        else if(KnbnCard.leankor__DurationUnits__c=='Minutes') KC.DurationUnits='mi';
                        if(KnbnCard.leankor__StartDateTime__c <= KnbnCard.leankor__DueDateTime__c){
                            KC.StartDate= JSON.Serialize(KnbnCard.leankor__StartDateTime__c);
                            KC.DueDate=JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                        }else{
                            KC.StartDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                            KC.DueDate = JSON.Serialize(KnbnCard.leankor__DueDateTime__c);
                        }
                        KC.PercentDone=KnbnCard.leankor__PercentComplete2__c;
                        KC.leaf=true;
                        KC.Title=KCTemplate.Name;
                        KC.Top=Integer.valueOf(KnbnCard.leankor__Top__c);
                        KC.Bottom=Integer.valueOf(KnbnCard.leankor__Bottom__c);
                        KC.Left=Integer.valueOf(KnbnCard.leankor__Left__c);
                        KC.Width=Integer.valueOf(KnbnCard.leankor__Width__c);
                        KC.Height=Integer.valueOf(KnbnCard.leankor__Height__c);
                        KC.X=Integer.valueOf(KnbnCard.leankor__x__c);
                        KC.Y=Integer.valueOf(KnbnCard.leankor__Y__c);
                        KC.JSONData=KnbnCard.leankor__JSONData__c;
                        KC.JSONDefinition=KnbnCard.leankor__JSONDefinition__c;
                        KC.State=KnbnCard.leankor__State__c;
                        KC.ZoneID=(KnbnCard.leankor__ZoneGUID__c==null?'':KnbnCard.leankor__ZoneGUID__c);
                        KC.TemplateID=(KnbnCard.leankor__KanbanCardTemplate__c==null?'':KnbnCard.leankor__KanbanCardTemplate__c);
                        KC.Color=KCTemplate.leankor__Color__c;
                        KC.Priority=Integer.valueOf(KnbnCard.leankor__Priority__c);
                        KC.HarveyBall=string.valueOf(KnbnCard.leankor__PercentComplete2__c);
                        KC.DateColor=KnbnCard.leankor__DateColor__c;
                        KC.Description=KnbnCard.leankor__DescriptionLong__c;
                        KC.ValueStreamCardLink=(KnbnCard.leankor__ValueStreamCardLink__c==null?'':KnbnCard.leankor__ValueStreamCardLink__c);
                        KC.ValueStreamLinkBoardType=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__r.leankor__BoardType__c);
                        KC.ValueStreamLinkID=(KnbnCard.leankor__ValueStreamLink__c==null?'':KnbnCard.leankor__ValueStreamLink__c);
                        KC.Account=(KnbnCard.leankor__Account__r.Id==null?'':KnbnCard.leankor__Account__r.Id);
                        KC.Contact=(KnbnCard.leankor__Contact__r.Id==null?'':KnbnCard.leankor__Contact__r.Id);
                        KC.CaseID=(KnbnCard.leankor__Case__r.Id==null?'':KnbnCard.leankor__Case__r.Id);
                        KC.Opportunity=(KnbnCard.leankor__Opportunity__c==null?'':KnbnCard.leankor__Opportunity__c);
                        KC.OpportunityName=(KnbnCard.leankor__Opportunity__c==null?'':KnbnCard.leankor__Opportunity__r.Name);
                        KC.ValueStream=KnbnCard.leankor__ValueStream__c;
                        KC.CmpID=KnbnCard.leankor__CmpID__c;
                        KC.GUID=KnbnCard.leankor__GUID__c;
                        KC.OwnerID=KnbnCard.OwnerID;
                        UserID.add(KnbnCard.OwnerID);
                        KC.OwnerName = KnbnCard.Owner.Name;
                        KC.AccountName=(KnbnCard.leankor__Account__r.Name==null?'':KnbnCard.leankor__Account__r.Name);
                        KC.ContactName=(KnbnCard.leankor__Contact__r.Name==null?'':KnbnCard.leankor__Contact__r.Name);
                        KC.CaseSubject= (KnbnCard.leankor__Case__c == null ?'':(KnbnCard.leankor__Case__r.Subject == null ? 'Case : '+KnbnCard.leankor__Case__r.CaseNumber :KnbnCard.leankor__Case__r.Subject));                
                        KC.CaseStatus=(KnbnCard.leankor__Case__r.Status==null?'':KnbnCard.leankor__Case__r.Status);  
                        KC.CasePriority=(KnbnCard.leankor__Case__r.Priority==null?'':KnbnCard.leankor__Case__r.Priority); 
                        KC.CaseTrigger=false;
                        KC.ZoneTitle='';
                        KC.LeavedZoneTitle='';
                        KC.Base64Drawing='';
                        KC.Base64FileType=''; 
                        KC.KanbanUrl='';
                        KC.BoardType= KnbnCard.leankor__ValueStream__r.leankor__Boardtype__c;
                        KC.AcceptanceCriteria= KnbnCard.leankor__AcceptanceCriteria__c;
                        KanbanCardList.add(KC);
                        
                    }
                    KCTemp.DueDate = JSON.Serialize(tempDueDate);
                }
                kcTemp.children=KanbanCardList;
                kcTemp.expanded=true;
                kcTemp.Color=kcTemplate.leankor__Color__c;
                kcTemp.CSSLayout=kcTemplate.leankor__CSSLayout__c;
                kcTemp.DerivedFrom=kcTemplate.leankor__DerivedFrom__c;
                kcTemp.Height=Integer.valueOf(kcTemplate.leankor__Height__c);
                kcTemp.JSONData=kcTemplate.leankor__JSONData__c;
                kcTemp.JSONDefinition=kcTemplate.leankor__JSONDefinition__c;
                kcTemp.Title=kcTemplate.leankor__Title__c;
                kcTemp.ValueStream=kcTemplate.leankor__ValueStream__c;
                kcTemp.Width=Integer.valueOf(kcTemplate.leankor__Width__c);
                kanbanCardTemplateList.add(kcTemp);
            }
        }
        boolean currentrecords = true;
        List<User> UserList = [Select Id,
                                    Name 
                                From User 
                                Where Id In :UserID];
        for (User Userdata :UserList) {
            if (Userdata.ID == UserInfo.getUserId()) {
                currentrecords = false;
                break;
            }
        }
        if (currentrecords) {
            UserList = [Select Id,
                                Name 
                            From User 
                            Where Id = :UserInfo.getUserID()];
        }
        Set<CardResource> cardResources = new Set<CardResource>();
            for(User u : UserList){
            CardResource tempResource = new CardResource(u.Id,u.Name);
            cardResources.add(tempResource);
        }
        PortfolioResourceRecords PortfoilioResult = new PortfolioResourceRecords(cardResources,kanbanCardTemplateList);
        return PortfoilioResult;    
        */
        return new PortfolioResourceRecords(new Set<CardResource>(),new List<leankor.realTimeController.KanbanTemplate>());
        
    }
}