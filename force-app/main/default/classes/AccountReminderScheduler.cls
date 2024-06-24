global class AccountReminderScheduler {

    global static void scheduleMonthlyReminder() {
        String cronExpression = '0 0 0 ? * 2#1 *'; // Every first Monday of the month at midnight
        System.schedule('AccountReminderBatch Job', cronExpression, new AccountReminderBatch());
    }
}


   