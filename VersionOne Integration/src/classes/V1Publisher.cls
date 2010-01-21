public with sharing class V1Publisher {
	private List<Case> cases;
	private Settings settings;

	private static final String DEFECT_URL = 'rest-1.v1/Data/Defect';
	private static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name="%1"';
	private static final String SCOPE_URL  = 'rest-1.v1/Data/Scope?sel=&where=(Scope.AssetState!=\'Closed\';Scope.Name=\'%1\')';
	private static final String LINK_URL = 'rest-1.v1/Data/Link';

	@future (callout=true)
	public static void publish() {
		Settings settings = new Settings();
		List<Case> cases = V1CaseCollector.getCasesForV1();
		for (Case caseData : cases) {
			createDefectInVersionOne(caseData, settings);
		}
		Group dstQueue = V1CaseCollector.getQueueByName('Assigned to VersionOne');
		V1CaseCollector.setCasesOwner(cases, dstQueue);
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
		Settings settings = new Settings();
		String source = getSourceId(settings.getSource(), settings);
		if (source == null) {
			System.debug('Source \'SalesForce\' not found in VersionOne. Cases can\'t be ported to VersionOne.');
			return;
		}

		String firstBody = '<Asset>' +
							'<Relation act="set" name="Scope">' +
								'<Asset idref="Scope:' + findProjectId('SalesForce test', settings) + '"/>' +
							'</Relation>' +
							'<Attribute act="set" name="Name">Defect new #'+ system.now()+' created from SalesForce </Attribute>' +
							'<Attribute act="set" name="Reference">IDOPJbvjdofjs9</Attribute>' +
							'<Attribute act="set" name="Description">Description lala</Attribute>' +
							'<Relation act="set" name="Source">' +
								'<Asset href="rest-1.v1/Data/StorySource/' + source + '" idref="StorySource:' + source + '" />' +
							'</Relation>' +
						  '</Asset>';

		XMLDom xmlParser = new XMLDom();
		try {
		    Http h=new Http();

		    //Send the request, andreturn a response
		    HttpResponse res = h.send(createRequest(firstBody, settings, DEFECT_URL, 'POST'));
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
			createLinkV1ToSF(id, '12345', settings);

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
	* Creates defect in the VersionOne and assign link to it
	*
	**/
	private static void createDefectInVersionOne(Case caseData, Settings settings) {
		String sourceId = getSourceId(settings.getSource(), settings);

		if (sourceId == null) {
			System.debug('Source ' + settings.getSource() + ' not found in VersionOne. Cases can\'t be ported to VersionOne.');
			//return null;
			return;
		}
		String createDefectBody = '<Asset>' +
							'<Relation act="set" name="Scope">' +
								'<Asset idref="Scope:' + findProjectId(caseData.Product__c, settings) + '"/>' +
							'</Relation>' +
							'<Attribute act="set" name="Name">' + caseData.Subject +'</Attribute>' +
							'<Attribute act="set" name="Reference">' + caseData.CaseNumber +'</Attribute>' +
							'<Attribute act="set" name="Description">' + (caseData.Description != null ? caseData.Description : '') +'</Attribute>' +
							'<Relation act="set" name="Source">' +
								'<Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceId + '" idref="StorySource:' + sourceId + '" />' +
							'</Relation>' +
						'</Asset>';
		System.debug('XML for create defect:' + createDefectBody);

		XMLDom xmlParser = new XMLDom();
		try {
		    Http h=new Http();
		    HttpResponse res = h.send(createRequest(createDefectBody, settings, DEFECT_URL, 'POST'));

		    if (res.getStatusCode() == 200) {
				xmlParser.parseFromString(res.getBody());
		    } else {
		    	System.debug('Problem with creating new defect in the VersionOne' + res.getBody());
		    	//return '0';
		    }

		    String id = xmlParser.getElementByTagName('Asset').getAttribute('id').split(':')[1];
		    //System.debug('respond = ' + xmlParser.toXmlString());
		    //System.debug('found id=' + id);
			createLinkV1ToSF(id, caseData.Id, settings);

		} catch (Exception e) {
			System.debug('publishCase(): Http.send() failed: ' + e);
			//return -1;
		}

		//return '0';
	}

	private static String findProjectId(String productName, Settings settings) {
		if (productName == null) {
			return '0';
		}
		try {
			XMLDom xmlParser = new XMLDom();
		    Http h = new Http();
		    String escapedProductName = EncodingUtil.urlEncode(productName, 'UTF-8');

		    //Send the request, andreturn a response
		    HttpResponse res = h.send(createRequest('', settings, SCOPE_URL.replace('%1', escapedProductName), 'GET'));
		    if (res.getStatusCode() == 200) {
				xmlParser.parseFromString(res.getBody());
		    } else {
		    	System.debug('Problem with getting project from the VersionOne' + res.getBody());
		    	return '0';
		    }

		    //Element assetTag = xmlParser.getElementByTagName('Asset');
		    System.debug('findProjectId respond = ' + xmlParser.toXmlString());
		    if (xmlParser.getElementByTagName('Asset') != null) {
		    	return xmlParser.getElementByTagName('Asset').getAttribute('id').split(':')[1];
		    }
		} catch (Exception e) {
			System.debug('Finding Project Id  failed: ' + e);
			//return -1;
		}

		return '0';
	}


	private static void createLinkV1ToSF(String defectId, String caseId, Settings settings) {
//		<Asset>
//			<Attribute act="set" name="OnMenu">false</Attribute>
//			<Attribute act="set" name="URL">http://www.google.com?q=Y</Attribute>
//			<Attribute act="set" name="Name">Link Y</Attribute>
//			<Relation act="set" name="Asset">
//				<Asset idref="Scope:0"/>
//			</Relation>
//		</Asset>
		String body = '<Asset>' +
						'<Attribute act="set" name="OnMenu">true</Attribute>' +
						'<Attribute act="set" name="URL">https://na1.salesforce.com/' + caseId + '</Attribute>' +
						'<Attribute act="set" name="Name">SalesForce Case</Attribute>' +
						'<Relation act="set" name="Asset">' +
							'<Asset idref="Defect:' + defectId + '"/>' +
					   '</Relation></Asset>';


		try {
			XMLDom xmlParser = new XMLDom();
		    Http h = new Http();

		    //Send the request, andreturn a response
		    HttpResponse res = h.send(createRequest(body, settings, LINK_URL, 'POST'));
		    if (res.getStatusCode() != 200) {
		    	System.debug('Problem to create link to case' + res.getBody());
		    }

		} catch (Exception e) {
			System.debug('Creating link to case failed: ' + e);
			//return -1;
		}

	}



	private static String getSourceId(String sourceName, Settings settings) {
		try {
			XMLDom xmlParser = new XMLDom();
		    Http h = new Http();
		    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');

		    //Send the request, andreturn a response
		    HttpResponse res = h.send(createRequest('', settings, SOURCE_URL.replace('%1', escapedSourceName), 'GET'));
		    if (res.getStatusCode() == 200) {
				xmlParser.parseFromString(res.getBody());
		    } else {
		    	System.debug('Problem with getting source from the VersionOne' + res.getBody());
		    	return null;
		    }

		    XMLDom.Element assetTag = xmlParser.getElementByTagName('Asset');
		    System.debug('getSourceId respond = ' + xmlParser.toXmlString());
		    if (assetTag != null) {
		    	return assetTag.getAttribute('id').split(':')[1];
		    }
		} catch (Exception e) {
			System.debug('Getting source Id  failed: ' + e);
			//return -1;
		}

		return null;

		//return '1010';
	}


	public static HttpRequest createRequest(String body, Settings settings, String additionUrl, String requestType) {
	    //Instantiate a new HTTP request,specify the method (GET) as well as the endpoint
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

	private static void addAuthorization(HttpRequest req, Settings settings) {
		Blob headerValue = Blob.valueOf(settings.getUserName() + ':' + settings.getPassword());
		String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
	}


}