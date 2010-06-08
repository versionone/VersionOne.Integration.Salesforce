public interface IDefectFacade {

	String createDefectInVersionOne(Case caseData, Defect defectData);

	void assignDefectToCase(Case caseData, String defectId);

	void unassignDefectFromCase();

}