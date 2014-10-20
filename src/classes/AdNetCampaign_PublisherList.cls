//controller class for the component AdNetCampaign_PublisherList

public with sharing class AdNetCampaign_PublisherList {

	public Id campaignId {get; set;}
	
	private List<PublisherGroupWrapper> publisherGroupList;
	
	public AdNetCampaign_PublisherList() {
		
	}
	
	public List<PublisherGroupWrapper> getPublisherGroups() {
		if(this.publisherGroupList == null) {
			this.publisherGroupList = new List<PublisherGroupWrapper>();
			for(Ad_Network_Campaign_Participation__c pg : [SELECT Id, Name, Account__r.Id, Account__r.Name, Account_Approval__c, Advertiser_Approval__c, Billing_Approval__c 
															 FROM Ad_Network_Campaign_Participation__c 
															WHERE Ad_Network_Campaign__c=:this.campaignId AND RecordType.Name = 'Publisher Group'])
			{
				PublisherGroupWrapper pubGroup = new PublisherGroupWrapper(pg, [SELECT Id, Name, Account__r.Id, Account__r.Name, Account_Approval__c, Advertiser_Approval__c, Billing_Approval__c 
															 					  FROM Ad_Network_Campaign_Participation__c WHERE Ad_Network_Campaign__c=:this.campaignId AND RecordType.Name = 'Publisher' AND Account__r.parent.Id = :pg.Account__r.Id]);
				this.publisherGroupList.add(pubGroup);
			}
		}
		System.debug('list size: '+publisherGroupList.size());
		return this.publisherGroupList;
	}
	
	public PageReference ChangePublishers() {
		PageReference pref = Page.AdNetworkCampaign_PublisherSelection;
		pref.getParameters().put('id', this.campaignId);
		return pref;
	}
}