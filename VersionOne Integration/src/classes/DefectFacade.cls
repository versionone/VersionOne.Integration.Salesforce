public class DefectFacade implements IDefectFacade {
    private final IV1Connector connector;
    private final Map<String, Defect> defectData;

    public DefectFacade(IV1Connector connector) {
        defectData = new Map<String, Defect>();
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
                assignDefectToCase(caseData, id, null);
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

    public void assignDefectToCase(Case caseData, String defectId, String devStatus) {
        V1CaseCollector.updateCase(caseData, defectId, true, devStatus);
    }

    public void unassignDefectFromCase(Case caseData) {
        if (caseData.V1DefectId__c == null || caseData.V1DefectId__c == '') {
            throw new IntegrationException('There is no assigned defect to the case.');
        }
        String id = getDefectFromToken(caseData.V1DefectId__c);
        String notRemovedData = removeInfoAboutAssociationFromDefect(id);

        V1CaseCollector.updateCase(caseData, '', false, null);

        if (notRemovedData != '') {
            throw new IntegrationException('Some information about association was not removed from the defect. (' + notRemovedData + ')');
        }
    }

    public void publishStatus(Case caseData) {
        if (caseData.V1DefectId__c == null || caseData.V1DefectId__c == '') {
            throw new IntegrationException('There is no assigned defect to the case.');
        }
        try {
        	Defect defectData = getDefectByToken(caseData.V1DefectId__c);
        	V1CaseCollector.updateDeveloperStatus(caseData, defectData.status);
        } catch(Exception ex) {
        	throw new IntegrationException('Status was not published. Problem with getting information about defect.');
        }
    }

    public Defect getDefectByToken(String defectToken) {
        if (defectData.get(defectToken) == null) {
            String id = getDefectFromToken(defectToken);
            try {
            	defectData.put(defectToken, connector.getDefectById(id)); 
            } catch (Exception ex) {
            	throw new IntegrationException('Problem with getting defect.');
        	}
        }
        return defectData.get(defectToken);
    }

    public List<Defect> searchForDefects(String queryString, Boolean includeClosedItems) {
    	try {
    		return connector.searchDefects(queryString, includeClosedItems);
    	} catch(Exception ex) {
    		throw new IntegrationException('Failed to lookup defects in VersionOne.');
    	}
    }

    private String removeInfoAboutAssociationFromDefect(String id) {
        String notRemovedData = '';

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
            notRemovedData += 'Link';
        }
        return notRemovedData;
    }

    private String getDefectFromToken(String token) {
        return token.split(':')[1];
    }
}