/*********************************************************************************
* Company     : Leankor
* Description : Getting All Fields Data and There Type Which was Present inside FieldSets
 *********************************************************************************/ 
global with sharing class LeankorFieldSetController {

    public LeankorFieldSetController(leankor.Util controller) {}

    global class JsonInformation {
        public Map<String, Object> jsonDefinitions;
		public String jsonData;
        public String fieldSetName;
        public String fieldSetAPIName;
        public Boolean autoCalculateTotals;
        public Boolean isReadOnly = false;

    }

    global class JsonInformationWithConfig{
		public List<JsonInformation> jsonInformation;
        public Map<String, Object> config;
    }
    
    private static List<String> allowedFieldSetNames = new List<String>();

    /*------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The Field Which Present inside FieldSet
	    Inputs:         No input  
	    Returns:        List of JsonInformation
	------------------------------------------------------------*/
    @deprecated
    @RemoteAction
    global static List<JsonInformation> readFieldSetInfo() {
        List<JsonInformation> result = new List<JsonInformation>();
        return result;
    }

    /*------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The Field Which Present inside FieldSet
	    Inputs:         List of Board IDs 
	    Returns:        List of JsonInformation
	------------------------------------------------------------*/
    @RemoteAction
    global static List<JsonInformation> readObjectFieldSetInfo(List<Id> valueStreamIds) {
        ValueStreamBehavior valueStreamBehavior = new ValueStreamBehavior();
        ProjectBoardWorkFieldSetBehaviour projectBoardWorkFieldSetBehaviour = new ProjectBoardWorkFieldSetBehaviour();

        if (!valueStreamBehavior.isAccessible() || !projectBoardWorkFieldSetBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        // Added Security code for sentize user Input
        for (String singleValueStreamIds : valueStreamIds) {

            if (String.isNotBlank(singleValueStreamIds) && Util.getSObjectName(singleValueStreamIds) != 'leankor__ValueStream__c') {
                throw new Util.LeanException('Error: Invalid input');
            }

        }

        List<JsonInformation> result = new List<JsonInformation>();
        Map<String, Schema.SObjectField> fieldMapKanbanCard = realTimeController.fieldMapKanbanCard;
        JsonInformation jsonDataDescription = new JsonInformation();
        KanbanSerializer kanbanSerializer = new KanbanSerializer();
        List<String> allFeatureData = new List<String>();

        List<leankor__Filter__c> filterInsertLogs = [Select Id,
                                                            Name,
                                                            leankor__ValueStream__c,
                                                            leankor__FeatureData__c,
                                                            leankor__User__c 
                                                        From leankor__Filter__c 
                                                        Where leankor__ValueStream__c In :valueStreamIds
                                                            And OwnerId = :UserInfo.getUserId()
                                                        With Security_Enforced
                                                        Limit 50000];

        for (leankor__Filter__c singleFilterInstance : filterInsertLogs) {
            if  (String.isNotBlank(singleFilterInstance.leankor__FeatureData__c)) {
                allFeatureData.add(singleFilterInstance.leankor__FeatureData__c);
            }
        }

        
        Map<String,Boolean> fieldsetAvailableinBoard = new Map<String,Boolean>();
        List<String> fieldsetWithonlyReadAccess = new List<String>();
        for (leankor__ProjectBoardWorkFieldSet__c singleRecord : [Select Id,
                                                                        Name,
                                                                        leankor__FieldSetName__c,
                                                                        leankor__ProjectBoard__c,
                                                                        leankor__AutoCalculateTotals__c,
                                                                        UserRecordAccess.HasReadAccess,
                                                                        UserRecordAccess.HasEditAccess
                                                                    From leankor__ProjectBoardWorkFieldSet__c
                                                                    Where leankor__ProjectBoard__c In :valueStreamIds
                                                                    Limit 50000]) {
            if(singleRecord.UserRecordAccess.HasReadAccess == true) {
                
                fieldsetAvailableinBoard.put(singleRecord.leankor__FieldSetName__c, singleRecord.leankor__AutoCalculateTotals__c);
            }

            if(singleRecord.UserRecordAccess.HasReadAccess == true && singleRecord.UserRecordAccess.HasEditAccess == false) {
                fieldsetWithonlyReadAccess.add(singleRecord.leankor__FieldSetName__c);
            }
        }  
               
        try {

            for (String singleRecordOfProjectBoardWorkFieldSet : fieldsetAvailableinBoard.keySet()) {

                for (RealTimeController.FieldSetJSONWrapper fieldSet : RealTimeController.getKanbanFieldSetANDJSON()) {

                    Boolean isFieldsetHaveReadAccess = false;
                    if (singleRecordOfProjectBoardWorkFieldSet.toLowerCase() == fieldSet.fieldSetAPIName) {
                        JsonInformation tempJsonDataDescription = new JsonInformation();
                        tempJsonDataDescription.fieldSetName = fieldSet.fieldSetName;
                        tempJsonDataDescription.fieldSetAPIName = fieldSet.fieldSetAPIName; 
                        tempJsonDataDescription.autoCalculateTotals = fieldsetAvailableinBoard.get(singleRecordOfProjectBoardWorkFieldSet);
                        if(fieldsetWithonlyReadAccess.contains(fieldSet.fieldSetAPIName)) {
                            isFieldsetHaveReadAccess = true;
                        }
                        
                        tempJsonDataDescription.isReadOnly = isFieldsetHaveReadAccess;

                        for (String singleString : allFeatureData) {

                            if (singleString.contains('FSC:' + fieldSet.fieldSetAPIName)) {
                                tempJsonDataDescription.jsonDefinitions = kanbanSerializer.customMetadataHeader('leankor__KanbanCard__c', fieldSet.fieldSetAPIName, realTimeController.UIHeaderSettings, realTimeController.UIItemSettings, fieldMapKanbanCard);
                            }

                        }

                        result.add(tempJsonDataDescription);
                    }
                }
            }
        }

        catch(Exception e ) {	
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }

        return result;
    }

    @AuraEnabled (cacheable = true)
    public static List<JsonInfo> readObjectFieldSetInfoAura(List<Id> valueStreamIds){
        try {
            List<JsonInformation> jsonInformation =  readObjectFieldSetInfo(valueStreamIds);
            List<JsonInfo> jsonInfoList = new List<JsonInfo>();
            for (JsonInformation info : jsonInformation) {
                JsonInfo jsonInfo = new JsonInfo();
                jsonInfo.jsonDefinitions  = info.jsonDefinitions;
                jsonInfo.jsonData  = info.jsonData;
                jsonInfo.fieldSetName = info.fieldSetName;
                jsonInfo.fieldSetAPIName =  info.fieldSetAPIName;
                jsonInfo.autoCalculateTotals = info.autoCalculateTotals;
                jsonInfo.isReadOnly  = info.isReadOnly;
                jsonInfoList.add(jsonInfo);
            }
            return jsonInfoList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @TestVisible
    private class FieldSetAndValueStreamInformation {
		public List<String> fieldSetName ;
        public String valuestreamId;
    }
    /*------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting FieldsetDetials
	    Inputs:         List of FieldsetName
	    Returns:        JsonInformationWithConfig
	------------------------------------------------------------*/
    @RemoteAction
    global static JsonInformationWithConfig readFieldSetDetails(List<String> fieldsetAndValueStreamData) {
        ProjectBoardWorkFieldSetBehaviour projectBoardWorkFieldSetBehaviour = new ProjectBoardWorkFieldSetBehaviour();
        if (!projectBoardWorkFieldSetBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        JsonInformationWithConfig jsonDefinationIncludeConfig = new JsonInformationWithConfig();
        List<JsonInformation> result = new List<JsonInformation>();
        Map<String, Schema.SObjectField> fieldMapKanbanCard = realTimeController.fieldMapKanbanCard;
        JsonInformation jsonDataDescription = new JsonInformation();
        KanbanSerializer kanbanSerializerInstance = new KanbanSerializer();
        LeankorFieldSetController.FieldSetAndValueStreamInformation fieldSetAndValueStream = (LeankorFieldSetController.FieldSetAndValueStreamInformation)JSON.deserialize(fieldsetAndValueStreamData[0],(LeankorFieldSetController.FieldSetAndValueStreamInformation.Class));
        //List<String>fieldsetRecords = new List<String>{'fieldSetAndValueStream.fieldSetName'}
        if (String.isNotBlank(fieldSetAndValueStream.valuestreamId) && Util.getSObjectName(fieldSetAndValueStream.valuestreamId) != 'leankor__ValueStream__c') {
            throw new Util.LeanException('Error: Invalid input');
        }
        try {

            List<String> fieldsetWithonlyReadAccess = new List<String>();
            Map<String, Boolean> fieldsetDetailsWithAutoTotal = new Map<String, Boolean>(); 
            for (leankor__ProjectBoardWorkFieldSet__c singleRecord : [Select Id,
                                                                            Name,
                                                                            leankor__FieldSetName__c,
                                                                            leankor__ProjectBoard__c,
                                                                            leankor__AutoCalculateTotals__c,
                                                                            UserRecordAccess.HasReadAccess,
                                                                            UserRecordAccess.HasEditAccess
                                                                        From leankor__ProjectBoardWorkFieldSet__c
                                                                        Where leankor__ProjectBoard__c =:fieldSetAndValueStream.valuestreamId
                                                                            And leankor__FieldSetName__c IN :fieldSetAndValueStream.fieldSetName
                                                                        Limit 50000]) {
                if(singleRecord.UserRecordAccess.HasReadAccess == true && singleRecord.UserRecordAccess.HasEditAccess == false) {
                    fieldsetWithonlyReadAccess.add(singleRecord.leankor__FieldSetName__c);
                }
                fieldsetDetailsWithAutoTotal.put(singleRecord.leankor__FieldSetName__c, singleRecord.leankor__AutoCalculateTotals__c);
            }

            for (RealTimeController.FieldSetJSONWrapper fieldSet : RealTimeController.getKanbanFieldSetANDJSON()) {

                for (String singlefieldsetAPIName : fieldSetAndValueStream.fieldSetName) {

                    Boolean isFieldsetHaveReadAccess = false;
                    if (singlefieldsetAPIName == fieldSet.fieldSetAPIName) {
                        JsonInformation tempJsonDataDescription = new JsonInformation();
                        tempJsonDataDescription.fieldSetName = fieldSet.fieldSetName;
                        tempJsonDataDescription.fieldSetAPIName = fieldSet.fieldSetAPIName; 
            
                        // Check if the fieldSetAPIName exists in the map
                        if (fieldsetDetailsWithAutoTotal.containsKey(fieldSet.fieldSetAPIName)) {
                            tempJsonDataDescription.autoCalculateTotals = fieldsetDetailsWithAutoTotal.get(fieldSet.fieldSetAPIName);
                        } else {
                            tempJsonDataDescription.autoCalculateTotals = false;
                        }

                        if(fieldsetWithonlyReadAccess.contains(fieldSet.fieldSetAPIName)) {
                            isFieldsetHaveReadAccess = true;
                        }

                        tempJsonDataDescription.isReadOnly = isFieldsetHaveReadAccess;

                        tempJsonDataDescription.jsonDefinitions = kanbanSerializerInstance.customMetadataHeader('leankor__KanbanCard__c', fieldSet.fieldSetAPIName, realTimeController.UIHeaderSettings, realTimeController.UIItemSettings, fieldMapKanbanCard);
                        result.add(tempJsonDataDescription);
                    }
                }
            }

            jsonDefinationIncludeConfig.JsonInformation = result;
            jsonDefinationIncludeConfig.config = KanbanSerializer.configPartOfHeaderSettings;
        }

        catch(Exception e ) {	
            throw new Util.LeanException('ERROR:' + e.getMessage());
        }
        
        return jsonDefinationIncludeConfig;
    }

    /*----------------------------------------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The Field Which Present inside FieldSet in specific Cards
	    Inputs:         Cards Ids  
	    Returns:        Map<Id, leankor__KanbanCard__c> key as a CardId and Value as a (Custom field Data) 
	---------------------------------------------------------------------------------------------*/
    @RemoteAction     
    global static  Map<Id, leankor__KanbanCard__c> readCardsFieldSetData(List<Id> cardIds) {
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();

        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        // Added Security code for sentize user Input
        for (String singleCardId : cardIds) {

            if (String.isNotBlank(singleCardId) && Util.getSObjectName(singleCardId) != 'leankor__KanbanCard__c') {
                throw new Util.LeanException('Error: Invalid input');
            }

        }

        String sobjectName = 'leankor__KanbanCard__c';
        Map<Id, leankor__KanbanCard__c> mapCustomFieldsKanbanCard = allCardsFieldSetData(cardIds, sobjectName);
        return mapCustomFieldsKanbanCard;
    }

    /*----------------------------------------------------------------------------------------------
    Author:         Abhishek Joshi
    Company:        Leankor
    Description:    Getting Custom Fields Data for Specific FieldSet
    Inputs:         Cards Ids, Fieldset API Names   
    Returns:        Map<Id, leankor__KanbanCard__c> key as a CardId and Value as a (Custom field Data) 
    ----------------------------------------------------------------------------------------------*/
    @RemoteAction     
    global static Map<Id, leankor__KanbanCard__c> getCardsCustomFieldData(List<Id> cardIds, List<String> fieldsetAPIList) {
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();

        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        // Security: Validate each card ID to ensure it's a KanbanCard record
        for (String singleCardId : cardIds) {
            if (String.isNotBlank(singleCardId) && Util.getSObjectName(singleCardId) != 'leankor__KanbanCard__c') {
                throw new Util.LeanException('Error: Invalid input');
            }
        }

        LeankorFieldSetController.allowedFieldSetNames = fieldsetAPIList;
        
        String sobjectName = 'leankor__KanbanCard__c';
        Map<Id, leankor__KanbanCard__c> mapCustomFieldsKanbanCard = allCardsFieldSetData(cardIds, sobjectName);
        
        return mapCustomFieldsKanbanCard;
    }

    /*----------------------------------------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The CustomField Which Present inside FieldSet 
	    Inputs:         ValueStream Ids  
	    Returns:        Map<Id, leankor__KanbanCard__c> key as a CardId and Value as a leankor__KanbanCard__c(Custom field Data) 
	---------------------------------------------------------------------------------------------*/
    
    @RemoteAction     
    global static  Map<Id, leankor__KanbanCard__c> readValueStreamCardsFieldSetData(List<Id> valueStreamIds) {
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();

        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        // Added Security code for sentize user Input
        for (String singleValueStreamId : valueStreamIds) {

            if (String.isNotBlank(singleValueStreamId) && Util.getSObjectName(singleValueStreamId) != 'leankor__ValueStream__c') {
                throw new Util.LeanException('Error: Invalid input');
            }

        }

        String sobjectName = 'leankor__ValueStream__c';
        Map<Id, leankor__KanbanCard__c> mapKanbancard = allCardsFieldSetData(valueStreamIds, sobjectName);
        return mapKanbancard;
    }

    /*----------------------------------------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The Custom Field Which Present inside Speicific Fieldset
	    Inputs:         ValueStream Ids, Fieldset API Names  
	    Returns:        Map<Id, leankor__KanbanCard__c> key as a CardId and Value as a leankor__KanbanCard__c(Custom field Data) 
	---------------------------------------------------------------------------------------------*/
    @RemoteAction     
    global static Map<Id, leankor__KanbanCard__c> getAllCustomFieldsData(List<Id> valueStreamIds, List<String> fieldsetAPIList) {
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();

        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }

        // Added Security code for sentize user Input
        for (String singleValueStreamId : valueStreamIds) {

            if (String.isNotBlank(singleValueStreamId) && Util.getSObjectName(singleValueStreamId) != 'leankor__ValueStream__c') {
                throw new Util.LeanException('Error: Invalid input');
            }

        }
        LeankorFieldSetController.allowedFieldSetNames = fieldsetAPIList;
        String sobjectName = 'leankor__ValueStream__c';
        Map<Id, leankor__KanbanCard__c> mapKanbancard = allCardsFieldSetData(valueStreamIds, sobjectName);
        return mapKanbancard;
    }

    /*----------------------------------------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The Field Which Present inside FieldSet in specific Cards
	    Inputs:         Ids(CardIds or ValueStream Ids) and Name of Sobject
	    Returns:        Map<Id, leankor__KanbanCard__c> key as a CardId and Value as a (Custom field Data) 
	---------------------------------------------------------------------------------------------*/
    @TestVisible
    private static Map<Id, leankor__KanbanCard__c> allCardsFieldSetData(List<Id> recordIds, String sObjectName) {
        Map<Id, leankor__KanbanCard__c> mapCustomFieldsKanbanCard = new Map<Id, leankor__KanbanCard__c>();

        if (recordIds == null || recordIds.isEmpty()) {
            return mapCustomFieldsKanbanCard;
        }

        try {
            if (recordIds.size() > 0) {
                LeankorFieldSetController.FieldSetRecord fieldSetRecord = LeankorFieldSetController.getAllCustomFieldsInsideTheFieldSet(recordIds, sObjectName);
                String fieldList = fieldSetRecord.allFieldsInStringFormat;

                String soql;

                if (sObjectName == 'leankor__KanbanCard__c') {
                    soql = 'Select Id ' + fieldList +
                                ' From leankor__KanbanCard__c' +
                                ' Where Id In :recordIds And leankor__isRecordDeleted__c = false' +
                                ' Limit 50000';
                } else if (sObjectName == 'leankor__ValueStream__c') {
                    if (fieldSetRecord.isFieldSetAvailableAtBoard) {
                        return mapCustomFieldsKanbanCard; // Early return as no data needed
                    }

                    soql = 'Select Id ' + fieldList +
                                ' From leankor__KanbanCard__c' +
                                ' Where leankor__ValueStream__c In :recordIds And leankor__isRecordDeleted__c = false' +
                                ' Limit 50000';
                }

                if (String.isNotBlank(soql)) {
                    mapCustomFieldsKanbanCard = new Map<Id, leankor__KanbanCard__c>(
                        (List<leankor__KanbanCard__c>) Database.query(soql)
                    );
                }
            }
        } catch (Exception e) {
            throw new Util.LeanException('ERROR: ' + e.getMessage());
        }

        return mapCustomFieldsKanbanCard;
    }

 
 

    // We will save all required Fieldsets and their Fields data in this inner class, which we use in the clone functionality.
    public class FieldSetRecord {
        public String allFieldsInStringFormat;
        public Boolean isFieldSetAvailableAtBoard = false;
    }

   
    
    /*------------------------------------------------------------------------------------------------------------------------
	    Author:         Abhishek Joshi
	    Company:        Leankor
	    Description:    Getting data of all The Field Which Present inside FieldSet 
	    Inputs:         Record Ids and RecordsObjectName  
	    Returns:        Return a FieldSetRecord object that contains all the required information needed 
	---------------------------------------------------------------------------------------------*/
    public static FieldSetRecord getAllCustomFieldsInsideTheFieldSet(List<Id> recordIds, String sObjectName) {
        FieldSetRecord fieldSetRecord = new FieldSetRecord();

        if (recordIds == null || recordIds.isEmpty()) {
            return fieldSetRecord;
        }

        // Supported field types
        Set<Schema.DisplayType> supportedTypes = new Set<Schema.DisplayType>{
                                                                            Schema.DisplayType.BOOLEAN,
                                                                            Schema.DisplayType.CURRENCY,
                                                                            Schema.DisplayType.DATE,
                                                                            Schema.DisplayType.DOUBLE,
                                                                            Schema.DisplayType.PICKLIST,
                                                                            Schema.DisplayType.REFERENCE,
                                                                            Schema.DisplayType.STRING,
                                                                            Schema.DisplayType.URL,
                                                                            Schema.DisplayType.PERCENT,
                                                                            Schema.DisplayType.DATETIME
                                                                            };

        Set<Id> valueStreamIds = new Set<Id>();
        Set<String> includedFieldSetNames = new Set<String>();
        Boolean isFieldsetAvailable = false;

        if (sObjectName == 'leankor__KanbanCard__c') {
            List<leankor__KanbanCard__c> kanbanCards = [Select leankor__ValueStream__c
                                                            From leankor__KanbanCard__c
                                                            Where Id In :recordIds
                                                            With Security_Enforced
                                                            Limit 50000];

            for (leankor__KanbanCard__c card : kanbanCards) {
                if (card.leankor__ValueStream__c != null) {
                    valueStreamIds.add(card.leankor__ValueStream__c);
                }
            }
        } else if (sObjectName == 'leankor__ValueStream__c') {
            valueStreamIds.addAll(recordIds);
        }

        if (!valueStreamIds.isEmpty()) {
            List<leankor__ProjectBoardWorkFieldSet__c> fieldSetRecords = [Select leankor__FieldSetName__c
                                                                            From leankor__ProjectBoardWorkFieldSet__c
                                                                            Where leankor__ProjectBoard__c In :valueStreamIds
                                                                            With Security_Enforced
                                                                            Limit 50000];

            isFieldsetAvailable = fieldSetRecords.isEmpty();

            for (leankor__ProjectBoardWorkFieldSet__c record : fieldSetRecords) {
                if (String.isNotBlank(record.leankor__FieldSetName__c)) {
                    includedFieldSetNames.add(record.leankor__FieldSetName__c.trim());
                }
            }
        }

        Map<String, Schema.SObjectField> allFieldsMap = leankor__KanbanCard__c.SObjectType.getDescribe().fields.getMap();
        Map<String, Schema.FieldSet> allFieldSets = Schema.SObjectType.leankor__KanbanCard__c.fieldSets.getMap();

        Set<String> customFieldList = new Set<String>();

        for (String fieldSetName : includedFieldSetNames) {

            if (!allFieldSets.containsKey(fieldSetName)) {
                continue;
            }
            
            if (!LeankorFieldSetController.allowedFieldSetNames.isEmpty() && !LeankorFieldSetController.allowedFieldSetNames.contains(fieldSetName)) {
                continue;
            }

            for (Schema.FieldSetMember fieldMember : allFieldSets.get(fieldSetName).getFields()) {
                String fieldPath = fieldMember.getFieldPath();
                
                // use this if block in Scrarch org for enable Fieldset 
                // if (fieldPath.containsIgnoreCase('__c') &&
                //     supportedTypes.contains(fieldMember.getType()) && allFieldsMap.containsKey(fieldPath)) {
                
                if (!fieldPath.containsIgnoreCase('leankor__') && fieldPath.containsIgnoreCase('__c') &&
                    supportedTypes.contains(fieldMember.getType()) && allFieldsMap.containsKey(fieldPath)) {
                        customFieldList.add(fieldPath);
                }
            }
        }
        // Clear static variable after use
        LeankorFieldSetController.allowedFieldSetNames.clear();

        // Populate result
        fieldSetRecord.allFieldsInStringFormat = !customFieldList.isEmpty() ? ',' + String.join(customFieldList, ',') : '';
        fieldSetRecord.isFieldSetAvailableAtBoard = isFieldsetAvailable;
        return fieldSetRecord;
    }
}