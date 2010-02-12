global public class SyncSchedule implements Schedulable {

    public static final Integer MAX_COUNT = 10;
    public static final String CRON_EXP = '0 0 0 * * ?';
    public static final String JOB_NAME = 'Sync with VersionOne Job';

    global void execute(SchedulableContext sc) {
        Settings settings = new Settings();
        (new Syncronizer(settings, new Requestor(settings))).syncCases();
    }

    public static String schedule(Integer countPerDay) {
        unscheduleAll();
        System.assert(countPerDay <= MAX_COUNT);
        //TODO
        return null;
    }

    public static String schedule() {
        unscheduleAll();
        return addSchedule(JOB_NAME, CRON_EXP);
    }

    public static String addSchedule(String name, String cronExp) {
        Schedulable job = new SyncSchedule();
        return System.schedule(name, cronExp, job);
    }

    public static Boolean unschedule(String id) {
        try {
            System.abortJob(id);
            return true;
        } catch (Exception e) {
            System.debug('Cannot abort job: ' + id + '\n  ' + e);
            return false;
        }
    }

    public static Integer unscheduleAll() {
        Integer res = 0;
        CronTrigger[] triggers = [SELECT Id FROM CronTrigger];
        for (CronTrigger tr: triggers){
            if (unschedule(tr.Id)) {
                res++;
            }
        }
        return res;
    }
}