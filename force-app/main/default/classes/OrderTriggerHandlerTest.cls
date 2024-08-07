@isTest
public class OrderTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account', Active__c = false);
        insert testAccount;

        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            Status = 'Draft',
            ContractTerm = 12,
            StartDate = Date.today()
        );
        insert testContract;

        TestDataFactory.createTestProductAndPriceBookEntry();
    }

    @isTest
    static void testOrderStatusUpdateWithoutProducts() {
        // Test de mise à jour du statut d'une commande sans produits associés
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Order ord = TestDataFactory.createOrderWithStatus(acc, 'Draft');

        Test.startTest();
        ord.Status = 'Activated';
        try {
            update ord;
            Assert.fail('Expected DMLException not thrown');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('You cannot activate this order because it does not have any associated products.'));
        }
        Test.stopTest();
    }

    @isTest
    static void testOrderStatusUpdateWithProducts() {
        // Test de mise à jour du statut d'une commande avec produits associés
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();
        Order ord = TestDataFactory.createOrderWithStatus(acc, 'Draft');
        TestDataFactory.addOrderItem(ord, priceBookEntryId);

        Test.startTest();
        ord.Status = 'Activated';
        update ord;
        Test.stopTest();

        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :ord.Id];
        Assert.areEqual('Activated', updatedOrder.Status);
    }

    @isTest
    static void testOrderFieldUpdate() {
        // Test de mise à jour d'un autre champ de la commande
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();
        Order ord = TestDataFactory.createOrderWithStatus(acc, 'Draft');
        TestDataFactory.addOrderItem(ord, priceBookEntryId);

        Test.startTest();
        ord.Description = 'Updated Description';
        update ord;
        Test.stopTest();

        Order updatedOrder = [SELECT Description FROM Order WHERE Id = :ord.Id];
        Assert.areEqual('Updated Description', updatedOrder.Description);
    }

    @isTest
    static void testOrderWithNoChanges() {
        // Test sans changement de la commande
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();
        Order ord = TestDataFactory.createOrderWithStatus(acc, 'Draft');
        TestDataFactory.addOrderItem(ord, priceBookEntryId);

        Test.startTest();
        update ord;
        Test.stopTest();

        Order updatedOrder = [SELECT Status, EffectiveDate FROM Order WHERE Id = :ord.Id];
        Assert.areEqual('Draft', updatedOrder.Status);
        Assert.areEqual(Date.today(), updatedOrder.EffectiveDate);
    }

    @isTest
    static void testAccountIsActiveAfterOrderInsertion() {
        // Test pour vérifier que le compte devient actif après l'insertion d'une commande
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Assert.isFalse(acc.Active__c, 'Account should be inactive initially');

        Order newOrder = TestDataFactory.createOrderWithStatus(acc, 'Draft');

        Account updatedAccount = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        Assert.isTrue(updatedAccount.Active__c, 'Account should become active after order insertion');
    }

    @isTest
    static void testAccountRemainsActiveAfterSingleOrderDeletion() {
        // Test pour vérifier que le compte reste actif après la suppression d'une commande
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        Order ord1 = TestDataFactory.createOrderWithStatus(acc, 'Draft');
        TestDataFactory.addOrderItem(ord1, priceBookEntryId);
        Order ord2 = TestDataFactory.createOrderWithStatus(acc, 'Draft');
        TestDataFactory.addOrderItem(ord2, priceBookEntryId);

        acc.Active__c = true;
        update acc;

        Test.startTest();
        delete ord1;
        Test.stopTest();

        Account updatedAccAfterDelete = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        Assert.isTrue(updatedAccAfterDelete.Active__c, 'Account should remain active after deleting one order');
    }

    @isTest
    static void testAccountBecomesInactiveAfterAllOrdersDeletion() {
        // Test pour vérifier que le compte devient inactif après la suppression de toutes les commandes
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        Order ord1 = TestDataFactory.createOrderWithStatus(acc, 'Draft');
        TestDataFactory.addOrderItem(ord1, priceBookEntryId);
        Order ord2 = TestDataFactory.createOrderWithStatus(acc, 'Draft');
        TestDataFactory.addOrderItem(ord2, priceBookEntryId);

        acc.Active__c = true;
        update acc;

        delete ord1;

        Test.startTest();
        delete ord2;
        Test.stopTest();

        Account updatedAcc2 = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        Assert.isFalse(updatedAcc2.Active__c, 'Account should be inactive after deleting all orders');
    }

    @isTest
    static void testHighVolumeOrders() {
        // Test pour vérifier la mise à jour du champ Active__c avec un grand volume de commandes
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 250; i++) {
            Order ord = new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id = Test.getStandardPricebookId()
            );
            orders.add(ord);
        }
        insert orders;

        List<OrderItem> orderItems = new List<OrderItem>();
        for (Order ord : orders) {
            OrderItem ordItem = new OrderItem(
                OrderId = ord.Id,
                Quantity = 1,
                PricebookEntryId = priceBookEntryId,
                UnitPrice = 5000.00
            );
            orderItems.add(ordItem);
        }
        insert orderItems;

        Account updatedAcc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        Assert.isTrue(updatedAcc.Active__c, 'Account should be active after inserting high volume of orders');

        Test.startTest();
        delete orders;
        Test.stopTest();

        updatedAcc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        Assert.isFalse(updatedAcc.Active__c, 'Account should be inactive after deleting all high volume orders');
    }
}
