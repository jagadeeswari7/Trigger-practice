trigger CaseTrigger on Case (before delete, after insert, after update, after delete, after undelete) {

    switch on Trigger.operationType {
        when BEFORE_DELETE {
            CaseTriggerHandler.preventCaseDeletion(Trigger.old);
        }
        /** 
         * Each case can have multiple related cases. Implement a feature that automatically calculates and updates the
         * total resolution days for parent cases based on the days of the related child cases.
         * Also, any changes in the child case records should be reflected in the parent case's resolution time.
         *
         * Questions - How many levels deep this heirarchy can go? 1 level deep
         * Can resolution days be updated manually? No, read-only field
         * When does the resolution days field update? When the case status updates to resolved.
         * Can a case be created in resolved status directly? Yes
        **/
        when AFTER_INSERT {
            CaseTriggerHandler.afterInsertHandler(Trigger.new);
        }
        when AFTER_UPDATE {
            CaseTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        when AFTER_DELETE {
            CaseTriggerHandler.afterDeleteHandler(Trigger.old);
        }
        when AFTER_UNDELETE {
            CaseTriggerHandler.afterUndeleteHandler(Trigger.old);
        }

    }

}