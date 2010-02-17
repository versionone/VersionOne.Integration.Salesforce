public class Syncronizer {
    //StorySource%3a1009
    private static final String CLOSED_DEFECTS_URL = 'rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="{0}";Defect.AssetState="Closed"{1})';
    private final Settings settings;
    private final IV1Connector connector;

    public Syncronizer(Settings settings, IV1Connector connector) {
        this.settings = settings;
        this.connector = connector;
    }

    public void syncCases() {
        System.debug('==> TODO sync job there!');
        //TODO sync job there
    }

    public List<String> getClosedDefects() {
        List<Case> portedCases = V1CaseCollector.getCasesByOwnerId(settings.getDestQueueId(), false);
        if (portedCases.size() == 0) {
            System.debug('There are no cases for close');
            return null;
        }

        return connector.getClosedDefects();
    }
}