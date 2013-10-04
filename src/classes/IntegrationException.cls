public class IntegrationException extends Exception {
    private Severity severityValue = Severity.ERROR;
    
    public IntegrationException(String message, Severity severityValue) {
        this.setMessage(message);
        this.severityValue = severityValue;
    }
    
    public Severity getSeverity() { 
        return severityValue; 
    }
}