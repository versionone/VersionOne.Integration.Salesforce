public class DefectFacadeMock implements IDefectFacade {

    public static final String CreatedDefectToken = 'Defect:2345';
    public static final String DefectTitle = 'Defect Title';
    public static final String DefectDescription = 'Defect Description';

    private static final Map<String, Exception> exceptions = new Map<String, Exception>();
    public static final String CREATE_DEFECT_IN_V1_EXCEPTION = 'createDefectInVersionOneException';
    public static final String DEFECT_BY_ID_EXCEPTION = 'defectByIdException';
    public static final String ASSIGN_DEFECT_TO_CASE_EXCEPTION = 'assignDefectToCaseException';
    public static final String UNASSIGN_DEFECT_FROM_CASE_EXCEPTION = 'unassignDefectFromCaseException';
    public static final String PUBLISH_STATUS_EXCEPTION = 'publishStatusException';
    public static final String SEARCH_EXCEPTION = 'searchException';
    public static final String GETTING_CASES_WITH_DEFECT_EXCEPTION = 'getCasesWithDefects';

    public AssignDefectPassedData assignDefectResultValue { get; private set; }

    public List<Defect> foundDefects { get; set; }
    public List<DefectWrapper> casesWithDefects { get; set; }

    public List<V1FieldData> getFieldsData() {
        return new List<V1FieldData>();
    }

    public String createDefectInVersionOne(Case caseData, Defect defectData) {
        System.debug('createDefectInVersionOneException=' + exceptions.get(CREATE_DEFECT_IN_V1_EXCEPTION));
        if (exceptions.get(CREATE_DEFECT_IN_V1_EXCEPTION) != null) {
            throw exceptions.get(CREATE_DEFECT_IN_V1_EXCEPTION);
        }
        return CreatedDefectToken;
    }

    public List<Defect> searchForDefects(DefectSearchCriteria searchCriteria) {
        if(exceptions.get(SEARCH_EXCEPTION) != null) {
            throw exceptions.get(SEARCH_EXCEPTION);
        }

        return foundDefects;
    }

    public void assignDefectToCase(Case caseData, Defect defectData) {
        assignDefectResultValue = new AssignDefectPassedData(caseData, defectData);

        if(exceptions.get(ASSIGN_DEFECT_TO_CASE_EXCEPTION) != null) {
            throw exceptions.get(ASSIGN_DEFECT_TO_CASE_EXCEPTION);
        }
    }

    public void unassignDefectFromCase(Case caseData) {
        assignDefectResultValue = new AssignDefectPassedData(caseData, null);

        if (exceptions.get(UNASSIGN_DEFECT_FROM_CASE_EXCEPTION) != null) {
            throw exceptions.get(UNASSIGN_DEFECT_FROM_CASE_EXCEPTION);
        }
    }

    public void publishStatus(Case caseData) {
        if (exceptions.get(PUBLISH_STATUS_EXCEPTION) != null) {
            throw exceptions.get(PUBLISH_STATUS_EXCEPTION);
        }
    }

    public Defect getDefectByToken(String defectToken){
        if (exceptions.get(DEFECT_BY_ID_EXCEPTION) != null) {
            throw exceptions.get(DEFECT_BY_ID_EXCEPTION);
        }
        Defect defectData = new Defect('title', 'description');
        defectData.id = CreatedDefectToken;
        defectData.title = DefectTitle;
        defectData.token = defectToken;
        defectData.description = DefectDescription;

        return defectData;
    }

	public List<DefectWrapper> getCasesWithDefects(Boolean isShowAllCase, Boolean isClosedCases, Boolean isClosedDefects) {
        if(exceptions.get(GETTING_CASES_WITH_DEFECT_EXCEPTION) != null) {
            throw exceptions.get(GETTING_CASES_WITH_DEFECT_EXCEPTION);
        }
		return casesWithDefects;
	}

	public void addException(String name, Exception ex) {
		exceptions.put(name, ex);
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