@isTest
public class  TestAllApexBatches{

      @testSetup static void createBaseData(){
      
        leankor__LeanConstants__c customSetting = new leankor__LeanConstants__c();
            customSetting.leankor__RetentionPeriodInDays__c = 1;
            customSetting.SetupOwnerId = Userinfo.getOrganizationId();
            insert customSetting;         
 
        //Load CSV file saved in static resource 
        List<SObject> lstVSRecs = Test.loadData(leankor__ValueStream__c.sObjectType,'LoadTestData');
        //Confirm that total number of accounts created are 3
        System.assertEquals(lstVSRecs.size(), 5);   
      
      } 

      @isTest
      static void testDeleteRaSm()
      {    
         leankor__ProjectRoom__c p = new leankor__ProjectRoom__c(Name = 'Project Room');        
         insert p;  
         leankor__ValueStream__c vStream = new leankor__ValueStream__c();
         vStream.Name = 'Plan Board (' + p.Name + ')';     
         vStream.leankor__BoardType__c = 'UberBoard';
         vStream.leankor__ProjectRoom__c = p.Id;  
         insert vStream;             
         List<leankor__KanbanCard__c> kclistCard = new List<leankor__KanbanCard__c>();      
         String folderId = leankor.TestDataFactory.getRecordType('leankor__KanbanCard__c','foldercard').Id;
         String milestoneId = leankor.TestDataFactory.getRecordType('leankor__KanbanCard__c','MileStoneCard').Id;
         String activityId = leankor.TestDataFactory.getRecordType('leankor__KanbanCard__c','ActivityCard').Id;
         //making data for delete RA and SM batch         
         for(Integer i = 0; i < 50; i++)
         {
                leankor__KanbanCard__c ag1 = new leankor__KanbanCard__c();
                ag1.Name = 'Folder' + i;
                ag1.RecordTypeId = folderId;
                ag1.leankor__ValueStream__c = vStream.Id;
                ag1.leankor__GUID__c = folderId + system.now().gettime() + i;
                ag1.ownerId = UserInfo.getuserId();
                
                kclistCard.add(ag1);
                
                leankor__KanbanCard__c ag2 = new leankor__KanbanCard__c();
                ag2.Name = 'MileStone ' + i;
                ag2.RecordTypeId = milestoneId;
                ag2.leankor__ValueStream__c = vStream.Id;
                ag2.leankor__GUID__c =  i + milestoneId + system.now().gettime();
                ag2.ownerId = UserInfo.getuserId();
                                            
                kclistCard.add(ag2);
                
                leankor__KanbanCard__c ag3 = new leankor__KanbanCard__c();
                ag3.Name = 'activity ' + i;
                ag3.RecordTypeId = activityId;
                ag3.leankor__ValueStream__c = vStream.Id;
                ag3.leankor__GUID__c =  activityId + i +system.now().gettime();
                ag3.ownerId = UserInfo.getuserId();
                                            
                kclistCard.add(ag3);
                
         }
         insert kclistCard;      
         Integer cardcount = [select count() from leankor__KanbanCard__c];     
         system.assert(cardcount == kclistCard.size());         
         List<leankor__ResourceAssignment__c> ralist = new List<leankor__ResourceAssignment__c>();
         List<leankor__ScheduleMode__c> smlist = new List<leankor__ScheduleMode__c>();        
         for(leankor__KanbanCard__c card : kclistCard)
         {
                leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c();
                ra.leankor__KanbanCard__c = Card.Id;
                ra.leankor__AssignedTo__c = Card.OwnerId;
                ra.leankor__PercentAllocation__c =100;           
                ralist.add(ra);
                
                leankor__ScheduleMode__c sm = new leankor__ScheduleMode__c();
                sm.leankor__EffortActual__c = 0.0;
                sm.leankor__EffortUnits__c = 'Days';
                sm.leankor__KanbanCard__c = Card.Id;
                sm.leankor__ManuallyScheduled__c = false;
                sm.leankor__Mode__c = 'Normal';
                                            
                smlist.add(sm);
         }
         insert ralist;
         insert smlist;        
         system.assert([select count() from leankor__ResourceAssignment__c] == ralist.size());
         system.assert([select count() from leankor__ScheduleMode__c] == smlist.size());        
         for(leankor__KanbanCard__c card : kclistCard)
         {
               if(card.RecordtypeId != milestoneId)
               {
                  card.leankor__ValueStream__c = null;
               }
         }
         update kclistCard;         
         database.executebatch(new leankor.DeleteResourceAssignmentRecords());         
         database.executebatch(new leankor.DeleteScheduleModeRecords());
         database.executebatch(new leankor.IsRecordDeletedOfKanbanCard());
                     
      }
      
      @isTest
      static void testUpdateCompletedTaskBatch()
      {
        List<leankor__KanbanCard__c> kclistCard = new List<leankor__KanbanCard__c>();
        leankor__ValueStream__c vStream = new leankor__ValueStream__c();
        vStream.Name = 'k1';     
        vStream.leankor__BoardType__c = 'kanban Board';
        insert vStream;
        String activityId = leankor.TestDataFactory.getRecordType('leankor__KanbanCard__c','ActivityCard').Id;
         
         //making data for update completed Task with lastmodified Date
         for(Integer i = 0; i < 50; i++)
         {        
            leankor__KanbanCard__c ag3 = new leankor__KanbanCard__c();
            ag3.Name = 'activity ' + i;
            ag3.RecordTypeId = activityId;
            ag3.leankor__ValueStream__c = vStream.Id;
            ag3.leankor__GUID__c =  activityId + i +system.now().gettime();
            ag3.ownerId = UserInfo.getuserId();
                                        
            kclistCard.add(ag3);
                
         }
         
         insert kclistCard;
         system.assert([select count() from leankor__KanbanCard__c] == kclistCard.size());
         List<Task> tsklist = new List<Task>();
         for(leankor__KanbanCard__c kc : kclistCard){
             
             Task tsk = new Task();
             tsk.whatId = kc.Id;
             tsk.status = 'Completed';
             
             tsklist.add(tsk);
         }
         insert tskList ; 
         system.assert([select count() from Task] == tsklist.size());        
         database.executebatch(new leankor.UpdateCompletedTaskBatch());     
      }
   
      @isTest
      static void testPurgeSoftDeletedRecordsForVS()
      {
            
            List<leankor__Chart__c> chartList = new List<leankor__Chart__c>();
            List<leankor__Preference__c> prefList = new List<leankor__Preference__c>();
            List<leankor__Security__c> secrList = new List<leankor__Security__c>();
            List<leankor__RealtimeTracker__c> rtList = new List<leankor__RealtimeTracker__c>();
            List<leankor__KanbanCard__c> kcCardList = new List<leankor__KanbanCard__c>();
            List<leankor__AutomationTemplate__c> atmList = new List<leankor__AutomationTemplate__c>();
            List<leankor__Zone__c> zoneList = new List<leankor__Zone__c>();
            List<leankor__Swimlane__c> swimListList = new List<leankor__Swimlane__c>();
            List<leankor__MasterContainer__c> mcList = new List<leankor__MasterContainer__c>();
            List<leankor__Dependency__c> dpList = new List<leankor__Dependency__c>();
            List<leankor__Sticker__c> stkList = new List<leankor__Sticker__c>();
            List<leankor__Marker__C> markerList = new List<leankor__Marker__C>();
            List<leankor__ProjectScheduleBaseline__c> psbList = new List<leankor__ProjectScheduleBaseline__c>();
            List<leankor__KanbanCardTemplate__C> kctList = new List<leankor__KanbanCardTemplate__C>();
            List<leankor__Filter__c> ftList = new List<leankor__Filter__c>();
         
            List<leankor__ValueStream__c> vStreamList = [select id from leankor__ValueStream__c where leankor__IsRecordDeleted__c=true limit 1];
            for(leankor__ValueStream__c vStream : vStreamList){
                for(Integer i=0;i<600;i++){
            leankor__Chart__c ch = new leankor__Chart__c();       
            ch.leankor__ChartURL__c = 'sssdsd';
            ch.leankor__DeveloperName__c = 'leankor';
            ch.leankor__ReportId__c = '00Od0000005NiGBEA0';
            ch.leankor__ValueStream__c = vStream.Id;
                    ch.leankor__GUID__C = TestDataFactory.createGuid();
                    chartList.add(ch);
            
            leankor__Preference__c pref = new leankor__Preference__c();
            pref.leankor__ValueStream__c = vStream.Id;
                    pref.leankor__GUID__C = TestDataFactory.createGuid();
                    prefList.add(pref);
                        
            leankor__Security__c secur =  new leankor__Security__c();
            secur.leankor__ValueStream__c = vStream.Id;
                    secur.leankor__GUID__C = TestDataFactory.createGuid();
                    secrList.add(secur);
            
            leankor__RealtimeTracker__c rt  = new leankor__RealtimeTracker__c();
            rt.leankor__ValueStream__c = vStream.Id;
                    rtList.add(rt);
            
            leankor__KanbanCard__c kccard = new leankor__KanbanCard__c();
            kccard.leankor__ValueStream__c = vStream.Id;
                    kccard.leankor__GUID__C = TestDataFactory.createGuid();         
                    kcCardList.add(kccard);
            
            leankor__AutomationTemplate__c atm = new  leankor__AutomationTemplate__c();
            atm.leankor__ValueStream__c = vStream.Id;
                    atm.leankor__GUID__C = TestDataFactory.createGuid();
                    atmList.add(atm);
        
            leankor__Zone__c  zonekbc =  new leankor__Zone__c();
            zonekbc.leankor__ValueStream__c = vStream.Id;
                    zonekbc.leankor__GUID__C = TestDataFactory.createGuid();
                    zoneList.add(zonekbc);
            
            leankor__Swimlane__c   swl = new leankor__Swimlane__c();
            swl.leankor__ValueStream__c = vStream.Id;
                    swimListList.add(swl);
            
            leankor__MasterContainer__c  mcont = new leankor__MasterContainer__c();
            mcont.leankor__ValueStream__c = vStream.Id;
                    mcont.leankor__GUID__C = TestDataFactory.createGuid();          
                    mcList.add(mcont);
            
            leankor__Dependency__c dp = new leankor__Dependency__c();
            dp.leankor__ValueStream__c = vStream.Id;
                    dp.leankor__GUID__C = TestDataFactory.createGuid();         
                    dpList.add(dp);
            
            leankor__Sticker__c str = new  leankor__Sticker__c();
            str.leankor__ValueStream__c = vStream.Id;
                    stkList.add(str);
            
            leankor__Marker__C  marker = new leankor__Marker__c();
            marker.leankor__ValueStream__c = vStream.Id;
            marker.leankor__GUID__C = TestDataFactory.createGuid();
                    marker.leankor__GUID2__C = TestDataFactory.createGuid();
                    markerList.add(marker);
            
                    leankor__ProjectScheduleBaseline__c psb  = new leankor__ProjectScheduleBaseline__c();
                    psb.leankor__ProjectBoard__c = vStream.Id;
                    psbList.add(psb);
            
                    leankor__KanbanCardTemplate__C kct = new leankor__KanbanCardTemplate__c();  
                    kct.leankor__ValueStream__c = vStream.Id;
                    kctList.add(kct);
            
                    leankor__Filter__c ft = new  leankor__Filter__c();
                    ft.leankor__ValueStream__c = vStream.Id;
                    ftList.add(ft);
                }
            }
            insert atmList;
            insert kcCardList;
                        
            List<leankor__TaskTemplate__c> ttList = new List<leankor__TaskTemplate__c>();   
            for(leankor__AutomationTemplate__c atm :atmList){
                leankor__TaskTemplate__c  temp = new leankor__TaskTemplate__c();
                temp.leankor__AutomationTemplate__c = atm.Id;
                temp.leankor__GUID__C = TestDataFactory.createGuid();
                ttList.add(temp);
            }           
            
            insert chartList;
            insert prefList;
            insert secrList;
            insert rtList;          
            insert zoneList;
            insert swimListList;
            insert mcList;
            insert dpList;
            insert stkList;
            insert markerList;          
            // There are 6 valuestream we have inserted in testSetup so other records should be greater than that.
            system.assert(limits.getdmlrows()>6);   
            test.startTest();
            
            insert psbList;
            insert kctList;
            insert ftList;      
            // There are 6 valuestream we have inserted in testSetup so other records should be greater than that. 
            system.assert(limits.getdmlrows()>6);   
            database.executebatch(new leankor.PurgeSoftDeletedRecords());     
            
            test.stopTest();     
            
      }
      
      @isTest
      static void testPurgeSoftDeletedRecordsForKb()
      {
        List<leankor__KanbanCard__c> kcCardList = new List<leankor__KanbanCard__c>();
        
        List<leankor__ValueStream__c> vStreamList = [select id from leankor__ValueStream__c where leankor__IsRecordDeleted__c=true limit 1];
            for(leankor__ValueStream__c vStream : vStreamList){
                   for(Integer i=0;i<499;i++){ 
                
                     leankor__KanbanCard__c kccard = new leankor__KanbanCard__c();
                        kccard.leankor__ValueStream__c = vStream.Id;
                        kccard.leankor__GUID__C = TestDataFactory.createGuid();         
                        kcCardList.add(kccard);
                    }  
            }
            
        insert kcCardList;                      
        List<leankor__KanbanCardSticker__c> kcsList = new List<leankor__KanbanCardSticker__c>();
        List<leankor__Subscriber__c> subList = new List<leankor__Subscriber__c>();
        List<leankor__ScheduleMode__c> schedList = new List<leankor__ScheduleMode__c>();
        List<leankor__ResourceAssignment__c> raList = new List<leankor__ResourceAssignment__c>();
        List<leankor__KanbanCardBaseline__c> kcbList = new List<leankor__KanbanCardBaseline__c>();
        List<EntitySubscription> entityList = new List<EntitySubscription>();
        List<leankor__ZoneKanbanAction__c> zonekanbanList = new List<leankor__ZoneKanbanAction__c>();           
            
        for(leankor__KanbanCard__c kccard :kcCardList){   
            leankor__KanbanCardSticker__c kcs = new leankor__KanbanCardSticker__c();
            kcs.leankor__KanbanCard__c = kccard.Id;
                    kcsList.add(kcs);
            
            leankor__Subscriber__c sub = new  leankor__Subscriber__c();
            sub.leankor__KanbanCard__c = kccard.Id;
                sub.leankor__SubscriberKey__c   = TestDataFactory.createGuid();
                    subList.add(sub);
            
            leankor__ScheduleMode__c sched = new leankor__ScheduleMode__c();
            sched.leankor__KanbanCard__c = kccard.Id;
                    schedList.add(sched);
            
            leankor__ResourceAssignment__c ra = new leankor__ResourceAssignment__c();
            ra.leankor__KanbanCard__c = kccard.Id;
                    raList.add(ra);
            
            leankor__KanbanCardBaseline__c kcb = new leankor__KanbanCardBaseline__c();
            kcb.leankor__KanbanCard__c = kccard.Id;
                    kcbList.add(kcb);
            
                EntitySubscription entity = new EntitySubscription();
                entity.ParentId = kccard.id;
                entity.SubscriberId =userinfo.getUserId();
                entityList.add(entity); 
            
                leankor__ZoneKanbanAction__c zonekanban = new leankor__ZoneKanbanAction__c();
                zoneKanban.leankor__kanbancard2__c = kccard.Id; 
                zoneKanban.leankor__valuestream__c = kccard.leankor__valuestream__c ; 
                zoneKanbanList.add(zoneKanban);  
                    
            }
            insert zoneKanbanList; 
            insert kcsList;
            insert subList;
            insert schedList;
            insert raList;
            insert kcbList;
            //insert entityList;
            // There are 6 valuestream we have inserted in testSetup so other records should be greater than that.
            system.assert(limits.getdmlrows()>6);
            test.startTest();
            database.executebatch(new leankor.PurgeSoftDeletedRecords());     
            
            test.stopTest();    
        
      }
      
       //Rs 15/3/2018
       static testmethod void testDeleteSecurityRecords(){
       UserRole userR=[SELECT Id,Name,ParentRoleId,RollupDescription FROM UserRole limit 1 ];
      
            leankor__ValueStream__c vStream = new leankor__ValueStream__c();
            vStream.Name = 'k1';     
            vStream.leankor__BoardType__c = 'kanban Board';
            insert vStream;
       
            leankor__Security__c secur =  new leankor__Security__c();
            secur.leankor__ValueStream__c = vStream.Id;
            secur.leankor__OwnerEditCard__c = false;
            secur.leankor__OwnerMoveCard__c = false;
            secur.leankor__UserRoleID__c = userR.id;
            secur.leankor__GUID__C = '1234'+system.now().getTime();
            insert secur;   
            
			Test.startTest();
           DeleteSecurityRecords deleteSecurity = new DeleteSecurityRecords();
           database.executebatch(new leankor.DeleteSecurityRecords()); 
			Test.stopTest();   
			List<leankor__Security__c> Securities = [SELECT Id FROM leankor__Security__c WHERE leankor__ValueStream__c =: vStream.Id];
			System.assert(Securities.size() == 0);
       } 
}