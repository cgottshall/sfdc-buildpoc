/**
 * Class        : OpportunityDocumentInboundEmail
 * Developer/Org: Rami Kalayanaraman/Bluewolf
 * Created      : April 27, 2012
 * Developer/Org: Daniel Hughes/Bluewolf
 * Modifieded   : May 13, 2012
 * Objective    : contain methods used by triggers and other code that deals specifically with the Contact object
 */
public with sharing class ContactService
{
    final static String CLASSNAME = '\n\n**** ContactService.@@METHOD()';
    
    static map<Id,Schema.RecordTypeInfo> recordTypes = Contact.getSobjectType().getDescribe().getRecordTypeInfosByID();

    public static list<Contact> setRecordTypeName(list<Contact> contactList)
    {
        for(Contact c : contactList) {
            c.Record_Type_Name__c = recordTypes.get(c.RecordTypeId).getName();
        }
        return contactList;
    }
    
    // returnContact method added by Rami Kalayanaraman/Bluewolf on April 27 2012
    public static map<Id, Contact> returnContact(Set<Id> contactIds)
    {
        map<Id, Contact> returnContact = new map<Id, Contact>();
        list<Contact> contactList = [Select c.Id, c.Account.Name, c.AccountId From Contact c WHERE Id IN : contactIds];
        if(contactList.size() > 0) {
            for(Contact contact : contactList) {
                returnContact.put(contact.id, contact);
            }
        }
        return returnContact;
    }

    //private static list<ContactHistory__c> contactHistories;
    public static void onAfterUpdate(Contact[] oldContacts, Contact[] updatedContacts, map<ID, Contact> contactMap, map<ID, Contact> contactOldMap)
    {
    /*
        final String METHODNAME = CLASSNAME.replace('@@METHOD','OnAfterUpdate');
        system.Debug(LoggingLevel.DEBUG,METHODNAME.replace('**** ','**** Inside ') + '\n\n');
        Set<Id> AccountIdSet = new Set<Id>();
        for(Contact cont1: oldContacts) AccountIdSet.add(cont1.AccountId);
        for(Contact cont2: updatedContacts) AccountIdSet.add(cont2.AccountId);
        map<Id,Account> AccountMap=new map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :AccountIdSet]);
        // Instantiate the Contact history list
        contactHistories = new list<ContactHistory__c>();
        
        // use Custom Setting
        map<String,ContactHistoryTracking__c> chtMap = ContactHistoryTracking__c.getAll();
        
        system.debug(LoggingLevel.DEBUG,METHODNAME+' :: Contact History Tracking ON: '+chtMap + '\n\n');
        
        // Iterate through the updated Contacts
        for(Contact a: updatedContacts){
            
            system.debug(LoggingLevel.DEBUG,METHODNAME+' :: History Tracking on Contact: '+a + '\n\n');
            for(ContactHistoryTracking__c aht : chtMap.values()) {
                system.debug(LoggingLevel.DEBUG,METHODNAME+' :: Processing : '+ aht.Name + '\n\n');
                try {
                    Boolean newBVal, oldBVal;
                    String newSVal, oldSVal;
                    if(aht.Track_As_Data_Type__c.equals('Boolean')) {
                        newBVal = (Boolean)a.get(aht.Name);
                        oldBVal = (Boolean)contactOldMap.get(a.Id).get(aht.Name);
                    } else {
                        if(aht.Name == 'AccountId'){
                            newSVal = (AccountMap.get(a.AccountId)).Name;
                            Id ContactAcctId;
                            String AcctName='';
                            if(contactOldMap.containskey(a.Id)) ContactAcctId = contactOldMap.get(a.Id).AccountId;
                            if(ContactAcctId != null){
                                if(AccountMap.containskey(ContactAcctId)) AcctName = AccountMap.get(ContactAcctId).Name;
                            }
                            oldSVal = AcctName;
                            //oldSVal = (AccountMap.get(contactOldMap.get(a.Id).AccountId)).Name;
                        }else if(aht.Name == 'MailingAddress'){
                            Contact old = contactOldMap.get(a.Id);
                            String oldAddy = old.MailingStreet +','+old.MailingCity +','+old.MailingState +','+old.MailingPostalCode +','+old.MailingCountry;
                            String newAddy = a.MailingStreet +','+a.MailingCity +','+a.MailingState +','+a.MailingPostalCode +','+a.MailingCountry;
                            newSVal = newAddy.replace(',,','').replace(', ,','').replace('null','');
                            oldSVal = oldAddy.replace(',,','').replace(', ,','').replace('null','');
                        }else{
                            newSVal = (String)a.get(aht.Name);
                            oldSVal = (String)contactOldMap.get(a.Id).get(aht.Name);
                        }
                    }
                    system.debug(LoggingLevel.DEBUG,METHODNAME+' :: History Tracking: (old String Val) '+oldSVal+' == (new String Val) ' + newSVal + '? ' + '\n\n');
                    system.debug(LoggingLevel.DEBUG,METHODNAME+' :: History Tracking: (old Bool Val) '+oldBVal+' == (new Bool Val) ' + newBVal + '? ' + '\n\n');

                    if((newSVal != null && oldSVal != null && newSVal != oldSVal) 
                    || (newBVal != null && oldBVal != null && newBVal != oldBVal))
                    {
                        ContactHistory__c contHistory = new ContactHistory__c(
                            Contact__c = a.Id
                            ,Date__c = system.now()
                            ,User__c = UserInfo.getUserId()
                            ,Field__c = aht.Action_Description__c
                        );
                        if(newSVal != null && oldSVal !=null && newSVal != oldSVal){
                            contHistory.Action__c = 'Changed ' + aht.Action_Description__c + ' from ' + oldSVal + ' to ' + newSVal;
                            contHistory.BeforeValue__c = oldSVal;
                            contHistory.AfterValue__c = newSVal;
                        }else if(newBVal != null && oldBVal != null && newBVal != oldBVal){
                            contHistory.Action__c = 'Changed ' + aht.Action_Description__c + ' from ' + boolToString(oldBVal) + ' to ' + boolToString(newBVal);
                            contHistory.BeforeValue__c = boolToString(oldBVal);
                            contHistory.AfterValue__c = boolToString(newBVal);
                        }

                        contactHistories.add(contHistory);
                    }
                } catch (system.SObjectException sobex) {
                    if(sobex.getMessage().contains('Invalid field'))
                        system.debug(LoggingLevel.DEBUG,METHODNAME+' :: Contact History Tracking CONFIG EXCEPTION: '+aht.Name+' is not a valid field for Contact' + '\n\n');
                }
            }
        }
        
        if(BW_Utility.ValidateList(contactHistories)){
            
            try{
                // Insert the list of ContactHistory__c records in the database
                insert contactHistories;
            }catch(DMLException dE){
                ErrorLogUtils.logError(dE.getMessage(), CLASSNAME.replace('\n\n**** ','').replace('.@@METHOD()',''), METHODNAME.replace('\n\n**** ',''));
            }       
        }
    */        
    }
    
    private static String boolToString(Boolean b) {
        if(b) return 'Yes';
        else return 'No';
    }

}