public class V1CaseCollector {

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

	/* Update cases: set Owner and custom field to the specified values. Create Comment with specified body.
	 * cases - list of cases to process.
	 * ownerId - ID of the owner to set to all cases.
	 * commentBody - text of comment body to attach to all cases.
	 * fieldName - name of custom field.
	 * fieldValues - list values to set to custom field. Must be same size as list of cases.
	 * 				 Each value set to apropriate case: case[i].<fieldName> = fieldValues[i].
	 */
	public static void updateCases(List<Case> cases, String ownerId, String commentBody,
								   String fieldName, List<Object> fieldValues) {
		List<CaseComment> comments = new List<CaseComment>();
		for (Integer i = 0; i < cases.size(); i++){
			Case c = cases[i];
			System.debug('BEFORE UPDATE: ' + c);
			c.OwnerId = ownerId;
			if (fieldValues[i] != null) {
				c.put(fieldName, fieldValues[i]);
			}
			comments.add(new CaseComment(CommentBody = commentBody, ParentId = c.Id));
			System.debug('AFTER CHANGE: ' + c);
		}
		Database.update(cases);
		insert comments;
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