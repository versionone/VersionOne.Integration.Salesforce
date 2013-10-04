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

    static testMethod void getCasesByCasesNumberTest() {
        Case case1 = new Case(Subject='TestCase1');
        Case case2 = new Case(Subject='TestCase2');
        Case case3 = new Case(Subject='TestCase3');
        Case case4 = new Case(Subject='TestCase4');
        insert new Case[] {case1, case2, case3, case4};
        case1 = [SELECT CaseNumber, Subject FROM Case WHERE Id = :case1.Id];
        case2 = [SELECT CaseNumber, Subject FROM Case WHERE Id = :case2.Id];
        case3 = [SELECT CaseNumber, Subject FROM Case WHERE Id = :case3.Id];

        Case[] newCase = V1CaseCollector.getCasesByCasesNumber(new String[]{case1.CaseNumber, case2.CaseNumber, case3.CaseNumber});
        System.assertEquals(3, newCase.size(), 'Incorrect number of cases.');
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
        String devStatus = 'In Progress';
        Case case1 = new Case(Subject='TestCase1');
        insert new Case[] {case1};
        case1 = [SELECT CaseNumber, Subject, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :case1.Id];

        V1CaseCollector.updateCase(case1, defectId, true, devStatus);
        Case newCase = [SELECT CaseNumber, Subject, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(devStatus, newCase.V1DevelopmentStatus__c, 'Incorrect case numbers.');
        System.assertEquals(case1.CaseNumber, newCase.CaseNumber, 'Incorrect case numbers.');
        System.assertEquals(case1.Subject, newCase.Subject, 'Incorrect subject.');
        System.assertEquals(true, newCase.V1Association__c, 'Case has to be associated with defect from Versionone.');
        System.assertEquals(defectId, newCase.V1DefectId__c, 'Incorrect associated defect id from VersionOne.');
    }

    static testMethod void updateDeveloperStatusTest() {
        String status = 'In Progress';
        Case case1 = new Case(Subject='TestCase1');
        insert new Case[] {case1};
        case1 = [SELECT V1DevelopmentStatus__c FROM Case WHERE Id = :case1.Id];

        V1CaseCollector.updateDeveloperStatus(case1, status);
        case1 = [SELECT V1DevelopmentStatus__c FROM Case WHERE Id = :case1.Id];
        System.assertEquals(status, case1.V1DevelopmentStatus__c, 'Incorrect case numbers.');
    }

    static testMethod void getMappingListTest() {
        for (MappingV1ProjectsToSFProducts__c obj :
            [select Id from MappingV1ProjectsToSFProducts__c]) {
            delete obj;
        }
        String projectName1 = 'Project Name';
        String productName1 = 'Product Name';
        String projectToken1 = 'Scope:1234';
        String productId1 = 'GDS';
        MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
        mappingData1.SFProductId__c = productId1;
        mappingData1.SFProductName__c = productName1;
        mappingData1.V1ProjectToken__c = projectToken1;
        mappingData1.V1ProjectName__c = projectName1;
        String projectName2 = 'Project Name 2';
        String productName2 = 'Product Name 2';
        String projectToken2 = 'Scope:2468';
        String productId2 = 'GDS 2';
        MappingV1ProjectsToSFProducts__c mappingData2 = new MappingV1ProjectsToSFProducts__c();
        mappingData2.SFProductId__c = productId2;
        mappingData2.SFProductName__c = productName2;
        mappingData2.V1ProjectToken__c = projectToken2;
        mappingData2.V1ProjectName__c = projectName2;
        insert new MappingV1ProjectsToSFProducts__c[]{mappingData1, mappingData2};

        List<MappingV1ProjectsToSFProducts__c> mappings = V1CaseCollector.getMappingList();
        System.assertEquals(2, mappings.size(), 'Incorrect number of mappings.');
        assertMappingContain(mappingData1, mappings, 'Incorrect data in mapping');
        assertMappingContain(mappingData2, mappings, 'Incorrect data in mapping');
        //System.assertEquals(productId1, mappings.get(0).SFProductId__c, 'Incorrect product id for first mapping.');
        //System.assertEquals(productName1, mappings.get(0).SFProductName__c, 'Incorrect product name for first mapping.');
        //System.assertEquals(projectToken1, mappings.get(0).V1ProjectToken__c, 'Incorrect project token for first mapping.');
        //System.assertEquals(projectName1, mappings.get(0).V1ProjectName__c, 'Incorrect project name for first mapping.');
        //System.assertEquals(productId2, mappings.get(1).SFProductId__c, 'Incorrect product id for second mapping.');
        //System.assertEquals(productName2, mappings.get(1).SFProductName__c, 'Incorrect product name for second mapping.');
        //System.assertEquals(projectToken2, mappings.get(1).V1ProjectToken__c, 'Incorrect project token for second mapping.');
        //System.assertEquals(projectName2, mappings.get(1).V1ProjectName__c, 'Incorrect project name for second mapping.');
    }

    private static void assertMappingContain(MappingV1ProjectsToSFProducts__c expected, List<MappingV1ProjectsToSFProducts__c> actuals, String errorMessage){
        boolean result = false;
        for (MappingV1ProjectsToSFProducts__c actual : actuals) {
            if (isMappingEquals(actual, expected)) {
                result = true;
                break;
            }
        }

        System.assert(result, errorMessage);
    }

    private static void assertMappingContain(ProjectProductMapping expected, List<MappingV1ProjectsToSFProducts__c> actuals, String errorMessage){
        boolean result = false;
        for (MappingV1ProjectsToSFProducts__c actual : actuals) {
            if (isMappingEquals(actual, expected)) {
                result = true;
                break;
            }
        }

        System.assert(result, errorMessage);
    }

    private static boolean isMappingEquals(MappingV1ProjectsToSFProducts__c mapping1, MappingV1ProjectsToSFProducts__c mapping2) {
        Boolean result = true;
        result = mapping1.SFProductId__c == mapping2.SFProductId__c;
        result = mapping1.SFProductName__c == mapping2.SFProductName__c;
        result = mapping1.V1ProjectToken__c == mapping2.V1ProjectToken__c;
        result = mapping1.V1ProjectName__c == mapping2.V1ProjectName__c;
        System.assertNotEquals(null, result, 'Result state is not correct.');
        return result;
    }

    private static boolean isMappingEquals(MappingV1ProjectsToSFProducts__c mapping1, ProjectProductMapping mapping2) {
        Boolean result = true;
        result = mapping2.productId == mapping1.SFProductId__c;
        result = mapping2.productName == mapping1.SFProductName__c;
        result = mapping2.projectToken == mapping1.V1ProjectToken__c;
        result = mapping2.projectName == mapping1.V1ProjectName__c;
        System.assertNotEquals(null, result, 'Result state is not correct.');
        return result;
    }

    static testMethod void addNewMappingTest() {
        String projectName = 'Project Name';
        String productName = 'Product Name';
        String projectToken = 'Scope:1234';
        String productId = 'GDS';
        ProjectProductMapping mapping = new ProjectProductMapping(projectName, true, productName);
        mapping.projectToken = projectToken;
        mapping.productId = productId;
        V1CaseCollector.addNewMapping(mapping);

        MappingV1ProjectsToSFProducts__c newMapping = [SELECT ID FROM MappingV1ProjectsToSFProducts__c WHERE SFProductId__c =: productId and SFProductName__c =: productName and V1ProjectToken__c =: projectToken and V1ProjectName__c =: projectName];
        System.assertNotEquals(null, newMapping, 'Incorrect mapping data from the base.');
    }


    static testMethod void deleteMappingTest() {
        for (MappingV1ProjectsToSFProducts__c obj :
            [select Id from MappingV1ProjectsToSFProducts__c]) {
            delete obj;
        }
        String projectName1 = 'Project Name';
        String productName1 = 'Product Name';
        String projectToken1 = 'Scope:1234';
        String productId1 = 'GDS';
        MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
        mappingData1.SFProductId__c = productId1;
        mappingData1.SFProductName__c = productName1;
        mappingData1.V1ProjectToken__c = projectToken1;
        mappingData1.V1ProjectName__c = projectName1;
        String projectName2 = 'Project Name 2';
        String productName2 = 'Product Name 2';
        String projectToken2 = 'Scope:2468';
        String productId2 = 'GDS 2';
        MappingV1ProjectsToSFProducts__c mappingData2 = new MappingV1ProjectsToSFProducts__c();
        mappingData2.SFProductId__c = productId2;
        mappingData2.SFProductName__c = productName2;
        mappingData2.V1ProjectToken__c = projectToken2;
        mappingData2.V1ProjectName__c = projectName2;
        insert new MappingV1ProjectsToSFProducts__c[]{mappingData1, mappingData2};

        V1CaseCollector.deleteMapping(mappingData1.id);
        List<MappingV1ProjectsToSFProducts__c> mappings = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c];
        System.assertEquals(1, mappings.size(), 'Incorect about of mapping after deleting.');
        //System.assertEquals(productName2, mappings.get(0).SFProductName__c, 'Incorect product name in mapping which was not deleted.');
        assertMappingContain(mappingData2, mappings, 'Incorect product data in mapping which was not deleted.');
    }

    //this test just verify that if there is no record with specify id, will not exception happens
    static testMethod void deleteMappingWhenNothingToDeleteTest() {
        for (MappingV1ProjectsToSFProducts__c obj :
            [select Id from MappingV1ProjectsToSFProducts__c]) {
            delete obj;
        }
        V1CaseCollector.deleteMapping('112312313123');
        //assert to show that we can reach this place
        System.assert(true);
    }

    static testMethod void updateMappingTest() {
        for (MappingV1ProjectsToSFProducts__c obj :
            [select Id from MappingV1ProjectsToSFProducts__c]) {
            delete obj;
        }
        String projectName1 = 'Project Name';
        String productName1 = 'Product Name';
        String projectToken1 = 'Scope:1234';
        String productId1 = 'GDS';
        MappingV1ProjectsToSFProducts__c mappingData1 = new MappingV1ProjectsToSFProducts__c();
        mappingData1.SFProductId__c = productId1;
        mappingData1.SFProductName__c = productName1;
        mappingData1.V1ProjectToken__c = projectToken1;
        mappingData1.V1ProjectName__c = projectName1;
        String projectName2 = 'Project Name 2';
        String productName2 = 'Product Name 2';
        String projectToken2 = 'Scope:2468';
        String productId2 = 'GDS 2';
        MappingV1ProjectsToSFProducts__c mappingData2 = new MappingV1ProjectsToSFProducts__c();
        mappingData2.SFProductId__c = productId2;
        mappingData2.SFProductName__c = productName2;
        mappingData2.V1ProjectToken__c = projectToken2;
        mappingData2.V1ProjectName__c = projectName2;
        insert new MappingV1ProjectsToSFProducts__c[]{mappingData1, mappingData2};
        String newProjectName = 'new project name';
        String newProductName = 'new product name';
        String newProjectToken = 'Scope:2345';
        String newProductId = 'new GDS';

        ProjectProductMapping updateForMapping = new ProjectProductMapping(newProjectName, false, newProductName);
        updateForMapping.projectToken = newProjectToken;
        updateForMapping.productId = newProductId;

        V1CaseCollector.updateMapping(mappingData2.id, updateForMapping);
        List<MappingV1ProjectsToSFProducts__c> mappings = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c];
        System.assertEquals(2, mappings.size(), 'Incorect about of mapping after deleting.');
        assertMappingContain(mappingData1, mappings, 'Incorect product data in mapping which was not updated.');
        assertMappingContain(updateForMapping, mappings, 'Incorect product data in mapping which was not updated.');
    }

    static testMethod void getCasesTest() {
        for (Case obj : [select Id from Case]) {
            delete obj;
        }

        System.runAs(createUser('test4356')){
            String queueName = 'TestQueue1';
            Group queue = new Group(Type='Queue', Name=queueName);
            insert queue;
            QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
            insert sobj;
            Case case1 = new Case(Subject='TestCase1', OwnerId = queue.Id, V1Association__c = true);
            Case case2 = new Case(Subject='TestCase2', OwnerId = queue.Id, V1Association__c = true);
            Case case3 = new Case(Subject='TestCase3', OwnerId = queue.Id, V1Association__c = true);
            Case case4 = new Case(Subject='TestCase4', V1Association__c = true);
            insert new Case[] {case1, case2, case3, case4};

            Case[] cases = V1CaseCollector.getCases(queue.Id, false);
            System.assertEquals(3, cases.size(), 'Incorrect numbers of cases.');

            case2.status = 'Closed';
            case3.V1Association__c = false;
            update new Case[] {case2, case3};
            Case[] newCases = V1CaseCollector.getCases(queue.Id, true);
            System.assertEquals(1, newCases.size(), 'Incorrect numbers of cases. One cases have to be closed');
            assertContains(case2, newCases, 'Incorrect data in result.');
            newCases = V1CaseCollector.getCases(queue.Id, false);
            System.assertEquals(1, newCases.size(), 'Incorrect numbers of cases. Two classes have to be not closed');
            assertContains(case1, newCases, 'Incorrect data in result.');
            newCases = V1CaseCollector.getCases(null, false);
            System.assertEquals(2, newCases.size(), 'Incorrect numbers of cases.');
        }
    }

    static void assertContains (SObject expect, SObject[] actuals, String msg) {
        Boolean contains = false;
        for (SObject o : actuals) {
            if (o.Id == expect.Id) {
                contains = true;
                break;
            }
        }
        System.assert(contains, msg + '\n  ' + expect + ' not found in ' + actuals);
    }

    static User createUser(String alias) {
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
        return user;
    }
}