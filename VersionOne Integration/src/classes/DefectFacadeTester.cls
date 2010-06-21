@isTest
private class DefectFacadeTester {

    static testMethod void createDefectInVersionOneTest() {
        String defectToken = 'defect:1234';
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemToken(defectToken);
        IDefectFacade defectFacade = new DefectFacade(connector);
        Defect defectData = new Defect('defect name', 'defect description');
        Case case1 = new Case(Subject = 'case1', Description = 'desc');
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        String createdDefectToken = defectFacade.createDefectInVersionOne(case1, defectData);

        Case newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(defectToken, createdDefectToken, 'Incorrect defect token');
        System.assertEquals(true, newCase1.V1Association__c, 'Incorrect defect association flag');
        System.assertEquals(defectToken, newCase1.V1DefectId__c, 'Incorrect defect token');
    }

    static testMethod void createDefectInVersionOneWithExceptionsTest() {
        String defectToken = 'defect:1234'; 
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemToken(defectToken);
        IDefectFacade defectFacade = new DefectFacade(connector);
        Defect defectData = new Defect('defect name', 'defect description');

        // Exception during defect creation
        connector.setExceptionForCreationWorkitemInV1(new NullPointerException());
        Case case1 = new Case(Subject = 'case1', Description = 'desc');
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

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
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        createdDefectToken = null;
        try {
            createdDefectToken = defectFacade.createDefectInVersionOne(case1, defectData);
            System.assert(false, 'Error! IntegrationException must be thrown.');
        } catch (IntegrationException ex) {}

        newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(null, createdDefectToken, 'Incorrect defect token');
        System.assertEquals(true, newCase1.V1Association__c, 'Incorrect defect association flag');
        System.assertEquals(defectToken, newCase1.V1DefectId__c, 'Incorrect defect token');
    }

    static testMethod void unassignDefectFromCaseTest() {
        Case case1 = new Case(Subject = 'case1', Description = 'desc', V1DefectId__c = 'Defect:2345', V1Association__c = true);
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector);
        defectFacade.unassignDefectFromCase(case1);
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        System.assertEquals(null, case1.V1DefectId__c, 'Assigned defect has to be empty.');
        System.assertEquals(false, case1.V1Association__c, 'Case does not have association.');
    }

    static testMethod void unassignDefectFromCaseWithExceptionsTest() {
        Case case1 = new Case(Subject = 'case1', Description = 'desc', V1DefectId__c = 'Defect:2345', V1Association__c = true);
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setRemoveLinkFromDefectException(new NullPointerException());
        connector.setUpdateReferenceForDefectException(new NullPointerException());
        IDefectFacade defectFacade = new DefectFacade(connector);
        try {
            defectFacade.unassignDefectFromCase(case1);
            System.assert(false, 'Error! IntegrationException must be thrown.');
        } catch(IntegrationException ex) {}
        System.assertEquals(null, case1.V1DefectId__c, 'Assigned defect has to be empty.');
        System.assertEquals(false, case1.V1Association__c, 'Case does not have association.');
    }

    static testMethod void publishStatusTest() {
        Case case1 = new Case(Subject = 'case1', Description = 'desc', V1DefectId__c = 'Defect:2345', V1Association__c = true);
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :case1.Id];

        V1ConnectorMock connector = new V1ConnectorMock();
        IDefectFacade defectFacade = new DefectFacade(connector);
        defectFacade.publishStatus(case1);

        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(V1ConnectorMock.Developer_Status, case1.V1DevelopmentStatus__c, 'Incorrect developer status.');
    }
}