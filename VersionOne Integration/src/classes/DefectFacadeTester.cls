@isTest
private class DefectFacadeTester {

    static testMethod void createDefectInVersionOneTest() {
        String defectId = 'defect:1234';
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemId(defectId);
        IDefectFacade defectFacade = new DefectFacade(connector);
        Defect defectData = new Defect('defect name', 'defect description');
        Case case1 = new Case(Subject = 'case1', Description = 'desc');
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        String createdDefectId = defectFacade.createDefectInVersionOne(case1, defectData);

		Case newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
		System.assertEquals(defectId, createdDefectId, 'Incorrect defect id');
		System.assertEquals(true, newCase1.V1Association__c, 'Incorrect defect id');
		System.assertEquals(defectId, newCase1.V1DefectId__c, 'Incorrect defect id');
    }

    static testMethod void createDefectInVersionOneWithExceptionsTest() {
        String defectId = 'defect:1234';
        V1ConnectorMock connector = new V1ConnectorMock();
        connector.setCreatedWorkitemId(defectId);
        IDefectFacade defectFacade = new DefectFacade(connector);
        Defect defectData = new Defect('defect name', 'defect description');

        // Exception during defect creation
        connector.setExceptionForCreationWorkitemInV1(new NullPointerException());
        Case case1 = new Case(Subject = 'case1', Description = 'desc');
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

		String createdDefectId;
		try {
        	createdDefectId = defectFacade.createDefectInVersionOne(case1, defectData);
        	System.assert(false, 'Error! V1RequestException must be thrown.');
        } catch (NullPointerException ex) {}

		Case newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
		System.assertEquals(null, createdDefectId, 'Incorrect defect id');
		System.assertEquals(false, newCase1.V1Association__c, 'Incorrect defect id');
		System.assertEquals(null, newCase1.V1DefectId__c, 'Incorrect defect id');

		//Exception duing link creation
		connector.setExceptionForCreationWorkitemInV1(null);
		connector.setExceptionForLinkCreationInV1(new NullPointerException());
        case1 = new Case(Subject = 'case1', Description = 'desc');
        insert case1;
        case1 = [SELECT Subject, Id, Description, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

		createdDefectId = null;
		try {
        	createdDefectId = defectFacade.createDefectInVersionOne(case1, defectData);
        	System.assert(false, 'Error! V1RequestException must be thrown.');
        } catch (V1RequestException ex) {}

		newCase1 = [SELECT V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
		System.assertEquals(null, createdDefectId, 'Incorrect defect id');
		System.assertEquals(true, newCase1.V1Association__c, 'Incorrect defect id');
		System.assertEquals(defectId, newCase1.V1DefectId__c, 'Incorrect defect id');
    }
}