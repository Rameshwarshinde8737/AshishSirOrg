@isTest
public with sharing class PermissionSetsTestDataFactory {
    public PermissionSetsTestDataFactory() {}

	// This method is used for getting the Id for a certain Profile to be assigned to a test user
	private static Id getProfile(String profileName) {
		Id profileId;
		try {
			List<Profile> profileGet = [Select Id,
												Name
											From Profile
											Where Name = :profileName
											Limit 1];
			if(!profileGet.isEmpty()) {
				profileId = profileGet[0].Id;
			}

			return profileId;
		} catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}

	}

	// This method is used for creating a User with specified Names, Profile, and Permission Set(s)
	// A User object is then returned with the indicated Permission Set(s) assigned to it
	public static User getUser(String firstName, String lastName, String profileName, List<String> permissionSets) {
		String profileId = (String)getProfile(profileName);
		if(profileId == null) {
			throw new Util.LeanException('Error: Please assign an existing profile for the test user.');
		}

		User newUser = createUser(firstName, lastName, profileId, '');

		insert newUser;

		assignPermissionSet(permissionSets, newUser);

		return newUser;
	}

	// This method creates a User record that will be used for testing
	private static User createUser(String firstName, String lastName, String profileId, String contactId) {
		String orgId = UserInfo.getOrganizationId();
		String timeString = String.valueOf(DateTime.now().getTime());
		Integer randomNum = Integer.valueOf(Math.rint(Math.random()*100));
		String userUnique = orgId + timeString + randomNum;
		User tempUser = new User();
		tempUser.FirstName = firstName;
		tempUser.LastName = lastName;
		tempUser.Email = userUnique + '@testuser' + orgId + '.com';
		tempUser.Username = userUnique + '@testuser' + orgId + '.com';
		tempUser.EmailEncodingKey = 'UTF-8';
		tempUser.Alias = userUnique.substring(6,10) + 'test';
		tempUser.TimeZoneSidKey = 'America/Los_Angeles';
		tempUser.LocaleSidKey = 'en_US'; 
		tempUser.LanguageLocaleKey = 'en_US';  
		tempUser.ProfileId = profileId;
		
		if(!String.isBlank(contactId)) {
			tempUser.ContactId = contactId;
		}

		return tempUser;
	}

	//This method assigns a permission set to the test user
	private static void assignPermissionSet(List<String> permissionSetNames, User usr) {
		List<PermissionSet> ps = new List<PermissionSet>();

		try {
			ps = [Select ID 
					From PermissionSet 
					Where Name In :permissionSetNames
					Limit 100];

			if(!ps.isEmpty()) {
				List<PermissionSetAssignment> permissionsList = new List<PermissionSetAssignment>();

				for(PermissionSet perm : ps) {
					PermissionSetAssignment permSet = new PermissionSetAssignment(AssigneeId = usr.Id, 
																				PermissionSetId = perm.Id);
					permissionsList.add(permSet);
				}

				insert permissionsList;
			} else {
				throw new Util.LeanException('Error: Permission set does not exist. Please use an existing permission set or create a new one');
			}
		} catch(Exception e) {
			throw new Util.LeanException('ERROR:' + e.getMessage());
		}

	}

	// This method creates an Account record - mainly used for the purpose of creating a Community User
	public static Account createAccount(String accName) {
		Account commAccount = new Account(Name = accName); 

		insert commAccount;

		return commAccount;
	}

	// This method creates a Contact record - mainly used for the purpose of creating a Community User
	public static Contact createContact(String firstName, String lastName, String email, String accId) {
		Contact commContact = new Contact();
		commContact.FirstName = firstName;
		commContact.LastName = lastName;
		commContact.Email = email;
		commContact.AccountId = accId;
		commContact.Birthdate = Date.newInstance(2016, 12, 9);
		insert commContact;

		return commContact;
	}

	// This method creates a Community User for testing the user type
	public static User getCommunityUser(String firstName, String lastName, String contactId, String profileName, List<String> permissionSets) {
		
		String profileId = (String)getProfile(profileName);
		if(profileId == null) {
			throw new Util.LeanException('Error: Please assign an existing profile for the test community user.');
		}

		User comUser = createUser(firstName, lastName, profileId, contactId);

		insert comUser;

		assignPermissionSet(permissionSets, comUser);

		return comUser;
	}

	public static void makeCommunityUserData(){
        Account sampleAcc = createAccount('A Test Account');
        Contact commContact = createContact('Community', 'User', 'commuser@testemail.com', sampleAcc.Id);
    }

}