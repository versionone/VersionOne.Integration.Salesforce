public class DefectFacadeMock implements IDefectFacade {

    public static final String CreatedDefectToken = 'Defect:2345';
    public static final String DefectTitle = 'Defect Title';
    public static final String DefectDescription = 'Defect Description';
    private final List<ClosedDefect> closedDefects = new List<ClosedDefect>();
    private static Exception createDefectInVersionOneException;
    private static Exception defectByIdException;
    private static Exception assignDefectToCaseException;
    private static Exception unassignDefectFromCaseException;
    private static Exception publishStatusException;
    private static Exception searchException;

    public AssignDefectPassedData assignDefectResultValue { get; private set; }

    public List<Defect> foundDefects { get; set; }

    public List<V1FieldData> getFieldsData() {
        return new List<V1FieldData>();
    }

    public String createDefectInVersionOne(Case caseData, Defect defectData) {
        System.debug('createDefectInVersionOneException=' + createDefectInVersionOneException);
        if (createDefectInVersionOneException != null) {
            throw createDefectInVersionOneException;
        }
        return CreatedDefectToken;
    }

    public List<Defect> searchForDefects(DefectSearchCriteria searchCriteria) {
        if(searchException != null) {
            throw searchException;
        }

        return foundDefects;
    }

    public void setSearchException(Exception ex) {
        searchException = ex;
    }

    public void setCreateDefectInVersionOneException(Exception ex) {
        createDefectInVersionOneException = ex;
    }

    public void assignDefectToCase(Case caseData, Defect defectData) {
        assignDefectResultValue = new AssignDefectPassedData(caseData, defectData);

        if(assignDefectToCaseException != null) {
            throw assignDefectToCaseException;
        }
    }

    public void unassignDefectFromCase(Case caseData) {
        assignDefectResultValue = new AssignDefectPassedData(caseData, null);

        if (unassignDefectFromCaseException != null) {
            throw unassignDefectFromCaseException;
        }
    }

    public void setAssignDefectToCaseException(Exception ex) {
        assignDefectToCaseException = ex;
    }

    public void setUnassignDefectFromCaseException(Exception ex) {
        unassignDefectFromCaseException = ex;
    }

    public void publishStatus(Case caseData) {
        if (publishStatusException != null) {
            throw publishStatusException;
        }
    }

    public void setPublishStatusException(Exception ex) {
        publishStatusException = ex;
    }


    public Defect getDefectByToken(String defectToken){
        if (defectByIdException != null) {
            throw defectByIdException;
        }
        Defect defectData = new Defect('title', 'description');
        defectData.id = CreatedDefectToken;
        defectData.title = DefectTitle;
        defectData.token = defectToken;
        defectData.description = DefectDescription;

        return defectData;
    }

    public void setGetDefectByIdException(Exception ex) {
        defectByIdException = ex;
    }

	public List<ClosedDefect> getClosedDefects(String dateString) {
		return closedDefects;
	}

    public class AssignDefectPassedData {
        public Case caseValue { get; private set; }
        public Defect defectValue { get; private set; }

        public AssignDefectPassedData(Case caseValue, Defect defectValue) {
            this.caseValue = caseValue;
            this.defectValue = defectValue;
        }
    }

 }