import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Import existing Apex methods from ProjectBoardCarousel
import getWIByFilter from '@salesforce/apex/ProjectBoardCarousel.getWIByFilter';
import updateMyWorkTaskLoad from '@salesforce/apex/ProjectBoardCarousel.updateMyWorkTaskLoad';
// import getMyWorkTaskLoad from '@salesforce/apex/ProjectBoardCarousel.getMyWorkTaskLoad';

// Import labels for internationalization
// import WORK_ITEMS from '@salesforce/label/c.WorkItems';
// import SEE_TASKS from '@salesforce/label/c.SeeTasks';
// import SORT_BY from '@salesforce/label/c.SortBy';
// import DATE_LABEL from '@salesforce/label/c.Date';
// import FROM_LABEL from '@salesforce/label/c.From';
// import TO_LABEL from '@salesforce/label/c.To';
// import WORK_BY_DUE_DATE from '@salesforce/label/c.WorkByDueDate';
// import WORK_BY_PROJECT from '@salesforce/label/c.WorkByProject';
// import MY_PRIORITY_WORK from '@salesforce/label/c.MyPriorityWork';
// import WORK_BY_TYPE from '@salesforce/label/c.WorkByType';
// import NO_WORK_ITEMS from '@salesforce/label/c.NoWorkItems';
// import QUICK_ACTIONS from '@salesforce/label/c.QuickActions';
// import FILES from '@salesforce/label/c.Files';
// import LOG_TIME from '@salesforce/label/c.LogTime';
// import MARK_COMPLETE from '@salesforce/label/c.MarkComplete';
// import MARK_INCOMPLETE from '@salesforce/label/c.MarkIncomplete';

export default class ClaudeMyWorkList extends NavigationMixin(LightningElement) {
     // Labels
    labels = {
        workItems:  'WORK ITEMS',
        seeTasks:  'See Tasks',
        sortBy: 'Sort By',
        date:  'Date',
        from:  'From',
        to:  'To',
        noWorkItems:  'No work items found',
        quickActions:  'Quick Actions',
        files:  'Files',
        logTime:  'Log Time',
        markComplete: 'Mark Complete',
        markIncomplete:  'Mark Incomplete'
    };

    // Reactive properties
    @track groupedWorkItems = [];
    @track totalWorkItems = 0;
    @track showTasks = false;
    @track selectedFilter = 'WORKBYDUEDATE';
    @track fromDate = '';
    @track toDate = '';
    @track isLoading = false;

    // Filter options
    filterOptions = [
        { label: 'Work by Due Date', value: 'WORKBYDUEDATE' },
        { label:  'Work by Project', value: 'WORKBYPROJECT' },
        { label:  'My Priority Work', value: 'PRIORITYWORK' },
        { label: 'Work by Type', value: 'WORKBYTYPE' }
    ];

    // Private properties
    dateRangeStart = null;
    dateRangeEnd = null;

    /**
     * Component initialization
     */
    connectedCallback() {
        this.initializeDateRange();
        // this.loadUserPreferences();
    }

    /**
     * Initialize date range (default: current week)
     */
    initializeDateRange() {
        const today = new Date();
        const startOfWeek = new Date(today.setDate(today.getDate() - today.getDay()));
        const endOfWeek = new Date(today.setDate(today.getDate() - today.getDay() + 6));

        this.dateRangeStart = startOfWeek;
        this.dateRangeEnd = endOfWeek;
        this.fromDate = this.formatDate(startOfWeek);
        this.toDate = this.formatDate(endOfWeek);
    }

    /**
     * Load user preferences from existing backend
     */
    loadUserPreferences() {
        getMyWorkTaskLoad()
            .then(result => {
                this.showTasks = result;
                this.loadMyWorkItems();
            })
            .catch(error => {
                console.error('Error loading preferences:', error);
                this.loadMyWorkItems(); // Load anyway with default
            });
    }

    /**
     * Load work items using EXISTING ProjectBoardCarousel.getWIByFilter method
     */
    loadMyWorkItems() {
        this.isLoading = true;

        // Build filter object matching WorkFilter class structure
        const filterObj = {
            filterType: this.selectedFilter,
            rangeStartDate: this.dateRangeStart ? this.dateRangeStart.toISOString() : null,
            rangeEndDate: this.dateRangeEnd ? this.dateRangeEnd.toISOString() : null,
            isMyWorkTaskLoad: this.showTasks
        };

        // Convert to JSON string as expected by getWIByFilter
        const filterData = JSON.stringify(filterObj);

        getWIByFilter({ filterData: filterData })
            .then(result => {
                this.processWorkItemsFromBackend(result);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.showError('Error loading work items', error.body?.message || error.message);
                console.error('Error:', error);
            });
    }

    /**
     * Process work items returned from ProjectBoardCarousel
     * Result is List<Card> from your existing backend
     */
    processWorkItemsFromBackend(cards) {
        if (!cards || cards.length === 0) {
            this.groupedWorkItems = [];
            this.totalWorkItems = 0;
            return;
        }

        // Group items based on filter type
        let grouped = {};

        cards.forEach(card => {
            let groupKey;
            let groupName;

            switch(this.selectedFilter) {
                case 'WORKBYDUEDATE':
                    groupKey = this.getDateGroupKey(card.DueDate);
                    groupName = this.getDateGroupName(card.DueDate);
                    break;
                case 'WORKBYPROJECT':
                    groupKey = card.ProjectRoomName || 'No Project';
                    groupName = card.ProjectRoomName || 'No Project';
                    break;
                case 'PRIORITYWORK':
                    groupKey = this.getPriorityGroupKey(card);
                    groupName = this.getPriorityGroupName(card);
                    break;
                case 'WORKBYTYPE':
                    groupKey = card.ItemType || 'Unknown';
                    groupName = this.getItemTypeDisplay(card.ItemType);
                    break;
                default:
                    groupKey = 'default';
                    groupName = 'Work Items';
            }

            if (!grouped[groupKey]) {
                grouped[groupKey] = {
                    id: groupKey,
                    displayName: groupName,
                    items: [],
                    expanded: true,
                    Color: this.getGroupColor(groupKey)
                };
            }

            // Process individual item for display
            const processedItem = this.processWorkItem(card);
            grouped[groupKey].items.push(processedItem);
        });

        // Convert to array and add computed properties
        this.groupedWorkItems = Object.values(grouped).map(group => ({
            ...group,
            childCount: group.items.length,
            expandIcon: group.expanded ? '-' : '+',
            headerClass: `work-group-header ${group.expanded ? 'expanded' : 'collapsed'}`,
            headerStyle: `color: ${group.Color || '#000'}; border-left-color: ${group.Color || '#000'}`,
            arrowClass: group.expanded ? 'arrow-down' : 'arrow-right'
        }));

        this.totalWorkItems = cards.length;
    }

    /**
     * Process individual work item for display
     * Card structure from ProjectBoardCarousel.Card class
     */
    processWorkItem(card) {
        const isTask = card.ItemType === 'TASK' || card.ItemType === 'Task';
        const isActivity = card.ItemType === 'ACTIVITY' || card.ItemType === 'Activity';
        const isMilestone = card.ItemType === 'MILESTONE' || card.ItemType === 'Milestone';

        const progress = isActivity ? card.percentCompleted : card.HarveyBall;
        const isComplete = isTask ? (card.Status === 'Completed') : (progress === 100);

        return {
            ...card,
            isTask: isTask,
            isActivity: isActivity,
            isMilestone: isMilestone,
            displayItemType: this.getItemTypeDisplay(card.ItemType),
            valueStreamIconClass: card.BoardType === 'UberBoard' ? 'gantt-icon' : 'board-icon',
            displayValueStreamName: card.BoardType === 'UberBoard' ? 'Plan Gantt' : card.ValueStreamName,
            priorityClass: this.getPriorityClass(card),
            priorityText: this.getPriorityText(card),
            checkboxClass: isComplete ? 'checkbox checked' : 'checkbox',
            checkboxTitle: isComplete ? this.labels.markIncomplete : this.labels.markComplete,
            showHarveyBall: !isTask,
            harveyBallClass: this.getHarveyBallClass(progress),
            progressText: `${progress || 0}%`,
            displayStatus: this.getTaskStatusDisplay(card.Status),
            hasFiles: card.filesCount > 0,
            hasComments: card.ChatterCount > 0,
            hasStickers: card.Sticker && Array.isArray(card.Sticker) && card.Sticker.length > 0,
            stickerImages: this.processStickerImages(card.Sticker),
            formattedDueDate: this.formatDate(card.DueDate),
            dateTooltip: this.getDateTooltip(card),
            fullTitle: this.getFullTitle(card)
        };
    }

    /**
     * Event Handlers
     */
    handleFilterChange(event) {
        this.selectedFilter = event.detail.value;
        this.loadMyWorkItems(); // Reload with new filter
    }

    handleTaskToggle(event) {
        this.showTasks = event.target.checked;

        // Use existing backend method to update preference
        updateMyWorkTaskLoad({ myWorkLoadsTasks: this.showTasks })
            .then(() => {
                this.loadMyWorkItems();
            })
            .catch(error => {
                this.showError('Error updating preference', error.body?.message);
            });
    }

    handleGroupToggle(event) {
        const groupId = event.currentTarget.dataset.groupId;
        this.groupedWorkItems = this.groupedWorkItems.map(group => {
            if (group.id === groupId) {
                const expanded = !group.expanded;
                return {
                    ...group,
                    expanded: expanded,
                    expandIcon: expanded ? '-' : '+',
                    headerClass: `work-group-header ${expanded ? 'expanded' : 'collapsed'}`,
                    arrowClass: expanded ? 'arrow-down' : 'arrow-right'
                };
            }
            return group;
        });
    }

    handleItemClick(event) {
        const itemId = event.currentTarget.dataset.itemId;
        const item = this.findItemById(itemId);

        if (item) {
            // Navigate to record detail page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: item.Id,
                    objectApiName: this.getObjectApiName(item),
                    actionName: 'view'
                }
            });
        }
    }

    handleMarkComplete(event) {
        event.stopPropagation();
        const itemId = event.currentTarget.dataset.itemId;
        // TODO: Call your existing backend method to mark item complete
        console.log('Mark complete clicked for:', itemId);
        this.showError('Not Implemented', 'Connect to your existing mark complete method');
    }

    handleDateRangeClick() {
        // TODO: Open date picker modal
        console.log('Date range picker clicked');
    }

    /**
     * Helper methods
     */
    findItemById(itemId) {
        for (let group of this.groupedWorkItems) {
            const item = group.items.find(i => i.Id === itemId);
            if (item) return item;
        }
        return null;
    }

    getObjectApiName(item) {
        if (item.ItemType === 'TASK' || item.ItemType === 'Task') {
            return 'Task';
        }
        return 'leankor__KanbanCard__c';
    }

    getDateGroupKey(date) {
        if (!date) return 'nodate';
        const itemDate = new Date(date);
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        if (this.isSameDay(itemDate, today)) return 'today';
        if (this.isSameDay(itemDate, tomorrow)) return 'tomorrow';
        if (itemDate < today) return 'overdue';
        return 'later';
    }

    getDateGroupName(date) {
        const key = this.getDateGroupKey(date);
        const names = {
            'today': 'Today',
            'tomorrow': 'Tomorrow',
            'overdue': 'Overdue',
            'later': 'Later',
            'nodate': 'No Due Date'
        };
        return names[key] || 'Other';
    }

    getPriorityGroupKey(item) {
        if (item.ItemType === 'TASK' || item.ItemType === 'Task') {
            return item.TaskPriority || 'Normal';
        }
        return item.Priority !== undefined ? `priority_${item.Priority}` : 'priority_none';
    }

    getPriorityGroupName(item) {
        if (item.ItemType === 'TASK' || item.ItemType === 'Task') {
            return item.TaskPriority || 'Normal';
        }
        const priorities = { 1: 'Critical', 2: 'Medium', 3: 'Low' };
        return priorities[item.Priority] || 'None';
    }

    getItemTypeDisplay(itemType) {
        if (!itemType) return '';
        const types = {
            'ACTIVITY': 'ACTIVITY',
            'Activity': 'ACTIVITY',
            'MILESTONE': 'MILESTONE',
            'Milestone': 'MILESTONE',
            'TASK': 'TASK',
            'Task': 'TASK',
            'KC': 'CARD',
            'kc': 'CARD'
        };
        return types[itemType] || itemType.toUpperCase();
    }

    getPriorityClass(item) {
        if (item.ItemType === 'TASK' || item.ItemType === 'Task') {
            const priorityMap = { 'High': 1, 'Normal': 2, 'Low': 3 };
            const level = priorityMap[item.TaskPriority] || 3;
            return `priority priority-${level}`;
        }
        return `priority priority-${item.Priority || 0}`;
    }

    getPriorityText(item) {
        if (item.ItemType === 'TASK' || item.ItemType === 'Task') {
            return item.TaskPriority || 'Normal';
        }
        const priorities = { 1: 'Critical', 2: 'Medium', 3: 'Low' };
        return priorities[item.Priority] || 'None';
    }

    getHarveyBallClass(progress) {
        if (!progress || progress < 25) return 'harvey-ball harvey-0';
        if (progress < 50) return 'harvey-ball harvey-25';
        if (progress < 75) return 'harvey-ball harvey-50';
        if (progress < 100) return 'harvey-ball harvey-75';
        return 'harvey-ball harvey-100';
    }

    getTaskStatusDisplay(status) {
        const statusMap = {
            'Not Started': 'Not Started',
            'In Progress': 'In Progress',
            'Waiting on someone else': 'Waiting',
            'Deferred': 'Deferred',
            'Completed': 'Completed'
        };
        return statusMap[status] || status;
    }

    processStickerImages(stickers) {
        if (!stickers || !Array.isArray(stickers)) return [];
        return stickers.map((sticker, index) => ({
            id: index,
            url: `/servlet/servlet.FileDownload?file=${sticker.Id}`
        }));
    }

    getDateTooltip(item) {
        let tooltip = '';
        if (item.StartDate) {
            tooltip += `Start Date: ${this.formatDate(item.StartDate)} `;
        }
        if (item.DueDate) {
            tooltip += `Due Date: ${this.formatDate(item.DueDate)}`;
        }
        return tooltip;
    }

    getFullTitle(item) {
        let title = `Name: ${item.Name}`;
        if (item.Category) title += `\nCategory: ${item.Category}`;
        if (item.MasterContainer) title += `\nMaster Container: ${item.MasterContainer}`;
        if (item.Description) title += `\nDescription: ${item.Description}`;
        return title;
    }

    getGroupColor(groupKey) {
        const colors = {
            'today': '#FF6B6B',
            'tomorrow': '#4ECDC4',
            'overdue': '#FF0000',
            'later': '#95A5A6',
            'priority_1': '#E74C3C',
            'priority_2': '#F39C12',
            'priority_3': '#3498DB'
        };
        return colors[groupKey] || '#34495E';
    }

    formatDate(date) {
        if (!date) return '';
        const d = new Date(date);
        return d.toLocaleDateString();
    }

    isSameDay(date1, date2) {
        return date1.getFullYear() === date2.getFullYear() &&
               date1.getMonth() === date2.getMonth() &&
               date1.getDate() === date2.getDate();
    }

    /**
     * Toast notifications
     */
    showSuccess(message) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        }));
    }

    showError(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error'
        }));
    }

    /**
     * Computed properties
     */
    get hasWorkItems() {
        return this.groupedWorkItems && this.groupedWorkItems.length > 0;
    }
}