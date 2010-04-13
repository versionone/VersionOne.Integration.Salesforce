public class Synchronizer {

    private final Settings settings;
    private final IV1Connector connector;

    public Synchronizer(Settings settings) {
        this.settings = settings;
        connector = new V1Connector(settings, new Requestor(settings));
    }

    public Synchronizer(Settings settings, IV1Connector connector) {
        this.settings = settings;
        this.connector = connector;
    }

    /**
     * Update cases.
     *
     * Returns: count of updated Cases.
     * Throws: Exception on errors.
     */
    public Integer syncCases() {
        if (!publishedCasesExist()) {
            return 0;
        }
        List<String> closedCases = connector.getClosedWorkitems();
        Case[] cases = V1CaseCollector.getCasesByCaseNumbersAndOwnerId(closedCases, settings.getDestQueueId());
        if (cases != null && cases.size() == 0) {
            // store date of last closed defect in the VersionOne (date was set in the getCasesByCaseNumbers method)
            // because of MIXED_DML_OPERATION we can save it only if no one case is updated
            connector.getSettings().updateDateLastClosedAsset();
        } else if (cases != null) {
            V1CaseCollector.closeCases(cases, settings.getCommentOnClosing());
        }
        return cases.size();
    }

    public Boolean publishedCasesExist() {
        List<Case> portedCases = V1CaseCollector.getCasesByOwnerId(settings.getDestQueueId(), false);
        System.debug('published cases exist: ' + portedCases.size());
        return portedCases.size() > 0;
    }

    public static Map<String, String> getFutureCurrentFuture() {
        String jobType = 'future';
        String methodName = 'runSynchronizerWithVersionOne';
        String[] statuses = new String[]{'Queued', 'Processing'};
        AsyncApexJob aaj;
        try {
            aaj = [SELECT Id, Status, NumberOfErrors
                FROM AsyncApexJob WHERE
                    JobType =: jobType AND
                    MethodName =: methodName AND
                    Status in: statuses];
        } catch (QueryException ex) {
            // no current future was ran
            return null;
        }

        Map<String, String> futureData = new Map<String, String>();
        futureData.put('Status', aaj.Status);
        futureData.put('NumberOfErrors', String.valueof(aaj.NumberOfErrors));

        return futureData;
    }

    public static Boolean isFutureRan() {
        Map<String, String> futureData = getFutureCurrentFuture();
        if (futureData == null) {
            return false;
        }
        return futureData.get('Status') == 'Queued' || futureData.get('Status') == 'Processing';
    }

    public static Integer amountUpdatedCases { set; get; }

    @future (callout=true)
    public static void runSynchronizerWithVersionOne() {
        try {
            amountUpdatedCases = new Synchronizer(new Settings()).syncCases();
        } catch (Exception ex) {
            System.debug('Failed to update Cases. ' + ex.getMessage());
        }
    }
}