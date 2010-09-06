/**
* This is mock of Requestor class for testing
*
**/
public class RequestorMock implements IRequestor {
    public List<String> responceBody = new List<String>();
    public List<Integer> statusCode = new List<Integer>();
    public List<String> bodyForSend = new List<String>();
    public List<String> urlForSend = new List<String>();
    public Integer numberRequest = 0;
    public List<Exception> exceptions;

    public RequestorMock(String body, Integer statusCode) {
        this(body, statusCode, null);
    }

    public RequestorMock(String body, Integer statusCode, List<Exception> exceptions) {
        this.responceBody.add(body);
        this.statusCode.add(statusCode);
        this.exceptions = exceptions;
    }

    public RequestorMock(List<String> bodies, List<Integer> statusCodes, List<Exception> exceptions) {
        this.responceBody = bodies;
        this.statusCode = statusCodes;
        this.exceptions = exceptions;
    }

    public String getBody() {
    	if (numberRequest > responceBody.size()) {
    		responceBody.get(0);
    	}
        return responceBody.get(numberRequest-1);
    }

    public Integer getStatusCode() {
    	if (numberRequest > statusCode.size()) {
    		return statusCode.get(0);
    	}
        return statusCode.get(numberRequest-1);
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