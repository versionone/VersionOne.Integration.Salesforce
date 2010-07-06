@isTest
private class DefectFacadeTester {
    private static final String DEFECT_TOKEN = 'Defect:2345';
    private static final String PROJECT_TOKEN = 'Scope:1000';
    private static final String PROJECT_NAME = 'V1 Project';
    private static final String PRODUCT_ID = 'DefaultProductId';
    private static final String PRODUCT_NAME = 'DefaultProduct';

    static testMethod void createDefectInVersionOneTest() {
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemToken(DEFECT_TOKEN);
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        Defect defectData = new Defect('defect name', 'defect description');
        Case case1 = createCase('case1', 'desc', false);

        String createdDefectToken = defectFacade.createDefectInVersionOne(case1, defectData);

        Case newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(DEFECT_TOKEN, createdDefectToken, 'Incorrect defect token');
        System.assertEquals(true, newCase1.V1Association__c, 'Incorrect defect association flag');
        System.assertEquals(DEFECT_TOKEN, newCase1.V1DefectId__c, 'Incorrect defect token');
    }

    static testMethod void createDefectUsingMappingTest() {
        removeAllMappings();
        String projectId = PROJECT_TOKEN.split(':')[1];

        // we deliberately put Project ID to mapping Project Name field to be able to check later that mock receives correct parameter value
        MappingV1ProjectsToSFProducts__c mapping = new MappingV1ProjectsToSFProducts__c();
        mapping.SFProductId__c = PRODUCT_ID;
        mapping.SFProductName__c = PRODUCT_NAME;
        mapping.V1ProjectToken__c = PROJECT_TOKEN;
        mapping.V1ProjectName__c = projectId;
        insert mapping;

        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemToken(DEFECT_TOKEN);
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        Defect defectValue = new Defect('defect name', 'defect description');
        Case caseValue = createCase('case1', 'desc', false);

        String createdDefectToken = defectFacade.createDefectInVersionOne(caseValue, defectValue);

        Case updatedCase = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :caseValue.Id];
        System.assertEquals(DEFECT_TOKEN, createdDefectToken, 'Incorrect defect token');
        System.assertEquals(true, updatedCase.V1Association__c, 'Incorrect defect association flag');
        System.assertEquals(DEFECT_TOKEN, updatedCase.V1DefectId__c, 'Incorrect defect token');
        System.assertEquals(defectValue.project, projectId);
    }

    static testMethod void createDefectInVersionOneWithExceptionsTest() {
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemToken(DEFECT_TOKEN);
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        Defect defectData = new Defect('defect name', 'defect description');

        // Exception during defect creation
        connector.setExceptionForCreationWorkitemInV1(new NullPointerException());
        Case case1 = createCase('case1', 'desc', false);

        String createdDefectToken;
        try {
            createdDefectToken = defectFacade.createDefectInVersionOne(case1, defectData);
            System.assert(false, 'Error! V1RequestException must be thrown.');
        } catch (IntegrationException ex) {}

        Case newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(null, createdDefectToken, 'Incorrect defect token');
        System.assertEquals(false, newCase1.V1Association__c, 'Incorrect defect association flag');
        System.assertEquals(null, newCase1.V1DefectId__c, 'Incorrect defect token');

        //Exception during link creation
        connector.setExceptionForCreationWorkitemInV1(null);
        connector.setExceptionForLinkCreationInV1(new NullPointerException());
        case1 = new Case(Subject = 'case1', Description = 'desc');
        insert case1;
        case1 = [SELECT Subject, Id, Description, Product__c, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        createdDefectToken = null;
        try {
            createdDefectToken = defectFacade.createDefectInVersionOne(case1, defectData);
            System.assert(false, 'Error! IntegrationException must be thrown.');
        } catch (IntegrationException ex) {}

        newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(null, createdDefectToken, 'Incorrect defect token');
        System.assertEquals(true, newCase1.V1Association__c, 'Incorrect defect association flag');
        System.assertEquals(DEFECT_TOKEN, newCase1.V1DefectId__c, 'Incorrect defect token');
    }

    static testMethod void unassignDefectFromCaseTest() {
        Case case1 = createCase('case1', 'desc', true);

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        defectFacade.unassignDefectFromCase(case1);
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        System.assertEquals(null, case1.V1DefectId__c, 'Assigned defect has to be empty.');
        System.assertEquals(false, case1.V1Association__c, 'Case does not have association.');
    }

    static testMethod void unassignNotAssignedDefectTest() {
        Case caseValue = createCase('case1', 'desc', false);
        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());

        try {
            defectFacade.unassignDefectFromCase(caseValue);
            System.assert(false, 'We\'re awaiting unassignment failure and should never hit this line');
        } catch(IntegrationException ex) { }
    }

    static testMethod void assignDefectSetReferenceFailureTest() {
        Case caseValue = createCase('case1', 'desc', true);
        Defect defectValue = createDefect('defect', 'description', false);

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());

        connector.setUpdateReferenceForDefectException(new IntegrationException());

        try {
            defectFacade.assignDefectToCase(caseValue, defectValue);
            System.assert(false, 'This line should not be reached - we\'re awaiting an exception');
        } catch(IntegrationException ex) { }
    }

    static testMethod void assignDefectCreateLinkFailureTest() {
        Case caseValue = createCase('case1', 'desc', true);
        Defect defectValue = createDefect('defect', 'description', false);

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());

        connector.setExceptionForLinkCreationInV1(new IntegrationException());

        try {
            defectFacade.assignDefectToCase(caseValue, defectValue);
            System.assert(false, 'This line should not be reached - we\'re awaiting an exception');
        } catch(IntegrationException ex) {
            System.assertEquals(ex.getSeverity(), Severity.WARNING);
        }

        caseValue = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :caseValue.Id];

        // link creation failures are never considered critical, so we check that Case is updated
        System.assertEquals(caseValue.V1Association__c, true, 'Association field should be set');
        System.assertEquals(caseValue.V1DefectId__c, DEFECT_TOKEN, 'Defect token does not match expectations');
    }

    static testMethod void assignClosedDefectSuccessTest() {
        Case caseValue = createCase('case1', 'desc', true);
        Defect defectValue = createDefect('defect', 'description', true);

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());

        connector.setUpdateReferenceForDefectException(new IntegrationException());

        defectFacade.assignDefectToCase(caseValue, defectValue);
        caseValue = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :caseValue.Id];

        System.assertEquals(caseValue.V1Association__c, true, 'Association field should be set');
        System.assertEquals(caseValue.V1DefectId__c, DEFECT_TOKEN, 'Defect token does not match expectations');
    }

    static testMethod void assignNonClosedDefectSuccessTest() {
        Case caseValue = createCase('case1', 'desc', true);
        Defect defectValue = createDefect('defect', 'description', true);

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());

        defectFacade.assignDefectToCase(caseValue, defectValue);
        caseValue = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :caseValue.Id];

        System.assertEquals(caseValue.V1Association__c, true, 'Association field should be set');
        System.assertEquals(caseValue.V1DefectId__c, DEFECT_TOKEN, 'Defect token does not match expectations');
    }

    static testMethod void unassignDefectFromCaseWithExceptionsTest() {
        Case case1 = createCase('case1', 'desc', true);

        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setRemoveLinkFromDefectException(new NullPointerException());
        connector.setUpdateReferenceForDefectException(new NullPointerException());
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        try {
            defectFacade.unassignDefectFromCase(case1);
            System.assert(false, 'Error! IntegrationException must be thrown.');
        } catch(IntegrationException ex) {}
        System.assertEquals(null, case1.V1DefectId__c, 'Assigned defect has to be empty.');
        System.assertEquals(false, case1.V1Association__c, 'Case does not have association.');
    }

    static testMethod void publishStatusTest() {
        Case case1 = createCase('case1', 'desc', true);

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        defectFacade.publishStatus(case1);

        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(V1ConnectorMock.developmentStatus, case1.V1DevelopmentStatus__c, 'Incorrect developer status.');
    }

    static testMethod void searchForDefectsFailureTest() {
        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        connector.setSearchForDefectsException(new IntegrationException());
        DefectSearchCriteria criteria = new DefectSearchCriteria();
        criteria.includeClosedDefects = true;
        criteria.queryString = 'test';
        criteria.searchIn = 'Title';
        try {
            defectFacade.searchForDefects(criteria);
            System.assert(false, 'This line should not be reached - we\'re awaiting an exception');
        } catch(IntegrationException ex) { }
    }

    static testMethod void searchForDefectsTest() {
        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        DefectSearchCriteria criteria = new DefectSearchCriteria();
        criteria.includeClosedDefects = true;
        criteria.queryString = 'test';
        criteria.searchIn = 'Title';
        try {
            defectFacade.searchForDefects(criteria);
        } catch(IntegrationException ex) {
            System.assert(false, 'We\'re not expecting connector to fail this time');
        }
        String[] fields = connector.getFieldsForSearch();
        System.assertEquals(1, fields.size());
        System.assertEquals('Name', fields.get(0));

        criteria.searchIn = 'All';
        try {
            defectFacade.searchForDefects(criteria);
        } catch(IntegrationException ex) {
            System.assert(false, 'We\'re not expecting connector to fail this time');
        }
        fields = connector.getFieldsForSearch();
        System.assertEquals(4, fields.size());//'Number', 'Name', 'Description', 'Reference'
        System.assertEquals('Number', fields.get(0));
        System.assertEquals('Name', fields.get(1));
        System.assertEquals('Description', fields.get(2));
        System.assertEquals('Reference', fields.get(3));
    }

    static testMethod void searchForDefectsWithIncorrectFieldDataTest() {
        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        DefectSearchCriteria criteria = new DefectSearchCriteria();
        criteria.includeClosedDefects = true;
        criteria.queryString = 'test';
        criteria.searchIn = 'incorrect data';
        try {
            defectFacade.searchForDefects(criteria);
            System.assert(false, 'This line should not be reached - we\'re awaiting an exception');
        } catch(IntegrationException ex) {
        }
    }

    private static Case createCase(String caseSubject, String caseDescription, Boolean isAssigned) {
        Case caseValue = new Case(
            Subject = 'case1',
            Description = 'desc',
            Product__c = PRODUCT_ID,
            V1Association__c = isAssigned,
            V1DefectId__c = isAssigned ? DEFECT_TOKEN : null
        );
        insert caseValue;
        caseValue = [SELECT Subject, Id, Description, Product__c, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :caseValue.Id];
        return caseValue;
    }

    private static void removeAllMappings() {
        for (MappingV1ProjectsToSFProducts__c obj :
            [select Id from MappingV1ProjectsToSFProducts__c]) {
            delete obj;
        }
    }

    private static Defect createDefect(String title, String description, Boolean isClosed) {
        Defect defectValue = new Defect(title, description);
        defectValue.token = DEFECT_TOKEN;
        defectValue.isClosed = isClosed;
        return defectValue;
    }
}