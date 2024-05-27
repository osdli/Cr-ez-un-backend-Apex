public class OrderTriggerHandler {
    public static void beforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        for (Order ord : newOrders) {
            if (ord.Status == 'Active' && ord.Status != oldOrderMap.get(ord.Id).Status) {
                checkOrderProducts(ord);
            }
        }
    }

    private static void checkOrderProducts(Order ord) {
        List<OrderItem> products = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id];
        if (products.isEmpty()) {
            ord.addError('Cannot activate Order without associated products.');
        }
    }
}

