public with sharing class AdNetworkCampaign_Message {
	
	private ApexPages.StandardController ctrl;
	public String documentId {get; private set;}
	
	public AdNetworkCampaign_Message(ApexPages.StandardController sc) {
		this.ctrl = sc;
		this.documentId = ApexPages.currentPage().getParameters().get('docid');
	}

}