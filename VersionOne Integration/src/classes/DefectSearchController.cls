public class DefectSearchController {
    private transient Settings innerSettings;
    private transient IDefectFacade innerDefectFacade;
    
    private DefectSearchCriteria searchCriteria;
    private List<Defect> foundDefects;
    private List<String> errors;
    
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
        errors = new List<String>();
    }
    
    public DefectSearchController(ApexPages.StandardController controller) {
    	this();
    }
    
    public DefectSearchCriteria getSearchCriteria() {
    	return searchCriteria;
    }
    
    public Boolean errorsExist {
    	get { return errors.size() > 0; }
    }
    
    public Boolean defectsFound {
    	get { return foundDefects != null; }
    }
    
    public List<Defect> getDefects() {
    	return foundDefects;
    }
    
    public integer foundDefectsCount {
    	get { return foundDefects != null ? foundDefects.size() : 0; }
    }
    
    public PageReference searchForDefects() {
    	System.debug('searching for ' + searchCriteria.queryString + ', closed=' + searchCriteria.includeClosedDefects);
    	errors.clear();
    	foundDefects = null;
    	
    	if(searchCriteria == null || searchCriteria.queryString.trim().length() == 0) {
    		addError('Please provide non-empty search criteria');
    		return null;
    	}
    	
    	try {
    		foundDefects = DefectFacade.searchForDefects(searchCriteria.queryString, searchCriteria.includeClosedDefects);
    	} catch(IntegrationException ex) {
    		System.debug(ex.getMessage());
    		addError(ex.getMessage());
    	}
    	
    	return null;
    }
    
    private void addError(String text) {
    	errors.add(text);
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, text));
    }
    
    public class DefectSearchCriteria {
    	public String queryString { get; set; }
    	public Boolean includeClosedDefects { get; set; } 
    }
}