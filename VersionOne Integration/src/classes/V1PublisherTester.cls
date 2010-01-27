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

        System.assertEquals(V1Publisher.getProjects().size(), 12, 'Error! Incorrect amount of projects.');
        System.assertEquals(V1Publisher.getDefaultProjectId(), '1', 'Errro! Incorect default project.');
        System.assertEquals(V1Publisher.findProjectId('Integrational tests project'), '1457', 'Incorrect id for \'Integrational tests project.');
    }

    static testMethod void incorrectProjectsListTest() {
    	V1Publisher.resetAllData();
        //incorrect responce
        Settings settings = new Settings();
        IRequestor requestor = new TestRequestor('', 400);
        V1Publisher.setRequestor(requestor);
		try{
			V1Publisher.findAllProjects(settings);
			System.assert(false, 'This place cannot be reached.');
		}catch(VersionOneException e){
			//Catch code
		}
        System.assertEquals(V1Publisher.getProjects().size(), 0, 'Error! Incorrect amount of projects.');
        System.assertEquals(V1Publisher.getDefaultProjectId(), String.valueof(0), 'Error! Incorrect default project');
        System.assertEquals(V1Publisher.findProjectId('Integrational tests project'), '0', 'Incorrect id for \'Integrational tests project\'.');
    }

    static testMethod void correctCreatingLinkToSalesForceCaseTest() {
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

		System.assertEquals(((TestRequestor)requestor).getSentBody(0), body, 'Incorrect created body for POST.');
    }

    static testMethod void incorrectCreatingLinkToSalesForceCaseTest() {
    	//test has to complete without any errors
    	V1Publisher.resetAllData();

    	IRequestor requestor = new TestRequestor('', 400);
    	Settings settings = new Settings();
    	Integer defectId = 123;
    	String caseId = 'CaseId';
    	V1Publisher.setRequestor(requestor);
    	try {
    		V1Publisher.createLinkV1ToSF(defectId, 'CaseId', settings);
    		System.assert(false, 'This place cannot be reached.');
		}catch(VersionOneException e){
			//Catch code
		}
    	String body = '<Asset>' +
						'<Attribute act="set" name="OnMenu">true</Attribute>' +
						'<Attribute act="set" name="URL">https://na7.salesforce.com/' + caseId + '</Attribute>' +
						'<Attribute act="set" name="Name">SalesForce Case</Attribute>' +
						'<Relation act="set" name="Asset">' +
							'<Asset idref="Defect:' + defectId + '"/>' +
					    '</Relation>' +
					   '</Asset>';

		System.assertEquals(((TestRequestor)requestor).getSentBody(0), body, 'Incorrect created body for POST.');
    }

    static testMethod void correctGetAlreadyExistedDefectsTest() {
    	V1Publisher.resetAllData();

		//prepare data
		Case case1 = new Case(Subject = 'case1');
		Case case2 = new Case(Subject = 'case2');
		Case case3 = new Case(Subject = 'case3');
		Test.startTest();
		insert new Case[]{case1, case2, case3};
		Test.stopTest();
		case1 = [SELECT CaseNumber FROM Case WHERE Id = :case1.Id];
		case2 = [SELECT CaseNumber FROM Case WHERE Id = :case2.Id];
		case3 = [SELECT CaseNumber FROM Case WHERE Id = :case3.Id];

		String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="2" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/Defect/1047" id="Defect:1047"><Attribute name="Reference">' + case1.CaseNumber + '</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Defect/1051" id="Defect:1051"><Attribute name="Reference">' + case2.CaseNumber + '</Attribute></Asset></Assets>';
		String path = 'http://localhost/VersionOne';
		String sourceName = 'TestSource';
		Settings testSettings = Settings.getTestSettings();
		IRequestor requestor = new TestRequestor(body, 200);
		V1Publisher.setRequestor(requestor);

		Map<String, Boolean> alredyPorted =  V1Publisher.getAlreadyExistedDefects(testSettings, new Case[]{case1, case2, case3});
		System.assertEquals(alredyPorted.size(), 2, 'Error! Incorrect numbers of found defects.');
		System.assert(alredyPorted.containsKey(case1.CaseNumber), 'Error! Case \'' + case1.CaseNumber + '\' has to be found.');
		System.assert(!alredyPorted.containsKey(case3.CaseNumber), 'Error! Case \'' + case3.CaseNumber + '\' has to be found.');
		System.assertEquals('rest-1.v1/Data/Defect?sel=Reference&where=((Reference=\'' + case1.CaseNumber + '\'|Reference=\'' + case2.CaseNumber + '\'|Reference=\'' + case3.CaseNumber + '\');Source.Name="' + sourceName + '")', ((TestRequestor)requestor).getSentUrl(0), 'Error! Case \'' + case3.CaseNumber + '\' has to be found.');
		delete new Case[]{case1, case2, case3};
    }

    static testMethod void correctFindSourceId() {
    	V1Publisher.resetAllData();
    	String sourceName = 'TestSource';
    	String sourceIdExpected = '1010';
    	//ISettings settings = new TestSettings(sourceName);
    	Settings testSettings = Settings.getTestSettings();
    	String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceIdExpected + '" id="StorySource:' + sourceIdExpected + '" /></Assets>';
		IRequestor requestor = new TestRequestor(body, 200);
		V1Publisher.setRequestor(requestor);

    	String sourceId = V1Publisher.findSourceId(testSettings);
    	System.assertEquals(sourceIdExpected, sourceId, 'Incorrect id of source');
    }

    static testMethod void correctCreateDefectInVersionOne() {
    	V1Publisher.resetAllData();
    	//data preparation
    	String caseName = 'Test case';
    	String caseDescription = 'Case for testing';
    	Case caseData = new Case(Subject = caseName, Description = caseDescription);
    	Test.startTest();
		insert caseData;
		Test.stopTest();
		caseData = [SELECT CaseNumber, Subject, Description FROM Case WHERE Id = :caseData.Id];

		String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/1699/4596" id="Defect:1699:4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
		String sourceName = 'TestSource';
		String sourceId = '1010';
		String productId = '123';
		String expectedSendBody = '<Asset>' +
							'<Relation act="set" name="Scope">' +
								'<Asset idref="Scope:' + productId + '"/>' +
							'</Relation>' +
							'<Attribute act="set" name="Name">' + caseName +'</Attribute>' +
							'<Attribute act="set" name="Reference">' + caseData.CaseNumber +'</Attribute>' +
							'<Attribute act="set" name="Description">' + caseDescription + '</Attribute>' +
							'<Relation act="set" name="Source">' +
								'<Asset idref="StorySource:' + sourceId + '"/>' +
							'</Relation>' +
						'</Asset>';
    	//ISettings settings = new TestSettings(sourceName);
    	Settings testSettings = Settings.getTestSettings();
    	IRequestor requestor = new TestRequestor(body, 200);
    	V1Publisher.setRequestor(requestor);

    	Integer defectId = V1Publisher.createDefectInVersionOne(caseData, testSettings, productId, sourceId);

    	System.assertEquals(expectedSendBody, ((TestRequestor)requestor).getSentBody(0), 'Error! Incorrect xml for creating defect in the VersionOne');
    	System.assertEquals(1699, defectId, 'Error! Incorrect defect id');

    	delete caseData;
    }
/*
    static testMethod void correctIsDefectAlreadyExistTest() {
    	V1Publisher.resetAllData();

		String caseNumber = '00012304';
		String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/Defect/1051" id="Defect:1051"><Attribute name="Source.Name">SalesForce</Attribute><Attribute name="Reference">' + caseNumber + '</Attribute></Asset></Assets>';
		String path = 'http://localhost/VersionOne';
		String sourceName = 'TestSource';
		ISettings settings = new TestSettings(sourceName);
		IRequestor requestor = new TestRequestor(body, 200);
		V1Publisher.setRequestor(requestor);
		Boolean result = V1Publisher.isDefectAlreadyExist(settings, caseNumber);

		System.assertEquals('rest-1.v1/Data/Defect?sel=Reference,Source.Name&where=(Reference="' + caseNumber + '";Source.Name="' + sourceName + '")', ((TestRequestor)requestor).getSentUrl(), 'Incorrect created URL for defect request.');
		System.assert(result, 'Error! Defect has to be found.');
    }

    static testMethod void correctIsDefectNotAlreadyExistTest() {
    	V1Publisher.resetAllData();

		String caseNumber = '00012304';
		String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"></Assets>';
		String path = 'http://localhost/VersionOne';
		String sourceName = 'TestSource';
		ISettings settings = new TestSettings(sourceName);
		IRequestor requestor = new TestRequestor(body, 200);
		V1Publisher.setRequestor(requestor);
		Boolean result = V1Publisher.isDefectAlreadyExist(settings, caseNumber);

		System.assertEquals('rest-1.v1/Data/Defect?sel=Reference,Source.Name&where=(Reference="' + caseNumber + '";Source.Name="' + sourceName + '")', ((TestRequestor)requestor).getSentUrl(), 'Incorrect created URL for defect request.');
		System.assert(!result, 'Error! Defect has to be not found.');
    }
    */

    public class TestRequestor implements IRequestor {
    	private String responceBody;
    	private Integer statusCode;
    	private List<String> bodyForSend = new List<String>();
    	private List<String> urlForSend = new List<String>();

		public TestRequestor(String body, Integer statusCode) {
			this.responceBody = body;
			this.statusCode = statusCode;
		}


		public String getBody() {
			return responceBody;
		}

		public Integer getStatusCode() {
			return statusCode;
    	}

    	public String getSentBody(Integer i) {
    		return bodyForSend.get(i);
    	}

    	public String getSentUrl(Integer i) {
    		return urlForSend.get(i);
    	}

		public void request(HttpRequest request) {

		}

		public HttpRequest createRequest(String body, String additionUrl, String requestType) {
			this.bodyForSend.add(body);
			this.urlForSend.add(additionUrl);

			return new HttpRequest();
		}
    }
}