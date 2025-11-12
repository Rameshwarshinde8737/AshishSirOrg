/**
 * Company : Leankor
 * FILE : CreateScheduleModeRecordsQueueable.cls
 * CLASS : CreateScheduleModeRecordsQueueable
 * USAGE : Create ScheduleMode Records for milestones.
 */
public with sharing class CreateScheduleModeRecordsQueueable implements Queueable  {
    // Default Empty constructor for Queueable Class.
    public CreateScheduleModeRecordsQueueable() {}

    // Execute method for creating ScheduleMode Records for milestone who doesn't have Schedulemode Record.
    public void execute(QueueableContext context) {
        ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
        if (!scheduleModeBehavior.isCreateable()) {
            System.abortJob(context.getJobId());
        }
        List<leankor__KanbanCard__c> milestoneCards =  [Select Id,
                                                            Name
                                                        From leankor__kanbanCard__c
                                                        Where Id Not In (Select leankor__KanbanCard__c 
                                                                            From leankor__ScheduleMode__c)
                                                            And RecordTypeId = :Schema.Sobjecttype.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId() 
                                                            And leankor__IsRecordDeleted__c = false
                                                        With Security_Enforced
                                                        Limit 10000];
        if(milestoneCards.size() > 0 ){
            List<leankor__ScheduleMode__c> scheduleModes = new List<leankor__ScheduleMode__c>();
            for(leankor__KanbanCard__c milestoneCard : milestoneCards){
                scheduleModes.add(new leankor__ScheduleMode__c(
                                    leankor__EffortActual__c = 0.0,
                                    leankor__EffortUnits__c = 'Days',
                                    leankor__KanbanCard__c = milestoneCard.Id,
                                    leankor__ManuallyScheduled__c = false,
                                    leankor__Mode__c = 'Normal'
                                ) );
            }
            insert scheduleModes;
            // Query number of remaining records for milestone.
            Integer remainingMileStones =  [Select Count()
                                                    From leankor__kanbanCard__c
                                                    Where Id Not In (Select leankor__KanbanCard__c
                                                                        From leankor__ScheduleMode__c)
                                                        And RecordTypeId = :Schema.Sobjecttype.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId() 
                                                        And leankor__IsRecordDeleted__c = false
                                                    With Security_Enforced
                                                    Limit 10000];
            // Chaining Queueables for Remaining Milestone records.
            if(remainingMileStones > 0){
                System.enqueueJob(new CreateScheduleModeRecordsQueueable());
            }
        }            
    }
}