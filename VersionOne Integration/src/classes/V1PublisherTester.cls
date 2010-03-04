@isTest
private class V1PublisherTester {

    static testMethod void publishTest() {
        //prepare queue
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        String queueNameD = 'TestQueue2';
        Group queueD = new Group(Type='Queue', Name=queueNameD);
        insert queueD;
        QueueSobject sobjD = new QueueSobject(QueueId = queueD.Id, SobjectType = 'Case');
        insert sobjD;

        String queueNameS = 'TestQueue3';
        Group queueS = new Group(Type='Queue', Name=queueNameS);
        insert queueS;
        QueueSobject sobjS = new QueueSobject(QueueId = queueS.Id, SobjectType = 'Case');
        insert sobjS;

        System.runAs(createUser('test4356')){
            //prepare cases
            Case case1 = new Case(Subject = 'case1', OwnerId = queueD.Id);
            Case case2 = new Case(Subject = 'case2', OwnerId = queue.Id);
            Case case3 = new Case(Subject = 'case3', OwnerId = queueD.Id);
            Case case4 = new Case(Subject = 'case4', OwnerId = queueD.Id);
            insert new Case[]{case1, case2, case3, case4};

            case1 = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case1.Id];
            case2 = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case2.Id];
            case3 = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case3.Id];
            case4 = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case4.Id];

            Map<String, Boolean> alreadyPortedCases = new Map<String, Boolean> {case2.CaseNumber => true};

            Integer defectId = 1699;
            Integer product_Id = 123;
            //String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/' + defectId +'/4596" id="Defect:' +defectId + ':4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
            String path = 'http://localhost/';
            String sourceName = 'TestSource';
            String sourceId = '1010';
            String caseName = '<Test case>';
            String caseDescription = 'Case for testing';
            String pComment = 'publishing comment';
            String cComment = 'closing comment';

            String expectedSendBody = '<Asset>' +
                                '<Relation act="set" name="Scope">' +
                                    '<Asset idref="Scope:' + product_Id + '"/>' +
                                '</Relation>' +
                                '<Attribute act="set" name="Name">&lt;Test case&gt;</Attribute>' +
                                '<Attribute act="set" name="Reference">' + case1.CaseNumber +'</Attribute>' +
                                '<Attribute act="set" name="Description">' + caseDescription + '</Attribute>' +
                                '<Relation act="set" name="Source">' +
                                    '<Asset idref="StorySource:' + sourceId + '"/>' +
                                '</Relation>' +
                            '</Asset>';
            String additionPath = 'assetdetail.v1?oid=Defect%3a';

            Settings testSettings = Settings.getTestSettings();
            testSettings.setPath(path);
            testSettings.setUserName('user');
            testSettings.setPassword('11111');
            testSettings.setSource(sourceName);
            testSettings.setSourceId(sourceId);
            testSettings.setDestQueueId(queue.Id);
            testSettings.setDefectQueueId(queueD.Id);
            testSettings.setStoryQueueId(queueS.Id);
            testSettings.setCommentBody(pComment);
            testSettings.setCommentOnClosing(cComment);
            IRequestor requestor = new RequestorMock('', 200);
            V1ConnectorMock connector = new V1ConnectorMock();
            connector.setCreatedDefectId(defectId);
            connector.setTestAlreadyExistedDefects(alreadyPortedCases);
            V1Publisher.settings = testSettings;
            V1Publisher.connector = connector;

            Test.startTest();
            V1Publisher.publish();
            Test.stopTest();

            Case newCase1 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case1.Id];
            System.assertEquals(path + additionPath + defectId, newCase1.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase1.OwnerId);
            CaseComment newComment = [SELECT CommentBody FROM CaseComment where ParentId = :newCase1.Id];
            System.assertEquals(pComment, newComment.CommentBody);

            Case newCase2 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case2.Id];
            System.assertEquals(null, newCase2.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase2.OwnerId);
            List<CaseComment> newComment2 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase2.Id];
            System.assertEquals(0, newComment2.size(), 'Incorrect number of comments for case 2');

            Case newCase3 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case3.Id];
            System.assertEquals(path + additionPath + defectId, newCase3.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase3.OwnerId);
            CaseComment newComment3 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase3.Id];
            System.assertEquals(pComment, newComment3.CommentBody);

            Case newCase4 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case4.Id];
            System.assertEquals(path + additionPath + defectId, newCase4.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase4.OwnerId);
            CaseComment newComment4 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase4.Id];
            System.assertEquals(pComment, newComment4.CommentBody);
        }
    }

    static testMethod void exceptionInPublishTest() {
        //prepare queue
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        String queueName2 = 'TestQueue2';
        Group queue2 = new Group(Type='Queue', Name=queueName2);
        insert queue2;
        QueueSobject sobj2 = new QueueSobject(QueueId = queue2.Id, SobjectType = 'Case');
        insert sobj2;

        String queueName3 = 'TestQueue3';
        Group queue3 = new Group(Type='Queue', Name=queueName3);
        insert queue3;
        QueueSobject sobj3 = new QueueSobject(QueueId = queue3.Id, SobjectType = 'Case');
        insert sobj3;

        System.runAs(createUser('test4356')){
            //prepare cases
            Case case1 = new Case(Subject = 'case1', OwnerId = queue2.Id);
            Case case2 = new Case(Subject = 'case2', OwnerId = queue2.Id);
            Case case3 = new Case(Subject = 'case3', OwnerId = queue2.Id);
            insert new Case[]{case1, case2, case3};
            case1 = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case1.Id];
            case2 = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case2.Id];
            case3 = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c FROM Case WHERE Id = :case3.Id];

            Map<String, Boolean> alreadyPortedCases = new Map<String, Boolean>();
            alreadyPortedCases.put(case2.CaseNumber, true);
            List<Case> cases = new Case[]{case1, case2, case3};

            Integer defectId = 1699;
            //String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/' + defectId +'/4596" id="Defect:' +defectId + ':4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
            String sourceName = 'TestSource';
            String sourceId = '1010';
            String productId = '123';
            String caseName = '<Test case>';
            String caseDescription = 'Case for testing';
            String path = 'http://localhost/';
            String userName = 'userName';
            String comment = 'test comment';
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
            String additionPath = 'assetdetail.v1?oid=Defect%3a';
            Settings testSettings = Settings.getTestSettings();
            testSettings.setDestQueueId(queue.Id);
            testSettings.setDefectQueueId(queue2.Id);
            testSettings.setStoryQueueId(queue3.Id);
            testSettings.setPath(path);
            testSettings.setCommentBody(comment);
            testSettings.setSourceId(sourceId);
            testSettings.setSource(sourceName);
            testSettings.setUserName(userName);
            V1Publisher.settings = testSettings;
            IRequestor requestor = new RequestorMock('', 200);
            V1ConnectorMock connector = new V1ConnectorMock();
            connector.setCreatedDefectId(defectId);
            connector.setTestAlreadyExistedDefects(alreadyPortedCases);
            connector.enableException(new V1RequestException('Just test exception.'));
            V1Publisher.connector = connector;

            Test.startTest();
            V1Publisher.publish();
            Test.stopTest();

            Case newCase1 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case1.Id];
            System.assertEquals(case1.VersionOneUrl__c, newCase1.VersionOneUrl__c);
            System.assertEquals(case1.OwnerId, newCase1.OwnerId);
            List<CaseComment> newComment1 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase1.Id];
            System.assertEquals(0, newComment1.size(), 'Incorrect number of comments for case 1');

            Case newCase2 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case2.Id];
            System.assertEquals(case2.VersionOneUrl__c, newCase2.VersionOneUrl__c);
            System.assertEquals(case2.OwnerId, newCase2.OwnerId);
            List<CaseComment> newComment2 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase2.Id];
            System.assertEquals(0, newComment2.size(), 'Incorrect number of comments for case 2');

            Case newCase3 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case3.Id];
            System.assertEquals(case3.VersionOneUrl__c, newCase3.VersionOneUrl__c);
            System.assertEquals(case3.OwnerId, newCase3.OwnerId);
            List<CaseComment> newComment3 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase3.Id];
            System.assertEquals(0, newComment3.size(), 'Incorrect number of comments for case 3');
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