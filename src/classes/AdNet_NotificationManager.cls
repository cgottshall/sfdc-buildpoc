public with sharing class AdNet_NotificationManager {
	
	private Ad_Network_Campaign__c campaign;
	
	public AdNet_NotificationManager()
	{
		
	}
	
	public AdNet_NotificationManager(Id campaignId)
	{
		setCampaignId(campaignId);
	}
	
	public void setCampaignId(Id campaignId)
	{
		try
		{
			this.campaign = [SELECT Sales_Assistant__c, NSP__c, Sales_Rep__c FROM Ad_Network_Campaign__c WHERE Id = :campaignId];
		}
		catch (Exception e)
		{
			this.campaign = null;
		}
	}
	
	public List<Id> getDocumentNotificationRecipientIds (String documentType) {
		List<Id> idList = new List<Id>();
		if(this.campaign == null)
			return null;
		
		if(this.campaign.Sales_Assistant__c != null)
			idList.add(this.campaign.Sales_Assistant__c);
		if(this.campaign.NSP__c != null)
			idList.add(this.campaign.NSP__c);
		if(this.campaign.Sales_Rep__c != null)
			idList.add(this.campaign.Sales_Rep__c);
		return idList;
	}

}