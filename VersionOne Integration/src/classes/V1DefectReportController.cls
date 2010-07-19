public class V1DefectReportController {
	private List<ClosedDefect> closedDefects = null;

	public String userDate {
		get; set;
	}

    private transient Settings innerSettings;
    public Settings settings {
        get {
            if (innerSettings == null) {
                innerSettings = new Settings();
            }
            return innerSettings;
        }
        set {
            innerSettings = value;
        }
    }

    private transient IDefectFacade innerDefectFacade;
    public IDefectFacade defectFacade {
        get {
            if (innerDefectFacade == null) {
                innerDefectFacade = new DefectFacade(new V1Connector(settings, new Requestor(settings)), settings);
            }
            return innerDefectFacade;
        }
        set {
            innerDefectFacade = value;
        }
    }

    public boolean displayClosedDefectsTable {
    	get {
    		return closedDefects != null;
    	}
    }

	public List<ClosedDefect> getClosedDefectData() {
		return closedDefects;
	}

	public PageReference findClosedDefects() {
		closedDefects = defectFacade.getClosedDefects(userDate);
		return null;
	}
}