public interface IRequestor {
	/**
	* Makes GET request
	**/
	void doGet(String body, String url);

	/**
	* Makes POST request
	**/
	void doPost(String body, String url);

	/**
	* Returns body from responce
	*
	**/
	String getBody();

	/**
	* Return status code from responce
	*
	**/
	Integer getStatusCode();
}