trigger OrderTrigger on Order (before update, before delete) {
    if (Trigger.isUpdate) {
        OrderTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isDelete) {
        OrderTriggerHandler.beforeDelete(Trigger.old);
    }
}



