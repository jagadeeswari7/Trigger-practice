trigger AccountTrigger on Account (before update, after update, after undelete) {

    // If an Account with Industry Agriculture and Type Prospect is updated and 
    // Ownership is set to Private, 
    // do not allow user to save the record.
    if(Trigger.isBefore && Trigger.isUpdate) {
        AccountTriggerHandler.handleActivitiesBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    // Every time an account website is updated, 
    // update the website field on all its child contacts
    if(Trigger.isAfter && Trigger.isUpdate) {
        AccountTriggerHandler.handleActivitiesAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

    // When an account record is restored from the bin,
    // update its name, prefix it with “Restored” keyword
    if(Trigger.isAfter && Trigger.isUndelete){
        AccountTriggerHandler.handleActivitiesAfterUndelete(Trigger.new);
    }
}