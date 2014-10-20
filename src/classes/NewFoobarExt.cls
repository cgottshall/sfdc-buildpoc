public with sharing class NewFoobarExt {

    public Id recordTypeId { get; set; }

    public NewFoobarExt(ApexPages.StandardController std) {
        Foobar__c foo = (Foobar__c)std.getRecord();
        recordTypeId = foo.RecordTypeId;
    }
}