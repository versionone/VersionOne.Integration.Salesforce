public class V1CaseCollector {

    /* Query not closed cases with specified owner which can be ported to the VersionOne.
     * cases aren't closed and isn't processing atm.
     * ownerId - ID of an owner.
     * Return: Array of cases.
     */
    public static Case[] getCasesByOwnerId(String ownerId) {
        return getCasesByOwnerId(ownerId, false);
    }

    /* Query cases with specified owner, and cases aren't processing atm.
     * ownerId - ID of an owner.
     * isClosed - is case closed.
     *			true  - gather only not closed cases
     *			false - gather only closed cases
     * Return: Array of cases.
     */
    public static Case[] getCasesByOwnerId(String ownerId, Boolean isClosed) {
        Case[] cases;
        if (isClosed) {
            cases = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, V1Processing__c
                          FROM Case WHERE OwnerId = :ownerId and Status = 'Closed' and V1Processing__c = false ];
        } else {
            cases = [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, V1Processing__c
                          FROM Case WHERE OwnerId = :ownerId and Status <> 'Closed' and V1Processing__c = false ];
        }
        System.debug('==> getCasesByOwnerId() found: ' + cases.size());
        return cases;
    }

    /**
     * Query cases with specified owners, with any status of processing and not closed.
     * ownerId - ID list of owners.
     **/
    public static Case[] getCasesByOwners(List<String> ownerId) {
        return [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, V1Processing__c
                          FROM Case WHERE OwnerId in :ownerId and Status <> 'Closed'];
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

    /* Query not closed cases with specified case number
     * caseNumbers - case number
     * Return: found case
     */
    public static Case getCaseByCaseNumber(String caseNumber) {
        return [SELECT id, OwnerId, CaseNumber, Description, VersionOneProject__c, Subject, VersionOneUrl__c, V1Processing__c
                          FROM Case WHERE CaseNumber = :caseNumber and Status <> 'Closed'];
    }

    /* Update case: set Owner and VersionOneUrl to the specified values. Create Comment with specified body.
     * case - case to process.
     * ownerId - ID of the owner to set to case.
     * commentBody - text of a comment to add to case. If null - comment will not be created.
     * v1Url - URL to set to VersionOneUrl field.
     */
    public static void updateCase(Case c, String ownerId, String commentBody, String v1Url, Boolean isProcessing) {
        System.debug('BEFORE CHANGE: ' + c);
        c.OwnerId = ownerId;
        c.VersionOneUrl__c = v1Url;
        c.V1Processing__c = isProcessing;
        System.debug('AFTER CHANGE: ' + c);
        update c;

        if (commentBody != null) {
            System.debug('Add new comment: ' + commentBody + ' for ' + c.Id + ' case');
            insert new CaseComment(CommentBody = commentBody, ParentId = c.Id);
        }
    }

    /**
     * Update case: set VersionOneUrl custom field to specified value.
     * case  - case to process
     * v1Url - URL to set to VersionOneUrl field.
     **/
    public static void updateUrlToVersionOneInCase(Case c, String v1Url) {
        System.debug('BEFORE CHANGE: ' + c);
        c.VersionOneUrl__c = v1Url;
        System.debug('AFTER CHANGE: ' + c);
        update c;
    }

    /**
     *
     *
     **/
    public static void updateProcessInVersionOneInCase(List<Case> cases, boolean isProcess) {
        for (Case c : cases) {
            System.debug('BEFORE CHANGE: ' + c);
            c.V1Processing__c = isProcess;
            System.debug('AFTER CHANGE: ' + c);
        }
        Database.update(cases);
    }

    /*
     * Closes cases. Create comment with specified  body.
     * cases 		- list of cases to process.
     * commentBody	- text of comment body to attach to all cases. If null - no comments are created.
     */
    public static void closeCases(List<Case> cases, String commentBody) {
        for (Case c : cases){
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