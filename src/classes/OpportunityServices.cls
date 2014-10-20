/*
 * Class        : OpportunityServices
 * Developer/Org: Rami Kalayanaraman/Bluewolf
 * Created      : April 27, 2011
 * Objective    : Services class for opportunity. 
*/
public with sharing class OpportunityServices {
	public static String STAGE_CLOSED_LOST = 'Closed Lost';
	public static String STAGE_DTQ = 'DTQ';
	public static String PROPOSAL_EXPIRED = 'Proposal Expired';
    public static void upsertOpportunities(list<Opportunity> updatedOpps)
    {
    	Set<Id> contactIds = new Set<Id>();
    	map<Id, Contact> contactMatch = new map<Id, Contact>();
    	
    	for(Opportunity opp : updatedOpps) {
    		contactIds.add(opp.Broker__c);
    	}
    
    	if(contactIds.size() > 0)
    		contactMatch = ContactService.returnContact(contactIds);
    		
    	for(Opportunity incomingOpp : updatedOpps) {
			if(incomingOpp.Brokerage__c == null)
			{
				if(contactMatch.containsKey(incomingOpp.Broker__c)){
					Id brokerageId = contactMatch.get(incomingOpp.Broker__c).AccountId;
					if(brokerageId <> null)
						incomingOpp.Brokerage__c = brokerageId;
				}
			}
    	}
  	}
  	
  	// ScheduledOpportunityClose calls this method
  	// Assumptions are made outside of this method that the segment is National and the Max Expiration is prior to today
  	public static void closeLoseOpps(list<Opportunity> oppList){
  		if (oppList == null || oppList.isEmpty()) return;
  		
  		for (Opportunity opp: oppList){
  			opp.StageName = STAGE_CLOSED_LOST;
  			opp.CloseDate = Date.TODAY();
  			opp.Primary_Closed_Lost_Reason__c = PROPOSAL_EXPIRED;
  		}
  		
  		upsert oppList;
  	}
  	
  	public static void updateOpportunityProductsProbability(list<Opportunity> updatedOpps, map<Id,Opportunity> updatedOppsMapOld){
  		Set<Id> OpportunityIdSet = new Set<Id>();
  		
  		// get the IDs of the Opportunities where the Stage has just changed to "Closed Lost" or "DTQ"
  		for(Opportunity opp : updatedOpps){
  			Opportunity oldVersion = updatedOppsMapOld.get(opp.Id);
  			if(opp.StageName != oldVersion.StageName && (opp.StageName == STAGE_CLOSED_LOST || opp.StageName == STAGE_DTQ)){
  				// the stage has changed to 'Closed Lost' or 'Closed Lost' when it previously was another value
  				OpportunityIdSet.add(opp.Id);
  			}
  		}
  		if(OpportunityIdSet.size() > 0){
  			map<Id,list<OpportunityLineItem>> OpptyProductMap = OpportunityLineItemServices.returnOpportunityIdToOpportunityLineItemListMap(OpportunityIdSet);
  			list<OpportunityLineItem> OpptyLineItemsToUpdate = new list<OpportunityLineItem>();

  			// update the Probability__c value for all of the OpportunityLineItem
  			for(Id oppId: OpptyProductMap.keyset()){
  				list<OpportunityLineItem> WIP_OpptyLineItems = OpptyProductMap.get(oppId);
  				for(OpportunityLineItem OLI: WIP_OpptyLineItems) OLI.Probability__c = 0;
  				OpptyLineItemsToUpdate.addAll(WIP_OpptyLineItems);
  			}
  			
  			// commit the changes
  			update OpptyLineItemsToUpdate;
  		}
  	}
  	
  	public static void createProducts(Map<Id,Set<String>> opptyProdNameMap) {
  		//use the EB pricebook - this will need refactored when RP sales comes on board
		Pricebook2 ebPricebook;
  		//get a set of Opportunity IDs
		Set<Id> opptyIds = opptyProdNameMap.keySet();
		Set<String> prodNames = new Set<String>();
		//make sure all product names are treated with upper case characters
		for(Set<String> stSet : opptyProdNameMap.values())
			for(String st : stSet) {
				prodNames.add(st.toUpperCase());
				stSet.remove(st);
				stSet.add(st.toUpperCase());  //replace all values with upper-cased versions
			}
  		try {
  			ebPricebook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'EB Sales Pricebook' LIMIT 1];
  		} catch (QueryException qe) {
  			ErrorLogUtils.logError('EB Sales Pricebook could not be located', 'OpportunityServices', 'createProducts');
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'EB Sales Pricebook could not be located'));
  			return;
  		}
  		 
  		//find all pricebook entries for the products with names in the product list, that are in the pricebooks of opportunities
  		Map<String,PricebookEntry> prodPbeMap = new Map<String,PricebookEntry>();
  		
  		for(PricebookEntry pbe : [SELECT Id, Product2Id, Product2.Name, Product2.EB_Sales_Product_Family__c, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id = :ebPricebook.Id AND Product2.Name IN :prodNames]) {
  			prodPbeMap.put(pbe.Product2.Name.toUpperCase(), pbe);
  		}
  		System.debug('########## prodPbeMap: '+prodPbeMap);
  		
  		Map<Id,Opportunity> existing = new Map<Id,Opportunity>([SELECT Id, Name, (SELECT Id, PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.Name FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :opptyProdNameMap.keySet()]);
  		//go through the opptyProdMap, get the pricebook entries from the opportunity's pricebook in pbMap
  		for(Id oppId : opptyProdNameMap.keySet()) {
  			//get existing opportunity with lines
  			OpportunityLineItem[] existingOppLines = existing.get(oppId).OpportunityLineItems;
  			//what are the existing product names being used on the opportunity?
  			Set<String> existingProdNames = new Set<String>();
  			for(OpportunityLineItem oli : existingOppLines)
  				existingProdNames.add(oli.PricebookEntry.Product2.Name.toUpperCase());
  			Set<String> remainderSet = opptyProdNameMap.get(oppId);
  			System.debug('########## Requested Set of products: '+remainderSet);
  			System.debug('########## existing products: '+existingProdNames);
  			remainderSet.removeAll(existingProdNames);
  			System.debug('########## For Opportunity ID '+oppId+' adding Products: '+remainderSet);
  			opptyProdNameMap.put(oppId, remainderSet);
  		}
  		
  		List<OpportunityLineItem> newOppLines = new List<OpportunityLineItem>();
  		//go through each opportunity id and create an OpportunityLineItem for each product named in the related set of strings
  		for(Id oppId : opptyProdNameMap.keySet()) {
  			Set<String> prodToAdd = opptyProdNameMap.get(oppId);
  			for(String pname : prodToAdd) {
  				PricebookEntry pbe = prodPbeMap.get(pname.toUpperCase());
  				if(pbe!=null)
  					newOppLines.add( new OpportunityLineItem(OpportunityId=oppId, PricebookEntryId=pbe.Id, Quantity=1, TotalPrice=0.00));
  				else
  					ErrorLogUtils.logError('Attempted to create Opportunity Line Item for an invalid product: '+pname, 'OpportunityServices', 'createProducts');
  			}
  		}
  		if(newOppLines.size()>0) {
  			try {
  				Database.Saveresult[] saveResults = Database.insert(newOppLines, true);
  				for(Database.Saveresult sr : saveResults) {
  					if(!sr.isSuccess()) {
  						for(Database.Error err : sr.getErrors())
	  						ErrorLogUtils.logError('Error while saving Opportunity Line Item: '+err, 'OpportunityServices', 'createProducts');
  					}
  				}
  			} catch (Exception ex) {
  				ErrorLogUtils.logError('Exception while saving Opportunity Line Items: '+ex.getMessage(), 'OpportunityServices', 'createProducts');
  			}
  		}
  	}
  	
  	public static void setOwnerUserEPIN(List<Opportunity> opptyList) {
  		Set<Id> ownerIds = new Set<Id>();
		for(Opportunity opp : opptyList)
			ownerIds.add(opp.OwnerId);
		Map<Id,User> ownerUserMap = new Map<Id,User>([SELECT Id, User_EPIN__c FROM User WHERE Id IN :ownerIds]);
		//An OwnerId must relate to a User record, so I'm not null checking here because I'm guaranteed a non-null map value for each ID
		for(Opportunity opp : opptyList)
			opp.Owner_User_EPIN__c = ownerUserMap.get(opp.OwnerId).User_EPIN__c;
  	}
}