/**
*Class : DeleteSecurityRecords
*Description :  Batch Apex class for Delete Records of Security__c object
*/
global with sharing class DeleteSecurityRecords implements Database.Batchable<sObject>{
         
    //make batch apex for Delete Records of Security__c object
    
    public  map<String,UserRole> userRoleMap;
    public  set<String> userRoleId; 
        
    global DeleteSecurityRecords(){  
		this.userRoleMap = new map<String,UserRole>([SELECT Id FROM UserRole WHERE PortalType != 'None']);
		this.userRoleId	= userRoleMap.keySet();	
	} 
	   
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM leankor__Security__c ' + 'WHERE (  leankor__OwnerEditCard__c = false AND leankor__OwnerMoveCard__c = false ) OR ' + ' leankor__UserRoleID__c IN: userRoleId ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<leankor__Security__c> scope) {
        //Check CRUD / FLC behavior   
        SecurityBehavior securityBehavior = new SecurityBehavior();
        if (!securityBehavior.isDeletable()) {
            System.abortJob(BC.getJobId());
        }
        //Check CRUD / FLC behavior   

        try{	                		
            if(scope.size()>0){			
                delete scope;
            }				       	        
        }catch(Exception ex){
            //25/04/2023 : We are Throwing Exception
            throw new DeleteSecurityRecordsException('ERROR:' + ex.getMessage()); 		        
        }        	
    }
 
    global void finish(Database.BatchableContext BC){
            
    }

    global class DeleteSecurityRecordsException extends Exception{}
}