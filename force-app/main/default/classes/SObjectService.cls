public abstract with sharing class SObjectService {
    
    public abstract void updateObject(SObject record);
    
    public abstract void insertObject(SObject record);
    
    public virtual List<SObject> filterRecords(List<SObject> records, Map<String, Object> filters) {
        List<SObject> filteredSObjects = new List<SObject>();
        
        Set<SObject> filteredRecords = new Set<SObject>();
        
        for(SObject record : records) {
            
            for(String filter : filters.keySet()) {
                
                if(filters.get(filter) instanceof Integer) {
                    
                    if(record.get(filter) != null && (Decimal) record.get(filter) >= (Integer) filters.get(filter)) {
                        filteredRecords.add(record);
                    } else {
                        filteredRecords.remove(record);
                    }
                } else if (filters.get(filter) instanceof String) {
                    if(record.get(filter) != null) {
                        filteredRecords.add(record);
                    } else {
                        filteredRecords.remove(record);
                    }
                }
            }
        }
        filteredSObjects = new List<SObject>(filteredRecords);
        
        return filteredSObjects;
    }
    
}