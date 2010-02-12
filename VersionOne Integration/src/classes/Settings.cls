public with sharing class Settings {
    private final V1Settings__c mycs;

    private String path;
    private String userName;
    private String password;
    private String source;
    private String sourceId;
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
                mycs.Path__c = 'http://example.com/VersionOne/';
                mycs.UserName__c = 'admin';
                //mycs.Password__c = 'admin';
                //mycs.EscalateQueueId__c = null;
                //mycs.AssignedQueueId__c = null;
                //mycs.Source__c = 'SalesForce';
                mycs.CommentBody__c = 'Escalated to VersionOne';
                insert mycs;
            }

            path = mycs.Path__c;
            userName = mycs.UserName__c;
            password = mycs.Password__c;
            commentBody = mycs.commentBody__c;
            source = mycs.Source__c;
            sourceId = mycs.V1SourceId__c;
            sourceQueueId = mycs.EscalateQueueId__c;
            destQueueId = mycs.AssignedQueueId__c;
        }
    }

    public static Settings getTestSettings() {
         Settings settings = new Settings(null);
         return settings;
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

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        if (userName == '') {
            this.userName = null;
        } else {
            this.userName = userName;
        }
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

    public String getSourceQueueId() {
        return sourceQueueId;
    }

    public void setSourceQueueId(String id) {
        if (id == '') {
            sourceQueueId = null;
        } else {
            sourceQueueId = id;
        }
    }

    public String getDestQueueId() {
        return destQueueId;
    }

    public void setDestQueueId(String id) {
        if (id == '') {
            destQueueId = null;
        } else {
            destQueueId = id;
        }
    }

    public String getSource() {
        return this.source;
    }

    public void setSource(String source) {
        if (source == '') {
            this.source = null;
        } else {
            this.source = source;
        }
    }

    public String getSourceId() {
    	return this.sourceId;
    }

    public void setSourceId(String sourceId) {
		this.sourceId = sourceId;
    }

    public String getV1Url() {
        return 'VersionOneUrl__c';
    }

    public String getV1Project() {
        return 'VersionOneProject__c';
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
            mycs.V1SourceId__c = sourceId;
            update mycs;
        } else {
            //TODO Can be there?
        }
    }

    public String getCommentBody() {
        return commentBody;
    }

    public void setCommentBody(String text) {
        if (text == '') {
            commentBody = null;
        } else {
            commentBody = text;
        }
    }

    /**
    * Returns true if main attributes are not null
    *
    **/
    public boolean isCorrect() {
        return getSource() != null && getDestQueueId() != null &&
            getSourceQueueId() != null && getPath() != null &&
            getUserName() != null && getPath() != null && getSourceId() != null;
    }
}