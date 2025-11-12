import { api, LightningElement, track, wire } from 'lwc';
import getallParentFolder from '@salesforce/apex/realtimeKanbanController.getallParentFolder';
import getPortHierarchyAura from '@salesforce/apex/ProjectBoardCarousel.getPortHierarchyAura';
import createListPortfolioAura from '@salesforce/apex/ProjectBoardCarousel.createListPortfolioAura';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import LODASH from '@salesforce/resourceUrl/lodash';
import DEEPDASH from '@salesforce/resourceUrl/deepdash';
import {
  mutateTree,
  attachChildren,
  addKeyInObject,
  collapseDescendants
} from 'c/utils';
import removePortfolio from '@salesforce/apex/ProjectBoardCarousel.removePortfolio';
import deleteProjectRoom from '@salesforce/apex/ProjectBoardCarousel.deleteProjectRoom';
import createListProjectsAura from '@salesforce/apex/ProjectBoardCarousel.createListProjectsAura';
import manageNavChange from '@salesforce/apex/realtimeKanbanController.manageNavChange';
import getSessionId from '@salesforce/apex/GanttLWCExtraCode.getSessionId';
export default class AppContainer extends LightningElement {
    @api activeView = 'myWorkitems';
    @api vfUrl;
    @api recordId;
    @track isSidebarVisible = true;
    @track folders;
    @track sessionId;
    @track foldersForMove;
    loadedParents = new Set();  
    get isMyWork() {
        return this.activeView === 'myWorkitems';
    }

    get isPortfolioPage() {
        return this.activeView === 'portfolioPage';
    }

    get isVFPage() {
        return this.activeView === 'vfPage';
    }

    get isProjectNav() {
        return this.activeView === 'projectNav';
    }

    get toggleIconName() { 
        return this.isSidebarVisible ? 'icon-uniA21' : 'icon-uniA20'; 
    }

    get toggleButtonClass() {
        return this.isSidebarVisible ? 'sidebar-toggle open' : 'sidebar-toggle closed';
    }

    renderedCallback() {
        if (this.libsReady) return;
        this.libsReady = true;

        // For zipped static resources, append file name:
        const lodashUrl = `${LODASH}/lodash.js`;     // if single file, just LODASH
        const deepdashUrl = `${DEEPDASH}/deepdash.min.js`; // This now loads the non-standalone version
        Promise.all([
            loadScript(this, lodashUrl),
            loadScript(this, deepdashUrl)
        ])
            .then(() => {
                window.deepdash(window._);
            })
            .catch(e => {
                console.error('Failed to load lodash/deepdash:', e);
            });
    }

    connectedCallback() {
        this.template.addEventListener('openportfolio', this.handleOpenPortfolio.bind(this));
        this.template.addEventListener('openmywork', this.handleOpenMyWork.bind(this));

        this.loadParentFolders();
    }

    handleOpenVF(event) {
        this.activeView = 'vfPage';
        this.vfUrl = event.detail.vfUrl;
        this.toggleSidebarVisibility();
    }

    toggleSidebarVisibility() {
        this.isSidebarVisible = !this.isSidebarVisible;
    }

    handleOpenPortfolio() {
        this.activeView = 'portfolioPage';
        this.toggleSidebarVisibility(); // optional: auto-close sidebar
    }
    handleOpenMyWork() {
        this.activeView = 'myWorkitems';
        this.toggleSidebarVisibility(); // optional: auto-close sidebar
    }
    // folderItem component logic
    async loadParentFolders() {
        try {
            const data = await getallParentFolder();
            this.sessionId  = await getSessionId();
            this.folders = addKeyInObject(data, (folder) => ({
                chevronIcon: 'icon-uniA20',
                expanded: false,
                isPortfolio: folder.RoomType === 'Portfolio',
            }),
                window._
            )
            this.foldersForMove = JSON.parse(JSON.stringify(this.folders));
        } catch (error) {
            console.error('Error loading parent folders:', error);
        }
    }   


    handleAction(event) {
        const { type } = event.detail;
        switch (type) {
            case 'folderClick':
                this.handleFolderAction(event);
                break;
            case 'openProjectNav':
                this.handleShowProjectNav(event);
                break;
            case 'addFolder':
            case 'addProject':
                this.handleAddFolderProject(event);
                break;
            case 'edit':
                this.handleEditFolderProject(event);
                break;
            case 'delete':
                this.handleDeleteFolderProject(event);
                break;
            default:
                console.log('Unknown action type:', type);
                break;
        }
    }
    
    async handleAddFolderProject(event) {
        this.isLoading = true;
        const { folder, folderProjectName, type } = event.detail;
        const parentId = folder && folder.Id;
        const name = folderProjectName;

        try {
            let result
            if (type == 'addFolder') {
                result = await createListPortfolioAura({
                    portfoliodataList: [
                        { Id: "", Name: name, ParentPortfolio: parentId ? parentId : null }
                    ]
                });
            }else{
                result = await createListProjectsAura({
                    Prjlogs: { Id: "", Name: name, ParentPortfolio: parentId || null }
                });
            }

            const newItems = addKeyInObject(
                result,
                (f) => ({
                    chevronIcon: 'icon-uniA20',
                    expanded: false,
                    isPortfolio: f.RoomType === 'Portfolio',
                    ChildRecords: [],
                    showMenu: false
                }),
                window._
            );
            
            this.folders = attachChildren(this.folders, parentId, newItems, window._);
            this.showToast('Success', `${type === 'addFolder' ? 'Folder' : 'Project'} created successfully`, 'success');
        } catch (error) {
            console.error('Error creating folder/project:', error);
            this.showToast('Error', 'Failed to create folder/project', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleFolderAction(event) {
        const { folder } = event.detail;
        const id = folder.Id;
        const willExpand = !folder.expanded;
        const isMoveModal = event.detail.from === 'moveModal';
        let targetTree = isMoveModal ? [...this.foldersForMove] : [...this.folders];
        if (!willExpand) {
            // collapsing: close entire subtree
            targetTree = collapseDescendants(targetTree, id, window._);
            targetTree = mutateTree(targetTree, {
                type: 'update', id, patch: { expanded: false, chevronIcon: 'icon-uniA20', showMenu: false }
            }, window._);
            if (isMoveModal) {
                this.foldersForMove = targetTree;
            } else {
                this.folders = targetTree;
            }
            return;
        }

        // expanding: flip the node, then lazily fetch if needed
        targetTree = mutateTree(targetTree, {
            type: 'update', id, patch: { expanded: true, chevronIcon: 'icon-chevron-down', showMenu: false }
        }, window._);
        if (isMoveModal) {
            this.foldersForMove = targetTree;
        } else {
            this.folders = targetTree;
        }
        if (!this.loadedParents.has(id)) {
            this.loadSubFolders(id,isMoveModal);
        }
    }

    async handleEditFolderProject(event) {
        const { folder, folderProjectName } = event.detail;
        const cloned = { ...folder, Name: folderProjectName };
        const Verb = 'LeankorNAV'
        const SomeJSONData = JSON.stringify({
            ...cloned,
            verb: folder.RoomType === 'Portfolio' ? 'UpdateFolder' : 'UpdateProject'
        })
        const SessionID = this.sessionId;
        try {
            const result = await manageNavChange({ Verb, SomeJSONData, SessionID });
            this.folders = mutateTree(
                this.folders,
                { type: 'update', id: folder.Id, patch: { Name: cloned.Name } },
                window._
            );
            this.showToast('Success', `${folder.RoomType === 'Portfolio' ? 'Folder' : 'Project'} updated successfully`, 'success');
        } catch (error) {
            console.error('Error editing folder/project:', error);
        }
    }

    async loadSubFolders(parentId,isMoveModal = false) {
        try {
            const children = await getPortHierarchyAura({
                port: { Id: parentId, navigationVerb: 'LeankorNav' }
            });

            const decorated = (children || []).map(c => ({
                ...c,
                chevronIcon: 'icon-uniA20',
                expanded: false,
                isPortfolio: c.RoomType === 'Portfolio',
                ChildRecords: null,
                showMenu: false
            }));
            if (isMoveModal) {
                this.foldersForMove = attachChildren(this.foldersForMove, parentId, decorated, window._);
            } else {
                this.folders = attachChildren(this.folders, parentId, decorated, window._);
                // optionally deep clone for move modal
                this.foldersForMove = JSON.parse(JSON.stringify(this.folders));
            }

            this.loadedParents.add(parentId);
        } catch (error) {
            console.error('Error loading subfolders:', error);
        }
    }

    async handleDeleteFolderProject(event) {
        const { folder } = event.detail;
        try {
            if (folder.isPortfolio) {
                const result = await removePortfolio({ portfolioIds: [folder.Id] });
                if (result) {
                    this.folders = mutateTree(this.folders, { type: 'delete', id: folder.Id }, window._);
                    this.showToast('Success', 'Folder deleted successfully', 'success');
                }
            } else {
                const result = await deleteProjectRoom({ PrjID: folder.Id });
                if (result) {
                    this.folders = mutateTree(this.folders, { type: 'delete', id: folder.Id }, window._);
                    this.showToast('Success', 'Project deleted successfully', 'success');
                }
            }
        } catch (error) {
            console.error( error);
        }
    }

    handleMenu(event) {
        const targetId = event.detail.folder.Id;

        // Close all menus first
        let next = addKeyInObject(this.folders, () => ({ showMenu: false }), window._);
        // Open only the requested one
        next = mutateTree(next, { type: 'setKey', id: targetId, key: 'showMenu', value: true }, window._);
        this.folders = next;

    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleShowProjectNav(event) {
        this.activeView = 'projectNav';
    }

    async handleMoveFolderProject(event) {
        const { folderToMove, destinationFolder } = event.detail;

        try {
            const Verb = 'LeankorNAV';
            const SomeJSONData = JSON.stringify({
                ...folderToMove,
                verb: "MoveRoom",
                ParentPortfolio: destinationFolder?.Id || null,
                parentId: destinationFolder?.Id || null
            });

            await manageNavChange({ Verb, SomeJSONData, SessionID: this.sessionId });

            // Remove folder from current location
            let updatedTree = mutateTree(this.folders, {
                type: 'delete',
                id: folderToMove.Id
            }, window._);

            // Prepare node to insert (keep expanded true for top-level so it shows)
            const movedNode = {
                ...folderToMove,
                chevronIcon: 'icon-chevron-down', // expanded icon
                expanded: false,
                showMenu: false,
                depth: destinationFolder?.Id ? folderToMove.depth : 0
            };

            if (!destinationFolder?.Id) {
                // Top-level insert
                updatedTree = [movedNode, ...updatedTree]; // prepend to make top-level
            } else {
                // Insert as child
                updatedTree = attachChildren(
                    updatedTree,
                    destinationFolder.Id,
                    [movedNode],
                    window._,
                    false // do NOT expand parent
                );
            }

            this.folders = [...updatedTree];
            this.showToast('Success', 'Item moved successfully', 'success');

        } catch (error) {
            console.error('Error moving folder/project:', error);
            this.showToast('Error', 'Failed to move item', 'error');
        }
    }

}