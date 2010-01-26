public class VersionOneException extends Exception {

	private String responceBody;

	public VersionOneException(String message, String responceBody) {
		this(message);
		this.responceBody = responceBody;
	}

	public String getResponceBody() {
		return responceBody;
	}
}