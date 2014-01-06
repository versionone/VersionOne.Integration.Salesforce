@isTest
private class DefectTester 
{
    private static final String DEFECT_TITLE = 'Test Defect Title';
    private static final String DEFECT_DESCRIPTION = 'Test defect description.';
    private static final String DEFECT_OWNER = 'Member:12345';
    
    static @isTest void isAssignedToCaseTest() 
    {
        Defect defect = new Defect(DEFECT_TITLE, DEFECT_DESCRIPTION);
        Boolean result = defect.isAssignedToCase(null);
        System.assertEquals(false, result);
    }
    
    static @isTest void getOwnersAsStringTest()
    {
        Defect defect = new Defect(DEFECT_TITLE, DEFECT_DESCRIPTION);
        String result = defect.getOwnersAsString();
        System.assertEquals('', result);
        
        defect.owners = new String[]{DEFECT_OWNER};
        result = defect.getOwnersAsString();
        System.assertEquals(DEFECT_OWNER, result);
        
        defect.owners.add(DEFECT_OWNER);
        result = defect.getOwnersAsString();
        System.assertEquals(DEFECT_OWNER + ', ' + DEFECT_OWNER, result);
    }
}