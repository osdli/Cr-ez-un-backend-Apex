@isTest
public class TaskReminderServiceTest {

    @isTest
    static void testCreateReminderTasks() {
        // Créer un utilisateur de test pour posséder les comptes
        User testUser = TestDataFactory.createTestUser();
        System.runAs(testUser) {
            List<Account> testAccounts = new List<Account>();

            // Créer 10 comptes de test avec un propriétaire valide
            for (Integer i = 0; i < 10; i++) {
                Account acc = new Account(Name = 'Test Account ' + i, OwnerId = testUser.Id);
                testAccounts.add(acc);
            }
            insert testAccounts;

            // Créer manuellement des sous-listes
            List<Account> accountsWithOrders = new List<Account>();
            List<Account> accountsWithTasks = new List<Account>();

            for (Integer i = 0; i < 5; i++) {
                accountsWithOrders.add(testAccounts[i]);
            }

            for (Integer i = 5; i < 8; i++) {
                accountsWithTasks.add(testAccounts[i]);
            }

            // S'assurer que certains comptes ont des commandes et des tâches existantes
            TestDataFactory.createOrdersForAccounts(accountsWithOrders, 1);
            TestDataFactory.createTasksForAccounts(accountsWithTasks, 'Call', 1);

            // Vérifier les tâches avant l'exécution
            List<Task> existingTasks = [SELECT Id, WhatId, Subject FROM Task WHERE Subject = 'Call'];

            // Appeler la méthode pour créer des tâches de rappel
            Test.startTest();
            TaskReminderService.createReminderTasks(testAccounts);
            Test.stopTest();

            // Vérifier que les tâches de rappel ont été créées pour les comptes sans commandes ni tâches existantes
            List<Task> tasks = [SELECT Id, WhatId, Subject FROM Task WHERE Subject = 'Call' AND CreatedDate = TODAY];

            // Identifier les comptes sans commandes ni tâches pour vérifier l'exactitude
            List<Account> expectedAccountsToProcess = new List<Account>();
            for (Account acc : testAccounts) {
                if (!accountsWithOrders.contains(acc) && !accountsWithTasks.contains(acc)) {
                    expectedAccountsToProcess.add(acc);
                }
            }

            // Vérifier si les tâches existantes avant le test étaient incluses dans les nouvelles tâches
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

            // Vérifier que le nombre de tâches créées est correct
            Assert.areEqual(expectedAccountsToProcess.size(), newTaskCount, 'Le nombre de tâches créées devrait correspondre au nombre de comptes sans commandes ni tâches existantes');
            for (Task task : tasks) {
                Assert.areEqual('Call', task.Subject, 'Le sujet de la tâche devrait être "Call"');
            }
        }
    }
}
