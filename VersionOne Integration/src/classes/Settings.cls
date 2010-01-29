public with sharing class Settings {
	private final V1Settings__c mycs;

	private String path;
	private String userName;
	private String password;
	private String source;
	private String sourceQueueId;
	private String destQueueId;
	private String urlV1Field;

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
				mycs.EscalateQueueId__c = '0';
				//mycs.UrlV1Field__c = 'VersionOneUrl__c';
				mycs.Source__c = 'SalesForce';
				insert mycs;
			}
			// just some hardcode till we don't have UI for settings
			mycs.Path__c = 'http://195.62.49.62:7001/VersionOne/';
			String queueName = 'Escalate to VersionOne';
			String queueString = 'SELECT ID, Name FROM Group WHERE Name=\''+queueName+'\'' ;
			Group owner = (Group) Database.query(queueString);
			mycs.EscalateQueueId__c = owner.Id;
			mycs.AssignedQueueId__c = V1CaseCollector.getQueueIdByName('Assigned to VersionOne');
			mycs.Source__c = 'SalesForce';
			//\\

			path = mycs.Path__c;
			userName = mycs.UserName__c;
			password = mycs.Password__c;
			urlV1Field = 'VersionOneUrl__c';
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

	public String getDestQueueId() {
		return destQueueId;
	}

	public String getSource() {
		return this.source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getV1Url() {
		return urlV1Field;
	}
}