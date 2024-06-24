global class AccountReminderBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static Date testExecutionDate;

    global AccountReminderBatch() {
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OwnerId FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        Date todayDate = testExecutionDate != null ? testExecutionDate : Date.today();
        
        // Check if today is the first Monday of the month
        if (isFirstMondayOfMonth(todayDate)) {
            System.debug('Scope: ' + scope);
            TaskReminderService.createReminderTasks(scope);
        } else {
            System.debug('Today is not the first Monday of the month. No tasks created.');
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Notification ou autre logique de fin de traitement
    }

    private Boolean isFirstMondayOfMonth(Date todayDate) {
        Date firstDayOfMonth = Date.newInstance(todayDate.year(), todayDate.month(), 1);
        Integer dayOfWeek = Datetime.newInstance(firstDayOfMonth.year(), firstDayOfMonth.month(), firstDayOfMonth.day(), 0, 0, 0).dayOfWeek();
        Integer daysToFirstMonday = (8 - dayOfWeek) % 7; // Calculer le nombre de jours jusqu'au premier lundi
        Date firstMonday = firstDayOfMonth.addDays(daysToFirstMonday);

        return todayDate == firstMonday;
    }

    @TestVisible
    static void setTestDate(Date testDate) {
        testExecutionDate = testDate;
    }
}
