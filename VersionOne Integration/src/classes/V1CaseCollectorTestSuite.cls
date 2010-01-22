@isTest
private class V1CaseCollectorTestSuite {

    static testMethod void getQueueIdByNameTest() {
    	String queueName = 'TestQueue1';
    	Group queue = new Group(Type='Queue', Name=queueName);
    	insert queue;
        String queueId = V1CaseCollector.getQueueIdByName(queueName);
        System.assertEquals(queueId, queue.Id);
    }
}