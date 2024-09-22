public with sharing class CaseTriggerHandler {
    public static Set<Id> parentCaseIdsToUpdate;

    public static void preventCaseDeletion(List<Case> oldCases) {
        // Allow Case Deletion only by System Admin users
        Map<Id, Profile> systemAdmins = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name = 'System Administrator']);
        if(!systemAdmins.containsKey(UserInfo.getProfileId())){
            for(Case oldCase : oldCases) {
                    // Add an error to all case records in the oldCases list
                oldCase.addError('Case cannot be deleted as you dont have required permission');
            }
        }
    }

    public static void afterInsertHandler(List<Case> cases) {
        parentCaseIdsToUpdate = new Set<Id>();
        for(Case cas : cases) {
            if(cas.Resolution_Days__c != null){
                //get parent and update Total_Resolution_Days__c
                parentCaseIdsToUpdate.add(cas.ParentId);
            }
        }

        if(parentCaseIdsToUpdate.size() > 0){
            CaseTriggerHelper.updateTotalResolutionDaysOnParentCases(parentCaseIdsToUpdate);
        }
    }

    public static void afterUpdateHandler(List<Case> cases,Map<Id, Case> oldCasesMap) {
        parentCaseIdsToUpdate = new Set<Id>();
        for (Case cas : cases) {
            Case oldCaseVer = oldCasesMap.get(cas.Id);
            if (cas.Resolution_Days__c != oldCaseVer.Resolution_Days__c) {
                if (cas.ParentId != null) {
                    parentCaseIdsToUpdate.add(cas.ParentId);
                }
            }

            if (cas.ParentId != oldCaseVer.ParentId) {
                if (oldCaseVer.ParentId != null) {
                    parentCaseIdsToUpdate.add(oldCaseVer.ParentId);
                }
            }
        }
        CaseTriggerHelper.updateTotalResolutionDaysOnParentCasesUsingInnerQuery(
            parentCaseIdsToUpdate
        );
    }

    public static void afterDeleteHandler(List<Case> cases) {
        parentCaseIdsToUpdate = new Set<Id>();
        for(Case cas : cases) {
            if(cas.Resolution_Days__c != null){
                //get parent and update Total_Resolution_Days__c
                parentCaseIdsToUpdate.add(cas.ParentId);
            }
        }

        if(parentCaseIdsToUpdate.size() > 0){
            CaseTriggerHelper.updateTotalResolutionDaysOnParentCases(parentCaseIdsToUpdate);
        }
    }

    public static void afterUndeleteHandler(List<Case> cases) {
        parentCaseIdsToUpdate = new Set<Id>();
        for(Case cas : cases) {
            if(cas.Resolution_Days__c != null){
                //get parent and update Total_Resolution_Days__c
                parentCaseIdsToUpdate.add(cas.ParentId);
            }
        }

        if(parentCaseIdsToUpdate.size() > 0){
            CaseTriggerHelper.updateTotalResolutionDaysOnParentCases(parentCaseIdsToUpdate);
        }
    }
}