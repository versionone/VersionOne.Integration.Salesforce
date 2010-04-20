@isTest
private class V1SynchronizerControllerTester {

    static testMethod void table1BindDataTest() {
        String queueName = 'TestQueue';
        Group queue = new Group(Type='Queue', Name=queueName + '1');
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        Group queue2 = new Group(Type='Queue', Name=queueName+'2');
        insert queue2;
        QueueSobject sobj2 = new QueueSobject(QueueId = queue2.Id, SobjectType = 'Case');
        insert sobj2;
        Integer numberOfCases = 45;
        List<Case> cases = new List<Case>();
        List<Group> queues = new Group[]{queue, queue2};

        System.runAs(createUser('test4356')){
            for (Integer i = 0; i<numberOfCases; i++) {
                Integer randomIndex = (Math.random() * 2).intValue();
                System.debug('Index:'+randomIndex);
                Case caseData = new Case(Subject='TestCase1', OwnerId = queues.get(randomIndex).Id);
                cases.add(caseData);
            }
            insert cases;

            V1SynchronizerController controller = new V1SynchronizerController();
            Settings settingsData = Settings.getTestSettings();
            settingsData.setDefectQueueId(queue.Id);
            settingsData.setStoryQueueId(queue2.Id);
            controller.settings = settingsData;

            controller.initData();
            TablePaginator paginator = controller.table1Paginator;

            System.assertEquals(numberOfCases, paginator.getRecordsNumber(), 'Incorrect number of cases');
            System.assertEquals(3, paginator.getTotalPageNumber(), 'Incorrect number of pages');

            System.assertEquals(1, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the first page');
            System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
            controller.table1NextBtnClick();
            System.assertEquals(2, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the second page');
            System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
            controller.table1NextBtnClick();
            System.assertEquals(3, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(5, paginator.getCases().size(), 'Incorrect number of cases on the third page');
            System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
            System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be disabled.');
            controller.table1PreviousBtnClick();
            System.assertEquals(2, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the second page');
            System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
            controller.table1PreviousBtnClick();
            System.assertEquals(1, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the first page');
            System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        }
    }

    static testMethod void table2BindDataTest() {
        String queueName = 'TestQueue';
        Group queue = new Group(Type='Queue', Name=queueName + '1');
        insert queue;
        QueueSobject sobj = new QueueSobject(QueueId = queue.Id, SobjectType = 'Case');
        insert sobj;
        Integer numberOfCases = 60;
        List<Case> cases = new List<Case>();

        System.runAs(createUser('test4356')){
            for (Integer i = 0; i<numberOfCases; i++) {
                Case caseData = new Case(Subject='TestCase1', OwnerId = queue.Id);
                cases.add(caseData);
            }
            insert cases;

            V1SynchronizerController controller = new V1SynchronizerController();
            Settings settingsData = Settings.getTestSettings();
            settingsData.setDestQueueId(queue.Id);
            controller.settings = settingsData;

            controller.initData();
            TablePaginator paginator = controller.table2Paginator;

            System.assertEquals(numberOfCases, paginator.getRecordsNumber(), 'Incorrect number of cases');
            System.assertEquals(3, paginator.getTotalPageNumber(), 'Incorrect number of pages');

            System.assertEquals(1, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the first page');
            System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
            controller.table2NextBtnClick();
            System.assertEquals(2, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the second page');
            System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
            controller.table2NextBtnClick();
            System.assertEquals(3, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(20, paginator.getCases().size(), 'Incorrect number of cases on the third page');
            System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
            System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be disabled.');
            controller.table2PreviousBtnClick();
            System.assertEquals(2, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the second page');
            System.assertEquals(false, paginator.getPreviousButtonDisabled(), 'The Previous button has to be enabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
            controller.table2PreviousBtnClick();
            System.assertEquals(1, paginator.getPageNumber(), 'Incorrect number of current page');
            System.assertEquals(paginator.getPageSize(), paginator.getCases().size(), 'Incorrect number of cases on the first page');
            System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
            System.assertEquals(false, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
        }
    }


	static testMethod void emptyPagesTest() {
		V1SynchronizerController controller = new V1SynchronizerController();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setDestQueueId('12345');
        controller.settings = settingsData;
		controller.initData();

		TablePaginator paginator = controller.table1Paginator;
        System.assertEquals(0, paginator.getRecordsNumber(), 'Incorrect number of cases');
        System.assertEquals(0, paginator.getTotalPageNumber(), 'Incorrect number of pages');

	    System.assertEquals(0, paginator.getPageNumber(), 'Incorrect number of current page');
	    System.assertEquals(null, paginator.getCases(), 'Incorrect number of cases on the first page');
	    System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
	    System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
	    controller.table1NextBtnClick();
	    System.assertEquals(0, paginator.getPageNumber(), 'Incorrect number of current page');
	    System.assertEquals(null, paginator.getCases(), 'Incorrect number of cases on the first page');
	    System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
	    System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
	    controller.table1PreviousBtnClick();
	    System.assertEquals(0, paginator.getPageNumber(), 'Incorrect number of current page');
	    System.assertEquals(null, paginator.getCases(), 'Incorrect number of cases on the first page');
	    System.assertEquals(true, paginator.getPreviousButtonDisabled(), 'The Previous button has to be disabled.');
	    System.assertEquals(true, paginator.getNextButtonDisabled(), 'The Next button has to be enabled.');
	}

    static User createUser(String alias) {
        User user = new User();
        user.Username = alias + '@not-a-mail.com';
        user.LastName = alias;
        user.Email = alias + '@not-a-mail.com';
        user.alias = alias;
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user.LanguageLocaleKey = 'en_US';
        return user;
    }
}