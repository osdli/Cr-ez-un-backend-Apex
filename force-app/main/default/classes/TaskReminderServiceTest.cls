@isTest
public class TaskReminderServiceTest {

    @isTest
    static void testCreateReminderTasks() {
        // Créer un utilisateur de test pour être le propriétaire des comptes
        User testUser = TestDataFactory.createTestUser();
        System.runAs(testUser) {
            List<Account> testAccounts = new List<Account>();

            // Créer 10 comptes de test avec un propriétaire valide
            for (Integer i = 0; i < 10; i++) {
                Account acc = new Account(Name = 'Test Account ' + i, OwnerId = testUser.Id);
                testAccounts.add(acc);
            }
            insert testAccounts;
            System.debug('Test Accounts: ' + testAccounts);

            // Créer manuellement les sous-listes
            List<Account> accountsWithOrders = new List<Account>();
            List<Account> accountsWithTasks = new List<Account>();

            for (Integer i = 0; i < 5; i++) {
                accountsWithOrders.add(testAccounts[i]);
            }

            for (Integer i = 5; i < 8; i++) {
                accountsWithTasks.add(testAccounts[i]);
            }

            // Assurez-vous que certains comptes ont des commandes et des tâches existantes
            TestDataFactory.createOrdersForAccounts(accountsWithOrders, 1);
            TestDataFactory.createTasksForAccounts(accountsWithTasks, 'Call', 1);

            System.debug('Accounts with Orders: ' + accountsWithOrders);
            System.debug('Accounts with Tasks: ' + accountsWithTasks);

            // Vérifier les tâches avant l'exécution
            List<Task> existingTasks = [SELECT Id, WhatId, Subject FROM Task WHERE Subject = 'Call'];
            System.debug('Existing Tasks before execution: ' + existingTasks);

            // Appeler la méthode pour créer des tâches de rappel
            Test.startTest();
            TaskReminderService.createReminderTasks(testAccounts);
            Test.stopTest();

            // Vérifier que des tâches de rappel ont été créées pour les comptes sans commandes ni tâches existantes
            List<Task> tasks = [SELECT Id, WhatId, Subject FROM Task WHERE Subject = 'Call' AND CreatedDate = TODAY];
            System.debug('Tasks created: ' + tasks);

            // Identifier les comptes sans commandes ni tâches pour vérifier l'exactitude
            List<Account> expectedAccountsToProcess = new List<Account>();
            for (Account acc : testAccounts) {
                if (!accountsWithOrders.contains(acc) && !accountsWithTasks.contains(acc)) {
                    expectedAccountsToProcess.add(acc);
                }
            }
            System.debug('Expected Accounts to Process: ' + expectedAccountsToProcess);

            // Vérifier si les tâches existantes avant le test ont été incluses dans les nouvelles tâches
            Set<Id> existingTaskIds = new Set<Id>();
            for (Task t : existingTasks) {
                existingTaskIds.add(t.Id);
            }

            Integer newTaskCount = 0;
            for (Task t : tasks) {
                if (!existingTaskIds.contains(t.Id)) {
                    newTaskCount++;
                }
            }

            // Assert que le nombre de tâches créées est correct
            System.assertEquals(expectedAccountsToProcess.size(), newTaskCount, 'Le nombre de tâches créées devrait correspondre au nombre de comptes sans commandes ni tâches existantes');
            for (Task task : tasks) {
                System.assertEquals('Call', task.Subject, 'Le sujet de la tâche devrait être "Call"');
            }
        }
    }
}
