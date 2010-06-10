public class DefectFacade implements IDefectFacade {
	private IV1Connector connector;

	public DefectFacade(IV1Connector connector) {
		this.connector = connector;
	}

	public String createDefectInVersionOne(Case caseData, Defect defectData) {
        String id;
        try {
        	id = connector.createWorkitemInV1(caseData, defectData);
        } catch (Exception ex) {
        	throw new IntegrationException(ex.getMessage());
        }

        if (id != null) {
        	try {
        		createLinkInVersionOne(caseData, id);
        	} catch (Exception ex) {
        		throw new IntegrationException('Defect was created in the VersionOne but link was not created in the VersionOne.');
        	} finally {
				assignDefectToCase(caseData, id);
        	}

        }

        return id;
	}

	public void createLinkInVersionOne(Case caseData, String id) {
		try {
			connector.createLinkV1ToSF(id, caseData);
		} catch (Exception ex) {
			throw new IntegrationException('Link to the case was not created.');
		}
	}

	public void assignDefectToCase(Case caseData, String defectId) {
    	V1CaseCollector.updateCase(caseData, defectId, true);
	}

	public void unassignDefectFromCase(Case caseData) {
		if (caseData.V1DefectId__c == null || caseData.V1DefectId__c == '') {
			throw new IntegrationException('There is no assigned defect to the case.');
		}
		String id = getDefectFromToken(caseData.V1DefectId__c);
		String notRemovedData = removeInfoAboutAssociationFromDefect(id);

		V1CaseCollector.updateCase(caseData, '', false);

		if (notRemovedData != null) {
			throw new IntegrationException('Some information about association was not removed from the defect. (' + notRemovedData + ')');
		}
	}

	private String removeInfoAboutAssociationFromDefect(String id) {
		String notRemovedData;

		try {
			connector.updateReferenceForDefect(id);
		} catch (Exception ex) {
			notRemovedData = 'Reference';
		}

		try {
			connector.removeLinkFromDefect(id);
		} catch (Exception ex) {
			if (notRemovedData != '') {
				notRemovedData += ', ';
			}
			notRemovedData = 'Link';
		}
		return notRemovedData;
	}

	private String getDefectFromToken(String token) {
		return token.split(':')[1];
	}
}