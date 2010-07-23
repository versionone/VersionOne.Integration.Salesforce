public class V1DefectReportController {
	private List<DefectWrapper> closedDefects = null;

	public String userDate { get; set; }
	private final Integer ITEMS_PER_PAGE = 20;
	private final String COOKIE_NAME = 'datetime';

	public DefectTablePaginator paginator { get; private set; }

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
    		return closedDefects != null && closedDefects.size() > 0;
    	}
    }

    public V1DefectReportController() {
		Cookie lastDateTime = ApexPages.currentPage().getCookies().get(COOKIE_NAME);
		if (lastDateTime != null) {
			userDate = lastDateTime.getValue();
		}
    }

	public List<DefectWrapper> getClosedDefect() {
		return closedDefects;
	}

    public void goToPage() {
    	String pageNumber = ApexPages.currentPage().getParameters().get('pageNumber');
        try {
            paginator.goToPage(Integer.valueof(pageNumber));
        } catch (Exception ex) {
            //do nothing
        }
    }

	public PageReference findClosedDefects() {
        closedDefects = null;
        paginator = new DefectTablePaginator(ITEMS_PER_PAGE, new List<DefectWrapper>());

        try {
            List<Defect> defects = defectFacade.getClosedDefects(userDate);
            closedDefects = new List<DefectWrapper>();
			DateTime latestDate = null;
            for(Defect defect : defects) {
                closedDefects.add(new DefectWrapper(null, defect));
                DateTime testDate = V1Connector.convertToDateTime(defect.changeDate);
                if (latestDate == null || testDate > latestDate) {
                	latestDate = testDate;
                }
            }

            if(closedDefects.size() == 0) {
                addPageMessage(ApexPages.Severity.INFO, 'There are no defects closed since ' + userDate);
            }

            paginator = new DefectTablePaginator(ITEMS_PER_PAGE, closedDefects);
			storeCookie(latestDate);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            addPageMessage(ApexPages.Severity.ERROR, ex.getMessage());
        }

		return null;
	}

	private void storeCookie(DateTime dateForCookie) {
		if (dateForCookie != null) {
        	// store cookies during 2 months
        	Cookie newDateTime = new Cookie(COOKIE_NAME, dateForCookie.format('yyyy-MM-dd'), null, 60*60*24*30*2, false);
        	ApexPages.currentPage().setCookies(new Cookie[]{newDateTime});
		}
	}

    private void addPageMessage(ApexPages.Severity severity, String text) {
        ApexPages.addMessage(new ApexPages.Message(severity, text));
    }
}