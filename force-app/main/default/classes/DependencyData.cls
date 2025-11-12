public class DependencyData {
    @AuraEnabled
    public string id{get; set;}
    @AuraEnabled
	public string fromId{get; set;}
    @AuraEnabled
	public string fromVsId{get; set;}
    @AuraEnabled
	public string to{get; set;}
    @AuraEnabled
	public string toVsId{get; set;}
    @AuraEnabled
	public Integer type{get; set;}
    @AuraEnabled
	public Integer lag{get; set;}
    @AuraEnabled
	public string LagUnit{get; set;}
    @AuraEnabled
	public Decimal lagLeadDuration{get; set;}
    @AuraEnabled
	public Boolean isDependencyRecalculate{get; set;}
    @AuraEnabled
	public Boolean isExternalDependency{get; set;}
}