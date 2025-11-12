import { api, LightningElement, track } from 'lwc';
import getProjectBoardHierarchyAura from '@salesforce/apex/ProjectBoardCarousel.getProjectBoardHierarchyAura';
import createListProjectBoardAura from '@salesforce/apex/ProjectBoardCarousel.createListProjectBoardAura';
import removeProjectBoard from '@salesforce/apex/ProjectBoardCarousel.removeProjectBoard';
import manageNavChange from '@salesforce/apex/realtimeKanbanController.manageNavChange';
import { mutateTree, findById, getObjectById  } from 'c/utils';
import getSessionId from '@salesforce/apex/GanttLWCExtraCode.getSessionId';
export default class BoardNavigation extends LightningElement {
    @api projectData
    @api boardList;
    @track isVisibleMenu = false;
    @track popupStyle = '';
    @track popupPositon = { top: 0, left: 0 }
    @track menuOption = [];
    @track isAddItem = false;
    @track placeholder = '';
    @track inputValue = '';
    @track selectedAction = '';
    @track selectedBoardId = '';
    @track showSpinner = false;
    sessionId
    // @api setLoading(isLoading) {
    //     this.showSpinner = isLoading;
    // }

    get buttonLabel() {
        return this.selectedAction.includes('edit') ? 'Update' : 'Add';
    }

    goToBack() {
        const event = new CustomEvent('showfoldernav', {
            detail: { value: 'test' },
            bubbles: true,  
            composed: true      
        });
        this.dispatchEvent(event);
    }

    connectedCallback() {
        this.handleLoadProjectBoards();
    }

    async handleLoadProjectBoards() {
        try {
            this.sessionId = await getSessionId();
            const result = await getProjectBoardHierarchyAura({
                projectRoomID: this.projectData.Id,
                RoomName: this.projectData.Name,
            })
            this.boardList = result.map(item => {
                return {
                    ...item,
                    boardType: item.boardType || item.name, // in case boardType is missing
                    ChildRecords: item.childRecords || [],
                    IsExpanded: false,
                    leaf: false,
                    showDots: item.boardType === 'UberBoard',
                    showArrowDots: (
                        item.name === 'ProjectBoards' ||
                        item.name === 'Whiteboards' ||
                        item.name === 'Dashboards'
                    )
                };
            })
        } catch (error) {
            console.error('Error loading project boards:', error);
        }
    }

    toggleMenu(event) {
        event.stopPropagation();
        const boardName = event.target.dataset.name;
        const boardId = event.target.dataset.id;

        this.menuOption = this.getMenuOption(boardName);

        const rect = event.currentTarget.getBoundingClientRect();
        this.popupPositon.top = rect.top + 35;
        this.popupPositon.left = rect.right - 35;
        this.popupStyle = `position: fixed; top: ${this.popupPositon.top}px; left: ${this.popupPositon.left}px; width: 180px; z-index: 1000;`;
        this.isVisibleMenu = true;
        this.isAddItem = false;
        this.selectedBoardId = boardId;

        if (this.isVisibleMenu) {
            setTimeout(() => document.addEventListener("click", this.handleOutsideClick), 0);
        }
    }

    handleOutsideClick = (event) => {
        const popup = this.template.querySelector('.custom-popup');
        const popover = this.template.querySelector('.slds-popover');
        if ((popup && !popup.contains(event.target)) || (popover && !popover.contains(event.target))) {
            this.isVisibleMenu = false;
            this.isAddItem = false;
            document.removeEventListener('click', this.handleOutsideClick, true);
        }
    }

    stopClose(event) {
        event.stopPropagation();
    }


    getMenuOption(boardName) {
        if (boardName === "UberBoard") {
            return [
                { id: 1, name: 'Edit Name', value: 'editPgName' },
                { id: 2, name: 'Quick Action', value: 'quickAction' }
            ];
        }
        if (boardName === "ProjectBoards") {
            return [
                { id: 1, name: 'Create Kanban Board', value: 'createKanbanBoard' }
            ];
        }
        if (boardName === "Whiteboards") {
            return [
                { id: 1, name: 'Create Whiteboard', value: 'createWhiteBoard' }
            ];
        }
        if (boardName === "Dashboards") {
            return [
                { id: 1, name: 'Create Leankor Dashboard', value: 'createLeankorDashboard' },
                { id: 2, name: 'Create Lightning Dashboard', value: 'createLightningDashboard' },

            ];
        }
        if (boardName === 'Kanban Board') {
            return [
                { id: 1, name: 'View Kanban', value: 'viewKanban' },
                { id: 2, name: 'View Calendar', value: 'viewCalendar' },
                { id: 3, name: 'Edit Name', value: 'editKbName' },
                { id: 4, name: 'Delete', value: 'delete' },
            ];
        }
        if (boardName === 'Whiteboard') {
            return [
                { id: 1, name: 'View White board', value: 'viewWhite' },
                { id: 2, name: 'View Calendar', value: 'viewCalendar' },
                { id: 3, name: 'Edit Name', value: 'editKbName' },
                { id: 4, name: 'Delete', value: 'delete' },
            ];
        }

        if (boardName === 'DashBoard') {
            return [
                { id: 1, name: 'View Dash Board', value: 'viewDash' },
                { id: 2, name: 'View Calendar', value: 'viewCalendar' },
                { id: 3, name: 'Edit Name', value: 'editKbName' },
                { id: 4, name: 'Delete', value: 'delete' },
            ];
        }
        return [];
    }

    handleMenuAction(event) {
        const action = event.currentTarget.dataset.value;
        this.selectedAction = action;
        this.isVisibleMenu = false;
        const board = this.findProjectBoardById(this.boardList, this.selectedBoardId);

        this.popupStyle = `position: fixed; top: ${this.popupPositon.top}px; left: ${this.popupPositon.left}px; width: 300px; z-index: 1000;`;

        switch (action) {
            case 'createKanbanBoard':
                this.placeholder = 'New Kanban Board';
                this.isAddItem = true;
                break;
            case 'createWhiteBoard':
                this.placeholder = 'New Whiteboard';
                this.isAddItem = true;
                break;
            case 'createLeankorDashboard':
                this.placeholder = 'New Leankor Dashboard';
                this.isAddItem = true;
                break;
            case 'editPgName':
            case 'editKbName':
                this.placeholder = 'Enter board name';
                this.inputValue = board ? board.name : '';
                this.isAddItem = true;
                break;
            case 'delete':
                this.deleteKanbanWhiteBoard();
                break;
            default:
                this.isAddItem = false;
        }
    }

    findProjectBoardById(boards, boardId) {
        for (let f of boards) {
            if (f.Id === boardId) return f;

            if (Array.isArray(f.childRecords) && f.childRecords.length > 0) {
                const found = this.findProjectBoardById(f.childRecords, boardId);
                if (found) return found;
            }
        }
        return null;
    }

    handleNameChange(event) {
        this.inputValue = event.target.value;
    }

    handleCreateFolder() {
        switch (this.selectedAction) {
            case 'createKanbanBoard':
                this.createKanbanWhiteBoard('kanbanBoard');
                break;
            case 'createWhiteBoard':
                this.createKanbanWhiteBoard('whiteBoard');
                break;
            case 'createLeankorDashboard':
                this.createKanbanWhiteBoard('dashboard');
                break;
            case 'editPgName':
                this.editBoardName();
                break;
            case 'editKbName':
                this.editBoardName();
                break;
        }
        this.isAddItem = false;
        this.selectedAction = '';
    }

    async createKanbanWhiteBoard(type) {
        if (!this.inputValue) {
            alert('Please enter a name for the Kanban Board.');
            return;
        }
        const boardTypeMap = {
            kanbanBoard: 1,
            whiteBoard: 2,
            dashboard: 3
        };
        const boardType = boardTypeMap[type] || null;
        try {
            const result = await createListProjectBoardAura({
                prjName: this.inputValue,
                projectRoomId: this.boardList[boardType].roomId,
                boardType: boardType == 3 ? 'DashBoard' : 'Kanban Board',
                projectBoardId: '',
                kanbanCardId: ''
            });
            let updatedBoards = JSON.parse(JSON.stringify(this.boardList))
            updatedBoards[boardType].ChildRecords.push(result[0]);
            updatedBoards[boardType].expanded = true;
            this.boardList = updatedBoards;
        } catch (error) {
            console.error('Error creating Kanban Board:', error);
        }

    }

    async deleteKanbanWhiteBoard() {
        try {
            const jsonData = JSON.stringify({ Id: this.selectedBoardId, verb: "DeleteProjectBoard" });
            const [removeResult, navResult] = await Promise.all([
                removeProjectBoard({ VSID: this.selectedBoardId }),
                manageNavChange({
                    Verb: 'LeankorNAV',
                    SomeJSONData: jsonData,
                    SessionID: this.sessionId
                })
            ]);
                this.boardList = mutateTree(this.boardList, {
                    type: 'delete',
                    id: this.selectedBoardId
                }, window._);

        } catch (error) {
            console.error('Error deleting Kanban Board:', error);
        }

    }

    async editBoardName() {
        if (!this.inputValue) {
            alert('Please enter a name for the Board.');
            return;
        }
        const boardHit = findById(this.boardList, this.selectedBoardId, window._);
        // const board = this.findProjectBoardById(this.boardList, this.selectedBoardId);
        let jsonData = JSON.stringify({
            Id: this.selectedBoardId,
            name: this.inputValue,
            BoardType: boardHit.boardType,
            roomId: boardHit.roomId,
            disableCalendarView: boardHit.disableCalendarView,
            hasDeleteAccess: boardHit.hasDeleteAccess,
            hasEditAccess: boardHit.hasEditAccess,
            hasReadAccess: boardHit.hasReadAccess,
            leaf: boardHit.leaf,
            CssLayout: boardHit.cssLayout,
            verb: "UpdateProjectBoard"
        });

        try {
            let result = await manageNavChange({
                Verb: "LeankorNAV",
                SomeJSONData: jsonData,
                SessionID: this.sessionId
            });
            if (result) {
                let id = this.selectedBoardId
                this.boardList = mutateTree(this.boardList, {
                    type: 'update', id, patch: { Id: this.selectedBoardId, name: this.inputValue }
                }, window._);
                this.inputValue = '';

            }
        }

        catch (er) {
            console.error('Error updating board name:', er);
        }

    }

    toggleBoard(event) {
        const boardId = event.currentTarget.dataset.id;
        const boardName = event.currentTarget.dataset.name;
        const board = this.boardList.find(b => b.Id === boardId);
        const newExpanded = !board?.expanded;
        if (boardName === 'UberBoard') {
            // ✅ open the Gantt VF page
            const ganttUrl = `https://fun-agility-9842-dev-ed--leankor.scratch.vf.force.com/apex/leankor__GanttView?fid=${board.roomId}&btype=projectgantt&Id=${board.Id}`;
            this.dispatchEvent(new CustomEvent('openvf', {
                detail: { vfUrl: ganttUrl },
                bubbles: true,
                composed: true
            }));
            return;
        }
        this.boardList = mutateTree(this.boardList, {
            type: 'setKey',
            id: boardId,
            key: 'expanded',
            value: newExpanded
        }, window._);
    }

    navigateToProject(event) {
        const projectId = event.currentTarget.dataset.id;
        const projectRoomId = event.currentTarget.dataset.roomid;
        const projectUrl = `https://fun-agility-9842-dev-ed--leankor.scratch.vf.force.com/apex/leankor__KanbanBoard?Id=${projectId}`;
        this.dispatchEvent(new CustomEvent('openvf', {
            detail: { vfUrl: projectUrl },
            bubbles: true,
            composed: true
        }));

    }
}