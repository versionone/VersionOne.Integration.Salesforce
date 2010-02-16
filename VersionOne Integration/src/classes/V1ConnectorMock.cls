public class V1ConnectorMock implements IV1Connector {

    private String sourceId = '123456';
    private String exceptionMessage = '';
    private Integer exceptionType = 0;
    private Boolean isExceptionEnabled = false;

    public List<String> getClosedDefects() {
        List<String> defects = new List<String>();
        defects.add('defect_id_1');
        defects.add('defect_id_2');

        return defects;
    }

    public String getSourceId() {
        if (isExceptionEnabled && exceptionType == 1) {
        	System.debug('Throw VersionOneException');
            throw new VersionOneException(exceptionMessage, 'test body');
        } else if (isExceptionEnabled && exceptionType == 2) {
        	System.debug('Throw NullPointerException');
            throw new NullPointerException();
        }

        return sourceId;
    }

    public void setTestSourceId(String sourceId) {
        this.sourceId = sourceId;
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

}