/*---------------------------------------------------------------------------------------
* Copyright 2012-2016 Leankor All rights reserved
* Author     : RBO
* Company    : Leankor
* Description: Fetch translated custom labels by combining custom metadata, picklist field 
*              values, and hardcoded constraints. This class is used both from Apex and Lightning 
*              components. The exposed Aura-enabled method caches results for efficiency.
* Test Class : LabelProviderTest
*
* Overview:
* - Retrieves labels based on the current user's language.
* - Optionally uses custom labels (controlled via a custom setting flag).
* - Merges labels from:
*     - Custom Metadata records (leankor__VisualLeanLabelProvider__mdt)
*     - Picklist field values defined in PICKLIST_OBJECTS_FIELDS
*     - Hardcoded schedule constraint labels for UI picklist decoding.
*
* Dependencies:
* - leankor__LeanConstants__c for configuration flag (leankor__UseCustomLabels__c)
* - leankor__VisualLeanLabelProvider__mdt custom metadata for custom labels
* - DescribeSchema.getPicklistFieldValueInMap helper method to map picklist labels.
*
* Security & Best Practices:
* - Declared as 'global inherited sharing' to enforce sharing rules.
* - Uses dynamic SOQL with input sanitization to mitigate SOQL injection risks.
*
* Testing:
* - Several helper methods are marked with @testVisible for targeted unit testing.
---------------------------------------------------------------------------------------*/
// NOTE: Custom Labels: ExternallyDependentOrSchedulingModeWarning change to ExternallyDependentOrScheduleModeWarning
//       Ensure that 'Custom Labels'.Name has a max length of 40
//          leankor__VisualLeanLabelProvider__mdt.'Visual Lean Label Provider Name' has a max legth of 40 
//       Modify UI for ExternallyDependentOrSchedulingModeWarning
//       Add Custom Label records to leankor__VisualLeanLabelProvider__mdt 
//          leankor__VisualLeanLabelProvider__mdt.'Label' = 'Leankor'
//          leankor__VisualLeanLabelProvider__mdt.'Visual Lean Label Provider Name' = 'Custom Labels'.Name
//          leankor__VisualLeanLabelProvider__mdt.'Categories' = 'Custom Labels'.Categories, supports multiple categories separated by comma

global inherited sharing class LabelProvider {
    // Constants
    // Namespace used to prefix custom label names
    private static final String NAMESPACE_PREFIX = 'leankor';

    // Current user's language, used for fetching labels
    private static final String LANGUAGE = UserInfo.getLanguage();

    // Flag from custom setting to determine whether to use custom label retrieval
    private static final Boolean USE_CUSTOM_LABELS = leankor__LeanConstants__c.getInstance().leankor__UseCustomLabels__c;
        
    /*
     * Map of objects and their associated picklist fields. This is used
     * when pulling translated picklist values that appear in the UI
     */
    private static final Map<String, Set<String>> PICKLIST_OBJECTS_FIELDS = new Map<String, Set<String>> {
        'Task' => new Set<String> {
            'Status', 
            'Priority'
        }, 
        'leankor__KanbanCard__c' => new Set<String> {
            'leankor__DurationUnits__c', 
            'leankor__OnBudget__c', 
            'leankor__OnQuality__c',
            'leankor__OnTime__c'
        },
        'leankor__TaskTemplate__c' => new Set<String> {
            'leankor__Priority__c', 
            'leankor__Status__c'
        }, 
        'leankor__ProjectLaunchBehavior__c' => new Set<String> {
            'leankor__ViewType__c'
        }, 
        'leankor__IssueLog__c' => new Set<String> {
            'leankor__Probability__c', 
            'leankor__StatusType__c',
            'leankor__Weight__c'
        }, 
        'leankor__Intro__c' => new Set<String> {
            'leankor__IntroLocation__c'
        }, 
        'leankor__Expense__c' => new Set<String> {
            'leankor__Category__c', 
            'leankor__ExpenseAccount__c',
            'leankor__ExpenseSubCategory__c'
        }, 
        'leankor__ItemApproval__c' => new Set<String> {
            'leankor__ApprovalHistoryStatus__c', 
            'leankor__DurationUnitChange__c',
            'leankor__RequestType__c'
        },
        'leankor__ScheduleConstraint__c' => new Set<String> {
            'leankor__Description__c'
        },
        'leankor__TimeSheet__c' => new Set<String> {
            'leankor__ApprovalHistoryStatus__c' 
        }
    };
        

    //===========================================================================
    // Lightning Component Integration
    //===========================================================================
    /**
     * @description
     *   Exposes an AuraEnabled and cacheable method for Lightning consumers.
     *   It constructs a set of consumers (including default components) and delegates
     *   fetching labels to the core getLabelsForConsumers method.
     *
     * @param componentName - The name of the Lightning component consuming the labels.
     * @return Map<String,String> - A map of label identifiers to their translated strings.
     */
    @AuraEnabled(cacheable=true)
    global static Map<String, String> getLabelsForConsumersLightning(String componentName) {
        Set<String> consumers = new Set<String>{'LeankorBase', 'LeankorCalendar', componentName};
        Map<String, String> returnMap = new Map<String, String>();  

        // Delegate to shared logic
        returnMap = LabelProvider.getLabelsForConsumers(consumers);
        return returnMap;
    }


    //===========================================================================
    // Core Method: Aggregate Labels for Consumers
    //===========================================================================
    /**
     * @description
     *   Fetches a unified map of labels for the provided consumers. It aggregates labels
     *   from custom metadata (if enabled), picklist values, and hardcoded constraint mappings.
     *
     * @param consumerNames - A set of consumer category names to filter custom metadata labels.
     * @return Map<String,String> - Aggregated label map.
     */
    public static Map<String, String> getLabelsForConsumers(Set<String> consumerNames) {
        Map<String, String> returnMap = new Map<String, String>(); 
        
        if (USE_CUSTOM_LABELS) {
            String namespaceAPI = NAMESPACE_PREFIX + '__';
            for (leankor__VisualLeanLabelProvider__mdt labelProvider : readLabelProviders(consumerNames)) {
                String labelName = labelProvider.QualifiedApiName.replace(namespaceAPI,'');
                try {
                    returnMap.put(labelName, System.Label.get(NAMESPACE_PREFIX, labelName, LANGUAGE));
                } catch (System.InvalidParameterValueException e) {
                    continue;
                }
            }
        }
        //If we are using Dynamic links for custom label then salesforce pkg not including custom label in 1GP package. 
        //so that we are including those new label by using hard link refrence in system.debug();
        System.debug('ExternallyDependentOrScheduleModeWarning=>' +System.Label.leankor.ExternallyDependentOrScheduleModeWarning);
        System.debug('FetchingRows=>' +System.Label.leankor.FetchingRows);
        System.debug('GeneralError=>' +System.Label.leankor.GeneralError);
        System.debug('PleaseSelectResourceTypeAssign=>' +System.Label.leankor.PleaseSelectResourceTypeAssign);
        System.debug('InvalidNumber=>' +System.Label.leankor.InvalidNumber);
        System.debug('PG_NegativeDurationErrorMsg=>' +System.Label.leankor.PG_NegativeDurationErrorMsg);
        System.debug('MinText=>' +System.Label.leankor.MinText);
        System.debug('MaxText=>' +System.Label.leankor.MaxText);
        System.debug('BuiltPage=>' +System.Label.leankor.BuiltPage);
        System.debug('PortfolioGanttChart=>' +System.Label.leankor.PortfolioGanttChart);

        getPicklistLabels(returnMap);

        // Hardcoded mapping of labels
        getHardCodedLabels(returnMap);

        return returnMap;
    }


    //===========================================================================
    // Hardcoded Label Mappings for Schedule Constraints
    //===========================================================================
    /**
     * @description
     *   Adds hardcoded mappings for schedule constraint labels to the return map.
     *   A JSON serialized representation of the constraint descriptions is stored for UI decoding.
     *
     * @param returnMap - The map where labels are aggregated.
     */
    @testVisible
    private static void getHardCodedLabels(Map<String, String> returnMap) {
        // start hardcoded picklist mapping for leankor__ScheduleConstraint__c
        List<List<String>> constraintDescriptions = new List<List<String>>();

        returnMap.put('FinishNoLaterConstraint', getMapValue(returnMap, 'finishnolaterthan', constraintDescriptions));
        returnMap.put('FinishNoEarlierConstraint', getMapValue(returnMap, 'finishnoearlierthan', constraintDescriptions));
        returnMap.put('MustFinishConstraint', getMapValue(returnMap, 'mustfinishon', constraintDescriptions));
        returnMap.put('MustStartConstraint', getMapValue(returnMap, 'muststarton', constraintDescriptions));
        returnMap.put('StartNoEarlierConstraint', getMapValue(returnMap, 'startnoearlierthan', constraintDescriptions));
        returnMap.put('StartNoLaterConstraint', getMapValue(returnMap, 'startnolaterthan', constraintDescriptions));
        returnMap.put('aslateaspossible', getMapValue(returnMap, 'aslateaspossible', constraintDescriptions));
        returnMap.put('assoonaspossible', getMapValue(returnMap, 'assoonaspossible', constraintDescriptions));

        // Store as JSON for UI decoding
        returnMap.put('ConstraintDescription', JSON.serialize(constraintDescriptions));
        // end hardcoded picklist mapping for leankor__ScheduleConstraint__c
    }


    //===========================================================================
    // Helper Method: Retrieve Map Value and Record Constraint Mapping
    //===========================================================================
    /**
     * @description
     *   Retrieves a value from the given label map corresponding to the provided key.
     *   If the value does not exist or is blank, returns an empty string.
     *   In addition, adds the key-value pair to the items list for constraint mapping.
     *
     * @param returnMap - The map from which to retrieve the label.
     * @param key - The key to lookup in the return map.
     * @param items - A list collecting key-value pairs for constraint descriptions.
     * @return String - The label value (or empty string if not found).
     */
    @testVisible
    private static String getMapValue(Map<String, String> returnMap, String key, List<List<String>> items) {
        String returnMapItemValue = returnMap.get(key);

        returnMapItemValue = String.isBlank(returnMapItemValue) ? '' : returnMapItemValue;
        items.add(new List<String>{key, returnMapItemValue});

        return returnMapItemValue;
    }


    //===========================================================================
    // Custom Metadata Query for Label Providers
    //===========================================================================
    /**
     * @description
     *   Retrieves custom metadata records containing label definitions that match the provided consumer categories.
     *   Constructs dynamic SOQL conditions by sanitizing consumer input to prevent injection attacks.
     *
     * @param categories - A set of consumer category names to filter the custom metadata.
     * @return List<leankor__VisualLeanLabelProvider__mdt> - List of custom metadata records matching the filter.
     */
    @testVisible
    private static List<leankor__VisualLeanLabelProvider__mdt> readLabelProviders(Set<String> categories) {
        if (categories == null || categories.isEmpty()) {
            return new List<leankor__VisualLeanLabelProvider__mdt>();
        }

        // Clean and escape input tags
        List<String> conditions = new List<String>();
        for (String category : categories) {
            if (String.isNotBlank(category)) {
                String cleanCategory = sanitizeForSOQL(category.toLowerCase().trim());
                // Add LIKE clause safely with escaped literal
                conditions.add('leankor__Categories__c Like \'%' + cleanCategory + '%\'');
            }
        }

        if (conditions.isEmpty()) {
            return new List<leankor__VisualLeanLabelProvider__mdt>();
        }
        
        // Build the WHERE clause
        String whereClause = String.join(conditions, ' Or ');
        String query = 'Select QualifiedApiName, leankor__Categories__c From leankor__VisualLeanLabelProvider__mdt Where ' + whereClause + ' Limit 50000';
        return Database.query(query);
    }


    //===========================================================================
    // Picklist Labels Aggregation
    //===========================================================================
    /**
     * @description
     *   Iterates over the pre-defined mapping of objects and their picklist fields.
     *   For each field, retrieves picklist value labels using DescribeSchema.getPicklistFieldValueInMap
     *   and merges the resulting key-value pairs into the return map.
     *
     * @param returnMap - The map to which the picklist labels will be added.
     */
    @testVisible
    private static void getPicklistLabels(Map<String, String> returnMap) {
        for (String objectName : PICKLIST_OBJECTS_FIELDS.keySet()) {
            for (String picklistFieldName : PICKLIST_OBJECTS_FIELDS.get(objectName)) {
                Map<String, String> picklistFieldValues = DescribeSchema.getPicklistFieldValueInMap(objectName, picklistFieldName);
                returnMap.putAll(picklistFieldValues);
            }
        }
    }
    
    
    //===========================================================================
    // Input Sanitization for Dynamic SOQL
    //===========================================================================
    /**
     * @description
     *   Sanitizes a given input string for safe inclusion in dynamic SOQL queries.
     *   Escapes characters that could manipulate the query structure.
     *
     * @param input - The string to sanitize.
     * @return String - The sanitized string.
     */
    @testVisible
    private static String sanitizeForSOQL(String input) {
        return String.isBlank(input)
            ? ''
            : input
                .replace('\\', '\\\\')   // escape backslash
                .replace('\'', '\\\'')   // escape single quote
                .replace('%', '\\%')     // escape percent (wildcard)
                .replace('_', '\\_');    // escape underscore (wildcard)
    }
}