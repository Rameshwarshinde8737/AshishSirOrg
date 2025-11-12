public with sharing class PlanBoard extends Board{
	public static void createPlanBoard(String valueStreamId){
        List<leankor__Zone__c> zones = new List<leankor__Zone__c>();
        //Create savepoint
        Savepoint newSavepoint = Database.setSavepoint();
        try {
        	ValueStream newValueStream = new ValueStream(ValueStream.PLAN_BOARD);
        	zones = CreateBoard(newValueStream);
            if(!zones.isEmpty()){
	            leankor.KanbanController.CloneBoard cBoard = new leankor.KanbanController.CloneBoard();
	            cBoard.VSID = valueStreamId;
	            cBoard.RealVSID = '';
	            cBoard.KanbanVerb = false;
	            cBoard.KanbanTemplateVerb = true;
	            cBoard.StickerVerb = false;
	            cBoard.TaskVerb = false;
	            cBoard.ZoneVerb = false;
	            cBoard.MarkerVerb = false;
	            cBoard.ChartVerb = false;
	            cBoard.BoardType ='Plan Board';
	            cBoard.LinkCloneRoomID = '';
	            cBoard.LinkCloneVSID = '';
	            cBoard.LinkCloneKanbanCardID = ''; 			
	            leankor.KanbanController.CloneSystemBoard(cBoard);
	        }
        }catch(Exception e) {
            //Rollback savepoint
            Database.rollback(newSavepoint);
            throw new Util.LeanException('ERROR:' + e.getMessage()); 
        }
    }
}