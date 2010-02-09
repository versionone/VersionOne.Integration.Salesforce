//TODO
// create parser for exceptions from the VersionOne, atm we just put xml to log

public with sharing class V1Publisher {

	private static Map<String, String> projects = new Map<String, String>();
	private static String defaultProjectId = '0';
	private static IRequestor requestor;
	private static Settings settings;

	private static final String DEFECT_URL = 'rest-1.v1/Data/Defect';
	private static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name="{0}"';
	private static final String SCOPE_URL  = 'rest-1.v1/Data/Scope?sel=Name&where=(Scope.AssetState!=\'Closed\')';
	private static final String LINK_URL = 'rest-1.v1/Data/Link';
	private static final String CHECK_DEFECT_URL = 'rest-1.v1/Data/Defect?sel=Reference,Source.Name&where=(Reference="{0}";Source.Name="{1}")';
	private static final String MULTI_DEFECT_CHECK_URL = 'rest-1.v1/Data/Defect?sel=Reference&where=({0}Source.Name="{1}")';// {0} - Reference='%ref1%'|Reference='%ref2%'

	private static final String DEFAULT_DEFECT_NAME = 'Case from SalesForce';
	private static final String URL_TO_V1_TEMPLATE = 'assetdetail.v1?oid=Defect%3a';

	public static void setRequestor(IRequestor requestorData) {
		requestor = requestorData;
	}

	public static void setSettings(Settings settingsData) {
		settings = settingsData;
	}

	public static void resetAllData() {
		projects = new Map<String, String>();
		defaultProjectId = '0';
	}

	@future (callout=true)
	public static void publish() {
		resetAllData();
		if (settings == null) {
			settings = new Settings();
		}
		if (requestor == null) {
			setRequestor(new Requestor(settings));
		}
		if (settings.getSource() == null || settings.getDestQueueId() == null ||
			settings.getSourceQueueId() == null || settings.getPath() == null ||
			settings.getUserName() == null || settings.getPath() == null) {
			errorMessage('Incorrect settings.');
			return;
		}
		String sourceId = findSourceId();
		if (sourceId == null) {
			errorMessage('Source ' + settings.getSource() + ' not found in VersionOne. Cases can\'t be ported to VersionOne.');
			return;
		}
		List<Case> cases = V1CaseCollector.getCasesByOwnerId(settings.getSourceQueueId());

		Map<String, Boolean> alreadyPortedCases;
		try {
			alreadyPortedCases = getAlreadyExistedDefects(cases);
			findAllProjects();
		} catch (VersionOneException ex) {
			errorMessage(ex.getErrorMessage(), ex);
			return;
		} catch (Exception ex) {
			errorMessage('Internal problems during getting existed defects from the VersionOne: ', ex);
			return;
		}
		processCases(alreadyPortedCases, cases, sourceId);
	}


	/**
	* Processes cases assigned to settings.getSourceQueueId() queue and update that cases
	*
	*
	**/
	public static void processCases(Map<String, Boolean> alreadyPortedCases, List<Case> cases, String sourceId) {
		List<Case> processedCases = new List<Case>();
		List<String> urls = new List<String>();
		Integer maxPublishCases = 3; // we have restriction on 10 request by http.send
		for (Case caseData : cases) {
			if (alreadyPortedCases.containsKey(caseData.CaseNumber)) {
				errorMessage('Case "' + caseData.Subject + '" (' + caseData.CaseNumber +') was already ported.' );
				processedCases.add(caseData);
				urls.add(null);
			} else {
				if (maxPublishCases > 0) {
					maxPublishCases--;
					String projectId = findProjectId(caseData.Product__c);
					Integer id = createDefectInVersionOne(caseData, projectId, sourceId);
					if (id > 0) {
						processedCases.add(caseData);
						urls.add(settings.getPath()+ URL_TO_V1_TEMPLATE + id);
					}
				}
			}
		}

		V1CaseCollector.updateCases(processedCases, settings.getDestQueueId(), settings.getCommentBody(), settings.getV1Url(), urls);
	}


	/**
	* Creates defect in the VersionOne and assign link to it
	*
	* returns 	defect id  	- all ok
	*			-1 			- defect was not created
	**/
	public static Integer createDefectInVersionOne(Case caseData, String productId, String sourceId) {
		Integer defectId = -1;
		XMLDom xmlParser = new XMLDom();
		try {
			String createDefectBody = '<Asset>' +
								relationNode('Scope', 'Scope:' + productId) +
								attributeNode('Name', (caseData.Subject != null ? caseData.Subject : DEFAULT_DEFECT_NAME)) +
								attributeNode('Reference', caseData.CaseNumber) +
								attributeNode('Description', (caseData.Description != null ? caseData.Description : '')) +
								relationNode('Source', 'StorySource:' + sourceId) +
									  '</Asset>';
			System.debug('XML for create defect:' + createDefectBody);

		    requestor.request(requestor.createRequest(createDefectBody, DEFECT_URL, 'POST'));
		} catch (VersionOneException ex) {
			errorMessage(ex.getErrorMessage(), ex);
			return -1;
		}  catch (Exception ex) {
			errorMessage('Internal problems during creating defect: ', ex);
			return -1;
		}

	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    } else {
	    	errorMessage('Problem with creating new defect in the VersionOne' + requestor.getBody());
	    	return -1;
	    }

		try {
		    defectId = Integer.valueOf(xmlParser.getElementByTagName('Asset').getAttribute('id').split(':')[1]);
			createLinkV1ToSF(defectId, caseData.Id);
		} catch (VersionOneException ex) {
			errorMessage(ex.getErrorMessage(), ex);
		} catch (Exception ex) {
			errorMessage('Internal problems during creating link to case: ' + ex);
		}

		return defectId;
	}

	/**
	* Gathers all project from the VersionOne, and assign default project
	**/
	public static void findAllProjects() {
		XMLDom xmlParser = new XMLDom();

	    //Send the request, and get a response
	    requestor.request(requestor.createRequest('', SCOPE_URL, 'GET'));
	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    } else {
	    	throw new VersionOneException('Problem with getting projects from the VersionOne.', requestor.getBody());
	    }
		List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');

		Integer testId = 99999999;
		for (XMLDom.Element assetTag : assetTags) {
			String id = assetTag.getAttribute('id').split(':')[1];
			if (testId > Integer.valueOf(id)) {
				testId = Integer.valueOf(id);
			}
			String projectName = assetTag.getValue('Attribute');
			if (!projects.containsKey(projectName)) {
				projects.put(projectName, id);
			}
		}
		defaultProjectId = String.valueof(testId);

	    System.debug('findProjectId respond = ' + xmlParser.toXmlString());
	    System.debug('findProjectId size = ' + assetTags.size());
	}

	/**
	* Returns project id by product name
	**/
	public static String findProjectId(String productName) {
		if (productName != null && projects.containsKey(productName)) {
			return projects.get(productName);
		}

		return defaultProjectId;
	}

	/**
	* Creates link to the corresponding case in the SalesForce
	**/
	public static void createLinkV1ToSF(Integer defectId, String caseId) {
		String body = '<Asset>' +
						attributeNode('OnMenu', 'true') +
						attributeNode('URL', 'https://na7.salesforce.com/' + caseId) +
						attributeNode('Name', 'SalesForce Case') +
						relationNode('Asset', 'Defect:' + String.valueOf(defectId)) +
					   '</Asset>';
		XMLDom xmlParser = new XMLDom();

		//Send the request, and get a response
	    requestor.request(requestor.createRequest(body, LINK_URL, 'POST'));
	    if (requestor.getStatusCode() != 200) {
	    	throw new VersionOneException('Problem to create link to case', requestor.getBody());
	    }

	}

	/**
	* Were defect already created in the VersionOne
	*
	* Returns - List<Integer> Already ported cases
	**/
	public static Map<String, Boolean> getAlreadyExistedDefects(List<Case> cases) {
		String sourceName = settings.getSource();
		XMLDom xmlParser = new XMLDom();
	    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');
	    Map<String, Boolean> defectsInfo = new Map<String, Boolean>();

	    String reference = '';
	    if (cases.size() > 0) {
		    reference = '(';
		    for (Case caseData : cases) {
				reference = reference + 'Reference=\''+ caseData.CaseNumber + '\'|';
		    }
		    reference = reference.substring(0, reference.length() - 1);
		    reference = reference + ');';
	    }

	    //Send the request, and get a response
	    requestor.request(requestor.createRequest('', String.format(MULTI_DEFECT_CHECK_URL, new String[]{reference, escapedSourceName}), 'GET'));
	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    } else {
	    	throw new VersionOneException('Problem with getting data from the VersionOne', requestor.getBody());
	    }

	    List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
	    for (XMLDom.Element assetTag : assetTags) {
			defectsInfo.put(assetTag.getValue('Attribute'), true);
	    }

		return defectsInfo;
	}

	/**
	* Finds source id by name from the settings.
	*
	* Returns	id 		- if source was found
	*			null	- if source was not found
	**/
	public static String findSourceId() {
		XMLDom xmlParser = new XMLDom();
	    String escapedSourceName = EncodingUtil.urlEncode(settings.getSource(), 'UTF-8');
		try {
		    //Send the request, and get a response
		    requestor.request(requestor.createRequest('', String.format(SOURCE_URL, new String[]{escapedSourceName}), 'GET'));
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
		} catch (Exception ex) {
			errorMessage('Getting source Id  failed: ' + ex);
		}
		return null;
	}

	public static Map<String, String> getProjects() {
		return projects;
	}

	public static String getDefaultProjectId() {
		return defaultProjectId;
	}

	/**
	* Creates Relation node for request
	**/
	public static String relationNode(String name, String value) {
		return '<Relation act="set" name="' + name + '">' +
				'<Asset idref="' + value + '"/>' +
			   '</Relation>';
	}

	/**
	* Creates Attribute node for request
	**/
	public static String attributeNode(String name, String value) {
		if (value != null) {
			value = value.replace('<', '&lt;').replace('>', '&gt;');
		}
		return '<Attribute act="set" name="' + name + '">' + value + '</Attribute>';
	}

	/**
	* Handle error message
	**/
	public static void errorMessage(String message) {
		System.debug(message);
	}

	/**
	* Handle error message with exception
	**/
	public static void errorMessage(String message, Exception ex) {
		if (ex instanceof VersionOneException ) {
			System.debug(message + ':' + ((VersionOneException)ex).getResponceBody());
		} else {
			System.debug('Internal error:' + ex.getMessage());
		}
	}
}