public with sharing class ProjectService {
	
	//indicates whether or not projectWeeks are currently being recalculated
	public static Boolean projectWeekUpdateRunning = false;
	
	public static List<Project__c> updateProjectWeeks(List<Project__c> projects) {
		ProjectService.projectWeekUpdateRunning = true;
		Set<Id> projectIds = new Set<Id>();
		Map<Id, Project__c> projectMap;
		Boolean deleteError = false;
		for(Project__c p : projects) {
			projectIds.add(p.Id);
		}
		projectMap = new Map<Id, Project__c>([SELECT Id, (SELECT Id FROM Project_Weeks__r) FROM Project__c WHERE Id IN :projectIds]);
		//delete all existing weeks
		List<Project_Week__c> deleteWeeks = new List<Project_Week__c>();
		for(Project__c p : projects) {
			deleteWeeks.addAll(p.Project_Weeks__r);
		}
		try {
			Database.delete(deleteWeeks);
		} catch (Exception ex) {
			deleteError = true;
			System.debug('########## Error deleting project weeks: '+deleteWeeks);
		}
		if(!deleteError) {
			List<Project_Week__c> newWeeks = new List<Project_Week__c>();
			for(Project__c p : projects) {
				if(p.Start_Date__c != null && p.End_Date__c != null) {
					newWeeks.addAll(ProjectWeekService.createProjectWeeks(p.Id, p.Start_Date__c, p.End_Date__c));
				}
			}
			try {
				Database.insert(newWeeks);
			} catch (Exception ex) {
				System.debug('########## Error creating project weeks: '+newWeeks);
				projects.get(0).addError('Error creating project weeks: '+ex.getMessage());
			}
		}
		ProjectService.projectWeekUpdateRunning = false;
		return projects;
	}

}