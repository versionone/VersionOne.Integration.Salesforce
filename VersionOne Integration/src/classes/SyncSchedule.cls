global public class SyncSchedule implements Schedulable {

    /** CRON expression for job: run every day in 0:00. */
    public static final String CRON_EXP = '0 0 0 * * ?';
    public static final String JOB_NAME = 'Sync with VersionOne Job';

    /** Periodicaly executed method. */
    global void execute(SchedulableContext sc) {
        Settings settings = new Settings();
        (new Syncronizer(settings, new Requestor(settings))).syncCases();
    }

    /**
     * Add dayly schedule with standard name.
     *
     * Return: job ID.
     * Throws: Exceprion on fail.
     */
    public static String addSchedule() {
        return addSchedule(JOB_NAME, CRON_EXP);
    }

    /**
     * Add schedule with specified name and CRON expression.
     *
     * Returns: job ID.
     * Throws: Exceprion on fail.
     */
    public static String addSchedule(String name, String cronExp) {
        Schedulable job = new SyncSchedule();
        return System.schedule(name, cronExp, job);
    }

    /** Delete job with specified ID from schedule. */
    public static Boolean unschedule(String id) {
        try {
            System.abortJob(id);
            return true;
        } catch (Exception e) {
            System.debug('Cannot abort job: ' + id + '\n  ' + e);
            return false;
        }
    }
}