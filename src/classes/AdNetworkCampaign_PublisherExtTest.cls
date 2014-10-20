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
private class AdNetworkCampaign_PublisherExtTest {
	
	static ApexPages.StandardController adnetCampaign;
	static AdNetworkCampaign_PublisherExt pubExt;

	static Ad_Network_Campaign__c c;
	static Account a;
	
    static testMethod void testGetPublishers() {
    	c  = new Ad_Network_Campaign__c(Name='Unit Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
		insert c;
        adnetCampaign = new ApexPages.StandardController(c);
		pubExt = new AdNetworkCampaign_PublisherExt(adnetCampaign);
		List<Account> publisherAccounts = [SELECT Id, Name FROM Account WHERE Type = 'Ad Network Publisher Site'];
        Test.startTest();
        List<CheckboxAccount> cpubs = pubExt.getPublishers();
        System.assertEquals(publisherAccounts.size(), cpubs.size());
        Test.stopTest();
    }
    
    static testMethod void testProcessSelected_NoneExisting() {
    	c  = new Ad_Network_Campaign__c(Name='Unit Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
		insert c;
		a = new Account(Name='Testing Account',Type='Ad Network Publisher Site');
		insert a;
        adnetCampaign = new ApexPages.StandardController(c);
		pubExt = new AdNetworkCampaign_PublisherExt(adnetCampaign);
		List<CheckboxAccount> selectedParts = new List<CheckboxAccount>();
		selectedParts.add(new CheckboxAccount(a, true));
		Test.startTest();
		pubExt.publisherList = selectedParts;
		pubExt.processSelected();
		List<CheckboxAccount> pubList = pubExt.getPublishers();
		System.assertEquals(selectedParts.size(), pubList.size());
		Test.stopTest();
    }
    
    static testMethod void testProcessSelected_PreviousExisting() {
    	c  = new Ad_Network_Campaign__c(Name='Unit Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
		insert c;
		a = new Account(Name='Testing Account',Type='Ad Network Publisher Site');
		insert a;
		List<Account> publisherAccounts = [SELECT Id, Name FROM Account WHERE Type = 'Ad Network Publisher Site'];
        adnetCampaign = new ApexPages.StandardController(c);
		pubExt = new AdNetworkCampaign_PublisherExt(adnetCampaign);
		List<CheckboxAccount> selectedParts = new List<CheckboxAccount>();
		selectedParts.add(new CheckboxAccount(a, true));
		Integer participantCount =0;
		List<CheckboxAccount> pubList;
		
		Test.startTest();
		pubExt.publisherList = selectedParts;
		pubExt.processSelected();
		participantCount = [SELECT COUNT() FROM Ad_Network_Campaign_Participation__c WHERE Ad_Network_Campaign__c = :c.Id];
		pubList = pubExt.getPublishers();
		System.assertEquals(selectedParts.size(), pubList.size());
		System.assertEquals(participantCount, selectedParts.size());
		pubExt = new AdNetworkCampaign_PublisherExt(adnetCampaign);
		pubList = pubExt.getPublishers();
		System.assertEquals(publisherAccounts.size(), pubList.size());
		
		Account b = new Account(Name='Second Testing Account',Type='Ad Network Publisher Site');
		insert b;
		publisherAccounts = [SELECT Id, Name FROM Account WHERE Type = 'Ad Network Publisher Site'];
		selectedParts.add(new CheckboxAccount(b,true));
		
		pubExt.publisherList = selectedParts;
		pubExt.processSelected();
		participantCount = [SELECT COUNT() FROM Ad_Network_Campaign_Participation__c WHERE Ad_Network_Campaign__c = :c.Id];
		pubList = pubExt.getPublishers();
		System.assertNotEquals(publisherAccounts.size(), pubList.size());
		System.assertEquals(participantCount, selectedParts.size());
		
		selectedParts.remove(0);
		pubExt.publisherList = selectedParts;
		pubExt.processSelected();
		participantCount = [SELECT COUNT() FROM Ad_Network_Campaign_Participation__c WHERE Ad_Network_Campaign__c = :c.Id];
		pubList = pubExt.getPublishers();
		System.assertNotEquals(publisherAccounts.size(), pubList.size());
		System.assertEquals(participantCount, selectedParts.size());
		
		Test.stopTest();
    }
}