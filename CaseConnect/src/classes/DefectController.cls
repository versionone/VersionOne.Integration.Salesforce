public with sharing class DefectController {
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
                innerDefectFacade = new DefectFacade(new V1Connector(settings, new Requestor(settings)), settings);
            }
            return innerDefectFacade;
        }
        set {
            innerDefectFacade = value;
        }
    }

    public DefectController(Case c) {
        this(c.ID);
    }

    public DefectController(ApexPages.StandardController stdController) {
        this(stdController.getRecord().ID);
    }

    private DefectController(String id) {
        caseData = V1CaseCollector.getCaseByCaseId(id);
        defect = getDefaultDefectData();
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
        defect = getDefaultDefectData();
        return null;
    }

    public PageReference refreshWidow() {
        isEditForm = false;
        areThereErrors = false;
        return null;
    }

    public PageReference createDefect() {
        areThereErrors = false;
        try {
            String token = defectFacade.createDefectInVersionOne(caseData, defect);
            defect.token = token;
            if(token != null) {
                defect.id = token.split(':')[1];
            }
        } catch (IntegrationException ex) {
            System.debug('ex=' + ex);
            addErrorMessage(ex.getMessage());
        }

        defect.isClosed = false;
        isEditForm = false;
        return null;
    }

    public Boolean getIsDefectAssigned() {
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

        if (defect != null && defect.token == caseData.V1DefectId__c) {
            assignedDefect = defect;
        } else {
            try {
                assignedDefect = defectFacade.getDefectByToken(caseData.V1DefectId__c);
            } catch(Exception ex) {
                addWarningMessage(ex.getMessage());
            }
        }
        return assignedDefect;
    }

    public PageReference unassignDefect() {
        areThereErrors = false;
        try {
            defectFacade.unassignDefectFromCase(caseData);
        } catch (Exception ex) {
            addErrorMessage(ex.getMessage());
        }
        return null;
    }

    public PageReference publishStatus() {
    	try {
        	defectFacade.publishStatus(caseData);
    	} catch(Exception ex) {
			addWarningMessage(ex.getMessage());
        }
        return null;
    }

    private void addErrorMessage(String text) {
        areThereErrors = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, text));
    }

    private void addWarningMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, text));
    }

    private Defect getDefaultDefectData() {
        return new Defect(caseData.Subject, caseData.Description);
    }
}