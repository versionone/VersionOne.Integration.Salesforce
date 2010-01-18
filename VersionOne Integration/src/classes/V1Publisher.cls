public with sharing class V1Publisher {
	private List<Case> cases;

	public V1Publisher(List<Case> cases) {
		this.cases = cases;
	}

	public void publish() {
		for (Case caseData : cases) {
			System.debug('Case name:' + caseData.Subject);
			System.debug('Case product name:' + caseData.Product__c);
		}
	}

	private integer findProjectId(String productName) {
		return 1;
	}
}