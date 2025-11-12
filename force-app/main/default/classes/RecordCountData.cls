public class RecordCountData {
    @AuraEnabled
    public Integer chattersCount{get; set;}
    @AuraEnabled
    public Integer filesCount{get; set;}
    @AuraEnabled
    public Integer riskCount{get; set;}
    
    public RecordCountData(){
        chattersCount=0;
        filesCount=0;
        riskCount=0;
    }

}