public with sharing class AdNetworkTask {
	
	private ApexPages.StandardController taskController;
	private Task t;
	
	public String mode {	get{
								if(mode == null) 
									return 'edit'; 
								else 
									return mode;
								}
							set;
						}
	public String ptsQueue {get; set;}
	
	public AdNetworkTask(ApexPages.StandardController sc) {
		this.taskController = sc;
		t = (Task)sc.getRecord();
	}
	
	
}