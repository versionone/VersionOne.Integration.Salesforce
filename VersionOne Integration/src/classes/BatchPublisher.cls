global class BatchPublisher implements Database.Batchable<Case>, Database.AllowsCallouts, Database.Stateful {
    global Map<String, String> projects;
    global String defaultProject;
    global final List<Case> cases;
    global IConnectionFactory factory;
    global Boolean isCreatingFailed = false;
    global List<Case> updatedCases = new List<Case>();

    global BatchPublisher(IConnectionFactory factory) {
        this.factory = factory;
        V1Publisher publisher = getV1Publisher();
        cases = publisher.getCasesToPublish();
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
            caseData.V1Processing__c = true;
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
        if (isCreatingFailed) {
            isCreatingFailed = false;
            return;
        }

        IV1Connector connector = factory.getConnector();
        Settings settings = factory.getSettings();
        if (updateProjects(connector, scope)) {
            return;
        }
		System.debug('execute going to process:' + scope);
        for(Case caseData : scope){
            Case newCase = V1CaseCollector.getCaseByCaseNumber(caseData.CaseNumber);
            System.debug('execute newCase.VersionOneUrl__c: ' + newCase.VersionOneUrl__c + ' name:' + newCase.Subject);
            if (isCasePorted(newCase)) {
                portCaseToVersionOne(newCase, settings, connector);
            } else {
                createLinkInVersionOneAndCompletePorting(newCase, settings, connector);
                updatedCases.add(newCase);
            }
        }
    }

    /**
     * Gets project list from VersionOne.
     *
     * Returns 	true  - if needed projects was inialized
     *			false - if it is test or project was already initialized early
     **/
    private Boolean updateProjects(IV1Connector connector, List<Case> scope) {
        if (projects == null) {
            System.debug('Init projects.');
            projects = connector.findAllProjects();
            defaultProject = connector.getDefaultProjectId();
            //this is only for testing. because we have restriction to run only one execure in test method.
            // and we process all cases in one execute run
            if (scope.size() == 1) {
                return true;
            }
            scope.remove(0);
            /*
            if (scope.size() > 1) {
                scope.remove(0);
            } else {
                return true;
            }
            */
        }
        return false;
    }

    private void portCaseToVersionOne(Case caseData, Settings settings, IV1Connector connector) {
        String projectId;
        String workitemId;
        try {
            projectId = findProjectId(caseData.VersionOneProject__c);
            workitemId = connector.createWorkitemInV1(caseData, projectId);
        } catch (Exception ex) {
            // we use this variables to avoid trying to create link if workitem was not created
            isCreatingFailed = true;
            V1Publisher.errorMessage('Error during creating workitem in the VersionOne.', ex);
            V1CaseCollector.updateProcessInVersionOneInCase(new Case[] {caseData}, false);
        }
        String url = (workitemId == null) ? null : settings.getPath() + V1Publisher.URL_TO_V1_TEMPLATE + EncodingUtil.urlEncode(workitemId, 'UTF-8');
        V1CaseCollector.updateUrlToVersionOneInCase(caseData, url);
    }

    private void createLinkInVersionOneAndCompletePorting(Case caseData, Settings settings, IV1Connector connector) {
        String url;
        try {
            url = caseData.VersionOneUrl__c;
            String id = url.substring(url.indexOf('=') + 1).replace('%3a', ':').replace('%3A', ':');
            connector.createLinkV1ToSF(id, caseData);
        } catch (Exception ex) {
            V1Publisher.errorMessage('Error during creating link for workitem to case.', ex);
        }
        try {
            V1CaseCollector.updateCase(caseData, settings.getDestQueueId(), settings.getCommentBody(), url, false);
        } catch (Exception ex) {
            V1Publisher.errorMessage('Error during final updating case.', ex);
        }
    }

    private Boolean isCasePorted(Case caseData) {
        return caseData.VersionOneUrl__c == null || caseData.VersionOneUrl__c == '';
    }

    global void finish(Database.BatchableContext bc){
    	System.debug('finish cases:' + updatedCases);
        V1CaseCollector.updateProcessInVersionOneInCase(updatedCases, false);
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
        if (value < 3) {
            return 0;
        }
        Decimal decValue = --value;
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