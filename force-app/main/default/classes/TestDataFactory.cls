@isTest
public class TestDataFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        return acc;
    }

    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        return accounts;
    }

    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            ContractTerm = 12,
            StartDate = Date.today() 
        );
        insert contract;
        return contract;
    }

    public static Id createTestProductAndPriceBookEntry() {
        Product2 prod = new Product2(Name = 'GenWatt Diesel 10kW', ProductCode = 'GC1020');
        insert prod;

        Id standardPBId = Test.getStandardPricebookId();

        PriceBookEntry standardPBE = new PriceBookEntry(
            Product2Id = prod.Id,
            PriceBook2Id = standardPBId,
            UnitPrice = 5000.00,
            IsActive = true
        );
        insert standardPBE;
        
        return standardPBE.Id;
    }
    
    public static Order createOrder(Id accountId) {
        Order ord = new Order(
            AccountId = accountId,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert ord;
        return ord;
    }

    public static List<Order> createOrdersForAccounts(List<Account> accounts, Integer ordersPerAccount) {
        List<Order> orders = new List<Order>();
        for (Account acc : accounts) {
            for (Integer i = 0; i < ordersPerAccount; i++) {
                orders.add(new Order(
                    AccountId = acc.Id,
                    Status = 'Draft',
                    EffectiveDate = Date.today()
                ));
            }
        }
        insert orders;
        return orders;
    }

    public static Task createTask(Id whatId, String subject) {
        Task task = new Task(
            WhatId = whatId,
            Subject = subject,
            Status = 'Completed'
        );
        insert task;
        return task;
    }

    public static List<Task> createTasksForAccounts(List<Account> accounts, String subject, Integer tasksPerAccount) {
        List<Task> tasks = new List<Task>();
        for (Account acc : accounts) {
            for (Integer i = 0; i < tasksPerAccount; i++) {
                tasks.add(new Task(
                    WhatId = acc.Id,
                    Subject = subject,
                    ActivityDate = System.today()
                ));
            }
        }
        insert tasks;
        return tasks;
    }

    public static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;
        return testUser;
    }

    public static Order createOrderWithStatus(Account acc, String status) {
        Order ord = new Order(
            AccountId = acc.Id,
            Status = status,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;
        return ord;
    }

    public static void addOrderItem(Order ord, Id priceBookEntryId) {
        OrderItem ordItem = new OrderItem(
            OrderId = ord.Id,
            Quantity = 1,
            PricebookEntryId = priceBookEntryId,
            UnitPrice = 5000.00
        );
        insert ordItem;
    }
}
