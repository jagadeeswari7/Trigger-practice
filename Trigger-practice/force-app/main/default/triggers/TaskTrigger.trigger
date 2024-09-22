trigger TaskTrigger on Task (before insert, before update, after insert) {
    switch on Trigger.operationType {
        // Whenever a Task is created, set the Priority to High
        when BEFORE_INSERT {
            TaskTriggerHandler.handleActivitiesBeforeInsert(Trigger.new);
        }
        // Allow updating the Task record only if the parent Contact’s Account has the Permission checked.
        when BEFORE_UPDATE {
            TaskTriggerHandler.handleActivitiesBeforeUpdate(Trigger.new);
        }
        //Whenever a new Task is assigned to a Contact, increment the Number of Tasks field value by 1
        when AFTER_Insert {
            TaskTriggerHandler.handleActivitiesAfterInsert(Trigger.new);
        }
    }
}