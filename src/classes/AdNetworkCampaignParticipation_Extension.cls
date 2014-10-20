public class AdNetworkCampaignParticipation_Extension {

	private ApexPages.StandardController stdCtrl;
	private Ad_Network_Campaign_Participation__c ancp;
	
	public AdNetworkCampaignParticipation_Extension(ApexPages.StandardController sc) {
		this.stdCtrl = sc;
		this.ancp = (Ad_Network_Campaign_Participation__c)this.stdCtrl.getRecord();
	}
	
}