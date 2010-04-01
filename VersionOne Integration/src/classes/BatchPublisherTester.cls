@isTest
private class BatchPublisherTester {

    static testMethod void calculateValueTest() {
    	Integer value1 = 13;
    	Integer value2 = 12;
    	Integer value3 = 1;
    	Integer value4 = 25;
        System.assertEquals(6, BatchPublisher.calculateValue(value1));
        System.assertEquals(6, BatchPublisher.calculateValue(value2));
        System.assertEquals(0, BatchPublisher.calculateValue(value3));
        System.assertEquals(12, BatchPublisher.calculateValue(value4));
    }

    static testMethod void getBatchDataWithIncorrectIdTest() {
    	Map<String, String> data = BatchPublisher.getBatchData('1234567');
    	System.assertEquals(null, data);
    }
}