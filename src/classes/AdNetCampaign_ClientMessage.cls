public with sharing class AdNetCampaign_ClientMessage {
	
	private Map<String,EmailTemplate> messageTemplate;
	private Ad_Network_Campaign_Document__c document;
	private Id campaignId;
	private Id documentId;
	private Id accountId;
	private List<CheckboxContact> contactList;
	
	//for the outgoing message
	private String messageBody;
	private String subject;
	
	public AdNetCampaign_ClientMessage() {
		this.messageTemplate = new Map<String,EmailTemplate>();
		EmailTemplate temp;
		
		try {
			temp = [SELECT Id, Body, TemplateType FROM EmailTemplate WHERE DeveloperName = 'Ad_Network_New_RFP_Notification'];
			this.messageTemplate.put('RFP',temp);
		} catch (Exception e) {
			//don't add anything to the Map if you can't find an EmailTemplate
		}
		try {
			temp = [SELECT Id, Body, TemplateType FROM EmailTemplate WHERE DeveloperName = 'Ad_Network_New_DA_Notification'];
			this.messageTemplate.put('DA',temp);
		} catch (Exception e) {
			//don't add anything to the Map if you can't find an EmailTemplate
		}
		try {
			temp = [SELECT Id, Body, TemplateType FROM EmailTemplate WHERE DeveloperName = 'Ad_Network_New_IO_Notification'];
			this.messageTemplate.put('IO',temp);
		} catch (Exception e) {
			//don't add anything to the Map if you can't find an EmailTemplate
		}
	}
	
	public String getMessageBody() {
		Ad_Network_Campaign_Document__c document = getDocument();
		EmailTemplate t;
		String body = '';
		try {
			t = this.messageTemplate.get(document.Document_Type__c);
			body = t.Body;
			return body;
		} catch (Exception e) {
			return 'There is no template for the document type '+document.Document_Type__c;
		}
	}
	
	public void setMessageBody(String msgBody) {
		this.messageBody = msgBody;
	}
	
	private Ad_Network_Campaign_Document__c getDocument() {
		if(this.document == null) {
			try {
				this.document = [SELECT Id, Name, Document_Type__c, Comment__c, Ad_Network_Campaign_Participation__r.Account__c FROM Ad_Network_Campaign_Document__c Where Id =:this.documentId];
				this.accountId = document.Ad_Network_Campaign_Participation__r.Account__c;
			} catch (Exception e) {
				this.document = null;
			}
		}
		return this.document;
	}
	
	public List<CheckboxContact> getContacts() {
		if(this.contactList == null) {
			this.contactList = new List<CheckboxContact>();
			for(Contact c : [SELECT Id, Name, Email FROM Contact WHERE Account.Id= :getAccountId()])
			{
				this.contactList.add(new CheckboxContact(c));
			}
		}
		return this.contactList;
	}
	
	public void setContacts(List<CheckboxContact> clist) {
		this.contactList = clist;
		System.debug('Invoked setContacts() with list of size '+clist.size());
	}
	
	private Id getAccountId() {
		getDocument();
		return this.accountId;
	}
	
	public Id getDocumentId() {
		return this.documentId;
	}
	
	public void setDocumentId(String docId) {
		this.documentId = docId;
	}
	
	public Id getCampaignId() {
		return this.campaignId;
	}
	
	public void setCampaignId(String cid) {
		this.campaignId = (Id)cid;
	}
	
	public String getSubject() {
		return 'Test';
	}
	
	public void setSubject(String s) {
		this.subject = s;
	}
	
	public PageReference Send() {
		List<String> toList = new List<String>();
		Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
		for(CheckboxContact cc : getContacts()) {
			if(cc.selected) {
				toList.add(cc.contact.Email);
			}
		}
		toList.add('chris.gottshall@gmail.com');
		msg.setToAddresses(toList);
		msg.setSubject('Client Message '+this.subject);
		msg.setPlainTextBody(this.messageBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg});
		PageReference pref = new PageReference('/'+this.campaignId);
		return pref;
	}
	
	public PageReference Cancel() {
		PageReference pref = new PageReference('/'+this.campaignId);
		pref.setRedirect(true);
		return pref;
	}
	
}