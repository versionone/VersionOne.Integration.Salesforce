@isTest
private class SettingsTestSuite {

    static testMethod void pathTest() {
        Settings s = new Settings();
        s.setPath('');
        System.assertEquals(null, s.getPath(), 'Wrong Path.');
        s.setPath('http://localhost');
        System.assertEquals('http://localhost/', s.getPath(), 'Wrong Path.');
        s.setPath('http://localhost/');
        System.assertEquals('http://localhost/', s.getPath(), 'Wrong Path.');
    }


    static testMethod void updateSettingsTest() {
        delete [SELECT Id FROM V1Settings__c];
        Settings s = new Settings();
        String path = 'http://localhost/';
        String userName = 'UserName';
        String password = 'password';
        String source = 'Source';


        s.setPath(path);
        s.setUserName(userName);
        s.setSource(source);
        s.setPassword(password);

        s.updateSettings();

        Settings s1 = new Settings();
        System.assertEquals(path, s1.getPath(), 'Wrong Path.');
        System.assertEquals(userName, s1.getUserName(), 'Wrong User Name.');
        System.assertEquals(password, s1.getPassword(), 'Wrong Password.');
        System.assertEquals(source, s1.getSource(), 'Wrong Source.');
    }

    static testMethod void validateTest() {
        Settings settingsData = Settings.getTestSettings();
        String[] res;

        //all fields is filled
        settingsData.setPath('http://localhost');
        settingsData.setUserName('user');
        settingsData.setSource('source');
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
    }
}