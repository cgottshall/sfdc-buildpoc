public class CheckboxAccount {

	public Account account {get; set;}
	public Boolean selected {get; set;}
    
	/*This is the contructor method. When we create a new cContact object we pass a 
	Contact that is set to the con property. We also set the selected value to false*/
	public CheckboxAccount(Account a){
	    account = a;
	    selected = false;
	}
	public CheckboxAccount(Account a, Boolean s) {
		account = a;
	    selected = s;
	}
}