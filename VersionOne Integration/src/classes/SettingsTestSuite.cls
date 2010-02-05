@isTest
private class SettingsTestSuite {

    static testMethod void ConstructorTest() {
    	delete [SELECT Id FROM V1Settings__c];
        Settings s = new Settings();
        System.assertEquals('VersionOneUrl__c', s.getV1Url(), 'Wrong default V1 Url Field.');
        System.assertEquals('Escalated to VersionOne', s.getCommentBody(), 'Wrong default CommentBody.');
        System.assertEquals(null, s.getSourceQueueId(), 'Wrong default SourceQueueId.');
        System.assertEquals(null, s.getDestQueueId(), 'Wrong default DestQueueId.');
    }

    static testMethod void CommentBodyTest() {
        Settings s = new Settings();
        s.setCommentBody('');
        System.assertEquals(null, s.getCommentBody(), 'Wrong CommentBody.');
        s.setCommentBody('test string');
        System.assertEquals('test string', s.getCommentBody(), 'Wrong CommentBody.');
    }

    static testMethod void SourceQueueIdTest() {
        Settings s = new Settings();
        s.setSourceQueueId('');
        System.assertEquals(null, s.getSourceQueueId(), 'Wrong SourceQueueId.');
        s.setSourceQueueId('test string');
        System.assertEquals('test string', s.getSourceQueueId(), 'Wrong SourceQueueId.');
    }

    static testMethod void DestQueueIdTest() {
        Settings s = new Settings();
        s.setDestQueueId('');
        System.assertEquals(null, s.getDestQueueId(), 'Wrong DestQueueId.');
        s.setDestQueueId('test string');
        System.assertEquals('test string', s.getDestQueueId(), 'Wrong DestQueueId.');
    }
}