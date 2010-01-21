public class V1CaseCollector {

	public static List<Case> getCasesForV1() {
		Group srcQueue = getQueueByName('Escalate to VersionOne');
		if (srcQueue == null){
			return null;
		}
		List<Case> cases = [select id, OwnerId from Case where OwnerId = :srcQueue.Id ];
		System.debug('	Found Cases: ' + cases.size());
		return cases;
	}

	public static void setCasesOwner(List<Case> cases, Group owner) {
		for (Case c : cases) {
			System.debug('BEFORE UPDATE: ' + c);
			c.OwnerId = owner.Id;
			System.debug('AFTER CHANGE: ' + c);
		}
		//update cases;
	}

	public static Group getQueueByName(String name) {
		Group queues = [select Id, Name, Type from Group where Type='Queue' and name = :name];
		System.debug('	Found Queue: ' + queues);
		return queues;
	}
}