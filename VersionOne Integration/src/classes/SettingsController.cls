public class SettingsController {

	private transient IRequestor requestor;

    public PageReference SaveSettings() {
        System.debug('Save Settings');
        testMessage = '';
        testMessage = '';
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


    public String testSeverity{ get; set; }
    public String saveSeverity{ get; set; }
    public String testMessage{ get; set; }
    public String saveMessage{ get; set; }
    public Boolean isSettingsValidated { get; set; }
    public Boolean isSettingsCorrect { get; set; }
    public Boolean isSaved { get; set; }
	public Settings settings {get; set;}


    public PageReference TestSettings() {
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


    public String getGreeting() {
        return 'Hello tester!';
    }

    public void initSettings() {
        testMessage = '';
        saveMessage = '';
        isSettingsValidated = false;
        isSettingsCorrect = false;
        isSaved = false;
        settings = new Settings();
    }

    private static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name="{0}"';
    private boolean validateConnectionAndSource() {
    	XMLDom xmlParser = new XMLDom();
	    String escapedSourceName = EncodingUtil.urlEncode(settings.getSource(), 'UTF-8');

	    //Send the request, and get a response
	    //requestor.doGet('', String.format(SOURCE_URL, new String[]{escapedSourceName}));
	    requestor.request(requestor.createRequest('', String.format(SOURCE_URL, new String[]{escapedSourceName}), 'GET'));
	    System.debug('Responce code = ' + requestor.getStatusCode());
	    System.debug('Responce body = ' + requestor.getBody());
	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    }else if (requestor.getStatusCode() == 401){
			throw new VersionOneException('Credentions is not correct.', '');
	    }else if (requestor.getStatusCode() == 500){
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
/*
    public PageReference initPageAction() {
        PageReference homePage= new PageReference('/home/test.jsp');
        homePage.setRedirect(true);
        return homePage;
    }
    */


/*
    public PageReference save() {
        // Add the account to the database.
        //insert settings;

        // Send the user to the detail page for the new account.
        //PageReference acctPage = new ApexPages.StandardController(settings).view();
        //acctPage.setRedirect(true);

        return new PageReference();
    }
    */

    public void setRequestor(IRequestor requestor) {
    	this.requestor = requestor;
    }

    public List<SelectOption> getQueueList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('00GA0000000iNOGMA2','Escalate to VersionOne'));
        options.add(new SelectOption('00GA0000000iNOLMA2','Assigned to VersionOne'));
        options.add(new SelectOption('CANADA','Canada'));
        options.add(new SelectOption('MEXICO11','Mexico11'));
        options.add(new SelectOption('MEXICO31','Mexico21'));
        options.add(new SelectOption('MEXICO41','Mexico31'));
        options.add(new SelectOption('MEXICO51','Mexico41'));
        options.add(new SelectOption('MEXICO61','Mexico51'));
        options.add(new SelectOption('MEXICO71','Mexico61'));
        options.add(new SelectOption('MEXICO81','Mexico71'));

        options.add(new SelectOption('MEXICO12','Mexico12'));
        options.add(new SelectOption('MEXICO32','Mexico22'));
        options.add(new SelectOption('MEXICO42','Mexico32'));
        options.add(new SelectOption('MEXICO52','Mexico42'));
        options.add(new SelectOption('MEXICO62','Mexico52'));
        options.add(new SelectOption('MEXICO72','Mexico62'));
        options.add(new SelectOption('MEXICO82','Mexico72'));

        options.add(new SelectOption('MEXICO13','Mexico13'));
        options.add(new SelectOption('MEXICO33','Mexico23'));
        options.add(new SelectOption('MEXICO43','Mexico33'));
        options.add(new SelectOption('MEXICO53','Mexico43'));
        options.add(new SelectOption('MEXICO63','Mexico53'));
        options.add(new SelectOption('MEXICO73','Mexico63'));
        options.add(new SelectOption('MEXICO83','Mexico73'));
        return options;
    }
}