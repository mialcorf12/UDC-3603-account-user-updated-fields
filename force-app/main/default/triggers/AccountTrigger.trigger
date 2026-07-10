trigger AccountTrigger on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        AccountTriggerHandler.handleDynamicUpdate(Trigger.new, Trigger.oldMap);
    }
}