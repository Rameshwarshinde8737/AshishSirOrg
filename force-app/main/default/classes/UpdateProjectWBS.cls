/**************************************************************************
	* Company     : Leankor
 	* Description : This is helper class of MultipleUpdateProjectWBSAction.
 	* Usage	      : This is helper class of MultipleUpdateProjectWBSAction.
 	* None        : 
 **************************************************************************/ 
public with sharing class UpdateProjectWBS {
    
    private final String PARENT_NODE = 'parent';
    private final String CHILD_NODE = 'children';
    private final String BREAKDOWN_MARKER = '.';

    public String parentNode {
        get {
            return parentNode;
        } 
        set {
            parentNode = String.isBlank(value) ? PARENT_NODE : value.trim().toLowerCase();
        }
    }


    public String childNode {
        get {
            return childNode;
        } 
        set {
            childNode = String.isBlank(value) ? CHILD_NODE : value.trim().toLowerCase();
        }
    }


    public Set<Id> valueStreamIds {
        get {
            return valueStreamIds;
        } 
        set {
            valueStreamIds = value;
        }
    }


    public String breakdownMarker {
        get {
            return breakdownMarker;
        } 
        set {            
            breakdownMarker = String.isBlank(value) ? BREAKDOWN_MARKER : value.trim().left(1); // just the leftmost char
        }
    }


    public UpdateProjectWBS() {
        this.parentNode = PARENT_NODE;
        this.childNode = CHILD_NODE;
        this.breakdownMarker = BREAKDOWN_MARKER;      
    }


    public UpdateProjectWBS(Set<Id> valueStreamIds) {
        if (valueStreamIds.isEmpty()) {
            throw new UpdateProjectWBSException('Invalid input');
        }

        this.valueStreamIds = valueStreamIds;
        this.parentNode = PARENT_NODE;
        this.childNode = CHILD_NODE;
        this.breakdownMarker = BREAKDOWN_MARKER;
    }


    public UpdateProjectWBS(Id valueStreamId) {
        if (valueStreamId == null) {
            throw new UpdateProjectWBSException('Invalid input');
        }

        this.valueStreamIds = new Set<Id>{valueStreamId};
        this.parentNode = PARENT_NODE;
        this.childNode = CHILD_NODE;
        this.breakdownMarker = BREAKDOWN_MARKER;
    }


    public UpdateProjectWBS(Set<Id> valueStreamIds, String parentNode, String childNode, String breakdownMarker) {
        if (valueStreamIds.isEmpty() || String.isBlank(parentNode) || String.isBlank(childNode) || parentNode == childNode) {
            throw new UpdateProjectWBSException('Invalid input');
        }

        this.valueStreamIds = valueStreamIds;
        this.parentNode = parentNode;
        this.childNode = childNode;
        this.breakdownMarker = breakdownMarker;
    }


    public UpdateProjectWBS(Id valueStreamId, String parentNode, String childNode, String breakdownMarker) {
        if (valueStreamId == null || String.isBlank(parentNode) || String.isBlank(childNode) || parentNode == childNode) {
            throw new UpdateProjectWBSException('Invalid input');
        }

        this.valueStreamIds = new Set<Id>{valueStreamId};
        this.parentNode = parentNode;
        this.childNode = childNode;
        this.breakdownMarker = breakdownMarker;
    }


    // To Handle the exception 
    public class UpdateProjectWBSException extends Exception {}

    
    public class NodeIndex {
        public Integer value;
        
        public NodeIndex(Integer value) {
            this.value = value;
        }
    }


    public List<leankor__KanbanCard__c> generateProjectWorkOrderTree(List<Map<String, Object>> kanbanCardTree, leankor__ValueStream__c valueStream) {
        List<leankor__KanbanCard__c> kanbanCards = new List<leankor__KanbanCard__c>();

        try {
            kanbanCards = readKanbanCards(this.valueStreamIds);
            if (kanbanCards.size() > 0) { 
                Map<Id, leankor__KanbanCard__c> kanbanCardsById = new Map<Id, leankor__KanbanCard__c>();
                Map<Id, List<leankor__KanbanCard__c>> kanbanCardsByParentId = new Map<Id, List<leankor__KanbanCard__c>>();

                for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                    Id parentId = kanbanCard.leankor__ValueStreamCardLink__c;
                    if (!kanbanCardsByParentId.containsKey(parentId)) {
                        kanbanCardsByParentId.put(parentId, new List<leankor__KanbanCard__c>());
                    }
                    kanbanCardsByParentId.get(parentId).add(kanbanCard);
                    kanbanCardsById.put(kanbanCard.Id, kanbanCard);
                }

                // Call the recursive method to build the hierarchical tree structure starting from the root projectWorkOrder.
                Integer workBreakdownStructure = 1;
                NodeIndex projectSequence = new NodeIndex(workBreakdownStructure);
                for (leankor__KanbanCard__c kanbanCard : kanbanCards) {
                    if (kanbanCard.leankor__ValueStreamCardLink__c == null) {
                        if (valueStream.leankor__BoardType__c == 'UberBoard') {
                            kanbanCard.leankor__Order__c = workBreakdownStructure-1;
                            kanbanCard.leankor__CardId__c = String.valueOf(workBreakdownStructure);
                        }
                        // kanbanCard.leankor__SeriesNumber__c = projectSequence.value; // this is incremented inside buildTreeData()
                        kanbanCardTree.add(buildTreeData(kanbanCardsById, kanbanCardsByParentId, kanbanCard, projectSequence));
                        workBreakdownStructure++;
                    }
                }
            }

        } catch(Exception e) {
            throw new UpdateProjectWBSException(e.getmessage());
        }

        return kanbanCards;

    }


    @TestVisible
    private static List<leankor__KanbanCard__c> readKanbanCards(final Set<Id> valueStreamIds) {
        for (Id valueStreamId : valueStreamIds) {
            if (String.isBlank(valueStreamId) || Util.getSObjectName(valueStreamId) != 'leankor__ValueStream__c') {
                throw new UpdateProjectWBSException('Invalid input');
            }
        }

        /**The ORDER BY clause has been temporarily omitted in the SOQL query below because the FOR UPDATE clause has been added to lock records while updating CardId and Sequence. 
        In the future, if record locking is no longer required, simply remove the FOR UPDATE clause and uncomment the ORDER BY clause in the query." */
        List<leankor__KanbanCard__c> kanbanCards = [Select Id, 
                                                                Name,
                                                                leankor__ValueStream__c,
                                                                leankor__ValueStream__r.leankor__BoardType__C,
                                                                leankor__ValueStreamLink__c,
                                                                leankor__ValueStreamCardLink__c,
                                                                leankor__Order__c,
                                                                leankor__CardId__c,
                                                                leankor__SeriesNumber__c,
                                                                leankor__ValueStream__r.leankor__ProjectRoom__c,
                                                                leankor__ValueStreamLink__r.leankor__ProjectRoom__c        
                                                            From leankor__KanbanCard__c 
                                                            Where leankor__ValueStream__c In :valueStreamIds
                                                                And leankor__IsRecordDeleted__c = false
                                                                And leankor__ValueStream__r.leankor__IsRecordDeleted__c = false
                                                            With Security_Enforced
                                                            //Order By leankor__ValueStream__c,
                                                            //leankor__Order__c
                                                            Limit 50000 
                                                            For Update];

		// remove deleted records
		KanbanCard.removeDeletedKanbanCards(kanbanCards);

        kanbanCards.sort(new KanbanCardComparator());

        return kanbanCards;
    }


    // recursive method to build the hierarchical tree structure
    // kanbanCardsById, kanbanCardsByParentId, and projectWorkOrderParent are pass by reference
    @TestVisible
    private Map<String, Object> buildTreeData(Map<Id, leankor__KanbanCard__c> kanbanCardsById, Map<Id, List<leankor__KanbanCard__c>> kanbanCardsByParentId, leankor__KanbanCard__c kanbanCardParent, NodeIndex projectSequence) {
        Id parentId = kanbanCardParent.Id;
        String parentKanbanCardBreakdownStructure = kanbanCardParent.leankor__CardId__c;
        List<Map<String, Object>> children = new List<Map<String, Object>>();
        Map<String, Object> node = new Map<String, Object>();
       
        try {
            node.put(this.parentNode, kanbanCardsById.get(parentId));
            node.put(this.childNode, children);
            if (kanbanCardParent.leankor__valuestream__r.leankor__BoardType__c == 'UberBoard') {
                projectSequence.value++;
                kanbanCardParent.leankor__SeriesNumber__c = projectSequence.value;
            }

            if (kanbanCardsByParentId.containsKey(parentId)) {
                Integer workBreakdownStructure = 1;
                for (leankor__KanbanCard__c child : kanbanCardsByParentId.get(parentId)) {
                    child.leankor__Order__c = workBreakdownStructure-1;
                    child.leankor__CardId__c = parentKanbanCardBreakdownStructure + this.breakdownMarker + String.valueOf(workBreakdownStructure);
                    children.add(buildTreeData(kanbanCardsById, kanbanCardsByParentId, child, projectSequence));
                    workBreakdownStructure++;
                }
            }
        } catch(Exception e) {
            throw new UpdateProjectWBSException(e.getmessage());
        }

        return node;
    }
    

    public List<leankor__KanbanCard__c> updatekanbanCards(final List<leankor__KanbanCard__c> kanbanCards) {
        //Check CRUD / FLC behavior 
        KanbanCardBehaviour kanbanCardBehaviour = new KanbanCardBehaviour();
        if (!kanbanCardBehaviour.isUpdateable()) {
            throw new Util.LeanException('Error: No access to records');
        }
        //Check CRUD / FLC behavior 
        
        try {
            if (kanbanCards.size() > 0) {
                Database.update(kanbanCards);
            }
        } catch(Exception e) {
            throw new UpdateProjectWBSException(e.getMessage());
        }

        return kanbanCards;
    }


    // Custom comparator for sorting
    public class KanbanCardComparator implements Comparator<leankor__KanbanCard__c> {
        public Integer compare(leankor__KanbanCard__c card1, leankor__KanbanCard__c card2) {
            // Compare by ValueStream first
            Integer valueStreamComparison = String.valueOf(card1.leankor__ValueStream__c)
                .compareTo(String.valueOf(card2.leankor__ValueStream__c));
            if (valueStreamComparison != 0) {
                return valueStreamComparison;
            }
            // If ValueStream is equal, compare by Order
            return Integer.valueOf(card1.leankor__Order__c) - Integer.valueOf(card2.leankor__Order__c);
        }
    }
}