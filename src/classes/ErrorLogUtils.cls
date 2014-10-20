// Author @ Chris O Davies
public without sharing class ErrorLogUtils {
	
	// Method responsible for creating a new Error Log
	public static void logError(String message,String classname, String method) {
		
		// Create a new error log record
		Error_Log__c error = new Error_log__c(
			Class_Name__c = classname,
        	Error_Message__c = message,
        	Method_Name__c = method
        );
        
        // Insert the error log into the database
		insert error;
    }
    
}