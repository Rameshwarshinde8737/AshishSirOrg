import { api, LightningElement, track, wire } from 'lwc';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import BOARD_NAVIGATION_CHANNEL from '@salesforce/messageChannel/BoardNavigationMessageChannel__c';

export default class NavigationContainer extends LightningElement {
    // Public Properties
    @api isVisible;
    @api folders;
    @api foldersForMove;
    // Tracked Properties
    @track isShowBoardList = false;
    @track isShowFolderList = true;
    @track projectData; // (added for storing project data received via LMS)

    // Internal State
    subscription = null;

    // Getters
    get sidebarWrapperClass() {
        return `sidebar-wrapper${this.isVisible ? '' : ' closed'}`;
    }

    // Lifecycle Hooks
    connectedCallback() {
        this.subscribeToMessages();
    }

    // Message Service Wiring
    @wire(MessageContext)
    messageContext;

    subscribeToMessages() {
        if (this.subscription) {
            return;
        }

        this.subscription = subscribe(
            this.messageContext,
            BOARD_NAVIGATION_CHANNEL,
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    // LMS Message Handler
    handleMessage(message) {
        if (message.action === 'showBoardList') {
            this.isShowBoardList = true;
            this.isShowFolderList = false;
            this.projectData = message.payload.project;
        }
    }

    handelShowFolderNav(){
        this.isShowBoardList = false;
        this.isShowFolderList = true;
    }

    // Event Handlers (Bubble Up)
    handleFolderAction(event) {
        this.dispatchEvent(new CustomEvent('folderaction', {
            detail: event.detail,
            bubbles: true,
            composed: true
        }));
    }

    handleOpenPortfolio(event) {
        this.dispatchEvent(new CustomEvent('openportfolio', {
            detail: event.detail,
            bubbles: true,
            composed: true
        }));
    }
}