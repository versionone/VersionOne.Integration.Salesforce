public class V1DefectReportController {
    private List<DefectWrapper> casesWithDefects = null;

    //public String userDate { get; set; }
    //public String ownerDefectList { get; set; }
    public String ownerCaseList { get; set; }
    public String caseStatusList { get; set; }
    public String defectStatusList { get; set; }
    private final Integer ITEMS_PER_PAGE = 20;
    //private final String SHOW_MY_DEFECTS = '1';
    //private final String SHOW_ALL_DEFECTS = '2';
    private final String MY_CASE = '1';
    private final String ALL_CASE = '2';
    private final String OPEN = '1';
    private final String CLOSED = '2';

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

    public boolean displayCasesWithDefectsTable {
        get {
            return casesWithDefects != null && casesWithDefects.size() > 0;
        }
    }

    public V1DefectReportController() {
        //ownerDefectList = SHOW_ALL_DEFECTS;
        ownerCaseList = MY_CASE;
        caseStatusList = OPEN;
        defectStatusList = CLOSED;
    }

    public List<DefectWrapper> getCasesWithDefect() {
        return casesWithDefects;
    }

/*
    public List<SelectOption> getOwnerDefectListOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(SHOW_ALL_DEFECTS, 'Show all defects'));
        options.add(new SelectOption(SHOW_MY_DEFECTS, 'Show only my defects'));
        return options;
    }
*/

    public List<SelectOption> getOwnerCaseListOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ALL_CASE, 'All'));
        options.add(new SelectOption(MY_CASE, 'Mine'));
        return options;
    }

    public List<SelectOption> getStatusListOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(OPEN, 'Open'));
        options.add(new SelectOption(CLOSED, 'Closed'));
        return options;
    }

    public void goToPage() {
        String pageNumber = ApexPages.currentPage().getParameters().get('pageNumber');
        try {
            paginator.goToPage(Integer.valueof(pageNumber));
        } catch (Exception ex) {
            //do nothing
        }
    }

    public PageReference findCasesWithDefects() {
        casesWithDefects = new List<DefectWrapper>();
        paginator = new DefectTablePaginator(ITEMS_PER_PAGE, new List<DefectWrapper>());

        try {
            casesWithDefects = defectFacade.getCasesWithDefects(ownerCaseList == ALL_CASE, caseStatusList == CLOSED, defectStatusList == CLOSED);

            if(casesWithDefects.size() == 0) {
                addPageMessage(ApexPages.Severity.INFO, 'There are no records.');
            }

            paginator = new DefectTablePaginator(ITEMS_PER_PAGE, casesWithDefects);
        } catch (Exception ex) {
            casesWithDefects = new List<DefectWrapper>();
            System.debug(ex.getMessage());
            addPageMessage(ApexPages.Severity.ERROR, ex.getMessage());
        }

        return null;
    }

    private void addPageMessage(ApexPages.Severity severity, String text) {
        ApexPages.addMessage(new ApexPages.Message(severity, text));
    }
}