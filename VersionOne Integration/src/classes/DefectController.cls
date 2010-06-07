public class DefectController {
	private Case caseData;
	private Defect defect;
	public Boolean isEditForm {set;get; }

	private transient Settings innerSettings;
    public Settings settings {
        get {
            if (innerSettings == null) {
                innerSettings = new Settings();
            }
            return innerSettings;
        }
        set {
        	innerSettings = value;
        }
	}

    private transient IV1Connector innerConnector;
    public IV1Connector connector {
        get {
            if (innerConnector == null) {
                innerConnector = new V1Connector(settings, new Requestor(settings));
            }
            return innerConnector;
        }
        set {
            innerConnector = value;
        }
	}

	public DefectController(ApexPages.StandardController stdController) {
		caseData = V1CaseCollector.getCaseByCaseId(stdController.getRecord().ID);
		defect = getDefeaultDefectData();
		System.debug(caseData);
		isEditForm = false;
	}

    public void init() {
    }

    public PageReference showForm() {
    	isEditForm = true;
    	return null;
    }

    public PageReference cancelForm() {
    	isEditForm = false;
    	defect = getDefeaultDefectData();
    	return null;
    }

    public PageReference createDefect() {
		defect.project = settings.getProjectName();
		defect.isClosed = false;
    	String id = createDataInVersionOne(caseData);
		defect.id = id;
    	V1CaseCollector.updateCase(caseData, id, true);
    	//addInfoMessage(defect.title + ' // ' + defect.description);
    	isEditForm = false;

		return ApexPages.currentPage();
    }

	public Boolean getIsDefectAssigned() {
		System.debug('caseData.V1DefectId__c=' + caseData.V1DefectId__c);
		System.debug('caseData.V1Association__c=' + caseData.V1Association__c);
		return (caseData.V1DefectId__c != '' && caseData.V1DefectId__c != null) && caseData.V1Association__c;
	}

	public Defect getCreatingDefect() {
		return defect;
	}

	public Defect getAssignedDefect() {
		if (!getIsDefectAssigned()) {
			return null;
		}


		System.debug('****defect=' + defect);
		System.debug('****defectId=' + caseData.V1DefectId__c);

		if (defect != null && defect.id == caseData.V1DefectId__c) {
			return defect;
		} else {
			return connector.getDefectById(caseData.V1DefectId__c.split(':')[1]);
		}

	}

    /** return id created woritem or null in case any errors */
    public String createDataInVersionOne(Case caseData) {
        String id;
        try {
            id = connector.createWorkitemInV1(caseData, defect);
        } catch (Exception ex) {
        }
        if (id != null) {
        	connector.createLinkV1ToSF(id, caseData);
        }
        return id;
    }

    private static void addInfoMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, text));
    }

    private Defect getDefeaultDefectData() {
    	return new Defect(caseData.Subject, caseData.Description);
    }
}