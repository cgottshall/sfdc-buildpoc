@isTest
private class T_GoogleMapController {

    static testmethod void t1() {
		GoogleMapController c = new GoogleMapController();
		c.init(); 
		system.assert( c.geoDataTable != null );
	}
	
}