/**
* FILE:  FixExternalActivitiesBatch.cls
* CLASS: FixExternalActivitiesBatch
* USAGE: Updating all the corrupted activities IsExternallyDependent__c field.
* DATE : 27/12/18
*/

public class FixKanbanDataBatch implements Database.Batchable<sObject>{
    
  public Database.QueryLocator start(Database.BatchableContext bc){
         String kanbanQuery = 'SELECT Id, leankor__IsExternallyDependent__c, Name, leankor__Valuestream__c, (SELECT Id, leankor__Predecessor__r.leankor__ValueStream__c, leankor__Successor__r.leankor__ValueStream__c FROM leankor__PredecessorDependencies__r), (SELECT Id, leankor__Predecessor__r.leankor__ValueStream__c, leankor__Successor__r.leankor__ValueStream__c FROM leankor__SuccessorDependencies__r) FROM leankor__KanbanCard__c WHERE leankor__BoardType__c=\'UberBoard\' AND leankor__isRecordDeleted__c = false'  ;            
         return Database.getQueryLocator(kanbanQuery);        
  }
   
  public void execute(Database.BatchableContext bc, List<leankor__KanbanCard__c> kbSObjList){
	  //Check CRUD / FLC behavior   
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!KanbanCardBehaviour.isUpdateable()) {
			System.abortJob(BC.getJobId());
		}
		//Check CRUD / FLC behavior   
			
		//RS 04/02/2018 This code is commented because we are going use it in a reusable method. 
		/*
			List<leankor__KanbanCard__c> activityList=new List<leankor__KanbanCard__c>();
			try{                  
				for(leankor__KanbanCard__c activity:kbSObjList){
					//Create single dependencyList from both Prdecessor and Successor relationship
					List<leankor__Dependency__c> dependencyList=new List<leankor__Dependency__c>(); 
					
					//Add dependencies with predecessor relationship
					if(activity.leankor__PredecessorDependencies__r.size()>0){
					dependencyList.addAll(activity.leankor__PredecessorDependencies__r);          
					}           
					//Add dependencies with Successor relationship
					if(activity.leankor__SuccessorDependencies__r.size()>0){
					dependencyList.addAll(activity.leankor__SuccessorDependencies__r);             
					}
					//If activities have dependencies then check for External dependencies                      
					if(dependencyList.size()>0){              	                                 
						for(leankor__Dependency__c dep:dependencyList){
								//if activity has ExternallyDependent is set to true. 
								if( activity.leankor__IsExternallyDependent__c  && (dep.leankor__Predecessor__r.leankor__ValueStream__c != dep.leankor__Successor__r.leankor__ValueStream__c) )
								{                             
									break;                      
								}                  	 
								//If activity external dependencies but its ExternallyDependent flag is false then update it to  true
							else  if(!activity.leankor__IsExternallyDependent__c  && (dep.leankor__Predecessor__r.leankor__ValueStream__c != dep.leankor__Successor__r.leankor__ValueStream__c) ){
									activity.leankor__IsExternallyDependent__c=true;   
									break;                        
								}                        
								//If activity has ExternallyDependent is set to true and it does not have any ExternallyDependencies then set it to false
								else if( activity.leankor__IsExternallyDependent__c  && (dep.leankor__Predecessor__r.leankor__ValueStream__c == dep.leankor__Successor__r.leankor__ValueStream__c) )
								{
									activity.leankor__IsExternallyDependent__c=false;                          
								}                                                                                                                               
							}                                              
					}
					else{
						//If activity do not have any dependencies then update IsExternallyDependent to  false
						activity.leankor__IsExternallyDependent__c=false;                          
					}            
				activityList.add(activity);
				}   
					
				update activityList;
			}catch(Exception ex){
				System.debug('ERROR:' + ex.getMessage());
			}  */
			updateIsExternal(kbSObjList);
			
	}        

    public void finish(Database.BatchableContext bc){
        
    }               
    
    //RS 04/02/2018 New method for updating IsExternallyDependent field 
    public void updateIsExternal(List<leankor__KanbanCard__c> kbSObjList){
		//Check CRUD / FLC behavior   
		KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
		if (!KanbanCardBehaviour.isUpdateable()) {
			throw new FixKanbanDataBatchException('Error: No access to records');
		}
		//Check CRUD / FLC behavior   
		
		List<leankor__KanbanCard__c> activityList = new List<leankor__KanbanCard__c>();
	        try{                  
		        for(leankor__KanbanCard__c activity:kbSObjList){
		            //Create single dependencyList from both Prdecessor and Successor relationship
		            List<leankor__Dependency__c> dependencyList = new List<leankor__Dependency__c>(); 
		            
		            //Add dependencies with predecessor relationship
		            if(activity.leankor__PredecessorDependencies__r.size()>0){
		              dependencyList.addAll(activity.leankor__PredecessorDependencies__r);          
		            }           
		            //Add dependencies with Successor relationship
		            if(activity.leankor__SuccessorDependencies__r.size()>0){
		              dependencyList.addAll(activity.leankor__SuccessorDependencies__r);             
		            }
		            //If activities have dependencies then check for External dependencies                      
		            if(dependencyList.size()>0){              	                                 
		                for(leankor__Dependency__c dep:dependencyList){
		                	    //if activity has ExternallyDependent is set to true. 
		                	    if( activity.leankor__IsExternallyDependent__c  && (dep.leankor__Predecessor__r.leankor__ValueStream__c != dep.leankor__Successor__r.leankor__ValueStream__c) )
		                        {                             
		                            break;                      
		                        }                  	 
		                        //If activity external dependencies but its ExternallyDependent flag is false then update it to  true
		                       else  if(!activity.leankor__IsExternallyDependent__c  && (dep.leankor__Predecessor__r.leankor__ValueStream__c != dep.leankor__Successor__r.leankor__ValueStream__c) ){
		                            activity.leankor__IsExternallyDependent__c=true;   
		                            break;                        
		                        }                        
		                        //If activity has ExternallyDependent is set to true and it does not have any ExternallyDependencies then set it to false
		                        else if( activity.leankor__IsExternallyDependent__c  && (dep.leankor__Predecessor__r.leankor__ValueStream__c == dep.leankor__Successor__r.leankor__ValueStream__c) )
		                        {
		                            activity.leankor__IsExternallyDependent__c=false;                          
		                        }                                                                                                                               
		                    }                                              
		             }
		             else{
		                //If activity do not have any dependencies then update IsExternallyDependent to  false
		                activity.leankor__IsExternallyDependent__c=false;                          
		             }            
		          activityList.add(activity);
		        }   
		            
		        update activityList;
	        }catch(Exception ex){
				//25/04/2023 : We are Throwing Exception
				throw new FixKanbanDataBatchException('ERROR:' + ex.getMessage()); 
	    	}
    
    }
    
	public class FixKanbanDataBatchException extends Exception{}
                
}