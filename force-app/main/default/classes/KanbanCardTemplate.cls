public virtual with sharing class KanbanCardTemplate {
	public leankor__KanbanCardTemplate__c kanbanCardTemplate;
	public leankor__ValueStream__c valuestream;

    public String color {get; set;} 
    public String cssLayout {get; set;} 
    public String derivedFrom {get; set;}
    public Decimal height {get; set;} 
    public String jsonData {get; set;} 
    public String jsonDefinition {get; set;} 
    public String valueStreamId {get; set;}
    public Decimal width {get; set;}  
	public String name {get; set;}
	public String title {get; set;}
    public String ownerId {get; set;}
    public String fieldSetName {get; set;}
    public String weekCalendar {get; set;}

    public enum KanbanCardTemplateType {
		STANDARD,
		HR,
		SALES,
		MARKETING,
		FINANCE,
		OPERATIONS
    }

    /********************************************************************
    CONSTANTS
    *********************************************************************/
    public static final KanbanCardTemplate STANDARD {get;set;}
    //Static initializer
    static {
        STANDARD = new KanbanCardTemplate();
    	STANDARD.name = 'Default';
    	STANDARD.title = 'Default';
    }

    public static final KanbanCardTemplate HR {get;set;}
    //Static initializer
    static {
        HR = new KanbanCardTemplate();
    	HR.name = 'HR';
    	HR.title = 'HR';
    }

    public static final KanbanCardTemplate SALES {get;set;}
    //Static initializer
    static {
        SALES = new KanbanCardTemplate();
    	SALES.name = 'Sales';
    	SALES.title = 'Sales';
    }

    public static final KanbanCardTemplate MARKETING {get;set;}
    //Static initializer
    static {
        MARKETING = new KanbanCardTemplate();
    	MARKETING.name = 'Marketing';
    	MARKETING.title = 'Marketing';
    }

    public static final KanbanCardTemplate FINANCE {get;set;}
    //Static initializer
    static {
        FINANCE = new KanbanCardTemplate();
    	FINANCE.name = 'Finance';
    	FINANCE.title = 'Finance';
    }

    public static final KanbanCardTemplate OPERATIONS {get;set;}
    //Static initializer
    static {
        OPERATIONS = new KanbanCardTemplate();
    	OPERATIONS.name = 'Operations';
    	OPERATIONS.title = 'Operations';
    }

    public static final Map<String, KanbanCardTemplate> KANBANCARD_TEMPLATES {get;set;} 
    //Static initializer
    static {
        KANBANCARD_TEMPLATES = new Map<String, KanbanCardTemplate>();
        KANBANCARD_TEMPLATES.put('Default', STANDARD);
        // KANBANCARD_TEMPLATES.put('HR', HR);
        // KANBANCARD_TEMPLATES.put('Sales', SALES);
        // KANBANCARD_TEMPLATES.put('Marketing', MARKETING);
        // KANBANCARD_TEMPLATES.put('Finance', FINANCE);
        // KANBANCARD_TEMPLATES.put('Operations', OPERATIONS);
    }

    /********************************************************************
    CONSTRUCTORS
    *********************************************************************/
    //Default
	public KanbanCardTemplate() {
		
	}

    public KanbanCardTemplate(leankor__ValueStream__c valueStream, KanbanCardTemplateType kanbanCardTemplateType) {
        getKanbanCardTemplate(valueStream, kanbanCardTemplateType);
    }

    public KanbanCardTemplate(leankor__ValueStream__c valueStream, KanbanCardTemplate newKanbanCardTemplate) {
        this.name = newKanbanCardTemplate.name;
        this.title = newKanbanCardTemplate.title;
        this.valuestream = valueStream;
    }

    public KanbanCardTemplate(String valueStreamId, String ownerId, leankor__KanbanCardTemplate__c newKanbanCardTemplate) {
        this.color = newKanbanCardTemplate.leankor__Color__c; 
        this.cssLayout = newKanbanCardTemplate.leankor__CSSLayout__c; 
        this.derivedFrom = null; 
        this.height = newKanbanCardTemplate.leankor__Height__c; 
        this.jsonData = newKanbanCardTemplate.leankor__JSONData__c; 
        this.jsonDefinition = newKanbanCardTemplate.leankor__JSONDefinition__c; 
        this.title = newKanbanCardTemplate.id;
        this.valueStreamId = valueStreamId; 
        this.width = newKanbanCardTemplate.leankor__Width__c; 
        this.name = newKanbanCardTemplate.Name;
        this.ownerId = ownerId;
        this.fieldSetName = newKanbanCardTemplate.leankor__FieldSetName__c;
        this.weekCalendar = newKanbanCardTemplate.leankor__weekCalendar__c;
    }

	/********************************************************************
    FACTORY
    *********************************************************************/
    public KanbanCardTemplate getKanbanCardTemplate(leankor__ValueStream__c valueStream, KanbanCardTemplateType kanbanCardTemplateType) {
        KanbanCardTemplate kanbancardtemplate;
        switch on kanbanCardTemplateType {
            when STANDARD {
                kanbancardtemplate = new StandardKanbanCardTemplate(valueStream);
            }
            when HR {
                kanbancardtemplate = new HrKanbanCardTemplate(valueStream);
            }
            when SALES {
                kanbancardtemplate = new SalesKanbanCardTemplate(valueStream);
            }
            when MARKETING {
                kanbancardtemplate = new MarketingKanbanCardTemplate(valueStream);
            }
            when FINANCE {
                kanbancardtemplate = new FinanceKanbanCardTemplate(valueStream);
            }
            when OPERATIONS {
                kanbancardtemplate = new OperationsKanbanCardTemplate(valueStream);
            }
            when else {
                kanbancardtemplate = new KanbanCardTemplate();
            }
        }
        return kanbancardtemplate;
    }

    /********************************************************************
    SUBCLASS TYPES
    *********************************************************************/
    @testvisible
    private class StandardKanbanCardTemplate extends KanbanCardTemplate{
        public StandardKanbanCardTemplate(leankor__ValueStream__c valueStream) {
            super(valueStream, STANDARD);
        }
    }
    @testvisible
    private class HrKanbanCardTemplate extends KanbanCardTemplate{
        public HrKanbanCardTemplate(leankor__ValueStream__c valueStream) {
            super(valueStream, HR);
        }
    }
    @testvisible
    private class SalesKanbanCardTemplate extends KanbanCardTemplate{
        public SalesKanbanCardTemplate(leankor__ValueStream__c valueStream) {
            super(valueStream, SALES);
        }
    }
    @testvisible
    private class MarketingKanbanCardTemplate extends KanbanCardTemplate{
        public MarketingKanbanCardTemplate(leankor__ValueStream__c valueStream) {
            super(valueStream, MARKETING);
        }
    }
    @testvisible
    private class FinanceKanbanCardTemplate extends KanbanCardTemplate{
        public FinanceKanbanCardTemplate(leankor__ValueStream__c valueStream) {
            super(valueStream, FINANCE);
        }
    }
    @testvisible
    private class OperationsKanbanCardTemplate extends KanbanCardTemplate{
        public OperationsKanbanCardTemplate(leankor__ValueStream__c valueStream) {
            super(valueStream, OPERATIONS);
        }
    }
	
	public void setKanbanBoardKanbanCardTemplate(KanbanCardTemplate kanbanCardTemplate) {
        this.kanbanCardTemplate = new leankor__KanbanCardTemplate__c(
        	Name = kanbanCardTemplate.name,
        	leankor__Title__c = kanbanCardTemplate.title,
        	leankor__JSONDefinition__c = '',
        	leankor__JSONData__c = '',
        	leankor__Width__c = 170,
        	leankor__Height__c =120,
        	leankor__CSSLayout__c = '',
        	leankor__Color__c = '#bdbffc',
        	leankor__ValueStream__c = kanbanCardTemplate.valuestream.id
        );
	}

    public void setKanbanCardTemplate(KanbanCardTemplate kanbanCardTemplate) {
        this.kanbanCardTemplate = new leankor__KanbanCardTemplate__c(
            leankor__Color__c = kanbanCardTemplate.color, 
            leankor__CSSLayout__c = kanbanCardTemplate.cssLayout, 
            leankor__DerivedFrom__c = kanbanCardTemplate.derivedFrom, 
            leankor__Height__c = kanbanCardTemplate.height, 
            leankor__JSONData__c = kanbanCardTemplate.jsonData, 
            leankor__JSONDefinition__c = kanbanCardTemplate.jsonDefinition, 
            leankor__Title__c = kanbanCardTemplate.title,
            leankor__ValueStream__c = kanbanCardTemplate.valueStreamId, 
            leankor__Width__c = kanbanCardTemplate.width, 
            Name = kanbanCardTemplate.name,
            OwnerId = kanbanCardTemplate.ownerId,
            leankor__FieldSetName__c = kanbanCardTemplate.fieldSetName,
            leankor__WeekCalendar__c = kanbanCardTemplate.weekCalendar
        );
    }

	public static List<leankor__KanbanCardTemplate__c> createKanbanCardTemplates(final List<KanbanCardTemplate> kanbanCardTemplates) {
        
        //Check CRUD / FLC behavior   
		KanbanCardTemplateBehaviour kanbanCardTemplateBehaviour = new KanbanCardTemplateBehaviour();
		if (!kanbanCardTemplateBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
		//Check CRUD / FLC behavior 
        
        List<leankor__KanbanCardTemplate__c> newkanbanCardTemplates = new List <leankor__KanbanCardTemplate__c>();
        leankor__KanbanCardTemplate__c newkanbanCardTemplate = new leankor__KanbanCardTemplate__c();
	    for(KanbanCardTemplate kanbanCardTemplate: kanbanCardTemplates) {
	    	newkanbanCardTemplate = kanbanCardTemplate.kanbanCardTemplate;
	    	newkanbanCardTemplates.add(newKanbanCardTemplate);
	    }

	    try{
        	Database.insert(newkanbanCardTemplates, false);
    	}catch(DMLException e){
            //25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());
    	}

    	return newkanbanCardTemplates;
	}

}