/**
 * Copyright 2012-2018 Lucidsoft Inc. All rights reserved.
 * FILE: scheduledToDeleteStreamingChannel.cls
 * CLASS: scheduledToDeleteStreamingChannel   
 */
Global with sharing class ScheduledToDeleteStreamingChannel implements schedulable {		
	Global void execute(SchedulableContext sc) {
      //DeleteStreamingChannelBatch b = new DeleteStreamingChannelBatch(); 
      //database.executebatch(b);
	  if(!StreamingChannel.sObjectType.getDescribe().isDeletable()){
			System.abortJob(sc.getTriggerId());
		}
      List<StreamingChannel> streamingChannelLogs = [SELECT Id FROM StreamingChannel WHERE (Name LIKE '/u/Leankor/Navigation/Project/RT%' or Name Like '/u/Leankor/Navigation/Project/LeankorNAV') AND LastModifiedDate < YESTERDAY limit 9999];
	  	try{
        	if(streamingChannelLogs.size()> 0){
            	Database.Delete(streamingChannelLogs,false);
			}
    	}catch (Exception e){
			throw new Util.LeanException('ERROR:' + e.getMessage());
    	}   
      
    }      
}