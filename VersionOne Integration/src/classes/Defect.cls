public class Defect {

	public Defect() {
		this('Title', 'Description');
	}

	public Defect(String title, String description) {
		this.title = title;
		this.description = description;
	}

	public String title {get; set;}
	public String description {get; set;}
}