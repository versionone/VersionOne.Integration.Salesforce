@isTest
private class V1PublisherTester {

    static testMethod void correctProjectsListTest() {
    	V1Publisher.resetAllData();
    	// correct responce
    	String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="21" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/Scope/1081" id="Scope:1081"><Attribute name="Name">CI</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1367" id="Scope:1367"><Attribute name="Name">Misha\'s project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1099" id="Scope:1099"><Attribute name="Name">Manual Hudson testing</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/0" id="Scope:1"><Attribute name="Name">System (All Projects)</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1675" id="Scope:1675"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1676" id="Scope:1676"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1082" id="Scope:1082"><Attribute name="Name">HudsonPlugin</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1202" id="Scope:1202"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1204" id="Scope:1204"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1443" id="Scope:1443"><Attribute name="Name">testAlina</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1349" id="Scope:1349"><Attribute name="Name">stanf</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1002" id="Scope:1002"><Attribute name="Name">DIR project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1457" id="Scope:1457"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1462" id="Scope:1462"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1467" id="Scope:1467"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1472" id="Scope:1472"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1477" id="Scope:1477"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1492" id="Scope:1492"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1542" id="Scope:1542"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1562" id="Scope:1562"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1008" id="Scope:1008"><Attribute name="Name">_Bugzilla test</Attribute></Asset></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        Settings settings = new Settings();
        V1Publisher.setRequestor(requestor);
        V1Publisher.setSettings(settings);
        V1Publisher.findAllProjects();

        System.assertEquals(V1Publisher.getProjects().size(), 12, 'Error! Incorrect amount of projects.');
        System.assertEquals(V1Publisher.getDefaultProjectId(), '1', 'Errro! Incorect default project.');
        System.assertEquals(V1Publisher.findProjectId('Integrational tests project'), '1457', 'Incorrect id for \'Integrational tests project.');
    }

    static testMethod void incorrectProjectsListTest() {
    	V1Publisher.resetAllData();
        //incorrect responce
        Settings settings = new Settings();
        IRequestor requestor = new RequestorMock('', 400);
        V1Publisher.setRequestor(requestor);
        V1Publisher.setSettings(settings);
		try{
			V1Publisher.findAllProjects();
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

    	IRequestor requestor = new RequestorMock('', 200);
    	Settings settings = new Settings();
    	Integer defectId = 123;
    	String caseId = 'CaseId';
    	V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(settings);
    	V1Publisher.createLinkV1ToSF(defectId, 'CaseId');

    	String body = '<Asset>' +
						'<Attribute act="set" name="OnMenu">true</Attribute>' +
						'<Attribute act="set" name="URL">https://na7.salesforce.com/' + caseId + '</Attribute>' +
						'<Attribute act="set" name="Name">SalesForce Case</Attribute>' +
						'<Relation act="set" name="Asset">' +
							'<Asset idref="Defect:' + defectId + '"/>' +
					    '</Relation>' +
					   '</Asset>';

		System.assertEquals(((RequestorMock)requestor).getSentBody(0), body, 'Incorrect created body for POST.');
    }

    static testMethod void incorrectCreatingLinkToSalesForceCaseTest() {
    	//test has to complete without any errors
    	V1Publisher.resetAllData();

    	IRequestor requestor = new RequestorMock('', 400);
    	Settings settings = new Settings();
    	Integer defectId = 123;
    	String caseId = 'CaseId';
    	V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(settings);
    	try {
    		V1Publisher.createLinkV1ToSF(defectId, 'CaseId');
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

		System.assertEquals(((RequestorMock)requestor).getSentBody(0), body, 'Incorrect created body for POST.');
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
		testSettings.setSource(sourceName);
		IRequestor requestor = new RequestorMock(body, 200);
		V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);

		Map<String, Boolean> alreadyPorted = V1Publisher.getAlreadyExistedDefects(new Case[]{case1, case2, case3});
		System.assertEquals(alreadyPorted.size(), 2, 'Error! Incorrect numbers of found defects.');
		System.assert(alreadyPorted.containsKey(case1.CaseNumber), 'Error! Case \'' + case1.CaseNumber + '\' has to be found.');
		System.assert(!alreadyPorted.containsKey(case3.CaseNumber), 'Error! Case \'' + case3.CaseNumber + '\' has to be found.');
		System.assertEquals('rest-1.v1/Data/Defect?sel=Reference&where=((Reference=\'' + case1.CaseNumber + '\'|Reference=\'' + case2.CaseNumber + '\'|Reference=\'' + case3.CaseNumber + '\');Source.Name="' + sourceName + '")', ((RequestorMock)requestor).getSentUrl(0), 'Error! Case \'' + case3.CaseNumber + '\' has to be found.');
		delete new Case[]{case1, case2, case3};
    }

    static testMethod void incorrectGetAlreadyExistedDefectsTest() {
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
		testSettings.setSource(sourceName);
		IRequestor requestor = new RequestorMock(body, 400);
		V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);

    	try {
    		Map<String, Boolean> alreadyPorted =  V1Publisher.getAlreadyExistedDefects(new Case[]{case1, case2, case3});
    		System.assert(false, 'This place cannot be reached.');
		}catch(VersionOneException e){
			//Catch code
		}
    }

    static testMethod void correctFindSourceId() {
    	V1Publisher.resetAllData();
    	String sourceName = 'TestSource';
    	String sourceIdExpected = '1010';
    	Settings testSettings = Settings.getTestSettings();
    	testSettings.setSource(sourceName);
    	String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceIdExpected + '" id="StorySource:' + sourceIdExpected + '" /></Assets>';
		IRequestor requestor = new RequestorMock(body, 200);
		V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);

    	String sourceId = V1Publisher.findSourceId();
    	System.assertEquals(sourceIdExpected, sourceId, 'Incorrect id of source');
    }

    static testMethod void incorrectFindSourceId() {
    	V1Publisher.resetAllData();
    	String sourceName = 'TestSource';
    	String sourceIdExpected = null;
    	Settings testSettings = Settings.getTestSettings();
    	testSettings.setSource(sourceName);
    	String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceIdExpected + '" id="StorySource:' + sourceIdExpected + '" /></Assets>';
		IRequestor requestor = new RequestorMock(body, 400);
		V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);

    	String sourceId = V1Publisher.findSourceId();
    	System.assertEquals(sourceIdExpected, sourceId, 'Incorrect id of source');
    }

    static testMethod void exceptionFindSourceId() {
    	V1Publisher.resetAllData();
    	String sourceName = 'TestSource';
    	String sourceIdExpected = null;
    	Settings testSettings = Settings.getTestSettings();
    	testSettings.setSource(sourceName);
    	String body = '';
		IRequestor requestor = new RequestorMock(body, 200, new Exception[]{new NullPointerException()});
		V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);

    	String sourceId = V1Publisher.findSourceId();
    	System.assertEquals(sourceIdExpected, sourceId, 'Incorrect id of source');
    }

    static testMethod void correctCreateDefectInVersionOne() {
    	V1Publisher.resetAllData();
    	//data preparation
    	String caseName = '<Test case>';
    	String caseDescription = 'Case for testing';
    	Case caseData = new Case(Subject = caseName, Description = caseDescription);
    	Test.startTest();
		insert caseData;
		Test.stopTest();
		caseData = [SELECT CaseNumber, Subject, Description FROM Case WHERE Id = :caseData.Id];

		// case 1
		String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/1699/4596" id="Defect:1699:4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
		String sourceName = 'TestSource';
		String sourceId = '1010';
		String productId = '123';
		String expectedSendBody = '<Asset>' +
							'<Relation act="set" name="Scope">' +
								'<Asset idref="Scope:' + productId + '"/>' +
							'</Relation>' +
							'<Attribute act="set" name="Name">&lt;Test case&gt;</Attribute>' +
							'<Attribute act="set" name="Reference">' + caseData.CaseNumber +'</Attribute>' +
							'<Attribute act="set" name="Description">' + caseDescription + '</Attribute>' +
							'<Relation act="set" name="Source">' +
								'<Asset idref="StorySource:' + sourceId + '"/>' +
							'</Relation>' +
						'</Asset>';
    	Settings testSettings = Settings.getTestSettings();
    	IRequestor requestor = new RequestorMock(body, 200);
    	V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);

    	Integer defectId = V1Publisher.createDefectInVersionOne(caseData, productId, sourceId);

    	System.assertEquals(expectedSendBody, ((RequestorMock)requestor).getSentBody(0), 'Error! Incorrect xml for creating defect in the VersionOne');
    	System.assertEquals(1699, defectId, 'Error! Incorrect defect id');

    	//case 2
		sourceName = 'TestSource';
		sourceId = '1010';
		productId = '123';
		expectedSendBody = '<Asset>' +
							'<Relation act="set" name="Scope">' +
								'<Asset idref="Scope:' + productId + '"/>' +
							'</Relation>' +
							'<Attribute act="set" name="Name">Case from SalesForce</Attribute>' +
							'<Attribute act="set" name="Reference">' + caseData.CaseNumber +'</Attribute>' +
							'<Attribute act="set" name="Description"></Attribute>' +
							'<Relation act="set" name="Source">' +
								'<Asset idref="StorySource:' + sourceId + '"/>' +
							'</Relation>' +
						'</Asset>';
    	requestor = new RequestorMock(body, 200);
    	V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);
    	caseData.Subject = '';
    	caseData.Description = '';

    	defectId = V1Publisher.createDefectInVersionOne(caseData, productId, sourceId);
    	System.assertEquals(expectedSendBody, ((RequestorMock)requestor).getSentBody(0), 'Error! Incorrect xml for creating defect in the VersionOne');
    	System.assertEquals(1699, defectId, 'Error! Incorrect defect id');

    	delete caseData;
    }

    static testMethod void incorrectCreateDefectInVersionOne() {
    	String caseName = 'Test case';
		String sourceId = '1010';
		String productId = '123';
    	String caseDescription = 'Case for testing';
    	Case caseData = new Case(Subject = caseName, Description = caseDescription);
    	Test.startTest();
		insert caseData;
		Test.stopTest();
    	IRequestor requestor = new RequestorMock('', 400);
    	V1Publisher.setRequestor(requestor);

    	Integer defectId = V1Publisher.createDefectInVersionOne(caseData, productId, sourceId);
    	System.assertEquals(-1, defectId, 'Error! Incorrect defect id');
    	delete caseData;
    }

	static testMethod void exceptionsCreateDefectInVersionOne() {
		V1Publisher.resetAllData();
		System.debug('exceptionsCreateDefectInVersionOne: 1');
		// incorrect responce from the VersionOne on any request during creation defect
    	String caseName = 'Test case';
		String sourceId = '1010';
		String productId = '123';
		String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/1699/4596" id="Defect:1699:4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
    	String caseDescription = 'Case for testing';
		Case caseData = new Case(Subject = caseName, Description = caseDescription);
    	Settings testSettings = Settings.getTestSettings();
    	Exception[] exceptions = new Exception[]{new VersionOneException('test error', '<html>error</html>')};
    	IRequestor requestor = new RequestorMock(body, 200, exceptions);
    	V1Publisher.setRequestor(requestor);
    	V1Publisher.setSettings(testSettings);

    	Integer defectId = V1Publisher.createDefectInVersionOne(caseData, productId, sourceId);
    	System.assertEquals(-1, defectId, 'Error! Incorrect defect id');

		System.debug('exceptionsCreateDefectInVersionOne: 2');
    	// ecxeption during creating defect in the VersionOne
    	exceptions = new Exception[]{new NullPointerException()};
    	requestor = new RequestorMock(body, 200, exceptions);
    	V1Publisher.setRequestor(requestor);

    	defectId = V1Publisher.createDefectInVersionOne(caseData, productId, sourceId);
    	System.assertEquals(-1, defectId, 'Error! Incorrect defect id');

		System.debug('exceptionsCreateDefectInVersionOne: 3');
    	// incorrect responce from the VersionOne during creating link to case in the VersionOne
    	exceptions = new Exception[]{null, new VersionOneException('test error', '<html>error</html>')};
    	requestor = new RequestorMock(body, 200, exceptions);
    	V1Publisher.setRequestor(requestor);

    	defectId = V1Publisher.createDefectInVersionOne(caseData, productId, sourceId);
    	System.assertEquals(1699, defectId, 'Error! Incorrect defect id');

		System.debug('exceptionsCreateDefectInVersionOne: 4');
    	// ecxeption during creating link to case in the VersionOne
    	exceptions = new Exception[]{null, new NullPointerException()};
    	requestor = new RequestorMock(body, 200, exceptions);
    	V1Publisher.setRequestor(requestor);

    	defectId = V1Publisher.createDefectInVersionOne(caseData, productId, sourceId);
    	System.assertEquals(1699, defectId, 'Error! Incorrect defect id');
	}

	static testMethod void processCasesTest() {
		V1Publisher.resetAllData();
		//prepare queue
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

		System.runAs(createUser('test4356')){
			//prepare cases
			Case case1 = new Case(Subject = 'case1');
			Case case2 = new Case(Subject = 'case2');
			Case case3 = new Case(Subject = 'case3');
			insert new Case[]{case1, case2, case3};
			case1 = [SELECT id, OwnerId, CaseNumber, Description, Product__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case1.Id];
			case2 = [SELECT id, OwnerId, CaseNumber, Description, Product__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case2.Id];
			case3 = [SELECT id, OwnerId, CaseNumber, Description, Product__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case3.Id];

			Map<String, Boolean> alreadyPortedCases = new Map<String, Boolean>();
			alreadyPortedCases.put(case2.CaseNumber, true);
			List<Case> cases = new Case[]{case1, case2, case3};

			String defectId = '1699';
			String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/' + defectId +'/4596" id="Defect:' +defectId + ':4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
			String sourceName = 'TestSource';
			String sourceId = '1010';
			String productId = '123';
	    	String caseName = '<Test case>';
	    	String caseDescription = 'Case for testing';
	    	String path = 'http://localhost/';
			String expectedSendBody = '<Asset>' +
								'<Relation act="set" name="Scope">' +
									'<Asset idref="Scope:' + productId + '"/>' +
								'</Relation>' +
								'<Attribute act="set" name="Name">&lt;Test case&gt;</Attribute>' +
								'<Attribute act="set" name="Reference">' + case1.CaseNumber +'</Attribute>' +
								'<Attribute act="set" name="Description">' + caseDescription + '</Attribute>' +
								'<Relation act="set" name="Source">' +
									'<Asset idref="StorySource:' + sourceId + '"/>' +
								'</Relation>' +
							'</Asset>';
			String comment = 'test comment';
			String additionPath = 'assetdetail.v1?oid=Defect%3a';
	    	Settings testSettings = Settings.getTestSettings();
	    	testSettings.setDestQueueId(queue.Id);
	    	testSettings.setPath(path);
	    	testSettings.setCommentBody(comment);
	    	IRequestor requestor = new RequestorMock(body, 200);
	    	V1Publisher.setRequestor(requestor);
	    	V1Publisher.setSettings(testSettings);

			V1Publisher.processCases(alreadyPortedCases, cases, sourceId);

			Case newCase1 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case1.Id];
			System.assertEquals(path + additionPath + defectId, newCase1.VersionOneUrl__c);
			System.assertEquals(queue.Id, newCase1.OwnerId);
			CaseComment newComment = [SELECT CommentBody FROM CaseComment where ParentId = :newCase1.Id];
			System.assertEquals(comment, newComment.CommentBody);

			Case newCase2 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case2.Id];
			System.assertEquals(null, newCase2.VersionOneUrl__c);
			System.assertEquals(queue.Id, newCase2.OwnerId);
			CaseComment newComment2 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase2.Id];
			System.assertEquals(comment, newComment2.CommentBody);

			Case newCase3 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case3.Id];
			System.assertEquals(path + additionPath + defectId, newCase3.VersionOneUrl__c);
			System.assertEquals(queue.Id, newCase3.OwnerId);
			CaseComment newComment3 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase3.Id];
			System.assertEquals(comment, newComment2.CommentBody);
		}
	}

    static User createUser(String alias) {
        User user = new User();
        user.Username = alias + '@not-a-mail.com';
        user.LastName = alias;
        user.Email = alias + '@not-a-mail.com';
        user.alias = alias;
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user.LanguageLocaleKey = 'en_US';
        return user;
    }
}