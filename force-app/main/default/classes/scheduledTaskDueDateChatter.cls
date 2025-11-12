/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: scheduledTaskDueDateChatter.cls
 * CLASS: scheduledTaskDueDateChatter    
 */

Global class scheduledTaskDueDateChatter implements Schedulable {
   Global void execute(SchedulableContext sc) {
      TaskDueDateChatter t = new TaskDueDateChatter (); 
      database.executebatch(t);
   }
}