public class V1ConnectorMock implements IV1Connector {

    private String sourceId = '123456';
    private Exception ex;
    private Exception creationWorkitemException;
    private Exception createLinkException;
    public String createdWorkitemToken;
    private Map<String, Boolean> alreadyExistedDefects = new Map<String, Boolean>();
    private List<String> closedDefects = new List<String>();
    private Exception removeLinkFromDefectException;
    private Exception updateReferenceForDefectException;
    private Exception searchForDefectsException;

    public static final String defaultProjectId = '1010';
    public static final String developmentStatus = 'In Progress';
    
    public DefectSearchCriteria defectSearchCriteria { get; private set; }

    public Defect getDefectById(String id) {
        Defect defectData = new Defect('title', 'description');
        defectData.id = id;
        defectData.status = developmentStatus;

        return defectData;
    }

	public List<Defect> searchDefects(String find, Boolean isLookingInClosed) {
		defectSearchCriteria = new DefectSearchCriteria();
		defectSearchCriteria.queryString = find;
		defectSearchCriteria.includeClosedDefects = isLookingInClosed;
		
		if(searchForDefectsException != null) {
			throw searchForDefectsException;
		} 
		
		return null;
	}
	
	public void setSearchForDefectsException(Exception ex) {
		searchForDefectsException = ex;
	}

    public void removeLinkFromDefect(String defectId) {
        throwException();
        if (removeLinkFromDefectException != null) {
            throw removeLinkFromDefectException;
        }
    }

    public void setRemoveLinkFromDefectException(Exception ex) {
        removeLinkFromDefectException = ex;
    }

    public void updateReferenceForDefect(String defectId, String referenceValue) {
        throwException();
        if (updateReferenceForDefectException != null) {
            throw updateReferenceForDefectException;
        }
    }

    public void setUpdateReferenceForDefectException(Exception ex) {
        updateReferenceForDefectException = ex;
    }

    public String getSourceId() {
        throwException();
        return sourceId;
    }

    public void setTestSourceId(String sourceId) {
        this.sourceId = sourceId;
    }

    public Map<String, String> findAllProjects() {
        throwException();
        Map<String, String> result = new Map<String, String>();
        result.put('Scope:1081', 'CI');
        result.put(defaultProjectId, 'Main project');

        return result;
    }

    public String getDefaultProjectId() {
        return defaultProjectId;
    }

    public void createLinkV1ToSF(String defectId, Case caseData) {
        if (createLinkException != null) {
            throw createLinkException;
        }
    }

    public void setExceptionForLinkCreationInV1(Exception ex) {
        createLinkException = ex;
    }

    public String createWorkitemInV1(Case caseData, Defect defectData) {
        if (creationWorkitemException != null) {
            throw creationWorkitemException;
        }
        return createdWorkitemToken;
    }

    public void setCreatedWorkitemToken(String token) {
        createdWorkitemToken = token;
    }

    public void setExceptionForCreationWorkitemInV1(Exception ex) {
        creationWorkitemException = ex;
    }

    public Settings getSettings() {
        return Settings.getTestSettings();
    }

    /**
     * Enables exception throwing on next calls of any methods.
     */
    public void enableException(Exception ex) {
        this.ex = ex;
    }

    private void throwException() {
        if (ex != null) {
            throw ex;
        }
    }
}