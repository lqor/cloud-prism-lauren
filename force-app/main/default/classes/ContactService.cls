public with sharing class ContactService {

    public List<Contact> createTwoContactObjects(List<Account> twoAccounts) {
        if(twoAccounts.size() != 2) {
            return null;
        }

        List<Contact> twoContacts = new List<Contact>();
        Contact firstContact = new Contact();
        Contact secondContact = new Contact();

        firstContact.LastName = 'Miyazaki';
        firstContact.Sign_Up_Date__c = System.today();
        firstContact.AccountId = twoAccounts.get(0).Id;

        secondContact.LastName = 'Miyamoto';
        secondContact.Sign_Up_Date__c = System.today();
        secondContact.AccountId = twoAccounts.get(1).Id;

        twoContacts.add(firstContact);
        twoContacts.add(secondContact);

        return twoContacts;
    }

    public void insertContact(Contact contact) {
        insert contact;
    }

    public void insertContacts(List<Contact> contacts) {
        insert contacts;
    }

    public List<Contact> insertTwoContactsWithAccounts() {
        AccountService accountService = new AccountService();
        List<Account> twoAccounts = accountService.createTwoAccounts();
        accountService.insertAccounts(twoAccounts);

        List<Contact> twoContacts = createTwoContactObjects(twoAccounts);
        insertContacts(twoContacts);

        return twoContacts;
    }

    public void updateContacts(List<Contact> contacts) {
        update contacts;
    }

    public void updateContactsPhoneByAccount(Id accountId, String phoneNumber) {
        List<Contact> contacts = ContactQueries.queryContactsByAccountId(accountId);

        for(Contact contact : contacts) {
            contact.Phone = phoneNumber;
        }

        updateContacts(contacts);
    }

}