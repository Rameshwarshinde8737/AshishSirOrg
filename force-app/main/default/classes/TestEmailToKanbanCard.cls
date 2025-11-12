@IsTest
public class TestEmailToKanbanCard 
{
    static testMethod void TestEmailToKanbanCard() 
    {
    // Create a new email, envelope object and Attachment
   Messaging.InboundEmail email = new Messaging.InboundEmail();
   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
   Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();

   email.subject = 'test';
   env.fromAddress = 'user@user.com';

   // set the body of the attachment
   inAtt.body = blob.valueOf('test');
   inAtt.fileName = 'my attachment name';
   inAtt.mimeTypeSubType = 'plain/txt';

   email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt }; 

   // call the class and test it with the data in the testMethod
    EmailToKanbanCard em = new EmailToKanbanCard();
    Messaging.InboundEmailResult result=em.handleInboundEmail(email, env );
    System.assertEquals( result.success  ,true); 
        }
}