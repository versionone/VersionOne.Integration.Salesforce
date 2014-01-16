@isTest
private class DefectControllerTester 
{
    private static final String CASE_SUBJECT = 'TestCase1';
    private static final String CASE_DESCRIPTION = 'Description 123';
    private static final String PROJECT_NAME = 'project name';
    private static final String DEFECT_TOKEN = DefectFacadeMock.CreatedDefectToken;
    private static final String SF_PRODUCT_ID = 'GC1020';

    static @isTest void mainTest() 
    {
        DefectController controller = getControllerWithoutAssignedDefect();

        Defect defect = controller.getCreatingDefect();
        System.assertEquals(CASE_SUBJECT, defect.title);
        System.assertEquals(CASE_DESCRIPTION, defect.description);

        controller.showForm();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(true, controller.isEditForm);

        controller.refreshWidow();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(false, controller.isEditForm);
    }
    
    static @isTest void createDefectWithNoSettingsTest()
    {
        DefectController controller = getControllerWithoutSettings();
        Settings settings = controller.settings;
        System.assertEquals(null, settings.getCurrentMemberId());
    }

    static @isTest void createDefectTest() 
    {
        DefectController controller = getControllerWithoutAssignedDefect();
        controller.createDefect();
        Defect defect = controller.getCreatingDefect();

        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(false, defect.isClosed);
        System.assertEquals(DEFECT_TOKEN, defect.token);
    }

    static @isTest void createDefectWithExceptionTest() 
    {
        DefectController controller = getControllerWithoutAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.CREATE_DEFECT_IN_V1_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;
        controller.createDefect();
        Defect defect = controller.getCreatingDefect();
        System.assertEquals(true, controller.areThereErrors);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors after failed defect creation.');
    }

    static @isTest void getAssignedDefectTest() 
    {
        DefectController controller = getControllerWithAssignedDefect();

        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(DefectFacadeMock.DefectTitle, defectData.title);
        System.assertEquals(DefectFacadeMock.DefectDescription, defectData.description);
        System.assertEquals(DefectFacadeMock.CreatedDefectToken, defectData.token);
    }

    static @isTest void getAssignedDefectWithExceptionTest() 
    {
        DefectController controller = getControllerWithAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.DEFECT_BY_ID_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;

        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(null, defectData);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors after failed defect creation.');
    }

    static @isTest void getAssignedDefectWithoutRequestToV1Test() 
    {
        DefectController controller = getControllerWithAssignedDefect();
        controller.createDefect();
        controller.defectFacade = null;
        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(CASE_SUBJECT, defectData.title);
        System.assertEquals(CASE_DESCRIPTION, defectData.description);
        System.assertEquals(DEFECT_TOKEN, defectData.token);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static @isTest void getAssignedDefectWhenDefectIsNotAssignedTest() 
    {
        DefectController controller = getControllerWithoutAssignedDefect();

        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(null, defectData);
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static @isTest void unassignDefectTest() 
    {
        DefectController controller = getControllerWithAssignedDefect();

        controller.unassignDefect();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static @isTest void unassignDefectWithExeptionTest() 
    {
        DefectController controller = getControllerWithAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.UNASSIGN_DEFECT_FROM_CASE_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;

        controller.unassignDefect();
        System.assertEquals(true, controller.areThereErrors);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static @isTest void publishStatusTest() 
    {
        DefectController controller = getControllerWithAssignedDefect();

        controller.publishStatus();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static @isTest void publishStatusWithExceptionTest() 
    {
        DefectController controller = getControllerWithAssignedDefect();
        DefectFacadeMock facade = (DefectFacadeMock)controller.defectFacade;
        facade.addException(DefectFacadeMock.PUBLISH_STATUS_EXCEPTION, new IntegrationException('test exception'));
        controller.defectFacade = facade;

        controller.publishStatus();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static @isTest void cancelFormTest() 
    {
        String newTitle = 'new title';
        String newDescription = 'new description';
        DefectController controller = getControllerWithoutAssignedDefect();

        controller.getCreatingDefect().title = newTitle;
        controller.getCreatingDefect().description = newDescription;
        Defect defect = controller.getCreatingDefect();
        controller.isEditForm = true;

        System.assertEquals(newTitle, defect.title, 'Incorrect title');
        System.assertEquals(newDescription, defect.description, 'Incorrect description');
        System.assertEquals(true, controller.isEditForm, 'Incorrect description');

        controller.cancelForm();
        defect = controller.getCreatingDefect();
        System.assertEquals(CASE_SUBJECT, defect.title, 'Incorrect title');
        System.assertEquals(CASE_DESCRIPTION, defect.description, 'Incorrect description');
        System.assertEquals(false, controller.isEditForm, 'Incorrect description');
    }

    private static DefectController getControllerWithoutAssignedDefect() 
    {
        Case caseData = new Case(Subject = CASE_SUBJECT, Description = CASE_DESCRIPTION, V1Product__c = SF_PRODUCT_ID);
        insert new Case[] {caseData};

        caseData = [SELECT V1Association__c FROM Case WHERE Id = :caseData.Id];
        System.assertEquals(false, caseData.V1Association__c, 'Incorrect case state.');
        return getController(caseData);
    }

    private static DefectController getControllerWithAssignedDefect() 
    {
        Case caseData = new Case(Subject = CASE_SUBJECT, Description = CASE_DESCRIPTION, V1Association__c = true, V1DefectId__c = DEFECT_TOKEN, V1Product__c = SF_PRODUCT_ID);
        insert new Case[] {caseData};

        caseData = [SELECT V1Association__c FROM Case WHERE Id = :caseData.Id];
        System.assertEquals(true, caseData.V1Association__c, 'Incorrect case state.');
        return getController(caseData);
    }
    
    private static DefectController getControllerWithoutSettings() 
    {
        Case caseData = new Case(Subject = CASE_SUBJECT, Description = CASE_DESCRIPTION, V1Association__c = true, V1DefectId__c = DEFECT_TOKEN, V1Product__c = SF_PRODUCT_ID);
        insert new Case[] {caseData};
        caseData = [SELECT V1Association__c FROM Case WHERE Id = :caseData.Id];
        
        DefectFacadeMock facade = new DefectFacadeMock();
        DefectController controller = new DefectController(caseData);
        controller.defectFacade = facade;
        return controller;        
    }

    private static DefectController getController(Case caseData) 
    {
        DefectFacadeMock facade = new DefectFacadeMock();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setProjectName(PROJECT_NAME);
        DefectController controller = new DefectController(caseData);
        controller.defectFacade = facade;
        controller.settings = settingsData;

        System.assertNotEquals(null, controller, 'Incorrect controller state.');
        return controller;
    }
}