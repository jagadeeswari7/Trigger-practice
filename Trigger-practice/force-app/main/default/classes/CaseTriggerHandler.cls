public with sharing class CaseTriggerHandler {
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
}