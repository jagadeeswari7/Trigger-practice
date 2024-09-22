trigger LeadTrigger on Lead (before update, after update) {
    // Do not allow a user to modify the Lead record if the Lead is created before 8 days from today
    if(Trigger.isBefore && Trigger.isUpdate) {
        LeadTriggerHandler.preventLeadUpdate(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        if(!LeadTriggerHandler.hasAfterUpdateBeenExecuted) {
            LeadTriggerHandler.hasAfterUpdateBeenExecuted = true;
            LeadTriggerHandler.preventRecursiveTrigger(Trigger.new);
        }
    }
}