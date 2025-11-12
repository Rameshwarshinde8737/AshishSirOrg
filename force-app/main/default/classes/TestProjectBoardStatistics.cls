@isTest
public class TestProjectBoardStatistics{
    static testMethod Void test(){
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        

        leankor__projectroom__c pr = new leankor__projectroom__c( Name ='test');
            insert pr;
        leankor__Valuestream__c VS = new leankor__Valuestream__c(Name =  'Testing board', leankor__projectroom__c = pr.id);
            insert VS;
            List<leankor__Valuestream__c> listVS = new List<leankor__Valuestream__c>();
            listVS.add(VS);

        List<leankor__kanbancard__c> kanbancardlist = new List<leankor__kanbancard__c>();
            leankor__kanbancard__c insertkanbancard = new leankor__kanbancard__c();
            insertkanbancard.Name = 'Kanban1';
            insertkanbancard.leankor__ValueStream__c = VS.id;
            insertkanbancard.leankor__GUID__c = system.now() +'A183289';
            insertkanbancard.leankor__StartDateTime__c = system.now();
            insertkanbancard.leankor__DueDateTime__c = system.now() +10;
            insertkanbancard.leankor__EstimatedDuration__c = 10;
            insertkanbancard.leankor__PercentComplete2__c = 10;
            kanbancardlist.add(insertkanbancard);
            leankor__kanbancard__c insertkanbancard1 = new leankor__kanbancard__c();
            insertkanbancard1.Name = 'Kanban2';
            insertkanbancard1.leankor__ValueStream__c = VS.id;
            insertkanbancard1.leankor__GUID__c = system.now() +'l447856';
            insertkanbancard1.leankor__StartDateTime__c = system.now();
            insertkanbancard1.leankor__DueDateTime__c = system.now() +15;
            insertkanbancard1.leankor__EstimatedDuration__c = 15;
            insertkanbancard1.leankor__PercentComplete2__c = 10;
            kanbancardlist.add(insertkanbancard1);
            insert kanbancardlist;

            ProjectBoardStatistics PBS = new ProjectBoardStatistics();
            PBS.start(BC);
            PBS.execute(BC,listVS);
            PBS.finish(BC);
            system.assert(listVS.size()>0);
    }
}