public virtual with sharing class Swimlane {
	public String id {get; set;}
	public String forceId {get; set;}
	public String name {get; set;} {name = 'Default Swimlane';}
	public Decimal cardPerRow {get; set;} {cardPerRow = 1;}
	public String cmpId {get; set;}
	public String color {get; set;}
	public String guid {get; set;}
	public Decimal height {get; set;} {height = 320;}
	public String help {get; set;} {help = '';}
	public Boolean isCardAvailable {get; set;} {isCardAvailable = false;}
	public Decimal left {get; set;} {Left = 2100;}
	public Decimal limits {get; set;} {Limits = 0;}
	public String masterContainer {get; set;}
	public Decimal order {get; set;} {Order = 0;}
	public String title {get; set;} {Title = 'Default Swimlane';}
	public Decimal top {get; set;} {Top = 2100;}
	public String valueStreamId {get; set;}
	public Decimal width {get; set;}
	public String unit {get; set;}


    public enum SwimlaneType {
        INPROGRESS,
        STANDARD
    }


    /********************************************************************
    CONSTANTS
    *********************************************************************/
    public static final Swimlane INPROGRESS {get;set;}
    //Static initializer
    static {
    	INPROGRESS = new Swimlane();
    	//Manage consistent Swimlane color for default Systemswimlanes boards
    	//INPROGRESS.color='#66CC00';
    	INPROGRESS.color='#4183D7';
    }


    public static final Swimlane STANDARD {get;set;}
    //Static initializer
    static {
    	STANDARD = new Swimlane();
    	STANDARD.color='#4183D7';
    }


    public static final Map<String, Swimlane> SWIMLANES {get;set;} 
    //Static initializer
    static {
        SWIMLANES = new Map<String, Swimlane>();
        SWIMLANES.put('InProgress', INPROGRESS);
        SWIMLANES.put('Standard', STANDARD);
	}
	

    /********************************************************************
    CONSTRUCTORS
    *********************************************************************/
	public Swimlane() {

	}


	public Swimlane(leankor__MasterContainer__c masterContainer, SwimlaneType swimlaneType, Integer index) {
		getSwimlane(masterContainer, swimlaneType, index);
	}


	public Swimlane(leankor__MasterContainer__c masterContainer, Swimlane newSwimlane, Integer index) {
		this.id = newSwimlane.id;
		this.forceId = newSwimlane.forceId;
		this.name = newSwimlane.name;
		this.cardPerRow = newSwimlane.cardPerRow;
		this.cmpId = 'ext-swimlaneContainer-'+index;
		this.color = newSwimlane.color;
		this.guid = masterContainer.leankor__ValueStream__c+'-'+System.now().getTime()+'-sl00'+index;
		this.height = newSwimlane.height;
		this.help = newSwimlane.help;
		this.isCardAvailable = newSwimlane.isCardAvailable;
		this.left = newSwimlane.left;
		this.limits = newSwimlane.limits;
		this.masterContainer = masterContainer.id;
		this.order = newSwimlane.order;
		this.title = newSwimlane.title;
		this.top = newSwimlane.top;
		this.valueStreamId = masterContainer.leankor__ValueStream__c;
		this.width = (masterContainer.leankor__width__c == 210 ? 209: 418);
		this.unit = newSwimlane.unit;
	}


	public Swimlane(String valueStreamId, String masterContainerId, leankor__Swimlane__c newSwimlane) {
        this.cardPerRow = newSwimlane.leankor__CardPerRow__c;
        this.cmpId = newSwimlane.leankor__CmpID__c;
        this.color = newSwimlane.leankor__Color__c;
        this.unit = newSwimlane.leankor__Unit__c;
        this.guid = newSwimlane.Id+'-'+masterContainerId+'-s';
        this.height = newSwimlane.leankor__Height__c;
        this.help = newSwimlane.leankor__Help__c;
        this.left = newSwimlane.leankor__Left__c;
        this.limits = newSwimlane.leankor__Limit__c;
        this.masterContainer  = masterContainerId;
        this.name = newSwimlane.Name;
        this.order = newSwimlane.leankor__Order__c;
        this.title = newSwimlane.leankor__Title__c;
        this.top = newSwimlane.leankor__Top__c;
        this.valueStreamId = valueStreamId;
        this.width = newSwimlane.leankor__Width__c;
        this.isCardAvailable = newSwimlane.leankor__IsCardAvailable__c;
	}


    /********************************************************************
    FACTORY
    *********************************************************************/
    private Swimlane getSwimlane(leankor__MasterContainer__c masterContainer, SwimlaneType swimlaneType, Integer index) {
		Swimlane swimlane;
		
        switch on swimlaneType {
            when INPROGRESS {
                swimlane = new InProgressSwimlane(masterContainer, index);
            }
            when STANDARD {
                swimlane = new StandardSwimlane(masterContainer, index);
            }
            when else {
                swimlane = new Swimlane();
            }
		}
		
        return swimlane;
    }


    /********************************************************************
    SUBCLASS TYPES
    *********************************************************************/
   @testvisible
    private class InProgressSwimlane extends Swimlane {
        public InProgressSwimlane(leankor__MasterContainer__c masterContainer, Integer index) {
            super(masterContainer, INPROGRESS, index);
        }
    }


    private class standardSwimlane extends Swimlane {
        public standardSwimlane(leankor__MasterContainer__c masterContainer, Integer index) {
            super(masterContainer, STANDARD, index);
        }
    }


	/*------------------------------------------------------------
	Company:        Leankor
	Description:    This Method is use for creating Swimlane Records
	Inputs:         List of Swimlane innerClass
	Returns:        List of Swimlane object records 
	------------------------------------------------------------*/
   	//@RemoteAction
    public static List<leankor__Swimlane__c> createSwimlanes(final List<Swimlane> swimlanes) {
		List<leankor__Swimlane__c> results = new List<leankor__Swimlane__c>();
		
		//Check CRUD / FLC behavior
		SwimlaneBehavior swimlaneBehavior = new SwimlaneBehavior();
		if (!swimlaneBehavior.isCreateable()) {
			throw new Util.LeanException('Error: No access to records');
		} 
		//Check CRUD / FLC behavior
		
		try {
	        for (Swimlane swimlane : swimlanes) {
	        	leankor__Swimlane__c createSwimlane = new leankor__Swimlane__c();
				createSwimlane.Name = swimlane.name;
				createSwimlane.leankor__CardPerRow__c = swimlane.cardPerRow;
				createSwimlane.leankor__CmpID__c = swimlane.cmpId;
				createSwimlane.leankor__Unit__c = swimlane.unit;
				createSwimlane.leankor__Color__c = swimlane.color;
				createSwimlane.leankor__GUID__c = swimlane.guid;
				createSwimlane.leankor__Height__c = swimlane.height;
				createSwimlane.leankor__Help__c = swimlane.help;
				createSwimlane.leankor__IsCardAvailable__c = swimlane.isCardAvailable;
				createSwimlane.leankor__Left__c = swimlane.left;
				createSwimlane.leankor__Limit__c = swimlane.limits;
				createSwimlane.leankor__MasterContainer__c = (swimlane.masterContainer == ''? null : swimlane.masterContainer);
				createSwimlane.leankor__Order__c = swimlane.order;
				createSwimlane.leankor__Title__c = swimlane.title;
				createSwimlane.leankor__Top__c = swimlane.top;
				createSwimlane.leankor__ValueStream__c = (swimlane.valueStreamId == ''? null : swimlane.valueStreamId);
				createSwimlane.leankor__Width__c = swimlane.width;
			 
				results.add(createSwimlane);
			}
			
			DataBase.insert(results);
			
        } catch(Exception e) {
            throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return results;
	}
}