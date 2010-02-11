global public class SyncSchedule implements Schedulable {

    public static final String CRON_EXP = '0 0 0 * * ?';
    public static final String JOB_NAME = 'Sync with VersionOne Job';

    global void execute(SchedulableContext sc) {
    	Settings settings = new Settings();
        (new Syncronizer(settings, new Requestor(settings))).syncCases();
    }

    public static String schedule(Integer countPerDay) {
        System.assert(countPerDay < 10);
        //TODO
        return null;
    }

    public static String schedule() {
        return schedule(CRON_EXP);
    }

    public static String schedule(String cronExp) {
        Schedulable job = new SyncSchedule();
        return System.schedule(JOB_NAME, cronExp, job);
    }

    public static void unscheduleAll() {
        System.abortJob(JOB_NAME);
    }
}