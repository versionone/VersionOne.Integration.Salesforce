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

}