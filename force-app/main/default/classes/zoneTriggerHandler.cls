/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: zoneTriggerHandler.cls
 * CLASS: zoneTriggerHandler   
 */

public with sharing class zoneTriggerHandler {

    public static boolean firstRun = true;

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public zoneTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    //public void OnBeforeInsert(Object[] newObjects){
    //    // EXECUTE BEFORE INSERT LOGIC
    //}

    //public void OnAfterInsert(Object[] newObjects){
    //    // EXECUTE AFTER INSERT LOGIC
    //}
    
    //@future public static void OnAfterInsertAsync(Set<ID> newIDs){
    //    // EXECUTE AFTER INSERT LOGIC ASYNC
    //}


    //public void OnBeforeUpdate(Object[] oldObjects, Object[] updatedObjects, Map<ID,Object> ObjectMap){
    //    // BEFORE UPDATE LOGIC
    //}

    public void OnAfterUpdate(Object[] oldObjects, Object[] updatedObjects, Map<ID,Object> ObjectMap){

        if (firstRun){
            firstRun = false;
        }
        else {
            System.debug('OnAfterUpdate triggered itself!');
        }
        
        // LOGIC GOES HERE
        leankor__Zone__c[] oldZones = (leankor__Zone__c[]) oldObjects;
        leankor__Zone__c[] updatedZones = (leankor__Zone__c[]) updatedObjects;
        integer idx = 0;
       /* 
        for (leankor__Zone__c myZone : updatedZones){
            
            System.debug('new zone: '+myZone.Name);
            System.debug('old zone: '+ oldZones[idx].Name);
            
            if (myZone.Name != oldZones[idx].Name){
                
                // get the queue based on the old name
                String oldNm = oldZones[idx].Name;
                String oldId = oldZones[idx].Id;
                
                // TODO: figure out when to strip off last 3 characters of ID to get 15 char ID; using 18 now
                oldNm = oldNm.deleteWhitespace();
                if (oldNm.length() > 21){
                    oldNm = oldNm.substring(0,20);
                }
                oldNm += '-';
                oldNm += oldId.left(15);
                
                System.debug('queue name to find: '+ oldNm);
                
                List<Group> g = [SELECT Id, Name FROM Group WHERE Name = :oldNm LIMIT 1];

                // set the new name
                if (g.size() > 0){
                    String newNm, Zn, newDevNm;
                    for (Group myG : g){
                        newNm = newDevNm = myZone.Name.deleteWhitespace();
                        if (newNm.length() > 21){
                            newNm = newDevNm = newNm.substring(0,20);
                        }
                        newNm += '-';
                        newDevNm += '_';
                        Zn = myZone.Id;
                        newNm += Zn.left(15);
                        newDevNm += Zn.left(15);
                        
                        myG.Name = newNm;
                        myG.DeveloperName = newDevNm;
                    }
                    
                    try {
                        update g;
                    }
                    // catch for upsert group of type 'Queue'
                    catch (DmlException e) {
                        System.debug(e.getMessage());
                    }
                }else {
                    System.debug('Could not find queue: ' + oldNm);
                }
            }
            idx++;
        }
        */
        // DON'T FORGET TO RESET FLAG BEFORE EXIT
        firstRun = true;
    }

    // @future public static void OnAfterUpdateAsync(Set<ID> updatedIDs){
    //
    //}

    //public void OnBeforeDelete(Object[] ObjectsToDelete, Map<ID,Object> ObjectMap){
    //    // BEFORE DELETE LOGIC
    //}

    //public void OnAfterDelete(Object[] deletedObjects, Map<ID,Object> ObjectMap){
    //    // AFTER DELETE LOGIC
    //}

    //@future public static void OnAfterDeleteAsync(Set<ID> deletedIDs){
    //
    //}

    //public void OnUndelete(Object[] restoredObjects){
    //    // AFTER UNDELETE LOGIC
    //}

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext{

        get{ return !IsTriggerContext;}

    }

    public boolean IsWebServiceContext{

        get{ return !IsTriggerContext;}

    }

    public boolean IsExecuteAnonymousContext{

        get{ return !IsTriggerContext;}

    }

}