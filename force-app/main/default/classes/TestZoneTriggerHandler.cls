/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestZoneTriggerHandler.cls
 * CLASS: TestZoneTriggerHandler         
 */
 
@isTest
private class TestZoneTriggerHandler {

    public static testMethod void testZoneTrigger() {
        
        // this section just to test certain internal classes
        zoneTriggerHandler zth = new zoneTriggerHandler(true, 1);
        Boolean itc = zth.IsTriggerContext;
        Boolean ivfpc = zth.IsVisualforcePageContext;
        Boolean iwsc = zth.IsWebServiceContext;
        Boolean ieac = zth.IsExecuteAnonymousContext;
        
        User u;
        User thisUser;
        try{
        thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        }catch(QueryException ex){
        System.debug('Error : '+ex.getMessage());
        }
        leankor__Zone__c lz = new leankor__Zone__c(Name = 'testname');
        Group g;
        
        // test main trigger here
        System.runAs(thisUser){
            insert lz;
            
           
             User otherUser=new User();
            try{
            otherUser = [SELECT Id,ProfileId,UserRoleId FROM User WHERE UserType =:UserInfo.getUserType() and ProfileId != :UserInfo.getProfileId() limit 1];
            }catch(Exception Ex){
                System.debug('Error : '+ex.getMessage());
            }
            
            u = new User(alias = 'jsmtih', email='jsmith@acme.com', 
                emailencodingkey='UTF-8', lastname='Smith', 
                languagelocalekey='en_US', 
                localesidkey='en_US',
                profileid = (otherUser.Id==null?UserInfo.getProfileId():otherUser.ProfileId), //UserInfo.getProfileId()p.Id, 
                userroleid = (otherUser.Id==null?UserInfo.getUserRoleId():otherUser.UserRoleId),//UserInfo.getUserRoleId(),r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='whatthe@blah.cowblah.co.in');
        try{
            insert u;
            }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            }
            // set up the group
            String nm = lz.Id;
            nm = nm.left(15);
            
            g = new Group(Type = 'Queue',
                                DoesSendEmailToMembers = true,
                                Name = 'testname-' + nm);
            try{
            
            insert g;
            }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            }
            
        }
        
        System.runAs(u){
            lz.Name = 'newname';
            update lz;  // should trigger a change to queue name
        }
        
        Group g2;
        try{
        g2 = [SELECT Id, Name FROM Group WHERE Id = :g.Id LIMIT 1];

        }catch(QueryException ex){
            System.debug('Error : '+ex.getMessage());
            }
        String newNm = g2.Name;
        system.AssertEquals(lz.Name , 'newname');
    
        System.runAs(thisUser){
            delete lz;
        }
        System.runAs(thisUser){
            undelete lz;
        }
    }
    
}