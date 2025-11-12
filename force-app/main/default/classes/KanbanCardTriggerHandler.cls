/**
 Copyright 2012-2017 Lucidsoft Inc. All rights reserved.
 FILE: kanbancardTriggerHandler.cls
 CLASS: kanbancardTriggerHandler
*/
public with sharing class KanbanCardTriggerHandler{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public KanbanCardTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Object[] newObjects){
        set<String> VSIDS = New set<String>();
        set<String> MCIDs = New set<String>();
        set<String> GetsMCIDs = New set<String>();
        Map<String,leankor__Swimlane__c> GetsSWIDs = New Map<String,leankor__Swimlane__c>();
        Map<String,leankor__Valuestream__c> VSmap = New Map<String,leankor__Valuestream__c>();
        Map<String,Boolean> VSweekendmap = New Map<String,Boolean>(); 
        
        //ss 05.04.2018
        //Added variable for getting first day of week from custom setting 	
        Integer firstDayOfWeek =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c == null ?1 : leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c.intValue();   
   		firstDayOfWeek= firstDayOfWeek==null || firstDayOfWeek<0  || firstDayOfWeek > 6?1:firstDayOfWeek;
   		//Create instance of WorkWeek which provides Working week days information
        Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek,5);
    	//ss 05.04.2018
        for(leankor__Kanbancard__C insertKC :(List<leankor__Kanbancard__C >) Trigger.new){
            if(insertKC.leankor__Valuestream__c != null){
                VSIDS.add(insertKC.leankor__Valuestream__c);
            }
            if(insertKC.leankor__MasterContainer__c != null ){
                MCIDs.add(insertKC.leankor__MasterContainer__c);
            }
        }
        String query ='Select ID,leankor__SevenDayWorkWeek__c,(Select ID,Name,leankor__Width__c,leankor__Height__c,leankor__JSONDefinition__c,leankor__JSONData__c,leankor__Color__c from leankor__Kanban_Card_Templates__r LIMIT 1) from leankor__Valuestream__c Where ID IN :VSIDs';
        List<leankor__Valuestream__c> VSLogs =Database.query(query); 
        for(leankor__Valuestream__c Vslog :VSlogs ){
            VSmap.put(Vslog.ID, Vslog);
            VSweekendmap.put(Vslog.ID,Vslog.leankor__SevenDayWorkWeek__c);
        }
        List<leankor__Swimlane__c> SWLogs = new List<leankor__Swimlane__c> ();
        if(MCIDs.size()>0){
        	String querysw ='SELECT Id,leankor__MasterContainer__c,Name,(Select Id,Name,leankor__GUID__C,leankor__Swimlane__r.leankor__MasterContainer__C from leankor__Zones__r ORDER BY leankor__Order__c) FROM leankor__Swimlane__c Where leankor__MasterContainer__c IN :MCIDs AND leankor__Valuestream__c IN :VSIDs ORDER BY leankor__MasterContainer__C,leankor__Order__c ASC NULLS FIRST';
            SWLogs = Database.query(querysw);
            for(leankor__Swimlane__c SW :SWLogs ){
                GetsMCIDs.add(SW.leankor__MasterContainer__c);
                GetsSWIDs.put(SW.ID,SW);
            }
        }
        integer i=10;
        for(leankor__Kanbancard__C updateKCLog : (List<leankor__Kanbancard__C >) Trigger.new){
            if((updateKCLog.leankor__GUID__c == '305ee49a-8489-4091-bf76-8a07048066f8' || updateKCLog.leankor__GUID__c == '' || updateKCLog.leankor__GUID__c == null ) && updateKCLog.leankor__ValueStream__C != null){
                leankor__Valuestream__c thisVS = VSmap.get(updateKCLog.leankor__ValueStream__C);
                leankor__KanbanCardTemplate__c Category = ThisVS.leankor__Kanban_Card_Templates__r;
                updateKCLog.leankor__GUID__c ='Bulk-'+System.now().getTime()+'-GUID'+i;
                updateKCLog.leankor__Title__C = (updateKCLog.leankor__Title__C == 'Work Order' ? Category.Name : updateKCLog.leankor__Title__C);
                updateKCLog.Name = (updateKCLog.Name == null ? Category.Name : updateKCLog.Name);
                updateKCLog.leankor__point__C = (updateKCLog.leankor__point__C == null ? 1 : updateKCLog.leankor__point__C);
                updateKCLog.leankor__EffortRemaining__C = (updateKCLog.leankor__EffortRemaining__C == 0 ? 1 : updateKCLog.leankor__EffortRemaining__C);
                updateKCLog.leankor__Top__C = (updateKCLog.leankor__Top__C == 100 ? 2100 : updateKCLog.leankor__Top__C);
                updateKCLog.leankor__Left__C = (updateKCLog.leankor__Left__C == 100 ? 2100 : updateKCLog.leankor__Left__C);
                updateKCLog.leankor__Width__C = (Category.leankor__Width__c == null ? updateKCLog.leankor__Width__C : Category.leankor__Width__c);
                updateKCLog.leankor__Height__C = (Category.leankor__Height__c == null ? updateKCLog.leankor__Height__C : Category.leankor__Height__c); 
                updateKCLog.leankor__JSONDefinition__C = Category.leankor__JSONDefinition__c;
                updateKCLog.leankor__JSONData__C = Category.leankor__JSONData__c; //request.JSONData;  // Can User Template
                updateKCLog.leankor__KanbanCardTemplate__c = Category.Id;
                updateKCLog.leankor__Color__C = Category.leankor__Color__c; //request.Color;  // Can User Template
                updateKCLog.leankor__DueDateTime__C = (updateKCLog.leankor__DueDateTime__C == null ? System.Now() :updateKCLog.leankor__DueDateTime__C);
                updateKCLog.leankor__EstimatedDuration__C = (updateKCLog.leankor__EstimatedDuration__C == null? 1 : updateKCLog.leankor__EstimatedDuration__C);
                updateKCLog.leankor__DurationUnits__C = (updateKCLog.leankor__DurationUnits__C == null ? 'Days' : updateKCLog.leankor__DurationUnits__C);
                updateKCLog.OwnerID = Userinfo.getuserID();
                updateKCLog.leankor__PercentComplete2__c = 0;
                updateKCLog.leankor__Order__C = i+100 ;
                updateKCLog.leankor__OnBudget__C = 'Green';
                updateKCLog.leankor__OnQuality__C = 'Green';
                updateKCLog.leankor__StartDateTime__C = (updateKCLog.leankor__StartDateTime__C== null ? System.Now(): updateKCLog.leankor__StartDateTime__C);    
                i++;
                if(!VSweekendmap.get(updateKCLog.leankor__ValueStream__C)){
                    datetime tempcalduedate = updateKCLog.leankor__StartDateTime__C;
                    for(integer icount = 1 ;icount < integer.valueof(updateKCLog.leankor__EstimatedDuration__C);icount++ ){
                        tempcalduedate = tempcalduedate+1;
                        //ss 04.05.2018 
                        //Calculate WorkingWeekDays escaping non working day according to first day of week
						tempcalduedate = Util.readNextWorkingDateTime(workWeek,tempcalduedate);
                        /*if(tempcalduedate.format('E') == 'Sat' || tempcalduedate.format('E') == 'Sun'){
                            tempcalduedate = tempcalduedate+1;
                        }
                        if(tempcalduedate.format('E') == 'Sat' || tempcalduedate.format('E') == 'Sun'){
                            tempcalduedate = tempcalduedate+1;
                        }*/
                        //ss 04.05.2018
                        }
                    updateKCLog.leankor__DueDateTime__C = tempcalduedate;
                }
                if(updateKCLog.leankor__MasterContainer__C != null && GetsMCIDs.contains(updateKCLog.leankor__MasterContainer__C)){
                    if(updateKCLog.leankor__Swimlane__c != null && GetsSWIDs.containskey(updateKCLog.leankor__Swimlane__c)){
                        leankor__Swimlane__c SWlog = GetsSWIDs.get(updateKCLog.leankor__Swimlane__c);
                        updateKCLog.leankor__MasterContainer__c = SWlog.leankor__MasterContainer__c;
                        updateKCLog.leankor__Swimlane__c = SWlog.ID;
                        if(updateKCLog.leankor__Zone__c != null){
                            for(leankor__Zone__c Zonelog : SWlog.leankor__Zones__r ){
                                if(updateKCLog.leankor__Zone__c == Zonelog.ID){
                                    updateKCLog.leankor__Zone__c = Zonelog.ID;
                                    updateKCLog.leankor__ZoneGUID__c = Zonelog.leankor__GUID__c;
                                    break;
                                }else{
                                    updateKCLog.leankor__Zone__c = SWlog.leankor__Zones__r[0].ID;
                                    updateKCLog.leankor__ZoneGUID__c = SWlog.leankor__Zones__r[0].leankor__GUID__c ;
                                }
                            }   
                        }else{
                            updateKCLog.leankor__Zone__c = SWlog.leankor__Zones__r[0].ID;
                            updateKCLog.leankor__ZoneGUID__c = SWlog.leankor__Zones__r[0].leankor__GUID__c ;
                        }
                    }else{
                        for(leankor__Swimlane__c SW :SWLogs ){
                            if(updateKCLog.leankor__MasterContainer__c == SW.leankor__MasterContainer__c ){
                                updateKCLog.leankor__MasterContainer__c = SW.leankor__MasterContainer__c ;
                                updateKCLog.leankor__Swimlane__c = SW.ID;
                                updateKCLog.leankor__Zone__c = SW.leankor__Zones__r[0].ID ;
                                updateKCLog.leankor__ZoneGUID__c = SW.leankor__Zones__r[0].leankor__GUID__c;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

}