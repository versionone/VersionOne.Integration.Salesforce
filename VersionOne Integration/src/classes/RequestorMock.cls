/**
* This is mock of Requestor class for testing
*
**/
public class RequestorMock implements IRequestor {
    public String responceBody;
    public Integer statusCode;
    public List<String> bodyForSend = new List<String>();
    public List<String> urlForSend = new List<String>();
    public Integer numberRequest = 0;
    public List<Exception> exceptions;

    public RequestorMock(String body, Integer statusCode) {
        this(body, statusCode, null);
    }

    public RequestorMock(String body, Integer statusCode, List<Exception> exceptions) {
        this.responceBody = body;
        this.statusCode = statusCode;
        this.exceptions = exceptions;
    }

    public String getBody() {
        return responceBody;
    }

    public Integer getStatusCode() {
        return statusCode;
    }

    public String getSentBody(Integer i) {
        return bodyForSend.get(i);
    }

    public String getSentUrl(Integer i) {
        return urlForSend.get(i);
    }

    public void request(HttpRequest request) {
        System.debug('Call number:' + numberRequest);
        if (exceptions != null && exceptions.get(numberRequest) != null) {
            throw exceptions.get(numberRequest);
        }
        numberRequest++;
    }

    public HttpRequest createRequest(String body, String additionUrl, String requestType) {
        this.bodyForSend.add(body);
        this.urlForSend.add(additionUrl);
        return new HttpRequest();
    }
}