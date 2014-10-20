/* controller example for google map component */

public class GoogleMapController {
    // or whatever you need to return a valid key to the component
    public string forcekey {
    	get { return geoApiKey.forcekey; }
    }
    
    Account[] accounts = new Account[]{};
    
    public Account[] init() { 
     	if (accounts.size() > 0 ) return accounts;
    	accounts = [select name, description, 
            lat__c, lon__c ,
            website, phone, 
            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
            ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
            Which_Address__c
                from account 
                where geocode_status__c = 'G_GEO_SUCCESS'
                limit 14];
        return accounts;
    }
    
    public string geoDataTable {
    	get { 
	    	init();
	        GoogleViz gv = new GoogleViz();
	        gv.cols = new list<GoogleViz.col> { 
	            new GoogleViz.Col('A','Lat','number'),
	            new GoogleViz.Col('B','Lon','number'),
	            new GoogleViz.Col('C','Name','string') 
	        };
	        for (Account a: accounts) {
	        	googleViz.row rr = new googleViz.row();
	        	rr.cells.add(new GoogleViz.cell(a.lat__c)); 
	            rr.cells.add(new GoogleViz.cell(a.lon__c)); 
	            String descript = a.name +  a.billingCity + ', ' + a.billingstate;
	            if (a.website != null) {
	            	descript += a.website;
	            }
	        	rr.cells.add(new GoogleViz.cell(descript)); 
	        	gv.addRow(rr); 
	        }
	        return gv.toJsonString(); 
	    }
    }
    
    public List<MapItem> mapItemData {
    	get {
    		init();
    		List<MapItem> mapItemList = new List<MapItem>();
    		for(Account a : accounts) {
    			mapItemList.add(new MapItem(a));
    		}
    		return mapItemList;
    	}
    }
    
    public string sayHello() {
    	return 'Hello';
    }
}