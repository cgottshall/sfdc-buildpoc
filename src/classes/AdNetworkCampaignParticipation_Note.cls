public with sharing class AdNetworkCampaignParticipation_Note {
	
	private String retUrl;
	private ApexPages.StandardController participationController;
	private Ad_Network_Campaign_Participation__c participation;
	
	public String title {get; set;}
	public String body {get; set;}
	public Boolean isPrivate {get; set;}
	
	public AdNetworkCampaignParticipation_Note(ApexPages.StandardController sc) {
		this.participationController = sc;
		this.retUrl = ApexPages.currentPage().getParameters().get('retUrl');
		this.participation = (Ad_Network_Campaign_Participation__c)this.participationController.getRecord();
	}
	
	public PageReference save() {
		Note n = new Note(Title=this.title, Body=this.body, parentId=this.participation.Id);
		insert n;
		return returnPage();
	}
	
	public PageReference cancel() {
		return returnPage();
	}
	
	private PageReference returnPage() {
		return new PageReference(this.retUrl);
	}
}