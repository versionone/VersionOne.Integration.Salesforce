public class V1SynchronizerController {

    private static final String CASE_UPDATE_STATUS_TEXT = 'Case update status';
    private static final String CASE_PUBLISH_STATUS_TEXT = 'Case publish status';
    private static final String CASE_PUBLISHED_TEXT = 'Cases published';
    private static final String STATUS_COMPLETED_TEXT = 'Completed';

    private List<Case> waitedCases;
    private List<Case> pageCases;
    private Integer pageNumber;
    private Integer pageSize;
    private Integer totalPageNumber;

    public V1SynchronizerController() {
        pageNumber = 0;
        totalPageNumber = 0;
        pageSize = 20;
        isNoDataForTable1 = false;

        table2PageNumber = 0;
        table2TotalPageNumber = 0;
        table2PageSize = 20;
        isNoDataForTable2 = false;
    }

    public void initData() {
        casesWaitingPorting = null;
        casesPorted = null;

        Table1BindData(1);
        Table2BindData(1);

        showSynchronizerInfo();
        showPublisherInfo();
    }

    public PageReference forceSync() {
        settings = null;
        if (settings.getBatchId() != null || Synchronizer.isFutureRan() || V1Publisher.isFutureRan()) {
            showSynchronizerInfo();
            return null;
        }

        try {
            Synchronizer.runSynchronizerWithVersionOne();
        } catch (Exception ex) {
            addErrorMessage('Failed to run cases updater.');
            ApexPages.addMessages(ex);
        }

        try {
            BatchPublisher batch = new BatchPublisher(new ConnectionFactory());
            ID batchprocessid = Database.executeBatch(batch, 1);
            settings.setBatchId(batchprocessid);
            settings.updateBatchId();
            isBatchRan = true;
        } catch (Exception ex) {
            addErrorMessage('Failed to run cases publisher.');
            ApexPages.addMessages(ex);
        }

        addConfirmMessage('Synchronizer was started.');

        return null;
    }

    public Settings settings {
        get {
            if (settings == null) {
                settings = new Settings();
            }
            return settings;
        } set;}

    //Synchronize action
    public Boolean isBatchRan {get; set;}
    public Boolean isFutureRan {get; set;}

    public void showSynchronizerInfo() {
        isBatchRan = BatchPublisher.isRan(settings.getBatchId());
        Map<String, String> futureData = Synchronizer.getFutureCurrentFuture();
        isFutureRan = futureData != null;
        displayBatchProgress(settings.getBatchId());

        if (isFutureRan || settings.getBatchId() != null) {
            displayFutureProgress(CASE_UPDATE_STATUS_TEXT, futureData);
        }
        if (!isBatchRan && !isFutureRan && settings.getBatchId() != null) {
            settings.setBatchId(null);
            settings.updateBatchId();
        }
    }

    public void showPublisherInfo() {
        Map<String, String> futureData = V1Publisher.getFutureCurrentFuture();
        if (futureData != null) {
            isFutureRan = true;
            displayFutureProgress(CASE_PUBLISH_STATUS_TEXT, futureData);
        }
    }

    private void displayBatchProgress(String id) {
        Map<String, String> batchData = BatchPublisher.getBatchData(id);
        if (batchData == null) {
            return;
        }
        addInfoMessage(CASE_PUBLISH_STATUS_TEXT + ' : ' + batchData.get('Status'));
        addInfoMessage(CASE_PUBLISHED_TEXT + ' : ' + batchData.get('JobItemsProcessed'));
        //addInfoMessage('Number of errors: ' + batchData.get('NumberOfErrors'));
        //addInfoMessage('Total cases: ' + batchData.get('TotalJobItems'));
    }

    private void displayFutureProgress(String text, Map<String, String> data) {
        String status;
        if (data != null) {
            status = data.get('Status');
        } else {
            status = STATUS_COMPLETED_TEXT;
        }
        addInfoMessage(text + ':' + status);
    }

    //Messages
    private static void addErrorMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, text));
    }

    private static void addInfoMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, text));
    }

    private static void addConfirmMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, text));
    }

    // ------------- Common for tables --------------
    private List<Case> fillCasesForCurrentPage(Integer newPageIndex, List<Case> cases, Integer pageNumber, Integer pageSize) {
        System.debug('fillCasesForCurrentPage cases:' + cases);
        Transient Integer counter = 0;
        Transient Integer min = 0;
        Transient Integer max = 0;
        if (newPageIndex > pageNumber) {
            min = pageNumber * pageSize;
            max = newPageIndex * pageSize;
        } else {
            max = newPageIndex * pageSize;
            min = max - pageSize;
        }
        List<Case> currentCases = new List<Case>();
        for(Case c : cases) {
            counter++;
            if (counter > min && counter <= max) {
                currentCases.add(c);
            }
        }
        System.debug('currentCases cases:' + currentCases);
        return currentCases;
    }

    // -------- Table 1------------------

    public Boolean isNoDataForTable1 {get; set;}

    public Integer getRecordsNumber() {
        if (casesWaitingPorting == null){
            return 0;
        } else {
            return casesWaitingPorting.size();
        }
    }

    public PageReference goToTable1Page() {
        String pageNumber = ApexPages.currentPage().getParameters().get('pageNumber');
        System.debug('go to page table 1:' + pageNumber);
        try {
            table1BindData(Integer.valueof(pageNumber));
        } catch (Exception ex) {
            //do nothing
        }
        return null;
    }

    public List<Integer> getTable1PagesList() {
        List<Integer> pagesNumbers = new List<Integer>();
        Integer amountPages = getTable1TotalPageNumber();
        for (Integer i=0; i<amountPages; i++) {
            pagesNumbers.add(i);
        }
        return pagesNumbers;
    }

    public Integer getTable1PageNumber(){
        return pageNumber;
    }

    public List<Case> getTable1Cases() {
        return pageCases;
    }

    public Integer getTable1PageSize() {
        return pageSize;
    }

    public Boolean getTable1PreviousButtonDisabled() {
        System.debug('pageNumber = ' + pageNumber);
        return !(pageNumber > 1);
    }

    public Boolean getTable1NextButtonDisabled() {
        if (casesWaitingPorting == null){
            return true;
        } else {
            return ((pageNumber * pageSize) >= casesWaitingPorting.size());
        }
    }

    public Integer getTable1TotalPageNumber() {
        if (totalPageNumber == 0 && casesWaitingPorting !=null) {
            totalPageNumber = casesWaitingPorting.size() / pageSize;
            Integer mod = casesWaitingPorting.size() - (totalPageNumber * pageSize);
            if (mod > 0) {
                totalPageNumber++;
            }
        }
        return totalPageNumber;
    }

    private List<Case> casesWaitingPorting {
        get {
            if (waitedCases == null) {
                waitedCases = V1CaseCollector.getCasesByOwners(new String[] {settings.getDefectQueueId(), settings.getStoryQueueId()});
            }
            return waitedCases;
        }
        set;
    }

    private void table1BindData(Integer newPageIndex) {
        try {
            pageCases = fillCasesForCurrentPage(newPageIndex, casesWaitingPorting, getTable1PageNumber(), getTable1PageSize());
            pageNumber = newPageIndex;
            isNoDataForTable1 = false;
            if (pageCases == null || pageCases.size() == 0) {
                isNoDataForTable1 = true;
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    }

    public PageReference table1NextBtnClick() {
        table1BindData(pageNumber + 1);
        return null;
    }

    public PageReference table1PreviousBtnClick() {
        table1BindData(pageNumber - 1);
        return null;
    }
    //\\-----------Table 1------------------
    // ----------Table 2------------------
    private List<Case> portedCases;
    private List<Case> table2PageCases;
    private Integer table2PageNumber;
    private Integer table2PageSize;
    private Integer table2TotalPageNumber;

    public Boolean isNoDataForTable2 {get; set;}

    private List<Case> casesPorted {
        get {
            if (portedCases == null) {
                portedCases = V1CaseCollector.getCasesByOwners(new String[] {settings.getDestQueueId()});
            }
            return portedCases;
        }
        set;
    }

    public Integer getTable2RecordsNumber() {
        if (casesPorted == null){
            return 0;
        } else {
            return casesPorted.size();
        }
    }

    public List<Integer> getTable2PagesList() {
        List<Integer> pagesNumbers = new List<Integer>();
        Integer amountPages = getTable2TotalPageNumber();
        for (Integer i=0; i<amountPages; i++) {
            pagesNumbers.add(i);
        }
        return pagesNumbers;
    }

    public Integer getTable2PageNumber(){
        return table2PageNumber;
    }

    public List<Case> getTable2Cases() {
        return table2PageCases;
    }

    public Integer getTable2PageSize() {
        return table2PageSize;
    }

    public Boolean getTable2PreviousButtonDisabled() {
        return !(table2PageNumber > 1);
    }

    public Boolean getTable2NextButtonDisabled() {
        if (portedCases == null){
            return true;
        } else {
            return ((table2PageNumber * table2PageSize) >= portedCases.size());
        }
    }

    public PageReference goToTable2Page() {
        String pageNumber = ApexPages.currentPage().getParameters().get('pageNumber');
        System.debug('go to page:' + pageNumber);
        try {
            table2BindData(Integer.valueof(pageNumber));
        } catch (Exception ex) {
            //do nothing
        }

        return null;
    }

    public Integer getTable2TotalPageNumber() {
        if (table2TotalPageNumber == 0 && portedCases !=null) {
            table2TotalPageNumber = portedCases.size() / table2PageSize;
            Integer mod = portedCases.size() - (table2TotalPageNumber * table2PageSize);
            if (mod > 0) {
                table2TotalPageNumber++;
            }
        }
        return table2TotalPageNumber;
    }

    private void table2BindData(Integer newPageIndex) {
        try {
            table2PageCases = fillCasesForCurrentPage(newPageIndex, casesPorted, getTable2PageNumber(), getTable2PageSize());
            System.debug('table2binddata index=' +  newPageIndex + '   page cases:' + table2PageCases);
            table2PageNumber = newPageIndex;
            isNoDataForTable2 = false;
            if (table2PageCases == null || table2PageCases.size() == 0) {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
                isNoDataForTable2 = true;
            }
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    }

    public PageReference table2NextBtnClick() {
        table2BindData(table2PageNumber + 1);
        return null;
    }

    public PageReference table2PreviousBtnClick() {
        table2BindData(table2PageNumber - 1);
        return null;
    }
    //\\ ----------Table 2------------------
}