global with sharing class TimeSheet {

    global TimeSheet(ApexPages.StandardController stdController) {
        
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read TimeSheet base on TimeSheetIds
     Input       : List of User Id
     Output      : List of TimeSheet
     --------------------------------------------------------------------------------*/ 

    @RemoteAction
    global static List<leankor__TimeSheet__c> readTimeSheets(final List<Id> resourceIds){  
        for (Id resourceId : resourceIds) {
            if (String.isNotBlank(resourceId) && (Util.getSObjectName(resourceId) != 'User')) {
				throw new Util.LeanException('Error: Invalid input');
			}
        }
        List<leankor__TimeSheet__c> timesheets = new List<leankor__TimeSheet__c>();
        try {
            timesheets = [Select Id,
                                    Name,
                                    leankor__ApprovalHistoryStatus__c,
                                    leankor__EndDateTime__c,
                                    leankor__Resource__c,
                                    leankor__StartDateTime__c
                                    From leankor__TimeSheet__c
                                    Where leankor__Resource__c In: resourceIds
                                With Security_Enforced
                                Order By leankor__StartDateTime__c Desc];
                
        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return timesheets;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Read TimeSheet base on TimeSheetIds
     Input       : List of TimeSheet Id
     Output      : List of TimeSheet
     --------------------------------------------------------------------------------*/ 

     @RemoteAction
     global static List<leankor__TimeSheet__c> readTimeSheetsByIds(final List<Id> timeSheetIds){
        for (Id timeSheetId : timeSheetIds) {
            if (String.isNotBlank(timeSheetId) && (Util.getSObjectName(timeSheetId) != 'leankor__TimeSheet__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
        }
        List<leankor__TimeSheet__c> timesheets = new List<leankor__TimeSheet__c>();
         
        try {
             timesheets = [Select Id,
                                    Name,
                                    leankor__ApprovalHistoryStatus__c,
                                    leankor__EndDateTime__c,
                                    leankor__Resource__c,
                                    leankor__StartDateTime__c
                                    From leankor__TimeSheet__c
                                Where Id In: timeSheetIds
                                With Security_Enforced
                                Order By leankor__StartDateTime__c DESC];
                 
        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return timesheets;
     }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method will create the TimeSheet and also will update associate all the user's TimeLog (not parented records) that have dates in-between start and end dates.
     Input       : List of TimeSheet
     Output      : List of TimeSheet
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeSheet__c> createTimeSheets(final List<leankor__TimeSheet__c> timeSheets){
        if (!leankor__TimeSheet__c.sObjectType.getDescribe().isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        Savepoint sp = Database.setSavepoint();  
        Set<Id> resourceIds = new set<Id>();
        Map<Id, List<leankor__TimeCard__c>> timeCardMap = new Map<Id, List<leankor__TimeCard__c>>();
        List<leankor__TimeCard__c> timeCards = new List<leankor__TimeCard__c>();
        Date minTimeSheetDate;
        Date maxTimeSheetDate;
        try {
            if(timeSheets.size() > 0){
                insert timeSheets;
            }
            for (leankor__TimeSheet__c timeSheet : timeSheets) {
                for (leankor__TimeCard__c timeCard : leankor.TimeCard.readTimeCardsUsers(new List< Id>{timeSheet.leankor__Resource__c}, timeSheet.leankor__StartDateTime__c, timeSheet.leankor__EndDateTime__c)) {
                    if (timeCard.leankor__TimeSheet__c == null) {
                        leankor__TimeCard__c newTimeCard = new leankor__TimeCard__c();
                        newTimeCard.Id = timeCard.Id;
                        newTimeCard.leankor__TimeSheet__c = timeSheet.Id;
                        timeCards.add(newTimeCard);
                    }
                }
            } 
            leankor.TimeCard.updateTimeCards(timeCards);

        } catch (Exception e) {
            Database.rollback(sp);
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return timeSheets;
    } 

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Update the TimeSheet that received in the method.
     Input       : List of TimeSheet
     Output      : List of TimeSheet
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeSheet__c> updateTimeSheets(final List<leankor__TimeSheet__c> timeSheets){
        if (!leankor__TimeSheet__c.sObjectType.getDescribe().isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        for(leankor__TimeSheet__c timeSheet : timeSheets){
            if (String.isNotBlank(timeSheet.Id) && (Util.getSObjectName(timeSheet.Id) != 'leankor__TimeSheet__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
        }
        Map<String, DateTime> mintimecardMap = new Map<String, DateTime>();
        Map<String, DateTime> maxtimecardMap = new Map<String, DateTime>();
        List<leankor__TimeSheet__c> result = new List<leankor__TimeSheet__c>();
        DateTime minTimeSheetDate, maxTimeSheetDate, mintimecardDate, maxtimecardDate; 
        Set<Id> timeSheetIds = (new Map<Id, SObject>(timesheets)).keySet();
        try {
            for (AggregateResult timeCard : [Select Min(leankor__LogTime__c) minDate,
                                                        Max(leankor__LogTime__c) maxDate,
                                                        leankor__TimeSheet__c timeSheet
                                                    From leankor__TimeCard__c 
                                                    Where leankor__TimeSheet__c In: timeSheetIds
                                                    With Security_Enforced
                                                    Group By leankor__TimeSheet__c]) {
                mintimecardMap.put(String.valueOf(timeCard.get('timeSheet')), DateTime.valueOf(timeCard.get('minDate')));
                maxtimecardMap.put(String.valueOf(timeCard.get('timeSheet')), DateTime.valueOf(timeCard.get('maxDate')));
            }  
            for (leankor__TimeSheet__c timeSheet : timeSheets) {
                //Changes for Date field to DateTime field.
                minTimeSheetDate = Date.newInstance(timeSheet.leankor__StartDateTime__c.year(),timeSheet.leankor__StartDateTime__c.month(),timeSheet.leankor__StartDateTime__c.day());
                maxTimeSheetDate = Date.newInstance(timeSheet.leankor__EndDateTime__c.year(),timeSheet.leankor__EndDateTime__c.month(),timeSheet.leankor__EndDateTime__c.day());
             // minTimeSheetDate = timeSheet.leankor__StartDateTime__c;
             // maxTimeSheetDate = timeSheet.leankor__EndDateTime__c;
              

                if (minTimecardMap.size() > 0 || maxtimecardMap.size() > 0 ) {
                  //Changes for Date field to DateTime field.
                    mintimecardDate = Date.newInstance(mintimecardMap.get(timeSheet.Id).year(), mintimecardMap.get(timeSheet.Id).month(), mintimecardMap.get(timeSheet.Id).day());
                    maxtimecardDate = Date.newInstance(maxtimecardMap.get(timeSheet.Id).year(), maxtimecardMap.get(timeSheet.Id).month(), maxtimecardMap.get(timeSheet.Id).day());
                 // mintimecardDate = mintimecardMap.get(timeSheet.id);
                //  maxtimecardDate = maxtimecardMap.get(timeSheet.id);
                  
                    if ((mintimecardDate >= minTimeSheetDate && maxtimecardDate <= maxTimeSheetDate)) {                    
                    result.add(timeSheet);
                    }
                } else {
                    result.add(timesheet);
                }
            }
            if (result.size() > 0) {
                update result;
                return result;
            }  
        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }
        return new List<leankor__TimeSheet__c>();
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method deleted the TimeSheet if leankor__ApprovalHistoryStatus__c id empty.
     Input       : List of TimeSheet Id
     Output      : List of TimeSheet Id
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<Id> deleteTimeSheets(final List<Id> timeSheetIds){
        if (!leankor__TimeSheet__c.sObjectType.getDescribe().isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        for (Id timeSheetId : timeSheetIds) {
            if (String.isNotBlank(timeSheetId) && (Util.getSObjectName(timeSheetId) != 'leankor__TimeSheet__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
        }
        List<leankor__TimeSheet__c> timeSheetList;
        try {
            // To allow deletion if ApprovalHistoryStatus is empty
            timeSheetList = [Select Id 
                                From leankor__TimeSheet__c 
                                Where Id In: timeSheetIds And leankor__ApprovalHistoryStatus__c = null
                                With Security_Enforced];
            
            for (leankor__TimeSheet__c timeSheet : timeSheetList) {
                timeSheet.leankor__Resource__c = null;
            }

            if (timeSheetList.size() > 0) {
                update timeSheetList;
                return timeSheetIds;
            }
            
        } catch (Exception e) {
            throw new Util.LeanException('Error : ' + e.getmessage());
        }

        return new List<Id>();
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : This method return Last Created TimeSheet for the logged user.
     Input       : None
     Output      : TimeSheet Object
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static leankor__TimeSheet__c getLastCreatedTimeSheet() {
        leankor__TimeSheet__c timeSheet;
        List<leankor__TimeSheet__c> timeSheets = [Select Id,
                                                            Name,
                                                            leankor__ApprovalHistoryStatus__c,
                                                            leankor__EndDateTime__c,
                                                            leankor__Resource__c,
                                                            leankor__StartDateTime__c
                                                        From leankor__TimeSheet__c
                                                        Where leankor__Resource__c =: UserInfo.getUserId()
                                                        With Security_Enforced
                                                        Order by CreatedDate Desc 
                                                        Limit 1];
            if(timeSheets.size() > 0){
                timeSheet = timeSheets[0];
            }
        return timeSheet;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : Clone the Time sheet and child TimeCards
     Input       : List of TimeSheet
     Output      : List of TimeSheet
     --------------------------------------------------------------------------------*/ 
    @RemoteAction
    global static List<leankor__TimeSheet__c> cloneTimeSheets(List<leankor__TimeSheet__c> timeSheets){
        if (!leankor__TimeSheet__c.sObjectType.getDescribe().isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }

        for (leankor__TimeSheet__c timeSheet : timeSheets) {
            if (String.isNotBlank(timeSheet.Id) && (Util.getSObjectName(timeSheet.Id) != 'leankor__TimeSheet__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
        }
        Savepoint sp = Database.setSavepoint();
        List<leankor__TimeSheet__c> timeSheetList = new List<leankor__TimeSheet__c>();
        List<leankor__TimeSheet__c> timeSheetListNew = new List<leankor__TimeSheet__c>();
        Map<Id, leankor__TimeSheet__c> timeSheetOldNewIdMap = new Map<Id, leankor__TimeSheet__c>();
        List<leankor__TimeCard__c> clonedTimeCards = new List<leankor__TimeCard__c>();
        List<Id> timeSheetIds = new List<Id>();

        for (leankor__TimeSheet__c timeSheet : timeSheets) {
            timeSheetIds.add(timeSheet.Id);
        }

        Map<Id, List<leankor__TimeCard__c>> timeCardMap = TimeSheet.getTimeCards(timeSheetIds);
        try {
            for (leankor__TimeSheet__c sourceTimeSheet : timeSheets) {
                leankor__TimeSheet__c tempTimeSheet = new leankor__TimeSheet__c();
                tempTimeSheet.Name = sourceTimeSheet.Name;
                tempTimeSheet.leankor__Resource__c = sourceTimeSheet.leankor__Resource__c;
                tempTimeSheet.leankor__StartDateTime__c = sourceTimeSheet.leankor__StartDateTime__c;
                tempTimeSheet.leankor__EndDateTime__c = sourceTimeSheet.leankor__EndDateTime__c;
                timeSheetListNew.add(tempTimeSheet);
            }

            insert timeSheetListNew;
            for (Integer index = 0; index < timeSheets.size(); index++) {
                timeSheetOldNewIdMap.put(timeSheets[index].Id, timeSheetListNew[index]);
            }

            for (Id oldTimeSheetId : timeCardMap.keyset()) {
                for (leankor__TimeCard__c oldTimeCard : timeCardMap.get(oldTimeSheetId)) {
                    leankor__TimeSheet__c newTimeSheet = timeSheetOldNewIdMap.get(oldTimeCard.leankor__TimeSheet__c);

                leankor__TimeCard__c clonedTimeCard = new leankor__TimeCard__c();
                    clonedTimeCard.leankor__Subject__c = oldTimeCard.leankor__Subject__c;
                    clonedTimeCard.leankor__Description__c = oldTimeCard.leankor__Description__c;
                    clonedTimeCard.leankor__Assign_a_User__c = oldTimeCard.leankor__Assign_a_User__c;
                    clonedTimeCard.leankor__Duration__c = oldTimeCard.leankor__Duration__c;
                    clonedTimeCard.leankor__Estimation__c = oldTimeCard.leankor__Estimation__c;
                    clonedTimeCard.leankor__Hours__c = oldTimeCard.leankor__Hours__c;
                    clonedTimeCard.leankor__KanbanCard__c = oldTimeCard.leankor__KanbanCard__c;
                    clonedTimeCard.leankor__LogTime__c = oldTimeCard.leankor__LogTime__c;
                    clonedTimeCard.leankor__Notes__c = oldTimeCard.leankor__Notes__c;
                    clonedTimeCard.leankor__Task__c = oldTimeCard.leankor__Task__c;
                    clonedTimeCard.leankor__TaskDueDate__c = oldTimeCard.leankor__TaskDueDate__c;
                    clonedTimeCard.leankor__AssignedTo__c = oldTimeCard.leankor__AssignedTo__c;
                    clonedTimeCard.leankor__ExpenseAccount__c = oldTimeCard.leankor__ExpenseAccount__c;
                    clonedTimeCard.leankor__ExpenseCategory__c = oldTimeCard.leankor__ExpenseCategory__c;
                    clonedTimeCard.leankor__ExpenseSubCategory__c = oldTimeCard.leankor__ExpenseSubCategory__c; 
                    clonedTimeCard.leankor__ExternalHourlyRate__c = oldTimeCard.leankor__ExternalHourlyRate__c; 
                    clonedTimeCard.leankor__TimeSheet__c = newTimeSheet.Id;
                    clonedTimeCard.leankor__Order__c = oldTimeCard.leankor__Order__c;

                    /* Date newStartDate = Date.newInstance(newTimeSheet.leankor__StartDateTime__c.year(), newTimeSheet.leankor__StartDateTime__c.month(), newTimeSheet.leankor__StartDateTime__c.day());
                    Date newEndDate = Date.newInstance(newTimeSheet.leankor__EndDateTime__c.year(), newTimeSheet.leankor__EndDateTime__c.month(), newTimeSheet.leankor__EndDateTime__c.day());
                    Date oldtimeCardDate = Date.newInstance(oldTimeCard.leankor__LogTime__c.year(), oldTimeCard.leankor__LogTime__c.month(), oldTimeCard.leankor__LogTime__c.day());
                    
                    if((oldtimeCardDate < newStartDate || oldtimeCardDate > newEndDate) && oldtimeCardDate < newStartDate){
                        clonedTimeCard.leankor__LogTime__c = newTimeSheet.leankor__StartDateTime__c; 
            }

                    if((oldtimeCardDate < newStartDate || oldtimeCardDate > newEndDate) && oldtimeCardDate > newEndDate){
                        clonedTimeCard.leankor__LogTime__c = newTimeSheet.leankor__EndDateTime__c; 
                    }*/
                    if((oldTimeCard.leankor__LogTime__c < newTimeSheet.leankor__StartDateTime__c || oldTimeCard.leankor__LogTime__c > newTimeSheet.leankor__EndDateTime__c) && oldTimeCard.leankor__LogTime__c < newTimeSheet.leankor__StartDateTime__c){
                        clonedTimeCard.leankor__LogTime__c = newTimeSheet.leankor__StartDateTime__c; 
                    }

                    if((oldTimeCard.leankor__LogTime__c < newTimeSheet.leankor__StartDateTime__c || oldTimeCard.leankor__LogTime__c > newTimeSheet.leankor__EndDateTime__c) && oldTimeCard.leankor__LogTime__c > newTimeSheet.leankor__EndDateTime__c){
                        clonedTimeCard.leankor__LogTime__c = newTimeSheet.leankor__EndDateTime__c; 
                    }

                    clonedTimeCards.add(clonedTimeCard);
                }
            }
            insert clonedTimeCards;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new Util.LeanException('Error : ' + e.getmessage());
        } 
        return timeSheetListNew;
    }

    /*-------------------------------------------------------------------------------
     Company     : Leankor
     Description : return the all timeCards based on parent TimeSheet Id.
     Input       : List of TimeSheet
     Output      : Map<Id, List<leankor__TimeCard__c>>
     --------------------------------------------------------------------------------*/ 
    @TestVisible
    private static Map<Id, List<leankor__TimeCard__c>> getTimeCards(List<Id> timeSheetIds){
        Map<Id, List<leankor__TimeCard__c>> result = new Map<Id, List<leankor__TimeCard__c>>();
        for(leankor__TimeCard__c timeCard : [Select Id,
                                                        leankor__Subject__c,
                                                        leankor__Description__c,
                                                        leankor__Assign_a_User__c,
                                                        leankor__Assign_a_User__r.Name,
                                                        leankor__Duration__c,
                                                        leankor__Estimation__c,
                                                        leankor__Hours__c,
                                                        leankor__KanbanCard__c,
                                                        leankor__LogTime__c,
                                                        leankor__Notes__c,
                                                        leankor__Task__c,
                                                        OwnerId,
                                                        leankor__TaskDueDate__c,
                                                        leankor__AssignedTo__c,
                                                        leankor__ExpenseAccount__c,
                                                        leankor__ExpenseCategory__c,
                                                        leankor__ExpenseSubCategory__c,
                                                        leankor__ExternalHourlyRate__c,
                                                        leankor__TimeSheet__c,
                                                        leankor__Order__c 
                                                    From leankor__TimeCard__c
                                                    Where leankor__TimeSheet__c In: timeSheetIds
                                                    With Security_Enforced]){
            List <leankor__TimeCard__c> timeCards = result.containsKey(timeCard.leankor__TimeSheet__c) ? result.get(timeCard.leankor__TimeSheet__c) : new List <leankor__TimeCard__c>();
            timeCards.add(timeCard);
            result.put(timeCard.leankor__TimeSheet__c, timeCards);
        }
        return result;
    }

    /*---------------------------------------------------------------------------------------------------------
     Description : Read TimeSheet records that are submitted for approvals and assigned to a user
     Input       : User Id, List of approval process status (Started, Pending, Approved, etc.)
     Output      : List of TimeSheet records
    ----------------------------------------------------------------------------------------------------------*/ 
    @RemoteAction 
    global static List<leankor__TimeSheet__c> readTimeSheetsProcessApprovals(final Id actorId, final List<String> approvalStatus) {
        return [Select Id,
                        Name, 
                        leankor__StartDateTime__c, 
                        leankor__EndDateTime__c, 
                        leankor__Resource__c, 
                        leankor__ApprovalHistoryStatus__c,
                        leankor__Resource__r.Name
                    From leankor__TimeSheet__c
                    Where Id In :readTimeSheetsProcessInstances(actorId, approvalStatus)
                    With Security_Enforced];
    }
 
 
    /*---------------------------------------------------------------------------------------------------------
     Description : Read ProcessInstance records that are assigned to a user
     Input       : User Id of responsible user for approving TimeSheet records, List of approval process status (Started, Pending, Approved, etc.)
     Output      : List of TimeSheet Ids
    ----------------------------------------------------------------------------------------------------------*/    
    @TestVisible
    private static Set<Id> readTimeSheetsProcessInstances(Id actorId, final List<String> approvalStatus) {
        Set<Id> targetObjectIds = new Set<Id>();
        String tableEnumORId = 'leankor__TimeSheet__c';
        for (ProcessInstance processInstance : [Select Id,
                                                        TargetObjectId,
                                                        (Select Id
                                                            From WorkItems 
                                                            Where ActorId = :actorId)
                                                    From ProcessInstance
                                                    Where Status In :approvalStatus
                                                        And ProcessDefinition.TableEnumOrId =: tableEnumORId
                                                        And ProcessDefinition.Type = 'Approval'
                                                        And ProcessDefinition.State = 'Active'
                                                    With Security_Enforced]) {
        
            if (!processInstance.WorkItems.isEmpty()) {
                targetObjectIds.add(processInstance.TargetObjectId);
            }
        }
 
        return targetObjectIds;
    }


    /*---------------------------------------------------------------------------------------------------------
     Description : Read Filter records
     Input       : filter Id
     Output      : List of Filter records
    ----------------------------------------------------------------------------------------------------------*/ 
    @RemoteAction 
    global static List<leankor__Filter__c> getFilterRecord(Id timeSheetId) {
        if (String.isNotBlank(timeSheetId) && (Util.getSObjectName(timeSheetId) != 'leankor__TimeSheet__c')) {
            throw new Util.LeanException('Error: Invalid input');
        }
        return [Select Id,
                        OwnerId,
                        leankor__BoardURL__c,
                        leankor__FeatureData__c,
                        leankor__User__c
                    From leankor__Filter__c
                    Where leankor__BoardURL__c =: timeSheetId
						And leankor__User__c =: UserInfo.getUserId()
                    With Security_Enforced];
    }
    /*---------------------------------------------------------------------------------------------------------
     Description : upsert Filter records
     Input       : filter Data
     Output      : List of Filter records
    ----------------------------------------------------------------------------------------------------------*/ 
    @RemoteAction 
    global static List<leankor__Filter__c> upsertFilterRecords(List<leankor__Filter__c> filterRecord) {
        for(leankor__Filter__c filter : filterRecord){
            if (String.isNotBlank(filter.Id) && (Util.getSObjectName(filter.Id) != 'leankor__Filter__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        FilterBehaviour filterBehaviour = new FilterBehaviour();
        if (!filterBehaviour.isUpdateable() ||
            !filterBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        try {
            upsert filterRecord;
            return filterRecord;
        } catch (DmlException e) {
            throw new Util.LeanException('Exception Error: ' + e.getMessage());
        }

    }

    /*---------------------------------------------------------------------------------------------------------
     Description : delete Filter records
     Input       : filter Data
     Output      : List of Filter records
    ----------------------------------------------------------------------------------------------------------*/ 
    
    @RemoteAction 
    global static Boolean deleteFilterRecords(List<leankor__Filter__c> filterRecords) {
        /*
        for (leankor__Filter__c filter : filterRecords) {
            if (String.isNotBlank(filter.Id) && (Util.getSObjectName(filter.Id) != 'leankor__Filter__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
        FilterBehaviour filterBehaviour = new FilterBehaviour();
        if (!filterBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        try {
            for (leankor__Filter__c filter : filterRecords) {
                filter.leankor__ValueStream__c = null;
                filter.leankor__User__c = null;
            }
            update filterRecords;
            return true;
        } catch (DmlException e) {
            throw new Util.LeanException('Exception Error: ' + e.getMessage());
        }
        */
        return true;
    }

}