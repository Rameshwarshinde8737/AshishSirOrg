/**************************************************************************
 * Copyright 2012-2018 Lucidsoft Inc. All rights reserved
 * FILE: BoardStatistics.cls
 * CLASS: BoardStatistics    
 **************************************************************************/ 
global with sharing class ProjectBoardStatistics implements Database.Batchable<sObject>
{
    //
    // This Method is for Getting Cards records on Board in Batch format  
    //
    global Database.QueryLocator start(final Database.BatchableContext bc)
    {   /*
        *Modified By :Ashutosh Gour
        *Modification : Modification for making SOQL selective and remove negative selection.
        */
        /* Comment query due to selective SOQL
        String query = 'Select Id From leankor__ValueStream__c Where isDeleted = false And leankor__IsRecordDeleted__c = false And leankor__Boardtype__c != \'Card Hierarchy\' And leankor__ProjectRoom__c != null';
        */
        String query = 'Select Id, leankor__ProjectRoom__c, leankor__Boardtype__c From leankor__ValueStream__c Where isDeleted = false And leankor__IsRecordDeleted__c = false';
        return Database.getQueryLocator(query);
    }
    
    // This(Execute Method) is for Getting Per  VS Cards records on Board in Batch format  
    global void execute(final Database.BatchableContext bc, final List<leankor__ValueStream__c > vsLogs) {              
        
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ValueStreamStatisticBehavior valueStreamStatisticBehavior = new ValueStreamStatisticBehavior();
        if (!valueStreamBehavior.isUpdateable() || 
            !valueStreamStatisticBehavior.isCreateable()) {
            System.abortJob(bc.getJobId());
        }
        //Check CRUD / FLC behavior             
        /*
        *Modified By :Ashutosh Gour
        *Modification : Modification for making SOQL selective and remove negative selection.
        */
        //new code included for Selective soql            
        List<leankor__ValueStream__c> newvsLogs = new List<leankor__ValueStream__c>();
        for (leankor__ValueStream__c vslog : vsLogs) {
            if (vslog.leankor__ProjectRoom__c != null && vslog.leankor__Boardtype__c != 'Card Hierarchy') {
                leankor__ValueStream__c tempvsLog = new leankor__ValueStream__c();
                tempvsLog.Id = vslog.Id;
                newvsLogs.add(tempvsLog);    
            }            
        }
        //end new Code
        Map<Id, List<leankor__KanbanCard__c>> mapCards = new Map<Id, List<leankor__KanbanCard__c>>();
        leankor__KanbanCard__c card = new leankor__KanbanCard__c();
        /* Comment query due to selective SOQL
        String query = 'Select Id, leankor__EffortRemainingTime__c, leankor__PercentComplete__c, leankor__BudgetTimeRemaining__c, leankor__Budgeted_Time__c, leankor__EstimatedDuration__c, leankor__Point__c, leankor__ValueStream__c From leankor__KanbanCard__c Where isDeleted = false And leankor__IsRecordDeleted__c = false And leankor__IsRecordDeleted__c = false And leankor__ValueStream__c In :vsLogs';
        */
        String query = 'Select Id, leankor__EffortRemainingTime__c, leankor__PercentComplete2__c, leankor__BudgetTimeRemaining__c, leankor__Budgeted_Time__c, leankor__EstimatedDuration__c, leankor__Point__c, leankor__ValueStream__c From leankor__KanbanCard__c Where isDeleted = false And leankor__IsRecordDeleted__c = false And leankor__IsRecordDeleted__c = false And leankor__ValueStream__c In :newvsLogs';
        Date currentDateTime = system.Today();
        List<leankor__ValueStreamStatistic__c> insertLogs = new List<leankor__ValueStreamStatistic__c>(); 
        try {    
        	
        	//update PercentComplete of ValueStream
            /* edit code due to selective SOQL
        	Map<String,leankor__ValueStream__c> vsPercentCompleteMap = readPercentCompleteBoard(vsLogs);
            */
            Map<String,leankor__ValueStream__c> vsPercentCompleteMap = readPercentCompleteBoard(newvsLogs);
        	if(vsPercentCompleteMap.size()>0){
        		update vsPercentCompleteMap.values();
        	} 
        	
            Database.QueryLocator queryLocator = Database.getQueryLocator(query);
            Database.QueryLocatorIterator queryIterator =  queryLocator.iterator();     
            // Iterate over the records
            while (queryIterator.hasNext())
            {
                card = (leankor__KanbanCard__c)queryIterator.next();
                List<leankor__KanbanCard__c> listCards = new List<leankor__KanbanCard__c>();
                if(mapCards.containsKey(card.leankor__ValueStream__c)) {
                    listCards = mapCards.get(card.leankor__ValueStream__c);
                }
                listCards.add(card);
                mapCards.put(card.leankor__ValueStream__c, listCards);
            }

            for (Id vsLogId : mapCards.keySet()) {
                List<leankor__KanbanCard__c> kanbans = mapCards.get(vsLogId);
                Integer completedCardCount = 0;
                Integer totalCardsCount = 0;
                Decimal cardsBudgetedTime = 0;
                Decimal remainingcardsBudgetedTime = 0;
                Decimal cardsDuration = 0;
                Decimal completedcardsDuration = 0;
                Integer totalPoint = 0;
                Integer totalRemainingPoint = 0;
                Integer point = 0;
                Decimal effortRemaining = 0;               
                Integer percentComplete = 0;         
                
                // summarize details
                for (leankor__KanbanCard__c cardLog : kanbans) {
                    totalCardsCount += 1;
                    completedCardCount += cardLog.leankor__PercentComplete2__c == 100 ? 1 : 0;
                    cardsBudgetedTime += cardLog.leankor__Budgeted_Time__c == null ? 0 : cardLog.leankor__Budgeted_Time__c;
                    remainingcardsBudgetedTime += cardLog.leankor__BudgetTimeRemaining__c == null ? 0 : cardLog.leankor__BudgetTimeRemaining__c;
                    cardsDuration += cardLog.leankor__EstimatedDuration__c == null ? 0 : cardLog.leankor__EstimatedDuration__c; // this field need to change for right calculation
                    completedcardsDuration += cardLog.leankor__PercentComplete2__c == 100 ? cardLog.leankor__EstimatedDuration__c : 0;
                    totalPoint += (Integer)(cardLog.leankor__Point__c == null ? 0 :  cardLog.leankor__Point__c);
                    effortRemaining += cardLog.leankor__EffortRemainingTime__c == null ? 0 :cardLog.leankor__EffortRemainingTime__c;
                    point = (Integer)(cardLog.leankor__Point__c == null ? 0 :  cardLog.leankor__Point__c );
                    percentComplete = (Integer)(cardLog.leankor__PercentComplete2__c == null ? 0 : (cardLog.leankor__PercentComplete2__c==1 ? 0 : cardLog.leankor__PercentComplete2__c));
                    totalRemainingPoint += point - ((percentComplete * point)/100);
                }   

                insertLogs.add
                    (
                        new leankor__ValueStreamStatistic__c
                        (
	                        leankor__KanbanCardCount__c = totalCardsCount,
	                        leankor__CompletedCardCount__c = completedCardCount,
	                        leankor__CardsBudgetedTime__c = cardsBudgetedTime,
	                        leankor__CardsRemainingBudgetedTime__c = remainingcardsBudgetedTime,
	                        leankor__CardsDuration__c = cardsDuration,
	                        leankor__CompletedcardsDuration__c = completedcardsDuration,
	                        leankor__TotalCardsPoint__c= totalPoint,
	                        leankor__TotalRemainingCardsPoint__c= totalRemainingPoint,
	                        leankor__TotalEffortRemainingTime__c = EffortRemaining,
	                        leankor__ValueStream__c = vsLogId,
                            leankor__ScheduleDate__c = currentDateTime,
                            leankor__TotalPercentComplete__c  = vsPercentCompleteMap.get(vsLogId).leankor__PercentComplete__c
                        )
                    );                
            }
            if (!insertLogs.isEmpty()) {
                insert insertLogs;
            }
        }catch(DmlException e){
            throw new ProjectBoardStatisticsException('ERROR:' + e.getMessage());
        }
    }
    
    // Finish Method For Batch format 
    global void finish(final Database.BatchableContext bc) {
        // Empty method
    }
    
	//Get average PercentComplete of the valueStreams
    public Map<String,leankor__ValueStream__c> readPercentCompleteBoard(final List<leankor__ValueStream__c > vsLogs){
    	Map<String,leankor__ValueStream__c> vsAggregateMap = new Map<String,leankor__ValueStream__c>();
		for(sObject res : [select avg(leankor__PercentComplete2__c) percentComplete, leankor__valueStream__c valueStreamId from leankor__KanbanCard__c where leankor__isRecordDeleted__c = false and leankor__ValueStream__r.leankor__IsRecordDeleted__c = false and leankor__ValueStream__c in: vsLogs group by leankor__valueStream__c]){
    		leankor__ValueStream__c vs = new leankor__ValueStream__c();
    		vs.Id = (String)res.get('valueStreamId');
    		vs.leankor__PercentComplete__c = (Decimal)res.get('percentComplete');
    		vsAggregateMap.put(vs.Id, vs);
    	}
    	return 	vsAggregateMap;
    }

    global class ProjectBoardStatisticsException extends Exception{}
}