public with sharing class ContactService extends SObjectService implements SObjectServiceInterface {
    
    public List<Contact> createTwoContactObjects(List<Account> twoAccounts) {
        if(twoAccounts.size() != 2) {
            return null;
        }
        
        List<Contact> twoContacts = new List<Contact>();
        Contact firstContact = new Contact();
        Contact secondContact = new Contact();
        
        firstContact.LastName = 'Miyazaki';
        firstContact.AccountId = twoAccounts.get(0).Id;
        
        secondContact.LastName = 'Miyamoto';
        secondContact.AccountId = twoAccounts.get(1).Id;
        
        twoContacts.add(firstContact);
        twoContacts.add(secondContact);
        
        return twoContacts;
    }
    
    public List<Contact> insertTwoContactsWithAccounts() {
        AccountService accountService = new AccountService();
        List<Account> twoAccounts = accountService.createTwoAccounts();
        insert twoAccounts;
        
        List<Contact> twoContacts = createTwoContactObjects(twoAccounts);
        insert twoContacts;
        
        return twoContacts;
    }
    
    public void updateContactsPhoneByAccount(Id accountId, String phoneNumber) {
        List<Contact> contacts = ContactQueries.queryContactsByAccountId(accountId);
        
        for(Contact contact : contacts) {
            contact.Phone = phoneNumber;
        }
        
        update contacts;
    }
    
    public Boolean validateObject(SObject record) {
        if(record instanceof Contact) {
            Contact contact = (Contact) record;
            return contact.LastName != null;
        }
        
        return false;
    }
    
    public void formatRecord(SObject record) {
        if(record instanceof Contact) {
            Contact contact = (Contact) record;
            
            List<String> splitFirstNames = new List<String>(contact.FirstName.split(' '));
            List<String> splitLastNames = new List<String>(contact.LastName.split(' '));
            
            String formattedFirstName = '';
            String formattedLastName = '';
            String firstLetterFirstName = '';
            String firstLetterLastName = '';
            String trimmedFirstName = '';
            String trimmedLastName = '';
            
            for(String firstName : splitFirstNames) {
                trimmedFirstName = firstName.trim();
                
                if(trimmedFirstName.length() > 1) {
                    firstLetterFirstName = trimmedFirstName.substring(0,1);
                } else if(trimmedFirstName.length() == 1) {
                    firstLetterFirstName = trimmedFirstName;
                } else {
                    continue;
                }
                
                if(firstLetterFirstName.isAllLowerCase()) {
                    formattedFirstName += trimmedFirstName.capitalize() + ' ';
                } else {
                    formattedFirstName += trimmedFirstName + ' ';
                }
            }
            
            for(String lastName : splitLastNames) {
                trimmedLastName = lastName.trim();
                
                if(trimmedLastName.length() > 1) {
                    firstLetterLastName = trimmedLastName.substring(0,1);
                } else if(trimmedLastName.length() == 1) {
                    firstLetterLastName = trimmedLastName;
                } else {
                    continue;
                }
                
                if(firstLetterLastName.isAllLowerCase()) {
                    formattedLastName += trimmedLastName.capitalize() + ' ';
                } else {
                    formattedLastName += trimmedLastName + ' ';
                }
            }
            
            contact.FirstName = formattedFirstName.trim();
            contact.LastName = formattedLastName.trim();
        }
    }
    
    public override void updateObject(SObject record) {
        if(record == null || !(record instanceof Contact)) {
            return;
        }
        
        if(validateObject(record)) {
            update record;
        }
    }
    
    public override void insertObject(SObject record) {
        if(record == null || !(record instanceof Contact)) {
            return;
        }
        
        if(validateObject(record)) {
            insert record;
        }
    }
    
}