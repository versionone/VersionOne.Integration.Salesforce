public class SettingsController {

        //private V1Settings__c mycs;

    public TestSettings__c getGroup() {
        User product2 = new User();
        TestSettings__c a = new TestSettings__c();

        return a;
    }

/*
    public Product getProduct() {
        return null;
    }
    */

    //public Settings V1Settings;

    public SettingsController() {
        //initSettings();
    }

    public String getGreeting() {
        return 'Hello tester!';
    }

    public V1Settings__c mycs{get; set;}

/*
    public Settings getSettings() {
        return settings;
    }
    */

    public String getPath() {
        return mycs.Path__c;
    }

    public void setPath(String value) {
        mycs.Path__c = value;
    }

    public void initSettings() {

        //V1Settings = new Settings();

                mycs = V1Settings__c.getValues('V1Settings');

                //System.debug(mycs.Path__c);

                if(mycs == null) {
                        mycs = new V1Settings__c(Name= 'V1Settings');
                        mycs.Path__c = 'http://localhost';
                        mycs.UserName__c = 'admin';
                        mycs.Password__c = 'admin';
                        insert mycs;
                }
        //V1Settings = 'test';
        //return settings;
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