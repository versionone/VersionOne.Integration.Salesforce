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

    static testMethod void validateRequiredFieldsTest() {
        SettingsController controller = new SettingsController();
        Test.setCurrentPage(new PageReference('apex/Settings_page'));
        IRequestor requestor = new RequestorMock('', 200);
        Settings settingsData = Settings.getTestSettings();
        Boolean result;

        controller.setRequestor(requestor);

        //all fields is filled
        settingsData.setPath('http://localhost');
        settingsData.setUserName('user');
        settingsData.setSource('source');
        settingsData.setSourceQueueId('78234612347614298476');
        settingsData.setDestQueueId('235453764567567455345');
        settingsData.setCommentBody('test comment');
        settingsData.setPassword('password');
        controller.settings = settingsData;
        System.assert(controller.validateRequiredFields(), 'Incorrect reuslt when all required parameters is filled.');

        //empty path
        settingsData.setPath('');
        controller.settings = settingsData;
        result = controller.validateRequiredFields();
        System.assert(!result, 'Incorrect result when path is empty.');
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors when path is empty.');
        System.assertEquals('URL is required field.', ApexPages.getMessages()[0].getSummary(), 'Incorrect message when path is empty.');
        settingsData.setPath('http://localhost');

        //empty SourceQueueId
        settingsData.setSourceQueueId('');
        System.assert(!controller.validateRequiredFields(), 'Incorrect reuslt when SourceQueueId is empty.');
        settingsData.setSourceQueueId('78234612347614298476');

        //empty DestQueueId
        settingsData.setDestQueueId(null);
        System.assert(!controller.validateRequiredFields(), 'Incorrect reuslt when DestQueueId is empty.');
        settingsData.setDestQueueId('43564657586587456745');

        //empty Comment
        settingsData.setCommentBody(null);
        System.assert(controller.validateRequiredFields(), 'Incorrect reuslt when CommentBody is empty.');
        settingsData.setCommentBody('test comment');

        //empty user name
        settingsData.setUserName('');
        result = controller.validateRequiredFields();
        System.assertEquals(4, ApexPages.getMessages().size(), 'Incorrect number of errors when user name is empty.');
        System.assert(!result, 'Incorrect result when user name is empty.');
		System.assertEquals('User name is required field.', ApexPages.getMessages()[3].getSummary(), 'Incorrect message when user name is empty.');
		settingsData.setUserName('user');

        //empty source
        settingsData.setSource('');
        controller.settings = settingsData;
        result = controller.validateRequiredFields();
        System.assertEquals(5, ApexPages.getMessages().size(), 'Incorrect number of errors when source is empty.');
        System.assert(!result, 'Incorrect result when source is empty.');
        System.assertEquals('Source is required field.', ApexPages.getMessages()[4].getSummary(), 'Incorrect message when source is empty.');
        settingsData.setSource('source');

        //empty password
        settingsData.setPassword('');
        result = controller.validateRequiredFields();
        System.assertEquals(6, ApexPages.getMessages().size(), 'Incorrect number of errors when user name is empty.');
        System.assert(!result, 'Incorrect result when password is empty.');
		System.assertEquals('Password is required field.', ApexPages.getMessages()[5].getSummary(), 'Incorrect message when user name is empty.');
		settingsData.setUserName('password');

        //empty path
        settingsData.setPath('');
        controller.settings = settingsData;
        System.assert(!controller.validateRequiredFields(), 'Incorrect reuslt when path is empty.');
        settingsData.setPath('http://localhost');
    }

    static testMethod void validateConnectionAndSourceTest() {
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        String sourceName = 'TestSource';
        String sourceIdExpected = '1010';
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceIdExpected + '" id="StorySource:' + sourceIdExpected + '" /></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        settingsData.setSource(sourceName);

        controller.setRequestor(requestor);
        controller.settings = settingsData;

        controller.initSettings();
        System.assert(controller.validateConnectionAndSource(), 'Incorrect result of test.');

        //incorrect credentials
        requestor = new RequestorMock('', 401);
        controller.setRequestor(requestor);
        try {
            controller.validateConnectionAndSource();
            System.assert(false, 'This place cannot be reached.');
        }catch(VersionOneException e){}

        //incorrect path
        requestor = new RequestorMock('', 500);
        controller.setRequestor(requestor);
        try {
            controller.validateConnectionAndSource();
            System.assert(false, 'This place cannot be reached.');
        }catch(VersionOneException e){}

        //unknown error
        requestor = new RequestorMock('', 303);
        controller.setRequestor(requestor);
        try {
            controller.validateConnectionAndSource();
            System.assert(false, 'This place cannot be reached.');
        }catch(VersionOneException e){}

        //source was not found
        requestor = new RequestorMock('<?xml version="1.0" encoding="UTF-8"?><Assets/>', 200);
        controller.setRequestor(requestor);
        try {
            controller.validateConnectionAndSource();
            System.assert(false, 'This place cannot be reached.');
        }catch(VersionOneException e){}
    }

    static testMethod void testSettingsTest() {
        // not fully filled settings
        String sourceName = 'TestSource';
        String sourceIdExpected = '1010';
        String userName = 'UserName';
        String source = 'Source';
        String path = 'http://localhost';
        String destQueueId = 'destQueueId';
        String sourceQueueId = 'sourceQueueId';
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceIdExpected + '" id="StorySource:' + sourceIdExpected + '" /></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();

        controller.setRequestor(requestor);
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
        settingsData.setSourceQueueId(sourceQueueId);
        settingsData.setPassword('password');
        controller.testSettings();

        System.assert(controller.isSettingsCorrect, 'Settings have to be correct.');
        System.assert(controller.isSettingsValidated, 'Settings have to be validated.');
        System.assertEquals('Settings correct.', controller.testMessage, 'Test message has to be not empty.');
        System.assertEquals('info', controller.testSeverity, 'Incorrect severity.');
        System.assert(!controller.isSaved, 'Settings has to be not saved.');

        //VersionOneException during test connection
        requestor = new RequestorMock(body, 401);
        controller.setRequestor(requestor);
        controller.testSettings();
        System.assert(!controller.isSettingsCorrect, 'Settings have to be not correct.');
        System.assert(controller.isSettingsValidated, 'Settings have to be validated.');
        System.assertEquals('Credentials is not correct.', controller.testMessage, 'Test message has to be not empty.');
        System.assertEquals('error', controller.testSeverity, 'Incorrect severity.');
        System.assert(!controller.isSaved, 'Settings has to be not saved.');

        //Unknown exception during test connection
        requestor = new RequestorMock(body, 200, new Exception[]{new NullPointerException()});
        controller.setRequestor(requestor);
        controller.testSettings();
        System.assert(!controller.isSettingsCorrect, 'Settings have to be not correct.');
        System.assert(controller.isSettingsValidated, 'Settings have to be validated.');
        System.assertEquals('Internal error:Script-thrown exception', controller.testMessage, 'Test message has to be not empty.');
        System.assertEquals('error', controller.testSeverity, 'Incorrect severity.');
        System.assert(!controller.isSaved, 'Settings has to be not saved.');
    }

    static testMethod void saveSettingsTester() {
    	// normal way
        String userName = 'UserName';
        String source = 'Source';
        String path = 'http://localhost';
        String destQueueId = 'destQueueId';
        String sourceQueueId = 'sourceQueueId';
        String password = 'password';
        String body = '';
        IRequestor requestor = new RequestorMock(body, 200);
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setPath(path);
        settingsData.setUserName(userName);
        settingsData.setSource(source);
        settingsData.setDestQueueId(destQueueId);
        settingsData.setSourceQueueId(sourceQueueId);
        settingsData.setPassword(password);

        controller.setRequestor(requestor);
        controller.settings = settingsData;
        controller.isSettingsCorrect = true;

        controller.saveSettings();

        System.assert(controller.isSaved, 'Settings have to be saved.');
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assertEquals('Settings has been saved.', controller.saveMessage, 'Incorrect save message.');
        System.assertEquals('info', controller.saveSeverity, 'Incorrect save severity.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');
        System.assertEquals('', controller.testSeverity, 'Incorrect test severity.');

        //settings was incorrect, and person submited data but hack or using mouse
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
}