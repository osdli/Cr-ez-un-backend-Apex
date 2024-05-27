trigger OrderTrigger on Order (before update) {
    if (Trigger.isUpdate) {
        for (Order ord : Trigger.new) {
            if (ord.Status == 'Active' && ord.Status != Trigger.oldMap.get(ord.Id).Status) {
                OrderTriggerHandler.checkOrderProducts(ord);
            }
        }
    }
}
