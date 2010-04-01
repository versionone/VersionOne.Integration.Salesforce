trigger CaseUpdaterTrigger on Case (after update) {
    try {
		//Settings settings = new Settings();
    	//BatchTest batch = new BatchTest();
    	//ID batchprocessid = Database.executeBatch(batch);
        //V1Publisher.publish();
    } catch (System.AsyncException e) {}
}