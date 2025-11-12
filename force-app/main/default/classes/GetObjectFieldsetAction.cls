/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class GetObjectFieldsetAction {

    @InvocableMethod
    global static List<FieldSetData> getCustomFieldSet(List<Id> recordIds){
        Set<String> objectNames = new Set<String>();
        
        for(Id recordId : recordIds) {
            objectNames.add(Util.getSObjectName(recordId));
        }
        
        return readObjectFieldSet(objectNames); 
    }   
    
    public static List<FieldSetData> readObjectFieldSet(Set<String> objectNames) {
        List<FieldSetData> result = new List<FieldSetData>();
        FieldSetData fieldSetData;
        for(String objectName : objectNames) {
            Map<String, Schema.FieldSet> fieldSetMap = readObjectFieldSet(objectName);

            for(String fieldSetApiName : fieldSetMap.keySet()) {
                fieldSetData = new FieldSetData(String.valueOf(fieldSetMap.get(fieldSetApiName).getLabel()),
                                                                String.valueOf(fieldSetMap.get(fieldSetApiName).getName()),
                                                                String.valueOf(fieldSetApiName), 
                                                                String.valueOf(fieldSetMap.get(fieldSetApiName).getSObjectType()));
                result.add(fieldSetData);
            }
        }
        return result;
    }

    public static Map<String, Schema.FieldSet> readObjectFieldSet(String objectName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap();
    }

    global class FieldSetData {
        @AuraEnabled
        @invocableVariable
        global String label;
        @AuraEnabled
        @invocableVariable       
        global String fieldName;
        @AuraEnabled
        @invocableVariable       
        global String fieldApiName;
        @AuraEnabled
        @invocableVariable
        global String objectName;

        global FieldSetData(String label, String fieldName, String fieldApiName, String objectName){
            this.label = label;
            this.fieldName = fieldName;
            this.fieldApiName = fieldApiName;
            this.objectName = objectName;        
        }
    }
}