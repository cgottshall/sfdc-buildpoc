public with sharing class CheckboxContact {

	public Contact contact {get; set;}
	public Boolean selected {get; set;}
	
	
	public CheckboxContact(Contact c){
	    contact = c;
	    selected = false;
	}
	public CheckboxContact(Contact c, Boolean s) {
		contact = c;
	    selected = s;
	}
}