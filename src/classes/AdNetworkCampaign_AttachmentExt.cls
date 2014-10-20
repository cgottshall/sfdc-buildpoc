public with sharing class AdNetworkCampaign_AttachmentExt {
	
	private ApexPages.StandardController campaignCtrl;
	private List<Attachment> attachmentList;
	private Ad_Network_Campaign__c campaign;
	
	public AdNetworkCampaign_AttachmentExt(ApexPages.StandardController sc) {
		this.campaignCtrl = sc;
		this.campaign = (Ad_Network_Campaign__c)sc.getRecord();
	}
	
	public List<Attachment> getAttachments() {
		if(attachmentList == null) {
			List<Attachment> atts = [SELECT Id,Name,CreatedBy.Name FROM Attachment WHERE parentId = :campaign.Id];
			attachmentList = atts;
		}
		return attachmentList;
	}
	
	public void setAttachments(List<Attachment> attachments) {
		return;
	}

}