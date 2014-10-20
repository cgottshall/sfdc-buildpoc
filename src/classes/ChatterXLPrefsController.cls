public class ChatterXLPrefsController {

    public Map<String, Schema.SObjectType> gd {
        get {
            if(gd==null)
                gd = Schema.getGlobalDescribe();  //could be useful to get all objects in the org
            return gd;
        }
        private set;
    }
    
    public List<String> configObjects {
        get {
            Map<String,Chatter_XL_Configurable_Object__c> xlConfigable = Chatter_XL_Configurable_Object__c.getAll();
            List<String> configObjects = new List<String>(xlConfigable.keySet());
            //sort the configObjects list to make sure objects appear alphabetically
            configObjects.sort();
            return configObjects;
        }
        private set;
    }
    
    public ChatterXLPrefsController() {
        System.debug('########## GLOBAL DESCRIBE: '+gd);
    }
    
    public List<SelectOption> objectList {
        get {
            objectList = new List<SelectOption>();
            //only go through the list of configured objects for Chatter XL
            for(String key : configObjects) {
                SObjectType sot = gd.get(key);
                DescribeSObjectResult sodesc = sot.getDescribe();
                objectList.add(new SelectOption(sodesc.getName(),sodesc.getLabel()));
            }
            return objectList;
        }
        private set;
    }
    
    public String selectedObject {
        get {
            if(selectedObject==null)
                selectedObject = '';
            return selectedObject;
        }
        set;
    }
    
    public List<SelectOption> relatedItemsList {
        get {
            if(relatedItemsList==null)
                relatedItemsList = new List<SelectOption>();
            return relatedItemsList;
        }
        private set;
    }
    
    public List<String> selectedRelatedItems {
        get {
            //getUserPrefRelatedItems will return '' if there is nothing found
            if(selectedRelatedItems==null)
                selectedRelatedItems = getUserPrefRelatedItems(selectedObject);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PROPERTY GET: selectedRelatedItems: '+selectedRelatedItems));
            return selectedRelatedItems;
        }
        set {
            selectedRelatedItems = value;
        }
    }
        
    public void getRelatedItems() {
        selectedRelatedItems=null;
        relatedItemsList = new List<SelectOption>();
        List<String> relatedItems = Chatter_XL_Configurable_Object__c.getInstance(selectedObject).Related_Items__c.split(';');
        for(String i : relatedItems) {
            relatedItemsList.add(new SelectOption(i,i));
        }
        return;
    }
    
    public Chatter_XL_Preferences__c userPreferences {
        get {
            userPreferences = Chatter_XL_Preferences__c.getInstance(UserInfo.getUserId());
            System.debug('########## userPreferences: '+userPreferences);
            if(userPreferences==null)
                userPreferences = new Chatter_XL_Preferences__c(setupownerid = UserInfo.getUserId());
            return userPreferences;
        }
        private set;
    }
    
    public List<String> getUserPrefRelatedItems(String objectName) {
        List<String> objectRelatedItems = new List<String>();
        if(objectName!=null && objectName!='') {
            String prefValue = (String)userPreferences.get(objectName+'_Related_Items__c');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Retrieved from setting: userPreferences for '+objectName+': '+prefValue));
            objectRelatedItems = prefValue.split(';');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Parsed from setting: userPreferences for '+objectName+': '+objectRelatedItems));
        }
        return objectRelatedItems;
    }
    
    //return the updated version of the userPreferences property
    public Chatter_XL_Preferences__c setUserPrefRelatedItems(String objectName, List<String> relatedItemList) {
        Chatter_XL_Preferences__c currentPrefs = userPreferences;
        if(objectName!=null && objectName!='')
            currentPrefs.put(objectName+'_Related_Items__c', StringUtils.listJoin(relatedItemList, ';'));
        else {
            System.debug('Invalid/Unknown object name: '+objectName);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid/Unknown object name: '+objectName));
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'setUserPrefRelatedItems('+objectName+', '+relatedItemList+') result: '+currentPrefs));
        return currentPrefs;
    }
    
    public void savePreferences() {
        Chatter_XL_Preferences__c updatedPrefs = setUserPrefRelatedItems(selectedObject, selectedRelatedItems);
        upsert updatedPrefs;
        return;
    }
}