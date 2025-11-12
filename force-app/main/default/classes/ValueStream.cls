global with sharing class ValueStream {
	public leankor__ValueStream__c valueStream;
	public static final leankor__LeanConstants__c LEAN_CONSTANT = leankor__LeanConstants__c.getInstance();

    String name;
    String boardType;
    Boolean portfolioMode;
    Boolean sevenDayWorkWeek;

    public enum ValueStreamType {
        KANBAN_BOARD,
        PLAN_BOARD,
        DASH_BOARD
    }


    // CONSTANTS
    public static final ValueStream KANBAN_BOARD {get;set;}
    
    //Static initializer
    static {
        KANBAN_BOARD = new ValueStream();
        KANBAN_BOARD.name = '_System_Board';
        KANBAN_BOARD.boardType = 'Kanban Board';
        KANBAN_BOARD.portfolioMode = false;
        KANBAN_BOARD.sevenDayWorkWeek = false;
    }


    public static final ValueStream PLAN_BOARD {get;set;}
    //Static initializer
    static {
        PLAN_BOARD = new ValueStream();
        PLAN_BOARD.name = '_System_PlanBoard';
        PLAN_BOARD.boardType = 'Plan Board';
        PLAN_BOARD.portfolioMode = true;
        PLAN_BOARD.sevenDayWorkWeek = true;
    }


    public static final ValueStream DASH_BOARD {get;set;}
    //Static initializer
    static {
        DASH_BOARD = new ValueStream();
        DASH_BOARD.name = '_System_DashBoard';
        DASH_BOARD.boardType = 'DashBoard';
        DASH_BOARD.portfolioMode = false;
        DASH_BOARD.sevenDayWorkWeek = false;
    }

    // Default constructor
    public ValueStream() {}


	public ValueStream(ValueStream valueStream) {
        this.valueStream = new leankor__ValueStream__c (
            Name = valueStream.name, 
            leankor__BoardType__c = valueStream.boardType,
            //leankor__BoardType__c = 'Plan Board',
            leankor__SprintStartDate__c = null,
            leankor__PointPicklist__c = (String.isBlank(LEAN_CONSTANT.leankor__PointSequence__c) ? '[]' : LEAN_CONSTANT.leankor__PointSequence__c),
            leankor__DaysPerSprint__c = null,
            leankor__IsAgile__c = false,
            leankor__Effortindicator__c = 'Days',
            leankor__TaskDateCheck__c = (!LEAN_CONSTANT.leankor__AvoidTaskDueDateCheck__c),
            leankor__DefaultCategory__c = null,
            leankor__DisableCalendarView__c = false,
            leankor__IsTemplateBoard__c = false,
            leankor__PortfolioMode__c = valueStream.portfolioMode,
            //leankor__PortfolioMode__c = true,
            leankor__DisableTaskAsMiniature__c = false,
            leankor__SevenDayWorkWeek__c = valueStream.sevenDayWorkWeek,
            //leankor__SevenDayWorkWeek__c = true,
            leankor__DefaultOwnerID__c = userinfo.getuserID()
        );
	}


    public static List<leankor__ValueStream__c> createValueStream(List<leankor__ValueStream__c> valueStreams) {
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isCreateable()) {
            return new List<leankor__ValueStream__c>();
	    }
        //Check CRUD / FLC behavior

	    try {
        	Database.insert(valueStreams);
    	} catch(DMLException e) {
        	throw new Util.LeanException('ERROR:' + e.getMessage());
        }

    	return valueStreams;
	}


    public static List<leankor__ValueStream__c> updateValueStream(List<leankor__ValueStream__c> valueStreams) {
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior
    
        try { 
            DataBase.update(valueStreams);
        } catch(DmlException e) {
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        return valueStreams;
    }

    
	/*
	  Date :22/11/19
	  To Update valuestream.ScheduleRecalculate value.
	*/
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled
    global static Boolean updateScheduleRecalculate(List<leankor__ValueStream__c> valueStreams) {     
        for (leankor__ValueStream__c valueStream : valueStreams){
            if (String.isNotBlank(valueStream.Id) && (Util.getSObjectName(valueStream.Id) != 'leankor__ValueStream__c')) {
                throw new Util.LeanException('Error: Invalid input');
            }
        } 
        String kanbanVerb ='ScheduleRecalculate'; 
        Map<String,List<String>> broadcastContentMap =  new Map<String,List<String>>();
	    List<String> jsonDataList = new List<String>();
        List<String> vsList = new List<String>(); 
        
        //Check CRUD / FLC behavior
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        if (!valueStreamBehavior.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        try {                             
            DataBase.update(valueStreams);      
            for (leankor__ValueStream__c vs : valueStreams) {
            	if (vs.leankor__IsScheduleRecalculate__c) {           	
            		vsList.add(vs.id);
                	broadcastContentMap.put(vs.id,vsList);
            	}                
            }
            if (vsList.size()>0) {
        	    leankor.GenericStreamingController.sendBroadcastForBulkRecords(kanbanVerb, broadcastContentMap, UserInfo.getSessionId());       
            } 

        } catch (DmlException e) {
            throw new GanttTaskBoard.LeanException('ERROR:' + e.getMessage());
        }   

        return true;
    }
    
    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable = true)
    global static List<leankor__ValueStream__c> readValueStreams(String projectRoomId) {
        if (String.isNotBlank(projectRoomId) && (Util.getSObjectName(projectRoomId) != 'leankor__ProjectRoom__c')) {
            throw new Util.LeanException('Error: Invalid input');
        }
        try {
            return [Select  Id,
                            Name,
                            leankor__BoardType__c,
                            leankor__SevenDayWorkWeek__c,
                            leankor__IsTemplateBoard__c
                        From leankor__ValueStream__c
                        Where leankor__ProjectRoom__c =: projectRoomId
                            And leankor__isRecordDeleted__c = false
                        With Security_Enforced
                        Limit 50000];
        } catch (DmlException ex) {
            throw new GanttTaskBoard.LeanException('ERROR:' + ex.getMessage());
        }  
    }
}