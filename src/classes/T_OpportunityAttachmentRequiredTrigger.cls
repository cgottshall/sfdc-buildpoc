public with sharing class T_OpportunityAttachmentRequiredTrigger {
	
	public static List<Opportunity> oppsList = new List<Opportunity>();
	public static Account a;
	public static Map<String,Id> recordTypeMap = new Map<String,Id>();
	
	public static testMethod void testGetAttachmentCountByOpportunityId() {
		//load all the record types into a map for easy reference to the IDs
		for(RecordType rt : [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r WHERE SobjectType = 'Opportunity'])
    		recordTypeMap.put(rt.Name, rt.Id);
    		
		a = new Account(Name='Unit Test Account', AccountNumber='99999');
		insert a;
		List<Attachment> attToCreate = new List<Attachment>();
		
		for(Integer i=1; i < 100; i++) {
			Opportunity opp = new Opportunity(Name='testing',AccountId=a.Id,RecordTypeId=recordTypeMap.get('Strategic Opportunity'),First_Contact_Made__c=Date.parse('02/01/2010'),CloseDate=Date.parse('02/28/2010'),StageName='10 Percent',Probability=10,Amount=10);
			oppsList.add(opp);
		}
		insert oppsList;
		
		Set<Id> oppIdSet = new Set<Id>();
		for(Opportunity opp : oppsList) {
			oppIdSet.add(opp.Id);
			for(Integer atIdx=1; atIdx < 4; atIdx++) {
				Blob b = EncodingUtil.base64Decode('testing'+atIdx);
				Attachment att = new Attachment(Name='test attach '+atIdx,Body=b,ParentId=opp.Id);
				attToCreate.add(att);
			}
		}
		insert attToCreate;
		
		Map<Id,Integer> testMap = OpportunityAttachmentController.getAttachmentCountByOpportunityIds(oppIdSet);
		for(Opportunity opp : oppsList) {
			System.assertEquals(3, testMap.get(opp.Id));
		}
	}
	
	public static testMethod void testOpportunityAttachmentRequiredTrigger() {
		//setup the bunch of opportunities with attachments
		testGetAttachmentCountByOpportunityId();
		
		Opportunity fastTrackOppNoAtt = new Opportunity(Name='testing',AccountId=a.Id,RecordTypeId=recordTypeMap.get('Fast Track Opportunity'),First_Contact_Made__c=Date.today(),CloseDate=Date.today().addDays(30),StageName='10 Percent',Probability=10,Amount=10);
		insert fastTrackOppNoAtt;
		
		Opportunity strategicOppNoAtt = new Opportunity(Name='testing',AccountId=a.Id,RecordTypeId=recordTypeMap.get('Strategic Opportunity'),First_Contact_Made__c=Date.today(),CloseDate=Date.today().addDays(30),StageName='10 Percent',Probability=10,Amount=10);
		insert strategicOppNoAtt;
		
		Opportunity strategicOppWithAtt = oppsList.get(0);
		
		//attempt to transition opp from 10% to 20%, 1 having attachments, 1 without
		strategicOppNoAtt.Probability = 20;
		try {
			update strategicOppNoAtt;
			System.assert(false,'Strategic Opportunites without attachments should not be permitted to move forward');
		} catch (Exception ex) {
			System.assert(true, 'Strategic Opportunites without attachments should not be permitted to move forward');
		}
		
		strategicOppWithAtt.Probability = 20;
		try {
			update strategicOppWithAtt;
			System.assert(true, 'Strategic Opportunites with attachments should be permitted to move forward');
		} catch (Exception ex) {
			System.assert(false, 'Strategic Opportunites with attachments should be permitted to move forward');
		}
		
		fastTrackOppNoAtt.Probability = 20;
		try {
			update fastTrackOppNoAtt;
			System.assert(true, 'Fast Track Opportunites should be permitted to move forward without attachments');
		} catch (Exception ex) {
			System.assert(false, 'Fast Track Opportunites should be permitted to move forward without attachments');
		}
	}

}