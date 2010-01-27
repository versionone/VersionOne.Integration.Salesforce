public class V1CaseCollector {

	private static final String DEFECT_URL = 'http://integdmz01/VersionOne/assetdetail.v1?oid=Defect%3a';

	/* Query cases with specified owner.
	 * ownerId - ID of an owner.
	 * Return: Array of cases.
	 */
	public static Case[] getCasesByOwnerId(String ownerId) {
		Case[] cases = [SELECT id, OwnerId, CaseNumber, Description, Product__c, Subject
						  FROM Case WHERE OwnerId = :ownerId];
		System.debug('==> getCasesByOwnerId() found: ' + cases.size());
		return cases;
	}

	/* Set cases Owner to the specified value.
	 * cases - list of cases to process.
	 * ownerId - ID of the owner to set.
	 */
	public static void setCasesOwnerAndUrls(List<Case> cases, String ownerId, List<Integer> ids) {
		//for (Case c : cases) {
		for (Integer i = 0; i<cases.size(); i++){
			Case c = cases[i];
			Integer id = ids[i];
			System.debug('BEFORE UPDATE: ' + c);
			c.OwnerId = ownerId;
			if (id != null) {
				c.put('VersionOneUrl__c', DEFECT_URL + id);
			}
			System.debug('AFTER CHANGE: ' + c);
		}
		Database.update(cases);
	}

	public static void setCasesField(List<Case> cases, String field, List<Object> value) {
		for (Case c : cases) {
			System.debug('BEFORE UPDATE: ' + c);
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