public class DefectSearchController {
	private Case currentCase;
	
    private transient Settings innerSettings;
    private transient IDefectFacade innerDefectFacade;
    
    private DefectSearchCriteria searchCriteria = new DefectSearchCriteria();
    private List<DefectWrapper> foundDefects;
    private List<String> errors = new List<String>();
    
    public Boolean searchFailed { get; private set; } 
    
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
    
    public Boolean errorsExist {
    	get { return errors.size() > 0; }
    }
    
    public Boolean defectsFound {
    	get { return foundDefects != null && foundDefects.size() > 0; }
    }
    
    public String assignedDefectId { get; set; }
    public String unassignedDefectId { get; set; }
    
    public DefectSearchController(Case caseEntity) {
    	this(caseEntity.ID);
        searchCriteria = new DefectSearchCriteria();
    }
    
    public DefectSearchController(ApexPages.StandardController controller) {
    	this(controller.getRecord().ID);
    }
    
    private DefectSearchController(String id) {
        currentCase = V1CaseCollector.getCaseByCaseId(id);
    }
    
    public DefectSearchCriteria getSearchCriteria() {
    	return searchCriteria;
    }
    
    public List<DefectWrapper> getDefects() {
    	return foundDefects;
    }
    
    public Boolean isAssignedToCurrentCase(Defect defect) {
    	return defect.isAssignedToCase(currentCase);
    }
    
    public PageReference searchForDefects() {
    	System.debug('searching for ' + searchCriteria.queryString + ', closed=' + searchCriteria.includeClosedDefects);
    	errors.clear();
    	searchFailed = false;
    	foundDefects = null;
    	
    	if(searchCriteria == null || searchCriteria.queryString.trim().length() == 0) {
    		searchFailed = true;
    		addError('Please provide non-empty search criteria');
    		return null;
    	}
    	
    	try {
    		List<Defect> defects = DefectFacade.searchForDefects(searchCriteria.queryString, searchCriteria.includeClosedDefects);
    		foundDefects = new List<DefectWrapper>();
    		
    		for(Defect defect : defects) {
    			foundDefects.add(new DefectWrapper(currentCase, defect));
    		}
    		
    		if(foundDefects.size() == 0) {
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'VersionOne search returned no matching defects')); 
    		}
    		
    		System.debug('********** FOUND DEFECTS: ' + defects.size());
    	} catch(IntegrationException ex) {
    		System.debug(ex.getMessage());
    		searchFailed = true;
    		addError(ex.getMessage());
    	}
    	
    	return null;
    }
    
    public PageReference assignDefectToCase() {
    	try {
    		// assign
    	} catch(IntegrationException ex) {
    		addError('Failed to associate current Case and selected VersionOne defect: ' + ex.getMessage());
    	}
    	
    	return null;
    }
    
    public PageReference unassignDefectFromCase() {
    	try {
    		// unassign
    	} catch(IntegrationException ex) {
    		addError('Failed to detach selected VersionOne defect from current Case: ' + ex.getMessage());
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
    
    public class DefectWrapper {
    	public Case casePart { get; private set; }
    	public Defect defectPart { get; private set; }
    	
    	public Boolean isAssignedToCurrentCase {
    		get { 
    			return defectPart.isAssignedToCase(casePart); 
    	    }
    	}
    	
    	public DefectWrapper(Case casePart, Defect defectPart) {
    		this.casePart = casePart;
    		this.defectPart = defectPart;
    	}
    }
}