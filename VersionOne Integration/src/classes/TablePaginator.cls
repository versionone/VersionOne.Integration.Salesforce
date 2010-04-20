public class TablePaginator {

    private List<Case> cases;
    private List<Case> pageCases;
    private Integer pageNumber;
    private Integer pageSize;
    private Integer totalPageNumber;

    public TablePaginator(List<Case> cases) {
    	this.cases = cases;
        pageNumber = 0;
        totalPageNumber = 0;
        pageSize = 20;
        isNoData = false;
    }

    public void init() {
		bindData(1);
    }

    // ------------- Common for tables --------------
    private List<Case> fillCasesForCurrentPage(Integer newPageIndex, List<Case> cases) {
        System.debug('fillCasesForCurrentPage cases:' + cases);
        Transient Integer counter = 0;
        Transient Integer min = 0;
        Transient Integer max = 0;
        Integer pageNumber = getTotalPageNumber();
        Integer pageSize = getPageSize();
        if (newPageIndex > pageNumber) {
            min = pageNumber * pageSize;
            max = newPageIndex * pageSize;
        } else {
            max = newPageIndex * pageSize;
            min = max - pageSize;
        }
        List<Case> currentCases = new List<Case>();
        for(Case c : cases) {
            counter++;
            if (counter > min && counter <= max) {
                currentCases.add(c);
            }
        }
        System.debug('currentCases cases:' + currentCases);
        return currentCases;
    }

    public Boolean isNoData {get; set;}

    public Integer getRecordsNumber() {
        if (cases == null){
            return 0;
        } else {
            return cases.size();
        }
    }

    public void goToPage(Integer pageNumber) {
        System.debug('go to page table 1:' + pageNumber);
        try {
            bindData(Integer.valueof(pageNumber));
        } catch (Exception ex) {
            //do nothing
        }
    }

    public List<Integer> getPagesList() {
        List<Integer> pagesNumbers = new List<Integer>();
        Integer amountPages = getTotalPageNumber();
        for (Integer i=0; i<amountPages; i++) {
            pagesNumbers.add(i);
        }
        return pagesNumbers;
    }

    public Integer getPageNumber(){
        return pageNumber;
    }

    public List<Case> getCases() {
        return pageCases;
    }

    public Integer getPageSize() {
        return pageSize;
    }

    public Boolean getPreviousButtonDisabled() {
        System.debug('pageNumber = ' + pageNumber);
        return !(pageNumber > 1);
    }

    public Boolean getNextButtonDisabled() {
        if (cases == null){
            return true;
        } else {
            return ((pageNumber * pageSize) >= cases.size());
        }
    }

    public Integer getTotalPageNumber() {
        if (totalPageNumber == 0 && cases != null) {
            totalPageNumber = cases.size() / pageSize;
            Integer mod = cases.size() - (totalPageNumber * pageSize);
            if (mod > 0) {
                totalPageNumber++;
            }
        }
        return totalPageNumber;
    }


    private void bindData(Integer newPageIndex) {
    	if (newPageIndex <= getTotalPageNumber() && newPageIndex > 0) {
			pageCases = fillCasesForCurrentPage(newPageIndex, cases);
	        pageNumber = newPageIndex;
	        isNoData = false;
    	}
        if (pageCases == null || pageCases.size() == 0) {
            isNoData = true;
        }
    }

    public void nextBtnClick() {
        bindData(pageNumber + 1);
    }

    public void previousBtnClick() {
        bindData(pageNumber - 1);
    }

}