public class V1ConnectorMock implements IV1Connector {
    public static final String CREATION_WORKITEM_EXCEPTION = 'creationWorkitemException';
    public static final String CREATION_LINK_EXCEPTION = 'createLinkException';
    public static final String REMOVING_LINK_FROM_DEFECT_EXCEPTION = 'removeLinkFromDefectException';
    public static final String UPDATING_REFERENCE_FOR_DEFECT_EXCEPTION = 'updateReferenceForDefectException';
    public static final String SEARCHING_FOR_DEFECTS_EXCEPTION = 'searchForDefectsException';
    public static final String DELETION_REFERENCE_IN_DEFECT_EXCEPTION = 'deleteReferenceInDefectException';
    public static final String GETTING_CASES_WITH_DEFECTS_EXCEPTION = 'gettingCasesWithDefectsException';
    private String sourceId = '123456';
    public static final String MEMBER_ID = '20';
    private Exception ex;
    public String createdWorkitemToken;
    private Map<String, Boolean> alreadyExistedDefects = new Map<String, Boolean>();
    private List<Defect> closedDefects = new List<Defect>();

    public final Map<String, Exception> exceptions = new Map<String, Exception>();
    private String[] fieldsForSearch;

    public static final String defaultProjectId = '1010';
    public static final String developmentStatus = 'In Progress';

    public DefectSearchCriteria defectSearchCriteria { get; private set; }
    public List<Defect> AssignedDefects {get; set;}

    public Defect getDefectById(String id) {
        Defect defectData = new Defect('title', 'description');
        defectData.id = id;
        defectData.status = developmentStatus;

        return defectData;
    }

    public List<Defect> searchDefects(String query, Boolean isLookingInClosed, String[] fieldsForSearch) {
        defectSearchCriteria = new DefectSearchCriteria();
        defectSearchCriteria.queryString = query;
        defectSearchCriteria.includeClosedDefects = isLookingInClosed;
        this.fieldsForSearch = fieldsForSearch;
        //defectSearchCriteria.searchIn = fieldsForSearch;

        if(exceptions.get(SEARCHING_FOR_DEFECTS_EXCEPTION) != null) {
            throw exceptions.get(SEARCHING_FOR_DEFECTS_EXCEPTION);
        }

        return null;
    }

    public String[] getFieldsForSearch() {
        return fieldsForSearch;
    }

    public void removeLinkFromDefect(String defectId, Case caseData) {
        throwException();
        if (exceptions.get(REMOVING_LINK_FROM_DEFECT_EXCEPTION) != null) {
            throw exceptions.get(REMOVING_LINK_FROM_DEFECT_EXCEPTION);
        }
    }

    public void updateReferenceForDefect(String defectId, String referenceValue) {
        throwException();
        if (exceptions.get(UPDATING_REFERENCE_FOR_DEFECT_EXCEPTION) != null) {
            throw exceptions.get(UPDATING_REFERENCE_FOR_DEFECT_EXCEPTION);
        }
    }

    public void deleteReferenceInDefect(String defectId, String caseNumberToDelete) {
        throwException();
        if (exceptions.get(DELETION_REFERENCE_IN_DEFECT_EXCEPTION) != null) {
            throw exceptions.get(DELETION_REFERENCE_IN_DEFECT_EXCEPTION);
        }
    }

    public String getSourceId() {
        throwException();
        return sourceId;
    }

    public void setTestSourceId(String sourceId) {
        this.sourceId = sourceId;
    }

    public String getCurrentMemberId() {
        throwException();

        return MEMBER_ID;
    }

    public Map<String, String> findAllProjects() {
        throwException();
        Map<String, String> result = new Map<String, String>();
        result.put('Scope:1081', 'CI');
        result.put('Scope:' + defaultProjectId, 'Main project');

        return result;
    }

    public String getDefaultProjectId() {
        return defaultProjectId;
    }

    public void createLinkV1ToSF(String defectId, Case caseData) {
        if (exceptions.get(CREATION_LINK_EXCEPTION) != null) {
            throw exceptions.get(CREATION_LINK_EXCEPTION);
        }
    }

    public String createWorkitemInV1(Case caseData, Defect defectData, String projectId) {
        if (exceptions.get(CREATION_WORKITEM_EXCEPTION) != null) {
            throw exceptions.get(CREATION_WORKITEM_EXCEPTION);
        }

        defectData.project = projectId;
        return createdWorkitemToken;
    }

    public void setCreatedWorkitemToken(String token) {
        createdWorkitemToken = token;
    }
    public Settings getSettings() {
        return Settings.getTestSettings();
    }

    public List<Defect> getAssignedDefects(Case[] cases, Boolean isClosedDefects) {
        if (exceptions.get(GETTING_CASES_WITH_DEFECTS_EXCEPTION) != null) {
            throw exceptions.get(GETTING_CASES_WITH_DEFECTS_EXCEPTION);
        }
        return AssignedDefects;
    }


    /**
     * Enables exception throwing on next calls of any methods.
     */
    public void enableException(Exception ex) {
        this.ex = ex;
    }

    public void addException(String name, Exception ex) {
        exceptions.put(name, ex);
    }

    private void throwException() {
        if (ex != null) {
            throw ex;
        }
    }
}