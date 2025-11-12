/**
 * Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 * CLASS: SchedulePercentCompletedOnRA
 */
Global with sharing class SchedulePercentCompletedOnRA implements Schedulable {
    Global void execute(SchedulableContext sc) {
            //Execute batch apex for SetExternallyDependentOnCard 
            SetPercentCompletedOnRA SPCOA = new SetPercentCompletedOnRA();
            database.executebatch(SPCOA,200);
    }
}