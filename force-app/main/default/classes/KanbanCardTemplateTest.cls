@isTest
private class KanbanCardTemplateTest {

	private static leankor__ValueStream__c createExpectedValueStream() {
		leankor__LeanConstants__c leanConstant=leankor__LeanConstants__c.getInstance();
		leankor__ValueStream__c vStream=new leankor__ValueStream__c(Name ='_System_Board',leankor__BoardType__c ='Kanban Board');
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

	private static List<leankor__KanbanCardTemplate__c> createExpected() {
		List<leankor__KanbanCardTemplate__c> ListKct = new List<leankor__KanbanCardTemplate__c>();
   		/*for(integer i=0 ; i <=5 ;i++){
            leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
            leankor__JSONDefinition__c = '',
            leankor__JSONData__c = '',
            leankor__Width__c = 170,
            leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
            leankor__CSSLayout__c = '',
            leankor__Color__c = '#bdbffc',
            leankor__ValueStream__c = createExpectedValueStream().id
            );
            kct.Name = (i==0 ?'Default' :(i==1 ? 'HR' :(i==2?'Sales' :(i==3?'Marketing' :(i==4 ? 'Finance': 'Operations')))));
            kct.leankor__Title__c =kct.Name;
            ListKct.add(kct);
        }*/

		leankor__KanbanCardTemplate__c kct = new leankor__KanbanCardTemplate__c(
            leankor__JSONDefinition__c = '',
            leankor__JSONData__c = '',
            leankor__Width__c = 170,
            leankor__Height__c =120, // (projectBoard.leankor__BoardType__c == 'Whiteboard' ? 120 : 85),
            leankor__CSSLayout__c = '',
            leankor__Color__c = '#bdbffc',
            leankor__ValueStream__c = createExpectedValueStream().id,
			Name = 'Default',
			leankor__Title__c = 'Default'
		);
		ListKct.add(kct);
        try{
            DataBase.Insert(ListKct);
        }catch(DmlException e){
            System.debug(e.getMessage());
        }
        return ListKct;
	}

	private static List<leankor__KanbanCardTemplate__c> createActual() {
      	KanbanCardTemplate newKanbanCardTemplate = new KanbanCardTemplate();
      	List<KanbanCardTemplate> newKanbanCardTemplates = new List<KanbanCardTemplate>();
        for(String key : KanbanCardTemplate.KANBANCARD_TEMPLATES.keySet()) {
            newKanbanCardTemplate = new KanbanCardTemplate(createActualValueStream(), KanbanCardTemplate.KANBANCARD_TEMPLATES.get(key));
            newKanbanCardTemplate.setKanbanBoardKanbanCardTemplate(newKanbanCardTemplate);
            newKanbanCardTemplates.add(newKanbanCardTemplate);
        }
        return KanbanCardTemplate.createKanbanCardTemplates(newKanbanCardTemplates);
	}

	@isTest static void createCompareNotEqualsId() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].id, actual[i].id);	
		}
	}

	@isTest static void createCompareName() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);	
		}
	}

	@isTest static void createCompareTitle() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Title__c, actual[i].leankor__Title__c);	
		}
	}

	@isTest static void createCompareJSONDefinition() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__JSONDefinition__c, actual[i].leankor__JSONDefinition__c);	
		}
	}

	@isTest static void createCompareJSONData() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__JSONData__c, actual[i].leankor__JSONData__c);	
		}
	}

	@isTest static void createCompareWidth() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Width__c, actual[i].leankor__Width__c);	
		}
	}

	@isTest static void createCompareHeight() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Height__c, actual[i].leankor__Height__c);	
		}
	}

	@isTest static void createCompareCSSLayout() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CSSLayout__c, actual[i].leankor__CSSLayout__c);	
		}
	}

	@isTest static void createCompareColor() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Color__c, actual[i].leankor__Color__c);	
		}
	}

	@isTest static void createCompareNotEqualsValueStream() {
		List<leankor__KanbanCardTemplate__c> expected = createExpected();
		List<leankor__KanbanCardTemplate__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__ValueStream__c, actual[i].leankor__ValueStream__c);	
		}
	}

	private static List<leankor__KanbanCardTemplate__c> createExpectedClone() {
        leankor__KanbanCardTemplate__c testKanbanCardTemplate = createExpected()[0];
        List<leankor__KanbanCardTemplate__C> cloneTemplates = new List<leankor__KanbanCardTemplate__C>();
        String testValueStreamId = createActualValueStream().id;
        leankor__KanbanCardTemplate__C template = new leankor__KanbanCardTemplate__C(
            leankor__Color__c = testKanbanCardTemplate.leankor__Color__c, 
            leankor__CSSLayout__c = testKanbanCardTemplate.leankor__CSSLayout__c, 
            leankor__DerivedFrom__c = null, 
            leankor__Height__c = testKanbanCardTemplate.leankor__Height__c, 
            leankor__JSONData__c = testKanbanCardTemplate.leankor__JSONData__c, 
            leankor__JSONDefinition__c = testKanbanCardTemplate.leankor__JSONDefinition__c, 
            leankor__Title__c = testKanbanCardTemplate.Id,
            leankor__ValueStream__c = testValueStreamId, 
            leankor__Width__c = testKanbanCardTemplate.leankor__Width__c, 
            Name = testKanbanCardTemplate.Name,                         
            OwnerId = UserInfo.getUserId(),
            leankor__FieldSetName__c = testKanbanCardTemplate.leankor__FieldSetName__c
        );                
        cloneTemplates.add(template);
        DataBase.Insert(cloneTemplates, true);
        return cloneTemplates;
	}

	private static List<leankor__KanbanCardTemplate__c> createActualClone() {
		List<leankor__KanbanCardTemplate__C> cloneTemplates = new List<leankor__KanbanCardTemplate__C>();
		leankor__KanbanCardTemplate__c testKanbanCardTemplate = createActual()[0];
		String testValueStreamId = createActualValueStream().id;
		String newOwnerId;
        newOwnerId = UserInfo.getUserId();
        leankor.KanbanCardTemplate localKanbanCardTemplate = new leankor.KanbanCardTemplate(testValueStreamId, newOwnerId, testKanbanCardTemplate);
        localKanbanCardTemplate.setKanbanCardTemplate(localKanbanCardTemplate);               
        cloneTemplates.add(localKanbanCardTemplate.kanbanCardTemplate);
	    DataBase.Insert(cloneTemplates, true);
	    return cloneTemplates;
	}

	@isTest static void createCompareNotEqualsIdClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].id, actual[i].id);	
		}
	}

	@isTest static void createCompareNameClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);	
		}
	}

	@isTest static void createCompareNotEqualsTitleClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__Title__c, actual[i].leankor__Title__c);	
		}
	}

	@isTest static void createCompareJSONDefinitionClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__JSONDefinition__c, actual[i].leankor__JSONDefinition__c);	
		}
	}

	@isTest static void createCompareJSONDataClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__JSONData__c, actual[i].leankor__JSONData__c);	
		}
	}

	@isTest static void createCompareWidthClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Width__c, actual[i].leankor__Width__c);	
		}
	}

	@isTest static void createCompareHeightClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Height__c, actual[i].leankor__Height__c);	
		}
	}

	@isTest static void createCompareCSSLayoutClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CSSLayout__c, actual[i].leankor__CSSLayout__c);	
		}
	}

	@isTest static void createCompareColorClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Color__c, actual[i].leankor__Color__c);	
		}
	}

	@isTest static void createCompareNotEqualsValueStreamClone() {
		List<leankor__KanbanCardTemplate__c> expected = createExpectedClone();
		List<leankor__KanbanCardTemplate__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__ValueStream__c, actual[i].leankor__ValueStream__c);	
		}
	}

    /*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method allKanbanCardTemplateTest is cover all inner classs inside KanbanCardTemplate Class 
	----------------------------------------------------------------------------------------------------------*/ 
    @isTest
    private static void allKanbanCardTemplateTest(){
        
        leankor__ValueStream__c valueStreamRecord = createExpectedValueStream();
        
        leankor.KanbanCardTemplate.StandardKanbanCardTemplate standardKanbanCardTemplateRecord = new leankor.KanbanCardTemplate.StandardKanbanCardTemplate(valueStreamRecord);
        System.assertEquals(standardKanbanCardTemplateRecord.title, 'Default');
    
        leankor.KanbanCardTemplate.HrKanbanCardTemplate hrKanbanCardTemplateRecord = new leankor.KanbanCardTemplate.HrKanbanCardTemplate(valueStreamRecord);
        System.assertEquals(hrKanbanCardTemplateRecord.title, 'HR');
        
        leankor.KanbanCardTemplate.SalesKanbanCardTemplate salesKanbanCardTemplateRecord = new leankor.KanbanCardTemplate.SalesKanbanCardTemplate(valueStreamRecord);
        System.assertEquals(salesKanbanCardTemplateRecord.title,'Sales');
        
        leankor.KanbanCardTemplate.MarketingKanbanCardTemplate marketingKanbanCardTemplateRecord = new leankor.KanbanCardTemplate.MarketingKanbanCardTemplate(valueStreamRecord); 
        System.assertEquals(marketingKanbanCardTemplateRecord.title,'Marketing');
        
        leankor.KanbanCardTemplate.FinanceKanbanCardTemplate financeKanbanCardTemplateRecord = new leankor.KanbanCardTemplate.FinanceKanbanCardTemplate(valueStreamRecord); 
        System.assertEquals(financeKanbanCardTemplateRecord.title,'Finance');
        
        leankor.KanbanCardTemplate.OperationsKanbanCardTemplate operationsKanbanCardTemplateRecord = new leankor.KanbanCardTemplate.OperationsKanbanCardTemplate(valueStreamRecord);        
        System.assertEquals(operationsKanbanCardTemplateRecord.title,'Operations');
	}
    
	/*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getKanbanCardTemplate method inside KanbanCardTemplate Class
	----------------------------------------------------------------------------------------------------------*/ 
    @isTest 
    private static void getKanbanCardTemplateStandardTest(){
        leankor__ValueStream__c valueStreamRecord = createExpectedValueStream();
        leankor.KanbanCardTemplate.KanbanCardTemplateType standardRecord = KanbanCardTemplate.KanbanCardTemplateType.STANDARD;
        leankor.KanbanCardTemplate kanbanCardTemplateRecord = new leankor.KanbanCardTemplate();
        leankor.KanbanCardTemplate kanbanCardTemplateStandardRecords = new KanbanCardTemplate(valueStreamRecord,standardRecord); 
        leankor.KanbanCardTemplate kanbanCardTemplateStandardRecord = KanbanCardTemplateRecord.getKanbanCardTemplate(valueStreamRecord,standardRecord);
        System.assertEquals(kanbanCardTemplateStandardRecord.title, 'Default');
    }
    
	/*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getKanbanCardTemplate method inside KanbanCardTemplate Class
	----------------------------------------------------------------------------------------------------------*/ 
    @isTest  
    private static void getKanbanCardTemplateHRTest(){
        leankor__ValueStream__c valueStreamRecord = createExpectedValueStream();
        leankor.KanbanCardTemplate.KanbanCardTemplateType hrRecord = KanbanCardTemplate.KanbanCardTemplateType.HR;
        leankor.KanbanCardTemplate kanbanCardTemplateRecord = new leankor.KanbanCardTemplate();
        leankor.KanbanCardTemplate kanbanCardTemplateHrRecord = kanbanCardTemplateRecord.getKanbanCardTemplate(valueStreamRecord,hrRecord);
        System.assertEquals(kanbanCardTemplateHrRecord.title, 'HR');
    }
    
	/*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getKanbanCardTemplate method inside KanbanCardTemplate Class
	----------------------------------------------------------------------------------------------------------*/ 
    @isTest  
    private static void getKanbanCardTemplateSalesTest(){
        leankor__ValueStream__c valueStreamRecord = createExpectedValueStream();
        leankor.KanbanCardTemplate.KanbanCardTemplateType salesRecord = KanbanCardTemplate.KanbanCardTemplateType.SALES;
        leankor.KanbanCardTemplate kanbanCardTemplateRecord = new leankor.KanbanCardTemplate();
        leankor.KanbanCardTemplate kanbanCardTemplateSalesRecord = kanbanCardTemplateRecord.getKanbanCardTemplate(valueStreamRecord,salesRecord); 
        System.assertEquals(kanbanCardTemplateSalesRecord.title,'Sales');
    }
    
	/*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getKanbanCardTemplate method inside KanbanCardTemplate Class
	----------------------------------------------------------------------------------------------------------*/ 
    @isTest  
    private static void getKanbanCardTemplateMarketingTest(){
        leankor__ValueStream__c valueStreamRecord = createExpectedValueStream();
        leankor.KanbanCardTemplate.KanbanCardTemplateType marketingRecord = KanbanCardTemplate.KanbanCardTemplateType.MARKETING;
        leankor.KanbanCardTemplate kanbanCardTemplateRecord = new leankor.KanbanCardTemplate();
        leankor.KanbanCardTemplate kanbanCardTemplateMarketingRecord = kanbanCardTemplateRecord.getKanbanCardTemplate(valueStreamRecord,marketingRecord); 
        System.assertEquals(kanbanCardTemplateMarketingRecord.title,'Marketing');
    } 

    /*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getKanbanCardTemplate method inside KanbanCardTemplate Class
	----------------------------------------------------------------------------------------------------------*/     
    @isTest  
    private static void getKanbanCardTemplateFinanceTest(){
        leankor__ValueStream__c valueStreamRecord = createExpectedValueStream();  
        leankor.KanbanCardTemplate.KanbanCardTemplateType financeRecord = KanbanCardTemplate.KanbanCardTemplateType.FINANCE;
        leankor.KanbanCardTemplate kanbanCardTemplateRecord = new leankor.KanbanCardTemplate();
        leankor.KanbanCardTemplate kanbanCardTemplateFinanceRecord = kanbanCardTemplateRecord.getKanbanCardTemplate(valueStreamRecord,financeRecord); 
        System.assertEquals(kanbanCardTemplateFinanceRecord.title,'Finance');
    } 

    /*---------------------------------------------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getKanbanCardTemplate method inside KanbanCardTemplate Class
	----------------------------------------------------------------------------------------------------------*/ 
    @isTest  
    private static void getKanbanCardTemplateOperationsTest(){        
        leankor__ValueStream__c valueStreamRecord = createExpectedValueStream();
        leankor.KanbanCardTemplate.KanbanCardTemplateType operationsRecord = KanbanCardTemplate.KanbanCardTemplateType.OPERATIONS;
        leankor.KanbanCardTemplate kanbanCardTemplateRecord = new leankor.KanbanCardTemplate();
        leankor.KanbanCardTemplate kanbanCardTemplateFinanceRecord = kanbanCardTemplateRecord.getKanbanCardTemplate(valueStreamRecord,operationsRecord); 
       
        leankor.KanbanCardTemplate.KanbanCardTemplateType kanbanCardTemplateTypeRecords;
        leankor.KanbanCardTemplate kanbanCardRecord = new KanbanCardTemplate(valueStreamRecord,kanbanCardTemplateTypeRecords);
        System.assertEquals(kanbanCardTemplateFinanceRecord.title,'Operations');
    }   
}