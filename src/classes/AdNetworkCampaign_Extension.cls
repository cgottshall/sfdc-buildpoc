public with sharing class AdNetworkCampaign_Extension {
	
	private ApexPages.StandardController campaignController;
	private Ad_Network_Campaign__c campaign;
	private AdNetworkCampaignParticipationManager participationManager;
	private List<Ad_Network_Campaign_Participation__c> advertiserList;
	
	public List<Ad_Network_Campaign_Document__c> advertiserDocumentList {get; private set;}
	public List<Note> advertiserNoteList {get; private set;}
	
	public AdNetworkCampaign_Extension(ApexPages.StandardController sc) {
		this.campaignController = sc;
		this.campaign = (Ad_Network_Campaign__c)this.campaignController.getRecord();
		this.participationManager = new AdNetworkCampaignParticipationManager();
	}
	
	public Ad_Network_Campaign__c getCampaign() {
		return this.campaign;
	}

	public Ad_Network_Campaign_Participation__c getAdvertiserParticipation() {
		return this.participationManager.getCampaignAdvertiser(this.campaign);			
	}
	
	public List<Ad_Network_Campaign_Participation__c> getPublishers() {
		List<Ad_Network_Campaign_Participation__c> allPublishers = this.participationManager.getCampaignPublishers(this.campaign);
		return allPublishers;
	}
	
	public List<Ad_Network_Campaign_Participation__c> getPublisherGroups() {
		List<Ad_Network_Campaign_Participation__c> publisherGroups = this.participationManager.getCampaignPublisherGroups(this.campaign);
		return publisherGroups;
	}
	
	public PageReference NewDocument() {
		PageReference pref = Page.AdNetworkCampaign_NewDocument;
		pref.getParameters().put('cid', this.campaign.Id);
		return pref;
	}
	
	public PageReference SendAMessage() {
		PageReference pref = Page.AdNetworkCampaign_Message;
		pref.getParameters().put('id', this.campaign.Id);
		return pref;
	}
	
}