/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: visualHomeController.cls
 * CLASS: visualHomeController  
 */
global with sharing class visualHomeController {
    global visualHomeController() {}
    global visualHomeController(ApexPages.StandardController controller) {}
    global static List<leankor__KanbanCard__c> getKanbanCards() {
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();
        // Modify queries to fix 200k record issue
        for (leankor__KanbanCard__c kanban: readKanbanCards()) {
            if (String.isNotBlank(kanban.leankor__ValueStream__c) && String.isNotBlank(kanban.leankor__ValueStream__r.leankor__ProjectRoom__c)) {
                kanbanCards.add(kanban);
        }
    }

        return kanbanCards;
    }


    public static List<leankor__KanbanCard__c> readKanbanCards() {
        List<leankor__KanbanCard__c> kanbancards = new List<leankor__KanbanCard__c>();
         
        for (leankor__KanbanCard__c kanbanCard : [Select Id,
                                                            Name,
                                                            leankor__Title__c,
                                                            leankor__ValueStream__c,
                                                            leankor__ValueStream__r.Name,
                                                            leankor__ValueStream__r.leankor__BoardType__c,
                                                            leankor__DueDate__c,
                                                            leankor__PercentComplete2__c,
                                                            leankor__IsRecordDeleted__c,
                                                            leankor__valuestream__r.leankor__Projectroom__c,
                                                            leankor__Valuestream__r.leankor__IsTemplateBoard__c
                                                        From leankor__KanbanCard__c 
                                                        Where OwnerId =: UserInfo.getUserId() 
                                                        With Security_Enforced
                                                        Order By leankor__DueDate__c Asc Nulls Last
                                                        Limit 49999]) {
            if (kanbanCard.leankor__valuestream__c !=null 
                                                && kanbanCard.leankor__valuestream__r.leankor__Projectroom__c != null 
                                                && kanbanCard.leankor__Valuestream__r.leankor__IsTemplateBoard__c == false
                                                && kanbanCard.leankor__IsRecordDeleted__c == false) {
                kanbancards.add(kanbanCard);
            }
        }
            
        return kanbancards;
    }


    global PageReference Redirect() {
        UserBehaviour checkUserBehaviour = new userBehaviour();
        if (!checkUserBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        PageReference myWorkspace;
        User currentUser =null;
        try {
            currentUser =[Select Id, 
                                    Name,
                                    leankor__MyWorkspace__c 
                                From User 
                                Where Id =: UserInfo.getUserId() 
                                Limit 1];
        } catch(QueryException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());    
        }
        String myWorkpage =currentUser.leankor__MyWorkspace__c;
        PageReference errorPage = Page.leankor__VisualHome;
        try {   
            myWorkspace= new PageReference(myWorkpage);
            myWorkspace.setRedirect(true);
        } catch(Exception ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return myWorkspace;
    }
    global String getVisualReportURL() {
        String ReportID = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('ReportId'), 'UTF-8');
        return (((new Pagereference ('/'+ReportId)).setRedirect(false)).getContent().toString()); 
    }

    public Component.Apex.OutputText getOutputContent(){
        Component.Apex.OutputText oppText = new Component.Apex.OutputText(escape = false);
        String ReportID = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('ReportId'), 'UTF-8');
        oppText.value = (((new Pagereference ('/'+ReportId)).setRedirect(false)).getContent().toString());     
        return oppText ;
    }
 }