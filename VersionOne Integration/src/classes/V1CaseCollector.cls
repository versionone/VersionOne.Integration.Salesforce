public class V1CaseCollector {

    /* Query not closed cases with specified owner.
     * ownerId - ID of an owner.
     * Return: Array of cases.
     */
    public static Case[] getCasesByOwnerId(String ownerId) {
        return getCasesByOwnerId(ownerId, false);
    }

    /* Query cases with specified owner.
     * ownerId - ID of an owner.
     * isClosed - is case closed.
     *			true  - gather only not closed cases
     *			false - gather only closed cases
     * Return: Array of cases.
     */
    public static Case[] getCasesByOwnerId(String ownerId, Boolean isClosed) {
        Case[] cases;
        if (isClosed) {
            cases = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject
                          FROM Case WHERE OwnerId = :ownerId and Status = 'Closed'];
        } else {
            cases = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject
                          FROM Case WHERE OwnerId = :ownerId and Status <> 'Closed'];
        }
        System.debug('==> getCasesByOwnerId() found: ' + cases.size());
        return cases;
    }

    /* Query not closed cases with specified case numbers and owner
     * caseNumbers - array of case numbers
     * ownerId - ID of an owner.
     * Return: Array of cases
     */
    public static Case[] getCasesByCaseNumbersAndOwnerId(List<String> caseNumbers, String ownerId) {
        return [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject
                          FROM Case WHERE CaseNumber in :caseNumbers and Status <> 'Closed' and OwnerId = :ownerId];
    }

    /* Update case: set Owner and VersionOneUrl to the specified values. Create Comment with specified body.
     * case - cases to process.
     * ownerId - ID of the owner to set to case.
     * commentBody - text of a comment to add to case. If null - comment will not be created.
     * v1Url - URL to set to VersionOneUrl field.
     */
    public static void updateCase(Case c, String ownerId, String commentBody, String v1Url) {
        System.debug('BEFORE CHANGE: ' + c);
        c.OwnerId = ownerId;
        c.VersionOneUrl__c = v1Url;
        System.debug('AFTER CHANGE: ' + c);
        update c;

        if (commentBody != null) {
            insert new CaseComment(CommentBody = commentBody, ParentId = c.Id);
        }
    }

    /*
     * Closes cases. Create comment with specified  body.
     * cases 		- list of cases to process.
     * commentBody	- text of comment body to attach to all cases. If null - no comments are created.
     */
    public static void closeCases(List<Case> cases, String commentBody) {
        for (Integer i = 0; i < cases.size(); i++){
            Case c = cases[i];
            System.debug('BEFORE CHANGE: ' + c);
            c.Status = 'Closed';
            System.debug('AFTER CHANGE: ' + c);
        }
        Database.update(cases);

        if (commentBody != null) {
            List<CaseComment> comments = new List<CaseComment>();
            for (Case c : cases) {
                comments.add(new CaseComment(CommentBody = commentBody, ParentId = c.Id));
            }
            insert comments;
        }
    }


    /* Get Queue with specified Name.
     * Return: queue ID.
     */
    public static String getQueueIdByName(String name) {
        Group queue = [SELECT Id, Name, Type FROM Group WHERE Type='Queue' AND name = :name];
        System.debug('==> getQueueIdByName() ' + queue);
        return queue.Id;
    }

    /* Get all Queues in a system.
     * Return: array of queues.
     */
    public static Group[] getQueuesList() {
        Group[] queues = [SELECT Id, Name, Type FROM Group WHERE Type='Queue'];
        System.debug('==> getQueuesList() ' + queues);
        return queues;
    }
}