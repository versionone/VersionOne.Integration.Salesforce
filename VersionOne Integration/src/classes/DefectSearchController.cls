public class DefectSearchController {
	private Case currentCase;
	
    private transient Settings innerSettings;
    private transient IDefectFacade innerDefectFacade;
    
    private DefectSearchCriteria searchCriteria = new DefectSearchCriteria();
    private List<DefectWrapper> foundDefects;
    
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
    
    public Boolean displayDefectTable {
    	 get { 
    	 	return foundDefects != null && foundDefects.size() > 0; 
    	 } 
    }
    
    public String assignedDefectToken { get; set; }
    
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
    
    public PageReference searchForDefects() {
    	System.debug('////////searching for ' + searchCriteria.queryString + ', closed=' + searchCriteria.includeClosedDefects);
    	foundDefects = null;
    	
    	if(searchCriteria == null || searchCriteria.queryString == null || searchCriteria.queryString.trim().length() == 0) {
    		addPageMessage(ApexPages.Severity.ERROR, 'Please provide non-empty search criteria');
    		return null;
    	}
    	
    	try {
    		List<Defect> defects = DefectFacade.searchForDefects(searchCriteria.queryString, searchCriteria.includeClosedDefects);
    		foundDefects = new List<DefectWrapper>();
    		
    		for(Defect defect : defects) {
    			foundDefects.add(new DefectWrapper(currentCase, defect));
    		}
    		
    		if(foundDefects.size() == 0) {
    			addPageMessage(ApexPages.Severity.INFO, 'VersionOne search returned no matching defects'); 
    		}
    	} catch(IntegrationException ex) {
    		System.debug(ex.getMessage());
    		addPageMessage(ApexPages.Severity.ERROR, ex.getMessage());
    	}
    	
    	return null;
    }
    
    public PageReference assignDefectToCase() {
    	try {
    		Defect matchingDefect = findDefectByToken(assignedDefectToken);
    		System.debug('/////' + matchingDefect);
    		DefectFacade.assignDefectToCase(currentCase, matchingDefect.token, matchingDefect.status);
    	} catch(IntegrationException ex) {
    		addPageMessage(ApexPages.Severity.ERROR, 'Failed to associate current Case and selected VersionOne defect: ' + ex.getMessage());
    	}
    	
    	return null;
    }
    
    public PageReference unassignDefectFromCase() {
    	try {
    		DefectFacade.unassignDefectFromCase(currentCase);
    	} catch(IntegrationException ex) {
    		addPageMessage(ApexPages.Severity.ERROR, 'Failed to detach selected VersionOne defect from current Case: ' + ex.getMessage());
    	}
    	
    	return null;
    }
    
    private Defect findDefectByToken(String token) {
    	if(foundDefects == null) {
    		return null;
    	}
    	
    	for(DefectWrapper item : foundDefects) {
    		if(item.defectPart.token.equals(token)) {
    			return item.defectPart;
    		}
    	}

    	return null;
    }
    
    private void addPageMessage(ApexPages.Severity severity, String text) {
    	ApexPages.addMessage(new ApexPages.Message(severity, text));
    }
    
    /**
     * TODO implement field list here when the second Search story is started
     */ 
    public class DefectSearchCriteria {
    	public String queryString { get; set; }
    	public Boolean includeClosedDefects { get; set; } 
    }
}