public class Defect 
{
    public static final String ClosedAssetState = '128';

    public String title {get; set;}
    public String description {get; set;}
    public String token {get; set;}
    public String id {get; set;}
    public String assetNumber { get; set; }
    public String project {get; set;}
    public String priority {get; set;}
    public String status {get; set;}
    public String resolution {get; set;}
    public Boolean isClosed{get; set;}
    public String[] owners{get; set;}
    public Case[] cases {get; set;}
    public String changeDate { get; set; }

    public Defect(String title, String description) 
    {
        this.title = title;
        this.description = description;
    }
    
    public String getOwnersAsString() 
    {
        if (owners == null) 
        {
            return '';
        }
        
        String ownersString = '';
        
        for (String owner : owners) 
        {
            if (ownersString != '') 
            {
                ownersString += ', ';
            }
            ownersString += owner;
        }
        return ownersString;
    }  

    public Boolean isAssignedToCase(Case caseToCheck) 
    {
        if (caseToCheck == null) 
        {
            return false;
        }
        return caseToCheck.V1Association__c && token.equals(caseToCheck.V1DefectId__c);
    }
}