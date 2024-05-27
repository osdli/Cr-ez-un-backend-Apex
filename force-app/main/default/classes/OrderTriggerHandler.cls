public class OrderTriggerHandler {
    public static void checkOrderProducts(Order ord) {
        List<OrderItem> products = [SELECT Id FROM OrderItem WHERE OrderId = :ord.Id];
        if (products.isEmpty()) {
            ord.addError('Cannot activate Order without associated products.');
        }
    }
}
