public with sharing class TaskTriggerHandler {
    public static void handleActivitiesBeforeInsert(List<Task> newTasks) {
        for(Task taskRec : newTasks) {
            taskRec.Priority = 'High';
        }
    }

    public static void handleActivitiesBeforeUpdate(List<Task> newTasks) {
        for(Task taskRec : newTasks) {
            taskRec.Description = 'Task created via '+taskRec.Subject;
        }
    }

    public static void handleActivitiesAfterInsert(List<Task> newTasks) {
        Map<Id, Integer> contactCountMap = new Map<Id, Integer>();
        for(Task taskRec : newTasks) {
            if(String.valueOf(taskRec.WhoId).startsWith('003')) {
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