public with sharing class AdNetCampaignDetailComponentController {

	private Ad_Network_Campaign__c activeCampaign;
	
	public Ad_Network_Campaign__c getCampaign() {
		System.debug(this.activeCampaign);
		return this.activeCampaign;
	}
	
	public void setCampaign(Ad_Network_Campaign__c campaign) {
		this.activeCampaign = campaign;
	}

}