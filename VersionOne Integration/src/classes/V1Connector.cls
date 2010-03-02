public with sharing class V1Connector implements IV1Connector {
    public static final String CLOSED_DEFECTS_URL = 'rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="StorySource:{0}";Defect.AssetState="Closed"{1})';
    public static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name="{0}"';
    public static final String SCOPE_URL  = 'rest-1.v1/Data/Scope?sel=Name&where=(Scope.AssetState!=\'Closed\')';
    public static final String LINK_URL = 'rest-1.v1/Data/Link';
    public static final String DEFAULT_DEFECT_NAME = 'Case from SalesForce';
    public static final String DEFECT_URL = 'rest-1.v1/Data/Defect';
    public static final String MULTI_DEFECT_CHECK_URL = 'rest-1.v1/Data/Workitem?sel=Reference&where=(({0});Source.Name="{1}")';// {0} - Reference='%ref1%'|Reference='%ref2%'

    private final Settings settings;
    private final IRequestor requestor;

    private String defaultProjectId;

    public V1Connector(Settings settings, IRequestor requestor) {
        this.settings = settings;
        this.requestor = requestor;
    }

    public List<String> getClosedDefects() {
        XMLDom xmlParser = new XMLDom();
        List<String> references = new List<String>();
        String dateRestriction = '';
        if (settings.getLastDateChangeAsset() != null) {
            dateRestriction = ';ChangeDateUTC>\'' +settings.getLastDateChangeAsset().format('yyyy-MM-dd\'T\'HH:mm:ss') + '\'';
        }
        //Send the request, and get a response
        requestor.request(requestor.createRequest('', String.format(CLOSED_DEFECTS_URL, new String[]{settings.getSourceId(), dateRestriction}), 'GET'));
        if (isResponceStatusCodeCorrect()) {
            xmlParser.parseFromString(requestor.getBody());
            List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
            DateTime latestDate = settings.getLastDateChangeAsset();
            for (XMLDom.Element asset : assetTags) {
                String reference = getValue('Reference', asset.childNodes);
                String changeDateUTC = getValue('ChangeDateUTC', asset.childNodes);
                references.add(reference);
                DateTime testDate = convertToDateTime(changeDateUTC);
                if (latestDate == null || testDate > latestDate) {
                    latestDate = testDate;
                }
            }
            if (latestDate != settings.getLastDateChangeAsset()) {
                // here we set date
                // settings will be stored in the Syncronizer class, if no one case has to be updated
                settings.setLastDateChangeAsset(latestDate);
            }
        }

        return references;
    }

    public String getSourceId() {
        XMLDom xmlParser = new XMLDom();
        String escapedSourceName = EncodingUtil.urlEncode(settings.getSource(), 'UTF-8');

        //Send the request, and get a response
        requestor.request(requestor.createRequest('', String.format(SOURCE_URL, new String[]{escapedSourceName}), 'GET'));
        System.debug('Responce code = ' + requestor.getStatusCode());
        System.debug('Responce body = ' + requestor.getBody());
        if (isResponceStatusCodeCorrect()) {
            xmlParser.parseFromString(requestor.getBody());
            XMLDom.Element assetTag = xmlParser.getElementByTagName('Asset');
            System.debug('assetTag = ' + assetTag);
            if (assetTag != null) {
                return assetTag.getAttribute('id').split(':')[1];
            }
        }

        return null;
    }

    /**
    * Verifies that responce is correct and returns true if all is ok or
    * thorws VersionOneException is responce is not correct.
    **/
    public boolean isResponceStatusCodeCorrect() {
        if (requestor.getStatusCode() == 200) {
            return true;
        }else if (requestor.getStatusCode() == 401){
            throw new VersionOneException('Credentials is not correct.', '');
        }else if (requestor.getStatusCode() == 500 || requestor.getStatusCode() == 404){
            throw new VersionOneException('URL is not correct or VersionOne server has some problems at the moment.', '');
        }

        throw new VersionOneException('Problem with getting data from the VersionOne. (' + requestor.getStatusCode() + ')', requestor.getBody());
    }

    /**
    * Get value from elements with specific name attribute
    *
    * String attributeValue - value of name attribute for looking for.
    **/
    public String getValue(String attributeValue, List<XMLDom.Element> assetsData) {
        System.debug('assetsData size = ' + assetsData.size());
        for (XMLDom.Element element : assetsData) {
            String attibuteValue = element.getAttribute('name');
            System.debug('attibuteValue.equals(attributeValue)=' + attibuteValue.equals(attributeValue));
            if (attibuteValue != null && attibuteValue.equals(attributeValue)) {
                return element.nodeValue;
            }
        }

        return null;
    }


    /**
    * Converts string with yyyy-MM-ddTHH:mm:ss.MMM format to DateTime object
    * If millisecond more then 0 - convert to yyyy-MM-ddTHH:mm:ss
    * if millisecond equals 0 - convert to yyyy-MM-ddTHH:mm:ss-1
    **/
    public static DateTime convertToDateTime(String utcDate) {
        String[] dateTimeData = utcDate.split('T');
        String[] dateData = dateTimeData[0].split('-');
        String[] timeData = dateTimeData[1].split(':');
        Integer year = Integer.valueOf(dateData[0]);
        Integer month = Integer.valueOf(dateData[1]);
        Integer day = Integer.valueOf(dateData[2]);
        Integer hour = Integer.valueOf(timeData[0]);
        Integer minutes = Integer.valueOf(timeData[1]);
        Double secondAndMillisecond = Double.valueOf(timeData[2]);
        Integer second;
        if (secondAndMillisecond.intValue() == secondAndMillisecond ) {
            second = secondAndMillisecond.intValue() - 1;
        } else {
            second = secondAndMillisecond.intValue();
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
        if (requestor.getStatusCode() == 200) {
            xmlParser.parseFromString(requestor.getBody());
        } else {
            throw new VersionOneException('Problem with getting projects from the VersionOne.', requestor.getBody());
        }
        List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');

        Integer testId = 999999999;
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
     * Were defect already created in the VersionOne
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
        requestor.request(requestor.createRequest('', String.format(MULTI_DEFECT_CHECK_URL, new String[]{reference, source}), 'GET'));
        if (requestor.getStatusCode() == 200) {
            xmlParser.parseFromString(requestor.getBody());
        } else {
            throw new VersionOneException('Problem with getting data from the VersionOne', requestor.getBody());
        }

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
    public void createLinkV1ToSF(Integer defectId, String caseId) {
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
    * Creates defect in the VersionOne and assign link to it
    *
    * returns 	defect id  	- all ok
    *			-1 			- defect was not created
    **/
    public Integer createDefectInV1(Case caseData, String productId) {
        Integer defectId = -1;
        XMLDom xmlParser = new XMLDom();
        try {
            String createDefectBody = '<Asset>' +
                                relationNode('Scope', 'Scope:' + productId) +
                                attributeNode('Name', (caseData.Subject != null ? caseData.Subject : DEFAULT_DEFECT_NAME)) +
                                attributeNode('Reference', caseData.CaseNumber) +
                                attributeNode('Description', (caseData.Description != null ? caseData.Description : '')) +
                                relationNode('Source', 'StorySource:' + settings.getSourceId()) +
                                      '</Asset>';
            System.debug('XML for create defect:' + createDefectBody);

            requestor.request(requestor.createRequest(createDefectBody, DEFECT_URL, 'POST'));

            if (requestor.getStatusCode() == 200) {
                xmlParser.parseFromString(requestor.getBody());
            } else {
                V1Publisher.errorMessage('Problem with creating new defect in the VersionOne' + requestor.getBody());
                return -1;
            }

            return Integer.valueOf(xmlParser.getElementByTagName('Asset').getAttribute('id').split(':')[1]);
        } catch (VersionOneException ex) {
            V1Publisher.errorMessage(ex.getErrorMessage(), ex);
            return -1;
        }  catch (Exception ex) {
            V1Publisher.errorMessage('Internal problems during creating defect: ', ex);
            return -1;
        }
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
    * Returns current used settings
    **/
    public Settings getSettings() {
        return settings;
    }
}