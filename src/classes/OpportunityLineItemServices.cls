public with sharing class OpportunityLineItemServices {
    public static list<OpportunityLineItem> returnOpportunityLineItems(Id OpportunityId)
    {
        return [Select o.PricebookEntry.Name, o.Members__c, o.Monthly_Premium__c, o.Probability__c, o.TotalPrice From OpportunityLineItem o Where o.OpportunityId = :OpportunityId];   
    }
    public static map<Id,list<OpportunityLineItem>> returnOpportunityIdToOpportunityLineItemListMap(Set<Id> OpportunityIds)
    {
        map<Id,list<OpportunityLineItem>> OpportunityIdToOpportunityLineItemListMap = new map<Id,list<OpportunityLineItem>>();
        
    	for(OpportunityLineItem OLI:[Select o.OpportunityId, o.PricebookEntry.Name, o.Id, o.Probability__c From OpportunityLineItem o Where o.OpportunityId IN :OpportunityIds ORDER BY o.OpportunityId])
    	{
    		if(OpportunityIdToOpportunityLineItemListMap.containskey(OLI.OpportunityId)){
    			OpportunityIdToOpportunityLineItemListMap.get(OLI.OpportunityId).add(OLI);
    		}else{
    			list<OpportunityLineItem> l = new list<OpportunityLineItem>();
    			l.add(OLI);
    			OpportunityIdToOpportunityLineItemListMap.put(OLI.OpportunityId,l);
    		}
    	}
    	return OpportunityIdToOpportunityLineItemListMap;
    }
}