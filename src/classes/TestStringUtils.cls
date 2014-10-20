@isTest
private class TestStringUtils {
	
	static Set<String> stSet = new Set<String>(new String[]{'Do','Re','Mi','Fa','So','La','Ti'});
	static List<String> stList = new String[]{'Do','Re','Mi','Fa','So','Fa','Mi','Re','Do'};

    static testMethod void testListJoinDefaultSeparator() {
        String joinedList = StringUtils.listJoin(stList);
        List<String> splitList = joinedList.split(StringUtils.defaultDelimiter); //split on the default
        System.debug('########## splitList:'+splitList);
        //every list item should match
        for(Integer i = 0; i < splitList.size(); i++)
        	System.assertEquals(stList.get(i), splitList.get(i));
    }
    
    static testMethod void testListJoinCustomSeparator() {
    	String customDelimiter = '|';
    	String splitPattern = '[|]';
        String joinedList = StringUtils.listJoin(stList, customDelimiter);
        List<String> splitList = joinedList.split(splitPattern); //split on the customDelimiter
        System.debug('########## splitList'+splitList);
        //should get just as many list items from the split as were in the original set
        System.assertEquals(stList.size(), splitList.size());
        //every list item should match
        for(Integer i = 0; i < splitList.size(); i++)
        	System.assertEquals(stList.get(i), splitList.get(i));
    }
    
    static testMethod void testSetJoinDefaultSeparator() {
        String joinedSet = StringUtils.setJoin(stSet);
        List<String> splitList = joinedSet.split(StringUtils.defaultDelimiter); //split on the customDelimiter
        System.debug('########## splitList'+splitList);
        //should get just as many list items from the split as were in the original set
        System.assertEquals(stSet.size(), splitList.size());
        //every item in the list should be in the set
        for(String s : splitList)
        	System.assert(stSet.contains(s));
    }
    
    static testMethod void testSetJoinCustomSeparator() {
        String customDelimiter = '$';
        String splitPattern = '[$]';
        String joinedSet = StringUtils.setJoin(stSet, customDelimiter);
        List<String> splitList = joinedSet.split(splitPattern); //split on the customDelimiter
        System.debug('########## splitList'+splitList);
        //should get just as many list items from the split as were in the original set
        System.assertEquals(stSet.size(), splitList.size());
        //every item in the list should be in the set
        for(String s : splitList)
        	System.assert(stSet.contains(s));
    }
}