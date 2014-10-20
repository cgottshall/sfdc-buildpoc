public without sharing class OktaAuthTestHomeController {
    public Map<String,System.Cookie> allCookies {
        get {
            if(allCookies == null)
                allCookies = ApexPages.currentPage().getCookies();
            return allCookies;
        }
        private set;
    }
    
    public Set<String> allCookiesKeys {
        get {
            return allCookies.keySet();
        }
        private set;
    }
    
    public Integer cookieCount {
        get {
            return allCookiesKeys.size();
        }
        private set;
    }
}