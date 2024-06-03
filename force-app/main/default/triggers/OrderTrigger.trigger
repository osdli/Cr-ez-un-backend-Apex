trigger OrderTrigger on Order (before insert, before update, after delete) {
    if (Trigger.isInsert && Trigger.isBefore) {
        OrderTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        OrderTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isDelete && Trigger.isAfter
    ) {
        OrderTriggerHandler.afterDelete(Trigger.old);
    }
}
