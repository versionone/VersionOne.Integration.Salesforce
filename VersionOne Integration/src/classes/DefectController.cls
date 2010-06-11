public class DefectController {
	private Case caseData;
	private Defect defect;
	public Boolean isEditForm {set;get; }
	public Boolean areThereErrors {set;get;}

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

	private transient IDefectFacade innerDefectFacade;
	public IDefectFacade defectFacade {
        get {
            if (innerDefectFacade == null) {
                innerDefectFacade = new DefectFacade(new V1Connector(settings, new Requestor(settings)));
            }
            return innerDefectFacade;
        }
        set {
            innerDefectFacade = value;
        }
	}

    public DefectController(Case c) {
		init(c.ID);
    }


	public DefectController(ApexPages.StandardController stdController) {
		init(stdController.getRecord().ID);
	}

    public void init(String id) {
		caseData = V1CaseCollector.getCaseByCaseId(id);
		defect = getDefeaultDefectData();
		isEditForm = false;
		areThereErrors = false;
    }

    public PageReference showForm() {
    	areThereErrors = false;
    	isEditForm = true;
    	return null;
    }

    public PageReference cancelForm() {
    	isEditForm = false;
    	defect = getDefeaultDefectData();
    	return null;
    }

    public PageReference refreshWidow() {
    	isEditForm = false;
    	areThereErrors = false;
    	return null;
    }

    public PageReference createDefect() {
    	String id;
    	//PageReference currentPage = ApexPages.currentPage();

    	areThereErrors = false;
    	try {
    		id = defectFacade.createDefectInVersionOne(caseData, defect);
			defect.project = settings.getProjectName();
			defect.isClosed = false;
			defect.id = id;
			isEditForm = false;
    	} catch (IntegrationException ex) {
    		System.debug('ex=' + ex);
			addErrorMessage(ex.getMessage());

    	}
    	//addInfoMessage(defect.title + ' // ' + defect.description);

		//return currentPage;
		return null;
    }

	public Boolean getIsDefectAssigned() {
		System.debug('caseData.V1DefectId__c=' + caseData.V1DefectId__c);
		System.debug('caseData.V1Association__c=' + caseData.V1Association__c);
		return (caseData.V1DefectId__c != '' && caseData.V1DefectId__c != null) && caseData.V1Association__c && !areThereErrors;
	}

	public Defect getCreatingDefect() {
		return defect;
	}

	public Defect getAssignedDefect() {
		if (!getIsDefectAssigned()) {
			return null;
		}
		Defect assignedDefect;

		System.debug('****defect=' + defect);
		System.debug('****defectId=' + caseData.V1DefectId__c);

		if (defect != null && defect.id == caseData.V1DefectId__c) {
			assignedDefect = defect;
		} else {
			try {
				assignedDefect = defectFacade.getDefectById(caseData.V1DefectId__c);
			} catch(Exception ex) {
				addWarningMessage(ex.getMessage());
				//addErrorMessage(ex.getMessage());
			}
		}
		return assignedDefect;
	}

	public PageReference unassignDefect() {
		System.debug('**************unassignDefect');
		areThereErrors = false;
		try {
			defectFacade.unassignDefectFromCase(caseData);
		} catch (Exception ex) {
			addErrorMessage(ex.getMessage());
		}
		return null;
	}

	public PageReference publishStatus() {
		defectFacade.publishStatus(caseData);
		return null;
	}

    private void addErrorMessage(String text) {
    	areThereErrors = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, text));
    }

    private void addWarningMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, text));
    }


    private Defect getDefeaultDefectData() {
    	return new Defect(caseData.Subject, caseData.Description);
    }
}