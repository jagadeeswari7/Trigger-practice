// Whenever a Task is created, set the Priority to High
// Whenever a Task is updated, set the Description.
trigger TaskTrigger on Task (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
        for(Task taskRec : Trigger.new) {
            taskRec.Priority = 'High';
        }
    }else if(Trigger.isBefore && Trigger.isUpdate) {
        for(Task taskRec : Trigger.new) {
            taskRec.Description = 'Task created via '+taskRec.Subject;
        }
    }
   
}