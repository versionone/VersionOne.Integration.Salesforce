public interface IV1Connector {
    /**
    * Makes request to the VersionOne and get specify defect.
    * defectId  - defect id in the VersionOne
    * Returns: Defect with information from VersionOne.
    **/
    Defect getDefectById(String defectId);

    /**
    * Searches defects in the VersionOne by specify string.
    * find 					- string for searching.
    * isLookingInClosed 	- need to include closed defects in result.
    * fieldsForSearch		- field list where need to search specified text.
    **/
    List<Defect> searchDefects(String query, Boolean isLookingInClosed, String[] fieldsForSearch);

    /**
    * Removes link from defect in VersionOne if defect is not closed.
    * defectId  - defect id in the VersionOne.
    **/
	void removeLinkFromDefect(String defectId);

	/**
	* Updates reference for the defect.
	* defectId 			- defect id for updating.
	* referenceValue	- add this reference to defect reference.
	**/
	void updateReferenceForDefect(String defectId, String referenceValue);

	/**
	* Defect reference from the defect.
	* defectId 			 - defect id for updating.
	* caseNumberToDelete - remove this case number from the reference.
	**/
	void deleteReferenceInDefect(String defectId, String caseNumberToDelete);

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
    String createWorkitemInV1(Case caseData, Defect defectData, String projectId);

    /**
    * Returns current settings for connector.
    **/
    Settings getSettings();

    /**
    * Request information about closed defects since specified date,
    * dateData - since this date will be gathered all closed defects.
    * Return: defects which were closed since the date.
    **/
    List<Defect> getClosedDefects(DateTime dateData);
}