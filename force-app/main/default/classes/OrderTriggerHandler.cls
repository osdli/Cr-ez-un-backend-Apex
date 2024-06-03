public class OrderTriggerHandler {
    public static void beforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        for (Order ord : newOrders) {
            if (ord.Status == 'Activated' && ord.Status != oldOrderMap.get(ord.Id).Status) {
                checkOrderProducts(ord);
            }
        }
    }

    private static void checkOrderProducts(Order ord) {
        List<OrderItem> products = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id];
        if (products.isEmpty()) {
            ord.addError('You cannot activate this order because it does not have any associated products. Please add products before activating the order.');
        }
    }
}
