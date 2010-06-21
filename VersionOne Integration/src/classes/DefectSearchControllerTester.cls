@isTest
private class DefectSearchControllerTester {
	private static final String caseSubject = 'TestCase1';
    private static final String caseDescription = 'Case description';
    private static final String projectName = 'Call Center';
    private static final String assignedDefectToken = DefectFacadeMock.CreatedDefectToken;
    
    private static DefectFacadeMock defectFacadeMockValue;
    private static Settings settingsValue;
    private static Case caseData;
    
    static testMethod void emptyCriteriaSearchTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	System.assertEquals(controller.DefectFacade, defectFacadeMockValue);
    	System.assertEquals(controller.Settings, settingsValue); 
    	
    	controller.searchForDefects();
    	
    	System.assertEquals(controller.getDefects(), null);
    	System.assertEquals(controller.displayDefectTable, false);
    	pageMessageAssert(ApexPages.Severity.ERROR);
    }
    
    static testMethod void emptyResultSearchTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	defectFacadeMockValue.foundDefects = new List<Defect>();
    	
    	controller.getSearchCriteria().queryString = 'test';
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.searchForDefects();
    	
    	System.assertNotEquals(controller.getDefects(), null);
    	System.assertEquals(controller.getDefects().size(), 0);
    	System.assertEquals(controller.displayDefectTable, false);
    	pageMessageAssert(ApexPages.Severity.INFO);
    }
    
    static testMethod void searchFailureTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	defectFacadeMockValue.setSearchException(new IntegrationException());
    	
    	controller.getSearchCriteria().queryString = 'test';
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.searchForDefects();
    	
    	System.assertEquals(controller.getDefects(), null);
    	System.assertEquals(controller.displayDefectTable, false);
    	pageMessageAssert(ApexPages.Severity.ERROR);
    }
    
    static testMethod void nonEmptyResultSearchTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	defectFacadeMockValue.foundDefects = new List<Defect>();
    	Defect foundDefect = new Defect('test defect name', 'test defect description');
    	foundDefect.token = 'Defect:1234';
    	defectFacadeMockValue.foundDefects.add(foundDefect);
    	
    	controller.getSearchCriteria().queryString = 'test';
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.searchForDefects();
    	
    	System.assertNotEquals(controller.getDefects(), null);
    	System.assertEquals(controller.getDefects().size(), 1);
    	System.assertEquals(controller.displayDefectTable, true);
    	System.assertEquals(ApexPages.getMessages().size(), 0);
    }
    
    private static void pageMessageAssert(ApexPages.Severity severity) {
    	System.assertEquals(ApexPages.getMessages().size(), 1);
    	ApexPages.Message message = ApexPages.getMessages().get(0);
    	System.assertEquals(message.getSeverity(), severity);
    } 
    
    private static DefectSearchController getControllerWithoutAssignedDefect() { 
        caseData = new Case(Subject = caseSubject, Description = caseDescription);
        insert new Case[] {caseData};
        return getController();
    }

    private static DefectSearchController getControllerWithAssignedDefect() {
        caseData = new Case(Subject = caseSubject, Description = caseDescription, V1Association__c = true, V1DefectId__c = assignedDefectToken);
        insert new Case[] { caseData };
        return getController();
    }

    private static DefectSearchController getController() {
        defectFacadeMockValue = new DefectFacadeMock();
        settingsValue = Settings.getTestSettings(); 
        settingsValue.setProjectName(ProjectName);
        DefectSearchController controller = new DefectSearchController(caseData);
        controller.DefectFacade = defectFacadeMockValue;
        controller.Settings = settingsValue;
        return controller;
    }
}