public interface IDefectFacade {

	/**
	* Create defect in the VersionOne and assign it to a case in the SalesForce
	* caseData 		- case for assign
	* defectData 	- information about new defect
	* Returns id of created defect
	**/
	String createDefectInVersionOne(Case caseData, Defect defectData);

	/**
	* Assign defect in the VersionOne to case in the SalesForce
	* caseData 		- case for assign
	* defecId 		- defect id for assign
	* devStatus		- development status of defect
	**/
	void assignDefectToCase(Case caseData, String defectId, String devStatus);

	/**
	* Unsaaign a defect from the case. Also removes data from defect in the VersionOne
	* and information about defect from case in the SalesForce
	* caseData - case for removing assigned defect
	**/
	void unassignDefectFromCase(Case caseData);

	/**
	* Get status from the assigned defect and put it to the case
	* caseData 		- case for processing
	**/
	void publishStatus(Case caseData);

	/**
	* Get defect from the VersionOne by defect id
	* defectToken 	- defect token (for example Defect:1234)
	**/
	Defect getDefectById(String defectToken);

}