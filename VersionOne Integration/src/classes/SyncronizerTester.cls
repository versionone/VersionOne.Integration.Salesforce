@isTest
private class SyncronizerTester {

    static testMethod void getClosedDefectsTest() {
        // no ported cases
        Syncronizer synch = new Syncronizer(Settings.getTestSettings(), new V1ConnectorMock());
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
        synch = new Syncronizer(testSettings, testConnector);

        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject = 'case1', OwnerId = queue.Id);
            insert case1;

            List<String> defects = synch.getClosedDefects();
            System.assertEquals(2, defects.size(), 'Incorrect numbers of defects.');
            assertContains(testConnector.getClosedDefects().get(0), defects, 'Can\'t find ' + testConnector.getClosedDefects().get(0) + ' reference');
            assertContains(testConnector.getClosedDefects().get(1), defects, 'Can\'t find ' + testConnector.getClosedDefects().get(1) + ' reference');
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