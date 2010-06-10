public class V1ConnectorMock implements IV1Connector {

    private String sourceId = '123456';
    private Exception ex;
    private Exception creationWorkitemException;
    private Exception createLinkException;
    public String createdWorkitemId;
    private Map<String, Boolean> alreadyExistedDefects = new Map<String, Boolean>();
    private List<String> closedDefects = new List<String>();
    private Exception removeLinkFromDefectException;
    private Exception updateReferenceForDefectException;

    public static String defaultProjectId = '1010';

    public List<String> getClosedWorkitems() {
        throwException();
        return closedDefects;
    }

    public void setClosedDefects(List<String> closedDefects) {
        this.closedDefects = closedDefects;
    }

	public Defect getDefectById(String id) {
		Defect defectData = new Defect();
		defectData.id = id;

		return defectData;
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

	public void updateReferenceForDefect(String defectId) {
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
        result.put('1081', 'CI');
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
        return createdWorkitemId;
    }

    public void setCreatedWorkitemId(String defectId) {
    	createdWorkitemId = defectId;
    }

    public void setExceptionForCreationWorkitemInV1(Exception ex) {
		creationWorkitemException = ex;
    }

    public Map<String, Boolean> getReferencedWorkitems(List<Case> cases) {
        throwException();
        return alreadyExistedDefects;
    }

    public void setTestAlreadyExistedDefects(Map<String, Boolean> defects) {
        alreadyExistedDefects = defects;
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