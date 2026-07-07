trigger ContactTrigger on Contact (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.handleDynamicUpdate(Trigger.new, Trigger.oldMap);
    }
}
