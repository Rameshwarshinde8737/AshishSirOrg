import { LightningElement, track, api, wire } from 'lwc';
import LEANKOR_ICONS from '@salesforce/resourceUrl/leankorIcons';
import uuidLib from '@salesforce/resourceUrl/uuidLib';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { locale } from './local';
import { apexService } from './apexService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MyWorkItems extends LightningElement {
    @api recordId;
    @track workSections = [];
    @track filterStartDate;
    @track filterEndDate;
    @track startDate;
    @track dueDate;
    @track selectedWorkBy = 'WORKBYDUEDATE';
    @track isActive = false;
    @track isPopoverOpen = false;
    @track popoverStyle = '';
    @track isModalOpen = false;
    @track isChatterOpen = false;
    @track activeChild = null;
    @track sessionId;
    isLoading = false;
    selectedDateChildData = null;
    isDateFilterOpen 
    durationOptions = [
        { label: 'Minutes', value: 'Minutes' },
        { label: 'Hours', value: 'Hours' },
        { label: 'Days', value: 'Days' },
        { label: 'Weeks', value: 'Weeks' },
        { label: 'Months', value: 'Months' },
    ];
    logDate = new Date().toISOString().split("T")[0];
    logTime = 1;
    logDuration = "Hours";
    logDescription = null;
    statusOptions = [
        { value: 0, class: 'icon-uniA3C pointer slds-m-horizontal_x-small status-icon slds-button slds-button_icon' },
        { value: 25, class: 'icon-uniA3D pointer slds-m-horizontal_x-small status-icon slds-button slds-button_icon' },
        { value: 50, class: 'icon-uniA3E pointer slds-m-horizontal_x-small status-icon slds-button slds-button_icon' },
        { value: 75, class: 'icon-uniA3F pointer slds-m-horizontal_x-small status-icon slds-button slds-button_icon' },
        { value: 100, class: 'icon-uniA40 pointer slds-m-horizontal_x-small status-icon slds-button slds-button_icon' }
    ];
    get filterLabel() {
        const format = d => d ? this.formatDate(d) : 'dd/mm/yyyy';
        return `Date From ${format(this.filterStartDate)} To ${format(this.filterEndDate)}`;
    }
    
    formatDate(dateStr) {
        const date = new Date(dateStr);
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        return `${day}/${month}/${year}`;
    }

    connectedCallback() {
        Promise.all([
            loadScript(this, uuidLib),
            loadStyle(this, LEANKOR_ICONS + '/style.css')
        ])
            .then(() => {
                console.log('UUID lib and Leankor icons styles loaded successfully');
                this.loadWorkItems(this.buildFilterData("WORKBYDUEDATE"));
            })
            .catch(error => {
                console.error('Error loading resources:', error);
            });

        apexService.getSessionId().then(sessionId => {
            return initializeCometD(this, externallibs, sessionId);
        })
            .then(data => {
                this.sessionId = data;
                console.log('✅ CometD initialized');
                window.addEventListener('kanbanupdate', this.handleBroadcast);
            })
            .catch(error => {
                console.error('Error fetching session ID:', error);
                this.sessionId = undefined;
            });
    }

    buildFilterData(filterType, start = null, end = null) {
        return { rangeStartDate: start, rangeEndDate: end, filterType };
    }

    updateSections(updater) {
        this.workSections = this.workSections.map(updater);
    }

    updateChildren(section, updater) {
        return {
            ...section,
            children: section.children ? section.children.map(updater) : []
        };
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    getHarveyBallIconClass(harveyBall) {
        switch (harveyBall) {
            case 0: return 'icon-round-check-unchecked';
            case 25: return 'icon-uniA3D';
            case 50: return 'icon-uniA3E';
            case 75: return 'icon-uniA3F';
            case 100: return 'icon-uniA40';
            default: return 'icon-round-check-unchecked';
        }
    }

    getHarveyBallIconColor(harveyBall) {
        return harveyBall === 100 ? 'green' : '';
    }

    async loadWorkItems(filterData) {
        try {
            const result = await this.runWithLoader(() => apexService.fetchWorkItems(filterData));
            this.workSections = result.map(item => {
                const rawName = item.Name || "";
                const label = locale.myWorkLabel[rawName] || rawName;
                return {
                    ...item,
                    Name: rawName,
                    Label: label,
                    dotStyle: `background-color:${item.Color};`,
                    hasBeenOpened: false
                };
            });
        } catch (error) {
            console.error("Error fetching work items:", error);
        }
    }

    handleChange(event) {
        const value = event.target.value;
        this.selectedWorkBy = value;
        this.loadWorkItems(this.buildFilterData(value));
    }

    handleDateChange(event) {
        const { name, value } = event.target;
        this[name] = value || null;
        const bothEmpty = !this.filterStartDate && !this.filterEndDate;
        const bothFilled = this.filterStartDate && this.filterEndDate;
        if (bothEmpty || bothFilled) {
            this.loadWorkItems(
                this.buildFilterData("WORKBYDUEDATE", this.filterStartDate, this.filterEndDate)
            );
        }
    }

    async handleAccordionClick(event) {
        const btn = event.currentTarget;
        const sectionName = btn.dataset.name;
        const panel = btn.nextElementSibling;
        const icon = btn.querySelector(".accordion-icon");
        const section = this.workSections.find(sec => sec.Name === sectionName);

        if (section && !section.hasBeenOpened) {
            this.updateSections(sec =>
                sec.Name === sectionName ? { ...sec, isLoading: true, hasBeenOpened: true } : sec
            );

            const filterData = {
                filterType: this.selectedWorkBy,
                priorityType: this.selectedWorkBy === 'PRIORITYWORK' ? section.PriorityIndex : null,
                projectId: section?.Id,
                itemType: this.selectedWorkBy === 'WORKBYTYPE' ? sectionName : null,
                dueDateType: this.selectedWorkBy === 'WORKBYDUEDATE' ? sectionName : null,
                completedType: null,
                rangeStartDate: this.filterStartDate || null,
                rangeEndDate: this.filterEndDate || null
            };

            try {
                const result = await apexService.getWorkItemsByFilter(filterData);
                this.updateSections(sec =>
                    sec.Name === sectionName
                        ? {
                            ...sec,
                            children: result.map(child => ({
                                ...child,
                                priorityColorClass: this.getPriorityIconClass(child.Priority),
                                iconCircleClass: child.HarveyBall === 100 ? 'icon-round-check-checked green slds-m-left_x-small pointer slds-button slds-button_reset' : 'icon-circle-check slds-m-left_x-small pointer slds-button slds-button_reset',
                                statusClass: `${this.getHarveyBallIconClass(child.HarveyBall)} slds-m-left_x-small pointer  slds-button slds-button_reset ${this.getHarveyBallIconColor(child.HarveyBall)}`,
                                openPopup: null,
                                isDropdownOpen: false,
                                isDateOpen: false,
                                isClockOpen: false,
                                isTask: child.ItemType === 'TASK',
                                statusOptions: this.statusOptions.map(opt => ({
                                    ...opt,
                                    class: opt.value === child.HarveyBall
                                        ? `${opt.class} green`
                                        : opt.class
                                })),
                            })),
                            isLoading: false
                        }
                        : sec
                );

                requestAnimationFrame(() => {
                    panel.style.maxHeight = panel.scrollHeight + "px";
                    panel.style.overflow = "visible";
                    icon.iconName = "utility:chevronup";
                    btn.classList.add("active");
                });
            } catch (error) {
                this.updateSections(sec =>
                    sec.Name === sectionName ? { ...sec, isLoading: false } : sec
                );
            }
        } else {
            btn.classList.toggle("active");
            const isOpen = panel.style.maxHeight;
            panel.style.maxHeight = isOpen ? null : panel.scrollHeight + "px";
            if (isOpen) {
                panel.style.maxHeight = null;
                panel.style.overflow = "hidden";
                panel.setAttribute("aria-hidden", "true");
                icon.setAttribute("icon-name", "utility:chevrondown");
                panel.querySelectorAll("a, button, input, textarea, select, [tabindex]").forEach(el => {
                    el.setAttribute("tabindex", "-1");
                });
            } else {
                panel.style.maxHeight = panel.scrollHeight + "px";
                panel.style.overflow = "visible";
                panel.setAttribute("aria-hidden", "false");
                icon.iconName = "utility:chevronup";
                panel.querySelectorAll("a, button, input, textarea, select, [tabindex]").forEach(el => {
                    el.removeAttribute("tabindex");
                });
            }
        }
    }

    async handleUpdatePriority(event) {
        event.stopPropagation();
        const value = event.currentTarget.dataset.value;
        const childId = event.currentTarget.dataset.id;
        const childData = this.workSections
            .flatMap(section => section.children || [])
            .find(c => c.Id === childId);
        const priorityData = {
            Id: childData.Id,
            Name: childData.Title,
            Priority: this.mapPriorityValue(value),
            ValueStream: childData.ValueStream
        };
        this.removeChildFromSections(childId);
        this.updateSections(section =>
            this.updateChildren(section, c => {
                if (c.Id === childData.Id) {
                    return {
                        ...c,
                        Priority: this.mapPriorityValue(value),
                        priorityColorClass: this.getPriorityIconClass(this.mapPriorityValue(value)),
                        isDropdownOpen: false,
                        openPopup: null
                    };
                }
                return c;
            })
        );
        const updatedChild = {
            ...childData,
            Priority: this.mapPriorityValue(value),
            priorityColorClass: this.getPriorityIconClass(this.mapPriorityValue(value)),
            isDropdownOpen: false,
            openPopup: null
        };
        const sectionName = this.workSections.find(sec => sec.PriorityIndex === this.mapPriorityValue(value))?.Name;
        this.addChildToSection(updatedChild, sectionName);
        try {
            await this.runWithLoader(() =>
                apexService.updatePriority(priorityData)
            );

        } catch (error) {
            console.error('Error updating priority:', error);
        }
    }

    getPriorityIconClass(priority) {
        switch (priority) {
            case 1: return 'priority-red pointer icon-star-full1 slds-button slds-button_reset';
            case 2: return 'priority-blue pointer icon-star-full1 slds-button slds-button_reset';
            case 3: return 'priority-green pointer icon-star-full1 slds-button slds-button_reset';
            default: return 'pointer icon-star-full1 slds-button slds-button_reset';
        }
    }

    mapPriorityValue(label) {
        switch (label) {
            case 'Low': return 3;
            case 'Medium': return 2;
            case 'Critical': return 1;
            default: return null;
        }
    }

    get viewOptions() {
        return [
            { label: 'Work by Due Date', value: 'WORKBYDUEDATE' },
            { label: 'Work by Project', value: 'WORKBYPROJECT' },
            { label: 'My Priority Work', value: 'PRIORITYWORK' },
            { label: 'Work by Type', value: 'WORKBYTYPE' }
        ];
    }

    get workItemsCount() {
        return this.workSections.reduce((total, section) => total + (section.ChildCount || 0), 0);
    }

    async handleSeeTasksToggle(event) {
        const isChecked = event.target.checked;
        try {
            const result = await this.runWithLoader(() => apexService.updateTaskLoad(isChecked));
            this.loadWorkItems(this.buildFilterData("WORKBYDUEDATE"));
            console.log('Toggle updated, server returned:', result);
        } catch (err) {
            console.error('Error updating task load toggle:', err);
        }
    }

    stopClose(event) {
        event.stopPropagation();
    }

    openPopup(event) {
        event.stopPropagation();
        const childId = event.currentTarget.dataset.id;
        const popupType = event.currentTarget.dataset.type;
        this.updateSections(section =>
            this.updateChildren(section, child => {
                if (child.Id === childId) {
                    const isOpen = child.openPopup === popupType ? null : popupType;
                    if (isOpen === 'date') {
                        this.fetchKanbanCardRecord(childId);
                    }
                    return {
                        ...child,
                        openPopup: isOpen,
                        isStatusOpen: popupType === 'status',
                        isDropdownOpen: isOpen === 'dropdown',
                        isDateOpen: isOpen === 'date',
                        isClockOpen: isOpen === 'clock',
                    };
                }
                return {
                    ...child,
                    openPopup: null,
                    isStatusOpen: false,
                    isDropdownOpen: false,
                    isDateOpen: false,
                    isClockOpen: false
                };
            })
        );

        const anyOpen = this.workSections.some(sec =>
            sec.children?.some(c => c.openPopup)
        );

        if (anyOpen) {
            document.addEventListener("click", this.handleOutsideClick);
        } else {
            document.removeEventListener("click", this.handleOutsideClick);
        }
    }

    closePopup(event) {
        event.stopPropagation();
        const childId = event.currentTarget.dataset.id;
        const popupType = event.currentTarget.dataset.type;
        this.updateSections(section =>
            this.updateChildren(section, child => {
                if (child.Id === childId) {
                    return {
                        ...child,
                        openPopup: null,
                        isDateOpen: popupType === 'date' ? false : child.isDateOpen,
                        isClockOpen: popupType === 'clock' ? false : child.isClockOpen,
                        isStatusOpen: popupType === 'status' ? false : child.isStatusOpen
                    };
                }
                return child;
            })
        );

        const anyOpen = this.workSections.some(sec =>
            sec.children?.some(c => c.openPopup)
        );

        if (!anyOpen) {
            document.removeEventListener("click", this.handleOutsideClick);
        }
    }

    handleOutsideClick = (event) => {
        if (event.target.closest('.slds-popover')) {
            return;
        }

        this.updateSections(section =>
            this.updateChildren(section, child => ({
                ...child,
                openPopup: null,
                isDropdownOpen: false,
                isDateOpen: false,
                isClockOpen: false,
                isStatusOpen: false
            }))
        );
        this.isDateFilterOpen = false;
        this.template.removeEventListener("click", this.handleOutsideClick);
    };

    openFileUploadModal(event) {
        const childId = event.currentTarget.dataset.id;
        for (let section of this.workSections) {
            const child = section.children.find(c => c.Id === childId);
            if (child) {
                this.activeChild = child;
                break;
            }
        }
        this.isModalOpen = true;
    }

    openChatterModal(event) {
        const childId = event.currentTarget.dataset.id;
        for (let section of this.workSections) {
            const child = section.children.find(c => c.Id === childId);
            if (child) {
                this.activeChild = child;
                break;
            }
        }
        this.isChatterOpen = true;
    }

    async closeChatterModal() {
        this.isChatterOpen = false;

        if (this.activeChild?.Id) {
            try {
                const result = await this.runWithLoader(() =>
                    apexService.fetchRelatedRecordCount([this.activeChild.Id])
                );
                const childId = this.activeChild.Id;
                const record = result?.[childId] || {};
                this.updateSections(section =>
                    this.updateChildren(section, child => {
                        if (child.Id === childId) {
                            return {
                                ...child,
                                ChatterCount: record.chattersCount || 0,
                                filesCount: record.filesCount || 0
                            };
                        }
                        return child;
                    })
                );
            } catch (error) {
                console.error('Error fetching related record counts in closeChatterModal:', error);
            }
        }

        this.activeChild = null;
    }

    closefileUploadModal() {
        this.isModalOpen = false;
        this.activeChild = null;
    }

    handlePopoverDateChange(event) {
        const { name, value } = event.target;
        const childId = event.currentTarget.dataset.id;

        const childData = this.workSections
            .flatMap(section => section.children || [])
            .find(c => c?.Id === childId);


        if (name === 'dueDate') {
            const startDate = new Date(this.startDate);
            startDate.setHours(0, 0, 0, 0);
            const dueDateObj = new Date(value);
            dueDateObj.setHours(0, 0, 0, 0);

            const finalDueDate = dueDateObj < startDate ? new Date(startDate) : dueDateObj;
            const formattedDue = this.formatDate(finalDueDate);

            // Force sync UI & state
            event.target.value = formattedDue;
            this.dueDate = formattedDue;
            this.dueDateKey++;
            return;
        }

        // Update startDate
        this[name] = value || null;
        const startDate = new Date(this.startDate);
        startDate.setHours(0, 0, 0, 0);

        // === Auto-calculate due date from duration ===
        const durationVal = parseInt(childData?.EstimatedDuration, 10) || 0;
        const durationUnit = childData?.DurationUnits || 'Days';
        const workdayHours = 8;
        const sevenDay = true;

        let calculatedDue;

        switch (durationUnit) {
            case 'Minutes': {
                const days = Math.ceil(durationVal / (workdayHours * 60)) - 1;
                calculatedDue = this.addDays(startDate, days);
                break;
            }
            case 'Hours': {
                const days = Math.ceil(durationVal / workdayHours) - 1;
                calculatedDue = this.addDays(startDate, days);
                break;
            }
            case 'Days':
                calculatedDue = this.addDays(startDate, durationVal - 1);
                break;
            case 'Weeks': {
                const daysPerWeek = sevenDay ? 7 : 5;
                calculatedDue = this.addDays(startDate, daysPerWeek * durationVal - 1);
                break;
            }
            case 'Months': {
                const tmp = this.addMonths(startDate, durationVal);
                calculatedDue = this.addDays(tmp, -1);
                break;
            }
            case 'Years': {
                const tmp = this.addYears(startDate, durationVal);
                calculatedDue = this.addDays(tmp, -1);
                break;
            }
            default:
                calculatedDue = this.addDays(startDate, durationVal - 1);
        }

        this.dueDate = this.formatDate(calculatedDue);
        this.dueDateKey++;
    }

    // === Utility Functions ===

    addDays(date, days) {
        const result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }

    addMonths(date, months) {
        const result = new Date(date);
        const day = result.getDate();
        result.setDate(1);
        result.setMonth(result.getMonth() + months);
        const lastDay = new Date(result.getFullYear(), result.getMonth() + 1, 0).getDate();
        result.setDate(Math.min(day, lastDay));
        return result;
    }

    addYears(date, years) {
        const result = new Date(date);
        const day = result.getDate();
        result.setFullYear(result.getFullYear() + years);
        if (result.getDate() !== day) result.setDate(0);
        return result;
    }

    formatDate(date) {
        return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
    }
    
    async fetchKanbanCardRecord(recordId) {
        // this.isLoading = true;
        try {
            const result = await this.runWithLoader(() => apexService.fetchKanbanCardRecord(recordId));
            this.selectedDateChildData = result;
            this.startDate = result.StartDate;
            this.dueDate = result.DueDate;
        } finally {
            // this.isLoading = false;
        }
    }

    async handleDateSave(event) {
        const recordId = event.target.dataset.id;
        try {
            const start = new Date(this.startDate);
            const due = new Date(this.dueDate);
            const diffTime = due - start;
            const estimatedDuration = diffTime > 0
                ? Math.ceil(diffTime / (1000 * 60 * 60 * 24))
                : 0;
            const taskData = this.workSections.flatMap(section => section.children || []).find(c => c.Id === recordId);
            const previosData = JSON.stringify({
                Id: this.selectedDateChildData.Id,
                DueDate: this.selectedDateChildData.DueDate,
                StartDate: this.selectedDateChildData.StartDate,
                EstimatedDuration: this.selectedDateChildData.EstimatedDuration,
                DurationUnits: this.EffortUnit
            });
            const newData = JSON.stringify({
                SessionID: this.sessionId,
                SomeJSONData: JSON.stringify({ ...taskData, StartDate: this.withCurrentTime(this.startDate), DueDate: this.withCurrentTime(this.dueDate), EstimatedDuration: estimatedDuration }),
                VSID: this.selectedDateChildData.ValueStreamId,
                Verb: "UpdateKanbanCard",
            });
            await this.runWithLoader(() =>apexService.updateKanbanCardDates(previosData, newData));
            this.removeChildFromSections(recordId);
            const updatedChild = {
                ...taskData,
                StartDate: this.startDate,
                DueDate: this.dueDate,
                EstimatedDuration: estimatedDuration,
                isDateOpen: false,
                openPopup: null
            };
            this.addChildToSection(updatedChild);
        } catch (err) {
            console.error('Error updating Kanban card dates:', err);
        }
    }

    withCurrentTime(dateStr) {
        const base = new Date(dateStr);
        const now = new Date();
        base.setHours(now.getHours(), now.getMinutes(), now.getSeconds(), now.getMilliseconds());
        return base.toISOString();
    }

    removeChildFromSections(childId) {
        this.workSections = this.workSections.map(section => {
            if (section.children?.length) {
                const newChildren = section.children.filter(c => c.Id !== childId);
                return {
                    ...section,
                    children: newChildren,
                    ChildCount: newChildren.length
                };
            }
            return section;
        });
    }

    getSectionNameForDate(dueDate) {
        const diffDays = (new Date(dueDate).setHours(0, 0, 0, 0) - new Date().setHours(0, 0, 0, 0)) / 86_400_000;
        return diffDays < 0 ? "MWOverdue" :
            diffDays === 0 ? "MWDueToday" :
                diffDays <= 7 ? "MWThisWeek" :
                    diffDays <= 30 ? "MWNext30Days" : "MWLater";
    }

    addChildToSection(updatedChild, sectionName = null) {
        const targetSection = sectionName || this.getSectionNameForDate(updatedChild.DueDate);
        const childWithFlags = {
            ...updatedChild,
            priorityColorClass: this.getPriorityIconClass(updatedChild.Priority || ''),
            openPopup: null,
            isDropdownOpen: false,
            isDateOpen: false,
            isClockOpen: false,
            isTask: updatedChild.ItemType === 'TASK'
        };
        this.workSections = this.workSections.map(section => {
            if (section.Name === targetSection) {
                const newChildren = [...(section.children || []), childWithFlags];
                return {
                    ...section,
                    children: newChildren,
                    ChildCount: newChildren.length
                };
            }
            return section;
        });
        requestAnimationFrame(() => {
            const panel = this.template.querySelector(`.panel[data-name="${targetSection}"]`);
            const btn = this.template.querySelector(`.accordion[data-name="${targetSection}"]`);
            const icon = btn?.querySelector(".accordion-icon");
            if (panel && btn && btn.classList.contains("active")) {
                panel.style.maxHeight = panel.scrollHeight + "px";
                panel.style.overflow = "visible";
                icon?.setAttribute("icon-name", "utility:chevronup");
            }
        });
    }

    async handleLogSave(event) {
        event.stopPropagation();
        const childId = event.currentTarget.dataset.id;
        const childData = this.workSections
            .flatMap(section => section.children || [])
            .find(c => c.Id === childId);

        const estimation = Number(this.logTime) || 0;
        let hours = 0;
        let dailyHours = 8;
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
            KanbanCardID: childData.Id,
            Estimation: this.logTime || 0,
            Hours: Math.floor(hours),
            Description: this.logDescription || '',
            AssignedAUser: childData.AssignToId || '',
            Duration: this.logDuration || 'hours',
        };

        this.updateSections(section =>
                this.updateChildren(section, child => {
                    if (child.Id === childId) {
                        return {
                            ...child,
                            isClockOpen: false,
                            openPopup: null
                        };
                    }
                    return child;
                })
            );

        try {
            await this.runWithLoader(() => apexService.createCardLog(payload));
            this.logTime = 1;
            this.logDuration = 'Hours';
            this.logDescription = null;
            this.logDate = new Date().toISOString().split("T")[0];
        } catch (error) {
            console.error('Error creating log:', error);
        }
    }

    async handleStateChange(event) {
        const { id: childId, type, value } = event.currentTarget.dataset;
        const childData = this.workSections
            .flatMap(section => section.children || [])
            .find(c => c.Id === childId);
        const newHarveyBall =
            type === "markDone"
                ? (childData.HarveyBall === 100 ? 0 : 100)
                : parseInt(value, 10);
        const payload = JSON.stringify({
            Id: childData.Id,
            GUID: childData.GUID,
            Name: childData.Name,
            HarveyBall: newHarveyBall,
            KanbanUrl: '',
            ItemType: childData.ItemType,
            BoardType: childData.BoardType,
            ValueStreamCardLink: childData.ValueStreamCardLink,
            ValueStream: childData.ValueStream
        });
        this.updateSections(section =>
            this.updateChildren(section, c => {
                if (c.Id === childData.Id) {
                    return {
                        ...c,
                        HarveyBall: newHarveyBall,
                        iconCircleClass: newHarveyBall === 100 ? 'icon-round-check-checked green slds-m-left_x-small pointer slds-button slds-button_reset' : 'icon-circle-check slds-m-left_x-small pointer slds-button slds-button_reset',
                        statusClass: `${this.getHarveyBallIconClass(newHarveyBall)} slds-m-left_x-small pointer slds-button slds-button_reset ${this.getHarveyBallIconColor(newHarveyBall)}`,
                        isStatusOpen: false,
                        statusOptions: this.statusOptions.map(opt => ({
                            ...opt,
                            class: opt.value === newHarveyBall
                                ? `${opt.class} green`
                                : opt.class
                        })),
                    };
                }
                return c;
            })
        );
        try {
            await this.runWithLoader(() => apexService.changeKanbanState(childData.ValueStream, 'UpdateHarveyBall', this.sessionId, payload));

        } catch (error) {
            console.error('Error in kanbanStateChange:', error);
        }
    }

     async handleRefreshRecordCount(event) {
        const childId = event.detail.childId;
        const action = event.detail.action;
 
        if (action === 'remove') {
            this.updateSections(section =>
                this.updateChildren(section, child =>
                    child.Id === childId
                        ? { ...child, filesCount: child.filesCount - 1, ChatterCount: child.ChatterCount - 1 }
                        : child
                )
            );
            return;
        }
        try {
            const result = await this.runWithLoader(() => apexService.fetchRelatedRecordCount([childId]));
            if(result || result[childId]) {
                 this.updateSections(section =>
            this.updateChildren(section, child =>
                child.Id === childId
                    ? { ...child, ChatterCount: result[childId].chattersCount, filesCount: result[childId].filesCount }
                    : child
            )
        );
            }
        } catch (error) {
             console.error('Error fetching related record counts:', error);
        }
    }

    handleOpenKanbanBorad(event) {
        const childId = event.currentTarget.dataset.id;
        const childData = this.workSections
            .flatMap(section => section.children || [])
            .find(c => c.Id === childId);
        const vfUrl = `/apex/leankor__KanbanBoard?Id=${childData.ValueStream}&cardid=${childData.Id}`;
        this.dispatchEvent(new CustomEvent('openvf', {
            detail: { vfUrl }
        }));
    }

    // Date Filter Popover Methods
    toggleDateFilterPopover(event) {
        event.stopPropagation();

        this.isDateFilterOpen = !this.isDateFilterOpen;
        if (this.isDateFilterOpen) {
            document.addEventListener("click", this.handleOutsideClick);
        }
    }

    handleFilterDateChange(event) {
        const { name, value } = event.target;
        this[name] = value || null;
        if (name === 'filterStartDate') {
            // Set it first
            this.filterStartDate = value;

            // Check and correct
            if (this.filterEndDate && new Date(value) > new Date(this.filterEndDate)) {
                // Force the update by resetting the value temporarily
                this.filterStartDate = null;
                setTimeout(() => {
                    this.filterStartDate = this.filterEndDate;
                }, 0);
            }

        } else if (name === 'filterEndDate') {
            this.filterEndDate = value;

            if (this.filterStartDate && new Date(value) < new Date(this.filterStartDate)) {
                this.filterEndDate = null;
                setTimeout(() => {
                    this.filterEndDate = this.filterStartDate;
                }, 0);
            }
        }
    }

    handleFilterSave() {

        // Check if both dates are selected
        if (!this.filterStartDate || !this.filterEndDate) {
            this.showToast('Error', 'Both Start Date and End Date must be selected.', 'error');
            return;
        }

        // Convert to Date objects for comparison
        const start = new Date(this.filterStartDate);
        const end = new Date(this.filterEndDate);

        if (start > end) {
             this.showToast('Error', 'Start Date must be before or equal to End Date.', 'error');
            return;
        }

        // Dates are valid, proceed with saving
        this.isDateFilterOpen = false;
        this.loadWorkItems(
            this.buildFilterData("WORKBYDUEDATE", this.filterStartDate, this.filterEndDate)
        );
        document.removeEventListener("click", this.handleOutsideClick);
    }

    handleFilterDelete() {
        this.filterStartDate = null;
        this.filterEndDate = null;
        this.isDateFilterOpen = false;
        this.loadWorkItems(this.buildFilterData("WORKBYDUEDATE"));
    }

    handleFilterCancel() {
        this.isDateFilterOpen = false;
    }

    showToast(title, message, variant = 'info') {
        const event = new ShowToastEvent({
            title,
            message,
            variant, // 'success', 'error', 'warning', 'info'
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    async runWithLoader(promiseFn) {
        this.isLoading = true;
        try {
            return await promiseFn();
        } finally {
            this.isLoading = false;
        }
    }
}