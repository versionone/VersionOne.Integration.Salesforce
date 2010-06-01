public class DefectController {
	private Case caseData;
	private Defect defect;
	public Boolean isEditForm {get; set;}

	public DefectController(ApexPages.StandardController stdController) {
		caseData = (Case)stdController.getRecord();
		defect = new Defect();
		System.debug(caseData);
	}

    public void init() {
    	isEditForm = false;
    }

    public PageReference showForm() {
    	isEditForm = true;
    	return null;
    }

    public PageReference cancelForm() {
    	isEditForm = false;
    	defect = new Defect();
    	return null;
    }

    public PageReference createDefect() {
    	addInfoMessage(defect.title + ' // ' + defect.description);
    	return null;
    }

	public String getCaseID() {
		return caseData.ID;
	}

	public Defect getDefect() {
		return defect;
	}

    private static void addInfoMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, text));
    }
}