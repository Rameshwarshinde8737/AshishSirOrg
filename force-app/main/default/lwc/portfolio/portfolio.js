import { api, LightningElement, track } from 'lwc';
import createListPortfolioAura from '@salesforce/apex/ProjectBoardCarousel.createListPortfolioAura';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Portfolio extends LightningElement {

  @track folderName = '';
  @api folders = [];
  @track holdFolderName = '';
  headerCols = [
    '% Completion',
    'Planned Due Date',
    'Forecasted Due Date',
    'Project Owner'
  ];

  get dropdownActions() {
    if (this.isFolder) {
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

  handleFolderNameChange(event) {
    this.holdFolderName = event.target.value;
  }

  handleCreateFolder() {
    // this.dispatchEvent(new CustomEvent('createfolder', {
    //   detail: { name: this.holdFolderName.trim() },
    //   bubbles: true,
    //   composed: true
    // }));
  }

  connectedCallback() {
    this.isLoading = true;
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

}