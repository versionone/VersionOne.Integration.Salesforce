@isTest
private class SettingsControllerTester {

    static testMethod void getQueueListTest() {
        String queueName = 'TestQueue';
        Group queue1 = new Group(Type='Queue', Name=queueName+'1');
        insert queue1;
        Group queue2 = new Group(Type='Queue', Name=queueName+'2');
        insert queue2;
        Group queue3 = new Group(Name=queueName+'3');
        insert queue3;
        List<SelectOption> options = SettingsController.getQueueList();
        assertContainsOption(queueName+'1', options, 'Wrong option 1');
        assertContainsOption(queueName+'1', options, 'Wrong option 2');
    }

    static void assertContainsOption(String name, List<SelectOption> actuals, String msg) {
        Boolean contains = false;
        for (SelectOption o : actuals) {
            if (o.getLabel() == name) {
                contains = true;
                break;
            }
        }
        System.assert(contains, msg + '\n  ' + name + ' not found in ' + actuals);
    }

    static testMethod void validateSettingsTest() {
        SettingsController controller = new SettingsController();
        Test.setCurrentPage(new PageReference('apex/Settings_page'));
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();

        //all fields is filled
        settingsData.setPath('http://localhost');
        settingsData.setUserName('user');
        settingsData.setSource('source');
        settingsData.setDefectQueueId('78234612347614298476');
        settingsData.setStoryQueueId('1111111111111111111');
        settingsData.setDestQueueId('235453764567567455345');
        settingsData.setCommentBody('test comment');
        settingsData.setPassword('password');
        controller.settings = settingsData;
        System.assert(controller.validateSettings(), 'Incorrect reuslt when all required parameters is filled.');
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of errors when all required parameters is filled.');

        //empty path
        settingsData.setPath('');
        controller.settings = settingsData;
        System.assert(!controller.validateSettings(), 'Incorrect result when path is empty.');
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors when path is empty.');
        System.assert(ApexPages.getMessages()[0].getSummary().contains('URL'), 'Incorrect message when path is empty.');
        settingsData.setPath('http://localhost');
    }

    static testMethod void validateConnectionAndSourceTest() {
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        String sourceName = 'TestSource';
        String sourceIdExpected = '1010';
        settingsData.setSource(sourceName);
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setTestSourceId(sourceIdExpected);
        controller.connector = connector;
        controller.settings = settingsData;
        controller.initSettings();
        controller.validateConnectionAndSource();

        //thorw exception
        connector.enableException(new V1RequestException('Just test exception.'));
        try {
            controller.validateConnectionAndSource();
            System.assert(false, 'This place cannot be reached.');
        }catch(V1RequestException e){}

        //source was not found
        connector.setTestSourceId(null);
        try {
            controller.validateConnectionAndSource();
            System.assert(false, 'This place cannot be reached.');
        }catch(V1RequestException e){}
    }

    static testMethod void testSettingsTest() {
        // not fully filled settings
        String sourceName = 'TestSource';
        String sourceIdExpected = '1010';
        String userName = 'UserName';
        String source = 'Source';
        String path = 'http://localhost';
        String destQueueId = 'destQueueId';
        String defectQueueId = 'defectQueueId';
        String storyQueueId = 'storyQueueId';
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setTestSourceId(sourceIdExpected);
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = connector;
        controller.settings = settingsData;
        controller.testSettings();
        System.assert(!controller.isSettingsCorrect, 'Settings have to be not correct.');
        System.assert(!controller.isSettingsValidated, 'Settings have to be not validated.');
        System.assertEquals('', controller.testMessage, 'Test message has to be empty.');

        //all data are correct
        settingsData.setPath(path);
        settingsData.setUserName(userName);
        settingsData.setSource(source);
        settingsData.setDestQueueId(destQueueId);
        settingsData.setDefectQueueId(defectQueueId);
        settingsData.setStoryQueueId(storyQueueId);
        settingsData.setPassword('password');
        controller.testSettings();
        System.assert(controller.isSettingsCorrect, 'Settings have to be correct.');
        System.assert(controller.isSettingsValidated, 'Settings have to be validated.');
        System.assertEquals('Settings correct.', controller.testMessage, 'Incorrect message after testing.');
        System.assertEquals('info', controller.testSeverity, 'Incorrect severity.');
        System.assert(!controller.isSaved, 'Settings has to be not saved.');

        //V1RequestorException during test connection
        connector.enableException(new V1RequestException('TEST-TEST'));
        controller.testSettings();
        System.assert(!controller.isSettingsCorrect, 'Settings have to be not correct.');
        System.assert(controller.isSettingsValidated, 'Settings have to be validated.');
        System.assertEquals('TEST-TEST', controller.testMessage, 'Incorrect message after testing.');
        System.assertEquals('error', controller.testSeverity, 'Incorrect severity.');
        System.assert(!controller.isSaved, 'Settings has to be not saved.');

        //Unknown exception during test connection
        connector.enableException(new NullPointerException());
        controller.testSettings();
        System.assert(!controller.isSettingsCorrect, 'Settings have to be not correct.');
        System.assert(controller.isSettingsValidated, 'Settings have to be validated.');
        System.assertEquals('Script-thrown exception', controller.testMessage, 'Incorrect message after testing.');
        System.assertEquals('error', controller.testSeverity, 'Incorrect severity.');
        System.assert(!controller.isSaved, 'Settings has to be not saved.');

        //source is null
        System.debug('//source is null');
        connector.enableException(null);
        connector.setTestSourceId(null);
        controller.testSettings();
        System.assert(!controller.isSettingsCorrect, 'Settings have to be not correct.');
        System.assert(controller.isSettingsValidated, 'Settings have to be validated.');
        System.assert(controller.testMessage.toLowerCase().contains('source'), 'Incorrect message after testing: ' + controller.testMessage);
        System.assertEquals('error', controller.testSeverity, 'Incorrect severity.');
        System.assert(!controller.isSaved, 'Settings has to be not saved.');
    }

    static testMethod void saveSettingsTester() {
        // normal way
        String userName = 'UserName';
        String source = 'Source';
        String path = 'http://localhost';
        String destQueueId = 'destQueueId';
        String defectQueueId = 'defectQueueId';
        String storyQueueId = 'storyQueueId';
        String password = 'password';
        String sourceIdExpected = '1010';
        Settings settingsData = Settings.getTestSettings();
        settingsData.setPath(path);
        settingsData.setUserName(userName);
        settingsData.setSource(source);
        settingsData.setDestQueueId(destQueueId);
        settingsData.setDefectQueueId(defectQueueId);
        settingsData.setStoryQueueId(storyQueueId);
        settingsData.setPassword(password);
        settingsData.setScheduleId('wrong-id');

        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setTestSourceId(sourceIdExpected);
        SettingsController controller = new SettingsController();
        controller.connector = connector;
        controller.settings = settingsData;
        controller.initSettings();
        controller.isSettingsCorrect = true;
        controller.isSyncEnabled = true;
        controller.saveSettings();

        System.assert(controller.isSaved, 'Settings have to be saved.');
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assertEquals('Settings has been saved.', controller.saveMessage, 'Incorrect save message.');
        System.assertEquals('info', controller.saveSeverity, 'Incorrect save severity.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');
        System.assertEquals('', controller.testSeverity, 'Incorrect test severity.');

        String scheduleId = settingsData.getScheduleId();
        System.assertNotEquals(null, scheduleId, 'Schedule have to be created.');
        System.assert(SyncSchedule.isScheduled(scheduleId), 'Schedule don\'t exist.');

        controller.isSyncEnabled = false;
        controller.saveSettings();

        System.assert(settingsData.getScheduleId() == null , 'Schedule ID must be empty.');
        System.assert(!SyncSchedule.isScheduled(scheduleId), 'Schedule have to be removed.');

        //no source id
        connector.setTestSourceId(null);
        controller.saveSettings();
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assert(!controller.isSettingsCorrect, 'Settings have to not be correct.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');

        //settings was incorrect, and person submited data by hack
        controller.isSettingsCorrect = false;
        controller.saveSettings();
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors when path is empty.');
        System.assertEquals('Settings is not correct or was not validated.', ApexPages.getMessages()[0].getSummary(), 'Incorrect message when settings is not validated.');

        // not all required fields filled
        settingsData.setPath('');
        controller.settings = settingsData;
        controller.saveSettings();
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assert(!controller.isSettingsCorrect, 'Settings have to not be correct.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');
    }

    static testMethod void updateScheduleTest() {
        SettingsController c = new SettingsController();
        Settings s = Settings.getTestSettings();
        c.settings = s;
        c.isSyncEnabled = true;
        String newId = c.updateSchedule();

        System.assert(newId != null, 'New ID must be not null');
        System.assert(SyncSchedule.isScheduled(newId), 'job must be scheduled');

        s.setScheduleId(newId);
        c.isSyncEnabled = false;
        String newId2 = c.updateSchedule();

        System.assert(newId2 == null, 'Second ID must be null');
        System.assert(!SyncSchedule.isScheduled(newId), 'First job must be unscheduled');
    }
}