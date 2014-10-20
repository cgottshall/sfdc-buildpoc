global with sharing class AutocompleteTextController {
    
    public List<sObject> retObjects {get; private set;}
    public void setRetObjects(List<sObject> val){
        retObjects = val;
    }
    
    public List<sObject> removedObjects {get; private set;}
    public void setRemovedObjects(List<sObject> val){
        removedObjects = val;
    }
    
    private Set<String> alreadyAttachedObjectIds  = new Set<String>();
    
    //Properties to hold ActionFunction params
    public String addObjId {get; private set;}
    public String remObjId {get; private set;}
    public String objectName {get;private set;}
    public String queryFields {get; private set;}
    public Boolean EmployeeSwitch {get; set;}
    public Schema.SobjectType objType {
        get{
            if(objType == null) objType = Schema.getGlobalDescribe().get(objectName);
            return objType;
        } set;
    }
    
    private static String InternalContactRecordTypeId {
        get{
            if(InternalContactRecordTypeId == null){
                List<RecordType> rtypes = [Select Id, Name From RecordType where sObjectType='Contact' and Name='Internal Contact' and isActive=true];
                if(rtypes.isEmpty()) return '';
                else return rtypes.get(0).Id;
            }
            return InternalContactRecordTypeId;
        } set;
    }
    
    public void setAddObjId(String val){ addObjId = val; }
    public void setRemObjId(String val){ remObjId = val; }
    public void setObjectName(String val){ objectName = val; }
    public void setQueryFields(String val){ queryFields = val; }
    
    public List<sObjectWrapper> getInitObjects(){
        if(retObjects != null){
            List<sObjectWrapper> result = new List<sObjectWrapper>();
            for(sObject s : retObjects){
                result.add(new sObjectWrapper((String)s.get('Id'), (String)s.get('Name')));
                alreadyAttachedObjectIds.add((String)s.get('Id'));
            }
            return result;
        }
        else return null;
    }
    
    public static String buildQuery(String objName, String searchStr, String display_fields, String search_fields, String category, Boolean employees, String extraWhereClause){
        Set<String> qfields = new Set<String>(), sfields = new Set<String>();
        String orderBy = 'Name', fields = '', search = '', cleanSearchString;
        Integer qLimit = 10; //ordinarily limit to 10 results (otherwise the autocomplete will be massive)
        
        qfields.add('id');
        qfields.add('name');
        if(display_fields != '') qfields.addAll(display_fields.toLowerCase().split('[ ,]',-1));
        if(category != ''){
            orderBy = category;
            qfields.add(category);
        }
        
        
        cleanSearchString = String.escapeSingleQuotes(searchStr);
        sfields.add('name LIKE \'%' + cleanSearchString + '%\'');
        if(search_fields != ''){
            for(String s : search_fields.toLowerCase().split('[ ,]',-1)){
                if(s != '') sfields.add('' + s + ' LIKE \'%' + cleanSearchString +'%\'');
            }
        }
        
        fields = String.join(new List<String>(qfields),',');
        search = '(' + String.join(new List<String>(sfields),' OR ') + ')';
        
        String employeeClause;
        if(objName == 'Contact'){
            if(employees == true)
                employeeClause = 'RecordTypeId=\'' + InternalContactRecordTypeId +'\'';
            else
                employeeClause = 'RecordTypeId!=\'' + InternalContactRecordTypeId+'\'';
        }
        else{
            employeeClause = '';
        }
        
        if(employeeClause != '') search += ' AND (' + employeeClause + ')';
        if(extraWhereClause != '') search += ' AND (' + extraWhereClause + ')';
        
        String soql = 
            'SELECT '   +   fields  +
            ' FROM '    +   objName +
            ' WHERE '   +   search  +
            ' ORDER BY ' + orderBy +
            ' LIMIT ' + qLimit
            ;
            
        System.debug('SOQLSTATEMENT: ' + soql);
        return soql;
    }
    
    public static String buildSingleObjectQuery(String objName, String query_fields, String objId){
        Set<String> qfields = new Set<String>();
        
        qfields.add('id');
        qfields.add('name');
        if(query_fields != '') qfields.addAll(query_fields.toLowerCase().split('[ ,]',-1));
        
        String fields = String.join(new List<String>(qfields),',');
        
        String soql = 
            'SELECT '   +   fields  +
            ' FROM '    +   objName +
            ' WHERE Id=\'' + objId + '\'' +
            ' LIMIT 1'
            ;
            
        return soql;
    }
    
    
    public void AddObject(){
        String soql = buildSingleObjectQuery(objectName,queryFields,addObjId);
        retObjects.add(Database.query(soql));
    }
    
    public void RemoveObject(){
        //System.debug('REMOVING: '+ remObjId);
        for(integer i = 0; i < retObjects.size(); i++){ 
            sObject s = retObjects.get(i);
            //System.debug('REMOVING: '+ remObjId + ' ' + (String)s.get('id') + (remObjId == (String)s.get('id')));
            if((String)s.get('id') == remObjId){
                if(removedObjects != null && alreadyAttachedObjectIds.contains(remObjId)){
                    //System.debug('REMOVED1: '+ (String)s.get('id'));
                    removedObjects.add(s);
                    alreadyAttachedObjectIds.remove(remObjId);
                }
                //System.debug('LISTSIZE: '+ retObjects.size());
                Sobject victim = retObjects.remove(i);
                //System.debug('LISTSIZE: '+ retObjects.size());
            }
        }
    }
    
    @RemoteAction
    public static sObject[] getObjectsForAutocomplete(String objName, String searchStr, String display_fields, String search_fields, String category, Boolean employees, String extraWhereClause){
        String soql = buildQuery(objName, searchStr, display_fields, search_fields, category, employees, extraWhereClause);
        return Database.query(soql);
    }
}