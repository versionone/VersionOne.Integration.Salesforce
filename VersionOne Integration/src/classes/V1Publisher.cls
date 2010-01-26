//TODO create parser for exceptions from the VersionOne, atm we just put xml to log

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
	private static final String MULTI_DEFECT_CHECK_URL = 'rest-1.v1/Data/Defect?sel=Reference&where=({0};Source.Name="{1}")';// {0} - Reference='%ref1%'|Reference='%ref2%'

	private static final String DEFAULT_DEFECT_NAME = 'Case from SalesForce';

	public static void setRequestor(IRequestor requestorClass) {
		requestor = requestorClass;
	}

	public static void resetAllData() {
		projects = new Map<String, String>();
		defaultProjectId = '0';
	}

	@future (callout=true)
	public static void publish() {
		resetAllData();
		ISettings settings = new Settings();
		sourceId = findSourceId(settings);
		if (requestor == null) {
			requestor = new Requestor(settings);
		}
		if (sourceId == null) {
			errorMessage('Source ' + settings.getSource() + ' not found in VersionOne. Cases can\'t be ported to VersionOne.');
			return;
		}
		String srcQueue = V1CaseCollector.getQueueIdByName('Escalate to VersionOne');
		List<Case> cases = V1CaseCollector.getCasesByOwnerId(srcQueue);

		Map<String, Boolean> alreadyPortedCases;
		try {
			alreadyPortedCases = getAlreadyExistedDefects(settings, cases);
			findAllProjects(settings);
		} catch (VersionOneException ex) {
			errorMessage(ex.getMessage() + ':' + ex.getResponceBody());
			return;
		} catch (Exception ex) {
			errorMessage('Internal problems: ' + ex);
		}
		List<Case> processedCases = new List<Case>();
		Integer i = 0;
		for (Case caseData : cases) {
			if (alreadyPortedCases.containsKey(caseData.CaseNumber)) {
				Integer id = createDefectInVersionOne(caseData, settings);
				if (id > 0) {
					processedCases.add(caseData);
				}
			} else {
				errorMessage('Case "' + caseData.Subject + '" (' + caseData.CaseNumber +') was already ported.' );
				processedCases.add(caseData);
			}
			i++;// we have restriction on 10 request by http.send
			if (i == 2) {
				break;
			}
		}
		String dstQueue = V1CaseCollector.getQueueIdByName('Assigned to VersionOne');
		V1CaseCollector.setCasesOwner(processedCases, dstQueue);
	}

	/**
	* Creates defect in the VersionOne and assign link to it
	*
	* returns 	defect id  	- all ok
	*			-1 			- defect was not created
	**/
	public static Integer createDefectInVersionOne(Case caseData, ISettings settings) {
		Integer defectId = -1;
		XMLDom xmlParser = new XMLDom();
		try {
			String createDefectBody = '<Asset>' +
								relationNode('Scope', 'Scope:' + findProjectId(caseData.Product__c)) +
								attributeNode('Name', (caseData.Subject != null ? caseData.Subject : DEFAULT_DEFECT_NAME)) +
								attributeNode('Reference', caseData.CaseNumber) +
								attributeNode('Description', (caseData.Description != null ? caseData.Description : '')) +
								relationNode('Source', 'StorySource:' + sourceId) +
									  '</Asset>';
			System.debug('XML for create defect:' + createDefectBody);

		    requestor.doPost(createDefectBody, DEFECT_URL);
		} catch (VersionOneException ex) {
			errorMessage(ex.getMessage() + ':' + ex.getResponceBody());
			return -1;
		}  catch (Exception ex) {
			errorMessage('Internal problems during creating defect: ' + ex);
			return -1;
		}

	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    } else {
	    	errorMessage('Problem with creating new defect in the VersionOne' + requestor.getBody());
	    	return -1;
	    	//throw new VersionOneException('Problem with creating new defect in the VersionOne.', requestor.getBody());
	    }

		try {
		    defectId = Integer.valueOf(xmlParser.getElementByTagName('Asset').getAttribute('id').split(':')[1]);
			createLinkV1ToSF(defectId, caseData.Id, settings);
		} catch (VersionOneException ex) {
			errorMessage(ex.getMessage() + ':' + ex.getResponceBody());
		} catch (Exception ex) {
			errorMessage('Internal problems during creating link to case: ' + ex);
		}

		return defectId;
	}

	/**
	* Gathers all project from the VersionOne, and assign default project
	*
	**/
	public static void findAllProjects(ISettings settings) {
		XMLDom xmlParser = new XMLDom();

	    //Send the request, and get a response
	    requestor.doGet('', SCOPE_URL);
	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    } else {
	    	//errorMessage('Problem with getting projects from the VersionOne' + requestor.getBody());
	    	//return;
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
	*
	**/
	public static String findProjectId(String productName) {
		if (productName != null && projects.containsKey(productName)) {
			return projects.get(productName);
		}

		return defaultProjectId;
	}

	/**
	* Creates link to the corresponding case in the SalesForce
	*
	**/
	public static void createLinkV1ToSF(Integer defectId, String caseId, ISettings settings) {
		String body = '<Asset>' +
						attributeNode('OnMenu', 'true') +
						attributeNode('URL', 'https://na7.salesforce.com/' + caseId) +
						attributeNode('Name', 'SalesForce Case') +
						relationNode('Asset', 'Defect:' + String.valueOf(defectId)) +
					   '</Asset>';
		XMLDom xmlParser = new XMLDom();

		//Send the request, and get a response
	    requestor.doPost(body, LINK_URL);
	    if (requestor.getStatusCode() != 200) {
	    	//errorMessage('Problem to create link to case' + requestor.getBody());
	    	throw new VersionOneException('Problem to create link to case', requestor.getBody());
	    }

	}

	/**
	* Were defect already created in the VersionOne
	*
	* Returns - List<Integer> Already ported cases
	**/
	public static Map<String, Boolean> getAlreadyExistedDefects(ISettings settings, List<Case> cases) {
		String sourceName = settings.getSource();
		XMLDom xmlParser = new XMLDom();
	    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');
	    String reference = '(';
	    Map<String, Boolean> defectsInfo = new Map<String, Boolean>();

	    for (Case caseData : cases) {
			reference = reference + 'Reference=\''+ caseData.CaseNumber + '\'|';
	    }
	    reference = reference.substring(0, reference.length() - 1);
	    reference = reference + ')';

	    //Send the request, and get a response
	    requestor.doGet('', String.format(MULTI_DEFECT_CHECK_URL, new String[]{reference, escapedSourceName}));
	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    } else {
	    	throw new VersionOneException('Problem with getting data from the VersionOne', requestor.getBody());
	    	//errorMessage('Problem with getting data from the VersionOne' + requestor.getBody());
	    	//return true;
	    }

	    List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
	    for (XMLDom.Element assetTag : assetTags) {
			defectsInfo.put(assetTag.getValue('Attribute'), true);
	    }

		return defectsInfo;
	}

	/**
	* Was detect already created in the VersionOne.
	*
	* Returns  	true 	- already was created
	*			false 	- was not created.
	**/
	/*
	public static Boolean isDefectAlreadyExist(ISettings settings, String caseNumber) {
		String sourceName = settings.getSource();
		XMLDom xmlParser = new XMLDom();
	    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');
		try {
		    //Send the request, and get a response
		    requestor.doGet('', String.format(CHECK_DEFECT_URL, new String[]{caseNumber, escapedSourceName}));
		    if (requestor.getStatusCode() == 200) {
				xmlParser.parseFromString(requestor.getBody());
		    } else {
		    	throw new VersionOneException('Problem with getting data from the VersionOne', requestor.getBody());
		    	//errorMessage('Problem with getting data from the VersionOne' + requestor.getBody());
		    	//return true;
		    }

		    List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
		    if (assetTags.size() > 0) {
		    	return true;
		    }

		} catch (Exception ex) {
			errorMessage('Getting defects failed: ' + ex);
		}

		return false;
	}
	*/

	/**
	* Finds source id by name from the settings.
	*
	* Returns	id 		- if source was found
	*			null	- if source was not found
	**/
	public static String findSourceId(ISettings settings) {
		String sourceName = settings.getSource();
		XMLDom xmlParser = new XMLDom();
	    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');
		try {
		    //Send the request, and get a response
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
	**/
	public static void errorMessage(String message) {
		System.debug(message);
	}
}