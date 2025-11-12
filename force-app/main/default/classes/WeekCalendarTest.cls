@IsTest 
public class WeekCalendarTest {
    @isTest
    static void testReadWeekCalendars() {
        List<leankor__WeekCalendar__c> testRecords = new List<leankor__WeekCalendar__c>();

        for (Integer i = 1; i <= 5; i++) {
            leankor__WeekCalendar__c record = new leankor__WeekCalendar__c();
            record.Name = 'Test Calendar ' + i;
            record.leankor__Monday__c = true;
            record.leankor__Tuesday__c = false;
            record.leankor__Wednesday__c = true;
            record.leankor__Thursday__c = false;
            record.leankor__Friday__c = true;
            record.leankor__Saturday__c = false;
            record.leankor__Sunday__c = true;
            testRecords.add(record);
        }
        insert testRecords;

        Test.startTest();      
        List<WeekCalendar.InnerClass> result = WeekCalendar.readWeekCalendars();
        System.assertEquals(5, result.size());
        
        WeekCalendar.InnerClass firstRecord = result[0];
        System.assertEquals('Test Calendar 1', firstRecord.Name);
        System.assertEquals(true, firstRecord.Monday);
        System.assertEquals(false, firstRecord.Tuesday);
        System.assertEquals(true, firstRecord.Wednesday);
        System.assertEquals(false, firstRecord.Thursday);
        System.assertEquals(true, firstRecord.Friday);
        System.assertEquals(false, firstRecord.Saturday);
        System.assertEquals(true, firstRecord.Sunday);
        Test.stopTest();
    }

       
       @IsTest
       static void testWeekCalendarsWithNoData() {
         
         Test.startTest();                    
        list<WeekCalendar.innerClass> result = WeekCalendar.readWeekCalendars();
            system.debug(result);
        System.assertEquals(0, result.size());
        Test.stopTest();
	}
    
      @isTest
    static void testReadWeekCalendarsById() {
        
        leankor__WeekCalendar__c testWeekCalendar = new leankor__WeekCalendar__c();
        testWeekCalendar.Name = 'Test Week Calendar';
        testWeekCalendar.leankor__Monday__c = true;
        testWeekCalendar.leankor__Tuesday__c = false;
        testWeekCalendar.leankor__Wednesday__c = true;
        testWeekCalendar.leankor__Thursday__c = false;
        testWeekCalendar.leankor__Friday__c = true;
        testWeekCalendar.leankor__Saturday__c = false;
        testWeekCalendar.leankor__Sunday__c = true;
        insert testWeekCalendar;

        List<String> ids = new List<String>{testWeekCalendar.Id};

        Test.startTest();
        List<WeekCalendar.InnerClass> result = WeekCalendar.readWeekCalendarsById(ids);
        Test.stopTest();

        System.assertEquals(1, result.size());
        WeekCalendar.InnerClass innerClass = result[0];
        System.assertEquals('Test Week Calendar', innerClass.Name);
        System.assertEquals(true, innerClass.Monday);
        System.assertEquals(false, innerClass.Tuesday);
        System.assertEquals(true, innerClass.Wednesday);
        System.assertEquals(false, innerClass.Thursday);
        System.assertEquals(true, innerClass.Friday);
        System.assertEquals(false, innerClass.Saturday);
        System.assertEquals(true, innerClass.Sunday);
    }
    
    @isTest
    static void testWeekCalendarConstructor() {
        Util mockUtil = new Util();
        
        Test.startTest();
        WeekCalendar weekCalendar = new WeekCalendar(mockUtil);
        Test.stopTest();
        
        System.assertNotEquals(weekCalendar, null, 'WeekCalendar instance should be created successfully');
    }
    
}