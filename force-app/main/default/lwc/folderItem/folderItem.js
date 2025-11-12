import { LightningElement, track, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import BOARD_NAVIGATION_CHANNEL from '@salesforce/messageChannel/BoardNavigationMessageChannel__c';

export default class FolderItem extends LightningElement {
    @api folder;
    @api from;
    @api foldersForMove;
    @api moveOptions  = []
    @wire(MessageContext)
    messageContext;
    @track expanded = false;
    @track popoverStyle
    @track isShowMoreActions
    @track isAddNewFolderProject = false;
    @track holdFolderName = '';
    @track selectedMenuAction;
    @track popupPosition = { top: '0px', left: '0px' };
    @track isShowMoveModal = false;
    @track isShowCloneModal = false;
    @track folderToMove;
    @track selectedCloneProject;
    libsReady = false;
    get isPortfolioVariant() {
        return this.from === 'portfolio';
    }
    get isSideBarVariant() {
        return this.from === 'sideBar';
    }
    get isMoveModalVariant() {
        return this.from === 'moveModal';
    }
    get isIconVisibleForMove() {
        return this.from !== 'moveModal';
    }
    get isPortfolio() {
        return this.folder.RoomType === 'Portfolio';
    }
    get chevronOrFolderIconClass() {
        if (this.isMoveModalVariant) {
            return 'icon-folder-open1';
        }
        return this.chevronIconPort;
    }
    get chevronIconSidebar() {
        return this.folder.expanded ? 'icon-chevron-down' : 'icon-uniA20';
    }
    get chevronIconPort(){
       return this.folder.expanded ? 'icon-chevron-down' : 'icon-chevron-up'; 
    }
    get folderSectionClass() {
        return 'folderSection slds-p-horizontal_x-small slds-p-vertical_xx-small';
    }
    get threeDotClass() {
        return this.isPortfolio ? 'icon-vert-dots' : 'icon-vert-dots childThreeDot';
    }
    get indentStyle() {
        const depth = this.folder?.depth || 0;
        // 20px per level; tweak as needed
        return `margin-left: ${depth * 12}px;`;
    }
    get dropdownActions() {
        if (this.isPortfolio) {
            return [
                { label: 'Add Folder', value: 'addFolder' },
                { label: 'Add Project', value: 'addProject' },
                { label: 'Edit Name', value: 'edit' },
                { label: 'Move', value: 'move' },
                { label: 'Delete', value: 'delete' }
            ];
        }
        return [
            { label: 'Edit Name', value: 'edit' },
            { label: 'Move', value: 'move' },
            { label: 'Delete', value: 'delete' },
            { label: 'Clone', value: 'clone' }
        ];
    }
    get popupStyle() {
        return `position: fixed; top: ${this.popupPosition.top}; left: ${this.popupPosition.left}; z-index: 1000;`;
    }

    renderedCallback() {
        console.log('Rendered Callback folder Items :');
    }
    
    handleMenuAction(evt){
        this.selectedMenuAction = evt.currentTarget.dataset.action;
        if (this.selectedMenuAction === 'move') {
           this.folderToMove = this.folder;
           this.isShowMoveModal = true;
           return;
        }
        if (this.selectedMenuAction === 'clone') {
            this.folderToMove = this.folder;
            this.isShowCloneModal = true;
             return;
        }
        if(['addFolder','addProject','edit'].includes(this.selectedMenuAction)){
            this.isAddNewFolderProject = true;
            this.selectedMenuAction === 'edit' ? this.holdFolderName = this.folder.Name : this.holdFolderName = '';
            return;
        }
        
        this.dispatchEvent(new CustomEvent('folderaction', {
            detail: { folder: this.folder, type: this.selectedMenuAction },
            bubbles: true,
            composed: true
        }));
        
    }
    
    handleCloseMove() {
        this.isShowMoveModal = false;
    }
    handleCloseClone() {
        this.isShowCloneModal = false;
    }
    
    handleCreateFolder() {
        this.isAddNewFolderProject = false;
        this.dispatchEvent(new CustomEvent('folderaction', {
            detail: { folder: this.folder, type: this.selectedMenuAction, folderProjectName: this.holdFolderName },
            bubbles: true,
            composed: true
        }));
         this.holdFolderName = '';
    }
    handleFolderNameChange(event) {
        this.holdFolderName = event.target.value;
    }

    handleChevronClick(event) {
        event.stopPropagation();
        // for both sidebar & moveModal — expand/collapse
        this.dispatchEvent(
            new CustomEvent('folderaction', {
                detail: {
                    folder: this.folder,
                    type: 'folderClick',
                    from: this.from
                },
                bubbles: true,
                composed: true
            })
        );
    }

    handleFolderNameClick(event) {
        event.stopPropagation();

        if (this.isMoveModalVariant) {
            // Instead of expanding, select this folder for move
            this.dispatchEvent(
                new CustomEvent('folderselectedformove', {
                    detail: {
                        selectedFolder: this.folder
                    },
                    bubbles: true,
                    composed: true
                })
            );
        } else {
            // default behavior (toggle expand)
            this.toggleFolder();
        }
    }
    
    toggleFolder() {
        this.expanded = !this.expanded;
        this.dispatchEvent(
            new CustomEvent('folderaction', {
                detail: {
                    folder: this.folder,
                    type: 'folderClick',
                    from: this.from
                },
                bubbles: true,
                composed: true
            })
        )
    }

    toggleDropdown(event) {
        event.stopPropagation();
        const buttonRect = event.currentTarget.getBoundingClientRect();
        this.popupPosition = {
            top: (buttonRect.top + 20) + 'px',
            left: (buttonRect.right - 10) + 'px'
        };
        this.isShowMoreActions = !this.isShowMoreActions;
        this.dispatchEvent(
            new CustomEvent('folderaction', {
                detail: {
                    folder: this.folder,
                    type: 'menuClick'
                },
                bubbles: true,        
                composed: true      
            })
        )
        document.removeEventListener('click', this.handleOutsideClick, true);
        if (this.isShowMoreActions) {
           setTimeout(() => document.addEventListener("click", this.handleOutsideClick), 0);
        } else {
            document.removeEventListener('click', this.handleOutsideClick, true);
        }
        this.getPopoverPosition(event);
    }

    handleOutsideClick = (event) => {
        if (!this.template.querySelector('[data-id="popover"]').contains(event.target)) {
            this.isShowMoreActions = false
            this.dispatchEvent(
                new CustomEvent('folderaction', {
                    detail: {
                        folder: this.folder,
                        type: 'outsideClickCloseMenu',
                        from: this.from
                    },
                    bubbles: true,
                    composed: true
                })
            )
            document.removeEventListener('click', this.handleOutsideClick, true);
        }
    }

    getPopoverPosition(event) {
        const icon = event.currentTarget;
        const rect = icon.getBoundingClientRect();
        const popoverHeight = this.isPortfolio ? 200 : 170 ;
        const popoverWidth = 150;

        let top = rect.bottom; // default below
        let left = rect.left;

        // ✅ Check space below first
        const spaceBelow = window.innerHeight - rect.bottom;
        if (spaceBelow < popoverHeight) {
            // Not enough space below → open above
            top = rect.top - popoverHeight;
            if (top < 0) {
                top = 0; // keep inside screen
            }
        }

        // ✅ Check space on the right
        if (left + popoverWidth > window.innerWidth) {
            left = window.innerWidth - popoverWidth;
        }
        if (left < 0) left = 0;

        this.popoverStyle = `position:fixed; top:${top}px; left:${left}px; width:${popoverWidth}px;height:${popoverHeight}px; z-index:9999;`;
    }

    handleProjectClick() {
        publish(this.messageContext, BOARD_NAVIGATION_CHANNEL, {
            action: 'showBoardList',
            payload: {
                project: this.folder,
            }
        });
    }

}