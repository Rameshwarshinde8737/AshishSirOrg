/**
* FILE:  FavoriteItem.cls
* CLASS: FavoriteItem
* USAGE: To retrieve and delete  favorite records .
*/
global with sharing class FavoriteItem {   	  

    private static final Integer LIMIT_READ_RECORD = 16500;
    private static final Integer LIMIT_DELETE_RECORD = 3300;
	  
    public FavoriteItem(ApexPages.StandardSetController controller) {}
    
    global class Favorite {      
        public String recordId;            
    	public String id;
    	public String boardId;
        public String projectId;
    	public String type;
    	public String boardType;
    	public String name;
    	public DateTime lastModifiedDate;
    	public String  projectName;
    	public String itemType;   	    	    
    }
    
    /*-------------------------------------------------------------------------------   	
		Author:        Vijay Jayswal
		Company:       Leankor
		Description:  To get FavoriteItem records for project,board card .
		Inputs:      
		Output:   	  List<Favorite>
		Date :	     04/02/2020		
	-------------------------------------------------------------------------------*/		              
    @RemoteAction
    global static List<Favorite> readFavoriteItems() {

		Id userId = UserInfo.getUserId();

    	List<Favorite> favoritItemList = new List<Favorite>();
		List<Sobject> sObjectList = new List<Sobject>();
		
		readProjectFavoriteItems(favoritItemList, userId);
		readProjectBoardFavoriteItems(favoritItemList, userId);
		readKanbanCardFavoriteItems(favoritItemList, userId);
    	 
    	return favoritItemList;
	} 

	@AuraEnabled(cacheable=true)
	public static List<FavoriteItems> readFavoriteItemsAura() {
		try {
			List<Favorite> favoriteItem = readFavoriteItems(); 
			List<FavoriteItems> result = new List<FavoriteItems>();
			for (Favorite favorite : favoriteItem) {
				FavoriteItems favoriteItems = new FavoriteItems();
				favoriteItems.id = favorite.id;
				favoriteItems.boardId = favorite.boardId;
				favoriteItems.projectId = favorite.projectId;
				favoriteItems.type = favorite.type;
				favoriteItems.boardType = favorite.boardType;
				favoriteItems.name = favorite.name;
				favoriteItems.lastModifiedDate = favorite.lastModifiedDate;
				favoriteItems.projectName = favorite.projectName;
				result.add(favoriteItems);
			}
        return result;
			
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
	

     /*-------------------------------------------------------------------------------   	
		Author:        Vijay Jayswal
		Company:       Leankor
		Description:  To remove FavoriteItem records. .
		Inputs:      List<Favorite> favorites
		Output:   	  String
		Date :	     04/02/2020		
	-------------------------------------------------------------------------------*/	
    @RemoteAction
    global static String removeFavoriteItems(List<Favorite> favorites) {

		//Added Security code for sentize user Input
        for (Favorite favoriteRequest : favorites) {
            if ((String.isNotBlank(favoriteRequest.boardId) && Util.getSObjectName(favoriteRequest.boardId) != 'leankor__ValueStream__c')
			||(String.isNotBlank(favoriteRequest.projectId) && Util.getSObjectName(favoriteRequest.projectId) != 'leankor__ProjectRoom__c')
			||(String.isNotBlank(favoriteRequest.recordId) && Util.getSObjectName(favoriteRequest.recordId) != 'leankor__KanbanCard__c')){
                throw new Util.LeanException('Error: Invalid input');
            }
			if((String.isNotBlank(favoriteRequest.Id) && Util.getSObjectName(favoriteRequest.Id) != 'leankor__ProjectFavorite__c')
			&&(Util.getSObjectName(favoriteRequest.Id) != 'leankor__ProjectBoardFavorite__c')
			&&(Util.getSObjectName(favoriteRequest.Id) != 'leankor__KanbanCardFavorite__c')){
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        List<Sobject> deleteRecords = new List<Sobject>();
        Set<String> recordTypeSet = new Set<String>();
        Set<Id> recordIdSet = new Set<Id>();
        
        for(Favorite favorite : favorites){
            recordTypeSet.add(favorite.type);
            recordIdSet.add(favorite.id);
		}
		
		//Check CRUD / FLC behavior  
		ProjectFavoriteBehaviour ProjectFavoriteBehaviour = new ProjectFavoriteBehaviour();
		ProjectBoardFavoriteBehaviour ProjectBoardFavoriteBehaviour = new ProjectBoardFavoriteBehaviour();
		KanbanCardFavoriteBehaviour kanbanCardFavoriteBehaviour = new KanbanCardFavoriteBehaviour();
		if (
			recordTypeSet.contains('Project') &&
			(!ProjectFavoriteBehaviour.isDeletable())
		) {
			throw new Util.LeanException('Error: No access to records');
		}

		if (
			recordTypeSet.contains('Board') && 
			(!ProjectBoardFavoriteBehaviour.isDeletable()) 
		) {
			throw new Util.LeanException('Error: No access to records');
		}

		if (
			recordTypeSet.contains('Card') && 
			(!kanbanCardFavoriteBehaviour.isDeletable())
		) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior  

        if (recordTypeSet.contains('Project')) {
            deleteRecords.addAll([Select Id 
            						From leankor__ProjectFavorite__c 
            						Where Id In :recordIdSet 
									With Security_Enforced
            						Limit : LIMIT_DELETE_RECORD]);
        }

        if (recordTypeSet.contains('Board')) {
            deleteRecords.addAll([Select Id 
            						From leankor__ProjectBoardFavorite__c 
            						Where Id In :recordIdSet
									With Security_Enforced
            						Limit :LIMIT_DELETE_RECORD]);
        }

        if (recordTypeSet.contains('Card')) {
            deleteRecords.addAll([Select Id 
            						From leankor__KanbanCardFavorite__c 
            						Where Id In :recordIdSet 
									With Security_Enforced
            						Limit : LIMIT_DELETE_RECORD]);
        }

        try {
            if (deleteRecords.size() > 0) {              
            	Database.delete(deleteRecords); //TBD: should allow partial success and return records that are not successfully deleted
            }            
            return 'Success';
        } catch (DmlException ex) {
            // return 'Failed';
		    //25/04/2023 : We are Throwing Exception
		    throw new Util.LeanException('ERROR:' + ex.getMessage()); 	
        }
	}


	@testVisible
	private static void readProjectFavoriteItems(List<Favorite> favoritItemList, Id userId){
		//To retrieve ProjectFavorite recods  
    	for (leankor__ProjectFavorite__c obj:[Select Id, 
													Name, 
													leankor__Project__c, 
													LastModifiedDate,
													leankor__Project__r.Name 
												From leankor__ProjectFavorite__c 
												Where CreatedById = :userId
												With Security_Enforced 
												Order By LastModifiedDate
												Limit : LIMIT_READ_RECORD]) {	   	
    		Favorite favorite = new Favorite();
    		favorite.id = obj.Id;
    		favorite.name = obj.Name;		
    		favorite.recordId = obj.leankor__Project__c;   
    		favorite.type = 'Project';  
    		favorite.lastModifiedDate = obj.LastModifiedDate ;  
            favorite.projectName = obj.leankor__Project__r.Name; 		  		
    		favoritItemList.add(favorite);
		}  
	}

	@testVisible
	private static void readProjectBoardFavoriteItems(List<Favorite> favoritItemList, Id userId){
		//To retrieve ProjectBoardFavorite recods       
    	for (leankor__ProjectBoardFavorite__c obj :[Select Id, 
															Name, 
															leankor__ProjectBoard__c, 
															leankor__ProjectBoard__r.leankor__ProjectRoom__c, 
															leankor__ProjectBoard__r.leankor__BoardType__c,
															leankor__ProjectBoard__r.leankor__isRecordDeleted__c, 
															LastModifiedDate 
														From leankor__ProjectBoardFavorite__c 
														Where CreatedById = :userId 
														With Security_Enforced
														Order By LastModifiedDate 
														Limit : LIMIT_READ_RECORD]) {
    		
    		if (obj.leankor__ProjectBoard__c != null 
    		&& !obj.leankor__ProjectBoard__r.leankor__isRecordDeleted__c) {
	    		Favorite favorite = new Favorite();
	    		favorite.id = obj.Id; 
	    		favorite.name = obj.Name;	  		
	    		favorite.recordId = obj.leankor__ProjectBoard__c;  
	    		favorite.type = 'Board';
	    		favorite.boardType = obj.leankor__ProjectBoard__r.leankor__BoardType__c;
	    		favorite.recordId = obj.leankor__ProjectBoard__c;
	    		favorite.projectId = obj.leankor__ProjectBoard__r.leankor__ProjectRoom__c;   
	    		favorite.lastModifiedDate = obj.LastModifiedDate ;   		 		
	    		favoritItemList.add(favorite);
    		}
        }
	}

	@testVisible
	private static void readKanbanCardFavoriteItems(List<Favorite> favoritItemList, Id userId){
		//To retrieve KanbanCardFavorite recods 
    	for (leankor__KanbanCardFavorite__c obj :[Select Id, 
														Name, 
														leankor__Activity__c, 
														leankor__Activity__r.leankor__ValueStream__c,
														leankor__Activity__r.leankor__isRecordDeleted__c,
														leankor__Activity__r.leankor__ValueStream__r.leankor__isRecordDeleted__c,
														leankor__Activity__r.leankor__ValueStream__r.leankor__BoardType__c,
														leankor__Activity__r.leankor__ValueStream__r.leankor__ProjectRoom__c, 
														LastModifiedDate,
														leankor__Activity__r.RecordType.Name 
													From leankor__KanbanCardFavorite__c 
													Where CreatedById = :userId
													With Security_Enforced 
													Order By LastModifiedDate 
													Limit : LIMIT_READ_RECORD]) {
			
			if (obj.leankor__Activity__c != null 
			&& !obj.leankor__Activity__r.leankor__isRecordDeleted__c 
			&& obj.leankor__Activity__r.leankor__ValueStream__c != null
			&& !obj.leankor__Activity__r.leankor__ValueStream__r.leankor__isRecordDeleted__c) {	
	    		Favorite favorite = new Favorite();
	    		favorite.id = obj.Id; 
	    		favorite.name = obj.Name;	  		
	    		favorite.recordId = obj.leankor__Activity__c;  
	    		favorite.type = 'Card';
	    		favorite.BoardType = obj.leankor__Activity__r.leankor__ValueStream__r.leankor__BoardType__c;
	    		favorite.boardId = obj.leankor__Activity__r.leankor__ValueStream__c;
	    		favorite.projectId = obj.leankor__Activity__r.leankor__ValueStream__r.leankor__ProjectRoom__c; 
	    		favorite.lastModifiedDate = obj.LastModifiedDate ;
				favorite.ItemType  = obj.leankor__Activity__r.RecordType.Name; 	   		
	    		favoritItemList.add(favorite);
			}
    	}
	}





    /**/
    global class projectSetup {
	    public String viewType;
	    public Boolean openNewTab; 
	    public String projectId;
	    public String boardType;
    
    }
    @RemoteAction
    global static List<projectSetup> readProjectSetup(projectSetup prjtSetup){
    		List<projectSetup> favoriteList =new List<projectSetup>();
    		for(leankor__ProjectLaunchBehavior__c plb:[SELECT Id,
    												leankor__ViewType__c,
    												leankor__Module__c,
    												leankor__Module__r.leankor__BoardType__c,
    												leankor__OpenNewTab__c 
    												FROM leankor__ProjectLaunchBehavior__c WHERE leankor__Project__c=: prjtSetup.projectId ]){   			
    			if((plb.leankor__Module__r.leankor__BoardType__c=='_System_Board' &&  prjtSetup.boardType=='Kanban Board') ||
    				(plb.leankor__Module__r.leankor__BoardType__c=='_System_PlanBoard' && prjtSetup.boardType=='Plan Board') ||
    				(plb.leankor__Module__r.leankor__BoardType__c=='_System_UberBoard' && prjtSetup.boardType=='UberBoard') ||
    				(plb.leankor__Module__r.leankor__BoardType__c=='_System_Whiteboard' && prjtSetup.boardType=='Whiteboard') ||
    				(plb.leankor__Module__r.leankor__BoardType__c=='_System_DashBoard' && prjtSetup.boardType=='DashBoard')
    				){
    				System.debug(plb.leankor__ViewType__c);
    				projectSetup proj =new projectSetup();
    				proj.viewType=plb.leankor__ViewType__c;
    				proj.openNewTab=plb.leankor__OpenNewTab__c;
    				favoriteList.add(proj);
    			}
    		}
    		System.debug(favoriteList);
    		 return  favoriteList;
    }
  
}