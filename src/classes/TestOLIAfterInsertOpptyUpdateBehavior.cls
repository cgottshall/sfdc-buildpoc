@isTest(SeeAllData=true)
private class TestOLIAfterInsertOpptyUpdateBehavior {
	
	static Account acct;
	static Opportunity oppty;
	static Product2 prod;
	static Pricebook2 pricebook;
	static PricebookEntry pbe;
	static Map<String,Integer> countMap = new Map<String,Integer>();
	
	static void setup() {
		acct = TestUtils.createAccount('OLI Testing', true);
		oppty = TestUtils.createOppty('OLI Testing', acct.Id, true);
		pricebook = TestUtils.createPricebook('Custom', false);
		prod = TestUtils.createProduct('Dummy Widget', true);
		pbe = TestUtils.createPricebookEntry(prod, pricebook);
		
		countMap.put('foo',0);
		countMap.put('bar',0);
		countMap.put('baz',0);
	}
	
	static testMethod void proveRandomOrderOfTriggers() {
		setup();
		
		for(Integer i=0; i < 5; i++) {
			testFooBarBazValues();
		}
		System.debug('########## countMap: '+countMap);
		System.assertEquals(3, countMap.keySet().size());
		for(String key : countMap.keySet()) {
			System.assert(countMap.get(key) < 5);  //can't get this to prove out - triggers appear to run in a particular order no matter how many times we run them
		}
	}

	/*
	test that Opportunity fields Foo__c, Bar__c, and Baz__c are set to 'foo', 'bar', and 'baz' respectively after
	creating a line item of each
	*/
    static void testFooBarBazValues() {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(String val : new String[]{'foo','bar','baz'}) {
        	oliList.add(new OpportunityLineItem(OpportunityId=oppty.Id, PricebookEntryId=pbe.Id, UnitPrice=1.00, Quantity=1, FooBarBaz__c=val));
        }
        
        insert oliList;

        Opportunity postOpp = [SELECT Id, Name, Foo__c, Bar__c, Baz__c, FooBarBaz__c, (SELECT Id, PricebookEntryId, UnitPrice, Quantity, FooBarBaz__c FROM OpportunityLineItems) FROM Opportunity WHERE Id = :oppty.Id];
        //make sure one of each 'foo', 'bar', and 'baz' exists
        System.assertEquals(0, Math.mod(postOpp.OpportunityLineItems.size(), oliList.size())); //list size is a multiple of oliList.size()
        for(OpportunityLineItem oli : oliList) {
        	Boolean matched = false;
        	for(OpportunityLineItem postOli : postOpp.OpportunityLineItems)
        		if(oli.FooBarBaz__c.equals(postOli.FooBarBaz__c)) {
        			matched = true;
        			break;
        		}
        	System.assert(matched, 'Did not find matching FooBarBaz value: '+oli.FooBarBaz__c);
        }
        //we know that all three olis were inserted, one with each distinct foobarbaz value
        /*
        System.assertEquals('foo', postOpp.Foo__c);
        System.assertEquals('bar', postOpp.Bar__c);
        System.assertEquals('baz', postOpp.Baz__c);
        */
        countMap.put(postOpp.FooBarBaz__c, countMap.get(postOpp.FooBarBaz__c)+1);
        System.debug('########## FooBarBaz: '+postOpp.FooBarBaz__c);
    }
}