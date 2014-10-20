public class AdNetworkCampaignDocument_Extension {

	private ApexPages.StandardController stdCtrl;
	
    //Our collection of the class/wrapper objects cContact 
    private List<SelectOption> documentTypes = new List<SelectOption>();
    
    private AdNetworkCampaignParticipationManager participationManager;
    private String selectedDocumentType = '';
	
	private String fileName;
	private Integer fileSize;
	private Blob fileBody;

    private Id campaignId;
    private Id campaignParticipationId;
    public Ad_Network_Campaign__c campaign {get; private set;}
	public String selectedRelatedEntityType {get; set;}
	public String documentComment {get; set;}
	
	public AdNetworkCampaignDocument_Extension(ApexPages.StandardController sc) {
		this.stdCtrl = sc;
		if(this.documentTypes.size() == 0){
			populateDocumentTypeList();
		}
		this.participationManager = new AdNetworkCampaignParticipationManager();
		
		try {
			if(this.campaignId == null)
				this.campaignId = System.currentPageReference().getParameters().get('cid');
		} catch (Exception e) {
			//do nothing
		}
		if(this.campaignId != null)
			loadCampaign();
		
		//use Advertiser as the default relationship on the new document screen
		if(selectedRelatedEntityType == null)
			selectedRelatedEntityType = 'ADVERTISER';
		
		System.debug('AdNetworkCampaignDocument_Extension constructed');
	}
	
	private void loadCampaign() {
		this.campaign = new Ad_Network_Campaign__c();
		try {
			this.campaign = [SELECT Id, Name, Advertiser__r.Name FROM Ad_Network_Campaign__c WHERE Id =:this.campaignId];
		} catch (Exception e) {
			//do nothing
		}
	}
	
	private List<Schema.PicklistEntry> getDocumentType_PicklistValues() {
		Schema.DescribeFieldResult F = Ad_Network_Campaign_Document__c.Document_Type__c.getDescribe();
		List<Schema.PicklistEntry> plvs = F.getPicklistValues();
		return plvs;
	}
	
	private void populateDocumentTypeList() {
		Integer i;
		List<Schema.PicklistEntry> plvs = getDocumentType_PicklistValues();
		this.documentTypes.clear();
		for(i=0; i < plvs.size(); i++) {
			PicklistEntry pe = plvs.get(i);
			if(pe.isActive())
				this.documentTypes.add(new SelectOption(pe.getValue(),pe.getLabel()));
			if(pe.isActive() && pe.isDefaultValue())
				setSelectedDocumentType(pe.getLabel());
		}
	}
	
	public List<SelectOption> getDocumentTypes() {
		return this.documentTypes;
	}
	
    public String getSelectedDocumentType() {
    	return this.selectedDocumentType;
    }
    
    public void setSelectedDocumentType(String s) {
    	System.debug('setSelectedDocumentType() invoked with argument: '+s);
    	this.selectedDocumentType = s;
    }
    
    public String getCampaignId() {
    	return this.campaignId;
    }
    
    public void setCampaignId(String cid) {
    	this.campaignId = cid;
    	loadCampaign();
    }
    
    public String getCampaignParticipationId() {
    	return this.campaignParticipationId;
    }
    
    public void setCampaignParticipationId(String cpid) {
    	this.campaignParticipationId = cpid;
    }
    
    public List<SelectOption> getPublisherRelationshipOptions() {
    	List<SelectOption> relOpts = new List<SelectOption>();
    	List<Ad_Network_Campaign_Participation__c> publisherGroups = participationManager.getCampaignPublisherGroups(this.campaign);
    	
    	for(Ad_Network_Campaign_Participation__c p : publisherGroups) {
    		relOpts.add(new SelectOption(p.Id,p.Account__r.Name));
    	}
    	return relOpts;
    }
    
    public String getFileName()
	{
		return this.fileName;
	}
	
	public void setFileName(String fileName)
	{
		this.fileName = fileName;
	}
	
	public Blob getFileBody()
	{
		return this.fileBody;
	}
	
	public void setFileBody(Blob fileBody)
	{
		this.fileBody = fileBody;
		if(this.fileBody != null)
			setFileSize(this.fileBody.size());
		else
			setFileSize(0);
	}

	public Integer getFileSize()
	{
		return this.fileSize;
	}

	public void setFileSize(Integer fileSize)
	{
		this.fileSize = fileSize;
	}
	
	public Ad_Network_Campaign_Participation__c getRelatedEntityParticipation() {
		List<Ad_Network_Campaign_Participation__c> participations = new List<Ad_Network_Campaign_Participation__c>();
		if(this.selectedRelatedEntityType == 'ADVERTISER') {
			participations = [SELECT Id FROM Ad_Network_Campaign_Participation__c 
										WHERE Ad_Network_Campaign__c = :this.campaign.Id AND 
											  RecordTypeId = :participationManager.getRecordTypes().get('Advertiser')];
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Advertiser Count: '+participations.size());
			ApexPages.addMessage(msg);
		} else { //publisher group
			participations = [SELECT Id FROM Ad_Network_Campaign_Participation__c 
										WHERE Ad_Network_Campaign__c = :this.campaign.Id AND 
											  RecordTypeId = :participationManager.getRecordTypes().get('Publisher Group') AND
											  Id = :this.campaignParticipationId];
		}
		if(participations.size() == 1)
			return participations.get(0);
		else
			return null;
	}

	private Database.SaveResult insertCampaignDocument(Id participationId)
	{
		Ad_Network_Campaign_Document__c doc = new Ad_Network_Campaign_Document__c(Ad_Network_Campaign_Participation__c = participationId, 
																				  Name = this.fileName, 
																				  Document_Type__c = this.selectedDocumentType,
																				  Comment__c = this.documentComment);
		return Database.insert(doc);
	}
	
	private Database.SaveResult insertAttachment(Id campaignDocumentId)
	{
		Database.SaveResult result;
				
		Attachment att = new Attachment(Body=this.fileBody, Name= this.fileName, ParentId=campaignDocumentId);
				
		result = Database.insert(att);

		fileBody = Blob.valueOf('  ');
		return result;
	}


	public PageReference processUpload()
	{
		PageReference pref = null;
		Ad_Network_Campaign_Participation__c participation;
		Database.SaveResult docResult;
		Database.SaveResult noteResult;
		Database.SaveResult attResult;
		try
		{
			participation = getRelatedEntityParticipation();
			System.debug(participation);
			if(participation == null) {
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not locate Campaign Participation '+ this.selectedRelatedEntityType + ' for ID: '+this.campaignParticipationId+', Campaign ID: '+this.campaignId);
				ApexPages.addMessage(msg);
				pref.getParameters().put('cid', this.campaignId);
				return pref;
			}
			
			docResult = insertCampaignDocument(participation.Id);
			if(docResult == null || !docResult.isSuccess()) {
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create Campaign Document');
				ApexPages.addMessage(msg);
				pref.getParameters().put('cid', this.campaignId);
				return pref;
			}
			
			attResult = insertAttachment(docResult.getId());
			if(attResult == null || !attResult.isSuccess()) {
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create Attachment '+this.fileName);
				ApexPages.addMessage(msg);
				pref.getParameters().put('cid', this.campaignId);
				return pref;
			}
			//ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Created Document with ID: '+docResult.getId()+' and Attachment with ID: '+attResult.getId());
			//ApexPages.addMessage(successMessage);
			pref = new PageReference('/'+getCampaignId());
			pref.getParameters().put('cpid', getCampaignParticipationId());
			pref.getParameters().put('attid', attResult.getId());
		}
		catch (Exception e)
		{
	    	ApexPages.AddMessages(e);
		}
		return pref;
	}
	
	public PageReference cancel() {
		return getReturnPage();
	}
	
	private PageReference getReturnPage() {
		if(this.campaignParticipationId != null)
			return new PageReference('/'+this.campaignParticipationId);
		else if(this.campaignId != null)
			return new PageReference('/'+this.campaignId);
		else
			return null;		
	}
	
	public PageReference WorkflowCheck() {
		PageReference publisherSelection = Page.AdNetworkCampaign_PublisherSelection;
		if(this.participationManager.getCampaignPublishers(this.campaign).size() == 0) {
			publisherSelection.getParameters().put('id', this.campaignId);
			publisherSelection.getParameters().put('msg', '1');
			publisherSelection.getParameters().put('nextStep', 'NewDocument');
			return publisherSelection;
		} else {
			return null;
		}
	}
    
}