public class DefectFacade implements IDefectFacade {
    private final IV1Connector connector;
    private final Settings settings;
    private final Map<String, Defect> defectData;
    public final List<V1FieldData> fieldsData = new List<V1FieldData>();

    public DefectFacade(IV1Connector connector, Settings settings) {
        defectData = new Map<String, Defect>();
        this.connector = connector;
        this.settings = settings;

        fieldsData.add(new V1FieldData('All', new String[]{'Number', 'Name', 'Description', 'Reference'}));
        fieldsData.add(new V1FieldData('ID', new String[]{'Number'}));
        fieldsData.add(new V1FieldData('Title', new String[]{'Name'}));
        fieldsData.add(new V1FieldData('Description', new String[]{'Description'}));
        fieldsData.add(new V1FieldData('Title & Description', new String[]{'Name', 'Description'}));
        fieldsData.add(new V1FieldData('Reference', new String[]{'Reference'}));
    }

    public List<V1FieldData> getFieldsData() {
        return fieldsData;
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

    private String[] resolveSearchField(String id) {
        for(V1FieldData field : fieldsData) {
            if (id == field.id) {
                return field.searchStrings;
            }
        }
        return null;
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

    public List<Defect> searchForDefects(DefectSearchCriteria searchCriteria) {
        String[] fields = resolveSearchField(searchCriteria.searchIn);
        if (fields == null) {
            throw new IntegrationException('There is no selected field for search.');
        }

        try {
            return connector.searchDefects(searchCriteria.queryString, searchCriteria.includeClosedDefects, fields);
        } catch(Exception ex) {
            throw new IntegrationException('Failed to lookup defects in VersionOne.');
        }
    }

    public List<Defect> getClosedDefects(String dateString) {
    	try {
    		return connector.getClosedDefects(getDateTime(dateString));
    	} catch(Exception ex) {
            throw new IntegrationException('Failed to get closed defects.');
        }
    }

    public static DateTime getDateTime(String dateString) {
    	if (dateString == null || dateString == '') {
    		return null;
    	}
    	String[] dateTimeDate = dateString.split(' ');
    	if (dateTimeDate.size() == 1) {
    		dateString += ' 00:00:00';
    	}

    	return datetime.valueOf(dateString);
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