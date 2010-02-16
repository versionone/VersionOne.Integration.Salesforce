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
        System.assertEquals('rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="' + sourceId + '";Defect.AssetState="Closed";ChangeDateUTC>\'' + expectedDate + '\')', ((RequestorMock)testRequestor).getSentUrl(0), 'Incorrect request url.');
    }

    static testMethod void correctGetSourceIdTester() {
        V1Publisher.resetAllData();
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
        V1Publisher.resetAllData();
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
        V1Publisher.resetAllData();
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