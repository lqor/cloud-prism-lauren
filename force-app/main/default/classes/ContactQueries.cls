public with sharing class ContactQueries {

    public static List<Contact> queryContactsByAccountId(Id accountId) {
        return [SELECT AccountId, Phone FROM Contact WHERE AccountId = :accountId];
    }

}