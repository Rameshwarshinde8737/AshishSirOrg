/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: TestCaseTriggerHandler.cls
 * CLASS: TestCaseTriggerHandler
*/

@isTest
private class TestCaseTriggerHandler {
     /*
        Date :12/06/19
     */
    @testSetup 
    static void testData() {
    		List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 2);
        	List<leankor__ProjectRoom__c> projectList = leankor.TestDataFactory.createProjects('Test Project', folderList,2);     		   	          	          	  	
   	}
    public static testMethod void testCaseTrigger() {

       leankor.TestDataFactory.createLeanConstants();

        //Make sure LeanConstants is setup properly
        leankor__LeanConstants__c cont = leankor__LeanConstants__c.getInstance();
        System.assertEquals(true, cont.leankor__DisableKanbanCardTrigger__c);

        User u;
        User thisUser;
        try{
            thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() limit 1];        
        }catch(QueryException ex){
            System.debug('Error : '+ex.getMessage());
        }

        Group g;
        Case c=new Case(priority='High',origin='Email',Status='New',Type = 'others');
       //Date :12/06/19
        List<leankor__ProjectRoom__c> projectList  =[select id from leankor__ProjectRoom__c];       
        // test main trigger here
        System.runAs(thisUser){
            leankor__ValueStream__c vs = new leankor__ValueStream__c(Name = 'myVS',leankor__CaseSynchronization__c=false,leankor__CaseType__c='New',leankor__CaseRecordType__c='CaseRecordType',leankor__BoardType__c ='Kanban Board',leankor__ProjectRoom__c=projectList[0].id);
            insert vs;
            leankor__Zone__C zone=new leankor__zone__c(Name ='TestZone',leankor__guid__c=TestDataFactory.createguid(),leankor__ValueStream__c=vs.Id,leankor__caseStatus__c='New');
            insert zone;
            leankor__Zone__C zone1=new leankor__zone__c(Name ='TestZone1',leankor__guid__c=TestDataFactory.createguid(),leankor__ValueStream__c=vs.Id,leankor__caseStatus__c='Working');
            insert zone1;
            leankor__ValueStream__c vs1 = new leankor__ValueStream__c(Name = 'myVS1',leankor__CaseSynchronization__c=false,leankor__CaseType__c='None',leankor__CaseRecordType__c='None', leankor__BoardType__c ='Whiteboard',leankor__ProjectRoom__c=projectList[0].id);
            insert vs1;
            leankor__Zone__C zone2=new leankor__zone__c(Name ='TestZone12',leankor__guid__c=TestDataFactory.createguid(),leankor__ValueStream__c=vs1.Id,leankor__caseStatus__c='Default');
            insert zone2;
            //Date :12/06/19
            leankor__MasterContainer__c mastercontainer=new leankor__MasterContainer__c();
   	          		mastercontainer.Name='Backlog';
   	          		mastercontainer.leankor__GUID__c=TestDataFactory.createguid();
   	          		mastercontainer.leankor__Type__c='BackLog';
   	         insert mastercontainer;	
            leankor__Swimlane__c swimlane =new leankor__Swimlane__c(leankor__MasterContainer__c= mastercontainer.id,leankor__GUID__c=TestDatafactory.createguid());   	        	   	       	
   	        insert 	swimlane;   	        	
            leankor__Zone__C zone3 =new leankor__Zone__C(Name ='Tes13',leankor__guid__c=TestDataFactory.createguid(),leankor__caseStatus__c='none',leankor__ValueStream__c=vs.id,leankor__Swimlane__c=swimlane.id);
            insert zone3;
             leankor__Zone__C zone4 =new leankor__Zone__C(Name ='Tes14',leankor__guid__c=TestDataFactory.createguid(),leankor__caseStatus__c='none',leankor__ValueStream__c=vs.id);
            insert zone4;          
            //Default template for the case syncronization
            leankor__KanbanCardTemplate__c template= new leankor__KanbanCardTemplate__c(
                Name = 'Default Temp',
                leankor__Title__c ='Default Temp',
                leankor__Color__c = '#EEERRR',
                leankor__Height__c = 150,
                leankor__Width__c = 200,
                leankor__JSONData__c = '{}',
                leankor__JSONDefinition__c = '{}',
                leankor__ValueStream__c = vs.Id
            );
            insert template;
            realtimeController.ProjectBoard prj=new realtimeController.ProjectBoard();
            prj.id=vs.Id;
            prj.caseType='All';
            prj.caseSynchronization=true;
            prj.caseRecordType='All';
            prj.caseCardCategory = template.Id; 
            prj.boardType ='Kanban Board';
            leankor__ValueStream__c vsUpdate=realtimeController.updateProjectBoard(prj);
            System.assert(vsUpdate != null);
            prj.id=vs1.Id;
            leankor__ValueStream__c vsUpdate1=realtimeController.updateProjectBoard(prj);
            System.assert(vsUpdate1 != null);
            try{
                insert c;
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
            }
            
            User otherUser=new User();
            try{
                otherUser = [SELECT Id,ProfileId,UserRoleId FROM User WHERE UserType = :UserInfo.getUserType()  and ProfileId != :UserInfo.getProfileId() limit 1];
            }catch(Exception Ex){
                System.debug('Error : '+ex.getMessage());
            }
            u = new User(alias = 'jsmtih', email='jsmith@acme.com', 
                emailencodingkey='UTF-8', lastname='Smith', 
                languagelocalekey='en_US', 
                localesidkey='en_US', 
                profileid = (otherUser.Id==null?UserInfo.getProfileId():otherUser.ProfileId),  //UserInfo.getProfileId(),p.Id,
                userroleid =(otherUser.Id==null?UserInfo.getUserRoleId():otherUser.UserRoleId), //UserInfo.getUserRoleId(), r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='whattheuser@blah.cowblah.co.in');
            try{
                insert u;
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
            }
                        
            PermissionSetAssignment PSA=new PermissionSetAssignment();
            try{
                PSA= [SELECT AssigneeId,Id,PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name Like '%Lean%' limit 1];
            }catch(Exception ex){
                System.debug('Error : '+ex.getMessage());
            }
        
            PermissionSetAssignment newPSA=new PermissionSetAssignment();
            newPSA.AssigneeId=u.Id;
            newPSA.PermissionSetId= PSA.PermissionSetId;
            try{
                insert newPSA;
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
            }
        }
        System.runAs(u){
            c.Status= 'Working';
            try {
                update c;
            } catch (Exception ex) {
                System.debug('Error : '+ex.getMessage());
            }
              
        }
        
        System.runAs(thisUser){
            try {
                delete c;
            } catch (Exception ex) {
                System.debug('Error : '+ex.getMessage());
            }
        }
       //Date : 12/06/19
       /* System.runAs(thisUser){
            List<Case> cases=new List<Case>();
            Integer i=0;
            for(i=0;i<5;i++){
                Case bc=new Case(priority='High',origin='Email',Status='New',Type = 'others');
                cases.add(bc);
            }
              
            insert cases;

            for(Case bc: cases){
                bc.Status ='Working';
            } 
           //Date : 12/06/19
            update cases;
            delete cases;
            undelete cases;
            delete cases;
        }*/
        
    }
}