@isTest
private class TestRelationshipBehavior {
	
	static foobar__c foobar;
	static barbaz__c barbaz;

	/*
		This test demonstrates that a cross-object formula field 
		does not trigger an update on the referncing record when the referenced record is updated
	*/
    static testMethod void testTriggerEventsFoobarBarbaz() {
        foobar__c foobarVerify;
        barbaz__c barbazVerify;
        Map<Integer,Integer> timeMap = new Map<Integer,Integer>();
        foobar = new foobar__c(Name='Relationship Foobar', Likelihood__c=67.335, Lucky_Number__c=10.37, Money__c=1000000000.01, Pick_Many__c='Tessera;Pente', Pick_One__c='Gamma', The_Text__c='Some Text Value', Yes_No__c=true);
        insert foobar;
        barbaz = new barbaz__c(Name='Relationship Barbaz', foobar__c=foobar.Id);
        insert barbaz;
        foobarVerify = [SELECT Id, Name, Likelihood__c, Lucky_Number__c, Money__c, Pick_Many__c, Pick_One__c, The_Text__c, Yes_No__c, CreatedDate, LastModifiedDate FROM foobar__c WHERE Id = :foobar.Id];
        barbazVerify = [SELECT Id, Name, foobar__c, foobar_text__c, CreatedDate, LastModifiedDate FROM barbaz__c WHERE Id = :barbaz.Id];
        System.assertEquals(foobar.The_Text__c, barbazVerify.foobar_text__c);
        System.assert(barbazVerify.LastModifiedDate >= foobarVerify.LastModifiedDate);
        //kill some time
        for(Integer i=0; i<1000; i++) {
        	for(Integer j=1; j<10; j++) {
        		if(!timeMap.keySet().contains(j))
        			timeMap.put(j,i);
        	}		
        }
        foobar.The_Text__c = 'A New Value';
        update foobar;
        //reselect the records and compare values
        foobarVerify = [SELECT Id, Name, Likelihood__c, Lucky_Number__c, Money__c, Pick_Many__c, Pick_One__c, The_Text__c, Yes_No__c, CreatedDate, LastModifiedDate FROM foobar__c WHERE Id = :foobar.Id];
        barbazVerify = [SELECT Id, Name, foobar__c, foobar_text__c, CreatedDate, LastModifiedDate FROM barbaz__c WHERE Id = :barbaz.Id];
        System.assertEquals(foobar.The_Text__c, barbazVerify.foobar_text__c);
        //barbaz should not have been updated, so not the last modified date should be prior to the foobar last modified
        System.assert(barbazVerify.LastModifiedDate < foobarVerify.LastModifiedDate, 'barbaz last modified same as foobar last modified? '+(barbazVerify.LastModifiedDate==foobarVerify.LastModifiedDate));
    }
}