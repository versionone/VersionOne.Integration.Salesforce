public class VersionOneException extends Exception {

    private String responceBody;
    private String message;

    public VersionOneException(String errorMessage, String responceBody) {
        this.message = errorMessage;
        this.responceBody = responceBody;
    }

    public String getResponceBody() {
        return responceBody;
    }

    public String getErrorMessage() {
        return message;
    }
}