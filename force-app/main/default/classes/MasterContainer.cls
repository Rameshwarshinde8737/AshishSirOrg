public virtual with sharing class MasterContainer {
    public leankor__MasterContainer__c masterContainer;
    public String id {get; set;}
    public String unit {get; set;}
    public String forceId {get; set;}
    public String name {get; set;}
    public String color {get; set;}
    public String cmpId {get; set;}
    public String guid {get; set;}
    public Decimal height {get; set;} {height = 352;} //Initialize
    public Boolean isCardAvailable {get; set;} {isCardAvailable = false;} //Initialize
    public Decimal left {get; set;} {left = 2080;} //Initialize
    public Decimal limits {get; set;} {limits = 0;} //Initialize
    public Decimal order {get; set;}
    public String title {get; set;}
    public Decimal top {get; set;} {top = 2010;} //Initialize
    public String type {get; set;}
    public String valueStreamId {get; set;}
    public Decimal width {get; set;} {width = 210;} //Initialize
    
    public enum MasterContainerType {
        TEMPLATE, 
        BACKLOG, 
        INPROGRESS, 
        REVIEWANDAPPROVE, 
        DONE, 
        ARCHIVE
    }

    /********************************************************************
    CONSTANTS
    *********************************************************************/
    public static final MasterContainer TEMPLATE {get;set;}
    //Static initializer
    static {
        TEMPLATE = new MasterContainer();
        TEMPLATE.color = '#DBDB12';
        TEMPLATE.name = 'Template';
        TEMPLATE.title = 'Template';
        TEMPLATE.type = 'Template';
    }
    public static final MasterContainer BACKLOG {get;set;}
    //Static initializer
    static {
        BACKLOG = new MasterContainer();
        BACKLOG.color = '#A0A0A0';
        BACKLOG.name = 'Backlog';
        BACKLOG.title = 'Backlog';
        BACKLOG.type = 'Backlog';
    }

    public static final MasterContainer INPROGRESS {get;set;}
    //Static initializer
    static {        
        INPROGRESS = new MasterContainer();
        INPROGRESS.color = '#6666FF';
        INPROGRESS.name = 'In Progress';
        INPROGRESS.title = 'In Progress';
        INPROGRESS.type = 'Regular';
    }

    public static final MasterContainer REVIEWANDAPPROVE {get;set;}
    //Static initializer
    static {
        REVIEWANDAPPROVE = new MasterContainer();
        REVIEWANDAPPROVE.color = '#FF8000';
        REVIEWANDAPPROVE.name = 'Review & Approve';
        REVIEWANDAPPROVE.title = 'Review & Approve';
        REVIEWANDAPPROVE.type = 'Regular';
    }

    public static final MasterContainer DONE {get;set;}
    //Static initializer
    static {
        DONE = new MasterContainer();
        DONE.color = '#66CC00';
        DONE.name = 'Done';
        DONE.title = 'Done';
        DONE.type = 'Regular';
    }

    public static final MasterContainer ARCHIVE {get;set;}
    //Static initializer
    static {
        ARCHIVE = new MasterContainer();
        ARCHIVE.color = '#808080';
        ARCHIVE.name = 'Archive';
        ARCHIVE.title = 'Archive';
        ARCHIVE.type = 'Archive';
    }
    public static final Map<String, MasterContainer> MASTERCONTAINERS {get;set;} 
    //Static initializer
    static {
        MASTERCONTAINERS = new Map<String, MasterContainer>();
        MASTERCONTAINERS.put('Template', TEMPLATE);
        MASTERCONTAINERS.put('Backlog', BACKLOG);
        MASTERCONTAINERS.put('In Progress', INPROGRESS);
        MASTERCONTAINERS.put('Review & Approve', REVIEWANDAPPROVE);
        MASTERCONTAINERS.put('Done', DONE);
        MASTERCONTAINERS.put('Archive', ARCHIVE);
    }

    /********************************************************************
    CONSTRUCTORS
    *********************************************************************/
    //Default
    public MasterContainer() {

    }

    public MasterContainer(leankor__ValueStream__c valueStream, MasterContainerType masterContainerType, Integer index) {
        getMasterContainer(valueStream, masterContainerType, index);
    }

    public MasterContainer(leankor__ValueStream__c valueStream, MasterContainer newMasterContainer, Integer index) {
        this.forceId = newMasterContainer.forceId;
        this.unit = newMasterContainer.unit;
        this.name = newMasterContainer.name;
        this.color = newMasterContainer.color;
        this.cmpId = 'ext-masterContainer-'+index;
        this.guid = valueStream.id+'-'+System.now().getTime()+'-mc00'+index;
        this.height = newMasterContainer.height;
        this.isCardAvailable = newMasterContainer.isCardAvailable;
        this.left = newMasterContainer.left;
        this.limits = newMasterContainer.limits;
        this.order = index;
        this.title = newMasterContainer.title;
        this.top = newMasterContainer.top;
        this.type = newMasterContainer.type;
        this.valueStreamId = valueStream.id;
        this.width = newMasterContainer.width;
    }

    public MasterContainer(String valueStreamId, leankor__MasterContainer__c newMasterContainer) {
        this.cmpId = newMasterContainer.leankor__CmpID__c;
        this.color = newMasterContainer.leankor__Color__c;
        this.unit = newMasterContainer.leankor__Unit__c;
        this.guid  = newMasterContainer.Id+'-'+valueStreamId+'-m';
        this.height = newMasterContainer.leankor__Height__c;
        this.left = newMasterContainer.leankor__Left__c;
        this.limits = newMasterContainer.leankor__Limit__c;
        this.name = newMasterContainer.Name;
        this.order = newMasterContainer.leankor__Order__c;
        this.title = newMasterContainer.leankor__Title__c;
        this.top = newMasterContainer.leankor__Top__c;
        this.type = newMasterContainer.leankor__Type__c;
        this.valueStreamId = valueStreamId;
        this.width = newMasterContainer.leankor__Width__c;
        this.isCardAvailable = newMasterContainer.leankor__IsCardAvailable__c;
    }

    public MasterContainer(leankor__ValueStream__c valueStream, leankor__MasterContainer__c masterContainer, Integer index) {
        this.masterContainer = masterContainer;
    }

    /********************************************************************
    FACTORY
    *********************************************************************/
    private MasterContainer getMasterContainer(leankor__ValueStream__c valueStream, MasterContainerType masterContainerType, Integer index) {
        MasterContainer masterContainer;
        switch on masterContainerType {
            when TEMPLATE {
                masterContainer = new TemplateMasterContainer(valueStream, index);
            }
            when BACKLOG {
                masterContainer = new BacklogMasterContainer(valueStream, index);
            }
            when INPROGRESS {
                masterContainer = new InProgressMasterContainer(valueStream, index);
            }
            when REVIEWANDAPPROVE {
                masterContainer = new ReviewAndApproveMasterContainer(valueStream, index);
            }
            when DONE {
                masterContainer = new DoneMasterContainer(valueStream, index);
            }
            when ARCHIVE {
                masterContainer = new ArchiveMasterContainer(valueStream, index);
            }
            when else {
                masterContainer = new MasterContainer();
            }
        }
        return masterContainer;
    }

    /********************************************************************
    SUBCLASS TYPES
    *********************************************************************/
    private class TemplateMasterContainer extends MasterContainer{
        public TemplateMasterContainer(leankor__ValueStream__c valueStream, Integer index) {
            super(valueStream, TEMPLATE, index);
        }
    }

    private class BacklogMasterContainer extends MasterContainer{
        public BacklogMasterContainer(leankor__ValueStream__c valueStream, Integer index) {
            super(valueStream, BACKLOG, index);
        }
    }

    private class InProgressMasterContainer extends MasterContainer{
        public InProgressMasterContainer(leankor__ValueStream__c valueStream, Integer index) {
            super(valueStream, INPROGRESS, index);
        }
    }

    private class ReviewAndApproveMasterContainer extends MasterContainer{
        public ReviewAndApproveMasterContainer(leankor__ValueStream__c valueStream, Integer index) {
            super(valueStream, REVIEWANDAPPROVE, index);
        }
    }

    private class DoneMasterContainer extends MasterContainer{
        public DoneMasterContainer(leankor__ValueStream__c valueStream, Integer index) {
            super(valueStream, DONE, index);
        }
    }

    private class ArchiveMasterContainer extends MasterContainer{
        public ArchiveMasterContainer(leankor__ValueStream__c valueStream, Integer index) {
            super(valueStream, ARCHIVE, index);
        }
    }

    /********************************************************************
    EXCEPTIONS
    *********************************************************************/
    private class MasterContainerException extends Exception {}
    private class ObjectLevelSecurityException extends Exception {}

    /********************************************************************
    CRUD OPERATIONS
    *********************************************************************/
    //Checks CRUD CREATE operation (OLS for now)
    /*private static Boolean isCreateable(final String sObjectName){
    	DescribeSchema describeSchema = new DescribeSchema();
        Schema.DescribeSObjectResult describeSObjectResult = describeSchema.describeSObject(sObjectName);
        Boolean isObjectCreateable = describeSchema.isObjectCreateable(describeSObjectResult);
        Boolean isFieldCreatable = true;     
        return isObjectCreateable && isFieldCreatable;
    }

	//Checks CRUD READ operation (OLS for now)
    private static Boolean isAccessible(final String sObjectName){
        DescribeSchema describeSchema = new DescribeSchema();
        Schema.DescribeSObjectResult describeSObjectResult = describeSchema.describeSObject(sObjectName);
        Boolean isObjectAccessible = describeSchema.isObjectAccessible(describeSObjectResult);      
        Boolean isFieldAccessible = true;
        return isObjectAccessible && isFieldAccessible;
    }   

	//Checks CRUD UPDATEABLE operation (OLS for now)
    private static Boolean isUpdateable(final String sObjectName){
    	DescribeSchema describeSchema = new DescribeSchema();
        Schema.DescribeSObjectResult describeSObjectResult = describeSchema.describeSObject(sObjectName);
        Boolean isObjectUpdateable = describeSchema.isObjectUpdateable(describeSObjectResult);      
        Boolean isFieldUpdateable = true;
        return isObjectUpdateable && isFieldUpdateable;
    }

    //Checks CRUD DELETE operation (OLS for now)
    private static Boolean isDeletable(final String sObjectName){
        DescribeSchema describeSchema = new DescribeSchema();
        Schema.DescribeSObjectResult describeSObjectResult = describeSchema.describeSObject(sObjectName);
        Boolean isObjectDeletable = describeSchema.isObjectDeletable(describeSObjectResult);      
        Boolean isFieldDeletable = true;
        return isObjectDeletable;
    }*/

    //Accesor CREATE method for a list of MasterContainer sObjects
    @RemoteAction
    public static List<leankor__MasterContainer__c> createMasterContainers(final List<MasterContainer> masterContainers){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        if (!masterContainerBehaviour.isAccessible() ||
            !masterContainerBehaviour.isCreateable()) {
            System.debug('Error: No access to create records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__MasterContainer__c> results = new List<leankor__MasterContainer__c>();
        try {
            for (MasterContainer masterContainer : masterContainers) {
                leankor__MasterContainer__c createMasterContainer = new leankor__MasterContainer__c();
                createMasterContainer.Name = masterContainer.name;
                createMasterContainer.leankor__Color__c = masterContainer.color;
                createMasterContainer.leankor__Unit__c = masterContainer.unit;
                createMasterContainer.leankor__CmpID__c = masterContainer.cmpId;
                createMasterContainer.leankor__GUID__c = masterContainer.guid;
                createMasterContainer.leankor__Height__c = masterContainer.height;
                createMasterContainer.leankor__IsCardAvailable__c = masterContainer.isCardAvailable;
                createMasterContainer.leankor__Left__c = masterContainer.left;
                createMasterContainer.leankor__Limit__c = masterContainer.limits;
                createMasterContainer.leankor__Order__c = masterContainer.order;
                createMasterContainer.leankor__Title__c = masterContainer.title;
                createMasterContainer.leankor__Top__c = masterContainer.top;
                createMasterContainer.leankor__Type__C = masterContainer.type;
                createMasterContainer.leankor__ValueStream__c = (masterContainer.valueStreamId == '')?null : masterContainer.valueStreamId;
                createMasterContainer.leankor__Width__c = masterContainer.width;            
            	results.add(createMasterContainer);
            }
            DataBase.insert(results);
        } catch(Exception e) {
        	System.debug('Error : '+e.getMessage());
        	throw new MasterContainerException('Create exception: '+e.getMessage(), e); 
        }
        return results;
    }

    //Accesor READ method for a list of MasterContainer sObjects
    @RemoteAction
    public static List<leankor__MasterContainer__c> readMasterContainers(final String valueStream){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        if (!masterContainerBehaviour.isAccessible()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

    	List<leankor__MasterContainer__c> results = new List<leankor__MasterContainer__c>();
    	try {
            results = [Select Id,
                                leankor__Unit__c,
                                leankor__CmpID__c,
                                leankor__Color__c,
                                leankor__guid__c,
                                leankor__Height__c,
                                leankor__IsCardAvailable__c,
                                leankor__Left__c,
                                leankor__Limit__c,
                                leankor__Order__c,
                                leankor__Title__c,
                                leankor__Top__c,
                                leankor__Type__c,
                                leankor__ValueStream__c,
                                leankor__Width__c,
                                Name,
                                OwnerId 
                            From leankor__MasterContainer__c 
                            Where leankor__ValueStream__c =: valueStream 
                            With Security_Enforced
                            Limit 50000];
        }
        catch (Exception e) {
            System.debug('Error : '+e.getMessage());
        	throw new MasterContainerException('Read exception: ', e);
        }
        return results;
    }

    //Mutator UPDATE method for a list of MasterContainer sObjects
    @RemoteAction
    public static List<leankor__MasterContainer__c> updateMasterContainers(final List<MasterContainer> masterContainers){
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        if (!masterContainerBehaviour.isAccessible() ||
            !masterContainerBehaviour.isUpdateable() || 
            !masterContainerBehaviour.isCreateable()) {
            System.debug('Error: No access to records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        List<leankor__MasterContainer__c> results = new List<leankor__MasterContainer__c>();
        try {
            for (MasterContainer masterContainer : masterContainers) {
                leankor__MasterContainer__c updateMasterContainer = new leankor__MasterContainer__c();
                updateMasterContainer.Name = masterContainer.name;
                updateMasterContainer.leankor__Color__c = masterContainer.color;
                updateMasterContainer.leankor__Unit__c = masterContainer.unit;
                updateMasterContainer.leankor__CmpID__c = masterContainer.cmpId;
                updateMasterContainer.leankor__GUID__c = masterContainer.guid;
                updateMasterContainer.leankor__Height__c = masterContainer.height;
                updateMasterContainer.leankor__IsCardAvailable__c = masterContainer.isCardAvailable;
                updateMasterContainer.leankor__Left__c = masterContainer.left;
                updateMasterContainer.leankor__Limit__c = masterContainer.limits;
                updateMasterContainer.leankor__Order__c = masterContainer.order;
                updateMasterContainer.leankor__Title__c = masterContainer.title;
                updateMasterContainer.leankor__Top__c = masterContainer.top;
                updateMasterContainer.leankor__Type__C = masterContainer.type;
                updateMasterContainer.leankor__ValueStream__c = (masterContainer.valueStreamId == '')?null : masterContainer.valueStreamId;
                updateMasterContainer.leankor__Width__c = masterContainer.width;
                results.add(updateMasterContainer);
            }
            Schema.Sobjectfield externField = leankor__MasterContainer__c.Fields.leankor__GUID__c;
            Database.upsert(results, externField); // GUID is the external unique key to match
           
        } catch(Exception e) {
            System.debug('Error : '+e.getMessage());
             results = new List<leankor__MasterContainer__c>();
            throw new MasterContainerException('Update exception', e);
        }
        return results;
    }

    //Mutator DELETE method for a list of MasterContainer sObjects
    @RemoteAction
    public static String deleteMasterContainers(final List<String> Ids){  
        //Check CRUD / FLC behavior 
        MasterContainerBehaviour masterContainerBehaviour = new MasterContainerBehaviour();
        if (!masterContainerBehaviour.isAccessible() ||
            !masterContainerBehaviour.isUpdateable()) {
            System.debug('Error: No access to delete records');
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 

        String operationStatus = 'success';
        List<leankor__MasterContainer__c> masterContainers = [Select Id,
                                                                    leankor__ValueStream__c
                                                                    From leankor__MasterContainer__c 
                                                                Where Id In :ids 
                                                                With Security_Enforced
                                                                Limit 10000];
        
        for (leankor__MasterContainer__c masterContainer : masterContainers) {
    	            masterContainer.leankor__ValueStream__c = null;
    	        }
        try{
           if (!masterContainers.isEmpty()) {
                update masterContainers;
           }
        }catch(Exception e){
            System.debug('Error : '+e.getMessage());
            operationStatus = 'failed';
            throw new MasterContainerException('Delete exception', e);
            
        }
        return operationStatus;
    }
}