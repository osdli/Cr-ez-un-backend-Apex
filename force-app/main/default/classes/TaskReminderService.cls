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

        // Récupérer les comptes avec des tâches
        Set<Id> accountIdsWithTasks = new Set<Id>();
        for (Task t : [SELECT WhatId FROM Task WHERE WhatId IN :accountIds]) {
            accountIdsWithTasks.add(t.WhatId);
        }

        // Filtrer les comptes sans commandes ni tâches
        List<Account> accountsToProcess = new List<Account>();
        for (Account acc : accounts) {
            if (!accountIdsWithOrders.contains(acc.Id) && !accountIdsWithTasks.contains(acc.Id)) {
                accountsToProcess.add(acc);
            }
        }

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
    }
}
