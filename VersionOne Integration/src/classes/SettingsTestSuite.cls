@isTest
private class SettingsTestSuite {

    static testMethod void constructorTest() {
        delete [SELECT Id FROM V1Settings__c];
        Settings s = new Settings();
        System.assertEquals('Escalated to VersionOne', s.getCommentBody(), 'Wrong default CommentBody.');
        System.assertEquals(null, s.getStoryQueueId(), 'Wrong default StoryQueueId.');
        System.assertEquals(null, s.getDefectQueueId(), 'Wrong default DefectQueueId.');
        System.assertEquals(null, s.getDestQueueId(), 'Wrong default DestQueueId.');
    }

    static testMethod void commentOnClosingTest() {
        Settings s = new Settings();
        s.setCommentOnClosing('');
        System.assertEquals(null, s.getCommentOnClosing(), 'Wrong CommentOnClosing.');
        s.setCommentOnClosing('test string');
        System.assertEquals('test string', s.getCommentOnClosing(), 'Wrong CommentOnClosing.');
    }

    static testMethod void commentBodyTest() {
        Settings s = new Settings();
        s.setCommentBody('');
        System.assertEquals(null, s.getCommentBody(), 'Wrong CommentBody.');
        s.setCommentBody('test string');
        System.assertEquals('test string', s.getCommentBody(), 'Wrong CommentBody.');
    }

    static testMethod void defectQueueIdTest() {
        Settings s = new Settings();
        s.setDefectQueueId('');
        System.assertEquals(null, s.getDefectQueueId(), 'Wrong DefectQueueId.');
        s.setDefectQueueId('test string');
        System.assertEquals('test string', s.getDefectQueueId(), 'Wrong DefectQueueId.');
    }

    static testMethod void storyQueueIdTest() {
        Settings s = new Settings();
        s.setStoryQueueId('');
        System.assertEquals(null, s.getStoryQueueId(), 'Wrong StoryQueueId.');
        s.setStoryQueueId('test string');
        System.assertEquals('test string', s.getStoryQueueId(), 'Wrong StoryQueueId.');
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
        System.assertEquals(null, s.getPath(), 'Wrong Path.');
        s.setPath('http://localhost');
        System.assertEquals('http://localhost/', s.getPath(), 'Wrong Path.');
        s.setPath('http://localhost/');
        System.assertEquals('http://localhost/', s.getPath(), 'Wrong Path.');
    }

    static testMethod void scheduleIdTest() {
        Settings s = new Settings();
        s.setScheduleId('');
        System.assertEquals(null, s.getScheduleId(), 'Wrong ScheduleId.');
        s.setScheduleId('wrong-id');
        System.assertEquals('wrong-id', s.getScheduleId(), 'Wrong ScheduleId.');
    }

    static testMethod void updateSettingsTest() {
        delete [SELECT Id FROM V1Settings__c];
        Settings s = new Settings();
        String path = 'http://localhost/';
        String userName = 'UserName';
        String password = 'password';
        String source = 'Source';
        String destQueueId = 'destQueueId';
        String defectQueueId = 'sourceQueueId';
        String storyQueueId = 'sourceQueueId';
        String comment = 'comment';
        String comment1 = 'comment1';

        s.setPath(path);
        s.setUserName(userName);
        s.setSource(source);
        s.setPassword(password);
        s.setCommentBody(comment);
        s.setCommentOnClosing(comment1);
        s.setDestQueueId(destQueueId);
        s.setDefectQueueId(defectQueueId);
        s.setStoryQueueId(storyQueueId);

        s.updateSettings();

        Settings s1 = new Settings();
        System.assertEquals(path, s1.getPath(), 'Wrong Path.');
        System.assertEquals(userName, s1.getUserName(), 'Wrong User Name.');
        System.assertEquals(password, s1.getPassword(), 'Wrong Password.');
        System.assertEquals(source, s1.getSource(), 'Wrong Source.');
        System.assertEquals(destQueueId, s1.getDestQueueId(), 'Wrong Dest Queue Id.');
        System.assertEquals(defectQueueId, s1.getDefectQueueId(), 'Wrong Defect Queue Id.');
        System.assertEquals(storyQueueId, s1.getStoryQueueId(), 'Wrong Story Queue Id.');
        System.assertEquals(comment, s1.getCommentBody(), 'Wrong Comment Body.');
        System.assertEquals(comment1, s1.getCommentOnClosing(), 'Wrong Comment on closing.');
    }

    static testMethod void validateTest() {
        Settings settingsData = Settings.getTestSettings();
        String[] res;

        //all fields is filled
        settingsData.setPath('http://localhost');
        settingsData.setUserName('user');
        settingsData.setSource('source');
        settingsData.setDefectQueueId('234612347614298476');
        settingsData.setStoryQueueId('999999999999999999');
        settingsData.setDestQueueId('453764567567455345');
        settingsData.setCommentBody('test comment');
        settingsData.setPassword('password');

        System.assertEquals(0, settingsData.validate().size(), 'Incorrect number of errors when all required parameters is filled.');

        //empty path
        settingsData.setPath('');
        res = settingsData.validate();
        System.assertEquals(1, res.size(), 'Incorrect number of errors when path is empty.');
        System.assert(res[0].contains('URL'), res[0] + ' - Incorrect message.');
        settingsData.setPath('http://localhost');

        //empty user name
        settingsData.setUserName('');
        res = settingsData.validate();
        System.assertEquals(1, res.size(), 'Incorrect number of errors when user name is empty.');
        System.assert(res[0].contains('User'), res[0] + ' - Incorrect message.');
        settingsData.setUserName('user');

        //empty password
        settingsData.setPassword('');
        res = settingsData.validate();
        System.assertEquals(1, res.size(), 'Incorrect number of errors.');
        System.assert(res[0].contains('Password'), res[0] + ' - Incorrect message.');
        settingsData.setPassword('password');

        //empty source
        settingsData.setSource('');
        res = settingsData.validate();
        System.assertEquals(1, res.size(), 'Incorrect number of errors when source is empty.');
        System.assert(res[0].contains('Source'), res[0] + ' - Incorrect message.');
        settingsData.setSource('source');

        //empty DefectQueueId
        settingsData.setDefectQueueId('');
        res = settingsData.validate();
        System.assertEquals(1, res.size(), 'Incorrect number of errors when DefectQueueId is empty.');
        System.assert(res[0].contains('Defect'), res[0] + ' - Incorrect message.');
        settingsData.setDefectQueueId('78234612347614298476');

        //empty StoryQueueId
        settingsData.setStoryQueueId('');
        res = settingsData.validate();
        System.assertEquals(1, res.size(), 'Incorrect number of errors when StoryQueueId is empty.');
        System.assert(res[0].contains(settingsData.getStoryQueueIdTitle()), res[0] + ' - Incorrect message.');
        settingsData.setStoryQueueId('111111111111');

        //empty DestQueueId
        settingsData.setDestQueueId(null);
        res = settingsData.validate();
        System.assertEquals(1, res.size(), 'Incorrect number of errors when DestQueueId is empty.');
        System.assert(res[0].contains('Destination'), res[0] + ' - Incorrect message.');
        settingsData.setDestQueueId('43564657586587456745');
    }
}