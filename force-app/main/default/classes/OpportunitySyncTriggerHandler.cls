/**
 Copyright 2012-2015 Lucidsoft Inc. All rights reserved.
 FILE: OpportunitySyncTriggerHandler.cls
 CLASS: OpportunitySyncTriggerHandler
*/
public with sharing class OpportunitySyncTriggerHandler{
    public static boolean firstRun = true;
    Boolean TempRecordType =  false;
    List<UserRole> AllRoles = [SELECT Id, Name, ParentRoleId FROM UserRole LIMIT 49999];
    PageReference pageRef_opp = new PageReference('/apex/leankor__VisualKanban');
    public static String baseUrl= 'https://' + DomainCreator.getOrgMyDomainHostname()+''+(new PageReference('/apex/leankor__VisualKanban').getUrl());
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static final Boolean USECUSTOMLABEL_CONST = leankor__LeanConstants__c.getInstance().leankor__UseCustomLabels__c;
    public OpportunitySyncTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    //ss 04.05.2018
    //Added variable for getting first day of week from custom setting 	
    Integer firstDayOfWeek =  leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c == null ?1 : leankor__LeanConstants__c.getInstance().leankor__FirstDayOfTheWeek__c.intValue();
    //ss 04.05.2018


    public void OnBeforeInsert(Object[] newObjects) {
        Opportunity[] newOpportunity = (Opportunity[]) newObjects;

        for (Opportunity obj : newOpportunity) {
            obj.Name = (obj.Name.replaceAll('\\<.*?\\>', '')).mid(0, 120);
        }
    }


    //
    // This Code run when insert trigger run which create Cards on all that board which contain Opportunity sync filed true 
    // INPUT :- Opportunity Object(new)
    // OUTPUT :- Void
    //
    public void OnAfterInsert_opp(Object[] newObjects){
    	firstDayOfWeek= (firstDayOfWeek==null || firstDayOfWeek<0  || firstDayOfWeek > 6)?1:firstDayOfWeek;
    	//Create instance of WorkWeek which provides Working week days information
	    Util.WorkWeek workWeek = new Util.WorkWeek(firstDayOfWeek,5);
	    Map<String, Integer> nonWorkingDays = workWeek.readNonWorkingDays();	
        // EXECUTE AFTER INSERT LOGIC
        if (firstRun){
            firstRun = false;
        }else {
            System.debug('OnAfterInsert triggered itself!');
        }
        // LOGIC GOES HERE
        Opportunity[] NewOpportunity = (Opportunity[]) newObjects;
        
        integer idx_opp = 0;
        boolean flag_opp=true;
       Set<String> OpportunityTypes=new Set<String>();
       OpportunityTypes.add('All');
        List<RecordType> RecordTypes = leankor.realtimeController.getActiveRecordType('Opportunity'); 
        
        // check this methord also run for Opportunity as well( leankor.realtimeKanbanController.getActiveRecordType)
        Set<String> OpportunityRecordTypes = new Set<String>();
        OpportunityRecordTypes.add('All');
        If(RecordTypes.size() == 0){
        TempRecordType = true ;
         OpportunityRecordTypes.add('None');
        }
        for(Opportunity myOpportunity:NewOpportunity){
            if(myOpportunity.Type == null){
            OpportunityTypes.add('None');
            }else{
            OpportunityTypes.add(myOpportunity.Type);
            }
            if(RecordTypes.Size()>0 ){
                String myOppRecordType =(String) myOpportunity.get('RecordTypeId');
                if(myOppRecordType != null || myOppRecordType != ''){
                    OpportunityRecordTypes.add(myOppRecordType);
                }
            }
        }
        List<String> newOppTypes=new List<String>(OpportunityTypes);
        List<String> newOppRecordTypes=new List<String>(OpportunityRecordTypes);
       String OpportunityType='(';
        String OpportunityRecordType='(';
       
        for(Integer i=0;i<=newOppTypes.size()-1;i++){
            if(i<newOppTypes.size()-1){
                OpportunityType +=((newOppTypes[i] !=null || newOppTypes[i] !='null')?'\''+newOppTypes[i]+'\',':'None');
            }else{
                OpportunityType +=((newOppTypes[i] !=null || newOppTypes[i] !='null')?'\''+newOppTypes[i]+'\')':'None');
            }
        }
        for(Integer i=0;i<=newOppRecordTypes.size()-1;i++){
            if(i<newOppRecordTypes.size()-1){
                OpportunityRecordType +=((newOppRecordTypes[i] !=null || newOppRecordTypes[i] !='null')?'\''+newOppRecordTypes[i]+'\',':'None');
            }else{
                OpportunityRecordType +=((newOppRecordTypes[i] !=null || newOppRecordTypes[i] !='null')?'\''+newOppRecordTypes[i]+'\')':'None');
            }
        }
        String query_Opp='Select Id,leankor__SevenDayWorkWeek__c,Name,leankor__OpportunityRoleId__c,(Select ID from leankor__valueStream__c.leankor__kanban_cards__r),(Select Id,Name,leankor__Top__c,leankor__OpportunityStageName__c,leankor__Left__c,leankor__X__c,leankor__Y__c,leankor__GUID__C,leankor__Order__c,leankor__Swimlane__c,leankor__Swimlane__r.leankor__Order__c,leankor__Swimlane__r.leankor__MasterContainer__c,leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Type__C,leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Order__c  from leankor__ValueStream__c.leankor__Zones__r),leankor__BoardType__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStreamLink__r.leankor__Boardtype__c,leankor__OpportunityLeadSource__c,leankor__OpportunityCardCategory__c,leankor__OpportunityCardCategory__r.leankor__Color__c,leankor__OpportunityCardCategory__r.leankor__Height__c,leankor__OpportunityCardCategory__r.leankor__JSONData__c,leankor__OpportunityCardCategory__r.leankor__JSONDefinition__c,leankor__OpportunityCardCategory__r.leankor__Title__c,leankor__OpportunityCardCategory__r.leankor__Width__c,leankor__OpportunityCardCategory__r.Name, leankor__OpportunityType__c, leankor__OpportunitySynchronization__c,leankor__OpportunityRecordType__c,leankor__PointPicklist__c  from leankor__ValueStream__c where  leankor__OpportunityRecordType__c  includes '+OpportunityRecordType+' and leankor__OpportunityType__c includes '+OpportunityType+' and leankor__OpportunitySynchronization__c =true and leankor__BoardType__c  in (\'Whiteboard\',\'Kanban Board\',\'Plan Board\',\'DashBoard\') limit 9999';
        List<leankor__ValueStream__c> vsl=Database.query(query_opp);
        List<realTimeController.Kanban> KanbanCards =new List<realTimeController.Kanban>();
        List<realTimeController.Kanban> tempKanbanCards = new List<realTimeController.Kanban>();
        String translatedOpportunityLabel = 'Opportunity';
        for(Opportunity myOpp:NewOpportunity){       
            Integer i=1;
            for(leankor__ValueStream__c vs:vsl){ 
                String myOppleadsource =((myOpp.LeadSource ==null )?'None':myOpp.LeadSource);
                String myOppType =((myOpp.Type ==null )?'None':myOpp.Type);
                String myOppRecordId='';
                if(RecordTypes.size() >0){  
                    myOppRecordId=(String) myOpp.get('RecordTypeId');
                    if(myOppRecordId == null || myOppRecordId ==''){
                       myOppRecordId= 'All';
                    }
                }else{
                    myOppRecordId= 'All';
                }             
                String Getrole =vs.leankor__OpportunityRoleId__c ;
                String tempLeadSourceString = (myOpp.get('LeadSource') == null ? 'None' : myOpp.LeadSource);
                Set<String> DownRolesId = leankor.ProjectBoardCarousel.GetDownRolesId(Getrole,AllRoles);
                String tempTypeString = (myOpp.get('Type') == null ? 'None' : myOpp.Type);             
                
                if((vs.leankor__OpportunityType__c =='All' || vs.leankor__OpportunityType__c.contains(tempTypeString)) && (vs.leankor__OpportunityRecordType__c.contains(myOppRecordId)|| TempRecordType || vs.leankor__OpportunityRecordType__c =='All') &&  (DownRolesId.contains(Userinfo.getUserRoleId())) &&   (vs.leankor__OpportunityLeadSource__c =='All' || vs.leankor__OpportunityLeadSource__c.contains(tempLeadSourceString))){
                    if(USECUSTOMLABEL_CONST){
                        translatedOpportunityLabel = System.Label.leankor.Opportunity;
                    }  

                    RealTimeController.Kanban card = new RealTimeController.Kanban();
                    Card.Id = '';
                    card.GUID=myOpp.ID+'-'+system.Now().getTime()+'-'+i;//Implemented custom(dynamic) guid for every kanbancard. Remember Here multiple VS multiple cards 
                    card.ForceID='';
                    card.Name= translatedOpportunityLabel + ':'+ myOpp.Name;
                    card.Name = card.Name.mid(0, 80);
                    card.CmpID='';
                    card.DueDate=myOpp.CloseDate;
                    card.Priority= 4;
                    card.OwnerID=myOpp.OwnerId;
                    card.HarveyBall='0';
                    card.DateColor='';
                    card.EstimatedDuration=1;
                    card.EffortRemaining=1;
                    card.Description=(myOpp.Description==null?'':myOpp.Description);
                    card.Durationunits='Days';
                    card.KanbanUrl=baseUrl+'?id='+vs.Id+'&cardid=';
                    card.ValueStreamCardLink=vs.leankor__ValueStreamCardLink__c;
                    card.ValueStreamLinkID=vs.leankor__ValueStreamLink__c;
                    card.ValueStream=vs.Id;
                    card.ValueStreamLinkBoardType = vs.leankor__ValueStreamLink__r.leankor__Boardtype__c;
                    card.Account=(myOpp.AccountId==null?'':myOpp.AccountId);
                    card.AccountName=(myOpp.Account.Name==null?'':myOpp.Account.Name);
                    card.Contact='';
                    card.ContactName='';
                    card.Opportunity=myOpp.Id;
                    card.OpportunityStage = myOpp.stageName;
                    card.OpportunityName = myOpp.Name;
                    card.CaseID = '';
                    card.Order = vs.leankor__kanban_cards__r.size()+20 ;
                    //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
                    card.flowWithGS = false;
                    card.ownerIsActive = myOpp.Owner.IsActive;
                    
                    if(vs.leankor__PointPicklist__c != null){
                        List<Integer> ListPoint = (List<Integer>)JSON.Deserialize(vs.leankor__PointPicklist__c, List<integer>.class);
                        card.point = (ListPoint.size() <= 0 ?1 : ListPoint[0]);
                    }

                    if(vs.leankor__Zones__r.size()>0){
                        Boolean flag=true;  
                        boolean flag1=true;
                        boolean flag2=true;
                        boolean flag3=true;
                        for(leankor__Zone__c zone:vs.leankor__Zones__r){
                            if(zone.leankor__OpportunityStageName__c == myOpp.StageName){
                                card.Top=Integer.valueOf(zone.leankor__Top__c);
                                card.Left=Integer.valueOf(zone.leankor__Left__c);
                                card.X=Integer.valueOf(zone.leankor__X__c);
                                card.Y=Integer.valueOf(zone.leankor__Y__c);
                                card.State='inzone';
                                card.Zoneid=zone.leankor__GUID__c;
                                card.SWForceID = zone.leankor__Swimlane__c;
                                card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                card.ZoneForceID = zone.ID;
                                card.ZoneTitle=zone.Name;
                                break;
                            }else if(zone.leankor__OpportunityStageName__c == 'Default'){
                                if(flag){
                                    card.Top=Integer.valueOf(zone.leankor__Top__c);
                                    card.Left=Integer.valueOf(zone.leankor__Left__c);
                                    card.X=Integer.valueOf(zone.leankor__X__c);
                                    card.Y=Integer.valueOf(zone.leankor__Y__c);
                                    card.State='inzone';
                                    card.ZoneId=zone.leankor__GUID__c;
                                    card.SWForceID = zone.leankor__Swimlane__c;
                                    card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                    card.ZoneForceID = zone.ID;
                                    card.ZoneTitle=zone.Name;
                                    Flag=false;
                                }
                            }else if( zone.leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Type__C=='Backlog' && (zone.leankor__OpportunityStageName__c == 'None'||zone.leankor__OpportunityStageName__c == '')) 
                            //zone.leankor__Order__c==1 && if((zone.leankor__Order__c==1) && (zone.leankor__Swimlane__r.leankor__Order__c==1) && (zone.leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Order__c==1))
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
                            } else if((zone.leankor__OpportunityStageName__c == 'None'||zone.leankor__OpportunityStageName__c == '') && vs.leankor__BoardType__c != 'Whiteboard'){
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
                            }else{
                                if(flag){
                                    card.Top=2100;
                                    card.Left=2100;
                                    card.X=0;
                                    card.Y=47;
                                    card.State='nozone';
                                    card.ZoneId='';
                                    card.ZoneTitle='';
                                }
                            }
                        }
                    }else{
                        card.Top=2100;
                        card.Left=2100;
                        card.X=0;
                        card.Y=47;
                        card.State='nozone';
                        card.ZoneId='';
                        card.ZoneTitle='';
                    }
                    card.StartDate = card.DueDate ;
                    
                    //ss 04.05.2018
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
                    
                    card.Width=Integer.valueOf(vs.leankor__OpportunityCardCategory__r.leankor__Width__c);
                    card.Height=Integer.valueOf(vs.leankor__OpportunityCardCategory__r.leankor__Height__c);
                    card.Title=vs.leankor__OpportunityCardCategory__r.leankor__Title__c;
                    card.TemplateID=vs.leankor__OpportunityCardCategory__c;
                    card.Color=vs.leankor__OpportunityCardCategory__r.leankor__Color__c;
                    card.JSONDefinition=vs.leankor__OpportunityCardCategory__r.leankor__JSONDefinition__c;
                    card.JSONData=vs.leankor__OpportunityCardCategory__r.leankor__JSONData__c;
                    card.BoardType=vs.leankor__BoardType__c;
                    KanbanCards.add(card);                  
                    i++;
                }
            }
        }
        
        //As KanbanCards list is cleared inside create KC code we need to manage duplicate list for sending broadcast
        tempKanbanCards.addAll(KanbanCards); 
        List<leankor__KanbanCard__c> successCards= RealTimeController.CreateKanbanCards('',KanbanCards);
        
        if(successCards.Size() > 0){      		
       		//creating default RA and SM                      
	        leankor.GanttTaskBoard.CreateScheduleMode(successCards);
	        leankor.GanttTaskBoard.CreateDefaultResourceAssignment(successCards);
        }
        
        List<realtimeController.bulkStreaming> bulkStreamings = new List<RealTimeController.bulkStreaming> ();
        for(leankor__KanbanCard__c kc:successCards){
            for(leankor.RealTimeController.Kanban k:tempKanbanCards){
                if(k.GUID == kc.leankor__GUID__c ){ // TODO : Need to put GUID inplace of Id for change to RealTimeController. 
                    k.ForceID = kc.Id;
                    k.Id = kc.Id;
                    K.CaseTrigger = true;
                    RealTimeController.bulkStreaming bulkStream = new RealTimeController.bulkStreaming();
                    bulkStream.VSID = k.valuestream;
                    bulkStream.Verb = 'CreateKanbanCard';
                    bulkStream.SessionID = UserInfo.getSessionId();
                    bulkStream.SomeJSONdata = Json.serialize(k);
                    bulkStreamings.add(bulkStream);
                }
            }
        }
        RealTimeController.manageBulkStreaming(bulkStreamings,'CreateKanbanCard');
    }


    public void OnAfterUpdate(Object[] oldObjects, Object[] updatedObjects, Map<ID,Object> ObjectMap){
        // EXECUTE AFTER INSERT LOGIC
        if (firstRun){
            firstRun = false;
        }else {
            System.debug('OnAfterUpdate triggered itself!');
        }
        // LOGIC GOES HERE
        Opportunity[] oldOpp = (Opportunity[]) oldObjects;
        Opportunity[] updatedOpp = (Opportunity[]) updatedObjects;
        integer idx = 0;
        boolean flag=true;
        boolean flag1=true;
        boolean flag2=true;
        boolean flag3=true;
        Set<String> OppTypes=new Set<String>();
        OppTypes.add('All');
        List<RecordType> RecordTypes=leankor.RealTimeController.getActiveRecordType('Opportunity');
        Set<String> OpportunityRecordTypes=new Set<String>();
        OpportunityRecordTypes.add('All');
        for(Opportunity myOpp:updatedOpp){
            if(myOpp.StageName != oldOpp[idx].StageName){
                if(myOpp.Type != null){
                    OppTypes.add(myOpp.Type);
                }else{
                    OppTypes.add('None');
                }
                if(RecordTypes.Size()>0){
                    String myOppRecordType =(String) myOpp.get('RecordTypeId');
                    if(myOppRecordType != null || myOppRecordType != ''){
                        OpportunityRecordTypes.add(myOppRecordType);
                    }
                } 
            }
            idx++;
        }
        List<String> newOppTypes=new List<String>(OppTypes);
        List<String> newOppRecordTypes=new List<String>(OpportunityRecordTypes);
        String OpportunityType='(';
        String OpportunityRecordType='(';
        for(Integer i=0;i<=newOppTypes.size()-1;i++){
            if(i<newOppTypes.size()-1){
                OpportunityType +=((newOppTypes[i] !=null || newOppTypes[i] !='null')?'\''+newOppTypes[i]+'\',':'None');
            }else{
                OpportunityType +=((newOppTypes[i] !=null || newOppTypes[i] !='null')?'\''+newOppTypes[i]+'\')':'None');
            }
        }
        for(Integer i=0;i<=newOppRecordTypes.size()-1;i++){
            if(i<newOppRecordTypes.size()-1){
                OpportunityRecordType +=((newOppRecordTypes[i] !=null || newOppRecordTypes[i] !='null')?'\''+newOppRecordTypes[i]+'\',':'None');
            }else{
                OpportunityRecordType +=((newOppRecordTypes[i] !=null || newOppRecordTypes[i] !='null')?'\''+newOppRecordTypes[i]+'\')':'None');
            }
        }
        
        String query ='Select Id,Name,(Select ID from leankor__valueStream__c.leankor__kanban_cards__r),(Select Id,leankor__CaseStatus__c,leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Type__C,Name,leankor__OpportunityStageName__c,leankor__Top__c,leankor__Left__c,leankor__X__c,leankor__Y__c,leankor__GUID__C,leankor__Swimlane__c,leankor__Swimlane__r.leankor__MasterContainer__c from leankor__ValueStream__c.leankor__Zones__r),(SELECT Id,leankor__Opportunity__C,leankor__Opportunity__r.Name,leankor__Account__c,leankor__Account__r.Name,leankor__Bottom__c,leankor__Case__c,leankor__Opportunity__r.CloseDate,leankor__Opportunity__r.StageName,leankor__Opportunity__r.Type,leankor__CmpID__c,leankor__Color__c,leankor__CardID__c,leankor__Contact__c,leankor__Contact__r.Name,leankor__CSSLayout__c,leankor__DateColor__c,leankor__DescriptionLong__c,leankor__Description__c,leankor__DueDate__c,leankor__DurationUnits__c,leankor__EffortRemaining__c,leankor__EstimatedDuration__c,leankor__GUID__c,leankor__HarveyBallDoneDate__c,leankor__Height__c,leankor__valuestream__r.leankor__BoardType__c,leankor__JSONData__c,leankor__JSONDefinition__c,leankor__KanbanCardTemplate__c,leankor__KanbanCardTemplate__r.leankor__Title__c,leankor__Left__c,leankor__PercentComplete2__c,leankor__Priority__c,leankor__State__c,leankor__Title__c,leankor__Top__c,leankor__ValueStreamCardLink__c,leankor__ValueStreamLink__c,leankor__ValueStreamLink__r.leankor__Boardtype__c,leankor__ValueStream__c,leankor__Width__c,leankor__X__c,leankor__Y__c,leankor__ZoneGUID__c,Name,OwnerId,leankor__StartDate__c,leankor__StartDateTime__c,leankor__DueDateTime__c FROM leankor__ValueStream__c.leankor__Kanbans__r),leankor__OpportunityCardCategory__r.Name,leankor__boardtype__c,leankor__OpportunityType__c, leankor__OpportunitySynchronization__c from leankor__ValueStream__c where  leankor__OpportunityRecordType__c  includes '+OpportunityRecordType+' and leankor__OpportunityType__c includes '+OpportunityType+' and leankor__OpportunitySynchronization__c =true and leankor__BoardType__c  in (\'Whiteboard\',\'Kanban Board\',\'Plan Board\',\'DashBoard\') limit 9999';
        List<leankor__ValueStream__c> vsl=Database.query(query);
        List<RealTimeController.Kanban> KanbanCards=new List<RealTimeController.Kanban>();
        List<RealTimeController.bulkStreaming> bulkStreamings = new List<RealTimeController.bulkStreaming> ();
        for(Opportunity myOpp:updatedOpp){
            for(leankor__ValueStream__c vs:vsl){ 
                if(vs.leankor__Kanbans__r.Size() >0 ){
                    for(leankor__KanbanCard__c kanban : vs.leankor__Kanbans__r){
                        if(kanban.leankor__GUID__C.startswith(myOpp.ID+'-') || kanban.leankor__Opportunity__c == myOpp.Id ){
                            leankor.RealTimeController.Kanban card=new leankor.RealTimeController.Kanban();
                            card.ID = Kanban.ID;
                            card.GUID=kanban.leankor__GUID__C; // TODO : replace Id to GUID and need one Id as Force ID
                            card.ForceID=kanban.Id;
                            card.Name=Kanban.Name ; //'Opportunity:'+myOpp.Name;
                            card.CmpID=kanban.leankor__CmpID__c;
                            card.DueDate=kanban.leankor__DueDateTime__c;
                            card.Priority=Integer.valueOf(kanban.leankor__Priority__c);
                            card.OwnerId=kanban.OwnerId;
                            card.HarveyBall= JSON.serialize(kanban.leankor__PercentComplete2__c);
                            card.EstimatedDuration=kanban.leankor__EstimatedDuration__c;
                            card.EffortRemaining=integer.valueof(kanban.leankor__EffortRemaining__c);
                            card.Description=(myOpp.Description==null?kanban.leankor__DescriptionLong__c:myOpp.Description);
                            card.Durationunits=kanban.leankor__DurationUnits__c;
                            card.KanbanUrl=baseUrl+'?id='+vs.Id+'&cardid=';
                            card.ValueStreamCardLink=(kanban.leankor__ValueStreamCardLink__c==null?'':kanban.leankor__ValueStreamCardLink__c);
                            card.ValueStreamLinkID=(kanban.leankor__ValueStreamLink__c==null?'':kanban.leankor__ValueStreamLink__c);
                            card.ValueStream=kanban.leankor__ValueStream__c;
                            //card.ValueStreamLinkBoardType = vs.leankor__ValueStreamLink__r.leankor__Boardtype__c;
                            card.Account=(kanban.leankor__Account__c==null?myOPp.AccountId:kanban.leankor__Account__c);
                            card.AccountName=(kanban.leankor__Account__r.Name==null?myOpp.Account.Name:kanban.leankor__Account__r.Name);
                            card.Contact=(kanban.leankor__Contact__c==null?'':kanban.leankor__Contact__c);
                            card.ContactName=(kanban.leankor__Contact__r.Name==null?'' : kanban.leankor__Contact__r.Name);
                            card.Opportunity =(kanban.leankor__Opportunity__c==null?'':kanban.leankor__Opportunity__c);
                            card.OpportunityName=(kanban.leankor__Opportunity__c==null?'': kanban.leankor__Opportunity__r.Name);
                            card.OpportunityStage = myOpp.stageName;
                            card.CaseID=(kanban.leankor__Case__c==null?'':kanban.leankor__Case__c);
                            card.LeavedZoneId =(kanban.leankor__ZoneGUID__c==null?'':kanban.leankor__ZoneGUID__c);
                            card.StartDate = kanban.leankor__StartDateTime__c;
                            card.Order= vs.leankor__kanban_cards__r.size() + 20 ; //DateTime.now().getTime();
                            card.CardID=kanban.leankor__CardID__c;
                            //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
                    		card.flowWithGS = false;
                                    Integer cIdx=0;                          
                            if(vs.leankor__Zones__r.size()>0){
                                flag=true;
                                flag1=true;
                                flag2=true;
                                flag3=true;
                                
                                for(leankor__Zone__c zone:vs.leankor__Zones__r){
                                    if(kanban.leankor__ZoneGUID__c !=null && kanban.leankor__ZoneGUID__c==zone.leankor__GUID__C){
                                        card.LeavedZoneTitle =zone.Name;
                                    }
                                    if(zone.leankor__OpportunityStageName__c == myOpp.StageName){                                      
                                        card.Top=Integer.valueOf(zone.leankor__Top__c);
                                        card.Left=Integer.valueOf(zone.leankor__Left__c);
                                        card.X=Integer.valueOf(zone.leankor__X__c);
                                        card.Y=Integer.valueOf(zone.leankor__Y__c);
                                        card.State='inzone';
                                        card.Zoneid=zone.leankor__GUID__c;//Need Discussion - All VS with Opportunity Synchronization- enable should create zones with name of 
                                        card.SWForceID = zone.leankor__Swimlane__c;
                                        card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                        card.ZoneForceID = zone.ID;
                                        break;
                                    }else if(zone.leankor__OpportunityStageName__c == 'Default'){
                                        if(flag){
                                            card.Top=Integer.valueOf(zone.leankor__Top__c);
                                            card.Left=Integer.valueOf(zone.leankor__Left__c);
                                            card.X=Integer.valueOf(zone.leankor__X__c);
                                            card.Y=Integer.valueOf(zone.leankor__Y__c);
                                            card.State='inzone';
                                            card.Zoneid=zone.leankor__GUID__c;//Need Discussion - All VS with Opportunity Synchronization- enable should create zones with name of Opportunity status.
                                            card.SWForceID = zone.leankor__Swimlane__c;
                                            card.MCForceID = zone.leankor__Swimlane__r.leankor__MasterContainer__c;
                                            card.ZoneForceID = zone.ID;
                                            flag=false;
                                        }
                                    }else if( zone.leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Type__C=='Backlog' && (zone.leankor__CaseStatus__c == 'None'||zone.leankor__CaseStatus__c == '')) 
                            //zone.leankor__Order__c==1 && if((zone.leankor__Order__c==1) && (zone.leankor__Swimlane__r.leankor__Order__c==1) && (zone.leankor__Swimlane__r.leankor__MasterContainer__r.leankor__Order__c==1))
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
                                    } else if((zone.leankor__CaseStatus__c == 'None'||zone.leankor__CaseStatus__c == '') && vs.leankor__boardtype__c != 'whiteboard') {
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
                                    }else{
                                        if(flag){
                                            card.Top=2100;
                                            card.Left=2100;
                                            card.X=0;
                                            card.Y=47;
                                            card.State='nozone';
                                            card.ZoneId='';
                                        }
                                    }
                                }
                            }else{
                                card.Top=2100;
                                card.Left=2100;
                                card.X=0;
                                card.Y=47;
                                card.State='nozone';
                                card.Zoneid='';
                            }
                            card.Width=Integer.valueOf(kanban.leankor__Width__c);//Integer.valueOf(vs.leankor__Kanbans__r[cIdx].leankor__Width__c);
                            card.Height=Integer.valueOf(kanban.leankor__Height__c);//Integer.valueOf(vs.leankor__Kanbans__r[cIdx].leankor__Height__c);
                            card.Title=kanban.leankor__KanbanCardTemplate__r.leankor__Title__c;//vs.leankor__Kanbans__r[cIdx].leankor__KanbanCardTemplate__r.leankor__Title__c;
                            card.TemplateID=kanban.leankor__KanbanCardTemplate__c;//vs.leankor__Kanbans__r[cIdx].leankor__KanbanCardTemplate__c;
                            card.Color=kanban.leankor__Color__c;//vs.leankor__Kanbans__r[cIdx].leankor__Color__c;
                            card.JSONDefinition=kanban.leankor__JSONDefinition__c;//vs.leankor__Kanbans__r[cIdx].leankor__JSONDefinition__c;
                            card.JSONData=kanban.leankor__JSONData__c;//vs.leankor__Kanbans__r[cIdx].leankor__JSONData__c;
                            card.BoardType=kanban.leankor__valuestream__r.leankor__BoardType__c;
                            String JSONPackage=JSON.serialize(card);
                            RealTimeController.bulkStreaming bulkStream= new RealTimeController.bulkStreaming();
                                bulkStream.VSId= card.valueStream;
                                bulkStream.Verb= 'MoveKanbanCard';
                                bulkStream.SessionID = UserInfo.getSessionId();
                                bulkStream.SomeJSONData =JSONPackage;   
                            bulkStreamings.add(bulkStream);
                        } // End of If 
                    } // End of Loop
                }// End of If
            }//End of VS
        }//End of NewOpportunity
        RealTimeController.manageBulkStreaming(bulkStreamings,'MoveKanbanCard');
    }

    //This Method is Run By trigger on Opportunity and Its funnctionlity is to update Related Card With This Opportunity ID.
    public void OnAfterDelete(Object[] deletedObjects, Map<ID,Object> ObjectMap){
        List<String> deleteCards=new List<String>();    
            Opportunity[] deletedOpp = (Opportunity[]) deletedObjects;
            integer idx = 0;
        Boolean flag = true;

        Set<String> OppTypes=new Set<String>();
        OppTypes.add('All');
        List<RecordType> RecordTypes=leankor.RealTimeController.getActiveRecordType('Opportunity');
        Set<String> OppRecordTypes=new Set<String>();
        OppRecordTypes.add('All');
                
        for(Opportunity myOpp:deletedOpp){
            if(myOpp.Type != null){
                OppTypes.add(myOpp.Type);
            }else{
                OppTypes.add('None');
            }
            if(RecordTypes.Size()>0){
                String myOppRecordType =(String) myOpp.get('RecordTypeId');
                if(myOppRecordType != null || myOppRecordType != ''){
                    OppRecordTypes.add(myOppRecordType);
                }
            } 
        }
        List<RealTimeController.bulkStreaming> bulkStreamings = new List<RealTimeController.bulkStreaming> ();
        
        for(Opportunity opp : deletedOpp){
            for (leankor__ValueStream__c vs: [SELECT 
                                                Id,
                                                (SELECT 
                                                        Id,
                                                        leankor__Opportunity__c,
                                                        leankor__GUID__c,
                                                        leankor__ValueStream__c 
                                                    FROM leankor__Kanbans__r 
                                                ),
                                                leankor__ProjectRoom__c
                                            FROM leankor__ValueStream__c 
                                            WHERE (leankor__OpportunityRecordType__c  IN : OppRecordTypes 
	        								 OR leankor__CaseType__c IN : OppTypes ) 
	        								 AND leankor__OpportunitySynchronization__c =true 
                                                AND leankor__BoardType__c  IN ('Whiteboard','Kanban Board','DashBoard','Plan Board')
                                            LIMIT 9999]) {

                if (vs.leankor__ProjectRoom__c != null) {	        								 	        	              	
                    for(leankor__KanbanCard__c kanban : vs.leankor__Kanbans__r){
	                    	
	                    if (kanban.leankor__GUID__C.startswith(opp.Id+'-')) {               
		                    leankor.RealTimeController.CardStreamingPackage card=new leankor.RealTimeController.CardStreamingPackage();                      
                            card.ID = kanban.ID;
                            Card.GUID = Kanban.leankor__GUID__c;
                            card.ForceID=kanban.Id;
                            //20/March/2024 : Currently we are deprecating GS channel, So broadcast should not fire in GS, so we are setting false value.
		                	card.flowWithGS = false;
		                	card.ValueStream = kanban.leankor__ValueStream__c;
		
                            RealTimeController.bulkStreaming bulkStream= new RealTimeController.bulkStreaming();
                            bulkStream.VSID= vs.Id;
                            bulkStream.Verb= 'DeleteKanbanCard';
                            bulkStream.SessionID = UserInfo.getSessionId();
                            bulkStream.SomeJSONdata = Json.serialize(card);
                            bulkStreamings.add(bulkStream);
		                        
		                    deleteCards.add(card.GUID);
	                    }
                    }
                }
            } 
        }

        RealTimeController.removeKanbanCard(deleteCards);
        RealTimeController.manageBulkStreaming(bulkStreamings,'DeleteKanbanCard');    
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