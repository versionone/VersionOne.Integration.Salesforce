public class V1ConnectorMock implements IV1Connector {

    private String sourceId = '123456';
    private Exception ex;
    private Integer createdDefectId = 0;
    private Map<String, Boolean> alreadyExistedDefects = new Map<String, Boolean>();
    private List<String> closedDefects = new List<String>();

    public List<String> getClosedDefects() {
        throwException();
        return closedDefects;
    }

    public void setClosedDefects(List<String> closedDefects) {
        this.closedDefects = closedDefects;
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
        result.put('CI', '1081');

        return result;
    }

    public String getDefaultProjectId() {
        return '1010';
    }

    public void createLinkV1ToSF(Integer defectId, String caseId) {

    }

    public Integer createDefectInV1(Case caseData, String productId) {
        return createdDefectId;
    }

    public void setCreatedDefectId(Integer defectId) {
        throwException();
        createdDefectId = defectId;
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