global public class SyncSchedule implements Schedulable {

    public static final String CRON_EXP = '0 0 0 * * ?';

    global void execute(SchedulableContext sc) {
    	Settings settings = new Settings();
        (new Syncronizer(settings, new Requestor(settings))).syncCases();
    }

    public static void schedule() {
    	Schedulable job = new SyncSchedule();
        System.schedule('Sync with VersionOne Job', CRON_EXP, job);
    }
}