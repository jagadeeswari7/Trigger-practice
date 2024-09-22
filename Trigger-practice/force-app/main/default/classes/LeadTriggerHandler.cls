public with sharing class LeadTriggerHandler {
    //Do not allow a user to modify the Lead record if the Lead is created before 8 days from today
    public static void preventLeadUpdate(List<Lead> newLeads){
        for(Lead leadRecord : newLeads){
            if(leadRecord.CreatedDate < System.today() - 8){
                leadRecord.addError('Cannot modify the record');
            }
        }
    }
}