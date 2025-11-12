/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: PostInstallleankor.cls
 * CLASS: PostInstallLean
*/

global without sharing class PostInstallLean implements InstallHandler
{
    Global void onInstall(InstallContext context) {

        if (context.previousVersion() == null) {
            if (leankor__LeanConstants__c.getInstance() == null) {
                try{
                    upsert new leankor__LeanConstants__c(SetupOwnerId = Userinfo.getOrganizationId());         
                }catch(DMLException ex){
                    System.debug('Error : '+ex);
                }
            }
            
            String scheduleJobYearRange = ''+Date.today().year()+'-'+(Date.today().year()+3);   
            String schCardDueDate = '0 0 23 * * ? '+scheduleJobYearRange;
            scheduledCardDueDateChatter cardDueDate = new scheduledCardDueDateChatter();        
            scheduledTaskDueDateChatter taskDueDate = new scheduledTaskDueDateChatter();
            String schTaskDueDate = '0 0 23 * * ? '+scheduleJobYearRange;
            
            scheduledProjectBoardStats  VSStats = new scheduledProjectBoardStats();
            String  schVSstats = '0 0 23 * * ? '+scheduleJobYearRange;
                            
            String  scheduleSetActivityTrackerCron = '0 0 4 * * ? '+scheduleJobYearRange;
            ScheduleSetActivityTracker schedSetActivityTracker = new ScheduleSetActivityTracker();                
            
            String cardDueDateJobID = system.schedule('Card Past Due-'+system.now().getTime(), schCardDueDate , cardDueDate);
            String taskDueDateJobID = system.schedule('Task Past Due-'+system.now().getTime(), schTaskDueDate , taskDueDate);
            String BurnDownChartJobID = system.schedule('Project Board Statistics-'+system.now().getTime(), schVSstats , VSStats);
                    
            System.schedule('Schedule Set Activity Tracker-'+system.now().getTime(), scheduleSetActivityTrackerCron , schedSetActivityTracker);
                    
            leankor__LeanConstants__c Customsetting = 
                new leankor__LeanConstants__c(
                    leankor__DisableKanbanCardTrigger__c = true,
                    leankor__FirstInstall__c = true,
                    leankor__DisableCaseTrigger__c= true,
                    leankor__DisableOpportunityTrigger__c= true,
                    leankor__AvoidTaskDueDateCheck__c = true,
                    leankor__OverrideDependencyCompletionRule__c = true,
                    leankor__SupportURL__c = 'https://support.leankor.com',
                    leankor__ShowDateOnCardFace__c = true,
                    leankor__KanbanBoardScrollSpeed__c = 30,
                    leankor__DisableProjectFinancialTrigger__c = true
                    );
            try{
                DataBase.insert(Customsetting,false);
            }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
            }
            
            List<leankor__Module__c> Module_list = new List<leankor__Module__c>();
                leankor__Module__c Obj_data = new leankor__Module__c(leankor__BoardType__c = '_System_UberBoard',leankor__Order__c = 1,leankor__SetUp__c = true,Name = 'Plan (Gantt)'); 
                Module_list.add(Obj_data);
                leankor__Module__c Obj_data1 = new leankor__Module__c(leankor__BoardType__c = '_System_PlanBoard',leankor__Order__c = 2,leankor__SetUp__c = true,Name = 'Roll Up'); 
                Module_list.add(Obj_data1);
                leankor__Module__c Obj_data2 = new leankor__Module__c(leankor__BoardType__c = '_System_Board',leankor__Order__c = 3,leankor__SetUp__c = true,Name = 'Project Boards'); 
                Module_list.add(Obj_data2);
                leankor__Module__c Obj_data3 = new leankor__Module__c(leankor__BoardType__c = '_System_Whiteboard',leankor__Order__c = 4,leankor__SetUp__c = true,Name = 'Whiteboards'); 
                Module_list.add(Obj_data3);
                leankor__Module__c Obj_data4 = new leankor__Module__c(leankor__BoardType__c = '_System_DashBoard',leankor__Order__c = 5,leankor__SetUp__c = true,Name = 'DashBoard');   Module_list.add(Obj_data4);
                leankor__Module__c Obj_data5 = new leankor__Module__c(leankor__BoardType__c = '',leankor__Order__c = 6,leankor__SetUp__c = true,Name = 'Financials');
                Module_list.add(Obj_data5);
            try{
                DataBase.insert (Module_list, false);
               }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
            }

            List<leankor__ScheduleConstraint__c> scheduleConstraints = new List <leankor__ScheduleConstraint__c>();
            leankor__ScheduleConstraint__c scheduleConstraint1 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'startnoearlierthan', leankor__Description__c = 'startnoearlierthan');
            scheduleConstraints.add(scheduleConstraint1);
            leankor__ScheduleConstraint__c scheduleConstraint2 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'startnolaterthan', leankor__Description__c = 'startnolaterthan');
            scheduleConstraints.add(scheduleConstraint2);
            leankor__ScheduleConstraint__c scheduleConstraint3 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'muststarton', leankor__Description__c = 'muststarton');
            scheduleConstraints.add(scheduleConstraint3);
            leankor__ScheduleConstraint__c scheduleConstraint4 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'finishnoearlierthan', leankor__Description__c = 'finishnoearlierthan');
            scheduleConstraints.add(scheduleConstraint4);
            leankor__ScheduleConstraint__c scheduleConstraint5 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'finishnolaterthan', leankor__Description__c = 'finishnolaterthan');
            scheduleConstraints.add(scheduleConstraint5);
            leankor__ScheduleConstraint__c scheduleConstraint6 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'mustfinishon', leankor__Description__c = 'mustfinishon');
            scheduleConstraints.add(scheduleConstraint6);
            leankor__ScheduleConstraint__c scheduleConstraint7 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'assoonaspossible', leankor__Description__c = 'assoonaspossible');
            scheduleConstraints.add(scheduleConstraint7);
            leankor__ScheduleConstraint__c scheduleConstraint8 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'aslateaspossible', leankor__Description__c = 'aslateaspossible');
            scheduleConstraints.add(scheduleConstraint8);

            try{
                insert scheduleConstraints;
               }catch(DMLException ex){
                System.debug('Error : '+ex.getMessage());
            }
        } 
        //scheduling purgesoftdeleteRecords @3AM on every day.  
        if(context.previousVersion() == null || (context.previousVersion() != null && context.isUpgrade() && context.previousVersion().compareTo(new Version(1,239)) <= 0))
        {    
            if(!Test.isRunningTest())
            {
                Date currentDate = System.today();
                Integer scheduleYear = currentDate.year() + 5; 
                String scheduleTimePurge = '0 0 3 * * ? 2018-' + scheduleYear;        
                SchedulePurgeSoftDeletedRecords purgeDeleteRecords = new SchedulePurgeSoftDeletedRecords();
                String purgeScheduleId = system.schedule('PurgeSoftDeletedRecords -'+system.now().getTime(), scheduleTimePurge , purgeDeleteRecords);  
            }						
        } 	    	    	 
	    
        if(context.previousVersion() != null && context.isUpgrade() && (context.previousVersion().compareTo(new Version(1, 300)) <= 0)) {

            List<leankor__ValueStream__c> valueStreams = new List<leankor__ValueStream__c>();
            // creating leankor__ScheduleConstraint__c record if not created previously.
            if([Select Id From leankor__ScheduleConstraint__c Limit 1000].isEmpty()){
                List<leankor__ScheduleConstraint__c> scheduleConstraints = new List <leankor__ScheduleConstraint__c>();
                leankor__ScheduleConstraint__c scheduleConstraint1 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'startnoearlierthan', leankor__Description__c = 'startnoearlierthan');
                scheduleConstraints.add(scheduleConstraint1);
                leankor__ScheduleConstraint__c scheduleConstraint2 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'startnolaterthan', leankor__Description__c = 'startnolaterthan');
                scheduleConstraints.add(scheduleConstraint2);
                leankor__ScheduleConstraint__c scheduleConstraint3 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'muststarton', leankor__Description__c = 'muststarton');
                scheduleConstraints.add(scheduleConstraint3);
                leankor__ScheduleConstraint__c scheduleConstraint4 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'finishnoearlierthan', leankor__Description__c = 'finishnoearlierthan');
                scheduleConstraints.add(scheduleConstraint4);
                leankor__ScheduleConstraint__c scheduleConstraint5 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'finishnolaterthan', leankor__Description__c = 'finishnolaterthan');
                scheduleConstraints.add(scheduleConstraint5);
                leankor__ScheduleConstraint__c scheduleConstraint6 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'mustfinishon', leankor__Description__c = 'mustfinishon');
                scheduleConstraints.add(scheduleConstraint6);
                leankor__ScheduleConstraint__c scheduleConstraint7 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'assoonaspossible', leankor__Description__c = 'assoonaspossible');
                scheduleConstraints.add(scheduleConstraint7);
                leankor__ScheduleConstraint__c scheduleConstraint8 = new leankor__ScheduleConstraint__c(leankor__Type__c = 'aslateaspossible', leankor__Description__c = 'aslateaspossible');
                scheduleConstraints.add(scheduleConstraint8);

                try{
                    insert scheduleConstraints;
                }catch(DMLException ex){
                    System.debug('Error : '+ex.getMessage());
                }
            }
			
            // Ramanand : 28/12/2021 - Changes for insert schedule mode record for exiting milestone record. 
            System.enqueueJob(new CreateScheduleModeRecordsQueueable());
        } 

        // 16/08/2022 - Changes to update Streaming API Version to 55.
        if(context.previousVersion() != null && context.isUpgrade() && context.previousVersion().compareTo(new Version(1,301)) <= 0) {
			leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getOrgDefaults();
			leanConstant.leankor__StreamingAPIVersion__c = 55.0;		 	
            try {
				update leanConstant;
            } catch(DMLException ex){
				System.debug('ERROR: During update custom setting fields for Dependency Completion Rule and Duration On Effort Driven Task: ' + ex.getMessage());
            }
        }
        if(context.previousVersion() != null && context.isUpgrade() && context.previousVersion().compareTo(new Version(1,305)) <= 0) {
            leankor__LeanConstants__c leanConstant = leankor__LeanConstants__c.getOrgDefaults();
			leanConstant.leankor__DisableProjectFinancialTrigger__c	= true;	 	
            try {
				update leanConstant;
            } catch(DMLException ex){
				System.debug('ERROR: During update custom setting fields for Trigger setting: ' + ex.getMessage());
            }
        }
                  
    }// end of method
              
  }