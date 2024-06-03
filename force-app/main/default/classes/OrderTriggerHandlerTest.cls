@isTest
public class OrderTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Création des données de test nécessaires pour tous les tests
        Account testAccount = TestDataFactory.createAccount();
        Contract testContract = TestDataFactory.createContract(testAccount.Id);
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

        // Ajouter un OrderItem (produit) à la commande
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

        // Ajouter un OrderItem (produit) à la commande
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

        // Ajouter un OrderItem (produit) à la commande
        OrderItem ordItem = new OrderItem(
            OrderId = ord.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem;
        
        Test.startTest();
        
        // Mise à jour sans changement
        update ord;
        
        Test.stopTest();
        
        Order updatedOrder = [SELECT Status, EffectiveDate FROM Order WHERE Id = :ord.Id];
        System.assertEquals('Draft', updatedOrder.Status);
        System.assertEquals(Date.today(), updatedOrder.EffectiveDate);
    }
}
