public without sharing class UserActivityLogService {
    
    public static List<String> logBeforeInsert(List<User> users) {
        List<String> logIds = new List<String>();
        List<User_Activity_Log__c> uaLogs = new List<User_Activity_Log__c>();
        for(User u : users)
            uaLogs.add(new User_Activity_Log__c(Timing__c='Before', Event__c='Insert', User_ID__c=u.Id, Profile__c=u.ProfileId, Federation_ID__c=u.FederationIdentifier));
        try {
            Database.SaveResult[] results = Database.insert(uaLogs);
            for(Database.SaveResult sr : results)
                logIds.add((String)sr.Id);
        } catch (Exception ex) {
            logIds.add('EXCEPTION: '+ex.getMessage());
        }
        return logIds;
    }
    
    public static List<String> logBeforeUpdate(List<User> users) {
        List<String> logIds = new List<String>();
        List<User_Activity_Log__c> uaLogs = new List<User_Activity_Log__c>();
        for(User u : users)
            uaLogs.add(new User_Activity_Log__c(Timing__c='Before', Event__c='Update', User_ID__c=u.Id, Profile__c=u.ProfileId, Federation_ID__c=u.FederationIdentifier));
        try {
            Database.SaveResult[] results = Database.insert(uaLogs);
            for(Database.SaveResult sr : results)
                logIds.add((String)sr.Id);
        } catch (Exception ex) {
            logIds.add('EXCEPTION: '+ex.getMessage());
        }
        return logIds;
    }
    
    public static List<String> logAfterInsert(List<User> users) {
        List<String> logIds = new List<String>();
        List<User_Activity_Log__c> uaLogs = new List<User_Activity_Log__c>();
        for(User u : users)
            uaLogs.add(new User_Activity_Log__c(Timing__c='After', Event__c='Insert', User_ID__c=u.Id, Profile__c=u.ProfileId, Federation_ID__c=u.FederationIdentifier));
        try {
            Database.SaveResult[] results = Database.insert(uaLogs);
            for(Database.SaveResult sr : results)
                logIds.add((String)sr.Id);
        } catch (Exception ex) {
            logIds.add('EXCEPTION: '+ex.getMessage());
        }
        return logIds;
    }
    
    public static List<String> logAfterUpdate(List<User> users) {
        List<String> logIds = new List<String>();
        List<User_Activity_Log__c> uaLogs = new List<User_Activity_Log__c>();
        for(User u : users)
            uaLogs.add(new User_Activity_Log__c(Timing__c='After', Event__c='Update', User_ID__c=u.Id, Profile__c=u.ProfileId, Federation_ID__c=u.FederationIdentifier));
        try {
            Database.SaveResult[] results = Database.insert(uaLogs);
            for(Database.SaveResult sr : results)
                logIds.add((String)sr.Id);
        } catch (Exception ex) {
            logIds.add('EXCEPTION: '+ex.getMessage());
        }
        return logIds;
    }
    
}