trigger ContactTrigger on Contact (before insert, after insert, after update) {
    // If a Contact is created without a parent Account, 
    // do not allow user to create the contact record.
    if(Trigger.isBefore && Trigger.isInsert) {
        PreventDuplicateTriggerHandler.checkForDuplicateContacts(Trigger.new);
    }

    //Share the contact record with a public group as soon as a record is created
    if(Trigger.isAfter && Trigger.isInsert) {
        ContactTriggerHandler.handleAfterInsertActivities(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.handleAfterUpdateActivites(Trigger.new, Trigger.oldMap);
    }
}