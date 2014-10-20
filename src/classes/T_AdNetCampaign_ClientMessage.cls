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
private class T_AdNetCampaign_ClientMessage {

    static testMethod void myUnitTest() {
        AdNetCampaign_ClientMessage clientMsg = new AdNetCampaign_ClientMessage();
        //create a campaign and a document
        Account adv = new Account(Name='Dummy Advertiser');
        insert adv;
        Ad_Network_Campaign__c cmpn = new Ad_Network_Campaign__c(Name='Test Campaign', Advertiser__c=adv.Id, Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
        insert cmpn;
        Ad_Network_Campaign_Participation__c part = [SELECT Id, Name, Account__c, Ad_Network_Campaign__c FROM Ad_Network_Campaign_Participation__c WHERE Account__c = :adv.Id];
        Ad_Network_Campaign_Document__c doc = new Ad_Network_Campaign_Document__c(Name='Test Doc',Ad_Network_Campaign_Participation__c=part.Id);
        insert doc;
        
        //test client message component
        clientMsg.setCampaignId(cmpn.Id);
        clientMsg.setDocumentId(doc.Id);
        
    }
}