@isTest
private class SyncScheduleTestSuite {

    static void checkJobsCount(Integer count) {
        List<CronTrigger> triggers = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assertEquals(count, triggers.size(), 'Wrong triggers count');
    }

    static testMethod void scheduleTest() {
        checkJobsCount(0);
        SyncSchedule.addSchedule('testJob0', '1 1 1 * * ?');
        checkJobsCount(1);
        String id1 = SyncSchedule.schedule();
        checkJobsCount(1);
        SyncSchedule.addSchedule('testJob1', '1 1 1 * * ?');
        checkJobsCount(2);
        SyncSchedule.addSchedule('testJob2', '2 2 2 * * ?');
        checkJobsCount(3);
        System.assert(SyncSchedule.unschedule(id1), 'Job wasn\'t unsheduled.');
        checkJobsCount(2);
        System.assertEquals(2, SyncSchedule.unscheduleAll(), 'Not all jobs was unsheduled.');
        checkJobsCount(0);
        System.assert(!SyncSchedule.unschedule(id1), 'Nonexising job cannot be unsheduled.');
    }
}
/*
CronTrigger fields:
endtime
cronexpression
previousfiretime
starttime
nextfiretime
state
createddate
timestriggered
ownerid
createdbyid
id
timezonesidkey
lastmodifiedbyid
*/