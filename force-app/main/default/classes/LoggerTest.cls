@IsTest
public with sharing class LoggerTest {

    @TestSetup
    static void setup() {
    }

    @IsTest
    static void logException_UnitTest() {
        try {
            Participant__c participant = [SELECT Id FROM Participant__c WHERE Id = NULL];
        } catch(Exception e) {
            Logger logger = new Logger();
            logger.logException(e);
        }

        ErrorLog__c insertedLog = [
            SELECT Id, ClassName__c, MethodName__c, ExceptionType__c, ExceptionMessage__c, LineNumber__c
            FROM ErrorLog__c LIMIT 1
        ];
        Assert.isNotNull(insertedLog);
        Assert.isTrue(insertedLog.ClassName__c.contains('LoggerTest'));
        Assert.isTrue(insertedLog.MethodName__c.contains('logException_UnitTest'));
        Assert.areEqual(11, insertedLog.LineNumber__c);
    }

}