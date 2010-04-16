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

    static testMethod void updateCasesTest() {
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject='TestCase1');
            Case case2 = new Case(Subject='TestCase2');
            Case case3 = new Case(Subject='TestCase3');
            insert new Case[] {case1, case2, case3};

            Case[] cases = V1CaseCollector.getCasesByOwnerId(queue.Id);
            System.assertEquals(0, cases.size(), 'There is already owned cases.');

            Test.startTest();
            V1CaseCollector.updateCase(case1, queue.Id, 'test comment1', 'testUrl', false);
            V1CaseCollector.updateCase(case2, queue.Id, 'test comment2', null, false);
            Test.stopTest();

            case1 = [SELECT ownerId, VersionOneUrl__c FROM Case WHERE Id = :case1.Id];
            case2 = [SELECT ownerId, VersionOneUrl__c FROM Case WHERE Id = :case2.Id];
            case3 = [SELECT ownerId, VersionOneUrl__c FROM Case WHERE Id = :case3.Id];

            System.assertEquals(queue.Id, case1.OwnerId, 'Wrong Case owner.');
            System.assertEquals(queue.Id, case2.OwnerId, 'Wrong Case owner.');
            System.assertNotEquals(queue.Id, case3.OwnerId, 'Wrong Case owner.');
            System.assertEquals('testUrl', case1.VersionOneUrl__c, 'Case1 customField doesn\'t changed.');
            System.assertEquals(null, case2.VersionOneUrl__c, 'Case2 customField set by mistake.');
            System.assertEquals(null, case3.VersionOneUrl__c, 'Case3 customField set by mistake.');

            Case[] newCases = V1CaseCollector.getCasesByOwnerId(queue.Id);
            System.assertEquals(2, newCases.size(), 'Wrong count of owned cases.');
            assertContains(case1, newCases, 'Wrong owned case1.');
            assertContains(case2, newCases, 'Wrong owned case2.');

            CaseComment comment1 = [SELECT CommentBody, ParentId FROM CaseComment WHERE ParentId = :case1.Id];
            System.assertEquals('test comment1', comment1.CommentBody, 'Wrong comment');
            CaseComment comment2 = [SELECT CommentBody, ParentId FROM CaseComment WHERE ParentId = :case2.Id];
            System.assertEquals('test comment2', comment2.CommentBody, 'Wrong comment');
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
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject='TestCase1', OwnerId = queue.Id);
            Case case2 = new Case(Subject='TestCase2', OwnerId = queue.Id);
            Case case3 = new Case(Subject='TestCase3', OwnerId = queue.Id);
            //will not in the list because of processing
            Case case4 = new Case(Subject='TestCase4', OwnerId = queue.Id, V1Processing__c = true);
            insert new Case[] {case1, case2, case3};

            Case[] cases = V1CaseCollector.getCasesByOwnerId(queue.Id);
            System.assertEquals(3, cases.size(), 'Incorrect numbers of cases.');

            case2.status = 'Closed';
            update case2;
            System.debug('case 2 status : ' + case2.status);
            Case[] newCases = V1CaseCollector.getCasesByOwnerId(queue.Id, true);
            System.assertEquals(1, newCases.size(), 'Incorrect numbers of cases. One cases have to be closed');
            assertContains(case2, newCases, 'Wrong owned case2.');
            newCases = V1CaseCollector.getCasesByOwnerId(queue.Id, false);
            System.assertEquals(2, newCases.size(), 'Incorrect numbers of cases. Two classes have to be not closed');
            assertContains(case1, newCases, 'Wrong owned case1.');
            assertContains(case3, newCases, 'Wrong owned case3.');
        }
    }

    static testMethod void getCaseByCaseNumberTest() {
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject='TestCase1', OwnerId = queue.Id);
            insert new Case[] {case1};
            case1 = [SELECT CaseNumber, Subject FROM Case WHERE Id = :case1.Id];

            Case newCase = V1CaseCollector.getCaseByCaseNumber(case1.CaseNumber);
            System.assertEquals(case1.CaseNumber, newCase.CaseNumber, 'Incorrect case numbers.');
            System.assertEquals(case1.Subject, newCase.Subject, 'Incorrect subject.');
        }
    }

    static testMethod void updateUrlToVersionOneInCaseTest() {
        String queueName = 'TestQueue1';
        String url = 'http://test.com';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject='TestCase1', OwnerId = queue.Id);
            insert new Case[] {case1};
            case1 = [SELECT CaseNumber, Subject FROM Case WHERE Id = :case1.Id];

            V1CaseCollector.updateUrlToVersionOneInCase(case1, url);

            Case newCase = [SELECT CaseNumber, Subject, VersionOneUrl__c FROM Case WHERE Id = :case1.Id];
            System.assertEquals(case1.CaseNumber, newCase.CaseNumber, 'Incorrect case numbers.');
            System.assertEquals(case1.Subject, newCase.Subject, 'Incorrect subject.');
            System.assertEquals(url, newCase.VersionOneUrl__c, 'Incorrect url.');
        }
    }

    static testMethod void getCasesByCaseNumberTest() {
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject='TestCase1', OwnerId = queue.Id);
            Case case2 = new Case(Subject='TestCase2', OwnerId = queue.Id, Status = 'Closed');
            Case case3 = new Case(Subject='TestCase3');
            insert new Case[] {case1, case2, case3};
            case1 = [SELECT CaseNumber FROM Case WHERE Id = :case1.Id];
            case2 = [SELECT CaseNumber FROM Case WHERE Id = :case2.Id];
            case3 = [SELECT CaseNumber FROM Case WHERE Id = :case3.Id];

            List<String> caseNumbers = new String[] {case1.CaseNumber, case2.CaseNumber, case3.CaseNumber};
            System.debug('caseNumbers=' + caseNumbers);
            Case[] cases = V1CaseCollector.getCasesByCaseNumbersAndOwnerId(caseNumbers, queue.Id);
            System.assertEquals(1, cases.size(), 'Incorrect numbers of cases.');
        }
    }

    static testMethod void closeCasesTest() {
        String testComment = 'Test comment';
        Case case1 = new Case(Subject='TestCase1');
        Case case2 = new Case(Subject='TestCase2');
        Case case3 = new Case(Subject='TestCase3');
        insert new Case[] {case1, case2, case3};
        case1 = [SELECT CaseNumber FROM Case WHERE Id = :case1.Id];
        case2 = [SELECT CaseNumber FROM Case WHERE Id = :case2.Id];
        case3 = [SELECT CaseNumber FROM Case WHERE Id = :case3.Id];
        V1CaseCollector.closeCases(new Case[] {case1, case2, case3}, testComment);

        Case newCase1 = [SELECT Status FROM Case WHERE Id = :case1.Id];
        System.assertEquals('Closed', newCase1.Status, 'Incorrect status of case.');
        CaseComment newComment1 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase1.Id];
        System.assertEquals(testComment, newComment1.CommentBody);
        Case newCase2 = [SELECT Status FROM Case WHERE Id = :case2.Id];
        System.assertEquals('Closed', newCase2.Status, 'Incorrect status of case.');
        CaseComment newComment2 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase2.Id];
        System.assertEquals(testComment, newComment2.CommentBody);
        Case newCase3 = [SELECT Status FROM Case WHERE Id = :case3.Id];
        System.assertEquals('Closed', newCase3.Status, 'Incorrect status of case.');
        CaseComment newComment3 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase3.Id];
        System.assertEquals(testComment, newComment3.CommentBody);
    }

    static testMethod void updateProcessInVersionOneInCaseTest() {
        Case case1 = new Case(Subject='TestCase1');
        Case case2 = new Case(Subject='TestCase2');
        Case case3 = new Case(Subject='TestCase3');
        insert new Case[] {case1, case2, case3};
        case1 = [SELECT V1Processing__c FROM Case WHERE Id = :case1.Id];
        case2 = [SELECT V1Processing__c FROM Case WHERE Id = :case2.Id];
        case3 = [SELECT V1Processing__c FROM Case WHERE Id = :case3.Id];

        System.assertEquals(false, case1.V1Processing__c, 'Incorrect start value.');
        System.assertEquals(false, case2.V1Processing__c, 'Incorrect start value.');
        System.assertEquals(false, case3.V1Processing__c, 'Incorrect start value.');

        V1CaseCollector.updateProcessInVersionOneInCase(new Case[] {case1, case3}, true);

        Case newCase1 = [SELECT V1Processing__c FROM Case WHERE Id = :case1.Id];
        Case newCase2 = [SELECT V1Processing__c FROM Case WHERE Id = :case2.Id];
        Case newCase3 = [SELECT V1Processing__c FROM Case WHERE Id = :case3.Id];
        System.assertEquals(true, newCase1.V1Processing__c, 'Incorrect value after first processing.');
        System.assertEquals(false, newCase2.V1Processing__c, 'Incorrect value after first processing.');
        System.assertEquals(true, newCase3.V1Processing__c, 'Incorrect value after first processing.');

        V1CaseCollector.updateProcessInVersionOneInCase(new Case[] {case1, case2, case3}, false);

        newCase1 = [SELECT V1Processing__c FROM Case WHERE Id = :case1.Id];
        newCase2 = [SELECT V1Processing__c FROM Case WHERE Id = :case2.Id];
        newCase3 = [SELECT V1Processing__c FROM Case WHERE Id = :case3.Id];
        System.assertEquals(false, newCase1.V1Processing__c, 'Incorrect value after second processing.');
        System.assertEquals(false, newCase2.V1Processing__c, 'Incorrect value after second processing.');
        System.assertEquals(false, newCase3.V1Processing__c, 'Incorrect value after second processing.');
    }

    static testMethod void getCasesWaitingOrPortingByOwnersTest() {
        String queueName = 'TestQueue';
        Group queue = new Group(Type='Queue', Name=queueName + '1');
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        Group queue2 = new Group(Type='Queue', Name=queueName+'2');
        insert queue2;
        QueueSobject sobj2 = new QueueSobject(QueueId = queue2.Id, SobjectType = 'Case');
        insert sobj2;
        Group queue3 = new Group(Type='Queue', Name=queueName+'3');
        insert queue3;
        QueueSobject sobj3 = new QueueSobject(QueueId = queue3.Id, SobjectType = 'Case');
        insert sobj3;

        System.runAs(createUser('test4356')){
            Case case1 = new Case(Subject='TestCase1', OwnerId = queue.Id);
            Case case2 = new Case(Subject='TestCase2', OwnerId = queue2.Id);
            Case case3 = new Case(Subject='TestCase3', OwnerId = queue3.Id);
            Case case4 = new Case(Subject='TestCase4', OwnerId = queue.Id, V1Processing__c = true);
            insert new Case[] {case1, case2, case3, case4};

            Case[] newCases = V1CaseCollector.getCasesWaitingOrPortingByOwners(new String[]{queue.Id, queue2.Id});
            System.assertEquals(3, newCases.size(), 'Incorrect number of case.');
            assertContains(case1, newCases, 'TestCase1 has to be in the list');
            assertContains(case2, newCases, 'TestCase2 has to be in the list');
            assertContains(case4, newCases, 'TestCase4 has to be in the list');
        }
    }
}