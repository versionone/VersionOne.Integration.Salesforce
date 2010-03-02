@isTest
private class V1ConnectorTester {

    static testMethod void getValueTest() {
        String numberData = 'D-01032';
        String changeDateUTC = '2009-10-21T08:57:50.493';
        String reference = '33';
        String xml = '<Assets total="2" pageSize="2147483647" pageStart="0">' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Defect/1077" id="Defect:1077">' +
                            '<Attribute name="Number">' + numberData + '</Attribute>' +
                            '<Attribute name="ChangeDateUTC">' + changeDateUTC + '</Attribute>' +
                            '<Attribute name="Reference">' + reference + '</Attribute>' +
                        '</Asset>' +
                      '</Assets>';
        XMLDom xmlParser = new XMLDom();
        xmlParser.parseFromString(xml);
        List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
        System.debug('size of assetTags:' + assetTags.size());
        List<XMLDom.Element> attibuteTags = assetTags.get(0).childNodes;

        V1Connector synch = new V1Connector(Settings.getTestSettings(), new RequestorMock('', 200));

        System.assertEquals(numberData, synch.getValue('Number', attibuteTags), 'Incorrect Number value.');
        System.assertEquals(changeDateUTC, synch.getValue('ChangeDateUTC', attibuteTags), 'Incorrect ChangeDateUTC value.');
        System.assertEquals(reference, synch.getValue('Reference', attibuteTags), 'Incorrect Reference value.');
        System.assertEquals(null, synch.getValue('test', attibuteTags), 'Incorrect test value.');
    }

    static testMethod void convertToDateTimeTest() {
        String changeDateUTC = '2009-10-21T08:57:50.493';
        String expectedDateTime = '2009-10-21 08:57:50';

        DateTime test = V1Connector.convertToDateTime(changeDateUTC);
        System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void convertToDateTimeTest2() {
        String changeDateUTC = '2009-10-21T08:57:50.000';
        String expectedDateTime = '2009-10-21 08:57:49';

        DateTime test = V1Connector.convertToDateTime(changeDateUTC);
        System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void getClosedDefectsTest() {
        String reference1 = '33';
        String reference2 = '4354304350893';
        String queueId = '12345667';
        String sourceId = '1010';
        String xml = '<Assets total="2" pageSize="2147483647" pageStart="0">' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Defect/1077" id="Defect:1077">' +
                            '<Attribute name="Number">D-01032</Attribute>' +
                            '<Attribute name="ChangeDateUTC">2009-10-21T08:57:50.493</Attribute>' +
                            '<Attribute name="Reference">' + reference1 + '</Attribute>' +
                        '</Asset>' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Defect/1077" id="Defect:1077">' +
                            '<Attribute name="Number">D-01032</Attribute>' +
                            '<Attribute name="ChangeDateUTC">2009-10-21T08:57:30.493</Attribute>' +
                            '<Attribute name="Reference">' + reference2 + '</Attribute>' +
                        '</Asset>' +
                      '</Assets>';
        Settings testSettings = Settings.getTestSettings();
        IRequestor testRequestor = new RequestorMock(xml, 200);
        testSettings.setDestQueueId(queueId);
        testSettings.setSourceId(sourceId);
        String expectedDate = '2009-10-20T09:57:33';
        testSettings.setLastDateChangeAsset(Datetime.newInstance(2009, 10, 20, 9, 57, 33));
        V1Connector connector = new V1Connector(testSettings, testRequestor);
        List<String> references = connector.getClosedDefects();
        System.assertEquals(2, references.size(), 'Incorrect number of assets.');
        assertContains(reference1, references, 'Can\'t find ' + references + ' reference');
        assertContains(reference2, references, 'Can\'t find ' + references + ' reference');
        System.assertEquals('2009-10-21 08:57:50', testSettings.getLastDateChangeAsset().format('yyyy-MM-dd HH:mm:ss'), 'Incorrect latest datetime of chaned asset.');
        System.assertEquals('rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="StorySource:' + sourceId + '";Defect.AssetState="Closed";ChangeDateUTC>\'' + expectedDate + '\')', ((RequestorMock)testRequestor).getSentUrl(0), 'Incorrect request url.');
    }

    static testMethod void correctGetSourceIdTester() {
        String sourceName = 'TestSource';
        String sourceIdExpected = '1010';
        Settings testSettings = Settings.getTestSettings();
        testSettings.setSource(sourceName);
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceIdExpected + '" id="StorySource:' + sourceIdExpected + '" /></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        IV1Connector connector = new V1Connector(testSettings, requestor);

        String sourceId = connector.getSourceId();
        System.assertEquals(sourceIdExpected, sourceId, 'Incorrect id of source');
    }

    static testMethod void incorrectGetSourceIdTester() {
        String sourceName = 'TestSource';
        String sourceIdExpected = null;
        Settings testSettings = Settings.getTestSettings();
        testSettings.setSource(sourceName);
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="0" pageSize="0" pageStart="0"></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        IV1Connector connector = new V1Connector(testSettings, requestor);

        String sourceId = connector.getSourceId();
        System.assertEquals(sourceIdExpected, sourceId, 'Incorrect id of source');
    }

    static testMethod void exceptionsGetSourceIdTester() {
        String sourceName = 'TestSource';
        String sourceIdExpected = null;
        Settings testSettings = Settings.getTestSettings();
        testSettings.setSource(sourceName);
        String body = '';
        IRequestor requestor = new RequestorMock(body, 401);
        V1Connector connector = new V1Connector(testSettings, requestor);

        try {
            String sourceId = connector.getSourceId();
            System.assert(false, 'This cannot be reached.');
        } catch (VersionOneException ex) {
            System.assertEquals('Credentials is not correct.', ex.getErrorMessage(), 'Incorrect error message.');
        }

        //another exception
        requestor = new RequestorMock(body, 500);
        connector = new V1Connector(testSettings, requestor);

        try {
            String sourceId = connector.getSourceId();
            System.assert(false, 'This cannot be reached.');
        } catch (VersionOneException ex) {
            System.assertEquals('URL is not correct or VersionOne server has some problems at the moment.', ex.getErrorMessage(), 'Incorrect error message.');
        }

        //another exception
        requestor = new RequestorMock(body, 404);
        connector = new V1Connector(testSettings, requestor);

        try {
            String sourceId = connector.getSourceId();
            System.assert(false, 'This cannot be reached.');
        } catch (VersionOneException ex) {
            System.assertEquals('URL is not correct or VersionOne server has some problems at the moment.', ex.getErrorMessage(), 'Incorrect error message.');
        }

        //another exception
        requestor = new RequestorMock(body, 111);
        connector = new V1Connector(testSettings, requestor);

        try {
            String sourceId = connector.getSourceId();
            System.assert(false, 'This cannot be reached.');
        } catch (VersionOneException ex) {
            System.assertEquals('Problem with getting data from the VersionOne. (111)', ex.getErrorMessage(), 'Incorrect error message.');
        }

    }

    static testMethod void correctProjectsListTest() {
        // correct responce
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="21" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/Scope/1081" id="Scope:1081"><Attribute name="Name">CI</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1367" id="Scope:1367"><Attribute name="Name">Misha\'s project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1099" id="Scope:1099"><Attribute name="Name">Manual Hudson testing</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/0" id="Scope:1"><Attribute name="Name">System (All Projects)</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1675" id="Scope:1675"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1676" id="Scope:1676"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1082" id="Scope:1082"><Attribute name="Name">HudsonPlugin</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1202" id="Scope:1202"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1204" id="Scope:1204"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1443" id="Scope:1443"><Attribute name="Name">testAlina</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1349" id="Scope:1349"><Attribute name="Name">stanf</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1002" id="Scope:1002"><Attribute name="Name">DIR project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1457" id="Scope:1457"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1462" id="Scope:1462"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1467" id="Scope:1467"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1472" id="Scope:1472"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1477" id="Scope:1477"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1492" id="Scope:1492"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1542" id="Scope:1542"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1562" id="Scope:1562"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1008" id="Scope:1008"><Attribute name="Name">_Bugzilla test</Attribute></Asset></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        Settings testSettings = Settings.getTestSettings();
        V1Connector connector = new V1Connector(testSettings, requestor);
        Map<String, String> projects = connector.findAllProjects();

        System.assertEquals(12, projects.size(), 'Error! Incorrect amount of projects.');
        System.assertEquals('1', connector.getDefaultProjectId(), 'Error! Incorect default project.');
        System.assertEquals('1457', projects.get('Integrational tests project'), 'Incorrect id for \'Integrational tests project.');
    }

    static testMethod void incorrectProjectsListTest() {
        //incorrect responce
        Settings testSettings = Settings.getTestSettings();
        IRequestor requestor = new RequestorMock('', 400);
        V1Connector connector = new V1Connector(testSettings, requestor);
        Map<String, String> projects;
        try{
            projects = connector.findAllProjects();
            System.assert(false, 'This place cannot be reached.');
        }catch(VersionOneException e){
            //Catch code
        }
        System.assertEquals(null, projects, 'Error! Incorrect amount of projects.');
        //System.assertEquals(V1Publisher.getDefaultProjectId(), String.valueof(0), 'Error! Incorrect default project');
        //System.assertEquals(V1Publisher.findProjectId('Integrational tests project'), '0', 'Incorrect id for \'Integrational tests project\'.');
    }

    static testMethod void correctGetAlreadyExistedDefectsTest() {
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
        V1Connector connector = new V1Connector(testSettings, requestor);

        Map<String, Boolean> alreadyPorted = connector.getReferencedWorkitems(new Case[]{case1, case2, case3});
        System.assertEquals(alreadyPorted.size(), 2, 'Error! Incorrect numbers of found defects.');
        System.assert(alreadyPorted.containsKey(case1.CaseNumber), 'Error! Case \'' + case1.CaseNumber + '\' has to be found.');
        System.assert(!alreadyPorted.containsKey(case3.CaseNumber), 'Error! Case \'' + case3.CaseNumber + '\' has to be found.');
        System.assertEquals('rest-1.v1/Data/Defect?sel=Reference&where=((Reference=\'' + case1.CaseNumber + '\'|Reference=\'' + case2.CaseNumber + '\'|Reference=\'' + case3.CaseNumber + '\');Source.Name="' + sourceName + '")', ((RequestorMock)requestor).getSentUrl(0), 'Error! Case \'' + case3.CaseNumber + '\' has to be found.');
        delete new Case[]{case1, case2, case3};
    }

    static testMethod void incorrectGetAlreadyExistedDefectsTest() {
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
        V1Connector connector = new V1Connector(testSettings, requestor);

        try {
            Map<String, Boolean> alreadyPorted =  connector.getReferencedWorkitems(new Case[]{case1, case2, case3});
            System.assert(false, 'This place cannot be reached.');
        }catch(VersionOneException e){
            //Catch code
        }
    }

    static testMethod void correctCreatingLinkToSalesForceCaseTest() {
        IRequestor requestor = new RequestorMock('', 200);
        Settings testSettings = Settings.getTestSettings();
        Integer defectId = 123;
        String caseId = 'CaseId';
        V1Connector connector = new V1Connector(testSettings, requestor);
        //V1Publisher.setRequestor(requestor);
        //V1Publisher.setSettings(settings);
        connector.createLinkV1ToSF(defectId, 'CaseId');

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
        IRequestor requestor = new RequestorMock('', 400);
        Settings testSettings = Settings.getTestSettings();
        Integer defectId = 123;
        String caseId = 'CaseId';
        V1Connector connector = new V1Connector(testSettings, requestor);
        //V1Publisher.setRequestor(requestor);
        //V1Publisher.setSettings(settings);
        try {
            connector.createLinkV1ToSF(defectId, 'CaseId');
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

    static testMethod void correctCreateDefectInVersionOne() {
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
        testSettings.setSourceId(sourceId);
        RequestorMock requestor = new RequestorMock(body, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        Integer defectId = connector.createDefectInV1(caseData, productId);

        System.assertEquals(expectedSendBody, requestor.getSentBody(0), 'Error! Incorrect xml for creating defect in the VersionOne');
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
        connector = new V1Connector(testSettings, requestor);
        caseData.Subject = '';
        caseData.Description = '';

        defectId = connector.createDefectInV1(caseData, productId);
        System.assertEquals(expectedSendBody, requestor.getSentBody(0), 'Error! Incorrect xml for creating defect in the VersionOne');
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
        RequestorMock requestor = new RequestorMock('', 400);
        Settings cfg = Settings.getTestSettings();
        cfg.setSourceId(sourceId);
        V1Connector connector = new V1Connector(cfg, requestor);

        Integer defectId = connector.createDefectInV1(caseData, productId);
        System.assertEquals(-1, defectId, 'Error! Incorrect defect id');
        delete caseData;
    }

    static testMethod void exceptionsCreateDefectInVersionOne() {
        System.debug('exceptionsCreateDefectInVersionOne: 1');
        // incorrect responce from the VersionOne on any request during creation defect
        String caseName = 'Test case';
        String sourceId = '1010';
        String productId = '123';
        String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/1699/4596" id="Defect:1699:4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
        String caseDescription = 'Case for testing';
        Case caseData = new Case(Subject = caseName, Description = caseDescription);
        Settings testSettings = Settings.getTestSettings();
        testSettings.setSourceId(sourceId);
        Exception[] exceptions = new Exception[]{new VersionOneException('test error', '<html>error</html>')};
        RequestorMock requestor = new RequestorMock(body, 200, exceptions);
        V1Connector connector = new V1Connector(testSettings, requestor);

        Integer defectId = connector.createDefectInV1(caseData, productId);
        System.assertEquals(-1, defectId, 'Error! Incorrect defect id');

        System.debug('exceptionsCreateDefectInVersionOne: 2');
        // ecxeption during creating defect in the VersionOne
        exceptions = new Exception[]{new NullPointerException()};
        requestor = new RequestorMock(body, 200, exceptions);
        connector = new V1Connector(testSettings, requestor);

        defectId = connector.createDefectInV1(caseData, productId);
        System.assertEquals(-1, defectId, 'Error! Incorrect defect id');

        System.debug('exceptionsCreateDefectInVersionOne: 3');
        // incorrect responce from the VersionOne during creating link to case in the VersionOne
        exceptions = new Exception[]{null, new VersionOneException('test error', '<html>error</html>')};
        requestor = new RequestorMock(body, 200, exceptions);
        connector = new V1Connector(testSettings, requestor);

        defectId = connector.createDefectInV1(caseData, productId);
        System.assertEquals(1699, defectId, 'Error! Incorrect defect id');

        System.debug('exceptionsCreateDefectInVersionOne: 4');
        // ecxeption during creating link to case in the VersionOne
        exceptions = new Exception[]{null, new NullPointerException()};
        requestor = new RequestorMock(body, 200, exceptions);
        connector = new V1Connector(testSettings, requestor);

        defectId = connector.createDefectInV1(caseData, productId);
        System.assertEquals(1699, defectId, 'Error! Incorrect defect id');
    }

    static testMethod void getSettingsTest() {
        Settings testSettings = Settings.getTestSettings();
        IRequestor requestor = new RequestorMock('', 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        System.assertEquals(testSettings, connector.getSettings(), 'Incorrect settings.');
    }

    static void assertContains (String expect, List<String> actuals, String msg) {
        Boolean contains = false;
        for (String o : actuals) {
            if (o.equals(expect)) {
                contains = true;
                break;
            }
        }
        System.assert(contains, msg + '\n  ' + expect + ' not found in ' + actuals);
    }
}