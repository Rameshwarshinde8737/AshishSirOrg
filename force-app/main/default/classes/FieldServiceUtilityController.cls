/* Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: FieldServiceUtilityController .cls
 * CLASS: FieldServiceUtilityController 
 */
Global with sharing class FieldServiceUtilityController {

    public FieldServiceUtilityController(Util controller) {}


    public FieldServiceUtilityController(ApexPages.StandardController controller) {}

    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Getting WorkOrder records of kanbancards
    Inputs:         List of KanbanCard Ids
    Returns:        List<WorkOrderType>
    ------------------------------------------------------------*/
    @Readonly
    @RemoteAction
    global static List<KanbanController.WorkOrderType> getWorkOrderRecords(List<String> kanbanCardIds){
        //Added Security code for sentize user Input
        for (String kanbanCard : kanbanCardIds) {
            if (String.isNotBlank(kanbanCard) && Util.getSObjectName(kanbanCard)!= 'leankor__KanbanCard__c') {
                throw new Util.LeanException('Error: Invalid input');
            }
        }             
        List<KanbanController.WorkOrderType> typelist = new List<KanbanController.WorkOrderType>();                     
        try{
                                                            
            if (kanbanCardIds.size() > 0  && kanbanCardIds != null) {
                
              String soql1 = 'Select Id,';
              if (KanbanController.checkFSLManageApp()) {
              	soql1 += 'WorkType.Name,';
              }
             //soql1 += 'WorkOrderNumber, Subject From WorkOrder  where KanbanCard__c IN (' + KanbanController.listIdsToString(kanbanCardIds) + ')' + ' ORDER BY CreatedDate DESC limit 49999';
             soql1 += 'WorkOrderNumber, Subject From WorkOrder  where KanbanCard__c  In :kanbanCardIds Order By CreatedDate DESC limit 49999';

             List<sObject> WorkOrderList = Database.query(soql1);
            
             String jsonRecords = JSON.serialize(WorkOrderList);
            
             typelist = (List<KanbanController.WorkOrderType>)JSON.deserialize(jsonRecords,List<KanbanController.WorkOrderType>.class);                             
                            
          }
        }catch(Exception ex) {
            //return new List<KanbanController.WorkOrderType>();
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        }
        return typelist; 
                                        
    }
     /*------------------------------------------------------------
    Author:         Rahul Solanki
    Company:        Leankor
    Description:    Getting All WorkOrder records
    Inputs:         Offset number, filter value, limit to query
    Returns:        RecordDetails
    ------------------------------------------------------------*/
    @Readonly
    @RemoteAction
    global static RecordDetails getAllWorkOrders(Integer OffsetSize, String FilterValue, Integer Limits){
        String FilterVal = '%' + FilterValue + '%'; // It can be '' or any string.
        // getting count to manage paging or maximum number of user available on the basis filterValue. 
        
        //SS 12.12.2018
        //Separated logic for getting workOrder count 
        String countQuery = 'SELECT Count() FROM WorkOrder where WorkOrderNumber Like: FilterVal Or Subject Like: FilterVal';
        Boolean hasFSL= KanbanController.checkFSLManageApp();
        //Add WorkType filter only when FSL package is installed.
        if (hasFSL) {
        	countQuery += ' OR WorkType.Name Like: FilterVal'; 
        }
        integer count = database.countQuery(countQuery);
        List<KanbanController.FieldServiceLigtning> fslList = new List<KanbanController.FieldServiceLigtning>();
        RecordDetails Records = new RecordDetails();
        try{
        
        //String soql1 = 'SELECT KanbanCard__c,KanbanCard__r.leankor__Folder__c , KanbanCard__r.Name,KanbanCard__r.leankor__ValueStream__r.Name,KanbanCard__r.leankor__ProjectRoom__c,Subject,WorkOrderNumber,WorkType.Name FROM WorkOrder where WorkOrderNumber LIKE: FilterVal OR Subject LIKE: FilterVal OR WorkType.Name LIKE: FilterVal ORDER BY WorkOrderNumber DESC Limit: Limits offset: OffsetSize';      
        
        String soql1 = 'SELECT KanbanCard__c,KanbanCard__r.leankor__Folder__c , KanbanCard__r.Name,KanbanCard__r.leankor__ValueStream__r.Name,KanbanCard__r.leankor__ProjectRoom__c,Subject,WorkOrderNumber';
        if (hasFSL) {
        	soql1 += ' ,WorkType.Name';
        }
        soql1 +=' FROM WorkOrder where WorkOrderNumber Like: FilterVal OR Subject Like: FilterVal';
        if (hasFSL) {
        soql1 += ' OR WorkType.Name Like: FilterVal';
        }
        soql1 +=' ORDER BY WorkOrderNumber DESC Limit: Limits offset: OffsetSize';
        List<sObject> workOrderList = Database.query(soql1);          
                  
        for(sObject wo : workOrderList)
        {           
            KanbanController.FieldServiceLigtning fsl = new KanbanController.FieldServiceLigtning();
            fsl.workOrderNumber = wo.get('WorkOrderNumber') == null ? '' : String.valueof(wo.get('WorkOrderNumber'));
            fsl.workOrderId = wo.get('Id') == null ? '' : String.valueof(wo.get('Id'));
            fsl.WorkTypeName = hasFSL ? (wo.getSobject('WorkType')== null ? '':  String.valueof(wo.getSobject('WorkType').get('Name'))) : '' ;                  
            fsl.Subject = wo.get('Subject') == null ? '' : String.valueof(wo.get('Subject'));
            fsl.folderName = wo.getSobject('KanbanCard__r') == null ? '': String.valueof(wo.getSobject('KanbanCard__r').get('leankor__Folder__c'));
            fsl.projectName = wo.getSobject('KanbanCard__r') == null ? '': String.valueof(wo.getSobject('KanbanCard__r').get('leankor__ProjectRoom__c'));
            fsl.projectBoardName = wo.getSobject('KanbanCard__r') == null ? '': (wo.getSobject('KanbanCard__r').getSobject('leankor__ValueStream__r') == null?'': String.valueof(wo.getSobject('KanbanCard__r').getSobject('leankor__ValueStream__r').get('Name')));
            fsl.cardName =  String.isBlank(fsl.projectName) || String.isBlank(fsl.projectBoardName) || wo.getSobject('KanbanCard__r') == null ? '': String.valueof(wo.getSobject('KanbanCard__r').get('Name'));                
            fsl.cardId = String.isBlank(fsl.projectName) || String.isBlank(fsl.projectBoardName) || wo.get('KanbanCard__c') == null ? '' : String.valueof(wo.get('KanbanCard__c'));         
             
            fslList.add(fsl);           
        }
                                
        Records.Count = count; 
        Records.OffsetSize = OffsetSize;
        Records.FieldServiceLightning = fslList;    
                          
       } catch(Exception ex) {
       			//return new RecordDetails();
                //25/04/2023 : We are Throwing Exception
                throw new Util.LeanException('ERROR:' + ex.getMessage()); 
        }
        return Records;             
    }
    
    // This Is Inner Class For Record Details
    Global class RecordDetails {
       Public Integer Count;
       Public Integer OffsetSize;            
       Public List <KanbanController.FieldServiceLigtning> FieldServiceLightning ;
		//Need to show FSL data info with KC Card
        Public Integer workOrderCount;
        Public Integer serviceAppointmentCount;
        public DateTime fslSchedDueDateTime;
        public DateTime fslSchedStartDateTime;
    }
    
    /*------------------------------------------------------------
    Author:         Suraj Sen
    Company:        Leankor
    Description:    Update WorkOrder records
    Inputs:         List Of String
    Returns:        String (Success or Failure)
    ------------------------------------------------------------*/
    @RemoteAction
    global static boolean updateWorkOrder(List<String> WorkOrderRecordData){
        KanbanCardBehaviour checkKanbanCardBehaviour = new KanbanCardBehaviour();
        if (!checkKanbanCardBehaviour.isUpdateable() ) {
            return false;
        }
        List<sObject> sObjectList = new List<sObject>();
        if (!WorkOrderRecordData.isEmpty())
        {
        	try{            
	            for(String str : WorkOrderRecordData)
	            {
	                KanbanController.FieldServiceLigtning UpdateWOData = (KanbanController.FieldServiceLigtning)JSON.deserialize(str,KanbanController.FieldServiceLigtning.class);                                      
	                Schema.SObjectType workOrderSobject=Schema.getGlobalDescribe().get('WorkOrder');                  
	                Sobject NewWorkOrderSobject=workOrderSobject.newSObject(UpdateWOData.workOrderId);
	                NewWorkOrderSobject.put('KanbanCard__c', UpdateWOData.cardId);
	                sObjectList.add(NewWorkOrderSobject);                                                                                                                   
	            }
	            update sObjectList;   
	        }catch(Exception ex) {
	            //return false;
                //25/04/2023 : We are Throwing Exception
                throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
	        }
        }           
        return true ; 
    }
        
    /////This method is used to get FSL data info cards have
    @RemoteAction
    global static Map<String, FieldServiceUtilityController.RecordDetails> readCardsFSLInfo(List<String> ids, String recordType){
        
        List<sObject> sObjectList = new List<sObject>();
        Map<String, FieldServiceUtilityController.RecordDetails> fslRecordCount = new Map<String, FieldServiceUtilityController.RecordDetails>();
        Boolean hasFSL = KanbanController.checkFSLManageApp();
        if (!ids.isEmpty() && KanbanController.checkFieldExistInSobject()) {
			try {            
				String soql1 = 'Select KanbanCard__c, '; 
				if (hasFSL) {
					soql1+='(Select SchedStartTime, SchedEndTime From ServiceAppointments),';	
				}
				soql1 += ' Id From WorkOrder ';            
				if (recordType.containsIgnoreCase('Valuestream')) {
                    //soql1 += ' where KanbanCard__r.leankor__Valuestream__c IN (' + KanbanController.listIdsToString(new List<String>(ids)) + ')' + ' ORDER BY CreatedDate DESC limit 49999';
                    soql1 += ' where KanbanCard__r.leankor__Valuestream__c In :ids  Order By CreatedDate DESC limit 49999';

                } else {
                    //soql1 += ' where KanbanCard__c IN (' + KanbanController.listIdsToString(new List<String>(ids)) + ')' + ' ORDER BY CreatedDate DESC limit 49999';
                    soql1 += ' where KanbanCard__c In :ids  Order By CreatedDate DESC limit 49999';
                }
				List<sObject> sObjects = Database.query(soql1);
				if (sObjects.size()>0) {
					for (sObject sObj: sObjects) {
						FieldServiceUtilityController.RecordDetails rd = fslRecordCount.containsKey((String)sObj.get('KanbanCard__c')) ? fslRecordCount.get((String)sObj.get('KanbanCard__c')) : new FieldServiceUtilityController.RecordDetails();
						
						rd.workOrderCount = rd.workOrderCount!= null ? rd.workOrderCount+1: 1;
						if (hasFSL && sObj.getSobjects('ServiceAppointments') != null) {
							rd.serviceAppointmentCount =rd.serviceAppointmentCount!= null ? rd.serviceAppointmentCount : 0;
							rd.serviceAppointmentCount = rd.serviceAppointmentCount + ((List<Object>) sObj.getSobjects('ServiceAppointments')).size();
							for (sObject sob:sObj.getSobjects('ServiceAppointments')) {
							    rd.fslSchedStartDateTime = rd.fslSchedStartDateTime!= null ? (rd.fslSchedStartDateTime>((DateTime)sob.get('SchedStartTime')) ? ((DateTime)sob.get('SchedStartTime')) : rd.fslSchedStartDateTime) : (DateTime)sob.get('SchedStartTime');
								rd.fslSchedDueDateTime  = rd.fslSchedDueDateTime!= null ? (rd.fslSchedDueDateTime<((DateTime)sob.get('SchedEndTime')) ? ((DateTime)sob.get('SchedEndTime')) : rd.fslSchedDueDateTime)  : (DateTime)sob.get('SchedEndTime');
					        }
					    }
						fslRecordCount.put((String)sObj.get('KanbanCard__c'), rd);
					}
				}
			} catch(Exception ex) {
	            throw new GanttTaskBoard.LeanException('Exception : '+ex.getMessage());
	        }
		}      
		return FSLRecordCount;    
    }
}