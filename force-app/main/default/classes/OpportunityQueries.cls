public with sharing class OpportunityQueries {

    public static List<Opportunity> queryOpportunitiesByStage(String stage) {
        return [
            SELECT Id, Name, StageName
            FROM Opportunity
            WHERE StageName = :stage
        ];
    }

    public static List<Opportunity> queryOpportunitiesByAmountAndStage(Integer amount, String stage) {
        return [
            SELECT Id, Name, Amount, StageName
            FROM Opportunity
            WHERE Amount >= :amount AND StageName = :stage
        ];
    }

    public static List<Opportunity> queryOpportunitiesByCreatedDate(Date startDate, Date endDate) {
        return [
            SELECT Id, Name, CreatedDate
            FROM Opportunity
            WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate
        ];
    }

    public static List<Opportunity> queryOpportunitiesByAmount(Integer amount) {
        return [
            SELECT Id, Name, Amount, StageName 
            FROM Opportunity
            WHERE Amount >= :amount
        ];
    }

    public static List<Opportunity> queryOpportunitiesByCloseDate(Date closeDate) {
        return [
            SELECT Id, Name, Amount, StageName, CloseDate 
            FROM Opportunity
            WHERE CloseDate = :closeDate
        ];
    }

    public static List<Opportunity> queryOpportunityByAmount(Integer amount) {
        return [
            SELECT Id, Name, Amount, StageName, CloseDate, Probability
            FROM Opportunity 
            WHERE Amount < :amount 
        ];
    }
}