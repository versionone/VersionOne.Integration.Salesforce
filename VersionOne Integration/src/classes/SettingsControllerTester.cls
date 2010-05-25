@isTest
private class SettingsControllerTester {

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
        settingsData.setPassword(password);

        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setTestSourceId(sourceIdExpected);
        SettingsController controller = new SettingsController();
        controller.connector = connector;
        controller.settings = settingsData;
        controller.initSettings();
        controller.isSettingsCorrect = true;
        controller.saveSettings();

        System.assert(controller.isSaved, 'Settings have to be saved.');
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assertEquals('Settings has been saved.', controller.saveMessage, 'Incorrect save message.');
        System.assertEquals('info', controller.saveSeverity, 'Incorrect save severity.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');
        System.assertEquals('', controller.testSeverity, 'Incorrect test severity.');

        controller.saveSettings();

        //no source id
        connector.setTestSourceId(null);
        controller.saveSettings();
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assert(!controller.isSettingsCorrect, 'Settings have to not be correct.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');

        //settings was incorrect, and person submited data by hack
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

    static testMethod void updateProjectDataTester() {
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;

        System.assertEquals(false, controller.updateProjectData());//settings is not correct(no full filled)
        System.assertEquals(null, settingsData.getProjectId());

        settingsData.setPath('http://aaa.com/v1');
        settingsData.setUserName('user');
        settingsData.setSource('12345');
        settingsData.setPassword('password');
        controller.settings = settingsData;
        System.assert(controller.updateProjectData());
        System.assertEquals(V1ConnectorMock.defaultProjectId, settingsData.getProjectId());
        System.assertEquals('Main project', settingsData.getProjectName());

        System.assertEquals(false, controller.updateProjectData());
        System.assertEquals(V1ConnectorMock.defaultProjectId, settingsData.getProjectId());
        System.assertEquals('Main project', settingsData.getProjectName());
    }

    static testMethod void getMappingsTester() {
    	String projectName = 'Project name';
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setProjectId(V1ConnectorMock.defaultProjectId);
        settingsData.setProjectName(projectName);
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;

        List<SettingsController.Mapping> mappings = controller.getMappings();
        System.assertEquals(1, mappings.size(), 'Incorrect numbers of mapped projects.');
        System.assertEquals(projectName, mappings.get(0).getProjectName(), 'Incorrect mapped project.');
        System.assert(mappings.get(0).getIsVisible(), 'Incorrect "visible" status');
    }

    static testMethod void getVersionOneProjectsListTester() {
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
		controller.initSettings();
        List<SelectOption> options = controller.getVersionOneProjectsList();
        assertContainsOption('CI', options, 'Wrong option');
    }
}