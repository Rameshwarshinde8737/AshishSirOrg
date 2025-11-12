@isTest
private class MasterContainerTest {


	private static leankor__ValueStream__c createExpectedValueStream() {
		leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
		leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name='_System_Board',leankor__BoardType__c='Kanban Board');
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
		try{
		    Database.insert(vStream);
		}catch(DMLException ex){
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

	private static List<leankor__MasterContainer__c> createExpected() {
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

	private static List<leankor__MasterContainer__c> createActual() {
		leankor__ValueStream__c newValuestream = createActualValueStream();

		List<MasterContainer> newMasterContainers = new List<MasterContainer>();
		MasterContainer newMasterContainer = new MasterContainer();
		Integer masterContainerIndex = 0;

        for(String key : MasterContainer.MASTERCONTAINERS.keySet()) {
            newMasterContainer = new MasterContainer(newValuestream, MasterContainer.MASTERCONTAINERS.get(key), masterContainerIndex);
            newMasterContainers.add(newMasterContainer);
            masterContainerIndex++;
        }
		return MasterContainer.createMasterContainers(newMasterContainers);
	}

	@isTest static void createCompareName() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);
		}
	}
	
	@isTest static void createCompareUnit() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Unit__c, actual[i].leankor__Unit__c);
		}
	}

	@isTest static void createCompareCmpID() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__CmpID__c, actual[i].leankor__CmpID__c);
		}
	}

	@isTest static void createCompareNotEqualsGUID() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertNotEquals(expected[i].leankor__GUID__c, actual[i].leankor__GUID__c);
		}
	}

	@isTest static void createCompareHeight() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Height__c, actual[i].leankor__Height__c);
		}
	}

	@isTest static void createCompareIsCardAvailable() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__IsCardAvailable__c, actual[i].leankor__IsCardAvailable__c);
		}
	}

	@isTest static void createCompareLeft() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Left__c, actual[i].leankor__Left__c);
		}
	}

	@isTest static void createCompareLimit() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Limit__c, actual[i].leankor__Limit__c);
		}
	}

	@isTest static void createCompareOrder() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Order__c, actual[i].leankor__Order__c);
		}
	}

	@isTest static void createCompareTitle() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Title__c, actual[i].leankor__Title__c);
		}
	}

	@isTest static void createCompareTop() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Top__c, actual[i].leankor__Top__c);
		}
	}

	@isTest static void createCompareType() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Type__c, actual[i].leankor__Type__c);
		}
	}

	@isTest static void createCompareNotEqualsValueStream() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertNotEquals(expected[i].leankor__ValueStream__c, actual[i].leankor__ValueStream__c);
		}
	}

	@isTest static void createCompareWidth() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Width__c, actual[i].leankor__Width__c);
		}
	}

	@isTest static void createCompareId() {
		List<leankor__MasterContainer__c> expected = createExpected();
		List<leankor__MasterContainer__c> actual = createActual();
		for(Integer i; i < expected.size(); i++) {	
			System.assertEquals(expected[i].Id, actual[i].Id);
		}
	}

	@isTest static void readCompare() {
		List<leankor__MasterContainer__c> expected = createExpected();
		//System.assertEquals(KanbanController.getMasterContainer(expected[0].leankor__ValueStream__c), MasterContainer.readMasterContainers(expected[0].leankor__ValueStream__c));
	}

	private static List<leankor__MasterContainer__c> createExpectedClone() {
        List<leankor.KanbanController.MasterContainer> MContainers = new List<leankor.KanbanController.MasterContainer>();
		leankor.KanbanController.MasterContainer MC=new leankor.KanbanController.MasterContainer();
		List<leankor__MasterContainer__c> MasterContainers = new List<leankor__MasterContainer__c>();
		leankor__MasterContainer__c testData  = createExpected()[0];
		String testValueStreamId = createExpectedValueStream().id;
        MC.CmpID=testData.leankor__CmpID__c;
        MC.Color=testData.leankor__Color__c;
        MC.Unit=testData.leankor__Unit__c;
        MC.GUID =testData.Id+'-'+testValueStreamId+'-m';
        MC.Height=testData.leankor__Height__c;
        MC.Left=testData.leankor__Left__c;
        MC.Limits=testData.leankor__Limit__c;
        MC.Name=testData.Name;
        MC.Order=testData.leankor__Order__c;
        MC.Title=testData.leankor__Title__c;
        MC.Top=testData.leankor__Top__c;
        MC.Type=testData.leankor__Type__c;
        MC.ValueStreamID=testValueStreamId;
        MC.Width=testData.leankor__Width__c;
        MC.isCardAvailable=testData.leankor__IsCardAvailable__c;
        MContainers.add(MC);
        MasterContainers = leankor.KanbanController.createMasterContainer(MContainers);
        return MasterContainers;
    }

	private static List<leankor__MasterContainer__c> createActualClone() {
		List<leankor.MasterContainer> newMasterContainers = new List<leankor.MasterContainer>();  
		List<leankor__MasterContainer__c> serverMasterContainers = new List<leankor__MasterContainer__c>();
		leankor__MasterContainer__c testData  = createActual()[0];
		String testValueStreamId = createExpectedValueStream().id;
        leankor.MasterContainer localMasterContainer = new leankor.MasterContainer(testValueStreamId, testData);
        newMasterContainers.add(localMasterContainer);
        serverMasterContainers = leankor.MasterContainer.createMasterContainers(newMasterContainers); 
        //code coverage for  updateMasterContainers method. 
        //List<leankor__MasterContainer__c> MasterContainers =leankor.MasterContainer.updateMasterContainers(newMasterContainers);
        List<String> ids= new List<String>();
          for(leankor.MasterContainer mc:newMasterContainers){
          	 ids.add(mc.id);           
           }
         //String deletemastercontainer= leankor.MasterContainer.deleteMasterContainers(ids);
        return serverMasterContainers;
    }

	@isTest static void createCompareColorClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Color__c, actual[i].leankor__Color__c);
		}
	}

	@isTest static void createCompareNameClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);
		}
	}
	
	@isTest static void createCompareUnitClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Unit__c, actual[i].leankor__Unit__c);
		}
	}

	@isTest static void createCompareCmpIDClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__CmpID__c, actual[i].leankor__CmpID__c);
		}
	}

	@isTest static void createCompareNotEqualsGUIDClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertNotEquals(expected[i].leankor__GUID__c, actual[i].leankor__GUID__c);
		}
	}

	@isTest static void createCompareHeightClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Height__c, actual[i].leankor__Height__c);
		}
	}

	@isTest static void createCompareIsCardAvailableClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__IsCardAvailable__c, actual[i].leankor__IsCardAvailable__c);
		}
	}

	@isTest static void createCompareLeftClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Left__c, actual[i].leankor__Left__c);
		}
	}

	@isTest static void createCompareLimitClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Limit__c, actual[i].leankor__Limit__c);
		}
	}

	@isTest static void createCompareOrderClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Order__c, actual[i].leankor__Order__c);
		}
	}

	@isTest static void createCompareTitleClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Title__c, actual[i].leankor__Title__c);
		}
	}

	@isTest static void createCompareTopClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Top__c, actual[i].leankor__Top__c);
		}
	}

	@isTest static void createCompareTypeClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Type__c, actual[i].leankor__Type__c);
		}
	}

	@isTest static void createCompareNotEqualsValueStreamClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertNotEquals(expected[i].leankor__ValueStream__c, actual[i].leankor__ValueStream__c);
		}
	}

	@isTest static void createCompareWidthClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i = 0; i < expected.size(); i++) {	
			System.assertEquals(expected[i].leankor__Width__c, actual[i].leankor__Width__c);
		}
	}

	@isTest static void createCompareIdClone() {
		List<leankor__MasterContainer__c> expected = createExpectedClone();
		List<leankor__MasterContainer__c> actual = createActualClone();
		for(Integer i; i < expected.size(); i++) {	
			System.assertEquals(expected[i].Id, actual[i].Id);
		}
	}

  /*---------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getMasterContainer inside  MasterContainer Class
	------------------------------------------------------------------------------------*/ 
	@isTest 
	private static void getMasterContainerTemplateTest(){
		leankor__ValueStream__c newValuestream = createActualValueStream();
        leankor.MasterContainer.MasterContainerType masterContainerTypeRecord = MasterContainer.MasterContainerType.TEMPLATE;
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeTemplateRecord  = new MasterContainer(newValuestream,MasterContainerTypeRecord,index);
        System.assertEquals(masterContainerTypeTemplateRecord.title, null);
        Test.stopTest();
    }

    /*---------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getMasterContainer inside  MasterContainer Class
	------------------------------------------------------------------------------------*/ 
	@isTest 
	private static void getMasterContainerBacklogTest(){
		leankor__ValueStream__c newValuestream = createActualValueStream();
        leankor.MasterContainer.MasterContainerType masterContainerTypeRecord = MasterContainer.MasterContainerType.BACKLOG;
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeBacklogRecord  = new MasterContainer(newValuestream,MasterContainerTypeRecord,index);
        System.assertEquals(masterContainerTypeBacklogRecord.title, null);
        Test.stopTest();
    }

  	/*---------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getMasterContainer inside  MasterContainer Class
	------------------------------------------------------------------------------------*/  
	@isTest 
	private static void getMasterContainerInProgressTest(){
 		leankor__ValueStream__c newValuestream = createActualValueStream();
        leankor.MasterContainer.MasterContainerType masterContainerTypeRecord = MasterContainer.MasterContainerType.INPROGRESS;
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeInProgressRecord  = new MasterContainer(newValuestream,MasterContainerTypeRecord,index);
        System.assertEquals(masterContainerTypeInProgressRecord.title, null);
        Test.stopTest();
    }

   	/*---------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getMasterContainer inside  MasterContainer Class
	------------------------------------------------------------------------------------*/  
	@isTest 
	private static void getMasterContainerReviewAndApproveTest(){
 		leankor__ValueStream__c newValuestream = createActualValueStream();
        leankor.MasterContainer.MasterContainerType masterContainerTypeRecord = MasterContainer.MasterContainerType.REVIEWANDAPPROVE;
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeReviewAndApproveRecord  = new MasterContainer(newValuestream,MasterContainerTypeRecord,index);
        System.assertEquals(masterContainerTypeReviewAndApproveRecord.title, null);
        Test.stopTest();
    }

  	/*---------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getMasterContainer inside  MasterContainer Class
	------------------------------------------------------------------------------------*/  
	@isTest 
	private static void getMasterContainerDoneTest(){
 		leankor__ValueStream__c newValuestream = createActualValueStream();
        leankor.MasterContainer.MasterContainerType masterContainerTypeRecord = MasterContainer.MasterContainerType.DONE;
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeDoneRecord  = new MasterContainer(newValuestream,MasterContainerTypeRecord,index);
        System.assertEquals(masterContainerTypeDoneRecord.title, null);
        Test.stopTest();
    }

	/*---------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getMasterContainer inside  MasterContainer Class
	------------------------------------------------------------------------------------*/  
	@isTest 
	private static void getMasterContainerArchiveTest(){
 		leankor__ValueStream__c newValuestream = createActualValueStream();
        leankor.MasterContainer.MasterContainerType masterContainerTypeRecord = MasterContainer.MasterContainerType.ARCHIVE;
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeArchiveRecord  = new MasterContainer(newValuestream,MasterContainerTypeRecord,index);
        System.assertEquals(masterContainerTypeArchiveRecord.title, null);
        Test.stopTest();
    }

  	/*---------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getMasterContainer inside  MasterContainer Class
	------------------------------------------------------------------------------------*/  
	@isTest 
	private static void getMasterContainerOneTest(){
 		leankor__ValueStream__c newValuestream = createActualValueStream();
        leankor.MasterContainer.MasterContainerType masterContainerType; 
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeRecord  = new MasterContainer(newValuestream,masterContainerType,index);
        System.assertEquals(masterContainerTypeRecord.title, null);
        Test.stopTest();
    }

 	/*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover MasterContainer[CONSTRUCTOR] inside  MasterContainer Class
	----------------------------------------------------------------------------------------------------------*/ 
	@isTest 
	private static void masterContainerTest(){
 		leankor__ValueStream__c newValuestream = createActualValueStream();
		List<leankor__MasterContainer__c> expected = createExpected();
		leankor__MasterContainer__c masterContainer = new leankor__MasterContainer__c(); 
		for(leankor__MasterContainer__c masterContainerList :expected){
			masterContainer.id=masterContainerList.id;
		}
        Integer index = 0;
        Test.startTest();
        leankor.MasterContainer  masterContainerTypeRecord  = new MasterContainer(newValuestream,masterContainer,index);
        System.assertEquals(masterContainerTypeRecord.title, null);
        Test.stopTest();
    }

	/*---------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover deleteMasterContainers inside  MasterContainer Class
	------------------------------------------------------------------------------------*/ 
	/*
	@isTest 
	private static void deleteMasterContainersTest(){
 		leankor__ValueStream__c newValuestream = createActualValueStream();
		List<leankor__MasterContainer__c> expected = createExpected();
		List<String> ids= new List<String>();
		for( leankor__MasterContainer__c mc:expected){
			ids.add(mc.id);           
		}
	 	Test.startTest();
		String deletemastercontainer = leankor.MasterContainer.deleteMasterContainers(ids);
		System.assertEquals(deletemastercontainer, 'success');
		Test.stopTest();
    }
	*/
}