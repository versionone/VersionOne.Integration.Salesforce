public class V1DefectReportController {
	private List<DefectWrapper> closedDefects = null;

	public String userDate { get; set; }
	public DefectTablePaginator paginator { get; private set; }
	private final Integer ITEMS_PER_PAGE = 10;

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

    public V1DefectReportController() {
    }


	public List<DefectWrapper> getClosedDefectData() {
		return closedDefects;
	}

	public PageReference findClosedDefects() {
        closedDefects = null;
        paginator = new DefectTablePaginator(ITEMS_PER_PAGE, new List<DefectWrapper>());

        try {
            List<Defect> defects = defectFacade.getClosedDefects(userDate);
            closedDefects = new List<DefectWrapper>();

            for(Defect defect : defects) {
                closedDefects.add(new DefectWrapper(null, defect));
            }

            if(closedDefects.size() == 0) {
                addPageMessage(ApexPages.Severity.INFO, 'There are no any defects closed since ' + userDate);
            }

            paginator = new DefectTablePaginator(ITEMS_PER_PAGE, closedDefects);

        } catch(IntegrationException ex) {
            System.debug(ex.getMessage());
            addPageMessage(ApexPages.Severity.ERROR, ex.getMessage());
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            addPageMessage(ApexPages.Severity.ERROR, ex.getMessage());
        }

		return null;
	}

    private void addPageMessage(ApexPages.Severity severity, String text) {
        ApexPages.addMessage(new ApexPages.Message(severity, text));
    }
}