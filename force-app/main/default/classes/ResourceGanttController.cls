/**
 * Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
 * FILE:  ResourceGanttController.cls
 * CLASS: ResourceGanttController
 * USAGE: manages to Get record of Card for New Gantt Resource  .
 */
global with sharing class ResourceGanttController {
    public ResourceGanttController() {}
    global ResourceGanttController(ApexPages.StandardController controller) {}
	//20/March/2024 : Currently we are deprecating Broadcasting channel, So broadcast should ot fire in PE, so we are setting true value.
	private static final Boolean IS_USING_PLATFORM_EVENT = true;

    global class ResourceAssignmentlog {
        global List<user> ResourceUsers = new List<user>();
        global List<UserData> ResourceUsersData = new List <UserData>();
        global list < leankor.KanbanToGanttController.MasterContainer > ResourceCards = new list < leankor.KanbanToGanttController.MasterContainer > ();
        global list < leankor.KanbanToGanttController.MasterContainer > ResourceAssignmentList = new list < leankor.KanbanToGanttController.MasterContainer > ();
    	global Integer WorkingHoursPerDay;
    }
    global class ResourceAssignmentInputlog {
        global list < string > ProjectIds = new list < string > ();
        global list < string > AllRoleIds = new list < string > ();
        global list < string > UserIDs = new list < string > ();
        global boolean isprojectfilter;
        global String StartDate;
        global String DueDate;
    }
    
    global class UserData
    {   
        global User UserRecord;
        global List<leankor.ResourceGanttController.ResourceCalendar> ResourceHoursData;   
    }
    
    /*-------------------------------------------------------------------------------	
	Company: 		Leankor
	Description: 	Check field exist in given sObject or not.  
	Inputs: 		ResourceAssignmentInputlog InputRMlog
	Returns: 		ResourceAssignmentlog
	Modified: 		RS 04/12/2018 For Case 2482 - Resource Schedule - Add Resource Bug
					Earlier it was supporting single filter but now it supports multiple filter
	---------------------------------------------------------------------------------*/    
    @remoteaction
    global static ResourceAssignmentlog getAllResources(ResourceAssignmentInputlog InputRMlog) {
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		UserBehaviour userBehaviour = new UserBehaviour();
		if (!userBehaviour.isAccessible() || !kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
		for (String roleId : InputRMlog.AllRoleIds){
			if (String.isNotBlank(roleId) && Util.getSObjectName(roleId) != 'UserRole') {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		for (String projectId : InputRMlog.ProjectIds){
			if (String.isNotBlank(projectId) && Util.getSObjectName(projectId) != 'leankor__ProjectRoom__c') {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
        ResourceAssignmentlog resultlist = new ResourceAssignmentlog();
        Integer hours = leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c == null ? 0 :Integer.valueof(leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c);        
        resultlist.WorkingHoursPerDay = (hours <= 0 ? 8 :(hours > 24 ? 24 :hours));
        
        set < string > setOfKCID = new set < string > ();
        set < string > setOfUserID = new set < string > ();
        
        Date beginDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(InputRMlog.StartDate), DateTime.class));
        Date endDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(InputRMlog.DueDate), DateTime.class));
        
        List < UserRole > UserRolewithUser = new List < UserRole > ();
        List < leankor__ResourceAssignment__c > CardRSLog = new List < leankor__ResourceAssignment__c > ();
		List < leankor__ResourceAssignment__c > CardRSLog1 ; 
        
        //25.04.2018 - define List of String which store ProjectIds/UserIds
        List<String> filterIds =  new List<String>();
		List<String> projectIds =  new List<String>();
        
		//Boolean checkFSL = leankor.KanbanController.checkFSLManageApp();
		//RS 05/12/2018  Due to 'Availability of FSL features in Leankor application' feature have to add this condition
        //Boolean checkFSL = leankor.KanbanController.checkFSLManageApp() ? new DescribeSchema().isFieldExistInSobject('WorkOrder','leankor__KanbanCard__c') : false;
		
        /*SS 19.12.2018*/
        //For both checking FSL package and KanbanCard field in sObject we have individual methods now.       
		Boolean checkFSL = leankor.KanbanController.checkFSLManageApp() ? leankor.KanbanController.checkFieldExistInSobject() : false ;       
		
        if (InputRMlog.AllRoleIds.size() > 0)
        {
        	//SS 07.05.2018
        	//Added filter for getting only active User
            UserRolewithUser = [Select Id, 
										(Select Id, 
											Name, 
											IsActive 
										From Users)
										From UserRole 
										Where Id In: InputRMlog.AllRoleIds];
            //UserRolewithUser = [SELECT Id, (Select ID, Name from Users where IsActive = true)FROM UserRole where ID IN: InputRMlog.AllRoleIds];
            //ss 07.05.2018
	        for (UserRole UserRoleLogs: UserRolewithUser)
	        {
	            if (UserRoleLogs.Users.size() > 0)
	            {
	                resultlist.ResourceUsers.addall(UserRoleLogs.Users);
	            }
	        }
	        //25.04.2018 - adding all user ids - for FSL
	        if(checkFSL){
	        	for(User u :resultlist.ResourceUsers){
	        		filterIds.add(u.Id);
	        	}
	        }
	        //25.04.2018 
	        //we have removed boardtype condition
	        CardRSLog = [Select leankor__AssignedTo__c, 
								leankor__KanbanCard__c, 
								leankor__PercentAllocation__c
							From leankor__ResourceAssignment__c
							Where (leankor__AssignedTo__c In: resultlist.ResourceUsers 
								And leankor__Kanbancard__r.leankor__TemplateBoard__c = false 
								And leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
								And leankor__Kanbancard__r.Recordtype.Name = 'ActivityCard'
								And leankor__Kanbancard__r.leankor__Valuestream__c != null
								And leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null
								And ((leankor__Kanbancard__r.leankor__StartDate__c >= : beginDate And leankor__Kanbancard__r.leankor__StartDate__c <=: endDate) 
								Or (leankor__Kanbancard__r.leankor__DueDate__c <= : endDate And leankor__Kanbancard__r.leankor__DueDate__c >= : beginDate) 
								Or(leankor__Kanbancard__r.leankor__StartDate__c <= : beginDate AND leankor__Kanbancard__r.leankor__DueDate__c >= : endDate)))
							With Security_Enforced];
		}
            
		if (InputRMlog.isprojectfilter && InputRMlog.ProjectIds.size()>0){	 
            
			CardRSLog1 = [Select leankor__AssignedTo__c, 
									leankor__KanbanCard__c, 
									leankor__PercentAllocation__c
                				From leankor__ResourceAssignment__c
                				Where ((leankor__Kanbancard__r.leankor__ValueStreamCardLink__c = null 
									And leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c In: InputRMlog.ProjectIds) 
									Or leankor__Kanbancard__r.leankor__ValueStreamLink__r.leankor__ProjectRoom__c In: InputRMlog.ProjectIds) 
									And leankor__Kanbancard__r.leankor__TemplateBoard__c = false 
									And leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
									And  leankor__Kanbancard__r.Recordtype.Name = 'ActivityCard' And leankor__Kanbancard__r.leankor__ValueStream__c != null 
									And leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null 
									And ((leankor__Kanbancard__r.leankor__StartDate__c >= : beginDate 
									And leankor__Kanbancard__r.leankor__StartDate__c <=: endDate) 
									Or (leankor__Kanbancard__r.leankor__DueDate__c <= : endDate And leankor__Kanbancard__r.leankor__DueDate__c >= : beginDate) 
									Or(leankor__Kanbancard__r.leankor__StartDate__c <= : beginDate And leankor__Kanbancard__r.leankor__DueDate__c >= : endDate))
								With Security_Enforced];
            
			// YJ-23.05.2018 - Modified Query to Tracked Linked Diffrent Project Card on RM
			CardRSLog.addAll(CardRSLog1);
            
            
			
            //SS 07.05.2018    		
            //adding ProjectIds
            if(checkFSL){
				projectIds.addAll(InputRMlog.ProjectIds);
            }
		}
		
		if(InputRMlog.UserIDs.size()>0){ 
			CardRSLog1 =  [Select leankor__AssignedTo__c, 
									leankor__KanbanCard__c, 
									leankor__PercentAllocation__c 
								From leankor__ResourceAssignment__c 
								Where leankor__AssignedTo__c In: InputRMlog.UserIDs 
									And leankor__Kanbancard__r.leankor__TemplateBoard__c = false 
									And leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != 'Template' 
									And leankor__Kanbancard__r.Recordtype.Name = 'ActivityCard' 
									And leankor__Kanbancard__r.leankor__ValueStream__c != null 
									And leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null 
									And  ((leankor__Kanbancard__r.leankor__StartDate__c >= : beginDate And leankor__Kanbancard__r.leankor__StartDate__c <=: endDate) 
									Or (leankor__Kanbancard__r.leankor__DueDate__c <= : endDate And leankor__Kanbancard__r.leankor__DueDate__c >= : beginDate) 
									Or(leankor__Kanbancard__r.leankor__StartDate__c <= : beginDate And leankor__Kanbancard__r.leankor__DueDate__c >= : endDate))
								With Security_Enforced];     
			
			CardRSLog.addAll(CardRSLog1);    
            //25.04.2018 - adding all user ids - for FSL
            if(checkFSL){
            	filterIds.addAll(InputRMlog.UserIDs);
        }
            //25.04.2018 
        }
        // adding Resource Assignment Records
        for (leankor__ResourceAssignment__c RSLog: CardRSLog){
            leankor.KanbanToGanttController.MasterContainer CardRSLogMC = new leankor.KanbanToGanttController.MasterContainer();
            CardRSLogMC.ID = RSLog.ID;
            CardRSLogMC.ResourceId = RSLog.leankor__AssignedTo__c;
            CardRSLogMC.TaskId = RSLog.leankor__Kanbancard__c;
            CardRSLogMC.Units = RSLog.leankor__PercentAllocation__c;
            CardRSLogMC.Type = 'Leankor';
            
            setOfUserID.add(RSLog.leankor__AssignedTo__c);
            setOfKCID.add(RSLog.leankor__Kanbancard__c);
            
            resultlist.ResourceAssignmentList.add(CardRSLogMC);
        }
        
		
        set<String> fslKanbanCardIds = new Set<String>();
        // checking FSL is installed or not if FSL is not installed then code will not execute
		
		
		//RS 14.3.2019 For FSL enhancements 
		map<String,sObject> mapOfsObject = new Map<string,sObject>();
		map<String,String> mapOfGUID = new Map<String,String>();		
			
        if(checkFSL){
	        List<sObject> arList = new List<sObject>();
	        map <Id, sObject> arMap = new map <Id, sObject>();
			map<Id,sObject> woMap = new map<Id,sObject>();
			map<Id,sObject> woNewMap = new map<Id,sObject>();

			/* 25.04.2018 - getting FSL resource*/
			if(InputRMlog.UserIDs.size()>0 || InputRMlog.AllRoleIds.size() > 0){
	            
	            //first getting service resource records according user id filter
				String serviceResWithOutProjectFilter = 'Select Id,Name,RelatedRecordId,(Select ServiceAppointmentId,ServiceAppointment.ParentRecordId, ServiceAppointment.Duration , ServiceAppointment.DurationType , ServiceAppointment.SchedEndTime , ServiceAppointment.SchedStartTime ,ServiceAppointment.OwnerId ,ServiceAppointment.Description , ServiceAppointment.AppointmentNumber,ServiceAppointment.Owner.Name  From ServiceAppointments) From ServiceResource Where RelatedRecordId In : filterIds';
				arList = Database.query(serviceResWithOutProjectFilter);
				
				//getting and store workOrder id from service resource List 
				set<String> workIds = new set<String>();	
				for(sObject ar : arList){
					for(sObject sa : ar.getSobjects('ServiceAppointments')){					
					    workIds.add(String.valueof(sa.getSobject('ServiceAppointment').get('ParentRecordId')));						
					}
				
				}
				//according to workIds , we are getting WorkOrder record for Kanbancard			
				String workOrderWithOutProjectFilter = 'Select id, KanbanCard__c From WorkOrder where Id In : workIds And KanbanCard__c != null And Kanbancard__r.leankor__TemplateBoard__c = false And Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != \'Template\' And Kanbancard__r.Recordtype.Name = \'ActivityCard\' And Kanbancard__r.leankor__ValueStream__c != null And Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null And  ((Kanbancard__r.leankor__StartDate__c >= : beginDate And Kanbancard__r.leankor__StartDate__c <=: endDate) Or (Kanbancard__r.leankor__DueDate__c <= : endDate And Kanbancard__r.leankor__DueDate__c >= : beginDate) Or(Kanbancard__r.leankor__StartDate__c <= : beginDate And Kanbancard__r.leankor__DueDate__c >= : endDate)) ';			
				woMap.putAll(new map<Id,sObject>(Database.query(workOrderWithOutProjectFilter)));
				
			}
			
			if(InputRMlog.isprojectfilter){
				//according to workIds , we are getting WorkOrder record for Kanbancard			
				String workOrderWithProjectFilter = 'Select id,KanbanCard__c From WorkOrder Where Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c In : projectIds And KanbanCard__c != null And Kanbancard__r.leankor__TemplateBoard__c = false And Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != \'Template\' And Kanbancard__r.Recordtype.Name = \'ActivityCard\' And Kanbancard__r.leankor__ValueStream__c != null And Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c != null AND Kanbancard__r.isRecordDeleted__c = false AND  ((Kanbancard__r.leankor__StartDate__c >= : beginDate and Kanbancard__r.leankor__StartDate__c <=: endDate) OR (Kanbancard__r.leankor__DueDate__c <= : endDate and Kanbancard__r.leankor__DueDate__c >= : beginDate) OR(Kanbancard__r.leankor__StartDate__c <= : beginDate AND Kanbancard__r.leankor__DueDate__c >= : endDate)) ';			
				woNewMap.putAll(new map<Id,sObject>(Database.query(workOrderWithProjectFilter)));	
				List<Id> workOrderIds = new List<Id>(woNewMap.keySet());
				
				//first getting service resource records according user id filter
	        	String serviceApp =  'Select ID,(SELECT ServiceResourceId FROM ServiceResources ) from ServiceAppointment Where ParentRecordID IN : workOrderIds';
				List<sObject> serviceAppList = Database.query(serviceApp);
				
				List<String> serviceResource = new List<String>();
				
				for(sObject s : serviceAppList){		        
					for(sobject o: s.getSobjects('ServiceResources')){
						serviceResource.add(String.valueof(o.get('ServiceResourceId')));
					}				
				}
				//first getting service resource records according user id filter
				String serviceResWithProjectFilter = 'SELECT Id,Name,RelatedRecordId,(Select ServiceAppointmentId,ServiceAppointment.ParentRecordId, ServiceAppointment.Duration , ServiceAppointment.DurationType , ServiceAppointment.SchedEndTime , ServiceAppointment.SchedStartTime,ServiceAppointment.OwnerId, ServiceAppointment.Description ,ServiceAppointment.AppointmentNumber,ServiceAppointment.Owner.Name From ServiceAppointments) FROM ServiceResource WHERE ID IN : serviceResource';
				arList.addAll(Database.query(serviceResWithProjectFilter));
			}	
			
			woMap.putAll(woNewMap);
			for(sObject obj : arList){
				arMap.put(obj.Id, obj);
			}
			arList.clear();
			for(Id tempId: arMap.keySet()){
				arList.add(arMap.get(tempId));
			}
			for(sObject ar : arList){ 
				  //maping between kanbanCard Id and SA count
				  // RS 14.3.2019 Commented For FSl enhancement because we do not need to show number of SA in activity resource utilization 
				  //map<String,Integer> mapSA = new map<String,Integer>();			  
				  
				  				  
				  for(sObject sa : ar.getSobjects('ServiceAppointments')){	
					   //get WorkOrder Id
					   String workOrderId = String.valueof(sa.getSobject('ServiceAppointment').get('ParentRecordId'));            		              
					   if(workOrderId != null ){	  
							if(woMap.get(workOrderId) != null){	
								// get KanbanCard Id
								String kanbanCardId = String.valueof(woMap.get(workOrderId).get('KanbanCard__c'));                   
								//Integer i = mapSA.containskey(kanbanCardId) ? mapSA.get(kanbanCardId) + 1 : 1 ;
								//mapSA.put(kanbanCardId,i);
								
								// RS 14.3.2019 Modification For FSl enhancement 
								leankor.KanbanToGanttController.MasterContainer CardFSL = new leankor.KanbanToGanttController.MasterContainer();
								CardFSL.ResourceId = String.valueof(ar.get('RelatedRecordId'));
								CardFSL.TaskId =  createGuid();
								//CardFSL.Units = 50;
								//CardFSL.SACount = mapSA.get(kanbanCardId);
								CardFSL.Type = 'FSL';
								CardFSL.Id = createGuid();
								CardFSL.cardId = kanbanCardId;
								resultlist.ResourceAssignmentList.add(CardFSL);
								
								//RS 14.3.2019 Creating map of service appointments with taskid as key
								mapOfsObject.put(CardFSL.TaskId,sa);
									
								//Store user Id and card Id for getting User and KanbanCard Records
								setOfUserID.add(String.valueof(ar.get('RelatedRecordId')));
								fslKanbanCardIds.add(kanbanCardId);
								
							}
					   }
				  }
			}
        }
		// 25.04.2018 - getting FSL resource
		
		
		/*SS 31.01.2019*/
		
		//Limit is set to 4999 because aggregate query covers all records before filtering
		//ON RM for showing halo of misaligned activity UI needs min and max date of miniatures
		Map<String, AggregateResult> aggDataMap = new Map<String, AggregateResult>();
		List<AggregateResult> resAgg  = [Select Min(leankor__StartDateTime__c) minStartDate, 
												Max(leankor__DueDateTime__c) maxDueDate,  
												leankor__valuestreamCardLink__c parentId    
											From leankor__KanbanCard__c 
											Where leankor__ValuestreamCardLink__c In: setOfKCID
												And leankor__ValuestreamCardLink__r.leankor__BoardType__c='UberBoard'
												And leankor__BoardType__c != 'UberBoard'  
												And leankor__IsRecordDeleted__c = false
												And leankor__Valuestream__r.leankor__IsTemplateBoard__c =false 
												And leankor__MasterContainer__r.leankor__Type__c != 'Template'
											With Security_Enforced
											Group By leankor__valuestreamCardLink__c 
											Limit 5000];
		for(AggregateResult aggregateRecord : resAgg){
			 aggDataMap.put((String)aggregateRecord.get('parentId'), aggregateRecord);							 
		}
		
		/*SS 30.08.2018*/
		//leankor__Valuestream__r.leankor__ProjectRoom__c field in query
		// YJ-24.05.2018 - Added field for Linked Icon on RM
        for (leankor__KanbanCard__c allocationlog: [Select Id,
															leankor__ValueStreamCardLink__c,
															leankor__ValueStream__r.leankor__ProjectRoom__c,
															leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
															leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__r.Name,
															Name,
															OwnerId,
															leankor__DueDateTime__c,
															leankor__DurationUnits__c,
															leankor__EstimatedDuration__c,
															leankor__GUID__c,
															leankor__PercentComplete2__c,
															leankor__StartDateTime__c,
															leankor__Title__c,
															leankor__ValueStream__c, 
															Owner.Name,
        													leankor__ValueStream__r.leankor__Boardtype__c,
															leankor__Folder__c,
															leankor__ProjectRoom__c,
															leankor__ValueStream__r.UserRecordAccess.HasEditAccess,
															leankor__Valuestream__r.leankor__ProjectRoom__r.UserRecordAccess.HasEditAccess,
															leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
															(Select Id, 
																leankor__ManuallyScheduled__c, 
																leankor__Mode__c, 
																leankor__EffortUnits__c, 
																leankor__EffortActual__c
															From leankor__ScheduleModes__r
															Limit 1)
														From leankor__KanbanCard__c
														Where Id In: setOfKCID]){           	
        	// making record for Leankor
            leankor.KanbanToGanttController.MasterContainer CardLog = new leankor.KanbanToGanttController.MasterContainer();
            cardlog.Id = allocationlog.ID;
            cardlog.Name = allocationlog.Name;          
            cardlog.ForceID = allocationlog.Id;    
            cardlog.DurationUnits = allocationlog.leankor__DurationUnits__c;
            cardlog.Title = allocationlog.leankor__Title__c;
            cardlog.ValueStreamID = allocationlog.leankor__ValueStream__c;          
            cardlog.GUID = allocationlog.leankor__GUID__c;          
            cardlog.StartDate = JSON.Serialize(allocationlog.leankor__StartDateTime__c);
            cardlog.DueDate = JSON.Serialize(allocationlog.leankor__DueDateTime__c);
            cardlog.PercentDone = allocationlog.leankor__PercentComplete2__c;
            cardlog.leaf = true;
            cardlog.EstimatedDuration = allocationlog.leankor__EstimatedDuration__c;         
            cardlog.OwnerID = allocationlog.OwnerId;
            cardlog.ItemType = 'ActivityCard';
            cardlog.BoardType = allocationlog.leankor__ValueStream__r.leankor__Boardtype__c;
            cardlog.OwnerName = allocationlog.Owner.Name;
            cardlog.SevenDayWorkWeek = allocationlog.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c;
            CardLog.ProjectRoomName=  allocationlog.leankor__ProjectRoom__c; //RS 17/4/2018 For showing ProjectName on Resource Utilization page. 
            cardlog.Type = 'Leankor';
            
			// YJ-24.05.2018 - Added Variable for Linked Icon on RM
            cardlog.ParentProjectRoomID = allocationlog.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c;
            cardlog.parentProjectRoomName = allocationlog.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__r.Name;
            cardlog.isLinked = allocationlog.leankor__ValueStreamCardLink__c != null ? (allocationlog.leankor__ValueStream__r.leankor__ProjectRoom__c != allocationlog.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c ? true : false) : false;          
            // YJ-24.05.2018
			/*SS 30.08.2018*/
			//Added projectRoomId to KanbanCard object for PG activity
			cardLog.ProjectRoomID = cardlog.BoardType == 'UberBoard' ? allocationLog.leankor__Valuestream__r.leankor__ProjectRoom__c: null;
           //Date : 09/05/19 use to security.
            cardlog.hasEditAccess= allocationLog.leankor__ValueStream__r.UserRecordAccess.HasEditAccess;
            if(aggDataMap.size() > 0 && aggDataMap.containsKey(cardLog.Id)){
            	cardlog.minStartDate =(DateTime) aggDataMap.get(cardlog.Id).get('minStartDate');
            	cardlog.maxDueDate = (DateTime) aggDataMap.get(cardlog.Id).get('maxDueDate');
            }
            if (allocationlog.leankor__ScheduleModes__r.size() > 0){
                cardlog.ManuallyScheduled = allocationlog.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
                cardlog.SchedulingMode = allocationlog.leankor__ScheduleModes__r[0].leankor__Mode__c;
                cardlog.Effort = allocationlog.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
                cardlog.EffortUnit = allocationlog.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
                resultlist.ResourceCards.add(cardlog);
            }
            
        }
            if(checkFSL){
			// SS 19.12.2018 If Fsl is enabled then get FSL data count for fsl related cards
			// RS 19.3.2019 no need to call this method		
	    	//Map<String, FieldServiceUtilityController.RecordDetails> fslDataInfo = FieldServiceUtilityController.readCardsFSLInfo(new List<String>(fslKanbanCardIds),'KC');
			//SS 30.08.2018 leankor__Valuestream__r.leankor__ProjectRoom__c field in query
	        // 25.04.2018 - getting FSL resource cards
	        map<Id,leankor__KanbanCard__c> cardMap = new map<Id,leankor__KanbanCard__c>([Select Id, 
																									Name,
																									OwnerId,
																									leankor__DueDateTime__c,
																									leankor__DurationUnits__c,
																									leankor__EstimatedDuration__c,
																									leankor__GUID__c,
																									leankor__PercentComplete2__c,
																									leankor__StartDateTime__c,
																									leankor__Title__c,
																									leankor__ValueStream__c, 
																									Owner.Name,        
																									leankor__ValueStream__r.leankor__Boardtype__c,
																									leankor__Folder__c,
																									leankor__ProjectRoom__c,
																									leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
																									leankor__Valuestream__r.leankor__ProjectRoom__c,
																									(Select Id, 
																										leankor__ManuallyScheduled__c, 
																										leankor__Mode__c, 
																										leankor__EffortUnits__c, 
																										leankor__EffortActual__c
																										From leankor__ScheduleModes__r
																										Limit 1)
																								From leankor__KanbanCard__c
																								Where Id In: fslKanbanCardIds]);
			//making records as FSL resource							            
	        for(leankor.KanbanToGanttController.MasterContainer rs : resultlist.ResourceAssignmentList){           	
	        	if(rs.Type == 'FSL'){
	        		// RS 14.3.2019 Modification For FSl enhancement 
		        	leankor__KanbanCard__c allocationlog = cardMap.get(rs.cardId);
		        	
		        	/* RS 14.3.2019 commented For FSl enhancement 
		        	rs.TaskId =  createGuid();
		            cardlog.DurationUnits = allocationlog.leankor__DurationUnits__c;		                      
		            cardlog.StartDate = JSON.Serialize(allocationlog.leankor__StartDateTime__c);
		            cardlog.DueDate = JSON.Serialize(allocationlog.leankor__DueDateTime__c);
		            cardlog.PercentDone = allocationlog.leankor__PercentComplete2__c;		            
		            cardlog.EstimatedDuration = allocationlog.leankor__EstimatedDuration__c;         
		            cardlog.OwnerID = allocationlog.OwnerId;
		            cardlog.OwnerName = allocationlog.Owner.Name; */ 		            
		            	            	
	            	sobject sa1 = mapOfsObject.get(rs.TaskId);
		            leankor.KanbanToGanttController.MasterContainer CardLog = new leankor.KanbanToGanttController.MasterContainer();
		            cardlog.Id = rs.TaskId;
		            cardlog.Name = allocationlog.Name;
		            cardlog.ForceID = allocationlog.Id;
		            cardlog.Title = allocationlog.leankor__Title__c;
		            cardlog.ValueStreamID = allocationlog.leankor__ValueStream__c;          
		            cardlog.GUID = allocationlog.leankor__GUID__c;
		            cardlog.leaf = true;    
		            sobject serviceApp = sa1.getSobject('ServiceAppointment') ; 
		            cardlog.DurationUnits = string.ValueOf(serviceApp.get('DurationType'));			            
		            cardlog.Description = string.ValueOf(serviceApp.get('Description'));
		            cardLog.saAppointmentNumber =  string.ValueOf(serviceApp.get('AppointmentNumber'));			                      
		            cardlog.StartDate = JSON.Serialize(serviceApp.get('SchedStartTime'));
		            cardlog.DueDate = JSON.Serialize(serviceApp.get('SchedEndTime'));
		            cardlog.EstimatedDuration = Integer.ValueOf(serviceApp.get('Duration'));         
		            cardlog.OwnerID = string.ValueOf(serviceApp.get('OwnerId'));
		            cardlog.ItemType = 'ActivityCard';
		            cardlog.BoardType = allocationlog.leankor__ValueStream__r.leankor__Boardtype__c;
		            cardlog.OwnerName = string.ValueOf(serviceApp.getSobject('Owner').get('Name'));
		            cardlog.SevenDayWorkWeek = allocationlog.leankor__Valuestream__r.leankor__SevenDayWorkWeek__c;
		            CardLog.ProjectRoomName=  allocationlog.leankor__ProjectRoom__c; 
		            cardlog.Type = 'FSL';
					cardLog.ProjectRoomID = cardlog.BoardType == 'UberBoard' ? allocationLog.leankor__Valuestream__r.leankor__ProjectRoom__c: null;
					//If kc have FSL then add info with instance
					
					// RS 19.3.2019 Modification For FSl enhancement 				
					//cardLog.workOrderCount = fslDataInfo.containsKey(cardLog.ForceID) ? fslDataInfo.get(cardLog.ForceID).workOrderCount : 0;
					//cardLog.serviceAppointmentCount = fslDataInfo.containsKey(cardLog.ForceID) ? fslDataInfo.get(cardLog.ForceID).serviceAppointmentCount!=null ? fslDataInfo.get(cardLog.ForceID).serviceAppointmentCount  : null : 0;
					//cardLog.fslSchedStartDateTime = fslDataInfo.containsKey(cardLog.ForceID) ?  fslDataInfo.get(cardLog.ForceID).fslSchedStartDateTime!=null ? fslDataInfo.get(cardLog.ForceID).fslSchedStartDateTime : null : null;
					//cardLog.fslSchedDueDateTime = fslDataInfo.containsKey(cardLog.ForceID) ? fslDataInfo.get(cardLog.ForceID).fslSchedDueDateTime!=null ? fslDataInfo.get(cardLog.ForceID).fslSchedDueDateTime: null : null;						
					
					// RS 14.3.2019 Earlier we were assigning min and max dates of service appointment but now using activity dates.
					cardLog.fslSchedStartDateTime = allocationlog.leankor__StartDateTime__c;
					cardLog.fslSchedDueDateTime =  allocationlog.leankor__DueDateTime__c;						
					
		            if (allocationlog.leankor__ScheduleModes__r.size() > 0){
		                cardlog.ManuallyScheduled = allocationlog.leankor__ScheduleModes__r[0].leankor__ManuallyScheduled__c;
		                cardlog.SchedulingMode = allocationlog.leankor__ScheduleModes__r[0].leankor__Mode__c;
		                cardlog.Effort = allocationlog.leankor__ScheduleModes__r[0].leankor__EffortActual__c;
		                cardlog.EffortUnit = allocationlog.leankor__ScheduleModes__r[0].leankor__EffortUnits__c;
		                resultlist.ResourceCards.add(cardlog);
		            }		            
	            
        	}
	        }
        }
        
        if (InputRMlog.isprojectfilter || InputRMlog.UserIDs.size()>0)
        {
			/*SS 03.09.2018*/
			//Add user details in any case, either user does not have any Cards or RA
			resultlist.ResourceUsers.addAll([Select ID, Name, IsActive FROM User WHERE ID IN: setOfUserID or Id IN: InputRMlog.UserIDs]);           
        }
        
        // adding business hour data according to user 
        List<ResourceCalendar>  getResourceHourdata = getBusinessHourData();
        List<UserData> resourceData = new List<UserData>();
        
        for(User ur : resultlist.ResourceUsers)
        {
           UserData UD = new UserData();
           UD.UserRecord = ur;
           UD.ResourceHoursData = new List<leankor.ResourceGanttController.ResourceCalendar>();
           UD.ResourceHoursData.addAll(getResourceHourdata);     
           resourceData.add(UD);           
        }            
        resultlist.ResourceUsersData = resourceData;      
        resultlist.ResourceUsers.clear();    
        return resultlist;
    }
    public static String createGuid() {
        Blob generatedBlob = Crypto.GenerateAESKey(128);
        String hex = EncodingUtil.ConvertTohex(generatedBlob);
        String guid = hex.substring(0, 8)
            + '-' + hex.substring(8, 12)
            + '-' + hex.substring(12, 16)
            + '-' + hex.substring(16, 20)
            + '-' + hex.substring(20);
        return guid;
    }
    
    //Have to deprecated 
    @ RemoteAction
    global static ResourceAssignmentlog getResourcesByUser(ResourceAssignmentInputlog InputRMlog){
      return new ResourceAssignmentlog();
    }
    //
    
    //
    global class ResourceAssignmentCreateDelete{
        global List <String> deleteId = new List <String>();
        global list < leankor.KanbanToGanttController.MasterContainer > newData = new list < leankor.KanbanToGanttController.MasterContainer > ();
    }
    
    @remoteaction
    global static list < leankor.KanbanToGanttController.MasterContainer > CreateAndDeleteResourceAssignment(ResourceAssignmentCreateDelete RSAlog) {
        for(String deletedResourceId : RSAlog.deleteId){
			if (String.isNotBlank(deletedResourceId) && Util.getSObjectName(deletedResourceId) != 'leankor__ResourceAssignment__c') {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		ResourceAssignmentBehavior checkResourceAssignmentBehavior = new ResourceAssignmentBehavior();
		KanbanCardBehaviour checkKanbanCardBehaviour = new KanbanCardBehaviour();
		RealtimeTrackerBehavior checkRealtimeTrackerBehavior = new RealtimeTrackerBehavior();
		if (!checkResourceAssignmentBehavior.isCreateable() ||
			!checkResourceAssignmentBehavior.isUpdateable() ||
			!checkKanbanCardBehaviour.isUpdateable() ||
			!checkRealtimeTrackerBehavior.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
		}

    	List <leankor__ResourceAssignment__c> resourceList = new List<leankor__ResourceAssignment__c>();
		for (leankor__ResourceAssignment__c resourceAssignment : [Select Id,
																		leankor__KanbanCard__c,
																		leankor__AssignedTo__c,
																		leankor__ResourceType__c,
																		leankor__ProjectFinancial__c
																		From leankor__ResourceAssignment__c 
																	Where Id In: RSAlog.deleteId
																	With Security_Enforced
																	Limit 10000]) {
			resourceAssignment.leankor__KanbanCard__c = null;
			resourceAssignment.leankor__AssignedTo__c = null;
			resourceAssignment.leankor__ResourceType__c = null;
			resourceAssignment.leankor__ProjectFinancial__c = null;
			resourceList.add(resourceAssignment);
		}
        
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            update resourceList;
        } catch (DMLException ex) {
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        list < leankor.KanbanToGanttController.MasterContainer > result = new list < leankor.KanbanToGanttController.MasterContainer > ();     
        list < leankor__ResourceAssignment__c > Insertlog = new list < leankor__ResourceAssignment__c > ();
		List<String> kanbancardIds = new List<String>();

        for (leankor.KanbanToGanttController.MasterContainer RA: RSAlog.newData) {          
            leankor__ResourceAssignment__c RSA = new leankor__ResourceAssignment__c();
            RSA.leankor__KanbanCard__c = RA.TaskId;
            RSA.leankor__AssignedTo__c = RA.ResourceId;
            RSA.leankor__PercentAllocation__c = RA.Units;
            RSA.leankor__PercentCompleted__c = RA.PercentDone;
            Insertlog.add(RSA);
            kanbancardIds.add(RA.TaskId);                              
        }
        
        /* updating kanban card owner id as RA resource ID.*/   
        list<leankor__KanbanCard__c> kanbancardlist = new list<leankor__KanbanCard__c>();
        map<Id,leankor__KanbanCard__c> kanbancardmap = new map<Id,leankor__KanbanCard__c>([Select 
																								Id,
																								leankor__ProjectRoom__c,
																								leankor__ValueStream__r.Name,
																								Name,
																								leankor__ValueStream__c,
																								leankor__BoardType__c 
																							From leankor__KanbanCard__c 
																							Where Id In: kanbancardIds]);       
        
        List<leankor.realtimeController.ChatterFeed> CFeeds = new List<leankor.realtimeController.ChatterFeed>();
        
        for(leankor.KanbanToGanttController.MasterContainer RA: RSAlog.newData){ 
        	    //only for kanban cards  	        		
        		if (kanbancardmap.get(RA.TaskId).leankor__BoardType__c != 'UberBoard') {
        			leankor__KanbanCard__c kc = new leankor__KanbanCard__c();
            		kc.Id = RA.TaskId;
            		kc.OwnerId = RA.ResourceId;
            		kanbancardlist.add(kc);
            		
            		if (RA.ResourceId != UserInfo.getUserId()) {
	            		//sending email to new user of kanban card
	            		leankor__KanbanCard__c card = kanbancardmap.get(RA.TaskId);           		
	            		leankor.realtimeController.ChatterFeed CFeed = new leankor.realtimeController.ChatterFeed();                 
	                    CFeed.KanbanID = card.Id;
	                    CFeed.KanbanTitle = card.Name;
	                    
	                    CFeed.ProjectBoardName = card.leankor__ProjectRoom__c +' / '+ card.leankor__ValueStream__r.Name;
	                    
	                    CFeed.KanbanURL ='https://' + DomainCreator.getOrgMyDomainHostname();                   
	                    //Need to checking board type here to make correct url for the Kanban Card.
	                    if (card.leankor__BoardType__c == 'Kanban Board' || card.leankor__BoardType__c == 'Plan Board') {
	                        CFeed.KanbanURL += (new PageReference('/apex/leankor__KanbanBoard').getUrl()) + '?Id=' + card.leankor__ValueStream__c + '&cardid=';
	                    } else if (card.leankor__BoardType__c == 'Portfolio View') {
	                        CFeed.KanbanURL += (new PageReference('/apex/leankor__PortfolioView').getUrl()) + '?Id=' + card.leankor__ValueStream__c + '&cardid=';
	                    } else{
	                        CFeed.KanbanURL += (new PageReference('/apex/leankor__VisualKanban').getUrl()) + '?Id=' + card.leankor__ValueStream__c + '&cardid=';
	                    }                    
	                    CFeed.AssignedUser = RA.ResourceId;                 
	                    CFeeds.add(CFeed);
            		}
        		}
        }
        try {        	
	       	DataBase.update(kanbancardlist, true);      	
            DataBase.insert(insertLog, true);          
        } catch (DMLException ex) {
        	
        	Database.rollback(sp);       	        	        	
            leankor.KanbanToGanttController.MasterContainer resultlog = new leankor.KanbanToGanttController.MasterContainer();
            resultlog.Name = ex.getMessage();
            result.add(resultlog);
            
            if((ex.getMessage()).containsIgnoreCase('TRANSFER_REQUIRES_READ')){
            	throw new GanttTaskBoard.LeanException('Insufficient privileges to change the ownership of this record. Please contact your Admin');
        	}
            
            //return result;
			//25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        
        for (leankor__ResourceAssignment__c RAdata: insertLog){
            leankor.KanbanToGanttController.MasterContainer resultlog = new leankor.KanbanToGanttController.MasterContainer();
            resultlog.Id = RAdata.Id;
            resultlog.ResourceId = RAdata.leankor__AssignedTo__c;
            resultlog.Units = RAdata.leankor__PercentAllocation__c;
            resultlog.TaskId = RAdata.leankor__KanbanCard__c;
            resultlog.Type = 'Leankor';
            result.add(resultlog);
        }
        //sending email to new user of kanban card
        leankor.realtimeController.createChatterFeed(CFeeds, 'CreateKanbanCard');
        
        if(insertLog.size()>0)
        {
	        //broadcast from RS to MyWork for change to resource owner 
	        leankor.realTimeController.JSONGroup MyJSONGroup = new leankor.realTimeController.JSONGroup();
	        
	        leankor.GanttTaskBoard.ResourceAssignment resourceData = new leankor.GanttTaskBoard.ResourceAssignment();
	        resourceData.verb = 'CreateResourceAssignment';
	        resourceData.Id = insertLog[0].Id;
	        resourceData.Name = insertLog[0].Name;
	        resourceData.ResourceId = insertLog[0].leankor__AssignedTo__c;
	        resourceData.Units = insertLog[0].leankor__PercentAllocation__c;
	        resourceData.TaskId = insertLog[0].leankor__KanbanCard__c;
	        
	        leankor__RealtimeTracker__c aRealtimeTracker = new leankor__RealtimeTracker__c();
	        
	        aRealtimeTracker.leankor__ValueStream__c = null;
	        aRealtimeTracker.leankor__SessionID__c = userInfo.getSessionId();
	        aRealtimeTracker.leankor__KanbanVerb__c = 'LeankorNAV';// verb for MainNAV page = LeankorNAV, create new verb for project gantt
		    
		           
	        if (!leankor.realTimeController.putJSONGroup(JSON.serialize(resourceData), MyJSONGroup)){
	            // string was too large
	            System.debug('ERROR: JSON String too large for broadcasting  for NAVpage ' );
	        }else {       	
	            insert  GenericStreamingController.assignJsonData(aRealtimeTracker, myJSONGroup);           
	        }
			if (IS_USING_PLATFORM_EVENT) {
				//Create Broadcast Event and Publish to end Users
				LeankorOperationController.sendBroadcast('LeankorNAV', JSON.serialize(resourceData), UserInfo.getSessionId());
			}
		}
        return result;
    }
    
    
    global class ResourceCalendar
    {   
         global String Type;
         global Date ResourceDate;
         global Date OverrideStartDate;
         global Date OverrideEndDate;
         global Integer Weekday;
         global List<String> Availability;
         global Boolean IsWorkingDay;
         global String Name;
         global boolean isDailyWeekDayHoliday;
         public DateTime OverrideStartDateWithTime;
         public DateTime OverrideEndDateWithTime;                        
    }   
    /*global class GlobalHourWork
    {
      global Date EndDate;
      global Date StartDate;
      global List<ResourceCalendar> GlobalHour; 
    }
    */  
    public static List<ResourceCalendar> getBusinessHourData() {  
		/*if (!leankor__GlobalWorkHour__c.sObjectType.getDescribe().isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		}*/ 
        List<ResourceCalendar> globalfinalresult = new List<ResourceCalendar>();            
        //getting globalWorkHour record
        List<leankor__GlobalWorkHour__c> businessHourList = [Select leankor__BusinessHours__r.SundayStartTime,
																	leankor__BusinessHours__r.SundayEndTime,
																	leankor__BusinessHours__r.MondayStartTime,
																	leankor__BusinessHours__r.MondayEndTime,
																	leankor__BusinessHours__r.TuesdayStartTime,
																	leankor__BusinessHours__r.TuesdayEndTime,
																	leankor__BusinessHours__r.WednesdayStartTime,
																	leankor__BusinessHours__r.WednesdayEndTime,
																	leankor__BusinessHours__r.ThursdayStartTime,
																	leankor__BusinessHours__r.ThursdayEndTime,
																	leankor__BusinessHours__r.FridayStartTime,
																	leankor__BusinessHours__r.FridayEndTime,
																	leankor__BusinessHours__r.SaturdayStartTime,
																	leankor__BusinessHours__r.SaturdayEndTime,
																	leankor__EndDate__c,
																	leankor__StartDate__c
																From leankor__GlobalWorkHour__c
																Order By Name ASC  
																Limit 49999];
             
        // getting all holidays 
        List<Holiday> holidayList = [Select ActivityDate,
											EndTimeInMinutes,
											Id,
											IsAllDay,
        									IsRecurrence,
											LastModifiedById,
											LastModifiedDate,
        									Name,
											RecurrenceDayOfMonth,
											RecurrenceDayOfWeekMask,
        									RecurrenceEndDateOnly,
											RecurrenceInstance,
											RecurrenceInterval,
        									RecurrenceMonthOfYear,
											RecurrenceStartDate,
        									RecurrenceType,
											StartTimeInMinutes 
										From Holiday];
               									      								      		        									        									           
        try
        {
            for(leankor__GlobalWorkHour__c GWH :BusinessHourList)
            {                                                     
                
               if(GWH.leankor__BusinessHours__c != null )
               {                  
	                // all seven day of week for formating according to LeankorGanttJS 
	                for(Integer i=0;i<=6;i++)
	                {                              
	                        ResourceCalendar rc = new ResourceCalendar();
	                        rc.Availability = new List<String>();               
	                        rc.Type = 'WEEKDAYOVERRIDE';                
	                        rc.Weekday = i;
	                        rc.OverrideStartDate = GWH.leankor__StartDate__c;
                        	rc.OverrideEndDate  = GWH.leankor__EndDate__c; 
	                        rc.OverrideStartDateWithTime = datetime.newInstance(GWH.leankor__StartDate__c.year(), GWH.leankor__StartDate__c.month(),GWH.leankor__StartDate__c.day(),14,0,0);
	                        rc.OverrideEndDateWithTime  = datetime.newInstance(GWH.leankor__EndDate__c.year(), GWH.leankor__EndDate__c.month(),GWH.leankor__EndDate__c.day(),14,0,0);               
	                        Time starttime = null;
	                        Time endtime = null;                                        
	                        if(i==0){   
	                            starttime = GWH.leankor__BusinessHours__r.SundayStartTime;
	                            endtime = GWH.leankor__BusinessHours__r.SundayEndTime;                                       
	                        }
	                        else if(i==1){
	                            starttime = GWH.leankor__BusinessHours__r.MondayStartTime;
	                            endtime = GWH.leankor__BusinessHours__r.MondayEndTime;                       
	                        }
	                        else if(i==2){
	                            starttime = GWH.leankor__BusinessHours__r.TuesdayStartTime;
	                            endtime = GWH.leankor__BusinessHours__r.TuesdayEndTime;                          
	                        }
	                        else if(i==3){
	                            starttime = GWH.leankor__BusinessHours__r.WednesdayStartTime;
	                            endtime = GWH.leankor__BusinessHours__r.WednesdayEndTime;    
	                                        
	                        }
	                        else if(i==4){
	                            starttime = GWH.leankor__BusinessHours__r.ThursdayStartTime;
	                            endtime = GWH.leankor__BusinessHours__r.ThursdayEndTime;     
	                        }
	                        else if(i==5){
	                            starttime = GWH.leankor__BusinessHours__r.FridayStartTime;
	                            endtime = GWH.leankor__BusinessHours__r.FridayEndTime;                                       
	                        }
	                        else{
	                            starttime = GWH.leankor__BusinessHours__r.SaturdayStartTime;
	                            endtime = GWH.leankor__BusinessHours__r.SaturdayEndTime;                 
	                        }
	                        
	                        if(starttime != null){
	                            //any week day Availability will be 24 hours
	                            if(starttime.hour() == 0 && endtime.hour() == 0 && starttime.minute() == 0 && endtime.minute() == 0 )
	                            {
	                                rc.Availability.add('00:00-24:00');//according to LeankorGanttJS format
	                            }
	                            else            
	                            {
	                            String countStart = (starttime.hour()==0 ? 1 : (Integer)Math.log10(Math.abs(starttime.hour()))+1) == 1 ? 0+''+starttime.hour(): String.valueof(starttime.hour()) ;
	                            String countEnd = (endtime.hour()==0 ? 1 : (Integer)Math.log10(Math.abs(endtime.hour()))+1) == 1 ? 0+''+endtime.hour() : String.valueof(endtime.hour());
	                            String countStartMin = (starttime.minute()==0 ? 1 : (Integer)Math.log10(Math.abs(starttime.minute()))+1) == 1 ? 0+''+starttime.minute() : String.valueof(starttime.minute());
	                            String countEndMin = (endtime.minute()==0 ? 1 : (Integer)Math.log10(Math.abs(endtime.minute()))+1) == 1 ? 0+''+endtime.minute() : String.valueof(endtime.minute());
	                            
		                            if( (starttime.hour() != 0 || starttime.minute() != 0 ) && endtime.hour() == 0 )
		                            {
		                            	rc.Availability.add(countStart+':'+countStartMin +'-'+'24:00');	                            
		                            }else
		                            {	                          
		                            	rc.Availability.add(countStart+':'+countStartMin +'-'+countEnd+':'+countEndMin);
		                            }                    
	                            }
	                            rc.IsWorkingDay = true;
	                        }   
	                        else{
	                            rc.Availability.add('00:00-00:00');
	                            rc.IsWorkingDay = false;                    
	                        }   
	                        globalfinalresult.add(rc);        
	                   }
                }else
                {
                   
                   ResourceCalendar rc = new ResourceCalendar();
                   rc.Name = 'BusinessHour is not Available';
                   globalfinalresult.add(rc);
                
                }
                   
                //getting holidays and making format according to LeankorGanttJS format                                                            
                //globalfinalresult.addAll(getHolidaydata(holidayList,GWH));                                                                                                                                                                                     
            }                                       
        } catch(Exception e) {   
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }           
        return globalfinalresult;           
    }
    
}