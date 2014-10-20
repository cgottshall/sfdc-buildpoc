/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CaseTriggerTests {
	
	static Account testAccount;
	static Contact testContact;
	static Case testCase;

    static testMethod void newCaseCommentTriggerTest() {
        setup();
        //add a comment
        CaseComment ccom = new CaseComment(CommentBody = 'This is a test', ParentId = testCase.Id);
        Test.startTest();
        //insert comment
        insert ccom;
        Test.stopTest();
        tearDown();        
    }
    
    static testMethod void caseAssignmentGroupSet() {
    	setup();
    	//Change Assignment Group value and Assignee value
    	Test.startTest();
    	testCase.Assignment_Group__c = 'Escalation to PTS';
    	testCase.Assignee__c = 'Business Systems';
    	update testCase;
    	Test.stopTest();
    	tearDown();
    }
    
    static testMethod void caseAssignmentGroupSet_QueueOwner() {
    	setup();
    	List<QueueSobject> queues = [SELECT QueueId FROM QueueSobject];
    	testCase.OwnerId = queues.get(0).QueueId;
    	update testCase;
    	//Change Assignment Group value and Assignee value
    	Test.startTest();
    	testCase.Assignment_Group__c = 'Escalation to PTS';
    	testCase.Assignee__c = 'Business Systems';
    	update testCase;
    	Test.stopTest();
    	tearDown();
    }
    
    static testMethod void sendMessageToPts_AutomatedUserDNE() {
    	List<User> users = [SELECT Id FROM User WHERE Username='pts@ibsys.com.testing'];
    	if(users.size() > 0)
    		for(User u : users) {
    			u.IsActive = false;
    			update u;
    		}
    	Test.startTest();
    	CaseCommentHandler.sendMessageToPts('Unit Test Message', 'Automated User should not exist. Please delete.');
    	Test.stopTest();
    }
    
    static testMethod void sendMessageToPts_AutomatedUserExists() {
    	List<User> users = [SELECT Id FROM User WHERE Username='pts@ibsys.com.testing'];
    	if(users.size() == 0) {
    		User activeUser = [SELECT TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey FROM User WHERE isActive = true LIMIT 1];
    		User auto = new User(Alias='Auto',LastName='Automated User',Username='pts@ibsys.com.testing',Email='pts@ibsys.com', 
    							 TimeZoneSidKey=activeUser.TimeZoneSidKey, LocaleSidKey=activeUser.LocaleSidKey, 
    							 EmailEncodingKey=activeUser.EmailEncodingKey, ProfileId=activeUser.ProfileId, 
    							 LanguageLocaleKey=activeUser.LanguageLocaleKey);
    		insert auto;
    	} else if(users.get(0).isActive == false) {
    		User auto = users.get(0);
    		auto.isActive = true;
    		update auto;
    	}
    	Test.startTest();
    	CaseCommentHandler.sendMessageToPts('Unit Test Message', 'Automated User should exist. Please delete.');
    	Test.stopTest();
    }
    
    static testMethod void testCommentOnEscalatedCase() {
    	setup();
    	//Change Assignment Group value and Assignee value
    	testCase.Assignment_Group__c = 'Escalation to PTS';
    	testCase.Assignee__c = 'Business Systems';
    	//add a comment
        CaseComment ccom = new CaseComment(CommentBody = 'This is a test', ParentId = testCase.Id);
    	update testCase;
    	Test.startTest();
    	insert ccom;
    	Test.stopTest();
    	tearDown();
    }
    
    static void setup() {
    	//create a case
        testAccount = new Account(Name='Testing Account');
        insert testAccount;
        testContact = new Contact(Account=testAccount,FirstName='Timmy',LastName='Tester');
        insert testContact;
        testCase = new Case(Contact=testContact,Account=testAccount, Subject='Testing for Comment Trigger', Assignment_Group__c = null);
		insert testCase;
    }
    
    static void tearDown() {
    	delete testCase;
        delete testAccount;
    }
}