public with sharing class OpportunityService {
    
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
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = System.today().addDays(14);

        return opportunity;
    }

    public Opportunity createNewOpportunity(String name, String stageName, Date closeDate, Decimal amount, Id accountId) {
        Opportunity opportunity = new Opportunity();
        
        if(name == null) {
            name = 'Default Opportunity';
        }

        if(stageName == null) {
            stageName = 'Prospecting';
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
        opportunity.StageName = 'Needs Analysis';
        
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
            if(opportunity.StageName == 'Closed Won') {
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

        stageNames.add('Prospecting');
        stageNames.add('Qualification');
        stageNames.add('Needs Analysis');
        stageNames.add('Value Proposition');
        stageNames.add('Id. Decision Makers');
        stageNames.add('Perception Analysis');
        stageNames.add('Proposal/Price Quote');
        stageNames.add('Negotiation/Review');
        stageNames.add('Closed Won');
        stageNames.add('Closed Lost');

        return listsPractice.getRandomStringFromList(stageNames);
    }

    public void insertOpportunity(Opportunity opportunity) {
        insert opportunity;
    }
    
}