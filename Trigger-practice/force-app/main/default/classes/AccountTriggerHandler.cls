public with sharing class AccountTriggerHandler {
    public static void handleActivitiesBeforeUpdate(List<Account> newAccountRecords, Map<Id, Account> oldAccountRecordsMap) {
        for(Account accRec : newAccountRecords) {
            // If an Account with Industry Agriculture and Type Prospect is updated
            if(accRec.Industry == 'Agriculture' && accRec.Type == 'Prospect') {
                // check if ownership is updated and set to private Public -> private
                if(oldAccountRecordsMap.get(accRec.Id).Ownership != accRec.Ownership && accRec.Ownership == 'Private') {
                    // Throw an error
                    accRec.addError('Cannot modify Ownership');
                }
            }
        }
    }

    public static void handleActivitiesAfterUpdate(List<Account> newAccountRecords, Map<Id, Account> oldAccountRecordsMap, Map<Id, Account> newAccountRecordsMap) {
        Set<Id> accountIds = new Set<Id>();
        for(Account accRec : newAccountRecords) {
            // If an account website is updated
            if(accRec.Website != oldAccountRecordsMap.get(accRec.Id).Website) {
                    // store the account ids in a set
                    accountIds.add(accRec.Id);
            }
        }

        if(!accountIds.isEmpty()) {
            callAsyncApex(accountIds);
            List<Contact> contactList = new List<Contact>();
            for(Contact contactRec : [SELECT Id, AccountId, Website__c FROM Contact WHERE AccountId IN :accountIds]) {
                // update the website field on all its child contacts
                contactRec.Website__c = newAccountRecordsMap.get(contactRec.AccountId).Website;
                contactList.add(contactRec);
            }

            if(!contactList.isEmpty()) {
                update contactList;
            }
        }
    }

    public static void handleActivitiesAfterUndelete(List<Account> restoredRecords){
        List<Account> restoredAccounts = new List<Account>();
        for(Account acc : [SELECT Name from Account where id IN :restoredRecords]){
            acc.Name = 'Restored '+acc.Name;
            restoredAccounts.add(acc);
        }

        if(restoredAccounts.size() > 0){
            update restoredAccounts;
        }
    }

    @future
    public static void callAsyncApex(Set<Id> accountIds){
        List<Contact> contactList = new List<Contact>();
            for(Contact contactRec : [SELECT Id, AccountId, Website__c FROM Contact WHERE AccountId IN :accountIds]) {
                // update the website field on all its child contacts
                contactRec.LeadSource = 'Web';
                contactList.add(contactRec);
            }

            if(!contactList.isEmpty()) {
                update contactList;
            }
    }
}