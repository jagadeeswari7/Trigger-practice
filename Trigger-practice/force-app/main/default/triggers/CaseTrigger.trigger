trigger CaseTrigger on Case (before delete) {

    if(Trigger.isDelete) {
        CaseTriggerHandler.preventCaseDeletion(Trigger.old);
    }
}