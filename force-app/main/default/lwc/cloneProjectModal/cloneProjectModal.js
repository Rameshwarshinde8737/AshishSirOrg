import { api, LightningElement, track } from 'lwc';
import createProjectLaunchSettingsAura from '@salesforce/apex/realtimeKanbanController.createProjectLaunchSettingsAura';

export default class CloneProjectModal extends LightningElement {
    @api dialogTitle = 'Clone Project ABCD';
    @api isShowCloneModal;
    @api selectedCloneProject;
    @track form = {
        projectName: '',
        startDate: null,
        dueDate: null,
        launchDate: null,
        folder: null
    };

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

    get disableClone() {
        return !this.form.projectName;
    }

    get folderOptions() {
        return [
            { label: 'Parent 1 Child 1', value: 'p1c1' },
            { label: 'Parent 1 Child 2', value: 'p1c2' },
            { label: 'Parent 2 Child 1', value: 'p2c1' }
        ];
    }
    renderedCallback() {
        if (this.selectedCloneProject) {
            this.callCreateProjectLaunchSettings();
        }
    }
    connectedCallback() {
       
    }

    callCreateProjectLaunchSettings() {
        // Prepare payload

        createProjectLaunchSettingsAura({ RID: this.selectedCloneProject.Id })
            .then((result) => {
                console.log('✅ Apex call success:', result);
                // Handle success logic here
            })
            .catch((error) => {
                console.error('❌ Apex call error:', error);
            });
    }

    handleInput = (e) => {
        const field = e.currentTarget.dataset.field;
        this.form = { ...this.form, [field]: e.detail.value };
    };

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

    handleCancel = () => {
       this.dispatchEvent(new CustomEvent('closeclone'));
       this.isShowCloneModal = false;
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