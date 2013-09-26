/**
 * Represents inforamtion about field for seach
 *
 **/
public class V1FieldData {
    public String title{ get; set; }
    public String[] searchStrings{ get; set; }
    public String id{ get; private set;}

    public V1FieldData(String title, String[] searchStrings) {
        this.title = title;
        this.searchStrings = searchStrings;
        this.id = title.replace(' ', '_');
    }
}