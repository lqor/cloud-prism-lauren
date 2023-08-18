@IsTest
public with sharing class ErrorLogCleanupScheduledTest {

    @IsTest
    static void scheduler_UnitTest() {
        ErrorLogCleanupScheduled cleanup = new ErrorLogCleanupScheduled();
        String cronExpression = '0 0 0 ? * * *';

        Test.startTest();
        String jobId = System.schedule('Error Log Cleanup Batch', cronExpression, cleanup);
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