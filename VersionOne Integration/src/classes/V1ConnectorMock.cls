public class V1ConnectorMock implements IV1Connector {

    private String sourceId = '123456';
    private String exceptionMessage = '';
    private Integer exceptionType = 0;
    private Boolean isExceptionEnabled = false;
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
    * Enables exceptions for call any methods
    * params : 	enableException - true enable exceptions, false - disable
    *  			type 			- 1 VersionOneException, 2 NullPointerException
    *			message			- message
    **/
    public void enableException(boolean enableException, Integer exceptionType, String message) {
        this.exceptionMessage = message;
        this.exceptionType = exceptionType;
        isExceptionEnabled = enableException;
    }

    private void throwException() {
        System.debug('isExceptionEnabled=' + isExceptionEnabled + ' | exceptionType=' + exceptionType);
        if (isExceptionEnabled && exceptionType == 1) {
            System.debug('Throw VersionOneException');
            throw new VersionOneException(exceptionMessage, 'test body');
        } else if (isExceptionEnabled && exceptionType == 2) {
            System.debug('Throw NullPointerException');
            throw new NullPointerException();
        }
    }
}