public class DefectFacade implements IDefectFacade {
	private IV1Connector connector;

	public DefectFacade(IV1Connector connector) {
		this.connector = connector;
	}

	public String createDefectInVersionOne(Case caseData, Defect defectData) {
        String id;
        id = connector.createWorkitemInV1(caseData, defectData);

        if (id != null) {
        	connector.createLinkV1ToSF(id, caseData);
        	assignDefectToCase(caseData, id);
        }

        return id;
	}

	public void assignDefectToCase(Case caseData, String defectId) {
    	V1CaseCollector.updateCase(caseData, defectId, true);
	}

	public void unassignDefectFromCase() {

	}
}