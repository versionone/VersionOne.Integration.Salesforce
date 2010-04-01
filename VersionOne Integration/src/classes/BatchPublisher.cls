global class BatchPublisher implements Database.Batchable<Case>, Database.AllowsCallouts, Database.Stateful {

    private String query = 'Select id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c from Case where CaseNumber=\'00004155\'';

    global Map<String, String> projects;
    global String defaultProject;
    global final List<Case> cases;
    global final IV1Connector connector;

    global BatchPublisher() {
        V1Publisher.init();
        V1Publisher publisher = new V1Publisher();
        cases = publisher.getCases();
    }

    global Iterable<Case> start(Database.BatchableContext bc){
        System.debug('start connector: ' + connector);
        if (cases.size() == 0) {
            return cases;
        }
        V1Publisher.init();
        V1Publisher publisher = new V1Publisher();
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

        return casesForProcess;
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){
        Settings settings = new Settings();
        V1Connector connector = new V1Connector(settings, new Requestor(settings));
        if (projects == null) {
            System.debug('Init projects.');
            System.debug('execute connector: ' + connector);
            projects = connector.findAllProjects();
            defaultProject = connector.getDefaultProjectId();
            return;
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
                //VersionOne/assetdetail.v1?oid=Defect%3a1273
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

    public static Boolean isRunned(String id) {
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