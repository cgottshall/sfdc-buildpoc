public with sharing class AdNetworkCampaign_NoteExt {

	private ApexPages.StandardController campaignCtrl;
	private List<Note> noteList;
	private Ad_Network_Campaign__c campaign;
	
	public AdNetworkCampaign_NoteExt(ApexPages.StandardController sc) {
		this.campaignCtrl = sc;
		this.campaign = (Ad_Network_Campaign__c)sc.getRecord();
	}
	
	public List<Note> getNotes() {
		if(noteList == null) {
			List<Note> notes = [SELECT Id,CreatedBy.Name,CreatedDate FROM Note WHERE parentId = :campaign.Id];
			noteList = notes;
		}
		return noteList;
	}
	
	public void setAttachments(List<Note> notes) {
		return;
	}
}