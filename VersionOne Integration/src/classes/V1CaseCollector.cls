public class V1CaseCollector {

    /* Query not closed cases with specified case number
     * caseNumbers - case number
     * Return: found case
     */
    public static Case getCaseByCaseNumber(String caseNumber) {
        return [SELECT id, CaseNumber, Description, Subject
                          FROM Case WHERE CaseNumber = :caseNumber and Status <> 'Closed'];
    }

}