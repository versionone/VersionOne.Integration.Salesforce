public with sharing class Settings implements ISettings {
	private final V1Settings__c mycs;

	private String path;
	private String userName;
	private String password;
	private String source;
	private String escalateQueueId;
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
				insert mycs;
			}
			mycs.Path__c = 'http://195.62.49.62:7001/VersionOne/';

			path = mycs.Path__c;
			userName = mycs.UserName__c;
			password = mycs.Password__c;
			urlV1Field = 'VersionOneUrl__c';
			source = 'SalesForce';
		}

		String queueName = 'Escalate to VersionOne';
		String queueString = 'SELECT ID, Name FROM Group WHERE Name=\''+queueName+'\'' ;
		Group owner = (Group) Database.query(queueString);
		escalateQueueId = owner.Id;
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

	public String getPassword() {
		return password;
	}

	public String getEscalateQueueId() {
		return escalateQueueId;
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