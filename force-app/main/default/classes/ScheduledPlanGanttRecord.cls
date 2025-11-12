/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * CLASS: ScheduledPlanGanttRecord 
 */
Global with sharing class ScheduledPlanGanttRecord implements Schedulable 
{
    Global void execute(SchedulableContext sc) 
    {
        CreateUberBoard CUB = new CreateUberBoard();
        database.executebatch(CUB);
    }
}