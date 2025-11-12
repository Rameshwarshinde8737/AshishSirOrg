/**
 * Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 * FILE: PurgeSoftDeletedRecords.cls
 * CLASS: PurgeSoftDeletedRecords
 * Description : Users can have a retention period and records beyond this period will be deleted on daily basis.
 * Schedule new apex job to run on daily basis @3.00AM   
 */
global without sharing class PurgeSoftDeletedRecords implements Database.Batchable<sObject> {
    
	// rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type
	public static final Set<String> SETSTICKERSOBJECTS_CONST = new Set<String>{'leankor__Background__c', 'leankor__Marker__c', 'leankor__ValueStream__c', 'leankor__Sticker__c', 'leankor__KanbanCard__c'};
	// rbo 08.19.17 sObjectNames of custom objects that use stickers, this set will be used for filtering Attachment - Parent.Type   
    private final Integer retentionPeriod;
	
	
    global PurgeSoftDeletedRecords() {     
		this.retentionPeriod = leankor__LeanConstants__c.getInstance().leankor__RetentionPeriodInDays__c == null 
							? 0 
							: Integer.valueof(leankor__LeanConstants__c.getInstance().leankor__RetentionPeriodInDays__c); 
    }    
	   
	
    global Database.QueryLocator start(Database.BatchableContext BC) {                     
    	return Database.getQueryLocator(getQueryString());
    }   
	
	
    global void execute(Database.BatchableContext BC, List<leankor__ValueStream__c> softValueStreamList) {
        DateTime retentionDate = System.now() - retentionPeriod;    
		
		try {    
        	//If � Retention period in days � is less than 1, DO NOT purge soft deleted records (zero and negative values) as per TDD        
			if (retentionPeriod >= 1 ) {  
        		System.debug('more than 1 days');
            	deleteRecords(softValueStreamList, retentionDate);
        	}
        } catch(Exception e) {        
            throw new PurgeSoftDeletedRecordsException('ERROR:' + e.getMessage()); 
        }        
	} 
	
    
    public static Integer getQueryRowsCount() {
		//If we perform dml operation on 9999 records then dmlRow count will be 10000
		//and in case of exception rollback performed then it will count one dml row means total 10001.
		//then exception occurs for dml rows 10001.
		//So that is why we have used limit counter 9998
		
    	return 9998 - Limits.getQueryRows();
	}	             
	
          
    global static void deleteRecords(List<leankor__ValueStream__c> vsIds, DateTime retentionDate) {                    
    	//RS 9/3/2018 Modified the code to prevent the governor limits , used getQueryRows for that.        
		Savepoint sp = Database.setSavepoint();

		//Check CRUD / FLC behavior	
		/*KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();	
		KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
		ValuestreamBehavior valuestreamBehavior = new ValuestreamBehavior();
		EntitySubscriptionBehaviour entitySubscriptionBehaviour = new EntitySubscriptionBehaviour();
		ChartBehaviour chartBehaviour = new ChartBehaviour();
		PreferenceBehaviour preferenceBehaviour = new PreferenceBehaviour();
		SecurityBehavior securityBehavior = new SecurityBehavior();
		RealtimeTrackerBehavior realtimeTrackerBehavior = new RealtimeTrackerBehavior();
		TaskTemplateBehavior taskTemplateBehavior = new TaskTemplateBehavior();
		AutomationTemplateBehaviour automationTemplateBehaviour = new AutomationTemplateBehaviour();
		SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
		ZoneBehavior zoneBehavior = new ZoneBehavior();
		MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour(); 
		DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
		TaskBehaviour taskBehaviour = new TaskBehaviour();
		KanbanCardStickerBehaviour kanbanCardStickerBehaviour = new KanbanCardStickerBehaviour(); 
		SubscriberBehavior subscriberBehavior = new SubscriberBehavior(); 
		ScheduleModeBehavior scheduleModeBehavior = new ScheduleModeBehavior();
		ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
		PushTopicBehaviour pushTopicBehaviour = new PushTopicBehaviour();
		AttachmentBehaviour attachmentBehaviour = new AttachmentBehaviour(); 
		StickerBehavior stickerBehavior = new StickerBehavior();
		MarkerBehaviour markerBehaviour = new MarkerBehaviour();
		ZoneKanbanActionBehavior zoneKanbanActionBehavior = new ZoneKanbanActionBehavior();
		StatusLogBehaviour StatusLogBehaviour = new StatusLogBehaviour();
		FilterBehaviour FilterBehaviour = new FilterBehaviour(); 
		ProjectScheduleBaselineBehaviour ProjectScheduleBaselineBehaviour = new ProjectScheduleBaselineBehaviour();
		KanbanCardBaselineBehaviour KanbanCardBaselineBehaviour = new KanbanCardBaselineBehaviour();

		if (
			!kanbanCardBehaviour.isAccessible() || !kanbanCardBehaviour.isDeletable() ||
			!kanbanCardTemplateBehaviour.isAccessible() || !kanbanCardTemplateBehaviour.isDeletable() ||
			!valuestreamBehavior.isAccessible() || !valuestreamBehavior.isDeletable() ||
			!entitySubscriptionBehaviour.isAccessible() || !entitySubscriptionBehaviour.isDeletable() ||
			!chartBehaviour.isAccessible() || !chartBehaviour.isDeletable() ||
			!preferenceBehaviour.isAccessible() || !preferenceBehaviour.isDeletable() ||
			!securityBehavior.isAccessible() || !securityBehavior.isDeletable() ||
			!realtimeTrackerBehavior.isAccessible() || !realtimeTrackerBehavior.isDeletable() ||
			!taskTemplateBehavior.isAccessible() || !taskTemplateBehavior.isDeletable() ||
			!automationTemplateBehaviour.isAccessible() || !automationTemplateBehaviour.isDeletable() ||
			!swimlaneBehavior.isAccessible() || !swimlaneBehavior.isDeletable() ||
			!zoneBehavior.isAccessible() || !zoneBehavior.isDeletable() ||
			!masterContainerBehaviour.isAccessible() || !masterContainerBehaviour.isDeletable() ||
			!dependencyBehaviour.isAccessible() || !dependencyBehaviour.isDeletable() ||
			!taskBehaviour.isAccessible() || !taskBehaviour.isDeletable() ||
			!kanbanCardStickerBehaviour.isAccessible() || !kanbanCardStickerBehaviour.isDeletable() ||
			!subscriberBehavior.isAccessible() || !subscriberBehavior.isDeletable() ||
			!scheduleModeBehavior.isAccessible() || !scheduleModeBehavior.isDeletable() ||
			!resourceAssignmentBehavior.isAccessible() || !resourceAssignmentBehavior.isDeletable() ||
			!pushTopicBehaviour.isAccessible() || !pushTopicBehaviour.isDeletable() ||
			!attachmentBehaviour.isAccessible() || !attachmentBehaviour.isDeletable() ||
			!stickerBehavior.isAccessible() || !stickerBehavior.isDeletable() ||
			!markerBehaviour.isAccessible() || !markerBehaviour.isDeletable() ||
			!zoneKanbanActionBehavior.isAccessible() || !zoneKanbanActionBehavior.isDeletable() ||
			!StatusLogBehaviour.isAccessible() || !StatusLogBehaviour.isDeletable() ||
			!FilterBehaviour.isAccessible() || !FilterBehaviour.isDeletable() ||
			!ProjectScheduleBaselineBehaviour.isAccessible() || !ProjectScheduleBaselineBehaviour.isDeletable() ||
			!KanbanCardBaselineBehaviour.isAccessible() || !KanbanCardBaselineBehaviour.isDeletable() 
		) {
			System.debug('Error: No access to records');
			//throw new Util.LeanException('Error: No access to records');
		}*/
		//Check CRUD / FLC behavior	

		try {
			Map<String,Schema.SObjectType> check_pkg = Schema.getGlobalDescribe();
			List<leankor__KanbanCard__c> cardList = [Select Id 
														From leankor__KanbanCard__c 
														Where leankor__ValueStream__c In :vsIds Or (leankor__IsRecordDeleted__c = true And LastModifiedDate <=:retentionDate)
														Limit: getQueryRowsCount()];
			if (check_pkg.get('EntitySubscription') != null) {		
				List<Sobject> Entity = [Select Id 
											From EntitySubscription 
											Where ParentId In :cardList 
											Limit 1000];
				Database.delete(Entity, true);
			}	
			
			List<leankor__Chart__c> chrt = [Select Id 
												From leankor__Chart__c 
												Where leankor__ValueStream__c In : vsIds 
													Or leankor__ValueStream__c = null
												Limit : getQueryRowsCount()];       
			Database.delete(chrt, true);
			//Ramanand : 03/June/2024 : Fixes for the project cloning issue where cloning is failed if Board has No Preference records. 
			if (getQueryRowsCount() > 0) {
				List<leankor__Preference__c>  prefs = [Select Id 
															From leankor__Preference__c 
															Where leankor__ValueStream__c In :vsIds 
																//Or (leankor__ValueStream__c = null And leankor__DerivedFrom__c = null)
															Limit: getQueryRowsCount()]; 
				Database.delete(prefs, true);
			}
		
			if (getQueryRowsCount() > 0 ) {
				List<leankor__Security__c>  security = [Select Id 
															From leankor__Security__c 
															Where leankor__ValueStream__c In : vsIds 
																Or (leankor__ValueStream__c = null And leankor__UserRoleId__c = null)
															Limit: getQueryRowsCount()]; 
				Database.delete(security, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__RealtimeTracker__c> realtimeTrackers = [Select Id 
																		From leankor__RealtimeTracker__c 
																		Where leankor__ValueStream__c In :vsIds 
																		Limit : getQueryRowsCount()];                     
				Database.delete(realtimeTrackers, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__StatusLog__c> statusLogs = [Select Id 
															From leankor__StatusLog__c 
															Where leankor__KanbanCard__c In :cardList
															 	Or (leankor__KanbanCard__c = null)
															Limit : getQueryRowsCount()];              
				Database.delete(statusLogs, true);
			}
			
			List<leankor__AutomationTemplate__c> automationTemplates = new List<leankor__AutomationTemplate__c>();
			if (getQueryRowsCount() > 0) {
				automationTemplates = [Select Id 
											From leankor__AutomationTemplate__c 
											Where leankor__ValueStream__c In :vsIds
												Or (leankor__ValueStream__c = null 
												And leankor__ProjectRoomLink__c = null
												And leankor__ProjectRoom__c = null 
												And leankor__ValueStreamCardLink__c = null
												And leankor__ValueStreamLink__c = null
												And leankor__KanbanCardTemplate__c = null
												And leankor__Account__c = null
												And leankor__Zone__c = null ) 
											Limit : getQueryRowsCount()];
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__TaskTemplate__c> TaskTemplates = [Select Id 
																	From leankor__TaskTemplate__c 
																	Where leankor__AutomationTemplate__c In :automationTemplates
																		Or (leankor__AutomationTemplate__c = null) 
																	Limit : getQueryRowsCount()];           
				Database.delete(TaskTemplates, true);
			}	
			
			if (!automationTemplates.isEmpty()) {
				Database.delete(automationTemplates, true);
			}
				
			
			if (getQueryRowsCount() > 0) {
				List<leankor__Zone__c> zones = [Select Id 
													From leankor__Zone__c 
													Where leankor__ValueStream__c In :vsIds 
													Limit : getQueryRowsCount()];        
				Database.delete(zones, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__Swimlane__c> swimlane = [Select Id 
															From leankor__Swimlane__c 
															Where leankor__ValueStream__c In :vsIds 
																Or (leankor__ValueStream__c = null And leankor__MasterContainer__c = null)
															Limit : getQueryRowsCount()];      
				Database.delete(swimlane, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__MasterContainer__c> masterContainers = [Select Id 
																		From leankor__MasterContainer__c  
																		Where leankor__ValueStream__c In :vsIds 
																			Or (leankor__ValueStream__c = null)
																		Limit : getQueryRowsCount()];             
				Database.delete(masterContainers, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__Dependency__c>  dependeciesList = [Select Id 
																	From leankor__Dependency__c 
																	Where leankor__ValueStream__c In :vsIds 
																		Or (leankor__ValueStream__c = null Or leankor__ValueStream__r.leankor__ProjectRoom__r.leankor__Portfolio__c = null)  
																		Or (leankor__ValueStream__c = null And leankor__Successor__c = null And leankor__Predecessor__c = null)
																	Limit : getQueryRowsCount()];           
				Database.delete(dependeciesList, true);          
			}
			
			if (getQueryRowsCount() > 0) {
				List<Task> tsk= [Select Id 
									From Task 
									Where whatId In (Select Id 
														From leankor__KanbanCard__c 
														Where leankor__ValueStream__c In : vsIds 
															Or (leankor__IsRecordDeleted__c = true  
																And LastModifiedDate <=:retentionDate)) 
															And IsDeleted = false 
									Limit : getQueryRowsCount() 
									All Rows];       
				Database.delete(tsk, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__KanbanCardSticker__c> kcSticker = [Select Id 
																	From leankor__KanbanCardSticker__c 
																	Where leankor__KanbanCard__c In :cardList
																		Or (leankor__KanbanCard__c = null And leankor__Sticker__c = null)
																	Limit : getQueryRowsCount()];               
				Database.delete(kcSticker, true);
			}
			
			if (getQueryRowsCount() > 0) {
				List<leankor__Subscriber__C> subscribers = [Select Id 
																From leankor__Subscriber__c 
																Where leankor__KanbanCard__c In :cardList 
																	Or (leankor__KanbanCard__c = null
																	 	And leankor__Preference__c = null
																		And leankor__SubscriberId__c = null)
																Limit : getQueryRowsCount()];       
				Database.delete(subscribers, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__ScheduleMode__c> scheduleModes = [Select Id 
																	From leankor__ScheduleMode__c 
																	Where leankor__KanbanCard__c In :cardList
																		Or (leankor__KanbanCard__c = null 
																			And leankor__ScheduleConstraint__c = null)
																	Limit : getQueryRowsCount()];       
				Database.delete(scheduleModes, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__ResourceAssignment__c> rsourceAssignments = [Select Id 
																				From leankor__ResourceAssignment__c 
																				Where leankor__KanbanCard__c In :cardList
																					Or (leankor__KanbanCard__c = null
																						And leankor__AssignedTo__c = null
																						And leankor__ResourceType__c = null
																						And leankor__ProjectFinancial__c = null)
																				Limit : getQueryRowsCount()];        
				Database.delete(rsourceAssignments, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__KanbanCardBaseline__c> kanbanBaseLines = [Select Id  
																			From leankor__KanbanCardBaseline__c 
																			Where leankor__KanbanCard__c In :cardList
																				Or (leankor__KanbanCard__c = null 
																					And leankor__ProjectScheduleBaseline__c = null)
																			Limit : getQueryRowsCount()];         
				Database.delete(kanbanBaseLines, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__ProjectScheduleBaseline__c> DeleteProjectBaseLine = [Select Id  
																						From leankor__ProjectScheduleBaseline__c 
																						Where leankor__ProjectBoard__c In :vsIds 
																						Limit : getQueryRowsCount()];         
				Database.delete(DeleteProjectBaseLine, true);
			}	
		
			if (getQueryRowsCount() > 0) {
				List<leankor__KanbanCardTemplate__C> kanbanTemplate = [Select Id 
																			From leankor__KanbanCardTemplate__c 
																			Where leankor__ValueStream__c In :vsIds 
																			Limit : getQueryRowsCount()];      
				Database.delete(kanbanTemplate, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<String>  pushTopicIDs = new List<String>();
				for (leankor__ValueStream__c vs: vsIds) {
					pushTopicIDs.add('RT'+ vs.Id);
				}
				List<PushTopic> pushTopics = [Select Id 
													From PushTopic 
													Where Name In : pushTopicIDs 
													Limit : getQueryRowsCount()];
				Database.delete(pushTopics, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<leankor__Filter__c> deleteFilters = [Select Id 
															From leankor__Filter__c 
															Where leankor__ValueStream__c In :vsIds 
																Or (leankor__ValueStream__c = null 
																	And leankor__User__c = null)
															Limit : getQueryRowsCount()];           
				Database.delete(deleteFilters, true);
			}	
			
			if (getQueryRowsCount() > 0) {
				List<Attachment> attByVs =	[Select Id 
													From Attachment 
													Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
														And ParentId In :vsIds 
													Limit: getQueryRowsCount()];
				Database.delete(attByVs, true);
			}	

			if (getQueryRowsCount()  > 0) {
				List<Attachment> attByMarker =	[Select Id 
														From Attachment 
														Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
															And  (Parentid In (Select Id 
																					From leankor__Marker__c 
																					Where leankor__ValueStream__c In : vsIds)) 
														Limit: getQueryRowsCount()];
				Database.delete(attByMarker, true);
			} 

			if (getQueryRowsCount() > 0) {
				List<Attachment> attBySticker =	[Select Id 
														From Attachment 
														Where Parent.Type In :SETSTICKERSOBJECTS_CONST 
															And  (Parentid In (Select Id 
																					From leankor__Sticker__c 
																					Where leankor__ValueStream__c In : vsIds)) 
														Limit: getQueryRowsCount()];
				Database.delete(attBySticker, true);
			}
			
			if (getQueryRowsCount() > 0) {
				List<leankor__Sticker__c> Sticker = [Select Id		
															From leankor__Sticker__c 
															Where leankor__ValueStream__c In : vsIds 
															Limit: getQueryRowsCount()];
				Database.delete(Sticker, true);
			}
			if (getQueryRowsCount() > 0) {
				List<leankor__Marker__c> markers = [Select Id 
														From leankor__Marker__c 
														Where leankor__ValueStream__c In : vsIds 
															Or (leankor__ValueStream__c = null
																And leankor__ValueStreamCardLink__c = null
																And leankor__ValueStreamLink__c = null
																And leankor__Sticker__c = null)
														Limit : getQueryRowsCount()];
				Database.delete(markers, true);
			}    
					
			if (getQueryRowsCount() > 0) {
				List<leankor__ZoneKanbanAction__c>  zoneKanbanActionsByVS = [Select Id 
																					From leankor__ZoneKanbanAction__c 
																					Where leankor__ValueStream__c In : vsIds 
																					Limit: getQueryRowsCount()];
				Database.delete(zoneKanbanActionsByVS, true);
			}
			
			if (getQueryRowsCount() > 0) {
				List<leankor__ZoneKanbanAction__c> zoneKanbanActionsByKB = [Select Id 
																				From leankor__ZoneKanbanAction__c 
																				Where leankor__kanbanCard2__c In (Select Id 
																														From leankor__KanbanCard__c 
																														Where leankor__ValueStream__c In : vsIds 
																															Or (leankor__IsRecordDeleted__c = true  
																																And  LastModifiedDate <=:retentionDate)) 
																				Limit: getQueryRowsCount()];
				Database.delete(zoneKanbanActionsByKB, true);
			}
			
			/*if (getQueryRowsCount() > 0) {
				List<leankor__Background__c> backGrounds = [Select Id 
																From leankor__Background__c
																Where leankor__ValueStream__c In :vsIds
																	Or (leankor__ValueStream__c = null)
																Limit : getQueryRowsCount()];
				Database.delete(backGrounds, true);
			}*/
			
				
			if (getQueryRowsCount() > 0) {
				List<leankor__IssueLog__c> issueLogs = [Select Id 
																From leankor__IssueLog__c
																Where leankor__KanbanCard__c = null
																	And leankor__AssignedTo__c = null
																Limit : getQueryRowsCount()];
				Database.delete(issueLogs, true);
			}

			if (getQueryRowsCount() > 0) {
				List<leankor__TimeCard__c> timeCardList = [Select Id 
																From leankor__TimeCard__c
																Where leankor__Assign_a_User__c = null
																	And leankor__AssignedTo__c = null
																	And leankor__KanbanCard__c = null 
																	And leankor__TimeSheet__c = null
																Limit : getQueryRowsCount()];
				Database.delete(timeCardList, true);
			}

			if (getQueryRowsCount() > 0) {
				List<leankor__TimeSheet__c> timeSheetList = [Select Id 
																From leankor__TimeSheet__c
																Where leankor__Resource__c = null
																Limit : getQueryRowsCount()];
				Database.delete(timeSheetList, true);
			}

			if (getQueryRowsCount() > 0) {
				Database.delete(cardList, true);	
			}

			if (getQueryRowsCount() > 0) {
				Database.delete(vsIds, true); 
			}          		
				
			if (getQueryRowsCount() > 0 ) {
				List<leankor__ProjectRoom__c> projectRooms = [Select Id
				                                                From leankor__ProjectRoom__c
															    Where leankor__Portfolio__c = null
															    Limit :getQueryRowsCount()];

				List<leankor__ProjectLaunchBehavior__c> projectLaunchBehaviors;

				// Check if roomlist is not empty before proceeding
				if (!projectRooms.isEmpty() && getQueryRowsCount() > 0) {
					projectLaunchBehaviors = [Select Id 
					                            From leankor__ProjectLaunchBehavior__c 
												Where leankor__Project__c In :projectRooms 
												Limit :getQueryRowsCount()];

					Database.delete(projectLaunchBehaviors, true);

				}

				if (!projectRooms.isEmpty() && getQueryRowsCount() > 0) {

					Database.delete(projectRooms, true);
				}
			}

			// Deleting ProjectFinancial Records
			if (getQueryRowsCount() > 0) {
				List<leankor__ProjectFinancial__c> projectFinancialRecords = [Select Id
																				From leankor__ProjectFinancial__c 
																				Where leankor__Project__c = null
																					Or leankor__FinancialAccount__c = null
																				Limit : getQueryRowsCount()];

				Database.delete(projectFinancialRecords, true);																					
			}
			
			//Deleting expenseRecords Records 
			if (getQueryRowsCount() > 0) {
				List<leankor__Expense__c> expenseRecords = [Select Id
																From leankor__Expense__c
																Where leankor__Portfolio__c = null
																	And leankor__Project__c = null
																	And leankor__ProjectBoard__c = null
																	And leankor__KanbanCard__c = null
																	And leankor__DeliveredProduct__c = null
																	And leankor__ProjectFinancial__c = null
																Limit : getQueryRowsCount()];
				Database.delete(expenseRecords, true);	
			}

			// Deleting ExpenseResourceAssignment Records
			if (getQueryRowsCount() > 0) {
				List<leankor__ExpenseResourceAssignment__c> expenseResourceAssignmentRecords = [Select Id
																									From leankor__ExpenseResourceAssignment__c 
																									Where leankor__Expense__c = null
																									Limit : getQueryRowsCount()];

				Database.delete(expenseResourceAssignmentRecords, true);																					
			}	

		} catch(Exception exp){
			//Rollback operation will count only one dml row
			Database.rollback(sp);		
			throw new PurgeSoftDeletedRecordsException('ERROR:' + exp.getMessage());	
		}		
    }
    	
	
	global void finish(Database.BatchableContext BC) {       
        //nested batch for kanban card after running purgesolftdeletedrecord according to valuestream
        //leankor.PurgeSoftDeletedRecordsKC PSDR = new leankor.PurgeSoftDeletedRecordsKC(); 
      	//database.executebatch(PSDR);
	}
	

	/******************************************************************
 		Author : Suraj Sen
		Description : get query string according to available soft deleted valuestream
					if there is no soft deleted VS but exist Soft deleted card's then create
				   	one dummy soft deleted VS record and execute further batch
	*******************************************************************/
	public String getQueryString() {
		
		//Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isAccessible() ||
            !valueStreamBehavior.isCreateable()) {
            throw new PurgeSoftDeletedRecordsException('Error: No access to records');
		}
        //Check CRUD / FLC behavior
     	
     	//minus retentionPeriod from today date
       	DateTime retentionDate = System.now() - retentionPeriod;
		
		//This will be default query for batch execution. 
       	String defaultQuery = 'Select Id, leankor__IsRecordDeleted__c '
     							  +'From leankor__ValueStream__c '
     							  +'Where leankor__IsRecordDeleted__c = True '
     							  +'AND LastModifiedDate < '+retentionDate.format('yyyy-MM-dd') + 'T23:59:59Z ';
								   
     	if (Database.query(defaultQuery+' Limit 1').size() > 0) {
     		return defaultQuery;
     	} else if (Database.query('Select Id '
     							  +'From leankor__KanbanCard__c '
     							  +'Where leankor__IsRecordDeleted__c = True '
     							  +'AND LastModifiedDate < '+retentionDate.format('yyyy-MM-dd') + 'T23:59:59Z '
     							  +'Limit 1'
     					 ).size() > 0) {

     		insert new leankor__Valuestream__c(name='PurgeSoftDeletedDummyRecord',leankor__IsRecordDeleted__c =true);
     		return 'Select Id, leankor__IsRecordDeleted__c '
     				  +'From leankor__ValueStream__c '
     				  +'Where Name=\'PurgeSoftDeletedDummyRecord\' And leankor__IsRecordDeleted__c = True';

		} else if(Database.query('Select Id '
								   +'From leankor__ProjectRoom__c '
								   +'Where leankor__Portfolio__c = null '
								   +'AND LastModifiedDate < '+retentionDate.format('yyyy-MM-dd') + 'T23:59:59Z '
								   +'Limit 1').size() > 0) {
										
		  insert new leankor__Valuestream__c(name='PurgeSoftDeletedDummyRecord',leankor__IsRecordDeleted__c = true);
		 return 'Select Id, leankor__IsRecordDeleted__c '
				   +'From leankor__ValueStream__c '
				   +'Where Name=\'PurgeSoftDeletedDummyRecord\' And leankor__IsRecordDeleted__c = True';	
		}
		 
     	return defaultQuery;

    }	
	
	public class PurgeSoftDeletedRecordsException extends Exception {}
}