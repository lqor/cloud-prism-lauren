public with sharing class UserTableController {

    @AuraEnabled
    public static List<User> getUsers() {
        return [SELECT Id, Name, Email, Department, Phone, Title, ContactId FROM User WHERE IsActive = true];
    }

}