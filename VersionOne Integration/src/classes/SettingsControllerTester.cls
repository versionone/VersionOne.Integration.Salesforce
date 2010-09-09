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

    static testMethod void saveSettingsTest() {
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
        System.assertEquals('Settings have been saved.', controller.saveMessage, 'Incorrect save message.');
        System.assertEquals('info', controller.saveSeverity, 'Incorrect save severity.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');
        System.assertEquals('', controller.testSeverity, 'Incorrect test severity.');

        System.assertEquals(sourceIdExpected, settingsData.getSourceId(), 'Incorrect source id.');
        System.assertEquals(V1ConnectorMock.MEMBER_ID, settingsData.getCurrentMemberId(), 'Incorrect member id.');

        //controller.saveSettings();

        //no source id
        connector.setTestSourceId(null);
        controller.saveSettings();
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assert(!controller.isSettingsCorrect, 'Settings have to not be correct.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');

        //settings was incorrect, and person submited data by hack
        controller.saveSettings();
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors when path is empty.');
        System.assertEquals('Settings are not correct, or validation could not be completed successfully.', ApexPages.getMessages()[0].getSummary(), 'Incorrect message when settings is not validated.');

        // not all required fields filled
        settingsData.setPath('');
        controller.settings = settingsData;
        controller.saveSettings();
        System.assert(!controller.isSettingsValidated, 'Settings have to not be validated.');
        System.assert(!controller.isSettingsCorrect, 'Settings have to not be correct.');
        System.assertEquals('', controller.testMessage, 'Incorrect test message.');
    }

    static testMethod void updateProjectDataTest() {
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

    static testMethod void getMappingsTest() {
		for (MappingV1ProjectsToSFProducts__c obj :
		    [select Id from MappingV1ProjectsToSFProducts__c]) {
		    delete obj;
		}

    	String projectName1 = 'Project Name 1';
    	String productName1 = 'Product Name 1';
    	String projectToken1 = 'Scope:1234';
    	String productId1 = 'GDS';
    	MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
    	mappingData1.SFProductId__c = productId1;
    	mappingData1.SFProductName__c = productName1;
    	mappingData1.V1ProjectToken__c = projectToken1;
    	mappingData1.V1ProjectName__c = projectName1;
    	insert mappingData1;
    	System.debug('----mappingData1.id' + mappingData1.id);

        String projectName = 'Project name';
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setProjectId(V1ConnectorMock.defaultProjectId);
        settingsData.setProjectName(projectName);
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        List<ProjectProductMapping> mappings = controller.getMappings();
        System.assertEquals(2, mappings.size(), 'Incorrect numbers of mapped projects.');
        System.assertEquals(projectName, mappings.get(0).projectName, 'Incorrect mapped project.');
        System.assert(mappings.get(0).IsVisible, 'Incorrect "visible" status');
        System.assertEquals(projectName1, mappings.get(1).projectName, 'Incorrect mapped project.');
        System.assert(!mappings.get(1).IsVisible, 'Incorrect "visible" status');
    }

    static testMethod void getMappingsWithOnlyDefaultTest() {
		for (MappingV1ProjectsToSFProducts__c obj :
		    [select Id from MappingV1ProjectsToSFProducts__c]) {
		    delete obj;
		}

        String projectName = 'Project name';
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setProjectId(V1ConnectorMock.defaultProjectId);
        settingsData.setProjectName(projectName);
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        List<ProjectProductMapping> mappings = controller.getMappings();
        System.assertEquals(1, mappings.size(), 'Incorrect numbers of mapped projects.');
        System.assertEquals(projectName, mappings.get(0).projectName, 'Incorrect mapped project.');
        System.assert(mappings.get(0).IsVisible, 'Incorrect "visible" status');
    }

    static testMethod void getProductListTest() {
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.Case.fields.Product__c;
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        List<Selectoption> options = controller.getProductList();
        System.assertEquals(ple.size(), options.size(), 'Incorrect amount of products options');
    }

    static testMethod void getVersionOneProjectsListTest() {
        SettingsController controller = new SettingsController();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        controller.initSettings();
        List<SelectOption> options = controller.getVersionOneProjectsList();
        assertContainsOption('CI', options, 'Wrong option');
    }

    static testMethod void updateProjectMappingWithErrorTest() {
		for (MappingV1ProjectsToSFProducts__c obj :
		    [select Id from MappingV1ProjectsToSFProducts__c]) {
		    delete obj;
		}

    	String projectName1 = 'Project Name 1';
    	String productName1 = 'Product Name 1';
    	String projectToken1 = 'Scope:1234';
    	String productId1 = 'GDS';
    	MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
    	mappingData1.SFProductId__c = productId1;
    	mappingData1.SFProductName__c = productName1;
    	mappingData1.V1ProjectToken__c = projectToken1;
    	mappingData1.V1ProjectName__c = projectName1;
    	insert mappingData1;

        SettingsController controller = new SettingsController();
		controller.initSettings();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        ApexPages.currentPage().getParameters().put('mappingId', 'a03A00000014Nt9IAE');
        controller.currentMapping = new ProjectProductMapping(projectName1, true, productName1);
        controller.currentMapping.projectToken = projectToken1;
        controller.currentMapping.productId = productId1;
        controller.updateProjectMapping();
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors when product id already used.');
    }

    static testMethod void updateProjectMappingWithoutSecurityCodeTest() {
		for (MappingV1ProjectsToSFProducts__c obj :
		    [select Id from MappingV1ProjectsToSFProducts__c]) {
		    delete obj;
		}

    	String projectName1 = 'CI';
    	String productName1 = 'GDS';
    	String projectToken1 = 'Scope:1081';
    	String productId1 = 'GDS';
    	MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
    	mappingData1.SFProductId__c = productId1;
    	mappingData1.SFProductName__c = productName1;
    	mappingData1.V1ProjectToken__c = projectToken1;
    	mappingData1.V1ProjectName__c = projectName1;
    	insert mappingData1;

        SettingsController controller = new SettingsController();
		controller.initSettings();
		controller.code = '123';//incorrect security code
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        ApexPages.currentPage().getParameters().put('mappingId', mappingData1.Id);
        controller.currentMapping = new ProjectProductMapping(projectName1 + 'up', true, productName1 + 'up');
        controller.currentMapping.projectToken = projectToken1;
        controller.currentMapping.productId = productId1+ 'up';
        controller.updateProjectMapping();
        MappingV1ProjectsToSFProducts__c resultMapping = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c where id=:mappingData1.Id];
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors.');
        System.assertEquals(projectName1, resultMapping.V1ProjectName__c, 'Incorrect project name for updated mapping with incorrect code.');
        System.assertEquals(projectToken1, resultMapping.V1ProjectToken__c, 'Incorrect project token for updated mapping with incorrect code.');
        System.assertEquals(productName1, resultMapping.SFProductName__c, 'Incorrect project token for updated mapping with incorrect code.');
    }

    static testMethod void updateProjectMappingWithSameMappingIdTest() {
		for (MappingV1ProjectsToSFProducts__c obj :
		    [select Id from MappingV1ProjectsToSFProducts__c]) {
		    delete obj;
		}

    	String projectName1 = 'CI';
    	String productName1 = 'GDS';
    	String projectToken1 = 'Scope:1081';
    	String productId1 = 'GDS';
    	MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
    	mappingData1.SFProductId__c = productId1;
    	mappingData1.SFProductName__c = productName1;
    	mappingData1.V1ProjectToken__c = projectToken1;
    	mappingData1.V1ProjectName__c = projectName1;
    	insert mappingData1;

        SettingsController controller = new SettingsController();
		controller.initSettings();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        ApexPages.currentPage().getParameters().put('mappingId', mappingData1.Id);
        controller.currentMapping = new ProjectProductMapping(projectName1 + 'up', true, productName1 + 'up');
        controller.currentMapping.projectToken = projectToken1;
        controller.currentMapping.productId = productId1+ 'up';
        controller.updateProjectMapping();
        MappingV1ProjectsToSFProducts__c resultMapping = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c where id=:mappingData1.Id];
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of errors when product id already used.');
        System.assertEquals(projectName1, resultMapping.V1ProjectName__c, 'Incorrect project name for updated mapping.');
        System.assertEquals(projectToken1, resultMapping.V1ProjectToken__c, 'Incorrect project token for updated mapping.');
        System.assertEquals(productName1 + 'up', resultMapping.SFProductName__c, 'Incorrect project token for updated mapping.');
    }

    static testMethod void removeProjectMappingTest() {
		for (MappingV1ProjectsToSFProducts__c obj :
		    [select Id from MappingV1ProjectsToSFProducts__c]) {
		    delete obj;
		}

    	String projectName1 = 'Project Name 1';
    	String productName1 = 'Product Name 1';
    	String projectToken1 = 'Scope:1234';
    	String productId1 = 'GDS';
    	MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
    	mappingData1.SFProductId__c = productId1;
    	mappingData1.SFProductName__c = productName1;
    	mappingData1.V1ProjectToken__c = projectToken1;
    	mappingData1.V1ProjectName__c = projectName1;
    	String projectName2 = 'Project Name 2';
    	String productName2 = 'Product Name 2';
    	String projectToken2 = 'Scope:2345';
    	String productId2 = 'GDS 2';
    	MappingV1ProjectsToSFProducts__c mappingData2 = new MappingV1ProjectsToSFProducts__c();
    	mappingData2.SFProductId__c = productId2;
    	mappingData2.SFProductName__c = productName2;
    	mappingData2.V1ProjectToken__c = projectToken2;
    	mappingData2.V1ProjectName__c = projectName2;
    	insert new MappingV1ProjectsToSFProducts__c[] {mappingData1, mappingData2};

    	ApexPages.currentPage().getParameters().put('mappingId', mappingData1.id);
        SettingsController controller = new SettingsController();
        controller.initSettings();
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        controller.removeProjectMapping();

		List<MappingV1ProjectsToSFProducts__c> resultMappings1 = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c where id=:mappingData1.Id];
		MappingV1ProjectsToSFProducts__c resultMapping2 = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c where id=:mappingData2.Id];
		System.assertEquals(0, resultMappings1.size(), 'This mapping should be deleted');
		System.assertNotEquals(null, resultMapping2, 'This mapping should be not deleted');
		System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of errors.');
    }

    static testMethod void removeProjectMappingWithoutSpecialCodeTest() {
		for (MappingV1ProjectsToSFProducts__c obj :
		    [select Id from MappingV1ProjectsToSFProducts__c]) {
		    delete obj;
		}

    	String projectName1 = 'Project Name 1';
    	String productName1 = 'Product Name 1';
    	String projectToken1 = 'Scope:1234';
    	String productId1 = 'GDS';
    	MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
    	mappingData1.SFProductId__c = productId1;
    	mappingData1.SFProductName__c = productName1;
    	mappingData1.V1ProjectToken__c = projectToken1;
    	mappingData1.V1ProjectName__c = projectName1;
    	String projectName2 = 'Project Name 2';
    	String productName2 = 'Product Name 2';
    	String projectToken2 = 'Scope:2345';
    	String productId2 = 'GDS 2';
    	MappingV1ProjectsToSFProducts__c mappingData2 = new MappingV1ProjectsToSFProducts__c();
    	mappingData2.SFProductId__c = productId2;
    	mappingData2.SFProductName__c = productName2;
    	mappingData2.V1ProjectToken__c = projectToken2;
    	mappingData2.V1ProjectName__c = projectName2;
    	insert new MappingV1ProjectsToSFProducts__c[] {mappingData1, mappingData2};

    	ApexPages.currentPage().getParameters().put('mappingId', mappingData1.id);
    	ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP', '127.0.0.1');
        SettingsController controller = new SettingsController();
        controller.initSettings();
        controller.code = '123';//incorrect security code
        Settings settingsData = Settings.getTestSettings();
        controller.connector = new V1ConnectorMock();
        controller.settings = settingsData;
        controller.removeProjectMapping();

		List<MappingV1ProjectsToSFProducts__c> resultMapping1 = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c where id=:mappingData1.Id];
		MappingV1ProjectsToSFProducts__c resultMapping2 = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c where id=:mappingData2.Id];
		System.assertNotEquals(null, resultMapping1, 'This mapping should be not deleted');
		System.assertNotEquals(null, resultMapping2, 'This mapping should be not deleted');
		System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors.');
    }
}