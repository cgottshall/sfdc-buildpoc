public with sharing class ProjectTeamMemberService {
	
	public static List<Project_Team_Member__c> setName(List<Project_Team_Member__c> theList) {
		Set<Id> contactIds = new Set<Id>();
		Map<Id, Contact> contactMap;
		for(Project_Team_Member__c ptm : theList) {
			contactIds.add(ptm.Team_Member__c);
		}
		contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Id IN :contactIds]);
		
		for(Project_Team_Member__c ptm : theList) {
			ptm.Name = contactMap.get(ptm.Team_Member__c).FirstName + ' ' + contactMap.get(ptm.Team_Member__c).LastName;
		}
		return theList;
	}

}