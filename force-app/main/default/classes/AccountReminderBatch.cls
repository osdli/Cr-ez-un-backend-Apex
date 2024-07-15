global class AccountReminderBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OwnerId FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        TaskReminderService.createReminderTasks(scope);
    }

    global void finish(Database.BatchableContext BC) {
        // Notification ou autre
    }
}