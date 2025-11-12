global with sharing class GanttLWCExtraCode {
    
    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getCustomSettingFields() {
        leankor__LeanConstants__c customSetting = [SELECT 
            leankor__AllowSchedulingConstraints__c,
            leankor__FirstDayOfTheWeek__c,
            leankor__SevenDayWorkWeek__c,
            leankor__ShowIDColumnIndication__c,
            leankor__ShowImportMSProjectMenu__c,
            leankor__WorkingHoursPerDay__c 
            FROM leankor__LeanConstants__c LIMIT 1];

        return new Map<String, Object> {
            'AllowSchedulingConstraints' => customSetting.leankor__AllowSchedulingConstraints__c,
            'FirstDayOfTheWeek' => customSetting.leankor__FirstDayOfTheWeek__c,
            'SevenDayWorkWeek' => customSetting.leankor__SevenDayWorkWeek__c,
            'ShowIDColumnIndication' => customSetting.leankor__ShowIDColumnIndication__c,
            'IsMsProjectEnable' => customSetting.leankor__ShowImportMSProjectMenu__c,
            'WorkingHoursPerDay' => customSetting.leankor__WorkingHoursPerDay__c
        };
    }
    
    @AuraEnabled(cacheable=true)
    global static String getSessionId() {
        // Return the current session ID
        return UserInfo.getSessionId();
    }
    
    
}