public abstract with sharing class SObjectService {
    
    public abstract void updateObject(SObject record);
    public abstract void insertObject(SObject record);
    
    public virtual List<SObject> filterRecords(List<SObject> records, Map<String, Object> filters) {
        List<SObject> filteredSObjects = new List<SObject>();
                
        for(SObject record : records) {
            Boolean meetsCriteria = false;

            for(String filter : filters.keySet()) {

                if(
                    filters.get(filter) instanceof Integer && 
                    record.get(filter) != null && 
                    (Decimal) record.get(filter) >= (Integer) filters.get(filter)
                ) {
                    meetsCriteria = true;
                } else if (
                    filters.get(filter) instanceof String && 
                    record.get(filter) != null && 
                    record.get(filter) == filters.get(filter)
                ) {
                    meetsCriteria = true;
                } else {
                    meetsCriteria = false;
                    break;
                }
            }

            if(meetsCriteria) {
                filteredSObjects.add(record);
            } 
        }
        
        return filteredSObjects;
    }
    
}