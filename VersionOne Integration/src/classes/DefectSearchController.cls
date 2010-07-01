public class DefectSearchController {
    private final Integer ITEMS_PER_PAGE = 10;

    private Case currentCaseValue;

    private transient Settings innerSettings;
    private transient IDefectFacade innerDefectFacade;

    private DefectSearchCriteria searchCriteria = new DefectSearchCriteria();
    private List<DefectWrapper> foundDefects;

    public DefectTablePaginator paginator { get; private set; }

    public Case currentCase {
        get { return currentCaseValue; }
        private set { currentCaseValue = value; }
    }

    public Settings Settings {
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
                innerDefectFacade = new DefectFacade(new V1Connector(settings, new Requestor(settings)), settings);
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

    public Boolean refreshWindow { get; private set; }

    public String assignedDefectToken { get; set; }

    public Integer pageNumber { get; set; }

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

    public List<Selectoption> getFieldsList() {
        List<SelectOption> options = new List<SelectOption>();
        List<V1FieldData> fieldData = defectFacade.getFieldsData();
        for(V1FieldData field : fieldData) {
            options.add(new SelectOption(field.id, field.title));
        }
        return options;
    }

    public PageReference searchForDefects() {
        foundDefects = null;
        paginator = new DefectTablePaginator(ITEMS_PER_PAGE, new List<DefectWrapper>());

        if(searchCriteria == null || searchCriteria.isEmpty()) {
            addPageMessage(ApexPages.Severity.ERROR, 'Please provide non-empty search criteria');
            return null;
        }

        try {
            List<Defect> defects = defectFacade.searchForDefects(searchCriteria);
            foundDefects = new List<DefectWrapper>();

            for(Defect defect : defects) {
                foundDefects.add(new DefectWrapper(currentCase, defect));
            }

            if(foundDefects.size() == 0) {
                addPageMessage(ApexPages.Severity.INFO, 'VersionOne search returned no matching defects');
            }

            paginator = new DefectTablePaginator(ITEMS_PER_PAGE, foundDefects);
        } catch(IntegrationException ex) {
            System.debug(ex.getMessage());
            addPageMessage(ApexPages.Severity.ERROR, ex.getMessage());
        }

        return null;
    }

    public void goToPage() {
        paginator.goToPage(pageNumber);
    }

    public PageReference assignDefectToCase() {
        try {
            refreshWindow = true;
            Defect matchingDefect = findDefectByToken(assignedDefectToken);
            defectFacade.assignDefectToCase(currentCase, matchingDefect);
        } catch(IntegrationException ex) {
            refreshWindow = false;

            if(ex.getSeverity() == Severity.WARNING) {
                addPageMessage(ApexPages.Severity.WARNING, ex.getMessage());
            } else {
                addPageMessage(ApexPages.Severity.ERROR, 'Failed to associate current Case and selected VersionOne defect: ' + ex.getMessage());
            }
        }

        return null;
    }

    public PageReference unassignDefectFromCase() {
        try {
            refreshWindow = true;
            defectFacade.unassignDefectFromCase(currentCase);
        } catch(IntegrationException ex) {
            refreshWindow = false;
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
}