@isTest
private class TestApex {
	
	static final Integer MAX_LIST_SIZE = 1000000;
	
	static testMethod void testListSizeLimit() {
		List<Integer> testList = new List<Integer>();
		for(Integer i = 0; i < MAX_LIST_SIZE; i++) {
			testList.add(i);
		}
		System.assertEquals(MAX_LIST_SIZE, testList.size());
		try {
			testList.add(1);
			System.assert(false, 'List Size should not work: '+ testList.size());
		} catch(Exception ex) {
			System.assert(true);
			System.debug('########## testListSizeLimit() caused exception: '+ex.getMessage());
		}
	}

}