/**
 * Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 * FILE: SchedulePurgeSoftDeletedRecords.cls
 * CLASS: SchedulePurgeSoftDeletedRecords
 */
global with sharing class SchedulePurgeSoftDeletedRecords implements Schedulable{

   Global void execute(SchedulableContext sc) {    
      PurgeSoftDeletedRecords PSDR = new PurgeSoftDeletedRecords(); 
      database.executebatch(PSDR,1);
   }

}