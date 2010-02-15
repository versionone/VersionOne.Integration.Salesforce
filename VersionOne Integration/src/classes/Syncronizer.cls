public class Syncronizer {
    //StorySource%3a1009
    private static final String CLOSED_DEFECTS_URL = 'rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="{0}";Defect.AssetState="Closed"{1})';
    private final Settings settings;
    private final IRequestor requestor;

    public Syncronizer(Settings settings, Irequestor requestor) {
        this.settings = settings;
        this.requestor = requestor;
    }

    public void syncCases() {
        //TODO sync job there
    }

    public List<String> getClosedDefects() {
        List<Case> portedCases = V1CaseCollector.getCasesByOwnerId(settings.getDestQueueId(), false);
        if (portedCases.size() == 0) {
            System.debug('There are no cases for close');
            return null;
        }

        //String sourceName = settings.getSource();
        XMLDom xmlParser = new XMLDom();
        //String escapedSourceId = EncodingUtil.urlEncode('Source:' + settings.getSourceId(), 'UTF-8');// TODO change to source id
        String dateRestriction = '';
        if (settings.getLastDateChangeAsset() != null) {
            dateRestriction = ';ChangeDateUTC>\'' +settings.getLastDateChangeAsset().format('yyyy-MM-dd\'T\'HH:mm:ss') + '\'';
        }
        //Send the request, and get a response
        requestor.request(requestor.createRequest('', String.format(CLOSED_DEFECTS_URL, new String[]{settings.getSourceId(), dateRestriction}), 'GET'));
        if (requestor.getStatusCode() == 200) {
            xmlParser.parseFromString(requestor.getBody());
        } else {
            throw new VersionOneException('Problem with getting data from the VersionOne', requestor.getBody());
        }
        List<XMLDom.Element> assetTags = xmlParser.getElementsByTagName('Asset');
        List<String> references = new List<String>();
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

        return references;
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
    * If millisecont more then 0 - convert to yyyy-MM-ddTHH:mm:ss
    * if millisecont equals 0 - convert to yyyy-MM-ddTHH:mm:ss-1
    *
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