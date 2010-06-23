@isTest
private class DefectSearchControllerTester {
	private static final String caseSubject = 'TestCase1';
    private static final String caseDescription = 'Case description';
    private static final String projectName = 'Call Center';
    private static final String defectStatus = 'In Progress';
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
    	System.assertEquals(controller.paginator.getRecordCount(), 0);
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
    	System.assertEquals(controller.paginator.getRecordCount(), 0);
    	pageMessageAssert(ApexPages.Severity.ERROR);
    }
    
    static testMethod void nonEmptyResultSearchTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	setupFoundDefect();
    	
    	controller.getSearchCriteria().queryString = caseSubject;
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.searchForDefects();
    	
    	System.assertNotEquals(controller.getDefects(), null);
    	System.assertEquals(controller.getDefects().size(), 1);
    	System.assertEquals(controller.displayDefectTable, true);
    	System.assertEquals(controller.paginator.getRecordCount(), 1);
    	System.assertEquals(ApexPages.getMessages().size(), 0);
    }
    
    static testMethod void assignDefectFailureTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	defectFacadeMockValue.setAssignDefectToCaseException(new IntegrationException());
    	controller.assignedDefectToken = assignedDefectToken;
    	setupFoundDefect();
    	
    	controller.getSearchCriteria().queryString = caseSubject;
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.searchForDefects();
    	controller.assignDefectToCase();
    
    	pageMessageAssert(ApexPages.Severity.ERROR);
    }
    
    static testmethod void assignDefectTest() {
    	DefectSearchController controller = getControllerWithoutAssignedDefect();
    	controller.assignedDefectToken = assignedDefectToken;
    	setupFoundDefect();
    	
    	controller.getSearchCriteria().queryString = caseSubject;
    	controller.getSearchCriteria().includeClosedDefects = false;
    	controller.searchForDefects();
    	controller.assignDefectToCase();
    
    	System.assertEquals(ApexPages.getMessages().size(), 0);
    	System.assertEquals(caseData.Id, defectFacadeMockValue.assignDefectResultValue.caseValue.Id); 
    	System.assertEquals(assignedDefectToken, defectFacadeMockValue.assignDefectResultValue.token);
    	System.assertEquals(defectStatus, defectFacadeMockValue.assignDefectResultValue.status);
    }
    
    static testMethod void unassignDefectFailureTest() {
    	DefectSearchController controller = getControllerWithAssignedDefect();
    	defectFacadeMockValue.setUnassignDefectFromCaseException(new IntegrationException());
    	
    	controller.unassignDefectFromCase();
    
    	pageMessageAssert(ApexPages.Severity.ERROR);
    }
    
    static testMethod void unassignDefectTest() {
    	DefectSearchController controller = getControllerWithAssignedDefect();
    	
    	controller.unassignDefectFromCase();
    
        System.assertEquals(caseData.Id, defectFacadeMockValue.assignDefectResultValue.caseValue.Id); 
    	System.assertEquals(null, defectFacadeMockValue.assignDefectResultValue.token);
    	System.assertEquals(null, defectFacadeMockValue.assignDefectResultValue.status);
    	System.assertEquals(ApexPages.getMessages().size(), 0);
    }
    
    private static void setupFoundDefect() {
    	defectFacadeMockValue.foundDefects = new List<Defect>();
    	Defect foundDefect = new Defect(caseSubject, caseDescription);
    	foundDefect.token = assignedDefectToken;
    	foundDefect.status = defectStatus;
    	defectFacadeMockValue.foundDefects.clear();
    	defectFacadeMockValue.foundDefects.add(foundDefect);
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