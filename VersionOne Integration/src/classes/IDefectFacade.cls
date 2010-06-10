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
	**/
	void assignDefectToCase(Case caseData, String defectId);

	/**
	* Unsaaign a defect from the case. Also removes data from defect in the VersionOne
	* and information about defect from case in the SalesForce
	* caseData - case for removing assigned defect
	**/
	void unassignDefectFromCase(Case caseData);

}