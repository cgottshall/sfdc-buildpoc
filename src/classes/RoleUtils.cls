/*
	Adapted from Jeff Douglas' RoleUtils blog post
*/
public with sharing class RoleUtils {

	//retrieve a set of all user IDs that are in a role at or below the role named by roleName
	public static Set<ID> getUsersInRoleAndSubordinates(String roleName) {
		try {
			// get requested roleId by name
			Id roleId = [select Id from UserRole where Name = :roleName].Id;
			// get all of the roles underneath the user
			Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
			// get all of the ids for the users in those roles
			Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds OR UserRoleId = :roleId]);
			// return the ids as a set so you can do what you want with them
			return users.keySet();
		} catch (Exception ex) {
			System.debug('########## getRoleSubordinateUsers() Exception: '+ex);
			return null;
		}
	}
	
	//Depth-first search of all subordinate UserRole IDs
	private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
		
		Set<ID> currentRoleIds = new Set<ID>();
		
		// get all of the roles underneath the passed roles
		for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null])
			currentRoleIds.add(userRole.Id);
		 
		// go fetch some more rolls!
		if(currentRoleIds.size() > 0)
			currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
		return currentRoleIds;
	}

}