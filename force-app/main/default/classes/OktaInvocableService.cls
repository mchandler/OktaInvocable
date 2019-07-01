global with sharing class OktaInvocableService {

    @InvocableMethod(label='Initialize Okta Profile' description='Sends the Contact on the CP to the Okta service')
    global static void initOkta(List<Compliance_Profile__c> cProfiles) {
        if (cProfiles.size() == 1) {
            Compliance_Profile__c cProfile = cprofiles.get(0);
            doCallout(cProfile.Contact__c);
        }
    }

    @Future(Callout = true)
    global static void doCallout(Id contactId) {
        String method = 'POST';
        String endpoint = OktaInvocableSettings.getInstance().getRootUrl() + '/users?activate=true';
        List<Okta_Service_Log__c> logs = new List<Okta_Service_Log__c>();

        Contact contact = [SELECT Id, FirstName, LastName, Email, candidateId__c, Okta_ID__c FROM Contact WHERE Id = :contactId];

        if (!String.isEmpty(contact.Okta_ID__c)) {
            // if the Okta ID has a value, there's nothing to do here
            return;
        }

        String jsonString = createOktaMessage(contact);
        HttpResponse response = OktaGatewayService.rest(method, endpoint, jsonString);

        Okta_Service_Log__c log = log(method, endpoint, jsonString, response);
        logs.add(log);

        System.debug('Okta: ' + response.getStatusCode() + ' / ' + response.getStatus());

        String jsonResponse = response.getBody();
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

        String id = (String) jsonMap.get('id');
        associate(id, contact, logs);
    }

    private static void associate(String id, Contact contact, List<Okta_Service_Log__c> logs) {
        String method = 'POST';
        OktaInvocableSettings config = OktaInvocableSettings.getInstance();
        String endpoint = config.getRootUrl() + '/apps/' + config.getAppId() + '/users';

        OktaAssociation association = new OktaAssociation();
        OktaCredentials credentials = new OktaCredentials();
        association.id = id;
        credentials.userName = contact.Email;
        association.credentials = credentials;

        String jsonString = JSON.serialize(association);
        HttpResponse response = OktaGatewayService.rest(method, endpoint, jsonString);

        System.debug('Okta AppLink: ' + response.getStatusCode() + ' / ' + response.getStatus());

        Okta_Service_Log__c log = log(method, endpoint, jsonString, response);
        logs.add(log);

        insert logs;

        contact.Okta_ID__c = id;
        update contact;
    }

    private static String createOktaMessage(Contact contact) {
        OktaProfileShell shell = new OktaProfileShell();
        OktaProfile profile = new OktaProfile();

        profile.firstName = contact.FirstName;
        profile.lastName = contact.LastName;
        profile.email = contact.Email;
        profile.login = contact.Email;
        profile.candidateid = contact.candidateId__c;

        shell.profile = profile;

        return JSON.serialize(shell);
    }

    private class OktaProfileShell {
        public OktaProfile profile;
    }

    private class OktaProfile {
        public String firstName;
        public String lastName;
        public String email;
        public String login;
        public String division = 'Oxford';
        public String userType = 'Consultant';
        public String candidateid;
    }

    private class OktaAssociation {
        public String id;
        public OktaCredentials credentials;
    }

    private class OktaCredentials {
        public String userName;
        public String password = '{}';
    }

    private static Okta_Service_Log__c log(String method, String path, String payload, HttpResponse response) {
        Decimal statusCode = (Decimal) response.getStatusCode();

        Okta_Service_Log__c serviceLog = new Okta_Service_Log__c(Method__c = method,
                Endpoint__c = path, Payload__c = payload, Status_Code__c = statusCode,
                Status__c = response.getStatus(), Body__c = response.getBody());

        return serviceLog;
    }

}