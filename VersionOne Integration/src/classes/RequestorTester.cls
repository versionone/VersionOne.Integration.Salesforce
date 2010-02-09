/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
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