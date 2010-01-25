public class V1CaseCollector {

	public static Case[] getCasesByOwnerId(String ownerId) {
		Case[] cases = [SELECT id, OwnerId, CaseNumber, Description, Product__c, Subject
						  FROM Case WHERE OwnerId = :ownerId ];
		System.debug('==> getCasesByOwnerId() found: ' + cases.size());
		return cases;
	}

	/* Set cases Owner to the specified value.
	 * cases - list of cases to process.
	 * ownerId - ID of the owner to set.
	 */
	public static void setCasesOwner(List<Case> cases, String ownerId) {
		for (Case c : cases) {
			System.debug('BEFORE UPDATE: ' + c);
			c.OwnerId = ownerId;
			System.debug('AFTER CHANGE: ' + c);
		}
		Database.update(cases);
	}

	/* Get Queue with specified Name.
	 * Return: queue ID.
	 */
	public static String getQueueIdByName(String name) {
		Group queue = [SELECT Id, Name, Type FROM Group WHERE Type='Queue' AND name = :name];
		System.debug('==> getQueueIdByName() ' + queue);
		return queue.Id;
	}
}