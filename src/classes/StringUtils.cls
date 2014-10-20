/*
	This class provides utility methods for strings and collections of strings.
*/
global class StringUtils {
	
	public static String defaultDelimiter = ':';
	
	/*
		This methods joins together a list of strings with the specified delimiter
	*/
	global static String listJoin(List<String> theList, String delimiter) {
		System.debug('#########'+theList);
		if(theList==null)
			return '';
		if(delimiter==null || delimiter == '')
			delimiter = defaultDelimiter;
		System.debug('#########'+delimiter);
		String resultString = '';
		//loop through the list of string and add the delimiter before each string, 
		//as long as the resultString isn't currently empty
		for(String s : theList) {
            if(resultString.length()>1)
                resultString += delimiter;
            resultString += s;
        }
        System.debug('#########'+resultString);
        return resultString;
	}
	
	/* This does the same thing as the other listJoin method, but accepts just a list */
	global static String listJoin(List<String> theList) {
        return listJoin(theList, null);
	}
	
	/*
		This methods joins together a set of strings with the specified delimiter
	*/
	global static String setJoin(Set<String> theSet, String delimiter) {
		System.debug('#########'+theSet);
		if(theSet==null)
			return '';
		if(delimiter==null || delimiter == '')
			delimiter = defaultDelimiter;
		System.debug('#########'+delimiter);
		String resultString = '';
		//loop through the list of string and add the delimiter before each string, 
		//as long as the resultString isn't currently empty
		for(String s : theSet) {
            if(resultString.length()>1)
                resultString += delimiter;
            resultString += s;
        }
        System.debug('#########'+resultString);
        return resultString;
	}
	
	/* This does the same thing as the other setJoin method, but accepts just a set */
	global static String setJoin(Set<String> theSet) {
        return setJoin(theSet, null);
	}
}