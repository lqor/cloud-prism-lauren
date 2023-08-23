import { LightningElement, track } from 'lwc';

export default class UserList extends LightningElement {
    @track users = [
        {
            Id: 1,
            Name: 'John Doe',
            Title: 'Admin',
            Username: 'john.doe@salesforce.com',
            Phone: '123-456-7890',
            Department: 'IT'
        },
        {
            Id: 2,
            Name: 'Jane Smith',
            Title: 'Developer',
            Username: 'jane.smith@salesforce.com',
            Phone: '987-654-3210',
            Department: 'Engineering'
        },
        {
            Id: 3,
            Name: 'Michael Brown',
            Title: 'Sales',
            Username: 'michael.brown@salesforce.com',
            Phone: '555-123-4567',
            Department: 'Sales'
        },
        {
            Id: 4,
            Name: 'Emily White',
            Title: 'HR Manager',
            Username: 'emily.white@salesforce.com',
            Phone: '555.987.6543',
            Department: 'Human Resources'
        },
        {
            Id: 5,
            Name: 'Samuel Green',
            Title: 'Support Specialist',
            Username: 'samuel.green@salesforce.com',
            Phone: '555-456-7890',
            Department: 'Support'
        },
        {
            Id: 6,
            Name: 'Linda Martinez',
            Title: 'Marketing',
            Username: 'linda.martinez@salesforce.com',
            Phone: '555-123-4567',
            Department: 'Marketing'
        },
        {
            Id: 7,
            Name: 'Robert Taylor',
            Title: 'Admin',
            Username: 'robert.taylor@salesforce.com',
            Phone: '555-321-4567',
            Department: 'IT'
        },
        {
            Id: 8,
            Name: 'Marie Anderson',
            Title: 'HR Assistant',
            Username: 'marie.anderson@salesforce.com',
            Phone: '555-654-3210',
            Department: 'Human Resources'
        },
        {
            Id: 9,
            Name: 'James Wilson',
            Title: 'Support Lead',
            Username: 'james.wilson@salesforce.com',
            Phone: '555-789-0123',
            Department: 'Support'
        },
        {
            Id: 10,
            Name: 'Patricia Jones',
            Title: 'Marketing',
            Username: 'patricia.jones@salesforce.com',
            Phone: '555-012-3456',
            Department: 'Marketing'
        }
    ];

    numberOfUsers = this.users.length;

    @track departments = [
        {
            Id: 1,
            Name: 'Marketing'
        },
        {
            Id: 2,
            Name: 'Sales'
        },
        {
            Id: 3,
            Name: 'IT'
        },
        {
            Id: 4,
            Name: 'Human Resources'
        },
        {
            Id: 5,
            Name: 'Support'
        },
        {
            Id: 6,
            Name: 'Engineering'
        }
    ];

    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );

        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    handleSubmit(event) {
        event.preventDefault();

        const fields = event.detail.fields;
        const newUser = {
            Id: this.users.length + 1,
            Name: fields.FirstName + ' ' + fields.LastName,
            Title: fields.Title,
            Username: fields.Email,
            Phone: fields.Phone,
            Department: fields.Department
        };

        this.users.push(newUser);
    }

}