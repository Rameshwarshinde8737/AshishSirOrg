/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ProjectBoardWorkFieldSet {
    
    @AuraEnabled(cacheable=true)
    @RemoteAction
    public static List<leankor__ProjectBoardWorkFieldSet__c> readProjectBoardWorkFieldSetRecords(String valueStream){
        
        return [Select Id, 
                        Name, 
                        leankor__ProjectBoard__c,
                        leankor__FieldSetName__c 
                    From leankor__ProjectBoardWorkFieldSet__c 
                    Where leankor__ProjectBoard__c =: valueStream 
                    With Security_Enforced
                    Limit 500];
    }
    
    @AuraEnabled
    public static List<leankor__ProjectBoardWorkFieldSet__c> createProjectBoardWorkFieldSets(final List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSets, List<String> valueStreamIds) {
        
        //Check CRUD / FLC behavior
        ProjectBoardWorkFieldSetBehaviour projectBoardWorkFieldSetBehaviour = new ProjectBoardWorkFieldSetBehaviour();
        FilterBehaviour filterBehaviour = new FilterBehaviour();
        if (!projectBoardWorkFieldSetBehaviour.isAccessible() ||
            !projectBoardWorkFieldSetBehaviour.isCreateable() ||
            !projectBoardWorkFieldSetBehaviour.isDeletable() ||
            !filterBehaviour.isUpdateable() ) {
            throw new Util.LeanException('Error: No access to records');
        }
        
        //Check CRUD / FLC behavior
        Map<String, String> tempFieldSetMap = new Map<String, String>();
        List<FieldSetData> fieldSetDataList = new List<FieldSetData>();
        DescribeSchema describeSchema = new DescribeSchema();
        Map<String, Schema.FieldSet> fieldSetMap = describeSchema.getFieldSets('leankor__KanbanCard__c');
        List<leankor.RealTimeController.bulkStreaming> bulkStreams = new List<leankor.RealTimeController.bulkStreaming>();
        List<String>fieldSetNames = new List<String>();
        //tempFieldSetMap.put('TestRam', 'Test Ram');
        try{ 
            List<leankor__ProjectBoardWorkFieldSet__c> deleteProjectBoardWorkFieldSets = [Select Id
                                                                                            From leankor__ProjectBoardWorkFieldSet__c
                                                                                            Where leankor__ProjectBoard__c In: valueStreamIds
                                                                                            With Security_Enforced];
            delete deleteProjectBoardWorkFieldSets;
            insert projectBoardWorkFieldSets;
            
            for(leankor__ProjectBoardWorkFieldSet__c projectBoardWorkFieldSet : projectBoardWorkFieldSets) {
                FieldSetData fieldSetData = new FieldSetData();
                fieldSetData.fieldSetAPIName = projectBoardWorkFieldSet.leankor__FieldSetName__c;
                fieldSetData.autoCalculateTotals = projectBoardWorkFieldSet.leankor__AutoCalculateTotals__c;
                fieldSetNames.add(projectBoardWorkFieldSet.leankor__FieldSetName__c);
                if( fieldSetMap.containsKey(projectBoardWorkFieldSet.leankor__FieldSetName__c)){
                    fieldSetData.fieldSetName = fieldSetMap.get(projectBoardWorkFieldSet.leankor__FieldSetName__c).getLabel();
                }
                fieldSetDataList.add(fieldSetData);
            }

            List<String> featureDataFieldSet = new List<String>();
            List<leankor__Filter__c> filterInsertLogs = [Select Id,
                                                                Name,
                                                                leankor__ValueStream__c,
                                                                leankor__FeatureData__c,
                                                                leankor__User__c 
                                                            From leankor__Filter__c 
                                                            Where leankor__ValueStream__c In: valueStreamIds
                                                                And OwnerId =:UserInfo.getUserId()
                                                            With Security_Enforced];
                        
           
            if(filterInsertLogs.size()>0){
                String featureRecord = filterInsertLogs[0].leankor__FeatureData__c;
                for(String singleFieldsetName:fieldSetMap.keySet()){
                    String modifiedFieldsetName = 'FSC:' + singleFieldsetName;
                    if(featureRecord.contains(modifiedFieldsetName)){
                        featureDataFieldSet.add(singleFieldsetName);
                    }
                }

                List<String> removedFieldset = new List<String>();
                for(String singleRecord : featureDataFieldSet){
                    if (!fieldSetNames.contains(singleRecord)){
                        removedFieldset.add(singleRecord);
                    }
                }
                
                // Remove Fieldset which we are removed form Quick Action now we deleted form Feature Data to 
                for(String singleFieldsetName : removedFieldset){
                    String modifiedFieldsetName = 'FSC:' + singleFieldsetName;
                    if(featureRecord.contains(modifiedFieldsetName)){
                        // Remove the specified value and any preceding comma directly in the JSON string
                        featureRecord = featureRecord.replaceAll(',"' + modifiedFieldsetName + '"', '')
                        .replaceAll('"' + modifiedFieldsetName + '"', '');

                        // Remove any remaining leading commas
                        featureRecord = featureRecord.replace('[,', '[');

                        // Remove any trailing commas after the modification
                        featureRecord = featureRecord.replaceAll(',]', ']');
                    }
                }
                
                
                filterInsertLogs[0].leankor__FeatureData__c = featureRecord;
                update filterInsertLogs;
            }


            for(String valueStreamId : valueStreamIds) {
                leankor.RealTimeController.bulkStreaming tempStreaming = new leankor.RealTimeController.bulkStreaming();
                FieldSetInfo tempLog = new FieldSetInfo();
                
                tempLog.ValueStreamId = valueStreamId;
                tempLog.MySessionId = UserInfo.getSessionId();
                tempLog.fieldSets = fieldSetDataList;
                tempStreaming.VSID = valueStreamId;
                tempStreaming.Verb = 'ManageProjectBoardWorkFieldSet';
                tempStreaming.SessionID = UserInfo.getSessionId();
                tempStreaming.SomeJSONData = JSON.Serialize(tempLog);
                bulkStreams.add(tempStreaming);    
            }
            leankor.RealTimeController.sendBroadcast(bulkStreams, 'ManageProjectBoardWorkFieldSet');     
        }
        catch(DmlException e){
            e.setMessage('Error: No access to records');
            throw new GanttTaskBoard.LeanException(e.getMessage());
        }             
        return projectBoardWorkFieldSets;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<GetObjectFieldsetAction.FieldSetData> getCustomFieldSet(){
        
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        
        Set<String> objectNames = new Set<String>();
        objectNames.add('leankor__KanbanCard__c');
        
        return GetObjectFieldsetAction.readObjectFieldSet(objectNames);
    }

    @AuraEnabled(cacheable=true)
    public static FieldSetDetails getCustomFieldSetDetails(String valueStream){
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isAccessible()) {
            throw new Util.LeanException('Error: No access to records');
        }
        
        Set<String> objectNames = new Set<String>();
        objectNames.add('leankor__KanbanCard__c');

        FieldSetDetails fieldSetDetails = new FieldSetDetails();
        fieldSetDetails.customFieldSet = GetObjectFieldsetAction.readObjectFieldSet(objectNames);
        fieldSetDetails.projectBoardWorkFieldSetRecords = [Select Id, 
                                                                    Name, 
                                                                    leankor__ProjectBoard__c,
                                                                    leankor__FieldSetName__c,
                                                                    leankor__AutoCalculateTotals__c 
                                                                From leankor__ProjectBoardWorkFieldSet__c 
                                                                Where leankor__ProjectBoard__c =: valueStream 
                                                                With Security_Enforced
                                                                Limit 500];
        return fieldSetDetails;
    }

    public class FieldSetDetails {
        @AuraEnabled 
        public List<GetObjectFieldsetAction.FieldSetData> customFieldSet;
        @AuraEnabled
        public List<leankor__ProjectBoardWorkFieldSet__c> projectBoardWorkFieldSetRecords;
    }
    
    public class FieldSetData {
        public String fieldSetName;
        public String fieldSetAPIName;
        public Boolean autoCalculateTotals;
    }
    
    public class FieldSetInfo {
        public String ValueStreamId;
        public String MySessionId;
        public List<ProjectBoardWorkFieldSet.FieldSetData> fieldSets; 
    }
    
}