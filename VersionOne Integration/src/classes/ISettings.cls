public interface ISettings {
	/**
	* Path to the VersionOne
	**/
	String getPath();
	/**
	* Set path to the VersionOne
	**/
	void setPath(String path);
	/**
	* Get user name for the VersionOne
	**/
	String getUserName();
	/**
	* Get password for the VersionOne
	**/
	String getPassword();
	/**
	* Get name of queue for porting Cases to Defects
	**/
	String getEscalateQueueId();
	/**
	* Get source name for the VersionOne defects
	**/
	String getSource();

}