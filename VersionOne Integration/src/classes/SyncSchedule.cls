global public class SyncSchedule implements Schedulable {

    public static final String CRON_EXP = '0 0 0 * * ?';

    global void execute(SchedulableContext sc) {
        (new Syncronizer()).syncCases();
    }

    public static void schedule() {
    	Schedulable job = new SyncSchedule();
        System.schedule('Sync with VersionOne Job', CRON_EXP, job);
    }
}