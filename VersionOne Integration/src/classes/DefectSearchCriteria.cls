/**
 * TODO implement field list here when the second Search story is started
 */ 
public class DefectSearchCriteria {
	public String queryString { get; set; }
	public Boolean includeClosedDefects { get; set; } 
	
	public Boolean isEmpty() {
		return queryString == null || queryString.trim().length() == 0;
	}
}