global class SobjectHelper {

	public static Set<Id> getObjectIdsFromObjectList(List<Sobject> objectList) {
		Set<Id> idSet = new Set<Id>();
		for(Sobject so : objectList) {
			idSet.add(so.Id);
		}
		return idSet;
	}
	
	static  testMethod void testGetObjectIdsFromObjectList() {
		List<Account> objList = new List<Account>();
		List<Id> idList = new List<Id>();
		Account a = new Account(Name='Testing Account');
		insert a;
		objList.add(a);
		idList.add(a.Id);
		Test.startTest();
		Set<Id> idSet = getObjectIdsFromObjectList(objList);
		System.assert(idSet.containsAll(idList));
		Test.stopTest();
	}
}