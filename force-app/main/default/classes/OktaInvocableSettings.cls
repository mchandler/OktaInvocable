public class OktaInvocableSettings {

    private static String ROOT_URL;
    private static String AUTH_TOKEN;
    private static String APP_ID;

    private static OktaInvocableSettings settings;

    private OktaInvocableSettings() {
        Okta_Integration_Setting__mdt config = [SELECT Root_URL__c, Auth_Token__c, App_ID__c
                                    FROM Okta_Integration_Setting__mdt
                                    WHERE DeveloperName = 'Okta'];

        ROOT_URL = config.Root_URL__c;
        AUTH_TOKEN = config.Auth_Token__c;
        APP_ID = config.App_ID__c;
    }

    public static OktaInvocableSettings getInstance() {
        if (settings == null) {
            settings = new OktaInvocableSettings();
        }

        return settings;
    }

    public String getRootUrl() {
        return ROOT_URL;
    }

    public String getAuthToken() {
        return AUTH_TOKEN;
    }

    public String getAppId() {
        return APP_ID;
    }

}