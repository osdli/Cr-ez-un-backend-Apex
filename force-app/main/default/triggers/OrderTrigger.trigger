trigger OrderTrigger on Order (before update) {
    if (Trigger.isUpdate) {
        OrderTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}

