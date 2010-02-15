@isTest
private class SyncScheduleTestSuite {

    static Integer countJobs() {
        return [SELECT count() FROM CronTrigger];
    }

    static testMethod void scheduleAndUnscheduleTest() {
        Integer x = countJobs();

        String id0 = SyncSchedule.addSchedule('testJob0', '1 1 1 * * ?');
        System.assert(id0 != null, 'Schedule 0 wasn\'t added.');
        System.assertEquals(x + 1, countJobs(), 'Wrong triggers count');

        String id1 = SyncSchedule.addSchedule();
        System.assert(id1 != null, 'Schedule 1 wasn\'t added.');
        System.assertEquals(x + 2, countJobs(), 'Wrong triggers count');

        System.assert(SyncSchedule.unschedule(id0), 'Job 0 wasn\'t unsheduled.');
        System.assertEquals(x + 1, countJobs(), 'Wrong triggers count');

        System.assert(SyncSchedule.unschedule(id1), 'Job 1 wasn\'t unsheduled.');
        System.assertEquals(x, countJobs(), 'Wrong triggers count');

        System.assert(!SyncSchedule.unschedule('Wrong ID'), 'Wrong Id was unsheduled.');
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