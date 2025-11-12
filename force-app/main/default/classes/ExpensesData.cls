global with sharing class ExpensesData {
    public ExpensesData (ApexPages.StandardSetController controller) {   
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RID')) && 
        Util.getSObjectName(ApexPages.currentPage().getParameters().get('RID')) != 'leankor__ProjectRoom__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        RoomID = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('RID'),'UTF-8');
        String lex = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('isLightning'),'UTF-8');
        this.showLex = lex != null ? true : false;     
         
    }  
    global boolean showLex{get;set;}     
    public static Map<Id, String> recordtypemap {get;set;} 
           
    global string RoomID {get; set;}
    global ExpensesData (ApexPages.StandardController controller){}
    global static string getExpenseID(){
         return leankor__Expense__c.sObjectType.getDescribe().getKeyPrefix();
    }
    global static List<leankor__Expense__c> getExpenses(){
        Map<String, Schema.FieldSet> FsMap =    Schema.SObjectType.Expense__c.fieldSets.getMap();
        Schema.FieldSet fs1 = FsMap.get('leankor__ExpenseViewFieldSet'); 
        List<Schema.FieldSetMember> ss = fs1.getFields();
        string query;
        boolean first=true;
        for(Schema.FieldSetMember f : ss ) {
            if(first){
               query = 'Select '+f.getFieldPath();
                first =false;
            }else{
                query += ','+ f.getFieldPath() ;
            }
        }
     
        String tempVariable = ApexPages.currentPage().getParameters().get('RID') != null ? Encodingutil.urlEncode(ApexPages.currentPage().getParameters().get('RID'),'utf-8') : null ;
        query += ' From leankor__Expense__c Where leankor__Project__c = \''+String.escapeSingleQuotes(tempVariable)+'\'';
        return Database.query(query);
    }
    global static string getObjectId(){
        FieldDefinition listofMetadataPrj = new FieldDefinition();
        try{
            listofMetadataPrj =[SELECT QualifiedApiName,DurableId,EntityDefinitionId,Id,Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'leankor__Expense__c' and QualifiedApiName ='leankor__Project__c'];         
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        }  
        string completeField = listofMetadataPrj.DurableId;
        string[] finalstr =completeField.split('\\.');
        string ObjectId = finalstr[0]; 
        return ObjectID;
    }
    global static string getDurableIdforProject(){
        FieldDefinition listofMetadataPrj = new FieldDefinition();
        try{
            listofMetadataPrj =[SELECT QualifiedApiName,DurableId,EntityDefinitionId,Id,Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'leankor__Expense__c' and QualifiedApiName ='leankor__Project__c'];         
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        }     
        string completeField = listofMetadataPrj.DurableId;
        string[] finalstr =completeField.split('\\.');
        string DurableIdforProject = finalstr[1]; 
        return DurableIdforProject;
    }
    global static string getDurableIdforportfolio(){
        FieldDefinition listofMetadataPort = new FieldDefinition();
        try{
            listofMetadataPort =[SELECT QualifiedApiName,DurableId,EntityDefinitionId,Id,Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'leankor__Expense__c' and QualifiedApiName ='leankor__Portfolio__c'];
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        }     
        string completeField2 = listofMetadataPort.DurableId;
        string[] finalstr2 =completeField2.split('\\.');
        string DurableIdforportfolio = finalstr2[1];
        return   DurableIdforportfolio;
    }
    global static string getPortfolioId(){ 
        leankor__ProjectRoom__c listofRoom = new leankor__ProjectRoom__c();
                
        try{                          
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RID'))) {                          
                listofRoom = [Select Id,
                                        leankor__Portfolio__c,
                                        leankor__Portfolio__r.name,
                                        Name 
                                    From leankor__ProjectRoom__c 
                                    Where Id =:Encodingutil.urlencode(ApexPages.currentPage().getParameters().get('RID'),'utf-8')
                                    With Security_Enforced];
            }
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        }
         return listofRoom.leankor__Portfolio__c;
        } 
             
    
    global static string getPortfolioName(){
        leankor__ProjectRoom__c listofRoom = new leankor__ProjectRoom__c();
        try{                            
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RID'))) {                        
                listofRoom = [Select Id,
                                        leankor__Portfolio__c,
                                        leankor__Portfolio__r.name,
                                        Name 
                                    From leankor__ProjectRoom__c 
                                    Where Id =:Encodingutil.urlEncode(ApexPages.currentPage().getParameters().get('RID'),'utf-8')
                                    With Security_Enforced];
            }
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());
        }
        return listofRoom.leankor__Portfolio__r.Name;
    }
    global static string getRoomName(){ 
        leankor__ProjectRoom__c listofRoom = new leankor__ProjectRoom__c ();
        try{                            
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RID'))) {                         
                listofRoom = [Select Id,
                                        leankor__Portfolio__c,
                                        leankor__Portfolio__r.name,
                                        Name 
                                    From leankor__ProjectRoom__c 
                                    Where Id =:Encodingutil.urlEncode(ApexPages.currentPage().getParameters().get('RID'),'UTF-8')
                                    With Security_Enforced];
            }
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage());	
        }
        return listofRoom.Name;
    }
    global static string getRoomID(){                            
        leankor__ProjectRoom__c RoomLog = new leankor__ProjectRoom__c();
        try{
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RID'))){
                Roomlog = [Select Id,
                                    leankor__Portfolio__c,
                                    leankor__Portfolio__r.name,
                                    Name 
                                From leankor__ProjectRoom__c 
                                Where Id =:Encodingutil.urlEncode(ApexPages.currentPage().getParameters().get('RID'),'UTF-8')
                                With Security_Enforced];
            }
        }catch(DMLException ex){
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        }
        return Roomlog.id;
    }
    /*
    //RS 24/10/2017 
    public List<SelectOption> getrectypes(){
    
    List<Schema.RecordTypeInfo> ERT = leankor__Expense__c.SObjectType.getDescribe().getRecordTypeInfos();
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.RecordTypeInfo rt:ERT){
            if(rt.name!='master'){
            options.add(new SelectOption(rt.Name,rt.Name));   
            } 
    }
        return options;
    }
    //RS 24/10/2017 
    public PageReference showExpensesRecordType(){
        show= true;
        return null;
    } 
    //RS 24/10/2017 
    public PageReference saveExpense(){
        insert expRT ;
       PageReference MyObjectPR= new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+expRT.Id); 
    
        return MyObjectPR;
    }
    //RS 24/10/2017 
    public PageReference saveAndNewExpense(){
        showNew= false; 
        insert expRT;
       
       
        return null;
    }
    //RS 24/10/2017 
    public PageReference showNewExpenseForm(){
        showNew=true;
        return null;
    }
    //RS 24/10/2017 
    public PageReference customCancel() {
    
    PageReference MyObjectPR= new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm()+'/a05/o'); 
    MyObjectPR.setRedirect(true);
    return MyObjectPR;
    }
    //RS 26/10/2017 For lightning Component 
       
    //Lightning 
    @AuraEnabled 
    public static list<string> getRectypeNames(){
    
    List<string> recT = new list<string>();
    List<Schema.RecordTypeInfo> ERT = leankor__Expense__c.SObjectType.getDescribe().getRecordTypeInfos();
    for(Schema.RecordTypeInfo rt : ERT ){
       recT.add(rt.Name);
    }   
     return recT;
    }
    
    @AuraEnabled 
    public static string getRectypeName(String recTypeId){
       
     return leankor__Expense__c.SObjectType.getDescribe().getRecordTypeInfosbyId().get(recTypeId).getName();
    }
    */
    
    /*
    @AuraEnabled 
    public static leankor__Expense__c getExpenseRecord(String expenseId){
    leankor__Expense__c rl = [select Name, leankor__ApprovingManager__c, leankor__Chargeable__c, leankor__Category__c, leankor__ContactSubmittingExpense__c, leankor__Date__c, leankor__DeliveredProduct__c, leankor__ExpenseAmount__c, 
                           leankor__ExpenseCode__c,leankor__ExpenseNumber__c, leankor__Invoiced__c, leankor__IncludesTax__c, leankor__KanbanCard__c,
                           leankor__LongDescription__c, leankor__PaymentReceived__c, leankor__PlannedExpense__c, leankor__PaymentNotes__c,  
                           leankor__PersonSubmittingExpense__c, leankor__Project__c, leankor__Portfolio__c, leankor__Plan__c, 
                           leankor__ProjectBoard__c,  leankor__Reimbursable__c, recordTypeId, OwnerId from leankor__Expense__c 
                           where id=:expenseId limit 1];
    return rl; 
    }
    */
    
    /*
    @AuraEnabled        
    public static List<leankor__ValueStream__c> getProjectBoards(String projectId){
        return [SELECT Name FROM leankor__ValueStream__c WHERE leankor__ProjectRoom__c =: projectId];
    }
    
    @AuraEnabled        
    public static String getselectedProjectBoardId(String boardName){
    leankor__ValueStream__c selectedBoard =[SELECT Id FROM leankor__ValueStream__c WHERE Name =: boardName limit 1];
    System.debug('selected board :' +selectedBoard);
        return selectedBoard.Id ;
    }
    
    @AuraEnabled        
    public static String getselectedProjectBoardName(String boardId){
    leankor__ValueStream__c selectedBoard =[SELECT Name FROM leankor__ValueStream__c WHERE Id=: boardId limit 1];
    System.debug('selected board :' +selectedBoard);
        return selectedBoard.Name;
    }
    
    
    @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = leankor__Expense__c.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master')
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap.values();
    }
    
    
    @AuraEnabled
    public static User getCurrentUser() {
      User user = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
      return user;
    }
    
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.leankor__Expense__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    } 
    */
    /*
    @AuraEnabled
    public static String getHelpText(String fieldName){     
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('leankor__Expense__c').getDescribe().fields.getMap();
        return fieldMap.get(fieldName).getDescribe().getInlineHelpText();
    }
    */
    /*
    @AuraEnabled
    public static leankor__Expense__c updateExpense(leankor__Expense__c expense) {    
        update expense;      
    	return expense;
    }
    */
    
    
    /*
    @AuraEnabled
    public static String getBaseUrl() {     
        return URL.getSalesforceBaseUrl().toExternalForm();  
    }
    
    @AuraEnabled
    public static String getUIThemeDescription() {
        return UserInfo.getUiThemeDisplayed();
    }
    */
    //***************For lightning expense****************//
    
    //getting field according to fieldSet
    //09/09/2021 : Changes Public method to Global for release update. 
    @AuraEnabled 
    global static list<sObject> getExpenseRecords(String projectId)
    {
        //Added Security code for sentize user Input
        if ((String.isNotBlank(projectId) && Util.getSObjectName(projectId) != 'leankor__ProjectRoom__c')){
            throw new Util.LeanException('Error: Invalid input');
        }
        
        DescribeSchema descSche= new DescribeSchema();
        Set<String> fieldSetNames = new Set<String>(getFieldSetAPIName());         
        
        //added lookup field for Name otherwise Id will show UI.
        fieldSetNames.add('RecordType.Name');
        fieldSetNames.add('leankor__PersonSubmittingExpense__r.Name');
        fieldSetNames.add('leankor__Project__r.Name');
        fieldSetNames.add('leankor__KanbanCard__r.Name');
        fieldSetNames.add('leankor__ContactSubmittingExpense__r.Name');
        fieldSetNames.add('leankor__Portfolio__r.Name');
        fieldSetNames.add('leankor__PlannedExpense__r.Name');
        fieldSetNames.add('leankor__ProjectBoard__r.Name');
        fieldSetNames.add('leankor__ApprovingManager__r.Name');
        fieldSetNames.add('leankor__DeliveredProduct__r.Name');
              
        String whereClauseVar= 'where leankor__Project__c = '+'\''+projectId+'\'';
        
        return descSche.dynamicFieldQuery('leankor__Expense__c', fieldSetNames,whereClauseVar );

    }
    
    //Get current project info
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled        
    global static leankor__ProjectRoom__c getProject(String projectId){
        //Added Security code for sentize user Input
        if ((String.isNotBlank(projectId) && Util.getSObjectName(projectId) != 'leankor__ProjectRoom__c')){
            throw new Util.LeanException('Error: Invalid input');
        }
        return [Select Id,
                        leankor__Portfolio__c,
                        leankor__Portfolio__r.Name,  
                        Name 
                    From leankor__ProjectRoom__c 
                    Where Id =:projectId 
                    With Security_Enforced
                    Limit 1];
    }
    //Save expense record and if any error return error respone 
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static List<string> saveExpense(leankor__Expense__c expense) {
        ExpenseBehaviour checkExpenseBehaviour = new ExpenseBehaviour();
        if (!checkExpenseBehaviour.isCreateable()) {
            return new List<String>();
        }
        //SS 15.12.2017 parameter recordTypeId is removed after using User Interface Api
        //expense.recordTypeId=recordTypeId;      
        //insert expense;  
        List<String> responseString= new List<String>(); 
        try{ 
            Database.SaveResult srList = Database.insert(expense, false);
            // Iterate through each returned result
            if (srList.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                responseString.add('Success');
                return responseString;
            }
            else {
                // Operation failed, so get all errors 
                Integer i=0;               
                for(Database.Error err : srList.getErrors()) {
                    responseString.add(++i+') '+err.getMessage());
                }
            }
        }
        catch(Exception ex)
        {
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        } 
        return responseString;
    }
    
    //Query for dynamically provided string
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static List<sObject> querySalesforceRecord(String queryString) {
    	return Database.query(queryString);
    }
    
    //Return List of fieldSet labels
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static List<String> getFieldSetLabels() {
        DescribeSchema descSche= new DescribeSchema();
        List<String> fieldSetLabels = new List<String>();
        for(Schema.FieldSetMember fieldLabel:descSche.getFieldSetFields('leankor__Expense__c', 'leankor__ExpenseViewFieldSet'))
        {
          fieldSetLabels.add(fieldLabel.getLabel());
        }
        return fieldSetLabels;
    }
    
    //Return List of fieldSet apiNames
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static List<String> getFieldSetAPIName() {
        DescribeSchema descSche= new DescribeSchema();
        List<String> fieldSetLabels = new List<String>();
        for(Schema.FieldSetMember fieldLabel:descSche.getFieldSetFields('leankor__Expense__c', 'leankor__ExpenseViewFieldSet'))
        {
          fieldSetLabels.add(fieldLabel.getFieldPath());
        }
        return fieldSetLabels;
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static Map<String, String> getLabelsForConsumers(String componentName) {
        Set<String> consumers = new Set<String>{'LeankorBase', 'LeankorCalendar', componentName};
        return leankor.LabelProvider.getLabelsForConsumers(consumers);
    }
}