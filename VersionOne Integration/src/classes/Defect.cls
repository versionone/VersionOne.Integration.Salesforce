public class Defect {

    public static final String ClosedAssetState = '128';

    public Defect(String title, String description) {
        this.title = title;
        this.description = description;
    }

    public String title {get; set;}
    public String description {get; set;}
    public String token {get; set;}
    public String id {get; set;}
    public String project {get; set;}
    public String priority {get; set;}
    public String status {get; set;}
    public String resolution {get; set;}
    public Boolean isClosed{get; set;}
}