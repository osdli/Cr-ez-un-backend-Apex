global class AccountReminderScheduler {

    global static void scheduleMonthlyReminder() {
        String cronExpression = '0 0 0 ? * 2#1 *'; // Lancer chaque Lundi du mois
        System.schedule('AccountReminderBatch Job', cronExpression, new AccountReminderBatch());
    }
}


   