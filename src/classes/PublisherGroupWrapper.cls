/* this is a wrapper class because I wanted to use Map<String, Ad_Network_Campaign_Participation__c> in a visual force page
   Instead, I am now returning a List<PublisherGroupWrapper> which contains the contents I wanted in my Map
*/
public with sharing class PublisherGroupWrapper {
	
	public Ad_Network_Campaign_Participation__c publisherGroup {get; set;}
	public List<Ad_Network_Campaign_Participation__c> siteList {get; set;}
	
	public PublisherGroupWrapper(){
		this.publisherGroup = null;
		this.siteList = new List<Ad_Network_Campaign_Participation__c>();
	}
	public PublisherGroupWrapper(Ad_Network_Campaign_Participation__c pGroup, List<Ad_Network_Campaign_Participation__c> pList){
		this.publisherGroup = pGroup;
		this.siteList = pList;
	}

}