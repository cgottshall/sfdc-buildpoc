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
private class T_AdNetworkCampaignParticipationManager {

	static AdNetworkCampaignParticipationManager mgr;
	
    static testMethod void testCreateManager() {    
    	mgr = new AdNetworkCampaignParticipationManager();
        Map<String,Id> rtypes = mgr.getRecordTypes();
        System.debug(rtypes);
        System.assert(rtypes.containsKey('Publisher'));
        System.assertNotEquals(null, rtypes.get('Publisher'));
    }
    
    static testMethod void testCreateAdvertiserParticipationFromCampaign() {
    	mgr = new AdNetworkCampaignParticipationManager();
    	Account advert = new Account(Name='Test Advertiser');
    	insert advert;
    	Ad_Network_Campaign__c campaign = new Ad_Network_Campaign__c(Advertiser__c = advert.Id, Name='Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
    	insert campaign;
    	
    	Ad_Network_Campaign_Participation__c advertiser = mgr.getCampaignAdvertiser(campaign);
    	System.assertNotEquals(null, advertiser);
    	
    	List<Ad_Network_Campaign_Participation__c> publishers = mgr.getCampaignPublishers(campaign);
    	System.assertEquals(0, publishers.size());
    }
    
    static testMethod void testNullAdvertiser() {
    	mgr = new AdNetworkCampaignParticipationManager();
    	Ad_Network_Campaign__c campaign = new Ad_Network_Campaign__c(Name='Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
    	insert campaign;
    	Ad_Network_Campaign_Participation__c advertiser = mgr.getCampaignAdvertiser(campaign);
    	System.assertEquals(null, advertiser);
    }
    
    static testMethod void testAddRemovePublishers() {
    	mgr = new AdNetworkCampaignParticipationManager();
    	Account advert = new Account(Name='Test Advertiser');
    	insert advert;
    	Ad_Network_Campaign__c campaign = new Ad_Network_Campaign__c(Advertiser__c = advert.Id, Name='Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
    	insert campaign;
    	
    	Ad_Network_Campaign_Participation__c advertiser = mgr.getCampaignAdvertiser(campaign);
    	System.assertNotEquals(null, advertiser);
    	
    	List<Ad_Network_Campaign_Participation__c> publishers = mgr.getCampaignPublishers(campaign);
    	System.assertEquals(0, publishers.size());
    	
    	Account pubA = new Account(Name='Test Publisher A');
    	Account pubB = new Account(Name='Test Publisher B');
    	List<Account> pubs = new Account[] {pubA, pubB};
    	insert pubs;
    	mgr.addCampaignPublishers(pubs, campaign);
    	publishers = mgr.getCampaignPublishers(campaign);
    	System.assertEquals(2, publishers.size());
    	
    	pubs.remove(0);
    	mgr.removeCampaignPublishers(pubs, campaign);
    	publishers = mgr.getCampaignPublishers(campaign);
    	System.assertEquals(1, publishers.size());
    	System.assertEquals(pubA.Id, publishers.get(0).Account__c);
    }
    
    static testMethod void testManualChangeAdvertiser() {
    	mgr = new AdNetworkCampaignParticipationManager();
    	Account advert = new Account(Name='Test Advertiser');
    	insert advert;
    	Ad_Network_Campaign__c campaign = new Ad_Network_Campaign__c(Advertiser__c = advert.Id, Name='Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
    	insert campaign;
    	
    	Ad_Network_Campaign_Participation__c advertiser = mgr.getCampaignAdvertiser(campaign);
    	System.assertNotEquals(null, advertiser);
    	
    	Account newAdvert = new Account(Name='Replacement Test Advertiser');
    	insert newAdvert;
    	mgr.changeCampaignAdvertiser(advert, newAdvert, campaign);
    	
    	advertiser = mgr.getCampaignAdvertiser(campaign);
    	System.assertNotEquals(null, advertiser);
    }
    
    static testMethod void testTriggerChangeAdvertiser() {
    	mgr = new AdNetworkCampaignParticipationManager();
    	Account advert = new Account(Name='Test Advertiser');
    	insert advert;
    	Ad_Network_Campaign__c campaign = new Ad_Network_Campaign__c(Advertiser__c = advert.Id, Name='Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
    	insert campaign;
    	
    	Ad_Network_Campaign_Participation__c advertiser = mgr.getCampaignAdvertiser(campaign);
    	System.assertNotEquals(null, advertiser);
    	
    	Account newAdvert = new Account(Name='Replacement Test Advertiser');
    	insert newAdvert;
    	campaign.Advertiser__c = newAdvert.Id;
    	update campaign;
    	
    	advertiser = mgr.getCampaignAdvertiser(campaign);
    	System.assertNotEquals(null, advertiser);
    }
}