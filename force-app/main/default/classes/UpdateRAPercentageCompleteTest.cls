@isTest
global class UpdateRAPercentageCompleteTest{
     public testMethod static void testBatch()
     {
	        //creating users
	        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
	        User u1 = new User(Alias =  'Sachin', 
	                                Email =  'Sachin' + '@leankor.com',
	                                EmailEncodingKey = 'UTF-8', 
	                                LastName = 'Ten', 
	                                LanguageLocaleKey = 'en_US',
	                                LocaleSidKey = 'en_US', 
	                                ProfileId = p.Id,
	                                TimeZoneSidKey = 'America/Los_Angeles', 
	                                UserName = 'Sachin' + '@leankor.com.test');
	        User u2 = new User(Alias =  'Sachin1', 
	                                Email = 'Sachin1' + '@leankor.com',
	                                EmailEncodingKey = 'UTF-8', 
	                                LastName = 'Ten', 
	                                LanguageLocaleKey = 'en_US',
	                                LocaleSidKey = 'en_US', 
	                                ProfileId = p.Id,
	                                TimeZoneSidKey = 'America/Los_Angeles', 
	                                UserName = 'Sachin1' + '@leankor.com.test');
	       User u3 = new User(Alias =  'Sachin2', 
	                                Email = 'Sachin2' + '@leankor.com',
	                                EmailEncodingKey = 'UTF-8', 
	                                LastName = 'Ten', 
	                                LanguageLocaleKey = 'en_US',
	                                LocaleSidKey = 'en_US', 
	                                ProfileId = p.Id,
	                                TimeZoneSidKey = 'America/Los_Angeles', 
	                                UserName = 'Sachin2' + '@leankor.com.test');
	        list<user> u = new  list<user>();
	        u.add(u1);
	        u.add(u2);
	        u.add(u3);
	        insert u;
	        
	        leankor__Portfolio__c folder = new leankor__Portfolio__c(Name = 'folderName');
	        insert folder;
	        leankor__ProjectRoom__c project = new leankor__ProjectRoom__c(Name ='projectName' , leankor__Portfolio__c = folder.Id);
	        insert project; 
	        leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='Kanban',leankor__BoardType__c='UberBoard',leankor__ProjectRoom__c = project.ID);
	        insert vStream;
	        	        
	        List<leankor__KanbanCard__c> activitylist = new List<leankor__KanbanCard__c>();               
            //creating activities
            for(integer i=0;i<10;i++){
             leankor__KanbanCard__c activity = new leankor__KanbanCard__c();
                      activity.name = 'Activity'+i;
                      activity.leankor__ValueStream__c  = vStream.Id;
                      activity.leankor__GUID__c = system.now().getTime()+''+i;               
                      activity.leankor__StartDateTime__c = system.now();
                      activity.leankor__DueDateTime__c = system.now();                 
                      activity.leankor__PercentComplete2__c=50.00;
                      activitylist.add(activity);
            }       
	        
	        insert activitylist ;
	        
	        //creating activity's ResourceAssignments and each activity having three resources 
	        list<leankor__ResourceAssignment__c> resourceAssignmentList = new list<leankor__ResourceAssignment__c>(); 
	        List<leankor__KanbanCard__c> updateHarveyStatus = new List<leankor__KanbanCard__c>();
	        for(leankor__KanbanCard__c  kanbanCardRecord :activitylist){
	            leankor__ResourceAssignment__c Rsa1 = new leankor__ResourceAssignment__c(leankor__KanbanCard__c = kanbanCardRecord.Id,leankor__AssignedTo__c = u[0].Id,leankor__PercentAllocation__c =10.00,leankor__PercentCompleted__c=25.00);
	            leankor__ResourceAssignment__c Rsa2 = new leankor__ResourceAssignment__c(leankor__KanbanCard__c = kanbanCardRecord.Id,leankor__AssignedTo__c = u[1].Id,leankor__PercentAllocation__c =30.00,leankor__PercentCompleted__c=30.00);  
	            leankor__ResourceAssignment__c Rsa3 = new leankor__ResourceAssignment__c(leankor__KanbanCard__c = kanbanCardRecord.Id,leankor__AssignedTo__c = u[2].Id,leankor__PercentAllocation__c =60.00,leankor__PercentCompleted__c=50.00);
	            
	            resourceAssignmentList.add(Rsa1);
	            resourceAssignmentList.add(Rsa2);
	            resourceAssignmentList.add(Rsa3); 
	            
	            kanbanCardRecord.leankor__PercentComplete2__c = Rsa1.leankor__PercentCompleted__c*(Rsa1.leankor__PercentAllocation__c/100) + Rsa2.leankor__PercentCompleted__c*(Rsa2.leankor__PercentAllocation__c/100) +Rsa3.leankor__PercentCompleted__c*(Rsa3.leankor__PercentAllocation__c/100);     
	            kanbanCardRecord.leankor__PercentComplete2__c = kanbanCardRecord.leankor__PercentComplete2__c.round().intValue();
	            updateHarveyStatus.add(kanbanCardRecord);   
	        }   
	        insert resourceAssignmentList ;
	        
	        
	        Test.StartTest();
	         
	        update updateHarveyStatus ;
	        //updating wrong data for testing
	        list<leankor__ResourceAssignment__c> resourceAssignmentSecondList = new list<leankor__ResourceAssignment__c>(); 
	        for(leankor__ResourceAssignment__c  resourceAssignmentRecord :resourceAssignmentList){
	            resourceAssignmentRecord.leankor__PercentCompleted__c=40.00;                   
	            resourceAssignmentSecondList.add(resourceAssignmentRecord);
	        }
	        update resourceAssignmentSecondList;
	        //this batch will calculate correct data and updtae
	        leankor.UpdateRAPercentageComplete batch = new leankor.UpdateRAPercentageComplete();
	        Database.executeBatch(Batch,2000);
	        
	        Test.StopTest();    
	        for(leankor__ResourceAssignment__c resourceAssignmentRecord : [select id,name,leankor__PercentCompleted__c,leankor__PercentAllocation__c,leankor__KanbanCard__c  from leankor__ResourceAssignment__c where leankor__KanbanCard__c IN : activitylist]){   
	            System.assertEquals(42.0,resourceAssignmentRecord.leankor__PercentCompleted__c);   
	        }
       } 
}