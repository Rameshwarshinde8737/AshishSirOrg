/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: ChatterAutoFollow.cls
 * CLASS: ChatterAutoFollow    
 */
public without sharing class ChatterAutoFollow{
    public static void createAutoFollow(List<EntitySubscription> ES){
        //Check CRUD / FLC behavior     
        EntitySubscriptionBehaviour entitySubscriptionBehaviour =  new EntitySubscriptionBehaviour();
        if (!entitySubscriptionBehaviour.isAccessible()
        ||  !entitySubscriptionBehaviour.isCreateable())
        {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        try{
            Database.insert(ES,false);
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
    }

    public static void removeAutoFollow(List<EntitySubscription> ES){
        //Check CRUD / FLC behavior     
       /*EntitySubscriptionBehaviour entitySubscriptionBehaviour =  new EntitySubscriptionBehaviour();
        if (!entitySubscriptionBehaviour.isAccessible()
        ||  !entitySubscriptionBehaviour.isDeletable())
        {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        try{
            Database.Delete(ES,false);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }*/
    }

    public static void removeAutoFollow(List<EntitySubscription> ES, Boolean allOrNone){
        //Check CRUD / FLC behavior     
        /*EntitySubscriptionBehaviour entitySubscriptionBehaviour =  new EntitySubscriptionBehaviour();
        if (!entitySubscriptionBehaviour.isAccessible()
        ||  !entitySubscriptionBehaviour.isDeletable())
        {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        try{
            Database.Delete(ES, allOrNone);
        }catch(DMLException ex){
            System.debug('Error : '+ex.getMessage());
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }*/
    }
}