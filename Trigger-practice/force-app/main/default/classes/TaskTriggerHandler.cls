public with sharing class TaskTriggerHandler {
    public static void handleActivitiesBeforeInsert(List<Task> newTasks) {
        for(Task taskRec : newTasks) {
            taskRec.Priority = 'High';
        }
    }

    public static void handleActivitiesBeforeUpdate(List<Task> newTasks) {
        //Allow updating the Task record only if the parent Contact’s Account has the Modify Task Permission checked
        List<Id> contactIds = new List<Id>();
        for(Task taskRec : newTasks) {
            if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWith('003')) {
                contactIds.add(taskRec.WhoId);
            }
        }
        if(contactIds.size() > 0) {
            Map<Id, Boolean> contactCheckBoxMap = new Map<Id, Boolean>();
            for(Contact con : [SELECT ID, Account.Modify_Task_Permission__c from Contact where ID in :contactIds] ) {
                contactCheckBoxMap.put(con.Id, (Boolean)con.Account.Modify_Task_Permission__c);
            }

            if(contactCheckBoxMap.size() > 0) {
                for(task taskRec : newTasks) {
                    if(!contactCheckBoxMap.get(taskRec.WhoId)) {
                        taskRec.addError('Cannot modify as you dont have required permission');
                    }
                }
            }
        }
    }

    public static void handleActivitiesAfterInsert(List<Task> newTasks) {
        Map<Id, Integer> contactCountMap = new Map<Id, Integer>();
        for(Task taskRec : newTasks) {
            if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWith('003')) {
                if(contactCountMap.containsKey(taskRec.WhoId)) {
                    contactCountMap.put(taskRec.WhoId, contactCountMap.get(taskRec.WhoId)+1);
                }else{
                    contactCountMap.put(taskRec.WhoId, 1);
                }
            }
        }
        List<Contact> contactsToAdd = new List<Contact>();
        for(Contact con : [SELECT Id,Number_Of_Tasks_Associated__c from Contact WHERE ID IN :contactCountMap.keySet()]) {
            if(con.Number_Of_Tasks_Associated__c != null) {
                con.Number_Of_Tasks_Associated__c += contactCountMap.get(con.Id);
            }else{
                con.Number_Of_Tasks_Associated__c = 1;
            }
            contactsToAdd.add(con);
        }

        if(contactsToAdd.size() > 0){
            update contactsToAdd;
        }
    }
}