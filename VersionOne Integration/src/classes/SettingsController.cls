public class SettingsController {

    public String getGreeting() {
        return 'Hello tester!';
    }

    public Settings settings {get; set;}

	public void initSettings() {
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
}