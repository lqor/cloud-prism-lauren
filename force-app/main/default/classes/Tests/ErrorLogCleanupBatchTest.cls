@IsTest
public with sharing class ErrorLogCleanupBatchTest {

    @TestSetup
    static void setup() {
        List<ErrorLog__c> errorLogs = new List<ErrorLog__c>();

        for(Integer i = 0; i < 20; i++) {
            ErrorLog__c log = new ErrorLog__c();

            if(Math.mod(i, 2) == 0) {
                log.Name = 'Important Log ' + i;
                log.Important__c = true;
            } else {
                log.Name = 'Unimportant Log ' + i;
                log.Important__c = false;
            }

            errorLogs.add(log);
        }

        insert errorLogs;

        for(ErrorLog__c log : errorLogs) {
            Test.setCreatedDate(log.Id, Date.today().addDays(-100));
        }

        update errorLogs;
    }

    @IsTest
    static void executeBatch_UnitTest() {
        ErrorLogCleanupMetadata__mdt ErrorLogCleanupMdt = ErrorLogCleanupMetadataQueries.queryErrorLogCleanupMetadata();
        Date retentionDate = System.today().addDays(ErrorLogCleanupMdt.RetentionDays__c.intValue());
        List<ErrorLog__c> importantLogs = [SELECT Id, Important__c FROM ErrorLog__c WHERE Important__c = true];

        Test.startTest();
        Database.executeBatch(new ErrorLogCleanupBatch());
        Test.stopTest();

        List<ErrorLog__c> retainedLogs = [SELECT Id, CreatedDate, Important__c FROM ErrorLog__c];
        Assert.areEqual(importantLogs.size(), retainedLogs.size());
    }

}