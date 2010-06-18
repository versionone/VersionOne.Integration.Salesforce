public class DefectSearchController {
    private transient Settings innerSettings;
    private transient IDefectFacade innerDefectFacade;
    
    private DefectSearchCriteria searchCriteria;
    
    public Settings Settings {
        get {
            if (innerSettings == null) {
                innerSettings = new Settings();
            }
            return innerSettings;
        }
        set { innerSettings = value; }
    }
    
    public IDefectFacade DefectFacade {
        get {
            if (innerDefectFacade == null) {
                innerDefectFacade = new DefectFacade(new V1Connector(settings, new Requestor(settings)));
            }
            return innerDefectFacade;
        }
        set { innerDefectFacade = value; }
    }
    
    public DefectSearchController() {
        searchCriteria = new DefectSearchCriteria();
    }
    
    public DefectSearchController(ApexPages.StandardController controller) {
    	this();
    }
    
    public DefectSearchCriteria getSearchCriteria() {
    	return searchCriteria;
    }
    
    public PageReference searchForDefects() {
    	System.debug('searching for ' + searchCriteria.queryString + ', closed=' + searchCriteria.includeClosedDefects);
    	return null;
    }
    
    public class DefectSearchCriteria {
    	public String queryString { get; set; }
    	public String includeClosedDefects { get; set; } 
    }
}