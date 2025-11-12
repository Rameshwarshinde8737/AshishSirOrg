/**
 * This class used to perform CRUD opeation on task in without sharing environment.
 */
public without sharing class OpenTaskRestriction {
    
    public static List<Task> updateTask(List<Task> taskList) {   				    		  				
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        try {
            DataBase.update(taskList);
        } catch(DmlException e) {
            System.debug('Error: '+e.getMessage());
           // return null;
           //25/04/2023 : We are Throwing Exception
           throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        return taskList;
    }


    public static void deleteTask(List<Task> taskList) {   				    		  		  
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isDeletable()
        ) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        try {
            DataBase.delete(taskList);
        } catch(DmlException e) {
            System.debug(e.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
    }  

    // Read task on the Kanban Card 
    public static List<Task> readTask(List<String> kanbanIds) {
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!taskBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        return [SELECT 
                    Id, 
                    Priority, 
                    OwnerID, 
                    Subject, 
                    Status, 
                    ActivityDate, 
                    WhatID, 
                    Description, 
                    CreatedDate, 
                    Owner.Name 
                FROM Task
                WHERE WhatId IN: kanbanIds 
                    AND IsDeleted = false 
                LIMIT 49999
                    ALL ROWS];
    }

    public static List<Task> readTask(List<Task> tasks) {
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!taskBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        return [SELECT 
                    Id, 
                    Priority, 
                    OwnerID, 
                    Subject, 
                    Status, 
                    ActivityDate, 
                    WhatID, 
                    Description, 
                    CreatedDate, 
                    Owner.Name 
                FROM Task
                WHERE Id in: tasks 
                    AND IsDeleted = false
                    LIMIT 9999 
                    ALL ROWS];
    }

    public static List<Task> readTask(String taskId) {
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!taskBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        return [SELECT 
                    Id, 
                    Priority, 
                    OwnerID, 
                    Subject, 
                    Status, 
                    ActivityDate, 
                    WhatID, 
                    Description, 
                    CreatedDate, 
                    Owner.Name 
                FROM Task
                WHERE Id =: taskId 
                    AND IsDeleted = false
                    LIMIT 1 
                    ALL ROWS];
    }

    public static List<Task> readTask(List<String> taskIds, String cardId) {
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!taskBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        return [SELECT 
                    Id
                FROM Task
                WHERE WhatId =: cardId
                	  AND Id in: taskIds 
                      AND IsDeleted = false 
                LIMIT 49999
                    ALL ROWS];
    }

    public static Map<Id, List<Task>> readKanbanTask(List<leankor__KanbanCard__c> kanbanCards) {
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (!taskBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        Map<Id, List<Task>> taskMap = new Map<Id, List<Task>>();
        
        for(Task tsk: [SELECT 
                            Id, 
                            WhatId, 
                            ActivityDate 
                        FROM Task 
                        WHERE WhatID IN: kanbanCards 
                            AND What.Type = 'leankor__KanbanCard__c' 
                            AND IsDeleted = false 
                        LIMIT 49999 
                            ALL ROWS]) {
            List<Task> taskList = taskMap.containsKey(tsk.WhatId) ? taskMap.get(tsk.WhatId) : new List<Task>();
            taskList.add(tsk);  
            taskMap.put(tsk.WhatId, taskList);
        }

        return taskMap;
    }

    public static List<FeedItem> getFileFeedItem(List<String> parentIds) {
        //Check CRUD / FLC behavior
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (!feedItemBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<FeedItem> feeds = new List<FeedItem>();

        for (FeedItem feed : [SELECT 
                    Id,
                    LastModifiedDate,
                    LinkUrl,
                    ParentId,
                    RelatedRecordId,
                    Status,
                    SystemModstamp,
                    Title,
                    Type,
                    (SELECT // FeedAttachments subquery
                            FeedEntityId, 
                            Id, 
                            RecordId, 
                            Title, 
                            Type, 
                            Value 
                        FROM FeedAttachments 
                        WHERE RecordId != null),
                    (SELECT // FeedComments subquery
                            CreatedDate, 
                            FeedItemId, 
                            Id, 
                            RelatedRecordId, 
                            ParentId, 
                            Status, 
                            SystemModstamp 
                        FROM FeedComments)							
                FROM FeedItem 
                WHERE //Type != 'TrackedChange' AND 
                    ParentId IN: parentIds]) {
            
            if (feed.Type != 'TrackedChange') {
                feeds.add(feed);
            }
        }

        return feeds;
    }

    
    public static List<Database.SaveResult> insertRealTimeTrackers(List<leankor__RealTimeTracker__c> realtimeTrackers){
        //Check CRUD / FLC behavior
        RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior(); 
        if (
            !realtimeTrackerBehavior.isAccessible() ||
            !realtimeTrackerBehavior.isCreateable()
        ) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<Database.SaveResult> result = new List<Database.SaveResult>();
    	try {
            result = Database.insert(realtimeTrackers, true);
    		//return Database.insert(realtimeTrackers, true);
    	} catch (DmlException e) {
            System.debug('ERROR:' + e.getMessage());
            //throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        return result;
    }

    // This method can be used to update the task depends upon the old and new values on the card
    public static void updateTask(List<leankor__KanbanCard__c> kanbanCards,  Map<Id, leankor__KanbanCard__c> oldKanbanMap) {
        //Check CRUD / FLC behavior
        TaskBehaviour taskBehaviour = new TaskBehaviour();
        if (
            !taskBehaviour.isAccessible() ||
            !taskBehaviour.isUpdateable()
        ) {
            System.debug('Error: No access to update records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        List<Task> tasks = new List<Task>();
        Map<Id,Boolean> vsMap = new Map<Id,Boolean>();
        Map<Id, leankor.Util.WorkWeek> workWeekMap = new Map<Id, leankor.Util.WorkWeek>();
        Map<Id, List<Task>> taskMap = leankor.OpenTaskRestriction.readKanbanTask(kanbanCards);

        Map<Id, Set<String>> weekDaysCard = new Map<Id, Set<String>>();
        for (leankor__KanbanCard__c kanban : kanbanCards) {
            vsMap.put(kanban.leankor__Valuestream__c, kanban.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c);
            
            if((KanbanController.isCalledFromMultipleAPI == true || realTimeController.updateTaskDatesWeekCalendar == true ) && kanban.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c){
                Set<String> weekDays = new Set<String>();
                weekDays.add(kanban.leankor__Monday__c == false ? 'Mon' : 'false');
                weekDays.add(kanban.leankor__Tuesday__c == false ? 'Tue' : 'false');
                weekDays.add(kanban.leankor__Wednesday__c == false ? 'Wed' : 'false');
                weekDays.add(kanban.leankor__Thursday__c == false ? 'Thu' : 'false');
                weekDays.add(kanban.leankor__Friday__c == false ? 'Fri' : 'false');
                weekDays.add(kanban.leankor__Saturday__c == false ? 'Sat' : 'false');
                weekDays.add(kanban.leankor__Sunday__c == false ? 'Sun' : 'false');
                weekDaysCard.put(kanban.Id, weekDays);
        }
        }

        // Create the workweek instance 
        Map<Id, List<leankor__ProjectScheduleBlackout__c>> blackoutMap = leankor.RealTimeControllerHelper.getBlackOutRecords(vsMap.keySet());
        for (Id vs : vsMap.keySet()) {
            leankor.Util.WorkWeek work = new leankor.Util.WorkWeek(vsMap.get(vs) ? 7: 5, blackoutMap.get(vs));
            workWeekMap.put(vs, work);
        }

        leankor__KanbanCard__c oldKanban;
        for (leankor__Kanbancard__c kanban: kanbanCards) {
            // Update the task dates according to the card.
            if (taskMap.containsKey(kanban.Id) && taskMap.get(kanban.ID).size() > 0 && oldKanbanMap.containsKey(kanban.Id)) { 
                util.weekDays = weekDaysCard.containsKey(kanban.Id) ? weekDaysCard.get(kanban.Id) : new Set<String>();
                // Get the old values on the card
                oldKanban = oldKanbanMap.get(kanban.Id);
                
                for (Task tsk: taskMap.get(kanban.ID)) {	
                    if ((kanban.leankor__StartDate__c != oldKanban.leankor__StartDate__c) && (kanban.leankor__DueDate__c != oldKanban.leankor__DueDate__c)) {
                        Integer diff = oldKanban.leankor__StartDate__c.daysBetween(kanban.leankor__StartDate__c);
                        tsk.ActivityDate = tsk.ActivityDate + diff;
                    }
                    if (kanban.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c && Util.weekDays.size() > 1) {
                        DateTime taskDateTime = workWeekMap.get(kanban.leankor__Valuestream__c).getNextWorkingDay(DateTime.newInstance(tsk.ActivityDate.year(), tsk.ActivityDate.month(), tsk.ActivityDate.day(), 1, 1, 1));
                        tsk.ActivityDate = taskDateTime.date();
                    }

                    if (tsk.ActivityDate > kanban.leankor__DueDate__c && kanban.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                        tsk.ActivityDate = kanban.leankor__DueDate__c;
                    } else if (tsk.ActivityDate < kanban.leankor__StartDate__c && kanban.leankor__Valuestream__r.leankor__TaskDatecheck__c) {
                        tsk.ActivityDate = kanban.leankor__StartDate__c;
                    }

                    if (!kanban.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c) {
                    tsk.ActivityDate = workWeekMap.get(kanban.leankor__Valuestream__c).getNextWorkingDay(tsk.ActivityDate).dateGmt();
                    }
                    
                    tasks.add(tsk);
                }
            }
        }
       
        // Update the Task
        updateTask(tasks);
    }
}