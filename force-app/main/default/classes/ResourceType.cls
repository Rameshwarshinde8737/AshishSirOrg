/*  
   * 	FILE: ResourceType.cls
   *	CLASS: ResourceType 
   * 	Date :12/09/19
*/

Global with sharing class ResourceType {
			 
    public ResourceType(ApexPages.StandardSetController controller) {

    }


    public ResourceType(ApexPages.StandardController controller) {

    }

			 
	 public leankor__ResourceType__c resourceType {get; set;}	
	 public static final Boolean IS_MULTI_CURRENCY_ORGANIZATION = UserInfo.isMultiCurrencyOrganization();	
	 	
     //Default Constructor
     public ResourceType(String json) {
        this.resourceType = new leankor__ResourceType__c();
     }
    
    /*------------------------------------------------------------	
		Company: 		Leankor
		Description: 	get resourceType   data 
		Inputs: 		
		Returns: 		Map<Id, leankor__ResourceType__c>
		Date : 12/09/19
	------------------------------------------------------------*/ 
    // queries resource type records and returns a map of resource object per combined categories 
	 public static Map<Id, leankor__ResourceType__c> readResourceType(Set<Id> resourceTypeIds) {    
	 	    Map<Id, leankor__ResourceType__c> mapResourceType = new Map<Id, leankor__ResourceType__c>(); 
       		List<leankor__ResourceType__c> resourceTypes = new List<leankor__ResourceType__c>();    
            List<String> fieldNames = new List<String> {  
            		'Id', 
            	 	'Name', 
            	  	'leankor__InternalHourlyRate__c',  
            	  	'leankor__ExternalHourlyRate__c', 
            	   	'leankor__ExpenseCategory__c',
                    'leankor__ExpenseSubCategory__c',
                    'leankor__ExpenseAccount__c',
					'leankor__ProjectFinancial__c'
            }; 
            
        	if (IS_MULTI_CURRENCY_ORGANIZATION) { 
        	            fieldNames.add('CurrencyIsoCode');      
        	}      
        	try{ 
        	 	resourceTypes = Database.query('Select ' + String.join(fieldNames,', ') + ' From leankor__ResourceType__c  where Id In:resourceTypeIds Order By Name');  
        	 	for (leankor__ResourceType__c resourceType : resourceTypes) {  
        	 	 	mapResourceType.put(resourceType.Id, resourceType);
        	 	 }         
        	} catch(Exception e) {
       					 throw e;     
       	    
       		}          
       	 return mapResourceType;    
     } 
     /*
      	Date : 12/09/19
     */
     public static leankor__ResourceAssignment__c setResourceAccounts(Id resourceTypeId, Map<Id, leankor__ResourceType__c> resourceTypes, leankor__ResourceAssignment__c resourceAssignment) { 
      	    leankor__ResourceAssignment__c objectResourceAssignment = resourceAssignment; 
      	    try { 
      	    	if (resourceTypes.containsKey(resourceTypeId)) {
      	    	  		 	leankor__ResourceType__c assignedResourceType = resourceTypes.get(resourceTypeId);
      	    	  		 	objectResourceAssignment.leankor__ExpenseAccount__c = assignedResourceType.leankor__ExpenseAccount__c;
      	    	  		 	objectResourceAssignment.leankor__ExpenseSubCategory__c = assignedResourceType.leankor__ExpenseSubCategory__c; 
      	    	  		 	objectResourceAssignment.leankor__ExpenseCategory__c = assignedResourceType.leankor__ExpenseCategory__c;             
      	    	  		 	objectResourceAssignment.leankor__ExternalHourlyRate__c = assignedResourceType.leankor__ExternalHourlyRate__c;             
      	    	  		 	objectResourceAssignment.leankor__InternalHourlyRate__c = assignedResourceType.leankor__InternalHourlyRate__c;
      	    	  		 	objectResourceAssignment.leankor__ProjectFinancial__c = assignedResourceType.leankor__ProjectFinancial__c;
      	    	  	} else {
      	    	  			objectResourceAssignment.leankor__ExpenseAccount__c = null;
      	    	  			objectResourceAssignment.leankor__ExpenseSubCategory__c = null;
      	    	  			objectResourceAssignment.leankor__ExpenseCategory__c = null;          
      	    	  			objectResourceAssignment.leankor__ExternalHourlyRate__c = 0;   
      	    	  			objectResourceAssignment.leankor__InternalHourlyRate__c = 0;
      	    	  			objectResourceAssignment.leankor__ProjectFinancial__c = null;
      	    	  	}         
      	      }catch (Exception e) {  
      	    	  	           throw e;  
      	      }           
      	      return objectResourceAssignment;  
      
     }
     /*
      	Date : 12/09/19
     */    
     public static leankor__ResourceAssignment__c setResourceAccounts(Id resourceTypeId, Map<Id, leankor__ResourceType__c> resourceTypes, leankor__ResourceAssignment__c resourceAssignment, Boolean isMultiCurrency) { 
     	         leankor__ResourceAssignment__c objectResourceAssignment;
     	         try {
     	         	 	Map<String, Object> mapResourceAsignment = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resourceAssignment));
     	         	 	if (resourceTypes.containsKey(resourceTypeId)) {   
     	         	 		    leankor__ResourceType__c assignedResourceType = resourceTypes.get(resourceTypeId); 
     	         	 		    Map<String, Object> mapResourceType = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(assignedResourceType));     
     	         	 		    mapResourceAsignment.put('leankor__ExpenseAccount__c', mapResourceType.get('leankor__ExpenseAccount__c'));      
     	         	 		    mapResourceAsignment.put('leankor__ExpenseSubCategory__c', mapResourceType.get('leankor__ExpenseSubCategory__c'));      
     	         	 		    mapResourceAsignment.put('leankor__ExpenseCategory__c', mapResourceType.get('leankor__ExpenseCategory__c'));  
     	         	 		    mapResourceAsignment.put('leankor__ExternalHourlyRate__c', mapResourceType.get('leankor__ExternalHourlyRate__c')); 
     	         	 		    mapResourceAsignment.put('leankor__InternalHourlyRate__c', mapResourceType.get('leankor__InternalHourlyRate__c'));   
     	         	 		    mapResourceAsignment.put('CurrencyIsoCode', isMultiCurrency ? mapResourceType.get('CurrencyIsoCode') : '');    
     	         	 		    mapResourceAsignment.put('leankor__ProjectFinancial__c', mapResourceType.get('leankor__ProjectFinancial__c'));
     	         	 	 } else {   
     	         	 	 	     mapResourceAsignment.put('leankor__ExpenseAccount__c', null);                  
     	         	 	 	     mapResourceAsignment.put('leankor__ExpenseSubCategory__c', null);                  
     	         	 	 	     mapResourceAsignment.put('leankor__ExpenseCategory__c', null);                 
     	         	 	 	     mapResourceAsignment.put('leankor__ExternalHourlyRate__c', 0);                  
     	         	 	 	     mapResourceAsignment.put('leankor__InternalHourlyRate__c', 0);             
     	         	 	 	     mapResourceAsignment.put('CurrencyIsoCode', isMultiCurrency ? Util.getCurrencyIsoCode(new leankor__ResourceType__c()) : '');            
     	         	 	 	     mapResourceAsignment.put('leankor__ProjectFinancial__c', null);
						}           
     	         	 	 objectResourceAssignment = (leankor__ResourceAssignment__c)JSON.deserialize(JSON.serialize(mapResourceAsignment), leankor__ResourceAssignment__c.class); 
         		} catch (Exception e) {             
         				throw e;         
         		}          
         		return objectResourceAssignment;
         		
     }			
    /*---------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	Inner class to return resources
	-----------------------------------------------*/
	global class Resources {
		public string name ; 
		public string resourceTypeId;
		public string Id;		
	}
     
	/*---------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	Inner class to return resourcetype
	-----------------------------------------------*/
	global class ResourceTypes {
		public string name;		
		public string Id;
		public List<Resources> relatedResources; 	 	
	} 
	
    /*-----------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	Inner class for returning resource type data 
	------------------------------------------------------------*/ 
    global class ResourceTypesLog {
        public List < leankor.KanbanToGanttController.MasterContainer > resourceCards = new List < leankor.KanbanToGanttController.MasterContainer > ();
        public List < leankor.KanbanToGanttController.MasterContainer > resourceAssignments = new List < leankor.KanbanToGanttController.MasterContainer > ();
    	public Integer workingHoursPerDay;
    	//public List<leankor__ResourceType__c> resourceTypes = new List<leankor__ResourceType__c>();
    	public List<ResourceType.Resources> resources = new List<ResourceType.Resources>();
    	public Integer count;
        public Integer offsetSize;        
        public List<ResourceTypes> resourceTypes;        
    } 			
    
    /*-----------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	Inner class for input data 
	------------------------------------------------------------*/  
    global class ResourceTypesInputLog {
        global List<String> projectIds = new List<String>();
        global List<String> UserIDs = new List<String>();
        global boolean isProjectFilter;
        global String startDate;
        global String dueDate;
        global List<String> resourceTypeIds = new List<String>();   
    }
     


	/*-----------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	get resource types for capacity planning 
	Inputs: 		ResourceTypesInputLog inputRMlog
	Returns: 		ResourceTypesLog
	------------------------------------------------------------*/
    @remoteaction
    global static ResourceTypesLog readAllResourceTypes(ResourceTypesInputLog inputRMlog){
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!kanbanCardBehaviour.isAccessible()) {
			throw new Util.LeanException('Error: No access to records');
		} 
		for(String projectId : inputRMlog.projectIds){
            if (String.isNotBlank(projectId) && (Util.getSObjectName(projectId) != 'leankor__ProjectRoom__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
		
		for(String resourceTypeId : inputRMlog.resourceTypeIds){
            if (String.isNotBlank(resourceTypeId) && (Util.getSObjectName(resourceTypeId) != 'leankor__ResourceType__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        ResourceTypesLog resultList = new ResourceTypesLog();
        Integer hours = leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c == null 
						? 0 
						:Integer.valueof(leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c);        
        resultList.workingHoursPerDay = (hours <= 0 ? 8 :(hours > 24 ? 24 :hours));              
        
		Set<String> setKanbanIds = new Set<String>();
        Set<String> setResourceTypeIds = new Set<String>();
        Map<Id,leankor__ResourceAssignment__c> queriedResourcesMap = new Map<Id,leankor__ResourceAssignment__c>();
		Map<Id,leankor__ResourceAssignment__c> queriedResourcesAccToProjects = new Map<Id,leankor__ResourceAssignment__c>();
		Map<Id,leankor__ResourceAssignment__c> queriedResourcesAccToUsers = new Map<Id,leankor__ResourceAssignment__c>();
		Set<string> kanbanIds = new Set<string>();        
        Date beginDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(inputRMlog.startDate), DateTime.class));
        Date endDate = Date.valueOf((DateTime)JSON.deserialize(JSON.serialize(inputRMlog.dueDate), DateTime.class));
        Set<String> expenseAccount = new Set<String>();
        Set<String> expenseCategory = new Set<String>();
        Set<String> expenseSubCategory = new Set<String>();
        Map<String , Resources> userAndWrappedResourcesData = new Map<String , Resources>();
        List<ResourceTypes> resourceTypesList = new List<ResourceTypes>();
        Map<String,List<Resources>> resourceTypeAndResourceMap = new Map<String,List<Resources>>();
        		
		//For Resource Assignment Array 
		map<String,List<leankor__ResourceAssignment__c> > finalResourceTypeAndResourceAssignMap = new map<String,List<leankor__ResourceAssignment__c> >();		
		
        List<ResourceType.Resources> resourceList = new List<ResourceType.Resources>();        

        if (inputRMlog.resourceTypeIds.size() > 0){

			map<String,leankor__ResourceType__c> userAndResourceTypeMap = new map<String,leankor__ResourceType__c>();
			map<String,leankor__Resource__c> userResourceMap = new map<String,leankor__Resource__c>();
			map<String,leankor__ResourceType__c> resourceAndResourceTypeMap = new map<String,leankor__ResourceType__c>();
			// Get the Resource Type.
			Map<String,leankor__ResourceType__c> allResourceTypesMap = new Map<String,leankor__ResourceType__c>([Select 
																														leankor__ExpenseAccount__c,
																														leankor__ExpenseCategory__c,
																														leankor__ExpenseSubCategory__c,
																														Name 
																													From leankor__ResourceType__c 
																													Where Id In: inputRMlog.resourceTypeIds 
																													With Security_Enforced
																													Limit 50000]);

			for(leankor__ResourceType__c rt : allResourceTypesMap.values()){
				expenseAccount.add(rt.leankor__ExpenseAccount__c);
				expenseCategory.add(rt.leankor__ExpenseCategory__c);
				expenseSubCategory.add(rt.leankor__ExpenseSubCategory__c);
			}

			// Get the Resource
			Map<string, leankor__Resource__c> allResourcesMap = new Map<string, leankor__Resource__c>([Select 
																											leankor__ExpenseAccount__c,
																											leankor__User__c,
																											leankor__ExpenseCategory__c,
																											leankor__ExpenseSubCategory__c,
																											Name,								
																											leankor__User__r.Name 
																										From leankor__Resource__c 
																										Where leankor__ExpenseAccount__c In: expenseAccount 
																											And leankor__ExpenseCategory__c In: expenseCategory 
																											And leankor__ExpenseSubCategory__c In: expenseSubCategory
																										With Security_Enforced
																										Limit 50000]);

			// Extracting the related resources
			for(leankor__ResourceType__c resType : allResourceTypesMap.values()){
				for(leankor__Resource__c res : allResourcesMap.Values()){
					// Tilak: 12.03.2020 - Filterning the resource when no user is assigned on resource.
					if(String.isNotBlank(res.leankor__User__c) 
						&& (resType.leankor__ExpenseAccount__c == res.leankor__ExpenseAccount__c 
						&& resType.leankor__ExpenseCategory__c == res.leankor__ExpenseCategory__c 
						&& resType.leankor__ExpenseSubCategory__c == res.leankor__ExpenseSubCategory__c)){

						userAndResourceTypeMap.put(res.leankor__User__c ,resType );
						userResourceMap.put(res.leankor__User__c ,res );
						resourceAndResourceTypeMap.put(res.Id, resType);
					}
				}
			}

			// Get the resource assignment record for requested resourceType.	
			/*
			*Modified By :Ashutosh Gour
			*Modification : Modification for making SOQL selective and remove negative selection.
			*/
			for(leankor__ResourceAssignment__c resourceAssignment : [Select 
																		Id,
																		leankor__AssignedTo__c,
																		CreatedDate,
																		leankor__ExpenseAccount__c,
																		leankor__ExpenseCategory__c,
																		leankor__ExpenseSubCategory__c,
																		leankor__ResourceType__c,
																		leankor__KanbanCard__c,
																		leankor__PercentAllocation__c,
																		leankor__Kanbancard__r.leankor__Valuestream__c,
																		leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
																		leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c  
																	From leankor__ResourceAssignment__c
																	Where leankor__ResourceType__c In : inputRMlog.resourceTypeIds 
																		And leankor__Kanbancard__r.leankor__TemplateBoard__c = false 
																		And leankor__Kanbancard__r.Recordtype.Name = 'ActivityCard' 
																		And leankor__Kanbancard__r.leankor__isRecordDeleted__c = false
																		And (
																			(leankor__Kanbancard__r.leankor__StartDate__c >= : beginDate And leankor__Kanbancard__r.leankor__StartDate__c <=: endDate) 
																			Or (leankor__Kanbancard__r.leankor__DueDate__c <= : endDate And leankor__Kanbancard__r.leankor__DueDate__c >= : beginDate) 
																			Or(leankor__Kanbancard__r.leankor__StartDate__c <= : beginDate And leankor__Kanbancard__r.leankor__DueDate__c >= : endDate)
																			) 
																	With Security_Enforced
																	Order By CreatedDate ASC NULLS FIRST
																	Limit 50000]){
				if (resourceAssignment.leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != 'Template' &&
					resourceAssignment.leankor__Kanbancard__r.leankor__Valuestream__c != null &&
					resourceAssignment.leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c !=null) {
						queriedResourcesMap.put(resourceAssignment.Id, resourceAssignment);
				}
			}

			// Get resource assignment record assign to requested users.
			/*
			*Modified By :Ashutosh Gour
			*Modification : Modification for making SOQL selective and remove negative selection.
			*/
			for (leankor__ResourceAssignment__c resourceAssignment : [Select 
																		Id,
																		leankor__AssignedTo__c,
																		CreatedDate,
																		leankor__ExpenseAccount__c,
																		leankor__ExpenseCategory__c,
																		leankor__ExpenseSubCategory__c,
																		leankor__ResourceType__c,
																		leankor__KanbanCard__c,
																		leankor__PercentAllocation__c,
																		leankor__Kanbancard__r.leankor__Valuestream__c,
																		leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
																		leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c 
																	From leankor__ResourceAssignment__c
																	Where leankor__AssignedTo__r.Id In : userAndResourceTypeMap.keyset() 
																		And leankor__Kanbancard__r.leankor__TemplateBoard__c = false 
																		And leankor__Kanbancard__r.Recordtype.Name = 'ActivityCard' 
																		And leankor__Kanbancard__r.leankor__isRecordDeleted__c = false
																		And ((leankor__Kanbancard__r.leankor__StartDate__c >= : beginDate and leankor__Kanbancard__r.leankor__StartDate__c <=: endDate) 
																		Or (leankor__Kanbancard__r.leankor__DueDate__c <= : endDate and leankor__Kanbancard__r.leankor__DueDate__c >= : beginDate) 
																		Or(leankor__Kanbancard__r.leankor__StartDate__c <= : beginDate AND leankor__Kanbancard__r.leankor__DueDate__c >= : endDate)
																		) 
																	With Security_Enforced
																	Order By CreatedDate ASC NULLS FIRST
																	Limit 50000]) {
			
				if (resourceAssignment.leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != 'Template' &&
					resourceAssignment.leankor__Kanbancard__r.leankor__Valuestream__c != null &&
					resourceAssignment.leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c !=null) {
						queriedResourcesAccToUsers.put(resourceAssignment.Id, resourceAssignment);
				}
			}
			// Add both queried records.
			queriedResourcesMap.putAll(queriedResourcesAccToUsers); 

			for(leankor__ResourceAssignment__c  res : queriedResourcesMap.values()){
				/*if(res.leankor__ExpenseAccount__c == null || res.leankor__ExpenseCategory__c == null || res.leankor__ExpenseSubCategory__c == null){
					if(queriedResourcesMap.containsKey(res.Id)){
						queriedResourcesMap.remove(res.Id);
					}	
				}else{
					kanbanIds.add(res.leankor__KanbanCard__c);	
				}*/	

				if(String.isBlank(res.leankor__Kanbancard__r.leankor__Valuestream__c)
					&& String.isBlank(res.leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c)) {
					// Remove the record in this condition.
					queriedResourcesMap.remove(res.Id);
				}else {
					kanbanIds.add(res.leankor__KanbanCard__c);
				}			
			}
		
			/*
			List<leankor__ResourceAssignment__c> raList1 = [SELECT Id,leankor__AssignedTo__c,CreatedDate,leankor__ExpenseAccount__c,leankor__ExpenseCategory__c,leankor__ExpenseSubCategory__c,leankor__ResourceType__c,leankor__KanbanCard__c,leankor__PercentAllocation__c FROM leankor__ResourceAssignment__c WHERE leankor__KanbanCard__c IN : kanbanIds];	 
						
			for(leankor__ResourceAssignment__c ra : raList1){
				expenseAccount.add(ra.leankor__ExpenseAccount__c);
				expenseCategory.add(ra.leankor__ExpenseCategory__c);
				expenseSubCategory.add(ra.leankor__ExpenseSubCategory__c);
			}
			*/
							
			for(leankor__ResourceAssignment__c ra : queriedResourcesMap.values()){
				
				leankor__ResourceType__c resType = allResourceTypesMap.get(ra.leankor__ResourceType__c);					
				
				if(resType != null && ra.leankor__ResourceType__c != null){
				
					if(ra.leankor__ExpenseAccount__c == resType.leankor__ExpenseAccount__c && ra.leankor__ExpenseCategory__c == resType.leankor__ExpenseCategory__c && ra.leankor__ExpenseSubCategory__c == resType.leankor__ExpenseSubCategory__c){			  			
						if(finalResourceTypeAndResourceAssignMap.ContainsKey(resType.Id)){
							List<leankor__ResourceAssignment__c> oldResList = finalResourceTypeAndResourceAssignMap.get(resType.Id);
							oldResList.add(ra);
							finalResourceTypeAndResourceAssignMap.put(resType.Id,oldResList);				                
						}else{
							List<leankor__ResourceAssignment__c> newResList = new List<leankor__ResourceAssignment__c>();
							newResList.add(ra);
							finalResourceTypeAndResourceAssignMap.put(resType.Id,newResList);	                
						}
					}
				}
				else{
					if(ra.leankor__AssignedTo__c != null){
						leankor__Resource__c resource = userResourceMap.get(ra.leankor__AssignedTo__c);
						if(resource != null){
							if(!userAndWrappedResourcesData.containsKey(ra.leankor__AssignedTo__c)){
								Resources newRes = new Resources();
								newRes.Id = resource.Id;
								newRes.name = resource.leankor__User__r.Name;
								newRes.resourceTypeId = resourceAndResourceTypeMap.ContainsKey(resource.Id)? resourceAndResourceTypeMap.get(resource.Id).Id : '';
								userAndWrappedResourcesData.put(ra.leankor__AssignedTo__c,newRes);
								resourceList.add(newRes);								
							}
															
							list<leankor__ResourceAssignment__c> newResList = new List<leankor__ResourceAssignment__c>();
							newResList.add(ra);
							if(resourceAndResourceTypeMap.containsKey(resource.Id)){
								String resourceTypeId = resourceAndResourceTypeMap.get(resource.Id).Id; 
								
								if(finalResourceTypeAndResourceAssignMap.ContainsKey(resourceTypeId)){
									list<leankor__ResourceAssignment__c> oldResourceList = finalResourceTypeAndResourceAssignMap.get(resourceTypeId);
									//Added resource id and name due to UI need 
									//ra.leankor__ResourceType__c = resourceTypeId;
									ra.leankor__ResourceType__c = resource.Id;						                
									oldResourceList.add(ra);
									finalResourceTypeAndResourceAssignMap.put(resourceTypeId,oldResourceList);
									
								}else{
									list<leankor__ResourceAssignment__c> newResourceList = new List<leankor__ResourceAssignment__c>();
										//Added resource id and name due to UI need 
									//ra.leankor__ResourceType__c = resourceTypeId;
									ra.leankor__ResourceType__c = resource.Id;						                
									newResourceList.add(ra);
									finalResourceTypeAndResourceAssignMap.put(resourceTypeId,newResourceList);						                
								}
							}								
						}					
					}
				}
			}	
        }	
			
		
		if (inputRMlog.isProjectFilter && inputRMlog.projectIds.size()>0){ 

			map<String,leankor__ResourceType__c> userAndResourceTypeMap = new map<String,leankor__ResourceType__c>();
			map<String,leankor__Resource__c> userResourceMap = new map<String,leankor__Resource__c>();
			map<String,leankor__ResourceType__c> resourceAndResourceTypeMap = new map<String,leankor__ResourceType__c>();
			List<String> resourceTypeIds = new List<String>();
			/*
			*Modified By :Ashutosh Gour
			*Modification : Modification for making SOQL selective and remove negative selection.
			*/
			for (leankor__ResourceAssignment__c resourceAssignment : [Select Id,
																				leankor__AssignedTo__c,
																				CreatedDate,
																				leankor__ExpenseAccount__c,
																				leankor__ExpenseCategory__c,
																				leankor__ExpenseSubCategory__c,
																				leankor__ResourceType__c,
																				leankor__KanbanCard__c,
																				leankor__PercentAllocation__c,
																				leankor__Kanbancard__r.leankor__ValueStream__c,
																				leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
																				leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c
																			From leankor__ResourceAssignment__c
																			Where ((leankor__Kanbancard__r.leankor__ValueStreamCardLink__c = null 
																				And leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c In: inputRMlog.projectIds) 
																				Or leankor__Kanbancard__r.leankor__ValueStreamLink__r.leankor__ProjectRoom__c In: inputRMlog.projectIds) 
																				And leankor__Kanbancard__r.leankor__TemplateBoard__c = false 
																				And  leankor__Kanbancard__r.Recordtype.Name = 'ActivityCard' 
																				And leankor__Kanbancard__r.leankor__isRecordDeleted__c = false
																				And ((leankor__Kanbancard__r.leankor__StartDate__c >= : beginDate and leankor__Kanbancard__r.leankor__StartDate__c <=: endDate) 
																				Or (leankor__Kanbancard__r.leankor__DueDate__c <= : endDate and leankor__Kanbancard__r.leankor__DueDate__c >= : beginDate) 
																				Or(leankor__Kanbancard__r.leankor__StartDate__c <= : beginDate AND leankor__Kanbancard__r.leankor__DueDate__c >= : endDate)) 
																			With Security_Enforced
																			Order By CreatedDate ASC NULLS FIRST
																			Limit 50000]) {
				if (resourceAssignment.leankor__Kanbancard__r.leankor__MasterContainer__r.leankor__Type__c != 'Template' &&
					resourceAssignment.leankor__Kanbancard__r.leankor__Valuestream__c != null &&
					resourceAssignment.leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c !=null) {
						queriedResourcesAccToProjects.put(resourceAssignment.Id, resourceAssignment);
				}
			}
		    for(leankor__ResourceAssignment__c ra : queriedResourcesAccToProjects.values()){
				/*if (ra.leankor__ExpenseAccount__c == null || ra.leankor__ExpenseCategory__c == null || ra.leankor__ExpenseSubCategory__c == null) {
					if(queriedResourcesAccToProjects.containsKey(ra.Id)){
						queriedResourcesAccToProjects.remove(ra.Id);
					}					       
				}*/

				if(String.isNotBlank(ra.leankor__Kanbancard__r.leankor__ValueStream__c) 
					&& String.isNotBlank(ra.leankor__Kanbancard__r.leankor__ValueStream__r.leankor__ProjectRoom__c)){
					expenseAccount.add(ra.leankor__ExpenseAccount__c);
					expenseCategory.add(ra.leankor__ExpenseCategory__c);
					expenseSubCategory.add(ra.leankor__ExpenseSubCategory__c);
				}
			}
		         	
			for (leankor__ResourceAssignment__c ra : queriedResourcesAccToProjects.values()){
				if(ra.leankor__ResourceType__c != null){
					resourceTypeIds.add(ra.leankor__ResourceType__c);
				}		         		
			}
			        
			Map<String,leankor__ResourceType__c> allResourceTypesMap = 
				new Map<String,leankor__ResourceType__c>([Select leankor__ExpenseAccount__c,
																	leankor__ExpenseCategory__c,
																	leankor__ExpenseSubCategory__c,
																	Name 
																From leankor__ResourceType__c 
																Where( Id In: resourceTypeIds) 
																	Or (leankor__ExpenseAccount__c In: expenseAccount 
																			And leankor__ExpenseCategory__c In: expenseCategory 
																			And leankor__ExpenseSubCategory__c In: expenseSubCategory) 
																With Security_Enforced
																Limit 50000]);

			Map<string, leankor__Resource__c> allResourcesMap = 
				new Map<string, leankor__Resource__c>([Select leankor__ExpenseAccount__c,
																leankor__User__c,
																leankor__ExpenseCategory__c,
																leankor__ExpenseSubCategory__c,
																Name,
																leankor__User__r.Name 
															From leankor__Resource__c 
															Where leankor__ExpenseAccount__c In: expenseAccount 
																And leankor__ExpenseCategory__c In: expenseCategory 
																And leankor__ExpenseSubCategory__c In: expenseSubCategory
															With Security_Enforced
															Limit 50000]);
			
			for(leankor__ResourceType__c resType : allResourceTypesMap.values()){
				for(leankor__Resource__c res : allResourcesMap.Values()){
					
					if( resType.leankor__ExpenseAccount__c == res.leankor__ExpenseAccount__c && resType.leankor__ExpenseCategory__c == res.leankor__ExpenseCategory__c && resType.leankor__ExpenseSubCategory__c == res.leankor__ExpenseSubCategory__c){
						userAndResourceTypeMap.put(res.leankor__User__c ,resType );
						userResourceMap.put(res.leankor__User__c ,res );
						resourceAndResourceTypeMap.put(res.Id, resType);
					}
				}
			}

			for (leankor__ResourceAssignment__c ra : queriedResourcesAccToProjects.values()){
				
				if(ra.leankor__ResourceType__c != null) { 
					setResourceTypeIds.add(ra.leankor__ResourceType__c);
				}
				
				// Get the resource type
				leankor__ResourceType__c resType = allResourceTypesMap.get(ra.leankor__ResourceType__c);
			
				if (resType != null && ra.leankor__ResourceType__c != null) {	

					if (ra.leankor__ExpenseAccount__c == resType.leankor__ExpenseAccount__c 
							&& ra.leankor__ExpenseCategory__c == resType.leankor__ExpenseCategory__c 
							&& ra.leankor__ExpenseSubCategory__c == resType.leankor__ExpenseSubCategory__c) {
						
						if (finalResourceTypeAndResourceAssignMap.ContainsKey(resType.Id)) {
							List < leankor__ResourceAssignment__c > oldResList = finalResourceTypeAndResourceAssignMap.get(resType.Id);
							oldResList.add(ra);
							finalResourceTypeAndResourceAssignMap.put(resType.Id, oldResList);
							
						} else {
							List < leankor__ResourceAssignment__c > newResList = new List < leankor__ResourceAssignment__c > ();
							newResList.add(ra);
							finalResourceTypeAndResourceAssignMap.put(resType.Id, newResList);
							
						}
					}
				} else {
					if (ra.leankor__AssignedTo__c != null) {
						
						leankor__Resource__c resource = userResourceMap.get(ra.leankor__AssignedTo__c);

						if (resource != null) {

							if(!userAndWrappedResourcesData.containsKey(ra.leankor__AssignedTo__c)){
								Resources newRes = new Resources();
								newRes.Id = resource.Id;
								newRes.name = resource.leankor__User__r.Name;
								newRes.resourceTypeId = resourceAndResourceTypeMap.containsKey(resource.Id) ? resourceAndResourceTypeMap.get(resource.Id).Id : '';
								userAndWrappedResourcesData.put(ra.leankor__AssignedTo__c,newRes);
								resourceList.add(newRes);								
							}	

							if (resourceAndResourceTypeMap.containsKey(resource.Id)) {
								String resourceTypeId = resourceAndResourceTypeMap.containsKey(resource.Id) ? resourceAndResourceTypeMap.get(resource.Id).Id : '';

								if (finalResourceTypeAndResourceAssignMap.ContainsKey(resourceTypeId)) {

									List < leankor__ResourceAssignment__c > oldResourceList = finalResourceTypeAndResourceAssignMap.get(resourceTypeId);
									//ra.leankor__ResourceType__c = resourceTypeId;
									//Added resource id and name due to UI need 
									ra.leankor__ResourceType__c = resource.Id;					                        
									oldResourceList.add(ra);
									finalResourceTypeAndResourceAssignMap.put(resourceTypeId, oldResourceList);					                        
								} else {

									List < leankor__ResourceAssignment__c > newResourceList = new List < leankor__ResourceAssignment__c > ();
									//ra.leankor__ResourceType__c = resourceTypeId;
									//Added resource id and name due to UI need 
									ra.leankor__ResourceType__c = resource.Id;					                        
									newResourceList.add(ra);
									finalResourceTypeAndResourceAssignMap.put(resourceTypeId, newResourceList);
								}
							}					
						}					
					}

				}					
			}             
		}	

		for (List<leankor__ResourceAssignment__c> resLogList: finalResourceTypeAndResourceAssignMap.values()){
			for(leankor__ResourceAssignment__c resLog :resLogList){
				leankor.KanbanToGanttController.MasterContainer cardRSLogMC = new leankor.KanbanToGanttController.MasterContainer();
				cardRSLogMC.ID = resLog.ID;
				cardRSLogMC.ResourceId = resLog.leankor__ResourceType__c;
				cardRSLogMC.TaskId = resLog.leankor__Kanbancard__c;
				cardRSLogMC.Units = resLog.leankor__PercentAllocation__c;
				cardRSLogMC.Type = 'Leankor';            
				//setResourceTypeIds.add(resLog.leankor__ResourceType__c);
				setKanbanIds.add(resLog.leankor__Kanbancard__c);
				resultList.resourceAssignments.add(cardRSLogMC);
			}   
		} 
		/*
		*Modified By :Ashutosh Gour
		*Modification : Modification for making SOQL selective and remove negative selection.
		*/
		List<String> kanbanIdForAggDataMap = new List<String>();
		for (leankor__KanbanCard__c kanbanCard : [Select Id,
															leankor__MasterContainer__r.leankor__Type__c,
															leankor__BoardType__c
														From leankor__KanbanCard__c
														Where leankor__ValuestreamCardLink__c In: setKanbanIds 
															And leankor__ValuestreamCardLink__r.leankor__BoardType__c='UberBoard'
															And leankor__IsRecordDeleted__c = false
															And leankor__Valuestream__r.leankor__IsTemplateBoard__c =false
														With Security_Enforced]) {
			if (kanbanCard.leankor__BoardType__c != 'UberBoard' && kanbanCard.leankor__MasterContainer__r.leankor__Type__c != 'Template') {
				kanbanIdForAggDataMap.add(kanbanCard.Id);
			}
		}
		Map<String, AggregateResult> aggDataMap = new Map<String, AggregateResult>();
		List<AggregateResult> resAgg  = [Select Min(leankor__StartDateTime__c) minStartDate, 
												Max(leankor__DueDateTime__c) maxDueDate,  
												leankor__valuestreamCardLink__c parentId    
											From leankor__KanbanCard__c 
											Where Id In: kanbanIdForAggDataMap 
												And leankor__ValuestreamCardLink__c In: setKanbanIds
											With Security_Enforced
											Group By leankor__valuestreamCardLink__c 
											Limit 5000];
		for(AggregateResult aggregateRecord : resAgg){
			aggDataMap.put((String)aggregateRecord.get('parentId'), aggregateRecord);							 
		}		

		for(leankor__KanbanCard__c allocationlog : [Select Id,
															leankor__ValueStreamCardLink__c,
															leankor__ValueStream__r.leankor__ProjectRoom__c,
															leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
															leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__r.Name,
															Name,OwnerId,leankor__DueDateTime__c,
															leankor__DurationUnits__c,leankor__EstimatedDuration__c,
															leankor__GUID__c,leankor__PercentComplete2__c,
															leankor__StartDateTime__c,leankor__Title__c,
															leankor__ValueStream__c, Owner.Name,
															leankor__ValueStream__r.leankor__Boardtype__c,
															leankor__Folder__c,leankor__ProjectRoom__c,
															leankor__ValueStream__r.UserRecordAccess.HasEditAccess,
															leankor__Valuestream__r.leankor__ProjectRoom__r.UserRecordAccess.HasEditAccess,
															leankor__Valuestream__r.leankor__SevenDayWorkWeek__c,
															(Select Id, 
																	leankor__ManuallyScheduled__c, 
																	leankor__Mode__c, leankor__EffortUnits__c, 
																	leankor__EffortActual__c
																From leankor__ScheduleModes__r
																Limit 1)
														From leankor__KanbanCard__c
														Where Id In: setKanbanIds]){ 						            	           	
		    // making record for Leankor
			leankor.KanbanToGanttController.MasterContainer CardLog = new leankor.KanbanToGanttController.MasterContainer();
			cardlog.Id = allocationlog.Id;
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
			CardLog.ProjectRoomName=  allocationlog.leankor__ProjectRoom__c; 
			cardlog.Type = 'Leankor';
			cardlog.ParentProjectRoomID = allocationlog.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c;
			cardlog.parentProjectRoomName = allocationlog.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__r.Name;
			cardlog.isLinked = allocationlog.leankor__ValueStreamCardLink__c != null ? (allocationlog.leankor__ValueStream__r.leankor__ProjectRoom__c != allocationlog.leankor__ValueStreamCardLink__r.leankor__ValueStream__r.leankor__ProjectRoom__c ? true : false) : false;
			cardLog.ProjectRoomID = cardlog.BoardType == 'UberBoard' ? allocationLog.leankor__Valuestream__r.leankor__ProjectRoom__c: null;        
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
				resultList.ResourceCards.add(cardlog);
			}
		}			            

		
       	if (inputRMlog.isProjectFilter || InputRMlog.resourceTypeIds.size()>0){

       		//Map<String,leankor__ResourceType__c > allResourceTypesMap1 = new Map<String,leankor__ResourceType__c>([SELECT Id,Name,leankor__ExpenseAccount__c,leankor__ExpenseCategory__c,leankor__ExpenseSubCategory__c FROM leankor__ResourceType__c WHERE ID IN: setResourceTypeIds OR Id IN: inputRMlog.resourceTypeIds OR (leankor__ExpenseAccount__c IN: expenseAccount AND leankor__ExpenseCategory__c IN: expenseCategory AND leankor__ExpenseSubCategory__c IN: expenseSubCategory)]);	
			   Map<String,leankor__ResourceType__c > allResourceTypesMap1 = 
				new Map<String,leankor__ResourceType__c>( [Select Id,
																	Name,
																	leankor__ExpenseAccount__c,
																	leankor__ExpenseCategory__c,
																	leankor__ExpenseSubCategory__c 
																From leankor__ResourceType__c 
																Where Id In: setResourceTypeIds 
																	Or Id In: inputRMlog.resourceTypeIds
																	Or (leankor__ExpenseAccount__c In: expenseAccount 
																			And leankor__ExpenseCategory__c In: expenseCategory 
																			And leankor__ExpenseSubCategory__c In: expenseSubCategory)
																With Security_Enforced
																Limit 50000]);
			
			// Tilak: 12.03.2020 
			Set<String> resTypeSet = new Set<String>();
			for(String str: setResourceTypeIds){
				if(String.isNotBlank(str))
					resTypeSet.add(str);
			}
			for(String str: inputRMlog.resourceTypeIds){
				if(String.isNotBlank(str))
					resTypeSet.add(str);
			}
			// Date : 03/03/2020
			// Changes : commented if condition to get all resource type record for Capacity Planning 
			for(leankor__ResourceType__c rt : allResourceTypesMap1.values()){
				if (rt.leankor__ExpenseAccount__c == null || rt.leankor__ExpenseCategory__c == null || rt.leankor__ExpenseSubCategory__c == null) {
			        /*if(allResourceTypesMap1.containsKey(rt.Id)){
			         	allResourceTypesMap1.remove(rt.Id);
			        }	*/
					if(!resTypeSet.contains(rt.Id)){
						allResourceTypesMap1.remove(rt.Id);
					}			       
				}else{
	            	expenseAccount.add(rt.leankor__ExpenseAccount__c);
	            	expenseCategory.add(rt.leankor__ExpenseCategory__c);
	            	expenseSubCategory.add(rt.leankor__ExpenseSubCategory__c);
	        	}  	
			}  

			Map<String, leankor__Resource__c> allResourcesMap1 = new Map<String, leankor__Resource__c>([Select leankor__ExpenseAccount__c,
																												leankor__User__c,
																												leankor__ExpenseCategory__c,
																												leankor__ExpenseSubCategory__c,
																												Name,
																												leankor__User__r.Name 
																											From leankor__Resource__c 
																											Where leankor__ExpenseAccount__c In: expenseAccount 
																												And leankor__ExpenseCategory__c In: expenseCategory 
																												And leankor__ExpenseSubCategory__c In: expenseSubCategory
																											With Security_Enforced
																											Limit 50000]);
			//Add resource type details in any case, either resource type does not have any Cards or RA
			/*if(allResourceTypesMap != null){
				resultList.resourceTypes.addAll(allResourceTypesMap.values());
			}*/
			
			for(leankor__ResourceType__c resType : allResourceTypesMap1.values()){
				for(leankor__Resource__c res : allResourcesMap1.Values()){
					if( String.isNotBlank(res.leankor__User__c) 
						&& (resType.leankor__ExpenseAccount__c == res.leankor__ExpenseAccount__c 
						&& resType.leankor__ExpenseCategory__c == res.leankor__ExpenseCategory__c 
						&& resType.leankor__ExpenseSubCategory__c == res.leankor__ExpenseSubCategory__c)){
						
						if(resourceTypeAndResourceMap.ContainsKey(resType.Id)) {
			                list < Resources > oldResList = resourceTypeAndResourceMap.get(resType.Id);
			                Resources newRes = new Resources();
							newRes.Id = res.Id;
							newRes.name = res.leankor__User__r.Name;
							newRes.resourceTypeId = resType.Id;
			                oldResList.add(newRes);
			                resourceTypeAndResourceMap.put(resType.Id, oldResList);
				        }else{
			                list < Resources > newResList = new List < Resources > ();
			                Resources newRes = new Resources();
							newRes.Id = res.Id;
							newRes.name = res.leankor__User__r.Name;
							newRes.resourceTypeId = resType.Id;
			                newResList.add(newRes);
			                resourceTypeAndResourceMap.put(resType.Id, newResList);				               
			            }
			        }
				}
			}
			
			for(string resId :allResourceTypesMap1.keyset()){

	        	ResourceTypes rt = new ResourceTypes();
	        	rt.Id = resId;
	        	rt.name = allResourceTypesMap1.containsKey(resId) ? allResourceTypesMap1.get(resId).Name : '';
	        	rt.relatedResources = resourceTypeAndResourceMap.get(resId);
	        	resourceTypesList.add(rt);
        	}
        	
        	resultList.resourceTypes = resourceTypesList;		           
        } 
        
        resultList.resources = resourceList;
        return resultList;
    }  
    
    /*------------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	get resource types based on filter for capacity planning 
	Inputs: 		Integer offsetSize, String filterValue, Integer limits
	Returns: 		realTimeController.RecordDetails
	------------------------------------------------------------*/
    @RemoteAction
    global static ResourceTypesLog readFilteredResourceTypes(Integer offsetSize, String filterValue, Integer limits) {
    	
    	map<String,List<Resources>> resourceTypeAndResourceMap = new map<String,List<Resources>>();
    	Set<String> expenseAccount = new Set<String>();
        Set<String> expenseCategory = new Set<String>();
        Set<String> expenseSubCategory = new Set<String>();
        String filterVal = '%' + filterValue + '%'; // It can be '' or any string.
        // getting count to manage paging or maximum number of user available on the basis filterValue.
        
		Integer count = [Select Count() 
								From leankor__ResourceType__c 
								Where Name Like: filterVal
								With Security_Enforced];
        Map<String,leankor__ResourceType__c > allResourceTypesMap = 
		new Map<String,leankor__ResourceType__c>([Select leankor__ExpenseAccount__c,
															leankor__ExpenseCategory__c,
															leankor__ExpenseSubCategory__c,
															Name 
														From leankor__ResourceType__c 
														Where Name Like: filterVal
														With Security_Enforced
														Limit: limits 
														Offset: offsetSize]);
																	
		Integer hours = leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c == null 
						? 0 
						:Integer.valueof(leankor__LeanConstants__c.getInstance().leankor__WorkingHoursPerDay__c);        
        List<ResourceTypes> resourceTypesList = new List<ResourceTypes>();
		
		// Date : 03/03/2020
		// Changes : commented if condition to get all resource type record for Capacity Planning 
       	for(leankor__ResourceType__c rt : allResourceTypesMap.values()){
       		/*if (rt.leankor__ExpenseAccount__c == null || rt.leankor__ExpenseCategory__c == null || rt.leankor__ExpenseSubCategory__c == null) {
			        if(allResourceTypesMap.containsKey(rt.Id)){
			         	allResourceTypesMap.remove(rt.Id);
			        }					       
			}else{*/
        	expenseAccount.add(rt.leankor__ExpenseAccount__c);
        	expenseCategory.add(rt.leankor__ExpenseCategory__c);
        	expenseSubCategory.add(rt.leankor__ExpenseSubCategory__c);
        	//}        
		}   

		map<string, leankor__Resource__c> allResourcesMap = new map<string, leankor__Resource__c>([Select leankor__ExpenseAccount__c,
																											leankor__User__c,
																											leankor__ExpenseCategory__c,
																											leankor__ExpenseSubCategory__c,
																											Name,
																											leankor__User__r.Name
																										From leankor__Resource__c 
																										Where leankor__ExpenseAccount__c In: expenseAccount 
																											And leankor__ExpenseCategory__c In: expenseCategory 
																											And leankor__ExpenseSubCategory__c In: expenseSubCategory
																										With Security_Enforced]);
        
        for(leankor__ResourceType__c resType : allResourceTypesMap.values()){
			for(leankor__Resource__c res : allResourcesMap.Values()){
				if(resType.leankor__ExpenseAccount__c == res.leankor__ExpenseAccount__c && resType.leankor__ExpenseCategory__c == res.leankor__ExpenseCategory__c && resType.leankor__ExpenseSubCategory__c == res.leankor__ExpenseSubCategory__c){
					
					if(resourceTypeAndResourceMap.ContainsKey(resType.Id)) {
		                list < Resources > oldResList = resourceTypeAndResourceMap.get(resType.Id);
		                Resources newRes = new Resources();
						newRes.Id = res.Id;
						newRes.name = res.leankor__User__r.Name;
						newRes.resourceTypeId = resType.Id;
		                oldResList.add(newRes);
		                resourceTypeAndResourceMap.put(resType.Id, oldResList);
			        }else{
		                list < Resources > newResList = new List < Resources > ();
		                Resources newRes = new Resources();
						newRes.Id = res.Id;
						newRes.name = res.leankor__User__r.Name;
						newRes.resourceTypeId = resType.Id;
		                newResList.add(newRes);
		                resourceTypeAndResourceMap.put(resType.Id, newResList);				               
		            }
		        }
			}
		}
		
        ResourceTypesLog records = new ResourceTypesLog();
        records.count = count;
        records.offsetSize = offsetSize;
        records.workingHoursPerDay = (hours <= 0 ? 8 :(hours > 24 ? 24 :hours));
        for(string resId :allResourceTypesMap.keyset()){
        	ResourceTypes rt = new ResourceTypes();
        	rt.Id = resId;
        	rt.name = allResourceTypesMap.containsKey(resId) ? allResourceTypesMap.get(resId).Name : '';
        	rt.relatedResources = resourceTypeAndResourceMap.get(resId);
        	resourceTypesList.add(rt);
        }
        records.resourceTypes = resourceTypesList;
        return records;
    }
    
}