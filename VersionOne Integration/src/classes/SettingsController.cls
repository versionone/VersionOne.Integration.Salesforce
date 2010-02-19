public class SettingsController {

    public String testSeverity{ get; set; }
    public String saveSeverity{ get; set; }
    public String testMessage{ get; set; }
    public String saveMessage{ get; set; }
    public Boolean isSettingsValidated { get; set; }
    public Boolean isSettingsCorrect { get; set; }
    public Boolean isSaved { get; set; }
    public Settings settings {get; set;}
    public Boolean isSyncEnabled {get; set;}

    private transient IV1Connector connector;

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
        if (!validateRequiredFields()) {
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
        String sourceId = getSourceId();
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
        if (!validateRequiredFields()) {
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
        } catch (VersionOneException ex) {
            testSeverity = 'error';
            testMessage = ex.getErrorMessage();
            isSettingsCorrect = false;
        } catch (Exception ex) {
            testSeverity = 'error';
            testMessage = 'Internal error:' + ex.getMessage();
            isSettingsCorrect = false;
        }

        System.debug('Path:' + Settings.getPath() + ', UserName:' + Settings.getUserName() + ', Password:' + Settings.getPassword());
        System.debug('testMessage=' + testMessage);

        isSettingsValidated = true;
        isSaved = false;

        return null;
    }

    /**
    * Validates required fields. Adds errors messages on page.
    *
    * settings - settings to validate.
    * Returns 	true  - if all requred fields are filled.
    *			false - if any of requred fields are not filled.
    **/
    public Boolean validateRequiredFields() {
        Map<String, String> requredData = new Map<String, String>();
        // key - value for verify on null, value - error, if value is null
        requredData.put(settings.getPath(), 'URL is required field.');
        requredData.put(settings.getUserName(), 'User name is required field.');
        requredData.put(settings.getSource(), 'Source is required field.');
        requredData.put(settings.getDestQueueId(), 'You must choose a Destination Queue.');
        requredData.put(settings.getSourceQueueId(), 'You must choose a Source Queue.');
        requredData.put(settings.getPassword(), 'Password is required field.');

        Boolean result = true;
        for (String key : requredData.keySet()) {
            if (key == null) {
                addErrorMessage(requredData.get(key));
                result = false;
            }
        }

        if (settings.getDestQueueId() == settings.getSourceQueueId()) {
            addErrorMessage('Source Queue and Destination Queue must be different.');
            result = false;
        }
        return result;
    }

    private static void addErrorMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, text));
    }

    public void initSettings() {
        testMessage = '';
        saveMessage = '';
        isSettingsValidated = false;
        isSettingsCorrect = false;
        isSaved = false;
        if (settings == null) {
            settings = new Settings();
        }
        isSyncEnabled = SyncSchedule.isScheduled(settings.getScheduleId());
    }

    public boolean validateConnectionAndSource() {
        if (settings.getSource() == null) {
            throw new VersionOneException('Incorrect source.', '');
        }

        if (getSourceId() != null) {
            return true;
        }

        throw new VersionOneException('Source setting is not correct.', '');
    }

    public String getSourceId() {
        if (connector == null) {
            IRequestor requestor = new Requestor(settings);
            connector = new V1Connector(settings, requestor);
        }

        return connector.getSourceId();
    }

    public void setConnector(IV1Connector connector) {
        this.connector = connector;
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
        } catch (VersionOneException ex) {
            addErrorMessage('Failed to update Cases.');
            addErrorMessage(ex.getErrorMessage());
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