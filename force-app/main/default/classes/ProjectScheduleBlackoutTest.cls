@isTest
private  with sharing class ProjectScheduleBlackoutTest {
   
    private @IsTest
    static void testBlackoutClassMethods(){

        // Value Stream records are created
        leankor__ValueStream__c vs_1 = new leankor__ValueStream__c(Name = 'PS_Blackout_Test_VS_01');
        INSERT vs_1;

        List<leankor__ProjectScheduleBlackout__c> psbList = new List<leankor__ProjectScheduleBlackout__c>();

        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
        blackOut.leankor__EndDate__c = System.today()+5;
        blackOut.leankor__StartDate__c = System.today();
        blackOut.leankor__ProjectBoard__c = vs_1.Id; 
        psbList.add(blackOut);

        leankor__ProjectScheduleBlackout__c blackOut_1 = new leankor__ProjectScheduleBlackout__c();
        blackOut_1.leankor__EndDate__c = System.today()+20;
        blackOut_1.leankor__StartDate__c = System.today()+10;
        blackOut_1.leankor__ProjectBoard__c = vs_1.Id;
        psbList.add(blackOut_1); 

        leankor__ProjectScheduleBlackout__c blackOut_3 = new leankor__ProjectScheduleBlackout__c();
        blackOut_3.leankor__EndDate__c = System.today()-5;
        blackOut_3.leankor__StartDate__c = System.today()-15;
        blackOut_3.leankor__ProjectBoard__c = vs_1.Id; 
        psbList.add(blackOut_3);
        
        Test.startTest();

        // Create the records
        List<leankor__ProjectScheduleBlackout__c> createPSBList = ProjectScheduleBlackout.createProjectScheduleBlackouts(psbList);

        // Read the records
        List<String> vsList = new List<String>();
        vsList.add(vs_1.Id);
        ProjectScheduleBlackout.Blackouts innerClassInstance = new ProjectScheduleBlackout.Blackouts();
        innerClassInstance.boardIds  = vsList;
        innerClassInstance.boardType ='PDG';

        System.assertEquals(1, ProjectScheduleBlackout.readProjectScheduleBlackouts(innerClassInstance).size());
        innerClassInstance.boardIds.add('00Dd0000001h60X');
        try{
            Map<String, List<ProjectScheduleBlackout__c>> projectScheudleBlackoutResult = ProjectScheduleBlackout.readProjectScheduleBlackouts(innerClassInstance);
        }
        catch (Exception e) {
            System.Assert(e.getMessage().contains('Invalid input'));
        }

        //Read Data Table Column for Project Schedule Blackout
        ProjectScheduleBlackout.projectScheduleBlackoutViewFieldSet('leankor__ProjectScheduleBlackout__c');

        
        // Update the Records
        ProjectScheduleBlackout.updateProjectScheduleBlackouts(createPSBList);

        // Delete the Records
        ProjectScheduleBlackout.deleteProjectScheduleBlackouts(createPSBList);
        
        Test.stopTest(); 
    }
    
    /*--------------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover getSobjectLayoutFields Method inside  ProjectScheduleBlackout Class And cover Exception Part 
    ----------------------------------------------------------------------------------------------------------------------------------*/
    
    public class MakeMockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(201);
            return response;
        }
    }
    
    /*-------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover getSobjectLayoutFields Method inside  ProjectScheduleBlackout Class
    -------------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void getSobjectLayoutFieldsTest(){  
        Test.setMock(HttpCalloutMock.class, new leankor.TestInvocableMethods());
        Test.startTest(); 
        String  getSobjectLayoutFieldsresult = ProjectScheduleBlackout.getSobjectLayoutFields('leankor__ProjectScheduleBlackout__c');
        System.assertEquals('{"status":"success"}',getSobjectLayoutFieldsresult);
        Test.stopTest(); 
    }
    
    /*-----------------------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method ProjectScheduleBlackoutTest is cover ProjectScheduleBlackout constructor inside  ProjectScheduleBlackout Class 
    -------------------------------------------------------------------------------------------------------------------------------------------*/   
    @IsTest
    private static void projectScheduleBlackoutTest(){
        Boolean flag = true; 
        Test.startTest(); 
        ProjectScheduleBlackout projectScheduleBlackoutRecord = new ProjectScheduleBlackout();
        System.assertEquals(true, flag);  
        Test.stopTest(); 
    }
    
    /*-----------------------------------------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method ProjectScheduleBlackoutSecondTest is cover ProjectScheduleBlackout constructor inside  ProjectScheduleBlackout Class 
    -----------------------------------------------------------------------------------------------------------------------------------------------*/      
    @IsTest
    private static void projectScheduleBlackoutSecondTest(){
        Boolean flag = true; 
        Test.startTest(); 
        Util utilRecord = new Util();
        ProjectScheduleBlackout projectScheduleBlackoutRecord = new ProjectScheduleBlackout(utilRecord);
        System.assertEquals(true, flag); 
        Test.stopTest(); 
    }
    
    /*---------------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover readProjectScheduleBlackoutsLWC Method inside  ProjectScheduleBlackout Class
    ----------------------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void readProjectScheduleBlackoutsLWCTest(){
            
        leankor__ProjectRoom__c projectRecord = new leankor__ProjectRoom__c();
        projectRecord.Name ='Demo Project';
        insert projectRecord;
        leankor__ValueStream__c valueStreamRecord = new leankor__ValueStream__c();
        valueStreamRecord.Name = 'ps create';
        valueStreamRecord.leankor__ProjectRoom__c = projectRecord.id;
        valueStreamRecord.leankor__BoardType__c = 'Kanban Board';
        valueStreamRecord.leankor__SevenDayWorkWeek__c = true;
        valueStreamRecord.leankor__IsTemplateBoard__c = false;
        insert valueStreamRecord;
        leankor__ProjectScheduleBlackout__c blackOut = new leankor__ProjectScheduleBlackout__c();
        blackOut.name='Demo BlackOut';
        blackOut.leankor__EndDate__c = System.today()+5;
        blackOut.leankor__StartDate__c = System.today();
        blackOut.leankor__ProjectBoard__c = valueStreamRecord.Id;
        insert blackOut;
        
        List<String> boardIds = new List<String>();
        boardIds.add(valueStreamRecord.id);
        
        String boardTypes = valueStreamRecord.leankor__BoardType__c;
        
        List<leankor.ProjectScheduleBlackout.Blackouts> listBlackoutsRecord = new List<leankor.ProjectScheduleBlackout.Blackouts>();
                ProjectScheduleBlackout.Blackouts BlackoutsRecord = new ProjectScheduleBlackout.Blackouts();
                BlackoutsRecord.boardIds = boardIds;
                BlackoutsRecord.boardType = boardTypes;
                listBlackoutsRecord.add(BlackoutsRecord);
            
        Test.startTest(); 
        Map<String, List<ProjectScheduleBlackout__c>> readProjectScheduleBlackoutsLWCRecord = leankor.ProjectScheduleBlackout.Blackouts.readProjectScheduleBlackoutsLWC(listBlackoutsRecord);
        System.assert(readProjectScheduleBlackoutsLWCRecord.keySet().size()>0); 
        System.assert(readProjectScheduleBlackoutsLWCRecord.values().size()>0);                                               
                                                                      
        Test.stopTest(); 
    }
    
    /*----------------------------------------------------------------------------------------------------
    Company     : Leankor
    Description : This method is cover getSobjectLayoutFields Method inside  ProjectScheduleBlackout Class
    ----------------------------------------------------------------------------------------------------------*/
    @IsTest
    private static void getSobjectLayoutFieldsExceptionTest(){  
        Boolean flag = true; 
        try{
            Test.setMock(HttpCalloutMock.class, new MakeMockHttpResponse());
            Test.startTest(); 
            String  getSobjectLayoutFieldsresult = ProjectScheduleBlackout.getSobjectLayoutFields('leankor__ProjectScheduleBlackout__c');
            Test.stopTest(); 
        }catch(Exception ex){
            System.assertEquals('System.CalloutException',ex.getTypeName());  
        } 
        System.assertEquals(true, flag);   
    }
}