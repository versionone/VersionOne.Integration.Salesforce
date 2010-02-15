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
    	Syncronizer synch = new Syncronizer(Settings.getTestSettings(), new RequestorMock('', 200));

    	DateTime test = synch.convertToDateTime(changeDateUTC);
    	System.assertEquals(expectedDateTime, test.format('yyyy-MM-dd HH:mm:ss'), 'Incorrect time.');
    }

    static testMethod void convertToDateTimeTest2() {
    	String changeDateUTC = '2009-10-21T08:57:50.000';
    	String expectedDateTime = '2009-10-21 08:57:49';
    	Syncronizer synch = new Syncronizer(Settings.getTestSettings(), new RequestorMock('', 200));

    	DateTime test = synch.convertToDateTime(changeDateUTC);
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
	    	String sourceId = String.valueOf(queue.Id);
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
			testSettings.setSourceQueueId(sourceId);
			Syncronizer synch = new Syncronizer(testSettings, new RequestorMock(xml, 200));
			List<String> references = synch.getClosedDefects();
			System.assertEquals(2, references.size(), 'Incorrect number of assets.');
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