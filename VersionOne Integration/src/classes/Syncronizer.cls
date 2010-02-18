public class Syncronizer {
    //StorySource%3a1009
    private static final String CLOSED_DEFECTS_URL = 'rest-1.v1/Data/Defect?sel=Defect.Number,Defect.ChangeDateUTC,Defect.Reference&where=(Defect.Source="{0}";Defect.AssetState="Closed"{1})';
    private final Settings settings;
    private final IV1Connector connector;

    public Syncronizer(Settings settings) {
        this.settings = settings;
        connector = new V1Connector(settings, new Requestor(settings));
    }

    public Syncronizer(Settings settings, IV1Connector connector) {
        this.settings = settings;
        this.connector = connector;
    }

    /**
     * Update cases.
     *
     * Returns: count of updated Cases.
     * Throws: Exception on errors.
     */
    public Integer syncCases() {
        List<String> closedCases = getClosedDefects();
        Case[] cases = V1CaseCollector.getCasesByCaseNumbersAndOwnerId(closedCases, settings.getDestQueueId());
        if (cases != null && cases.size() == 0) {
            // store date of last closed defect in the VersionOne (date was set in the getCasesByCaseNumbers method)
            // because of MIXED_DML_OPERATION we can save it only if no one case is updated
            connector.getSettings().updateSettings();
        } else if (cases != null) {
            V1CaseCollector.closeCases(cases, settings.getCommentOnClosing());
        }

        return cases.size();
    }

    /**
    * g
    *
    **/
    public List<String> getClosedDefects() {
        List<Case> portedCases = V1CaseCollector.getCasesByOwnerId(settings.getDestQueueId(), false);
        if (portedCases.size() == 0) {
            System.debug('There are no cases for close');
            return null;
        }

        return connector.getClosedDefects();
    }
}