public with sharing class AdNetParticipation_DocsAndNotes {
	
	private Id participationId;
	private Ad_Network_Campaign_Participation__c participation;
	private String pageBlockTitle;
	private List<Ad_Network_Campaign_Document__c> documentList;
	private List<Note> noteList;
	private Id activeDocumentId = null;
	
	public AdNetParticipation_DocsAndNotes() {
		documentList = new List<Ad_Network_Campaign_Document__c>();
		noteList = new List<Note>();
		pageBlockTitle = 'Documents and Notes';
	}
	
	public void setParticipationId(String pid) {
		this.participationId = pid;
		try {
			this.participation = [SELECT Id, Account__r.Id, Account__r.Name, Ad_Network_Campaign__r.Id, Ad_Network_Campaign__r.Name FROM Ad_Network_Campaign_Participation__c WHERE Id =: this.participationId];
		} catch (Exception e) {
			this.participation = null;
		}
	}
	
	public Id getParticipationId() {
		return this.participationId;
	}
	
	public void setPageBlockTitle(String title) {
		this.pageBlockTitle = title;
	}
	
	public String getPageBlockTitle() {
		return this.pageBlockTitle;
	}
	
	public List<Ad_Network_Campaign_Document__c> getDocuments() {
		if(this.documentList.size() == 0 && this.participationId != null) {
			loadDocuments();
		}
		return this.documentList;
	}
	
	public List<Note> getNotes() {
		if(this.noteList.size() == 0 && this.participationId != null) {
			loadNotes();
		}
		return this.noteList;
	}
	
	
	private void loadDocuments() {
		this.documentList = [SELECT Id, Name, Document_Type__c, Comment__c, CreatedBy.Name, (SELECT Id, Name FROM Attachments LIMIT 1)
										 FROM Ad_Network_Campaign_Document__c
									    WHERE Ad_Network_Campaign_Participation__r.Id = :this.participationId];
	}
	
	private void loadNotes() {
		this.noteList = [SELECT Id, Title, Body, CreatedBy.Name, CreatedDate
										 FROM Note
									    WHERE parentId = :this.participationId];
	}
	
	public PageReference NewNote() {
		PageReference pageRef = Page.AdNetCampaignParticipation_Note;
		pageRef.getParameters().put('id', this.participationId);
		pageRef.getParameters().put('retURL', '%2F'+this.participationId);
		return pageRef;
	}
	
	public Id getActiveDocumentId() {
		return this.activeDocumentId;
	}
	
	public void setActiveDocumentId(String id) {
		try {
			this.activeDocumentId = (Id)id;
		} catch (Exception e) {
			this.activeDocumentId = null;
		}
	}
	
	public PageReference deleteDocument() {
		System.debug('active document ID is '+this.activeDocumentId);
		PageReference pref = null;
		try {
			Ad_Network_Campaign_Document__c doc = [SELECT Id,Name,Document_Type__c,CreatedBy.Name 
													FROM Ad_Network_Campaign_Document__c
												WHERE Id = :this.activeDocumentId LIMIT 1];
			delete doc;
			loadDocuments();
		} catch (Exception e) {
			ApexPages.Message exMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Bad Document ID: '+ this.activeDocumentId);
			ApexPages.addMessage(exMsg);
		}
		return pref;
	}
	
	public PageReference NewDocument() {
		PageReference pref = Page.AdNetworkCampaign_NewDocument;
		pref.getParameters().put('cid', this.participation.Ad_Network_Campaign__r.Id);
		pref.getParameters().put('cpid', this.participationId);
		pref.setRedirect(true);
		return pref;
	}
	
	public PageReference NotifyClient() {
		PageReference pref = Page.AdNetworkCampaign_Message;
		pref.getParameters().put('id', this.participation.Ad_Network_Campaign__r.Id);
		pref.getParameters().put('docid', this.activeDocumentId);
		pref.setRedirect(true);
		return pref;
	}

}