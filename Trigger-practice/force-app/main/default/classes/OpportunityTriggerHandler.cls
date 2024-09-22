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
        Set<Id> opportunityIds = new Set<Id>();

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
            } else if(opp.StageName == 'Closed Lost') {
                opportunityIds.add(opp.Id);
            }
        }

        if(opportunityIds.size() > 0) {
            //remove all Opportunity Team Members from the Opportunity
            List<OpportunityTeamMember> oppTeamMembersToDelete = [SELECT Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityIds];
            if(oppTeamMembersToDelete.size() > 0) {
                delete oppTeamMembersToDelete;
            }
        }

        if(tasksToInsert.size() > 0) {
            insert tasksToInsert;
        }
    }

    public static void addOppTeamMembers(List<Opportunity> newRecords, Map<Id, Opportunity> oldRecordsMap){
        List<OpportunityTeamMember> oppTeamMembersToInsert = new List<OpportunityTeamMember>();
        //As soon as Opportunity Stage reaches Needs Analysis, add all users of role Opportunists to the Team
        List<User> opportunists = [SELECT Id from User WHERE isActive = true AND UserRole.Name = 'Opportunists'];
        for(Opportunity opp : newRecords) {
            if(opp.StageName == 'Needs Analysis' && oldRecordsMap.get(opp.Id).StageName != opp.stageName) {
                for(User opportunist : opportunists) {
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = opp.Id;
                    otm.UserId = opportunist.Id;
                    otm.TeamMemberRole = 'Opportunity Team Member';
                    otm.OpportunityAccessLevel = 'Edit';
                    oppTeamMembersToInsert.add(otm);
                }
            }
        }

        if(oppTeamMembersToInsert.size() > 0) {
            insert oppTeamMembersToInsert;
        }
    }
}