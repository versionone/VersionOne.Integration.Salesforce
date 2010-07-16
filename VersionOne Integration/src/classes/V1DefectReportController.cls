public class V1DefectReportController {


	public String userDate {
		get; set;
	}

	public List<ClosedDefect> getClosedDefectData() {
		return new List<ClosedDefect>();
	}

	public PageReference findClosedDefects() {
		return null;
	}
}