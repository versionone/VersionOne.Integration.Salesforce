public class DefectFacadeMock implements IDefectFacade {

    public static final String CreatedDefectId = 'Defect:2345';
    public static final String DefectTitle = 'Defect Title';
    public static final String DefectDescription = 'Defect Description';
    private static Exception createDefectInVersionOneException;
    private static Exception defectByIdException;
    private static Exception unassignDefectFromCaseException;
    private static Exception publishStatusException;
    
    public List<Defect> foundDefects { get; set; }

    public String createDefectInVersionOne(Case caseData, Defect defectData) {
        System.debug('createDefectInVersionOneException=' + createDefectInVersionOneException);
        if (createDefectInVersionOneException != null) {
            throw createDefectInVersionOneException;
        }
        return CreatedDefectId;
    }
    
    public List<Defect> searchForDefects(String queryString, Boolean includeClosedItems) {
    	return foundDefects;
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


    public Defect getDefectById(String defectToken){
        if (defectByIdException != null) {
            throw defectByIdException;
        }
        Defect defectData = new Defect('title', 'description');
        defectData.id = CreatedDefectId;
        defectData.title = DefectTitle;
        defectData.description = DefectDescription;

        return defectData;
    }

    public void setGetDefectByIdException(Exception ex) {
        defectByIdException = ex;
    }   
 }