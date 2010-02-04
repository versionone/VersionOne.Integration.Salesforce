@isTest
private class SettingsControllerTester {

    static testMethod void validateRequiredFieldsTest() {
        SettingsController controller = new SettingsController();
        IRequestor requestor = new RequestorMock('', 200);
        Settings settingsData = Settings.getTestSettings();

        controller.setRequestor(requestor);
        controller.setSettings(settingsData);

        //empty path
        settingsData.setPath('');
        settingsData.setUserName('');
        settingsData.setSource('');
        System.assert(!controller.validateRequiredFields(), 'Incorrect reuslt when path is empty.');

        //empty user name
        settingsData.setPath('http://localhost');
        settingsData.setUserName('');
        settingsData.setSource('');
        System.assert(!controller.validateRequiredFields(), 'Incorrect reuslt when user name is empty.');

        //empty source
        settingsData.setPath('http://localhost');
        settingsData.setUserName('user');
        settingsData.setSource('');
        System.assert(!controller.validateRequiredFields(), 'Incorrect reuslt when source is empty.');

        //all fields is filled
        settingsData.setPath('http://localhost');
        settingsData.setUserName('user');
        settingsData.setSource('source');
        settingsData.setSourceQueueId('78234612347614298476');
        settingsData.setDestQueueId('78234612347614298476');
        System.assert(controller.validateRequiredFields(), 'Incorrect reuslt when all required parameters is filled.');
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