@isTest
private class SyncronizerTester {

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

        Syncronizer synch = new Syncronizer(Settings.getTestSettings(), new RequestorMock('', 200));

        System.assertEquals(numberData, synch.getValue('Number', attibuteTags), 'Incorrect Number value.');
        System.assertEquals(changeDateUTC, synch.getValue('ChangeDateUTC', attibuteTags), 'Incorrect ChangeDateUTC value.');
        System.assertEquals(reference, synch.getValue('Reference', attibuteTags), 'Incorrect Reference value.');
        System.assertEquals(null, synch.getValue('test', attibuteTags), 'Incorrect test value.');
    }

    static testMethod void convertToDateTimeTest() {
        String changeDateUTC = '2009-10-21T08:57:50.493';
        String expectedDateTime = '2009-10-21 08:57:50';

        DateTime test = Syncronizer.convertToDateTime(changeDateUTC);
        System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void convertToDateTimeTest2() {
        String changeDateUTC = '2009-10-21T08:57:50.000';
        String expectedDateTime = '2009-10-21 08:57:49';

        DateTime test = Syncronizer.convertToDateTime(changeDateUTC);
        System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void getClosedDefectsTest() {
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject = 'case1', OwnerId = queue.Id);
            insert case1;
            System.debug('Case case1:' + case1);
            String reference1 = '33';
            String reference2 = '4354304350893';
            String queueId = String.valueOf(queue.Id);
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
            testSettings.setSourceQueueId(queueId);
            testSettings.setSourceId(sourceId);
            String expectedDate = '2009-10-20T09:57:33';
            testSettings.setLastDateChangeAsset(Datetime.newInstance(2009, 10, 20, 9, 57, 33));
            Syncronizer synch = new Syncronizer(testSettings, testRequestor);
            List<String> references = synch.getClosedDefects();
            System.assertEquals(2, references.size(), 'Incorrect number of assets.');
            assertContains(reference1, references, 'Can\'t find ' + references + ' reference');
            assertContains(reference2, references, 'Can\'t find ' + references + ' reference');
            System.assertEquals('2009-10-21 08:57:50', testSettings.getLastDateChangeAsset().format('yyyy-MM-dd HH:mm:ss'), 'Incorrect latest datetime of chaned asset.');
            System.assertEquals('rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="' + sourceId + '";Defect.AssetState="Closed";ChangeDateUTC>\'' + expectedDate + '\')', ((RequestorMock)testRequestor).getSentUrl(0), 'Incorrect request url.');

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