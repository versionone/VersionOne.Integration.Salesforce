@isTest
private class DefectControllerTester {
	private static final String caseSubject = 'TestCase1';
	private static final String caseDescription = 'Description 123';
	private static final String projectName = 'project name';
	private static final String assignedDefectId = 'Defect:1234';

    static testMethod void mainTest() {
		DefectController controller = getControllerWithoutAssignedDefect();

		Defect defect = controller.getCreatingDefect();
		System.assertEquals(caseSubject, defect.title);
		System.assertEquals(caseDescription, defect.description);

		controller.showForm();
		System.assertEquals(false, controller.areThereErrors);
		System.assertEquals(true, controller.isEditForm);

		controller.refreshWidow();
		System.assertEquals(false, controller.areThereErrors);
		System.assertEquals(false, controller.isEditForm);
    }

    static testMethod void createDefectTest() {
    	DefectController controller = getControllerWithoutAssignedDefect();
    	controller.createDefect();
		Defect defect = controller.getCreatingDefect();

		System.assertEquals(false, controller.areThereErrors);
		System.assertEquals(false, defect.isClosed);
		System.assertEquals(ProjectName, defect.project);
		System.assertEquals(DefectFacadeMock.CreatedDefectId, defect.id);
    }

    static testMethod void createDefectWithExceptionTest() {
    	DefectController controller = getControllerWithoutAssignedDefect();
    	IDefectFacade facade = controller.defectFacade;
    	((DefectFacadeMock)facade).setCreateDefectInVersionOneException(new IntegrationException('test exception'));
    	controller.defectFacade = facade;
    	controller.createDefect();
    	Defect defect = controller.getCreatingDefect();
    	System.assertEquals(true, controller.areThereErrors);
    	System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors after failed defect creation.');
    }

    static testMethod void getAssignedDefectTest() {
    	DefectController controller = getControllerWithAssignedDefect();

    	Defect defectData = controller.getAssignedDefect();
		System.assertEquals(DefectFacadeMock.DefectTitle, defectData.title);
		System.assertEquals(DefectFacadeMock.DefectDescription, defectData.description);
		System.assertEquals(DefectFacadeMock.CreatedDefectId, defectData.id);

    }

    private static DefectController getControllerWithoutAssignedDefect() {
		Case caseData = new Case(Subject = caseSubject, Description = caseDescription);
        insert new Case[] {caseData};
        return getController(caseData);
    }

    private static DefectController getControllerWithAssignedDefect() {
		Case caseData = new Case(Subject = caseSubject, Description = caseDescription, V1Association__c = true, V1DefectId__c = assignedDefectId);
        insert new Case[] {caseData};
        return getController(caseData);
    }

    private static DefectController getController(Case caseData) {
        DefectFacadeMock facade = new DefectFacadeMock();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setProjectName(ProjectName);
        DefectController controller = new DefectController(caseData);
        controller.defectFacade = facade;
        controller.settings = settingsData;
        return controller;
    }
}