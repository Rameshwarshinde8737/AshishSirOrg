/* Files Connect Repository Resources
https://developer.salesforce.com/docs/atlas.en-us.chatterapi.meta/chatterapi/connect_resources_content-hub.htm
 */

global with sharing class FilesConnect {
	@TestVisible
	private static final String VERSION ='v55.0';

	public FilesConnect(Util controller) {}
	
    global FilesConnect(ApexPages.StandardController controller) {
	}

    global FilesConnect(){
    }

	/*
		Date: 13/02/2020 
        Now using getOrgDomainUrl- no need to register URL in remote site setting 
	 */
	//public static final String FILES_CONNECT = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/connect/content-hub';
	public static final String FILES_CONNECT = System.URL.getOrgDomainUrl().toExternalForm() + '/services/data/'+VERSION+'/connect/content-hub';
    public static final String SESSION_ID = UserInfo.getSessionID();
	
	
	global FilesConnect(ApexPages.StandardSetController controller) {
	}
	
	class FilesConnectException extends Exception {}
	
    global class Repository {
        public String id;
        public String label;
        public String iconUrl;
        public String type;
        public String externalDocumentInfo1;
        public String name;
        public String title;
        public String repositoryId;
        public String folderId;
        public String verb;
        public String owner;
        public String modifiedDate;
        public Integer count;
        public Integer offsetSize;
        public List<ContentDocument> contentDocuments;      
        public String fileName;
        public Boolean isFolder;       
    }
    
    /*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	get connected files using different verbs 
	Inputs: 		String requiredConnectedData
	Returns: 		list < Repository >
	------------------------------------------------------------*/ 
     @RemoteAction
	global static list < Repository > getConnectedFiles(String requiredConnectedData) {
		list < Repository > repo;
		Repository repositoryInstance ; 
		
		try {
			repositoryInstance = (Repository)JSON.deserialize(requiredConnectedData, Repository.class);		
			Switch on repositoryInstance.verb {
						when 'Repository' {
							repo = getExternalRepositories();
						}
						when'RootItems' {							
							repo = getRootItems(RepositoryInstance.repositoryId);						
							 //HttpResponse response = getRepositoryResource('/repositories/' + RepositoryInstance.repositoryId + '/folders/root/items');
            				 //repo = getItems(response.getBody());
						}
						when 'FolderItems'{
							repo = getFolderItems(repositoryInstance.repositoryId,repositoryInstance.folderId); 
						}
						when else {
							 return new list < Repository > ();
						}
					}	
		}catch (Exception e) {
            //throw new FilesConnectException(e);
            return new list < Repository > ();
        }
		return repo ;
	}        
    
   /*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	helper method to retrive external repositories 
	Inputs: 		-
	Returns: 		list < Repository >
	------------------------------------------------------------*/
    // Get a list of Files Connect repositories
    public static list < Repository > getExternalRepositories() {
       list < Repository > repo;
        try {
             HttpResponse response = getRepositoryResource('/repositories');				
             //repo = getExternalRepositoriesHelper(JSON.Serialize(ConnectApi.ContentHub.getRepositories()));            
             repo = getExternalRepositoriesHelper(response.getbody());
           
        } catch (Exception e) {
            //throw new FilesConnectException(e);
            return new list < Repository > ();
        }

        return repo;
    }
    
    /*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	External Repositories Helper
	Inputs: 		string response
	Returns: 		list < Repository >
	------------------------------------------------------------*/ 
	@TestVisible
    private static list < Repository > getExternalRepositoriesHelper(string response) {
    	list < Repository > repositories = new list < Repository > ();
            try {
                Map < String,Object > root = (Map < String, Object > )JSON.deserializeUntyped(response);
                
                List < Object > myMapObjects = (List < Object > )root.get('repositories');
	
                for (Object obj: myMapObjects) {

                    Repository rp = new Repository();
                    Map < String,Object > motifMap = (Map < String, Object > )(((Map < String, Object > )obj).get('motif'));

                    rp.id = (string)((Map < String, Object > )obj).get('id');
               		rp.label = (string)((Map < String, Object > )obj).get('label');
                    rp.iconUrl = (string)motifMap.get('mediumIconUrl');

                    Map < String,Object > providerTypeMap = (Map < String, Object > )(((Map < String, Object > )obj).get('providerType'));
                    rp.type = (string)providerTypeMap.get('type');

                    repositories.add(rp);
                }
           	} catch (Exception e) {
            	system.debug(e.getMessage());
                //throw new FilesConnectException(e);
           	}
        return repositories;
    }
    
    /*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	To get rootitems 
	Inputs: 		String repositoryId
	Returns: 		list < Repository >
	------------------------------------------------------------*/ 	 
    // Get folder items  
    public static List < Repository > getRootItems(String repositoryId) {
        List < Repository > rootItems;
        try {
            HttpResponse response = getRepositoryResource('/repositories/' + repositoryId + '/folders/root/items');

            rootItems = getItems(response.getBody());
        } catch (Exception e) {
            //throw new FilesConnectException(e);
            return new list < Repository > ();
        }
        return rootItems;
    }
    
    /*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	To get folder items   
	Inputs: 		String repositoryId,String folderId
	Returns: 		list < Repository >
	Modified : 		SS 19.09.2018 
					//Modified for getting items  
	------------------------------------------------------------*/
    public static List < Repository > getFolderItems(String repositoryId,String folderId) {
        List < Repository > rootItems;
        try {
            	HttpResponse response = getRepositoryResource('/repositories/' + repositoryId + '/folders/' + folderId+ '/items');			
               	//rootItems = getItems(JSON.Serialize(ConnectApi.ContentHub.getRepositoryFolderItems(repositoryId,folderId)));         
             	rootItems = getItems(response.getbody());                                
            } catch (Exception e) {
           	//throw new FilesConnectException(e);
          	 return new list < Repository > ();
       		}
        return rootItems;
    } 
        
    /*------------------------------------------------------------
	Author: 		Reynald ocampo 
	Company: 		Leankor
	Description: 	for Rest callout 
	Inputs: 		String repositoryResource
	Returns: 		HttpResponse
	------------------------------------------------------------*/    
    public static HttpResponse getRepositoryResource(String repositoryResource) {
        Http requestResponse = new Http();
        HttpResponse response;
        try {
            // configure request
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', 'Bearer ' + SESSION_ID);
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(FILES_CONNECT + repositoryResource);
            request.setMethod('GET');

            // configure response
            response = requestResponse.send(request);

        } catch (System.CalloutException e) {
            throw new FilesConnectException(e);
        }
        return response;
    }

	/*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	To get items  
	Inputs: 		string response
	Returns: 		list < Repository >
	Modified Date:  SS 09.09.2018 
				    //Add repositoryId in response with folder item details
	------------------------------------------------------------*/
	@TestVisible
    private static List < Repository > getItems(string response) {
        list < Repository > repositories = new list < Repository > ();

        try {
            Map < String,Object > root = (Map < String, Object > )JSON.deserializeUntyped(response);

            List < Object > myMapObjects = (List < Object > )root.get('items');

            for (Object obj: myMapObjects) {
                Repository rp = new Repository();

                rp.type = (string)((Map < String, Object > )obj).get('type');
                Map < String,Object > mapItems;

                if (rp.type == 'folder') {
                    mapItems = (Map < String, Object > )(((Map < String, Object > )obj).get('folder'));
                    rp.name = (string)((Map < String, Object > )mapItems).get('name');
                } else {
                    mapItems = (Map < String, Object > )(((Map < String, Object > )obj).get('file'));
                    rp.externalDocumentInfo1 = (string)((Map < String, Object > )mapItems).get('externalDocumentUrl');
                    rp.title = (string)((Map < String, Object > )mapItems).get('title');
                    rp.name = (string)((Map < String, Object > )mapItems).get('title');
                }

                rp.id = (string)((Map < String, Object > )mapItems).get('id');
                //rp.name = (string)((Map < String, Object > )mapItems).get('name');
                rp.owner = (string)((Map < String, Object > )mapItems).get('createdBy');
                rp.modifiedDate = (string)((Map < String, Object > )mapItems).get('modifiedDate');

                Map < String,Object > motifMap = (Map < String, Object > )(((Map < String, Object > )mapItems).get('motif'));
                Map < String,Object > repoMap = (Map < String, Object > )(((Map < String, Object > )mapItems).get('repository'));
                rp.iconUrl = (string)motifMap.get('mediumIconUrl');
                rp.repositoryId = (string)repoMap.get('id');
                repositories.add(rp);
            	}
        }catch (Exception e) {
            throw new FilesConnectException(e);
        }

        return repositories;

    }   
     
  
  	/*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	To attach file  
	Inputs: 		kanbanController.ChatterFileContent content
	Returns: 		boolean
	------------------------------------------------------------*/
	@RemoteAction 
	global static leankor.kanbanController.ChatterFileContent attachFile(String contentData){
		
		// Create a savepoint
		Savepoint sp = Database.setSavepoint();
		leankor.kanbanController.ChatterFileContent content ;
		leankor.kanbanController.ChatterFileContent chatterContent ; 
		
		try {			
			content = (leankor.kanbanController.ChatterFileContent)JSON.deserialize(contentData, (leankor.kanbanController.ChatterFileContent.Class));			
			Switch on content.sourceType {
				when 'ExternalFiles' {
					chatterContent = attachExternalFile(content);
				}					
			}												
		} catch (Exception e) {
			Database.rollback(sp);
			chatterContent = null ; 
			//return chatterContent; 
			throw new FilesConnectException(e);
	   	}
		return chatterContent;
	}	
	
	/*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	helper method to attach external file 
	Inputs: 		kanbanController.ChatterFileContent content
	Returns: 		leankor.kanbanController.ChatterFileContent
	------------------------------------------------------------*/
	public static leankor.kanbanController.ChatterFileContent attachExternalFile(leankor.kanbanController.ChatterFileContent contents) {		
		
		//Check CRUD / FLC behavior
        ContentVersionBehaviour contentVersionBehaviour = new ContentVersionBehaviour();
		FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (
            !contentVersionBehaviour.isAccessible() ||
            !contentVersionBehaviour.isCreateable() ||
			!feedItemBehaviour.isAccessible() ||
			!feedItemBehaviour.isCreateable()
        ) {
            throw new Util.LeanException('Error: No access to records');
		}
        //Check CRUD / FLC behavior
		
		leankor.kanbanController.ChatterFileContent content ;
		try {
			content = contents;
			ContentVersion cv = new ContentVersion();
			cv.ExternalDataSourceId = content.ExternalDataSourceId;
			cv.ExternalDocumentInfo1 = content.ExternalDocumentInfo1;
			cv.ExternalDocumentInfo2 = content.documentId;
			cv.VersionData = blob.ValueOf('1');
			cv.ContentLocation = 'E';
			cv.origin = 'H';
			cv.PathOnClient = content.name;
			cv.Title = content.Title;
			insert cv;
	
			FeedItem fi = new FeedItem();
			fi.Body = '';
			fi.ParentId = content.ParentId;
			fi.RelatedRecordId = cv.Id;
			insert fi;
	
			ContentVersion contVersion = [SELECT ContentDocumentId,Title FROM ContentVersion WHERE Id = : cv.Id limit 1];
	
			content.RelatedRecordId = fi.RelatedRecordId;
			content.ParentId = fi.ParentId;
			content.ContentLocation = cv.ContentLocation;
			content.ContentDocumentId = contVersion.ContentDocumentId;
			content.Title = contVersion.Title;
			/*
			*Modified By :Ashutosh Gour
			*Modification : Modification for making SOQL selective and remove negative selection.
			*/
			/*content.comments = [SELECT count()FROM leankor__KanbanCard__Feed WHERE ParentID = : content.ParentId 
			AND Type != 'TrackedChange' LIMIT 9999];*/
			List<leankor__KanbanCard__Feed> kcFeedList = new List<leankor__KanbanCard__Feed>();
			for (leankor__KanbanCard__Feed kcFeed : [Select 
														Id,
														Type
													From leankor__KanbanCard__Feed 
													Where ParentID = : content.ParentId
													With Security_Enforced 
													Limit 9999]) {
				if (kcFeed.Type != 'TrackedChange') {
					kcFeedList.add(kcFeed);
				}
			}
			content.comments = kcFeedList.size();
		} catch (Exception e) {			
			throw new FilesConnectException(e);			
		}
	
		return content;
	
	}
	
// 	global class FileUploadData {

//     @AuraEnabled
//     public String parentId { get; set; }

//     @AuraEnabled
//     public String contentVersionId { get; set; }

// }

	global class FileUploadData {
        //Public String base64File;
        //Public String contentType;
        //Public String title;
        public String parentId;
        public String contentVersionId;  
    }

	/*------------------------------------------------------------
	Author: 		Rahul Solanki 
	Company: 		Leankor
	Description: 	method to upload file 
	Inputs: 		FileUploadData uploadData
	Returns: 		leankor.kanbanController.ChatterFileContent
	------------------------------------------------------------*/
	@RemoteAction
	
 	global static leankor.kanbanController.ChatterFileContent uploadFile(FileUploadData uploadData) {		
		System.debug(uploadData);
		//Check CRUD / FLC behavior
        FeedItemBehaviour feedItemBehaviour = new FeedItemBehaviour();
        if (!feedItemBehaviour.isAccessible() || !feedItemBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
		}
        //Check CRUD / FLC behavior
		if (String.isNotBlank(uploadData.contentVersionId) && Util.getSObjectName(uploadData.contentVersionId) != 'ContentVersion') {
			throw new Util.LeanException('Error: Invalid input');
		}
		
		leankor.kanbanController.ChatterFileContent content = new leankor.kanbanController.ChatterFileContent();
		try {		
			//As Visibility field is not available for the org's which does not community enabled 
			//We have changed the code to sObject;
			sObject sObjFeed = new FeedItem();
			sObjFeed.put('Body','');
			sObjFeed.put('ParentId', uploadData.parentId);
			sObjFeed.put('RelatedRecordId', uploadData.contentVersionId);
			//Visibility is causing exception when files uploaded by external users
			//For external users we need to set visibility of contentDocument record's to AllUsers
			if (Network.getNetworkId() != null) {
				sObjFeed.put('Visibility','AllUsers');
			}
			Database.insert(sObjFeed, true);
	
			ContentVersion contVersion = [Select 
												ContentDocumentId,
												ContentLocation,
												Title 
											From ContentVersion 
											Where Id = : uploadData.contentVersionId 
											Limit 1];
	
			content.RelatedRecordId = (String) sObjFeed.get('RelatedRecordId');
			content.ParentId = (String) sObjFeed.get('ParentId');
			content.ContentLocation = contVersion.ContentLocation;
			content.ContentDocumentId = contVersion.ContentDocumentId;
			content.Title = contVersion.Title;

			List<leankor__KanbanCard__Feed> kcFeedList = new List<leankor__KanbanCard__Feed>();
			for (leankor__KanbanCard__Feed kcFeed : [Select 
															Id,
															Type
														From leankor__KanbanCard__Feed 
														Where ParentID = : uploadData.parentId 
														With Security_Enforced
														Limit 9999]) {
				if (kcFeed.Type != 'TrackedChange') {
					kcFeedList.add(kcFeed);
				}
			}
			content.comments = kcFeedList.Size();
		} catch (Exception e) {			
			throw new FilesConnectException(e);					
		}
		return content;
	}

	@AuraEnabled
	public static LwcChatterFileContent uploadFileAura(FileUploadRequest uploadRequest){
		LwcChatterFileContent fileContent = new LwcChatterFileContent();
	   System.debug('Upload Request==>'+uploadRequest);		
		//try {
			FileUploadData data = new FileUploadData();
			data.parentId = uploadRequest.parentId;
			data.contentVersionId = uploadRequest.contentVersionId;
			leankor.kanbanController.ChatterFileContent chatterFileContent = FilesConnect.uploadFile(data);
			
            fileContent.Id = chatterFileContent.Id;
            fileContent.LastModifiedDate = chatterFileContent.LastModifiedDate;
            fileContent.LinkUrl = chatterFileContent.LinkUrl;
            fileContent.ParentId = chatterFileContent.ParentId;
            fileContent.RelatedRecordId = chatterFileContent.RelatedRecordId;
            fileContent.Status = chatterFileContent.Status;
            fileContent.SystemModstamp = chatterFileContent.SystemModstamp;
            fileContent.Title = chatterFileContent.Title;
            fileContent.Type = chatterFileContent.Type;
            fileContent.ExternalDocumentInfo1 = chatterFileContent.ExternalDocumentInfo1;
            fileContent.ContentLocation = chatterFileContent.ContentLocation;
            fileContent.ExternalDataSourceId = chatterFileContent.ExternalDataSourceId;
            fileContent.ContentDocumentId = chatterFileContent.ContentDocumentId;
            fileContent.externalDocumentInfo2 = chatterFileContent.externalDocumentInfo2;
            fileContent.name = chatterFileContent.name;
            fileContent.documentId = chatterFileContent.documentId;
            fileContent.sourceType = chatterFileContent.sourceType;
            fileContent.comments = chatterFileContent.comments;
            fileContent.latestPublishedVersionId = chatterFileContent.latestPublishedVersionId;	
		//}	
		/*catch(Exception e) {
			throw new FilesConnectException(e);	
		}*/
		return fileContent;	
	}
  
    @RemoteAction
    global static List < Repository > globalSearchFileInRepository(String searchData){
        List <Repository> searchItemList = new List <Repository >();
       	try{
       		Repository searchItems = (Repository)JSON.deserialize(searchData, (Repository.Class));
	        String repositoryId = searchItems.repositoryId;
	        String parentId = searchItems.folderId;
	        String queryString = 'FIND \''+String.escapeSingleQuotes(searchItems.fileName) +'\' IN  NAME FIELDS  RETURNING ContentHubItem(Id ,name, title,FileType,isFolder, ExternalDocumentUrl, ContentHubRepositoryId, Owner, ContentModifiedDate, ExternalContentUrl where ContentHubRepositoryId =:repositoryId limit 2000)';
	      
	        List <List<SObject>> sObjectList = Search.query(queryString);
        	for(List<SObject> sObjList : sObjectList){
        		for(SObject sObje : sObjList){
		        	Repository repoInstance = new Repository();
		        	repoInstance.Id = sObje.get('Id') == null ? '' : String.valueof(sObje.get('Id'));
		        	repoInstance.name = sObje.get('name') == null ? '' : String.valueof(sObje.get('name'));
		        	repoInstance.title = sObje.get('title') == null ? '' : String.valueof(sObje.get('title'));
		        	repoInstance.type = Boolean.valueof(sObje.get('isFolder')) ? 'Folder' : 'File';
		        	repoInstance.externalDocumentInfo1 = sObje.get('ExternalDocumentUrl') == null ? '' : String.valueOf(sObje.get('ExternalDocumentUrl'));
		        	repoInstance.owner = sObje.get('Owner') == null ? '' : String.valueof(sObje.get('Owner'));
		        	repoInstance.modifiedDate = sObje.get('ContentModifiedDate') == null ? '' : String.valueof(sObje.get('ContentModifiedDate'));	
		        	repoInstance.repositoryId = sObje.get('ContentHubRepositoryId') == null ? '' : String.valueof(sObje.get('ContentHubRepositoryId'));
		        	repoInstance.iconUrl = sObje.get('ExternalContentUrl') == null ? '' : String.valueof(sObje.get('ExternalContentUrl'));
		        	repoInstance.isFolder = Boolean.valueof(sObje.get('isFolder'));
		        	searchItemList.add(repoInstance);
                }
        	}	        
        }catch(Exception e){
        	throw new FilesConnectException(e);
        }
        return searchItemList;
    }
    
   }