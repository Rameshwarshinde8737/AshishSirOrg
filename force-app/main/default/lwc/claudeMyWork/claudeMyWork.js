import { api, LightningElement } from 'lwc';
// import MY_WORK_ITEMS from '@salesforce/label/c.MyWorkItems';
export default class ClaudeMyWork extends LightningElement {
    // Labels for internationalization
    labels = {
        myWorkItems: 'My Work Items'
    };

    @api height = '100%';

    connectedCallback() {
        // Initialize component
        console.log('MyWork component initialized');
    }
}