trigger CaseUpdaterTrigger on Case (after update) {
	//List<Case> cases = new List<Case>();
	//Settings settings = new Settings();
	/*
    for (Case updatedCase : Trigger.new) {
        System.debug('Case name:' + updatedCase.Subject);
        System.debug('Case owner id:' + updatedCase.OwnerId);
        System.debug('Case product:' + updatedCase.Product__c);

		//Prefix User: 005
		//Prefix Group (Queue): 00G
		String ownerId = String.valueOf(updatedCase.OwnerId);
        if (ownerId.startsWith('00G') && ownerId.equals(settings.getEscalateQueueId())) {
		//user owner = [SELECT ID, username FROM User WHERE ID:=createdCase.OwnerId];
			//String ownerString = 'SELECT ID, Name FROM Group WHERE ID=\''+ownerId+'\'' ;
        	//Group owner = (Group) Database.query(ownerString);
        	//System.debug('Case owner:' + owner.Name);
        	cases.add(updatedCase);
        }
    }
	*/
	//V1Publisher publisher = new V1Publisher(cases);

	String srcQueue = V1CaseCollector.getQueueIdByName('Escalate to VersionOne');
	if (V1CaseCollector.countCasesWithOwnerId(srcQueue) > 0){
		V1Publisher.publish();
	}
}