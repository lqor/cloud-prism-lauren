public virtual interface SObjectServiceInterface {

    Boolean validateObject(SObject record);
    void formatRecord(SObject record);
    
}