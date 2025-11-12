import { api, LightningElement, track } from 'lwc';
import getProjectRooms from '@salesforce/apex/ProjectBoardCarousel.getProjectRooms';
export default class MyWorkProjectFilter extends LightningElement {
    @api isOpen = false;

    @track projects = [];
    @track isLoading = false;
    @track error;
    allProjects = []; 
    // Watcher: when modal opens, fetch projects
    renderedCallback() {
        if (this.isOpen && this.projects.length === 0 && !this.isLoading) {
            this.fetchProjects();
        }
    }

    async fetchProjects() {
        this.isLoading = true;
        try {
            const result = await getProjectRooms();
            this.allProjects = result.map(p => ({
                id: p.Id,
                name: p.Name,
                folder: p.leankor__Portfolio__r?.Name || 'No Folder'
            }));
            this.projects = [...this.allProjects];
            this.error = undefined;
        } catch (err) {
            this.error = err.body?.message || err.message;
            console.error('Error fetching projects:', err);
        } finally {
            this.isLoading = false;
        }
    }

    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        if (!searchKey) {
            this.projects = [...this.allProjects];
        } else {
            this.projects = this.allProjects.filter(
                proj => proj.name.toLowerCase().includes(searchKey)
            );
        }
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}