public with sharing class AdNetworkCampaignParticipationManager {
	
	private Map<String,Id> recordTypeMap;
	
	private void loadRecordTypes() {
		this.recordTypeMap = new Map<String,Id>();
		for(RecordType r : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Ad_Network_Campaign_Participation__c']) {
			this.recordTypeMap.put(r.Name, r.Id);
		}
		System.debug('recordTypeMap: '+this.recordTypeMap);
	}
	
	public Map<String,Id> getRecordTypes() {
		if(this.recordTypeMap == null)
			loadRecordTypes();
		System.debug(this.recordTypeMap);
		return this.recordTypeMap;
	}
	
	public void createAdvertiserParticipation(List<Ad_Network_Campaign__c> campaigns) {
		List<Ad_Network_Campaign_Participation__c> newParticipations = new List<Ad_Network_Campaign_Participation__c>();
		for(Ad_Network_Campaign__c c : campaigns) {
			newParticipations.add(new Ad_Network_Campaign_Participation__c(
												Account__c=c.Advertiser__c, 
												Ad_Network_Campaign__c=c.Id, 
												RecordTypeId=getRecordTypes().get('Advertiser'))
										);
		}
		insert newParticipations;
		
	}
	
	public void changeAdvertiserParticipation(List<Ad_Network_Campaign__c> campaigns) {
		Set<Id> campaignIds = SobjectHelper.getObjectIdsFromObjectList(campaigns);
		List<Ad_Network_Campaign_Participation__c> existingParticipations = [SELECT Id, Account__c, Ad_Network_Campaign__c FROM Ad_Network_Campaign_Participation__c WHERE Ad_Network_Campaign__c IN :campaignIds];
		List<Ad_Network_Campaign_Participation__c> changedParticipations = new List<Ad_Network_Campaign_Participation__c>();
		for(Ad_Network_Campaign__c c : campaigns) {
			for(Ad_Network_Campaign_Participation__c cpart : existingParticipations) {
				if(c.Id == cpart.Ad_Network_Campaign__c) {
					cpart.Account__c = c.Advertiser__c;
					changedParticipations.add(cpart);
				}
			}
		}
		update changedParticipations;
	}
	
	public void changeCampaignAdvertiser(Account existingAdvertiser, Account newAdvertiser, Ad_Network_Campaign__c campaign) {
		Ad_Network_Campaign_Participation__c advertiserParticipation = 
				[SELECT Id FROM Ad_Network_Campaign_Participation__c 
				WHERE Account__r.Id =:existingAdvertiser.Id AND Ad_Network_Campaign__c =:campaign.Id LIMIT 1];
		advertiserParticipation.Account__c = newAdvertiser.Id;
		update advertiserParticipation;
	}
	
	public void addCampaignPublishers(List<Account> publishers, Ad_Network_Campaign__c campaign) {
		List<Ad_Network_Campaign_Participation__c> newParticipations = new List<Ad_Network_Campaign_Participation__c>();
    	for(Account a : publishers) {
    		Ad_Network_Campaign_Participation__c newPart = 
    			new Ad_Network_Campaign_Participation__c(Account__c=a.Id, Ad_Network_Campaign__c=campaign.Id, RecordTypeId=getRecordTypes().get('Publisher'));
    		newParticipations.add(newPart);
    	}
    	insert newParticipations;
	}
	
	public void removeCampaignPublishers(List<Account> publishers, Ad_Network_Campaign__c campaign) {
		Set<Id> accountIds = SobjectHelper.getObjectIdsFromObjectList(publishers);
    	List<Ad_Network_Campaign_Participation__c> removedParticipations = [SELECT Id FROM Ad_Network_Campaign_Participation__c WHERE Account__r.Id IN :accountIds AND Ad_Network_Campaign__c =:campaign.Id];
    	delete removedParticipations;
	}

	public List<Ad_Network_Campaign_Participation__c> getCampaignPublishers(Ad_Network_Campaign__c campaign) {
    	List<Ad_Network_Campaign_Participation__c> participants = 
    		[SELECT Id, Account__r.Id, Account__r.Name, Account__r.parent.Name, Account__r.parent.Id,  Account_Approval__c, Advertiser_Approval__c, Billing_Approval__c FROM Ad_Network_Campaign_Participation__c 
    		 WHERE Ad_Network_Campaign__c = :campaign.Id AND RecordTypeId = :getRecordTypes().get('Publisher')];
    	return participants;
    }
    
    public void addCampaignPublisherGroups(List<Account> publisherGroups, Ad_Network_Campaign__c campaign) {
		List<Ad_Network_Campaign_Participation__c> newParticipations = new List<Ad_Network_Campaign_Participation__c>();
    	for(Account a : publisherGroups) {
    		Ad_Network_Campaign_Participation__c newPart = 
    			new Ad_Network_Campaign_Participation__c(Account__c=a.Id, Ad_Network_Campaign__c=campaign.Id, RecordTypeId=getRecordTypes().get('Publisher Group'));
    		newParticipations.add(newPart);
    	}
    	insert newParticipations;
	}
	
	public List<Ad_Network_Campaign_Participation__c> getCampaignPublisherGroups(Ad_Network_Campaign__c campaign) {
    	List<Ad_Network_Campaign_Participation__c> participants = 
    		[SELECT Id, Account__r.Id, Account__r.Name, Account_Approval__c, Advertiser_Approval__c, Billing_Approval__c FROM Ad_Network_Campaign_Participation__c 
    		 WHERE Ad_Network_Campaign__c = :campaign.Id AND RecordTypeId = :getRecordTypes().get('Publisher Group')];
    	return participants;
    }
    
    /* FOR FUTURE USE
       Would like to have a display component that can generate the publisher list grouped by publishing company
       This would provide a Map<PublishingCompanyName,List<Publisher>> */
    public Map<String,List<Ad_Network_Campaign_Participation__c>> getCampaignPublishersGroupedByParentCompany(Ad_Network_Campaign__c campaign) {
    	Map<String,List<Ad_Network_Campaign_Participation__c>> pubCompanyMap = new Map<String,List<Ad_Network_Campaign_Participation__c>>();
    	List<Ad_Network_Campaign_Participation__c> participants = getCampaignPublishers(campaign);
    	String companyKey;
    	for(Ad_Network_Campaign_Participation__c p : participants) {
    		if(p.Account__r.parent.Name == null || p.Account__r.parent.Name == '') {
    			companyKey = 'Independent';
    		} else {
    			companyKey = p.Account__r.parent.Name;
    		}
    		if(!pubCompanyMap.containsKey(companyKey)) {
    			pubCompanyMap.put(companyKey, new List<Ad_Network_Campaign_Participation__c>());
    		}
    		pubCompanyMap.get(companyKey).add(p);
    	}
    	return pubCompanyMap;
    }
    
    public Ad_Network_Campaign_Participation__c getCampaignAdvertiser(Ad_Network_Campaign__c campaign) {
    	List<Ad_Network_Campaign_Participation__c> participants = 
    		[SELECT Id, Account__r.Id, Account__r.Name, Account__r.parent.Name, Billing_Approval__c, Account_Approval__c, Advertiser_Approval__c FROM Ad_Network_Campaign_Participation__c 
    		 WHERE Ad_Network_Campaign__c = :campaign.Id AND RecordTypeId = :getRecordTypes().get('Advertiser')];
    	if(participants.size() > 0)
	    	return participants.get(0);
	    else
	    	return null;
    }
    
    public void updateCampaignPublisherGroups(Ad_Network_Campaign__c campaign) {
    	//Obtain a set of Ids that represent the desired publisher group Accounts
    	Set<Id> pubGroupAccountIds = new Set<Id>();
		for(Ad_Network_Campaign_Participation__c p :  [SELECT Account__r.parent.Id 
														 FROM Ad_Network_Campaign_Participation__c 
		    		 									WHERE Ad_Network_Campaign__c = :campaign.Id 
		    		 										  AND RecordTypeId = :getRecordTypes().get('Publisher')]) {
			pubGroupAccountIds.add(p.Account__r.parent.Id);
		}
		//DebugEmail.idSet('pubGroupAccountIds', pubGroupAccountIds, 'Campaign '+campaign.Id+' - updateCampaignPublisherGroups():136');
		//remove participations for any accounts that are not in the Id Set
		List<Ad_Network_Campaign_Participation__c> discarded = [SELECT Id, Account__r.Id, Account__r.Name, CreatedDate FROM Ad_Network_Campaign_Participation__c WHERE Ad_Network_Campaign__c = :campaign.Id AND RecordTypeId = :getRecordTypes().get('Publisher Group') AND Account__r.Id NOT IN :pubGroupAccountIds];
		//DebugEmail.adNetworkCampaignParticipationList('Discarded', discarded, 'Campaign '+campaign.Id+' - updateCampaignPublisherGroups():139');
		delete discarded;
		
    	for(Ad_Network_Campaign_Participation__c p : [SELECT Id, Account__r.Id, Account__r.Name 
														FROM Ad_Network_Campaign_Participation__c 
 													   WHERE Ad_Network_Campaign__c = :campaign.Id 
 													   		 AND RecordTypeId = :getRecordTypes().get('Publisher Group')]) {
    		if(pubGroupAccountIds.contains(p.Account__r.Id)) {
    			pubGroupAccountIds.remove(p.Account__r.Id);
    		}
    	}
    	List<Account> newPublisherGroupAccounts = [SELECT Id, Name FROM Account WHERE Id IN :pubGroupAccountIds];
    	//DebugEmail.accountList('New Publisher Groups', newPublisherGroupAccounts, 'Campaign '+campaign.Id+' - updateCampaignPublisherGroups():151');
    	addCampaignPublisherGroups(newPublisherGroupAccounts, campaign);
    }
    
}