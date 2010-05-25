global with sharing class Settings {

    private final V1Settings__c mycs;

    private String path;
    private String userName;
    private String password;
    private String source;
    private String sourceId;
    private DateTime changeDateUTC;
    private String projectId;
    private String projectName;

    public Settings () {
        this(getMics('V1Settings'));
    }

    private Settings(V1Settings__c mycs) {
        if (mycs != null) {
            this.mycs = mycs;
            setPath(mycs.Path__c);
            setUserName(mycs.UserName__c);
            setPassword(mycs.Password__c);
            setSource(mycs.Source__c);
            setSourceId(mycs.V1SourceId__c);
            setProjectId(mycs.V1ProjectId__c);
            setProjectName(mycs.V1ProjectName__c);
            changeDateUTC = mycs.DateLastClosedAsset__c;
        }
    }

    private static V1Settings__c getMics(String name) {
        V1Settings__c res = V1Settings__c.getValues(name);
        if(res == null) {
            System.debug('Settings not found. Creating new one.');
            res = new V1Settings__c(Name = name);
            res.Path__c = 'http://example.com/VersionOne/';
            res.UserName__c = 'admin';
            insert res;
        }
        return res;
    }

    public static Settings getTestSettings() {
         Settings settings = new Settings(null);
         return settings;
    }

    public String getPathTitle() {
        return 'URL to VersionOne';
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        if (path == '') {
            path = null;
        }
        if (path != null && !path.endsWith('/')) {
            path = path + '/';
        }
        this.path = path;
    }

    public String getUserNameTitle() {
        return 'User name';
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String name) {
        if (name == '') {
            userName = null;
        } else {
            userName = name;
        }
    }

    public String getPasswordTitle() {
        return 'Password';
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        if (password == '') {
            this.password = null;
        } else {
            this.password = password;
        }
    }

    public String getSourceTitle() {
        return 'Source';
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        if (source == '') {
            this.source = null;
        } else {
            this.source = source;
        }
    }

    public String getSourceId() {
        return sourceId;
    }

    public void setSourceId(String id) {
        sourceId = id;
    }

    public void setProjectId(String id) {
    	projectId = id;
    }

    public String getProjectId() {
    	return projectId;
    }

    public void setProjectName(String name) {
    	projectName = name;
    }

    public String getProjectName() {
    	return projectName;
    }

    public void setLastDateChangeAsset(DateTime changeDateUTC) {
        this.changeDateUTC = changeDateUTC;
    }

    public DateTime getLastDateChangeAsset() {
        return this.changeDateUTC;
    }

    public void updateSettings() {
        System.debug('update Settings');
        if (mycs != null) {
            mycs.Path__c = path;
            mycs.UserName__c = userName;
            mycs.Password__c = password;
            mycs.Source__c = source;
            mycs.V1SourceId__c = sourceId;
            mycs.DateLastClosedAsset__c = changeDateUTC;
            mycs.V1ProjectId__c = projectId;
            mycs.V1ProjectName__c = projectName;
            update mycs;
        } //else Do nothing (used in tests)
    }

    /**
     * Store date of last closed asset to SF custom settings storage
     */
    public void updateDateLastClosedAsset() {
        if (mycs != null) {
            mycs.DateLastClosedAsset__c = changeDateUTC;
            update mycs;
        } //else Do nothing (used in tests)
    }

    /** Returns array of error messages or empty array if all is crrect. */
    public String[] validate() {
        List<String> res = new List<String>();
        testAndAddMessage(res, getPathTitle(), getPath());
        testAndAddMessage(res, getUserNameTitle(), getUserName());
        testAndAddMessage(res, getSourceTitle(), getSource());
        testAndAddMessage(res, getPasswordTitle(), getPassword());

        return res;
    }

    /** Adds error message for specified field if value is null */
    public static void testAndAddMessage(List<String> res, String fieldTitle, object value) {
        if (value == null) {
            res.add('You must fill ' + fieldTitle);
        }
    }

    /** Returns true if settings are crrect. */
    public Boolean isValid() {
        return validate().size() == 0;
    }
}