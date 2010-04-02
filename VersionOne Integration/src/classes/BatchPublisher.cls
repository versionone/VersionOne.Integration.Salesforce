global class BatchPublisher implements Database.Batchable<Case>, Database.AllowsCallouts, Database.Stateful {
    global Map<String, String> projects;
    global String defaultProject;
    global final List<Case> cases;
    global IConnectionFactory factory;

    global BatchPublisher(IConnectionFactory factory) {
        this.factory = factory;
        V1Publisher publisher = getV1Publisher();
        cases = publisher.getCases();
        System.debug('BatchPublisher cases:'+cases);
    }

    private V1Publisher getV1Publisher() {
        V1Publisher.connector = factory.getConnector();
        V1Publisher.settings = factory.getSettings();
        V1Publisher.init();
        return new V1Publisher();
    }

    global Iterable<Case> start(Database.BatchableContext bc){
        if (cases.size() == 0) {
            return cases;
        }

        V1Publisher publisher = getV1Publisher();
        List<Case> casesForProcess = new List<Case>();
        Map<String, Boolean> publishedCases = publisher.getPublishedCases();
        //it's like fake case to get project list from the VersionOne
        casesForProcess.add(cases.get(0));
        for (Case caseData : cases) {
            if (publishedCases.containsKey(caseData.CaseNumber)) {
                //errorMessage('Case "' + caseData.Subject + '" (' + caseData.CaseNumber +') was already ported.' );
                continue;
            }
            caseData.VersionOneUrl__c = '';
            //add every case twice because:
            //  at first we will create workitems in the VersionOne
            //  at second we will create link to SalesForce's case in the VersionOne
            casesForProcess.add(caseData);
            casesForProcess.add(caseData);
            update caseData;
        }
        System.debug('start casesForProcess:'+casesForProcess);
        return casesForProcess;
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){
        IV1Connector connector = factory.getConnector();
        Settings settings = factory.getSettings();
        if (projects == null) {
            System.debug('Init projects.');
            projects = connector.findAllProjects();
            defaultProject = connector.getDefaultProjectId();
            //this is only for testing. because we have restriction to run only one execure in test method.
            if (scope.size() == 1) {
                return;
            } else {
                scope.remove(0);
            }
        }

        for(Case caseData : scope){
            Case newCase = V1CaseCollector.getCaseByCaseNumber(caseData.CaseNumber);
            System.debug('execute newCase.VersionOneUrl__c: ' + newCase.VersionOneUrl__c);
            if (isCasesPorted(newCase)) {// port case to VersionOne
                String projectId = findProjectId(caseData.VersionOneProject__c);
                String workitemId = connector.createWorkitemInV1(caseData, projectId);
                String url = (workitemId == null) ? null : settings.getPath() + V1Publisher.URL_TO_V1_TEMPLATE + EncodingUtil.urlEncode(workitemId, 'UTF-8');
                V1CaseCollector.updateUrlToVersionOneInCase(caseData, url);
            } else { //assign link to SalesForce's case in the VersionOne
                String url = newCase.VersionOneUrl__c;
                String id = url.substring(url.indexOf('=') + 1).replace('%3a', ':').replace('%3A', ':');
                connector.createLinkV1ToSF(id, caseData);
                V1CaseCollector.updateCase(caseData, settings.getDestQueueId(), settings.getCommentBody(), newCase.VersionOneUrl__c);
            }
        }
    }

    private Boolean isCasesPorted(Case caseData) {
        return caseData.VersionOneUrl__c == null || caseData.VersionOneUrl__c == '';
    }

    global void finish(Database.BatchableContext bc){
    }

    /** Returns project id by project name. **/
    private String findProjectId(String projectName) {
        if (projects.containsKey(projectName)) {
            return projects.get(projectName);
        }
        return defaultProject;
    }

    public static Map<String, String> getBatchData(String id) {
        AsyncApexJob aaj;
        try {
            aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                FROM AsyncApexJob WHERE ID =: id ];
        } catch(QueryException ex) {
            // incorrect id
            return null;
        }
        Integer total = calculateValue(aaj.TotalJobItems);
        Integer processed = calculateValue(aaj.JobItemsProcessed);
        Integer errors = calculateValue(aaj.NumberOfErrors);
        Map<String, String> bantchData = new Map<String, String>();
        bantchData.put('Status', aaj.Status);
        bantchData.put('JobItemsProcessed', String.valueof(processed));
        bantchData.put('TotalJobItems', String.valueof(total));
        bantchData.put('NumberOfErrors', String.valueof(errors));
        return bantchData;
    }

    public static Integer calculateValue(Integer value) {
        if (value == 0) {
            return 0;
        }
        Decimal decValue = value;
        decValue = decValue.divide(2, 0, System.RoundingMode.DOWN);
        return decValue.intValue();

    }

    public static Boolean isRan(String id) {
        if (id == null) {
            return false;
        }
        Map<String, String> batchData = getBatchData(id);
        if (batchData == null) {
            return false;
        }
        return batchData.get('Status') == 'Queued' || batchData.get('Status') == 'Processing';
    }

}