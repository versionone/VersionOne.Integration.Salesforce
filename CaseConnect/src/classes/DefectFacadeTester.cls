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
        connector.addException(V1ConnectorMock.CREATION_WORKITEM_EXCEPTION, new IntegrationException());
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
        connector.addException(V1ConnectorMock.CREATION_WORKITEM_EXCEPTION, null);
        connector.addException(V1ConnectorMock.CREATION_LINK_EXCEPTION, new IntegrationException());
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

        connector.addException(V1ConnectorMock.UPDATING_REFERENCE_FOR_DEFECT_EXCEPTION, new IntegrationException());

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

        connector.addException(V1ConnectorMock.CREATION_LINK_EXCEPTION, new IntegrationException());

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

        connector.addException(V1ConnectorMock.UPDATING_REFERENCE_FOR_DEFECT_EXCEPTION, new IntegrationException());

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
        connector.addException(V1ConnectorMock.REMOVING_LINK_FROM_DEFECT_EXCEPTION, new IntegrationException());
        connector.addException(V1ConnectorMock.UPDATING_REFERENCE_FOR_DEFECT_EXCEPTION, new IntegrationException());
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
        connector.addException(V1ConnectorMock.SEARCHING_FOR_DEFECTS_EXCEPTION, new IntegrationException());
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

    static testMethod void getDateTimeTest() {
    	String dateTime1 = '2009-10-21 08:57:50';
    	String dateTime2 = '2009-10-21';
    	String format = 'yyyy-MM-dd HH:mm:ss';
        System.assertEquals(null, DefectFacade.getDateTime(null));
        System.assertEquals(dateTime1, DefectFacade.getDateTime(dateTime1).format(format));
        System.assertEquals(dateTime2+' 00:00:00', DefectFacade.getDateTime(dateTime2).format(format));
    }

    static testMethod void getCasesWithDefectsTest() {
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemToken(DEFECT_TOKEN);
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());

    	User userData = createUser('testUser');
    	List<Case> cases = new List<Case>();
    	List<Defect> defects = new List<Defect>();
    	Integer numberRecords = 100;
		System.runAs(userData){
	    	for (Integer i=0; i<numberRecords; i++) {
		        Case caseValue = new Case(
		            Subject = 'case'+i,
		            Description = 'desc'+i,
		            Product__c = PRODUCT_ID,
		            V1Association__c = true,
		            V1DefectId__c = 'Defect:'+i,
		            OwnerId = Userinfo.getUserId()
		        );
	    	    cases.add(caseValue);
	    	    Defect defectData = new Defect('case'+i, 'desc'+i);
	    	    defectData.id = String.valueof(i);
	    	    defects.add(defectData);
	    	}
	    	insert cases;
	    	connector.AssignedDefects = defects;

    		List<DefectWrapper> wrappedDefects = defectFacade.getCasesWithDefects(true, false, true);
    		System.assertEquals(numberRecords, wrappedDefects.size(), 'Incorrect numbers of defects.');
    		for (Integer i=0; i<numberRecords; i++) {
    			System.assertNotEquals(null, wrappedDefects.get(i).casePart, 'Case can\'t be null.');
    			System.assertNotEquals(null, wrappedDefects.get(i).defectPart, 'Defect can\'t be null.');
    		}
		}
    }

    static testMethod void getCasesWithDefectsWithExceptionTest() {
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.addException(V1ConnectorMock.GETTING_CASES_WITH_DEFECTS_EXCEPTION, new IntegrationException());
        IDefectFacade defectFacade = new DefectFacade(connector, Settings.getTestSettings());
        try {
            defectFacade.getCasesWithDefects(true, true, true);
            System.assert(false, 'This line should not be reached - we\'re awaiting the IntegrationException exception');
        } catch(IntegrationException ex) { }

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
        caseValue = [SELECT Subject, Id, Description, Product__c, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c, CaseNumber FROM Case WHERE Id = :caseValue.Id];
        System.assertNotEquals(null, caseValue);
        return caseValue;
    }

    private static void removeAllMappings() {
        for (MappingV1ProjectsToSFProducts__c obj :
            [select Id from MappingV1ProjectsToSFProducts__c]) {
            delete obj;
        }

         System.assertEquals(0, [select Id from MappingV1ProjectsToSFProducts__c LIMIT 5].size());
    }

    private static Defect createDefect(String title, String description, Boolean isClosed) {
        Defect defectValue = new Defect(title, description);
        defectValue.token = DEFECT_TOKEN;
        defectValue.isClosed = isClosed;
        System.assertNotEquals(null, defectValue);
        return defectValue;
    }

    private static User createUser(String alias) {
        User user = new User();
        user.Username = alias + '@not-a-mail.com';
        user.LastName = alias;
        user.Email = alias + '@not-a-mail.com';
        user.alias = alias;
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user.LanguageLocaleKey = 'en_US';
        System.assertNotEquals(null, user);
        return user;
    }
}