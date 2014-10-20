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
private class Test_AdNetworkCampaignParticipation_Ext {

	static AdNetworkCampaignParticipation_Extension ext;
	static ApexPages.StandardController partController;
	static Ad_Network_Campaign__c campaign;
	static Ad_Network_Campaign_Participation__c participation;
	static Account publisher;
	static Id recordTypeId;
	
    static testMethod void setup() {
    	List<RecordType> publisherRecordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Ad_Network_Campaign_Participation__c' AND Name = 'Publisher' LIMIT 1];
    	if(publisherRecordTypes.size() > 0)
    		recordTypeId = publisherRecordTypes.get(0).Id;
        campaign = new Ad_Network_Campaign__c(Name='Test Campaign', Io_Flight_Start_Date__c=Date.today(), Io_Flight_End_Date__c=Date.today()+1, Sales_Team__c='National');
        insert campaign;
        publisher = new Account(Name='Test Publisher', Type='Ad Network Publisher Site');
        insert publisher;
		participation = new Ad_Network_Campaign_Participation__c(Account__c=publisher.Id, Ad_Network_Campaign__c=campaign.Id, RecordTypeId=recordTypeId);
		insert participation;
        partController = new ApexPages.StandardController(participation);
        ext = new AdNetworkCampaignParticipation_Extension(partController);
    }
    
    /* the extension code that this was testing got moved to another class
    static testMethod void testGetDocuments() {
    	setup();
    	List<Ad_Network_Campaign_Document__c> docs = ext.getDocuments();
    	System.assertEquals(0, docs.size());
    	
    	//create an instance of the document extension and create a document for this participation
    	Ad_Network_Campaign_Document__c doc1 = new Ad_Network_Campaign_Document__c();
    	AdNetworkCampaignDocument_Extension docExt = new AdNetworkCampaignDocument_Extension(new ApexPages.StandardController(doc1));
    	List<SelectOption> docTypes = docExt.getDocumentTypes();
    	docExt.setCampaignParticipationId(participation.Id);
    	docExt.setSelectedDocumentType(docTypes.get(0).getValue());
    	PageReference blobMockPageRef = Page.TestBlobMock;
    	Blob docBlob = blobMockPageRef.getContent();
    	docExt.setFileBody(docBlob);
    	docExt.setFileName('Test Doc');
    	PageReference pr = docExt.processUpload();
    	
    	//reload the extension so it reloads the document list for this participation
    	ext = new AdNetworkCampaignParticipation_Extension(partController);
    	docs = ext.getDocuments();
    	//should only be 1 document now
    	System.assertEquals(1, docs.size());
    	
    	//test that getAttachments returns null
    	System.assertEquals(null, ext.getAttachments(docs.get(0).Id));
    	
    	ext.setActiveDocumentId(docs.get(0).Id);
    	System.assertEquals(docs.get(0).Id, ext.getActiveDocumentId());
    	
    	//test deleting the document
    	PageReference deletedPr = ext.deleteDocument();
    	System.assertEquals(null, deletedPr);
    	System.assertEquals(0, ext.getDocuments().size());
    }
    
    static testMethod void testNewDocument() {
    	setup();
    	PageReference newdocPage = Page.AdNetworkCampaign_NewDocument;
    	newdocPage.getParameters().put('cpid', participation.Id);
    	PageReference pr = ext.NewDocument();
    	System.assertEquals(participation.Id, pr.getParameters().get('cpid'));
    	System.assert(pr.getRedirect());
    }
    */
    
}