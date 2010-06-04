public class V1CaseCollector {

    /* Query case with specified case number
     * caseNumbers - case number
     * Return: found case
     */
    public static Case getCaseByCaseNumber(String caseNumber) {
        return [SELECT id, CaseNumber, Description, Subject
                          FROM Case WHERE CaseNumber = :caseNumber];
    }

    /* Query case with specified case ID
     * caseNumbers - case number
     * Return: found case
     */
    public static Case getCaseByCaseId(String caseID) {
        return [SELECT id, CaseNumber, Description, Subject, V1Association__c, V1DefectId__c
                          FROM Case WHERE id = :caseID];
    }

	/**
	 * Update case
	 * caseData 	- case which need to be updated
	 * defectId 	- id of defect which was assigned for this case
	 * assicuation	- was defect from VersionOne associated
	 **/
    public static void updateCase(Case caseData, String defectId, Boolean association) {
    	caseData.V1DefectId__c = defectId;
    	caseData.V1Association__c = association;
    	update caseData;
	}

}