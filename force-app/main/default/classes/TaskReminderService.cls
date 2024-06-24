public class TaskReminderService {

    public static void createReminderTasks(List<Account> accounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        // Récupérer les comptes avec des commandes
        Set<Id> accountIdsWithOrders = new Set<Id>();
        for (Order ord : [SELECT AccountId FROM Order WHERE AccountId IN :accountIds]) {
            accountIdsWithOrders.add(ord.AccountId);
        }
        System.debug('accountIdsWithOrders: ' + accountIdsWithOrders);

        // Récupérer les tâches avec le sujet 'Call'
        Set<Id> accountIdsWithTasks = new Set<Id>();
        for (Task t : [SELECT WhatId FROM Task WHERE WhatId IN :accountIds AND Subject = 'Call']) {
            accountIdsWithTasks.add(t.WhatId);
        }
        System.debug('accountIdsWithTasks: ' + accountIdsWithTasks);

        // Filtrer les comptes sans commandes ni tâches
        List<Account> accountsToProcess = new List<Account>();
        for (Account acc : accounts) {
            if (!accountIdsWithOrders.contains(acc.Id) && !accountIdsWithTasks.contains(acc.Id)) {
                accountsToProcess.add(acc);
            }
        }
        System.debug('accountsToProcess: ' + accountsToProcess);

        // Créer des tâches de rappel
        List<Task> tasksToInsert = new List<Task>();
        for (Account acc : accountsToProcess) {
            Task reminderTask = new Task(
                Subject = 'Call',
                Status = 'New',
                Priority = 'Normal',
                OwnerId = acc.OwnerId,
                WhatId = acc.Id,
                ActivityDate = Date.today() + 5
            );
            tasksToInsert.add(reminderTask);
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
        System.debug('tasksToInsert: ' + tasksToInsert);
    }
}
