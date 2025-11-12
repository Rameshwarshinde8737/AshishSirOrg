@isTest
private with sharing class FavoriteItemTest {
    static testMethod void testFavoriteItem(){
        List<leankor__ProjectFavorite__c> projectFavorites = new List<leankor__ProjectFavorite__c>();
        List<leankor__ProjectBoardFavorite__c> projectBoardFavorites = new List<leankor__ProjectBoardFavorite__c>();
        List<leankor__KanbanCardFavorite__c> kanbanCardFavorites = new List<leankor__KanbanCardFavorite__c>();
        
        User u = leankor.TestDataFactory.createStandardUser('Lean123');	
        List<leankor__Portfolio__c> folderList = leankor.TestDataFactory.createFolder('Test Folder', 1);
        List<leankor__ProjectRoom__c> projects = leankor.TestDataFactory.createProjects('Test Project', folderList, 5);  
        List<leankor__Valuestream__c> projectBoards = leankor.TestDataFactory.createValueStream(projects, 'Kanban Board', u);
        leankor__KanbanCardTemplate__c template = leankor.TestDataFactory.createKanbanCardTemplate(projectBoards[0]); 
        List<leankor__KanbanCard__c> kanbanCards = leankor.TestDataFactory.createKanbanCard(projectBoards[0],template,5,null,u);	

        for(leankor__ProjectRoom__c project : projects){
            leankor__ProjectFavorite__c projectFavorite = new leankor__ProjectFavorite__c(Name = project.Name, leankor__Project__c = project.Id);
            projectFavorites.add(projectFavorite);
        }
        for(leankor__ValueStream__c valueStream : projectBoards){
            leankor__ProjectBoardFavorite__c projectBoardFavorite = new leankor__ProjectBoardFavorite__c(Name = valueStream.Name, leankor__ProjectBoard__c = valueStream.Id);
            projectBoardFavorites.add(projectBoardFavorite);
        }
        for(leankor__KanbanCard__c kanbanCard : kanbanCards){
            leankor__KanbanCardFavorite__c kanbanCardFavorite = new leankor__KanbanCardFavorite__c(Name = kanbanCard.Name, leankor__Activity__c = kanbanCard.Id);
            kanbanCardFavorites.add(kanbanCardFavorite);
        }

        INSERT projectFavorites;
        INSERT projectBoardFavorites;
        INSERT kanbanCardFavorites;
    
        List<leankor.FavoriteItem.Favorite> favorites = new List<leankor.FavoriteItem.Favorite>();
        for(leankor__ProjectFavorite__c projectFavorite : projectFavorites){
            leankor.FavoriteItem.Favorite favorite = new leankor.FavoriteItem.Favorite();
            favorite.id = projectFavorite.Id;
            favorite.type = 'Project';
            favorites.add(favorite);
        }
        for(leankor__ProjectBoardFavorite__c projectBoardFavorite : projectBoardFavorites){
            leankor.FavoriteItem.Favorite favorite = new leankor.FavoriteItem.Favorite();
            favorite.id = projectBoardFavorite.Id;
            favorite.type = 'Board';
            favorites.add(favorite);
        }
        for(leankor__KanbanCardFavorite__c kanbanCardFavorite : kanbanCardFavorites){
            leankor.FavoriteItem.Favorite favorite = new leankor.FavoriteItem.Favorite();
            favorite.id = kanbanCardFavorite.Id;
            favorite.type = 'Card';
            favorites.add(favorite);
        }
        
        Test.startTest(); 
        List<leankor.FavoriteItem.Favorite> favoriteItems = leankor.FavoriteItem.readFavoriteItems();
        System.assert(favoriteItems != null);
        String result = leankor.FavoriteItem.removeFavoriteItems(favorites);
        System.assertEquals('Success', result);
        Test.stopTest();
    }
}