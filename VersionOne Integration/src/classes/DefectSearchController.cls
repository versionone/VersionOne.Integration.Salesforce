public class DefectSearchController {
    private transient Settings innerSettings;
    private transient IDefectFacade innerDefectFacade;
    
    public Settings settings {
        get {
            if (innerSettings == null) {
                innerSettings = new Settings();
            }
            return innerSettings;
        }
        set { innerSettings = value; }
    }
    
    public IDefectFacade defectFacade {
        get {
            if (innerDefectFacade == null) {
                innerDefectFacade = new DefectFacade(new V1Connector(settings, new Requestor(settings)));
            }
            return innerDefectFacade;
        }
        set { innerDefectFacade = value; }
    }
    
    public DefectSearchController() {}
    
    public DefectSearchController(ApexPages.StandardController controller) {
    	//
    }
    
    public PageReference searchForDefects() {
    	return null;
    }
}