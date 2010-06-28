public class DefectFacade implements IDefectFacade {
    private final IV1Connector connector;
    private final Settings settings;
    private final Map<String, Defect> defectData;

    public DefectFacade(IV1Connector connector, Settings settings) {
        defectData = new Map<String, Defect>();
        this.connector = connector;
        this.settings = settings;
    }

    public String createDefectInVersionOne(Case caseData, Defect defectData) {
        String token;
        try {
        	String projectId = resolveV1ProjectId(caseData);
            token = connector.createWorkitemInV1(caseData, defectData, projectId);
        } catch (Exception ex) {
            throw new IntegrationException(ex.getMessage());
        }

        if (token != null) {
            try {
                createLinkInVersionOne(caseData, token);
            } catch (Exception ex) {
                throw new IntegrationException('Defect was created successfully, but link was not created in VersionOne.');
            } finally {
                updateCaseOnAssignment(caseData, token, null);
            }
        }

        return token;
    }
    
    private String resolveV1ProjectId(Case caseValue) {
    	MappingV1ProjectsToSFProducts__c mapping = V1CaseCollector.getProductToProjectMappingForCase(caseValue);
    	
    	if(mapping != null) {
    		return mapping.V1ProjectToken__c.split(':')[1];
    	}
    	
    	return settings.getProjectId();
    }

    public void createLinkInVersionOne(Case caseData, String token) {
        try {
            connector.createLinkV1ToSF(token, caseData);
        } catch (Exception ex) {
            throw new IntegrationException('Link to the case was not created in VersionOne.', Severity.WARNING);
        }
    }
    
    /**
     * Assign defect to case: fill Case association fields, fill Defect reference and create V1 link. 
     * Note that we have to do callouts first, and link creation failure is not critical and should not 
     * break method execution.
     */
    // TODO refactor 
    public void assignDefectToCase(Case caseData, Defect defectData) {
    	try {
    		if(!defectData.isClosed) {
    	        connector.updateReferenceForDefect(defectData.id, caseData.id);
    		}
    	} catch(Exception ex) {
    		throw new IntegrationException('Failed to update VersionOne defect Reference field.');
    	}
    	
    	IntegrationException linkException = null;
    	
    	try {
    		createLinkInVersionOne(caseData, defectData.token);
    	} catch(IntegrationException ex) {
    		linkException = ex;
    	}
    	
    	updateCaseOnAssignment(caseData, defectData.token, defectData.status);
    	
    	if(linkException != null) {
    		throw linkException;
    	}
    }

    private void updateCaseOnAssignment(Case caseData, String defectToken, String devStatus) {
        V1CaseCollector.updateCase(caseData, defectToken, true, devStatus);
    }

    public void unassignDefectFromCase(Case caseData) {
        if (caseData.V1DefectId__c == null || caseData.V1DefectId__c == '') {
            throw new IntegrationException('There is no defect assigned to the case.');
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
            connector.updateReferenceForDefect(id, '');
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