public class TestUtils {
	
	public static Pricebook2 standardPB {
		get {
			if(standardPB==null)
				standardPB = [SELECT Id, Name, IsStandard, IsActive FROM Pricebook2 WHERE IsStandard=true LIMIT 1];
			return standardPB;
		}
		private set;
	}
	
	public static Account createAccount(String nameExt, Boolean doInsert) {
		Account a;
		String name = 'Unit Test Account' + (nameExt==''?'': ' '+nameExt);
		a = new Account(Name=name);
		if(doInsert)
			insert a;
		return a;
	}
	
	public static Opportunity createOppty(String nameExt, Id accountId, Boolean doInsert) {
		Opportunity o;
		String name = 'Unit Test Opportunity' + (nameExt==''?'': ' '+nameExt);
		if(accountId==null)
			accountId = createAccount('', true).Id;
		o = new Opportunity(Name=name, AccountId=accountId, StageName='Prospecting', CloseDate=Date.today().addYears(1));
		if(doInsert)
			insert o;
		return o;
	}
	
	public static Product2 createProduct(String nameExt, Boolean doInsert) {
		Product2 p;
		String name = 'Unit Test Product' + (nameExt==''?'': ' '+nameExt);
		p = new Product2(Name=name);
		if(doInsert) {
			insert p;
			createPricebookEntry(p, standardPB);
		}
		return p;
	}
	
	public static PricebookEntry createPricebookEntry(Product2 prod, Pricebook2 pbk) {
		PricebookEntry pbe;
		if(pbk.IsStandard)
			pbe = new PricebookEntry(Pricebook2Id=pbk.Id, Product2Id=prod.Id, UnitPrice=1.00, IsActive=true);
		else
			pbe = new PricebookEntry(Pricebook2Id=pbk.Id, Product2Id=prod.Id, UnitPrice=1.00, IsActive=true, UseStandardPrice=false);
		System.debug('########## Pricebook Entry: '+pbe);
		System.debug('########## Pricebook: '+pbk);
		insert pbe;
		return pbe;
	}
	
	public static Pricebook2 createPricebook(String nameExt, Boolean isStandard) {
		String name = 'Unit Test Pricebook' + (nameExt==''?'': ' '+nameExt);
		Pricebook2 pb = new Pricebook2(Name=name, IsActive=true);
		insert pb;
		return pb;
	}

}