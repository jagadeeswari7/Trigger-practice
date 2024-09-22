public with sharing class LeadTriggerHandler {
    /**
     * static boolean variable : Naive fix
     * problems - partial retry issue
     *          - Breaks unit tests
     *          - Breaks dml with more than 200 records
     **/
    public static Boolean hasAfterUpdateBeenExecuted = false;

    // Use Static Set for more than 200 records
    /**
     * slightly improved method based on excluding already processed records
     * problems - still has partial retry issue
     *          - Breaks unit tests
     **/
    public static Set<Id> setExecutedRecord = new Set<Id>();

    //Do not allow a user to modify the Lead record if the Lead is created before 8 days from today
    public static void preventLeadUpdate(List<Lead> newLeads){
        for(Lead leadRecord : newLeads){
            if(leadRecord.CreatedDate > System.today() - 8){
                leadRecord.addError('Cannot modify the record');
            }
        }
    }

    // Update instry with apparel
    public static void preventRecursiveTrigger(List<Lead> newLeads){
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead leadRecord : newLeads){
            if(!setExecutedRecord.contains(conObj.id)){
                Lead newLeadRecord = new Lead(Id=leadRecord.Id);
                newLeadRecord.Industry = 'Apparel';
                leadsToUpdate.add(newLeadRecord);
                // Add records to set,to bypass the limit
                setExecutedRecord.add(leadRecord.Id);
            }  
        }

        if(leadsToUpdate.size() > 0) {
            update leadsToUpdate;
        }
    }
}