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
        String expectedDateTime = '2009-10-21 08:57:50';

        DateTime test = V1Connector.convertToDateTime(changeDateUTC);
        System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void convertToDateTimeTest3() {
        String changeDateUTC = '2009-10-21 08:57:50.000';
        String expectedDateTime = '2009-10-21 08:57:50';

        DateTime test = V1Connector.convertToDateTime(changeDateUTC);
        System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void convertToDateTimeTest4() {
        String changeDateUTC = '2009-10-21 08:57:50.501';
        String expectedDateTime = '2009-10-21 08:57:51';

        DateTime test = V1Connector.convertToDateTime(changeDateUTC);
        System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void correctGetSourceTokenTester() {
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
        Settings testSettings = Settings.getTestSettings();
        testSettings.setSource('TestSource');
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="0" pageSize="0" pageStart="0"></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        IV1Connector connector = new V1Connector(testSettings, requestor);

        String sourceId = connector.getSourceId();
        System.assertEquals(null, sourceId, 'sourceId must not be returned.');
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
        } catch (V1RequestException ex) {}

        //another exception
        requestor = new RequestorMock(body, 500);
        connector = new V1Connector(testSettings, requestor);

        try {
            String sourceId = connector.getSourceId();
            System.assert(false, 'This cannot be reached.');
        } catch (V1RequestException ex) {}

        //another exception
        requestor = new RequestorMock(body, 404);
        connector = new V1Connector(testSettings, requestor);

        try {
            String sourceId = connector.getSourceId();
            System.assert(false, 'This cannot be reached.');
        } catch (V1RequestException ex) {}

        //another exception
        requestor = new RequestorMock(body, 111);
        connector = new V1Connector(testSettings, requestor);

        try {
            String sourceId = connector.getSourceId();
            System.assert(false, 'This cannot be reached.');
        } catch (V1RequestException ex) {}
    }

    static testMethod void correctProjectsListTest() {
        // correct responce
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="21" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/Scope/1081" id="Scope:1081"><Attribute name="Name">CI</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1367" id="Scope:1367"><Attribute name="Name">Misha\'s project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1099" id="Scope:1099"><Attribute name="Name">Manual Hudson testing</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/0" id="Scope:1"><Attribute name="Name">System (All Projects)</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1675" id="Scope:1675"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1676" id="Scope:1676"><Attribute name="Name">DefectTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1082" id="Scope:1082"><Attribute name="Name">HudsonPlugin</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1202" id="Scope:1202"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1204" id="Scope:1204"><Attribute name="Name">StoryTester</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1443" id="Scope:1443"><Attribute name="Name">testAlina</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1349" id="Scope:1349"><Attribute name="Name">stanf</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1002" id="Scope:1002"><Attribute name="Name">DIR project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1457" id="Scope:1457"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1462" id="Scope:1462"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1467" id="Scope:1467"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1472" id="Scope:1472"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1477" id="Scope:1477"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1492" id="Scope:1492"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1542" id="Scope:1542"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1562" id="Scope:1562"><Attribute name="Name">Integrational tests project</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Scope/1008" id="Scope:1008"><Attribute name="Name">_Bugzilla test</Attribute></Asset></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        Settings testSettings = Settings.getTestSettings();
        V1Connector connector = new V1Connector(testSettings, requestor);
        Map<String, String> projects = connector.findAllProjects();

        System.assertEquals(21, projects.size(), 'Error! Incorrect amount of projects.');
        System.assertEquals('1', connector.getDefaultProjectId(), 'Error! Incorect default project.');
        System.assertEquals('Integrational tests project', projects.get('Scope:1457'), 'Incorrect id for \'Integrational tests project.');
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
        }catch(V1RequestException e){
            //Catch code
        }
        System.assertEquals(null, projects, 'Error! Incorrect amount of projects.');
        //System.assertEquals(V1Publisher.getDefaultProjectId(), String.valueof(0), 'Error! Incorrect default project');
        //System.assertEquals(V1Publisher.findProjectId('Integrational tests project'), '0', 'Incorrect id for \'Integrational tests project\'.');
    }

    static testMethod void correctGetReferencedWorkitemsTest() {
        //prepare data
        Case case1 = new Case(Subject = 'case1');
        Case case2 = new Case(Subject = 'case2');
        Case case3 = new Case(Subject = 'case3');
        insert new Case[]{case1, case2, case3};
        case1 = [SELECT CaseNumber FROM Case WHERE Id = :case1.Id];
        case2 = [SELECT CaseNumber FROM Case WHERE Id = :case2.Id];
        case3 = [SELECT CaseNumber FROM Case WHERE Id = :case3.Id];

        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="2" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/Defect/1047" id="Defect:1047"><Attribute name="Reference">' + case1.CaseNumber + '</Attribute></Asset><Asset href="/VersionOne/rest-1.v1/Data/Defect/1051" id="Defect:1051"><Attribute name="Reference">' + case2.CaseNumber + '</Attribute></Asset></Assets>';
        String path = 'http://localhost/VersionOne';
        String sourceName = 'TestSource';
        Settings testSettings = Settings.getTestSettings();
        testSettings.setSource(sourceName);
        RequestorMock requestor = new RequestorMock(body, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        Test.startTest();
        Map<String, Boolean> alreadyPorted = connector.getReferencedWorkitems(new Case[]{case1, case2, case3});
        Test.stopTest();

        System.assertEquals(alreadyPorted.size(), 2, 'Error! Incorrect numbers of found defects.');
        System.assert(alreadyPorted.containsKey(case1.CaseNumber), 'Error! Case \'' + case1.CaseNumber + '\' has to be found.');
        System.assert(!alreadyPorted.containsKey(case3.CaseNumber), 'Error! Case \'' + case3.CaseNumber + '\' has to be found.');
        String reference = 'Reference=\'' + case1.CaseNumber + '\'|Reference=\'' + case2.CaseNumber + '\'|Reference=\'' + case3.CaseNumber + '\'';
        System.assertEquals(String.format(V1Connector.WORKITEM_REFERENCE_SEARCH_URL, new String[]{reference, sourceName}),
            requestor.getSentUrl(0), 'Error! Wrong URL while quering referenced cases \'' + case3.CaseNumber);
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
        }catch(V1RequestException e){
            //Catch code
        }
    }

    static testMethod void correctCreatingLinkToSalesForceCaseTest() {
        Case case1 = new Case(Subject = 'case1');
        insert case1;
        case1 = [SELECT CaseNumber, OwnerId FROM Case WHERE Id = :case1.Id];

        RequestorMock requestor = new RequestorMock('', 200);
        Settings testSettings = Settings.getTestSettings();
        String defectId = 'DefectStory:123';
        V1Connector connector = new V1Connector(testSettings, requestor);
        //V1Publisher.setRequestor(requestor);
        //V1Publisher.setSettings(settings);

        connector.createLinkV1ToSF(defectId, case1);
        String body = '<Asset>' +
                        '<Attribute act="set" name="OnMenu">true</Attribute>' +
                        '<Attribute act="set" name="URL">https://na7.salesforce.com/' + case1.Id + '</Attribute>' +
                        '<Attribute act="set" name="Name">SalesForce Case</Attribute>' +
                        '<Relation act="set" name="Asset">' +
                            '<Asset idref="' + defectId + '"/>' +
                        '</Relation>' +
                       '</Asset>';

        System.assertEquals(body, requestor.getSentBody(0), 'Incorrect created body for POST.');
    }

    static testMethod void incorrectCreatingLinkToSalesForceCaseTest() {
        Case case1 = new Case(Subject = 'case1');
        insert case1;
        case1 = [SELECT CaseNumber, OwnerId FROM Case WHERE Id = :case1.Id];

        //test has to complete without any errors
        RequestorMock requestor = new RequestorMock('', 400);
        Settings testSettings = Settings.getTestSettings();
        String defectId = 'Defect:123';
        V1Connector connector = new V1Connector(testSettings, requestor);
        try {
            connector.createLinkV1ToSF(defectId, case1);
            System.assert(false, 'This place cannot be reached.');
        }catch(V1RequestException e){ }
        String body = '<Asset>' +
                        '<Attribute act="set" name="OnMenu">true</Attribute>' +
                        '<Attribute act="set" name="URL">https://na7.salesforce.com/' + case1.Id + '</Attribute>' +
                        '<Attribute act="set" name="Name">SalesForce Case</Attribute>' +
                        '<Relation act="set" name="Asset">' +
                            '<Asset idref="' + defectId + '"/>' +
                        '</Relation>' +
                       '</Asset>';

        System.assertEquals(body, requestor.getSentBody(0), 'Incorrect created body for POST.');
    }

    static testMethod void correctCreateDefectInVersionOne() {
        //data preparation
        String caseName = '<Test case>';
        String caseDescription = 'Case for testing';
        Case caseData = new Case(Subject = caseName, Description = caseDescription);
        Test.startTest();
        insert caseData;
        Test.stopTest();
        caseData = [SELECT CaseNumber, Subject, Description, OwnerId FROM Case WHERE Id = :caseData.Id];

        // case 1
        Defect defectData = new Defect(caseName, caseDescription);
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
        testSettings.setProjectId(productId);
        RequestorMock requestor = new RequestorMock(body, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        String workitemId = connector.createWorkitemInV1(caseData, defectData, testSettings.getProjectId());

        System.assertEquals(expectedSendBody, requestor.getSentBody(0), 'Error! Incorrect xml for creating defect in the VersionOne');
        System.assertEquals('Defect:1699', workitemId, 'Error! Incorrect defect id');

        //case 2
        caseName = 'Case from SalesForce';
        defectData = new Defect(caseName, '');
        sourceName = 'TestSource';
        sourceId = '1010';
        productId = '123';
        expectedSendBody = '<Asset>' +
                            '<Relation act="set" name="Scope">' +
                                '<Asset idref="Scope:' + productId + '"/>' +
                            '</Relation>' +
                            '<Attribute act="set" name="Name">' + caseName + '</Attribute>' +
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

        workitemId = connector.createWorkitemInV1(caseData, defectData, productId);
        System.assertEquals(expectedSendBody, requestor.getSentBody(0), 'Error! Incorrect xml for creating defect in the VersionOne');
        System.assertEquals('Defect:1699', workitemId, 'Error! Incorrect defect id');
    }

    static testMethod void incorrectCreateDefectInVersionOne() {
        String caseName = 'Test case';
        String sourceId = '1010';
        String productId = '123';
        String caseDescription = 'Case for testing';
        Defect defectData = new Defect(caseName, caseDescription);
        Case caseData = new Case(Subject = caseName, Description = caseDescription);
        insert caseData;

        RequestorMock requestor = new RequestorMock('', 400);
        Settings cfg = Settings.getTestSettings();
        cfg.setSourceId(sourceId);
        V1Connector connector = new V1Connector(cfg, requestor);

        try {
            Test.startTest();
            String id = connector.createWorkitemInV1(caseData, defectData, cfg.getProjectId());
            Test.stopTest();
            System.assert(false, 'Error! V1RequestException must be thrown.');
        } catch (V1RequestException ex) {}
    }

    static testMethod void exceptionsCreateDefectInVersionOne() {
        System.debug('exceptionsCreateDefectInVersionOne: 1');
        // incorrect responce from the VersionOne on any request during creation defect
        String caseName = 'Test case';
        String sourceId = '1010';
        String productId = '123';
        String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/1699/4596" id="Defect:1699:4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
        String caseDescription = 'Case for testing';
        Defect defectData = new Defect(caseName, caseDescription);
        Case caseData = new Case(Subject = caseName, Description = caseDescription);
        Settings testSettings = Settings.getTestSettings();
        testSettings.setSourceId(sourceId);
        RequestorMock requestor = new RequestorMock(body, 200, new Exception[]{new V1RequestException('test error')});
        V1Connector connector = new V1Connector(testSettings, requestor);

        try {
            String id = connector.createWorkitemInV1(caseData, defectData, testSettings.getProjectId());
            System.assert(false, 'Error! V1RequestException must be thrown.');
        } catch (V1RequestException ex) {}

        System.debug('exceptionsCreateDefectInVersionOne: 2');
        // ecxeption during creating defect in the VersionOne
        requestor = new RequestorMock(body, 200, new Exception[]{new NullPointerException()});
        connector = new V1Connector(testSettings, requestor);

        try {
            String Id = connector.createWorkitemInV1(caseData, defectData, testSettings.getProjectId());
            System.assert(false, 'Error! V1RequestException must be thrown.');
        } catch (NullPointerException ex) {}

        System.debug('exceptionsCreateDefectInVersionOne: 3');
        // incorrect responce from the VersionOne during creating link to case in the VersionOne
        requestor = new RequestorMock(body, 200, new Exception[]{null, new V1RequestException('test error')});
        connector = new V1Connector(testSettings, requestor);

        String workitemId = connector.createWorkitemInV1(caseData, defectData, testSettings.getProjectId());
        System.assertEquals('Defect:1699', workitemId, 'Error! Incorrect defect id');

        System.debug('exceptionsCreateDefectInVersionOne: 4');
        // ecxeption during creating link to case in the VersionOne
        requestor = new RequestorMock(body, 200, new Exception[]{null, new NullPointerException()});
        connector = new V1Connector(testSettings, requestor);

        workitemId = connector.createWorkitemInV1(caseData, defectData, testSettings.getProjectId());
        System.assertEquals('Defect:1699', workitemId, 'Error! Incorrect defect id');
    }

    static testMethod void getSettingsTest() {
        Settings testSettings = Settings.getTestSettings();
        IRequestor requestor = new RequestorMock('', 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        System.assertEquals(testSettings, connector.getSettings(), 'Incorrect settings.');
    }

    static testMethod void getDefectByIdTest() {
        String defectId = '2345';
        String defectToken = 'Defect:2345';
        String resolution = 'Duplicate';
        String project = 'SalesForce test';
        String description = 'q2312313132';
        String assetNumber = 'D-01398';
        String name = 'for paging testing 1';
        String priority = 'Medium';
        String status = 'In Progress';
        String expectedUrl = 'rest-1.v1/Data/Defect/' + defectId + '?sel=Name,Description,Status.Name,Number,Scope.Name,ResolutionReason.Name,Priority.Name,AssetState';
        Settings testSettings = Settings.getTestSettings();
        String xml = '<Asset href="/VersionOne/rest-1.v1/Data/Defect/' + defectId + '" id="' + defectToken + '">' +
                        '<Attribute name="ResolutionReason.Name">' + resolution + '</Attribute>' +
                        '<Attribute name="Scope.Name">' + project + '</Attribute>' +
                        '<Attribute name="Description">' + description + '</Attribute>' +
                        '<Attribute name="Number">' + assetNumber + '</Attribute>' +
                        '<Attribute name="AssetState">128</Attribute>' +
                        '<Attribute name="Status.Name">' + status + '</Attribute>' +
                        '<Attribute name="Name">' + name + '</Attribute>' +
                        '<Attribute name="Priority.Name">' + priority + '</Attribute>' +
                      '</Asset>';
        IRequestor requestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);
        Defect defectData = connector.getDefectById(defectId);

        System.assertEquals(defectToken, defectData.token, 'Incorrect token.');
        System.assertEquals(defectId, defectData.id, 'Incorrect id.');
        System.assertEquals(assetNumber, defectData.assetNumber, 'Incorrect Number.');
        System.assertEquals(resolution, defectData.resolution, 'Incorrect resolution.');
        System.assertEquals(project, defectData.project, 'Incorrect project name.');
        System.assertEquals(description, defectData.description, 'Incorrect defect description.');
        System.assertEquals(name, defectData.title, 'Incorrect defect name.');
        System.assertEquals(priority, defectData.priority, 'Incorrect defect priority.');
        System.assertEquals(true, defectData.isClosed, 'Defect is closed!');
        System.assertEquals(expectedUrl, ((RequestorMock)requestor).getSentUrl(0), 'Incorrect requested URL.');
    }

    static testMethod void removeLinkFromDefectTest() {
        String defectId = '2345';
        String linkId = '2346';
        Settings testSettings = Settings.getTestSettings();
        String expectedUrl1 = 'rest-1.v1/Data/Link?sel=Name&where=(Asset=\'Defect:' + defectId + '\')';
        String expectedUrl2 = 'rest-1.v1/Data/Link/' + linkId + '?op=Delete';
        String xml = '<Assets total="1" pageSize="2147483647" pageStart="0">' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Link/' + linkId + '" id="Link:' + linkId + '">' +
                        '<Attribute name="Name">' + V1Connector.LINK_NAME_TO_CASE + '</Attribute>' +
                        '</Asset>' +
                     '</Assets>';
        RequestorMock requestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        connector.removeLinkFromDefect(defectId);
        System.assertEquals(expectedUrl1, requestor.getSentUrl(0), 'Incorrect requested URL for link.');
        System.assertEquals(expectedUrl2, requestor.getSentUrl(1), 'Incorrect requested URL for deleting link.');
    }

    static testMethod void removeLinkFromDefectWithMultipleLinksTest() {
        String defectId = '2345';
        String linkId = '2346';
        String linkId2 = '2347';
        Settings testSettings = Settings.getTestSettings();
        String expectedUrl1 = 'rest-1.v1/Data/Link?sel=Name&where=(Asset=\'Defect:' + defectId + '\')';
        String expectedUrl2 = 'rest-1.v1/Data/Link/' + linkId + '?op=Delete';
        String expectedUrl3 = 'rest-1.v1/Data/Link/' + linkId2 + '?op=Delete';
        String xml = '<Assets total="2" pageSize="2147483647" pageStart="0">' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Link/' + linkId + '" id="Link:' + linkId + '">' +
                            '<Attribute name="Name">' + V1Connector.LINK_NAME_TO_CASE + '</Attribute>' +
                        '</Asset>' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Link/' + linkId2 + '" id="Link:' + linkId2 + '">' +
                            '<Attribute name="Name">' + V1Connector.LINK_NAME_TO_CASE + '</Attribute>' +
                        '</Asset>' +
                      '</Assets>';
        RequestorMock requestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        connector.removeLinkFromDefect(defectId);
        System.assertEquals(expectedUrl1, requestor.getSentUrl(0), 'Incorrect requested URL for link.');
        System.assertEquals(expectedUrl2, requestor.getSentUrl(1), 'Incorrect requested URL for link.');
        System.assertEquals(expectedUrl3, requestor.getSentUrl(2), 'Incorrect requested URL for link.');
    }

    static testMethod void removeLinkFromDefectWithMultipleLinksButRemoveOnlyOneTest() {
        String defectId = '2345';
        String linkId = '2346';
        Settings testSettings = Settings.getTestSettings();
        String expectedUrl1 = 'rest-1.v1/Data/Link?sel=Name&where=(Asset=\'Defect:' + defectId + '\')';
        String expectedUrl2 = 'rest-1.v1/Data/Link/' + linkId + '?op=Delete';
        String xml = '<Assets total="2" pageSize="2147483647" pageStart="0">' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Link/' + linkId + '" id="Link:' + linkId + '">' +
                            '<Attribute name="Name">' + V1Connector.LINK_NAME_TO_CASE + '</Attribute>' +
                        '</Asset>' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Link/2415" id="Link:2415">' +
                            '<Attribute name="Name">test2</Attribute>' +
                        '</Asset>' +
                      '</Assets>';
        RequestorMock requestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        connector.removeLinkFromDefect(defectId);
        System.assertEquals(expectedUrl1, requestor.getSentUrl(0), 'Incorrect requested URL for link.');
        System.assertEquals(expectedUrl2, requestor.getSentUrl(1), 'Incorrect requested URL for link.');
        try {
            System.assertEquals(null, requestor.getSentUrl(2));
            System.assert(false, 'This cannot be reached. Have to be only 2 requests');
        } catch (Exception ex){}
    }

    static testMethod void removeLinkFromDefectButNoLinkTest() {
        String defectId = '2345';
        String linkId = '2346';
        Settings testSettings = Settings.getTestSettings();
        String expectedUrl1 = 'rest-1.v1/Data/Link?sel=Name&where=(Asset=\'Defect:' + defectId + '\')';
        String expectedUrl2 = 'rest-1.v1/Data/Link/' + linkId + '?op=Delete';
        String xml = '<Assets total="0" pageSize="2147483647" pageStart="0"/>';
        RequestorMock requestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        try {
            connector.removeLinkFromDefect(defectId);
            System.assert(false, 'This cannot be reached.');
        } catch (V1RequestException ex){}
    }

    static testMethod void updateReferenceForDefectTest() {
        String defectId = '2345';
        String resolution = 'Duplicate';
        String project = 'SalesForce test';
        String description = 'q2312313132';
        String token = 'D-01398';
        String name = 'for paging testing 1';
        String priority = 'Medium';
        String status = 'In Progress';
        String xml = '<Asset href="/VersionOne/rest-1.v1/Data/Defect/' + defectId + '" id="Defect:' + defectId + '">' +
                        '<Attribute name="ResolutionReason.Name">' + resolution + '</Attribute>' +
                        '<Attribute name="Scope.Name">' + project + '</Attribute>' +
                        '<Attribute name="Description">' + description + '</Attribute>' +
                        '<Attribute name="Number">' + token + '</Attribute>' +
                        '<Attribute name="AssetState">64</Attribute>' +
                        '<Attribute name="Status.Name">' + status + '</Attribute>' +
                        '<Attribute name="Name">' + name + '</Attribute>' +
                        '<Attribute name="Priority.Name">' + priority + '</Attribute>' +
                      '</Asset>';
        Settings testSettings = Settings.getTestSettings();
        RequestorMock requestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);
        String expectionBody = '<Asset id="Defect:' + defectId + '"><Attribute act="set" name="Reference"></Attribute></Asset>';
        String expectionUrl = 'rest-1.v1/Data/Defect/' + defectId;

        connector.updateReferenceForDefect(defectId, '');
        System.assertEquals(expectionBody, requestor.getSentBody(1));
        System.assertEquals(expectionUrl, requestor.getSentUrl(1));
    }

    static testMethod void updateReferenceForDefectButWithoutUpdateTest() {
        String defectId = '2345';
        String resolution = 'Duplicate';
        String project = 'SalesForce test';
        String description = 'q2312313132';
        String token = 'D-01398';
        String name = 'for paging testing 1';
        String priority = 'Medium';
        String status = 'In Progress';
        String xml = '<Asset href="/VersionOne/rest-1.v1/Data/Defect/' + defectId + '" id="Defect:' + defectId + '">' +
                        '<Attribute name="ResolutionReason.Name">' + resolution + '</Attribute>' +
                        '<Attribute name="Scope.Name">' + project + '</Attribute>' +
                        '<Attribute name="Description">' + description + '</Attribute>' +
                        '<Attribute name="Number">' + token + '</Attribute>' +
                        '<Attribute name="AssetState">' + Defect.ClosedAssetState + '</Attribute>' +
                        '<Attribute name="Status.Name">' + status + '</Attribute>' +
                        '<Attribute name="Name">' + name + '</Attribute>' +
                        '<Attribute name="Priority.Name">' + priority + '</Attribute>' +
                      '</Asset>';
        Settings testSettings = Settings.getTestSettings();
        RequestorMock requestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, requestor);

        connector.updateReferenceForDefect(defectId, '');
        try {
            System.assertEquals(null, requestor.getSentUrl(1));
            System.assert(false, 'This cannot be reached. Have to be only 1 request');
        } catch (Exception ex){}
    }

    static testMethod void searchDefectsTest() {
    	String[] fields = new String[]{'Name', 'Number'};
    	Defect expectedDefect1 = new Defect('testing new functionality (updated)', null);
    	expectedDefect1.status = 'In Progress';
    	expectedDefect1.id = '2469';
    	expectedDefect1.token = 'Defect:2469';
    	expectedDefect1.assetNumber = 'D-01470';
    	expectedDefect1.isClosed = false;
    	expectedDefect1.project = 'SalesForce test';
    	expectedDefect1.priority = 'Low';
    	expectedDefect1.resolution = '';
		Defect expectedDefect2 = new Defect('testing new functionality', null);
		expectedDefect2.id = '2473';
		expectedDefect2.token = 'Defect:2473';
		expectedDefect2.status = '';
		expectedDefect2.assetNumber = 'D-01472';
		expectedDefect2.isClosed = false;
		expectedDefect2.project = 'SalesForce test';
		expectedDefect2.priority = '';
		expectedDefect2.resolution = 'Fixed';
    	String searchPhrase = 'testing new functionality';
    	String expectedUrl = 'rest-1.v1/Data/Defect?sel=Status.Name,AssetState,Number,Name,ResolutionReason.Name,Priority.Name,Scope.Name&where=(Defect.AssetState!=\'Closed\')&sort=-CreateDateUTC' + createSearchQuery(searchPhrase) + '&findin=Name,Number';
    	String xml = '<Assets total="2" pageSize="2147483647" pageStart="0">' +
						'<Asset href="/VersionOne/rest-1.v1/Data/Defect/' + expectedDefect1.id + '" id="Defect:' + expectedDefect1.id + '">' +
							'<Attribute name="Status.Name">' + expectedDefect1.status + '</Attribute>' +
							'<Attribute name="ResolutionReason.Name"/>' +
							'<Attribute name="Name">' + expectedDefect1.title + '</Attribute>' +
							'<Attribute name="Priority.Name">' + expectedDefect1.priority + '</Attribute>' +
							'<Attribute name="AssetState">64</Attribute>' +
							'<Attribute name="Scope.Name">' + expectedDefect1.project + '</Attribute>' +
							'<Attribute name="Number">' + expectedDefect1.assetNumber + '</Attribute>' +
						'</Asset>' +
						'<Asset href="/VersionOne/rest-1.v1/Data/Defect/' + expectedDefect2.id + '" id="Defect:' + expectedDefect2.id + '">' +
							'<Attribute name="Status.Name"/>' +
							'<Attribute name="ResolutionReason.Name">' + expectedDefect2.resolution + '</Attribute>' +
							'<Attribute name="Name">' + expectedDefect2.title + '</Attribute>' +
							'<Attribute name="Priority.Name"/>' +
							'<Attribute name="AssetState">64</Attribute>' +
							'<Attribute name="Scope.Name">' + expectedDefect2.project + '</Attribute>' +
							'<Attribute name="Number">' + expectedDefect2.assetNumber + '</Attribute>' +
						'</Asset>' +
					  '</Assets>';
		Settings testSettings = Settings.getTestSettings();
        RequestorMock testRequestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, testRequestor);

        List<Defect> defects = connector.searchDefects(searchPhrase, false, fields);

        System.assertEquals(2, defects.size());
		System.assertEquals(expectedUrl, testRequestor.getSentUrl(0),'Incorrect request url.');
        System.assert(defectEquals(expectedDefect1, defects.get(0)), 'Incorrect data for defect 1');
        System.assert(defectEquals(expectedDefect2, defects.get(1)), 'Incorrect data for defect 2');
    }

    static testMethod void searchDefectsWithClosedDefectsTest() {
    	String[] fields = new String[]{'Number', 'Name', 'Description', 'Reference'};
    	Defect expectedDefect1 = new Defect('testing new functionality (updated)', null);
    	expectedDefect1.status = 'In Progress';
    	expectedDefect1.id = '2469';
    	expectedDefect1.token = 'Defect:2469';
    	expectedDefect1.assetNumber = 'D-01470';
    	expectedDefect1.isClosed = true;
    	expectedDefect1.project = 'SalesForce test';
    	expectedDefect1.priority = 'Low';
    	expectedDefect1.resolution = '';
		Defect expectedDefect2 = new Defect('testing new functionality', null);
		expectedDefect2.id = '2473';
		expectedDefect2.token = 'Defect:2473';
		expectedDefect2.status = '';
		expectedDefect2.assetNumber = 'D-01472';
		expectedDefect2.isClosed = false;
		expectedDefect2.project = 'SalesForce test';
		expectedDefect2.priority = '';
		expectedDefect2.resolution = 'Fixed';
    	String searchPhrase = 'testing new functionality';
    	String expectedUrl = 'rest-1.v1/Data/Defect?sel=Status.Name,AssetState,Number,Name,ResolutionReason.Name,Priority.Name,Scope.Name&sort=-CreateDateUTC' + createSearchQuery(searchPhrase) + '&findin=Number,Name,Description,Reference';
    	String xml = '<Assets total="2" pageSize="2147483647" pageStart="0">' +
						'<Asset href="/VersionOne/rest-1.v1/Data/Defect/' + expectedDefect1.id + '" id="Defect:' + expectedDefect1.id + '">' +
							'<Attribute name="Status.Name">' + expectedDefect1.status + '</Attribute>' +
							'<Attribute name="ResolutionReason.Name"/>' +
							'<Attribute name="Name">' + expectedDefect1.title + '</Attribute>' +
							'<Attribute name="Priority.Name">' + expectedDefect1.priority + '</Attribute>' +
							'<Attribute name="AssetState">128</Attribute>' +
							'<Attribute name="Scope.Name">' + expectedDefect1.project + '</Attribute>' +
							'<Attribute name="Number">' + expectedDefect1.assetNumber + '</Attribute>' +
						'</Asset>' +
						'<Asset href="/VersionOne/rest-1.v1/Data/Defect/' + expectedDefect2.id + '" id="Defect:' + expectedDefect2.id + '">' +
							'<Attribute name="Status.Name"/>' +
							'<Attribute name="ResolutionReason.Name">' + expectedDefect2.resolution + '</Attribute>' +
							'<Attribute name="Name">' + expectedDefect2.title + '</Attribute>' +
							'<Attribute name="Priority.Name"/>' +
							'<Attribute name="AssetState">64</Attribute>' +
							'<Attribute name="Scope.Name">' + expectedDefect2.project + '</Attribute>' +
							'<Attribute name="Number">' + expectedDefect2.assetNumber + '</Attribute>' +
						'</Asset>' +
					  '</Assets>';
		Settings testSettings = Settings.getTestSettings();
        RequestorMock testRequestor = new RequestorMock(xml, 200);
        V1Connector connector = new V1Connector(testSettings, testRequestor);

        List<Defect> defects = connector.searchDefects(searchPhrase, true, fields);

        System.assertEquals(2, defects.size());
		System.assertEquals(expectedUrl, testRequestor.getSentUrl(0),'Incorrect request url.');
        System.assert(defectEquals(expectedDefect1, defects.get(0)), 'Incorrect data for defect 1');
        System.assert(defectEquals(expectedDefect2, defects.get(1)), 'Incorrect data for defect 2');
    }

    static testMethod void getClosedDefectsTest() {
        String reference1 = '33';
        Defect closedDefect1 = new Defect('testing defect 1', null);
		closedDefect1.changeDate = '2009-10-21 08:57:50';
        closedDefect1.casesId = reference1.split(';');
        closedDefect1.assetNumber = 'D-01032';
        closedDefect1.token = 'Defect:1077';
        closedDefect1.id = '1077';
        closedDefect1.isClosed = true;
        String reference2 = '4354304350893';
        Defect closedDefect2 = new Defect('testing defect 2', null);
		closedDefect2.changeDate = '2009-10-21 08:57:52';
        closedDefect2.casesId = reference2.split(';');
        closedDefect2.assetNumber = 'D-01033';
        closedDefect2.token = 'Defect:1078';
        closedDefect2.id = '1078';
        closedDefect2.isClosed = true;
        String queueId = '12345667';
        String sourceId = '1010';
        String xml = '<Assets total="2" pageSize="2147483647" pageStart="0">' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Defect/1077" id="' + closedDefect1.token + '">' +
                            '<Attribute name="Number">' + closedDefect1.assetNumber + '</Attribute>' +
                            '<Attribute name="ChangeDateUTC">2009-10-21T08:57:50.493</Attribute>' +
							'<Attribute name="Name">' + closedDefect1.title + '</Attribute>' +
                            '<Attribute name="Reference">' + reference1 + '</Attribute>' +
                            '<Attribute name="AssetState">128</Attribute>' +
                        '</Asset>' +
                        '<Asset href="/VersionOne/rest-1.v1/Data/Defect/1077" id="' + closedDefect2.token + '">' +
                            '<Attribute name="Number">' + closedDefect2.assetNumber + '</Attribute>' +
                            '<Attribute name="ChangeDateUTC">2009-10-21T08:57:52.493</Attribute>' +
							'<Attribute name="Name">' + closedDefect2.title + '</Attribute>' +
                            '<Attribute name="Reference">' + reference2 + '</Attribute>' +
                            '<Attribute name="AssetState">128</Attribute>' +
                        '</Asset>' +
                      '</Assets>';
        Settings testSettings = Settings.getTestSettings();
        RequestorMock testRequestor = new RequestorMock(xml, 200);
        testSettings.setSourceId(sourceId);
        String expectedDate = '2009-10-20T09:57:33';
        V1Connector connector = new V1Connector(testSettings, testRequestor);

        List<Defect> closedDefects = connector.getClosedDefects(Datetime.newInstance(2009, 10, 20, 9, 57, 33));

        System.assertEquals(2, closedDefects.size(), 'Incorrect number of assets.');
        assertContains(closedDefect1, closedDefects, 'Can\'t find closed defect');
        assertContains(closedDefect2, closedDefects, 'Can\'t find closed defect');
        //System.assertEquals('2009-10-21 08:57:50', testSettings.getLastDateChangeAsset().format('yyyy-MM-dd HH:mm:ss'), 'Incorrect latest datetime of chaned asset.');
        System.assertEquals(1, testRequestor.numberRequest, 'Wrong requests count.');
        System.assert(testRequestor.getSentUrl(0).contains('Source=\'StorySource:' + sourceId), 'Incorrect request url: ' + testRequestor.getSentUrl(0));
        System.assert(testRequestor.getSentUrl(0).contains(expectedDate), 'Incorrect request url.');
    }

    private static String createSearchQuery(string searchPhrase) {
    	List<String> parts = searchPhrase.trim().split(' ');
    	String query = '';

    	for(String part : parts) {
    		query += '&find=' + part;
    	}

    	return query;
    }


    private static Boolean defectEquals(Defect defect1, Defect defect2) {
    	Boolean result = true;
    	result = defect1.title == defect2.title;
    	result = result && defect1.description == defect2.description;
    	result = result && defect1.token == defect2.token;
    	result = result && defect1.id == defect2.id;
    	result = result && defect1.assetNumber == defect2.assetNumber;
    	result = result && defect1.project == defect2.project;
    	result = result && defect1.priority == defect2.priority;
    	result = result && defect1.status == defect2.status;
    	result = result && defect1.resolution == defect2.resolution;
    	result = result && defect1.isClosed == defect2.isClosed;
    	result = result && defect1.isClosed == defect2.isClosed;
    	result = result && defect1.casesId == defect2.casesId;
    	result = result && defect1.changeDate == defect2.changeDate;

    	return result;
    }

    static void assertContains(Defect expect, List<Defect> actuals, String msg) {
        Boolean contains = false;
        for (Defect actual : actuals) {
            if (defectEquals(expect, actual)) {
                contains = true;
                break;
            }
        }
        System.assert(contains, msg + '\n  ' + expect + ' not found in ' + actuals);
    }
}