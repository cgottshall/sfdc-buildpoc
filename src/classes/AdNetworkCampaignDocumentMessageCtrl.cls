public with sharing class AdNetworkCampaignDocumentMessageCtrl {

	public Id documentId {get; set;}
	public String documentAction {get; set;}
	private Ad_Network_Campaign_Document__c document;
	private Ad_Network_Campaign_Participation__c participation;
	private Ad_Network_Campaign__c campaign;
	
	public Ad_Network_Campaign_Document__c getDocument() {
		if(this.document == null) {
			loadDocument();
		}
		return this.document;
	}
	
	private void loadDocument() {
		this.document = [SELECT Id, Name, Ad_Network_Campaign_Participation__c, Document_Type__c, Comment__c, CreatedBy.Name, CreatedDate FROM Ad_Network_Campaign_Document__c WHERE Id = :this.documentId];
	}
	
	public Ad_Network_Campaign_Participation__c getParticipation() {
		if(this.participation == null) {
			loadParticipation();
		}
		return this.participation;
	}
	
	private void loadParticipation() {
		getDocument();
		this.participation = [SELECT Id, Name, Account__r.Id, Account__r.Name, Ad_Network_Campaign__c FROM Ad_Network_Campaign_Participation__c WHERE Id = :this.document.Ad_Network_Campaign_Participation__c];
	}
	
	public Ad_Network_Campaign__c getCampaign() {
		if(this.campaign == null)
			loadCampaign();
		return this.campaign;
	}
	
	private void loadCampaign() {
		getParticipation();
		this.campaign = [SELECT Id, Name, Advertiser__r.Id, Advertiser__r.Name FROM Ad_Network_Campaign__c WHERE Id = :this.participation.Ad_Network_Campaign__c];
	}
	
	public String getAction() {
		if(this.documentAction == 'add') {
			return 'added';
		}
		
		return '';
	}
}