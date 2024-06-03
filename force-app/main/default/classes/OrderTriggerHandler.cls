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

    public static void beforeInsert(List<Order> newOrders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : newOrders) {
            if (ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            List<Account> accounts = [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds];
            for (Account acc : accounts) {
                acc.Active__c = true;
            }
            update accounts;
        }
    }

    public static void afterDelete(List<Order> oldOrders) {
        Set<Id> accountIds = new Set<Id>();
        for (Order ord : oldOrders) {
            if (ord.AccountId != null) {
                accountIds.add(ord.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            // Extraire les IDs des comptes avec d'autres commandes
            Map<Id, Integer> orderCountMap = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT AccountId, COUNT(Id) orderCount
                FROM Order
                WHERE AccountId IN :accountIds
                GROUP BY AccountId
            ]) {
                orderCountMap.put((Id) ar.get('AccountId'), (Integer) ar.get('orderCount'));
            }

            List<Account> accountsToUpdate = new List<Account>();
            for (Account acc : [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds]) {
                if (!orderCountMap.containsKey(acc.Id) || orderCountMap.get(acc.Id) == 0) {
                    acc.Active__c = false;
                    accountsToUpdate.add(acc);
                }
            }
            
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
}
