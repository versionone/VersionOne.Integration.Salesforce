public with sharing class SettingsController {

    private static String DEFAULT_PRODUCT = 'Not in this list';
    private static String DEFAULT_PRODUCT_ID = '0';

    public String testSeverity{get; set;}
    public String saveSeverity{get; set;}
    public String testMessage{get; set;}
    public String saveMessage{get; set;}
    public Boolean isSettingsValidated {get; set;}
    public Boolean isSettingsCorrect {get; set;}
    public Boolean isSaved {get; set;}
    public Boolean isGotProjects {get; set;}
    public ProjectProductMapping currentMapping{ get; set;}

    private transient Settings innerSettings;
    //private Map<String, String> projects;
    public Settings settings {
        get {
            if (innerSettings == null) {
                innerSettings = new Settings();
            }
            return innerSettings;
        }
        set {
            innerSettings = value;
        }
    }

    private transient IV1Connector innerConnector;
    public IV1Connector connector {
        get {
            if (innerConnector == null) {
                innerConnector = new V1Connector(settings, new Requestor(settings));
            }
            return innerConnector;
        }
        set {
            innerConnector = value;
        }
    }

    private Map<String, String> innerProjects;
    public Map<String, String> projects {
        get {
            if (innerProjects == null || innerProjects.keySet().size() == 0) {
                refreshProjectsList();
            }
            return innerProjects;
        }
        set {}
    }

    private void refreshProjectsList() {
        try {
            innerProjects = connector.findAllProjects();
            isGotProjects = true;
        } catch (Exception ex) {
            innerProjects = new Map<String, String>();
            System.debug('Exception was thrown.' + ex);
            isGotProjects = false;
        }
    }

    private List<MappingV1ProjectsToSFProducts__c> baseMappingData;
    private void resetMappingData() {
    	baseMappingData = null;
    }

    private List<MappingV1ProjectsToSFProducts__c> getMappingData() {
    	if (baseMappingData == null) {
    		baseMappingData = V1CaseCollector.getMappingList();
    	}
    	return baseMappingData;
    }

    /** Must be called before usage of any other method. */
    public void initSettings() {
    	currentMapping = new ProjectProductMapping(null, null, null);
    	resetConnectionFormSettings();
        isGotProjects = false;
        refreshProjectsList();
        if (updateProjectData()) {
            settings.updateSettings();
        }
    }

    private void resetConnectionFormSettings() {
        testMessage = '';
        saveMessage = '';
        isSettingsValidated = false;
        isSettingsCorrect = false;
        isSaved = false;
    }

	/*
	* Is there is no settings for default mapping sets it.
	* Return: true - if settings was updated, false - if setting wasn't updated
	*/
    public boolean updateProjectData() {
        boolean isUpdated = false;

        if (settings.validate().size() == 0 &&
            (settings.getProjectId() == '' || settings.getProjectId() == null ||
             settings.getProjectName() == '' || settings.getProjectName() == null)) {
            updateDefaultProjectSettings(connector.getDefaultProjectId());
            isUpdated = true;
        }

        return isUpdated;
    }

    public PageReference saveSettings() {
        isSettingsCorrect = validateSettings();
        String sourceId, memberId;
        try {
            sourceId = connector.getSourceId();
        } catch (Exception ex) {}
        try {
            memberId = connector.getCurrentMemberId();
        } catch (Exception ex) {}
        if (!isSettingsCorrect || sourceId == null || memberId == null) {
            isSettingsCorrect = false;
            isSettingsValidated = false;
            testMessage = '';
            isSaved = false;
            addErrorMessage('Settings is not correct or was not validated.');
            return null;
        }
        settings.setCurrentMemberId(memberId);
        settings.setSourceId(sourceId);

        System.debug('Save Settings');
        testMessage = '';
        testSeverity = '';
        isSettingsValidated = false;
        isSaved = true;
        if(!updateProjectData()) {
            refreshProjectsList();
        }
        try {
            settings.updateSettings();
            saveSeverity = 'info';
            saveMessage = 'Settings has been saved.';
        } catch (Exception ex) {
            saveSeverity = 'error';
            saveMessage = 'Settings has not been saved. Reason:' + ex.getMessage();
        }
        return null;
    }

    public PageReference testSettings() {
        if (!validateSettings()) {
            isSettingsCorrect = false;
            isSettingsValidated = false;
            testMessage = '';
            return null;
        }

        try {
            validateConnectionAndSource();
            testSeverity = 'info';
            testMessage = 'Settings correct.';
            isSettingsCorrect = true;
        } catch (Exception ex) {
            testSeverity = 'error';
            testMessage = ex.getMessage();
            isSettingsCorrect = false;
        }

        System.debug('testMessage=' + testMessage);

        isSettingsValidated = true;
        isSaved = false;

        return null;
    }

    public PageReference addMapping() {
    	if (!isProductAlreadyUsed(currentMapping.productId, '0')) {
    		currentMapping.projectName = projects.get(currentMapping.projectToken);
    		currentMapping.productName = currentMapping.productId;
    		V1CaseCollector.addNewMapping(currentMapping);
    	} else {
    		addErrorMessage('Mapping for this product already exist');
    	}
    	resetMappingData();

    	return null;
    }

    /**
     * Validates settings and adds errors messages on page if any.
     *
     * settings - settings to validate.
     * Returns 	true  - if all requred fields are filled.
     *			false - if any of requred fields are not filled.
     */
    public Boolean validateSettings() {
        String[] errors = settings.validate();
        for (String msg : errors) {
            addErrorMessage(msg);
        }
        return errors.size() == 0;
    }

    private static void addErrorMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, text));
    }

    private static void addInfoMessage(String text) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, text));
    }

    public void validateConnectionAndSource() {
        if (settings.getSource() == null || connector.getSourceId() == null) {
            throw new V1RequestException('Incorrect source.');
        }
    }

    public List<SelectOption> getVersionOneProjectsList() {
        List<SelectOption> options = new List<SelectOption>();
        for(String id : projects.keySet()) {
            options.add(new SelectOption(id, projects.get(id)));
        }
        return options;
    }

    public List<Selectoption> getProductList() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption(DEFAULT_PRODUCT_ID, DEFAULT_PRODUCT));
        Schema.DescribeFieldResult fieldResult = Schema.sObjectType.Case.fields.Product__c;
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        return options;
    }

    public List<ProjectProductMapping> getMappings() {
        List<ProjectProductMapping> mappings = new List<ProjectProductMapping>();
        ProjectProductMapping mapping = new ProjectProductMapping(settings.getProjectName(), projects.containsKey('Scope:' + settings.getProjectId()), DEFAULT_PRODUCT);
        mapping.productId = DEFAULT_PRODUCT_ID;
        mapping.isDeletable = false;
        mappings.add(mapping);
        List<MappingV1ProjectsToSFProducts__c> baseMappingData = getMappingData();
        for (MappingV1ProjectsToSFProducts__c mapData : baseMappingData) {
	        mapping = new ProjectProductMapping(mapData.V1ProjectName__c, projects.containsKey(mapData.V1ProjectToken__c), mapData.SFProductName__c);
        	mapping.productId = mapData.SFProductId__c;
        	mapping.isDeletable = true;
        	mapping.mappingId = mapData.id;
        	mappings.add(mapping);
        }

        return mappings;
    }


    public PageReference updateProjectMapping() {
    	resetConnectionFormSettings();
    	String mappingId = ApexPages.currentPage().getParameters().get('mappingId');
    	if (mappingId == '') {
        	updateDefaultProjectSettings(currentMapping.projectToken.split(':')[1]);
        	settings.updateSettings();
    	} else {
    		if (!isProductAlreadyUsed(currentMapping.productId, mappingId)) {
	    		currentMapping.projectName = projects.get(currentMapping.projectToken);
	    		currentMapping.productName = currentMapping.productId;
    			V1CaseCollector.updateMapping(mappingId, currentMapping);
    			resetMappingData();
    		} else {
    			addErrorMessage('Mapping for this product already exist');
    		}
    	}

    	return null;
    }

    public PageReference removeProjectMapping() {
    	resetConnectionFormSettings();
    	String mappingId = ApexPages.currentPage().getParameters().get('mappingId');
    	if (mappingId == null || mappingId == '') {
    		addErrorMessage('Incorrect data for deletion.');
    		return null;
    	}

    	V1CaseCollector.deleteMapping(mappingId);
    	resetMappingData();

    	return null;
    }

    private boolean isProductAlreadyUsed(String productId, String mappingId) {
        List<MappingV1ProjectsToSFProducts__c> baseMappingData = getMappingData();
        for (MappingV1ProjectsToSFProducts__c mapData : baseMappingData) {
        	if (mapData.SFProductId__c == productId && mapData.id != mappingId) {
        		return true;
        	}
        }

        return false;
    }

    public void updateDefaultProjectSettings(String id) {
        settings.setProjectId(id);
        settings.setProjectName(projects.get('Scope:'+id));
    }
}