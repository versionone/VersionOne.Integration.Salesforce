public class DefectTablePaginator {
    private List<DefectWrapper> defects;
    private List<DefectWrapper> pageDefects;
    private Integer pageNumber;
    private Integer pageSizeValue;
    private Integer totalPageNumber;

    public DefectTablePaginator(Integer pageSizeToUse, List<DefectWrapper> defects) {
        this.defects = defects;
        pageSize = pageSizeToUse;
        pageNumber = 0;
        totalPageNumber = 0;
        hasData = true;
        bindData(1);
    }

    private List<DefectWrapper> fillDefectsForCurrentPage(Integer newPageIndex, List<DefectWrapper> defects) {
        transient Integer counter = 0;
        transient Integer min = 0;
        transient Integer max = 0;
        Integer pageNumber = getTotalPageNumber();

        if (newPageIndex > pageNumber) {
            min = pageNumber * pageSize;
            max = newPageIndex * pageSize;
        } else {
            max = newPageIndex * pageSize;
            min = max - pageSize;
        }

        List<DefectWrapper> currentDefects = new List<DefectWrapper>();
        for(DefectWrapper defect : defects) {
            counter++;

            if (counter > min && counter <= max) {
                currentDefects.add(defect);
            }
        }
        return currentDefects;
    }

    public Integer pageSize {
        get {
            return pageSizeValue;
        }
        private set {
            if(value < 1) {
                throw new IntegrationException('Page size must be positive number, at least 1');
            }
            pageSizeValue = value;
        }
    }

    public Boolean hasData {get; set;}

    public Integer getRecordCount() {
        return defects == null ? 0 : defects.size();
    }

    public void goToPage(Integer pageNumber) {
        System.debug('go to page:' + pageNumber);
        bindData(pageNumber);
    }

    public List<Integer> getPagesList() {
        List<Integer> pagesNumbers = new List<Integer>();
        Integer amountPages = getTotalPageNumber();

        for (Integer i = 0; i < amountPages; i++) {
            pagesNumbers.add(i);
        }

        return pagesNumbers;
    }

    public Integer getPageNumber(){
        return pageNumber;
    }

    public List<DefectWrapper> getDefects() {
        return pageDefects;
    }

    public Boolean getPreviousButtonDisabled() {
        return !(pageNumber > 1);
    }

    public Boolean getNextButtonDisabled() {
        if (defects == null){
            return true;
        } else {
            return ((pageNumber * pageSize) >= defects.size());
        }
    }

    public Integer getTotalPageNumber() {
        if (totalPageNumber == 0 && defects != null) {
            totalPageNumber = defects.size() / pageSize;
            Integer mod = defects.size() - (totalPageNumber * pageSize);
            if (mod > 0) {
                totalPageNumber++;
            }
        }

        return totalPageNumber;
    }

    private void bindData(Integer newPageIndex) {
        if (newPageIndex <= getTotalPageNumber() && newPageIndex > 0) {
            pageDefects = fillDefectsForCurrentPage(newPageIndex, defects);
            pageNumber = newPageIndex;
            hasData = true;
        }

        if (pageDefects == null || pageDefects.size() == 0) {
            hasData = false;
        }
    }

    public void nextBtnClick() {
        bindData(pageNumber + 1);
    }

    public void previousBtnClick() {
        bindData(pageNumber - 1);
    }
}