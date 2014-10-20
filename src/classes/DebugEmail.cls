global class DebugEmail {
	
	public static final String debugTo = 'cgottshall@ibsys.com';
	
	public static void accountList(String listName, List<Account> aList, String tracePoint) {
    	Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    	String sBody = '';
    	for(Account a : aList) {
    		sBody += a.Id+'\t'+a.Name+'\n';
    	}
    	msg.setToAddresses(new String[] {debugTo});
    	msg.setSubject(tracePoint+' - '+listName+' List Contents');
    	msg.setPlainTextBody(sBody);
    	Messaging.sendEmail(new Messaging.Email[] {msg});
    }
    
    public static void adNetworkCampaignParticipationList(String listName, List<Ad_Network_Campaign_Participation__c> pList, String tracePoint) {
    	Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    	String sBody = '';
    	for(Ad_Network_Campaign_Participation__c p : pList) {
    		sBody += p.Account__r.Id+'\t'+p.Account__r.Name+'\t'+p.CreatedDate+'\n';
    	}
    	msg.setToAddresses(new String[] {debugTo});
    	msg.setSubject(tracePoint+' - '+listName+' List Contents');
    	msg.setPlainTextBody(sBody);
    	Messaging.sendEmail(new Messaging.Email[] {msg});
    }
    
    public static void idSet(String setName, Set<Id> pSet, String tracePoint) {
    	Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    	String sBody = '';
    	for(Id i : pSet) {
    		sBody += i+'\n';
    	}
    	msg.setToAddresses(new String[] {debugTo});
    	msg.setSubject(tracePoint+' - '+setName+' Set Contents');
    	msg.setPlainTextBody(sBody);
    	Messaging.sendEmail(new Messaging.Email[] {msg});
    }
}