public with sharing class ResourceAssignment {
    public static List<leankor__ResourceAssignment__c> upsertResourceAssignments(final List<leankor__ResourceAssignment__c> resourceAssignments) {
		//Check CRUD / FLC behavior   
        ResourceAssignmentBehavior resourceAssignmentBehavior = new ResourceAssignmentBehavior();
		if (!resourceAssignmentBehavior.isCreateable() ||
			!resourceAssignmentBehavior.isUpdateable()) {
			throw new Util.LeanException('Error: No access to records');
		}
		//Check CRUD / FLC behavior 
		
		try{
			Database.upsert(resourceAssignments);
		}catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}
		return resourceAssignments;
	}
}