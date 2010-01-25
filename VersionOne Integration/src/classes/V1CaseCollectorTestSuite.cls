@isTest
private class V1CaseCollectorTestSuite {

    static testMethod void countAndGetCasesByOwnerIdTest() {

    }

    static testMethod void setCasesOwnerTest() {
    	String queueName = 'TestQueue1';
    	Group queue = new Group(Type='Queue', Name=queueName);
    	insert queue;
    	String case1Name = 'TestCase1';
    	Case case1 = new Case(Subject=case1Name);
    	insert case1;
    	String case2Name = 'TestCase2';
    	Case case2 = new Case(Subject=case2Name);
    	insert case2;
    	String case3Name = 'TestCase3';
    	Case case3 = new Case(Subject=case3Name);
    	insert case3;
    	QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
    	insert sobj;

		System.debug('==> OwnerId=' + case1.OwnerId);
		System.assertEquals(case1.OwnerId, null, 'Case1 already owned by queue.');
		System.assertEquals(case2.OwnerId, null, 'Case2 already owned by queue.');
		System.assertEquals(case3.OwnerId, null, 'Case3 already owned by queue.');

    	V1CaseCollector.setCasesOwner(new Case[] {case1, case2}, queue.Id);
		System.assertEquals(case1.OwnerId, queue.Id, 'Case1 Owner doesn\'t changed.');
		System.assertEquals(case2.OwnerId, queue.Id, 'Case2 Owner doesn\'t changed.');
		System.assertEquals(case3.OwnerId, null, 'Case3 Owner set by mistake.');

		Case[] newCases = V1CaseCollector.getCasesByOwnerId(queue.Id);
		System.assertEquals(newCases.size(), 2, 'Wrong count of owned cases.');
		System.assertEquals(newCases[0].Id, case1.Id, 'Wrong owned case1.');
		System.assertEquals(newCases[1].Id, case2.Id, 'Wrong owned case2.');
    }

    static testMethod void getQueueIdByNameTest() {
    	String queueName = 'TestQueue1';
    	Group group1 = new Group(Name=queueName);
    	insert group1;
    	Group queue = new Group(Type='Queue', Name=queueName);
    	insert queue;
    	Group group2 = new Group(Name=queueName);
    	insert group2;
        String queueId = V1CaseCollector.getQueueIdByName(queueName);
        System.assertEquals(queueId, queue.Id, '"Queue ID doesn\'t set');
    }
}