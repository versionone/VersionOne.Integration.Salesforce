@isTest
private class DefectTablePaginatorTester {
    static testMethod void paginatorTest() {
        Integer numberOfDefects = 45;
        List<Defect> defects = new List<Defect>();

        for (Integer i = 0; i < numberOfDefects; i++) {
            Defect defectData = new Defect('TestSubject', 'TestDescription');
            defects.add(defectData);
        }

        DefectTablePaginator paginator = new DefectTablePaginator(defects);

        List<Integer> pagesList = paginator.getPagesList();
        System.assertEquals(3, pagesList.size(), 'Incorrect number of cases');
        
        for (Integer i=0; i<pagesList.size(); i++) {
            if (i != pagesList.get(i)) {
                System.assertEquals(numberOfDefects, paginator.getRecordsNumber(), 'Incorrect number of pages.');
            }
        }
        
        System.assertEquals(numberOfDefects, paginator.getRecordsNumber(), 'Incorrect number of defects');
        System.assertEquals(3, paginator.getTotalPageNumber(), 'Incorrect number of pages');
        System.assertEquals(1, paginator.getPageNumber(), 'Incorrect number of current page');
        System.assertEquals(paginator.getPageSize(), paginator.getDefects().size(), 'Incorrect number of defects on the first page');
        System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
        System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        paginator.nextBtnClick();
        System.assertEquals(2, paginator.getPageNumber(), 'Incorrect number of current page');
        System.assertEquals(paginator.getPageSize(), paginator.getDefects().size(), 'Incorrect number of defects on the second page');
        System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
        System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        paginator.nextBtnClick();
        System.debug('paginator.getTable1Cases().size()' + paginator.getDefects().size());
        System.assertEquals(3, paginator.getPageNumber(), 'Incorrect number of current page');
        System.assertEquals(5, paginator.getDefects().size(), 'Incorrect number of defects on the third page');
        System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
        System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be disabled.');
        paginator.previousBtnClick();
        System.assertEquals(2, paginator.getPageNumber(), 'Incorrect number of current page');
        System.assertEquals(paginator.getPageSize(), paginator.getDefects().size(), 'Incorrect number of defects on the second page');
        System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
        System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        paginator.previousBtnClick();
        System.assertEquals(1, paginator.getPageNumber(), 'Incorrect number of current page');
        System.assertEquals(paginator.getPageSize(), paginator.getDefects().size(), 'Incorrect number of defects on the first page');
        System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
        System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        paginator.goToPage(3);
        System.assertEquals(3, paginator.getPageNumber(), 'Incorrect number of current page');
        System.assertEquals(5, paginator.getDefects().size(), 'Incorrect number of defects on the third page');
        System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
        System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be disabled.');
    }

    static testMethod void emptyPaginatorTest() {
        DefectTablePaginator paginator = new DefectTablePaginator(new List<Defect>());

        List<Integer> pagesList = paginator.getPagesList();
        System.assertEquals(0, pagesList.size(), 'Incorrect number of cases');
        System.assertEquals(0, paginator.getRecordsNumber(), 'Incorrect number of defects');
        System.assertEquals(0, paginator.getTotalPageNumber(), 'Incorrect number of pages');
        System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
        System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        System.assertEquals(0, paginator.getPageNumber(), 'Incorrect number of current page');

        paginator.goToPage(5);
        System.assertEquals(0, pagesList.size(), 'Incorrect number of defects');
        System.assertEquals(0, paginator.getRecordsNumber(), 'Incorrect number of defects');
        System.assertEquals(0, paginator.getTotalPageNumber(), 'Incorrect number of pages');
        System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
        System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        System.assertEquals(0, paginator.getPageNumber(), 'Incorrect number of current page');

        paginator.goToPage(-1);
        System.assertEquals(0, pagesList.size(), 'Incorrect number of cases');
        System.assertEquals(0, paginator.getRecordsNumber(), 'Incorrect number of defects');
        System.assertEquals(0, paginator.getTotalPageNumber(), 'Incorrect number of pages');
        System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
        System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        System.assertEquals(0, paginator.getPageNumber(), 'Incorrect number of current page');
    }
}