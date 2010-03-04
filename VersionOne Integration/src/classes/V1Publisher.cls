//TODO
// create parser for exceptions from the VersionOne, atm we just put xml to log

public with sharing class V1Publisher {

    private static final String URL_TO_V1_TEMPLATE = 'assetdetail.v1?oid=Defect%3a';

    public static IV1Connector connector {set;get;}
    public static Settings settings {set;get;}

    /** Lazy initialized map of projects (Name->ID). */
    private Map<String, String> projects;
    /** Lazy initialized list of casses need to be published. */
    private List<Case> cases;
    /** Lazy initialized map of casses which was already published (CaseID->?). */
    private Map<String, Boolean> publishedCases;

    @future (callout=true)
    public static void publish() {
        if (init()) {
            try {
                V1Publisher pub = new V1Publisher();
                pub.processCases();
            } catch (Exception ex) {
                errorMessage('Problems during getting existed defects from the VersionOne.', ex);
                return;
            }
        }
    }

    /** Initialize settings and connector, check whether settings are correct. */
    public static Boolean init() {
        if (settings == null) {
            settings = new Settings();
        }
        if (connector == null) {
            connector = new V1Connector(settings, new Requestor(settings));
        }
        if (!settings.isValid()) {
            errorMessage('Incorrect settings.');
            return false;
        }
        if (settings.getSourceId() == null) {
            errorMessage('Source ' + settings.getSource() + ' not found in VersionOne. Cases can\'t be ported to VersionOne.');
            return false;
        }
        return true;
    }

    public Map<String, String> getProjects() {
        if (projects == null) {
            projects = connector.findAllProjects();
        }
        return projects;
    }

    public Case[] getCases() {
        if (cases == null) {
            List<Case> res = V1CaseCollector.getCasesByOwnerId(settings.getDefectQueueId());
            res.addAll(V1CaseCollector.getCasesByOwnerId(settings.getStoryQueueId()));
            cases = res;
        }
        return cases;
    }

    public Map<String, Boolean> getPublishedCases() {
        if (publishedCases == null) {
            if (getCases().size() == 0) {
                publishedCases = new Map<String, Boolean>();
            } else {
                publishedCases = connector.getReferencedWorkitems(cases);
            }
        }
        return publishedCases;
    }

    /** Processes cases assigned to settings.getSourceQueueId() queue and update that cases. **/
    public void processCases() {
        Integer maxPublishCases = 3; // we have restriction on 10 request by http.send
        for (Case caseData : getCases()) {
            if (maxPublishCases-- > 0) {
               processCase(caseData);
            }
        }
    }

    public void processCase(Case caseData) {
        if (getPublishedCases().containsKey(caseData.CaseNumber)) {
            errorMessage('Case "' + caseData.Subject + '" (' + caseData.CaseNumber +') was already ported.' );
            V1CaseCollector.updateCase(caseData, settings.getDestQueueId(), settings.getCommentBody(), null);
        } else {
            String projectId = findProjectId(caseData.VersionOneProject__c);
            Integer id = connector.createWorkitemInV1(caseData, projectId);
            connector.createLinkV1ToSF(id, caseData.Id);
            V1CaseCollector.updateCase(caseData, settings.getDestQueueId(), settings.getCommentBody(), settings.getPath() + URL_TO_V1_TEMPLATE + id);
        }
    }

    /** Returns project id by project name. **/
    public String findProjectId(String projectName) {
        if (getProjects().containsKey(projectName)) {
            return getProjects().get(projectName);
        }
        return connector.getDefaultProjectId();
    }

    /** Logs error message. **/
    public static void errorMessage(String message) {
        System.debug(message);
    }

    /** Logs error message with exception. **/
    public static void errorMessage(String message, Exception ex) {
        System.debug(message + '/n' + ex);
    }
}