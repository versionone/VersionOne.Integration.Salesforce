public class V1CaseCollector {

    /* Query case with specified case number.
     * caseNumbers - case number.
     * Return: found case.
     */
    public static Case getCaseByCaseNumber(String caseNumber) {
        return [SELECT id, CaseNumber, Description, Subject
                          FROM Case WHERE CaseNumber = :caseNumber];
    }

    /* Query case with specified case ID.
     * caseNumbers - case number.
     * Return: found case.
     */
    public static Case getCaseByCaseId(String caseID) {
        return [SELECT id, CaseNumber, Description, Subject, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c
                          FROM Case WHERE id = :caseID];
    }

	/**
	 * Update case.
	 * caseData 	- case which need to be updated.
	 * defectId 	- id of defect which was assigned for this case.
	 * assicuation	- was defect from VersionOne associated.
	 **/
    public static void updateCase(Case caseData, String defectId, Boolean association, String devStatus) {
    	caseData.V1DefectId__c = defectId;
    	caseData.V1Association__c = association;
    	caseData.V1DevelopmentStatus__c = devStatus;
    	update caseData;
	}

	/**
	 * Update developer status.
	 * caseData 	- case which need to be updated.
	 * status		- developer status.
	 **/
	public static void updateDeveloperStatus(Case caseData, String status) {
		caseData.V1DevelopmentStatus__c = status;
		update caseData;
	}

}