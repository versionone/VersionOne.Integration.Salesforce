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
private class V1PublisherTester {

    static testMethod void correctProjectsListTest() {
    	V1Publisher.resetAllData();
    	// correct responce
    	String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="21" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/Scope/1081" id="Scope:1081"><Attribute name="Name">CI</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1367" id="Scope:1367"><Attribute name="Name">Misha\'s project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1099" id="Scope:1099"><Attribute name="Name">Manual Hudson testing</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/0" id="Scope:1"><Attribute name="Name">System (All Projects)</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1675" id="Scope:1675"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1676" id="Scope:1676"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1082" id="Scope:1082"><Attribute name="Name">HudsonPlugin</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1202" id="Scope:1202"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1204" id="Scope:1204"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1443" id="Scope:1443"><Attribute name="Name">testAlina</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1349" id="Scope:1349"><Attribute name="Name">stanf</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1002" id="Scope:1002"><Attribute name="Name">DIR project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1457" id="Scope:1457"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1462" id="Scope:1462"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1467" id="Scope:1467"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1472" id="Scope:1472"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1477" id="Scope:1477"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1492" id="Scope:1492"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1542" id="Scope:1542"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1562" id="Scope:1562"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1008" id="Scope:1008"><Attribute name="Name">_Bugzilla test</Attribute></Asset></Assets>';
        IRequestor requestor = new TestRequestor(body, 200);
        Settings settings = new Settings();
        V1Publisher.setRequestor(requestor);
        V1Publisher.findAllProjects(settings);

        System.assert(V1Publisher.getProjects().size() == 12, 'Incorrect amount of projects ' + V1Publisher.getProjects().size() + ' instead of 12');
        System.assert(V1Publisher.getDefaultProjectId().equals(String.valueof(1)), 'Default project has to has id equals 1 but found ' + V1Publisher.getDefaultProjectId());
        System.assert(V1Publisher.findProjectId('Integrational tests project').equals('1457'), 'Incorrect id for \'Integrational tests project\'. Has to be 1457 but found ' + V1Publisher.findProjectId('Integrational tests project'));
    }

    static testMethod void incorrectProjectsListTest() {
    	V1Publisher.resetAllData();
        //incorrect responce
        Settings settings = new Settings();
        IRequestor requestor = new TestRequestor('', 400);
        V1Publisher.setRequestor(requestor);
        V1Publisher.findAllProjects(settings);

        System.assert(V1Publisher.getProjects().size() == 0, 'Incorrect amount of projects ' + V1Publisher.getProjects().size() + ' instead of 0');
        System.assert(V1Publisher.getDefaultProjectId().equals(String.valueof(0)), 'Default project has to has id equals 0 but found ' + V1Publisher.getDefaultProjectId());
        System.assert(V1Publisher.findProjectId('Integrational tests project').equals('0'), 'Incorrect id for \'Integrational tests project\'. Has to be 0 but found ' + V1Publisher.findProjectId('Integrational tests project'));
    }

    static testMethod void correctCreatingLinkToSalesForceCase() {
    	V1Publisher.resetAllData();

    	IRequestor requestor = new TestRequestor('', 200);
    	Settings settings = new Settings();
    	Integer defectId = 123;
    	String caseId = 'CaseId';
    	V1Publisher.setRequestor(requestor);
    	V1Publisher.createLinkV1ToSF(defectId, 'CaseId', settings);

    	String body = '<Asset>' +
						'<Attribute act="set" name="OnMenu">true</Attribute>' +
						'<Attribute act="set" name="URL">https://na7.salesforce.com/' + caseId + '</Attribute>' +
						'<Attribute act="set" name="Name">SalesForce Case</Attribute>' +
						'<Relation act="set" name="Asset">' +
							'<Asset idref="Defect:' + defectId + '"/>' +
					    '</Relation>' +
					   '</Asset>';

		System.assert(((TestRequestor)requestor).getSentBody().equals(body), 'Incorrect created body for POST.');
    }

    public class TestRequestor implements IRequestor {
    	private String responceBody;
    	private Integer statusCode;
    	private String bodyForSend;

		public TestRequestor(String body, Integer statusCode) {
			this.responceBody = body;
			this.statusCode = statusCode;
		}

		public void doGet(String body, String url) {
		}
		public void doPost(String body, String url) {
			this.bodyForSend = body;
		}

		public String getBody() {
			return responceBody;
		}

		public Integer getStatusCode() {
			return statusCode;
    	}

    	public String getSentBody() {
    		return bodyForSend;
    	}
    }
}