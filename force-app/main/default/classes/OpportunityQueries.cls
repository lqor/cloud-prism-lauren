public with sharing class OpportunityQueries {

    public static final String CLOSED_LOST_OPP_STAGE = 'Closed Lost';


    public static List<Opportunity> queryOpportunitiesByStage(String stage) {
        return [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE StageName = :stage];
    }

    public static List<Opportunity> queryOpportunitiesByAmountAndStage(Integer amount, String stage) {
        return [SELECT Id, Name, Amount, StageName FROM Opportunity WHERE Amount >= :amount AND StageName = :stage];
    }

    public static List<Opportunity> queryOpportunitiesByCreatedDate(Date startDate, Date endDate) {
        return [
            SELECT Id, Name, CreatedDate
            FROM Opportunity
            WHERE CreatedDate >= :startDate AND CreatedDate <= :endDate
        ];
    }

    public static List<Opportunity> queryOpportunitiesByAmount(Integer amount) {
        return [SELECT Id, Name, Amount, StageName, Probability FROM Opportunity WHERE Amount >= :amount];
    }

    public static List<Opportunity> queryOpportunitiesByCloseDate(Date closeDate) {
        return [SELECT Id, Name, Amount, StageName, CloseDate  FROM Opportunity WHERE CloseDate = :closeDate];
    }

    public static List<Opportunity> queryOpportunityByAmount(Integer amount) {
        return [
            SELECT Id, Name, Amount, StageName, CloseDate, Probability
            FROM Opportunity 
            WHERE CloseDate < :pastDate AND StageName != :CLOSED_LOST_OPP_STAGE
        ];
    }

    public static List<Opportunity> queryOpportunitiesByAccountId(Id accountId) {
        return [SELECT AccountId, CloseDate FROM Opportunity WHERE AccountId = :accountId];
    }

}