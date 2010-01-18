public with sharing class Settings {
	private final V1Settings__c mycs;
	private final String escalateQueueId;

	public Settings () {
		User thisUser = [ Select Id from User where Id = :UserInfo.getUserId() ];

		mycs = V1Settings__c.getValues('V1Settings');

		if(mycs == null) {
			mycs = new V1Settings__c(Name= 'V1Settings');
			mycs.Path__c = 'http://localhost';
			mycs.UserName__c = 'admin';
			mycs.Password__c = 'admin';
			insert mycs;
		}


		String queueName = 'Escalate to VersionOne';
		String queueString = 'SELECT ID, Name FROM Group WHERE Name=\''+queueName+'\'' ;
		Group owner = (Group) Database.query(queueString);
		escalateQueueId = owner.Id;
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
}