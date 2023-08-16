public with sharing class ContactQueries {

    public static List<Contact> queryContactsByAccountId(Id accountId) {
        return [SELECT AccountId, Phone FROM Contact WHERE AccountId = :accountId];
    }

    public static List<Contact> queryContactsByAccountIds(Set<Id> accountIds) {
        return [SELECT Name, AccountId FROM Contact WHERE AccountId IN :accountIds];
    }

    public static List<Contact> queryContactsOfParticipantsById(Set<Id> contactIds) {
        return [SELECT Id, CanBookForOthers__c FROM Contact WHERE Id IN :contactIds];
    }

}