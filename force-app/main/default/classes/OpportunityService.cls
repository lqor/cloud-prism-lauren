public with sharing class OpportunityService {

    public static final String PROSPECTING_OPP_STAGE = 'Prospecting';
    public static final String QUALIFICATION_OPP_STAGE = 'Qualification';
    public static final String NEEDS_ANALYSIS_OPP_STAGE = 'Needs Analysis';
    public static final String VALUE_PROPOSITION_OPP_STAGE = 'Value Proposition';
    public static final String ID_DECISION_MAKERS_OPP_STAGE = 'Id. Decision Makers';
    public static final String PERCEPTION_ANALYSIS_OPP_STAGE = 'Perception Analysis';
    public static final String PROPOSAL_PRICE_QUOTE_OPP_STAGE = 'Proposal/Price Quote';
    public static final String NEGOTIATION_REVIEW_OPP_STAGE = 'Negotiation/Review';
    public static final String CLOSED_WON_OPP_STAGE = 'Closed Won';
    public static final String CLOSED_LOST_OPP_STAGE = 'Closed Lost';

    
    public Boolean isOpen(Opportunity opportunity) {
        return !opportunity.StageName.contains('Closed');
    }
    
    public Decimal calculateAmount(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        return firstOpportunity.Amount + secondOpportunity.Amount;
    }

    public Decimal calculateProbability(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        return (firstOpportunity.Probability + secondOpportunity.Probability) / 2;
    }
    
    public void doubleAmount(Opportunity opportunity) {
        opportunity.Amount *= 2;
    }
    
    public String getOpportunityDetails(Opportunity opportunity) {
        String name = 'The opportunity name is: ' + opportunity.Name;
        String amount = '. The opportunity amount is: ' + opportunity.Amount;
        String stage = '. The opportunity stage is: ' + opportunity.StageName + '.';
        String opportunityValues = name + amount + stage;

        return opportunityValues;
    } 

    public Opportunity softMerge(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        Opportunity returnOpportunity = new Opportunity();
        
        returnOpportunity.AccountId = firstOpportunity.AccountId;
        returnOpportunity.Amount = firstOpportunity.Amount;
        returnOpportunity.CloseDate = firstOpportunity.CloseDate;
        
        returnOpportunity.Name = secondOpportunity.Name;
        returnOpportunity.Probability = secondOpportunity.Probability;
        returnOpportunity.StageName = secondOpportunity.StageName;
        
        return returnOpportunity;
    }
    
    public Opportunity createNewOpportunity() {
        Opportunity opportunity = new Opportunity();
        
        opportunity.Name = 'Default Opportunity';
        opportunity.StageName = PROSPECTING_OPP_STAGE;
        opportunity.CloseDate = System.today().addDays(14);

        return opportunity;
    }

    public Opportunity createNewOpportunity(String name, String stageName, Date closeDate, Decimal amount, Id accountId) {
        Opportunity opportunity = new Opportunity();
        
        if(name == null) {
            name = 'Default Opportunity';
        }

        if(stageName == null) {
            stageName = PROSPECTING_OPP_STAGE;
        }

        if(closeDate == null) {
            closeDate = System.today().addDays(14);
        }

        if(amount == null) {
            amount = 250000;
        }

        opportunity.Name = name;
        opportunity.StageName = stageName;
        opportunity.CloseDate = CloseDate;
        opportunity.Amount = Amount;
        opportunity.AccountId = AccountId;

        return opportunity;
    }

    public Opportunity createOpportunityWithAccount(Account account) {
        Opportunity opportunity = new Opportunity();
        
        opportunity.AccountId = account.Id;
        opportunity.Amount = 2500;
        opportunity.CloseDate = System.today().addDays(14);
        opportunity.Name = account.Name + ' Installations';
        opportunity.Probability = 20;
        opportunity.StageName = NEEDS_ANALYSIS_OPP_STAGE;
        
        return opportunity;
    }

    // Lists & For Each Loops Exercises
    //--------------------------------------------------------------------------

    public List<Opportunity> createOpportunities(Integer n) {
        ListsPractice listsPractice = new ListsPractice();
        List<Opportunity> opportunities = new List<Opportunity>();
        
         for(Integer i = 0; i < n; i++) {
            Opportunity opportunity = createNewOpportunity();
            opportunity.Amount = listsPractice.getRandomNumberInRange(1000, 300000);
            opportunity.StageName = getRandomStageName();
            opportunities.add(opportunity);
        }

        return opportunities;
    }

    public List<Opportunity> filterOpportunitiesByStage(List<Opportunity> opportunities, String stageName) {
        List<Opportunity> filteredOpportunities = new List<Opportunity>();

        for(Opportunity opportunity : opportunities) {
            if(opportunity.StageName == stageName) {
                filteredOpportunities.add(opportunity);
            }
        }

        return filteredOpportunities;
    }

    public List<Opportunity> filterClosedWonOpportunities(List<Opportunity> opportunities) {
        List<Opportunity> closedWonOpportunities = new List<Opportunity>();

        for(Opportunity opportunity : opportunities) {
            if(opportunity.StageName == CLOSED_WON_OPP_STAGE) {
                closedWonOpportunities.add(opportunity);
            }
        }

        return closedWonOpportunities;
    }

    public Double calculateTotalRevenue(List<Opportunity> opportunities) {
        Double totalRevenue = 0.0;

        for(Opportunity opportunity : opportunities) {
            totalRevenue += opportunity.Amount;
        }

        return totalRevenue;
    }

    public String getRandomStageName() {
        ListsPractice listsPractice = new ListsPractice();
        List<String> stageNames = new List<String>();

        stageNames.add(PROSPECTING_OPP_STAGE);
        stageNames.add(QUALIFICATION_OPP_STAGE);
        stageNames.add(NEEDS_ANALYSIS_OPP_STAGE);
        stageNames.add(VALUE_PROPOSITION_OPP_STAGE);
        stageNames.add(ID_DECISION_MAKERS_OPP_STAGE);
        stageNames.add(PERCEPTION_ANALYSIS_OPP_STAGE);
        stageNames.add(PROPOSAL_PRICE_QUOTE_OPP_STAGE);
        stageNames.add(NEGOTIATION_REVIEW_OPP_STAGE);
        stageNames.add(CLOSED_WON_OPP_STAGE);
        stageNames.add(CLOSED_LOST_OPP_STAGE);

        return listsPractice.getRandomStringFromList(stageNames);
    }

    public void insertOpportunity(Opportunity opportunity) {
        insert opportunity;
    }

    public void insertOpportunities(List<Opportunity> opportunities) {
        insert opportunities;
    }

    public void updateOpportunities(List<Opportunity> opportunities) {
        update opportunities;
    }

    public void changeProbablityBasedOnAmount(Integer amount) {
        List<Opportunity> opportunities = OpportunityQueries.queryOpportunityByAmount(amount);

        for(Opportunity opportunity : opportunities) {
            opportunity.Probability *= 0.5;
        }

        updateOpportunities(opportunities);
    }   

    public void updateOpportunityCloseDates(String stageName, Integer daysToAdd) {
        List<Opportunity> opportunities = OpportunityQueries.queryOpportunitiesByStage(stageName);

        for(Opportunity opportunity : opportunities) {
            opportunity.CloseDate = opportunity.CloseDate.addDays(daysToAdd);
        }

        updateOpportunities(opportunities);
    }

    public void closeOldOpportunities(Integer amountOfMonths) {
        Date pastDate = System.today().addMonths(amountOfMonths);
        List<Opportunity> opportunities = OpportunityQueries.queryOpportunitiesByCloseDateAndNotClosedLost(pastDate);

        for(Opportunity opportunity : opportunities) {
            opportunity.StageName = CLOSED_LOST_OPP_STAGE;
        }

        updateOpportunities(opportunities);
    }

    public void addDaysToOpportunities(List<Id> accountIds, Integer amountOfDays) {
        List<Opportunity> opportunities = new List<Opportunity>();
        
        for(Id accountId : accountIds) {
            opportunities.addAll(OpportunityQueries.queryOpportunitiesByAccountId(accountId));
        }

        for(Opportunity opportunity : opportunities) {
            opportunity.CloseDate = opportunity.CloseDate.addDays(amountOfDays);
        }

        updateOpportunities(opportunities);
    }
    
}