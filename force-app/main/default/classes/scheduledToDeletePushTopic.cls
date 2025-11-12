/**
 * Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 * FILE: scheduledToDeletePushTopic.cls
 * CLASS: scheduledToDeletePushTopic   
 */
global with sharing class scheduledToDeletePushTopic implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        PushTopicBehaviour pushTopicBehaviour = new PushTopicBehaviour();
        if (!pushTopicBehaviour.isDeletable() ||
            !pushTopicBehaviour.isAccessible()) {
            System.abortJob(sc.getTriggerId());
        }
        /*SS 02.08.2018*/
    	//Delete pushtopics except created in current time.
	    //Datetime DateLimit =  system.now()-1 ;
    	Datetime DateLimit =  system.now();
        List<PushTopic> PushLogs =[Select Id 
                                    From PushTopic 
                                    Where LastModifiedDate <:DateLimit 
                                        And ((Name LIKE 'RT%' 
                                            And Query LIKE '%leankor__ValueStream__c%') 
                                        Or Name='RTLeankorNAV')];
        try{
            if(PushLogs.size()> 0){
                Database.Delete(PushLogs,true);
            }
        }catch (Exception e){
            throw new scheduledToDeletePushTopicException('ERROR:' + e.getMessage());
        } 
    }
    global class scheduledToDeletePushTopicException extends Exception{}
}