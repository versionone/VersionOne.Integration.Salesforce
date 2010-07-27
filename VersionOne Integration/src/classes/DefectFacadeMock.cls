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

    public AssignDefectPassedData assignDefectResultValue { get; private set; }

    public List<Defect> foundDefects { get; set; }
    public List<Defect> closedDefects { get; set; }

    public List<V1FieldData> getFieldsData() {
        return new List<V1FieldData>();
    }

    public String createDefectInVersionOne(Case caseData, Defect defectData) {
        System.debug('createDefectInVersionOneException=' + exceptions.get('createDefectInVersionOneException'));
        if (exceptions.get('createDefectInVersionOneException') != null) {
            throw exceptions.get('createDefectInVersionOneException');
        }
        return CreatedDefectToken;
    }

    public List<Defect> searchForDefects(DefectSearchCriteria searchCriteria) {
        if(exceptions.get('searchException') != null) {
            throw exceptions.get('searchException');
        }

        return foundDefects;
    }
/*
    public void setSearchException(Exception ex) {
        exceptions.put('searchException', ex);
    }


    public void setCreateDefectInVersionOneException(Exception ex) {
    	exceptions.put('createDefectInVersionOneException', ex);
    }
    */
    public void assignDefectToCase(Case caseData, Defect defectData) {
        assignDefectResultValue = new AssignDefectPassedData(caseData, defectData);

        if(exceptions.get('assignDefectToCaseException') != null) {
            throw exceptions.get('assignDefectToCaseException');
        }
    }

    public void unassignDefectFromCase(Case caseData) {
        assignDefectResultValue = new AssignDefectPassedData(caseData, null);

        if (exceptions.get('unassignDefectFromCaseException') != null) {
            throw exceptions.get('unassignDefectFromCaseException');
        }
    }
/*
    public void setAssignDefectToCaseException(Exception ex) {
        exceptions.put('assignDefectToCaseException', ex);
    }

    public void setUnassignDefectFromCaseException(Exception ex) {
    	exceptions.put('unassignDefectFromCaseException', ex);
    }
*/
    public void publishStatus(Case caseData) {
        if (exceptions.get('publishStatusException') != null) {
            throw exceptions.get('publishStatusException');
        }
    }
/*
    public void setPublishStatusException(Exception ex) {
    	exceptions.put('publishStatusException', ex);
    }
*/

    public Defect getDefectByToken(String defectToken){
        if (exceptions.get('defectByIdException') != null) {
            throw exceptions.get('defectByIdException');
        }
        Defect defectData = new Defect('title', 'description');
        defectData.id = CreatedDefectToken;
        defectData.title = DefectTitle;
        defectData.token = defectToken;
        defectData.description = DefectDescription;

        return defectData;
    }
/*
    public void setGetDefectByIdException(Exception ex) {
    	exceptions.put('defectByIdException', ex);
    }
*/

	public List<Defect> getClosedDefects(String dateString) {
		return closedDefects;
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