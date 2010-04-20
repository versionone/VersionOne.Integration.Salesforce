public class V1SynchronizerController {

    private static final String CASE_UPDATE_STATUS_TEXT = 'Case update status';
    private static final String CASE_PUBLISH_STATUS_TEXT = 'Case publish status';
    private static final String CASE_PUBLISHED_TEXT = 'Cases published';
    private static final String STATUS_COMPLETED_TEXT = 'Completed';

    private List<Case> waitedCases;
    private List<Case> portedCases;
    public TablePaginator table1Paginator {get; set;}
    public TablePaginator table2Paginator {get; set;}

    public V1SynchronizerController() {
    }

    public void initData() {
        table1Paginator = new TablePaginator(casesWaitingPorting);
        table1Paginator.init();
        table2Paginator = new TablePaginator(casesPorted);
        table2Paginator.init();

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
    public PageReference goToTable1Page() {
        String pageNumber = ApexPages.currentPage().getParameters().get('pageNumber');
        System.debug('go to page table 1:' + pageNumber);
        try {
            table1Paginator.goToPage(Integer.valueof(pageNumber));
        } catch (Exception ex) {
            //do nothing
        }
        return null;
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

    public PageReference table1NextBtnClick() {
        table1Paginator.nextBtnClick();
        return null;
    }

    public PageReference table1PreviousBtnClick() {
        table1Paginator.previousBtnClick();
        return null;
    }
    //\\-----------Table 1------------------
    // ----------Table 2------------------
    private List<Case> casesPorted {
        get {
            if (portedCases == null) {
                portedCases = V1CaseCollector.getCasesByOwners(new String[] {settings.getDestQueueId()});
            }
            return portedCases;
        }
        set;
    }

    public PageReference goToTable2Page() {
        String pageNumber = ApexPages.currentPage().getParameters().get('pageNumber');
        System.debug('go to page:' + pageNumber);
        try {
            table2Paginator.goToPage(Integer.valueof(pageNumber));
        } catch (Exception ex) {
            //do nothing
        }

        return null;
    }

    public PageReference table2NextBtnClick() {
        table2Paginator.nextBtnClick();
        return null;
    }

    public PageReference table2PreviousBtnClick() {
        table2Paginator.previousBtnClick();
        return null;
    }
    //\\ ----------Table 2------------------
}