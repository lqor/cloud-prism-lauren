import { LightningElement, track, api } from 'lwc';
import getUsers from '@salesforce/apex/UserTableController.getUsers';

import NAME from '@salesforce/schema/User.Name';
import EMAIL from '@salesforce/schema/User.Email';
import PHONE from '@salesforce/schema/User.Phone';
import DEPARTMENT from '@salesforce/schema/User.Department';
import TITLE from '@salesforce/schema/User.Title';
import CONTACT from '@salesforce/schema/User.ContactId';


export default class UserList extends LightningElement {
    fields = [NAME, EMAIL, PHONE, TITLE, DEPARTMENT, CONTACT];

    @api objectApiName = 'User';
    @track users = [];
    @track error;
    @track departments = [];
    @track uniqueDepts = new Set();

    connectedCallback() {
        this.loadUsers();
    }

    get numberOfUsers() {
        return this.users.length;
    }

    get numberOfDepartments() {
        return this.uniqueDepts.length;
    }

    handleClick(event) {
        event.preventDefault();
        const fields = event.detail.fields;

        const newUser = {
            Id: this.numberOfUsers + 1,
            Name: fields.FirstName + ' ' + fields.LastName,
            Title: fields.Title,
            Email: fields.Email,
            Phone: fields.Phone,
            Department: fields.Department
        };

        this.users.push(newUser);

        this.createDepartment(fields.Department, this.numberOfDepartments + 1);
    }

    loadUsers() {
        getUsers()
            .then(result => {
                this.users = result;

                this.users.forEach((user, index) => {
                    this.createDepartment(user.Department, index);
                });
            })
            .catch(error => {
                this.error = error;
            });
    }

    createDepartment(department, id) {
        if(department !== undefined && !this.uniqueDepts.has(department)) {
            const newDepartment = {
                Id: id,
                Name: department
            };

            this.departments.push(newDepartment);
            this.uniqueDepts.add(department);
        }
    }

}