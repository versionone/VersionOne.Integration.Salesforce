public interface IV1Connector {
    /**
    * Makes request to the VersionOne and get all closed defects.
    * Returns: list of CaseNumbers (references).
    **/
    List<String> getClosedWorkitems();

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
    * Creates defect or story in the VersionOne
    * caseData - SalesForce case
    * projectId - project id in the VersionOne
    * sourceId - source id in the VersionOne
    * Return: id of created workitem in the VersionOne
    **/
    Integer createWorkitemInV1(Case caseData, String projectId);

    /**
    * Gathers all already ported cases
    * cases - list of cases which need to test on existence in the VersionOne
    * Returns: List of correspond defects id, already exited in the VersionOne
    **/
    Map<String, Boolean> getReferencedWorkitems(List<Case> cases);

    /**
    * Returns current settings for connector
    **/
    Settings getSettings();
}