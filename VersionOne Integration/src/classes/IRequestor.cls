public interface IRequestor {
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

	void request(HttpRequest request);

	HttpRequest createRequest(String body, String additionUrl, String requestType);
}