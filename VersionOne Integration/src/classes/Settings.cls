public with sharing class Settings {
    private final V1Settings__c mycs;

    private String path;
    private String userName;
    private String password;
    private String source;
    private String sourceQueueId;
    private String destQueueId;
    private String commentBody;

    public Settings () {
        this('V1Settings');
    }

    private Settings(String settingsName) {
        if (settingsName != null) {
            mycs = V1Settings__c.getValues(settingsName);

            if(mycs == null) {
                mycs = new V1Settings__c(Name = settingsName);
                mycs.Path__c = 'http://localhost/VersionOne/';
                mycs.UserName__c = 'admin';
                mycs.Password__c = 'admin';
                mycs.EscalateQueueId__c = null;
                mycs.AssignedQueueId__c = null;
                mycs.Source__c = 'SalesForce';
                mycs.CommentBody__c = 'Escalated to VersionOne';
                insert mycs;
            }
            // just some hardcode till we don't have UI for settings
            //mycs.Path__c = 'http://195.62.49.62:7001/VersionOne/';
            //mycs.Source__c = 'SalesForce';
            //\\

            path = mycs.Path__c;
            userName = mycs.UserName__c;
            password = mycs.Password__c;
            commentBody = mycs.commentBody__c;
            source = mycs.Source__c;
            sourceQueueId = mycs.EscalateQueueId__c;
            destQueueId = mycs.AssignedQueueId__c;
        }
    }

    public static Settings getTestSettings() {
         Settings settings = new Settings(null);
         settings.setSource('TestSource');
         settings.setPath('http://195.62.49.62:7001/VersionOne/');
         return settings;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
    	if (path != null && path != '' && !path.endsWith('/')) {
    		path = path + '/';
    	}
        this.path = path;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getSourceQueueId() {
        return sourceQueueId;
    }

    public void setSourceQueueId(String id) {
        if (id == '')
            sourceQueueId = null;
        else
            sourceQueueId = id;
    }

    public String getDestQueueId() {
        return destQueueId;
    }

    public void setDestQueueId(String id) {
        if (id == '')
            destQueueId = null;
        else
            destQueueId = id;
    }

    public String getSource() {
        return this.source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getV1Url() {
        return 'VersionOneUrl__c';
    }

    public void updateSettings() {
        System.debug('update Settings');
        if (mycs != null) {
	        mycs.Path__c = path;
	        mycs.UserName__c = userName;
	        mycs.Password__c = password;
	        mycs.Source__c = source;
	        mycs.EscalateQueueId__c = sourceQueueId;
	        mycs.AssignedQueueId__c = destQueueId;
	        mycs.CommentBody__c = commentBody;
	        update mycs;
    	}
    }

    public String getCommentBody() {
        return commentBody;
    }

    public void setCommentBody(String text) {
        if (text == '')
            commentBody = null;
        else
            commentBody = text;
    }
}