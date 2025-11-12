public with sharing class KanbanBoard extends Board{
	public static void createKanbanBoard(String valueStreamId){
        ValueStream newValuestream;
        Mastercontainer newMasterContainer = new Mastercontainer();
        Swimlane newSwimlane = new Swimlane();
        Zone newZone = new Zone();
        KanbanCardTemplate newKanbanCardTemplate = new KanbanCardTemplate();

        List<MasterContainer> newMasterContainers = new List<MasterContainer>();
        List<Swimlane> newSwimlanes = new List<Swimlane>();
        List<Zone> newZones = new List<Zone>();
        List<KanbanCardTemplate> newKanbanCardTemplates = new List<KanbanCardTemplate>();
        
        leankor__ValueStream__c valueStreams = new leankor__ValueStream__c(); //Needs to be bulkified
        List<leankor__MasterContainer__c> masterContainers = new List<leankor__MasterContainer__c>();
        List<leankor__Swimlane__c> swimlanes = new List<leankor__Swimlane__c>();
        List<leankor__Zone__c> zones = new List<leankor__Zone__c>();
        List<leankor__KanbanCardTemplate__c> kanbanCardTemplates = new List<leankor__KanbanCardTemplate__c>();
        
        Integer masterContainerIndex = 0, swimlaneIndex = 0, zoneIndex = 0;
        Swimlane swimlaneType;
        //Create savepoint
        Savepoint newSavepoint = Database.setSavepoint();
        
        try {
             //Static class variable does not work as intended so using this 
            //Create local newValuestream.valueStream
            newValuestream = new ValueStream(ValueStream.KANBAN_BOARD);

            //Create server ValueStream
            //valueStreams = ValueStream.createValueStream(newValuestream.valueStream);
            List<leankor__ValueStream__c> vsList = new List<leankor__ValueStream__c>();
            vsList.add(newValuestream.valueStream);
            
			List<leankor__ValueStream__c> result = leankor.ValueStream.createValueStream(vsList);
            valueStreams = result.size() > 0 ? result[0] : new leankor__ValueStream__c();


            //Create and add local MasterContainers
            for(String key : MasterContainer.MASTERCONTAINERS.keySet()) {
                newMasterContainer = new MasterContainer(newValuestream.valueStream, MasterContainer.MASTERCONTAINERS.get(key), masterContainerIndex);
                newMasterContainers.add(newMasterContainer);
                masterContainerIndex++;
            }
            //Create server MasterContainers
            masterContainers = MasterContainer.createMasterContainers(newMasterContainers);
            //Create and add local Swimlanes
            for (leankor__MasterContainer__c masterContainer : masterContainers) {
            	//Manage consistent Swimlane color for default Systemswimlanes boards
                    swimlaneType = Swimlane.STANDARD;
                /*if(swimlaneIndex !=2) {
                    swimlaneType = Swimlane.STANDARD;
                }
                else {
                    swimlaneType = Swimlane.INPROGRESS;
                }*/
                newSwimlane = new Swimlane(masterContainer, swimlaneType, swimlaneIndex);
                newSwimlanes.add(newSwimlane);
                swimlaneIndex++;
            }
            //Create server Swimlanes
            swimlanes = Swimlane.createSwimlanes(newSwimlanes);
            
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
            
            //Create and add local kanbanCard templates
            for(String key : KanbanCardTemplate.KANBANCARD_TEMPLATES.keySet()) {
                newKanbanCardTemplate = new KanbanCardTemplate(newValuestream.valueStream, KanbanCardTemplate.KANBANCARD_TEMPLATES.get(key));
                newKanbanCardTemplate.setKanbanBoardKanbanCardTemplate(newKanbanCardTemplate);
                newKanbanCardTemplates.add(newKanbanCardTemplate);
            }
            //Create and add server kanbanCard templates
            kanbanCardTemplates = KanbanCardTemplate.createKanbanCardTemplates(newKanbanCardTemplates);

            //Update local valueStream
            valueStreams.leankor__DefaultCategory__c = kanbanCardTemplates[0].id;
            
            //Update server valueStream
            //ValueStream.updateValueStream(valueStreams);
            List<leankor__ValueStream__c> vsList1 = new List<leankor__ValueStream__c>();
            vsList1.add(valueStreams);
            ValueStream.updateValueStream(vsList1);

            if(!zones.isEmpty()){
                leankor.KanbanController.CloneBoard cBoard =new leankor.KanbanController.CloneBoard();
                cBoard.VSID = valueStreamId;
                cBoard.RealVSID = '';
                cBoard.KanbanVerb = false;
                cBoard.KanbanTemplateVerb = true;
                cBoard.StickerVerb = false;
                cBoard.TaskVerb = false;
                cBoard.ZoneVerb = true;
                cBoard.MarkerVerb = false;
                cBoard.ChartVerb = false;
                cBoard.BoardType ='Kanban Board';
                cBoard.LinkCloneRoomID = '';
                cBoard.LinkCloneVSID = '';
                cBoard.LinkCloneKanbanCardID = ''; 
                leankor.KanbanController.CloneSystemBoard(cBoard);
            }
        }catch(Exception e) {
            //Rollback savepoint
            Database.rollback(newSavepoint);
            //25/04/2023 : We are Throwing Exception
            throw new Util.LeanException('ERROR:' + e.getMessage());  
        }
    }
}