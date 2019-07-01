public class OktaGatewayService {

    public static HttpResponse rest(String method, String endPoint, String jsonString) {
        HttpResponse response;

        HttpRequest request = new HttpRequest();
        Http http = new Http();

        try {
            request.setMethod(method);
            request.setEndpoint(endPoint);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', OktaInvocableSettings.getInstance().getAuthToken());
            request.setBody(jsonString);

            request.setTimeout(5000); // timeout (5 seconds)

            response = http.send(request);
        } catch(Exception e) {
            response = new HttpResponse();
            response.setStatusCode(999);
            response.setBody('{"ERROR": "' + e.getMessage() + '"}');
            response.setStatus('Exception');
        }

        return response;
    }

}