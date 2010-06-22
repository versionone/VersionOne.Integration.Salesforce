public class DefectTablePaginator {
    private List<Defect> defects;
    private List<Defect> pageDefects;
    private Integer pageNumber;
    private Integer pageSize;
    private Integer totalPageNumber;

    public DefectTablePaginator(List<Defect> defects) {
        this.defects = defects;
        pageNumber = 0;
        totalPageNumber = 0;
        pageSize = 20;
        isNoData = false;
        bindData(1);
    }

    // ------------- Common for tables --------------
    private List<Defect> fillDefectsForCurrentPage(Integer newPageIndex, List<Defect> cases) {
        transient Integer counter = 0;
        transient Integer min = 0;
        transient Integer max = 0;
        Integer pageNumber = getTotalPageNumber();
        Integer pageSize = getPageSize();
        
        if (newPageIndex > pageNumber) {
            min = pageNumber * pageSize;
            max = newPageIndex * pageSize;
        } else {
            max = newPageIndex * pageSize;
            min = max - pageSize;
        }
        
        List<Defect> currentDefects = new List<Defect>();
        for(Defect defect : defects) {
            counter++;
            
            if (counter > min && counter <= max) {
                currentDefects.add(defect);
            }
        }
        return currentDefects;
    }

    public Boolean isNoData {get; set;}

    public Integer getRecordsNumber() {
        return defects == null ? 0 : defects.size();
    }

    public void goToPage(Integer pageNumber) {
        System.debug('go to page:' + pageNumber);
        bindData(pageNumber);
    }

    public List<Integer> getPagesList() {
        List<Integer> pagesNumbers = new List<Integer>();
        Integer amountPages = getTotalPageNumber();
        
        for (Integer i = 0; i<amountPages; i++) {
            pagesNumbers.add(i);
        }
        
        return pagesNumbers;
    }

    public Integer getPageNumber(){
        return pageNumber;
    }

    public List<Defect> getDefects() {
        return pageDefects;
    }

    public Integer getPageSize() {
        return pageSize;
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
            isNoData = false;
        }
        
        if (pageDefects == null || pageDefects.size() == 0) {
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