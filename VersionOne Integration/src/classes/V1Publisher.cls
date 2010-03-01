//TODO
// create parser for exceptions from the VersionOne, atm we just put xml to log

public with sharing class V1Publisher {

    private static final String URL_TO_V1_TEMPLATE = 'assetdetail.v1?oid=Defect%3a';

    public static IV1Connector connector {set;get;}
    public static Settings settings {set;get;}

    /** Lazy initialized map of projects (Name->ID) */
    private Map<String, String> projects;

    @future (callout=true)
    public static void publish() {
        if (check()) {
            V1Publisher pub = new V1Publisher();
            pub.publishDefects();
            pub.publishStories();
        }
    }

    public void publishDefects() {
        try {
            List<Case> cases = V1CaseCollector.getCasesByOwnerId(settings.getDefectQueueId());
            if (cases.size() > 0) {
                Map<String, Boolean> alreadyPortedCases = connector.getAlreadyExistedDefects(cases);
                processCases(alreadyPortedCases, cases);
            }
        } catch (VersionOneException ex) {
            errorMessage(ex.getErrorMessage(), ex);
            return;
        } catch (Exception ex) {
            errorMessage('Internal problems during getting existed defects from the VersionOne: ', ex);
            return;
        }
    }

    public void publishStories() {
        try {
            List<Case> cases = V1CaseCollector.getCasesByOwnerId(settings.getStoryQueueId());
            if (cases.size() > 0) {
                //Map<String, Boolean> alreadyPortedCases = connector.getAlreadyExistedDefects(cases);
                //processCases(alreadyPortedCases, cases, sourceId);
            }
        } catch (VersionOneException ex) {
            errorMessage(ex.getErrorMessage(), ex);
            return;
        } catch (Exception ex) {
            errorMessage('Internal problems during getting existed defects from the VersionOne: ', ex);
            return;
        }
    }

    public static Boolean check() {
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

    /** Processes cases assigned to settings.getSourceQueueId() queue and update that cases. **/
    public void processCases(Map<String, Boolean> alreadyPortedCases, List<Case> cases) {
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
                    String projectId = findProjectId(caseData.VersionOneProject__c);
                    Integer id = connector.createDefectInV1(caseData, projectId);
                    if (id > 0) {
                        connector.createLinkV1ToSF(id, caseData.Id);
                        processedCases.add(caseData);
                        urls.add(settings.getPath() + URL_TO_V1_TEMPLATE + id);
                    }
                }
            }
        }

        V1CaseCollector.updateCases(processedCases, settings.getDestQueueId(), settings.getCommentBody(), urls);
    }

    /** Returns project id by project name. **/
    public String findProjectId(String projectName) {
        if (getProjects().containsKey(projectName)) {
            return getProjects().get(projectName);
        }
        return connector.getDefaultProjectId();
    }

    /** Handles error message. **/
    public static void errorMessage(String message) {
        System.debug(message);
    }

    /** Handles error message with exception. **/
    public static void errorMessage(String message, Exception ex) {
        if (ex instanceof VersionOneException ) {
            System.debug(message + ':' + ((VersionOneException)ex).getResponceBody());
        } else {
            System.debug('Internal error:' + ex.getMessage());
        }
    }
}