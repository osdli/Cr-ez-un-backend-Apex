@isTest
private class AccountReminderBatchTest {
    
    @testSetup
    static void setup() {
       
        List<Account> accounts = TestDataFactory.createAccounts(200);
        
        // Créer des commandes pour les 100 premiers comptes pour simuler des données existantes
        List<Account> accountsWithOrders = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            accountsWithOrders.add(accounts[i]);
        }
        TestDataFactory.createOrdersForAccounts(accountsWithOrders, 1);
        
        // Créer des tâches avec le sujet 'Call' pour les 50 comptes suivants
        List<Account> accountsWithTasks = new List<Account>();
        for (Integer i = 100; i < 150; i++) {
            accountsWithTasks.add(accounts[i]);
        }
        TestDataFactory.createTasksForAccounts(accountsWithTasks, 'Call', 1);
    }
    
    @isTest
    static void testAccountReminderBatchProcessesAllAccounts() {
        Test.startTest();
        
        // Exécuter le lot
        AccountReminderBatch batchInstance = new AccountReminderBatch();
        Database.executeBatch(batchInstance);
        
        Test.stopTest();
        
        // Vérifier les résultats
        // Récupérer toutes les tâches créées aujourd'hui avec le sujet 'Call'
        List<Task> createdTasks = [SELECT Id, WhatId, Subject FROM Task WHERE Subject = 'Call' AND CreatedDate = TODAY];
        
        // Récupérer tous les comptes
        List<Account> allAccounts = [SELECT Id FROM Account];
        
        // Récupérer les comptes avec des commandes
        List<Order> orders = [SELECT AccountId FROM Order];
        Set<Id> accountsWithOrders = new Set<Id>();
        for (Order order : orders) {
            accountsWithOrders.add(order.AccountId);
        }
        
        // Récupérer les comptes avec des tâches créées avant aujourd'hui
        List<Task> tasks = [SELECT WhatId FROM Task WHERE Subject = 'Call' AND CreatedDate < TODAY];
        Set<Id> accountsWithTasks = new Set<Id>();
        for (Task task : tasks) {
            accountsWithTasks.add(task.WhatId);
        }
        
        // Identifier les comptes qui auraient dû avoir des tâches créées
        Set<Id> expectedAccountIdsToProcess = new Set<Id>();
        for (Account acc : allAccounts) {
            if (!accountsWithOrders.contains(acc.Id) && !accountsWithTasks.contains(acc.Id)) {
                expectedAccountIdsToProcess.add(acc.Id);
            }
        }

        // Vérifier que le nombre de tâches créées est conforme aux attentes
        System.assertEquals(expectedAccountIdsToProcess.size(), createdTasks.size(), 'Le nombre de tâches créées devrait correspondre au nombre de comptes sans commandes ni tâches existantes');
        for (Task task : createdTasks) {
            System.assertEquals('Call', task.Subject, 'Le sujet de la tâche devrait être "Call"');
        }
    }
}
