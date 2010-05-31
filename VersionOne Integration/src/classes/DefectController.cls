public class DefectController {

	public Boolean isEditForm {get; set;}

	public DefectController(ApexPages.StandardController stdController) {

	}

    public void init() {
    	isEditForm = false;
    }

    public PageReference showForm() {
    	isEditForm = true;
    	return null;
    }

    public PageReference cancelForm() {
    	isEditForm = false;
    	return null;
    }

}