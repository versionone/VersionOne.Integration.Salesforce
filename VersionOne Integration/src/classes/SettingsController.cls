public class SettingsController {

    public PageReference SaveSettings() {
        System.debug('Save Settings');
        testMessage = '';
        testMessage = '';
        saveSeverity = 'info';
        saveMessage = 'Settings has been saved.';
        isSettingsValidated = false;
        isSaved = true;
        try {
            settings.updateSettings();
        } catch (Exception ex) {
            saveSeverity = 'error';
            saveMessage = 'Settings has not been saved. Reason:' + ex.getMessage();
        }
        return null;
    }


    public String testSeverity{ get; set; }
    public String saveSeverity{ get; set; }
    public String testMessage{ get; set; }
    public String saveMessage{ get; set; }
    public Boolean isSettingsValidated { get; set; }
    public Boolean isSaved { get; set; }


    public PageReference TestSettings() {
        System.debug('Path:' + Settings.getPath() + ', UserName:' + Settings.getUserName() + ', Password:' + Settings.getPassword());
        testMessage = 'testing error message';
        testSeverity = 'error'; //info
        isSettingsValidated = true;
        isSaved = false;
        return null;
    }


    public String getGreeting() {
        return 'Hello tester!';
    }

    public Settings settings {get; set;}

    public void initSettings() {
        testMessage = '';
        saveMessage = '';
        isSettingsValidated = false;
        isSaved = false;
        settings = new Settings();
    }
/*
    public PageReference initPageAction() {
        PageReference homePage= new PageReference('/home/test.jsp');
        homePage.setRedirect(true);
        return homePage;
    }
    */


/*
    public PageReference save() {
        // Add the account to the database.
        //insert settings;

        // Send the user to the detail page for the new account.
        //PageReference acctPage = new ApexPages.StandardController(settings).view();
        //acctPage.setRedirect(true);

        return new PageReference();
    }
    */

    public List<SelectOption> getQueueList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('00GA0000000iNOGMA2','Escalate to VersionOne'));
        options.add(new SelectOption('00GA0000000iNOLMA2','Assigned to VersionOne'));
        options.add(new SelectOption('CANADA','Canada'));
        options.add(new SelectOption('MEXICO1','Mexico1'));
        options.add(new SelectOption('MEXICO3','Mexico2'));
        options.add(new SelectOption('MEXICO4','Mexico3'));
        options.add(new SelectOption('MEXICO5','Mexico4'));
        options.add(new SelectOption('MEXICO6','Mexico5'));
        options.add(new SelectOption('MEXICO7','Mexico6'));
        options.add(new SelectOption('MEXICO8','Mexico7'));
        return options;
    }
}