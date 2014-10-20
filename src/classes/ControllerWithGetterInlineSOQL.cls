public class ControllerWithGetterInlineSOQL {

    public Account getAccount() {
        return [SELECT Name FROM Account WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
}