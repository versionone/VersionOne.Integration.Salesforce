public class Syncronizer {
	//StorySource%3a1009
	private static final String CLOSED_DEFECTS_URL = 'rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source=\'{0}\';Defect.AssetState=\'Closed\')';
	private final Settings settings;
	private final IRequestor requestor;

	public Syncronizer(Settings settings, Irequestor requestor) {
		this.settings = settings;
		this.requestor = requestor;
	}

    public void syncCases() {
        //TODO sync job there
    }

    public void getClosedDefects() {
    	List<Case> closedCases = V1CaseCollector.getCasesByOwnerId(settings.getSourceQueueId(), true);
    	if (closedCases.size() == 0) {
    		System.debug('There are no cases for close');
    		return;
    	}

		String sourceName = settings.getSource();
		XMLDom xmlParser = new XMLDom();
	    String escapedSourceName = EncodingUtil.urlEncode(sourceName, 'UTF-8');// TODO change to source id

	    //Send the request, and get a response
	    requestor.request(requestor.createRequest('', String.format(CLOSED_DEFECTS_URL, new String[]{escapedSourceName}), 'GET'));
	    if (requestor.getStatusCode() == 200) {
			xmlParser.parseFromString(requestor.getBody());
	    } else {
	    	throw new VersionOneException('Problem with getting data from the VersionOne', requestor.getBody());
	    }
	}
}