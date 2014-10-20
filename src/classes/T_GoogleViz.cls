@isTest
private class T_GoogleViz {

	public static  testmethod void test_unparsing2() { 
		JSONObject.value va = new JSONObject.value('str'); 
		system.assert( va.valueToString()  == '"str"' );
		
		system.assert( 
			GoogleViz.dateToJavaScript(Date.newInstance(2008,3,30)) == 'new Date(2008, 3, 30, 0, 0, 0)', 
			' dateToJavaScript  failed' );
	 
	 	GoogleViz v = new GoogleViz(); 
	 	GoogleViz.Col cl = new GoogleViz.Col(); 
	 	cl.id = 'A';  
	 	cl.label = 'NEW A';
	 	cl.ctype = 't';
	 	system.debug(cl);
	 	system.debug(cl.toJsonString());
	 	string col_str = '{id: "A", label: "NEW A", type: "t"}';
	 	system.assert( col_str == cl.toJsonString() );
	 	
	 	system.debug( jsonobject.instance( col_str ) );
	}

	public static  testmethod void test_junparsing() { 
		GoogleViz.try_json( '{id:"A"}');
	 	GoogleViz.try_json( '{label:"NEW A",id:"A"}');
	 	GoogleViz.try_json( '{type:"t",label:"NEW A",id:"A"}');
	 	GoogleViz.try_json( '{type:12}');
	 	GoogleViz.try_json( '{type:true}');
	 	GoogleViz.try_json( '{type:false}');
	 	GoogleViz.try_json( '{a:[{v: "c"}, {v: 3}]}');
	}

	public static  testmethod void test_col() { 
	 	GoogleViz.Col cl = new GoogleViz.Col('A'); 
	 	cl = new GoogleViz.Col('A','New A'); 
	 	cl.ctype = 't';
	 	system.debug(cl.toJsonString());
	 	cl = new GoogleViz.Col('A','New A','t'); 
	 	system.debug(cl.toJsonString());
		
		GoogleViz gv = new GoogleViz(); 
		gv.cols = new list<GoogleViz.col> { new GoogleViz.Col('A','New A','t'),
			 new GoogleViz.Col('B','B label','n') };
		
		GoogleViz.row rr = new GoogleViz.row();
		
		GoogleViz.cell ctmp = new GoogleViz.cell('a');
		
		rr.cells.add ( ctmp );		
		rr.cells.add ( new GoogleViz.cell( 3, '3ish' ) ); // {v: 3.0, f: '3'}
		
		// {v: new Date(2008, 3, 30, 0, 31, 26), f: '4/30/08 12:31 AM'}
		rr.cells.add ( new GoogleViz.cell( Date.newInstance(2008,3,30), '4/30/08 12:31 AM' ) );
		
		gv.rowCollection.add( rr );
		system.debug (gv.toJSONString() ); 
		
		string assert = '{cols: [{id: "A", label: "New A", type: "t"},{id: "B", label: "B label", type: "n"}], rows: [[{v: "a"},{f: "3ish",v: 3},{v: new Date(2008, 3, 30, 0, 0, 0), f: "4/30/08 12:31 AM"}]]}';
		system.assert( assert == gv.toJSONString(), assert + ' \n'+  gv.toJSONString());
	}

	public static  testmethod void rowTest() { 
	 	GoogleViz.row r = new GoogleViz.row();
	 	GoogleViz.cell cc = new GoogleViz.cell(); 
	 	Opportunity[] al = [ select id,amount,closedate from opportunity limit 1];  
	 	r = new GoogleViz.row( new list<GoogleViz.cell> {cc} );
	}
}