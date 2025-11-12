/**
 Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 FILE: caseTriggerHandler.cls
 CLASS: caseTriggerHandler
*/
public with sharing class caseTriggerHandler{
    public static boolean firstRun = true;
    PageReference pageRef = new PageReference('/apex/leankor__VisualKanban');
    public static String baseUrl= 'https://' + DomainCreator.getOrgMyDomainHostname()
    +''+(new PageReference('/apex/leankor__VisualKanban').getUrl());
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private Map<String, String> picklistFieldMap = DescribeSchema.getPicklistFieldValueInMap('Case', 'Priority');
    private static final Boolean USECUSTOMLABEL_CONST = leankor__LeanConstants__c.getInstance().leankor__UseCustomLabels__c;
    Integer firstDayOfWeek =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c == null ?1 : leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c.intValue();
    public caseTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }


    public void OnBeforeInsert(Object[] newObjects) {
        Case[] newCases = (Case[]) newObjects;

        for (Case obj : newCases) {
            if (String.isNotBlank(obj.Subject)) {
                obj.Subject = (obj.Subject.replaceAll('\\<.*?\\>', '')).mid(0, 255);
            }
        }
    }


    
    // This Code run when insert trigger run which create Cards on all that board which contain case sync filed true 
    // INPUT :- Case Object(new)
    // OUTPUT :- Void
    public void OnAfterInsert(Object[] newObjects){
    	firstDayOfWeek= (firstDayOfWeek==null || firstDayOfWeek<0  || firstDayOfWeek > 6)?1:firstDayOfWeek;
    	Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek,5);
	    Map<String, Integer> nonWorkingDays = workWeek.readNonWorkingDays();
	    
        if (firstRun){
            firstRun = false;
        }else {
            System.debug('OnAfterInsert triggered itself!');
        }
        
        Case[] NewCases = (Case[]) newObjects;
        integer idx = 0;
        boolean flag=true;
        boolean flag1=true;
        boolean flag2=true;
        boolean flag3=true;
        
        Set<String> caseTypes=new Set<String>();
        caseTypes.add('All');
        List<RecordType> RecordTypes = leankor.realtimeController.getActiveRecordType('Case');
        Set<String> caseRecordTypes=new Set<String>();
        caseRecordTypes.add('All');
        for(Case myCase:NewCases){
            caseTypes.add(myCase.Type);
            if(RecordTypes.Size()>0 ){
                String myCaseRecordType =(String) myCase.get('RecordTypeId');
                if(myCaseRecordType != null || myCaseRecordType != ''){
                    caseRecordTypes.add(myCaseRecordType);
                }
            }
        }
        List<String> newCaseTypes=new List<String>(caseTypes);
        List<String> newCaseRecordTypes=new List<String>(caseRecordTypes);
        String CaseType='(';
        String CaseRecordType='(';
        
        for(Integer i=0;i<=newCaseTypes.size()-1;i++){
            if(i<newCaseTypes.size()-1){
                CaseType +=((newCaseTypes[i] !=null || newCaseTypes[i] !='null')?'\''+newCaseTypes[i]+'\',':'None');
            }else{
                CaseType +=((newCaseTypes[i] !=null || newCaseTypes[i] !='null')?'\''+newCaseTypes[i]+'\')':'None');
            }
        }
        
        for(Integer i=0;i<=newCaseRecordTypes.size()-1;i++){
            if(i<newCaseRecordTypes.size()-1){
                CaseRecordType +=((newCaseRecordTypes[i] !=null || newCaseRecordTypes[i] !='null')?'\''+newCaseRecordTypes[i]+'\',':'None');
            }else{
                CaseRecordType +=((newCaseRecordTypes[i] !=null || newCaseRecordTypes[i] !='null')?'\''+newCaseRecordTypes[i]+'\')':'None');
            }
        }

        String query ='Select Id,leankor__SevenDayWorkWeek__c,Name,(Select ID from leankor__valuestream__c.leankor__Kanban_Cards__r),(Select Id,Name,leankor__Top__c,leankor__CaseStatus__c,leankor__Left__c,leankor__X__c,leankor__Y__c,leankor__GUID__C,leankor__Order__c,leankor__Swimlane__c,leankor__Swimlane__r.leankor__Order__c,leankor__Swimlane__r.leankor__MasterContainer__c,leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Type__C,leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Order__c  from leankor__ValueStream__c.leankor__Zones__r),leankor__BoardType__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStreamLink__r.leankor__Boardtype__c,leankor__CaseCardCategory__c,leankor__CaseCardCategory__r.leankor__Color__c,leankor__CaseCardCategory__r.leankor__DerivedFrom__c,leankor__CaseCardCategory__r.leankor__Height__c,leankor__CaseCardCategory__r.leankor__JSONData__c,leankor__CaseCardCategory__r.leankor__JSONDefinition__c,leankor__CaseCardCategory__r.leankor__Title__c,leankor__CaseCardCategory__r.leankor__Width__c,leankor__CaseCardCategory__r.Name, leankor__CaseType__c,leankor__PointPicklist__c,leankor__CaseSynchronization__c,leankor__CaseRecordType__c  from leankor__ValueStream__c where  leankor__CaseRecordType__c  includes '+CaseRecordType+' and leankor__CaseType__c includes '+CaseType+' and leankor__CaseSynchronization__c =true and leankor__BoardType__c  in (\'Whiteboard\',\'Plan Board\',\'Kanban Board\',\'DashBoard\') AND leankor__ProjectRoom__c != null ';
        List<leankor__ValueStream__c> vsl=Database.query(query);
        List<realTimeController.Kanban> KanbanCards = new List<realTimeController.Kanban>();
        List<realTimeController.Kanban> tempKanbanCards = new List<realTimeController.Kanban>();
        String translatedCase = 'Case';
        String translatedPriority = '';
        
        for (Case myCase : NewCases){
            Integer i = 1;
            for(leankor__ValueStream__c vs:vsl){      
                String myCaseRecordId='';
                if(RecordTypes.size() >0){
                    myCaseRecordId=(String) myCase.get('RecordTypeId');
                    if(myCaseRecordId == null || myCaseRecordId ==''){
                        myCaseRecordId = 'All';
                    }
               }else{
                    myCaseRecordId= 'All';
               }
                String myCaseType = (myCase.get('Type') == null ? 'None' : myCase.Type);
                myCaseType = (myCase.Type == '' ? 'None' : myCase.Type);
               
                if(((vs.leankor__CaseType__c =='All') || (vs.leankor__CaseType__c.contains(myCaseType)) ) && (vs.leankor__CaseRecordType__c.contains(myCaseRecordId) || vs.leankor__CaseRecordType__c =='All')){          
                    realtimeController.Kanban card=new realtimeController.Kanban();
                    translatedPriority = myCase.Priority;
                    if(USECUSTOMLABEL_CONST){
                        translatedCase = System.Label.leankor.Case;
                        translatedPriority = picklistFieldMap.get(myCase.Priority);
                    }                    
                    card.Id='';
                    card.GUID =vs.Id+'-'+myCase.CaseNumber+'-'+i;//Implemented custom(dynamic) GUID for every kanbancard. Remember Here multiple VS multiple cards 
                    card.ForceID ='';
                    card.Name=(myCase.Priority == null ? 'None' : translatedPriority )+' : '+(myCase.Subject==null?(translatedCase + ' - '+myCase.CaseNumber):myCase.Subject);
                    card.Name = card.Name.mid(0, 80);
                    card.CmpID = '';
                    card.DueDate=System.Now();
                    card.Priority=(myCase.priority=='High'?1:(myCase.priority=='Medium'?2:(myCase.priority=='Low'?3:4)));
                    card.OwnerID = myCase.OwnerId;
                    card.HarveyBall='0';
                    card.DateColor='';
                    card.EstimatedDuration=1;
                    card.EffortRemaining = 1;
                    card.Description=(myCase.Description==null?'':myCase.Description);
                    card.DurationUnits ='Days';
                    card.KanbanUrl = baseUrl+'?id='+vs.Id+'&cardid=';
                    card.ValueStreamCardLink=vs.leankor__ValueStreamCardLink__c;
                    card.ValueStreamLinkID =vs.leankor__ValueStreamLink__c;
                    card.ValueStreamLinkBoardType = vs.leankor__ValueStreamLink__r.leankor__Boardtype__c;
                    card.ValueStream = vs.Id;
                    if(vs.leankor__PointPicklist__c != null){
                    List<Integer> ListPoint = (List<Integer>)JSON.Deserialize(vs.leankor__PointPicklist__c, List<integer>.class);
                    card.point = (ListPoint.size() <= 0 ?1 : ListPoint[0]);
                    }
                    card.Account=(myCase.AccountId==null?'':myCase.AccountId);
                    card.AccountName=(myCase.Account.Name==null?'':myCase.Account.Name);
                    card.Contact=(myCase.ContactId==null?'':myCase.ContactId);
                    card.ContactName = (myCase.Contact.Name==null?'':myCase.Contact.Name);
                    card.Opportunity = '';
                    card.OpportunityName='';
                    card.CaseID = myCase.Id;
                    card.CaseSubject = (myCase.Subject==null?('Case - '+myCase.CaseNumber):myCase.Subject);
                    card.CaseStatus = myCase.Status;
                    card.CasePriority = myCase.Priority;
                    card.Order = vs.leankor__Kanban_Cards__r.size()+10;
                    //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value. 
                    card.flowWithGS = false;
                    card.ownerIsActive = myCase.Owner.IsActive;
                
                    if (vs.leankor__Zones__r.size()>0){
                        flag = true;  
                        flag1 = true;
                        flag2 = true;
                        flag3 = true;
                        for(leankor__Zone__c zone : vs.leankor__Zones__r){
                            if(zone.leankor__CaseStatus__c == myCase.Status){
                                card.Top=Integer.valueOf(zone.leankor__Top__c);
                                card.Left=Integer.valueOf(zone.leankor__Left__c);
                                card.X = Integer.valueOf(zone.leankor__X__c);
                                card.Y = Integer.valueOf(zone.leankor__Y__c);
                                card.State='inzone';
                                card.ZoneID = zone.leankor__GUID__c;
                                card.SWForceID = zone.leankor__Swimlane__c;
                                card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                card.ZoneForceID = zone.ID;
                                card.ZoneTitle=zone.Name;
                                break;
                            }else if(zone.leankor__CaseStatus__c == 'Default'){
                                if(flag1){
                                    card.Top=Integer.valueOf(zone.leankor__Top__c);
                                    card.Left=Integer.valueOf(zone.leankor__Left__c);
                                    card.X = Integer.valueOf(zone.leankor__X__c);
                                    card.Y = Integer.valueOf(zone.leankor__Y__c);
                                    card.State = 'inzone';
                                    card.ZoneID = zone.leankor__GUID__c;
                                    card.SWForceID = zone.leankor__Swimlane__c;
                                    card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                    card.ZoneForceID = zone.ID;
                                    card.ZoneTitle = zone.Name;
                                    flag = false;
                                    flag1=false;
                                    flag2=false;
                                    flag3=false;
                                }
                            }else if( zone.leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Type__C=='Backlog' && (zone.leankor__CaseStatus__c == 'None'||zone.leankor__CaseStatus__c == '')) 
                            {
                                 if(flag2){
                                    card.Top=Integer.valueOf(zone.leankor__Top__c);
                                    card.Left=Integer.valueOf(zone.leankor__Left__c);
                                    card.X = Integer.valueOf(zone.leankor__X__c);
                                    card.Y = Integer.valueOf(zone.leankor__Y__c);
                                    card.State = 'inzone';
                                    card.ZoneID = zone.leankor__GUID__c;
                                    card.SWForceID = zone.leankor__Swimlane__c;
                                    card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                    card.ZoneForceID = zone.ID;
                                    card.ZoneTitle = zone.Name;
                                    flag = false;
                                    flag2=false;
                                    flag3=false;
                                }
                            } else if((zone.leankor__CaseStatus__c == 'None'||zone.leankor__CaseStatus__c == '') && vs.leankor__BoardType__c != 'Whiteboard'){
                                if(flag3){
                                    card.Top=Integer.valueOf(zone.leankor__Top__c);
                                    card.Left=Integer.valueOf(zone.leankor__Left__c);
                                    card.X = Integer.valueOf(zone.leankor__X__c);
                                    card.Y = Integer.valueOf(zone.leankor__Y__c);
                                    card.State = 'inzone';
                                    card.ZoneID = zone.leankor__GUID__c;
                                    card.SWForceID = zone.leankor__Swimlane__c;
                                    card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                    card.ZoneForceID = zone.ID;
                                    card.ZoneTitle = zone.Name;
                                    flag = false;
                                    flag3=false;
                                }   
                            } else{
                                if(flag){
                                    card.Top=2100;
                                    card.Left=2100;
                                    card.X = 0;
                                    card.Y = 47;
                                    card.State='nozone';
                                    card.ZoneID ='';
                                    card.ZoneTitle='';
                                }
                            }
                        }
                    }else{
                        card.Top=2100;
                        card.Left=2100;
                        card.X = 0;
                        card.Y = 47;
                        card.State='nozone';
                        card.ZoneID ='';
                        card.ZoneTitle='';
                   }
                   card.StartDate = System.Now();
				   
                    if(!vs.leankor__SevenDayWorkWeek__c){
                		//Check DueDate is not in working days and in non working day it is 1st or 2nd
						if(!nonWorkingDays.isEmpty() && (nonWorkingDays.get(card.Startdate.format('EEEE')) == 1)){
							card.Startdate = card.Startdate + 2;
                        	card.Duedate = card.Duedate + 2;
						}else if(!nonWorkingDays.isEmpty() && (nonWorkingDays.get(card.Startdate.format('EEEE')) == 2)){
                        card.Startdate = card.Startdate + 1;
                        card.Duedate = card.Duedate + 1;
                        }	                   
                   }
                   
                   card.Width = Integer.valueOf(vs.leankor__CaseCardCategory__r.leankor__Width__c);
                   card.Height = Integer.valueOf(vs.leankor__CaseCardCategory__r.leankor__Height__c);
                   card.Title = vs.leankor__CaseCardCategory__r.leankor__Title__c;
                   card.TemplateID = vs.leankor__CaseCardCategory__c;
                   card.color = vs.leankor__CaseCardCategory__r.leankor__Color__c;
                   card.JSONDefinition = vs.leankor__CaseCardCategory__r.leankor__JSONDefinition__c;
                   card.JSONData = vs.leankor__CaseCardCategory__r.leankor__JSONData__c;
                   card.BoardType = vs.leankor__boardType__c;
                   KanbanCards.add(card);
                   
                   i++;
               }
           }
        }
        
        //As KanbanCards list is cleared inside create KC code we need to manage duplicate list for sending broadcast
        tempKanbanCards.addAll(KanbanCards);
        List<leankor__KanbanCard__c> successCards = realtimeController.CreateKanbanCards('',KanbanCards);
        
        if(successCards.size() > 0)
        {	
        	leankor.GanttTaskBoard.CreateScheduleMode(successCards);
	        leankor.GanttTaskBoard.CreateDefaultResourceAssignment(successCards);                                  
        }
        
        List<realtimeController.bulkStreaming> bulkStreamings = new List<realtimeController.bulkStreaming> ();
        
        for(leankor__KanbanCard__c kc:successCards){
        	for( leankor.realtimeController.Kanban k :tempKanbanCards){
                if(k.GUID == kc.leankor__GUID__c){ // TODO : Need to put GUID inplace of Id for change to RealTimeController. 
                    k.ForceID = kc.Id;
                    k.Id = kc.Id;
                    K.CaseTrigger = true;
                    String st = JSON.serialize(k);
                    realtimeController.bulkStreaming bulkStream = new realtimeController.bulkStreaming();
                    bulkStream.VSID = k.valuestream;
                    bulkStream.Verb = 'CreateKanbanCard';
                    bulkStream.SessionID = UserInfo.getSessionId();
                    bulkStream.SomeJSONdata = st;
                    bulkStreamings.add(bulkStream);
                }
            }
        }
        realtimeController.manageBulkStreaming(bulkStreamings,'CreateKanbanCard');
    }


    //This Method is Run By trigger on Case and Its funnctionlity is to update Related Card With This case ID.
    //INPUT :- Case Object (Old,NEW,Map <CaseID, Ccomplete Object>) 
    //OUTPUT :- Void
    public void OnAfterUpdate(Object[] oldObjects, Object[] updatedObjects, Map<ID,Object> ObjectMap){
        if (firstRun){
            firstRun = false;
        }else {
            System.debug('OnAfterUpdate triggered itself!');
        }
        
        String translatedCase = 'Case';
        String translatedPriority = '';
        Case[] oldCases = (Case[]) oldObjects;
        Case[] updatedCases = (Case[]) updatedObjects;
        integer idx = 0;
        boolean flag=true;
        Set<String> caseTypes = new Set<String>();
        caseTypes.add('All');
        List<RecordType> RecordTypes = leankor.realtimeController.getActiveRecordType('Case');
        Set<String> caseRecordTypes = new Set<String>();
        caseRecordTypes.add('All');
        for(Case myCase:updatedCases){
            if(myCase.Status != oldCases[idx].Status){
                if(myCase.Type != null){
                    caseTypes.add(myCase.Type);
                }
                if(RecordTypes.Size()>0){
                    String myCaseRecordType =(String) myCase.get('RecordTypeId');
                    if(myCaseRecordType != null || myCaseRecordType != ''){
                        caseRecordTypes.add(myCaseRecordType);
                    }
                } 
            }
            idx++;
        }

        List<String> newCaseTypes = new List<String>(caseTypes);
        List<String> newCaseRecordTypes = new List<String>(caseRecordTypes);
        String CaseType='(';
        String CaseRecordType='(';
        for(Integer i=0;i<=newCaseTypes.size()-1;i++){
            if(i<newCaseTypes.size()-1){
                CaseType +=((newCaseTypes[i] != null || newCaseTypes[i] !='null')?'\''+newCaseTypes[i]+'\',':'None');
            }else{
                CaseType +=((newCaseTypes[i] != null || newCaseTypes[i] !='null')?'\''+newCaseTypes[i]+'\')':'None');
            }
        }
      
        for(Integer i=0;i<=newCaseRecordTypes.size()-1;i++){
            if(i<newCaseRecordTypes.size()-1){
                CaseRecordType +=((newCaseRecordTypes[i] !=null || newCaseRecordTypes[i] !='null')?'\''+newCaseRecordTypes[i]+'\',':'None');
            }else{
                CaseRecordType +=((newCaseRecordTypes[i] !=null || newCaseRecordTypes[i] !='null')?'\''+newCaseRecordTypes[i]+'\')':'None');
            }
        }

        String query ='Select Id,leankor__SevenDayWorkWeek__c,Name,(Select Id,Name,leankor__CaseStatus__c,leankor__Top__c,leankor__Left__c,leankor__X__c,leankor__Y__c,leankor__GUID__C,leankor__Swimlane__c,leankor__Swimlane__r.leankor__MasterContainer__c from leankor__ValueStream__c.leankor__Zones__r),(SELECT Id,leankor__Opportunity__C,leankor__Opportunity__r.Name,leankor__Account__c,leankor__Account__r.Name,leankor__Bottom__c,leankor__Case__c,leankor__Case__r.Subject,leankor__Case__r.Priority,leankor__Case__r.Status,leankor__CmpID__c,leankor__Color__c,leankor__Contact__c,leankor__Contact__r.Name,leankor__CSSLayout__c,leankor__DateColor__c,leankor__Order__c,leankor__DescriptionLong__c,leankor__EffortRemaining__c,leankor__Description__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__EstimatedDuration__c,leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__KanbanCardTemplate__r.leankor__Title__c,leankor__Left__c,leankor__PercentComplete2__c,leankor__Priority__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStreamLink__r.leankor__Boardtype__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__CardID__c,leankor__Y__c,leankor__ZoneGUID__c,Name,OwnerId,leankor__StartDate__c,leankor__StartDateTime__c,leankor__DueDateTime__c,leankor__valuestream__r.leankor__BoardType__c,leankor__point__c FROM leankor__ValueStream__c.leankor__Kanbans__r ),leankor__CaseCardCategory__r.Name, leankor__CaseType__c, leankor__CaseSynchronization__c from leankor__ValueStream__c where leankor__CaseRecordType__c  includes '+CaseRecordType+' and leankor__CaseType__c includes '+CaseType+' and leankor__CaseSynchronization__c =true and leankor__BoardType__c  in (\'Kanban Board\',\'Plan Board\',\'Whiteboard\',\'DashBoard\')';
        List<leankor__ValueStream__c> vsl=Database.query(query);
        List<realtimeController.Kanban> KanbanCards=new List<realtimeController.Kanban>();
        List<realtimeController.bulkStreaming> bulkStreamings = new List<realtimeController.bulkStreaming> ();
        Integer cIdx=0;
        for(Case myCase : updatedCases){
            for(leankor__ValueStream__c vs:vsl){
                if(vs.leankor__Kanbans__r.Size() >0 ){
                    for(leankor__KanbanCard__c kanban : vs.leankor__Kanbans__r){
                        translatedPriority = myCase.Priority;
                        if(USECUSTOMLABEL_CONST){
                            translatedCase = System.Label.leankor.Case;
                            translatedPriority = picklistFieldMap.get(myCase.Priority);
                        }  
                        if(kanban.leankor__GUID__C.startswith(vs.Id+'-'+myCase.CaseNumber+'-') || kanban.leankor__Case__c == myCase.Id ){ 
                            leankor.realtimeController.Kanban card=new leankor.realtimeController.Kanban();
                            card.Id = kanban.Id; // TODO : replace Id to GUID and need one Id as Force ID
                            card.GUId = kanban.leankor__GUID__C;
                            card.ForceID = kanban.Id;
                            card.Point = Kanban.leankor__point__c;
                            card.Name=(myCase.Priority == null ? 'None' : translatedPriority )+' : '+(myCase.Subject==null?(translatedCase + ' - '+myCase.CaseNumber):myCase.Subject);
                            card.CmpID = kanban.leankor__CmpID__c;
                            card.DueDate = kanban.leankor__DueDateTime__c;
                            card.Priority=(myCase.priority=='High'?1:(myCase.priority=='Medium'?2:(myCase.priority=='Low'?3:4)));
                            card.OwnerID = kanban.OwnerId;
                            card.HarveyBall = JSON.serialize(kanban.leankor__PercentComplete2__c); 
                            card.EstimatedDuration = kanban.leankor__EstimatedDuration__c;
                            card.Description = (myCase.Description==null?kanban.leankor__DescriptionLong__c:myCase.Description);
                            card.EffortRemaining=integer.valueof(kanban.leankor__EffortRemaining__c);
                            card.DurationUnits = kanban.leankor__DurationUnits__c;
                            card.KanbanUrl = baseUrl+'?id='+vs.Id+'&cardid=';
                            card.ValueStreamCardLink = (kanban.leankor__ValueStreamCardLink__c==null? '' : kanban.leankor__ValueStreamCardLink__c);
                            card.ValueStreamLinkID = (kanban.leankor__ValueStreamLink__c==null?'':kanban.leankor__ValueStreamLink__c);
                            card.ValueStream = kanban.leankor__ValueStream__c;
                            card.Account = (kanban.leankor__Account__c==null?myCase.AccountId:kanban.leankor__Account__c);
                            card.AccountName = (kanban.leankor__Account__r.Name==null?myCase.Account.Name:kanban.leankor__Account__r.Name);
                            card.Contact = (kanban.leankor__Contact__c==null?myCase.ContactId:kanban.leankor__Contact__c);
                            card.ContactName = (kanban.leankor__Contact__r.Name==null?myCase.Contact.Name : kanban.leankor__Contact__r.Name);
                            card.Opportunity = (kanban.leankor__Opportunity__c==null?'':kanban.leankor__Opportunity__c);
                            card.OpportunityName = (kanban.leankor__Opportunity__c==null?'': kanban.leankor__Opportunity__r.Name);
                            card.CaseID = (kanban.leankor__Case__c==null?myCase.Id:kanban.leankor__Case__c);
                            card.CaseSubject=(kanban.leankor__Case__r.Subject==null?myCase.Subject:kanban.leankor__Case__r.Subject);
                            card.CaseStatus=(kanban.leankor__Case__r.Status==null?myCase.Status:kanban.leankor__Case__r.Status);
                            card.CasePriority=(kanban.leankor__Case__r.Priority==null?myCase.Priority:kanban.leankor__Case__r.Priority);
                            card.LeavedZoneId =(kanban.leankor__ZoneGUID__c==null?'':kanban.leankor__ZoneGUID__c);
                            card.StartDate = kanban.leankor__StartDateTime__c;
                            card.Order = (kanban.leankor__Order__c == null ? 0 : kanban.leankor__Order__c);
                            card.CardID = kanban.leankor__CardID__c;                          
                            //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value. 
                    		card.flowWithGS = false;                          
                            if(vs.leankor__Zones__r.size()>0){
                                flag = true;
                                for(leankor__Zone__c zone : vs.leankor__Zones__r){
                                    if(kanban.leankor__ZoneGUID__c != null && kanban.leankor__ZoneGUID__c == zone.leankor__GUID__C){
                                        card.LeavedZoneTitle = zone.Name;
                                    }
                                    if(zone.leankor__CaseStatus__c == myCase.Status){
                                        card.Top = Integer.valueOf(zone.leankor__Top__c);
                                        card.Left = Integer.valueOf(zone.leankor__Left__c);
                                        card.X = Integer.valueOf(zone.leankor__X__c);
                                        card.Y = Integer.valueOf(zone.leankor__Y__c);
                                        card.State = 'inzone';
                                        card.ZoneID = zone.leankor__GUID__c;
                                        card.SWForceID = zone.leankor__Swimlane__c;
                                        card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                        card.ZoneForceID = zone.ID;
                                        break;
                                    }else if(zone.leankor__CaseStatus__c == 'Default'){
                                        if(flag){
                                            card.Top=Integer.valueOf(zone.leankor__Top__c);
                                            card.Left=Integer.valueOf(zone.leankor__Left__c);
                                            card.x=Integer.valueOf(zone.leankor__X__c);
                                            card.y=Integer.valueOf(zone.leankor__Y__c);
                                            card.state='inzone';
                                            card.zoneid=zone.leankor__GUID__c;//Need Discussion - All VS with Case Synchronization- enable should create zones with name of case status.
                                            card.SWForceID = zone.leankor__Swimlane__c;
                                            card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                            card.ZoneForceID = zone.ID;
                                            flag=false;
                                        }
                                    }else{
                                        if(flag){
                                            card.Top = 2100;
                                            card.Left = 2100;
                                            card.X = 0;
                                            card.Y = 47;
                                            card.State = 'nozone';
                                            card.ZoneID = '';
                                        }
                                    }
                                }
                            }else{
                                card.Top = 2100;
                                card.Left = 2100;
                                card.X = 0;
                                card.Y = 47;
                                card.State = 'nozone';
                                card.ZoneID = '';
                            }
                            card.Width = Integer.valueOf(kanban.leankor__Width__c);
                            card.Height = Integer.valueOf(kanban.leankor__Height__c);
                            card.Title = kanban.leankor__KanbanCardTemplate__r.leankor__Title__c;
                            card.TemplateID = kanban.leankor__KanbanCardTemplate__c;
                            card.Color = kanban.leankor__Color__c;
                            card.JSONDefinition = kanban.leankor__JSONDefinition__c;
                            card.JSONData = kanban.leankor__JSONData__c;                        
                            card.BoardType = kanban.leankor__valuestream__r.leankor__BoardType__c;          
                            realtimeController.bulkStreaming bulkStream = new realtimeController.bulkStreaming();
                            bulkStream.VSID = card.valuestream;
                            bulkStream.Verb = 'MoveKanbanCard';
                            bulkStream.SessionID = UserInfo.getSessionId();
                            bulkStream.SomeJSONData = JSON.serialize(card);
                            bulkStreamings.add(bulkStream);
                        } 
                    }
                }
            }
        }
        realtimeController.manageBulkStreaming(bulkStreamings,'MoveKanbanCard');
    }


    // This is method run at Detele trigger on case which delete all related cards.
    // INPUT : - Case Object
    // OUTPUT :- Void
    //
    public void OnAfterDelete(Object[] deletedObjects, Map<ID,Object> ObjectMap){
        List<String> deleteCards=new List<String>();    
        Case[] deletedCases = (Case[]) deletedObjects;
        integer idx = 0;
        boolean flag = true;  
        Set<String> caseTypes = new Set<String>();
        caseTypes.add('All');
        List<RecordType> RecordTypes = leankor.realtimeController.getActiveRecordType('Case');
        Set<String> caseRecordTypes = new Set<String>();
        caseRecordTypes.add('All');
        for(Case myCase:deletedCases){
            if(myCase.Type != null){
                caseTypes.add(myCase.Type);
            }else{
                caseTypes.add('None');
            }       
            if(RecordTypes.Size()>0){
                String myCaseRecordType =(String) myCase.get('RecordTypeId');
                if(myCaseRecordType != null || myCaseRecordType != ''){
                    caseRecordTypes.add(myCaseRecordType);
                }
            } 
        }
        List<String> newCaseTypes = new List<String>(caseTypes);
        List<String> newCaseRecordTypes = new List<String>(caseRecordTypes);
        String CaseType='(';
        String CaseRecordType='(';

        for(Integer i=0;i<=newCaseTypes.size()-1;i++){
            if(i<newCaseTypes.size()-1){
                CaseType +=((newCaseTypes[i] !=null || newCaseTypes[i] !='null')?'\''+newCaseTypes[i]+'\',':'None');
            }else{
                CaseType +=((newCaseTypes[i] !=null || newCaseTypes[i] !='null')?'\''+newCaseTypes[i]+'\')':'None');
            }
        }
        for(Integer i=0;i<=newCaseRecordTypes.size()-1;i++){
            if(i<newCaseRecordTypes.size()-1){
                CaseRecordType +=((newCaseRecordTypes[i] !=null || newCaseRecordTypes[i] !='null')?'\''+newCaseRecordTypes[i]+'\',':'None');
            }else{
                CaseRecordType +=((newCaseRecordTypes[i] !=null || newCaseRecordTypes[i] !='null')?'\''+newCaseRecordTypes[i]+'\')':'None');
            }
        }
        String query ='Select Id,Name,(Select Id,Name,leankor__CaseStatus__c,leankor__Top__c,leankor__Left__c,leankor__X__c,leankor__Y__c,leankor__GUID__C from leankor__ValueStream__c.leankor__Zones__r),(SELECT Id,leankor__Opportunity__C,leankor__Opportunity__r.Name,leankor__Account__c,leankor__Account__r.Name,leankor__Bottom__c,leankor__Case__c,leankor__Case__r.Subject,leankor__Case__r.Priority,leankor__Case__r.Status,leankor__CmpID__c,leankor__Color__c,leankor__Contact__c,leankor__Contact__r.Name,leankor__CSSLayout__c,leankor__DateColor__c,leankor__DescriptionLong__c,leankor__Description__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__EstimatedDuration__c,leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__Left__c,leankor__PercentComplete2__c,leankor__Priority__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__ZoneGUID__c,Name,OwnerId FROM leankor__ValueStream__c.leankor__Kanbans__r ),leankor__CaseCardCategory__r.Name, leankor__CaseType__c, leankor__CaseSynchronization__c from leankor__ValueStream__c where ( leankor__CaseRecordType__c  includes '+CaseRecordType+' OR leankor__CaseType__c includes '+CaseType+') and leankor__CaseSynchronization__c =true and leankor__BoardType__c  in (\'Whiteboard\',\'Kanban Board\',\'DashBoard\',\'Plan Board\')';
        List<leankor__ValueStream__c> vsl=Database.query(query);
        List<realtimeController.bulkStreaming> bulkStreamings = new List<realtimeController.bulkStreaming> ();
        for (Case myCase : deletedCases){              
            for(leankor__ValueStream__c vs : vsl){
                leankor.realtimeController.CardStreamingPackage card = new leankor.realtimeController.CardStreamingPackage();
                if(vs.leankor__Kanbans__r.Size() >0){
                    for(leankor__KanbanCard__c kanban : vs.leankor__Kanbans__r){
                        if(kanban.leankor__GUID__C.startswith(vs.Id+'-'+myCase.CaseNumber+'-') || kanban.leankor__Case__c == myCase.Id ){        
                            card.Id = kanban.Id;
                            card.GUID = kanban.leankor__GUID__c;
                            card.ForceID = kanban.Id;
                            //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
                            card.flowWithGS = false;
                            card.ValueStream = kanban.leankor__ValueStream__c;
                            realtimeController.bulkStreaming bulkStream = new realtimeController.bulkStreaming();
                            bulkStream.VSID = vs.Id;
                            bulkStream.Verb = 'DeleteKanbanCard';
                            bulkStream.SessionID = UserInfo.getSessionId();
                            bulkStream.SomeJSONData = JSON.serialize(card);
                            bulkStreamings.add(bulkStream);
                            deleteCards.add(card.GUID);
                        } 
                    } 
                } 
            } 
        }
        realtimeController.removeKanbanCard(deleteCards);
        realtimeController.manageBulkStreaming(bulkStreamings,'DeleteKanbanCard');    
    }

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