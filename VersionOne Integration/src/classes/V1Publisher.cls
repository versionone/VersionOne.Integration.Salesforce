//TODO
// create parser for exceptions from the VersionOne, atm we just put xml to log

public with sharing class V1Publisher {
    private static IV1Connector connector;
    private static Settings settings;

    private static final String URL_TO_V1_TEMPLATE = 'assetdetail.v1?oid=Defect%3a';

    public static void setConnector(IV1Connector connectorData) {
        connector = connectorData;
    }

    public static void setSettings(Settings settingsData) {
        settings = settingsData;
    }

	//TODO remove this method and all usages
    public static void resetAllData() {
        //defaultProjectId = '0';
    }

    @future (callout=true)
    public static void publish() {
        resetAllData();
        if (settings == null) {
            settings = new Settings();
        }
        if (connector == null) {
            setConnector(new V1Connector(settings, new Requestor(settings)));
        }
        if (!settings.isCorrect()) {
            errorMessage('Incorrect settings.');
            return;
        }
        String sourceId = Settings.getSourceId();//findSourceId();
        if (sourceId == null) {
            errorMessage('Source ' + settings.getSource() + ' not found in VersionOne. Cases can\'t be ported to VersionOne.');
            return;
        }
        List<Case> cases = V1CaseCollector.getCasesByOwnerId(settings.getSourceQueueId());

        Map<String, Boolean> alreadyPortedCases;
        Map<String, String> projects;
        try {
            alreadyPortedCases = connector.getAlreadyExistedDefects(cases);
            projects = connector.findAllProjects();
        } catch (VersionOneException ex) {
            errorMessage(ex.getErrorMessage(), ex);
            return;
        } catch (Exception ex) {
            errorMessage('Internal problems during getting existed defects from the VersionOne: ', ex);
            return;
        }
        processCases(alreadyPortedCases, cases, sourceId, projects);
    }


    /**
    * Processes cases assigned to settings.getSourceQueueId() queue and update that cases
    *
    *
    **/
    public static void processCases(Map<String, Boolean> alreadyPortedCases, List<Case> cases, String sourceId, Map<String, String> projects) {
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
                    String projectId = findProjectId((String) caseData.get(settings.getV1Project()), projects);
                    Integer id = connector.createDefectInVersionOne(caseData, projectId, sourceId);
                    if (id > 0) {
                        processedCases.add(caseData);
                        urls.add(settings.getPath() + URL_TO_V1_TEMPLATE + id);
                    }
                }
            }
        }

        V1CaseCollector.updateCases(processedCases, settings.getDestQueueId(), settings.getCommentBody(), settings.getV1Url(), urls);
    }

    /**
    * Returns project id by product name
    **/
    public static String findProjectId(String productName, Map<String, String> projects) {
        if (productName != null && projects.containsKey(productName)) {
            return projects.get(productName);
        }

        return connector.getDefaultProjectId();
    }


    /**
    * Handle error message
    **/
    public static void errorMessage(String message) {
        System.debug(message);
    }

    /**
    * Handle error message with exception
    **/
    public static void errorMessage(String message, Exception ex) {
        if (ex instanceof VersionOneException ) {
            System.debug(message + ':' + ((VersionOneException)ex).getResponceBody());
        } else {
            System.debug('Internal error:' + ex.getMessage());
        }
    }
}