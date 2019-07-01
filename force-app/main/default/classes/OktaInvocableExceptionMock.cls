@isTest
global class OktaInvocableExceptionMock implements HttpCalloutMock {

    global HttpResponse respond(HTTPRequest request) {
        throw new GatewayException('This is a test Exception.');
    }

    public class GatewayException extends Exception {}

}