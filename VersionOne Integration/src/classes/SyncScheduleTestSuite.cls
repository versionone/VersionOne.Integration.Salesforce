@isTest
private class SyncScheduleTestSuite {

    static testMethod void scheduleTest() {
        //CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        SyncSchedule.schedule();
    }
}