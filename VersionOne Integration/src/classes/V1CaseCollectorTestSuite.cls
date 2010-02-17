@isTest
private class V1CaseCollectorTestSuite {

    static testMethod void getQueuesListTest() {
        String queueName = 'TestQueue';
        Group queue1 = new Group(Type='Queue', Name=queueName+'1');
        insert queue1;
        Group queue2 = new Group(Type='Queue', Name=queueName+'2');
        insert queue2;
        Group queue3 = new Group(Name=queueName+'3');
        insert queue3;
        Group[] newQueues = V1CaseCollector.getQueuesList();
        assertContains(queue1, newQueues, 'Wrong queue1');
        assertContains(queue2, newQueues, 'Wrong queue2');
    }

    static void assertContains (SObject expect, SObject[] actuals, String msg) {
        Boolean contains = false;
        for (SObject o : actuals) {
            if (o.Id == expect.Id) {
                contains = true;
                break;
            }
        }
        System.assert(contains, msg + '\n  ' + expect + ' not found in ' + actuals);
    }

    static testMethod void setCasesOwnerTest() {
        V1Publisher.setSettings(Settings.getTestSettings());
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        System.runAs(createUser('test4356')){
            String customField = 'VersionOneUrl__c';
            Case case1 = new Case(Subject='TestCase1');
            Case case2 = new Case(Subject='TestCase2');
            Case case3 = new Case(Subject='TestCase3');
            insert new Case[] {case1, case2, case3};

            Case[] cases = V1CaseCollector.getCasesByOwnerId(queue.Id);
            System.assertEquals(0, cases.size(), 'There is already owned cases.');

            V1CaseCollector.updateCases(new Case[] {case1, case2}, queue.Id, 'test comment',
                                        customField, new String[] {'999', null});
            System.assertEquals(queue.Id, case1.OwnerId, 'Case1 Owner doesn\'t changed.');
            System.assertEquals(queue.Id, case2.OwnerId, 'Case2 Owner doesn\'t changed.');
            System.assertEquals(null, case3.OwnerId, 'Case3 Owner set by mistake.');
            System.assertEquals('999', case1.get(customField), 'Case1 customField doesn\'t changed.');
            System.assertEquals(null, case2.get(customField), 'Case2 customField set by mistake.');
            System.assertEquals(null, case3.get(customField), 'Case3 customField set by mistake.');

            Case[] newCases = V1CaseCollector.getCasesByOwnerId(queue.Id);
            System.assertEquals(2, newCases.size(), 'Wrong count of owned cases.');
            assertContains(case1, newCases, 'Wrong owned case1.');
            assertContains(case2, newCases, 'Wrong owned case2.');

            CaseComment comment1 = [SELECT CommentBody, ParentId FROM CaseComment WHERE ParentId = :case1.Id];
            System.assertEquals('test comment', comment1.CommentBody, 'Wrong comment of case1.');
            CaseComment comment2 = [SELECT CommentBody, ParentId FROM CaseComment WHERE ParentId = :case2.Id];
            System.assertEquals('test comment', comment2.CommentBody, 'Wrong comment of case1.');
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

    static testMethod void getQueueIdByNameTest() {
        V1Publisher.setSettings(Settings.getTestSettings());
        String queueName = 'TestQueue1';
        Group group1 = new Group(Name=queueName);
        insert group1;
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        Group group2 = new Group(Name=queueName);
        insert group2;
        String queueId = V1CaseCollector.getQueueIdByName(queueName);
        System.assertEquals(queue.Id, queueId, 'Queue ID doesn\'t set');
    }

    static testMethod void getCasesByOwnerIdTest() {
        V1Publisher.setSettings(Settings.getTestSettings());
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        System.runAs(createUser('test4356')){
        	Case case1 = new Case(Subject='TestCase1', OwnerId = queue.Id);
        	Case case2 = new Case(Subject='TestCase2', OwnerId = queue.Id);
        	Case case3 = new Case(Subject='TestCase3', OwnerId = queue.Id);
        	insert new Case[] {case1, case2, case3};

        	Case[] cases = V1CaseCollector.getCasesByOwnerId(queue.Id);
        	System.assertEquals(3, cases.size(), 'Incorrect numbers of cases.');

        	case2.status = 'Closed';
        	update case2;
        	System.debug('case 2 status : ' + case2.status);
        	Case[] newCases = V1CaseCollector.getCasesByOwnerId(queue.Id, true);
        	System.assertEquals(1, newCases.size(), 'Incorrect numbers of cases. One cases have to be closed');
            assertContains(case2, newCases, 'Wrong owned case1.');
        	newCases = V1CaseCollector.getCasesByOwnerId(queue.Id, false);
        	System.assertEquals(2, newCases.size(), 'Incorrect numbers of cases. Two classes have to be not closed');
            assertContains(case1, newCases, 'Wrong owned case1.');
            assertContains(case3, newCases, 'Wrong owned case1.');
		}
    }
}