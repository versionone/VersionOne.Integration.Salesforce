public class ProjectProductMapping {
	
    public String productName {get; set;}
    public String productId {get; set;}
    public String projectName {get; set;}
    public String projectToken {get; set;}
    public Boolean isVisible {get; set;}
    public Boolean isDeletable {get; set;}
    public String mappingId {get; set;}

    public ProjectProductMapping(String projectName, Boolean isVisible, String productName) {
        this.projectName = projectName;
        this.isVisible = isVisible;
        this.productName = productName;
    }
}