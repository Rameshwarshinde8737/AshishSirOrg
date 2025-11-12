@isTest
private class ResourceAvailabilityTriggerHandlerTest {

	public static User u = null;
	
	static void init(){
		u = createStandardUser('Leankor');
		assignpermissionSet('Visual_Lean_Designer', u);

	}

	static testmethod void testDatesWithNoOverlap(){
		init();

		Test.startTest();

		System.runAs(u){

			List<BusinessHours> bhs = [SELECT id FROM BusinessHours WHERE IsDefault=true];
			System.assert(bhs.size() == 1);

			leankor__GlobalWorkHour__c wh1 = new leankor__GlobalWorkHour__c();
			leankor__GlobalWorkHour__c wh2 = new leankor__GlobalWorkHour__c();
			leankor__GlobalWorkHour__c wh3 = new leankor__GlobalWorkHour__c();

			wh1.leankor__BusinessHours__c = bhs[0].Id;
			wh1.leankor__StartDate__c = Date.newInstance(2017 , 01 , 01);
			wh1.leankor__EndDate__c = Date.newInstance(2017 , 01 , 31);

			insert wh1;

			List<leankor__GlobalWorkHour__c> ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 1);

			wh2.leankor__BusinessHours__c = bhs[0].Id;
			wh2.leankor__StartDate__c = Date.newInstance(2017 , 02 , 01);
			wh2.leankor__EndDate__c = Date.newInstance(2017 , 02 , 28);

			insert wh2;

			ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 2);
						
			wh2.leankor__StartDate__c = Date.newInstance(2017 , 02 , 01);
			wh2.leankor__EndDate__c = Date.newInstance(2017 , 03 , 28);

			update wh2;

			ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 2);			

		}

		Test.stopTest();			

	}

	static testmethod void testDatesWithOverlap(){
		init();

		Test.startTest();

		System.runAs(u){
			List<BusinessHours> bhs = [SELECT id FROM BusinessHours WHERE IsDefault=true];
			System.assert(bhs.size() == 1);

			leankor__GlobalWorkHour__c wh1 = new leankor__GlobalWorkHour__c();
			leankor__GlobalWorkHour__c wh2 = new leankor__GlobalWorkHour__c();
			leankor__GlobalWorkHour__c wh3 = new leankor__GlobalWorkHour__c();
			leankor__GlobalWorkHour__c wh4 = new leankor__GlobalWorkHour__c();

			wh1.leankor__BusinessHours__c = bhs[0].Id;
			wh1.leankor__StartDate__c = Date.newInstance(2017 , 01 , 01);
			wh1.leankor__EndDate__c = Date.newInstance(2017 , 01 , 31);

			insert wh1;

			List<leankor__GlobalWorkHour__c> ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 1);

			//Record with same start and end date
			try{
				wh2.leankor__BusinessHours__c = bhs[0].Id;
				wh2.leankor__StartDate__c = Date.newInstance(2017 , 01 , 01);
				wh2.leankor__EndDate__c = Date.newInstance(2017 , 01 , 31);

				insert wh2;

			} catch(Exception exp) {
				boolean expectedException = exp.getMessage().contains('Start date or end date is already scheduled') ? true : false;
				System.AssertEquals(expectedException, true);
			}

			ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 1);	


			//Existing start / end date within new Start / end date range
			try{
				wh3.leankor__BusinessHours__c = bhs[0].Id;
				wh3.leankor__StartDate__c = Date.newInstance(2016 , 01 , 01);
				wh3.leankor__EndDate__c = Date.newInstance(2018 , 01 , 31);

				insert wh3;

			} catch(Exception exp) {
				boolean expectedException = exp.getMessage().contains('Start date or end date is already scheduled') ? true : false;
				System.AssertEquals(expectedException, true);
			}

			ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 1);	


			//overlapping start / end date range
			try{
				wh4.leankor__BusinessHours__c = bhs[0].Id;
				wh4.leankor__StartDate__c = Date.newInstance(2017 , 02 , 1);
				wh4.leankor__EndDate__c = Date.newInstance(2017 , 02 , 28);

				insert wh4;

			} catch(Exception exp) {
				boolean expectedException = exp.getMessage().contains('Start date or end date is already scheduled') ? true : false;
				System.AssertEquals(expectedException, true);
			}
			
			ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 2);
			
			// updateing existing Resource Availability 
			try{				
				wh4.leankor__StartDate__c = Date.newInstance(2017 , 01 , 17);				
				update wh1;
			}catch(Exception exp) {
				boolean expectedException = exp.getMessage().contains('Start date or end date is already scheduled') ? true : false;
				System.AssertEquals(expectedException, true);
			}		
			
			ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 2);
											

		}		

		Test.stopTest();		

	}	

	static testmethod void testValidationRule(){
		init();

		Test.startTest();

		System.runAs(u){
			List<BusinessHours> bhs = [SELECT id FROM BusinessHours WHERE IsDefault=true];
			System.assert(bhs.size() == 1);

			leankor__GlobalWorkHour__c wh1 = new leankor__GlobalWorkHour__c();
			leankor__GlobalWorkHour__c wh2 = new leankor__GlobalWorkHour__c();

			wh1.leankor__BusinessHours__c = bhs[0].Id;
			wh1.leankor__StartDate__c = Date.newInstance(2017 , 01 , 01);
			wh1.leankor__EndDate__c = Date.newInstance(2017 , 01 , 31);

			insert wh1;

			List<leankor__GlobalWorkHour__c> ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 1);

			try{
				wh2.leankor__BusinessHours__c = bhs[0].Id;
				wh2.leankor__StartDate__c = Date.newInstance(2018 , 01 , 31);
				wh2.leankor__EndDate__c = Date.newInstance(2018 , 01 , 01);

				insert wh2;

			} catch(Exception exp) {
				boolean expectedException = exp.getMessage().contains('Start Date must be less than or equal to the End Date.') ? true : false;
				System.AssertEquals(expectedException, true);
			}

			ra = [SELECT Id FROM leankor__GlobalWorkHour__c];
			System.assert(ra.size() == 1);		


		}

		Test.stopTest();
	}

	public static User createStandardUser(String userName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

		User u1 = new User(Alias = userName, 
							Email = userName + '@leankor.com',
							EmailEncodingKey = 'UTF-8', 
							LastName = 'Leankor1', 
							LanguageLocaleKey = 'en_US',
							LocaleSidKey = 'en_US', 
							ProfileId = p.Id,
							TimeZoneSidKey = 'America/Los_Angeles', 
							UserName = userName + '@leankor.com.test');

		insert u1;

		return u1;
	}


	//This method assign a given permission set to a given user
	public static void assignpermissionSet(String permissionSetName, User usr) {
		PermissionSet ps = [SELECT ID FROM PermissionSet WHERE Name = :permissionSetName];

		insert new PermissionSetAssignment(AssigneeId = usr.id, 
										PermissionSetId = ps.Id );
	}	
	
}