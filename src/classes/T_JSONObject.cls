/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class T_JSONObject {

    /* **************************
	 * TEST Methods to achieve required code coverage
	 *   many of these could be improved by using assert() instead of debug()
	 */
	static testmethod void test_tokener_nl() {
		//add a new line by inserting /n 
		JsonObject.JsonTokener tkr = new JsonObject.JsonTokener(
		'quoted string foo"');
		system.debug( 'next string is >'+tkr.nextString('"') );
	} 
	
	static testmethod void test_tokener() { 
		JsonObject.JsonTokener tkr = new JsonObject.JsonTokener('//ff \n{}');
		tkr.nextClean();
		tkr = new JsonObject.JsonTokener('/*fff*/\n{}');
		tkr.nextClean(); 
		tkr = new JsonObject.JsonTokener('#ff*\n{}');
		tkr.nextClean(); 
		tkr = new JsonObject.JsonTokener('/**ff \n{}');
		try { tkr.nextClean(); } catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'Unclosed comment');
		} 
	}
	
	static testmethod void test_parsing() {
		JSONObject jj;
		JsonObject.JsonTokener tkr;
		string simple = '{"translatedText":  "Ciao mondo"  }';
		string bool_simple = '{"responseBoolean"  :   true }';
		string nsimple = '{"responseData"  :   {"translatedText":  "Ciao mondo"  }, "responseDetails": null, "responseStatus": 200 }';
	
		// three methods of constructing an object
		system.debug( jsonobject.instance( bool_simple ) );
		system.debug( new jsonobject( bool_simple ) );	
	 	system.debug( new JSONObject( new JsonObject.JsonTokener(simple) ) );	
		
		tkr = new JsonObject.JsonTokener(nsimple);
		system.debug( tkr.more() );	
		system.debug( tkr.next(1) );	
		system.assert( tkr.next(0) == '' );	
		
		try { tkr.next(10000); 	} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'Ending position out of bounds: 10002');
		} 
		
		system.debug( tkr.next('r') );	
		
		try { tkr.next('z'); } catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'Expected z and instead saw e');
		} 
			
		system.debug( tkr.nextTo('e') );
		system.debug( tkr.skipTo('p') );
		system.debug( tkr.skipTo('z') );
			
		tkr = new JsonObject.JsonTokener(nsimple);
		jj = new JSONObject( tkr);
		 
		system.debug( jj.getData() );
		system.debug( jj.getData().keySet() );
		
		system.debug( 'response status ' + jj.getData().get('responseStatus') );
		system.debug( 'response status ' + jj.get('responseStatus') );
		system.debug( 'response details ' + jj.get('responseDetails') );
		
		system.debug( jj.getString('responseDetails') );
		system.assert( jj.getString('responseDetails') == null ,'expected null ');
		
		system.debug('value '+ jj.getValue('responseData') );
		
		JSONObject.value v = jj.getData().get('responseData');
	 	system.debug( jj.getString('responseDetails') );
		system.debug( 'response data is '+ v.obj);
		 
		//system.assert( v.obj.valu != null);
		system.debug( jj.getData().keySet() );
		 
		
		nsimple = '{"responseString"  :   "foo" }';
	 	tkr = new JsonObject.JsonTokener(nsimple);
		jj = new JSONObject( tkr);
		system.debug( jj.get('responseString') );
		 
		nsimple = '{"responseBoolean"  :   true }';
	 	tkr = new JsonObject.JsonTokener(nsimple);
		jj = new JSONObject( tkr);
		system.debug( jj.getValue('responseBoolean') );
		system.debug( jj.optBoolean('responseBoolean') );
		
		
		try { 
		system.debug ( new JSONObject ( new JsonObject.JSONTokener( 'sdfsdf' ) ) ); 
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'A JSONObject text must begin with {');
		} 
		
		try { 
		system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf": true' ) ) ); 
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'Expected a , or }');
		} 
		
		try { 
		system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf' ) ) ); 
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'Unterminated string');
		} 
	
		try { 
		system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf": 0x009.9 }' ) ) ); 
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'Invalid integer: 009.9');
		} 
	
		
		system.assert ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf": 009 }' ) ).getValue('sdfsdf').num == 9 ); 
		 
		system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"foo": 009 }' ) ).get('foo') == 9 ); 
		
		// array testing
		system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '[1,2,3]' ) )  );
		system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '[1,2,3,]' ) )  );
		system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '[]' ) )  );
		system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '(1,2,3 )' ) )  );
		
		try { 
		system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '(1,2,3 ]' ) )  );
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'Expected a >)<');
		} 
		
		try { 
		system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '1,2,3 ]' ) )  );
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'A JSONArray text must start with [');
		} 
	
		try { 
			system.debug ( jj.get('notfound')  );
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'JSONObject[notfound] not found.');
		} 
		
		system.assert( jj.keys() != null );
		system.assert( jj.length() > 0 ); 
		system.assert( jj.opt('responseBoolean') != null );
		system.assert( jj.has( 'responseBoolean') );
		try { 
			system.debug ( jj.getBoolean('notfound')  );
		} catch(exception ex) {
			system.debug( ' expected >'+ex.getMessage() + '<' );
			system.assert( ex.getMessage() == 'JSONObject[notfound] not found.');
		} 
	}
}