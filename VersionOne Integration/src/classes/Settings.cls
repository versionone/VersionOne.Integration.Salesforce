public with sharing class Settings {
    private final V1Settings__c mycs;

    private String path;
    private String userName;
    private String password;
    private String source;
    private String sourceId;
    private String defectQueueId;
    private String storyQueueId;
    private String destQueueId;
    private String commentBody;
    private DateTime changeDateUTC;
    private String scheduleId;
    private String commentOnClosing;

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
                mycs.CommentBody__c = 'Escalated to VersionOne';
                mycs.CommentOnClosing__c = 'Closed in the VersionOne';
                insert mycs;
            }

            setPath(mycs.Path__c);
            setUserName(mycs.UserName__c);
            setPassword(mycs.Password__c);
            setCommentBody(mycs.CommentBody__c);
            setCommentOnClosing(mycs.CommentOnClosing__c);
            setSource(mycs.Source__c);
            setSourceId(mycs.V1SourceId__c);
            setDefectQueueId(mycs.EscalateQueueId__c);
            setStoryQueueId(mycs.StoryQueueId__c);
            setDestQueueId(mycs.AssignedQueueId__c);
            changeDateUTC = mycs.DateLastClosedAsset__c;
            setScheduleId(mycs.scheduleId__c);
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

    public String getDefectQueueId() {
        return defectQueueId;
    }

    public void setDefectQueueId(String id) {
        if (id == '') {
            defectQueueId = null;
        } else {
            defectQueueId = id;
        }
    }

    public String getStoryQueueId() {
        return storyQueueId;
    }

    public void setStoryQueueId(String id) {
        if (id == '') {
            storyQueueId = null;
        } else {
            storyQueueId = id;
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
        return sourceId;
    }

    public void setSourceId(String id) {
        sourceId = id;
    }

    public String getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(String id) {
        if (id == '') {
            scheduleId = null;
        } else {
            scheduleId = id;
        }
    }

    public String getCommentOnClosing() {
        return commentOnClosing;
    }

    public void setCommentOnClosing(String text) {
        if (text == '') {
            commentOnClosing = null;
        } else {
            commentOnClosing = text;
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

    public void setLastDateChangeAsset(DateTime changeDateUTC) {
        this.changeDateUTC = changeDateUTC;
    }

    public DateTime getLastDateChangeAsset() {
        return this.changeDateUTC;
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
            mycs.EscalateQueueId__c = defectQueueId;
            mycs.StoryQueueId__c = storyQueueId;
            mycs.AssignedQueueId__c = destQueueId;
            mycs.CommentBody__c = commentBody;
            mycs.CommentOnClosing__c = commentOnClosing;
            mycs.V1SourceId__c = sourceId;
            mycs.DateLastClosedAsset__c = changeDateUTC;
            mycs.ScheduleId__c = scheduleId;
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
        Map<String, String> requredData = new Map<String, String>();
        requredData.put(getPath(), 'URL is required field.');
        requredData.put(getUserName(), 'User name is required field.');
        requredData.put(getSource(), 'Source is required field.');
        requredData.put(getDestQueueId(), 'You must choose a Destination Queue.');
        requredData.put(getDefectQueueId(), 'You must choose a Source Queue for Defects.');
        requredData.put(getStoryQueueId(), 'You must choose a Source Queue for Stories.');
        requredData.put(getPassword(), 'Password is required field.');

        List<String> res = new List<String>();
        for (String key : requredData.keySet()) {
            if (key == null) {
                res.add(requredData.get(key));
            }
        }

        Set<String> queues = new Set<String>();
        queues.add(getDefectQueueId());
        queues.add(getStoryQueueId());
        queues.add(getDestQueueId());
        if (queues.size() < 3){
            res.add('All queues must be different.');
        }
        return res;
    }
}