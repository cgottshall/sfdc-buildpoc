@isTest
private class T_AdNetworkCampaignDocument_Extension {

	static Ad_Network_Campaign__c campaign;
	static Ad_Network_Campaign_Participation__c participation;
	static Ad_Network_Campaign_Document__c doc;
	static Account publisher;
	static Account publisherGroup;
	static Account advertiser;
	static AdNetworkCampaignParticipationManager participationManager;
	static Id recordTypeId = null;
	static AdNetworkCampaignDocument_Extension ext;
	
    static void setup() {
    	List<RecordType> publisherRecordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Ad_Network_Campaign_Participation__c' AND Name = 'Publisher' LIMIT 1];
    	if(publisherRecordTypes.size() > 0)
    		recordTypeId = publisherRecordTypes.get(0).Id;
    	participationManager = new AdNetworkCampaignParticipationManager();
    	publisherGroup = new Account(Name='Test Publisher Group Account');
    	insert publisherGroup;
    	publisher = new Account(Name='Test Publisher Account', parentId=publisherGroup.Id);
    	insert publisher;
    	advertiser = new Account(Name='Test Advertiser');
    	insert advertiser;
    	campaign = new Ad_Network_Campaign__c(Name='Document Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National', Advertiser__c=advertiser.Id);
    	insert campaign;
    	participationManager.addCampaignPublishers(new List<Account> {publisher}, campaign);
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
    	ext.setCampaignId(campaign.Id);
    	
    	System.debug('Testing Advertiser Document Attachment');
    	//test advertiser document
    	ext.selectedRelatedEntityType = 'ADVERTISER';
    	ext.setCampaignParticipationId(null);
    	ext.setSelectedDocumentType(docTypes.get(0).getValue());
    	PageReference blobMockPageRef = new PageReference('/apex/TestBlobMock');
    	Blob docBlob = blobMockPageRef.getContent();
    	ext.setFileBody(docBlob);
    	ext.setFileName('Test Advertiser Doc');
    	PageReference pr = ext.processUpload();
    	System.assertNotEquals(new PageReference('/'+campaign.Id), pr);
    	System.assertEquals('Test Advertiser Doc', ext.getFileName());
    	System.assertEquals(docBlob.size(), ext.getFileSize());
    	System.assertEquals(campaign.Id, ext.getCampaignId());
    	
    	
    }
    
    static testMethod void testProcessUpload_PublisherDoc() {
    	setup();
    	List<SelectOption> docTypes = ext.getDocumentTypes();
    	ext.setCampaignId(campaign.Id);
    	
    	System.debug('Testing Publisher Document Attachment');
    	
    	ext.selectedRelatedEntityType = 'PUBLISHER';
    	List<Ad_Network_Campaign_Participation__c> pg = participationManager.getCampaignPublisherGroups(campaign);
    	ext.setCampaignParticipationId(pg.get(0).Id);
    	ext.setSelectedDocumentType(docTypes.get(0).getValue());
    	PageReference blobMockPageRef = new PageReference('/apex/TestBlobMock');
    	Blob docBlob = blobMockPageRef.getContent();
    	ext.setFileBody(docBlob);
    	ext.setFileName('Test Publisher Doc');
    	PageReference pr = ext.processUpload();
    	System.assertNotEquals(new PageReference('/'+campaign.Id), pr);
    	System.assertEquals('Test Publisher Doc', ext.getFileName());
    	System.assertEquals(docBlob.size(), ext.getFileSize());
    	System.assertEquals(campaign.Id, ext.getCampaignId());
    }
    
    static testMethod void testPublisherRelationshipOptions() {
    	setup();
    	System.debug('Campaign ID = '+campaign.Id);
    	ext.setCampaignId(campaign.Id);
    	
    	List<Ad_Network_Campaign_Participation__c> publishers  = [SELECT Id, Account__r.Id, Account__r.Name, Account__r.parent.Name, Account__r.parent.Id FROM Ad_Network_Campaign_Participation__c 
    		 														WHERE Ad_Network_Campaign__c = :campaign.Id AND RecordTypeId = :recordTypeId];
    	System.debug('CAMPAIGN = '+campaign);
    	System.debug('PARTICIPATION = '+participation);
    	System.debug('PUBLISHERS = '+publishers);
    	System.assertEquals(1, publishers.size());
    	List<SelectOption> options = ext.getPublisherRelationshipOptions();
    	System.assertEquals(publishers.size(), options.size());
    }
    
    static testMethod void testProcessUpload_noFile() {
    	setup();
    	List<SelectOption> docTypes = ext.getDocumentTypes();
    	ext.setFileBody(null);
    	ext.setCampaignId(campaign.Id);
    	PageReference pr = ext.processUpload();
    	System.assertEquals(null, pr);
    }
    
}