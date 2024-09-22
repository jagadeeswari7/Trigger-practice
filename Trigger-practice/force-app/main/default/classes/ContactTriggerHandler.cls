public with sharing class ContactTriggerHandler {
    public static void handleBeforeInsertActivities(List<Contact> newContacts) {
        for(Contact conRec : newContacts) {
            if(conRec.AccountId == null) {
                // throw the error if Account is not null
                conRec.addError('Account is mandatory to create the contact');
            }
        }
    }

    public static void handleAfterInsertActivities(List<Contact> newContacts) {
        // public group
        Id conInnoPublicGroupId = [SELECT ID FROM Group WHERE Name = 'Contact Trigger Innovators' LIMIT 1].Id;
        List<ContactShare> conShareList = new List<ContactShare>();
        for(Contact conRec : newContacts) {
            ContactShare conS = new ContactShare();
            conS.ContactId = conRec.Id;
            conS.ContactAccessLevel = 'Edit';
            conS.RowCause = 'Manual';
            conS.UserOrGroupId = conInnoPublicGroupId;
            // Add all the contacts to the public group once it is inserted
            conShareList.add(conS);
        }

        if(!conShareList.isEmpty()) {
            insert conShareList;
        }
    }


    //Send an email to the Account Owner when email or phone of a child contact is modified
    public static void handleAfterUpdateActivites(List<Contact> newContacts, Map<Id, Contact> oldContactRecordsMap) {
        List<Id> accountIdsToEmail = new List<Id>();
        for(Contact con : newContacts) {
            if(con.AccountId != null) {
                if(con.Email != oldContactRecordsMap.get(con.Id).Email || con.Phone != oldContactRecordsMap.get(con.Id).Phone) {
                    // Send email to the account owner
                    accountIdsToEmail.add(con.AccountId);
                }   
            }
        }

        if(!accountIdsToEmail.isEmpty()) {
            // Get the parent Accounts
            List<Account> accountRecordsMap = [SELECT Id, Owner.Email FROM Account WHERE ID IN :accountIdsToEmail];
            
            if(accountRecordsMap.size() > 0) {
                List<String> emailAddressesList = new List<String>();
                for(Account acc : accountRecordsMap) {
                    emailAddressesList.add(acc.Owner.Email);
                }

                if(emailAddressesList.size() > 0) {
                   // Send email
                   ContactTriggerHelper.sendEmailToAccountOwner(emailAddressesList);
                }
                
            }
        }
    }

}