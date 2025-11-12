/**
 * Tilak Raj Mahale:04.05.2020
 * Note: 1. This class used to perform CRUD opeation on leankor__Dependency__c in without sharing environment.
 *       2. Contain the methods related to external dependency.
 */
public without sharing class Dependency {

    // Types of dependencies
    public final static Set<String> DEPENDENCYTYPES = new Set<String> {
        'Finish To Start', 
        'Finish To Finish',
        'Start To Start', 
        'Start To Finish' 
        };

    public static Boolean updateDependency(List<leankor__Dependency__c> dependencies) {
        //Check CRUD / FLC behavior
        DependencyBehaviour dependencyBehaviour = new DependencyBehaviour();
        if (!dependencyBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior

        try {
            Database.update(dependencies);
        } catch (DmlException exc) {
            throw new Util.LeanException('ERROR:' + exc.getMessage()); 
        }

        return true;
    }


    public static List<leankor__Dependency__c> readDependency(Set<String> valueStreamIds) {
        return [Select Id,
                        leankor__IsDependencyRecalculate__c,
                        leankor__Predecessor__c,
                        leankor__Predecessor__r.leankor__ValueStream__c, 
                        leankor__Successor__c,
                        leankor__Successor__r.leankor__ValueStream__c,
                        leankor__ValueStream__c
                    From leankor__Dependency__c  
                    Where //leankor__ValueStream__r.leankor__boardtype__c = 'UberBoard' And 
                        leankor__Predecessor__r.leankor__IsRecordDeleted__c = false
                        And leankor__Successor__r.leankor__IsRecordDeleted__c = false
                        And leankor__ValueStream__r.leankor__IsTemplateBoard__c = false
                        And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                        And leankor__ValueStream__c IN: valueStreamIds
                    With Security_Enforced
                    Limit 49999];
    }

    // overloaded, locks all queried records for update
    // read all dependent work items including external dependencies
    public static List<leankor__Dependency__c> readDependency(Set<Id> valueStreamIds) {        
        // given valueStreamId, find all dependent ValueStream Ids and add to the set of valueStreamIds ---//
        Set<String> setOfValueStreamIds = GanttTaskBoard.readExternallyDependentVSIds(new List<Id>(valueStreamIds));  // this method is inefficient and will have to be refactored
        
        // lock all records during this transaction
        // should filter out leankor__ValueStream__r.leankor__IsTemplateBoard__c???
        List<leankor__Dependency__c> dependencies =  [Select Id,
                                                            leankor__Predecessor__c,
                                                            leankor__Predecessor__r.Name,
                                                            leankor__Predecessor__r.leankor__ValueStream__c,
                                                            leankor__Predecessor__r.leankor__ValueStreamCardLink__c,
                                                            leankor__Predecessor__r.leankor__StartDateTime__c,
                                                            leankor__Predecessor__r.leankor__DueDateTime__c,
                                                            leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                            leankor__Predecessor__r.leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__Successor__c,
                                                            leankor__Successor__r.Name,
                                                            leankor__Successor__r.leankor__ValueStream__c,
                                                            leankor__Successor__r.leankor__ValueStreamCardLink__c,
                                                            leankor__Successor__r.leankor__StartDateTime__c,
                                                            leankor__Successor__r.leankor__DueDateTime__c,
                                                            leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                            leankor__Successor__r.leankor__ValueStream__r.leankor__ScheduleBackward__c,
                                                            leankor__SuccessorType__c,
                                                            leankor__ValueStream__c,
                                                            leankor__ValueStream__r.leankor__ProjectRoom__c
                                                        From leankor__Dependency__c
                                                        Where leankor__ValueStream__c In :setOfValueStreamIds
                                                            And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                            And leankor__Predecessor__r.leankor__IsRecordDeleted__c = false
                                                            And leankor__Predecessor__r.leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                            And leankor__Successor__r.leankor__IsRecordDeleted__c = false
                                                            And leankor__Successor__r.leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                        With Security_Enforced
                                                        Limit 50000 
                                                        For Update];

        // remove deleted records
        for (Integer index = dependencies.size() - 1; index >= 0; index--) {
            leankor__Dependency__c dependency = dependencies.get(index);
            if (dependency.leankor__ValueStream__c == null
            || dependency.leankor__ValueStream__r.leankor__ProjectRoom__c == null 
            || dependency.leankor__Predecessor__r.leankor__ValueStream__c == null
            || dependency.leankor__Predecessor__r.leankor__ValueStream__r.leankor__ProjectRoom__c == null
            || dependency.leankor__Successor__r.leankor__ValueStream__c == null
            || dependency.leankor__Successor__r.leankor__ValueStream__r.leankor__ProjectRoom__c == null
            ) {
                dependencies.remove(index);
            }
        }

        return dependencies;
    }


    // Used to update the external dependencies if external link found for the given KC records.
    public static void updateExternalDependencies(Set<String> cardIds, Set<String> valueStreamIds) {
        // We only creating the map of Predecessor because changes in Predecessor affect the Successor but not vice versa
        Map<Id, List<leankor__Dependency__c>> dependencyMap = leankor.Dependency.getPredecessorDependencyMap(valueStreamIds);
        // Get all the external dependency those affected by the given card.
        Set<leankor__Dependency__c> dependencies = getAllExternalDependency(cardIds, dependencyMap);
        dependencyMap.clear();
        
        if (dependencies.size() > 0) {
            updateDependency(new List<leankor__Dependency__c>(dependencies));
        }
        
        // Send broadcast for external dependencies
        List<leankor.RealTimeController.BulkStreaming> depStreaming = leankor.RealTimeControllerHelper.getDependentCardsDataForStreaming(dependencies);
        dependencies.clear();

        // Add all the external value Streams
        //leankor.RealTimeController.externalCardIDs.addAll(GanttTaskBoard.getExternallyDependentVSIds(valueStreamIds));

        if (depStreaming.size() > 0) {
            leankor.realtimeController.sendBroadcast(depStreaming, 'ManageDependency');
        }
    }


    // Return all the external dependeny linked to the given cardIds
    @TestVisible
    private static Set<leankor__Dependency__c> getAllExternalDependency(Set<String> cardIds, Map<Id, List<leankor__Dependency__c>> dependencyMap) {
        Set<leankor__Dependency__c> externalDependency = new Set<leankor__Dependency__c>();
        Set<String> successorIds = new Set<String>();

        for (String predecessorId: cardIds) {
            // If no dependency on the card 
            if (!dependencyMap.containsKey(predecessorId)) {
                continue;
            }

            for (leankor__Dependency__c dep: dependencyMap.get(predecessorId)) {
                if (dep.leankor__Predecessor__r.leankor__ValueStream__c != dep.leankor__Successor__r.leankor__ValueStream__c && !leankor__LeanConstants__c.getInstance().leankor__DisableAutoTranslationOfActivity__c) {
                    // Make IsDependencyRecalculate__c = true for external dependency
                    dep.leankor__IsDependencyRecalculate__c = true;
                    externalDependency.add(dep);
                    // Add Extenal dependency Predecessor and Successor valueStream ids. This is used in GS to send broadcast for external dependency.
                    leankor.RealTimeController.externalCardIDs.add(dep.leankor__Predecessor__r.leankor__ValueStream__c);
                    leankor.RealTimeController.externalCardIDs.add(dep.leankor__Successor__r.leankor__ValueStream__c);
                    continue;
                }
                
                if (dependencyMap.containsKey(dep.leankor__Successor__c)) {
                    successorIds.add(dep.leankor__Successor__c);
                }
            }
        }
        // If Successor linked found!!
        if (successorIds.size() > 0) {
            externalDependency.addAll(getAllExternalDependency(successorIds, dependencyMap));
        }

        return externalDependency;
    }


    // This method returns the Predecessor => Dependency Map for given value streams
    public static Map<Id, List<leankor__Dependency__c>> getPredecessorDependencyMap(Set<String> valueStreamIds) {
        Map<Id, List<leankor__Dependency__c>> dependencyMap = new Map<Id, List<leankor__Dependency__c>>();
        
        for (leankor__Dependency__c dep: leankor.Dependency.readDependency(valueStreamIds)) {
            List<leankor__Dependency__c> depList = dependencyMap.containsKey(dep.leankor__Predecessor__c) ? dependencyMap.get(dep.leankor__Predecessor__c) : new List<leankor__Dependency__c>();
            depList.add(dep);
            dependencyMap.put(dep.leankor__Predecessor__c, depList);
        }

        return dependencyMap;
    }

    // overloaded
    // create a map of sucessor cards
    // key is predecessor, value is successor
    // returns the Predecessor => Dependency Map for a given list of Dependency    
    public static Map<Id, List<leankor__Dependency__c>> getPredecessorDependencyMap(List<leankor__Dependency__c> dependencies) {
        Map<Id, List<leankor__Dependency__c>> dependencyMap = new Map<Id, List<leankor__Dependency__c>>();

        for (leankor__Dependency__c dependency : dependencies) {
            List<leankor__Dependency__c> successors = new List<leankor__Dependency__c>();
            List<leankor__Dependency__c> dependencyMapValues = dependencyMap.get(dependency.leankor__Predecessor__c);
            if (dependencyMapValues != null) {
                successors.addAll(dependencyMapValues);
            }
            successors.add(dependency);    
            dependencyMap.put(dependency.leankor__Predecessor__c, successors);
        }
        
        return dependencyMap;
    }

    // create a map of predecessor cards
    // key is successor, value is predecessor
    // returns the Successor => Dependency Map for a given list of Dependency
    public static Map<Id, List<leankor__Dependency__c>> getSuccessorDependencyMap(List<leankor__Dependency__c> dependencies) {
        Map<Id, List<leankor__Dependency__c>> dependencyMap = new Map<Id, List<leankor__Dependency__c>>();

        for (leankor__Dependency__c dependency : dependencies) {
            List<leankor__Dependency__c> predecessors = new List<leankor__Dependency__c>();
            List<leankor__Dependency__c> dependencyMapValues = dependencyMap.get(dependency.leankor__Successor__c);
            if (dependencyMapValues != null) {
                predecessors.addAll(dependencyMapValues);
            }
            predecessors.add(dependency);    
            dependencyMap.put(dependency.leankor__Successor__c, predecessors);
        }
        
        return dependencyMap;
    }
}