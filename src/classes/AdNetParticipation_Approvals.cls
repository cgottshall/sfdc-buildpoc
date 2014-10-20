//Controller class for the AdNetParticipationApprovals Visualforce component

public with sharing class AdNetParticipation_Approvals {
	
	public Id participationId {get; set;}

	private Ad_Network_Campaign_Participation__c participation;
	
	public AdNetParticipation_Approvals() {	}
	
	public Ad_Network_Campaign_Participation__c getParticipation() {
		if(this.participation == null) {
			this.participation = [SELECT Id, Name, RecordType.Name, Account_Approval__c, Advertiser_Approval__c, Billing_Approval__c FROM Ad_Network_Campaign_Participation__c WHERE Id = :this.participationId];
		}
		return this.participation;
	}
	
	public PageReference AccountApproved() {
		this.participation.Account_Approval__c = 'Approved';
		update this.participation;
		return null;
	}
	public PageReference AccountRejected() {
		this.participation.Account_Approval__c = 'Rejected';
		update this.participation;
		return null;
	}
	public PageReference AdvertiserApproved() {
		this.participation.Advertiser_Approval__c = 'Approved';
		update this.participation;
		return null;
	}
	public PageReference AdvertiserRejected() {
		this.participation.Advertiser_Approval__c = 'Rejected';
		update this.participation;
		return null;
	}
	public PageReference BillingApproved() {
		this.participation.Billing_Approval__c = 'Approved';
		update this.participation;
		return null;
	}
	public PageReference BillingRejected() {
		this.participation.Billing_Approval__c = 'Rejected';
		update this.participation;
		return null;
	}
}