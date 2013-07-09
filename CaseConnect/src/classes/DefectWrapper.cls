/**
 * Defect wrapper used in Defect Search part. 
 * This class exists to overcome SF platform limitations in UI bindings, so it may be deleted after refactoring.
 */
public class DefectWrapper {
	public Case casePart { get; private set; }
	public Defect defectPart { get; private set; }
	
	public Boolean isAssignedToCurrentCase {
		get { 
			return defectPart.isAssignedToCase(casePart); 
	    }
	}
	
	public DefectWrapper(Case casePart, Defect defectPart) {
		this.casePart = casePart;
		this.defectPart = defectPart;
	}
}