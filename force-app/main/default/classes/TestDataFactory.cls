@isTest
public class TestDataFactory  {

    //ref : https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_utility_classes.htm
    
    public static void createBasicProject(){
        //add Lean module records.
        
        User u = createStandardUser('Leankor');
        assignpermissionSet('Visual_Lean_Designer', u);
        User u1 = createStandardUser('leankor1');
        User u2 = createStandardUser('leankor2');
        User u3 = createStandardUser('leankor3');
        assignpermissionSet('Visual_Lean_Designer', u1);
        assignpermissionSet('Visual_Lean_Designer', u2);
        assignpermissionSet('Visual_Lean_Designer', u3);


        System.runAs(u) {
            createLeanModules();
            list<leankor__Portfolio__c> folder = createFolder('Test Folder', 1);
            list<leankor__ProjectRoom__c> project = createProjects('Test Project', folder, 1);
            list<leankor__ProjectLaunchBehavior__c> pLaunch = createProjectLaunchBehavior(project);
            list<leankor__ValueStream__c> vStream = createValueStream(project, 'UberBoard', u);
            leankor__KanbanCardTemplate__c template = createKanbanCardTemplate(vStream[0]);
            List<leankor__KanbanCard__c> agList = createActivityGroups(vStream[0], template, 10);
            List<leankor__KanbanCard__c> activityList =createChildActivity(vStream[0], template, agList, 5);

            createScheduleMode(activityList,2);

            //assign resource allocation
            createResourceAssignment(activityList, u1, 10);
            createResourceAssignment(activityList, u2, 5);
            createResourceAssignment(activityList, u3, 25);
        }
        

    }
     
    public static void createComplexProject(){
        
        user u = [Select Id from User where Id =: UserInfo.getUserId()];
        System.runAs(u)
        {
            list<leankor__Portfolio__c> folder = createFolder('Test Folder', 1);
            list<leankor__ProjectRoom__c> project = createProjects('Test Project', folder, 1);  
            list<leankor__ProjectLaunchBehavior__c> pLaunch = createProjectLaunchBehavior(project);    
            list<leankor__ValueStream__c> vStream = createValueStream(project, 'Kanban Board', u);      
            leankor__KanbanCardTemplate__c template = createKanbanCardTemplate(vStream[0]);
            
            List<leankor__KanbanCard__c> kclist = createKanbanCard(vStream[0],template,20,NULL,u);
            createTask(kclist,1);
            
            createResourceAssignment(kclist, u,10);
            createResourceAssignment(kclist, u, 5);
            createResourceAssignment(kclist, u,25);
        }
           
    }   
    //This method creates a record in leankor__LeanConstants__c - custom settings, Visual Lean Constants
    public static void createLeanConstants()
    {
        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c(  leankor__DisableKanbanCardTrigger__c = true,
                                                                            leankor__FirstInstall__c = true ,
                                                                            leankor__DisableCaseTrigger__c= false,
                                                                            leankor__DisableOpportunityTrigger__c= true,
                                                                            leankor__AvoidTaskDueDateCheck__c = true,
                                                                            leankor__RetentionPeriodInDays__c = 30,
                                                                            SetupOwnerId = Userinfo.getOrganizationId());
        try
        {
            insert customSetting;
        }
        Catch(Exception Ex)
        {
            system.debug('Error:'+Ex.getMessage());
            
        }
   }

    //This method creates a User with Standard User profile
    public static User createStandardUser(String userName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User u1 = new User(Alias = userName, 
                            Email = userName + '@leankor.com',
                            EmailEncodingKey = 'UTF-8', 
                            LastName = 'Leankor1', 
                            LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', 
                            ProfileId = p.Id,
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            UserName = userName + '@leankor.com.test');

        insert u1;

        return u1;
    }


    //This method assign a given permission set to a given user
    public static void assignpermissionSet(String permissionSetName, User u) {
        PermissionSet ps = [SELECT ID FROM PermissionSet WHERE Name = :permissionSetName];

        
        insert new PermissionSetAssignment(AssigneeId = u.id, 
                                        PermissionSetId = ps.Id );
    }

  //To create n number of Folders
    public static List<leankor__Portfolio__c> createFolder(String folderName, Integer count){
        list<leankor__Portfolio__c> portfolioList = new list<leankor__Portfolio__c>();
        
        for(integer i=0;i<count;i++)
        {
        leankor__Portfolio__c f = new leankor__Portfolio__c(Name = folderName + '-' + count);
        portfolioList.add(f); 
        }
        insert portfolioList;

        return portfolioList;
    }

    //To create ChildFolder
    public static list<leankor__Portfolio__c> createChildFolder(String folderName, list<leankor__Portfolio__c> portfolioFolder){
        list<leankor__Portfolio__c> childfolder = new list<leankor__Portfolio__c>();
        
        for(leankor__Portfolio__c postfolioRecord:portfolioFolder)
        {
        leankor__Portfolio__c cf = new leankor__Portfolio__c(Name = 'ChildFolder',leankor__ParentPortfolio__c = postfolioRecord.Id); 
        childfolder.add(cf);
        }
        insert childfolder;
        
        return childfolder;
      }
      
    //To create n number of projects that attach to a specific folder
    public static list<leankor__ProjectRoom__c> createProjects(String projectName, list<leankor__Portfolio__c> folder, Integer count){
       list<leankor__ProjectRoom__c> projectRoomList = new list<leankor__ProjectRoom__c>();
        
        for(leankor__Portfolio__c profolioRecord: folder ){        
        for(integer i=0;i<count;i++){
        leankor__ProjectRoom__c p = new leankor__ProjectRoom__c(Name = projectName ,leankor__IsTemplateProject__c=true, leankor__Portfolio__c = profolioRecord.Id);        
        projectRoomList.add(p);
        }
      }
      insert projectRoomList;
      return projectRoomList;
     }

    //To create valuestream for a project
    public static list<leankor__ValueStream__c> createValueStream(list<leankor__ProjectRoom__c> project, String boardType, User u){
        
        list<leankor__ValueStream__c> vStreamList = new list<leankor__ValueStream__c>();
       
       for (leankor__ProjectRoom__c projectRoomRecord:project ){
        leankor__ValueStream__c vStream = new leankor__ValueStream__c();
        vStream.Name = 'Plan Board (' + projectRoomRecord.Name + ')';
        vStream.leankor__Effortindicator__c = 'Days';
        vStream.leankor__BoardType__c = boardType;
        vStream.leankor__EffortUnits__c='Days';
        vStream.leankor__Mode__c='Normal';
        vStream.leankor__ManuallyScheduled__c=False;
        vStream.leankor__ProjectRoom__c = projectRoomRecord.Id;
        vStream.leankor__Isrecalculate__c=False;
        vStream.leankor__DefaultOwnerID__c = u != null ? u.id : null;  
        vStream.leankor__IsTemplateBoard__c=false;
        vStreamList.add(vStream);
       }
        insert vStreamList;
        return vStreamList;
    }

    
    //This method creates Project launch behaviour record / Uber board
    public static list<leankor__ProjectLaunchBehavior__c> createProjectLaunchBehavior(list<leankor__ProjectRoom__c> project){
        
        leankor__Module__c uberBoard = [SELECT Id, Name FROM leankor__Module__c WHERE leankor__SetUp__c = true AND leankor__BoardType__c = '_System_UberBoard' LIMIT 1];
        list<leankor__ProjectLaunchBehavior__c> boardList = new list<leankor__ProjectLaunchBehavior__c>();
        for(leankor__ProjectRoom__c projectRoomRecord:project)
        {
        leankor__ProjectLaunchBehavior__c board = new leankor__ProjectLaunchBehavior__c();
         
        board.leankor__Project__c = projectRoomRecord.Id;
        board.leankor__Module__c = uberBoard.Id;
        boardList.add(board);
        }
        insert boardList;

        return boardList;
    }

   //This method creates KanbanCard template record
     public static leankor__KanbanCardTemplate__c createKanbanCardTemplate(leankor__ValueStream__c vStream){

        leankor__KanbanCardTemplate__c template = new leankor__KanbanCardTemplate__c();
        template.Name = 'Default';
        template.leankor__Title__c = 'Default';
        template.leankor__Height__c = 120;
        template.leankor__Color__c = '#bdbffc';
        template.leankor__Width__c = 170;
        template.leankor__ValueStream__c = vStream.Id;

        insert template;
        return template;
    }

    //This method created n number of activity groups for a project
    public static List<leankor__KanbanCard__c> createActivityGroups(leankor__ValueStream__c valueStream,leankor__KanbanCardTemplate__c template, Integer count){
        List<leankor__KanbanCard__c> agList = new List<leankor__KanbanCard__c>();
       Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
        
        for(Integer i = 0; i < count; i++){
            leankor__KanbanCard__c ag = new leankor__KanbanCard__c();

            ag.Name = 'Activity Group ' + i;
            ag.RecordTypeId = recType;
            ag.leankor__ValueStream__c = valueStream.Id;
            //ag.leankor__GUID__c = String.valueOf(system.now().getTime())+'-' + String.valueOf(i);
            ag.leankor__GUID__c = ''+i+createGuid();
            ag.leankor__CardID__c = String.valueOf(i);
            ag.leankor__Title__c = 'Activity Group ' + i;
            ag.leankor__Priority__c = 1;
            ag.leankor__ValueStreamCardLink__c = null;
            ag.leankor__KanbanCardTemplate__c = template.Id;
            ag.leankor__StartDate__c = System.today().addDays(-i);
            ag.leankor__DueDate__c = System.today().addDays(i);
            ag.leankor__StartDateTime__c =System.now().addDays(-i);
            ag.leankor__DueDateTime__c =System.now().addDays(i);
            ag.leankor__DurationUnits__c  = 'Days';
            ag.leankor__EstimatedDuration__c= 6;
            ag.leankor__PercentComplete2__c = 0;
            ag.leankor__IsSuccessorRecalculate__c=False;
            ag.leankor__IsExternallyDependent__c=False;
            agList.add(ag);
        }
            insert agList;
            return agList;
    }
    //This method created UniqueGuid 
    public static String createGuid(){
        Blob generatedBlob = Crypto.GenerateAESKey(128);
        String hex = EncodingUtil.ConvertTohex(generatedBlob);
        String guid = hex.substring(0, 8)
            + '-' + hex.substring(8, 12)
            + '-' + hex.substring(12, 16)
            + '-' + hex.substring(16, 20)
            + '-' + hex.substring(20);
        return guid;
    }
    //This created n number of ChildActivityGroups groups for a project
    public static List<leankor__KanbanCard__c> createChildActivityGroups(leankor__ValueStream__c valueStream,leankor__KanbanCardTemplate__c template, Integer count,List<leankor__KanbanCard__c> aglistData){
        List<leankor__KanbanCard__c> agList = new List<leankor__KanbanCard__c>();
        Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('FolderCard').getRecordTypeId();
        
        for(leankor__KanbanCard__c agRecord : aglistData){
        for(Integer i = 0; i < count; i++){
            leankor__KanbanCard__c ag = new leankor__KanbanCard__c();
            ag.Name = 'Activity Group ' + i;
            ag.RecordTypeId = recType;
            ag.leankor__ValueStream__c = valueStream.Id;
            ag.leankor__GUID__c = createGuid();
            //ag.leankor__GUID__c = String.valueOf(system.now().getTime())+'-' + String.valueOf(i);
            ag.leankor__CardID__c = String.valueOf(i);
            ag.leankor__Title__c = 'Activity Group ' + i;
            ag.leankor__Priority__c = 1;
            ag.leankor__ValueStreamCardLink__c = agRecord.id;
            ag.leankor__KanbanCardTemplate__c = template.Id;
            ag.leankor__StartDate__c = System.today().addDays(-i);
            ag.leankor__DueDate__c = System.today().addDays(i);
            ag.leankor__StartDateTime__c =System.now().addDays(-i);
            ag.leankor__DueDateTime__c =System.now().addDays(i);
            ag.leankor__DurationUnits__c  = 'Days';
            ag.leankor__EstimatedDuration__c= 6;
            ag.leankor__PercentComplete2__c = 0;
            agList.add(ag);
        }
        }
         insert agList;
         return agList;
    }

    //This created n number of ChildActivity for a activity group
    public static List<leankor__KanbanCard__c> createChildActivity(leankor__ValueStream__c valueStream, leankor__KanbanCardTemplate__c template, List<leankor__KanbanCard__c> groupList, Integer count){
        List<leankor__KanbanCard__c> agList = new List<leankor__KanbanCard__c>();
        Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
        Integer z = 1;
        if(groupList==Null)
        {
          for(Integer i = 0; i < count; i++){
                leankor__KanbanCard__c ag = new leankor__KanbanCard__c();
                ag.Name = 'Activity ' + i;
                ag.RecordTypeId = recType;
                ag.leankor__ValueStream__c = valueStream.Id;
                ag.leankor__GUID__c = createGuid();
                //ag.leankor__GUID__c = String.valueOf(i) + String.valueOf(system.now().getTime()) + String.valueOf(i);
                ag.leankor__CardID__c = String.valueOf(i);
                ag.leankor__Title__c = 'Activity ' + i;
                ag.leankor__Priority__c = z;
                ag.leankor__KanbanCardTemplate__c = template.Id;
                ag.leankor__StartDate__c = System.today();
                ag.leankor__DueDate__c = System.today().addDays(i);
                ag.leankor__PercentComplete2__c = 0;
                ag.OwnerId=UserInfo.getUserId() ;
                agList.add(ag);
                if(z>4)z=1;
        }
        }
        else {
        for(leankor__KanbanCard__c k : groupList){
            for(Integer i = 0; i < count; i++){
                leankor__KanbanCard__c ag = new leankor__KanbanCard__c();
                
                ag.Name = 'Activity ' + i;
                ag.RecordTypeId = recType;
                ag.leankor__ValueStream__c = valueStream.Id;
                ag.leankor__GUID__c = ''+i+createGuid();
                //ag.leankor__GUID__c = String.valueOf(i) + String.valueOf(system.now().getTime()) + String.valueOf(i);
                ag.leankor__CardID__c = String.valueOf(i);
                ag.leankor__Title__c = 'Activity ' + i;
                ag.leankor__Priority__c = z;
                ag.leankor__ValueStreamCardLink__c = k.Id;
                ag.leankor__KanbanCardTemplate__c = template.Id;
                ag.leankor__StartDate__c = System.today();
                ag.leankor__DueDate__c = System.today().addDays(i);
                ag.leankor__PercentComplete2__c = 0;
                ag.OwnerId=UserInfo.getUserId() ;
                agList.add(ag);
                if(z>4)z=1;
        }
        }
        }
        insert agList;
        return agList;
    }   
   //This method creates n number of ChildMilestone for a activity group
    public static List<leankor__KanbanCard__c> createChildMilestone(leankor__ValueStream__c valueStream, leankor__KanbanCardTemplate__c template, List<leankor__KanbanCard__c> groupList, Integer count){
        List<leankor__KanbanCard__c> agList = new List<leankor__KanbanCard__c>();
        Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('MileStoneCard').getRecordTypeId();
        
        Integer z = 1;
        
            if(groupList==Null)
        {
          for(Integer i = 0; i < count; i++){
                leankor__KanbanCard__c ag = new leankor__KanbanCard__c();
                ag.Name = 'Activity ' + i;
                ag.RecordTypeId = recType;
                ag.leankor__ValueStream__c = valueStream.Id;
                ag.leankor__GUID__c = ''+i+createGuid();
                //ag.leankor__GUID__c = String.valueOf(i) + String.valueOf(system.now().getTime()) + System.now().millisecond() + String.valueOf(i);
                ag.leankor__CardID__c = String.valueOf(i);
                ag.leankor__Title__c = 'Activity ' + i;
                ag.leankor__Priority__c = z;
                ag.leankor__KanbanCardTemplate__c = template.Id;
                ag.leankor__StartDate__c = System.today();
                ag.leankor__DueDate__c = System.today().addDays(i);
                ag.leankor__PercentComplete2__c = 0;
                agList.add(ag);
                if(z>4)z=1;
        }
        }
        else { 
         for(leankor__KanbanCard__c k : groupList) {    
        for(Integer i = 0; i < count; i++){
                
                
                leankor__KanbanCard__c ag = new leankor__KanbanCard__c();
                ag.Name = 'Milestone ' + i;
                ag.RecordTypeId = recType;
                ag.leankor__ValueStream__c = valueStream.Id;
                ag.leankor__GUID__c = ''+i+createGuid();
                //ag.leankor__GUID__c = String.valueof(i)  +System.now().getTime() + System.now().millisecond() +  String.valueof(i);
                //ag.leankor__GUID__c = guid;
                ag.leankor__CardID__c = String.valueOf(i);
                ag.leankor__Title__c = 'Milestone ' + i;
                ag.leankor__Priority__c = z;
                ag.leankor__ValueStreamCardLink__c = k.Id;
                ag.leankor__KanbanCardTemplate__c = template.Id;
                ag.leankor__StartDate__c = System.today();
                ag.leankor__DueDate__c = System.today().addDays(i);
                ag.leankor__PercentComplete2__c = 0;
                agList.add(ag);
                if(z>4)z=1;
            }
        }
        }
        insert agList;

        return agList;
    }   
   
    //To insert kanbancards for kanban board
    public static List<leankor__KanbanCard__c> createKanbanCard(leankor__ValueStream__c valueStream,leankor__KanbanCardTemplate__c template,Integer count,list<leankor__KanbanCard__c> aclist,user u){
          List<leankor__KanbanCard__c> kbList = new List<leankor__KanbanCard__c>();
          Id recType = Schema.SObjectType.leankor__KanbanCard__c.getRecordTypeInfosByName().get('ActivityCard').getRecordTypeId();
          Integer z = 1;      
          
           if(aclist!=Null)
        {
           for (leankor__KanbanCard__c k:aclist){    
                for(Integer i = 0; i < count; i++){
                    leankor__KanbanCard__c kb = new leankor__KanbanCard__c();
                
                    kb.Name = 'Activity ' + i;
                    kb.RecordTypeId = recType;
                    kb.leankor__ValueStream__c = valueStream.Id;
                    kb.leankor__GUID__c = ''+i+createGuid();
                    //kb.leankor__GUID__c = String.valueOf(i) + String.valueOf(system.now().getTime()) + String.valueOf(i);
                    kb.leankor__CardID__c = String.valueOf(i);
                    kb.leankor__Title__c = 'Activity ' + i;
                    kb.leankor__Priority__c = z;                
                    kb.leankor__KanbanCardTemplate__c = template.Id;
                    kb.leankor__StartDate__c = System.today();
                    kb.leankor__DueDate__c = System.today().addDays(i);
                    kb.leankor__PercentComplete2__c = 50;
                    kb.leankor__ValueStreamCardLink__c= k.id;
                    kb.OwnerId=u.id;
					kb.leankor__EstimatedDuration__c= i;
                    kbList.add(kb);
                    if(z>4)z=1;
                } 
            }
        }  else{
                for(Integer i = 0; i < count; i++){
                    leankor__KanbanCard__c kb = new leankor__KanbanCard__c();
                
                    kb.Name = 'Activity ' + i;
                    kb.RecordTypeId = recType;
                    kb.leankor__ValueStream__c = valueStream.Id;
                    kb.leankor__GUID__c = ''+i+createGuid();
                    //kb.leankor__GUID__c = String.valueOf(i) + String.valueOf(system.now().getTime()) + String.valueOf(i);
                    kb.leankor__CardID__c = String.valueOf(i);
                    kb.leankor__Title__c = 'Activity ' + i;
                    kb.leankor__Priority__c = z;                
                    kb.leankor__KanbanCardTemplate__c = template.Id;
                    kb.leankor__StartDate__c = System.today();
                    kb.leankor__DueDate__c = System.today().addDays(i);
                    kb.leankor__PercentComplete2__c = 50;
                    kb.leankor__ValueStreamCardLink__c= Null;
                	kb.leankor__EstimatedDuration__c= i;
                    kb.OwnerId=u.id;
                    kbList.add(kb);
                    if(z>4)z=1;
                } 
            }  
            insert kbList;
            return kbList;
        }
    
    
    // insert task
    public static void createTask(List<leankor__KanbanCard__c> kc,Integer count){
            
            List<Task> TaskList = new List<Task>();
            
            for(leankor__KanbanCard__c k : kc){
                
                Task Tsk = new Task();
                Tsk.Priority = 'High';
                Tsk.OwnerID = UserInfo.getUserId();                             
                Tsk.Status = 'In Progress';
                Tsk.ActivityDate = system.Today();
                Tsk.WhatId = k.Id;              
                TaskList.add(Tsk);
            }
            insert TaskList;  
    }  
    
    //To create ResourceAssignment for activity   
    public static list<leankor__ResourceAssignment__c> createResourceAssignment(list<leankor__KanbanCard__c> activity, User assignTo,integer count){
        list<leankor__ResourceAssignment__c> raList = new list<leankor__ResourceAssignment__c>();
        for(leankor__KanbanCard__c k :activity )
        {
             for(Integer i = 0; i < count; i++)
           {
        leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c();
        
        ra.leankor__KanbanCard__c = k.Id;
        ra.leankor__AssignedTo__c = userinfo.getUserId();
        ra.leankor__PercentAllocation__c = 40;
        ra.leankor__PercentCompleted__c = 50;
        raList.add(ra);
            }
        }
        insert raList;
        return raList;

    }
    
    //To create baseline data for board 
    public static List<String> createBaselineOnBoard(list<leankor__ValueStream__c> vStream){
            
             
            List<String> jsonList = new List<String>();
            for(leankor__ValueStream__c v : vStream)
            {
            GanttTaskBoard.Baseline bl = new GanttTaskBoard.Baseline();
            bl.Title = 'baseline';
            bl.ProjectBoardID = v.Id;               
            
            jsonList.add(JSON.serialize(bl)); 
            
            }
            return jsonList;
            
        
    }
     
     //To create baseline on activity 
     public static List<String> createBaselineOnActivity(list<leankor__KanbanCard__c> activityList,List<GanttTaskBoard.Baseline> bllist){
                List<String> actvityids = new List<String>();
                List<String> jsonactivityList = new List<String>();
            for(leankor__KanbanCard__c k : activityList)
            {
                leankor.GanttTaskBoard.Baseline bl1 = new  leankor.GanttTaskBoard.Baseline();
                
                bl1.ProjectBaselineID = bllist[0].ProjectBaselineID;
                bl1.KanbanCardID = k.Id;
                bl1.BaselineStartDate = k.leankor__StartDateTime__c;
                bl1.BaselineEndDate = k.leankor__DueDateTime__c;
                bl1.DurationUnit = k.leankor__DurationUnits__c ;
                bl1.EstimatedDuration = k.leankor__EstimatedDuration__c;
                bl1.isCriticalPath=false;
                actvityids.add(k.Id);
                jsonactivityList.add(JSON.serialize(bl1));
            }
            
            return jsonactivityList;
    }   
    
    
    
   //To create ScheduleMode for activity  
    public static List<leankor__ScheduleMode__c> createScheduleMode(List<leankor__KanbanCard__c> activityList,integer count){
        List<leankor__ScheduleMode__c> sModeList = new List<leankor__ScheduleMode__c>();

        for(leankor__KanbanCard__c kard : activityList){
             for(Integer i = 0; i < count; i++)
           {
            
            leankor__ScheduleMode__c sMode = new leankor__ScheduleMode__c();

            sMode.leankor__KanbanCard__c = kard.Id;
            sMode.leankor__EffortActual__c = 2;
            sMode.leankor__EffortUnits__c = 'Days';
            sMode.leankor__ManuallyScheduled__c = false;
            sMode.leankor__Mode__c = 'EffortDriven';

            sModeList.add(sMode);
           } 
        }

        insert sModeList;
        return sModeList;
    }

    //This add records to Lean module
    public static void createLeanModules(){
        List<leankor__Module__c> leanModule = new List<leankor__Module__c>();

        leankor__Module__c m1 = new leankor__Module__c(leankor__BoardType__c = '_System_UberBoard',leankor__Order__c = 1,leankor__SetUp__c = true,Name = 'Plan (Gantt)'); 
        leanModule.add(m1);
        leankor__Module__c m2 = new leankor__Module__c(leankor__BoardType__c = '_System_PlanBoard',leankor__Order__c = 2,leankor__SetUp__c = true,Name = 'Roll Up'); 
        leanModule.add(m2);
        leankor__Module__c m3 = new leankor__Module__c(leankor__BoardType__c = '_System_Board',leankor__Order__c = 3,leankor__SetUp__c = true,Name = 'Project Boards'); 
        leanModule.add(m3);
        leankor__Module__c m4 = new leankor__Module__c(leankor__BoardType__c = '_System_Whiteboard',leankor__Order__c = 4,leankor__SetUp__c = true,Name = 'Whiteboards'); 
        leanModule.add(m4);
        leankor__Module__c m5 = new leankor__Module__c(leankor__BoardType__c = '_System_DashBoard',leankor__Order__c = 5,leankor__SetUp__c = true,Name = 'DashBoard');  
        leanModule.add(m5);
        leankor__Module__c m6 = new leankor__Module__c(leankor__BoardType__c = '',leankor__Order__c = 6,leankor__SetUp__c = true,Name = 'Financials');
        leanModule.add(m6);

        insert leanModule;
    }

    public static RecordType getRecordType(String objectName, String developerName){
        RecordType rType  = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = :objectName and DeveloperName = :developerName];

        return rType;
    }
    
    //To create n number of expenseRecords that attach to a specific folder and project
    public static list<leankor__Expense__c> createExpenses(String name, Integer amount, Id folder, Id project, Integer count){
        List<leankor__Expense__c> expList= new List<leankor__Expense__c>();
        for(Integer i=0;i<count;i++)
        { 
        leankor__Expense__c Exp = new leankor__Expense__c();
        Exp.name= name+' - '+i;
        Exp.leankor__ExpenseAmount__c = amount;
        Exp.leankor__Project__c=project;
        Exp.leankor__Portfolio__c=folder;
        expList.add(Exp);
        }
        insert expList;
       return expList;
     }

    public static Boolean shareRecord(User user, List<String> recordids, String objectType, String AccessLevel){        
        List <Sobject> sObjectList = new List<Sobject>();
        Boolean isAccess=false;
        System.debug(recordids.size());
        Map <String, UserRecordAccess>  checkEditAccess = ProjectBoardCarousel.readRecordSecurity(recordids);
        System.debug(checkEditAccess);
        //try{
        if(Schema.getGlobalDescribe().get(objectType)!=null){
            for(String record : recordids){
                // Create new sharing object for the custom object Job.
                sObject sObjectShare = Schema.getGlobalDescribe().get(objectType).newSObject() ;                               
                // Set the ID of record being shared.
                sObjectShare.put('ParentId',record);     
                // Set the ID of user or group being granted access.
                 sObjectShare.put('UserOrGroupId',user.Id); 
                // Set the access level.               
                if(AccessLevel=='Read' && (!checkEditAccess.get(record).HasReadAccess)){
                    sObjectShare.put('AccessLevel','Read'); 
                } else if(AccessLevel=='Edit' && (!checkEditAccess.get(record).HasEditAccess)){
                     sObjectShare.put('AccessLevel','Edit');    
                }     
                // Set rowCause to 'manual' for manual sharing.             
                sObjectShare.put('RowCause','Manual');  
                // Add Sharing Record to the list                   
               if(sObjectShare.get('AccessLevel')!=null){
                    sObjectList.add(sObjectShare);
               }
            }       
            if(sObjectList.size()>0){
                System.debug(sObjectList);          
                insert sObjectList;
                isAccess=true;
            }
        }
     
        /*}catch(exception ex){
          System.debug(ex);
        }*/
        return isAccess;
    }     
    
    
    /* 
    public static void shareFolderAsReadAccess(User user, List<String> portfolioList){
        
        List<Sobject> folderShareList = new List<Sobject>();
        for(String record : portfolioList){
            // Create new sharing object for the custom object Job.
            //leankor__Portfolio__share folderShare = new leankor__Portfolio__share();
           sObject folderShare = Schema.getGlobalDescribe().get('leankor__Portfolio__share').newSObject() ;                    
            // Set the ID of record being shared.
            // folderShare.ParentId = record; 
            folderShare.put('ParentId',record);  
            // Set the ID of user or group being granted access.
            //folderShare.UserOrGroupId = user.Id;
             folderShare.put('UserOrGroupId',user.Id);  
            // Set the access level.
            //folderShare.AccessLevel = 'Read';
            folderShare.put('AccessLevel','Read');        
            // Set rowCause to 'manual' for manual sharing.
            //folderShare.RowCause = 'Manual';
             folderShare.put('RowCause','Manual');  
            // Add Sharing Record to the list
            folderShareList.add(folderShare);
        }
        insert folderShareList;
    }     
    
    public static void shareFolderAsReadWriteAccess(User user,List<String> portfolioList){
        
        List<leankor__Portfolio__share> folderShareList = new List<leankor__Portfolio__share>();
        
        for(String record : portfolioList){
            // Create new sharing object for the custom object Job.
            leankor__Portfolio__share folderShare = new leankor__Portfolio__share();
            // Set the ID of record being shared.
            folderShare.ParentId = record;  
            // Set the ID of user or group being granted access.
            folderShare.UserOrGroupId = user.Id;
            // Set the access level.
            folderShare.AccessLevel = 'Edit';      
            // Set rowCause to 'manual' for manual sharing.
            folderShare.RowCause = 'Manual';
            // Add Sharing Record to the list
            folderShareList.add(folderShare);
        }
        
        insert folderShareList;
    } 
    
    public static void shareProjectAsReadAccess(User user,List<String> projectList){
        
        List<leankor__ProjectRoom__Share> projectShareList = new List<leankor__ProjectRoom__Share>();
        
        for(String record : projectList){
            // Create new sharing object for the custom object Job.
            leankor__ProjectRoom__Share projectShare = new leankor__ProjectRoom__Share();
            // Set the ID of record being shared.
            projectShare.ParentId = record;  
            // Set the ID of user or group being granted access.
            projectShare.UserOrGroupId = user.Id;
            // Set the access level.
            projectShare.AccessLevel = 'Read';      
            // Set rowCause to 'manual' for manual sharing.
            projectShare.RowCause = 'Manual';
            // Add Sharing Record to the list
            projectShareList.add(projectShare);
        }
        
        insert projectShareList;
    }     
    
    public static void shareProjectAsReadWriteAccess(User user,List<String> projectList){
        
        List<leankor__ProjectRoom__Share> projectShareList = new List<leankor__ProjectRoom__Share>();
        for(String record : projectList){
            // Create new sharing object for the custom object Job.
            leankor__ProjectRoom__Share projectShare = new leankor__ProjectRoom__Share();
            // Set the ID of record being shared.
            projectShare.ParentId = record;  
            // Set the ID of user or group being granted access.
            projectShare.UserOrGroupId = user.Id;
            // Set the access level.
            projectShare.AccessLevel = 'Edit';      
            // Set rowCause to 'manual' for manual sharing.
            projectShare.RowCause = 'Manual';
            // Add Sharing Record to the list
            projectShareList.add(projectShare);
        }
        
        insert projectShareList;
    }    
    
    
    public static void shareBoardAsReadAccess(User user,List<String> ids){
        
        List<leankor__ValueStream__share> projectShare=new List<leankor__ValueStream__share>(); 
        for(String  recordid :ids){                    
           leankor__ValueStream__share project=new leankor__ValueStream__share();   
           project.UserOrGroupId = user.Id;
           project.AccessLevel='Read';
           project.ParentId = recordid;
           project.RowCause = 'Manual'; 
           projectshare.add(project);                              
        }
        
        insert projectShare;
    }   
                    
    public static void shareBoardAsReadWriteAccess(User user,List<String> ids){             
        
        List<leankor__ValueStream__share> projectShare=new List< leankor__ValueStream__share>();    
        for(String  recordid :ids){                   
          leankor__ValueStream__share project=new leankor__ValueStream__share ();   
          project.UserOrGroupId = user.Id;
          project.AccessLevel='Edit';
          project.ParentId = recordid;
          project.RowCause = 'Manual';  
          projectShare.add(project);                               
        }                   
        insert projectShare;
        System.debug(projectShare);                     
    }
    */

    //This method creates a User with Standard Platform User profile
    public static User createSystemUser(String userName) {
        Profile p = [Select Id 
                        From Profile 
                        Where Name = 'System Administrator' 
                        Limit 1];

        User u1 = new User();
        u1.Alias = userName;
        u1.Email = userName + '@leankor.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'Leankor1';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        u1.ProfileId = p.Id;
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.UserName = userName + '@leankor.com.test';
        insert u1;

        return u1;
    }
    
    //This method creates a User with Standard Platform User profile
    public static User createPlatformUser(String userName) {
        Profile p = [Select Id 
                        From Profile 
                        Where Name = 'Standard Platform User' 
                        Limit 1];

        User u1 = new User();
        u1.Alias = userName;
        u1.Email = userName + '@leankor.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'Leankor1';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        u1.ProfileId = p.Id;
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.UserName = userName + '@leankor.com.test';
        insert u1;

        return u1;
    }

    //This method creates a User with Standard Community User profile
    public static User createCommunityUser(String userName) {
        User portalOwner = [Select Id 
                                From User 
                                Where UserRoleId != null 
                                Limit 1];

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.OwnerId = portalOwner.Id;
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Community';
        con.LastName = 'User';
        con.Email = 'community.user@testorg.com';
        con.AccountId = acc.Id;
        insert con;

        Profile p = [Select Id 
                        From Profile 
                        Where Name = 'Customer Community User' 
                        Limit 1];

        User u1 = new User();
        u1.Alias = userName;
        u1.Email = userName + '@leankor.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LastName = 'Leankor1';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        u1.ProfileId = p.Id;
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.UserName = userName + '@leankor.com.test';
        u1.ContactId = con.Id;
        insert u1;

        return u1;

    }

    
}