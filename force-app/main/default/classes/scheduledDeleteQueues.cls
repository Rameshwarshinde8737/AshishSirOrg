/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: scheduledDeleteQueues.cls
 * CLASS: scheduledDeleteQueues    
 */

Global with sharing class scheduledDeleteQueues implements Schedulable {
   Global void execute(SchedulableContext sc) {
       DeleteQueuesandGroup s = new DeleteQueuesandGroup (); 
       database.executebatch(s);  
   }
}