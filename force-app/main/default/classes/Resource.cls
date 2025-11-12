public with sharing class Resource {
    public leankor__Resource__c resource {get; set;}	
	public static final Boolean IS_MULTI_CURRENCY_ORGANIZATION = UserInfo.isMultiCurrencyOrganization();
		
    //Default Constructor
    public Resource(String json) {
        this.resource = new leankor__Resource__c();
    }
    
    // queries resource records with set of user ids as parameter and returns a map of resource object
	public static Map<Id, leankor__Resource__c> readResource(Set<Id> userIds) {
   		Map<Id, leankor__Resource__c> mapResource = new Map<Id, leankor__Resource__c>();
		List<leankor__Resource__c> resources = new List<leankor__Resource__c>();
		   				
		List<String> fieldNames = new List<String> {
				'Id',
				'leankor__User__c',
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
				
		try {
			resources = Database.query('Select ' + String.join(fieldNames, ', ') + ' From leankor__Resource__c Where leankor__User__c In : userIds Order By CreatedDate');
	    	
	    	//System.debug('readResource resources: ' + resources);
	    							
			// this automatically puts the last entered record per user into the map, in case of duplicates
			for (leankor__Resource__c resource : resources) {
			    mapResource.put(resource.leankor__User__c, resource);
			}
		} catch (Exception e) {
			throw e; 
		}
		
		//System.debug('readResource mapResource: ' + mapResource);
		 
		return mapResource;
	}	

	// sets the accounts of the resource, returns a new instance of leankor__ResourceAssignment__c
	public static leankor__ResourceAssignment__c setResourceAccounts(Id resourceId, Map<Id, leankor__Resource__c> resourceTypes, leankor__ResourceAssignment__c resourceAssignment) {		
		leankor__ResourceAssignment__c objectResourceAssignment = resourceAssignment;
		try {			
			// defaults the RA to the latest equivalent expense account on the resource
	        if (resourceTypes.containsKey(resourceId)) {
	            leankor__Resource__c assignedResource = resourceTypes.get(resourceId);            
	            objectResourceAssignment.leankor__ExpenseAccount__c = assignedResource.leankor__ExpenseAccount__c;
	            objectResourceAssignment.leankor__ExpenseSubCategory__c = assignedResource.leankor__ExpenseSubCategory__c;                
	           	objectResourceAssignment.leankor__ExpenseCategory__c = assignedResource.leankor__ExpenseCategory__c;
	           	objectResourceAssignment.leankor__ExternalHourlyRate__c = assignedResource.leankor__ExternalHourlyRate__c;
	           	objectResourceAssignment.leankor__InternalHourlyRate__c = assignedResource.leankor__InternalHourlyRate__c; 	
	           	objectResourceAssignment.leankor__ProjectFinancial__c = assignedResource.leankor__ProjectFinancial__c;
	        } else {        					
	            objectResourceAssignment.leankor__ExpenseAccount__c = null;
	            objectResourceAssignment.leankor__ExpenseSubCategory__c = null;                
	           	objectResourceAssignment.leankor__ExpenseCategory__c = null;
				objectResourceAssignment.leankor__ExternalHourlyRate__c = 0;
	           	objectResourceAssignment.leankor__InternalHourlyRate__c = 0; 
	           	objectResourceAssignment.leankor__ProjectFinancial__c = null;							      		      		     					
	        }
		} catch (Exception e) {
			throw e; 
		}
		        
        return objectResourceAssignment;     
	}

	// sets the accounts of the resource, returns a new instance of leankor__ResourceAssignment__c
	public static leankor__ResourceAssignment__c setResourceAccounts(Id resourceId, Map<Id, leankor__Resource__c> resourceTypes, leankor__ResourceAssignment__c resourceAssignment, Boolean isMultiCurrency) {		
		leankor__ResourceAssignment__c objectResourceAssignment;
		try {
			Map<String, Object> mapResourceAsignment = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resourceAssignment));
			
			// defaults the RA to the latest equivalent expense account on the resource
	        if (resourceTypes.containsKey(resourceId)) {
	            leankor__Resource__c assignedResource = resourceTypes.get(resourceId);            
	            Map<String, Object> mapResource = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(assignedResource));
	            				
				mapResourceAsignment.put('leankor__ExpenseAccount__c', mapResource.get('leankor__ExpenseAccount__c'));       		
				mapResourceAsignment.put('leankor__ExpenseSubCategory__c', mapResource.get('leankor__ExpenseSubCategory__c'));       		
				mapResourceAsignment.put('leankor__ExpenseCategory__c', mapResource.get('leankor__ExpenseCategory__c'));       		
				mapResourceAsignment.put('leankor__ExternalHourlyRate__c', mapResource.get('leankor__ExternalHourlyRate__c'));       		
				mapResourceAsignment.put('leankor__InternalHourlyRate__c', mapResource.get('leankor__InternalHourlyRate__c')); 
				mapResourceAsignment.put('CurrencyIsoCode', isMultiCurrency ? mapResource.get('CurrencyIsoCode') : '');	
				mapResourceAsignment.put('leankor__ProjectFinancial__c', mapResource.get('leankor__ProjectFinancial__c'));       			           	
	        } else {
				mapResourceAsignment.put('leankor__ExpenseAccount__c', null);       		
				mapResourceAsignment.put('leankor__ExpenseSubCategory__c', null);       		
				mapResourceAsignment.put('leankor__ExpenseCategory__c', null);       		
				mapResourceAsignment.put('leankor__ExternalHourlyRate__c', 0);       		
				mapResourceAsignment.put('leankor__InternalHourlyRate__c', 0); 						
	           	mapResourceAsignment.put('CurrencyIsoCode', isMultiCurrency ? Util.getCurrencyIsoCode(new leankor__Resource__c()) : '');
				mapResourceAsignment.put('leankor__ProjectFinancial__c', null);
	        }
	
	        objectResourceAssignment = (leankor__ResourceAssignment__c)JSON.deserialize(JSON.serialize(mapResourceAsignment), leankor__ResourceAssignment__c.class);

		} catch (Exception e) {
			throw e; 
		}
		        
        return objectResourceAssignment;     
	}	
	
	/*	
	// gets the CurrencyIsoCode of a given record
	private static String getResourceCurrencyIsoCode(leankor__Resource__c resource) {		
		String currencyIsoCode = '';
		
		Map<String, Object> stringObject = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(resource));
		currencyIsoCode = (String)stringObject.get('CurrencyIsoCode');
		
		return currencyIsoCode;
	}
	*/	
}