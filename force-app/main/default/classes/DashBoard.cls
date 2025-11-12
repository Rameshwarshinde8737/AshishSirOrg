public with sharing class DashBoard extends Board{
	public static void createDashBoard(String valueStreamId){
		
		//Check CRUD / FLC behavior   
        MarkerBehaviour markerBehaviour = new MarkerBehaviour();
        ChartBehaviour chartBehaviour = new ChartBehaviour();
		ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        
        if (!markerBehaviour.isCreateable()
        ||  !chartBehaviour.isCreateable()
		||	!valueStreamBehavior.isUpdateable()) 
        {
			throw new Util.LeanException('Error: No access to records');
		}
        //Check CRUD / FLC behavior

        KanbanCardTemplate newKanbanCardTemplate = new KanbanCardTemplate();
        List<KanbanCardTemplate> newKanbanCardTemplates = new List<KanbanCardTemplate>();

		List<realTimeController.Zone> RemoteZones = new List<realTimeController.Zone>();
        String ReturnsZones='';

        Savepoint newSavepoint = Database.setSavepoint();
        try {
			List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
			vsList.add(new ValueStream(ValueStream.DASH_BOARD).valuestream);
			List<leankor__ValueStream__c> result = leankor.ValueStream.createValueStream(vsList);
	        leankor__ValueStream__c vStream = result.size() > 0 ? result[0] : new leankor__ValueStream__c();
		   
	        for(String key : KanbanCardTemplate.KANBANCARD_TEMPLATES.keySet()) {
	            newKanbanCardTemplate = new KanbanCardTemplate(vStream, KanbanCardTemplate.KANBANCARD_TEMPLATES.get(key));
	            newKanbanCardTemplate.setKanbanBoardKanbanCardTemplate(newKanbanCardTemplate);
	            newKanbanCardTemplates.add(newKanbanCardTemplate);
	        }
	        List<leankor__KanbanCardTemplate__c> ListKct = KanbanCardTemplate.createKanbanCardTemplates(newKanbanCardTemplates);
	        
	        //-- add labels in _systemdashboard
	        List<leankor__Marker__c> defaultlabels = new List<leankor__Marker__c>();
	        for(integer i=0;i<4;i++){
	            leankor__Marker__c addlabel =  new leankor__Marker__c();              
	            addlabel.leankor__Bottom__c = 0;
	            addlabel.leankor__CmpID__c = 'systemborad-labelText-1'+i;
	            addlabel.leankor__CSSLayout__c = '{"FontSize":25,"Color":"#202020","BackgroundColor":"transparent"}';
	            addlabel.leankor__GUID2__c =(i==0?system.now() + 'systemboard1-2':(i==1?system.now() + 'systemboard2-2':(i==2?system.now() + 'systemboard3-2': system.now() + 'systemboard4-2')));
	            addlabel.leankor__GUID__c = (i==0?system.now() + 'systemboard1':(i==1?system.now() + 'systemboard2':(i==2?system.now() + 'systemboard3':system.now() + 'systemboard4')));
	            addlabel.leankor__Height__c =(i==0 ? 43:(i==1 ? 39:(i==2 ? 70:70)));
	            addlabel.leankor__Left__c =(i==0 ? 2023:(i==1 ? 2024:(i==2 ? 2785:2012)));
	            addlabel.leankor__TextLabel__c =(i==0?'Work Schedule Performance':(i==1?'Work Load Distribution':(i==2?'Work Velocity':'Financial Metrics')));
	            addlabel.leankor__Top__c = (i==0 ? 2021:(i==1 ? 2350:(i==2 ? 2352 : 2697)));
	            addlabel.leankor__Type__c='Label';
	            addlabel.leankor__ValueStream__c = vStream.Id;
	            addlabel.leankor__Width__c =(i==0 ? 384:(i==1 ? 268:(i==2 ? 200 : 200)));
	            addlabel.leankor__X__c =(i== 0 ? 23 :(i==1 ? 24 :(i==2 ? 785 : 12)));
	            addlabel.leankor__Y__c = (i==0 ? 21 :(i==1 ? 350 :(i==2 ? 352 : 697)));
	            addlabel.leankor__ZIndex__c =(i== 0 ? 1000:(i== 1 ? 1001:(i==2 ? 1002 : 1003)));
	            addlabel.Name = 'Label';
	            defaultlabels.add(addlabel);
	        }
	        DataBase.Insert(defaultlabels);
	        //-- add charts in _systemdashboard
	        List<Report> Listofreport =[Select Id,
												DeveloperName,
												Format,
												Name 
											From Report 
											Where FolderName = 'Lean Reports'];
	        map<string,Report> ReportMap = new map<string,Report>();
	        for(Report Rport:Listofreport){
	            ReportMap.put(Rport.DeveloperName,Rport);
	        }
	        List<leankor__chart__c> listofcharts = new list<leankor__chart__c>();
	        for(integer i =0 ; i<=10;i++){
	            leankor__chart__c addchart =  new leankor__chart__c();
	                addchart.leankor__DeveloperName__c =(i==0 ? 'Project_Work_Behind_Schedule_by_Person':(i==1 ? 'Project_Tasks_Behind_Schedule' :(i==2 ? 'Project_Work_Behind_Schedule' :(i==3 ? 'Project_Work_Item_by_Person' :(i==4 ? 'Project_Burn_Down_Report':(i==5 ? 'Project_Labor_Budget_vs_Actual' :(i==6 ? 'Project_Actual_vs_Planned_Expenses' :(i==7 ? 'Project_Chargeable_Expense_Invoiced' :(i==8 ? 'Project_Chargeable_Expenses_Paid' : (i==9 ? 'Project_Workload_By_Person' : 'Project_Expenses_by_Date'))))))))));
	                Report getreportdata= ReportMap.get(addchart.leankor__DeveloperName__c);
	                if(getreportdata== null){
	                    continue;
	                }
	                addchart.Name = getreportdata.Name;
	                addchart.leankor__ReportId__c =getreportdata.id;
	                addchart.leankor__ChartURL__c ='https://' + DomainCreator.getOrgMyDomainHostname()
					+'/apex/leankor__VisualReport?dnm='+getreportdata.id +'&sz=tiny';
	                addchart.leankor__GUID__c= system.now() +'chart1-2'+i;
	                addchart.leankor__CmpID__c ='apex-chart-6'+i;
	                addchart.leankor__ValueStream__c =vStream.Id;
	                addchart.leankor__OnlyShowChart__c = true;
	                addchart.leankor__Format__c =getreportdata.Format;
	                addchart.leankor__Filter__c ='fieldFilter';
	                addchart.leankor__Size__c='tiny';              
	                addchart.leankor__Height__c =(i==0 ? 282 :(i==1 ? 282  :(i==2 ? 284 :(i==3 ? 296 :(i==4 ? 295  :(i==5 ? 310 :(i==6 ? 308  :(i==7 ? 306 : (i==8 ? 306 :(i==9 ? 294 : 306))))))))));
	                addchart.leankor__Width__c =(i==0 ? 353 :(i==1 ? 364  :(i==2 ? 384 :(i==3 ? 357 :(i==4 ? 400 :(i==5 ? 365 :(i==6 ? 374  :(i==7 ? 397  :(i==8 ? 374 :(i==9 ? 371 : 392))))))))));
	                addchart.leankor__Left__c =(i==0 ? 2027 :(i==1 ? 2390  :(i==2 ? 2762 :(i==3 ? 2024 :(i==4 ? 2792  :(i==5 ? 2018 :(i==6 ? 2391 :(i==7 ? 2776 :(i==8 ? 2392 :(i==9 ? 2389 : 2780))))))))));                
	                addchart.leankor__Top__c=(i==0 ? 2058 :(i==1 ? 2058  :(i==2 ? 2058 :(i==3 ? 2391 :(i==4 ? 2392 :(i==5 ? 2738 :(i==6 ? 2739 :(i==7 ? 3061 :(i==8 ? 3060 :(i==9 ? 2392 : 2738))))))))));
	                addchart.leankor__X__c =(i==0 ? 27 :(i==1 ? 390 :(i==2 ? 762 :(i==3 ? 24 :(i==4 ? 792 :(i==5 ? 18 :(i==6 ? 391  :(i==7 ? 776 :(i==8 ? 392 :(i==9 ? 389 : 780))))))))));
	                addchart.leankor__Y__c =(i==0 ? 58 :(i==1 ? 58 :(i==2 ? 58 :(i==3 ? 391 :(i==4 ? 392 :(i==5 ? 738 :(i==6 ? 739 :(i==7 ? 1061 :(i==8 ? 1060 :(i==9 ? 392 : 738))))))))));                
	                string JSONstring = '[{"column":"leankor__KanbanCard__c.leankor__ValueStream__c.leankor__ProjectRoom__c.Id","columnLabel":"Value Stream: Project Room: Project Room ID","operator":"equals","operatorLabel":"equals","valueData":"XYZ","value":"XYZ","dataType":"ID_DATA"}]';
	                if(i==6 || i==7 || i==8 || i==10){
	                    JSONstring = '[{"column":"leankor__ProjectRoom__c.Id","columnLabel":"Project Room ID","operator":"equals","operatorLabel":"equals","valueData":"XYZ","value":"XYZ","dataType":"ID_DATA"}]';
	                }else if(i==4){
	                    JSONstring = '[{"column":"leankor__ValueStream__c.leankor__ProjectRoom__c.Id","columnLabel":"Project Room: Project Room ID","operator":"equals","operatorLabel":"equals","valueData":"XYZ","value":"XYZ","dataType":"ID_DATA"}]';
	                }
	                addchart.leankor__JSONData__c = JSONstring;
	            listofcharts.add(addchart);
	        }
	        DataBase.Insert(listofcharts);
	        leankor__ValueStream__c projectBoardupdate = new leankor__ValueStream__c(leankor__DefaultCategory__c = ListKct[0].ID, ID = vStream.Id);
	        DataBase.update(projectBoardupdate);
	        leankor.realTimeController.Preference UserPref =  new leankor.realTimeController.Preference();
	            UserPref.id = '';
	            UserPref.name= userinfo.getname();
	            UserPref.guid = system.now()+'prefrence';
	            UserPref.followonchatter='all';
	            UserPref.subscribetocard='all';
	            UserPref.valuestream= vStream.Id;
	            UserPref.ownereditcard = false;
	            UserPref.ownermovecard= false;
	            UserPref.valuestreamowner = userinfo.getuserID();
	            UserPref.currentUser = userinfo.getuserID();
	            UserPref.cardpastduedate =true;
	            UserPref.taskpastduedate =true;
	            UserPref.moved = false;
	            UserPref.percentdone =true;
	            UserPref.flag =1;
	        leankor__Preference__c defultpre =leankor.realTimeController.getPreference(UserPref);
	        
	        leankor.KanbanController.CloneBoard cBoard =new leankor.KanbanController.CloneBoard();
	            cBoard.VSID = valueStreamId;
	            cBoard.RealVSID = vStream.Id; // _system_dashboard
	            cBoard.KanbanVerb = false;
	            cBoard.KanbanTemplateVerb = true;
	            cBoard.StickerVerb = false;
	            cBoard.TaskVerb = false;
	            cBoard.ZoneVerb = true;
	            cBoard.MarkerVerb = true;
	            cBoard.ChartVerb = true;
	            cBoard.BoardType ='DashBoard';
	            cBoard.LinkCloneRoomID = '';
	            cBoard.LinkCloneVSID = '';
	            cBoard.LinkCloneKanbanCardID = ''; 
	        leankor.KanbanController.CloneSystemBoard(cBoard);
        }catch(Exception e) {
            //Rollback savepoint
            Database.rollback(newSavepoint);
			//25/04/2023 : We are Throwing Exception
			throw new Util.LeanException('ERROR:' + e.getMessage());  
        }
	}

}