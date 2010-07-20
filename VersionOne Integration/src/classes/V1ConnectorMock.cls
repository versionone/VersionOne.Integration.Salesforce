public class V1ConnectorMock implements IV1Connector {

    private String sourceId = '123456';
    private Exception ex;
    private Exception creationWorkitemException;
    private Exception createLinkException;
    public String createdWorkitemToken;
    private Map<String, Boolean> alreadyExistedDefects = new Map<String, Boolean>();
    private List<Defect> closedDefects = new List<Defect>();
    private Exception removeLinkFromDefectException;
    private Exception updateReferenceForDefectException;
    private Exception searchForDefectsException;
    private String[] fieldsForSearch;

    public static final String defaultProjectId = '1010';
    public static final String developmentStatus = 'In Progress';

    public DefectSearchCriteria defectSearchCriteria { get; private set; }

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

		if(searchForDefectsException != null) {
			throw searchForDefectsException;
		}

		return null;
	}

	public String[] getFieldsForSearch() {
		return fieldsForSearch;
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
        result.put('Scope:' + defaultProjectId, 'Main project');

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

    public String createWorkitemInV1(Case caseData, Defect defectData, String projectId) {
        if (creationWorkitemException != null) {
            throw creationWorkitemException;
        }

        defectData.project = projectId;
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

    public List<Defect> getClosedDefects(DateTime dateData) {
        throwException();
        return closedDefects;
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