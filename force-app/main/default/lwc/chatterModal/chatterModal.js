import { api, LightningElement } from 'lwc'
export default class ChatterModal extends LightningElement {
    @api recordId;
    closeModal() {
        this.dispatchEvent(new CustomEvent('closechatter', {
            bubbles: true,
            composed: true
        }));
    }
    get chatterUrl() {
        return `/apex/leankor__KanbanCardChatterFeed?Id=${this.recordId}&isLightning=true`;
    }
}