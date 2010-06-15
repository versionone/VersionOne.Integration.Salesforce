public interface IV1Connector {
    /**
    * Makes request to the VersionOne and get specify defect.
    * defectId  - defect id in the VersionOne
    * Returns: Defect with information from VersionOne.
    **/
    Defect getDefectById(String defectId);

    /**
    * Removes link from defect in VersionOne if defect is not closed.
    * defectId  - defect id in the VersionOne.
    **/
	void removeLinkFromDefect(String defectId);

	/**
	* Updates reference for the defect.
	* defectId - defect id for updating.
	**/
	void updateReferenceForDefect(String defectId);

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
    * Return id of default project id, which will be used to assign defects if case has no prodoct.
    **/
    String getDefaultProjectId();

    /**
    * Creates link to SalesForce web page with information about case.
    * defectId  - defect id in the VersionOne.
    * caseData	- case to create link to.
    **/
    void createLinkV1ToSF(String workitemId, Case caseData);

    /**
    * Creates defect or story in the VersionOne.
    * caseData - SalesForce case.
    * projectId - project id in the VersionOne.
    * sourceId - source id in the VersionOne.
    * Return: id of created workitem in the VersionOne.
    **/
    String createWorkitemInV1(Case caseData, Defect defectData);

    /**
    * Returns current settings for connector.
    **/
    Settings getSettings();
}