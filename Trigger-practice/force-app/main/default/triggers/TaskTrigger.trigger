//Whenever a Task is created, set the Priority to High
trigger TaskTrigger on Task (before insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        for(Task taskRec : Trigger.new) {
            taskRec.Priority = 'High';
        }
    }
   
}