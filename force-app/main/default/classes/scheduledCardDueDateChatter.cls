/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: scheduledCardDueDateChatter.cls
 * CLASS: scheduledCardDueDateChatter   
 */
Global class scheduledCardDueDateChatter implements Schedulable {
   Global void execute(SchedulableContext sc) {
      CardDueDateChatter b = new CardDueDateChatter(); 
      database.executebatch(b);
   }
}