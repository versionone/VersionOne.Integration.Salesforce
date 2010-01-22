@isTest
private class V1CaseCollectorTestSuite {

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
		System.assert(case1.OwnerId == null, 'Case1 already owned by queue.');
		System.assert(case2.OwnerId == null, 'Case2 already owned by queue.');
		System.assert(case3.OwnerId == null, 'Case3 already owned by queue.');
    	V1CaseCollector.setCasesOwner(new Case[] {case1, case2}, queue.Id);

		System.assert(case1.OwnerId == queue.Id, 'Case1 Owner doesn\'t changed.');
		System.assert(case2.OwnerId == queue.Id, 'Case2 Owner doesn\'t changed.');
		System.assert(case3.OwnerId == null, 'Case3 Owner set by mistake.');
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