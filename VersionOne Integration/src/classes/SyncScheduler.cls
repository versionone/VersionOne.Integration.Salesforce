global public class SyncScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        (new Syncronizer()).syncCases();
    }
}