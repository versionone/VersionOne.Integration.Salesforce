public with sharing class Settings implements ISettings {
	private final V1Settings__c mycs;
	private final String escalateQueueId;
	private static final String testSettingsName = 'TestSettings';

	private String source;

	public Settings () {
		this('V1Settings');
	}

	private Settings(String settingsName) {
		mycs = V1Settings__c.getValues(settingsName);

		if(mycs == null) {
			mycs = new V1Settings__c(Name = settingsName);
			mycs.Path__c = 'http://localhost/VersionOne/';
			mycs.UserName__c = 'admin';
			mycs.Password__c = 'admin';
			insert mycs;
		}

		mycs.Path__c = 'http://195.62.49.62:7001/VersionOne/';
		source = 'SalesForce';


		String queueName = 'Escalate to VersionOne';
		String queueString = 'SELECT ID, Name FROM Group WHERE Name=\''+queueName+'\'' ;
		Group owner = (Group) Database.query(queueString);
		escalateQueueId = owner.Id;
	}

	public static Settings getTestSettings() {
		 Settings settings = new Settings(testSettingsName);
		 settings.setSource('TestSource');
		 return settings;
	}

	public static void deleteTestSettings() {
		V1Settings__c forDel = V1Settings__c.getValues(testSettingsName);
		delete forDel;
	}

	public String getPath() {
		return mycs.Path__c;
	}

	public void setPath(String path) {
		mycs.Path__c = path;
	}

	public String getUserName() {
		return mycs.UserName__c;
	}

	public String getPassword() {
		return mycs.Password__c;
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
}