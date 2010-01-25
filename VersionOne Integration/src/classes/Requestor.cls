public class Requestor implements IRequestor {
	private final ISettings settings;
	private HttpResponse responce;

	public Requestor(ISettings settings) {
		this.settings = settings;
	}

	/**
	* Makes GET request
	**/
	public void doGet(String body, String url) {
		responce = request(body, url, 'GET');
	}

	/**
	* Makes POST request
	**/
	public void doPost(String body, String url) {
		responce = request(body, url, 'POST');
	}

	public String getBody() {
		return responce.getBody();
	}

	public Integer getStatusCode() {
		return responce.getStatusCode();
	}

	/**
	* Makes request
	**/
	private HttpResponse request(String body, String url, String requestType) {
		Http h = new Http();
		HttpResponse res = h.send(createRequest(body, url, requestType));
		return res;
	}


	/**
	* Creates request
	*
	**/
	private HttpRequest createRequest(String body, String additionUrl, String requestType) {
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
		//req.setHeader('Content-Type', 'text/xml');
		return req;
	}

	/**
	* Adds basic authorization to the request
	*
	**/
	private void addAuthorization(HttpRequest req, ISettings settings) {
		Blob headerValue = Blob.valueOf(settings.getUserName() + ':' + settings.getPassword());
		String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
	}
}