public class Requestor implements IRequestor {
    private final Settings settings;
    private HttpResponse responce;

    public Requestor(Settings settings) {
        this.settings = settings;
    }

    public String getBody() {
        return responce != null ? responce.getBody() : null;
    }

    public Integer getStatusCode() {
        return responce != null ? responce.getStatusCode() : null;
    }

    /**
    * Makes request
    **/
    public void request(HttpRequest request) {
        Http h = new Http();
        responce = h.send(request);
    }


    /**
    * Creates request
    *
    **/
    public HttpRequest createRequest(String body, String additionUrl, String requestType) {
        HttpRequest req = new HttpRequest();
        req.setMethod(requestType);
        if (requestType.equals('POST')) {
            req.setHeader('Content-Length', String.valueOf(body.length()));
        }
        req.setEndpoint(settings.getPath() + additionUrl);
        addAuthorization(req, settings);
        if (body != null && body != '') {
            req.setBody(body);
        }
        System.debug('body=' + body);
        System.debug('Url=' + settings.getPath() + additionUrl);
        return req;
    }

    /**
    * Adds basic authorization to the request
    **/
    private void addAuthorization(HttpRequest req, Settings settings) {
        Blob headerValue = Blob.valueOf(settings.getUserName() + ':' + settings.getPassword());
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
    }
}