/*   
    * 	FILE: ProjectScheduleBlackout.cls
    *	CLASS: ProjectScheduleBlackout 
    *    Date:30/10/19
*/ 
global with sharing class ProjectScheduleBlackout {

    private static final String VERSION = 'v55.0';
    public ProjectScheduleBlackout(){}

    public ProjectScheduleBlackout(Util controller) {}
    

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static List<ProjectScheduleBlackout__c> createProjectScheduleBlackouts(final List<ProjectScheduleBlackout__c> projectScheduleBlackouts) {
       
        //Check CRUD / FLC behavior
        ProjectScheduleBlackoutBehaviour projectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        if (!projectScheduleBlackoutBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        	 
        try{ 
            insert projectScheduleBlackouts;
        }catch(DmlException e){
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }             
        return projectScheduleBlackouts;
    }

    global class Blackouts{
        @AuraEnabled
    	global List<String> boardIds{get; set;}
        @AuraEnabled
   		global String boardType{get; set;}
    
    }
    
    //Date :07/11/19 To get ProjectScheduleBlackout records.
    @RemoteAction
    global static Map<String, List<ProjectScheduleBlackout__c>> readProjectScheduleBlackouts(final leankor.ProjectScheduleBlackout.Blackouts blackout){ 
        for(String boardId : blackout.boardIds){
            if (String.isNotBlank(boardId)  && Util.getSObjectName(boardId) != 'leankor__ValueStream__c') {
                throw new Util.LeanException('Error: Invalid input');
            }
        }
    	
        Set<String> vsSet=new Set<String>(); // For value stream Id's
    	Map<String, List<ProjectScheduleBlackout__c>> vsBlackOutMap = new Map<String, List<ProjectScheduleBlackout__c>>();
    	
        vsSet.addAll(blackout.boardIds);

    	if(blackout.boardType == 'PDG'){
            // Get all related board Id's
    	  	vsSet.addAll(GanttTaskBoard.getExternallyDependentVSIds(vsSet));
    	}   	           
        
        try{         
            for(ProjectScheduleBlackout__c scheduleBlackout: [Select Id,
                                                                    Name,
                                                                    leankor__ProjectBoard__c,
                                                                    leankor__ProjectBoard__r.Name,
                                                                    leankor__ProjectBoard__r.leankor__SevenDayWorkWeek__c,
                                                                    leankor__StartDate__c,
                                                                    leankor__EndDate__c 
                                                                From ProjectScheduleBlackout__c 
                                                                Where leankor__ProjectBoard__c IN: vsSet 
                                                                    And leankor__ProjectBoard__r.leankor__IsRecordDeleted__c = false
                                                                With Security_Enforced
                                                                Order By leankor__StartDate__c, leankor__EndDate__c Asc
                                                                Limit 50000]){

           		List<ProjectScheduleBlackout__c> blackOutList = vsBlackOutMap.ContainsKey(scheduleBlackout.leankor__ProjectBoard__c) 
                                                                ? vsBlackOutMap.get(scheduleBlackout.leankor__ProjectBoard__c) 
                                                                : new List<ProjectScheduleBlackout__c> ();
				blackOutList.add(scheduleBlackout);
				vsBlackOutMap.put(scheduleBlackout.leankor__ProjectBoard__c, blackOutList);	
           }           
            
        }catch(Exception e){
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }  
        return vsBlackOutMap;
    }


    @AuraEnabled(cacheable=true)
    global static Map<String, List<ProjectScheduleBlackout__c>>  readProjectScheduleBlackoutsLWC(final List<leankor.ProjectScheduleBlackout.Blackouts> blackouts){
        //Input validation is already validate in child method.
        return readProjectScheduleBlackouts(blackouts.get(0));  
    }


    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static List<DataTableColumns> projectScheduleBlackoutViewFieldSet(String sObjectName){
        
        List<DataTableColumns> dateTableColumns = new List<DataTableColumns>();
        List<Schema.FieldSetMember> allSchemaFieldSetFieldNames = new List<Schema.FieldSetMember>();
        DescribeSchema describeSchema = new DescribeSchema();

        try {
    
            allSchemaFieldSetFieldNames = describeSchema.getAllFieldSetFields(sObjectName);
        for(Schema.FieldSetMember fsm : allSchemaFieldSetFieldNames){
            DataTableColumns dateColumn;
            /** Date: 25/11/ 2019 - To prevent project board column editable on lwc datatable.
                                Now reference field is not editable.*/
                if(String.valueOf(fsm.getType()).toLowerCase() == 'reference' || sObjectName == 'leankor__ValueStream__c'){
                dateColumn = new DataTableColumns( String.valueOf(fsm.getLabel()) , 
                                                                String.valueOf(fsm.getFieldPath()), 
                                                                String.valueOf(fsm.getType()).toLowerCase(),
                                                                false);

            }else{
                dateColumn = new DataTableColumns( String.valueOf(fsm.getLabel()) , 
                                                                String.valueOf(fsm.getFieldPath()), 
                                                                String.valueOf(fsm.getType()).toLowerCase(),
                                                                true);
            }
            /**Date: 23/11/ 2019 - To resolve the time zone issue on lwc datatable.
                                Now time will converted into the local time zone. */                                                    
            if(dateColumn.type == 'date'){
                dateColumn.type ='date-local';
            }
            dateTableColumns.add(dateColumn);   
            }
            
        } catch (Exception e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }

        return dateTableColumns;
    }

    global class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}   
        @AuraEnabled 
        public Boolean editable {get; set;}  

        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String type, Boolean editable){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;       
            this.editable = editable;     
        }
    }


    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled  
    global static Boolean updateProjectScheduleBlackouts(final List<ProjectScheduleBlackout__c> projectScheduleBlackouts){
       
        //Check CRUD / FLC behavior
        ProjectScheduleBlackoutBehaviour projectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        if (!projectScheduleBlackoutBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        
        try{  
            update projectScheduleBlackouts;
        }catch(DmlException e){
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        return true;
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static List<ProjectScheduleBlackout__c> deleteProjectScheduleBlackouts(final List<ProjectScheduleBlackout__c> projectScheduleBlackouts){
        
        //Check CRUD / FLC behavior
        ProjectScheduleBlackoutBehaviour projectScheduleBlackoutBehaviour = new ProjectScheduleBlackoutBehaviour();
        if (!projectScheduleBlackoutBehaviour.isDeletable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
        try{           
            delete projectScheduleBlackouts;
        }catch(DmlException e){
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }
        return projectScheduleBlackouts;    
    }


    /**
        Date: 05/12/2019
        Description: This method is a aura enabled method that returns the fields from Layout
		Input : String sObject Name
		Output : String (Layout metada)
        and return all field available in the page layout.
     */

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getSobjectLayoutFields(String sObjectName){

      	/*
			Date: 13/02/2020 
       		Now using getOrgDomainUrl- no need to register URL in remote site setting 
	 	*/
        //String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String sfdcURL = System.URL.getOrgDomainUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/'+VERSION+'/ui-api/layout/'+sObjectName; 
        HttpRequest httpRequest = new HttpRequest(); 
        httpRequest.setMethod('GET'); 
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        httpRequest.setEndpoint(restAPIURL);
        String response = '';
        try {  
                Http http = new Http();   
                HttpResponse httpResponse = http.send(httpRequest);  
                if (httpResponse.getStatusCode() == 200 ) {  
                                response = httpResponse.getBody();
                } else {
                    throw new CalloutException( httpResponse.getBody() );  
                        }
        } catch( System.Exception e) {  
            throw e;  
        }
        return response;
		//Metadata methods does not work in package. That's why we have reverted it and using again Ui-api
        // List<String> layoutFields = new List<String>();
        // List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {sObjectName+'-'+pageLayoutName});

        // Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        // for (Metadata.LayoutSection section : layoutMd.layoutSections) {
        //     for (Metadata.LayoutColumn column : section.layoutColumns) {
        //         if (column.layoutItems != null) {
        //             for (Metadata.LayoutItem item : column.layoutItems) {
        //                 if(item.field.substring((item.field.length() - 3),item.field.length()) == '__c'){
        //                     item.field = 'leankor__' + item.field;
        //                 }
        //                 layoutFields.add(item.field);
        //             }
        //         }
        //     }
        // }
        // return layoutFields;
                }
}