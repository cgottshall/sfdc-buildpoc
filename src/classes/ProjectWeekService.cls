public with sharing class ProjectWeekService {

	public static List<Project_Week__c> createProjectWeeks(Id projectId, Date startDate, Date endDate) {
		List<Project_Week__c> weeks = new List<Project_Week__c>();
		//find the start of the week that the start date is in
		startDate = startDate.toStartOfWeek();
		Date weekDate = startDate;
		while(weekDate < endDate) {
			weeks.add(new Project_Week__c(Project__c = projectId, Start_Of_Week__c = weekDate));
			weekDate = weekDate.addDays(7);
		}
		return weeks;
	}
}