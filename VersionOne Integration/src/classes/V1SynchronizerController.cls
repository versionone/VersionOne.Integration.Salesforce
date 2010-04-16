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
    }

    public void initData() {
        cases = null;
        totalPageNumber = 0;
        showSynchronizerInfo();
        TableBindData(1);

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

    // -------- Table 1------------------

    public Boolean isNoDataForTable1 {get; set;}

    public Integer getRecordsNumber() {
        if (cases == null){
            return 0;
        } else {
            return cases.size();
        }
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
        if (cases == null){
            return true;
        } else {
            return ((pageNumber * pageSize) >= cases.size());
        }
    }

    public Integer getTable1TotalPageNumber() {
        if (totalPageNumber == 0 && cases !=null) {
            totalPageNumber = cases.size() / pageSize;
            Integer mod = cases.size() - (totalPageNumber * pageSize);
            if (mod > 0) {
                totalPageNumber++;
            }
        }
        return totalPageNumber;
    }

    private List<Case> cases {
        get {
            if (waitedCases == null) {
                waitedCases = V1CaseCollector.getCasesWaitingOrPortingByOwners(new String[] {settings.getDefectQueueId(), settings.getStoryQueueId()});
            }
            return waitedCases;
        }
        set;
    }

    private void tableBindData(Integer newPageIndex) {
        try {
            fillCasesForCurrentPage(newPageIndex);
            pageNumber = newPageIndex;
            isNoDataForTable1 = false;
            if (pageCases == null || pageCases.size() <= 0) {
                isNoDataForTable1 = true;
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    }

    private void fillCasesForCurrentPage(Integer newPageIndex) {
        pageCases = new List<Case>();
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

        for(Case c : cases) {
            counter++;
            if (counter > min && counter <= max) {
                pageCases.add(c);
            }
        }
    }

    public PageReference table1NextBtnClick() {
        tableBindData(pageNumber + 1);
        return null;
    }

    public PageReference table1PreviousBtnClick() {
        tableBindData(pageNumber - 1);
        return null;
    }
}