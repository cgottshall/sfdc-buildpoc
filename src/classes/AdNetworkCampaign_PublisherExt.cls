public with sharing class AdNetworkCampaign_PublisherExt {
	
	private ApexPages.StandardController stdCtrl;
	private AdNetworkCampaignParticipationManager participationManager;
	protected Ad_Network_Campaign__c campaign;
	private Id publisherRecordTypeId;
	public List<CheckboxAccount> publisherList {get; set;}
	public String aMessage {get; set;}
    public String nextStep {get; private set;}
	
	public AdNetworkCampaign_PublisherExt(ApexPages.StandardController sc) {
		this.stdCtrl = sc;
		this.campaign = (Ad_Network_Campaign__c)this.stdCtrl.getRecord();
		this.participationManager = new AdNetworkCampaignParticipationManager();
		System.debug(System.Logginglevel.DEBUG, 'Logging for AdNetworkCampaign_PublisherExt');
		if(System.currentPageReference().getParameters().containsKey('msg'))
			if(System.currentPageReference().getParameters().get('msg') == '1')
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You must add publishing sites to the campaign before attaching any documents'));
		
		if(System.currentPageReference().getParameters().containsKey('nextStep'))
			this.nextStep = System.currentPageReference().getParameters().get('nextStep');
	}
	
	public List<CheckboxAccount> getPublishers() {
		if(this.publisherList == null) {
			Boolean matched = false;
			this.publisherList = new List<CheckboxAccount>();
			//this code is returning all accounts where type = 'ad network publisher site' and not only those that apply to the campaign
			List<Ad_Network_Campaign_Participation__c> participants = participationManager.getCampaignPublishers(this.campaign);
			List<Account> publisherSites = [SELECT Id, Name, parent.Name FROM Account WHERE Type = 'Ad Network Publisher Site' ORDER BY parent.Name ASC];
			System.debug('Participants list contains '+participants.size()+' Accounts');
			System.debug('PublisherSites list contains '+publisherSites.size()+' Accounts');
			for(Account a : publisherSites)
			{
				matched = false;
				for(Ad_Network_Campaign_Participation__c part : participants) {
					System.debug('comparing account '+ a.Name + ' with participant '+ part.Account__r.Name);
					if(part.Account__r.Id == a.Id) {
						this.publisherList.add(new CheckboxAccount(a, true));
						matched = true;
						break;
					}
				}
				if(!matched)
					this.publisherList.add(new CheckboxAccount(a, false));
			}
		}
		generateSelectedMessage(this.publisherList);
		System.debug(System.Logginglevel.DEBUG, 'publisher list has a length of ' + this.publisherList.size());
		return this.publisherList;
	}
	
	public PageReference processSelected(){
		PageReference pr;
        generateSelectedMessage(getPublishers());
        List<Account> selected = getSelectedAccounts(getPublishers());
        System.debug('selected.size(): '+selected.size());
        //DebugEmail.accountList('Selected', selected, 'Campaign: '+this.campaign.Id+' - processSelected():58');
        List<Account> currentParticipants = getParticipatingAccounts();
        System.debug('currentParticipants.size(): '+currentParticipants.size());
       // DebugEmail.accountList('Current Participants', currentParticipants, 'Campaign: '+this.campaign.Id+' - processSelected():61');
        List<Account> removed = findAccountsRemoved(selected, currentParticipants);
        System.debug('removed.size(): '+removed.size());
        //DebugEmail.accountList('Removed', removed, 'Campaign: '+this.campaign.Id+' - processSelected():64');
        List<Account> added = findAccountsAdded(selected, currentParticipants);
        System.debug('added.size(): '+added.size());
        //DebugEmail.accountList('Added', added, 'Campaign: '+this.campaign.Id+' - processSelected():67');
        //delete participations for removed accounts
        removeParticipation(removed);
        //create participations for added accounts
        createParticipation(added);
        if(this.nextStep == 'NewDocument')
        {
        	if(participationManager.getCampaignPublishers(this.campaign).size() == 0) 
        	{
	        	pr = Page.AdNetworkCampaign_PublisherSelection;
	        	pr.getParameters().put('id', this.campaign.Id);
	        	pr.getParameters().put('msg', '1');
				pr.getParameters().put('nextStep', 'NewDocument');
				pr.setRedirect(true);
	        }
	        else 
	        {
	        	pr = Page.AdNetworkCampaign_NewDocument;
	        	pr.getParameters().put('cid', this.campaign.Id);
        	}
        }
        else {
        	pr = stdCtrl.view();
        }
        return pr;
    }
    
    private void createParticipation(List<Account> accounts) {
    	participationManager.addCampaignPublishers(accounts, this.campaign);
    }
    
    private void removeParticipation(List<Account> accounts) {
    	participationManager.removeCampaignPublishers(accounts, this.campaign);
    }
    
    private List<Account> findAccountsRemoved(List<Account> selected, List<Account> existing) {
    	List<Account> removed = new List<Account>();
    	Boolean isSelected = false;
    	for(Account e : existing) {
    		isSelected = false;
    		for(Account s : selected) {
    			if(s.Id == e.Id)
    				isSelected = true;
    		}
    		if(!isSelected)
    			removed.add(e);
    	}
    	return removed;
    }
    
    private List<Account> findAccountsAdded(List<Account> selected, List<Account> existing) {
    	List<Account> added = new List<Account>();
    	Boolean existingAccount = false;
    	for(Account s : selected) {
    		existingAccount = false;
    		for(Account e : existing) {
    			if(s.Id == e.Id)
    				existingAccount = true;
    		}
    		if(!existingAccount)
    			added.add(s);
    	}
    	return added;
    }
    
    private List<Account> getParticipatingAccounts() {
    	List<Ad_Network_Campaign_Participation__c> participants = participationManager.getCampaignPublishers(this.campaign);
    	Set<Id> acctIds = new Set<Id>();
    	for(Ad_Network_Campaign_Participation__c part : participants) {
    		acctIds.add(part.Account__r.Id);
    	}
    	List<Account> publisherAccounts = [SELECT Id, Name, parent.Name FROM Account WHERE Id IN :acctIds ORDER BY parent.Name ASC];
    	return publisherAccounts;
    }
    
    private void generateSelectedMessage(List<CheckboxAccount> publishers) {
    	List<Account> selectedAccounts = getSelectedAccounts(publishers);
    	Integer counter = 0;
    	this.aMessage = '';
    	/*We will cycle through our list of cContacts and will check to see if the 
        selected property is set to true, if it is we add the Contact to the 
        selectedContacts list. */
        
    	for(Account acc : selectedAccounts){
            counter++;
            //system.debug(con);
                if(counter==selectedAccounts.size()) {
                    this.aMessage += acc.Name;
                } else {
                    this.aMessage += acc.Name+', ';
                }
        }
        /* Now we have our list of selected contacts and can perform any type of 
        logic we want, sending emails, updating a field on the Contact, etc */
        System.debug(System.Logginglevel.DEBUG, 'These are the selected Accounts...');
        System.Debug(selectedAccounts);
    }
    
   private List<Account> getSelectedAccounts(List<CheckboxAccount> cbxAccounts) {
    	List<Account> selectedAccounts = new List<Account>();
    	for(CheckboxAccount ca : cbxAccounts){
    		if(ca.selected == true) {
    			selectedAccounts.add(ca.account);
    		}
        }
        return selectedAccounts;
    }
    
}