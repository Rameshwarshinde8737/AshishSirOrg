global with sharing  class ViewGanttController {

	private static List<String> resoruceList;
	private  static List<leankor__Portfolio__c> globalportfolioList = new List<leankor__Portfolio__c>();
    
    public ViewGanttController() {}
    public ViewGanttController(ApexPages.StandardSetController controller) {}
	public ViewGanttController(leankor.Util controller){}
	Public ViewGanttController(ApexPages.StandardController stdController) {}

	public PageReference Calendar_View() {
		return null;
	}
	  
	/*--------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	global wrapper class to return data on UI
	---------------------------------------------------------*/
	global Class CheckAccessWrapper {
		public boolean hasAccess;
		public String folder;
		public String project;
		public String valuestream;
	}

	/*------------------------------------------------------------
	Author: 		Rahul Solanki
	Company: 		Leankor
	Description: 	check access for miniature cards
	Inputs: 		List<String> recordIds
	Returns: 		List<CheckAccessWrapper>
	------------------------------------------------------------*/
	@RemoteAction
	global static List < CheckAccessWrapper > checkAccessForBoards(List < String > recordIds) {
		for(String recordId : recordIds){
			if (String.isNotBlank(recordId) && (Util.getSObjectName(recordId) != 'leankor__Valuestream__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
		}

		return leankor.RealTimeControllerHelper.checkAccessForBoards(recordIds);
	}

	/*------------------------------------------------------------
	Author: 		Suraj Sen
	Company: 		Leankor
	Description: 	Get list of activities whose dates are not equal 
					with its miniatures min StartDate and max DueDate
					Used on VF page PlanningModeViolations
	Inputs: 		--
	Returns: 		List<leankor__KanbanCard__c> 
	------------------------------------------------------------*/
	public static List<leankor__KanbanCard__c> getViolatedActivities() {
		return leankor.RealTimeControllerHelper.getViolatedActivities();
	}
	
	/*------------------------------------------------------------
	Company: 		Leankor
	Description: 	Get the list of project for with Shring class.
	Inputs: 		List<leankor__Portfolio__c>
	Returns: 		List<leankor__ProjectRoom__c> 
	------------------------------------------------------------*/
	global static List<leankor__ProjectRoom__c> getAllProjectOfFolderWithoutSharing(List<leankor__Portfolio__c> portId) {
		for(leankor__Portfolio__c portfolio : portId){
			if (String.isNotBlank(portfolio.Id) && (Util.getSObjectName(portfolio.Id) != 'leankor__Portfolio__c')) {
				throw new Util.LeanException('Error: Invalid input');
			}
		}
		return leankor.RealTimeControllerHelper.getAllProjectOfFolderWithoutSharing(portId);
    }

	/*--------------------------------------------------------------
	Author: 		Suraj Sen 
	Company: 		Leankor
	Description: 	get Folder record id from ValueStream
	Inputs: 		Id recordId
	Returns: 		string	(folder id)
	------------------------------------------------------------*/
	@RemoteAction 
    global static String getFolderId(Id recordId) {
		return leankor.RealTimeControllerHelper.getFolderId(recordId);
    }
}