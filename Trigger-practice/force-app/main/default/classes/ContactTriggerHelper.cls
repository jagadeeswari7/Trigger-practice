public with sharing class ContactTriggerHelper {
    public static void sendEmailToAccountOwner(List<String> emailAddressesList) {
        // Get the email template
        /* Sending of email */
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailAddressesList;
        message.subject = 'Contact email or phone modified';
        message.plaintextbody = 'The email or phone information of your child contact has been modified, Please confirm!';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);
    }
}