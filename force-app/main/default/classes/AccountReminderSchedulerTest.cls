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
        
        System.assertNotEquals(null, ct, 'Le job devrait être planifié');
        System.assertEquals('0 0 0 ? * 2#1 *', ct.CronExpression, 'L\'expression CRON devrait être correcte');
        System.assertEquals(0, ct.TimesTriggered, 'Le job ne devrait pas encore avoir été déclenché');
        System.assertNotEquals(null, ct.NextFireTime, 'Il devrait y avoir une prochaine heure de déclenchement prévue');
    }
}
