/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: scheduledScheduleRecord .cls
 * CLASS: scheduledScheduleRecord 
 */
Global with sharing class scheduledModeRecord implements Schedulable {
    Global void execute(SchedulableContext sc) {
            CreateScheduleModeRecord sch = new  CreateScheduleModeRecord (); 
        database.executebatch(sch);
    }
}