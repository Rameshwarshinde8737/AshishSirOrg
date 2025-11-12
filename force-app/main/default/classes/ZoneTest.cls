@isTest
private class ZoneTest {

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
       	for(String key : MasterContainer.MASTERCONTAINERS.keySet()) {
            newMasterContainer = new MasterContainer(newValuestream, MasterContainer.MASTERCONTAINERS.get(key), masterContainerIndex);
            newMasterContainers.add(newMasterContainer);
            masterContainerIndex++;
        }
		return MasterContainer.createMasterContainers(newMasterContainers);
	}

	private static List<leankor__Swimlane__c> createExpectedSwimlanes() {
		List<leankor__MasterContainer__c> MasterContainers=createExpectedMasterContainers();
		List<KanbanController.Swimlane> Swims=new List<KanbanController.Swimlane>();
		List<leankor__Swimlane__c> Swimlanes=new List<leankor__Swimlane__c>();
		Integer j=0;
		for(leankor__MasterContainer__c m :MasterContainers){
		    KanbanController.Swimlane s=new KanbanController.Swimlane();
		    s.CardPerRow =1;
		    s.CmpID='ext-swimlaneContainer-'+j;
		    s.Color=(j==2?'#66CC00':'#4183D7');
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
	
	private static List<leankor__Swimlane__c> createActualSwimlanes() {
		List<leankor__MasterContainer__c> masterContainers = createActualMasterContainers();
		List<Swimlane> newSwimlanes = new List<Swimlane>();
		Swimlane newSwimlane;
		Integer swimlaneIndex = 0;
		Swimlane swimlaneType;
		for (leankor__MasterContainer__c masterContainer : masterContainers) {
			if(swimlaneIndex !=2) {
				swimlaneType = Swimlane.STANDARD;
			}else {
				swimlaneType = Swimlane.INPROGRESS;
			}
			newSwimlane = new Swimlane(masterContainer, swimlaneType, swimlaneIndex);
			newSwimlanes.add(newSwimlane);
			swimlaneIndex++;
		}
		return Swimlane.createSwimlanes(newSwimlanes);
	}

	private static List<leankor__Zone__c> createZone(String VSID, List < realTimeController.Zone > RemoteZones) {
        List < leankor__Zone__c > NewZoneList = new List < leankor__Zone__c > ();
        List < ID > GroupIDs = new List < ID > ();
        for (realTimeController.Zone RemoteZone: RemoteZones) {
            leankor__Zone__c NewZone = new leankor__Zone__c(
                    leankor__UrlLink__c = RemoteZone.UrlLink,
                    leankor__GUID__c = RemoteZone.GUID,
                    leankor__Title__c = RemoteZone.Title,
                    leankor__Unit__c = remoteZone.Unit,
                    Name = RemoteZone.Title,
                    leankor__Top__c = RemoteZone.Top,
                    leankor__Bottom__c = RemoteZone.Bottom,
                    leankor__Left__c = RemoteZone.Left,
                    leankor__Width__c = RemoteZone.Width,
                    leankor__Height__c = RemoteZone.Height,
                    leankor__X__c = RemoteZone.X,
                    leankor__OpportunityStageName__c = RemoteZone.ZoneOpportunityStage,
                    leankor__Y__c = RemoteZone.Y,
                    leankor__EntryFlowName__c = RemoteZone.EntryFlowName,
                    leankor__ExitFlowName__c = RemoteZone.ExitFlowName,
                    leankor__ValueStream__c = (VSID == '' ? null : VSID),
                    leankor__zoneMode__c = RemoteZone.ZoneMode,
                    leankor__kanbanSequence__c = RemoteZone.KanbanSequence,
                    leankor__ValueStreamLink__c = (RemoteZone.ValueStreamLinkID == '' ? null : RemoteZone.ValueStreamLinkID),
                    leankor__ValueStreamCardLink__c = (RemoteZone.ValueStreamCardLink == '' ? null : RemoteZone.ValueStreamCardLink),
                    leankor__DefaultWidth__c = RemoteZone.DefaultWidth,
                    leankor__DefaultHeight__c = RemoteZone.DefaultHeight,
                    leankor__CaseStatus__c = RemoteZone.ZoneStatus,
                    leankor__CardsPerRow__c = RemoteZone.CardsPerRow,
                    leankor__Help__c = RemoteZone.Help,
                    leankor__Limit__c = RemoteZone.TaskLimit,
                    leankor__Order__c = RemoteZone.Order,
                    leankor__ParentZone__c = (RemoteZone.ParentZone != '' ? RemoteZone.ParentZone : null),
                    leankor__Swimlane__c = (RemoteZone.Swimlane != '' ? RemoteZone.Swimlane : null));
            NewZoneList.add(NewZone);
        }
        List < Database.Saveresult > uResults;
        try {
            if (leankor__Zone__c.sObjectType.getDescribe().isCreateable()) {
                //Schema.Sobjectfield ExternField = leankor__Zone__c.Fields.leankor__GUID__c;
                uResults = Database.insert(NewZoneList, false);
            }
        } catch (DmlException e) {
            System.debug(e.getMessage());
            NewZoneList = new List<leankor__Zone__c>();
            return NewZoneList;
        }
        return NewZoneList;
    }

	private static List<leankor__Zone__c> createExpected() {
		List<realTimeController.Zone> RemoteZones = new List<realTimeController.Zone>();
		List<leankor__Zone__c> ReturnsZones;
		List<leankor__Swimlane__c> Swimlanes = createExpectedSwimlanes();
		Integer k = 0;
        for(leankor__Swimlane__c s:Swimlanes){
            realTimeController.Zone RemoteZone=new realTimeController.Zone();
            RemoteZone.Name = (k==1 || k==2 || k==3) ?'In Progress' :'Default Column';
            RemoteZone.GUID =s.leankor__ValueStream__c+'-'+System.now().getTime()+'-z100'+k;
            RemoteZone.Title = (k==1 || k==2 || k==3) ?'In Progress' :'Default Column';
            RemoteZone.Top=0;
            RemoteZone.Bottom =0;
            RemoteZone.Left =0;
            RemoteZone.Width =209;
            RemoteZone.Height =(k==2 || k==3) ? 174:492;
            RemoteZone.X = 0;
            RemoteZone.Y = 0;
            RemoteZone.EntryFlowName ='';
            RemoteZone.ExitFlowName ='';
            RemoteZone.ZoneMode ='Vertical Stretch';
            RemoteZone.KanbanSequence = '[]';
            RemoteZone.ValueStreamLinkID ='';
            RemoteZone.ValueStreamCardLink ='';
            RemoteZone.DefaultWidth  = 209;
            RemoteZone.DefaultHeight = (k==2 || k==3) ? 174:492;
            RemoteZone.ZoneStatus ='None';
            RemoteZone.CardsPerRow=1;
            RemoteZone.Help ='';
            RemoteZone.TaskLimit =0;
            RemoteZone.Order=0;
            RemoteZone.ParentZone='';
            RemoteZone.Swimlane=s.Id;
            RemoteZones.add(RemoteZone);
            k++;
        }
        ReturnsZones=createZone(Swimlanes[0].leankor__ValueStream__c,RemoteZones);
        return ReturnsZones;
	}

	private static List<leankor__Zone__c> createActual() {
        List<leankor__Swimlane__c> swimlanes = createActualSwimlanes();
        Zone newZone;
		List<leankor__Zone__c> zones;
		List<Zone> newZones = new List<Zone>();
		Integer zoneIndex = 0;    
        //Create and add local Zones
        for(leankor__Swimlane__c swimlane : swimlanes) {
            if(zoneIndex == 1) {
                newZone = new Zone(swimlane, Zone.STANDARDINPROGRESS, zoneIndex);
            }else if (zoneIndex == 2 || zoneIndex == 3) {
                newZone = new Zone(swimlane, Zone.INPROGRESS, zoneIndex);
            }else {
                newZone = new Zone(swimlane, Zone.STANDARD, zoneIndex);
            }
            newZones.add(newZone);
            zoneIndex++;
        }
        //Create server Zones
        zones = Zone.createZones(newZones);
        return zones;
	}


	@isTest static void createCompareNotEqualsId() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].id, actual[i].id);	
		}
	}

	@isTest static void createCompareUrlLink() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__UrlLink__c, actual[i].leankor__UrlLink__c);		
		}
	}

	@isTest static void createCompareNotEqualsGUID() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__GUID__c, actual[i].leankor__GUID__c);		
		}
	}

	@isTest static void createCompareTitle() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Title__c, actual[i].leankor__Title__c);		
		}
	}

	@isTest static void createCompareUnit() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Unit__c, actual[i].leankor__Unit__c);		
		}
	}

	@isTest static void createCompareName() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);		
		}
	}

	@isTest static void createCompareTop() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Top__c, actual[i].leankor__Top__c);		
		}
	}

	@isTest static void createCompareBottom() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Bottom__c, actual[i].leankor__Bottom__c);		
		}
	}

	@isTest static void createCompareLeft() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Left__c, actual[i].leankor__Left__c);		
		}
	}

	@isTest static void createCompareWidth() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Width__c, actual[i].leankor__Width__c);		
		}
	}

	@isTest static void createCompareHeight() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Height__c, actual[i].leankor__Height__c);		
		}
	}

	@isTest static void createCompareX() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__X__c, actual[i].leankor__X__c);		
		}
	}

	@isTest static void createCompareOpportunityStageName() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__OpportunityStageName__c, actual[i].leankor__OpportunityStageName__c);		
		}
	}

	@isTest static void createCompareY() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Y__c, actual[i].leankor__Y__c);		
		}
	}

	@isTest static void createCompareEntryFlowName() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__EntryFlowName__c, actual[i].leankor__EntryFlowName__c);		
		}
	}

	@isTest static void createCompareExitFlowName() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__ExitFlowName__c, actual[i].leankor__ExitFlowName__c);		
		}
	}

	@isTest static void createCompareNotEqualsValueStream() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__ValueStream__c, actual[i].leankor__ValueStream__c);		
		}
	}

	@isTest static void createComparezoneMode() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__zoneMode__c, actual[i].leankor__zoneMode__c);		
		}
	}

	@isTest static void createComparekanbanSequence() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__kanbanSequence__c, actual[i].leankor__kanbanSequence__c);		
		}
	}

	@isTest static void createCompareValueStreamLink() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__ValueStreamLink__c, actual[i].leankor__ValueStreamLink__c);		
		}
	}

	@isTest static void createCompareValueStreamCardLink() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__ValueStreamCardLink__c, actual[i].leankor__ValueStreamCardLink__c);		
		}
	}

	@isTest static void createCompareDefaultWidth() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__DefaultWidth__c, actual[i].leankor__DefaultWidth__c);		
		}
	}

	@isTest static void createCompareDefaultHeight() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__DefaultHeight__c, actual[i].leankor__DefaultHeight__c);		
		}
	}

	@isTest static void createCompareCaseStatus() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CaseStatus__c, actual[i].leankor__CaseStatus__c);		
		}
	}

	@isTest static void createCompareCardsPerRow() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__CardsPerRow__c, actual[i].leankor__CardsPerRow__c);		
		}
	}

	@isTest static void createCompareHelp() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Help__c, actual[i].leankor__Help__c);		
		}
	}

	@isTest static void createCompareLimit() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Limit__c, actual[i].leankor__Limit__c);		
		}
	}

	@isTest static void createCompareOrder() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__Order__c, actual[i].leankor__Order__c);		
		}
	}

	@isTest static void createCompareParentZone() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].leankor__ParentZone__c, actual[i].leankor__ParentZone__c);		
		}
	}

	@isTest static void createCompareNotEqualsSwimlane() {
		List<leankor__Zone__c> expected = createExpected();
		List<leankor__Zone__c> actual = createActual();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].leankor__Swimlane__c, actual[i].leankor__Swimlane__c);		
		}
	}

	private static List<leankor.realTimeController.Zone> createExpectedClone() {
		String testValueStreamId = createExpectedValueStream().id;
		String testSwimlaneId = createExpectedSwimlanes()[0].id;
		leankor__Zone__c testZone = createExpected()[0];
		List<leankor.realTimeController.Zone> RemoteZones = new List<leankor.realTimeController.Zone>();
        leankor.realTimeController.Zone RemoteZone=new leankor.realTimeController.Zone();
        RemoteZone.Name =testZone.Name;
        RemoteZone.GUID =testZone.Id+'-'+testSwimlaneId+'-z';
        RemoteZone.Title = testZone.leankor__Title__c;
        RemoteZone.Top=testZone.leankor__Top__c;
        RemoteZone.Bottom =testZone.leankor__Bottom__c;
        RemoteZone.Left =testZone.leankor__Left__c;
        RemoteZone.Width =testZone.leankor__Width__c;
        RemoteZone.Height =testZone.leankor__Height__c;
        RemoteZone.Unit =testZone.leankor__Unit__c;
        RemoteZone.X = testZone.leankor__X__c;
        RemoteZone.Y = testZone.leankor__Y__c;
        RemoteZone.EntryFlowName =testZone.leankor__EntryFlowName__c;
        RemoteZone.ExitFlowName =testZone.leankor__ExitFlowName__c;
        RemoteZone.ZoneMode =testZone.leankor__zoneMode__c;
        RemoteZone.KanbanSequence = testZone.leankor__kanbanSequence__c;
        RemoteZone.ValueStreamLinkID =testZone.leankor__ValueStreamLink__c;
        RemoteZone.ValueStreamCardLink =testZone.leankor__ValueStreamCardLink__c;
        RemoteZone.DefaultWidth  = testZone.leankor__DefaultWidth__c;
        RemoteZone.DefaultHeight = testZone.leankor__DefaultHeight__c;
        RemoteZone.ZoneStatus =testZone.leankor__CaseStatus__c ;
        RemoteZone.ZoneOpportunityStage = testZone.leankor__OpportunityStageName__c ;
        RemoteZone.CardsPerRow=testZone.leankor__CardsPerRow__c;
        RemoteZone.Help =testZone.leankor__Help__c;
        RemoteZone.TaskLimit =testZone.leankor__Limit__c;
        RemoteZone.Order=testZone.leankor__Order__c;
        RemoteZone.ParentZone='';
        RemoteZone.Swimlane=testSwimlaneId;
        RemoteZones.add(RemoteZone);
        realTimeController.createZone(testValueStreamId,RemoteZones);
        return RemoteZones;
	}

	private static List<leankor__Zone__c> createActualClone() {
		String testValueStreamId = createExpectedValueStream().id;
		String testSwimlaneId = createActualSwimlanes()[0].id;
		leankor__Zone__c testZone = createActual()[0];
		List<leankor.Zone> newZones = new List<leankor.Zone>();
		List<leankor__Zone__c> serverZones = new List<leankor__Zone__c>();
        leankor.Zone localZone = new leankor.Zone(testValueStreamId, testSwimlaneId, testZone);
        newZones.add(localZone);
        serverZones = leankor.Zone.createZones(newZones);
        return serverZones;
	}

	@isTest static void createCompareNotEqualsGUIDClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].GUID, actual[i].leankor__GUID__c);		
		}
	}

	@isTest static void createCompareTitleClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Title, actual[i].leankor__Title__c);		
		}
	}

	@isTest static void createCompareUnitClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Unit, actual[i].leankor__Unit__c);		
		}
	}

	@isTest static void createCompareNameClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Name, actual[i].Name);		
		}
	}

	@isTest static void createCompareTopClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Top, actual[i].leankor__Top__c);		
		}
	}

	@isTest static void createCompareBottomClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Bottom, actual[i].leankor__Bottom__c);		
		}
	}

	@isTest static void createCompareLeftClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Left, actual[i].leankor__Left__c);		
		}
	}

	@isTest static void createCompareWidthClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Width, actual[i].leankor__Width__c);		
		}
	}

	@isTest static void createCompareHeightClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Height, actual[i].leankor__Height__c);		
		}
	}

	@isTest static void createCompareXClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].X, actual[i].leankor__X__c);		
		}
	}

	@isTest static void createCompareOpportunityStageNameClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].ZoneOpportunityStage, actual[i].leankor__OpportunityStageName__c);		
		}
	}

	@isTest static void createCompareYClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Y, actual[i].leankor__Y__c);		
		}
	}

	@isTest static void createCompareEntryFlowNameClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].EntryFlowName, actual[i].leankor__EntryFlowName__c);		
		}
	}

	@isTest static void createCompareExitFlowNameClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].ExitFlowName, actual[i].leankor__ExitFlowName__c);		
		}
	}

	@isTest static void createComparezoneModeClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].ZoneMode, actual[i].leankor__zoneMode__c);		
		}
	}

	@isTest static void createComparekanbanSequenceClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].KanbanSequence, actual[i].leankor__kanbanSequence__c);		
		}
	}

	@isTest static void createCompareValueStreamLinkClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].ValueStreamLinkID, actual[i].leankor__ValueStreamLink__c);		
		}
	}

	@isTest static void createCompareValueStreamCardLinkClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].ValueStreamCardLink, actual[i].leankor__ValueStreamCardLink__c);		
		}
	}

	@isTest static void createCompareDefaultWidthClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].DefaultWidth, actual[i].leankor__DefaultWidth__c);		
		}
	}

	@isTest static void createCompareDefaultHeightClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].DefaultHeight, actual[i].leankor__DefaultHeight__c);		
		}
	}

	@isTest static void createCompareCaseStatusClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].ZoneStatus, actual[i].leankor__CaseStatus__c);		
		}
	}

	@isTest static void createCompareCardsPerRowClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].CardsPerRow, actual[i].leankor__CardsPerRow__c);		
		}
	}

	@isTest static void createCompareHelpClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Help, actual[i].leankor__Help__c);		
		}
	}

	@isTest static void createCompareLimitClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].TaskLimit, actual[i].leankor__Limit__c);		
		}
	}

	@isTest static void createCompareOrderClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertEquals(expected[i].Order, actual[i].leankor__Order__c);		
		}
	}

	@isTest static void createCompareNotEqualsParentZoneClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].ParentZone, actual[i].leankor__ParentZone__c);		
		}
	}

	@isTest static void createCompareNotEqualsSwimlaneClone() {
		List<leankor.realTimeController.Zone> expected = createExpectedClone();
		List<leankor__Zone__c> actual = createActualClone();

		for(Integer i = 0; i < expected.size(); i++) {
			System.assertNotEquals(expected[i].Swimlane, actual[i].leankor__Swimlane__c);		
		}
	}

	/*-----------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getZone Method inside  Zone Class
	---------------------------------------------------------------------*/ 
	@isTest
	 private static void getZoneStandardInProgressTest(){
		
		List<leankor__Swimlane__c> swimlanes = createExpectedSwimlanes();
        leankor__Swimlane__c  swimlaneRecord = [Select leankor__Swimlane__c.leankor__ValueStream__c
		                                           From leankor__Swimlane__c 
												   Where name='Default Swimlane'
											       Limit 1];

		leankor.Zone.ZoneType zoneTypeRecord = Zone.ZoneType.STANDARDINPROGRESS;
        Integer index = 0;
        Test.startTest();
		leankor.Zone zoneRecord = new Zone(swimlaneRecord,zoneTypeRecord,index);
        System.assertEquals(zoneRecord.height,492);
        Test.stopTest();
	}

	/*------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getZone Method inside  Zone Class
	---------------------------------------------------------------------*/ 
	@isTest
	 private static void getZoneInProgressTest(){

		List<leankor__Swimlane__c> Swimlanes = createExpectedSwimlanes();
        leankor__Swimlane__c  swimlaneRecord = [Select leankor__Swimlane__c.leankor__ValueStream__c
		                                           From leankor__Swimlane__c 
												   Where name='Default Swimlane'
											       Limit 1];

		leankor.Zone.ZoneType zoneTypeRecord = Zone.ZoneType.INPROGRESS;
        Integer index = 0; 
        Test.startTest();
		leankor.Zone zoneRecord = new Zone(swimlaneRecord,zoneTypeRecord,index);
        System.assertEquals(zoneRecord.height,492);
        Test.stopTest();
	}

	/*------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getZone Method inside  Zone Class
	---------------------------------------------------------------------*/ 
	@isTest
	 private static void getZoneStandardTest(){

		List<leankor__Swimlane__c> Swimlanes = createExpectedSwimlanes();
        leankor__Swimlane__c  swimlaneRecord = [Select  leankor__Swimlane__c.leankor__ValueStream__c
		                                           From leankor__Swimlane__c 
												   Where name='Default Swimlane'
											       Limit 1];

		leankor.Zone.ZoneType zoneTypeRecord = Zone.ZoneType.STANDARD;
        Integer index = 0;
        Test.startTest();
		leankor.Zone zoneRecord = new Zone(swimlaneRecord,zoneTypeRecord,index);
        System.assertEquals(zoneRecord.height,492);
        Test.stopTest(); 
	}
	
	/*------------------------------------------------------------------
	Company     : Leankor
	Description : This method is cover getZone Method inside  Zone Class
	---------------------------------------------------------------------*/ 
	@isTest
	 private static void getZoneTest(){

		List<leankor__Swimlane__c> Swimlanes = createExpectedSwimlanes();	
        leankor__Swimlane__c  swimlaneRecord = [Select id 
		                                           From leankor__Swimlane__c 
												   Where name='Default Swimlane'
											       Limit 1];

		leankor.Zone.ZoneType zoneTypeRecord; 
        Integer index = 0;
        Test.startTest();
		leankor.Zone zoneRecord = new Zone(swimlaneRecord,zoneTypeRecord,index);
        System.assertEquals(zoneRecord.height,492);
        Test.stopTest(); 
	}
}