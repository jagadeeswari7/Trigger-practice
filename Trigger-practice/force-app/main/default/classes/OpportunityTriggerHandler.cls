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

    public static void notifyAllWhenClosedWon(List<Opportunity> newRecords, Map<Id, Opportunity> oldOpportunitiesMap) {
        Set<Id> opportunityIds = new Set<Id>();
        Set<String> listOfUsersToNotify = new Set<String>();
        // If an Opportunity is Closed Won, send email to opportunity owner, account owner & team members, people from the public group
        for(Opportunity opp : newRecords) {
            if(opp.StageName == 'Closed Won' && oldOpportunitiesMap.get(opp.Id).StageName != 'Closed Won') {
                opportunityIds.add(opp.Id);
                listOfUsersToNotify.add(opp.OwnerId);
                listOfUsersToNotify.add(opp.Account.OwnerId);
            }
        }

        if(opportunityIds.size() > 0){
            for(OpportunityTeamMember oppTeamMem : [select UserId from OpportunityTeamMember where OpportunityID in :opportunityIds]){
                listOfUsersToNotify.add(oppTeamMem.UserId);
            }

            for(GroupMember groupMems : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.name = 'Opportunity MegaStars']) {
                listOfUsersToNotify.add(groupMems.UserOrGroupId);
            }
        }
        List<String> emailAddressesList = new List<String>();
        List<User> userRecords = [select email from user where id in :listOfUsersToNotify];
        if(userRecords.size() > 0) {
            // send email
            for(User userRec : userRecords){
                emailAddressesList.add(userRec.Email);
            }
        }

        if(emailAddressesList.size() > 0){
            ContactTriggerHelper.sendEmailToAccountOwner(emailAddressesList);
        }
        
    }
}