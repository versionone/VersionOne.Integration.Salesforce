@isTest
private class SettingsControllerTester {

    static testMethod void validateRequiredFieldsTest() {
        Settings settingsData = Settings.getTestSettings();

        //all fields is filled
        settingsData.setPath('http://localhost');
        settingsData.setUserName('user');
        settingsData.setSource('source');
        settingsData.setSourceQueueId('78234612347614298476');
        settingsData.setDestQueueId('78234612347614298476');
        settingsData.setCommentBody('test comment');
        System.assert(SettingsController.validateRequiredFields(settingsData), 'Incorrect reuslt when all required parameters is filled.');

        //empty SourceQueueId
        settingsData.setSourceQueueId('');
        System.assert(!SettingsController.validateRequiredFields(settingsData), 'Incorrect reuslt when SourceQueueId is empty.');
        settingsData.setSourceQueueId('78234612347614298476');

        //empty DestQueueId
        settingsData.setDestQueueId(null);
        System.assert(!SettingsController.validateRequiredFields(settingsData), 'Incorrect reuslt when DestQueueId is empty.');
        settingsData.setDestQueueId('78234612347614298476');

        //empty Comment
        settingsData.setCommentBody(null);
        System.assert(SettingsController.validateRequiredFields(settingsData), 'Incorrect reuslt when CommentBody is empty.');
        settingsData.setCommentBody('test comment');

        //empty source
        settingsData.setSource('');
        System.assert(!SettingsController.validateRequiredFields(settingsData), 'Incorrect reuslt when source is empty.');
        settingsData.setSource('source');

        //empty user name
        settingsData.setUserName('');
        System.assert(!SettingsController.validateRequiredFields(settingsData), 'Incorrect reuslt when user name is empty.');
        settingsData.setUserName('user');

        //empty path
        settingsData.setPath('');
        System.assert(!SettingsController.validateRequiredFields(settingsData), 'Incorrect reuslt when path is empty.');
        settingsData.setPath('http://localhost');
    }

    static testMethod void validateConnectionAndSourceTest() {
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        String sourceName = 'TestSource';
        String sourceIdExpected = '1010';
        String body = '<?xml version="1.0" encoding="UTF-8"?><Assets total="1" pageSize="2147483647" pageStart="0"><Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceIdExpected + '" id="StorySource:' + sourceIdExpected + '" /></Assets>';
        IRequestor requestor = new RequestorMock(body, 200);

        controller.setRequestor(requestor);
        controller.setSettings(settingsData);

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
}