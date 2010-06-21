public class DefectFacadeMock implements IDefectFacade {

    public static final String CreatedDefectToken = 'Defect:2345';
    public static final String DefectTitle = 'Defect Title';
    public static final String DefectDescription = 'Defect Description';
    private static Exception createDefectInVersionOneException;
    private static Exception defectByIdException;
    private static Exception unassignDefectFromCaseException;
    private static Exception publishStatusException;
    private static Exception searchException;
    
    public List<Defect> foundDefects { get; set; }

    public String createDefectInVersionOne(Case caseData, Defect defectData) {
        System.debug('createDefectInVersionOneException=' + createDefectInVersionOneException);
        if (createDefectInVersionOneException != null) {
            throw createDefectInVersionOneException;
        }
        return CreatedDefectToken;
    }
    
    public List<Defect> searchForDefects(String queryString, Boolean includeClosedItems) {
    	if(searchException != null) {
    		throw searchException;
    	}
    	
    	return foundDefects;
    }
    
    public void setSearchException(Exception ex) {
    	searchException = ex;
    }

    public void setCreateDefectInVersionOneException(Exception ex) {
        createDefectInVersionOneException = ex;
    }

    public void assignDefectToCase(Case caseData, String defectId, String devStatus) {}

    public void unassignDefectFromCase(Case caseData) {
    	if (unassignDefectFromCaseException != null) {
    		throw unassignDefectFromCaseException;
    	}
    }

    public void setUnassignDefectFromCaseException(Exception ex) {
		unassignDefectFromCaseException = ex;
    }

    public void publishStatus(Case caseData) {
    	if (publishStatusException != null) {
    		throw publishStatusException;
    	}
    }

    public void setPublishStatusException(Exception ex) {
    	publishStatusException = ex;
    }


    public Defect getDefectByToken(String defectToken){
        if (defectByIdException != null) {
            throw defectByIdException;
        }
        Defect defectData = new Defect('title', 'description');
        defectData.id = CreatedDefectToken;
        defectData.title = DefectTitle;
        defectData.token = defectToken;
        defectData.description = DefectDescription;

        return defectData;
    }

    public void setGetDefectByIdException(Exception ex) {
        defectByIdException = ex;
    }   
 }