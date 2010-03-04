public interface IRequestor {

    /** Returns responce body. */
    String getBody();

    /** Return status code of responce. */
    Integer getStatusCode();

    void request(HttpRequest request);

    HttpRequest createRequest(String body, String additionUrl, String requestType);
}