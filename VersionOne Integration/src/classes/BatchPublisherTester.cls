@isTest
private class BatchPublisherTester {

    static testMethod void calculateValueTest() {
    	Integer value1 = 13;
    	Integer value2 = 12;
    	Integer value3 = 1;
    	Integer value4 = 25;
        System.assertEquals(6, BatchPublisher.calculateValue(value1));
        System.assertEquals(6, BatchPublisher.calculateValue(value2));
        System.assertEquals(0, BatchPublisher.calculateValue(value3));
        System.assertEquals(12, BatchPublisher.calculateValue(value4));
    }

    static testMethod void getBatchDataWithIncorrectIdTest() {
    	Map<String, String> data = BatchPublisher.getBatchData('1234567');
    	System.assertEquals(null, data);
    }

    static testMethod void batchProcessTest() {
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

            String defectId = 'Defect:1699';
            Integer product_Id = 123;
            //String body = '<?xml version="1.0" encoding="UTF-8"?><Asset href="/VersionOne/rest-1.v1/Data/Defect/' + defectId +'/4596" id="Defect:' +defectId + ':4596"><Attribute name="Description">Case for testing</Attribute><Attribute name="Name">Test case</Attribute><Relation name="Source"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/1010" idref="StorySource:1010" /></Relation><Attribute name="Reference">00001227</Attribute><Relation name="Scope"><Asset href="/VersionOne/rest-1.v1/Data/Scope/123" idref="Scope:123" /></Relation></Asset>';
            String path = 'http://localhost/';
            String sourceName = 'TestSource';
            String sourceId = '1010';
            String caseName = '<Test case>';
            String caseDescription = 'Case for testing';
            String pComment = 'publishing comment';
            String cComment = 'closing comment';
            String additionPath = 'assetdetail.v1?oid=';

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
            V1ConnectorMock connector = new V1ConnectorMock();
            connector.createdWorkitemId = defectId;
            connector.setTestAlreadyExistedDefects(alreadyPortedCases);

		    BatchPublisher batch = new BatchPublisher(new ConnectionFactoryMock(testSettings, connector));

		    Test.startTest();
		    ID batchprocessid = Database.executeBatch(batch);
		    Test.stopTest();

            Case newCase1 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case1.Id];
            System.debug(newCase1);
            System.assertEquals(path + additionPath + EncodingUtil.urlEncode(defectId, 'UTF-8'), newCase1.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase1.OwnerId);
            CaseComment newComment = [SELECT CommentBody FROM CaseComment where ParentId = :newCase1.Id];
            System.assertEquals(pComment, newComment.CommentBody);

            Case newCase2 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case2.Id];
            System.debug(newCase1);
            System.assertEquals(null, newCase2.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase2.OwnerId);
            List<CaseComment> newComment2 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase2.Id];
            System.assertEquals(0, newComment2.size(), 'Incorrect number of comments for case 2');

            Case newCase3 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case3.Id];
            System.debug(newCase3);
            System.assertEquals(path + additionPath + EncodingUtil.urlEncode(defectId, 'UTF-8'), newCase3.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase3.OwnerId);
            CaseComment newComment3 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase3.Id];
            System.assertEquals(pComment, newComment3.CommentBody);

            Case newCase4 = [SELECT CaseNumber, VersionOneUrl__c, OwnerId FROM Case WHERE Id = :case4.Id];
            System.debug(newCase4);
            System.assertEquals(path + additionPath + EncodingUtil.urlEncode(defectId, 'UTF-8'), newCase4.VersionOneUrl__c);
            System.assertEquals(queue.Id, newCase4.OwnerId);
            CaseComment newComment4 = [SELECT CommentBody FROM CaseComment where ParentId = :newCase4.Id];
            System.assertEquals(pComment, newComment4.CommentBody);

            Map<String, String> batchData = BatchPublisher.getBatchData(batchprocessid);
            System.assertEquals('Completed', batchData.get('Status'));
            System.assertEquals('0', batchData.get('NumberOfErrors'));
            System.assertEquals(false, BatchPublisher.isRan(batchprocessid));

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