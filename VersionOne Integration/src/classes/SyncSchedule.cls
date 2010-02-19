global public class SyncSchedule implements Schedulable {

    /** CRON expression for job: run every day in 0:00. */
    public static final String CRON_EXP = '0 0 0 * * ?';
    public static final String JOB_NAME = 'Sync with VersionOne Job';

    /** Periodicaly executed method. */
    global void execute(SchedulableContext sc) {
        Settings settings = new Settings();
        IV1Connector connector = new V1Connector(settings, new Requestor(settings));
        (new Synchronizer(settings, connector)).syncCases();
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

    /** Check if job with specified ID exists. */
    public static Boolean isScheduled(String id) {
        if (id == null){
            return false;
        }
        Integer count = [SELECT count() FROM CronTrigger WHERE id=:id];
        System.debug(id + ' count: ' + count);
        return count > 0;
    }
}