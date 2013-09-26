public class V1RequestException extends Exception 
{
    private final String responseBody;

    public V1RequestException(String errorMessage, IRequestor requestor) 
    {
        this(errorMessage + '\n\tResponse:\n' + requestor.getBody());
    }

}