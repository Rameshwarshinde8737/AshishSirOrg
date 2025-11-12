/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: scheduledProjectBoardStats.cls
 * CLASS: scheduledProjectBoardStats    
 */

global with sharing class scheduledProjectBoardStats implements Schedulable {
   global void execute(SchedulableContext sc) {
       ProjectBoardStatistics s = new ProjectBoardStatistics (); 
       database.executebatch(s,10);  
   }
}