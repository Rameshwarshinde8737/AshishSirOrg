@isTest
private class SwimlaneTest {

	/*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is for setup the testData
	----------------------------------------------------------------------------------------------------------*/ 
	@testSetup
	private static void testData(){
	
		leankor__projectroom__c projectRecord  = new leankor__projectroom__c();
        projectRecord.Name ='test';
		insert projectRecord;
		
		leankor__Valuestream__c valueStreamRecord  = new leankor__Valuestream__c();
        valueStreamRecord.Name = 'Testing board';
        valueStreamRecord.leankor__IsScheduleRecalculate__c= false; 
        valueStreamRecord.leankor__projectroom__c = projectRecord.id;
        valueStreamRecord.leankor__BoardType__c = 'Kanban Board';
		insert valueStreamRecord;
		
		leankor__mastercontainer__c mastercontainerRecord = new leankor__mastercontainer__c();
		mastercontainerRecord.Name = 'Test MC';
		mastercontainerRecord.leankor__Valuestream__c = valueStreamRecord.id;
		mastercontainerRecord.leankor__GUID__c = valueStreamRecord.id+'-'+System.now().getTime()+'-mc00';
		mastercontainerRecord.leankor__Title__c = 'Template';
		mastercontainerRecord.leankor__Type__c = 'Template';
		mastercontainerRecord.leankor__Width__c = 210;
		insert mastercontainerRecord;
		
		leankor__swimlane__c  swimlaneRecord  = new  leankor__swimlane__c();
		swimlaneRecord.name = 'Test SW';
		swimlaneRecord.leankor__mastercontainer__c = mastercontainerRecord.id;
		swimlaneRecord.leankor__Valuestream__c = valueStreamRecord.id;
		swimlaneRecord.leankor__Title__c = 'Default Swimlane';
		swimlaneRecord.leankor__Width__c = 210;
		insert swimlaneRecord;  
	}

	private static leankor__ValueStream__c createExpectedValueStream() {
		leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
		leankor__ValueStream__c vStream=new leankor__ValueStream__c();
		vStream.Name='_System_Board';
		vStream.leankor__BoardType__c='Kanban Board';

		vStream.leankor__SprintStartDate__c = null;
		vStream.leankor__PointPicklist__c = ((leanConstant.leankor__PointSequence__c==null || leanConstant.leankor__PointSequence__c=='') ? '[]' :leanConstant.leankor__PointSequence__c);
		vStream.leankor__DaysPerSprint__c = null;
		vStream.leankor__IsAgile__c = false;
		vStream.leankor__Effortindicator__c = 'Days';
		vStream.leankor__TaskDateCheck__c =(!leanConstant.leankor__AvoidTaskDueDateCheck__c) ;
		vStream.leankor__DefaultCategory__c = null;
		vStream.leankor__DisableCalendarView__c = false;
		vStream.leankor__IsTemplateBoard__c = false;
		vStream.leankor__PortfolioMode__c = false;
		vStream.leankor__DisableTaskAsMiniature__c = false;
		vStream.leankor__SevenDayWorkWeek__c =false;
		vStream.leankor__DefaultOwnerID__c = userinfo.getuserID();
		try {
	    	Database.insert(vStream);
		} catch (DMLException ex) {
		    System.debug('Error : '+ex.getMessage());
		}
		return vStream;
	}

	private static leankor__ValueStream__c createActualValueStream() {
		List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
		vsList.add(new ValueStream(ValueStream.KANBAN_BOARD).valueStream);
		
		List<leankor__ValueStream__c> result = leankor.ValueStream.createValueStream(vsList);
		leankor__ValueStream__c valueStreams = result.size() > 0 ? result[0] : new leankor__ValueStream__c();

		return valueStreams;
	}	

	private static List<leankor__MasterContainer__c> createExpectedMasterContainers() {
		leankor__ValueStream__c newValueStream = createExpectedValueStream();
		
		List<KanbanController.MasterContainer> oldMasterContainers = new List<KanbanController.MasterContainer>();
		
		for (Integer i = 0; i < 6; i++) {
			KanbanController.MasterContainer MC=new KanbanController.MasterContainer();
			MC.CmpID='ext-masterContainer-'+i;
			MC.Color=(i==0?'#DBDB12':(i==1?'#A0A0A0':(i==2?'#6666FF':(i==3?'#FF8000':(i==4?'#66CC00':'#808080')))));
			MC.GUID =newValueStream.id+'-'+System.now().getTime()+'-mc00'+i;
			MC.Height=352; //670;
			MC.Left=2080;
			MC.Limits=0;
			MC.Name=(i==0?'Template':(i==1?'Backlog':(i==2?'In Progress':(i==3?'Review & Approve':(i==4?'Done':'Archive')))));
			MC.Order=i;
			MC.Title=(i==0?'Template':(i==1?'Backlog':(i==2?'In Progress':(i==3?'Review & Approve':(i==4?'Done':'Archive')))));
			MC.Top=2010;
			MC.Type=(i==0?'Template':(i==1?'Backlog':(i==2||i==3 ||i==4?'Regular':(i==5?'Archive':'Regular'))));
			MC.ValueStreamID=newValueStream.id;
			MC.Width=210;//(i==0? 210 :(i==1? 420 :(i==2? 420 :(i==3? 210 : 210 )))); //420;
			MC.isCardAvailable=false;
			oldMasterContainers.add(MC);
		}
		return KanbanController.createMasterContainer(oldMasterContainers);
	}
	
	private static List<leankor__MasterContainer__c> createActualMasterContainers() {
		leankor__ValueStream__c newValuestream = createActualValueStream();
		List<MasterContainer> newMasterContainers = new List<MasterContainer>();
		MasterContainer newMasterContainer;
		Integer masterContainerIndex = 0;
       	for (String key : MasterContainer.MASTERCONTAINERS.keySet()) {
            newMasterContainer = new MasterContainer(newValuestream, MasterContainer.MASTERCONTAINERS.get(key), masterContainerIndex);
            newMasterContainers.add(newMasterContainer);
            masterContainerIndex++;
        }
		return MasterContainer.createMasterContainers(newMasterContainers);
	}

	private static List<leankor__Swimlane__c> createExpected() {
		List<leankor__MasterContainer__c> MasterContainers=createExpectedMasterContainers();
		List<KanbanController.Swimlane> Swims=new List<KanbanController.Swimlane>();
		List<leankor__Swimlane__c> Swimlanes=new List<leankor__Swimlane__c>();
		Integer j=0;
		for (leankor__MasterContainer__c m :MasterContainers) {
		    KanbanController.Swimlane s=new KanbanController.Swimlane();
		    s.CardPerRow =1;
		    s.CmpID='ext-swimlaneContainer-'+j;
		    s.Color='#4183D7';
		    s.GUID=MasterContainers[j].leankor__ValueStream__c+'-'+System.now().getTime()+'-sl00'+j;
		    s.Height=320;
		    s.Help='';
		    s.Left=2100;
		    s.Limits=0;
		    s.MasterContainer = m.Id;
		    s.Name='Default Swimlane';
		    s.Order=0;
		    s.Title='Default Swimlane';
		    s.Top=2100;
		    s.ValueStreamID=MasterContainers[j].leankor__ValueStream__c;
		    s.Width=(m.leankor__width__c == 210 ? 209: 418);//418;
		    s.isCardAvailable = false;
		    Swims.add(s);
		    j++;
		}
		Swimlanes = KanbanController.createSwimlane(Swims);
		return Swimlanes;
	}
	
	private static List<leankor__Swimlane__c> createActual() {
		List<leankor__MasterContainer__c> masterContainers = createActualMasterContainers();
		List<Swimlane> newSwimlanes = new List<Swimlane>();
		Swimlane newSwimlane;
		Integer swimlaneIndex = 0;
		Swimlane swimlaneType;
		for (leankor__MasterContainer__c masterContainer : masterContainers) {
			if (swimlaneIndex !=2) {
				swimlaneType = Swimlane.STANDARD;
			} else {
				swimlaneType = Swimlane.INPROGRESS;
			}
			newSwimlane = new Swimlane(masterContainer, swimlaneType, swimlaneIndex);
			newSwimlanes.add(newSwimlane);
			swimlaneIndex++;
		}
		return Swimlane.createSwimlanes(newSwimlanes);
	}

	@isTest 
	static void createCompareName() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();

		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);	
		}
	}

	@isTest 
	static void createCompareCardPerRow() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CardPerRow__c, actual[i].leankor__CardPerRow__c);	
		}
	}

	@isTest 
	static void createCompareCmpID() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CmpID__c, actual[i].leankor__CmpID__c);	
		}
	}

	@isTest 
	static void createCompareUnit() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Unit__c, actual[i].leankor__Unit__c);	
		}
	}

	@isTest 
	static void createCompareColor() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Color__c, actual[i].leankor__Color__c);	
		}
	}
	
	@isTest 
	static void createCompareNotEqualsGUID() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__GUID__c, actual[i].leankor__GUID__c);	
		}
	}

	@isTest 
	static void createCompareHeight() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Height__c, actual[i].leankor__Height__c);	
		}
	}

	@isTest 
	static void createCompareHelp() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Help__c, actual[i].leankor__Help__c);	
		}
	}

	@isTest 
	static void createCompareIsCardAvailable() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__IsCardAvailable__c, actual[i].leankor__IsCardAvailable__c);	
		}
	}

	@isTest 
	static void createCompareLeft() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Left__c, actual[i].leankor__Left__c);	
		}
	}

	@isTest 
	static void createCompareLimit() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Limit__c, actual[i].leankor__Limit__c);	
		}
	}

	@isTest 
	static void createCompareNotEqualsMasterContainer() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__MasterContainer__c, actual[i].leankor__MasterContainer__c);	
		}
	}

	@isTest 
	static void createCompareOrder() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Order__c, actual[i].leankor__Order__c);	
		}
	}

	@isTest 
	static void createCompareTitle() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Title__c, actual[i].leankor__Title__c);	
		}
	}

	@isTest 
	static void createCompareTop() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Top__c, actual[i].leankor__Top__c);	
		}
	}

	@isTest 
	static void createCompareNotEqualsValueStream() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__ValueStream__c, actual[i].leankor__ValueStream__c);	
		}
	}

	@isTest 
	static void createCompareWidth() {
		List<leankor__Swimlane__c> expected = createExpected();
		List<leankor__Swimlane__c> actual = createActual();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Width__c, actual[i].leankor__Width__c);	
		}
	}

	private static List<leankor__Swimlane__c> createExpectedClone() {
		List<leankor.KanbanController.Swimlane> Swims = new List<leankor.KanbanController.Swimlane>();
		List<leankor__Swimlane__c> Swimlanes = new List<leankor__Swimlane__c>();
		String testValueStreamId = createExpectedValueStream().id;
		String testMasterContainerId = createExpectedMasterContainers()[0].id;
		leankor__Swimlane__c testSwimlane = createExpected()[0];

		leankor.KanbanController.Swimlane s=new leankor.KanbanController.Swimlane();
        s.CardPerRow =testSwimlane.leankor__CardPerRow__c;
        s.CmpID=testSwimlane.leankor__CmpID__c;
        s.Color=testSwimlane.leankor__Color__c;
        s.Unit=testSwimlane.leankor__Unit__c;
        s.GUID=testSwimlane.Id+'-'+testMasterContainerId+'-s';
        s.Height=testSwimlane.leankor__Height__c;
        s.Help=testSwimlane.leankor__Help__c;
        s.Left=testSwimlane.leankor__Left__c;
        s.Limits=testSwimlane.leankor__Limit__c;
        s.MasterContainer =testMasterContainerId;
        s.Name=testSwimlane.Name;
        s.Order=testSwimlane.leankor__Order__c;
        s.Title=testSwimlane.leankor__Title__c;
        s.Top=testSwimlane.leankor__Top__c;
        s.ValueStreamID=testValueStreamId;
        s.Width=testSwimlane.leankor__Width__c;
        s.isCardAvailable = testSwimlane.leankor__IsCardAvailable__c;
        Swims.add(s);

        Swimlanes = leankor.KanbanController.createSwimlane(Swims);

		return Swimlanes;
	}
	
	private static List<leankor__Swimlane__c> createActualClone() {
		List<leankor.Swimlane> newSwimlanes = new List<leankor.Swimlane>();
		List<leankor__Swimlane__c> serverSwimlanes = new List<leankor__Swimlane__c>();
		String testValueStreamId = createActualValueStream().id;
		String testMasterContainerId = createActualMasterContainers()[0].id;
		leankor__Swimlane__c testSwimlane = createActual()[0];

        leankor.Swimlane localSwimlane = new leankor.Swimlane(testValueStreamId, testMasterContainerId, testSwimlane);
        newSwimlanes.add(localSwimlane);

        serverSwimlanes = leankor.Swimlane.createSwimlanes(newSwimlanes);

		return serverSwimlanes;
	}

	@isTest 
	static void createCompareNameClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();

		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);	
		}
	}

	@isTest 
	static void createCompareCardPerRowClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CardPerRow__c, actual[i].leankor__CardPerRow__c);	
		}
	}

	@isTest 
	static void createCompareCmpIDClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CmpID__c, actual[i].leankor__CmpID__c);	
		}
	}

	@isTest 
	static void createCompareUnitClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Unit__c, actual[i].leankor__Unit__c);	
		}
	}

	@isTest 
	static void createCompareColorClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Color__c, actual[i].leankor__Color__c);	
		}
	}
	
	@isTest 
	static void createCompareNotEqualsGUIDClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__GUID__c, actual[i].leankor__GUID__c);	
		}
	}

	@isTest 
	static void createCompareHeightClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Height__c, actual[i].leankor__Height__c);	
		}
	}

	@isTest 
	static void createCompareHelpClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Help__c, actual[i].leankor__Help__c);	
		}
	}

	@isTest 
	static void createCompareIsCardAvailableClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__IsCardAvailable__c, actual[i].leankor__IsCardAvailable__c);	
		}
	}

	@isTest 
	static void createCompareLeftClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Left__c, actual[i].leankor__Left__c);	
		}
	}

	@isTest 
	static void createCompareLimitClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Limit__c, actual[i].leankor__Limit__c);	
		}
	}

	@isTest 
	static void createCompareNotEqualsMasterContainerClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__MasterContainer__c, actual[i].leankor__MasterContainer__c);	
		}
	}

	@isTest 
	static void createCompareOrderClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Order__c, actual[i].leankor__Order__c);	
		}
	}

	@isTest 
	static void createCompareTitleClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Title__c, actual[i].leankor__Title__c);	
		}
	}

	@isTest 
	static void createCompareTopClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Top__c, actual[i].leankor__Top__c);	
		}
	}

	@isTest 
	static void createCompareNotEqualsValueStreamClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__ValueStream__c, actual[i].leankor__ValueStream__c);	
		}
	}

	@isTest 
	static void createCompareWidthClone() {
		List<leankor__Swimlane__c> expected = createExpectedClone();
		List<leankor__Swimlane__c> actual = createActualClone();
		for (Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Width__c, actual[i].leankor__Width__c);	
		}
	}
	
    /*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover Swimlane[CONSTRUCTOR] Method inside  ResourceType Class
	----------------------------------------------------------------------------------------------------------*/ 
    
    @isTest static void getSwimlaneStandardTest(){
        
        leankor__mastercontainer__c masterContainerRecord = [Select Id, 
                                                                    leankor__ValueStream__c,
                                                                    leankor__Width__c   
                                                               From leankor__MasterContainer__c
                                                               Where Name = 'Test MC'];
        
        leankor.Swimlane.SwimlaneType swimlaneTypeStandardRecord = Swimlane.SwimlaneType.STANDARD;
        Integer swimlaneIndex = 0;
        
        Test.startTest();
        
        leankor.Swimlane  swimlaneStandardRecord = new Swimlane(masterContainerRecord,swimlaneTypeStandardRecord,swimlaneIndex);
        System.assertEquals(swimlaneStandardRecord.title, 'Default Swimlane');
        
        Test.stopTest();
        
    }
    
    /*---------------------------------------------------------------------------------------------------------
Company     : Leankor
Description : This method is cover Swimlane[CONSTRUCTOR] Method inside  ResourceType Class
----------------------------------------------------------------------------------------------------------*/ 
    
    @isTest static void getSwimlaneInprogressTest(){
        
        leankor__mastercontainer__c masterContainerRecord = [Select Id, 
                                                                    leankor__ValueStream__c,
                                                                    leankor__Width__c   
                                                                From leankor__MasterContainer__c
                                                                Where Name = 'Test MC'];
        
        
        leankor.Swimlane.SwimlaneType swimlaneTypeInprogressRecord = Swimlane.SwimlaneType.INPROGRESS;
        Integer swimlaneIndex = 0;
        
        Test.startTest();
        
        leankor.Swimlane  swimlaneInprogressRecord = new Swimlane(masterContainerRecord,swimlaneTypeInprogressRecord,swimlaneIndex);
        System.assertEquals(swimlaneInprogressRecord.title, 'Default Swimlane');
        
        Test.stopTest();
        
    }
    
    /*---------------------------------------------------------------------------------------------------------
Company     : Leankor
Description : This method is cover Swimlane[CONSTRUCTOR] Method inside  ResourceType Class
----------------------------------------------------------------------------------------------------------*/ 
    
    @isTest static void swimlaneTest(){
        
        leankor__mastercontainer__c masterContainerRecord = [Select Id, 
                                                                    leankor__ValueStream__c,
                                                                    leankor__Width__c   
                                                                From leankor__MasterContainer__c
                                                                Where Name = 'Test MC'];
        
        leankor.Swimlane.SwimlaneType swimlaneTypeRecords;
        Integer swimlaneIndex = 0;
        
        Test.startTest();
        
        leankor.Swimlane  swimlaneRecord = new Swimlane(masterContainerRecord,swimlaneTypeRecords,swimlaneIndex);
        System.assertEquals(swimlaneRecord.title, 'Default Swimlane');
        
        Test.stopTest();
        
    }
    
    /*---------------------------------------------------------------------------------------------------------
Company     : Leankor
Description : This method is cover InProgressSwimlane Subclass inside ResourceType Class
----------------------------------------------------------------------------------------------------------*/ 
    @isTest static void inProgressSwimlaneTest(){
        
        leankor__mastercontainer__c masterContainerRecord = [Select Id, 
                                                                    leankor__ValueStream__c,
                                                                    leankor__Width__c   
                                                                From leankor__MasterContainer__c
                                                                Where Name = 'Test MC'];
        Integer index = 0;
        
        Test.startTest();

        leankor.Swimlane.InProgressSwimlane inProgressSwimlaneRecord = new leankor.Swimlane.InProgressSwimlane(masterContainerRecord,index);
        System.assertEquals(inProgressSwimlaneRecord.title,'Default Swimlane');

        Test.stopTest();
    }
    
    @isTest
    static void testCreateSwimlanes_NoAccessException() {
        Profile p = [Select Id 
                        From Profile 
                        Where Name='Standard User'];
                        
        User u1 = new User();
        u1.Alias = 'leankor1';
        u1.Email='leankor1@leankor.com';
        u1.EmailEncodingKey='UTF-8'; 
        u1.LastName='Leankor1'; 
        u1.LanguageLocaleKey='en_US';
        u1.LocaleSidKey='en_US'; 
        u1.ProfileId = p.Id;
        u1.TimeZoneSidKey='America/Los_Angeles'; 
        u1.UserName='leankor1@leankor.com';
        insert u1;
        
        Test.startTest();
        try {
            System.runAs(u1) {
                Swimlane swim = new Swimlane();
                Swimlane.createSwimlanes(new List<Swimlane>{swim});
        	}
            
            System.assert(false, 'Exception should have been thrown');
        } catch (Util.LeanException e) {
            System.assertEquals('Error: No access to records', e.getMessage(), 'Expected access error');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateSwimlanes_InsertException() {
        Test.startTest();
        try {
            Swimlane.createSwimlanes(new List<Swimlane> {null});
            
            System.assert(false, 'Exception should have been thrown');
        } catch (Util.LeanException e) {
            System.assert(e.getMessage().startsWith('ERROR:'), 'Expected error handling message');
        }
        Test.stopTest();
    }
}