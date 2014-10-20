@isTest
private class TestChatterXLPrefsController {

    static testMethod void testConstructor() {
        ChatterXLPrefsController c = new ChatterXLPrefsController();
        System.assertNotEquals(null, c.userPreferences);
        System.assertEquals(Chatter_XL_Configurable_Object__c.getAll().size(), c.objectList.size());
        System.assertEquals('', c.selectedObject);
        System.assertEquals(0, c.relatedItemsList.size());
        System.assertEquals(0, c.selectedRelatedItems.size());
        System.assert(c.getUserPrefRelatedItems('Account').size() > 0);
        System.assert(c.getUserPrefRelatedItems('Contact').size() > 0);
        System.assert(c.getUserPrefRelatedItems('Case').size() > 0);
        System.assert(c.getUserPrefRelatedItems('Opportunity').size() > 0);
    }
    
    static testMethod void testGetRelatedItems() {
        ChatterXLPrefsController c = new ChatterXLPrefsController();
        for(String oType : c.configObjects) {
            c.selectedObject = oType;
            c.getRelatedItems();
            //there should be at least one related item configured for each object type in the customn setting
            System.assertNotEquals(0, Chatter_XL_Configurable_Object__c.getInstance(oType).Related_Items__c.split(';').size());
            //ensure the list of related items that is created by the controller is the same size as the list
            System.assertEquals(Chatter_XL_Configurable_Object__c.getInstance(oType).Related_Items__c.split(';').size(), c.relatedItemsList.size());
            //ensure that there is a default selected value for the current object
            System.assert(c.selectedRelatedItems.size() > 0);
        }
        
    }

}