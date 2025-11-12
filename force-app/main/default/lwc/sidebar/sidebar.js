import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import SMALLPHOTO_FIELD from '@salesforce/schema/User.SmallPhotoUrl';


export default class FolderSidebar extends NavigationMixin(LightningElement) {
    @api folders = []
    @api foldersForMove
    // --- User info
    @track userName;
    @track userSmallPhotoUrl;
    userInitials;
    sessionId = '';

    // --- Constants
    NAME_FIELD = NAME_FIELD;
    SMALLPHOTO_FIELD = SMALLPHOTO_FIELD;

    // --- Folder state
    @track holdFolderName = '';
    @track parentFolderId = null;

    // --- UI state
    @track isLoading = false;
    @track isAddParentFolder = false;
    @track isSidebarVisible = true;
    @track isShowBoardList = false;
    @track isPortfolioManagementExpanded = false;
    @track popupPosition = { top: '0px', left: '0px' };
    @track isSearchModalOpen = false;
    // --- Lifecycle

    get sidebarWrapperClass() {
        return `sidebar-wrapper${this.isVisible ? '' : ' closed'}`;
    }

    get portFolioIconName() {
        return this.isPortfolioManagementExpanded ? 'icon-chevron-down' :'icon-uniA20';
    }
    
    expandPortfolioManagement() {
        this.isPortfolioManagementExpanded = !this.isPortfolioManagementExpanded;
    }
    get popupStyle() {
        return `position: fixed; top: ${this.popupPosition.top}; left: ${this.popupPosition.left}; z-index: 1000;`;
    }
    openSearchModal() {
        this.isSearchModalOpen = true;
    }

    closeSearchModal() {
        this.isSearchModalOpen = false;
    }

    // --- Get logged-in user data
    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, SMALLPHOTO_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.userSmallPhotoUrl = data.fields.SmallPhotoUrl.value;
            this.userInitials = this.userName ? this.userName.charAt(0).toUpperCase() : '';
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }
  
    handlePortfolioClick() {
        // Dispatch a custom event to notify the parent (appContainer) to switch to the Portfolio view
        this.dispatchEvent(new CustomEvent('openportfolio', {
            bubbles: true,
            composed: true
        }));
    }
    
    openAddFolderPopup(event) {

        const buttonRect = event.currentTarget.getBoundingClientRect();
        // Calculate popup position
        this.popupPosition = {
            top: (buttonRect.top + 35) + 'px',
            left: (buttonRect.right - 35) + 'px'
        };

        this.isAddParentFolder = !this.isAddParentFolder;
        if (this.isAddParentFolder) {
            setTimeout(() => document.addEventListener("click", this.handleOutsideClick), 0);
        } else {
            document.removeEventListener("click", this.handleOutsideClick);
        }
    }

    handleFolderNameInput(event) {
        this.holdFolderName = event.target.value;
    }

    handleCreateFolder() {
        this.dispatchEvent(new CustomEvent('folderaction', {
            detail: {
                folder: null,                // no parent for top-level
                folderProjectName: this.holdFolderName,
                type: 'addFolder'
            },
            bubbles: true,
            composed: true
        }));
        this.holdFolderName  = '';
        // close popup locally
        this.isAddParentFolder = false;
    }

    handleMyWorkClick() {
        this.dispatchEvent(
            new CustomEvent('openmywork', {
                bubbles: true,
                composed: true
            })
        );
    }
}