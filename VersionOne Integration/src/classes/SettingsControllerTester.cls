/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
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