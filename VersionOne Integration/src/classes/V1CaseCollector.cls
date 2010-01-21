public class V1CaseCollector {


	public static Integer countCasesWithOwnerId(String ownerId) {
		Integer count = [SELECT count() FROM Case WHERE OwnerId = :ownerId ];
		System.debug('==> countCasesWithOwnerId() found: ' + count);
		return count;
	}

	public static Case[] getCasesByOwnerId(String ownerId) {
		Case[] cases = [SELECT id, OwnerId FROM Case WHERE OwnerId = :ownerId ];
		System.debug('==> getCasesByOwnerId() found: ' + cases.size());
		return cases;
	}

	public static void setCasesOwner(List<Case> cases, String ownerId) {
		for (Case c : cases) {
			System.debug('BEFORE UPDATE: ' + c);
			c.OwnerId = ownerId;
			System.debug('AFTER CHANGE: ' + c);
		}
		//update cases;
		Database.update(cases);
	}

	public static String getQueueIdByName(String name) {
		Group queue = [SELECT Id, Name, Type FROM Group WHERE Type='Queue' AND name = :name];
		System.debug('==> getQueueIdByName() ' + queue);
		return queue.Id;
	}
}