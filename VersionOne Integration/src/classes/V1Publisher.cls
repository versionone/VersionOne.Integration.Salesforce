public with sharing class V1Publisher {

	private static Map<String, String> projects = new Map<String, String>();
	private static String defaultProjectId = '0';
	private static IRequestor requestor;
	private static String sourceId;

	private static final String DEFECT_URL = 'rest-1.v1/Data/Defect';
	private static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name="{0}"';
	private static final String SCOPE_URL  = 'rest-1.v1/Data/Scope?sel=Name&where=(Scope.AssetState!=\'Closed\')';
	private static final String LINK_URL = 'rest-1.v1/Data/Link';
	private static final String CHECK_DEFECT_URL = 'rest-1.v1/Data/Defect?sel=Reference,Source.Name&where=(Reference="{0}";Source.Name="{1}")';

	private static final String DEFAULT_DEFECT_NAME = 'Case from SalesForce';


	public static void setRequestor(IRequestor requestorClass) {
		requestor = requestorClass;
	}

	@future (callout=true)
	public static void publish() {
		Settings settings = new Settings();
		if (requestor == null) {
			requestor = new Requestor(settings);
		}
		sourceId = findSourceId(settings);
		if (sourceId == null) {
			errorMessage('Source ' + settings.getSource() + ' not found in VersionOne. Cases can\'t be ported to VersionOne.');
			return;
		}
		String srcQueue = V1CaseCollector.getQueueIdByName('Escalate to VersionOne');
		List<Case> cases = V1CaseCollector.getCasesByOwnerId(srcQueue);
		findAllProjects(settings);
		for (Case caseData : cases) {
			if (!isDefectAlreadyExist(settings, caseData.CaseNumber)) {
				Integer id = createDefectInVersionOne(caseData, settings);
				if (id > 0) {
					//defect was created
				}
			} else {
				errorMessage('Case "' + caseData.Subject + '" (' + caseData.CaseNumber +') was already ported.' );
			}
		}
		String dstQueue = V1CaseCollector.getQueueIdByName('Assigned to VersionOne');
		V1CaseCollector.setCasesOwner(cases, dstQueue);
	}

	/**
	* Creates defect in the VersionOne and assign link to it
	*
	* returns 	defect id  	- all ok
	*			-1 			- defect was not created
	**/
	public static Integer createDefectInVersionOne(Case caseData, Settings settings) {
		String createDefectBody = '<Asset>' +
							relationNode('Scope', 'Scope:' + findProjectId(caseData.Product__c)) +
							//'<Attribute act="set" name="Name">' + (caseData.Subject != null ? caseData.Subject : DEFAULT_DEFECT_NAME) +'</Attribute>' +
							attributeNode('Name', (caseData.Subject != null ? caseData.Subject : DEFAULT_DEFECT_NAME)) +
							//'<Attribute act="set" name="Reference">' + caseData.CaseNumber +'</Attribute>' +
							attributeNode('Reference', caseData.CaseNumber) +
							//'<Attribute act="set" name="Description">' + (caseData.Description != null ? caseData.Description : '') +'</Attribute>' +
							attributeNode('Description', (caseData.Description != null ? caseData.Description : '')) +
							relationNode('Source', 'StorySource:' + sourceId) +
							//'<Relation act="set" name="Source">' +
							//	'<Asset href="/VersionOne/rest-1.v1/Data/StorySource/' + sourceId + '" idref="StorySource:' + sourceId + '" />' +
							//'</Relation>' +
						'</Asset>';
		System.debug('XML for create defect:' + createDefectBody);

		XMLDom xmlParser = new XMLDom();
		//Http h=new Http();
		Integer defectId = -1;
		try {
		    //HttpResponse res = h.send(createRequest(createDefectBody, settings, DEFECT_URL, 'POST'));
		    requestor.doPost(createDefectBody, DEFECT_URL);

		    if (requestor.getStatusCode() == 200) {
				xmlParser.parseFromString(requestor.getBody());
		    } else {
		    	errorMessage('Problem with creating new defect in the VersionOne' + requestor.getBody());
		    }

		    defectId = Integer.valueOf(xmlParser.getElementByTagName('Asset').getAttribute('id').split(':')[1]);
		    //System.debug('respond = ' + xmlParser.toXmlString());
		    //System.debug('found id=' + id);
			createLinkV1ToSF(defectId, caseData.Id, settings);

		} catch (Exception e) {
			errorMessage('publishCase(): Http.send() failed: ' + e);
		}

		return defectId;
	}

	/**
	* Gathers all project from the VersionOne, and assign default project
	*
	**/
	private static void findAllProjects(Settings settings) {
		XMLDom xmlParser = new XMLDom();
	    //Http h = new Http();

		try {
		    //Send the request, and get a response
		    //HttpResponse res = h.send(createRequest('', settings, SCOPE_URL, 'GET'));
		    requestor.doGet('', SCOPE_URL);
		    if (requestor.getStatusCode() == 200) {
				xmlParser.parseFromString(requestor.getBody());
		    } else {
		    	errorMessage('Problem with getting projects from the VersionOne' + requestor.getBody());
		    	return;
		    }

			List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
			if (assetTags.size() > 0) {
				defaultProjectId = assetTags.get(0).getElementByTagName('Asset').getAttribute('id').split(':')[1];
			}
			for (XMLDom.Element assetTag : assetTags) {
				projects.put(assetTag.getValue('Attribute'), assetTag.getAttribute('id').split(':')[1]);
			}

		    System.debug('findProjectId respond = ' + xmlParser.toXmlString());

		} catch (Exception e) {
			errorMessage('Finding Projects failed: ' + e);
		}
	}

	/**
	* Returns project id by product name
	*
	**/
	private static String findProjectId(String productName) {
		if (productName != null && projects.containsKey(productName)) {
			return projects.get(productName);
		}

		return defaultProjectId;
	}

	/**
	* Creates link to the corresponding case in the SalesForce
	*
	**/
	private static void createLinkV1ToSF(Integer defectId, String caseId, Settings settings) {
		String body = '<Asset>' +
						//'<Attribute act="set" name="OnMenu">true</Attribute>' +
						attributeNode('OnMenu', 'true') +
						//'<Attribute act="set" name="URL">https://na7.salesforce.com/' + caseId + '</Attribute>' +
						attributeNode('URL', 'https://na7.salesforce.com/' + caseId) +
						//'<Attribute act="set" name="Name">SalesForce Case</Attribute>' +
						attributeNode('Name', 'SalesForce Case') +
						relationNode('Asset', 'Defect:' + String.valueOf(defectId)) +
						//'<Relation act="set" name="Asset">' +
						//	'<Asset idref="Defect:' + defectId + '"/>' +
					    //'</Relation>' +
					   '</Asset>';
		XMLDom xmlParser = new XMLDom();
	    //Http h = new Http();

		try {
		    //Send the request, and get a response
		    //HttpResponse res = h.send(createRequest(body, settings, LINK_URL, 'POST'));
		    requestor.doPost(body, LINK_URL);
		    if (requestor.getStatusCode() != 200) {
		    	errorMessage('Problem to create link to case' + requestor.getBody());
		    }

		} catch (Exception e) {
			errorMessage('Creating link to case failed: ' + e);
		}

	}

	/**
	* Detects was current case already created in the VersionOne.
	*
	* Returns  	true 	- already was created
	*			false 	- was not created.
	**/
	private static Boolean isDefectAlreadyExist(Settings settings, String caseNumber) {
		String sourceName = settings.getSource();
		XMLDom xmlParser = new XMLDom();
	    //Http h = new Http();
	    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');
		try {
		    //Send the request, and get a response
		    //HttpResponse res = h.send(createRequest('', settings, String.format(CHECK_DEFECT_URL, new String[]{caseNumber, escapedSourceName}), 'GET'));
		    requestor.doGet('', String.format(CHECK_DEFECT_URL, new String[]{caseNumber, escapedSourceName}));
		    if (requestor.getStatusCode() == 200) {
				xmlParser.parseFromString(requestor.getBody());
		    } else {
		    	errorMessage('Problem with getting data from the VersionOne' + requestor.getBody());
		    	return true;
		    }

		    List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
		    if (assetTags.size() > 0) {
		    	return true;
		    }

		} catch (Exception e) {
			errorMessage('Getting defects failed: ' + e);
		}

		return false;
	}

	/**
	* Finds source id by name from the settings.
	*
	* Returns	id 		- if source was found
	*			null	- if source was not found
	**/
	private static String findSourceId(Settings settings) {
		String sourceName = settings.getSource();
		XMLDom xmlParser = new XMLDom();
	    //Http h = new Http();
	    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');
		try {
		    //Send the request, and get a response
		    //HttpResponse res = h.send(createRequest('', settings, String.format(SOURCE_URL, new String[]{escapedSourceName}), 'GET'));
		    requestor.doGet('', String.format(SOURCE_URL, new String[]{escapedSourceName}));
		    if (requestor.getStatusCode() == 200) {
				xmlParser.parseFromString(requestor.getBody());
		    } else {
		    	errorMessage('Problem with getting source from the VersionOne' + requestor.getBody());
		    	return null;
		    }

		    XMLDom.Element assetTag = xmlParser.getElementByTagName('Asset');
		    System.debug('findSourceId respond = ' + xmlParser.toXmlString());
		    if (assetTag != null) {
		    	return assetTag.getAttribute('id').split(':')[1];
		    }
		} catch (Exception e) {
			errorMessage('Getting source Id  failed: ' + e);
		}

		return null;
	}

	/**
	* Creates Relation node for request
	*
	**/
	public static String relationNode(String name, String value) {
		return '<Relation act="set" name="' + name + '">' +
				'<Asset idref="' + value + '"/>' +
			   '</Relation>';
	}

	/**
	* Creates Attribute node for request
	*
	**/
	public static String attributeNode(String name, String value) {
		return '<Attribute act="set" name="' + name + '">' + value + '</Attribute>';
	}


	/**
	* Outputs error message
	*
	*
	**/
	public static void errorMessage(String message) {
		System.debug(message);
	}
}