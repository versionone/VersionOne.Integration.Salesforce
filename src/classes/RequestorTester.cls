@isTest
private class RequestorTester {

    static testMethod void doGetTest() {
        String body = 'testing';
        String addUrl = 'rest-1.v1/Data/Defect';
        String method = 'GET';
        Settings testSettings = Settings.getTestSettings();
        Requestor requestor = new Requestor(testSettings);
        Httprequest request = requestor.createRequest(body, addUrl, method);

        System.assertEquals(body, request.getBody());
        System.assertEquals(testSettings.getPath() + addUrl, request.getEndpoint());
        System.assertEquals(method, request.getMethod());
        System.assertEquals(null, requestor.getBody());
        System.assertEquals(null, requestor.getStatusCode());
    }

    static testMethod void doPostTest() {
        String body = 'testing';
        String addUrl = 'rest-1.v1/Data/Defect';
        String method = 'POST';
        Settings testSettings = Settings.getTestSettings();
        Requestor requestor = new Requestor(testSettings);
        Httprequest request = requestor.createRequest(body, addUrl, method);

        System.assertEquals(body, request.getBody());
        System.assertEquals(testSettings.getPath() + addUrl, request.getEndpoint());
        System.assertEquals(method, request.getMethod());
        System.assertEquals(String.valueof(body.length()), request.getHeader('Content-Length'));
        System.assertEquals(null, requestor.getBody());
        System.assertEquals(null, requestor.getStatusCode());
    }
    
}