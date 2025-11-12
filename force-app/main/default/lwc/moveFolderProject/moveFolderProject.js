import { api, LightningElement, track, wire } from 'lwc';
import { findTopParent } from 'c/utils';
import createProjectLaunchSettingsAura from '@salesforce/apex/realtimeKanbanController.createProjectLaunchSettingsAura';

export default class MoveFolderProject extends LightningElement {
    @api openMoveModel;
    @api isShowCloneModal = false;
    @api foldersForMove;
    @api folderToMove;
    @track isPickerOpen = false;
    @track selectedDestinationLabel = '';
    @track selectedFolder;
    @track selectedDestinationFolder
    @track activeModal = ''; // 'move' or 'clone'
    rows = [
        { key: 'planGantt', label: 'Plan Gantt', value: true },
        { key: 'projectBoards', label: 'Project Boards', value: true },
        { key: 'whiteboards', label: 'Whiteboards', value: true },
        { key: 'dashboards', label: 'Dashboards', value: true },
        { key: 'financials', label: 'Financials', value: true },
        { key: 'files', label: 'Files', value: false },
        { key: 'customFields', label: 'Custom Fields', value: false },
        { key: 'stickers', label: 'Stickers', value: false }
    ].map(r => ({ ...r, ...decorate(r) }));
    @track form = {
        projectName: '',
        startDate: null,
        dueDate: null,
        launchDate: null,
        folder: null
    };
    cleanFolders(folders) {
        if (!folders) return [];

        return folders
            .filter(folder => folder.RoomType !== 'Room') // exclude 'Room'
            .map(folder => {
                // If ChildRecords exist, clean them recursively
                const { ChildRecords, ...rest } = folder;
                const cleanedChildren = this.cleanFolders(ChildRecords);
                return { ...rest, ChildRecords: cleanedChildren.length ? cleanedChildren : undefined };
            });
    }

    get filteredFolders() {
        // Check if there is at least one Portfolio folder
           let cleaned = this.cleanFolders(this.foldersForMove);
        const hasPortfolio = cleaned.some(f => f.RoomType === 'Portfolio');

        if (hasPortfolio) {
            cleaned = [{ Name: 'Top level folder', Id: 0, RoomType: 'Portfolio' }, ...cleaned];
        }

        return cleaned;
    }

    renderedCallback() {
        // ✅ Run once when modal is opened and folderToMove is available
        if (this.folderToMove && this.selectedDestinationLabel === '') {
            this.setSelectedDestinationLabel();
        }else if(this.isShowCloneModal && this.folderToMove){
            // this.callCreateProjectLaunchSettings();
        }

    }

    get disableClone() {
        return !this.form.projectName;
    }

    handleFolderSelectedForMove(event) {
        this.selectedFolder = event.detail.selectedFolder;
        this.selectedDestinationLabel = this.selectedFolder.Name;
        this.selectedDestinationFolder = this.selectedFolder;
        this.isPickerOpen = false; // close picker after selection
        // ✅ Reopen the correct modal
        if (this.activeModal === 'clone') {
            this.isShowCloneModal = true;
        } else {
            this.openMoveModel = true;
        }
        this.activeModal = '';
    }

    setSelectedDestinationLabel() {
        if (!this.folderToMove) return;

        if (this.folderToMove.RoomType === 'Portfolio') {
            this.selectedDestinationLabel = 'Top Level Root'
        } else if (this.folderToMove.RoomType === 'Room') {
            const top = findTopParent(this.foldersForMove, this.folderToMove.parentId);
            if (top) {
                this.selectedDestinationLabel = top.Name;
            }
        }
    }

    callCreateProjectLaunchSettings() {
        // Prepare payload

        createProjectLaunchSettingsAura({ RID: this.folderToMove.Id })
            .then((result) => {
                console.log('✅ Apex call success:', this.folderToMove.Id);
                // Handle success logic here
            })
            .catch((error) => {
                console.error('❌ Apex call error:', error);
            });
    }
    
    openFolderPicker() {
        // remember which modal opened picker
        if (this.openMoveModel) {
            this.activeModal = 'move';
        } else if (this.isShowCloneModal) {
            this.activeModal = 'clone';
        }
        // close current modals before showing picker
        this.isPickerOpen = true;
        this.isShowCloneModal = false;
        this.openMoveModel = false;
        this.dispatchEvent(new CustomEvent('closemove', { bubbles: true, composed: true }));
    }
    
    closeMoveModal() {
        this.openMoveModel = false;
        this.dispatchEvent(new CustomEvent('closemove', { bubbles: true, composed: true }));
        this.openMoveModel = false;

    }
    closeModal(){
        this.isPickerOpen = false;
    }

    async confirmMove() {
        this.openMoveModel = false;
        const eventDetail = {
            folderToMove: this.folderToMove,
            destinationFolder: this.selectedDestinationFolder
        };
        this.dispatchEvent(new CustomEvent('movefolderproject', {
            detail: eventDetail,
            bubbles: true,
            composed: true
        }));
    }

    toggleRow = (e) => {
        const key = e.currentTarget.dataset.key;
        this.rows = this.rows.map(r => {
            if (r.key === key) {
                const value = !r.value; // toggle value
                return { ...r, value, ...decorate({ ...r, value }) };
            }
            return r;
        });
    };

    handleClone = () => {
        const payload = {
            ...this.form,
            selections: this.rows.reduce((acc, r) => ({ ...acc, [r.key]: r.value }), {})
        };
        this.dispatchEvent(new CustomEvent('submit', { detail: payload }));
    };
}

function decorate(r) {
    const icon = 'utility:check'; // always checked icon
    const buttonClass = `row__button ${r.value ? 'green-bg' : 'bg-none'}`; // green background if selected
    const title = 'Included';
    return { icon, buttonClass, title };
}