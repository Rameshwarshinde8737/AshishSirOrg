global with sharing class LeankorViewController {
    private static final String ORG_DOMAIN_URL = getDomainURL();


    public LeankorViewController() {
    }
   

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getGanttViewURL(final String whatId) {
        String viewURL = '';
        if (whatId InstanceOf Id) {
            switch on Util.getSObjectName(whatId) {
                when 'leankor__ProjectRoom__c' {
                    leankor__ValueStream__c valueStream = readValueStream('UberBoard', 'leankor__ProjectRoom__c', whatId);
                    if (valueStream != null) {
                        viewURL = ORG_DOMAIN_URL
                        + '/leankor__GanttView?fid='
                        + valueStream.leankor__ProjectRoom__c 
                        + '&btype=projectgantt&Id=' 
                        + valueStream.Id;
                    }
                }
                when 'leankor__ValueStream__c' {
                    leankor__ValueStream__c valueStream = readValueStream('', 'Id', whatId);
                    // recursive call
                    if (valueStream != null) {
                        viewURL = getGanttViewURL(valueStream.leankor__ProjectRoom__c); // recursive call
                    }

                    /*
                    // non-recursive but more efficient
                    if (valueStream != null) {
                        if (valueStream.leankor__BoardType__c != 'UberBoard') {
                            valueStream = readValueStream('UberBoard', 'leankor__ProjectRoom__c', valueStream.leankor__ProjectRoom__c);
                        }
                    }  
                    if (valueStream != null) {
                        viewURL = ORG_DOMAIN_URL
                        + '/leankor__GanttView?fid='
                        + valueStream.leankor__ProjectRoom__c 
                        + '&btype=projectgantt&Id=' 
                        + valueStream.Id;
                    }
                    */
                }
            }
        }
        return viewURL;
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getKanbanViewURL(final String whatId) {
        String viewURL = '';
        if (whatId InstanceOf Id && Util.getSObjectName(whatId) == 'leankor__ValueStream__c') {
            viewURL = ORG_DOMAIN_URL
                    + '/leankor__KanbanBoard?Id='
                    + whatId
                    + '&isLightning=true';
        }
        return viewURL;
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getCalendarViewURL(final String whatId) {
        String viewURL = '';
        if (whatId InstanceOf Id && Util.getSObjectName(whatId) == 'leankor__ValueStream__c') {
            viewURL = ORG_DOMAIN_URL
                    + '/leankor__CalenderView?Id='
                    + whatId
                    + '&isLightning=true';
        }
        return viewURL;
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getDashboardViewURL(final String whatId) {
        String viewURL = '';
        if (whatId InstanceOf Id && Util.getSObjectName(whatId) == 'leankor__ValueStream__c') {
            viewURL = ORG_DOMAIN_URL
                    + '/leankor__VisualKanban?Id='
                    + whatId
                    + '&isLightning=true';
        }
        return viewURL;
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getWhiteboardViewURL(final String whatId) {
        return getDashboardViewURL(whatId);
    }


    @AuraEnabled(cacheable=true)
    global static String getResourceUtilizationViewURL(final String whatId) {
        return (ORG_DOMAIN_URL + '/leankor__ResourceManagementView?btype=ru');
        //Single Project: https://nwbr01-dev-ed--lean.visualforce.com/apex/leankor__ResourceManagementView?btype=ru&bId=a0J0W00000cpN0IUAU&preset=weekAndHour&start=2019-10-14T07:00:00.000Z&end=2019-11-29T06:00:00.000Z
        //Multiple Projects: https://nwbr01-dev-ed--lean.visualforce.com/apex/leankor__ResourceManagementView?btype=ru&filteredData=true&preset=weekAndHour&start=2019-10-14T06:00:00.000Z&end=2019-11-28T07:00:00.000Z&bottomVisible=false&projects=[%22a0J0W00000cpst3UAA%22,%22a0J0W00000cpuwVUAQ%22,%22a0J0W00000cpvv2UAA%22]
    }


    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getResourceScheduleViewURL(final String whatId) {
        return (ORG_DOMAIN_URL + '/leankor__ResourceManagementView?btype=rs');
        //Single Project: https://nwbr01-dev-ed--lean.visualforce.com/apex/leankor__ResourceManagementView?btype=rs&bId=a0J0W00000cpN0IUAU&preset=weekAndHour&start=2019-10-14T07:00:00.000Z&end=2019-11-29T06:00:00.000Z
        //Multiple Projects: https://leankorwork-dev-ed--lean.visualforce.com/apex/leankor__ResourceManagementView?btype=rs&filteredData=true&preset=weekAndDayLetter&start=2019-05-01T06:00:00.000Z&end=2021-04-01T06:00:00.000Z&bottomVisible=false&projects=[%22a084A00002EbysPQAR%22,%22a084A00002G553VQAR%22]
    }


    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getCapacityPlanningViewURL(final String whatId) {
        return (ORG_DOMAIN_URL + '/leankor__CapacityPlanning?btype=ru');
        //Single Project: https://leankorwork-dev-ed--lean.visualforce.com/apex/leankor__CapacityPlanning?btype=ru&bId=a08G000001vgZqaIAE&preset=weekAndDayLetter&start=2019-05-29T05:00:00.000Z&end=2021-03-30T05:00:00.000Z
        //Multiple Projects: https://leankorwork-dev-ed--lean.visualforce.com/apex/leankor__CapacityPlanning?btype=ru&filteredData=true&preset=weekAndMonth&start=2020-03-23T06:00:00.000Z&end=2020-05-11T06:00:00.000Z&bottomVisible=false&projects=[%22a08G00000291tUBIAY%22,%22a08G000001vgZqaIAE%22,%22a08G0000025aB1DIAU%22]
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getPortfolioGanttViewURL(final String whatId) {
        String viewURL = '';
        if (whatId InstanceOf Id) {            
            switch on Util.getSObjectName(whatId) {
                when 'leankor__Portfolio__c' {
                    viewURL = ORG_DOMAIN_URL
                    + '/leankor__PortfolioGanttView?fid='
                    + whatId
                    + '&btype=port';
                }
                when 'leankor__ProjectRoom__c' {
                    leankor__ValueStream__c valueStream = readValueStream('', 'leankor__ProjectRoom__c', whatId);
                    // recursive call
                    if (valueStream != null) {
                        viewURL = getPortfolioGanttViewURL(valueStream.leankor__ProjectRoom__r.leankor__Portfolio__c);
                    }
                }
                when 'leankor__ValueStream__c' {
                    leankor__ValueStream__c valueStream = readValueStream('', 'Id', whatId);
                    // recursive call
                    if (valueStream != null) {
                        viewURL = getPortfolioGanttViewURL(valueStream.leankor__ProjectRoom__r.leankor__Portfolio__c);
                    }
                }
            }
        }
        return viewURL;
    }

    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getMyWorkViewURL() {
        return (ORG_DOMAIN_URL + '/leankor__LeankorMyWork');
    }


    //09/09/2021 : Changes Public method to Global for release update.
    @AuraEnabled(cacheable=true)
    global static String getLeankorNavViewURL() {
        return (ORG_DOMAIN_URL + '/leankor__LeankorNav');
    }


    @TestVisible
    private static leankor__ValueStream__c readValueStream(final String boardType, final String whatFilterFieldName, final String whatFilterFieldValue) {
        String boardFilter = String.isBlank(boardType) ? '' : 'And leankor__BoardType__c = :boardType';
        String fieldFilter = (String.isBlank(whatFilterFieldName) || String.isBlank(whatFilterFieldValue)) ? '' : 'And ' + whatFilterFieldName + ' = :whatFilterFieldValue';
        return Database.query(
            'Select Id, leankor__ProjectRoom__c, leankor__BoardType__c, leankor__ProjectRoom__r.leankor__Portfolio__c From leankor__ValueStream__c Where leankor__isRecordDeleted__c = false ' + boardFilter + ' ' + fieldFilter + ' Limit 1');    
    }
 
    @TestVisible
    private static String getDomainURL() {
        return 
            String.isNotBlank(Network.getNetworkId())
            ? ('https://' + DomainCreator.getExperienceCloudSitesHostname()  + Util.getUrlPathPrefix())
            : URL.getOrgDomainUrl().toExternalForm() + '/apex';
    }

}