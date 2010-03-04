public class SettingsController {

    public String testSeverity{get; set;}
    public String saveSeverity{get; set;}
    public String testMessage{get; set;}
    public String saveMessage{get; set;}
    public Boolean isSettingsValidated {get; set;}
    public Boolean isSettingsCorrect {get; set;}
    public Boolean isSaved {get; set;}
    public Settings settings {get {
        if (settings == null) {
            settings = new Settings();
        }
        return settings;} set;}
    public Boolean isSyncEnabled {get; set;}

    private transient IV1Connector innerConnector;
    public IV1Connector connector {
        get {
            if (innerConnector == null) {
                innerConnector = new V1Connector(settings, new Requestor(settings));
            }
            return innerConnector;
        }
        set {
            innerConnector = value;
        }}

    /** Must be called before usage of any other method. */
    public void initSettings() {
        testMessage = '';
        saveMessage = '';
        isSettingsValidated = false;
        isSettingsCorrect = false;
        isSaved = false;
        isSyncEnabled = SyncSchedule.isScheduled(settings.getScheduleId());
    }

    public String updateSchedule() {
        String oldId = settings.getScheduleId();
        Boolean isScheduled = SyncSchedule.isScheduled(oldId);
        if (isSyncEnabled) {
            if (!isScheduled) {
                return SyncSchedule.addSchedule();
            }
            return oldId;
        }
        // Disable Sync
        if (isScheduled) {
            SyncSchedule.unschedule(oldId);
        }
        return null;
    }

    public PageReference saveSettings() {
        if (!validateSettings()) {
            isSettingsCorrect = false;
            isSettingsValidated = false;
            testMessage = '';
            isSaved = false;
            return null;
        }
        if (!isSettingsCorrect) {
            addErrorMessage('Settings is not correct or was not validated.');
            return null;
        }
        String sourceId = connector.getSourceId();
        if (sourceId == null) {
            isSettingsCorrect = false;
            isSettingsValidated = false;
            testMessage = '';
            isSaved = false;
            return null;
        }
        settings.setSourceId(sourceId);
        settings.setScheduleId(updateSchedule());

        System.debug('Save Settings');
        testMessage = '';
        testSeverity = '';
        isSettingsValidated = false;
        isSaved = true;
        try {
            settings.updateSettings();
            saveSeverity = 'info';
            saveMessage = 'Settings has been saved.';
        } catch (Exception ex) {
            saveSeverity = 'error';
            saveMessage = 'Settings has not been saved. Reason:' + ex.getMessage();
        }
        return null;
    }

    public PageReference testSettings() {
        if (!validateSettings()) {
            isSettingsCorrect = false;
            isSettingsValidated = false;
            testMessage = '';
            return null;
        }

        try {
            validateConnectionAndSource();
            testSeverity = 'info';
            testMessage = 'Settings correct.';
            isSettingsCorrect = true;
        } catch (Exception ex) {
            testSeverity = 'error';
            testMessage = ex.getMessage();
            isSettingsCorrect = false;
        }

        System.debug('Path:' + Settings.getPath() + ', UserName:' + Settings.getUserName() + ', Password:' + Settings.getPassword());
        System.debug('testMessage=' + testMessage);

        isSettingsValidated = true;
        isSaved = false;

        return null;
    }

    /**
     * Validates settings and adds errors messages on page if any.
     *
     * settings - settings to validate.
     * Returns 	true  - if all requred fields are filled.
     *			false - if any of requred fields are not filled.
     */
    public Boolean validateSettings() {
        String[] errors = settings.validate();
        for (String msg : errors) {
            addErrorMessage(msg);
        }
        return errors.size() == 0;
    }

    private static void addErrorMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, text));
    }

    public void validateConnectionAndSource() {
        if (settings.getSource() == null || connector.getSourceId() == null) {
            throw new V1RequestException('Incorrect source.');
        }
    }

    public static List<SelectOption> getQueueList() {
        Group[] queues = V1CaseCollector.getQueuesList();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        for(Group queue : queues) {
            options.add(new SelectOption(queue.Id, queue.Name));
        }
        return options;
    }

    public PageReference forceSync() {
        try {
            Integer count = (new Synchronizer(settings)).syncCases();
            String countStr = (count == 0 ? 'No' : String.valueOf(count));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                countStr + ' Cases have been closed.'));
        } catch (Exception ex) {
            addErrorMessage('Failed to update Cases.');
            ApexPages.addMessages(ex);
        }
        testMessage = '';
        testSeverity = '';
        saveSeverity = '';
        saveMessage = '';
        isSettingsValidated = false;
        isSaved = false;
        return null;
    }
}