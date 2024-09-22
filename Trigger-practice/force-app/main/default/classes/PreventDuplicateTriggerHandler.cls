public with sharing class PreventDuplicateTriggerHandler {
    public static void checkForDuplicateContacts(List<Contact> newContacts) {
        Set<String> uniqueEmails = new Set<String>();

        for(Contact con : newContacts) {
            if(con.Email != null) {
                uniqueEmails.add(con.Email);
            }
        }

        // Query existing contacts with the same unique keys
        Map<String, Contact> existingContacts = new Map<String, Contact>();
        if (!uniqueEmails.isEmpty()) {
            for (Contact existingContact : [SELECT Email FROM Contact WHERE Email IN :uniqueEmails]) {
                existingContacts.put(existingContact.Email, existingContact);
            }
        }

        // Check for duplicates with existing records
        for(Contact con : newContacts) {
            if(existingContacts.containsKey(con.Email)) {
                con.addError('Duplicate contacts are not allowed with same email');
            }
        }
    }
}