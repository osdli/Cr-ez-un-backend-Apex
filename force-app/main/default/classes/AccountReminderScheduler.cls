global class AccountReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AccountReminderBatch());
    }

    global static void scheduleMonthlyReminder() {
        String cronExpression = '0 0 0 ? * 2#1 *'; // Lancer chaque premier Lundi du mois
        System.schedule('AccountReminderBatch Job', cronExpression, new AccountReminderScheduler());
    }
}


   