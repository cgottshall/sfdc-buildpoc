public with sharing class OpportunityAttachmentController {

    public static Map<String,Id> recordTypeToIdMap = new Map<String,Id>();

    //method to handle a particular trigger
    public static void handleTrigger_Opportunity_AttachmentRequired(List<Opportunity> triggerNewList, Map<Id,Opportunity> triggerNewMap) {
    	//make sure record types are loaded
    	loadRecordtypeMap();
        //create a set of all opportunity IDs so we can bulk query for attachments
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp : triggerNewList) {
            //we only need to check opps with probability of more than 10%
            if(opp.RecordTypeId == recordTypeToIdMap.get('Strategic Opportunity') && opp.Probability > 10)
                oppIdSet.add(opp.Id);
        }
        
        Map<Id,Integer> oppIdToAttachmentCountMap = getAttachmentCountByOpportunityIds(oppIdSet);
        
        //check each opportunity being saved to validate the attachment count is appropriate for the new probability
        for(Id oppId : oppIdSet) {
            Opportunity opp = triggerNewMap.get(oppId);
            Integer attCount = oppIdToAttachmentCountMap.get(oppId);
            if(attCount == NULL || attCount < 1)
                opp.addError('At least one document must be attached before changing the probability to '+opp.Probability+'%');
        }
    }
    
    public static void loadRecordTypeMap() {
    	for(RecordType rt : [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r WHERE SobjectType = 'Opportunity'])
    		recordTypeToIdMap.put(rt.Name, rt.Id);
    }
    
    /*  This method is only implementable with Spring '10 release
        COUNT(field_name) and GROUP BY were introduced in Spring '10 and will cause exceptions on earlier releases
        This will provide better processing time since it will only return one sObject row per Opportunity ID
        
    public static Map<Id,Integer> getAttachmentCountByOpportunityIds(Set<Id> opportunityIds) {
        //store Opportunity ID and Attachment Count in a map for easy reference
        Map<Id,Integer> oppIdToAttachmentCountMap = new Map<Id,Integer>();
        //execute SOQL to get the attachment count for each opportunity being saved
        SObject[] oppIdAndAttCount = [SELECT COUNT(Id) AttachmentCount, ParentId 
                                                     FROM Attachment WHERE ParentId IN :opportunityIds 
                                                     GROUP BY ParentId ORDER BY ParentId];
        
        for(SObject oppWithCount : oppIdAndAttCount) {
            //put the AttachmentCount value from each item in the query result into the Map keyed by Opportunity Id
            oppIdToAttachmentCountMap.put((Id)oppWithCount.get('ParentId'), (Integer)oppWithCount.get('AttachmentCount'));
        }
        return oppIdToAttachmentCountMap;
    }
    */
    
    public static Map<Id,Integer> getAttachmentCountByOpportunityIds(Set<Id> opportunityIds) {
        //store Opportunity ID and Attachment Count in a map for easy reference
        Map<Id,Integer> oppIdToAttachmentCountMap = new Map<Id,Integer>();
        //execute SOQL to get the attachments for all opportunities being saved
        Attachment[] attachments = [SELECT Id, ParentId FROM Attachment WHERE ParentId IN :opportunityIds];
        //loop over attachments to determine the count for each Opportunity ID
        for(Attachment att : attachments) {
            Integer count = oppIdToAttachmentCountMap.get(att.ParentId);
            //if no count exists yet, this is the first related attachment record
            if(count==null)
                count=1;
            else
                count=count+1;
            //put the count into the Map keyed by Opportunity Id
            oppIdToAttachmentCountMap.put(att.ParentId, count);
        }
        return oppIdToAttachmentCountMap;
    }
    
}