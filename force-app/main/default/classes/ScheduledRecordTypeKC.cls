/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * CLASS: ScheduledKanbanCardRecord
 */
Global with sharing class ScheduledRecordTypeKC implements Schedulable {
    Global void execute(SchedulableContext sc) {
           
            UpdateRecordTypeKC URTC = new UpdateRecordTypeKC();
            database.executebatch(URTC);
    }
}