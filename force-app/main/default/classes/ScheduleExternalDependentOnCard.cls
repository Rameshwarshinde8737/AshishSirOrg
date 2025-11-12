/**
 * Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 * CLASS: ScheduleExternalDependentOnCard
 */
Global with sharing class ScheduleExternalDependentOnCard implements Schedulable {
    Global void execute(SchedulableContext sc) {
            //Execute batch apex for SetExternallyDependentOnCard 
            SetExternallyDependentOnCard SEDOC = new SetExternallyDependentOnCard();
            database.executebatch(SEDOC,200);
    }
}