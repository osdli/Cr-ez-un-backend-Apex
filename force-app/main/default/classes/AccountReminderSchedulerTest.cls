@isTest
public class AccountReminderSchedulerTest {

    @isTest
    static void testScheduleMonthlyReminder() {
        Test.startTest();
        AccountReminderScheduler.scheduleMonthlyReminder();
        Test.stopTest();
        
        // Vérifier que le job a été planifié
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger 
                          WHERE CronJobDetail.Name = 'AccountReminderBatch Job' LIMIT 1];
        
        Assert.isNotNull(ct, 'Le job devrait être planifié');
        Assert.areEqual('0 0 0 ? * 2#1 *', ct.CronExpression, 'L\'expression CRON devrait être correcte');
        Assert.areEqual(0, ct.TimesTriggered, 'Le job ne devrait pas encore avoir été déclenché');
        Assert.isNotNull(ct.NextFireTime, 'Il devrait y avoir une prochaine heure de déclenchement prévue');
    }
}
