@isTest
private class V1DefectReportControllerTester {

    private static DefectFacadeMock defectFacadeMockValue;
    private static Settings settingsValue;
    private static final String caseSubject = 'TestCase1';
    private static final String caseDescription = null;
    private static final String changeDate = '2010-05-12 11:11:11';

    static testMethod void findCasesWithDefectsWithEmptyResultTest() {
        V1DefectReportController controller = getController();
        defectFacadeMockValue.casesWithDefects = new List<DefectWrapper>();
        controller.findCasesWithDefects();

        System.assertNotEquals(null, controller.getCasesWithDefect());
        System.assertEquals(0, controller.getCasesWithDefect().size());
        System.assertEquals(false, controller.displayCasesWithDefectsTable);
        System.assertEquals(0, controller.paginator.getRecordCount());
        pageMessageAssert(ApexPages.Severity.INFO);
    }

    static testMethod void findCasesWithDefectsWithExceptionTest() {
        V1DefectReportController controller = getController();
        defectFacadeMockValue.addException(DefectFacadeMock.GETTING_CASES_WITH_DEFECT_EXCEPTION, new IntegrationException());
        controller.findCasesWithDefects();

        System.assertNotEquals(null, controller.getCasesWithDefect());
        System.assertEquals(controller.getCasesWithDefect().size(), 0);
        System.assertEquals(false, controller.displayCasesWithDefectsTable);
        System.assertEquals(0, controller.paginator.getRecordCount());
        pageMessageAssert(ApexPages.Severity.ERROR);
    }

    static testMethod void getOwnerCaseListOptionsTest() {
        V1DefectReportController controller = getController();
        System.assertEquals(2, controller.getOwnerCaseListOptions().size());
    }

    static testMethod void getStatusListOptionsTest() {
        V1DefectReportController controller = getController();
        System.assertEquals(2, controller.getStatusListOptions().size());
    }

    static testMethod void goToPageTest() {
        V1DefectReportController controller = getController();
        fillLotOfCasesWithDefects();
        controller.findCasesWithDefects();

        ApexPages.currentPage().getParameters().put('pageNumber', '1');
        controller.goToPage();
        System.assertEquals(20, controller.paginator.getDefects().size());
        ApexPages.currentPage().getParameters().put('pageNumber', '2');
        controller.goToPage();
        System.assertEquals(5, controller.paginator.getDefects().size());
    }

    private static void fillLotOfCasesWithDefects() {
        defectFacadeMockValue.casesWithDefects = new List<DefectWrapper>();
        for (Integer i = 0; i < 25; i++) {
            Defect foundDefect = new Defect(caseSubject + ' #' + i, caseDescription + ' #' + i);
            foundDefect.changeDate = changeDate;
            defectFacadeMockValue.casesWithDefects.add(new DefectWrapper(null, foundDefect));
        }
        System.assertEquals(25, defectFacadeMockValue.casesWithDefects.size(), 'Incorrect numbers of closed defects.');
    }

    private static void pageMessageAssert(ApexPages.Severity severity) {
        System.assertEquals(1, ApexPages.getMessages().size());
        ApexPages.Message message = ApexPages.getMessages().get(0);
        System.assertEquals(severity, message.getSeverity());
    }
    /*
    private static void fillCasesWithDefects() {
        defectFacadeMockValue.casesWithDefects = new List<DefectWrapper>();
        Defect foundDefect = new Defect(caseSubject, caseDescription);
        foundDefect.changeDate = changeDate;
        defectFacadeMockValue.casesWithDefects.add(new DefectWrapper(null, foundDefect));
        System.assertEquals(1, defectFacadeMockValue.casesWithDefects.size(), 'Incorrect numbers of closed defects.');
    }
    */

    private static V1DefectReportController getController() {
        defectFacadeMockValue = new DefectFacadeMock();
        settingsValue = Settings.getTestSettings();
        V1DefectReportController controller = new V1DefectReportController();
        controller.defectFacade = defectFacadeMockValue;
        controller.Settings = settingsValue;
        System.assertNotEquals(null, controller, 'Incorrect controller state.');
        return controller;
    }
}