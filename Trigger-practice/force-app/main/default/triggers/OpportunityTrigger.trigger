trigger OpportunityTrigger on Opportunity (before update, after update) {

    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            // If Opportunity Stage is Modified, 
            // update Opportunity Amount based on Probability * Expected Revenue
            OpportunityTriggerHandler.handleActivitiesBeforeUpdate(Trigger.new, Trigger.oldMap);
        }

        when AFTER_UPDATE {
            // Whenever an Opportunity is Closed Won, 
            // create a Task for the Opportunity Owner to split revenue among the team with high priority
            OpportunityTriggerHandler.handleActivitiesAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}