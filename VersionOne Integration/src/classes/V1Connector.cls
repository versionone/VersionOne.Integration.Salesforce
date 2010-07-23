public class V1Connector implements IV1Connector {

    public static final String DATA_URL = 'rest-1.v1/Data/';
    public static final String CLOSED_DEFECTS_URL = 'rest-1.v1/Data/Defect?sel=AssetState,Name,Number,ChangeDateUTC,Reference&where=(Source=\'\'StorySource:{0}\'\';AssetState=\'\'Closed\'\'{1})';
    public static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name=\'\'{0}\'\'';
    public static final String SCOPE_URL  = 'rest-1.v1/Data/Scope?sel=Name&where=(Scope.AssetState!=\'Closed\')';
    public static final String WORKITEM_REFERENCE_SEARCH_URL = 'rest-1.v1/Data/PrimaryWorkitem?sel=Reference&where=(({0});Source.Name=\'\'{1}\'\')';// {0} - Reference='%ref1%'|Reference='%ref2%'
    public static final String DEFECT_REQUEST_URL = 'rest-1.v1/Data/Defect/{0}?sel=Name,Description,Status.Name,Number,Scope.Name,ResolutionReason.Name,Priority.Name,AssetState';
    public static final String LINK_BY_DEFECT_ID_URL = 'rest-1.v1/Data/Link?sel=Name&where=(Asset=\'\'Defect:{0}\'\')';//'Defect:2345'
    public static final String DELETE_LINK_URL = 'rest-1.v1/Data/Link/{0}?op=Delete';
    public static final String UPDATE_REFERENCE_URL = 'rest-1.v1/Data/Defect/{0}';
    public static final String SEARCH_DEFECT_URL = 'rest-1.v1/Data/Defect?sel=Status.Name,AssetState,Number,Name,ResolutionReason.Name,Priority.Name,Scope.Name{0}&sort=-CreateDateUTC{1}';
    public static final String SEARCH_WORD_TEMPLATE = '&find={0}';
    public static final String FIELDS_LIST_FOR_SEARCH_TEMPLATE = '&findin={0}';
    public static final String SEARCH_PART_FOR_CLOSED_DEFECT_URL = '&where=(Defect.AssetState!=\'Closed\')';

    public static final String DEFAULT_DEFECT_NAME = 'Case from SalesForce';
    public static final String LINK_NAME_TO_CASE = 'SalesForce Case';

    private final Settings settings;
    private final transient IRequestor requestor;

    private String defaultProjectId;

    public V1Connector(Settings settings, IRequestor requestor) {
        this.settings = settings;
        this.requestor = requestor;
    }

    public void removeLinkFromDefect(String defectId) {
        String url = String.format(LINK_BY_DEFECT_ID_URL, new String[]{defectId});
        requestor.request(requestor.createRequest('', url, 'GET'));
        validateResponse();
        XMLDom xmlParser = new XMLDom();
        xmlParser.parseFromString(requestor.getBody());
        XMLDom.Element[] assets = xmlParser.getElementsByTagName('Asset');
        if (assets == null || assets.size() == 0) {
            throw new V1RequestException('There is no link for this defect.');
        }
        for (XMLDom.Element asset : assets) {
            String name = getValue('Name', asset.childNodes);
            String linkId = asset.getAttribute('id').split(':')[1];
            if (linkId != '' && name == LINK_NAME_TO_CASE) {
                url = String.format(DELETE_LINK_URL, new String[]{linkId});
                requestor.request(requestor.createRequest('', url, 'POST'));
                validateResponse();
            }
        }
    }

    public void updateReferenceForDefect(String defectId, String referenceValue) {
        Defect defectData = getDefectById(defectId);
        if (defectData.isClosed) {
            return;
        }
        String url = String.format(UPDATE_REFERENCE_URL, new String[]{defectId});

        String body = '<Asset id="Defect:' + defectId + '">' +
                        attributeNode('Reference', referenceValue) +
                      '</Asset>';
        requestor.request(requestor.createRequest(body, url, 'POST'));
        validateResponse();
    }

    public Defect getDefectById(String defectId) {
        String url = String.format(DEFECT_REQUEST_URL, new String[]{defectId});
        requestor.request(requestor.createRequest('', url, 'GET'));
        validateResponse();
        XMLDom xmlParser = new XMLDom();
        xmlParser.parseFromString(requestor.getBody());
        XMLDom.Element asset = xmlParser.getElementByTagName('Asset');
		Defect defectData = getDefect(asset);

        return defectData;
    }

    public List<Defect> searchDefects(String query, Boolean isLookingInClosed, String[] fieldsForSearch) {
    	List<Defect> defects = new List<Defect>();

    	String closedItemsFilter = isLookingInClosed ? '' : SEARCH_PART_FOR_CLOSED_DEFECT_URL;
    	String lookupQuery = '';
    	List<String> queryParts = query.trim().split(' ');
    	for(String queryPart : queryParts) {
    		lookupQuery += String.format(SEARCH_WORD_TEMPLATE, new String[] { queryPart });
    	}

    	lookupQuery += getFieldsForSearch(fieldsForSearch);

    	String url = String.format(SEARCH_DEFECT_URL, new String[] { closedItemsFilter, lookupQuery });

        requestor.request(requestor.createRequest('', url, 'GET'));
        validateResponse();
        XMLDom xmlParser = new XMLDom();
        xmlParser.parseFromString(requestor.getBody());
        List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
        for (XMLDom.Element assetTag : assetTags) {
        	defects.add(getDefect(assetTag));
        }
        return defects;
    }

    private String getFieldsForSearch(String[] fieldsForSearch) {
    	String fieldsForUrl = '';
    	if (fieldsForSearch != null && !fieldsForSearch.isEmpty()) {
    		String fields = '';
    		for(Integer i=0; i<fieldsForSearch.size(); i++) {
    			if (i > 0) {
    				fields += ',';
    			}
    			fields += fieldsForSearch[i];
    		}
			fieldsForUrl = String.format(FIELDS_LIST_FOR_SEARCH_TEMPLATE, new String[] { fields });
    	}
    	return fieldsForUrl;
    }

    private Defect getDefect(XMLDom.Element asset) {
    	Defect defectData = new Defect(getValue('Name', asset.childNodes), getValue('Description', asset.childNodes));
        defectData.resolution = getValue('ResolutionReason.Name', asset.childNodes);
        defectData.project = getValue('Scope.Name', asset.childNodes);
        defectData.assetNumber = getValue('Number', asset.childNodes);
        defectData.id = asset.getAttribute('id').split(':')[1];
        defectData.token = asset.getAttribute('id');
        defectData.isClosed = getValue('AssetState', asset.childNodes) == Defect.ClosedAssetState;
        defectData.priority = getValue('Priority.Name', asset.childNodes);
        defectData.status = getValue('Status.Name', asset.childNodes);
        DateTime changeDate = convertToDateTime(getValue('ChangeDateUTC', asset.childNodes));
        if (changeDate != null) {
			defectData.changeDate = convertToDateTime(getValue('ChangeDateUTC', asset.childNodes)).format('yyyy-MM-dd hh:mm:ss');
        }
        String reference = getValue('Reference', asset.childNodes);
        if (reference != null) {
        	defectData.casesId = reference.split(';');
        }

    	return defectData;
    }

    public String getSourceId() {
        String source = settings.getSource();
        if (source == null) {
            return null;
        }
        XMLDom xmlParser = new XMLDom();
        String escapedSourceName = EncodingUtil.urlEncode(source, 'UTF-8');

        //Send the request, and get a response
        HttpRequest req = requestor.createRequest('', String.format(SOURCE_URL, new String[]{escapedSourceName}), 'GET');
        requestor.request(req);
        validateResponse();
        xmlParser.parseFromString(requestor.getBody());
        XMLDom.Element assetTag = xmlParser.getElementByTagName('Asset');
        if (assetTag != null) {
            return assetTag.getAttribute('id').split(':')[1];
        }
        return null;
    }

    /**
     * Verifies that responce is correct.
     *
     * thorws: V1RequestException if responce is not correct.
     */
    public void validateResponse() {
        Integer status = requestor.getStatusCode();
        if (status == 200) {
            return;
        } else if (status == 401){
            throw new V1RequestException('Credentials are not correct.');
        } else if (status == 500 || status == 404){
            throw new V1RequestException('Error during request to the VersionOne. Possible reason: URL is not correct, VersionOne server has some problems at the moment or requested item does not exist.');
        }
        throw new V1RequestException('Problem with getting data from the VersionOne.', requestor);
    }

    /**
    * Get value from elements with specific name attribute
    *
    * String attributeValue - value of name attribute for looking for.
    **/
    public String getValue(String attributeValue, List<XMLDom.Element> assetsData) {
        for (XMLDom.Element element : assetsData) {
            String attibuteValue = element.getAttribute('name');
            if (attibuteValue != null && attibuteValue.equals(attributeValue)) {
                return element.nodeValue;
            }
        }

        return null;
    }


    /**
    * Converts string with yyyy-MM-ddTHH:mm:ss.MMM or yyyy-MM-dd HH:mm:ss.MMM format to DateTime object
    * If millisecond more then 0 - convert to yyyy-MM-ddTHH:mm:ss
    * if millisecond equals 0 - convert to yyyy-MM-ddTHH:mm:ss-1
    **/
    public static DateTime convertToDateTime(String utcDate) {
    	if (utcDate == null) {
    		return null;
    	}
        String[] dateTimeData = utcDate.split('T');
        if (dateTimeData.size() == 1 ) {
        	dateTimeData  = utcDate.split(' ');
        }
        String[] dateData = dateTimeData[0].split('-');
        String[] timeData = dateTimeData[1].split(':');
        Integer year = Integer.valueOf(dateData[0]);
        Integer month = Integer.valueOf(dateData[1]);
        Integer day = Integer.valueOf(dateData[2]);
        Integer hour = Integer.valueOf(timeData[0]);
        Integer minutes = Integer.valueOf(timeData[1]);
        Decimal secondAndMillisecond = Decimal.valueOf(timeData[2]);
        Integer second;
        if (secondAndMillisecond.intValue() == secondAndMillisecond ) {
            second = secondAndMillisecond.intValue();
        } else {
        	second = Math.round(secondAndMillisecond);
        }
        return DateTime.newInstance(year, month, day, hour, minutes, second);
    }


    /**
    * Gathers all project from the VersionOne, and assign default project
    **/
    public Map<String, String> findAllProjects() {
        XMLDom xmlParser = new XMLDom();
        Map<String, String> projects = new Map<String, String>();

        //Send the request, and get a response
        requestor.request(requestor.createRequest('', SCOPE_URL, 'GET'));
        if (requestor.getStatusCode() != 200) {
            throw new V1RequestException('Problem with getting projects from the VersionOne.', requestor);
        }
        xmlParser.parseFromString(requestor.getBody());
        List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');

        Integer testId = 999999999;
        for (XMLDom.Element assetTag : assetTags) {
            String id = assetTag.getAttribute('id').split(':')[1];
            if (testId > Integer.valueOf(id)) {
                testId = Integer.valueOf(id);
            }
            String projectName = assetTag.getValue('Attribute');
            if (!projects.containsKey(id)) {
                projects.put('Scope:' + id, projectName);
            }
        }
        defaultProjectId = String.valueof(testId);

        return projects;
    }

    /**
    * Returns default project. It we will use if user doesn't assign case to project
    **/
    public String getDefaultProjectId() {
        if (defaultProjectId == null) {
            findAllProjects();
        }
        return defaultProjectId;
    }

    /**
     * Were defects already created in the VersionOne
     *
     * Returns - List<Integer> Already ported cases
     */
    public Map<String, Boolean> getReferencedWorkitems(List<Case> cases) {
        XMLDom xmlParser = new XMLDom();

        String reference = '';
        for (Case caseData : cases) {
            reference += 'Reference=\''+ caseData.CaseNumber + '\'|';
        }
        reference = reference.substring(0, reference.length() - 1);

        //Send the request, and get a response
        String source = EncodingUtil.urlEncode(settings.getSource(), 'UTF-8');
        requestor.request(requestor.createRequest('',
            String.format(WORKITEM_REFERENCE_SEARCH_URL, new String[]{reference, source}), 'GET'));
        if (requestor.getStatusCode() != 200) {
            throw new V1RequestException('Problem with getting data from the VersionOne', requestor);
        }
        xmlParser.parseFromString(requestor.getBody());

        List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
        Map<String, Boolean> defectsInfo = new Map<String, Boolean>();
        for (XMLDom.Element assetTag : assetTags) {
            defectsInfo.put(assetTag.getValue('Attribute'), true);
        }
        return defectsInfo;
    }


    /////////////////// Create in the VersionOne

    /**
    * Creates link to the corresponding case in the SalesForce
    **/
    public void createLinkV1ToSF(String workitemId, Case caseData) {
    	//throw new V1RequestException('Problem to create link to case');
        if (workitemId == null) {
            return;
        }
        String body = '<Asset>' +
                        attributeNode('OnMenu', 'true') +
                        attributeNode('URL', 'https://na7.salesforce.com/' + caseData.Id) +
                        attributeNode('Name', LINK_NAME_TO_CASE) +
                        relationNode('Asset', workitemId) +
                       '</Asset>';

        //Send the request, and get a response
        requestor.request(requestor.createRequest(body, DATA_URL + 'Link', 'POST'));
        if (requestor.getStatusCode() != 200) {
            throw new V1RequestException('Problem to create link to case', requestor);
        }
    }

    /**
     * Creates defect or story in the VersionOne and assign link to it.
     *
     * returns: 	id of the created workitem
     * throws:  V1RequestException, Exception
     */
    public String createWorkitemInV1(Case caseData, Defect defectData, String projectId) {
        String body = '<Asset>'
            + relationNode('Scope', 'Scope:' + projectId)
            + attributeNode('Name', (defectData.title != null ? defectData.title : DEFAULT_DEFECT_NAME))
            + attributeNode('Reference', caseData.CaseNumber)
            + attributeNode('Description', (defectData.Description != null ? defectData.Description : ''))
            + relationNode('Source', 'StorySource:' + settings.getSourceId())
            + '</Asset>';
        String workitemType = 'Defect';
        System.debug('XML for creating ' + workitemType + ': ' + body);
        requestor.request(requestor.createRequest(body, DATA_URL + workitemType, 'POST'));

        if (requestor.getStatusCode() != 200) {
            throw new V1RequestException('Problem with creating new defect in the VersionOne', requestor);
        }
        XMLDom xmlParser = new XMLDom();
        xmlParser.parseFromString(requestor.getBody());
        String[] id = xmlParser.getElementByTagName('Asset').getAttribute('id').split(':');
        return id[0]+':'+id[1];
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
            value = value.replace('&', '&amp;');
            value = value.replace('<', '&lt;').replace('>', '&gt;');
        }
        return '<Attribute act="set" name="' + name + '">' + value + '</Attribute>';
    }

    /**
    * Returns current used settings
    **/
    public Settings getSettings() {
        return settings;
    }

    public List<Defect> getClosedDefects(DateTime dateData) {

        List<Defect> closedDefects = new List<Defect>();
        String dateRestriction = '';
        if (dateData != null) {
            dateRestriction = ';ChangeDateUTC>\'' + dateData.format('yyyy-MM-dd\'T\'HH:mm:ss') + '\'';
        }
        //Send the request, and get a response
        String url = String.format(CLOSED_DEFECTS_URL, new String[]{settings.getSourceId(), dateRestriction});
        requestor.request(requestor.createRequest('', url, 'GET'));
        validateResponse();
        XMLDom xmlParser = new XMLDom();
        xmlParser.parseFromString(requestor.getBody());
        XMLDom.Element[] assetTags = xmlParser.getElementsByTagName('Asset');
        for (XMLDom.Element asset : assetTags) {
        	Defect closedDefectData = getDefect(asset);

            closedDefects.add(closedDefectData);
        }
        return closedDefects;
    }
}