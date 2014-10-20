public with sharing class AdNetCampaign_PublisherGroupController {
	
	private ApexPages.StandardController campaignController;
	private AdNetworkCampaignParticipationManager participationManager;
	private Map<String,List<Ad_Network_Campaign_Participation__c>> campaignPublishers;
	
	public Ad_Network_Campaign__c campaign;
	
	public AdNetCampaign_PublisherGroupController() {
		this.participationManager = new AdNetworkCampaignParticipationManager();
		campaignPublishers = this.participationManager.getCampaignPublishersGroupedByParentCompany(this.campaign);
	}
	
	public List<String> getPublisherGroupNames() {
		return new List<String>(campaignPublishers.keySet());
	}
	
	public List<List<Ad_Network_Campaign_Participation__c>> getPublishers() {
		List<List<Ad_Network_Campaign_Participation__c>> allPublishers = new List<List<Ad_Network_Campaign_Participation__c>>();
		for(String groupName : getPublisherGroupNames()) {
			allPublishers.add(this.campaignPublishers.get(groupName));
		}
		return allPublishers;
	}

}