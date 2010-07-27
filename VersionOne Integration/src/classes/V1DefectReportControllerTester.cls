@isTest
private class V1DefectReportControllerTester {

    private static DefectFacadeMock defectFacadeMockValue;
    private static Settings settingsValue;
	private static final String caseSubject = 'TestCase1';
    private static final String caseDescription = null;
    private static final String changeDate = '2010-05-12 11:11:11';

    static testMethod void getCookieAtStartTest() {
    	Cookie newDateTime = new Cookie('datetime', changeDate.split(' ')[0], null, 60*60*24*30*2, false);
    	ApexPages.currentPage().setCookies(new Cookie[]{newDateTime});

    	V1DefectReportController controller = getController();
    	System.assertEquals(changeDate.split(' ')[0], controller.userDate);
    }

    static testMethod void findClosedDefectsWithEmptyDateTest() {
        V1DefectReportController controller = getController();
        fillClosedDefects();
        controller.findClosedDefects();

		Cookie lastDateTime = ApexPages.currentPage().getCookies().get('datetime');
		System.assertEquals(changeDate.split(' ')[0], lastDateTime.getValue());
    	System.assertNotEquals(null, controller.getClosedDefect());
    	System.assertEquals(1, controller.getClosedDefect().size());
    	System.assertEquals(true, controller.displayClosedDefectsTable);
    	System.assertEquals(1, controller.paginator.getRecordCount());
    }

    static testMethod void findClosedDefectsWithEmptyResultTest() {
        V1DefectReportController controller = getController();
        defectFacadeMockValue.closedDefects = new List<Defect>();
        controller.findClosedDefects();

		Cookie lastDateTime = ApexPages.currentPage().getCookies().get('datetime');
		System.assertEquals(null, lastDateTime);
    	System.assertNotEquals(null, controller.getClosedDefect());
    	System.assertEquals(0, controller.getClosedDefect().size());
    	System.assertEquals(false, controller.displayClosedDefectsTable);
    	System.assertEquals(0, controller.paginator.getRecordCount());
    	pageMessageAssert(ApexPages.Severity.INFO);
    }

    static testMethod void findClosedDefectsWithExceptionTest() {
        V1DefectReportController controller = getController();
        //defectFacadeMockValue.setSearchException(new IntegrationException());
        defectFacadeMockValue.addException('searchException', new IntegrationException());
        controller.findClosedDefects();

		Cookie lastDateTime = ApexPages.currentPage().getCookies().get('datetime');
		System.assertEquals(null, lastDateTime);
    	System.assertNotEquals(null, controller.getClosedDefect());
    	System.assertEquals(controller.getClosedDefect().size(), 0);
    	System.assertEquals(false, controller.displayClosedDefectsTable);
    	System.assertEquals(0, controller.paginator.getRecordCount());
    	pageMessageAssert(ApexPages.Severity.ERROR);
    }

    static testMethod void goToPageTest() {
    	V1DefectReportController controller = getController();
    	fillLotOfClosedDefects();
		controller.findClosedDefects();

    	ApexPages.currentPage().getParameters().put('pageNumber', '1');
    	controller.goToPage();
    	System.assertEquals(20, controller.paginator.getDefects().size());
    	ApexPages.currentPage().getParameters().put('pageNumber', '2');
    	controller.goToPage();
    	System.assertEquals(5, controller.paginator.getDefects().size());
    }

    private static void fillLotOfClosedDefects() {
    	defectFacadeMockValue.closedDefects = new List<Defect>();
    	for (Integer i = 0; i < 25; i++) {
	    	Defect foundDefect = new Defect(caseSubject + ' #' + i, caseDescription + ' #' + i);
	    	foundDefect.changeDate = changeDate;
	    	defectFacadeMockValue.closedDefects.add(foundDefect);
    	}
    }

    private static void pageMessageAssert(ApexPages.Severity severity) {
    	System.assertEquals(1, ApexPages.getMessages().size());
    	ApexPages.Message message = ApexPages.getMessages().get(0);
    	System.assertEquals(severity, message.getSeverity());
    }

    private static void fillClosedDefects() {
    	defectFacadeMockValue.closedDefects = new List<Defect>();
    	Defect foundDefect = new Defect(caseSubject, caseDescription);
    	foundDefect.changeDate = changeDate;
    	defectFacadeMockValue.closedDefects.add(foundDefect);
    }

    private static V1DefectReportController getController() {
        defectFacadeMockValue = new DefectFacadeMock();
        settingsValue = Settings.getTestSettings();
        V1DefectReportController controller = new V1DefectReportController();
        controller.defectFacade = defectFacadeMockValue;
        controller.Settings = settingsValue;
        return controller;
    }
}