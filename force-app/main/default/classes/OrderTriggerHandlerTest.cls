@isTest
public class OrderTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Créer les données de test nécessaires pour tous les tests
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
        // Cas de test pour vérifier la mise à jour du statut de la commande sans produits
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contract con = [SELECT Id, Status FROM Contract WHERE AccountId = :acc.Id LIMIT 1];
        con.Status = 'Activated';
        update con;

        Order ord = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;

        Test.startTest();

        ord.Status = 'Activated';
        try {
            update ord;
            System.assert(false, 'Expected DMLException not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('You cannot activate this order because it does not have any associated products.'));
        }

        Test.stopTest();
    }

    @isTest
    static void testOrderStatusUpdateWithProducts() {
        // Cas de test pour vérifier la mise à jour du statut de la commande avec produits
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contract con = [SELECT Id, Status FROM Contract WHERE AccountId = :acc.Id LIMIT 1];
        con.Status = 'Activated';
        update con;

        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        Order ord = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;

        OrderItem ordItem = new OrderItem(
            OrderId = ord.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem;

        Test.startTest();

        ord.Status = 'Activated';
        update ord;

        Test.stopTest();

        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :ord.Id];
        System.assertEquals('Activated', updatedOrder.Status);
    }

    @isTest
    static void testOrderFieldUpdate() {
        // Cas de test pour vérifier la mise à jour d'un autre champ de la commande
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contract con = [SELECT Id, Status FROM Contract WHERE AccountId = :acc.Id LIMIT 1];
        con.Status = 'Activated';
        update con;

        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        Order ord = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            Description = 'Initial Description'
        );
        insert ord;

        OrderItem ordItem = new OrderItem(
            OrderId = ord.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem;

        Test.startTest();

        ord.Description = 'Updated Description';
        update ord;

        Test.stopTest();

        Order updatedOrder = [SELECT Description FROM Order WHERE Id = :ord.Id];
        System.assertEquals('Updated Description', updatedOrder.Description);
    }

    @isTest
    static void testOrderWithNoChanges() {
        // Cas de test où il n'y a pas de changement dans la commande
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contract con = [SELECT Id, Status FROM Contract WHERE AccountId = :acc.Id LIMIT 1];
        con.Status = 'Activated';
        update con;

        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        Order ord = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;

        OrderItem ordItem = new OrderItem(
            OrderId = ord.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem;

        Test.startTest();

        update ord;

        Test.stopTest();

        Order updatedOrder = [SELECT Status, EffectiveDate FROM Order WHERE Id = :ord.Id];
        System.assertEquals('Draft', updatedOrder.Status);
        System.assertEquals(Date.today(), updatedOrder.EffectiveDate);
    }

    @isTest
    static void testAccountIsActiveAfterOrderInsertion() {
        // Récupérer le compte "Test Account"
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        // Vérifier que le champ Active__c est actif ou non
        System.assertEquals(false, acc.Active__c, 'Account should be inactive initially');
    
        // Insérer un nouvel ordre
        Order newOrder = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert newOrder;
    
        // Vérifier que le compte devient actif après l'insertion de l'ordre
        Account updatedAccount = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, updatedAccount.Active__c, 'Account should become active after order insertion');
    }

    @isTest
    static void testAccountRemainsActiveAfterSingleOrderDeletion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        System.assertEquals(false, acc.Active__c, 'Account should be inactive initially');

        Contract con = [SELECT Id, Status FROM Contract WHERE AccountId = :acc.Id LIMIT 1];
        con.Status = 'Activated';
        update con;

        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        Order ord1 = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord1;

        OrderItem ordItem1 = new OrderItem(
            OrderId = ord1.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem1;

        // Créer une autre commande
        Order ord2 = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord2;

        OrderItem ordItem2 = new OrderItem(
            OrderId = ord2.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem2;

        // Marquer le compte comme actif
        acc.Active__c = true;
        update acc;

        // Vérifier que la configuration est correcte
        Account updatedAcc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, updatedAcc.Active__c, 'Account should be active after setup');

        // Tester la suppression d'une commande, le compte doit rester actif
        Test.startTest();
        delete ord1;
        Test.stopTest();

        Account updatedAccAfterDelete = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, updatedAccAfterDelete.Active__c, 'Account should remain active after deleting one order');
    }

    @isTest
    static void testAccountBecomesInactiveAfterAllOrdersDeletion() {
        Account acc = [SELECT Id, Active__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        System.assertEquals(false, acc.Active__c, 'Account should be inactive initially');

        Contract con = [SELECT Id, Status FROM Contract WHERE AccountId = :acc.Id LIMIT 1];
        con.Status = 'Activated';
        update con;

        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        Order ord1 = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord1;

        OrderItem ordItem1 = new OrderItem(
            OrderId = ord1.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem1;

        // Créer une autre commande
        Order ord2 = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord2;

        OrderItem ordItem2 = new OrderItem(
            OrderId = ord2.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem2;

        // Marquer le compte comme actif
        acc.Active__c = true;
        update acc;

        // Supprimer la première commande
        delete ord1;

        // Tester la suppression de la deuxième commande, le compte doit devenir inactif
        Test.startTest();
        delete ord2;
        Test.stopTest();

        Account updatedAcc2 = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(false, updatedAcc2.Active__c, 'Account should be inactive after deleting all orders');
    }

    @isTest
    static void testHighVolumeOrders() {
        // Test pour vérifier la mise à jour du champ Active__c avec un grand volume de commandes
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id priceBookEntryId = TestDataFactory.createTestProductAndPriceBookEntry();

        List<Order> orders = new List<Order>();
        List<OrderItem> orderItems = new List<OrderItem>();

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

        // Vérifier que le compte est actif après l'insertion des commandes
        Account updatedAcc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, updatedAcc.Active__c, 'Account should be active after inserting high volume of orders');

        Test.startTest();
        delete orders;
        Test.stopTest();

        // Vérifier que le compte devient inactif après la suppression de toutes les commandes
        updatedAcc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(false, updatedAcc.Active__c, 'Account should be inactive after deleting all high volume orders');
    }
}
