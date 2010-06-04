@isTest
private class V1CaseCollectorTestSuite {

    static testMethod void getCaseByCaseNumberTest() {
        Case case1 = new Case(Subject='TestCase1');
        insert new Case[] {case1};
        case1 = [SELECT CaseNumber, Subject FROM Case WHERE Id = :case1.Id];

        Case newCase = V1CaseCollector.getCaseByCaseNumber(case1.CaseNumber);
        System.assertEquals(case1.CaseNumber, newCase.CaseNumber, 'Incorrect case numbers.');
        System.assertEquals(case1.Subject, newCase.Subject, 'Incorrect subject.');
    }

	static testMethod void getCaseByCaseIdTest() {
        Case case1 = new Case(Subject='TestCase1');
        insert new Case[] {case1};
        case1 = [SELECT CaseNumber, Subject FROM Case WHERE Id = :case1.Id];

        Case newCase = V1CaseCollector.getCaseByCaseId(case1.Id);
        System.assertEquals(case1.CaseNumber, newCase.CaseNumber, 'Incorrect case numbers.');
        System.assertEquals(case1.Subject, newCase.Subject, 'Incorrect subject.');
	}

	static testMethod void updateCaseTest() {
		String defectId = '123';
        Case case1 = new Case(Subject='TestCase1');
        insert new Case[] {case1};
        case1 = [SELECT CaseNumber, Subject, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];

        V1CaseCollector.updateCase(case1, defectId, true);
        Case newCase = [SELECT CaseNumber, Subject, V1Association__c, V1DefectId__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(case1.CaseNumber, newCase.CaseNumber, 'Incorrect case numbers.');
        System.assertEquals(case1.Subject, newCase.Subject, 'Incorrect subject.');
        System.assertEquals(true, newCase.V1Association__c, 'Case has to be associated with defect from Versionone.');
        System.assertEquals(defectId, newCase.V1DefectId__c, 'Incorrect associated defect id from VersionOne.');
	}
}