public with sharing class OpportunityTriggerHandler {

    public static void handleActivitiesBeforeUpdate(List<Opportunity> newRecords, Map<Id, Opportunity> oldOpportunitiesMap) {
        for(Opportunity opp : newRecords) {
            if(opp.StageName != oldOpportunitiesMap.get(opp.Id).StageName) {
                // Update Opportunity Amount
                opp.Amount = opp.Probability * opp.ExpectedRevenue;
            }
        }
    }

    public static void handleActivitiesAfterUpdate(List<Opportunity> newRecords, Map<Id, Opportunity> oldOpportunitiesMap) {
        List<Task> tasksToInsert = new List<Task>();
        for(Opportunity opp : newRecords) {
            if(opp.StageName == 'Closed Won' && oldOpportunitiesMap.get(opp.Id).StageName != 'Closed Won') {
                // Create a Task for the Opportunity Owner
                Task taskRec = new Task();
                taskRec.WhatId = opp.Id; // non-human: whatId, human: whoId
                taskRec.OwnerID = opp.OwnerId;
                taskRec.Subject = 'Split revenue with team';
                taskRec.Status = 'New';
                taskRec.Priority = 'High';
                tasksToInsert.add(taskRec);
            }
        }

        if(tasksToInsert.size() > 0) {
            insert tasksToInsert;
        }
    }
}