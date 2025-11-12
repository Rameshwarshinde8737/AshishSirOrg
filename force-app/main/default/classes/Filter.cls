public with sharing class Filter {
    public List<leankor__Filter__c> readFilters(String dynamicQuery) {
        // Queries and returns a list of queried Filter records
        return Database.query(dynamicQuery);
    }

    public List<leankor__Filter__c> createFilters(List<leankor__Filter__c> filters) {
        FilterBehaviour filterBehaviour = new FilterBehaviour();
        if (!filterBehaviour.isUpdateable() ||
            !filterBehaviour.isCreateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        // Insert the provided filters and return the created list
        Savepoint savePoint = Database.setSavepoint();
        try {
            upsert filters;
        } catch(Exception e){
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
        
        return filters;
    }

    public List<leankor__Filter__c> updateFilters(List<leankor__Filter__c> filters) {
        FilterBehaviour filterBehaviour = new FilterBehaviour();
        if (!filterBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        // Update the provided filters and return the updated list
        Savepoint savePoint = Database.setSavepoint();
        try {
            update filters;
        } catch(Exception e){
            Database.rollback(savePoint);
            throw new Util.LeanException('Error: ' + e.getmessage());
        }
        return filters;
    }

    public List<leankor__Filter__c> readFilters(List<leankor__ValueStream__c> valueStreams) {
        return [Select Id, 
                        Name,
                        leankor__CurrentView__c 
                    From leankor__Filter__c 
                    Where leankor__ValueStream__c In :valueStreams 
                        And leankor__User__c = :UserInfo.getUserId()
                    With Security_Enforced
                    Limit 50000];
    }

    //overloaded method of readFilters
    public List<leankor__Filter__c> readFilters(List<Id> filterIds) {
        List<leankor__Filter__c> getFilters = [Select Id,
                                                    leankor__OwnerData__c,
                                                    leankor__BoardURL__c, 
                                                    leankor__DefaultFilter__c, 
                                                    leankor__FilterON__c, 
                                                    leankor__User__c,
                                                    leankor__PriorityData__c,
                                                    leankor__StickerData__c,
                                                    leankor__CategoryData__c,
                                                    leankor__PortfolioLinkData__c,
                                                    leankor__ValueStream__c,
                                                    Name,
                                                    OwnerId,
                                                    leankor__FeatureData__c, 
                                                    leankor__MiniatureName__c,
                                                    leankor__PercentCompleteRangeFilter__c,
                                                    leankor__VisibleColumnWidth__c,
                                                    leankor__GanttDividerSize__c,
                                                    leankor__CurrentView__c,
                                              		leankor__ValueStream__r.leankor__BoardType__c,
                                                    leankor__HideSchedule__c
                                                From leankor__Filter__c 
                                                Where Id = :filterIds 
                                                With Security_Enforced
                                                Order By SystemModstamp 
                                                Limit 50000];

        return getFilters;                                             
    }
}