public class SettingsController {

    public String testSeverity{get; set;}
    public String saveSeverity{get; set;}
    public String testMessage{get; set;}
    public String saveMessage{get; set;}
    public Boolean isSettingsValidated {get; set;}
    public Boolean isSettingsCorrect {get; set;}
    public Boolean isSaved {get; set;}

    public Settings settings {
        get {
            if (settings == null) {
                settings = new Settings();
            }
            return settings;
        } set;}

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
    }


    public PageReference saveSettings() {
    	isSettingsCorrect = validateSettings();
    	String sourceId;
    	try {
    		sourceId = connector.getSourceId();
    	} catch (Exception ex) {}
        if (!isSettingsCorrect || sourceId == null) {
        	isSettingsCorrect = false;
            isSettingsValidated = false;
            testMessage = '';
            isSaved = false;
            addErrorMessage('Settings is not correct or was not validated.');
            return null;
        }

        settings.setSourceId(sourceId);

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

    private static void addInfoMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, text));
    }

    public void validateConnectionAndSource() {
        if (settings.getSource() == null || connector.getSourceId() == null) {
            throw new V1RequestException('Incorrect source.');
        }
    }
}