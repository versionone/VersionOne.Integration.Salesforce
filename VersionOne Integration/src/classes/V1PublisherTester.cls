@isTest
private class V1PublisherTester {

    static testMethod void processCasesTest() {
        V1Publisher.resetAllData();
        //prepare queue
        String queueName = 'TestQueue1';
        Group queue = new Group(Type='Queue', Name=queueName);
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;

        System.runAs(createUser('test4356')){
            //prepare cases
            Case case1 = new Case(Subject = 'case1');
            Case case2 = new Case(Subject = 'case2');
            Case case3 = new Case(Subject = 'case3');
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
            String comment = 'test comment';
            String additionPath = 'assetdetail.v1?oid=Defect%3a';
            Settings testSettings = Settings.getTestSettings();
            testSettings.setDestQueueId(queue.Id);
            testSettings.setPath(path);
            testSettings.setCommentBody(comment);
            IRequestor requestor = new RequestorMock('', 200);
            IV1Connector connector = new V1ConnectorMock();
            ((V1ConnectorMock)connector).setCreatedDefectId(defectId);
			V1Publisher.setConnector(connector);
            V1Publisher.setSettings(testSettings);
            Map<String, String> projects = new Map<String, String>();

            V1Publisher.processCases(alreadyPortedCases, cases, sourceId, projects);

            Case newCase1 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case1.Id];
            System.assertEquals(path + additionPath + defectId, newCase1.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase1.OwnerId);
            CaseComment newComment = [SELECT CommentBody FROM CaseComment where ParentId = :newCase1.Id];
            System.assertEquals(comment, newComment.CommentBody);

            Case newCase2 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case2.Id];
            System.assertEquals(null, newCase2.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase2.OwnerId);
            CaseComment newComment2 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase2.Id];
            System.assertEquals(comment, newComment2.CommentBody);

            Case newCase3 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case3.Id];
            System.assertEquals(path + additionPath + defectId, newCase3.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase3.OwnerId);
            CaseComment newComment3 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase3.Id];
            System.assertEquals(comment, newComment2.CommentBody);
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