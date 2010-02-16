public with sharing class V1Connector implements IV1Connector {
    private static final String CLOSED_DEFECTS_URL = 'rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="{0}";Defect.AssetState="Closed"{1})';
    private static final String SOURCE_URL = 'rest-1.v1/Data/StorySource?sel=&where=Name="{0}"';

    private final Settings settings;
    private final IRequestor requestor;

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
                settings.setLastDateChangeAsset(latestDate);
                settings.updateSettings();
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
}