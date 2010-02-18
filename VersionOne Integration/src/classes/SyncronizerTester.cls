@isTest
private class SyncronizerTester {

    static testMethod void getClosedDefectsTest() {
        // no ported cases
        Syncronizer synch = new Syncronizer(Settings.getTestSettings());
        System.assertEquals(null, synch.getClosedDefects(), 'No defects have to be found.');

        //there are ported cases
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        String queueId = queue.Id;
        String sourceId = '1010';
        Settings testSettings = Settings.getTestSettings();
        testSettings.setDestQueueId(queueId);
        testSettings.setSourceId(sourceId);
        IV1Connector testConnector = new V1ConnectorMock();
        String[] closedDefects = new String[]{'case number 1', 'case number 2'};
        ((V1ConnectorMock)testConnector).setClosedDefects(closedDefects);
        synch = new Syncronizer(testSettings, testConnector);

        System.runAs(createUser('test4356')){
        	// it need just to pass verification that at least one opened ported case exist
            Case case1 = new Case(Subject = 'case1', OwnerId = queue.Id);
            insert case1;

            List<String> defects = synch.getClosedDefects();
            System.assertEquals(2, defects.size(), 'Incorrect numbers of defects.');
            assertContains(closedDefects[0], defects, 'Can\'t find ' + testConnector.getClosedDefects().get(0) + ' reference');
            assertContains(closedDefects[1], defects, 'Can\'t find ' + testConnector.getClosedDefects().get(1) + ' reference');
        }
    }

    static testMethod void syncCasesTest() {
		Syncronizer synch;
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        String queueId = queue.Id;
        String sourceId = '1010';
        Settings testSettings = Settings.getTestSettings();
        testSettings.setDestQueueId(queueId);
        testSettings.setSourceId(sourceId);
        testSettings.setCommentOnClosing('Close in the VersionOne');

        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject = 'case1', OwnerId = queue.Id, Status = 'Closed');
            Case case2 = new Case(Subject = 'case2', OwnerId = queue.Id, Status = 'New');
            Case case3 = new Case(Subject = 'case3', Status = 'New');
            insert new Case[]{case1, case2, case3};
        	case1 = [SELECT CaseNumber FROM Case WHERE Id = :case1.Id];
        	case2 = [SELECT CaseNumber FROM Case WHERE Id = :case2.Id];
        	case3 = [SELECT CaseNumber FROM Case WHERE Id = :case3.Id];

	        IV1Connector testConnector = new V1ConnectorMock();
	        String[] closedTask = new String[] {case1.CaseNumber, case2.CaseNumber, case3.CaseNumber};
	        ((V1ConnectorMock)testConnector).setClosedDefects(closedTask);
	        synch = new Syncronizer(testSettings, testConnector);

            Integer numberCases = synch.syncCases();
            System.assertEquals(1, numberCases, 'Incorrect numbers of defects.');
            Case newCase1 = [SELECT CaseNumber, Status FROM Case WHERE Id = :case1.Id];
            Case newCase2 = [SELECT CaseNumber, Status FROM Case WHERE Id = :case2.Id];
            Case newCase3 = [SELECT CaseNumber, Status FROM Case WHERE Id = :case3.Id];
            System.assertEquals('Closed', newCase1.Status, 'Incorrect status of case 1.');
            System.assertEquals('Closed', newCase2.Status, 'Incorrect status of case 2.');
            System.assertEquals('New', newCase3.Status, 'Incorrect status of case 3.');
            List<CaseComment> newComment1 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase1.Id];
            CaseComment newComment2 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase2.Id];
            List<CaseComment> newComment3 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase3.Id];
            System.assertEquals(0, newComment1.size(), 'Incorrect number of comments for case 1');
            System.assertEquals(0, newComment3.size(), 'Incorrect number of comments for case 3');
            System.assertEquals(testSettings.getCommentOnClosing(), newComment2.CommentBody, 'Incorrect comment for case 2');

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