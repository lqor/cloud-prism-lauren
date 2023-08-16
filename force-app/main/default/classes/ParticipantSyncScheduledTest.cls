@IsTest
public with sharing class ParticipantSyncScheduledTest {

    @IsTest
    static void scheduler_UnitTest() {
        ParticipantSyncScheduled reminder = new ParticipantSyncScheduled();
        String cronExpression = '0 0 0 ? * * *';

        Test.startTest();
        String jobId = System.schedule('Participant Sync Batch', cronExpression, reminder);
        Test.stopTest();

        CronTrigger cronTrigger = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE Id = :jobId
        ];
        Assert.areEqual(cronExpression, cronTrigger.CronExpression);
        Assert.areEqual(0, cronTrigger.TimesTriggered);
    }

}