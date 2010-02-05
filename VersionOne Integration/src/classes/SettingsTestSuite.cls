@isTest
private class SettingsTestSuite {

    static testMethod void ConstructorTest() {
    	delete [SELECT Id FROM V1Settings__c];
        Settings s = new Settings();
        System.assertEquals('VersionOneUrl__c', s.getV1Url(), 'Wrong default V1 Url Field.');
        System.assertEquals('Escalated to VersionOne', s.getCommentBody(), 'Wrong default CommentBody.');
    }
}