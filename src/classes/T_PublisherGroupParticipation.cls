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
private class T_PublisherGroupParticipation {
	
	static AdNetworkCampaignParticipationManager pManager = new AdNetworkCampaignParticipationManager();
	static Ad_Network_Campaign__c campaign;
	static Account advertiser;
	static Account publisherGroup;
	static Account publisher;

    static testMethod void testPublisherGroupParticipationTrigger() {
    	Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    	List<User> admins = [SELECT Id, Name FROM User WHERE profileId =:adminProfile.Id];
    	System.debug(admins.get(0));
    	System.runAs(admins.get(0)) {
        advertiser = new Account(Name='Advertiser Account');
        insert advertiser;
        
        campaign = new Ad_Network_Campaign__c(Name='Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National', Advertiser__c=advertiser.Id);
        insert campaign;
        
        publisherGroup = new Account(Name='Publisher Group');
        insert publisherGroup;
        
        publisher = new Account(Name='Publisher Account', parent = publisherGroup);
        insert publisher;
        
        pManager.addCampaignPublishers(new List<Account> {publisher}, campaign);
        
        List<Ad_Network_Campaign_Participation__c> participants = 
    		[SELECT Id, Account__r.Id, Account__r.Name FROM Ad_Network_Campaign_Participation__c 
    		 WHERE Ad_Network_Campaign__c = :campaign.Id AND RecordTypeId = :pManager.getRecordTypes().get('Publisher Group')];
    	System.debug(participants);
    	
        System.assertEquals(1, pManager.getCampaignPublishers(campaign).size());
        System.assertEquals(1, pManager.getCampaignPublisherGroups(campaign).size());
        
        Account secondPublisher = new Account(Name='Second Publisher', parent=publisherGroup);
        insert secondPublisher;
        pManager.addCampaignPublishers(new List<Account> {secondPublisher}, campaign);
        System.assertEquals(2, pManager.getCampaignPublishers(campaign).size());
        System.assertEquals(1, pManager.getCampaignPublisherGroups(campaign).size());
    	}
    }
}