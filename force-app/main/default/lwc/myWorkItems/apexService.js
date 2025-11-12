import getMyWorkItemListAura from '@salesforce/apex/ProjectBoardCarousel.getMyWorkItemListAura';
import getWIByFilter from '@salesforce/apex/ProjectBoardCarousel.getWIByFilter';
import updatePriority from '@salesforce/apex/ProjectBoardCarousel.updatePriority';
import updateMyWorkTaskLoad from '@salesforce/apex/ProjectBoardCarousel.updateMyWorkTaskLoad';
import getKanbanCardRecordAura from '@salesforce/apex/realTimeController.getKanbanCardRecordAura';
import updatekanbanCardDates from '@salesforce/apex/ProjectBoardCarousel.updatekanbanCardDates';
import createCardLogAura from '@salesforce/apex/KanbanController.createCardLogAura';
import kanbanStateChange from '@salesforce/apex/realTimeController.kanbanStateChange';
import fatchRelatedRecordCount from '@salesforce/apex/GanttTaskBoard.fatchRelatedRecordCount';
import getSessionId from '@salesforce/apex/GanttLWCExtraCode.getSessionId';

export const apexService = {
    async getSessionId() {
        try {
            return await getSessionId();
        } catch (error) {
            console.error('Error fetching session ID:', error);
            throw error;
        }
    },

    async fetchWorkItems(filterData) {
        try {
            return await getMyWorkItemListAura({ filterData: JSON.stringify(filterData) });
        } catch (error) {
            console.error('Error fetching work items:', error);
            throw error;
        }
    },

    async getWorkItemsByFilter(filterData) {
        try {
            return await getWIByFilter({ filterData: JSON.stringify(filterData) });
        } catch (error) {
            console.error('Error fetching child data:', error);
            throw error;
        }
    },

    async updatePriority(priorityData) {
        try {
            return await updatePriority({ priorityData1: JSON.stringify(priorityData) });
        } catch (error) {
            console.error('Error updating priority:', error);
            throw error;
        }
    },

    async updateTaskLoad(myWorkLoadsTasks) {
        try {
            return await updateMyWorkTaskLoad({ myWorkLoadsTasks });
        } catch (error) {
            console.error('Error updating task load toggle:', error);
            throw error;
        }
    },

    async fetchKanbanCardRecord(recordId) {
        try {
            return await getKanbanCardRecordAura({
                kanbanJSON: JSON.stringify({ Id: recordId }),
                boardVerb: 'other'
            });
        } catch (error) {
            console.error('Error fetching Kanban card record:', error);
            throw error;
        }
    },

    async updateKanbanCardDates(previosData, newData) {
        try {
            return await updatekanbanCardDates({ previosData, newData });
        } catch (error) {
            console.error('Error updating Kanban card dates:', error);
            throw error;
        }
    },

    async createCardLog(request) {
        try {
            return await createCardLogAura({ request });
        } catch (error) {
            console.error('Error creating log:', error);
            throw error;
        }
    },

    async changeKanbanState(valueStreamId, verb, sessionId, jsonData) {
        try {
            return await kanbanStateChange({ valueStreamId, verb, sessionId, jsonData });
        } catch (error) {
            console.error('Error in kanbanStateChange:', error);
            throw error;
        }
    },

    async fetchRelatedRecordCount(ids) {
        try {
            return await fatchRelatedRecordCount({ ids });
        } catch (error) {
            console.error('Error fetching related record counts:', error);
            throw error;
        }
    }
};