public class DefectFacadeMock implements IDefectFacade {

	public static final String CreatedDefectId = '2345';
	public static final String DefectTitle = 'Defect Title';
	public static final String DefectDescription = 'Defect Description';
	private static Exception createDefectInVersionOneException;

	public String createDefectInVersionOne(Case caseData, Defect defectData) {
		System.debug('createDefectInVersionOneException=' + createDefectInVersionOneException);
		if (createDefectInVersionOneException != null) {
			throw createDefectInVersionOneException;
		}
		return CreatedDefectId;
	}

	public void setCreateDefectInVersionOneException(Exception ex) {
		createDefectInVersionOneException = ex;
	}

	public void assignDefectToCase(Case caseData, String defectId, String devStatus) {
	}

	public void unassignDefectFromCase(Case caseData) {

	}

	public void publishStatus(Case caseData) {

	}


	public Defect getDefectById(String defectToken){
		Defect defectData = new Defect();
		defectData.id = CreatedDefectId;
		defectData.title = DefectTitle;
		defectData.description = DefectDescription;

		return defectData;
	}

}