/**
* Copyright 2012-2016 Lucidsoft Inc. All rights reserved.
* FILE:  ProjectSetupController.cls
* CLASS: ProjectSetupController
* USAGE: manages to Get record of Project Setup.
*/
global with sharing class ProjectSetupController { 
    global leankor__ProjectRoom__c Project {get; set;}
    global boolean Show {get; set;}
    global leankor__Module__c Module {get; set;}
    global leankor__ProjectLaunchBehavior__c ProjectLaunch {get; set;}
    global List<wrapperModule> ModuleList {get;set;}
    global String oneclick {get; set;}
    global List<leankor__Module__c> selectedModules = new List<leankor__Module__c>();
    global List<leankor__Module__c> OpenANewTabModules = new List<leankor__Module__c>();
    global static Map<string,leankor__ProjectLaunchBehavior__c> Maponload = new Map<string,leankor__ProjectLaunchBehavior__c>();
    global boolean displayPopup {get; set;}
    global ApexPages.StandardController stdController;
    global boolean timer {get; set;}
    global string selectSetup1 {set;get;}

    private List<String> fieldSetLabels {get; set;}
    private List<String> fieldSetNames {get; set;}
    public Map<String, Field> fieldSetMemberMap;
    public List<Fieldset> fieldsets {get; set;}
    public Boolean useCustomLabel { get { return leankor__LeanConstants__c.getInstance().leankor__UseCustomLabels__c; } set; }

    global ProjectSetupController(ApexPages.StandardController stdController) {
        //Check CRUD / FLC behavior
        ProjectLaunchBehavior pLaunch = new ProjectLaunchBehavior();
        if (!pLaunch.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        show = true;
        DescribeSchema describeSchema = new DescribeSchema();
        List<Fieldset> fieldsets = new List<Fieldset>();
        this.fieldSetNames = new List<String>(describeSchema.getFieldSetNames('leankor__ProjectRoom__c'));
        this.fieldSetLabels = describeSchema.getFieldSetLabels('leankor__ProjectRoom__c');
        
        Map<String, Schema.FieldSet> fieldSetMap = describeSchema.getFieldSets('leankor__ProjectRoom__c');

        // Instantiate container holding the fieldset names and labels
        for (Integer i = 0; i < fieldSetNames.size(); i++) {
            if (!describeSchema.getFieldSetFields(fieldSetMap, fieldSetNames[i]).isEmpty()) {
                List<Schema.FieldSetMember> fieldSetMembers = describeSchema.getFieldSetFields(fieldSetMap, fieldSetNames[i]);
                List<Field> fields = new List<Field>();

                for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
                    Field field = new Field(fieldSetMember.getFieldPath(), fieldSetMember.getLabel(), describeSchema.isFieldAccessible(describeSchema.getObjectFields('leankor__ProjectRoom__c'), fieldSetMember.getFieldPath()));
                    fields.add(field);
                }

                Fieldset fieldset = new Fieldset(fieldSetNames[i], fieldSetLabels[i], fields);
                fieldsets.add(fieldset);
            }
        }

        this.fieldsets = fieldsets;
        // SS 19.06.2018 - addFields() causes failure when test class executes 
        // You cannot call addFields when the data is being passed into the controller by the caller(in Test methods).
        if (!Test.isRunningTest()) {
            stdController.addFields(describeSchema.getFieldSetFieldPaths('leankor__ProjectRoom__c'));
        }

        this.Project = (leankor__ProjectRoom__c)stdController.getRecord();
        this.stdController = stdController;
        //getprojectdata();
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('ID')) && Util.getSObjectName(ApexPages.currentPage().getParameters().get('ID')) != 'leankor__ProjectRoom__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        List<leankor__ProjectLaunchBehavior__c> pLB = [Select leankor__DefaultBoard__c,
                                                            leankor__DefaultBoard__r.Name,
                                                            leankor__Module__c,
                                                            leankor__OneClicklaunch__c,
                                                            leankor__OpenNewTab__c,
                                                            leankor__Project__c,
                                                            leankor__ViewType__c,
                                                            Name 
                                                        From leankor__ProjectLaunchBehavior__c 
                                                        Where leankor__Project__c = :ApexPages.currentPage().getParameters().get('ID')
                                                        With Security_Enforced];
            for (leankor__ProjectLaunchBehavior__c PLBlog : pLB) {
                Maponload.put(PLBlog.leankor__Module__c,PLBlog);
            } 
    }


    private class Field {
        public String name {get; set;}
        public String label {get; set;}
        public Boolean isFieldAccessible {get; set;}

        public Field(String name, String label, Boolean isFieldAccessible) {
            this.name = name;
            this.label = label;
            this.isFieldAccessible = isFieldAccessible;
        }
    }


    // Wrapper inline class to hold names and labels of a fieldset
    private class Fieldset {
        public String name {get; set;}
        public String label {get; set;}
        public List<Field> fields {get; set;}

        public Fieldset(String name, String label, List<Field> fields) {
            this.name = name;
            this.label = label;
            this.fields = fields;
        }
    }


    /********************************* Custom Save Method *****************************************/        
    public PageReference CustomSave() {
        //Check CRUD / FLC behavior
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!projectRoomBehaviour.isUpdateable() ||
            !valueStreamBehavior.isUpdateable() ||
            !dependencyBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        PageReference flag = stdController.save();    
        if (flag != null) {
            showPopup();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Project Setup Saved Successfully!'));
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('ID'))){  
                leankor__ProjectRoom__c ProjectLog = [Select Id, 
                                                            leankor__IsTemplateProject__c 
                                                        From leankor__ProjectRoom__c 
                                                        Where Id =: Encodingutil.urlEncode(ApexPages.currentPage().getParameters().get('ID'),'UTF-8')
                                                        With Security_Enforced];    
            
                if (ProjectLog.leankor__IsTemplateProject__c == true) {
                    List<leankor__ValueStream__c> VsList1 = new List<leankor__ValueStream__c>();    
                    for (leankor__ValueStream__c VSrecord : [Select leankor__IsTemplateBoard__c, 
                                                                    leankor__ProjectRoom__c, 
                                                                    UserRecordAccess.HasEditAccess 
                                                                From leankor__ValueStream__c 
                                                                Where leankor__ProjectRoom__c =: ProjectLog.Id 
                                                                Limit 9999]) {  
                        
                        if (VSrecord.UserRecordAccess.HasEditAccess) {
                            VSrecord.leankor__IsTemplateBoard__c = true;
                            VsList1.add(VSrecord);
                        }
                    }

                    Update VsList1; 
                    List<leankor__Dependency__c> filterDependency = new List<leankor__Dependency__c>();
                    List<leankor__Dependency__c> dependencies = [Select Id, 
                                                                    leankor__Predecessor__r.leankor__ValueStream__c, 
                                                                    leankor__Successor__r.leankor__ValueStream__c 
                                                                From leankor__Dependency__c 
                                                                Where leankor__valuestream__r.leankor__boardtype__c = 'UberBoard' 
                                                                    And (leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c =: ProjectLog.Id 
                                                                        Or leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c =: ProjectLog.Id)
                                                                With Security_Enforced];
                    
                for (leankor__Dependency__c dependency : dependencies) {
                    if (dependency.leankor__Predecessor__r.leankor__ValueStream__c != dependency.leankor__Successor__r.leankor__ValueStream__c) {
                        dependency.leankor__ValueStream__c = null;
                        dependency.leankor__Predecessor__c = null;
                        dependency.leankor__Successor__c = null;
                        filterDependency.add(dependency);
                    }
                }       

                if (dependencies.size() > 0) {
                    DataBase.update(filterDependency, true);
                } 

                } else {
                    List<leankor__ValueStream__c> VsList2 = new List<leankor__ValueStream__c>();     
                    for (leankor__ValueStream__c VSrecord: [SELECT leankor__IsTemplateBoard__c, leankor__ProjectRoom__c, UserRecordAccess.HasEditAccess FROM leankor__ValueStream__c WHERE leankor__ProjectRoom__c =: ProjectLog.Id LIMIT 9999]) {   
                        if (VSrecord.UserRecordAccess.HasEditAccess) {   
                            VSrecord.leankor__IsTemplateBoard__c = false;
                            VsList2.add(VSrecord);
                        }
                    }

                    Update VsList2; 
                }
            }
        }

        // Yash:23.01.2017 - This saveLaunchBehavior is calling after checking template of project because first priority is template of project is true or false.  
        saveLaunchBehavior();

        return null;
    }



    /*************************** pop up methods *************************/
    public void closePopup() {       
        displayPopup = false; 
        //timerOff(); 
    }   

    public void showPopup(){       
        displayPopup = true;
    }   

    global class wrapperModule {
        global leankor__Module__c modobject {get; set;}
        global Boolean openNewTab {get; set;}       
        global Boolean selectSetup {get; set;}
        global Boolean Oneclick1 {get; set;}
        global String DefaultBoard {get; set;}
        global String DefaultBoardID {get; set;}
        global String Boardtype;
        //global String ViewId{get;set;}
        global String DefaultView{get; set;}   
            
        //This is the contructor method. When we create a new wrapperModule object we pass a Module that is set to the mod property. We also set the selected value to false
        global wrapperModule(leankor__Module__c getmodvar) {
            modobject = getmodvar;
            if (Maponload.containsKey(modobject.ID)) {
                openNewTab = Maponload.get(modobject.ID).leankor__OpenNewTab__c;
                selectSetup = true;

                if (Maponload.get(modobject.ID).leankor__DefaultBoard__c != null) {
                    DefaultBoard = Maponload.get(modobject.ID).leankor__DefaultBoard__r.Name;
                    DefaultBoardID = Maponload.get(modobject.ID).leankor__DefaultBoard__c; 
                }

                if (Maponload.get(modobject.ID).leankor__ViewType__c != null) {
                    //ViewID = Maponload.get(modobject.ID).leankor__Module__c;
                    DefaultView = Maponload.get(modobject.ID).leankor__ViewType__c; 
                }

                Oneclick1 = Maponload.get(modobject.ID).leankor__OneClicklaunch__c;
            } else {
                openNewTab = false;
                selectSetup = false;
                Oneclick1 = false;
            }  

            Boardtype = getmodvar.leankor__BoardType__c;
            // set the initial value of the OneClickLaunch variable
            // set the initial list value of the ViewType variable, values must come from the metadata picklist of ProjectLaunchBehavior
            // set the initial list value of the DefaultBoard, values must come from the ValueStream's associated project boards            
        }
    }


    // This method uses a simple SOQL query to return a List of Modules
    global List<wrapperModule> getModules() {
        if (ModuleList == null) {
            ModuleList = new List<wrapperModule>();
            for (leankor__Module__c modvar: [Select Id, 
                                                    leankor__BoardType__c, 
                                                    Name 
                                                From leankor__Module__c 
                                                With Security_Enforced
                                                Order By leankor__order__c Asc 
                                                Limit 99]) {
                // As each Module is processed we create a new wrapperModule object and add it to the ModuleList
                ModuleList.add(new wrapperModule(modvar));
            }
        }

        return ModuleList;
    }


    global PageReference saveLaunchBehavior() {
        //Check CRUD / FLC behavior
        ProjectLaunchBehavior projectLaunchCheck = new ProjectLaunchBehavior();
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior(); 
        if (!projectLaunchCheck.isCreateable() ||
            !projectLaunchCheck.isDeletable() ||
            !valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        // why not use Project variable which contains the standardcontroller record instead of the above line?
        List<leankor__ProjectLaunchBehavior__c> oldPLB = [Select Id 
                                                            From leankor__ProjectLaunchBehavior__c 
                                                            Where leankor__Project__c = :Project.Id
                                                            With Security_Enforced];   
        List<leankor__ProjectLaunchBehavior__c> ProjectLaunchBehavior = new List<leankor__ProjectLaunchBehavior__c>();        
        Set<String> boardtype = new Set<String>();

        for (wrapperModule wrapperMod: getModules()) {
            if (wrapperMod.selectSetup) {
                selectedModules.add(wrapperMod.modobject);
                leankor__ProjectLaunchBehavior__c ProjectLB = new leankor__ProjectLaunchBehavior__c();
                ProjectLB.leankor__Module__c = wrapperMod.modobject.ID;
                ProjectLB.leankor__Project__c = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('ID'),'UTF-8');
                ProjectLB.leankor__OpenNewTab__c = wrapperMod.openNewTab;
                ProjectLB.leankor__OneClickLaunch__c = wrapperMod.Oneclick1;

                if (wrapperMod.modobject.Name != 'Financials' && wrapperMod.modobject.Name != 'Plan (Gantt)') {
                    ProjectLB.leankor__ViewType__c = wrapperMod.DefaultView;
                } else {
                    ProjectLB.leankor__ViewType__c = '';
                }

                if (wrapperMod.DefaultBoardID != '--None--') {
                    ProjectLB.leankor__DefaultBoard__c = wrapperMod.DefaultBoardID;
                } else {
                    ProjectLB.leankor__DefaultBoard__c = null;
                }

                ProjectLaunchBehavior.add(ProjectLB);   
                            
            } else {  
                //23.01.2017 yj - if select setup is false for module that module type is adding boardtype list.         
                if (wrapperMod.Boardtype == '_System_PlanBoard') {       
                    boardtype.add('Plan Board');
                }
                
                if (wrapperMod.Boardtype == '_System_DashBoard') {       
                    boardtype.add('DashBoard');
                }

                if (wrapperMod.Boardtype == '_System_Board') {       
                    boardtype.add('Kanban Board');
                }

                if (wrapperMod.Boardtype == '_System_UberBoard') {       
                    boardtype.add('UberBoard');
                }

                if (wrapperMod.Boardtype == '_System_Whiteboard') {       
                    boardtype.add('Whiteboard');
                }           
            }                              
        }

        Insert ProjectLaunchBehavior;
        Delete oldPLB;

        //23.01.2017 yj - if  boardtype list is not zero then we update valuestream's IsTemplateBoard is true.
        if (boardtype.size() != 0) {       
            List<leankor__ValueStream__c> vslist = [Select Id, 
                                                            leankor__BoardType__c, 
                                                            leankor__IsTemplateBoard__c 
                                                        From leankor__ValueStream__c 
                                                        Where leankor__BoardType__c In :boardtype 
                                                            And leankor__projectroom__c =: Project.Id 
                                                        With Security_Enforced    
                                                        Limit 9999];                      
            for (leankor__ValueStream__c vs : vslist) {     
                vs.leankor__IsTemplateBoard__c = true;      
            }  

            Database.update(vslist, true);
        }  

        showPopup();          
        return null;  
    }

    // Getting project data
    
    global static List<leankor__ProjectRoom__c> getprojectdata(){  
        /*   
        ProjectRoomBehaviour projectRoomBehaviour = new ProjectRoomBehaviour();
        if (!projectRoomBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: Invalid input');
        }   
        List<leankor__ProjectRoom__c> list_projectlogs = [Select Id,
                                                                leankor__Account__c,
                                                                leankor__Campaign__c,
                                                                leankor__Case__c,
                                                                leankor__DetailedDescription__c,
                                                                leankor__DueDate__c,
                                                                leankor__IsTemplateProject__c,
                                                                leankor__Opportunity__c,
                                                                leankor__PlannedBenefitGrossMargin__c,
                                                                leankor__Portfolio__c,
                                                                leankor__ProjectId__c,
                                                                leankor__ProjectManager__c,
                                                                leankor__ProjectNumber__c,
                                                                leankor__ProjectTemplate__c,
                                                                leankor__StartDate__c,
                                                                leankor__TargetGrossMargin__c,
                                                                leankor__TargetProjectCost__c,
                                                                Name 
                                                            From leankor__ProjectRoom__c 
                                                            Limit 49999];
        return list_projectlogs;
        */
        return new List<leankor__ProjectRoom__c>();
    }

    
    // Getting Launch object data from database
    global static List<leankor__ProjectLaunchBehavior__c> getProjectLaunch(){      
        /* 
        List<leankor__ProjectLaunchBehavior__c> list_ProjectLaunch = [Select Id,    
                                                                            leankor__DefaultBoard__c,
                                                                            leankor__Module__c,
                                                                            leankor__OneClicklaunch__c,
                                                                            leankor__OpenNewTab__c,
                                                                            leankor__Project__c,
                                                                            leankor__ViewType__c 
                                                                        From leankor__ProjectLaunchBehavior__c 
                                                                        With Security_Enforced
                                                                        Limit 99];        
        return list_ProjectLaunch;
        */
        return new List<leankor__ProjectLaunchBehavior__c>();
    }


    // Getting project object data from database
    global  static List<SelectOption> getboardtype() {
        List<SelectOption> boardtypelist= new List<SelectOption>();
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('ID'))) {
            List<leankor__ValueStream__c> BoardList = [Select leankor__BoardType__c,
                                                            leankor__ProjectRoom__c,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where leankor__BoardType__c = 'Kanban Board' 
                                                            And leankor__ProjectRoom__c =:Encodingutil.urlencode(ApexPages.currentPage().getParameters().get('ID'),'UTF-8')
                                                        With Security_Enforced];     
            for (leankor__ValueStream__c base:BoardList) {     
                boardtypelist.add(new SelectOption(base.Id,base.Name));
            }
        }

        return boardtypelist;    
    }


    // Getting DashBoard data from database
    global  static List<SelectOption> getDashboards() {
        List<SelectOption> boardtypelist= new List<SelectOption>();
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('ID'))) {
            List<leankor__ValueStream__c> BoardList = [Select leankor__BoardType__c,
                                                            leankor__ProjectRoom__c,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where leankor__BoardType__c = 'DashBoard' 
                                                            And leankor__ProjectRoom__c = :Encodingutil.urlencode(ApexPages.currentPage().getParameters().get('ID'),'UTF-8')
                                                        With Security_Enforced];      
        for (leankor__ValueStream__c base:BoardList) {     
            boardtypelist.add(new SelectOption(base.Id,base.Name));
        }
        }
        return boardtypelist;    
    }


    // Getting WhiteBoard data from database
    global  static List<SelectOption> getWhiteboards() {
        List<SelectOption> boardtypelist= new List<SelectOption>();
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('ID'))){
            List<leankor__ValueStream__c> boardList = [Select leankor__BoardType__c,
                                                            leankor__ProjectRoom__c,
                                                            Name 
                                                        From leankor__ValueStream__c 
                                                        Where leankor__BoardType__c = 'Whiteboard' 
                                                            And leankor__ProjectRoom__c = :Encodingutil.urlEncode(ApexPages.currentPage().getParameters().get('ID'),'UTF-8')
                                                        With Security_Enforced];     
            for (leankor__ValueStream__c base : boardList) {     
                boardtypelist.add(new SelectOption(base.Id,base.Name));
            }
        }
        return boardtypelist;    
    }


    global static List<SelectOption> getBoardView() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = leankor__ProjectLaunchBehavior__c.leankor__ViewType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for ( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(),f.getlabel()));
        } 

        return options;
    }
    
    
    // Getting BoardList data
    global static  List<SelectOption> getBoardList() {     
        List<SelectOption> options = new List<SelectOption>();
        /*
        Schema.DescribeFieldResult fieldResult = leankor__ValueStream__c.leankor__BoardType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        */
        return options;
    }  
}