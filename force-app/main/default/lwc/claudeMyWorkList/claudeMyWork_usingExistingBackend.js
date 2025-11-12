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
        workItems: 'WORK ITEMS',
        seeTasks: 'See Tasks',
        sortBy:  'Sort By',
        date:  'Date',
        from:  'From',
        to: 'To',
        noWorkItems:  'No work items found',
        quickActions:  'Quick Actions',
        files: 'Files',
        logTime: 'Log Time',
        markComplete:  'Mark Complete',
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
        { label:  'Work by Due Date', value: 'WORKBYDUEDATE' },
        { label:  'Work by Project', value: 'WORKBYPROJECT' },
        { label:  'My Priority Work', value: 'PRIORITYWORK' },
        { label:  'Work by Type', value: 'WORKBYTYPE' }
    ];

    // Private properties
    dateRangeStart = null;
    dateRangeEnd = null;

    /**
     * Component initialization
     */
    connectedCallback() {
        this.initializeDateRange();
        this.loadUserPreferences();
        this.loadMyWorkItems();
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
        try {
            if (window.glueforcenav && window.glueforcenav.getWorkspaceConfig) {
                const config = window.glueforcenav.getWorkspaceConfig();
                // Set task toggle based on user preference
                this.showTasks = config.MyWorkLoadsTasks === true;
            }
        } catch (error) {
            console.error('Error loading preferences:', error);
        }
    }

    /**
     * Load work items using existing glueforcenav.getCardHierarchy method
     * This is the EXACT method used by your ExtJS app!
     */
    loadMyWorkItems() {
        this.isLoading = true;

        // Build JSON parameters matching ExtJS format
        const jsonParams = JSON.stringify({
            rangeStartDate: this.dateRangeStart,
            rangeEndDate: this.dateRangeEnd,
            filterType: this.selectedFilter
        });

        try {
            // Call existing backend method
            if (window.glueforcenav && window.glueforcenav.getCardHierarchy) {
                window.glueforcenav.getCardHierarchy(jsonParams, (result) => {
                    // result is array of groups with ChildRecords
                    this.processGroupedData(result);
                    this.isLoading = false;
                });
            } else {
                console.error('glueforcenav.getCardHierarchy not available');
                this.showError('Error', 'Backend integration not available');
                this.isLoading = false;
            }
        } catch (error) {
            this.isLoading = false;
            this.showError('Error loading work items', error.message);
        }
    }

    /**
     * Process data returned from glueforcenav.getCardHierarchy
     * Format matches ExtJS response structure
     */
    processGroupedData(groups) {
        if (!groups || groups.length === 0) {
            this.groupedWorkItems = [];
            this.totalWorkItems = 0;
            return;
        }

        // Apply localization for non-PROJECT filters (matching ExtJS logic line 2250-2252)
        if (this.selectedFilter !== 'WORKBYPROJECT' && window.Locale && window.Locale.LocaleName) {
            groups.forEach(group => {
                if (group.Name && window.Locale.LocaleName[group.Name]) {
                    group.displayName = window.Locale.LocaleName[group.Name];
                }
            });
        }

        // For WORKBYPROJECT, use Name as displayName (matching ExtJS logic line 2265-2268)
        if (this.selectedFilter === 'WORKBYPROJECT') {
            groups.forEach(group => {
                group.displayName = group.Name;
            });

            // Sort alphabetically (matching ExtJS logic line 2272-2282)
            groups.sort((a, b) => {
                const comparison = a.Name.toLowerCase().localeCompare(b.Name.toLowerCase());
                return comparison === 0 ? a.Name.localeCompare(b.Name) : comparison;
            });

            // Alternate colors for projects (matching ExtJS logic line 2283-2291)
            groups.forEach((group, index) => {
                group.Color = index % 2 === 0 ? '#A9A9A9' : '#D3D3D3';
            });
        }

        // Convert to format expected by template
        let totalItems = 0;
        this.groupedWorkItems = groups.map(group => {
            const items = (group.ChildRecords || []).map(item => this.processWorkItem(item));
            totalItems += items.length;

            return {
                id: group.Id,
                displayName: group.displayName || group.Name,
                items: items,
                childCount: group.ChildCount,
                expanded: true, // Default to expanded
                expandIcon: '-',
                headerClass: 'work-group-header expanded',
                headerStyle: `color: ${group.Color || '#000'}`,
                arrowClass: 'arrow-down',
                Color: group.Color
            };
        });

        this.totalWorkItems = totalItems;
    }

    /**
     * Process individual work item for display
     */
    processWorkItem(item) {
        const isTask = item.ItemType === 'TASK' || item.ItemType === 'Task';
        const isActivity = item.ItemType === 'ACTIVITY' || item.ItemType === 'Activity';
        const isMilestone = item.ItemType === 'MILESTONE' || item.ItemType === 'Milestone';

        const progress = isActivity ? item.percentCompleted : item.HarveyBall;
        const isComplete = isTask ? (item.Status === 'Completed') : (progress === 100);

        return {
            ...item,
            isTask: isTask,
            isActivity: isActivity,
            isMilestone: isMilestone,
            displayItemType: this.getItemTypeDisplay(item.ItemType),
            valueStreamIconClass: item.BoardType === 'UberBoard' ? 'gantt-icon' : 'board-icon',
            displayValueStreamName: item.BoardType === 'UberBoard' ? 'Plan Gantt' : item.ValueStreamName,
            priorityClass: this.getPriorityClass(item),
            priorityText: this.getPriorityText(item),
            checkboxClass: isComplete ? 'checkbox checked' : 'checkbox',
            checkboxTitle: isComplete ? this.labels.markIncomplete : this.labels.markComplete,
            showHarveyBall: !isTask,
            harveyBallClass: this.getHarveyBallClass(progress),
            progressText: `${progress || 0}%`,
            displayStatus: this.getTaskStatusDisplay(item.Status),
            hasFiles: item.filesCount > 0,
            hasComments: item.ChatterCount > 0,
            hasStickers: item.Sticker && Array.isArray(item.Sticker) && item.Sticker.length > 0,
            stickerImages: this.processStickerImages(item.Sticker),
            formattedDueDate: this.formatDate(item.DueDate),
            dateTooltip: this.getDateTooltip(item),
            fullTitle: this.getFullTitle(item)
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
        if (window.glueforcenav && window.glueforcenav.updateMyWorkTaskLoad) {
            window.glueforcenav.updateMyWorkTaskLoad(this.showTasks, () => {
                // Callback: reload data after preference is saved
                this.loadMyWorkItems();
            });
        } else {
            // Fallback: just reload
            this.loadMyWorkItems();
        }
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
        const item = this.findItemById(itemId);

        if (item) {
            // TODO: Call your existing backend method to mark item complete
            // You'll need to identify the appropriate glueforcenav method for this
            // Example: window.glueforcenav.updateItemStatus(itemId, isComplete, callback)

            console.log('Mark complete clicked for:', itemId);
            this.showError('Not Implemented', 'Mark complete functionality needs to be connected to your backend');
        }
    }

    handleDateRangeClick() {
        // TODO: Open date picker modal
        // This would require a custom modal component or Lightning date picker
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
        // Return appropriate object API name based on item type
        if (item.ItemType === 'TASK' || item.ItemType === 'Task') {
            return 'Task';
        }
        // Update with your actual custom object name
        return 'Kanban_Card__c'; // Example - replace with your actual object
    }

    getItemTypeDisplay(itemType) {
        if (!itemType) return '';

        // Use Locale if available
        if (window.Locale && window.Locale.LocaleName && window.Locale.LocaleName[itemType]) {
            return window.Locale.LocaleName[itemType].toUpperCase();
        }

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

        // Build sticker URLs (matching ExtJS logic line 475-482)
        const communityName = window.glueforcenav?.getWorkspaceConfig()?.CommunityName;

        return stickers.map((sticker, index) => {
            const stickerId = sticker.Attachments ? sticker.Attachments[0].Id : sticker.Id;
            const urlPrefix = communityName ? `/${communityName}` : '';

            return {
                id: index,
                url: `${urlPrefix}/servlet/servlet.FileDownload?file=${stickerId}`
            };
        });
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

    formatDate(date) {
        if (!date) return '';
        const d = new Date(date);

        // Use glueforceUtil date formatting if available
        if (window.glueforceUtil && window.glueforceUtil.getDateFormat && window.glueforcenav) {
            const dateFormatOrder = window.glueforcenav.dateFormatOrder || ['m', 'd', 'y'];
            const format = window.glueforceUtil.getDateFormat(
                dateFormatOrder[0] + ' ' + dateFormatOrder[1] + ' ' + dateFormatOrder[2],
                true
            );
            // You may need to implement format conversion here
        }

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