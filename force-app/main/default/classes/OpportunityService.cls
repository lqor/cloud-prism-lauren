public with sharing class OpportunityService extends SObjectService implements SObjectServiceInterface {
    
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
        if(
            firstOpportunity == null || 
            secondOpportunity == null || 
            firstOpportunity.Amount == null || 
            secondOpportunity.Amount == null
        ) {
            return 0.0;
        }
        
        return firstOpportunity.Amount + secondOpportunity.Amount;
    }
    
    public Decimal calculateProbability(Opportunity firstOpportunity, Opportunity secondOpportunity) {
        if(
            firstOpportunity == null || 
            secondOpportunity == null ||
            firstOpportunity.Probability == null || 
            secondOpportunity.Probability == null
        ) {
            return 0.0;
        }
        
        return (firstOpportunity.Probability + secondOpportunity.Probability) / 2.0;
    }
    
    public void doubleAmount(Opportunity opportunity) {
        if(opportunity == null || opportunity.Amount == null) {
            return;
        }
        
        opportunity.Amount *= 2;
    }
    
    public String getOpportunityDetails(Opportunity opportunity) {
        if(opportunity == null) {
            return '';
        }
        
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
    
    public void changeProbablityBasedOnAmount(Integer amount) {
        List<Opportunity> opportunities = OpportunityQueries.queryOpportunitiesByAmount(amount);
        
        for(Opportunity opportunity : opportunities) {
            opportunity.Probability *= 0.5;
        }
        
        update opportunities;
    }   
    
    public void updateOpportunityCloseDates(String stageName, Integer daysToAdd) {
        List<Opportunity> opportunities = OpportunityQueries.queryOpportunitiesByStage(stageName);
        
        for(Opportunity opportunity : opportunities) {
            opportunity.CloseDate = opportunity.CloseDate.addDays(daysToAdd);
        }
        
        update opportunities;
    }
    
    public void closeOldOpportunities(Integer amountOfMonths) {
        Date pastDate = System.today().addMonths(amountOfMonths);
        List<Opportunity> opportunities = OpportunityQueries.queryOpportunitiesByCloseDateAndNotClosedLost(pastDate);
        
        for(Opportunity opportunity : opportunities) {
            opportunity.StageName = CLOSED_LOST_OPP_STAGE;
        }
        
        update opportunities;   
    }
    
    /** */
    public void addDaysToOpportunities(List<Id> accountIds, Integer amountOfDays) {
        if(accountIds == null || accountIds.size() == 0 || amountOfDays == null || amountOfDays == 0) {
            return;
        }
        
        List<Opportunity> opportunities = OpportunityQueries.queryOpportunitiesByAccountId(accountIds);
        
        for(Opportunity opportunity : opportunities) {
            opportunity.CloseDate = opportunity.CloseDate.addDays(amountOfDays);
        }
        
        update opportunities;
    }
    
    public Map<String, Integer> summarizeOpportunityStages(List<Opportunity> opportunities) {
        Map<String, Integer> opportunitiesByStage = new Map<String, Integer>();
        
        for(Opportunity opportunity : opportunities) {
            if(opportunitiesByStage.containsKey(opportunity.StageName)) {
                opportunitiesByStage.put(opportunity.StageName, opportunitiesByStage.get(opportunity.StageName) + 1);
            } else {
                opportunitiesByStage.put(opportunity.StageName, 1);
            }
        }
        
        return opportunitiesByStage;
    }
    
    public Map<Id, Integer> countOpportunitiesPerAccount(List<Opportunity> opportunities) {
        Map<Id, Integer> opportunitiesPerAccount = new Map<Id, Integer>();
        
        for(Opportunity opportunity : opportunities) {
            if(opportunitiesPerAccount.containsKey(opportunity.AccountId)) {
                opportunitiesPerAccount.put(opportunity.AccountId, opportunitiesPerAccount.get(opportunity.AccountId) + 1);
            } else {
                opportunitiesPerAccount.put(opportunity.AccountId, 1);
            }
        }
        
        return opportunitiesPerAccount;
    }
    
    public Boolean validateObject(SObject record) {
        if(record instanceof Opportunity) {
            Opportunity opportunity = (Opportunity) record;
            
            return opportunity.Name != null && opportunity.StageName != null && opportunity.CloseDate != null;
        }
        
        return false;
    }
    
    public void formatRecord(SObject record) {
        if(record instanceof Opportunity) {
            Opportunity opportunity = (Opportunity) record;
            
            List<String> splitNames = new List<String>(opportunity.Name.split(' '));
            String formattedName = '';
            String firstLetter = '';
            String trimmedName = '';
            
            for(String name : splitNames) {
                trimmedName = name.trim();
                
                if(trimmedName.length() > 1) {
                    firstLetter = trimmedName.substring(0,1);
                } else if(trimmedName.length() == 1) {
                    firstLetter = trimmedName;
                } else {
                    continue;
                }
                
                if(firstLetter.isAllLowerCase()) {
                    formattedName += trimmedName.capitalize() + ' ';
                } else {
                    formattedName += trimmedName + ' ';
                }
            }
            
            opportunity.Name = formattedName.trim();
        }
    }
    
    public override void updateObject(SObject record) {
        if(record == null || !(record instanceof Opportunity)) {
            return;
        }
        
        if(validateObject(record)) {
            update record;
        }
    }
    
    public override void insertObject(SObject record) {
        if(record == null || !(record instanceof Opportunity)) {
            return;
        }
        
        if(validateObject(record)) {
            insert record;
        }
    }
    
}