public class RecordDetail {
    
    // Fields for RecordDetails
    @AuraEnabled
    public Integer count { get; set; }
    
    @AuraEnabled
    public Integer offsetSize { get; set; }
    
    @AuraEnabled
    public List<Contact> contacts { get; set; }
    
    @AuraEnabled
    public List<Account> accounts { get; set; }
    
    @AuraEnabled
    public List<User> users { get; set; }
    
    @AuraEnabled
    public List<Case> cases { get; set; }
    
    @AuraEnabled
    public List<Opportunity> opportunities { get; set; }
    
    // Constructor
    public RecordDetail() {
        this.contacts = new List<Contact>();
        this.accounts = new List<Account>();
        this.users = new List<User>();
        this.cases = new List<Case>();
        this.opportunities = new List<Opportunity>();
    }

    // Additional methods or logic if needed
}