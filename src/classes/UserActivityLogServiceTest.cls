@isTest(SeeAllData=true)
private class UserActivityLogServiceTest {
    
    static Profile testProfile, adminProfile;
    static User existingUser, adminUser, newUser;

    static void setup() {
        testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        existingUser = createUser('');
        insert existingUser;
        adminUser = createUser('admin');
        adminUser.ProfileId = adminProfile.Id;
        insert adminUser;
    }
    
    static User createUser(String uniqueId) {
        if(uniqueId==null || uniqueId=='')
            uniqueId = System.currentTimeMillis().format().replaceAll(',','').left(8);
        return new User(ProfileId=testProfile.Id, FederationIdentifier='User'+uniqueId, FirstName='Tester', LastName='NewUser',
                        Username='user'+uniqueId+'@tester.com', Email='new@tester.com', Alias=uniqueId, CommunityNickname=uniqueId, 
                        TimeZoneSidKey='America/Chicago', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');
    }
    
    static List<User_Activity_Log__c> getLogsSince(Datetime dtFilter, Id whoFilter) {
        List<User_Activity_Log__c> logList;
        try {
            logList = [SELECT Id, Name, Timing__c, Event__c, Profile__c, User_ID__c, Federation_ID__c 
                         FROM User_Activity_Log__c WHERE CreatedDate >= :dtFilter AND CreatedById = :whoFilter 
                         ORDER BY CreatedDate ASC LIMIT 1000];
        } catch (QueryException qe) {
            logList = new List<User_Activity_Log__c>(); //return an empty list
            System.debug('########## NO RECORDS: User_Activity_Log__c');
        }
        return logList;
    }

    static testMethod void testServiceLoggingBeforeInsert() {
        setup();
        Datetime startTest;
        List<User_Activity_Log__c> startingLogs, endingLogs;
        List<User> userList;
        List<String> results;

        //make sure no logs have been created yet        
        startTest = Datetime.now();
        startingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(0, startingLogs.size());
        
        Test.startTest();
        System.runAs(adminUser) {
            userList = new List<User>();
            newUser = createUser('');
            userList.add(newUser);
            results = UserActivityLogService.logBeforeInsert(userList);
            System.debug('########## results: '+results);
        }
        Test.stopTest();
        
        endingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(1, endingLogs.size());
        System.assertEquals('Before', endingLogs.get(0).Timing__c);
        System.assertEquals('Insert', endingLogs.get(0).Event__c);
        System.assertEquals(testProfile.Id, endingLogs.get(0).Profile__c);
        System.assertEquals(null, endingLogs.get(0).User_ID__c);
        System.assertEquals(newUser.FederationIdentifier, endingLogs.get(0).Federation_ID__c);
    }
    
    static testMethod void testServiceLoggingBeforeUpdate() {
        setup();
        Datetime startTest;
        List<User_Activity_Log__c> startingLogs, endingLogs;
        List<User> userList;
        List<String> results;

        //make sure no logs have been created yet        
        startTest = Datetime.now();
        startingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(0, startingLogs.size());
        
        Test.startTest();
        System.runAs(adminUser) {
            userList = new List<User>();
            userList.add(existingUser);
            results = UserActivityLogService.logBeforeUpdate(userList);
            System.debug('########## results: '+results);
        }
        Test.stopTest();
        
        endingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(1, endingLogs.size());
        System.assertEquals('Before', endingLogs.get(0).Timing__c);
        System.assertEquals('Update', endingLogs.get(0).Event__c);
        System.assertEquals(testProfile.Id, endingLogs.get(0).Profile__c);
        System.assertEquals(existingUser.Id, endingLogs.get(0).User_ID__c);
        System.assertEquals(existingUser.FederationIdentifier, endingLogs.get(0).Federation_ID__c);
    }
    
    static testMethod void testServiceLoggingAfterInsert() {
        setup();
        Datetime startTest;
        List<User_Activity_Log__c> startingLogs, endingLogs;
        List<User> userList;
        List<String> results;

        //make sure no logs have been created yet        
        startTest = Datetime.now();
        startingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(0, startingLogs.size());
        
        Test.startTest();
        System.runAs(adminUser) {
            userList = new List<User>();
            newUser = createUser('');
            userList.add(newUser);
            results = UserActivityLogService.logAfterInsert(userList);
            System.debug('########## results: '+results);
        }
        Test.stopTest();
        
        endingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(1, endingLogs.size());
        System.assertEquals('After', endingLogs.get(0).Timing__c);
        System.assertEquals('Insert', endingLogs.get(0).Event__c);
        System.assertEquals(testProfile.Id, endingLogs.get(0).Profile__c);
        System.assertEquals(null, endingLogs.get(0).User_ID__c); //only null due to this simulation, actually inserting would produce a non-null value
        System.assertEquals(newUser.FederationIdentifier, endingLogs.get(0).Federation_ID__c);
    }
    
    private static testMethod void testServiceLoggingAfterUpdate() {
        setup();
        Datetime startTest;
        List<User_Activity_Log__c> startingLogs, endingLogs;
        List<User> userList;
        List<String> results;

        //make sure no logs have been created yet        
        startTest = Datetime.now();
        startingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(0, startingLogs.size());
        
        Test.startTest();
        System.runAs(adminUser) {
            userList = new List<User>();
            userList.add(existingUser);
            results = UserActivityLogService.logAfterUpdate(userList);
            System.debug('########## results: '+results);
        }
        Test.stopTest();
        
        endingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(1, endingLogs.size());
        System.assertEquals('After', endingLogs.get(0).Timing__c);
        System.assertEquals('Update', endingLogs.get(0).Event__c);
        System.assertEquals(testProfile.Id, endingLogs.get(0).Profile__c);
        System.assertEquals(existingUser.Id, endingLogs.get(0).User_ID__c);
        System.assertEquals(existingUser.FederationIdentifier, endingLogs.get(0).Federation_ID__c);
    }
    
    private static testMethod void testTriggerUserInsert() {
        setup();
        Datetime startTest;
        List<User_Activity_Log__c> startingLogs, endingLogs;
        List<User> userList;
        List<Database.SaveResult> results;

        //make sure no logs have been created yet        
        startTest = Datetime.now();
        startingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(0, startingLogs.size());
        
        Test.startTest();
        System.runAs(adminUser) {
            userList = new List<User>();
            newUser = createUser('insert');
            userList.add(newUser);
            results = Database.insert(userList);
            System.debug('########## results: '+results);
        }
        Test.stopTest();
        
        endingLogs = getLogsSince(startTest, adminUser.Id);
        //we expect there to be both a before insert and after insert log
        System.assertEquals(2, endingLogs.size());
        //logs are ordered by created date so first should be before insert, after insert second
        User_Activity_Log__c biLog = endingLogs.get(0);
        User_Activity_Log__c aiLog = endingLogs.get(1);
        
        System.assertEquals('Before', biLog.Timing__c);
        System.assertEquals('Insert', biLog.Event__c);
        System.assertEquals(testProfile.Id, biLog.Profile__c);
        System.assertEquals(null, biLog.User_ID__c);
        System.assertEquals(newUser.FederationIdentifier, biLog.Federation_ID__c);
        
        System.assertEquals('After', aiLog.Timing__c);
        System.assertEquals('Insert', aiLog.Event__c);
        System.assertEquals(testProfile.Id, aiLog.Profile__c);
        System.assertNotEquals(null, aiLog.User_ID__c); //an ID should exist now
        System.assertEquals(newUser.FederationIdentifier, aiLog.Federation_ID__c);
    }
    
    private static testMethod void testTriggerUserUpdate() {
        setup();
        Datetime startTest;
        List<User_Activity_Log__c> startingLogs, endingLogs;
        List<User> userList;
        List<Database.SaveResult> results;

        //make sure no logs have been created yet        
        startTest = Datetime.now();
        startingLogs = getLogsSince(startTest, adminUser.Id);
        System.assertEquals(0, startingLogs.size());
        
        Test.startTest();
        System.runAs(adminUser) {
            userList = new List<User>();
            userList.add(existingUser);
            results = Database.update(userList);
            System.debug('########## results: '+results);
        }
        Test.stopTest();
        
        endingLogs = getLogsSince(startTest, adminUser.Id);
        //we expect there to be both a before insert and after insert log
        System.assertEquals(2, endingLogs.size());
        //logs are ordered by created date so first should be before insert, after insert second
        User_Activity_Log__c buLog = endingLogs.get(0);
        User_Activity_Log__c auLog = endingLogs.get(1);
        
        System.assertEquals('Before', buLog.Timing__c);
        System.assertEquals('Update', buLog.Event__c);
        System.assertEquals(testProfile.Id, buLog.Profile__c);
        System.assertEquals(existingUser.Id, buLog.User_ID__c);
        System.assertEquals(existingUser.FederationIdentifier, buLog.Federation_ID__c);
        
        System.assertEquals('After', auLog.Timing__c);
        System.assertEquals('Update', auLog.Event__c);
        System.assertEquals(testProfile.Id, auLog.Profile__c);
        System.assertEquals(existingUser.Id, auLog.User_ID__c); //an ID should exist now
        System.assertEquals(existingUser.FederationIdentifier, auLog.Federation_ID__c);
    }
}