/**
* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
* FILE:  EmailToKanbanCard.cls
* CLASS: EmailToKanbanCard
* USAGE: Manages to Create Card from Inbound Emails.
*/

Global with sharing class EmailToKanbanCard implements Messaging.InboundEmailHandler {
    Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.Inboundenvelope envelope) {
        return new Messaging.InboundEmailResult();
    } 
}