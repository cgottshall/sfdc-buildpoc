public with sharing class MapItem {
	
	public Double lat {get;	set;}
	public Double lon {get;	set;}
	public String description {get;	set;}
	public Id objectId {get; set;}
	public String objectName {get; set;}
	public String objectType {get; set;}
	public String street {get; set;}
	public String city {get; set;}
	public String stateProv {get; set;}
	public String postalCode {get; set;}
	public String country {get; set;}
	public String phone {get; set;}
	
	public MapItem(Account a) {
		objectType = 'Account';
		lat = a.lat__c;
		lon = a.lon__c;
		description = a.Description;
		objectId = a.Id;
		objectName = a.Name;
		if(a.Which_Address__c == 'Shipping') {
			street = a.ShippingStreet;
			city = a.ShippingCity;
			stateProv = a.ShippingState;
			postalCode = a.ShippingPostalCode;
			country = a.ShippingCountry;
		} else if(a.Which_Address__c == 'Billing') {
			street = a.BillingStreet;
			city = a.BillingCity;
			stateProv = a.BillingState;
			postalCode = a.BillingPostalCode;
			country = a.BillingCountry;
		}
		phone = a.Phone;
	}
	
	public MapItem(Contact c) {
		objectType = 'Contact';
		lat = c.lat__c;
		lon = c.lon__c;
		description = c.Description;
		objectId = c.Id;
		objectName = c.Name;
		if(c.Which_Address__c == 'Mailing') {
			street = c.MailingStreet;
			city = c.MailingCity;
			stateProv = c.MailingState;
			postalCode = c.MailingPostalCode;
			country = c.MailingCountry;
		} else if (c.Which_Address__c == 'Other') {
			street = c.OtherStreet;
			city = c.OtherCity;
			stateProv = c.OtherState;
			postalCode = c.OtherPostalCode;
			country = c.OtherCountry;
		}
		phone = c.Phone;
	}
	
	public MapItem() {
		objectType = '';
		lat = 0;
		lon = 0;
		description = '';
		objectId = '';
		objectName = '';
		street = '';
		city = '';
		stateProv = '';
		postalCode = '';
		country = '';
		phone = '';
	}
	
	public String toJson() {
		String json = '{';
		json += 'objectType: "'+objectType+'",';
		json += 'lat: "'+lat+'",';
		json += 'lon: "'+lon+'",';
		json += 'description: "'+description+'",';
		json += 'objectId: "'+objectId+'",';
		json += 'objectName: "'+objectName+'",';
		json += 'street: "'+street+'",';
		json += 'city: "'+city+'",';
		json += 'stateProv: "'+stateProv+'",';
		json += 'postalCode: "'+postalCode+'",';
		json += 'country: "'+country+'",';
		json += 'phone: "'+phone+'"';
		json += '}';
		return json;
	}

}