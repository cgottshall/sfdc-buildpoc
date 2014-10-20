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
private class AdNetworkCampaignDocument_ExtensionTest {

	static Ad_Network_Campaign__c campaign;
	static Ad_Network_Campaign_Participation__c participation;
	static Ad_Network_Campaign_Document__c doc;
	static Id recordTypeId = null;
	static AdNetworkCampaignDocument_Extension ext;
	
    static testMethod void setup() {
    	List<RecordType> publisherRecordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Ad_Network_Campaign_Participation__c' AND Name = 'Publisher' LIMIT 1];
    	if(publisherRecordTypes.size() > 0)
    		recordTypeId = publisherRecordTypes.get(0).Id;
    	campaign = new Ad_Network_Campaign__c(Name='Document Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
    	insert campaign;
    	Account publisher = new Account(Name='Test Publisher Account');
    	insert publisher;
    	participation = new Ad_Network_Campaign_Participation__c(Account__c=publisher.Id, Ad_Network_Campaign__c=campaign.Id, RecordTypeId=recordTypeId);
        doc = new Ad_Network_Campaign_Document__c();
        ApexPages.StandardController docController = new ApexPages.StandardController(doc);
        ext = new AdNetworkCampaignDocument_Extension(docController);
    }
    
    static testMethod void testDocumentTypes() {
    	setup();
    	Integer i;
    	Schema.DescribeFieldResult F = Ad_Network_Campaign_Document__c.Document_Type__c.getDescribe();
		List<Schema.PicklistEntry> plvs = F.getPicklistValues();
		for(i=0; i < plvs.size(); i++) {
			PicklistEntry pe = plvs.get(i);
			if(!pe.isActive())
				plvs.remove(i);
		}
		List<SelectOption> docTypes = ext.getDocumentTypes();
		System.assertEquals(plvs.size(), docTypes.size());
		ext.setSelectedDocumentType(docTypes.get(0).getValue());
		System.assertEquals(docTypes.get(0).getValue(), ext.getSelectedDocumentType());
    }
    
    static testMethod void testProcessUpload() {
    	setup();
    	List<SelectOption> docTypes = ext.getDocumentTypes();
    	ext.setCampaignParticipationId(participation.Id);
    	ext.setSelectedDocumentType(docTypes.get(0).getValue());
    	PageReference blobMockPageRef = new PageReference('/apex/TestBlobMock');
    	Blob docBlob = blobMockPageRef.getContent();
    	ext.setFileBody(docBlob);
    	ext.setFileName('Test Doc');
    	PageReference pr = ext.processUpload();
    	System.assertNotEquals(new PageReference('/'+participation.Id), pr);
    	System.assertEquals('Test Doc', ext.getFileName());
    	System.assertEquals(docBlob.size(), ext.getFileSize());
    	System.assertEquals(participation.Id, ext.getCampaignParticipationId());
    }
    
    static testMethod void testProcessUpload_noFile() {
    	setup();
    	List<SelectOption> docTypes = ext.getDocumentTypes();
    	ext.setCampaignParticipationId(participation.Id);
    	PageReference pr = ext.processUpload();
    	System.assertEquals(null, pr);
    }
    
}