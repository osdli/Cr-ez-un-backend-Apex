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

    public static void beforeDelete(List<Order> oldOrders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : oldOrders) {
            if (ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            List<Account> accounts = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds];
            for (Account acc : accounts) {
                Boolean hasOtherOrders = [SELECT COUNT() FROM Order WHERE AccountId = :acc.Id AND Id NOT IN :oldOrders] > 0;
                if (!hasOtherOrders) {
                    acc.Active__c = 'No';
                }
            }
            update accounts;
        }
    }
}

