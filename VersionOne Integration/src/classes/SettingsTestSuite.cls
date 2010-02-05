@isTest
private class SettingsTestSuite {

    static testMethod void constructorTest() {
        delete [SELECT Id FROM V1Settings__c];
        Settings s = new Settings();
        System.assertEquals('VersionOneUrl__c', s.getV1Url(), 'Wrong default V1 Url Field.');
        System.assertEquals('Escalated to VersionOne', s.getCommentBody(), 'Wrong default CommentBody.');
        System.assertEquals(null, s.getSourceQueueId(), 'Wrong default SourceQueueId.');
        System.assertEquals(null, s.getDestQueueId(), 'Wrong default DestQueueId.');
    }

    static testMethod void commentBodyTest() {
        Settings s = new Settings();
        s.setCommentBody('');
        System.assertEquals(null, s.getCommentBody(), 'Wrong CommentBody.');
        s.setCommentBody('test string');
        System.assertEquals('test string', s.getCommentBody(), 'Wrong CommentBody.');
    }

    static testMethod void sourceQueueIdTest() {
        Settings s = new Settings();
        s.setSourceQueueId('');
        System.assertEquals(null, s.getSourceQueueId(), 'Wrong SourceQueueId.');
        s.setSourceQueueId('test string');
        System.assertEquals('test string', s.getSourceQueueId(), 'Wrong SourceQueueId.');
    }

    static testMethod void destQueueIdTest() {
        Settings s = new Settings();
        s.setDestQueueId('');
        System.assertEquals(null, s.getDestQueueId(), 'Wrong DestQueueId.');
        s.setDestQueueId('test string');
        System.assertEquals('test string', s.getDestQueueId(), 'Wrong DestQueueId.');
    }

    static testMethod void pathTest() {
        Settings s = new Settings();
        s.setPath('');
        System.assertEquals('', s.getPath(), 'Wrong Path.');
        s.setPath('http://localhost');
        System.assertEquals('http://localhost/', s.getPath(), 'Wrong Path.');
        s.setPath('http://localhost/');
        System.assertEquals('http://localhost/', s.getPath(), 'Wrong Path.');
    }

    static testMethod void updateSettingsTest() {
        delete [SELECT Id FROM V1Settings__c];
        Settings s = new Settings();
        String userName = 'UserName';
        String source = 'Source';
        String path = 'http://localhost/';
        String password = 'password';
        String destQueueId = 'destQueueId';
        String sourceQueueId = 'sourceQueueId';
        String comment = 'comment';
        s.setPath(path);
        s.setUserName(userName);
        s.setSource(source);
        s.setPassword(password);
        s.setCommentBody(comment);
        s.setDestQueueId(destQueueId);
        s.setSourceQueueId(sourceQueueId);

        s.updateSettings();

        V1Settings__c mycs = V1Settings__c.getValues('V1Settings');
        System.assertEquals(path, mycs.Path__c, 'Wrong Path.');
        System.assertEquals(userName, mycs.UserName__c, 'Wrong User Name.');
        System.assertEquals(password, mycs.Password__c, 'Wrong Password.');
        System.assertEquals(source, mycs.Source__c, 'Wrong Source.');
        System.assertEquals(destQueueId, mycs.AssignedQueueId__c, 'Wrong Assigned Queue Id.');
        System.assertEquals(sourceQueueId, mycs.EscalateQueueId__c, 'Wrong Escalate Queue Id.');
        System.assertEquals(comment, mycs.CommentBody__c, 'Wrong Comment Body.');
    }
}