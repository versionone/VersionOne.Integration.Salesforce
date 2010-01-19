public with sharing class V1Publisher {
	private List<Case> cases;
	private Settings settings;

	private static final String DEFECT_URL = 'rest-1.v1/Data/Defect';
	private static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?where=Name="%1"';
	private static final String SCOPE_URL  = 'rest-1.v1/Data/Scope?sel=&where=(Scope.AssetState!="Closed";Scope.Name="%1")';

	public V1Publisher(List<Case> cases) {
		this.cases = cases;
		this.settings = new Settings();
	}


	public void publish(List<Case> cases) {
		for (Case caseData : cases) {
			System.debug('Case name:' + caseData.Subject);
			System.debug('Case product name:' + caseData.Product__c);
		}
	}

	@future (callout=true)
	public static void test() {
/*
		String testBody = '<Asset href="/VersionOneNew/rest-1.v1/Data/Defect/2720/9416" id="Defect:2720:9416">'+
			'<Attribute name="Name">Defect #1 created from SalesForce</Attribute>'+
			'<Attribute name="Description">the description</Attribute>'+
			'<Attribute name="FoundBy">Yogi Bear</Attribute>'+
			'<Relation name="Scope">'+
				'<Asset href="/VersionOneNew/rest-1.v1/Data/Scope/0" idref="Scope:0" />'+
			'</Relation>'+
		'</Asset>';
		*/

		String firstBody = '<Asset>' +
							'<Relation act="set" name="Scope">' +
								'<Asset idref="Scope:0"/>' +
							'</Relation>' +
							'<Attribute act="set" name="Name">Defect new #321 created from SalesForce </Attribute>' +
							'<Attribute act="set" name="Reference">IDOPJbvjdofjs9</Attribute>' +
							'<Attribute act="set" name="Description">Description lala</Attribute>' +
							'<Relation act="set" name="Source">' +
								'<Asset href="rest-1.v1/Data/StorySource/' + getSourceId('asd') + '" idref="StorySource:' + getSourceId('asd') + '" />' +
							'</Relation>' +
						  '</Asset>';

		XMLDom xmlParser = new XMLDom();
		try {
		    Http h=new Http();

		    //Send the request, andreturn a response
		    HttpResponse res = h.send(createRequest(firstBody, new Settings(), DEFECT_URL, 'POST'));
		    //System.debug('responce code' + res.getStatusCode());
		    //System.debug('responce body' + res.getBody());
		    if (res.getStatusCode() == 200) {
				xmlParser.parseFromString(res.getBody());
		    } else {
		    	System.debug('Problem with creating new defect in the VersionOne' + res.getBody());
		    	return;
		    }

			/* respond
			<?xml version="1.0" encoding="UTF-8"?>
			<Asset href="/VersionOne/rest-1.v1/Data/Defect/5133/13154" id="Defect:5133:13154">
			<Attribute name="Name">Defect #1 Created in Unit Test</Attribute>
			<Relation name="Scope">
				<Asset href="/VersionOne/rest-1.v1/Data/Scope/5132" idref="Scope:5132" /></Relation></Asset>
				*/

		    String id = xmlParser.getElementByTagName('Asset').getAttribute('id').split(':')[1];
		    System.debug('respond = ' + xmlParser.toXmlString());
		    System.debug('found id=' + id);


			/* request
			<Asset id="Defect:5133">
				<Attribute act="set" name="Estimate">4.0</Attribute>
				<Attribute act="set" name="Description">the description</Attribute>
				<Attribute act="set" name="FoundBy">Yogi Bear</Attribute>
			</Asset>

			*/
		    //res = h.send(createRequest(testBody, new Settings(), DEFECT_URL + '/' + id));

		    //return res.getStatusCode();
		} catch (Exception e) {
			System.debug('publishCase(): Http.send() failed: ' + e);
			//return -1;
		}
	}

	/**
	* Creates defect in the VersionOne and returns id of created defect
	*
	**/
	private String createDefectInVersionOne(Case caseData, Settings settings) {
		String sourceId = getSourceId(settings.getSource());
		String firstBody = '<Asset>' +
							'<Relation act="set" name="Scope">' +
								'<Asset idref="' + findProjectId(caseData.Product__c) + '"/>' +
							'</Relation>' +
							'<Attribute act="set" name="Name">' + caseData.Subject +'</Attribute>' +
							'<Attribute act="set" name="Reference">' + caseData.CaseNumber +'</Attribute>' +
							'<Attribute act="set" name="Description">' + caseData.Description +'</Attribute>' +
							'<Relation act="set" name="Source">' +
								'<Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceId + '" idref="StorySource:' + sourceId + '" />' +
							'</Relation>' +
						  '</Asset>';

		return '0';
	}

	private String findProjectId(String productName) {
		try {
			XMLDom xmlParser = new XMLDom();
		    Http h = new Http();
		    Settings settings = new Settings();

		    //Send the request, andreturn a response
		    HttpResponse res = h.send(createRequest('', settings, SCOPE_URL.replace('%1', productName), 'GET'));
		    if (res.getStatusCode() == 200) {
				xmlParser.parseFromString(res.getBody());
		    } else {
		    	System.debug('Problem with creating new defect in the VersionOne' + res.getBody());
		    	return null;
		    }
		} catch (Exception e) {
			System.debug('Find Project Id failed: ' + e);
			//return -1;
		}


		return 'scope:0';
	}

	private static String getSourceId(String sourceName) {
		return '1010';
	}


	public static HttpRequest createRequest(String body, Settings settings, String additionUrl, String requestType) {
	    //Instantiate a new HTTP request,specify the method (GET) as well as the endpoint
		HttpRequest req = new HttpRequest();
		req.setMethod(requestType);
		req.setEndpoint(settings.getPath() + additionUrl);
		addAuthorization(req, settings);
		req.setBody(body);
		System.debug('body=' + body);
		System.debug('Url=' + settings.getPath() + additionUrl);
		//req.setHeader('Content-Type', 'text/xml');
		return req;
	}

	private static void addAuthorization(HttpRequest req, Settings settings) {
		Blob headerValue = Blob.valueOf(settings.getUserName() + ':' + settings.getPassword());
		String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
	}


}