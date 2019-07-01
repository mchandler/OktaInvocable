@isTest
global class OktaInvocableSuccessMock implements HttpCalloutMock {

    global HttpResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('OK');
        response.setBody('{"id": "123456"}');

        return response;
    }

}