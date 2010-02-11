public class SettingsController {

    public String testSeverity{ get; set; }
    public String saveSeverity{ get; set; }
    public String testMessage{ get; set; }
    public String saveMessage{ get; set; }
    public Boolean isSettingsValidated { get; set; }
    public Boolean isSettingsCorrect { get; set; }
    public Boolean isSaved { get; set; }
    public Settings settings {get; set;}

    private transient IRequestor requestor;

    public PageReference saveSettings() {
        if (!validateRequiredFields()) {
            isSettingsCorrect = false;
            isSettingsValidated = false;
            testMessage = '';
            isSaved = false;
            return null;
        }
        if (!isSettingsCorrect) {
            ApexPages.addMessage(getErrorMessage('Settings is not correct or was not validated.'));
            return null;
        }
        System.debug('Save Settings');
        testMessage = '';
        testSeverity = '';
        saveSeverity = 'info';
        saveMessage = 'Settings has been saved.';
        isSettingsValidated = false;
        isSaved = true;
        try {
            settings.updateSettings();
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
        if (requestor == null) {
            requestor = new Requestor(settings);
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
                ApexPages.addMessage(getErrorMessage(requredData.get(key)));
                result = false;
            }
        }

        /*
        if (settings.getPath() == null || settings.getPath() == '') {
            ApexPages.addMessage(getErrorMessage('URL is required field.'));
            result = false;
        }
        if (settings.getSource() == null || settings.getSource() == '') {
            ApexPages.addMessage(getErrorMessage('Source is required field.'));
            result = false;
        }
        if (settings.getUserName() == null || settings.getUserName() == '') {
            ApexPages.addMessage(getErrorMessage('User name is required field.'));
            result = false;
        }
        if (settings.getSourceQueueId() == null) {
            ApexPages.addMessage(getErrorMessage('You must choose a Source Queue.'));
            result = false;
        }
        if (settings.getDestQueueId() == null) {
            ApexPages.addMessage(getErrorMessage('You must choose a Destination Queue.'));
            result = false;
        }
        */
        if (settings.getDestQueueId() == settings.getSourceQueueId()) {
            ApexPages.addMessage(getErrorMessage('Source Queue and Destination Queue must be different.'));
            result = false;
        }
        return result;
    }

    private static ApexPages.Message getErrorMessage(String text) {
        return new ApexPages.Message(ApexPages.Severity.ERROR, text);
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
    }

    private static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name="{0}"';
    public boolean validateConnectionAndSource() {
        if (settings.getSource() == null) {
            throw new VersionOneException('Incorrect source.', '');
        }
        XMLDom xmlParser = new XMLDom();
        String escapedSourceName = EncodingUtil.urlEncode(settings.getSource(), 'UTF-8');

        //Send the request, and get a response
        requestor.request(requestor.createRequest('', String.format(SOURCE_URL, new String[]{escapedSourceName}), 'GET'));
        System.debug('Responce code = ' + requestor.getStatusCode());
        System.debug('Responce body = ' + requestor.getBody());
        if (requestor.getStatusCode() == 200) {
            xmlParser.parseFromString(requestor.getBody());
        }else if (requestor.getStatusCode() == 401){
            throw new VersionOneException('Credentials is not correct.', '');
        }else if (requestor.getStatusCode() == 500 || requestor.getStatusCode() == 404){
            throw new VersionOneException('URL is not correct or VersionOne server has some problems at the moment.', '');
        }else {
            throw new VersionOneException('Problem with getting source from the VersionOne.', requestor.getBody());
        }

        XMLDom.Element assetTag = xmlParser.getElementByTagName('Asset');
        System.debug('findSourceId respond = ' + xmlParser.toXmlString());
        if (assetTag != null) {
            return true;
        }

        throw new VersionOneException('Source setting is not correct.', '');
    }

    public void setRequestor(IRequestor requestor) {
        this.requestor = requestor;
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
}