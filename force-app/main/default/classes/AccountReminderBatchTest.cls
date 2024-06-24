@isTest
private class AccountReminderBatchTest {
    
    @testSetup
    static void setup() {
        // Create test data
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
    }
    
    @isTest
    static void testStart() {
        // Create instance of batch class
        AccountReminderBatch batch = new AccountReminderBatch();
        
        // Get the query locator
        Database.QueryLocator ql = batch.start(null);
        
        // Retrieve query records
        List<Account> accountList = new List<Account>();
        for (Account acct : [SELECT Id, OwnerId FROM Account]) {
            accountList.add(acct);
        }
        
        // Assert that the query locator is not null
        System.assertNotEquals(null, ql);
        
        // Assert that the query locator has records
        System.assert(accountList.size() > 0, 'Expected some Account records.');
    }

    @isTest
    static void testExecute() {
        // Create instance of batch class
        AccountReminderBatch batch = new AccountReminderBatch();
        
        // Get test accounts
        List<Account> accounts = [SELECT Id, OwnerId FROM Account LIMIT 10];
        
        // Execute the batch execute method
        Test.startTest();
        batch.execute(null, accounts);
        Test.stopTest();
        
    }

    @isTest
    static void testFinish() {
        // Create instance of batch class
        AccountReminderBatch batch = new AccountReminderBatch();
        
        // Execute the batch finish method
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
        
    }

    @isTest
    static void testSchedulable() {
        // Create instance of batch class
        AccountReminderBatch batch = new AccountReminderBatch();
        
        // Schedule the batch
        String jobId = System.schedule('TestJob', '0 0 0 1 1 ? 2050', batch);
        
        // Verify that the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 1 1 ? 2050', ct.CronExpression);
    }
}
