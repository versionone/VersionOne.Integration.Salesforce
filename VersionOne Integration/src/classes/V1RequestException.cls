public class V1RequestException extends Exception {

    private final String responceBody;

    public V1RequestException(String errorMessage, IRequestor requestor) {
        this(errorMessage + '\n\tResponse:\n' + requestor.getBody());
        this.responceBody = requestor.getBody();
    }

    public String getResponceBody() {
        return responceBody;
    }
}