@isTest
public class OktaInvocableServiceTest {

    public static List<Compliance_Profile__c> getProfiles(Boolean withOkta) {
        List<Compliance_Profile__c> cProfiles = new List<Compliance_Profile__c>();
        Compliance_Profile__c cProfile = new Compliance_Profile__c();

        Contact contact = new Contact(FirstName = 'A', LastName = 'B', Email = 'test@me.com', candidateId__c = '123');
        
        if (withOkta) {
            contact.Okta_ID__c = '1234567890';
        }
        
        insert contact;

        cProfile.Contact__c = contact.Id;
        cProfiles.add(cProfile);

        return cProfiles;
    }

    @isTest
    public static void testInitOkta() {
        List<Compliance_Profile__c> cProfiles = getProfiles(false);

        Test.setMock(HttpCalloutMock.class, new OktaInvocableSuccessMock());
        Test.startTest();

        OktaInvocableService.initOkta(cProfiles);

        Test.stopTest();

        List<Okta_Service_Log__c> logs = [SELECT Id FROM Okta_Service_Log__c];
        System.assertEquals(2, logs.size());
    }
    
    @isTest
    public static void testInitOktaExisting() {
        List<Compliance_Profile__c> cProfiles = getProfiles(true);
        
        Test.setMock(HttpCalloutMock.class, new OktaInvocableSuccessMock());
        Test.startTest();

        OktaInvocableService.initOkta(cProfiles);

        Test.stopTest();

        List<Okta_Service_Log__c> logs = [SELECT Id FROM Okta_Service_Log__c];
        System.assertEquals(0, logs.size());
    }

    @isTest
    public static void testInitOktaFailure() {
        List<Compliance_Profile__c> cProfiles = getProfiles(false);

        Test.setMock(HttpCalloutMock.class, new OktaInvocableExceptionMock());
        Test.startTest();

        OktaInvocableService.initOkta(cProfiles);

        Test.stopTest();
    }

}