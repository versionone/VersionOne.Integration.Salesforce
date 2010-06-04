global class V1ConnectorMock implements IV1Connector {

    private String sourceId = '123456';
    private Exception ex;
    private Exception creationWorkitemException;
    private Exception createLinkException;
    public String createdWorkitemId;
    private Map<String, Boolean> alreadyExistedDefects = new Map<String, Boolean>();
    private List<String> closedDefects = new List<String>();

    public static String defaultProjectId = '1010';

    global List<String> getClosedWorkitems() {
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

    global String getSourceId() {
        throwException();
        return sourceId;
    }

    public void setTestSourceId(String sourceId) {
        this.sourceId = sourceId;
    }

    global Map<String, String> findAllProjects() {
        throwException();
        Map<String, String> result = new Map<String, String>();
        result.put('1081', 'CI');
        result.put(defaultProjectId, 'Main project');

        return result;
    }

    global String getDefaultProjectId() {
        return defaultProjectId;
    }

    global void createLinkV1ToSF(String defectId, Case caseData) {
		if (createLinkException != null) {
			throw createLinkException;
		}
    }

    global void setExceptionForLinkCreationInV1(Exception ex) {
    	createLinkException = ex;
    }

    global String createWorkitemInV1(Case caseData, String productId) {
    	if (creationWorkitemException != null) {
    		throw creationWorkitemException;
    	}
        return createdWorkitemId;
    }

    global void setExceptionForCreationWorkitemInV1(Exception ex) {
		creationWorkitemException = ex;
    }

    global Map<String, Boolean> getReferencedWorkitems(List<Case> cases) {
        throwException();
        return alreadyExistedDefects;
    }

    public void setTestAlreadyExistedDefects(Map<String, Boolean> defects) {
        alreadyExistedDefects = defects;
    }

    global Settings getSettings() {
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