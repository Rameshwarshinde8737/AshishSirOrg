public with sharing class CreateProjectBoardQueueable implements Queueable {
	private CloneProjectAction.CloneProjectRequest request;
	private List<leankor__ValueStream__c> syncBoards ; 
	private List<leankor__ValueStream__c> asyncBoards ;
	
	public CreateProjectBoardQueueable(CloneProjectAction.CloneProjectRequest request, List<leankor__ValueStream__c> syncBoards, List<leankor__ValueStream__c> asyncBoards){
		this.request = request;
		this.syncBoards =  syncBoards;
		this.asyncBoards =  asyncBoards;
	}
    public void execute(QueueableContext context) {
		//Since we have only PG as sync board in cloning so use single ValueStream Object
		if(syncBoards.size()<0){
			return;
		}   
		leankor__ValueStream__c board =  syncBoards[0];
		//Ashutosh - 25/06/2021 - Temporary variable added for cloning async Boards because request.targetProjectStartDateTime is modifing below.
		Datetime PreviousTargetProjectStartDate = request.targetProjectStartDateTime;
		Integer addDays = 0;
		Util.WorkWeek workWeek = new Util.WorkWeek(request.firstDayOfWeek, 5);
		
		List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest> requestBoards = new List<leankor.CloneProjectBoardAction.CloneProjectBoardRequest>();
		leankor.CloneProjectBoardAction.CloneProjectBoardRequest requestBoard = new leankor.CloneProjectBoardAction.CloneProjectBoardRequest();
		
		requestBoard.FolderName = request.sourceFolderName;
		requestBoard.ProjectRoom = request.sourceProjectName;
		requestBoard.ProjectBoard = board.Name;
		requestBoard.ProjectBoardId = board.Id;
		requestBoard.TargetFolderName = request.targetFolderName;
		requestBoard.TargetRoom = request.targetProjectName;   
		requestBoard.ProjectRoomId = request.sourceProjectId;
		requestBoard.TargetRoomId = request.relinkClonedProjectId;   
		requestBoard.projectEventCustomPayload = request.projectEventCustomPayload;        
	        
		// Ashutosh : 29/09/2021 : getting blackout of source project for calculating initial date.
		List<leankor__ProjectScheduleBlackout__c> sourceblackOut = [Select 
																leankor__EndDate__c,                                                                         
																leankor__StartDate__c
															From leankor__ProjectScheduleBlackout__c
															Where leankor__ProjectBoard__c =: board.Id
															With Security_Enforced
															Limit 10000];
		//Ashutosh : 05/11/2021 : Dynamic value of workWeek is added.
		Util.WorkWeek workWeekwithBlackout = new Util.WorkWeek(request.firstDayOfWeek, board.leankor__SevenDayWorkWeek__c == true ? 7 : 5, sourceblackOut);
		if(board.leankor__BoardType__c == 'UberBoard') 
		{
			requestBoard.TargetBoard = 'Plan Board' +'('+requestBoard.TargetRoom+')';
			//03.02.2017 yj truncate string because name limit is 80 character and name field is default so can not change limit
			if(requestBoard.TargetBoard.length() > 80)
			{         
					requestBoard.TargetBoard = requestBoard.TargetBoard.substring(0,79);
					requestBoard.TargetBoard = requestBoard.TargetBoard+')';       
			}  
		}
		if(request.targetProjectStartDateTime != null){
			//Date: 17/06/2019 - Changes for clone the plan gantt according to project launch date.
			if(request.targetLaunchDateTime != null || request.targetLaunchDate != null){
				AggregateResult[] minStartDate = [Select Min(leankor__StartDateTime__c) minimumDate 
													From leankor__KanbanCard__c 
													Where leankor__ValueStream__c = :board.Id 
														And leankor__IsRecordDeleted__c = FALSE 
														And leankor__ValueStream__r.leankor__IsRecordDeleted__c = FALSE
													With Security_Enforced];
				if(minStartDate[0].get('minimumDate') != null){    	
					DateTime minimumStartDate = (Datetime)minStartDate[0].get('minimumDate');
					//Add number of days to StartDate to maintain difference with ProjectLaunchDate              
					if(board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c!=null){
						//Ashutosh : 05/11/2021 : workWeekwithBlackout.getBusinessDays method will work for both 5 and 7 day workweek.
						addDays = workWeekwithBlackout.getBusinessDays(board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c.dateGMT(), minimumStartDate.dateGMT());
						DateTime tempDate = request.targetProjectStartDateTime;
						if (board.leankor__SevenDayWorkWeek__c == true) {
							request.targetProjectStartDateTime = addDays != 0 ? request.targetProjectStartDateTime + addDays : minimumStartDate.dateGMT();	
						}
						// Ashutosh : 29/09/2021 : for fiveday Workweek we are using custom getBusinessDays method.
						else{
							request.targetProjectStartDateTime = addDays != 0 ? workWeekwithBlackout.nextBusinessDate(request.targetProjectStartDateTime, addDays) : minimumStartDate.dateGMT();
						}

						if(board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c.dateGMT() == minimumStartDate.dateGMT()){
							request.targetProjectStartDateTime = tempDate;
						}
					}
				}
			}
		
			if(!workWeek.isWorkingDay(request.targetProjectStartDateTime.formatGMT('EEEE')) && board.leankor__SevenDayWorkWeek__c == false){
				/* Ashutosh - 25/06/2021 - Previously if request.targetProjectStartDateTime is falling on weekend in five day working week then always add 1 day into it
				but now in case of backward date we will substract 1 day from request.targetProjectStartDateTime */
				requestBoard.initialDate = addDays < 0 && request.IsCloneWithLaunchDate && board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c > request.targetProjectStartDateTime ? request.targetProjectStartDateTime - 1 : request.targetProjectStartDateTime + 1; 
				if(!workWeek.isWorkingDay(requestBoard.initialDate.formatGMT('EEEE'))){
					/* Ashutosh - 01/06/2021 - Previously if requestBoard.initialDate is falling on weekend in five day working week then always add 1 day into it
						but now in case of backward date we will substract 1 day from requestBoard.initialDate */
					requestBoard.initialDate = addDays < 0 && request.IsCloneWithLaunchDate && board.leankor__ProjectRoom__r.leankor__ProjectLaunchDateTime__c > request.targetProjectStartDateTime ? requestBoard.initialDate - 1 : requestBoard.initialDate + 1;
				}
			}else{
				requestBoard.initialDate = request.targetProjectStartDateTime;
			}       
		}       
		if(request.targetProjectDueDateTime != null)
		{
			if(!workWeek.isWorkingDay(request.targetProjectDueDateTime.formatGMT('EEEE')) && board.leankor__SevenDayWorkWeek__c == false){
				requestBoard.TargetDate = request.targetProjectDueDateTime-1;
				if(!workWeek.isWorkingDay(requestBoard.TargetDate.formatGMT('EEEE'))){
					requestBoard.TargetDate = requestBoard.TargetDate-1;            	 
				}
			}else{
				requestBoard.TargetDate = request.targetProjectDueDateTime;
			}                
		}               
		requestBoard.checkCloneProject = 'StopOriginalkanbanCardUpdate';
		requestBoard.isplancloned = request.isplancloned ;
		requestBoard.cloneFiles = request.cloneFiles;
		requestBoard.cloneCustomFields = request.cloneCustomFields;
		//Pratiksha : 05/04/2021 - Changes for Clone Sticker while Project cloning. 
		requestBoard.stickerVerb = request.cardStickerVerb; 
		requestBoards.add(requestBoard);
		CloneProjectAction.isClonedProject = true;
		CloneProjectAction.isExpense = request.expenses;            
		Savepoint sp = Database.setSavepoint();
    	try {               
			if( leankor.CloneProjectBoardAction.CloneProjectBoard(requestBoards).size()>0){
				//29/09/2021 : Changes for Async Sticker cloning.
				//Ashutosh : 08/11/2021 : condition added for calling cloneCardsSticker only when stickerVerb is true.
				if (requestBoard.stickerVerb) {
					CloneProjectRemainingRecord.cloneCardsSticker(CloneProjectAction.kanbanCardIdsForStickerStatic, CloneProjectAction.mapWithOldKanbanCardStatic);
				}

				for (leankor__ValueStream__c asynchCloneProjectBoard : asyncBoards) {       
					request.sevenDayWorkWeek = asynchCloneProjectBoard.leankor__SevenDayWorkWeek__c;
					// Ashutosh - 25/06/2021 - reassign the intial request.targetProjectStartDateTime value into it with help of temporary variable for fiveday workweek. 
					if (!request.sevenDayWorkWeek) {
						request.targetProjectStartDateTime = PreviousTargetProjectStartDate;
					}
						
					// Tilak: 01.07.2020
					// CloneProjectAction.asynchCreateProjectBoard(JSON.serialize(request), JSON.serialize(asynchCloneProjectBoard));   	
					CloneProjectAction cloneProjectrequest = new CloneProjectAction(request, asynchCloneProjectBoard);
					//System.enqueueJob(cloneProjectrequest);
					Database.executeBatch(cloneProjectrequest);
				}
			}   
			
			/***25/03/2021 - We have to send "EndClone" broadcast when only PG(Plan Gantt) selected to clone while project cloning because now we have 
			 	shifted EndClone platform event code in CloneProjectRemainingRecord batch(that is another process) and we are not calling CloneProjectRemainingRecord batch for the PG board, 
				with that reason from here we are sending EndClone Platform event */
			if(asyncBoards.size()==0) {    
				//Ramanand : 11/Sep/2023 - Changes : Changing ProjectEvent structure now will publish EndClone ProjectEvent from isBroadcast method. 
				/*//------------------- BEGIN platform event broadcast
				leankor__ProjectEvent__e pe = new leankor__ProjectEvent__e();
                
				pe.leankor__EventCategory__c = 'Cloning';
				pe.leankor__EventName__c = 'EndClone';
				pe.leankor__IsAPIGenerated__c = true;  // set true if in Leankor API
				pe.leankor__ProjectID__c = request.relinkClonedProjectId;
				pe.leankor__UserID__c = UserInfo.getUserId();
				pe.leankor__CustomPayload__c = request.projectEventCustomPayload;
		
				// Call method to publish events
				Database.SaveResult pe_result = EventBus.publish(pe);
		
				// quick error processing, no need to Rollback
				if (!pe_result.isSuccess()){
					for(Database.Error err : pe_result.getErrors()) {
						System.debug('Leankor Platform Event Error: ' + err.getStatusCode() + ' - ' + err.getMessage());
					}
					// continue on because a failed platform event is no big deal ; do NOT rollback
				}         
				//------------------- END platform event broadcast   */
				
				
				CloneProjectAction.isBroadcast(request);
			}
	    } catch (Exception ex) {
	    	Database.rollback(sp);
	        throw new CloneProjectAction.CloneProjectActionException(ex.getMessage());
	    } 
    }
}