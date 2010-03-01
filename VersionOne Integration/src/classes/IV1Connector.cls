public interface IV1Connector {
    /**
    * Makes request to the VersionOne and get all closed defects.
    * Returns: list of CaseNumbers (references).
    **/
    List<String> getClosedDefects();

    /**
    * Returns: find and return id of current source(from Settings).
    **/
    String getSourceId();

    /**
    * Gather all project from the VersionOne.
    * Return: list of projects; key - name, value - id.
    **/
    Map<String, String> findAllProjects();

    /**
    * Return id of default project id, which will be used to assign defects if case has no prodoct
    **/
    String getDefaultProjectId();

    /**
    * Creates link to SalesForce web page with information about case
    * defectId  - defect id in the VersionOne
    * caseId	- case id in the SalesForce
    **/
    void createLinkV1ToSF(Integer defectId, String caseId);

    /**
    * Creates defect in the VersionOne
    * caseData - SalesForce case
    * productId - project id in the VersionOne
    * sourceId - source id in the VersionOne
    * Return: id of created defect in the VersionOne
    **/
    Integer createDefectInV1(Case caseData, String productId);

    /**
    * Gathers all already ported cases
    * cases - list of cases which need to test on existion in the VersionOne
    * Returns: List of correspond defects id, already exited in the VersionOne
    **/
    Map<String, Boolean> getAlreadyExistedDefects(List<Case> cases);

    /**
    * Returns current settings for connector
    **/
    Settings getSettings();
}