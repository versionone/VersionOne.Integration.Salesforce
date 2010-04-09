public class V1SynchronizerController {

	public V1SynchronizerController() {
	}

	public void initData() {
		showSynchronizerInfo();
	}

    public PageReference forceSync() {
        try {
            Synchronizer.runSynchronizerWithVersionOne();
            Synchronizer.isFutureRan();
        } catch (Exception ex) {
            addErrorMessage('Failed to run cases updater.');
            ApexPages.addMessages(ex);
        }

        try {
            BatchPublisher batch = new BatchPublisher(new ConnectionFactory());
            ID batchprocessid = Database.executeBatch(batch, 1);
            settings.setBatchId(batchprocessid);
            isBatchRan = true;
        } catch (Exception ex) {
            addErrorMessage('Failed to run cases publisher.');
            ApexPages.addMessages(ex);
        }

        addConfirmMessage('Synchronizer was started.');

        settings.updateBatchId();

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
            displayFutureProgress(futureData);
        }
        if (!isBatchRan && !isFutureRan && settings.getBatchId() != null) {
            settings.setBatchId(null);
            settings.updateBatchId();
        }
    }

    private void displayBatchProgress(String id) {
        Map<String, String> batchData = BatchPublisher.getBatchData(id);
        if (batchData == null) {
            return;
        }
        addInfoMessage('Case publish status: ' + batchData.get('Status'));
        addInfoMessage('Cases published: ' + batchData.get('JobItemsProcessed'));
        //addInfoMessage('Number of errors: ' + batchData.get('NumberOfErrors'));
        //addInfoMessage('Total cases: ' + batchData.get('TotalJobItems'));
    }

    private void displayFutureProgress(Map<String, String> data) {
    	String status;
    	if (data != null) {
			status = data.get('Status');
    	} else {
    		status = 'Completed';
    	}
        addInfoMessage('Case update status: ' + status);
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
}