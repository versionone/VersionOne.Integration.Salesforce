public class V1CaseCollector {

    /* Query case with specified case number.
     * caseNumbers - case number.
     * Return: found case.
     */
    public static Case getCaseByCaseNumber(String caseNumber) {
        return [SELECT id, CaseNumber, Description, Subject, Product__c
                          FROM Case WHERE CaseNumber = :caseNumber];
    }

    /* Query case with specified case ID.
     * caseNumbers - case id.
     * Return: found case.
     */
    public static Case getCaseByCaseId(String caseID) {
        return [SELECT id, CaseNumber, Description, Subject, Product__c, V1Association__c, V1DefectId__c, V1DevelopmentStatus__c
                          FROM Case WHERE id = :caseID];
    }

    /* Query cases with specified case IDs.
     * caseNumbers - collection of cases number.
     * Return: found cases.
     */
    public static Case[] getCasesByCasesNumber(String[] casesNumber) {
        return [SELECT id, CaseNumber FROM Case WHERE CaseNumber in :casesNumber];
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

    /**
     * Returns all mapping VersionOne projects to the SalesForce products.
     **/
    public static List<MappingV1ProjectsToSFProducts__c> getMappingList() {
        return [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c, V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c];
    }

    /**
     * Get mapping for the Case
     */
    public static MappingV1ProjectsToSFProducts__c getProductToProjectMappingForCase(Case caseValue) {
    	List<MappingV1ProjectsToSFProducts__c> mappings = [SELECT Id, SFProductId__c, SFProductName__c, V1ProjectToken__c,
    	                                                   V1ProjectName__c FROM MappingV1ProjectsToSFProducts__c
    	                                                   WHERE SFProductId__c = :caseValue.Product__c];
    	return mappings.size() > 0 ? mappings[0] : null;
    }

    /**
     * Adds new mapping to the SalesForce store(custom object).
     * mapping - information about mapping.
     **/
    public static void addNewMapping(ProjectProductMapping mapping) {
        MappingV1ProjectsToSFProducts__c mappingData = new MappingV1ProjectsToSFProducts__c();
        mappingData.SFProductId__c = mapping.productId;
        mappingData.SFProductName__c = mapping.productName;
        mappingData.V1ProjectToken__c = mapping.projectToken;
        mappingData.V1ProjectName__c = mapping.projectName;
        insert mappingData;
    }

    /**
     * Removes infoemation about mapping.
     * mappingId - mapping id which need to delete.
     **/
    public static void deleteMapping(String mappingId) {
        List<MappingV1ProjectsToSFProducts__c> mappings = [select Id from MappingV1ProjectsToSFProducts__c where id=:mappingId];
        delete mappings;
    }

    /**
     * Updates mapping data.
     * mappingId 	- mapping id which need to update.
     * mapping 		- data about mapping for updating
     **/
    public static void updateMapping(String mappingId, ProjectProductMapping mapping) {
        MappingV1ProjectsToSFProducts__c mappingData = [select Id from MappingV1ProjectsToSFProducts__c where id=:mappingId];
        mappingData.SFProductId__c = mapping.productId;
        mappingData.SFProductName__c = mapping.productName;
        mappingData.V1ProjectToken__c = mapping.projectToken;
        mappingData.V1ProjectName__c = mapping.projectName;
        update mappingData;
    }
}