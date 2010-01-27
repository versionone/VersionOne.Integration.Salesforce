trigger CaseUpdaterTrigger on Case (after update) {
    try {
        V1Publisher.publish();
    } catch (System.AsyncException e) {}
}