import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCardLogAura from '@salesforce/apex/KanbanController.createCardLogAura';
import { locale } from './locale';
import labels from 'c/leankorLabels';

export default class LeankorWorkItem extends LightningElement {
    labels = labels;
    @api item;
    @api sessionId;

    // UI State for popovers
    @track showPriorityPopover = false;
    @track showHarveyBallPopover = false;
    @track showDatePopover = false;
    @track showTimeLogPopover = false;
    @track isDropdownOpen = false; // Priority dropdown state
    @track isFileUploadModalOpen = false; // File upload modal state

    // Popover positioning
    @track popoverStyle = '';

    // Date picker state
    @track startDate = null;
    @track dueDate = null;

    // Time logging state
    @track logDate = new Date().toISOString().split("T")[0];
    @track logTime = 1;
    @track logDuration = 'Hours';
    @track logDescription = '';

    get durationOptions() {
        return [
            { label: this.labels.Minutes, value: 'Minutes' },
            { label: this.labels.Hours, value: 'Hours' },
            { label: this.labels.Days, value: 'Days' },
            { label: this.labels.Weeks, value: 'Weeks' },
            { label: this.labels.Months, value: 'Months' }
        ];
    }

    harveyBallOptions = [
        { value: 0, icon: 'icon-uniA3C', class: 'harvey-0' },
        { value: 25, icon: 'icon-uniA3D', class: 'harvey-25' },
        { value: 50, icon: 'icon-uniA3E', class: 'harvey-50' },
        { value: 75, icon: 'icon-uniA3F', class: 'harvey-75' },
        { value: 100, icon: 'icon-uniA40', class: 'harvey-100' }
    ];

    handleItemClick() {
        this.dispatchEvent(new CustomEvent('itemclick', {
            bubbles: true,
            composed: true,
            detail: { itemId: this.item.id }
        }));
    }

    get itemTypeLabel() {
        return this.item.itemType ? this.item.itemType.toUpperCase() : '';
    }

    get priorityClass() {
        return this.getPriorityIconClass(this.item.priority);
    }

    getPriorityIconClass(priority) {
        switch (priority) {
            case 1: return 'priority-red pointer icon-star-full1 slds-button slds-button_reset';
            case 2: return 'priority-blue pointer icon-star-full1 slds-button slds-button_reset';
            case 3: return 'priority-green pointer icon-star-full1 slds-button slds-button_reset';
            default: return 'pointer icon-star-full1 slds-button slds-button_reset';
        }
    }

    get priorityTitle() {
        if (!this.item.priority) return this.labels.None;
        if (this.item.priority === 1) return this.labels.Critical;
        if (this.item.priority === 2) return this.labels.Medium;
        if (this.item.priority === 3) return this.labels.Low;
        return this.labels.None;
    }

    get harveyBallClass() {
        const percent = this.item.itemType === 'ACTIVITY'
            ? this.item.percentCompleted
            : this.item.harveyBall;

        if (percent < 25) return 'harvey-ball-0';
        if (percent < 50) return 'harvey-ball-25';
        if (percent < 75) return 'harvey-ball-50';
        if (percent < 100) return 'harvey-ball-75';
        return 'harvey-ball-100';
    }

    get isCompleted() {
        if (this.item.itemType === 'TASK') {
            return this.item.status === 'Completed';
        }
        return this.item.harveyBall === 100 || this.item.percentCompleted === 100;
    }

    get checkboxIcon() {
        return this.isCompleted ? 'utility:check' : '';
    }

    get checkboxClass() {
        return this.isCompleted ? 'checkbox checked' : 'checkbox';
    }

    get checkboxTitle() {
        return this.isCompleted ? this.labels.MarkIncomplete : this.labels.MarkComplete;
    }

    get formattedDueDate() {
        if (!this.item.dueDate) return '';
        return new Date(this.item.dueDate).toLocaleDateString();
    }

    get showChatterCount() {
        return this.item.chatterCount && this.item.chatterCount > 0;
    }

    get showFilesCount() {
        return this.item.filesCount && this.item.filesCount > 0;
    }

    get isTask() {
        return this.item.itemType === 'TASK' || this.item.itemType === 'Task';
    }

    get taskPriorityClass() {
        if (!this.item.taskPriority) return '';
        if (this.item.taskPriority === 'High') return 'priority-1';
        if (this.item.taskPriority === 'Normal') return 'priority-2';
        return 'priority-3';
    }

    get taskStatusLabel() {
        return this.item.status || '';
    }

    get boardIconName() {
        return this.item.boardType === 'UberBoard' ? 'custom:custom85' : 'custom:custom63';
    }

    // ARIA attributes
    get workItemLabel() {
        const type = this.itemTypeLabel;
        const name = this.item.name;
        const priority = this.priorityTitle || this.item.taskPriority || '';
        const dueDate = this.formattedDueDate ? `${this.labels.Due} ${this.formattedDueDate}` : '';
        return `${type}: ${name}${priority ? ', ' + this.labels.Priority + ': ' + priority : ''}${dueDate ? ', ' + dueDate : ''}`;
    }

    get itemTypeAriaLabel() {
        return `${this.labels.ItemType}: ${this.itemTypeLabel}`;
    }

    get projectLabel() {
        return `${this.labels.Project}: ${this.item.projectName}`;
    }

    get projectAriaLabel() {
        return `${this.labels.OpenProject}: ${this.item.projectName}`;
    }

    get projectTooltip() {
        return this.item.projectName || '';
    }

    get boardLabel() {
        return `${this.labels.Board}: ${this.item.valueStreamName}`;
    }

    get boardAriaLabel() {
        return `${this.labels.OpenBoard}: ${this.item.valueStreamName}`;
    }

    get boardTooltip() {
        return this.item.valueStreamName || '';
    }

    get whatLabel() {
        return `${this.labels.Container}: ${this.item.whatName}`;
    }

    get whatAriaLabel() {
        return `${this.labels.OpenBoardFor}: ${this.item.whatName}`;
    }

    get whatTooltip() {
        return this.item.whatName || '';
    }

    get itemNameTooltip() {
        // Build comprehensive tooltip like ExtJS version
        let tooltip = this.item.name || '';
        if (this.item.category && this.item.itemType !== 'TASK') {
            tooltip += `\n${this.item.category}`;
        }
        if (this.item.masterContainer) {
            tooltip += `\n${this.item.masterContainer}`;
        }
        if (this.item.description) {
            tooltip += `\n${this.item.description}`;
        }
        return tooltip;
    }

    get itemNameAriaLabel() {
        return `${this.labels.OpenBoardForItem}: ${this.item.name}`;
    }

    get taskPriorityAriaLabel() {
        return `${this.labels.TaskPriority}: ${this.item.taskPriority || this.labels.None}`;
    }

    get priorityAriaLabel() {
        return `${this.labels.Priority}: ${this.priorityTitle}`;
    }

    get checkboxAriaLabel() {
        return this.isCompleted ? this.labels.Completed : this.labels.NotCompleted;
    }

    get isCompletedAria() {
        return this.isCompleted ? 'true' : 'false';
    }

    get taskStatusAriaLabel() {
        return `${this.labels.TaskStatus}: ${this.taskStatusLabel}`;
    }

    get harveyBallValue() {
        return parseInt(this.item.harveyBall || 0);
    }

    get harveyBallAriaLabel() {
        return `${this.labels.Progress}: ${this.harveyBallValue}% ${this.labels.Complete}`;
    }

    get currentHarveyBallIcon() {
        const value = this.harveyBallValue;
        const option = this.harveyBallOptions.find(opt => opt.value === value);
        return option ? option.icon : 'icon-uniA3C'; // Default to 0% icon
    }

    get filesAriaLabel() {
        const count = this.item.filesCount || 0;
        return `${count} ${count === 1 ? this.labels.File : this.labels.Files} ${this.labels.Attached}`;
    }

    get chatterAriaLabel() {
        const count = this.item.chatterCount || 0;
        return `${count} ${count === 1 ? this.labels.Comment : this.labels.Comments}`;
    }

    get dueDateAriaLabel() {
        return this.formattedDueDate ? `${this.labels.DueDate}: ${this.formattedDueDate}` : this.labels.NoDueDate;
    }

    // Locale Label Getters
    get selectPriorityLabel() {
        return this.labels.SelectPriority;
    }

    get selectStatusLabel() {
        return this.labels.SelectStatus;
    }

    get updateDatesLabel() {
        return this.labels.UpdateDates;
    }

    get logTimeLabel() {
        return this.labels.LogTime;
    }

    get lowLabel() {
        return this.labels.Low;
    }

    get mediumLabel() {
        return this.labels.Medium;
    }

    get criticalLabel() {
        return this.labels.Critical;
    }

    get saveLabel() {
        return this.labels.Save;
    }

    get cancelLabel() {
        return this.labels.Cancel;
    }

    get logLabel() {
        return this.labels.Log;
    }

    get dateLabel() {
        return this.labels.Date;
    }

    get loggedTimeLabel() {
        return this.labels.LoggedTime;
    }

    get durationLabel() {
        return this.labels.Duration;
    }

    get descriptionLabel() {
        return this.labels.Description;
    }

    get startDateLabel() {
        return this.labels.StartDate;
    }

    get dueDateLabel() {
        return this.labels.DueDate;
    }

    get quickActionLabel() {
        return this.labels.QuickAction;
    }

    get filesLabel() {
        return this.labels.Files;
    }

    get logTimeButtonLabel() {
        return this.labels.LogTime;
    }

    get commentsLabel() {
        return this.labels.Comments;
    }

    // Inline Editing Handlers

    /**
     * Handle priority icon click - toggle dropdown
     * Pattern from UpdatedMyWorkLWCCode 1/myWorkItems
     */
    handlePriorityClick(event) {
        event.stopPropagation();
        const wasOpen = this.isDropdownOpen;
        this.closeAllPopovers();
        this.isDropdownOpen = !wasOpen;

        if (this.isDropdownOpen) {
            this.calculatePopoverPosition(event.currentTarget, 'priority');
            this.addOutsideClickListener();
        } else {
            this.removeOutsideClickListener();
        }
    }

    /**
     * Handle priority selection from dropdown
     * Pattern from UpdatedMyWorkLWCCode 1/myWorkItems
     */
    async handleUpdatePriority(event) {
        event.stopPropagation();
        const value = event.currentTarget.dataset.value;
        const priority = this.mapPriorityValue(value);

        // Dispatch priority change event
        this.dispatchEvent(new CustomEvent('prioritychange', {
            bubbles: true,
            composed: true,
            detail: {
                itemId: this.item.id,
                priority: priority,
                item: this.item,
                priorityLabel: value
            }
        }));

        // Close dropdown
        this.isDropdownOpen = false;
        this.removeOutsideClickListener();
    }

    /**
     * Map priority label to numeric value
     * Pattern from UpdatedMyWorkLWCCode 1/myWorkItems
     */
    mapPriorityValue(label) {
        switch (label) {
            case 'Low': return 3;
            case 'Medium': return 2;
            case 'Critical': return 1;
            default: return null;
        }
    }

    handleHarveyBallClick(event) {
        event.stopPropagation();
        this.closeAllPopovers();
        this.showHarveyBallPopover = true;
        this.calculatePopoverPosition(event.currentTarget, 'harveyBall');
        this.addOutsideClickListener();
    }

    handleHarveyBallSelect(event) {
        event.stopPropagation();
        const selectedValue = parseInt(event.currentTarget.dataset.value);
        this.dispatchEvent(new CustomEvent('harveyballchange', {
            bubbles: true,
            composed: true,
            detail: {
                itemId: this.item.id,
                harveyBall: selectedValue,
                item: this.item
            }
        }));
        this.showHarveyBallPopover = false;
        this.removeOutsideClickListener();
    }

    handleMarkDoneToggle(event) {
        event.stopPropagation();
        const newValue = this.isCompleted ? 0 : 100;
        this.dispatchEvent(new CustomEvent('harveyballchange', {
            bubbles: true,
            composed: true,
            detail: {
                itemId: this.item.id,
                harveyBall: newValue,
                item: this.item
            }
        }));
    }

    handleDateClick(event) {
        event.stopPropagation();
        this.closeAllPopovers();
        this.startDate = this.item.startDate || null;
        this.dueDate = this.item.dueDate || null;
        this.showDatePopover = true;
        this.calculatePopoverPosition(event.currentTarget, 'date');
        this.addOutsideClickListener();
    }

    handleDateChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.target.value;
    }

    handleDateSave(event) {
        event.stopPropagation();
        this.dispatchEvent(new CustomEvent('datechange', {
            bubbles: true,
            composed: true,
            detail: {
                itemId: this.item.id,
                startDate: this.startDate,
                dueDate: this.dueDate,
                item: this.item
            }
        }));
        this.showDatePopover = false;
        this.removeOutsideClickListener();
    }

    handleTimeLogClick(event) {
        event.stopPropagation();
        this.closeAllPopovers();
        this.showTimeLogPopover = true;
        const triggerElement = this.template.querySelector('.time-log-container');
        this.calculatePopoverPosition(triggerElement, 'timeLog');
        this.addOutsideClickListener();
    }

    handleTimeLogChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.target.value;
    }

    async handleTimeLogSave(event) {
        event.stopPropagation();

        const estimation = Number(this.logTime) || 0;
        let hours = 0;
        const dailyHours = 8;
        switch (this.logDuration || '') {
            case 'Minutes':
                hours = estimation / 60;
                break;
            case 'Hours':
                hours = estimation;
                break;
            case 'Days':
                hours = estimation * dailyHours;
                break;
            case 'Weeks':
                hours = estimation * dailyHours * 5;
                break;
            case 'Months':
                hours = estimation * dailyHours * 20;
                break;
            default:
                hours = estimation;
        }

        const payload = {
            LogTime: JSON.stringify(new Date(this.logDate).toISOString()),
            KanbanCardID: this.item.id,
            Estimation: this.logTime || 0,
            Hours: Math.floor(hours),
            Description: this.logDescription || '',
            AssignedAUser: this.item.assignToId || '',
            Duration: this.logDuration || 'hours',
        };

        this.showTimeLogPopover = false;
        this.removeOutsideClickListener();

        try {
            await createCardLogAura({ cardLogData: payload });
            
            // Reset form on success
            this.logTime = 1;
            this.logDuration = 'Hours';
            this.logDescription = '';
            this.logDate = new Date().toISOString().split("T")[0];

        } catch (error) {
            console.error('Error creating time log:', error);
        }
    }

    /**
     * Handle Cancel button click in Time Log popover
     * Closes popover and resets form without saving
     */
    handleTimeLogCancel(event) {
        event.stopPropagation();
        this.showTimeLogPopover = false;
        this.removeOutsideClickListener();
        // Reset form to default values
        this.logDate = new Date().toISOString().split("T")[0];
        this.logTime = 1;
        this.logDuration = 'Hours';
        this.logDescription = '';
    }

    /**
     * Handle file upload icon click - open modal
     * Pattern from UpdatedMyWorkLWCCode 1/myWorkItems
     */
    handleFileClick(event) {
        event.stopPropagation();
        this.isFileUploadModalOpen = true;
    }

    /**
     * Close file upload modal
     * Pattern from UpdatedMyWorkLWCCode 1/myWorkItems
     */
    closeFileUploadModal() {
        this.isFileUploadModalOpen = false;
    }

    /**
     * Handle file count refresh after upload/delete
     * Pattern from UpdatedMyWorkLWCCode 1/myWorkItems
     */
    handleRefreshRecordCount(event) {
        const { action } = event.detail;
        const currentCount = this.item.filesCount || 0;

        if (action === 'add') {
            this.item.filesCount = currentCount + 1;
        } else if (action === 'remove' && currentCount > 0) {
            this.item.filesCount = currentCount - 1;
        }

        // Dispatch event to parent to update the item
        this.dispatchEvent(new CustomEvent('filecountchange', {
            bubbles: true,
            composed: true,
            detail: {
                itemId: this.item.id,
                filesCount: this.item.filesCount
            }
        }));
    }

    handleChatterClick(event) {
        event.stopPropagation();
        this.dispatchEvent(new CustomEvent('chatteropen', {
            bubbles: true,
            composed: true,
            detail: { itemId: this.item.id, item: this.item }
        }));
    }

    handleLightningAction(event) {
        event.stopPropagation();
        console.log('Lightning action clicked for item:', this.item.id);
        // Placeholder for quick action functionality
        // This could trigger a workflow, quick edit, or other action
        this.dispatchEvent(new CustomEvent('lightningaction', {
            bubbles: true,
            composed: true,
            detail: { itemId: this.item.id, item: this.item }
        }));
    }

    // Clickable Link Handlers
    handleProjectClick(event) {
        event.stopPropagation();
        // Dispatch event to open project in navigation
        this.dispatchEvent(new CustomEvent('projectclick', {
            bubbles: true,
            composed: true,
            detail: {
                projectId: this.item.projectId,
                projectName: this.item.projectName,
                item: this.item
            }
        }));
    }

    handleBoardClick(event) {
        event.stopPropagation();
        // Dispatch event to open board/value stream
        this.dispatchEvent(new CustomEvent('boardclick', {
            bubbles: true,
            composed: true,
            detail: {
                valueStreamId: this.item.valueStreamId,
                valueStreamName: this.item.valueStreamName,
                boardType: this.item.boardType,
                itemId: this.item.id,
                itemType: this.item.itemType,
                whatId: this.item.whatId, // For tasks
                item: this.item
            }
        }));
    }

    handleWhatClick(event) {
        event.stopPropagation();
        // Dispatch event to open board for the "what" container
        this.dispatchEvent(new CustomEvent('whatclick', {
            bubbles: true,
            composed: true,
            detail: {
                valueStreamId: this.item.valueStreamId,
                valueStreamName: this.item.valueStreamName,
                boardType: this.item.boardType,
                itemId: this.item.id,
                itemType: this.item.itemType,
                whatId: this.item.whatId,
                item: this.item
            }
        }));
    }

    handleItemNameClick(event) {
        event.stopPropagation();
        // Dispatch event to open board in new tab
        this.dispatchEvent(new CustomEvent('itemnameclick', {
            bubbles: true,
            composed: true,
            detail: {
                valueStreamId: this.item.valueStreamId,
                valueStreamName: this.item.valueStreamName,
                boardType: this.item.boardType,
                itemId: this.item.id,
                itemType: this.item.itemType,
                whatId: this.item.whatId, // For tasks
                openInNewTab: true,
                item: this.item
            }
        }));
    }

    // Popover Management
    // ADA Compliant - Convert pixels to rem for accessibility

    calculatePopoverPosition(triggerElement, popoverType = 'default') {
        if (!triggerElement) { return; }
        const rect = triggerElement.getBoundingClientRect();
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;

        // Estimated popover dimensions based on type (in pixels)
        const popoverDimensions = {
            priority: { width: 220, height: 180 },
            harveyBall: { width: 280, height: 100 },
            date: { width: 260, height: 220 },
            timeLog: { width: 448, height: 400 },
            default: { width: 240, height: 320 }
        };

        const dimensions = popoverDimensions[popoverType] || popoverDimensions.default;
        const popoverWidthPx = dimensions.width;
        const popoverHeightPx = dimensions.height;
        const marginPx = 16;
        const offsetPx = 4;

        let top = rect.bottom + offsetPx;
        let left = rect.left;

        const fitsBelow = (top + popoverHeightPx + marginPx) <= viewportHeight;
        const fitsAbove = (rect.top - popoverHeightPx - offsetPx) >= marginPx;

        if (!fitsBelow && fitsAbove) {
            top = rect.top - popoverHeightPx - offsetPx;
        } else if (!fitsBelow && !fitsAbove) {
            if (rect.top > (viewportHeight / 2)) {
                top = marginPx;
            } else {
                top = rect.bottom + offsetPx;
            }
        }

        if (popoverType === 'timeLog') {
            left = rect.right - popoverWidthPx;
            // Ensure it doesn't go off-screen to the left
            if (left < marginPx) {
                left = marginPx;
            }
        } else {
            const fitsRight = (left + popoverWidthPx + marginPx) <= viewportWidth;

            if (!fitsRight) {
                left = rect.right - popoverWidthPx;
                if (left < marginPx) {
                    left = viewportWidth - popoverWidthPx - marginPx;
                }
            }
        }

        left = Math.max(marginPx, Math.min(left, viewportWidth - popoverWidthPx - marginPx));
        top = Math.max(marginPx, Math.min(top, viewportHeight - popoverHeightPx - marginPx));

        const maxHeightPx = viewportHeight - top - marginPx;

        this.popoverStyle = `position: fixed; top: ${top}px; left: ${left}px; z-index: 9999; max-height: ${maxHeightPx}px; overflow-y: auto;`;
    }

    closeAllPopovers() {
        this.showPriorityPopover = false;
        this.showHarveyBallPopover = false;
        this.showDatePopover = false;
        this.showTimeLogPopover = false;
        this.isDropdownOpen = false; // Close priority dropdown
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    handleOutsideClick = (event) => {
        const path = event.composedPath && event.composedPath();
        const target = path ? path[0] : event.target;

        // If the click is inside any popover, do nothing.
        if (target.closest('.popover-container, .slds-popover, .dropdown-menu')) {
            return;
        }

        // Otherwise, the click is outside. Close all popovers.
        this.closeAllPopovers();
        this.removeOutsideClickListener();
    };

    addOutsideClickListener() {
        // Use capture phase and setTimeout to ensure proper event handling
        // Capture phase allows us to detect clicks even when stopPropagation is used
        setTimeout(() => {
            document.addEventListener('click', this.handleOutsideClick, true);
        }, 0);
    }

    removeOutsideClickListener() {
        document.removeEventListener('click', this.handleOutsideClick, true);
    }

    disconnectedCallback() {
        this.removeOutsideClickListener();
    }

    // Keyboard Navigation Handlers
    handleItemKeyDown(event) {
        const key = event.key;

        switch (key) {
            case 'Enter':
            case ' ': // Space key
                event.preventDefault();
                this.handleItemClick();
                break;
            case 'ArrowDown':
                event.preventDefault();
                this.focusNextItem();
                break;
            case 'ArrowUp':
                event.preventDefault();
                this.focusPreviousItem();
                break;
            default:
                break;
        }
    }

    focusNextItem() {
        const allItems = this.getAllWorkItems();
        const currentIndex = allItems.indexOf(this.template.querySelector('.work-item'));
        if (currentIndex < allItems.length - 1) {
            allItems[currentIndex + 1].focus();
        }
    }

    focusPreviousItem() {
        const allItems = this.getAllWorkItems();
        const currentIndex = allItems.indexOf(this.template.querySelector('.work-item'));
        if (currentIndex > 0) {
            allItems[currentIndex - 1].focus();
        }
    }

    getAllWorkItems() {
        const groupItems = this.template.closest('.group-items');
        if (groupItems) {
            return Array.from(groupItems.querySelectorAll('.work-item'));
        }
        return [];
    }

    handleCheckboxKeyDown(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            event.stopPropagation();
            // Handle checkbox toggle
            console.log('Checkbox toggled');
        }
    }

    handleQuickActionKeyDown(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            event.stopPropagation();
            // Handle quick action
            console.log('Quick action triggered');
        }
    }
}